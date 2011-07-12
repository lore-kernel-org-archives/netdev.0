From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Inline neigh binding.
Date: Tue, 12 Jul 2011 01:44:24 -0700 (PDT)
Message-ID: <20110712.014424.120003225201174608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42458 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737Ab1GLIo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 04:44:26 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6C8iPlR017622
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 01:44:25 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Get rid of all of the useless and costly indirection
by doing the neigh hash table lookup directly inside
of the neighbour binding.

Rename from arp_bind_neighbour to rt_bind_neighbour.

Use new helpers {__,}ipv4_neigh_lookup()

In rt_bind_neighbour() get rid of useless tests which
are never true in the context this function is called,
namely dev is never NULL and the dst->neighbour is
always NULL.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/arp.h |   33 ++++++++++++++++++++++++++++++++-
 net/ipv4/arp.c    |   24 ------------------------
 net/ipv4/route.c  |   30 +++++++++++++++++++++++++++---
 3 files changed, 59 insertions(+), 28 deletions(-)

diff --git a/include/net/arp.h b/include/net/arp.h
index 723bde5..5e669e6 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -15,6 +15,38 @@ static inline u32 arp_hashfn(u32 key, const struct net_device *dev, u32 hash_rnd
 	return val * hash_rnd;
 }
 
+static inline struct neighbour *__ipv4_neigh_lookup(struct neigh_table *tbl, struct net_device *dev, u32 key)
+{
+	struct neigh_hash_table *nht;
+	struct neighbour *n;
+	u32 hash_val;
+
+	rcu_read_lock_bh();
+	nht = rcu_dereference_bh(tbl->nht);
+	hash_val = arp_hashfn(key, dev, nht->hash_rnd) >> (32 - nht->hash_shift);
+	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
+	     n != NULL;
+	     n = rcu_dereference_bh(n->next)) {
+		if (n->dev == dev && *(u32 *)n->primary_key == key) {
+			if (!atomic_inc_not_zero(&n->refcnt))
+				n = NULL;
+			break;
+		}
+	}
+	rcu_read_unlock_bh();
+
+	return n;
+}
+
+static inline struct neighbour *ipv4_neigh_lookup(struct neigh_table *tbl, struct net_device *dev, const __be32 *pkey)
+{
+	struct neighbour *n = __ipv4_neigh_lookup(tbl, dev,
+						  *(__force u32 *)pkey);
+	if (n)
+		return n;
+	return neigh_create(tbl, pkey, dev);
+}
+
 extern void	arp_init(void);
 extern int	arp_find(unsigned char *haddr, struct sk_buff *skb);
 extern int	arp_ioctl(struct net *net, unsigned int cmd, void __user *arg);
@@ -22,7 +54,6 @@ extern void     arp_send(int type, int ptype, __be32 dest_ip,
 			 struct net_device *dev, __be32 src_ip,
 			 const unsigned char *dest_hw,
 			 const unsigned char *src_hw, const unsigned char *th);
-extern int	arp_bind_neighbour(struct dst_entry *dst);
 extern int	arp_mc_map(__be32 addr, u8 *haddr, struct net_device *dev, int dir);
 extern void	arp_ifdown(struct net_device *dev);
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 4412b57..3e55456 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -517,30 +517,6 @@ EXPORT_SYMBOL(arp_find);
 
 /* END OF OBSOLETE FUNCTIONS */
 
-int arp_bind_neighbour(struct dst_entry *dst)
-{
-	struct net_device *dev = dst->dev;
-	struct neighbour *n = dst->neighbour;
-
-	if (dev == NULL)
-		return -EINVAL;
-	if (n == NULL) {
-		__be32 nexthop = ((struct rtable *)dst)->rt_gateway;
-		if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
-			nexthop = 0;
-		n = __neigh_lookup_errno(
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-					 dev->type == ARPHRD_ATM ?
-					 clip_tbl_hook :
-#endif
-					 &arp_tbl, &nexthop, dev);
-		if (IS_ERR(n))
-			return PTR_ERR(n);
-		dst->neighbour = n;
-	}
-	return 0;
-}
-
 /*
  * Check if we can use proxy ARP for this path
  */
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a8ccd9b..c6388e8 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -108,6 +108,7 @@
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
+#include <net/atmclip.h>
 
 #define RT_FL_TOS(oldflp4) \
     ((u32)(oldflp4->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK)))
@@ -1006,6 +1007,29 @@ static int slow_chain_length(const struct rtable *head)
 	return length >> FRACT_BITS;
 }
 
+static int rt_bind_neighbour(struct rtable *rt)
+{
+	static const __be32 inaddr_any = 0;
+	struct net_device *dev = rt->dst.dev;
+	struct neigh_table *tbl = &arp_tbl;
+	const __be32 *nexthop;
+	struct neighbour *n;
+
+#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
+	if (dev->type == ARPHRD_ATM)
+		tbl = clip_tbl_hook;
+#endif
+	nexthop = &rt->rt_gateway;
+	if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
+		nexthop = &inaddr_any;
+	n = ipv4_neigh_lookup(tbl, dev, nexthop);
+	if (IS_ERR(n))
+		return PTR_ERR(n);
+	rt->dst.neighbour = n;
+
+	return 0;
+}
+
 static struct rtable *rt_intern_hash(unsigned hash, struct rtable *rt,
 				     struct sk_buff *skb, int ifindex)
 {
@@ -1042,7 +1066,7 @@ restart:
 
 		rt->dst.flags |= DST_NOCACHE;
 		if (rt->rt_type == RTN_UNICAST || rt_is_output_route(rt)) {
-			int err = arp_bind_neighbour(&rt->dst);
+			int err = rt_bind_neighbour(rt);
 			if (err) {
 				if (net_ratelimit())
 					printk(KERN_WARNING
@@ -1138,7 +1162,7 @@ restart:
 	   route or unicast forwarding path.
 	 */
 	if (rt->rt_type == RTN_UNICAST || rt_is_output_route(rt)) {
-		int err = arp_bind_neighbour(&rt->dst);
+		int err = rt_bind_neighbour(rt);
 		if (err) {
 			spin_unlock_bh(rt_hash_lock_addr(hash));
 
@@ -1599,7 +1623,7 @@ static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
 	rt->dst.neighbour = NULL;
 
 	rt->rt_gateway = peer->redirect_learned.a4;
-	if (arp_bind_neighbour(&rt->dst) ||
+	if (rt_bind_neighbour(rt) ||
 	    !(rt->dst.neighbour->nud_state & NUD_VALID)) {
 		if (rt->dst.neighbour)
 			neigh_event_send(rt->dst.neighbour, NULL);
-- 
1.7.5.4

