From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 08/13] net: vrf: ipv6 support for local traffic to local addresses
Date: Wed,  4 May 2016 20:33:25 -0700
Message-ID: <1462419210-10463-9-git-send-email-dsa@cumulusnetworks.com>
References: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33470 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755965AbcEEDeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 23:34:18 -0400
Received: by mail-pa0-f51.google.com with SMTP id xk12so31293392pac.0
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 20:34:18 -0700 (PDT)
In-Reply-To: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for locally originated traffic to VRF-local addresses.
This patch handles IPv6 support. With this patch, ping, tcp and udp
packets to a local IPv6 address are successfully routed:

    $ ping6 -c1 -I red 2100:1::1
    ping6: Warning: source address might be selected on device other than red.
    PING 2100:1::1(2100:1::1) from 2100:1::1 red: 56 data bytes
    64 bytes from 2100:1::1: icmp_seq=1 ttl=64 time=0.098 ms

ip6_input is exported so the VRF driver can use it for the dst input
function. IPv4 defaults to setting the input and output functions; IPv6
does not. VRF does not need to reinvent the Rx path so just export the
function.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c    | 79 ++++++++++++++++++++++++++++++++++++++++++++--------
 net/ipv6/ip6_input.c |  1 +
 2 files changed, 69 insertions(+), 11 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index b6e8b1e9b4fd..7a533607a08c 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -46,6 +46,7 @@ struct net_vrf {
 	struct rtable           *rth;
 	struct rtable           *rth_local;
 	struct rt6_info		*rt6;
+	struct rt6_info		*rt6_local;
 	u32                     tb_id;
 };
 
@@ -148,14 +149,39 @@ static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 	struct dst_entry *dst;
 	struct dst_entry *dst_null = &net->ipv6.ip6_null_entry->dst;
 
-	/* strip the ethernet header added for pass through VRF device */
-	__skb_pull(skb, skb_network_offset(skb));
-
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (dst == dst_null)
 		goto err;
 
 	skb_dst_drop(skb);
+
+	/* if dst.dev is loopback or the VRF device again this is locally
+	 * originated traffic destined to a local address. Short circuit
+	 * to Rx path using our local dst
+	 */
+	if (dst->dev == net->loopback_dev || dst->dev == dev) {
+		struct net_vrf *vrf = netdev_priv(dev);
+		struct rt6_info *rt6_local = vrf->rt6_local;
+
+		/* release looked up dst and use cached local dst */
+		dst_release(dst);
+
+		/* Ordering issue: cached local dst is created on newlink
+		 * before the IPv6 initialization. Using the local dst
+		 * requires rt6i_idev to be set so make sure it is.
+		 */
+		if (!rt6_local->rt6i_idev) {
+			rt6_local->rt6i_idev = in6_dev_get(dev);
+			if (!rt6_local->rt6i_idev)
+				goto err;
+		}
+
+		return vrf_local_xmit(skb, &rt6_local->dst);
+	}
+
+	/* strip the ethernet header added for pass through VRF device */
+	__skb_pull(skb, skb_network_offset(skb));
+
 	skb_dst_set(skb, dst);
 
 	ret = ip6_local_out(net, skb->sk, skb);
@@ -314,30 +340,61 @@ static int vrf_output6(struct net *net, struct sock *sk, struct sk_buff *skb)
 
 static void vrf_rt6_release(struct net_vrf *vrf)
 {
-	dst_release(&vrf->rt6->dst);
+	struct rt6_info *rt6;
+
+	rt6 = vrf->rt6;
+	dst_release(&rt6->dst);
 	vrf->rt6 = NULL;
+
+	rt6 = vrf->rt6_local;
+	if (rt6->rt6i_idev)
+		in6_dev_put(rt6->rt6i_idev);
+
+	dst_release(&rt6->dst);
+	vrf->rt6_local = NULL;
 }
 
 static int vrf_rt6_create(struct net_device *dev)
 {
+	int flags = DST_HOST | DST_NOPOLICY | DST_NOXFRM | DST_NOCACHE;
 	struct net_vrf *vrf = netdev_priv(dev);
 	struct net *net = dev_net(dev);
+	struct fib6_table *rt6i_table;
 	struct rt6_info *rt6;
 	int rc = -ENOMEM;
 
-	rt6 = ip6_dst_alloc(net, dev,
-			    DST_HOST | DST_NOPOLICY | DST_NOXFRM | DST_NOCACHE);
+	rt6i_table = fib6_new_table(net, vrf->tb_id);
+	if (!rt6i_table)
+		goto out;
+
+	/* create a dst for routing packets out a VRF device */
+	rt6 = ip6_dst_alloc(net, dev, flags);
 	if (!rt6)
 		goto out;
 
 	dst_hold(&rt6->dst);
+	rt6->rt6i_table = rt6i_table;
+	rt6->dst.output = vrf_output6;
+	vrf->rt6 = rt6;
 
-	rt6->rt6i_table = fib6_new_table(net, vrf->tb_id);
-	if (!rt6->rt6i_table)
+	/* create a dst for local routing - packets sent locally
+	 * to local address via the VRF device as a loopback
+	 */
+	rt6 = ip6_dst_alloc(net, dev, flags);
+	if (!rt6) {
+		dst_release(&vrf->rt6->dst);
 		goto out;
+	}
+
+	dst_hold(&rt6->dst);
+
+	rt6->dst.flags |= DST_HOST;
+	rt6->rt6i_idev = in6_dev_get(dev);
+	rt6->rt6i_flags = RTF_UP | RTF_NONEXTHOP | RTF_LOCAL;
+	rt6->rt6i_table = rt6i_table;
+	rt6->dst.input = ip6_input;
+	vrf->rt6_local = rt6;
 
-	rt6->dst.output	= vrf_output6;
-	vrf->rt6 = rt6;
 	rc = 0;
 out:
 	return rc;
@@ -733,7 +790,7 @@ static struct dst_entry *vrf_get_rt6_dst(const struct net_device *dev,
 		dst_hold(&rt->dst);
 	}
 
-	return (struct dst_entry *)rt;
+	return &rt->dst;
 }
 #endif
 
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index f185cbcda114..d896a08be0fc 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -298,6 +298,7 @@ int ip6_input(struct sk_buff *skb)
 		       dev_net(skb->dev), NULL, skb, skb->dev, NULL,
 		       ip6_input_finish);
 }
+EXPORT_SYMBOL_GPL(ip6_input);
 
 int ip6_mc_input(struct sk_buff *skb)
 {
-- 
2.1.4
