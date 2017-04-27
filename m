From: Marco Chiappero <marco.chiappero@intel.com>
Subject: [PATCH net-next 5/9] ipvlan: improve and uniform naming
Date: Thu, 27 Apr 2017 15:51:38 +0100
Message-ID: <20170427145142.15830-6-marco.chiappero@intel.com>
References: <20170427145142.15830-1-marco.chiappero@intel.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Sainath Grandhi <sainath.grandhi@intel.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Marco Chiappero <marco.chiappero@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:49079 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936935AbdD0Owl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 10:52:41 -0400
In-Reply-To: <20170427145142.15830-1-marco.chiappero@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename a few functions to make them more descriptive. Also rename a
couple of variables to make them consistent with similar ones in other
functions.

Signed-off-by: Marco Chiappero <marco.chiappero@intel.com>
Tested-by: Marco Chiappero <marco.chiappero@intel.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 29 ++++++++++++++---------------
 1 file changed, 14 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 876ce37..54c4e85 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -330,7 +330,7 @@ static int ipvlan_rcv_int_frame(struct ipvl_addr *addr, struct sk_buff **pskb)
 	return RX_HANDLER_CONSUMED;
 }
 
-static int ipvlan_process_v4_outbound(struct sk_buff *skb)
+static int ipvlan_process_l3_outbound_v4(struct sk_buff *skb)
 {
 	const struct iphdr *ip4h = ip_hdr(skb);
 	struct net_device *dev = skb->dev;
@@ -367,7 +367,7 @@ static int ipvlan_process_v4_outbound(struct sk_buff *skb)
 	return ret;
 }
 
-static int ipvlan_process_v6_outbound(struct sk_buff *skb)
+static int ipvlan_process_l3_outbound_v6(struct sk_buff *skb)
 {
 	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	struct net_device *dev = skb->dev;
@@ -404,7 +404,7 @@ static int ipvlan_process_v6_outbound(struct sk_buff *skb)
 	return ret;
 }
 
-static int ipvlan_process_outbound(struct sk_buff *skb)
+static int ipvlan_process_l3_outbound(struct sk_buff *skb)
 {
 	struct ethhdr *ethh = eth_hdr(skb);
 	int ret = NET_XMIT_DROP;
@@ -428,9 +428,9 @@ static int ipvlan_process_outbound(struct sk_buff *skb)
 	}
 
 	if (skb->protocol == htons(ETH_P_IPV6)) {
-		ret = ipvlan_process_v6_outbound(skb);
+		ret = ipvlan_process_l3_outbound_v6(skb);
 	} else if (skb->protocol == htons(ETH_P_IP)) {
-		ret = ipvlan_process_v4_outbound(skb);
+		ret = ipvlan_process_l3_outbound_v4(skb);
 	} else {
 		pr_warn_ratelimited("Dropped outbound packet type=%x\n",
 				    ntohs(skb->protocol));
@@ -479,16 +479,16 @@ static int ipvlan_xmit_mode_l3(struct sk_buff *skb, struct net_device *dev)
 		return ipvlan_rcv_int_frame(addr, &skb);
 
 	ipvlan_skb_crossing_ns(skb, ipvlan->phy_dev);
-	return ipvlan_process_outbound(skb);
+	return ipvlan_process_l3_outbound(skb);
 }
 
 static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
 {
 	const struct ipvl_dev *ipvlan = netdev_priv(dev);
-	struct ethhdr *eth = eth_hdr(skb);
+	struct ethhdr *ethh = eth_hdr(skb);
 	struct ipvl_addr *addr;
 
-	if (ether_addr_equal(eth->h_dest, eth->h_source)) {
+	if (ether_addr_equal(ethh->h_dest, ethh->h_source)) {
 		addr = ipvlan_get_slave_addr_dst(skb, ipvlan->port);
 		if (addr)
 			return ipvlan_rcv_int_frame(addr, &skb);
@@ -504,7 +504,7 @@ static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
 		 */
 		return dev_forward_skb(ipvlan->phy_dev, skb);
 
-	} else if (is_multicast_ether_addr(eth->h_dest)) {
+	} else if (is_multicast_ether_addr(ethh->h_dest)) {
 		ipvlan_skb_crossing_ns(skb, NULL);
 		ipvlan_multicast_enqueue(ipvlan->port, skb, true);
 		return NET_XMIT_SUCCESS;
@@ -576,9 +576,8 @@ static rx_handler_result_t ipvlan_handle_mode_l2(struct sk_buff **pskb,
 						 struct ipvl_port *port)
 {
 	struct sk_buff *skb = *pskb;
-	struct ethhdr *eth = eth_hdr(skb);
 
-	if (is_multicast_ether_addr(eth->h_dest)) {
+	if (is_multicast_ether_addr(eth_hdr(skb)->h_dest)) {
 		if (ipvlan_external_frame(skb, port)) {
 			struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
 
@@ -628,8 +627,8 @@ rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb)
 	return RX_HANDLER_CONSUMED;
 }
 
-static struct ipvl_addr *ipvlan_skb_to_addr(struct sk_buff *skb,
-					    struct net_device *dev)
+static struct ipvl_addr *ipvlan_skb_to_addr_l3s(struct sk_buff *skb,
+						struct net_device *dev)
 {
 	struct ipvl_port *port;
 
@@ -649,7 +648,7 @@ struct sk_buff *ipvlan_l3_rcv(struct net_device *dev, struct sk_buff *skb,
 	struct ipvl_addr *addr;
 	struct net_device *sdev;
 
-	addr = ipvlan_skb_to_addr(skb, dev);
+	addr = ipvlan_skb_to_addr_l3s(skb, dev);
 	if (!addr)
 		goto out;
 
@@ -699,7 +698,7 @@ unsigned int ipvlan_nf_input(void *priv, struct sk_buff *skb,
 	struct ipvl_addr *addr;
 	unsigned int len;
 
-	addr = ipvlan_skb_to_addr(skb, skb->dev);
+	addr = ipvlan_skb_to_addr_l3s(skb, skb->dev);
 	if (!addr)
 		goto out;
 
-- 
2.9.3

--------------------------------------------------------------
Intel Research and Development Ireland Limited
Registered in Ireland
Registered Office: Collinstown Industrial Park, Leixlip, County Kildare
Registered Number: 308263


This e-mail and any attachments may contain confidential material for the sole
use of the intended recipient(s). Any review or distribution by others is
strictly prohibited. If you are not the intended recipient, please contact the
sender and delete all copies.
