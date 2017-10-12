From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next v2 4/7] net: qualcomm: rmnet: Remove duplicate setting of rmnet private info
Date: Wed, 11 Oct 2017 18:43:55 -0600
Message-ID: <1507769038-30231-5-git-send-email-subashab@codeaurora.org>
References: <1507769038-30231-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33210 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752641AbdJLAoW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 20:44:22 -0400
In-Reply-To: <1507769038-30231-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The end point is set twice in the local_ep as well as the mux_id and
the real_dev in the rmnet private structure. Remove the local_ep.
While these elements are equivalent, rmnet_endpoint will be
used only as part of the rmnet_port for muxed scenarios in VND mode.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c   | 10 ++--------
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h   |  4 ----
 drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c | 18 ++++++++++--------
 drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.h |  3 +--
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c      | 19 ++-----------------
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h      |  1 -
 6 files changed, 15 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
index 85fce9c..96058bb 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
@@ -67,13 +67,8 @@ static int rmnet_is_real_dev_registered(const struct net_device *real_dev)
 	struct rmnet_endpoint *ep;
 	struct rmnet_port *port;
 
-	if (!rmnet_is_real_dev_registered(dev)) {
-		ep = rmnet_vnd_get_endpoint(dev);
-	} else {
-		port = rmnet_get_port_rtnl(dev);
-
-		ep = &port->muxed_ep[config_id];
-	}
+	port = rmnet_get_port_rtnl(dev);
+	ep = &port->muxed_ep[config_id];
 
 	return ep;
 }
@@ -183,7 +178,6 @@ static int rmnet_newlink(struct net *src_net, struct net_device *dev,
 	port->rmnet_mode = mode;
 
 	rmnet_set_endpoint_config(real_dev, mux_id, dev);
-	rmnet_set_endpoint_config(dev, mux_id, real_dev);
 	return 0;
 
 err2:
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
index 03d473f..c5f5c6d 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
@@ -20,9 +20,6 @@
 
 #define RMNET_MAX_LOGICAL_EP 255
 
-/* Information about the next device to deliver the packet to.
- * Exact usage of this parameter depends on the rmnet_mode.
- */
 struct rmnet_endpoint {
 	u8 mux_id;
 	struct net_device *egress_dev;
@@ -44,7 +41,6 @@ struct rmnet_port {
 extern struct rtnl_link_ops rmnet_link_ops;
 
 struct rmnet_priv {
-	struct rmnet_endpoint local_ep;
 	u8 mux_id;
 	struct net_device *real_dev;
 };
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
index 86e37cc..e0802d3 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
@@ -116,8 +116,7 @@ static void rmnet_set_skb_proto(struct sk_buff *skb)
 }
 
 static int rmnet_map_egress_handler(struct sk_buff *skb,
-				    struct rmnet_port *port,
-				    struct rmnet_endpoint *ep,
+				    struct rmnet_port *port, u8 mux_id,
 				    struct net_device *orig_dev)
 {
 	int required_headroom, additional_header_len;
@@ -136,10 +135,10 @@ static int rmnet_map_egress_handler(struct sk_buff *skb,
 		return RMNET_MAP_CONSUMED;
 
 	if (port->egress_data_format & RMNET_EGRESS_FORMAT_MUXING) {
-		if (ep->mux_id == 0xff)
+		if (mux_id == 0xff)
 			map_header->mux_id = 0;
 		else
-			map_header->mux_id = ep->mux_id;
+			map_header->mux_id = mux_id;
 	}
 
 	skb->protocol = htons(ETH_P_MAP);
@@ -176,14 +175,17 @@ rx_handler_result_t rmnet_rx_handler(struct sk_buff **pskb)
  * for egress device configured in logical endpoint. Packet is then transmitted
  * on the egress device.
  */
-void rmnet_egress_handler(struct sk_buff *skb,
-			  struct rmnet_endpoint *ep)
+void rmnet_egress_handler(struct sk_buff *skb)
 {
 	struct net_device *orig_dev;
 	struct rmnet_port *port;
+	struct rmnet_priv *priv;
+	u8 mux_id;
 
 	orig_dev = skb->dev;
-	skb->dev = ep->egress_dev;
+	priv = netdev_priv(orig_dev);
+	skb->dev = priv->real_dev;
+	mux_id = priv->mux_id;
 
 	port = rmnet_get_port(skb->dev);
 	if (!port) {
@@ -192,7 +194,7 @@ void rmnet_egress_handler(struct sk_buff *skb,
 	}
 
 	if (port->egress_data_format & RMNET_EGRESS_FORMAT_MAP) {
-		switch (rmnet_map_egress_handler(skb, port, ep, orig_dev)) {
+		switch (rmnet_map_egress_handler(skb, port, mux_id, orig_dev)) {
 		case RMNET_MAP_CONSUMED:
 			return;
 
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.h
index f2638cf..3537e4c 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.h
@@ -18,8 +18,7 @@
 
 #include "rmnet_config.h"
 
-void rmnet_egress_handler(struct sk_buff *skb,
-			  struct rmnet_endpoint *ep);
+void rmnet_egress_handler(struct sk_buff *skb);
 
 rx_handler_result_t rmnet_rx_handler(struct sk_buff **pskb);
 
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
index 7f90d55..4ca59a4 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
@@ -45,8 +45,8 @@ static netdev_tx_t rmnet_vnd_start_xmit(struct sk_buff *skb,
 	struct rmnet_priv *priv;
 
 	priv = netdev_priv(dev);
-	if (priv->local_ep.egress_dev) {
-		rmnet_egress_handler(skb, &priv->local_ep);
+	if (priv->real_dev) {
+		rmnet_egress_handler(skb);
 	} else {
 		dev->stats.tx_dropped++;
 		kfree_skb(skb);
@@ -143,21 +143,6 @@ u8 rmnet_vnd_get_mux(struct net_device *rmnet_dev)
 	return priv->mux_id;
 }
 
-/* Gets the logical endpoint configuration for a RmNet virtual network device
- * node. Caller should confirm that devices is a RmNet VND before calling.
- */
-struct rmnet_endpoint *rmnet_vnd_get_endpoint(struct net_device *rmnet_dev)
-{
-	struct rmnet_priv *priv;
-
-	if (!rmnet_dev)
-		return NULL;
-
-	priv = netdev_priv(rmnet_dev);
-
-	return &priv->local_ep;
-}
-
 int rmnet_vnd_do_flow_control(struct net_device *rmnet_dev, int enable)
 {
 	netdev_dbg(rmnet_dev, "Setting VND TX queue state to %d\n", enable);
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
index 8a4042f..cae134d 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
@@ -17,7 +17,6 @@
 #define _RMNET_VND_H_
 
 int rmnet_vnd_do_flow_control(struct net_device *dev, int enable);
-struct rmnet_endpoint *rmnet_vnd_get_endpoint(struct net_device *dev);
 int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
 		      struct rmnet_port *port,
 		      struct net_device *real_dev);
-- 
1.9.1
