From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 01/12] can: at91_can: don't touch skb after netif_receive_skb()/netif_rx()
Date: Wed, 15 Jul 2015 09:09:38 +0200
Message-ID: <1436944189-26618-2-git-send-email-mkl@pengutronix.de>
References: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:36906 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689AbbGOHJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 03:09:55 -0400
In-Reply-To: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no guarantee that the skb is in the same state after calling
net_receive_skb() or netif_rx(). It might be freed or reused. Not really
harmful as its a read access, except you turn on the proper debugging options
which catch a use after free.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/at91_can.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index f4e40aa4d2a2..945c0955a967 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -577,10 +577,10 @@ static void at91_rx_overflow_err(struct net_device *dev)
 
 	cf->can_id |= CAN_ERR_CRTL;
 	cf->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
-	netif_receive_skb(skb);
 
 	stats->rx_packets++;
 	stats->rx_bytes += cf->can_dlc;
+	netif_receive_skb(skb);
 }
 
 /**
@@ -642,10 +642,10 @@ static void at91_read_msg(struct net_device *dev, unsigned int mb)
 	}
 
 	at91_read_mb(dev, mb, cf);
-	netif_receive_skb(skb);
 
 	stats->rx_packets++;
 	stats->rx_bytes += cf->can_dlc;
+	netif_receive_skb(skb);
 
 	can_led_event(dev, CAN_LED_EVENT_RX);
 }
@@ -802,10 +802,10 @@ static int at91_poll_err(struct net_device *dev, int quota, u32 reg_sr)
 		return 0;
 
 	at91_poll_err_frame(dev, cf, reg_sr);
-	netif_receive_skb(skb);
 
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += cf->can_dlc;
+	netif_receive_skb(skb);
 
 	return 1;
 }
@@ -1067,10 +1067,10 @@ static void at91_irq_err(struct net_device *dev)
 		return;
 
 	at91_irq_err_state(dev, cf, new_state);
-	netif_rx(skb);
 
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += cf->can_dlc;
+	netif_rx(skb);
 
 	priv->can.state = new_state;
 }
-- 
2.1.4
