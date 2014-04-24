From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 04/26] can: c_can: Do not access skb after net_receive_skb()
Date: Fri, 25 Apr 2014 00:00:07 +0200
Message-ID: <1398376829-6771-5-git-send-email-mkl@pengutronix.de>
References: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Thomas Gleixner <tglx@linutronix.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>

There is no guarantee that the skb is in the same state after calling
net_receive_skb(). It might be freed or reused. Not really harmful as
its a read access, except you turn on the proper debugging options
which catch a use after free.

The whole can subsystem is full of this. Copy and paste ....

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Alexander Stein <alexander.stein@systec-electronic.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 8c725f4..6038761 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -429,10 +429,10 @@ static int c_can_read_msg_object(struct net_device *dev, int iface, int ctrl)
 		}
 	}
 
-	netif_receive_skb(skb);
-
 	stats->rx_packets++;
 	stats->rx_bytes += frame->can_dlc;
+
+	netif_receive_skb(skb);
 	return 0;
 }
 
@@ -960,9 +960,9 @@ static int c_can_handle_state_change(struct net_device *dev,
 		break;
 	}
 
-	netif_receive_skb(skb);
 	stats->rx_packets++;
 	stats->rx_bytes += cf->can_dlc;
+	netif_receive_skb(skb);
 
 	return 1;
 }
@@ -1033,10 +1033,9 @@ static int c_can_handle_bus_err(struct net_device *dev,
 	/* set a `lec` value so that we can check for updates later */
 	priv->write_reg(priv, C_CAN_STS_REG, LEC_UNUSED);
 
-	netif_receive_skb(skb);
 	stats->rx_packets++;
 	stats->rx_bytes += cf->can_dlc;
-
+	netif_receive_skb(skb);
 	return 1;
 }
 
-- 
1.9.0.279.gdc9e3eb

