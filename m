From: "David S. Miller" <davem@davemloft.net>
Subject: [4/6]: Add nodev neigh lookup for decnet
Date: Thu, 23 Sep 2004 22:50:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923225041.4a388eb0.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: laforge@gnumonks.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


It was the one and only tbl->hash() call site outside
of net/core/neighbour.c

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/23 16:52:29-07:00 davem@nuts.davemloft.net 
#   [NET]: Create neigh_lookup_nodev for decnet.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/decnet/dn_route.c
#   2004/09/23 16:51:55-07:00 davem@nuts.davemloft.net +1 -1
#   [NET]: Create neigh_lookup_nodev for decnet.
# 
# net/decnet/dn_neigh.c
#   2004/09/23 16:51:55-07:00 davem@nuts.davemloft.net +0 -21
#   [NET]: Create neigh_lookup_nodev for decnet.
# 
# net/core/neighbour.c
#   2004/09/23 16:51:55-07:00 davem@nuts.davemloft.net +18 -0
#   [NET]: Create neigh_lookup_nodev for decnet.
# 
# include/net/neighbour.h
#   2004/09/23 16:51:55-07:00 davem@nuts.davemloft.net +2 -0
#   [NET]: Create neigh_lookup_nodev for decnet.
# 
# include/net/dn_neigh.h
#   2004/09/23 16:51:55-07:00 davem@nuts.davemloft.net +0 -1
#   [NET]: Create neigh_lookup_nodev for decnet.
# 
diff -Nru a/include/net/dn_neigh.h b/include/net/dn_neigh.h
--- a/include/net/dn_neigh.h	2004-09-23 22:26:40 -07:00
+++ b/include/net/dn_neigh.h	2004-09-23 22:26:40 -07:00
@@ -18,7 +18,6 @@
 
 extern void dn_neigh_init(void);
 extern void dn_neigh_cleanup(void);
-extern struct neighbour *dn_neigh_lookup(struct neigh_table *tbl, const void *ptr);
 extern int dn_neigh_router_hello(struct sk_buff *skb);
 extern int dn_neigh_endnode_hello(struct sk_buff *skb);
 extern void dn_neigh_pointopoint_hello(struct sk_buff *skb);
diff -Nru a/include/net/neighbour.h b/include/net/neighbour.h
--- a/include/net/neighbour.h	2004-09-23 22:26:40 -07:00
+++ b/include/net/neighbour.h	2004-09-23 22:26:40 -07:00
@@ -189,6 +189,8 @@
 extern struct neighbour *	neigh_lookup(struct neigh_table *tbl,
 					     const void *pkey,
 					     struct net_device *dev);
+extern struct neighbour *	neigh_lookup_nodev(struct neigh_table *tbl,
+						   const void *pkey);
 extern struct neighbour *	neigh_create(struct neigh_table *tbl,
 					     const void *pkey,
 					     struct net_device *dev);
diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2004-09-23 22:26:40 -07:00
+++ b/net/core/neighbour.c	2004-09-23 22:26:40 -07:00
@@ -307,6 +307,23 @@
 	return n;
 }
 
+struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, const void *pkey)
+{
+	struct neighbour *n;
+	int key_len = tbl->key_len;
+	u32 hash_val = tbl->hash(pkey, NULL) & NEIGH_HASHMASK;
+
+	read_lock_bh(&tbl->lock);
+	for (n = tbl->hash_buckets[hash_val]; n; n = n->next) {
+		if (!memcmp(n->primary_key, pkey, key_len)) {
+			neigh_hold(n);
+			break;
+		}
+	}
+	read_unlock_bh(&tbl->lock);
+	return n;
+}
+
 struct neighbour *neigh_create(struct neigh_table *tbl, const void *pkey,
 			       struct net_device *dev)
 {
@@ -2068,6 +2085,7 @@
 EXPORT_SYMBOL(neigh_event_ns);
 EXPORT_SYMBOL(neigh_ifdown);
 EXPORT_SYMBOL(neigh_lookup);
+EXPORT_SYMBOL(neigh_lookup_nodev);
 EXPORT_SYMBOL(neigh_parms_alloc);
 EXPORT_SYMBOL(neigh_parms_release);
 EXPORT_SYMBOL(neigh_rand_reach_time);
diff -Nru a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
--- a/net/decnet/dn_neigh.c	2004-09-23 22:26:40 -07:00
+++ b/net/decnet/dn_neigh.c	2004-09-23 22:26:40 -07:00
@@ -359,27 +359,6 @@
  * basically does a neigh_lookup(), but without comparing the device
  * field. This is required for the On-Ethernet cache
  */
-struct neighbour *dn_neigh_lookup(struct neigh_table *tbl, const void *ptr)
-{
-	struct neighbour *neigh;
-	u32 hash_val;
-
-	hash_val = tbl->hash(ptr, NULL);
-
-	read_lock_bh(&tbl->lock);
-	for(neigh = tbl->hash_buckets[hash_val]; neigh != NULL; neigh = neigh->next) {
-		if (memcmp(neigh->primary_key, ptr, tbl->key_len) == 0) {
-			atomic_inc(&neigh->refcnt);
-			read_unlock_bh(&tbl->lock);
-			return neigh;
-		}
-	}
-	read_unlock_bh(&tbl->lock);
-
-	return NULL;
-}
-
-
 /*
  * Any traffic on a pointopoint link causes the timer to be reset
  * for the entry in the neighbour table.
diff -Nru a/net/decnet/dn_route.c b/net/decnet/dn_route.c
--- a/net/decnet/dn_route.c	2004-09-23 22:26:40 -07:00
+++ b/net/decnet/dn_route.c	2004-09-23 22:26:40 -07:00
@@ -996,7 +996,7 @@
 		 * here
 		 */
 		if (!try_hard) {
-			neigh = dn_neigh_lookup(&dn_neigh_table, &fl.fld_dst);
+			neigh = neigh_lookup_nodev(&dn_neigh_table, &fl.fld_dst);
 			if (neigh) {
 				if ((oldflp->oif && 
 				    (neigh->dev->ifindex != oldflp->oif)) ||
