From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Thu, 12 Jun 2003 22:38:18 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030612.223818.74754074.davem@redhat.com>
References: <16102.9418.43884.336925@robur.slu.se>
	<20030610.115759.26513736.davem@redhat.com>
	<16103.27039.204333.952703@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralph+d@istop.com, ralph@istop.com, hadi@shell.cyberus.ca,
	xerox@foonet.net, sim@netnation.com, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org, kuznet@ms2.inr.ac.ru
Return-path: <linux-net-owner@vger.kernel.org>
To: Robert.Olsson@data.slu.se
In-Reply-To: <16103.27039.204333.952703@robur.slu.se>
List-Id: netdev.vger.kernel.org

   From: Robert Olsson <Robert.Olsson@data.slu.se>
   Date: Wed, 11 Jun 2003 19:40:47 +0200

   vma      samples  %-age       symbol name
   c023c038 107340   33.143      fn_hash_lookup

Ok, let's optimize our datastructures for how we actually
use them :-)  Also, fn_zone shrunk by 8 bytes.

Try this:

--- ./include/net/ip_fib.h.~1~	Thu Jun 12 22:18:33 2003
+++ ./include/net/ip_fib.h	Thu Jun 12 22:19:57 2003
@@ -89,13 +89,12 @@ struct fib_info
 struct fib_rule;
 #endif
 
-struct fib_result
-{
-	unsigned char	prefixlen;
-	unsigned char	nh_sel;
+struct fib_result {
+	struct fib_info *fi;
 	unsigned char	type;
 	unsigned char	scope;
-	struct fib_info *fi;
+	unsigned char	prefixlen;
+	unsigned char	nh_sel;
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	struct fib_rule	*r;
 #endif
--- ./net/ipv4/fib_hash.c.~1~	Thu Jun 12 21:47:11 2003
+++ ./net/ipv4/fib_hash.c	Thu Jun 12 22:08:27 2003
@@ -65,16 +65,15 @@ typedef struct {
 	u32	datum;
 } fn_hash_idx_t;
 
-struct fib_node
-{
-	struct fib_node		*fn_next;
-	struct fib_info		*fn_info;
-#define FIB_INFO(f)	((f)->fn_info)
+struct fib_node {
 	fn_key_t		fn_key;
 	u8			fn_tos;
-	u8			fn_type;
-	u8			fn_scope;
 	u8			fn_state;
+	u8			fn_scope;
+	u8			fn_type;
+	struct fib_node		*fn_next;
+	struct fib_info		*fn_info;
+#define FIB_INFO(f)	((f)->fn_info)
 };
 
 #define FN_S_ZOMBIE	1
@@ -82,29 +81,19 @@ struct fib_node
 
 static int fib_hash_zombies;
 
-struct fn_zone
-{
-	struct fn_zone	*fz_next;	/* Next not empty zone	*/
-	struct fib_node	**fz_hash;	/* Hash table pointer	*/
-	int		fz_nent;	/* Number of entries	*/
-
+struct fn_zone {
 	int		fz_divisor;	/* Hash divisor		*/
-	u32		fz_hashmask;	/* (fz_divisor - 1)	*/
-#define FZ_HASHMASK(fz)	((fz)->fz_hashmask)
-
+#define FZ_HASHMASK(fz)	((fz)->fz_divisor - 1)
 	int		fz_order;	/* Zone order		*/
-	u32		fz_mask;
-#define FZ_MASK(fz)	((fz)->fz_mask)
+#define FZ_MASK(fz)	(inet_make_mask((fz)->fz_order))
+	struct fib_node	**fz_hash;	/* Hash table pointer	*/
+	struct fn_zone	*fz_next;	/* Next not empty zone	*/
+	int		fz_nent;	/* Number of entries	*/
 };
 
-/* NOTE. On fast computers evaluation of fz_hashmask and fz_mask
-   can be cheaper than memory lookup, so that FZ_* macros are used.
- */
-
-struct fn_hash
-{
-	struct fn_zone	*fn_zones[33];
+struct fn_hash {
 	struct fn_zone	*fn_zone_list;
+	struct fn_zone	*fn_zones[33];
 };
 
 static __inline__ fn_hash_idx_t fn_hash(fn_key_t key, struct fn_zone *fz)
@@ -197,7 +186,6 @@ static void fn_rehash_zone(struct fn_zon
 {
 	struct fib_node **ht, **old_ht;
 	int old_divisor, new_divisor;
-	u32 new_hashmask;
 		
 	old_divisor = fz->fz_divisor;
 
@@ -217,8 +205,6 @@ static void fn_rehash_zone(struct fn_zon
 		break;
 	}
 
-	new_hashmask = (new_divisor - 1);
-
 #if RT_CACHE_DEBUG >= 2
 	printk("fn_rehash_zone: hash for zone %d grows from %d\n", fz->fz_order, old_divisor);
 #endif
@@ -231,7 +217,6 @@ static void fn_rehash_zone(struct fn_zon
 		write_lock_bh(&fib_hash_lock);
 		old_ht = fz->fz_hash;
 		fz->fz_hash = ht;
-		fz->fz_hashmask = new_hashmask;
 		fz->fz_divisor = new_divisor;
 		fn_rebuild_zone(fz, old_ht, old_divisor);
 		write_unlock_bh(&fib_hash_lock);
@@ -261,7 +246,6 @@ fn_new_zone(struct fn_hash *table, int z
 	} else {
 		fz->fz_divisor = 1;
 	}
-	fz->fz_hashmask = (fz->fz_divisor - 1);
 	fz->fz_hash = fz_hash_alloc(fz->fz_divisor);
 	if (!fz->fz_hash) {
 		kfree(fz);
@@ -269,7 +253,6 @@ fn_new_zone(struct fn_hash *table, int z
 	}
 	memset(fz->fz_hash, 0, fz->fz_divisor*sizeof(struct fib_node*));
 	fz->fz_order = z;
-	fz->fz_mask = inet_make_mask(z);
 
 	/* Find the first not empty zone with more specific mask */
 	for (i=z+1; i<=32; i++)
@@ -312,10 +295,15 @@ fn_hash_lookup(struct fib_table *tb, con
 			if (f->fn_tos && f->fn_tos != flp->fl4_tos)
 				continue;
 #endif
-			f->fn_state |= FN_S_ACCESSED;
+			{
+				u8 state = f->fn_state;
 
-			if (f->fn_state&FN_S_ZOMBIE)
-				continue;
+				if (!(state & FN_S_ACCESSED))
+					f->fn_state = state | FN_S_ACCESSED;
+
+				if (state & FN_S_ZOMBIE)
+					continue;
+			}
 			if (f->fn_scope < flp->fl4_scope)
 				continue;
 
