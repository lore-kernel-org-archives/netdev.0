From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 05/12] net: vrf: Flip IPv6 path from dst to out hook
Date: Tue, 30 Aug 2016 10:34:10 -0700
Message-ID: <1472578457-26722-6-git-send-email-dsa@cumulusnetworks.com>
References: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33091 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932872AbcH3Re3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 13:34:29 -0400
Received: by mail-pf0-f182.google.com with SMTP id y134so10002036pfg.0
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 10:34:29 -0700 (PDT)
In-Reply-To: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flip the IPv6 output path from use of the vrf dst to the l3mdev tx out
hook.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c     | 156 ++++++++++++++++++++------------------------------
 net/ipv6/ip6_output.c |   9 ++-
 net/ipv6/route.c      |   5 --
 3 files changed, 70 insertions(+), 100 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 7517645347c3..df58bc791cfd 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -140,80 +140,42 @@ static int vrf_local_xmit(struct sk_buff *skb, struct net_device *dev,
 static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 					   struct net_device *dev)
 {
-	const struct ipv6hdr *iph = ipv6_hdr(skb);
-	struct net *net = dev_net(skb->dev);
-	struct flowi6 fl6 = {
-		/* needed to match OIF rule */
-		.flowi6_oif = dev->ifindex,
-		.flowi6_iif = LOOPBACK_IFINDEX,
-		.daddr = iph->daddr,
-		.saddr = iph->saddr,
-		.flowlabel = ip6_flowinfo(iph),
-		.flowi6_mark = skb->mark,
-		.flowi6_proto = iph->nexthdr,
-		.flowi6_flags = FLOWI_FLAG_L3MDEV_SRC | FLOWI_FLAG_SKIP_NH_OIF,
-	};
-	int ret = NET_XMIT_DROP;
-	struct dst_entry *dst;
-	struct dst_entry *dst_null = &net->ipv6.ip6_null_entry->dst;
-
-	dst = ip6_route_output(net, NULL, &fl6);
-	if (dst == dst_null)
-		goto err;
+	struct net_vrf *vrf = netdev_priv(dev);
+	struct dst_entry *dst = NULL;
+	struct rt6_info *rt6_local;
 
 	skb_dst_drop(skb);
 
-	/* if dst.dev is loopback or the VRF device again this is locally
-	 * originated traffic destined to a local address. Short circuit
-	 * to Rx path using our local dst
-	 */
-	if (dst->dev == net->loopback_dev || dst->dev == dev) {
-		struct net_vrf *vrf = netdev_priv(dev);
-		struct rt6_info *rt6_local;
-
-		/* release looked up dst and use cached local dst */
-		dst_release(dst);
+	rcu_read_lock();
 
-		rcu_read_lock();
+	rt6_local = rcu_dereference(vrf->rt6_local);
+	if (unlikely(!rt6_local)) {
+		rcu_read_unlock();
+		goto err;
+	}
 
-		rt6_local = rcu_dereference(vrf->rt6_local);
-		if (unlikely(!rt6_local)) {
+	/* Ordering issue: cached local dst is created on newlink
+	 * before the IPv6 initialization. Using the local dst
+	 * requires rt6i_idev to be set so make sure it is.
+	 */
+	if (unlikely(!rt6_local->rt6i_idev)) {
+		rt6_local->rt6i_idev = in6_dev_get(dev);
+		if (!rt6_local->rt6i_idev) {
 			rcu_read_unlock();
 			goto err;
 		}
-
-		/* Ordering issue: cached local dst is created on newlink
-		 * before the IPv6 initialization. Using the local dst
-		 * requires rt6i_idev to be set so make sure it is.
-		 */
-		if (unlikely(!rt6_local->rt6i_idev)) {
-			rt6_local->rt6i_idev = in6_dev_get(dev);
-			if (!rt6_local->rt6i_idev) {
-				rcu_read_unlock();
-				goto err;
-			}
-		}
-
-		dst = &rt6_local->dst;
-		dst_hold(dst);
-
-		rcu_read_unlock();
-
-		return vrf_local_xmit(skb, dev, &rt6_local->dst);
 	}
 
-	skb_dst_set(skb, dst);
+	dst = &rt6_local->dst;
+	if (likely(dst))
+		dst_hold(dst);
 
-	/* strip the ethernet header added for pass through VRF device */
-	__skb_pull(skb, skb_network_offset(skb));
+	rcu_read_unlock();
 
-	ret = ip6_local_out(net, skb->sk, skb);
-	if (unlikely(net_xmit_eval(ret)))
-		dev->stats.tx_errors++;
-	else
-		ret = NET_XMIT_SUCCESS;
+	if (unlikely(!dst))
+		goto err;
 
-	return ret;
+	return vrf_local_xmit(skb, dev, dst);
 err:
 	vrf_tx_error(dev, skb);
 	return NET_XMIT_DROP;
@@ -286,44 +248,43 @@ static netdev_tx_t vrf_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-/* modelled after ip6_finish_output2 */
-static int vrf_finish_output6(struct net *net, struct sock *sk,
-			      struct sk_buff *skb)
-{
-	struct dst_entry *dst = skb_dst(skb);
-	struct net_device *dev = dst->dev;
-	struct neighbour *neigh;
-	struct in6_addr *nexthop;
-	int ret;
+static int vrf_finish_output(struct net *net, struct sock *sk,
+			     struct sk_buff *skb);
 
+/* modelled after ip6_output */
+static int vrf_output6(struct net *net, struct sock *sk, struct sk_buff *skb)
+{
 	skb->protocol = htons(ETH_P_IPV6);
-	skb->dev = dev;
-
-	rcu_read_lock_bh();
-	nexthop = rt6_nexthop((struct rt6_info *)dst, &ipv6_hdr(skb)->daddr);
-	neigh = __ipv6_neigh_lookup_noref(dst->dev, nexthop);
-	if (unlikely(!neigh))
-		neigh = __neigh_create(&nd_tbl, nexthop, dst->dev, false);
-	if (!IS_ERR(neigh)) {
-		ret = dst_neigh_output(dst, neigh, skb);
-		rcu_read_unlock_bh();
-		return ret;
-	}
-	rcu_read_unlock_bh();
 
-	IP6_INC_STATS(dev_net(dst->dev),
-		      ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
-	kfree_skb(skb);
-	return -EINVAL;
+	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING,
+			    net, sk, skb, NULL, skb->dev,
+			    vrf_finish_output,
+			    !(IPCB(skb)->flags & IP6SKB_REROUTED));
 }
 
-/* modelled after ip6_output */
-static int vrf_output6(struct net *net, struct sock *sk, struct sk_buff *skb)
+static struct sk_buff *vrf_ip6_out(struct net_device *vrf_dev,
+				   struct sock *sk,
+				   struct sk_buff *skb)
 {
-	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING,
-			    net, sk, skb, NULL, skb_dst(skb)->dev,
-			    vrf_finish_output6,
-			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
+	struct net *net = dev_net(vrf_dev);
+	struct net_device *dev = skb->dev;
+	int err;
+
+	skb->dev = vrf_dev;
+
+	err = nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT, net, sk,
+		      skb, NULL, vrf_dev, vrf_output6);
+	if (likely(err == 1))
+		err = vrf_output6(net, sk, skb);
+
+	if (likely(err == 1)) {
+		skb->dev = dev;
+		nf_reset(skb);
+	} else {
+		skb = NULL;
+	}
+
+	return skb;
 }
 
 /* holding rtnl */
@@ -412,6 +373,13 @@ static int vrf_rt6_create(struct net_device *dev)
 	return rc;
 }
 #else
+static struct sk_buff *vrf_ip6_out(struct net_device *vrf_dev,
+				   struct sock *sk,
+				   struct sk_buff *skb)
+{
+	return skb;
+}
+
 static void vrf_rt6_release(struct net_device *dev, struct net_vrf *vrf)
 {
 }
@@ -482,6 +450,8 @@ static struct sk_buff *vrf_l3_out(struct net_device *vrf_dev,
 	switch (proto) {
 	case AF_INET:
 		return vrf_ip_out(vrf_dev, sk, skb);
+	case AF_INET6:
+		return vrf_ip6_out(vrf_dev, sk, skb);
 	}
 
 	return skb;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index bcec7e73eb0b..9711f32eedd7 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1054,10 +1054,15 @@ EXPORT_SYMBOL_GPL(ip6_dst_lookup);
 struct dst_entry *ip6_dst_lookup_flow(const struct sock *sk, struct flowi6 *fl6,
 				      const struct in6_addr *final_dst)
 {
+	struct net *net = sock_net(sk);
 	struct dst_entry *dst = NULL;
 	int err;
 
-	err = ip6_dst_lookup_tail(sock_net(sk), sk, &dst, fl6);
+	if (rt6_need_strict(&fl6->daddr) &&
+	    netif_index_is_l3_master(net, fl6->flowi6_oif))
+		return ERR_PTR(-ENETUNREACH);
+
+	err = ip6_dst_lookup_tail(net, sk, &dst, fl6);
 	if (err)
 		return ERR_PTR(err);
 	if (final_dst)
@@ -1065,7 +1070,7 @@ struct dst_entry *ip6_dst_lookup_flow(const struct sock *sk, struct flowi6 *fl6,
 	if (!fl6->flowi6_oif)
 		fl6->flowi6_oif = l3mdev_fib_oif(dst->dev);
 
-	return xfrm_lookup_route(sock_net(sk), dst, flowi6_to_flowi(fl6), sk, 0);
+	return xfrm_lookup_route(net, dst, flowi6_to_flowi(fl6), sk, 0);
 }
 EXPORT_SYMBOL_GPL(ip6_dst_lookup_flow);
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4a0f77aa49cf..65ee42ad2afd 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1188,13 +1188,8 @@ static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table
 struct dst_entry *ip6_route_output_flags(struct net *net, const struct sock *sk,
 					 struct flowi6 *fl6, int flags)
 {
-	struct dst_entry *dst;
 	bool any_src;
 
-	dst = l3mdev_get_rt6_dst(net, fl6);
-	if (dst)
-		return dst;
-
 	fl6->flowi6_iif = LOOPBACK_IFINDEX;
 
 	any_src = ipv6_addr_any(&fl6->saddr);
-- 
2.1.4
