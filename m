From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/2] can: dev: let can_get_echo_skb() return dlc of CAN frame
Date: Thu,  3 Nov 2011 10:47:54 +0100
Message-ID: <1320313675-30749-2-git-send-email-mkl@pengutronix.de>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA8E0@exch01-aklnz.MARINE.NET.INT>
 <1320313675-30749-1-git-send-email-mkl@pengutronix.de>
Cc: kurt.van.dijck@eia.be, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Reuben.Dowle@navico.com,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42628 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754770Ab1KCJsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 05:48:03 -0400
In-Reply-To: <1320313675-30749-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

can_get_echo_skb() is usually called in the TX complete handler.
The stats->tx_packets and stats->tx_bytes should be updated there, too.
This patch simplifies to figure out the size of the sent CAN frame.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/dev.c   |   10 +++++++++-
 include/linux/can/dev.h |    2 +-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 25695bd..b351632 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -327,16 +327,24 @@ EXPORT_SYMBOL_GPL(can_put_echo_skb);
  * is handled in the device driver. The driver must protect
  * access to priv->echo_skb, if necessary.
  */
-void can_get_echo_skb(struct net_device *dev, unsigned int idx)
+unsigned int can_get_echo_skb(struct net_device *dev, unsigned int idx)
 {
 	struct can_priv *priv = netdev_priv(dev);
 
 	BUG_ON(idx >= priv->echo_skb_max);
 
 	if (priv->echo_skb[idx]) {
+		struct sk_buff *skb = priv->echo_skb[idx];
+		struct can_frame *cf = (struct can_frame *)skb->data;
+		u8 dlc = cf->can_dlc;
+
 		netif_rx(priv->echo_skb[idx]);
 		priv->echo_skb[idx] = NULL;
+
+		return dlc;
 	}
+
+	return 0;
 }
 EXPORT_SYMBOL_GPL(can_get_echo_skb);
 
diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
index a0969fc..5d2efe7 100644
--- a/include/linux/can/dev.h
+++ b/include/linux/can/dev.h
@@ -92,7 +92,7 @@ void can_bus_off(struct net_device *dev);
 
 void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev,
 		      unsigned int idx);
-void can_get_echo_skb(struct net_device *dev, unsigned int idx);
+unsigned int can_get_echo_skb(struct net_device *dev, unsigned int idx);
 void can_free_echo_skb(struct net_device *dev, unsigned int idx);
 
 struct sk_buff *alloc_can_skb(struct net_device *dev, struct can_frame **cf);
-- 
1.7.4.1
