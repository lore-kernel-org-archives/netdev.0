From: "David S. Miller" <davem@davemloft.net>
Subject: [3/6]: Move neigh hash masks
Date: Thu, 23 Sep 2004 22:49:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923224957.624361a6.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: laforge@gnumonks.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This actually moves the mask macros into
net/core/neighbour.c

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/23 16:47:26-07:00 davem@nuts.davemloft.net 
#   [NET]: Privatize {P,}NEIGH_HASHMASK.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/core/neighbour.c
#   2004/09/23 16:46:50-07:00 davem@nuts.davemloft.net +23 -0
#   [NET]: Privatize {P,}NEIGH_HASHMASK.
# 
# include/net/neighbour.h
#   2004/09/23 16:46:50-07:00 davem@nuts.davemloft.net +2 -5
#   [NET]: Privatize {P,}NEIGH_HASHMASK.
# 
diff -Nru a/include/net/neighbour.h b/include/net/neighbour.h
--- a/include/net/neighbour.h	2004-09-23 22:26:24 -07:00
+++ b/include/net/neighbour.h	2004-09-23 22:26:24 -07:00
@@ -140,9 +140,6 @@
 	u8			key[0];
 };
 
-#define NEIGH_HASHMASK		0x1F
-#define PNEIGH_HASHMASK		0xF
-
 /*
  *	neighbour table manipulation
  */
@@ -176,8 +173,8 @@
 	struct neigh_parms	*parms_list;
 	kmem_cache_t		*kmem_cachep;
 	struct neigh_statistics	stats;
-	struct neighbour	*hash_buckets[NEIGH_HASHMASK+1];
-	struct pneigh_entry	*phash_buckets[PNEIGH_HASHMASK+1];
+	struct neighbour	**hash_buckets;
+	struct pneigh_entry	**phash_buckets;
 };
 
 /* flags for neigh_update() */
diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2004-09-23 22:26:24 -07:00
+++ b/net/core/neighbour.c	2004-09-23 22:26:24 -07:00
@@ -47,6 +47,9 @@
 #define NEIGH_PRINTK2 NEIGH_PRINTK
 #endif
 
+#define NEIGH_HASHMASK		0x1F
+#define PNEIGH_HASHMASK		0xF
+
 static void neigh_timer_handler(unsigned long arg);
 #ifdef CONFIG_ARPD
 static void neigh_app_notify(struct neighbour *n);
@@ -1205,6 +1208,7 @@
 void neigh_table_init(struct neigh_table *tbl)
 {
 	unsigned long now = jiffies;
+	unsigned long hsize, phsize;
 
 	atomic_set(&tbl->parms.refcnt, 1);
 	INIT_RCU_HEAD(&tbl->parms.rcu_head);
@@ -1220,6 +1224,18 @@
 	if (!tbl->kmem_cachep)
 		panic("cannot create neighbour cache");
 
+	hsize = (NEIGH_HASHMASK + 1) * sizeof(struct neighbour *);
+	tbl->hash_buckets = kmalloc(hsize, GFP_KERNEL);
+
+	phsize = (PNEIGH_HASHMASK + 1) * sizeof(struct pneigh_entry *);
+	tbl->phash_buckets = kmalloc(phsize, GFP_KERNEL);
+
+	if (!tbl->hash_buckets || !tbl->phash_buckets)
+		panic("cannot allocate neighbour cache hashes");
+
+	memset(tbl->hash_buckets, 0, hsize);
+	memset(tbl->phash_buckets, 0, phsize);
+
 	tbl->lock	       = RW_LOCK_UNLOCKED;
 	init_timer(&tbl->gc_timer);
 	tbl->gc_timer.data     = (unsigned long)tbl;
@@ -1260,6 +1276,13 @@
 		}
 	}
 	write_unlock(&neigh_tbl_lock);
+
+	kfree(tbl->hash_buckets);
+	tbl->hash_buckets = NULL;
+
+	kfree(tbl->phash_buckets);
+	tbl->phash_buckets = NULL;
+
 	return 0;
 }
 
