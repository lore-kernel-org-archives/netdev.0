From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Thu, 22 May 2003 03:40:58 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030522.034058.71558626.davem@redhat.com>
References: <20030520.173607.88482742.davem@redhat.com>
	<20030522084003.GA22613@netnation.com>
	<20030522.015815.91322249.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: sim@netnation.com
In-Reply-To: <20030522.015815.91322249.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "David S. Miller" <davem@redhat.com>
   Date: Thu, 22 May 2003 01:58:15 -0700 (PDT)
   
   Alexey, I will try to make something...
   
Simon (and others who want to benchmark :-), give this patch below a
try.

It applies cleanly to both 2.4.x and 2.5.x kernels.

Alexey, note the funny inaccurate comment found here, it totally
invalidates "fast computer" comment found a few lines below this.

Actually, much of this code wants some major cleanups.  It is even
quite costly to do these "u32 struct" things, especially on RISC.
Alexey no longer makes major surgery in this area, so they may be
undone. :)

Next experiment can be to reimplement fn_hash() as:

#include <linux/jhash.h>

static fn_hash_idx_t fn_hash(fn_key_t key, struct fn_zone *fz)
{
        u32 h = ntohl(key.datum)>>(32 - fz->fz_order);
	jhash_1word(h, 0);
        h &= FZ_HASHMASK(fz);
        return *(fn_hash_idx_t*)&h;
}

or something like that.  It is assuming we find some problems
with hash distribution when using huge number of routes.  Someone
will need to add fib_hash lookup statistics in order to determine
this.

Anyways, testers please let us know the results.  Note you must
have CONFIG_IP_ROUTE_LARGE_TABLES (and thus CONFIG_IP_ADVANCED_ROUTER)
in order to even make use of this stuff.

Thanks.

--- net/ipv4/fib_hash.c.~1~	Thu May 22 02:47:17 2003
+++ net/ipv4/fib_hash.c	Thu May 22 03:27:12 2003
@@ -89,7 +89,7 @@
 	int		fz_nent;	/* Number of entries	*/
 
 	int		fz_divisor;	/* Hash divisor		*/
-	u32		fz_hashmask;	/* (1<<fz_divisor) - 1	*/
+	u32		fz_hashmask;	/* (fz_divisor - 1)	*/
 #define FZ_HASHMASK(fz)	((fz)->fz_hashmask)
 
 	int		fz_order;	/* Zone order		*/
@@ -149,7 +149,30 @@
 
 static rwlock_t fib_hash_lock = RW_LOCK_UNLOCKED;
 
-#define FZ_MAX_DIVISOR 1024
+#define FZ_MAX_DIVISOR ((PAGE_SIZE<<MAX_ORDER) / sizeof(struct fib_node *))
+
+static unsigned long size_to_order(unsigned long size)
+{
+	unsigned long order;
+
+	for (order = 0; order < MAX_ORDER; order++) {
+		if ((PAGE_SIZE << order) >= size)
+			break;
+	}
+	return order;
+}
+
+static struct fib_node **fz_hash_alloc(int divisor)
+{
+	unsigned long size = divisor * sizeof(struct fib_node *);
+
+	if (divisor <= 1024) {
+		return kmalloc(size, GFP_KERNEL);
+	} else {
+		return (struct fib_node **)
+			__get_free_pages(GFP_KERNEL, size_to_order(size));
+	}
+}
 
 #ifdef CONFIG_IP_ROUTE_LARGE_TABLES
 
@@ -174,6 +197,15 @@
 	}
 }
 
+static void fz_hash_free(struct fib_node **hash, int divisor)
+{
+	if (divisor <= 1024)
+		kfree(hash);
+	else
+		free_pages((unsigned long) hash,
+			   size_to_order(divisor * sizeof(struct fib_node *)));
+}
+
 static void fn_rehash_zone(struct fn_zone *fz)
 {
 	struct fib_node **ht, **old_ht;
@@ -185,24 +217,30 @@
 	switch (old_divisor) {
 	case 16:
 		new_divisor = 256;
-		new_hashmask = 0xFF;
 		break;
 	case 256:
 		new_divisor = 1024;
-		new_hashmask = 0x3FF;
 		break;
 	default:
-		printk(KERN_CRIT "route.c: bad divisor %d!\n", old_divisor);
-		return;
+		if ((old_divisor << 1) > FZ_MAX_DIVISOR) {
+			printk(KERN_CRIT "route.c: bad divisor %d!\n", old_divisor);
+			return;
+		}
+		new_divisor = (old_divisor << 1);
+		break;
 	}
+
+	new_hashmask = (new_divisor - 1);
+
 #if RT_CACHE_DEBUG >= 2
 	printk("fn_rehash_zone: hash for zone %d grows from %d\n", fz->fz_order, old_divisor);
 #endif
 
-	ht = kmalloc(new_divisor*sizeof(struct fib_node*), GFP_KERNEL);
+	ht = fz_hash_alloc(new_divisor);
 
 	if (ht)	{
 		memset(ht, 0, new_divisor*sizeof(struct fib_node*));
+
 		write_lock_bh(&fib_hash_lock);
 		old_ht = fz->fz_hash;
 		fz->fz_hash = ht;
@@ -210,7 +248,8 @@
 		fz->fz_divisor = new_divisor;
 		fn_rebuild_zone(fz, old_ht, old_divisor);
 		write_unlock_bh(&fib_hash_lock);
-		kfree(old_ht);
+
+		fz_hash_free(old_ht, old_divisor);
 	}
 }
 #endif /* CONFIG_IP_ROUTE_LARGE_TABLES */
@@ -233,12 +272,11 @@
 	memset(fz, 0, sizeof(struct fn_zone));
 	if (z) {
 		fz->fz_divisor = 16;
-		fz->fz_hashmask = 0xF;
 	} else {
 		fz->fz_divisor = 1;
-		fz->fz_hashmask = 0;
 	}
-	fz->fz_hash = kmalloc(fz->fz_divisor*sizeof(struct fib_node*), GFP_KERNEL);
+	fz->fz_hashmask = (fz->fz_divisor - 1);
+	fz->fz_hash = fz_hash_alloc(fz->fz_divisor);
 	if (!fz->fz_hash) {
 		kfree(fz);
 		return NULL;
@@ -468,7 +506,7 @@
 		return err;
 
 #ifdef CONFIG_IP_ROUTE_LARGE_TABLES
-	if (fz->fz_nent > (fz->fz_divisor<<2) &&
+	if (fz->fz_nent > (fz->fz_divisor<<1) &&
 	    fz->fz_divisor < FZ_MAX_DIVISOR &&
 	    (z==32 || (1<<z) > fz->fz_divisor))
 		fn_rehash_zone(fz);
