From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 16/21] datapath: remove tunnel cache
Date: Thu, 24 May 2012 18:09:09 +0900
Message-ID: <1337850554-10339-17-git-send-email-horms@verge.net.au>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Cc: netdev@vger.kernel.org, Kyle Mestery <kmestery@cisco.com>,
	Simon Horman <horms@verge.net.au>
To: dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46713 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754567Ab2EXJJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 05:09:30 -0400
In-Reply-To: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As tunndevs no longer have a daddr the cache can no longer built in this way.
Furthermore, its not clear to me what the value of keeping the cache is in
the context of moving towards allowing use of in-tree tunnelling.

Cc: Kyle Mestery <kmestery@cisco.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 datapath/tunnel.c | 384 +++---------------------------------------------------
 datapath/tunnel.h |  52 --------
 2 files changed, 20 insertions(+), 416 deletions(-)

diff --git a/datapath/tunnel.c b/datapath/tunnel.c
index cdcb0a7..b997cb8 100644
--- a/datapath/tunnel.c
+++ b/datapath/tunnel.c
@@ -52,43 +52,9 @@
 #include "vport-generic.h"
 #include "vport-internal_dev.h"
 
-#ifdef NEED_CACHE_TIMEOUT
-/*
- * On kernels where we can't quickly detect changes in the rest of the system
- * we use an expiration time to invalidate the cache.  A shorter expiration
- * reduces the length of time that we may potentially blackhole packets while
- * a longer time increases performance by reducing the frequency that the
- * cache needs to be rebuilt.  A variety of factors may cause the cache to be
- * invalidated before the expiration time but this is the maximum.  The time
- * is expressed in jiffies.
- */
-#define MAX_CACHE_EXP HZ
-#endif
-
-/*
- * Interval to check for and remove caches that are no longer valid.  Caches
- * are checked for validity before they are used for packet encapsulation and
- * old caches are removed at that time.  However, if no packets are sent through
- * the tunnel then the cache will never be destroyed.  Since it holds
- * references to a number of system objects, the cache will continue to use
- * system resources by not allowing those objects to be destroyed.  The cache
- * cleaner is periodically run to free invalid caches.  It does not
- * significantly affect system performance.  A lower interval will release
- * resources faster but will itself consume resources by requiring more frequent
- * checks.  A longer interval may result in messages being printed to the kernel
- * message buffer about unreleased resources.  The interval is expressed in
- * jiffies.
- */
-#define CACHE_CLEANER_INTERVAL (5 * HZ)
-
-#define CACHE_DATA_ALIGN 16
 #define PORT_TABLE_SIZE  1024
 
 static struct hlist_head *port_table __read_mostly;
-static int port_table_count;
-
-static void cache_cleaner(struct work_struct *work);
-static DECLARE_DELAYED_WORK(cache_cleaner_wq, cache_cleaner);
 
 /*
  * These are just used as an optimization: they don't require any kind of
@@ -108,60 +74,17 @@ static unsigned int multicast_ports __read_mostly;
 #define rt_dst(rt) (rt->u.dst)
 #endif
 
-#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,1,0)
-static struct hh_cache *rt_hh(struct rtable *rt)
-{
-	struct neighbour *neigh = dst_get_neighbour_noref(&rt->dst);
-	if (!neigh || !(neigh->nud_state & NUD_CONNECTED) ||
-			!neigh->hh.hh_len)
-		return NULL;
-	return &neigh->hh;
-}
-#else
-#define rt_hh(rt) (rt_dst(rt).hh)
-#endif
-
 static struct vport *tnl_vport_to_vport(const struct tnl_vport *tnl_vport)
 {
 	return vport_from_priv(tnl_vport);
 }
 
-/* This is analogous to rtnl_dereference for the tunnel cache.  It checks that
- * cache_lock is held, so it is only for update side code.
- */
-static struct tnl_cache *cache_dereference(struct tnl_vport *tnl_vport)
-{
-	return rcu_dereference_protected(tnl_vport->cache,
-				 lockdep_is_held(&tnl_vport->cache_lock));
-}
-
-static void schedule_cache_cleaner(void)
-{
-	schedule_delayed_work(&cache_cleaner_wq, CACHE_CLEANER_INTERVAL);
-}
-
-static void free_cache(struct tnl_cache *cache)
-{
-	if (!cache)
-		return;
-
-	ovs_flow_put(cache->flow);
-	ip_rt_put(cache->rt);
-	kfree(cache);
-}
-
 static void free_config_rcu(struct rcu_head *rcu)
 {
 	struct tnl_mutable_config *c = container_of(rcu, struct tnl_mutable_config, rcu);
 	kfree(c);
 }
 
