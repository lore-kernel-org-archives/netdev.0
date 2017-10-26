From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next v2 1/4] net: qualcomm: rmnet: Fix the return value of rmnet_rx_handler()
Date: Thu, 26 Oct 2017 11:06:46 -0600
Message-ID: <1509037609-15444-2-git-send-email-subashab@codeaurora.org>
References: <1509037609-15444-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45856 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932137AbdJZRHT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 13:07:19 -0400
In-Reply-To: <1509037609-15444-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since packet is always consumed by rmnet_rx_handler(), we always
return RX_HANDLER_CONSUMED. There is no need to pass on this
value through multiple functions.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 .../net/ethernet/qualcomm/rmnet/rmnet_handlers.c   | 31 +++++++++-------------
 drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h    |  3 +--
 .../ethernet/qualcomm/rmnet/rmnet_map_command.c    |  4 +--
 3 files changed, 14 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
index df3d2d1..5dd186d 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
@@ -43,7 +43,7 @@ static void rmnet_set_skb_proto(struct sk_buff *skb)
 
 /* Generic handler */
 
-static rx_handler_result_t
+static void
 rmnet_deliver_skb(struct sk_buff *skb)
 {
 	skb_reset_transport_header(skb);
@@ -53,12 +53,11 @@ static void rmnet_set_skb_proto(struct sk_buff *skb)
 	skb->pkt_type = PACKET_HOST;
 	skb_set_mac_header(skb, 0);
 	netif_receive_skb(skb);
-	return RX_HANDLER_CONSUMED;
 }
 
 /* MAP handler */
 
-static rx_handler_result_t
+static void
 __rmnet_map_ingress_handler(struct sk_buff *skb,
 			    struct rmnet_port *port)
 {
@@ -91,31 +90,27 @@ static void rmnet_set_skb_proto(struct sk_buff *skb)
 	skb_pull(skb, sizeof(struct rmnet_map_header));
 	skb_trim(skb, len);
 	rmnet_set_skb_proto(skb);
-	return rmnet_deliver_skb(skb);
+	rmnet_deliver_skb(skb);
+	return;
 
 free_skb:
 	kfree_skb(skb);
-	return RX_HANDLER_CONSUMED;
 }
 
-static rx_handler_result_t
+static void
 rmnet_map_ingress_handler(struct sk_buff *skb,
 			  struct rmnet_port *port)
 {
 	struct sk_buff *skbn;
-	int rc;
 
 	if (port->ingress_data_format & RMNET_INGRESS_FORMAT_DEAGGREGATION) {
 		while ((skbn = rmnet_map_deaggregate(skb)) != NULL)
 			__rmnet_map_ingress_handler(skbn, port);
 
 		consume_skb(skb);
-		rc = RX_HANDLER_CONSUMED;
 	} else {
-		rc = __rmnet_map_ingress_handler(skb, port);
+		__rmnet_map_ingress_handler(skb, port);
 	}
-
-	return rc;
 }
 
 static int rmnet_map_egress_handler(struct sk_buff *skb,
@@ -149,15 +144,13 @@ static int rmnet_map_egress_handler(struct sk_buff *skb,
 	return RMNET_MAP_SUCCESS;
 }
 
-static rx_handler_result_t
+static void
 rmnet_bridge_handler(struct sk_buff *skb, struct net_device *bridge_dev)
 {
 	if (bridge_dev) {
 		skb->dev = bridge_dev;
 		dev_queue_xmit(skb);
 	}
-
-	return RX_HANDLER_CONSUMED;
 }
 
 /* Ingress / Egress Entry Points */
@@ -168,13 +161,12 @@ static int rmnet_map_egress_handler(struct sk_buff *skb,
  */
 rx_handler_result_t rmnet_rx_handler(struct sk_buff **pskb)
 {
-	int rc = RX_HANDLER_CONSUMED;
 	struct sk_buff *skb = *pskb;
 	struct rmnet_port *port;
 	struct net_device *dev;
 
 	if (!skb)
-		return RX_HANDLER_CONSUMED;
+		goto done;
 
 	dev = skb->dev;
 	port = rmnet_get_port(dev);
@@ -182,14 +174,15 @@ rx_handler_result_t rmnet_rx_handler(struct sk_buff **pskb)
 	switch (port->rmnet_mode) {
 	case RMNET_EPMODE_VND:
 		if (port->ingress_data_format & RMNET_INGRESS_FORMAT_MAP)
-			rc = rmnet_map_ingress_handler(skb, port);
+			rmnet_map_ingress_handler(skb, port);
 		break;
 	case RMNET_EPMODE_BRIDGE:
-		rc = rmnet_bridge_handler(skb, port->bridge_ep);
+		rmnet_bridge_handler(skb, port->bridge_ep);
 		break;
 	}
 
-	return rc;
+done:
+	return RX_HANDLER_CONSUMED;
 }
 
 /* Modifies packet as per logical endpoint configuration and egress data format
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h
index ce2302c..3af3fe7 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h
@@ -80,7 +80,6 @@ struct rmnet_map_header {
 struct sk_buff *rmnet_map_deaggregate(struct sk_buff *skb);
 struct rmnet_map_header *rmnet_map_add_map_header(struct sk_buff *skb,
 						  int hdrlen, int pad);
-rx_handler_result_t rmnet_map_command(struct sk_buff *skb,
-				      struct rmnet_port *port);
+void rmnet_map_command(struct sk_buff *skb, struct rmnet_port *port);
 
 #endif /* _RMNET_MAP_H_ */
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c
index 74d362f..51e6049 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c
@@ -76,8 +76,7 @@ static void rmnet_map_send_ack(struct sk_buff *skb,
 /* Process MAP command frame and send N/ACK message as appropriate. Message cmd
  * name is decoded here and appropriate handler is called.
  */
-rx_handler_result_t rmnet_map_command(struct sk_buff *skb,
-				      struct rmnet_port *port)
+void rmnet_map_command(struct sk_buff *skb, struct rmnet_port *port)
 {
 	struct rmnet_map_control_command *cmd;
 	unsigned char command_name;
@@ -102,5 +101,4 @@ rx_handler_result_t rmnet_map_command(struct sk_buff *skb,
 	}
 	if (rc == RMNET_MAP_COMMAND_ACK)
 		rmnet_map_send_ack(skb, rc);
-	return RX_HANDLER_CONSUMED;
 }
-- 
1.9.1
