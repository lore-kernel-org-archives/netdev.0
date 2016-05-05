From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 07/13] net: vrf: ipv4 support for local traffic to local addresses
Date: Wed,  4 May 2016 20:33:24 -0700
Message-ID: <1462419210-10463-8-git-send-email-dsa@cumulusnetworks.com>
References: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36184 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755933AbcEEDeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 23:34:17 -0400
Received: by mail-pf0-f176.google.com with SMTP id c189so33688416pfb.3
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 20:34:16 -0700 (PDT)
In-Reply-To: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for locally originated traffic to VRF local addresses.
This patch handles IPv4 support; follow on patch handles IPv6.

With this patch, ping, tcp and udp packets to a local IPv4 address are
successfully routed:

    $ ping -c1 -I red 10.100.1.1
    ping: Warning: source address might be selected on device other than red.
    PING 10.100.1.1 (10.100.1.1) from 10.100.1.1 red: 56(84) bytes of data.
    64 bytes from 10.100.1.1: icmp_seq=1 ttl=64 time=0.057 ms

This patch also enables use of IPv4 loopback address on the VRF device:
    $ ip addr add dev red 127.0.0.1/8

    $ ping -I red -c1 127.0.0.1
    PING 127.0.0.1 (127.0.0.1) from 127.0.0.1 red: 56(84) bytes of data.
    64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.058 ms

which comes in handy for example when running ntpd in a VRF context and
then using ntpq to query status.

The l3mdev change also passes packets to the VRF driver if the ingress
device is an L3 master. This is needed to reset the packet type to HOST.
(It is set to LOOPBACK to avoid hitting network taps a second time on
Rx.)

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 138 +++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 101 insertions(+), 37 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 39bef1dc41fa..b6e8b1e9b4fd 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -44,6 +44,7 @@
 
 struct net_vrf {
 	struct rtable           *rth;
+	struct rtable           *rth_local;
 	struct rt6_info		*rt6;
 	u32                     tb_id;
 };
@@ -54,6 +55,7 @@ struct pcpu_dstats {
 	u64			tx_drps;
 	u64			rx_pkts;
 	u64			rx_bytes;
+	u64			rx_drps;
 	struct u64_stats_sync	syncp;
 };
 
@@ -91,6 +93,40 @@ static struct rtnl_link_stats64 *vrf_get_stats64(struct net_device *dev,
 	return stats;
 }
 
+/* Local traffic destined to local address. Reinsert the packet to rx
+ * path, similar to loopback handling. Based on loopback_xmit
+ */
+static int vrf_local_xmit(struct sk_buff *skb, struct dst_entry *dst)
+{
+	struct net_device *dev = skb->dev;
+	struct pcpu_dstats *dstats = this_cpu_ptr(dev->dstats);
+	int len = skb->len;
+
+	skb_orphan(skb);
+
+	dst_hold(dst);
+	skb_dst_set(skb, dst);
+	skb_dst_force(skb);
+
+	/* set pkt_type to avoid skb hitting packet taps twice -
+	 * once Tx and again in Rx processing
+	 */
+	skb->pkt_type = PACKET_LOOPBACK;
+
+	skb->protocol = eth_type_trans(skb, skb->dev);
+
+	if (likely(netif_rx(skb) == NET_RX_SUCCESS)) {
+		u64_stats_update_begin(&dstats->syncp);
+		dstats->rx_pkts++;
+		dstats->rx_bytes += len;
+		u64_stats_update_end(&dstats->syncp);
+	} else {
+		this_cpu_inc(dev->dstats->rx_drps);
+	}
+
+	return NETDEV_TX_OK;
+}
+
 #if IS_ENABLED(CONFIG_IPV6)
 static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 					   struct net_device *dev)
@@ -112,6 +148,9 @@ static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 	struct dst_entry *dst;
 	struct dst_entry *dst_null = &net->ipv6.ip6_null_entry->dst;
 
+	/* strip the ethernet header added for pass through VRF device */
+	__skb_pull(skb, skb_network_offset(skb));
+
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (dst == dst_null)
 		goto err;
@@ -139,29 +178,6 @@ static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 }
 #endif
 
-static int vrf_send_v4_prep(struct sk_buff *skb, struct flowi4 *fl4,
-			    struct net_device *vrf_dev)
-{
-	struct rtable *rt;
-	int err = 1;
-
-	rt = ip_route_output_flow(dev_net(vrf_dev), fl4, NULL);
-	if (IS_ERR(rt))
-		goto out;
-
-	/* TO-DO: what about broadcast ? */
-	if (rt->rt_type != RTN_UNICAST && rt->rt_type != RTN_LOCAL) {
-		ip_rt_put(rt);
-		goto out;
-	}
-
-	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
-	err = 0;
-out:
-	return err;
-}
-
 static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 					   struct net_device *vrf_dev)
 {
@@ -176,9 +192,35 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 				FLOWI_FLAG_SKIP_NH_OIF,
 		.daddr = ip4h->daddr,
 	};