-static void free_cache_rcu(struct rcu_head *rcu)
-{
-	struct tnl_cache *c = container_of(rcu, struct tnl_cache, rcu);
-	free_cache(c);
-}
-
 static void assign_config_rcu(struct vport *vport,
 			      struct tnl_mutable_config *new_config)
 {
@@ -174,18 +97,6 @@ static void assign_config_rcu(struct vport *vport,
 	call_rcu(&old_config->rcu, free_config_rcu);
 }
 
-static void assign_cache_rcu(struct vport *vport, struct tnl_cache *new_cache)
-{
-	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
-	struct tnl_cache *old_cache;
-
-	old_cache = cache_dereference(tnl_vport);
-	rcu_assign_pointer(tnl_vport->cache, new_cache);
-
-	if (old_cache)
-		call_rcu(&old_cache->rcu, free_cache_rcu);
-}
-
 static unsigned int *find_port_pool(const struct tnl_mutable_config *mutable)
 {
 	bool is_multicast = ipv4_is_multicast(mutable->key.daddr);
@@ -223,13 +134,9 @@ static void port_table_add_port(struct vport *vport)
 	const struct tnl_mutable_config *mutable;
 	u32 hash;
 
-	if (port_table_count == 0)
-		schedule_cache_cleaner();
-
 	mutable = rtnl_dereference(tnl_vport->mutable);
 	hash = port_hash(&mutable->key);
 	hlist_add_head_rcu(&tnl_vport->hash_node, find_bucket(hash));
-	port_table_count++;
 
 	(*find_port_pool(rtnl_dereference(tnl_vport->mutable)))++;
 }
@@ -240,10 +147,6 @@ static void port_table_remove_port(struct vport *vport)
 
 	hlist_del_init_rcu(&tnl_vport->hash_node);
 
-	port_table_count--;
-	if (port_table_count == 0)
-		cancel_delayed_work_sync(&cache_cleaner_wq);
-
 	(*find_port_pool(rtnl_dereference(tnl_vport->mutable)))--;
 }
 
@@ -780,11 +683,6 @@ static void create_tunnel_header(const struct vport *vport,
 	tnl_vport->tnl_ops->build_header(vport, mutable, iph + 1);
 }
 
-static void *get_cached_header(const struct tnl_cache *cache)
-{
-	return (void *)cache + ALIGN(sizeof(struct tnl_cache), CACHE_DATA_ALIGN);
-}
-
 #ifdef HAVE_RT_GENID
 static inline int rt_genid(struct net *net)
 {
@@ -792,184 +690,6 @@ static inline int rt_genid(struct net *net)
 }
 #endif
 
