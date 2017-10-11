From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net 1/7] net: qualcomm: rmnet: Remove existing logic for bridge mode
Date: Tue, 10 Oct 2017 18:20:23 -0600
Message-ID: <1507681229-27861-2-git-send-email-subashab@codeaurora.org>
References: <1507681229-27861-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:43602 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756588AbdJKAVL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 20:21:11 -0400
In-Reply-To: <1507681229-27861-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will be rewritten in the following patches.

Fixes: ceed73a2cf4a ("drivers: net: ethernet: qualcomm: rmnet: Initial implementation")
Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h |  1 -
 .../net/ethernet/qualcomm/rmnet/rmnet_handlers.c   | 77 +++-------------------
 2 files changed, 9 insertions(+), 69 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
index dde4e9f..0b0c5a7 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
@@ -34,7 +34,6 @@ struct rmnet_endpoint {
  */
 struct rmnet_port {
 	struct net_device *dev;
-	struct rmnet_endpoint local_ep;
 	struct rmnet_endpoint muxed_ep[RMNET_MAX_LOGICAL_EP];
 	u32 ingress_data_format;
 	u32 egress_data_format;
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
index 540c762..b50f401 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
@@ -44,56 +44,18 @@ static void rmnet_set_skb_proto(struct sk_buff *skb)
 /* Generic handler */
 
 static rx_handler_result_t
-rmnet_bridge_handler(struct sk_buff *skb, struct rmnet_endpoint *ep)
+rmnet_deliver_skb(struct sk_buff *skb)
 {
-	if (!ep->egress_dev)
-		kfree_skb(skb);
-	else
-		rmnet_egress_handler(skb, ep);
+	skb_reset_transport_header(skb);
+	skb_reset_network_header(skb);
+	rmnet_vnd_rx_fixup(skb, skb->dev);
 
+	skb->pkt_type = PACKET_HOST;
+	skb_set_mac_header(skb, 0);
+	netif_receive_skb(skb);
 	return RX_HANDLER_CONSUMED;
 }
 
-static rx_handler_result_t
-rmnet_deliver_skb(struct sk_buff *skb, struct rmnet_endpoint *ep)
-{
-	switch (ep->rmnet_mode) {
-	case RMNET_EPMODE_NONE:
-		return RX_HANDLER_PASS;
-
-	case RMNET_EPMODE_BRIDGE:
-		return rmnet_bridge_handler(skb, ep);
-
-	case RMNET_EPMODE_VND:
-		skb_reset_transport_header(skb);
-		skb_reset_network_header(skb);
-		rmnet_vnd_rx_fixup(skb, skb->dev);
-
-		skb->pkt_type = PACKET_HOST;
-		skb_set_mac_header(skb, 0);
-		netif_receive_skb(skb);
-		return RX_HANDLER_CONSUMED;
-
-	default:
-		kfree_skb(skb);
-		return RX_HANDLER_CONSUMED;
-	}
-}
-
-static rx_handler_result_t
-rmnet_ingress_deliver_packet(struct sk_buff *skb,
-			     struct rmnet_port *port)
-{
-	if (!port) {
-		kfree_skb(skb);
-		return RX_HANDLER_CONSUMED;
-	}
-
-	skb->dev = port->local_ep.egress_dev;
-
-	return rmnet_deliver_skb(skb, &port->local_ep);
-}
-
 /* MAP handler */
 
 static rx_handler_result_t
@@ -130,7 +92,7 @@ static void rmnet_set_skb_proto(struct sk_buff *skb)
 	skb_pull(skb, sizeof(struct rmnet_map_header));
 	skb_trim(skb, len);
 	rmnet_set_skb_proto(skb);
-	return rmnet_deliver_skb(skb, ep);
+	return rmnet_deliver_skb(skb);
 }
 
 static rx_handler_result_t
@@ -204,29 +166,8 @@ rx_handler_result_t rmnet_rx_handler(struct sk_buff **pskb)
 	dev = skb->dev;
 	port = rmnet_get_port(dev);
 
-	if (port->ingress_data_format & RMNET_INGRESS_FORMAT_MAP) {
+	if (port->ingress_data_format & RMNET_INGRESS_FORMAT_MAP)
 		rc = rmnet_map_ingress_handler(skb, port);
-	} else {
-		switch (ntohs(skb->protocol)) {
-		case ETH_P_MAP:
-			if (port->local_ep.rmnet_mode ==
-				RMNET_EPMODE_BRIDGE) {
-				rc = rmnet_ingress_deliver_packet(skb, port);
-			} else {
-				kfree_skb(skb);
-				rc = RX_HANDLER_CONSUMED;
-			}
-			break;
-
-		case ETH_P_IP:
-		case ETH_P_IPV6:
-			rc = rmnet_ingress_deliver_packet(skb, port);
-			break;
-
-		default:
-			rc = RX_HANDLER_PASS;
-		}
-	}
 
 	return rc;
 }
-- 
1.9.1
