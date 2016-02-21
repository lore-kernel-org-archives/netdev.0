From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next v4 1/3] ipvlan: scrub skb before routing in L3 mode.
Date: Sat, 20 Feb 2016 19:31:32 -0800
Message-ID: <1456025492-30274-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36655 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbcBUTZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 14:25:33 -0500
Received: by mail-pa0-f68.google.com with SMTP id gc2so293372pab.3
        for <netdev@vger.kernel.org>; Sun, 21 Feb 2016 11:25:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Scrub skb before hitting the iptable hooks to ensure packets hit
these hooks. Set the xnet param only when the packet is crossing the
ns boundry so if the IPvlan slave and master belong to the same ns,
the param will be set to false.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
CC: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 8c48bb2a94ea..4e60c6bbdb6e 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -342,7 +342,7 @@ static struct ipvl_addr *ipvlan_addr_lookup(struct ipvl_port *port,
 	return addr;
 }
 
-static int ipvlan_process_v4_outbound(struct sk_buff *skb)
+static int ipvlan_process_v4_outbound(struct sk_buff *skb, bool xnet)
 {
 	const struct iphdr *ip4h = ip_hdr(skb);
 	struct net_device *dev = skb->dev;
@@ -365,7 +365,7 @@ static int ipvlan_process_v4_outbound(struct sk_buff *skb)
 		ip_rt_put(rt);
 		goto err;
 	}
-	skb_dst_drop(skb);
+	skb_scrub_packet(skb, xnet);
 	skb_dst_set(skb, &rt->dst);
 	err = ip_local_out(net, skb->sk, skb);
 	if (unlikely(net_xmit_eval(err)))
@@ -380,7 +380,7 @@ out:
 	return ret;
 }
 
-static int ipvlan_process_v6_outbound(struct sk_buff *skb)
+static int ipvlan_process_v6_outbound(struct sk_buff *skb, bool xnet)
 {
 	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	struct net_device *dev = skb->dev;
@@ -403,7 +403,7 @@ static int ipvlan_process_v6_outbound(struct sk_buff *skb)
 		dst_release(dst);
 		goto err;
 	}
-	skb_dst_drop(skb);
+	skb_scrub_packet(skb, xnet);
 	skb_dst_set(skb, dst);
 	err = ip6_local_out(net, skb->sk, skb);
 	if (unlikely(net_xmit_eval(err)))
@@ -418,8 +418,7 @@ out:
 	return ret;
 }
 
-static int ipvlan_process_outbound(struct sk_buff *skb,
-				   const struct ipvl_dev *ipvlan)
+static int ipvlan_process_outbound(struct sk_buff *skb, bool xnet)
 {
 	struct ethhdr *ethh = eth_hdr(skb);
 	int ret = NET_XMIT_DROP;
@@ -443,9 +442,9 @@ static int ipvlan_process_outbound(struct sk_buff *skb,
 	}
 
 	if (skb->protocol == htons(ETH_P_IPV6))
-		ret = ipvlan_process_v6_outbound(skb);
+		ret = ipvlan_process_v6_outbound(skb, xnet);
 	else if (skb->protocol == htons(ETH_P_IP))
-		ret = ipvlan_process_v4_outbound(skb);
+		ret = ipvlan_process_v4_outbound(skb, xnet);
 	else {
 		pr_warn_ratelimited("Dropped outbound packet type=%x\n",
 				    ntohs(skb->protocol));
@@ -481,6 +480,7 @@ static int ipvlan_xmit_mode_l3(struct sk_buff *skb, struct net_device *dev)
 	void *lyr3h;
 	struct ipvl_addr *addr;
 	int addr_type;
+	bool xnet;
 
 	lyr3h = ipvlan_get_L3_hdr(skb, &addr_type);
 	if (!lyr3h)
@@ -491,8 +491,9 @@ static int ipvlan_xmit_mode_l3(struct sk_buff *skb, struct net_device *dev)
 		return ipvlan_rcv_frame(addr, &skb, true);
 
 out:
+	xnet = !net_eq(dev_net(skb->dev), dev_net(ipvlan->phy_dev));
 	skb->dev = ipvlan->phy_dev;
-	return ipvlan_process_outbound(skb, ipvlan);
+	return ipvlan_process_outbound(skb, xnet);
 }
 
 static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
-- 
2.7.0.rc3.207.g0ac5344
