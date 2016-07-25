From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next] ipvlan: Scrub skb before crossing the namespace boundry
Date: Mon, 25 Jul 2016 14:38:16 -0700
Message-ID: <1469482696-32271-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35226 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753309AbcGYVie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 17:38:34 -0400
Received: by mail-pf0-f193.google.com with SMTP id h186so12559778pfg.2
        for <netdev@vger.kernel.org>; Mon, 25 Jul 2016 14:38:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

The earlier patch c3aaa06d5a63 (ipvlan: scrub skb before routing
in L3 mode.) did this but only for TX path in L3 mode. This
patch extends it for both the modes for TX/RX path.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 39 +++++++++++++++++++++++++--------------
 1 file changed, 25 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index d6d0524ee5fd..b5f9511d819e 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -254,6 +254,18 @@ acct:
 	}
 }
 
+static void ipvlan_skb_crossing_ns(struct sk_buff *skb, struct net_device *dev)
+{
+	bool xnet = true;
+
+	if (dev)
+		xnet = !net_eq(dev_net(skb->dev), dev_net(dev));
+
+	skb_scrub_packet(skb, xnet);
+	if (dev)
+		skb->dev = dev;
+}
+
 static int ipvlan_rcv_frame(struct ipvl_addr *addr, struct sk_buff **pskb,
 			    bool local)
 {
@@ -280,7 +292,7 @@ static int ipvlan_rcv_frame(struct ipvl_addr *addr, struct sk_buff **pskb,
 
 		*pskb = skb;
 	}
-	skb->dev = dev;
+	ipvlan_skb_crossing_ns(skb, dev);
 
 	if (local) {
 		skb->pkt_type = PACKET_HOST;
@@ -347,7 +359,7 @@ static struct ipvl_addr *ipvlan_addr_lookup(struct ipvl_port *port,
 	return addr;
 }
 
-static int ipvlan_process_v4_outbound(struct sk_buff *skb, bool xnet)
+static int ipvlan_process_v4_outbound(struct sk_buff *skb)
 {
 	const struct iphdr *ip4h = ip_hdr(skb);
 	struct net_device *dev = skb->dev;
@@ -370,7 +382,6 @@ static int ipvlan_process_v4_outbound(struct sk_buff *skb, bool xnet)
 		ip_rt_put(rt);
 		goto err;
 	}
-	skb_scrub_packet(skb, xnet);
 	skb_dst_set(skb, &rt->dst);
 	err = ip_local_out(net, skb->sk, skb);
 	if (unlikely(net_xmit_eval(err)))
@@ -385,7 +396,7 @@ out:
 	return ret;
 }
 
-static int ipvlan_process_v6_outbound(struct sk_buff *skb, bool xnet)
+static int ipvlan_process_v6_outbound(struct sk_buff *skb)
 {
 	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	struct net_device *dev = skb->dev;
@@ -408,7 +419,6 @@ static int ipvlan_process_v6_outbound(struct sk_buff *skb, bool xnet)
 		dst_release(dst);
 		goto err;
 	}
-	skb_scrub_packet(skb, xnet);
 	skb_dst_set(skb, dst);
 	err = ip6_local_out(net, skb->sk, skb);
 	if (unlikely(net_xmit_eval(err)))
@@ -423,7 +433,7 @@ out:
 	return ret;
 }
 
-static int ipvlan_process_outbound(struct sk_buff *skb, bool xnet)
+static int ipvlan_process_outbound(struct sk_buff *skb)
 {
 	struct ethhdr *ethh = eth_hdr(skb);
 	int ret = NET_XMIT_DROP;
@@ -447,9 +457,9 @@ static int ipvlan_process_outbound(struct sk_buff *skb, bool xnet)
 	}
 
 	if (skb->protocol == htons(ETH_P_IPV6))
-		ret = ipvlan_process_v6_outbound(skb, xnet);
+		ret = ipvlan_process_v6_outbound(skb);
 	else if (skb->protocol == htons(ETH_P_IP))
-		ret = ipvlan_process_v4_outbound(skb, xnet);
+		ret = ipvlan_process_v4_outbound(skb);
 	else {
 		pr_warn_ratelimited("Dropped outbound packet type=%x\n",
 				    ntohs(skb->protocol));
@@ -485,7 +495,6 @@ static int ipvlan_xmit_mode_l3(struct sk_buff *skb, struct net_device *dev)
 	void *lyr3h;
 	struct ipvl_addr *addr;
 	int addr_type;
-	bool xnet;
 
 	lyr3h = ipvlan_get_L3_hdr(skb, &addr_type);
 	if (!lyr3h)
@@ -496,9 +505,8 @@ static int ipvlan_xmit_mode_l3(struct sk_buff *skb, struct net_device *dev)
 		return ipvlan_rcv_frame(addr, &skb, true);
 
 out:
-	xnet = !net_eq(dev_net(skb->dev), dev_net(ipvlan->phy_dev));
-	skb->dev = ipvlan->phy_dev;
-	return ipvlan_process_outbound(skb, xnet);
+	ipvlan_skb_crossing_ns(skb, ipvlan->phy_dev);
+	return ipvlan_process_outbound(skb);
 }
 
 static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
@@ -528,11 +536,12 @@ static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
 		return dev_forward_skb(ipvlan->phy_dev, skb);
 
 	} else if (is_multicast_ether_addr(eth->h_dest)) {
+		ipvlan_skb_crossing_ns(skb, NULL);
 		ipvlan_multicast_enqueue(ipvlan->port, skb);
 		return NET_XMIT_SUCCESS;
 	}
 
-	skb->dev = ipvlan->phy_dev;
+	ipvlan_skb_crossing_ns(skb, ipvlan->phy_dev);
 	return dev_queue_xmit(skb);
 }
 
@@ -622,8 +631,10 @@ static rx_handler_result_t ipvlan_handle_mode_l2(struct sk_buff **pskb,
 			 * when work-queue processes this frame. This is
 			 * achieved by returning RX_HANDLER_PASS.
 			 */
-			if (nskb)
+			if (nskb) {
+				ipvlan_skb_crossing_ns(nskb, NULL);
 				ipvlan_multicast_enqueue(port, nskb);
+			}
 		}
 	} else {
 		struct ipvl_addr *addr;
-- 
2.8.0.rc3.226.g39d4020
