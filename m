From: Marco Chiappero <marco.chiappero@intel.com>
Subject: [PATCH net-next 7/9] ipvlan: relocate ipvlan_skb_crossing_ns calls
Date: Thu, 27 Apr 2017 15:51:40 +0100
Message-ID: <20170427145142.15830-8-marco.chiappero@intel.com>
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
        id S938853AbdD0Owq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 10:52:46 -0400
In-Reply-To: <20170427145142.15830-1-marco.chiappero@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Relocate ipvlan_skb_crossing_ns invocations across the code to reduce
duplications and improve readability. Additionally introduce
ipvlan_process_l2_outbound for the purpose, similarly to
ipvlan_process_l3_outbound.

Signed-off-by: Marco Chiappero <marco.chiappero@intel.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 81dc3e5..a9fc1b5 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -289,6 +289,8 @@ void ipvlan_process_multicast(struct work_struct *work)
 		ethh = eth_hdr(skb);
 		mac_hash = ipvlan_mac_hash(ethh->h_dest);
 
+		ipvlan_skb_crossing_ns(skb, NULL);
+
 		if (ether_addr_equal(ethh->h_dest, port->dev->broadcast))
 			pkt_type = PACKET_BROADCAST;
 		else
@@ -433,7 +435,8 @@ static int ipvlan_process_l3_outbound_v6(struct sk_buff *skb)
 	return ret;
 }
 
-static int ipvlan_process_l3_outbound(struct sk_buff *skb)
+static int ipvlan_process_l3_outbound(struct sk_buff *skb,
+				      struct net_device *dev)
 {
 	struct ethhdr *ethh = eth_hdr(skb);
 	int ret = NET_XMIT_DROP;
@@ -446,6 +449,8 @@ static int ipvlan_process_l3_outbound(struct sk_buff *skb)
 		goto out;
 	}
 
+	ipvlan_skb_crossing_ns(skb, dev);
+
 	/* The ipvlan is a pseudo-L2 device, so the packets that we receive
 	 * will have L2; which need to discarded and processed further
 	 * in the net-ns of the main-device.
@@ -478,8 +483,14 @@ static int ipvlan_xmit_mode_l3(struct sk_buff *skb, struct net_device *dev)
 	if (addr)
 		return ipvlan_rcv_int_frame(addr, &skb);
 
-	ipvlan_skb_crossing_ns(skb, ipvlan->phy_dev);
-	return ipvlan_process_l3_outbound(skb);
+	return ipvlan_process_l3_outbound(skb, ipvlan->phy_dev);
+}
+
+static inline int ipvlan_process_l2_outbound(struct sk_buff *skb,
+					     struct net_device *dev)
+{
+	ipvlan_skb_crossing_ns(skb, dev);
+	return dev_queue_xmit(skb);
 }
 
 static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
@@ -505,13 +516,11 @@ static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
 		return dev_forward_skb(ipvlan->phy_dev, skb);
 
 	} else if (is_multicast_ether_addr(ethh->h_dest)) {
-		ipvlan_skb_crossing_ns(skb, NULL);
 		ipvlan_multicast_enqueue(ipvlan->port, skb, true);
 		return NET_XMIT_SUCCESS;
 	}
 
-	ipvlan_skb_crossing_ns(skb, ipvlan->phy_dev);
-	return dev_queue_xmit(skb);
+	return ipvlan_process_l2_outbound(skb, ipvlan->phy_dev);
 }
 
 int ipvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -587,10 +596,8 @@ static rx_handler_result_t ipvlan_handle_mode_l2(struct sk_buff **pskb,
 			 * when work-queue processes this frame. This is
 			 * achieved by returning RX_HANDLER_PASS.
 			 */
-			if (nskb) {
-				ipvlan_skb_crossing_ns(nskb, NULL);
+			if (nskb)
 				ipvlan_multicast_enqueue(port, nskb, false);
-			}
 		}
 	} else {
 		struct ipvl_addr *addr;
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