-static bool check_cache_valid(const struct tnl_cache *cache,
-			      const struct tnl_mutable_config *mutable)
-{
-	struct hh_cache *hh;
-
-	if (!cache)
-		return false;
-
-	hh = rt_hh(cache->rt);
-	return hh &&
-#ifdef NEED_CACHE_TIMEOUT
-		time_before(jiffies, cache->expiration) &&
-#endif
-#ifdef HAVE_RT_GENID
-		rt_genid(dev_net(rt_dst(cache->rt).dev)) == cache->rt->rt_genid &&
-#endif
-#ifdef HAVE_HH_SEQ
-		hh->hh_lock.sequence == cache->hh_seq &&
-#endif
-		mutable->seq == cache->mutable_seq &&
-		(!ovs_is_internal_dev(rt_dst(cache->rt).dev) ||
-		(cache->flow && !cache->flow->dead));
-}
-
-static void __cache_cleaner(struct tnl_vport *tnl_vport)
-{
-	const struct tnl_mutable_config *mutable =
-			rcu_dereference(tnl_vport->mutable);
-	const struct tnl_cache *cache = rcu_dereference(tnl_vport->cache);
-
-	if (cache && !check_cache_valid(cache, mutable) &&
-	    spin_trylock_bh(&tnl_vport->cache_lock)) {
-		assign_cache_rcu(tnl_vport_to_vport(tnl_vport), NULL);
-		spin_unlock_bh(&tnl_vport->cache_lock);
-	}
-}
-
-static void cache_cleaner(struct work_struct *work)
-{
-	int i;
-
-	schedule_cache_cleaner();
-
-	rcu_read_lock();
-	for (i = 0; i < PORT_TABLE_SIZE; i++) {
-		struct hlist_node *n;
-		struct hlist_head *bucket;
-		struct tnl_vport *tnl_vport;
-
-		bucket = &port_table[i];
-		hlist_for_each_entry_rcu(tnl_vport, n, bucket, hash_node)
-			__cache_cleaner(tnl_vport);
-	}
-	rcu_read_unlock();
-}
-
-static void create_eth_hdr(struct tnl_cache *cache, struct hh_cache *hh)
-{
-	void *cache_data = get_cached_header(cache);
-	int hh_off;
-
-#ifdef HAVE_HH_SEQ
-	unsigned hh_seq;
-
-	do {
-		hh_seq = read_seqbegin(&hh->hh_lock);
-		hh_off = HH_DATA_ALIGN(hh->hh_len) - hh->hh_len;
-		memcpy(cache_data, (void *)hh->hh_data + hh_off, hh->hh_len);
-		cache->hh_len = hh->hh_len;
-	} while (read_seqretry(&hh->hh_lock, hh_seq));
-
-	cache->hh_seq = hh_seq;
-#else
-	read_lock(&hh->hh_lock);
-	hh_off = HH_DATA_ALIGN(hh->hh_len) - hh->hh_len;
-	memcpy(cache_data, (void *)hh->hh_data + hh_off, hh->hh_len);
-	cache->hh_len = hh->hh_len;
-	read_unlock(&hh->hh_lock);
-#endif
-}
-
-static struct tnl_cache *build_cache(struct vport *vport,
-				     const struct tnl_mutable_config *mutable,
-				     struct rtable *rt)
-{
-	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
-	struct tnl_cache *cache;
-	void *cache_data;
-	int cache_len;
-	struct hh_cache *hh;
-
-	if (!(mutable->flags & TNL_F_HDR_CACHE))
-		return NULL;
-
-	/*
-	 * If there is no entry in the ARP cache or if this device does not
-	 * support hard header caching just fall back to the IP stack.
-	 */
-
-	hh = rt_hh(rt);
-	if (!hh)
-		return NULL;
-
-	/*
-	 * If lock is contended fall back to directly building the header.
-	 * We're not going to help performance by sitting here spinning.
-	 */
-	if (!spin_trylock(&tnl_vport->cache_lock))
-		return NULL;
-
-	cache = cache_dereference(tnl_vport);
-	if (check_cache_valid(cache, mutable))
-		goto unlock;
-	else
-		cache = NULL;
-
-	cache_len = LL_RESERVED_SPACE(rt_dst(rt).dev) + mutable->tunnel_hlen;
-
-	cache = kzalloc(ALIGN(sizeof(struct tnl_cache), CACHE_DATA_ALIGN) +
-			cache_len, GFP_ATOMIC);
-	if (!cache)
-		goto unlock;
-
-	create_eth_hdr(cache, hh);
-	cache_data = get_cached_header(cache) + cache->hh_len;
-	cache->len = cache->hh_len + mutable->tunnel_hlen;
-
-	create_tunnel_header(vport, mutable, rt, cache_data);
-
-	cache->mutable_seq = mutable->seq;
-	cache->rt = rt;
-#ifdef NEED_CACHE_TIMEOUT
-	cache->expiration = jiffies + tnl_vport->cache_exp_interval;
-#endif
-
-	if (ovs_is_internal_dev(rt_dst(rt).dev)) {
-		struct sw_flow_key flow_key;
-		struct vport *dst_vport;
-		struct sk_buff *skb;
-		int err;
-		int flow_key_len;
-		struct sw_flow *flow;
-
-		dst_vport = ovs_internal_dev_get_vport(rt_dst(rt).dev);
-		if (!dst_vport)
-			goto done;
-
-		skb = alloc_skb(cache->len, GFP_ATOMIC);
-		if (!skb)
-			goto done;
-
-		__skb_put(skb, cache->len);
-		memcpy(skb->data, get_cached_header(cache), cache->len);
-
-		err = ovs_flow_extract(skb, dst_vport->port_no, &flow_key,
-				       &flow_key_len);
-
-		consume_skb(skb);
-		if (err)
-			goto done;
-
-		flow = ovs_flow_tbl_lookup(rcu_dereference(dst_vport->dp->table),
-					   &flow_key, flow_key_len);
-		if (flow) {
-			cache->flow = flow;
-			ovs_flow_hold(flow);
-		}
-	}
-
-done:
-	assign_cache_rcu(vport, cache);
-
-unlock:
-	spin_unlock(&tnl_vport->cache_lock);
-
-	return cache;
-}
-
 static struct rtable *__find_route(const struct tnl_mutable_config *mutable,
 				   u8 ipproto, __be32 daddr, __be32 saddr,
 				   u8 tos)
