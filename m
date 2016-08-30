From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 04/12] net: vrf: Flip IPv4 path from dst to out hook
Date: Tue, 30 Aug 2016 10:34:09 -0700
Message-ID: <1472578457-26722-5-git-send-email-dsa@cumulusnetworks.com>
References: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36554 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932721AbcH3Re3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 13:34:29 -0400
Received: by mail-pf0-f172.google.com with SMTP id h186so9944526pfg.3
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 10:34:28 -0700 (PDT)
In-Reply-To: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flip the IPv4 output path from use of the vrf dst to the l3mdev tx out
hook.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 171 ++++++++++++++++++++----------------------------------
 net/ipv4/route.c  |   4 --
 2 files changed, 64 insertions(+), 111 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 1ce7420322ee..7517645347c3 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -230,79 +230,28 @@ static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 					   struct net_device *vrf_dev)
 {
-	struct iphdr *ip4h = ip_hdr(skb);
-	int ret = NET_XMIT_DROP;
-	struct flowi4 fl4 = {
-		/* needed to match OIF rule */
-		.flowi4_oif = vrf_dev->ifindex,
-		.flowi4_iif = LOOPBACK_IFINDEX,
-		.flowi4_tos = RT_TOS(ip4h->tos),
-		.flowi4_flags = FLOWI_FLAG_ANYSRC | FLOWI_FLAG_L3MDEV_SRC |
-				FLOWI_FLAG_SKIP_NH_OIF,
-		.daddr = ip4h->daddr,
-	};
-	struct net *net = dev_net(vrf_dev);
-	struct rtable *rt;
-
-	rt = ip_route_output_flow(net, &fl4, NULL);
-	if (IS_ERR(rt))
-		goto err;
-
-	if (rt->rt_type != RTN_UNICAST && rt->rt_type != RTN_LOCAL) {
-		ip_rt_put(rt);
-		goto err;
-	}
+	struct net_vrf *vrf = netdev_priv(vrf_dev);
+	struct dst_entry *dst = NULL;
+	struct rtable *rth_local;
 
 	skb_dst_drop(skb);
 
-	/* if dst.dev is loopback or the VRF device again this is locally
-	 * originated traffic destined to a local address. Short circuit
-	 * to Rx path using our local dst
-	 */
-	if (rt->dst.dev == net->loopback_dev || rt->dst.dev == vrf_dev) {
-		struct net_vrf *vrf = netdev_priv(vrf_dev);
-		struct rtable *rth_local;
-		struct dst_entry *dst = NULL;
-
-		ip_rt_put(rt);
-
-		rcu_read_lock();
-
-		rth_local = rcu_dereference(vrf->rth_local);
-		if (likely(rth_local)) {
-			dst = &rth_local->dst;
-			dst_hold(dst);
-		}
-
-		rcu_read_unlock();
-
-		if (unlikely(!dst))
-			goto err;
+	rcu_read_lock();
 
-		return vrf_local_xmit(skb, vrf_dev, dst);
+	rth_local = rcu_dereference(vrf->rth_local);
+	if (likely(rth_local)) {
+		dst = &rth_local->dst;
+		dst_hold(dst);
 	}
 
-	skb_dst_set(skb, &rt->dst);
-
-	/* strip the ethernet header added for pass through VRF device */
-	__skb_pull(skb, skb_network_offset(skb));
+	rcu_read_unlock();
 
-	if (!ip4h->saddr) {
-		ip4h->saddr = inet_select_addr(skb_dst(skb)->dev, 0,
-					       RT_SCOPE_LINK);
+	if (unlikely(!dst)) {
+		vrf_tx_error(vrf_dev, skb);
+		return NET_XMIT_DROP;
 	}
 
-	ret = ip_local_out(dev_net(skb_dst(skb)->dev), skb->sk, skb);
-	if (unlikely(net_xmit_eval(ret)))
-		vrf_dev->stats.tx_errors++;
-	else
-		ret = NET_XMIT_SUCCESS;
-
-out:
-	return ret;
-err:
-	vrf_tx_error(vrf_dev, skb);
-	goto out;
+	return vrf_local_xmit(skb, vrf_dev, dst);
 }
 
 static netdev_tx_t is_ip_tx_frame(struct sk_buff *skb, struct net_device *dev)
@@ -473,64 +422,71 @@ static int vrf_rt6_create(struct net_device *dev)
 }
 #endif
 
-/* modelled after ip_finish_output2 */
+/* run skb through packet sockets for tcpdump with dev set to vrf dev */
 static int vrf_finish_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb_dst(skb);
-	struct rtable *rt = (struct rtable *)dst;
-	struct net_device *dev = dst->dev;
-	unsigned int hh_len = LL_RESERVED_SPACE(dev);
-	struct neighbour *neigh;
-	u32 nexthop;
-	int ret = -EINVAL;
-
-	/* Be paranoid, rather than too clever. */
-	if (unlikely(skb_headroom(skb) < hh_len && dev->header_ops)) {
-		struct sk_buff *skb2;
-
-		skb2 = skb_realloc_headroom(skb, LL_RESERVED_SPACE(dev));
-		if (!skb2) {
-			ret = -ENOMEM;
-			goto err;
-		}
-		if (skb->sk)
-			skb_set_owner_w(skb2, skb->sk);
-
-		consume_skb(skb);
-		skb = skb2;
+	if (likely(skb_headroom(skb) >= ETH_HLEN)) {
+		struct ethhdr *eth = (struct ethhdr *)skb_push(skb, ETH_HLEN);
+
+		ether_addr_copy(eth->h_source, skb->dev->dev_addr);
+		eth_zero_addr(eth->h_dest);
+		eth->h_proto = skb->protocol;
+		dev_queue_xmit_nit(skb, skb->dev);
+		skb_pull(skb, ETH_HLEN);
 	}
 
-	rcu_read_lock_bh();
-
-	nexthop = (__force u32)rt_nexthop(rt, ip_hdr(skb)->daddr);
-	neigh = __ipv4_neigh_lookup_noref(dev, nexthop);
-	if (unlikely(!neigh))
-		neigh = __neigh_create(&arp_tbl, &nexthop, dev, false);
-	if (!IS_ERR(neigh))
-		ret = dst_neigh_output(dst, neigh, skb);
-
-	rcu_read_unlock_bh();
-err:
-	if (unlikely(ret < 0))
-		vrf_tx_error(skb->dev, skb);
-	return ret;
+	return 1;
 }
 
 static int vrf_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	struct net_device *dev = skb_dst(skb)->dev;
-
-	IP_UPD_PO_STATS(net, IPSTATS_MIB_OUT, skb->len);
-
-	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
 
 	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING,
-			    net, sk, skb, NULL, dev,
+			    net, sk, skb, NULL, skb->dev,
 			    vrf_finish_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
 
+static struct sk_buff *vrf_ip_out(struct net_device *vrf_dev,
+				  struct sock *sk,
+				  struct sk_buff *skb)
+{
+	struct net *net = dev_net(vrf_dev);
+	struct net_device *dev = skb->dev;
+	int err;
+
+	skb->dev = vrf_dev;
+
+	err = nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_OUT, net, sk,
+		      skb, NULL, vrf_dev, vrf_output);
+	if (likely(err == 1))
+		err = vrf_output(net, sk, skb);
+
+	if (likely(err == 1)) {
+		skb->dev = dev;
+		nf_reset(skb);
+	} else {
+		skb = NULL;
+	}
+
+	return skb;
+}
+
+/* called with rcu lock held */
+static struct sk_buff *vrf_l3_out(struct net_device *vrf_dev,
+				  struct sock *sk,
+				  struct sk_buff *skb,
+				  u16 proto)
+{
+	switch (proto) {
+	case AF_INET:
+		return vrf_ip_out(vrf_dev, sk, skb);
+	}
+
+	return skb;
+}
+
 /* holding rtnl */
 static void vrf_rtable_release(struct net_device *dev, struct net_vrf *vrf)
 {
@@ -1067,6 +1023,7 @@ static const struct l3mdev_ops vrf_l3mdev_ops = {
 	.l3mdev_get_rtable	= vrf_get_rtable,
 	.l3mdev_get_saddr	= vrf_get_saddr,
 	.l3mdev_l3_rcv		= vrf_l3_rcv,
+	.l3mdev_l3_out		= vrf_l3_out,
 #if IS_ENABLED(CONFIG_IPV6)
 	.l3mdev_get_rt6_dst	= vrf_get_rt6_dst,
 	.l3mdev_get_saddr6	= vrf_get_saddr6,
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 1119f18fb720..d9936f90a755 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2244,10 +2244,6 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 				fl4->saddr = inet_select_addr(dev_out, 0,
 							      RT_SCOPE_HOST);
 		}
-
-		rth = l3mdev_get_rtable(dev_out, fl4);
-		if (rth)
-			goto out;
 	}
 
 	if (!fl4->daddr) {
-- 
2.1.4
