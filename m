From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 4/4] net: qualcomm: rmnet: Add support for GRO
Date: Tue, 24 Oct 2017 22:55:29 -0600
Message-ID: <1508907329-1077-5-git-send-email-subashab@codeaurora.org>
References: <1508907329-1077-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:43394 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751895AbdJYEzx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 00:55:53 -0400
In-Reply-To: <1508907329-1077-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add gro_cells so that rmnet devices can call gro_cells_receive
instead of netif_receive_skb.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/rmnet/Kconfig          | 1 +
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c   | 6 +++---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h   | 2 ++
 drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c | 4 +++-
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c      | 9 ++++++++-
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h      | 2 +-
 6 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/Kconfig b/drivers/net/ethernet/qualcomm/rmnet/Kconfig
index 6e2587a..9bb06d2 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/Kconfig
+++ b/drivers/net/ethernet/qualcomm/rmnet/Kconfig
@@ -5,6 +5,7 @@
 menuconfig RMNET
 	tristate "RmNet MAP driver"
 	default n
+	select GRO_CELLS
 	---help---
 	  If you select this, you will enable the RMNET module which is used
 	  for handling data in the multiplexing and aggregation protocol (MAP)
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
index 71bee1a..5ce4287 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
@@ -191,7 +191,7 @@ static int rmnet_newlink(struct net *src_net, struct net_device *dev,
 	return 0;
 
 err2:
-	rmnet_vnd_dellink(mux_id, port, ep);
+	rmnet_vnd_dellink(mux_id, port, ep, dev);
 err1:
 	rmnet_unregister_real_device(real_dev, port);
 err0:
@@ -221,7 +221,7 @@ static void rmnet_dellink(struct net_device *dev, struct list_head *head)
 	if (ep) {
 		hlist_del_init_rcu(&ep->hlnode);
 		rmnet_unregister_bridge(dev, port);
-		rmnet_vnd_dellink(mux_id, port, ep);
+		rmnet_vnd_dellink(mux_id, port, ep, dev);
 		kfree(ep);
 	}
 	rmnet_unregister_real_device(real_dev, port);
@@ -239,7 +239,7 @@ static int rmnet_dev_walk_unreg(struct net_device *rmnet_dev, void *data)
 	ep = rmnet_get_endpoint(d->port, mux_id);
 	if (ep) {
 		hlist_del_init_rcu(&ep->hlnode);
-		rmnet_vnd_dellink(mux_id, d->port, ep);
+		rmnet_vnd_dellink(mux_id, d->port, ep, rmnet_dev);
 		kfree(ep);
 	}
 	netdev_upper_dev_unlink(rmnet_dev, d->real_dev);
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
index 9586703d..c19259e 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
@@ -14,6 +14,7 @@
  */
 
 #include <linux/skbuff.h>
+#include <net/gro_cells.h>
 
 #ifndef _RMNET_CONFIG_H_
 #define _RMNET_CONFIG_H_
@@ -58,6 +59,7 @@ struct rmnet_priv {
 	u8 mux_id;
 	struct net_device *real_dev;
 	struct rmnet_pcpu_stats __percpu *pcpu_stats;
+	struct gro_cells gro_cells;
 };
 
 struct rmnet_port *rmnet_get_port(struct net_device *real_dev);
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
index 1ea9783..29842cc 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
@@ -46,13 +46,15 @@ static void rmnet_set_skb_proto(struct sk_buff *skb)
 static void
 rmnet_deliver_skb(struct sk_buff *skb)
 {
+	struct rmnet_priv *priv = netdev_priv(skb->dev);
+
 	skb_reset_transport_header(skb);
 	skb_reset_network_header(skb);
 	rmnet_vnd_rx_fixup(skb, skb->dev);
 
 	skb->pkt_type = PACKET_HOST;
 	skb_set_mac_header(skb, 0);
-	netif_receive_skb(skb);
+	gro_cells_receive(&priv->gro_cells, skb);
 }
 
 /* MAP handler */
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
index b0befa1..45a97eb 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
@@ -149,6 +149,8 @@ static void rmnet_get_stats64(struct net_device *dev,
  */
 void rmnet_vnd_setup(struct net_device *rmnet_dev)
 {
+	struct rmnet_priv *priv = netdev_priv(rmnet_dev);
+
 	rmnet_dev->netdev_ops = &rmnet_vnd_ops;
 	rmnet_dev->mtu = RMNET_DFLT_PACKET_SIZE;
 	rmnet_dev->needed_headroom = RMNET_NEEDED_HEADROOM;
@@ -162,6 +164,8 @@ void rmnet_vnd_setup(struct net_device *rmnet_dev)
 	rmnet_dev->flags &= ~(IFF_BROADCAST | IFF_MULTICAST);
 
 	rmnet_dev->needs_free_netdev = true;
+
+	gro_cells_init(&priv->gro_cells, rmnet_dev);
 }
 
 /* Exposed API */
@@ -196,11 +200,14 @@ int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
 }
 
 int rmnet_vnd_dellink(u8 id, struct rmnet_port *port,
-		      struct rmnet_endpoint *ep)
+		      struct rmnet_endpoint *ep, struct net_device *rmnet_dev)
 {
+	struct rmnet_priv *priv = netdev_priv(rmnet_dev);
+
 	if (id >= RMNET_MAX_LOGICAL_EP || !ep->egress_dev)
 		return -EINVAL;
 
+	gro_cells_destroy(&priv->gro_cells);
 	ep->egress_dev = NULL;
 	port->nr_rmnet_devs--;
 	return 0;
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
index 71e4c32..18cd5f6c 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
@@ -22,7 +22,7 @@ int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
 		      struct net_device *real_dev,
 		      struct rmnet_endpoint *ep);
 int rmnet_vnd_dellink(u8 id, struct rmnet_port *port,
-		      struct rmnet_endpoint *ep);
+		      struct rmnet_endpoint *ep, struct net_device *rmnet_dev);
 void rmnet_vnd_rx_fixup(struct sk_buff *skb, struct net_device *dev);
 void rmnet_vnd_tx_fixup(struct sk_buff *skb, struct net_device *dev);
 u8 rmnet_vnd_get_mux(struct net_device *rmnet_dev);
-- 
1.9.1