@@ -1001,33 +721,19 @@ static struct rtable *__find_route(const struct tnl_mutable_config *mutable,
 
 static struct rtable *find_route(struct vport *vport,
 				 const struct tnl_mutable_config *mutable,
-				 u8 tos, __be32 daddr, __be32 saddr,
-				 struct tnl_cache **cache)
+				 u8 tos, __be32 daddr, __be32 saddr)
 {
 	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
-	struct tnl_cache *cur_cache = rcu_dereference(tnl_vport->cache);
+	struct rtable *rt;
 
-	*cache = NULL;
 	tos = RT_TOS(tos);
 
-	if (daddr == mutable->key.daddr && saddr == mutable->key.saddr &&
-	    tos == RT_TOS(mutable->tos) &&
-	    check_cache_valid(cur_cache, mutable)) {
-		*cache = cur_cache;
-		return cur_cache->rt;
-	} else {
-		struct rtable *rt;
-
-		rt = __find_route(mutable, tnl_vport->tnl_ops->ipproto,
-				  daddr, saddr, tos);
-		if (IS_ERR(rt))
-			return NULL;
-
-		if (likely(tos == RT_TOS(mutable->tos)))
-			*cache = build_cache(vport, mutable, rt);
+	rt = __find_route(mutable, tnl_vport->tnl_ops->ipproto,
+			  daddr, saddr, tos);
+	if (IS_ERR(rt))
+		return NULL;
 
-		return rt;
-	}
+	return rt;
 }
 
 static bool need_linearize(const struct sk_buff *skb)
@@ -1152,7 +858,6 @@ int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
 	enum vport_err_type err = VPORT_E_TX_ERROR;
 	struct rtable *rt;
 	struct dst_entry *unattached_dst = NULL;
-	struct tnl_cache *cache;
 	int sent_len = 0;
 	__be16 frag_off = 0;
 	__be32 daddr;
@@ -1210,11 +915,10 @@ int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
 	}
 
 	/* Route lookup */
-	rt = find_route(vport, mutable, tos, daddr, saddr, &cache);
+	rt = find_route(vport, mutable, tos, daddr, saddr);
 	if (unlikely(!rt))
 		goto error_free;
-	if (unlikely(!cache))
-		unattached_dst = &rt_dst(rt);
+	unattached_dst = &rt_dst(rt);
 
 	tos = INET_ECN_encapsulate(tos, inner_tos);
 
@@ -1239,11 +943,9 @@ int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
 	 * If we are over the MTU, allow the IP stack to handle fragmentation.
 	 * Fragmentation is a slow path anyways.
 	 */
