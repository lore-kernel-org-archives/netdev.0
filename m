From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next v2 4/4] net: qualcomm: rmnet: Add support for GRO
Date: Thu, 26 Oct 2017 11:06:49 -0600
Message-ID: <1509037609-15444-5-git-send-email-subashab@codeaurora.org>
References: <1509037609-15444-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46232 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932399AbdJZRHc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 13:07:32 -0400
In-Reply-To: <1509037609-15444-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add gro_cells so that rmnet devices can call gro_cells_receive
instead of netif_receive_skb.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Cc: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/qualcomm/rmnet/Kconfig          | 1 +
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h   | 2 ++
 drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c | 4 +++-
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c      | 8 ++++++++
 4 files changed, 14 insertions(+), 1 deletion(-)

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
index b0befa1..9caa5e3 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
@@ -87,11 +87,18 @@ static int rmnet_vnd_get_iflink(const struct net_device *dev)
 static int rmnet_vnd_init(struct net_device *dev)
 {
 	struct rmnet_priv *priv = netdev_priv(dev);
+	int err;
 
 	priv->pcpu_stats = alloc_percpu(struct rmnet_pcpu_stats);
 	if (!priv->pcpu_stats)
 		return -ENOMEM;
 
+	err = gro_cells_init(&priv->gro_cells, dev);
+	if (err) {
+		free_percpu(priv->pcpu_stats);
+		return err;
+	}
+
 	return 0;
 }
 
@@ -99,6 +106,7 @@ static void rmnet_vnd_uninit(struct net_device *dev)
 {
 	struct rmnet_priv *priv = netdev_priv(dev);
 
+	gro_cells_destroy(&priv->gro_cells);
 	free_percpu(priv->pcpu_stats);
 }
 
-- 
1.9.1
