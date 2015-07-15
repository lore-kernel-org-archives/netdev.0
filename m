From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 02/12] can: flexcan: don't touch skb after netif_receive_skb()
Date: Wed, 15 Jul 2015 09:09:39 +0200
Message-ID: <1436944189-26618-3-git-send-email-mkl@pengutronix.de>
References: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no guarantee that the skb is in the same state after calling
net_receive_skb() or netif_rx(). It might be freed or reused. Not really
harmful as its a read access, except you turn on the proper debugging options
which catch a use after free.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 6201c5a1a884..b1e8d729851c 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -577,10 +577,10 @@ static int flexcan_poll_bus_err(struct net_device *dev, u32 reg_esr)
 		return 0;
 
 	do_bus_err(dev, cf, reg_esr);
-	netif_receive_skb(skb);
 
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += cf->can_dlc;
+	netif_receive_skb(skb);
 
 	return 1;
 }
@@ -622,10 +622,9 @@ static int flexcan_poll_state(struct net_device *dev, u32 reg_esr)
 	if (unlikely(new_state == CAN_STATE_BUS_OFF))
 		can_bus_off(dev);
 
-	netif_receive_skb(skb);
-
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += cf->can_dlc;
+	netif_receive_skb(skb);
 
 	return 1;
 }
@@ -670,10 +669,10 @@ static int flexcan_read_frame(struct net_device *dev)
 	}
 
 	flexcan_read_fifo(dev, cf);
-	netif_receive_skb(skb);
 
 	stats->rx_packets++;
 	stats->rx_bytes += cf->can_dlc;
+	netif_receive_skb(skb);
 
 	can_led_event(dev, CAN_LED_EVENT_RX);
 
-- 
2.1.4