-	if (unlikely(skb->len + mutable->tunnel_hlen > dst_mtu(&rt_dst(rt)) &&
-		     cache)) {
+	if (unlikely(skb->len + mutable->tunnel_hlen > dst_mtu(&rt_dst(rt)))) {
 		unattached_dst = &rt_dst(rt);
 		dst_hold(unattached_dst);
-		cache = NULL;
 	}
 
 	/* TTL */
@@ -1270,23 +972,15 @@ int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
 		if (unlikely(vlan_deaccel_tag(skb)))
 			goto next;
 
-		if (likely(cache)) {
-			skb_push(skb, cache->len);
-			memcpy(skb->data, get_cached_header(cache), cache->len);
-			skb_reset_mac_header(skb);
-			skb_set_network_header(skb, cache->hh_len);
-
-		} else {
-			skb_push(skb, mutable->tunnel_hlen);
-			create_tunnel_header(vport, mutable, rt, skb->data);
-			skb_reset_network_header(skb);
-
-			if (next_skb)
-				skb_dst_set(skb, dst_clone(unattached_dst));
-			else {
-				skb_dst_set(skb, unattached_dst);
-				unattached_dst = NULL;
-			}
+		skb_push(skb, mutable->tunnel_hlen);
+		create_tunnel_header(vport, mutable, rt, skb->data);
+		skb_reset_network_header(skb);
+
+		if (next_skb)
+			skb_dst_set(skb, dst_clone(unattached_dst));
+		else {
+			skb_dst_set(skb, unattached_dst);
+			unattached_dst = NULL;
 		}
 		skb_set_transport_header(skb, skb_network_offset(skb) + sizeof(struct iphdr));
 
@@ -1301,37 +995,7 @@ int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
 		if (unlikely(!skb))
 			goto next;
 
-		if (likely(cache)) {
-			int orig_len = skb->len - cache->len;
-			struct vport *cache_vport;
-
-			cache_vport = ovs_internal_dev_get_vport(rt_dst(rt).dev);
-			skb->protocol = htons(ETH_P_IP);
-			iph = ip_hdr(skb);
-			iph->tot_len = htons(skb->len - skb_network_offset(skb));
-			ip_send_check(iph);
-
-			if (cache_vport) {
-				if (unlikely(compute_ip_summed(skb, true))) {
-					kfree_skb(skb);
-					goto next;
-				}
-
-				OVS_CB(skb)->flow = cache->flow;
-				ovs_vport_receive(cache_vport, skb);
-				sent_len += orig_len;
-			} else {
-				int xmit_err;
-
-				skb->dev = rt_dst(rt).dev;
-				xmit_err = dev_queue_xmit(skb);
-
-				if (likely(net_xmit_eval(xmit_err) == 0))
-					sent_len += orig_len;
-			}
-		} else
-			sent_len += send_frags(skb, mutable);
-
+		sent_len += send_frags(skb, mutable);
 next:
 		skb = next_skb;
 	}
@@ -1414,13 +1078,6 @@ struct vport *ovs_tnl_create(const struct vport_parms *parms,
 	if (err)
 		goto error_free_mutable;
 
-	spin_lock_init(&tnl_vport->cache_lock);
-
-#ifdef NEED_CACHE_TIMEOUT
-	tnl_vport->cache_exp_interval = MAX_CACHE_EXP -
-				       (net_random() % (MAX_CACHE_EXP / 2));
-#endif
-
 	rcu_assign_pointer(tnl_vport->mutable, mutable);
 
 	port_table_add_port(vport);
@@ -1439,7 +1096,6 @@ static void free_port_rcu(struct rcu_head *rcu)
 	struct tnl_vport *tnl_vport = container_of(rcu,
 						   struct tnl_vport, rcu);
 
-	free_cache((struct tnl_cache __force *)tnl_vport->cache);
 	kfree((struct tnl_mutable __force *)tnl_vport->mutable);
 	ovs_vport_free(tnl_vport_to_vport(tnl_vport));
 }
diff --git a/datapath/tunnel.h b/datapath/tunnel.h
index 0af27ac..ed3b4ec 100644
--- a/datapath/tunnel.h
+++ b/datapath/tunnel.h
@@ -172,58 +172,6 @@ struct tnl_ops {
 /* If we can't detect all system changes directly we need to use a timeout. */
 #define NEED_CACHE_TIMEOUT
 #endif
-struct tnl_cache {
-	struct rcu_head rcu;
-
-	int len;		/* Length of data to be memcpy'd from cache. */
-	int hh_len;		/* Hardware hdr length, cached from hh_cache. */
-
-	/* Sequence number of mutable->seq from which this cache was
-	 * generated. */
-	unsigned mutable_seq;
-
-#ifdef HAVE_HH_SEQ
-	/*
-	 * The sequence number from the seqlock protecting the hardware header
-	 * cache (in the ARP cache).  Since every write increments the counter
-	 * this gives us an easy way to tell if it has changed.
-	 */
-	unsigned hh_seq;
-#endif
-
-#ifdef NEED_CACHE_TIMEOUT
-	/*
-	 * If we don't have direct mechanisms to detect all important changes in
-	 * the system fall back to an expiration time.  This expiration time
-	 * can be relatively short since at high rates there will be millions of
-	 * packets per second, so we'll still get plenty of benefit from the
-	 * cache.  Note that if something changes we may blackhole packets
-	 * until the expiration time (depending on what changed and the kernel
-	 * version we may be able to detect the change sooner).  Expiration is
-	 * expressed as a time in jiffies.
-	 */
-	unsigned long expiration;
-#endif
-
-	/*
-	 * The routing table entry that is the result of looking up the tunnel
-	 * endpoints.  It also contains a sequence number (called a generation
-	 * ID) that can be compared to a global sequence to tell if the routing
-	 * table has changed (and therefore there is a potential that this
-	 * cached route has been invalidated).
-	 */
-	struct rtable *rt;
-
-	/*
-	 * If the output device for tunnel traffic is an OVS internal device,
-	 * the flow of that datapath.  Since all tunnel traffic will have the
-	 * same headers this allows us to cache the flow lookup.  NULL if the
-	 * output device is not OVS or if there is no flow installed.
-	 */
-	struct sw_flow *flow;
-
-	/* The cached header follows after padding for alignment. */
-};
 
 struct tnl_vport {
 	struct rcu_head rcu;
-- 
1.7.10.2.484.gcd07cc5
