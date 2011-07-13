From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Embed hh_cache inside of struct neighbour.
Date: Wed, 13 Jul 2011 04:17:52 -0700 (PDT)
Message-ID: <20110713.041752.36378059082416460.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50423 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964915Ab1GMLRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 07:17:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that there is a one-to-one correspondance between neighbour
and hh_cache entries, we no longer need:

1) dynamic allocation
2) attachment to dst->hh
3) refcounting

Initialization of the hh_cache entry is indicated by hh_len
being non-zero, and such initialization is always done with
the neighbour's lock held as a writer.

Signed-off-by: David S. Miller <davem@davemloft.net>
--

This passes a bunch of basic testing I've done, and shaves
a few seconds off of the udpflood test.

Eric, I tried to do something reasonable with the resulting
dst_entry layout wrt. the 64-byte alignment thing.  I'm open
to suggestions.

And also notice how we don't need that DST_NOCACHE test any more,
since we now don't do atomics or modify dst_entry state just to setup
the hh_cache entry.

I hadn't really thought about this aspect of DST_NOCACHE before, but
it means that with the routing cache removal patches applied, HH
caching was completely disabled :-/ Well, at least now that will be
fixed :))

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7538237..5ccc0cb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -252,14 +252,7 @@ struct netdev_hw_addr_list {
 	netdev_hw_addr_list_for_each(ha, &(dev)->mc)
 
 struct hh_cache {
-	atomic_t	hh_refcnt;	/* number of users                   */
-/*
- * We want hh_output, hh_len, hh_lock and hh_data be a in a separate
- * cache line on SMP.
- * They are mostly read, but hh_refcnt may be changed quite frequently,
- * incurring cache line ping pongs.
- */
-	u16		hh_len ____cacheline_aligned_in_smp;
+	u16		hh_len;
 	u16		__pad;
 	int		(*hh_output)(struct sk_buff *skb);
 	seqlock_t	hh_lock;
@@ -273,12 +266,6 @@ struct hh_cache {
 	unsigned long	hh_data[HH_DATA_ALIGN(LL_MAX_HEADER) / sizeof(long)];
 };
 
-static inline void hh_cache_put(struct hh_cache *hh)
-{
-	if (atomic_dec_and_test(&hh->hh_refcnt))
-		kfree(hh);
-}
-
 /* Reserve HH_DATA_MOD byte aligned hard_header_len, but at least that much.
  * Alternative is:
  *   dev->hard_header_len ? (dev->hard_header_len +
diff --git a/include/net/dst.h b/include/net/dst.h
index e12ddfb..0dd7ccb 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -38,7 +38,6 @@ struct dst_entry {
 	unsigned long		expires;
 	struct dst_entry	*path;
 	struct neighbour	*neighbour;
-	struct hh_cache		*hh;
 #ifdef CONFIG_XFRM
 	struct xfrm_state	*xfrm;
 #else
@@ -47,6 +46,14 @@ struct dst_entry {
 	int			(*input)(struct sk_buff*);
 	int			(*output)(struct sk_buff*);
 
+	int			flags;
+#define DST_HOST		0x0001
+#define DST_NOXFRM		0x0002
+#define DST_NOPOLICY		0x0004
+#define DST_NOHASH		0x0008
+#define DST_NOCACHE		0x0010
+#define DST_NOCOUNT		0x0020
+
 	short			error;
 	short			obsolete;
 	unsigned short		header_len;	/* more space at head required */
@@ -62,7 +69,7 @@ struct dst_entry {
 	 * (L1_CACHE_SIZE would be too much)
 	 */
 #ifdef CONFIG_64BIT
-	long			__pad_to_align_refcnt[1];
+	long			__pad_to_align_refcnt[2];
 #endif
 	/*
 	 * __refcnt wants to be on a different cache line from
@@ -71,13 +78,6 @@ struct dst_entry {
 	atomic_t		__refcnt;	/* client references	*/
 	int			__use;
 	unsigned long		lastuse;
-	int			flags;
-#define DST_HOST		0x0001
-#define DST_NOXFRM		0x0002
-#define DST_NOPOLICY		0x0004
-#define DST_NOHASH		0x0008
-#define DST_NOCACHE		0x0010
-#define DST_NOCOUNT		0x0020
 	union {
 		struct dst_entry	*next;
 		struct rtable __rcu	*rt_next;
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 6fe8c2c..bd8f9f0 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -108,7 +108,7 @@ struct neighbour {
 	__u8			dead;
 	seqlock_t		ha_lock;
 	unsigned char		ha[ALIGN(MAX_ADDR_LEN, sizeof(unsigned long))];
-	struct hh_cache		*hh;
+	struct hh_cache		hh;
 	int			(*output)(struct sk_buff *skb);
 	const struct neigh_ops	*ops;
 	struct rcu_head		rcu;
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 56149ec..75ee421 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -343,14 +343,16 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+	struct neighbour *neigh;
 	struct dst_entry *dst;
 
 	skb->dev = bridge_parent(skb->dev);
 	if (!skb->dev)
 		goto free_skb;
 	dst = skb_dst(skb);
-	if (dst->hh) {
-		neigh_hh_bridge(dst->hh, skb);
+	neigh = dst->neighbour;
+	if (neigh->hh.hh_len) {
+		neigh_hh_bridge(&neigh->hh, skb);
 		skb->dev = nf_bridge->physindev;
 		return br_handle_frame_finish(skb);
 	} else if (dst->neighbour) {
diff --git a/net/core/dst.c b/net/core/dst.c
index 6135f36..4aacc14 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -172,7 +172,6 @@ void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
 	dst->expires = 0UL;
 	dst->path = dst;
 	dst->neighbour = NULL;
-	dst->hh = NULL;
 #ifdef CONFIG_XFRM
 	dst->xfrm = NULL;
 #endif
@@ -226,19 +225,13 @@ struct dst_entry *dst_destroy(struct dst_entry * dst)
 {
 	struct dst_entry *child;
 	struct neighbour *neigh;
-	struct hh_cache *hh;
 
 	smp_rmb();
 
 again:
 	neigh = dst->neighbour;
-	hh = dst->hh;
 	child = dst->child;
 
-	dst->hh = NULL;
-	if (hh)
-		hh_cache_put(hh);
-
 	if (neigh) {
 		dst->neighbour = NULL;
 		neigh_release(neigh);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index f879bb5..77a399f 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -297,6 +297,7 @@ static struct neighbour *neigh_alloc(struct neigh_table *tbl)
 	n->updated	  = n->used = now;
 	n->nud_state	  = NUD_NONE;
 	n->output	  = neigh_blackhole;
+	seqlock_init(&n->hh.hh_lock);
 	n->parms	  = neigh_parms_clone(&tbl->parms);
 	setup_timer(&n->timer, neigh_timer_handler, (unsigned long)n);
 
@@ -702,14 +703,11 @@ void neigh_destroy(struct neighbour *neigh)
 	if (neigh_del_timer(neigh))
 		printk(KERN_WARNING "Impossible event.\n");
 
-	hh = neigh->hh;
-	if (hh) {
-		neigh->hh = NULL;
-
+	hh = &neigh->hh;
+	if (hh->hh_len) {
 		write_seqlock_bh(&hh->hh_lock);
 		hh->hh_output = neigh_blackhole;
 		write_sequnlock_bh(&hh->hh_lock);
-		hh_cache_put(hh);
 	}
 
 	skb_queue_purge(&neigh->arp_queue);
@@ -737,8 +735,8 @@ static void neigh_suspect(struct neighbour *neigh)
 
 	neigh->output = neigh->ops->output;
 
-	hh = neigh->hh;
-	if (hh)
+	hh = &neigh->hh;
+	if (hh->hh_len)
 		hh->hh_output = neigh->ops->output;
 }
 
@@ -755,8 +753,8 @@ static void neigh_connect(struct neighbour *neigh)
 
 	neigh->output = neigh->ops->connected_output;
 
-	hh = neigh->hh;
-	if (hh)
+	hh = &neigh->hh;
+	if (hh->hh_len)
 		hh->hh_output = neigh->ops->hh_output;
 }
 
@@ -1017,7 +1015,7 @@ out_unlock_bh:
 }
 EXPORT_SYMBOL(__neigh_event_send);
 
-static void neigh_update_hhs(const struct neighbour *neigh)
+static void neigh_update_hhs(struct neighbour *neigh)
 {
 	struct hh_cache *hh;
 	void (*update)(struct hh_cache*, const struct net_device*, const unsigned char *)
@@ -1027,8 +1025,8 @@ static void neigh_update_hhs(const struct neighbour *neigh)
 		update = neigh->dev->header_ops->cache_update;
 
 	if (update) {
-		hh = neigh->hh;
-		if (hh) {
+		hh = &neigh->hh;
+		if (hh->hh_len) {
 			write_seqlock_bh(&hh->hh_lock);
 			update(hh, neigh->dev, neigh->ha);
 			write_sequnlock_bh(&hh->hh_lock);
@@ -1214,62 +1212,29 @@ struct neighbour *neigh_event_ns(struct neigh_table *tbl,
 }
 EXPORT_SYMBOL(neigh_event_ns);
 
-static inline bool neigh_hh_lookup(struct neighbour *n, struct dst_entry *dst)
-{
-	struct hh_cache *hh;
-
-	smp_rmb(); /* paired with smp_wmb() in neigh_hh_init() */
-	hh = n->hh;
-	if (hh) {
-		atomic_inc(&hh->hh_refcnt);
-		if (unlikely(cmpxchg(&dst->hh, NULL, hh) != NULL))
-			hh_cache_put(hh);
-		return true;
-	}
-	return false;
-}
-
 /* called with read_lock_bh(&n->lock); */
-static void neigh_hh_init(struct neighbour *n, struct dst_entry *dst,
-			  __be16 protocol)
+static void neigh_hh_init(struct neighbour *n, struct dst_entry *dst)
 {
-	struct hh_cache	*hh;
 	struct net_device *dev = dst->dev;
-
-	if (likely(neigh_hh_lookup(n, dst)))
-		return;
-
-	/* slow path */
-	hh = kzalloc(sizeof(*hh), GFP_ATOMIC);
-	if (!hh)
-		return;
-
-	seqlock_init(&hh->hh_lock);
-	atomic_set(&hh->hh_refcnt, 2);
-
-	if (dev->header_ops->cache(n, hh, protocol)) {
-		kfree(hh);
-		return;
-	}
+	__be16 prot = dst->ops->protocol;
+	struct hh_cache	*hh = &n->hh;
 
 	write_lock_bh(&n->lock);
 
-	/* must check if another thread already did the insert */
-	if (neigh_hh_lookup(n, dst)) {
-		kfree(hh);
+	/* Only one thread can come in here and initialize the
+	 * hh_cache entry.
+	 */
+	if (hh->hh_len)
+		goto end;
+
+	if (dev->header_ops->cache(n, hh, prot))
 		goto end;
-	}
 
 	if (n->nud_state & NUD_CONNECTED)
 		hh->hh_output = n->ops->hh_output;
 	else
 		hh->hh_output = n->ops->output;
 
-	smp_wmb(); /* paired with smp_rmb() in neigh_hh_lookup() */
-	n->hh	    = hh;
-
-	if (unlikely(cmpxchg(&dst->hh, NULL, hh) != NULL))
-		hh_cache_put(hh);
 end:
 	write_unlock_bh(&n->lock);
 }
@@ -1312,10 +1277,8 @@ int neigh_resolve_output(struct sk_buff *skb)
 		struct net_device *dev = neigh->dev;
 		unsigned int seq;
 
-		if (dev->header_ops->cache &&
-		    !dst->hh &&
-		    !(dst->flags & DST_NOCACHE))
-			neigh_hh_init(neigh, dst, dst->ops->protocol);
+		if (dev->header_ops->cache && !neigh->hh.hh_len)
+			neigh_hh_init(neigh, dst);
 
 		do {
 			seq = read_seqbegin(&neigh->ha_lock);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 54119d5..a621b96 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -182,6 +182,7 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	struct rtable *rt = (struct rtable *)dst;
 	struct net_device *dev = dst->dev;
 	unsigned int hh_len = LL_RESERVED_SPACE(dev);
+	struct neighbour *neigh;
 
 	if (rt->rt_type == RTN_MULTICAST) {
 		IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUTMCAST, skb->len);
@@ -203,11 +204,14 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 		skb = skb2;
 	}
 
-	if (dst->hh)
-		return neigh_hh_output(dst->hh, skb);
-	else if (dst->neighbour)
-		return dst->neighbour->output(skb);
-
+	neigh = dst->neighbour;
+	if (neigh) {
+		struct hh_cache *hh = &neigh->hh;
+		if (hh->hh_len)
+			return neigh_hh_output(hh, skb);
+		else
+			return dst->neighbour->output(skb);
+	}
 	if (net_ratelimit())
 		printk(KERN_DEBUG "ip_finish_output2: No header cache and no neighbour!\n");
 	kfree_skb(skb);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index c6388e8..a52bb74 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -426,9 +426,10 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 			(int)((dst_metric(&r->dst, RTAX_RTT) >> 3) +
 			      dst_metric(&r->dst, RTAX_RTTVAR)),
 			r->rt_key_tos,
-			r->dst.hh ? atomic_read(&r->dst.hh->hh_refcnt) : -1,
-			r->dst.hh ? (r->dst.hh->hh_output ==
-				       dev_queue_xmit) : 0,
+			-1,
+			(r->dst.neighbour ?
+			 (r->dst.neighbour->hh.hh_output ==
+			  dev_queue_xmit) : 0),
 			r->rt_spec_dst, &len);
 
 		seq_printf(seq, "%*s\n", 127 - len, "");
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9d4b165..f0f144c 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -100,6 +100,7 @@ static int ip6_finish_output2(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct net_device *dev = dst->dev;
+	struct neighbour *neigh;
 
 	skb->protocol = htons(ETH_P_IPV6);
 	skb->dev = dev;
@@ -134,11 +135,14 @@ static int ip6_finish_output2(struct sk_buff *skb)
 				skb->len);
 	}
 
-	if (dst->hh)
-		return neigh_hh_output(dst->hh, skb);
-	else if (dst->neighbour)
-		return dst->neighbour->output(skb);
-
+	neigh = dst->neighbour;
+	if (neigh) {
+		struct hh_cache *hh = &neigh->hh;
+		if (hh->hh_len)
+			return neigh_hh_output(hh, skb);
+		else
+			return dst->neighbour->output(skb);
+	}
 	IP6_INC_STATS_BH(dev_net(dst->dev),
 			 ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
 	kfree_skb(skb);