+	struct net *net = dev_net(vrf_dev);
+	struct rtable *rt;
 
-	if (vrf_send_v4_prep(skb, &fl4, vrf_dev))
+	rt = ip_route_output_flow(net, &fl4, NULL);
+	if (IS_ERR(rt))
+		goto err;
+
+	if (rt->rt_type != RTN_UNICAST && rt->rt_type != RTN_LOCAL) {
+		ip_rt_put(rt);
 		goto err;
+	}
+
+	skb_dst_drop(skb);
+
+	/* if dst.dev is loopback or the VRF device again this is locally
+	 * originated traffic destined to a local address. Short circuit
+	 * to Rx path using our local dst
+	 */
+	if (rt->dst.dev == net->loopback_dev || rt->dst.dev == vrf_dev) {
+		struct net_vrf *vrf = netdev_priv(vrf_dev);
+
+		ip_rt_put(rt);
+		return vrf_local_xmit(skb, &vrf->rth_local->dst);
+	}
+
+	skb_dst_set(skb, &rt->dst);
+
+	/* strip the ethernet header added for pass through VRF device */
+	__skb_pull(skb, skb_network_offset(skb));
 
 	if (!ip4h->saddr) {
 		ip4h->saddr = inet_select_addr(skb_dst(skb)->dev, 0,
@@ -200,9 +242,6 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 
 static netdev_tx_t is_ip_tx_frame(struct sk_buff *skb, struct net_device *dev)
 {
-	/* strip the ethernet header added for pass through VRF device */
-	__skb_pull(skb, skb_network_offset(skb));
-
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
 		return vrf_process_v4_outbound(skb, dev);
@@ -374,27 +413,45 @@ static int vrf_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 
 static void vrf_rtable_release(struct net_vrf *vrf)
 {
-	struct dst_entry *dst = (struct dst_entry *)vrf->rth;
+	dst_release(&vrf->rth->dst);
+	dst_release(&vrf->rth_local->dst);
 
-	dst_release(dst);
 	vrf->rth = NULL;
+	vrf->rth_local = NULL;
 }
 
-static struct rtable *vrf_rtable_create(struct net_device *dev)
+static int vrf_rtable_create(struct net_device *dev)
 {
 	struct net_vrf *vrf = netdev_priv(dev);
 	struct rtable *rth;
 
 	if (!fib_new_table(dev_net(dev), vrf->tb_id))
-		return NULL;
+		return -ENOMEM;
 
+	/* create a dst for local ingress routing - packets sent locally
+	 * to local address via the VRF device as a loopback
+	 */
+	rth = rt_dst_alloc(dev, RTCF_LOCAL, RTN_LOCAL, 1, 1, 0);
+	if (!rth)
+		return -ENOMEM;
+
+	rth->dst.dev = dev;
+	rth->rt_table_id = vrf->tb_id;
+	vrf->rth_local = rth;
+
+	/* create a dst for routing packets out through a VRF device */
 	rth = rt_dst_alloc(dev, 0, RTN_UNICAST, 1, 1, 0);
-	if (rth) {
-		rth->dst.output	= vrf_output;
-		rth->rt_table_id = vrf->tb_id;
+	if (!rth) {
+		dst_release(&vrf->rth_local->dst);
+		return -ENOMEM;
 	}
 
-	return rth;
+	rth->dst.output = vrf_output;
+	rth->dst.dev = dev;
+	rth->rt_table_id = vrf->tb_id;
+	vrf->rth = rth;
+
+	return 0;
 }
 
 /**************************** device handling ********************/
@@ -482,8 +539,7 @@ static int vrf_dev_init(struct net_device *dev)
 		goto out_nomem;
 
 	/* create the default dst which points back to us */
-	vrf->rth = vrf_rtable_create(dev);
-	if (!vrf->rth)
+	if (vrf_rtable_create(dev))
 		goto out_stats;
 
 	if (vrf_rt6_create(dev) != 0)
@@ -646,6 +702,14 @@ static struct sk_buff *vrf_l3_rcv(struct net_device *vrf_dev,
 				  struct sk_buff *skb,
 				  u16 proto)
 {
+	/* loopback based traffic. Need to reset pkt_type for upper
+	 * layers to process skb
+	 */
+	if (skb->pkt_type == PACKET_LOOPBACK) {
+		skb->pkt_type = PACKET_HOST;
+		return skb;
+	}
+
 	switch (proto) {
 	case AF_INET:
 		return vrf_ip_rcv(vrf_dev, skb);
-- 
2.1.4
