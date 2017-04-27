From: Marco Chiappero <marco.chiappero@intel.com>
Subject: [PATCH net-next 3/9] ipvlan: replace ipvlan_rcv_frame
Date: Thu, 27 Apr 2017 15:51:36 +0100
Message-ID: <20170427145142.15830-4-marco.chiappero@intel.com>
References: <20170427145142.15830-1-marco.chiappero@intel.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Sainath Grandhi <sainath.grandhi@intel.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Marco Chiappero <marco.chiappero@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:46967 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755640AbdD0Owk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 10:52:40 -0400
In-Reply-To: <20170427145142.15830-1-marco.chiappero@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So far the ipvlan_rcv_frame function handled the reception for slaves of
both externally and internally (from the same port) originated packets.
However they need significantly different processing, with almost no
code to share.

This patch modifies ipvlan_rcv_frame to deal with internal packets only,
renaming it to ipvlan_rcv_int_frame, and introduces a new
ipvlan_rcv_ext_frame function for externally originated ones.

Signed-off-by: Marco Chiappero <marco.chiappero@intel.com>
Tested-by: Marco Chiappero <marco.chiappero@intel.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 58 +++++++++++++++++++++-------------------
 1 file changed, 30 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index fd40c25..4683bad 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -280,46 +280,36 @@ static void ipvlan_skb_crossing_ns(struct sk_buff *skb, struct net_device *dev)
 		skb->dev = dev;
 }
 
-static int ipvlan_rcv_frame(struct ipvl_addr *addr, struct sk_buff **pskb,
-			    bool local)
+static int ipvlan_rcv_int_frame(struct ipvl_addr *addr, struct sk_buff **pskb)
 {
 	struct ipvl_dev *ipvlan = addr->master;
 	struct net_device *dev = ipvlan->dev;
-	unsigned int len;
-	rx_handler_result_t ret = RX_HANDLER_CONSUMED;
-	bool success = false;
 	struct sk_buff *skb = *pskb;
+	unsigned int len = skb->len + ETH_HLEN;
+	bool success = false;
 
-	len = skb->len + ETH_HLEN;
 	/* Only packets exchanged between two local slaves need to have
 	 * device-up check as well as skb-share check.
 	 */
-	if (local) {
-		if (unlikely(!(dev->flags & IFF_UP))) {
-			kfree_skb(skb);
-			goto out;
-		}
+	if (unlikely(!(dev->flags & IFF_UP))) {
+		kfree_skb(skb);
+		goto out;
+	}
 
-		skb = skb_share_check(skb, GFP_ATOMIC);
-		if (!skb)
-			goto out;
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (unlikely(!skb))
+		goto out;
 
-		*pskb = skb;
-	}
+	*pskb = skb;
 	ipvlan_skb_crossing_ns(skb, dev);
+	skb->pkt_type = PACKET_HOST;
 
-	if (local) {
-		skb->pkt_type = PACKET_HOST;
-		if (dev_forward_skb(ipvlan->dev, skb) == NET_RX_SUCCESS)
-			success = true;
-	} else {
-		ret = RX_HANDLER_ANOTHER;
+	if (dev_forward_skb(ipvlan->dev, skb) == NET_RX_SUCCESS)
 		success = true;
-	}
 
 out:
 	ipvlan_count_rx(ipvlan, len, success, false);
-	return ret;
+	return RX_HANDLER_CONSUMED;
 }
 
 static struct ipvl_addr *ipvlan_addr_lookup(struct ipvl_port *port,
@@ -525,7 +515,7 @@ static int ipvlan_xmit_mode_l3(struct sk_buff *skb, struct net_device *dev)
 
 	addr = ipvlan_addr_lookup(ipvlan->port, lyr3h, addr_type, true);
 	if (addr)
-		return ipvlan_rcv_frame(addr, &skb, true);
+		return ipvlan_rcv_int_frame(addr, &skb);
 
 out:
 	ipvlan_skb_crossing_ns(skb, ipvlan->phy_dev);
@@ -546,7 +536,7 @@ static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
 			addr = ipvlan_addr_lookup(ipvlan->port, lyr3h,
 						  addr_type, true);
 			if (addr)
-				return ipvlan_rcv_frame(addr, &skb, true);
+				return ipvlan_rcv_int_frame(addr, &skb);
 		}
 		skb = skb_share_check(skb, GFP_ATOMIC);
 		if (!skb)
@@ -616,6 +606,18 @@ static bool ipvlan_external_frame(struct sk_buff *skb, struct ipvl_port *port)
 	return true;
 }
 
+static int ipvlan_rcv_ext_frame(struct ipvl_addr *addr, struct sk_buff *skb)
+{
+	struct ipvl_dev *ipvlan = addr->master;
+	struct net_device *dev = ipvlan->dev;
+	unsigned int len = skb->len + ETH_HLEN;
+
+	ipvlan_skb_crossing_ns(skb, dev);
+	ipvlan_count_rx(ipvlan, len, true, false);
+
+	return RX_HANDLER_ANOTHER;
+}
+
 static rx_handler_result_t ipvlan_handle_mode_l3(struct sk_buff **pskb,
 						 struct ipvl_port *port)
 {
@@ -631,7 +633,7 @@ static rx_handler_result_t ipvlan_handle_mode_l3(struct sk_buff **pskb,
 
 	addr = ipvlan_addr_lookup(port, lyr3h, addr_type, true);
 	if (addr)
-		ret = ipvlan_rcv_frame(addr, pskb, false);
+		ret = ipvlan_rcv_ext_frame(addr, skb);
 
 out:
 	return ret;
@@ -670,7 +672,7 @@ static rx_handler_result_t ipvlan_handle_mode_l2(struct sk_buff **pskb,
 
 		addr = ipvlan_addr_lookup(port, lyr3h, addr_type, true);
 		if (addr)
-			ret = ipvlan_rcv_frame(addr, pskb, false);
+			ret = ipvlan_rcv_ext_frame(addr, skb);
 	}
 
 	return ret;
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
