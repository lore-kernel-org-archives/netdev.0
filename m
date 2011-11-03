From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/2] flexcan: Fix CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK
Date: Thu,  3 Nov 2011 10:47:55 +0100
Message-ID: <1320313675-30749-3-git-send-email-mkl@pengutronix.de>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA8E0@exch01-aklnz.MARINE.NET.INT>
 <1320313675-30749-1-git-send-email-mkl@pengutronix.de>
Cc: kurt.van.dijck@eia.be, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Reuben.Dowle@navico.com,
	Reuben Dowle <reuben.dowle@navico.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42627 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739Ab1KCJsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 05:48:03 -0400
In-Reply-To: <1320313675-30749-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Reuben Dowle <Reuben.Dowle@navico.com>

Currently the flexcan driver uses hardware local echo. This blindly
echos all transmitted frames to all receiving sockets, regardless what
CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK are set to.

This patch now submits transmitted frames to be echoed in the transmit
complete interrupt, preserving the reference to the sending
socket. This allows the can protocol to correctly handle the local
echo.

Further this patch moves tx_bytes statistic accounting into the tx_complete
handler.

Signed-off-by: Reuben Dowle <reuben.dowle@navico.com>
[mkl: move tx_bytes accounting into tx_complete handler; cleanups]
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index e023379..ea7b668 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -269,7 +269,6 @@ static int flexcan_get_berr_counter(const struct net_device *dev,
 static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	const struct flexcan_priv *priv = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
 	struct flexcan_regs __iomem *regs = priv->base;
 	struct can_frame *cf = (struct can_frame *)skb->data;
 	u32 can_id;
@@ -299,14 +298,11 @@ static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		flexcan_write(data, &regs->cantxfg[FLEXCAN_TX_BUF_ID].data[1]);
 	}
 
+	can_put_echo_skb(skb, dev, 0);
+
 	flexcan_write(can_id, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_id);
 	flexcan_write(ctrl, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_ctrl);
 
-	kfree_skb(skb);
-
-	/* tx_packets is incremented in flexcan_irq */
-	stats->tx_bytes += cf->can_dlc;
-
 	return NETDEV_TX_OK;
 }
 
@@ -609,9 +605,10 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
 
 	/* transmission complete interrupt */
 	if (reg_iflag1 & (1 << FLEXCAN_TX_BUF_ID)) {
-		/* tx_bytes is incremented in flexcan_start_xmit */
+		stats->tx_bytes += can_get_echo_skb(dev, 0);
 		stats->tx_packets++;
 		flexcan_write((1 << FLEXCAN_TX_BUF_ID), &regs->iflag1);
+		can_get_echo_skb(dev, 0);
 		netif_wake_queue(dev);
 	}
 
@@ -697,12 +694,13 @@ static int flexcan_chip_start(struct net_device *dev)
 	 * only supervisor access
 	 * enable warning int
 	 * choose format C
+	 * disable local echo
 	 *
 	 */
 	reg_mcr = flexcan_read(&regs->mcr);
 	reg_mcr |= FLEXCAN_MCR_FRZ | FLEXCAN_MCR_FEN | FLEXCAN_MCR_HALT |
 		FLEXCAN_MCR_SUPV | FLEXCAN_MCR_WRN_EN |
-		FLEXCAN_MCR_IDAM_C;
+		FLEXCAN_MCR_IDAM_C | FLEXCAN_MCR_SRX_DIS;
 	dev_dbg(dev->dev.parent, "%s: writing mcr=0x%08x", __func__, reg_mcr);
 	flexcan_write(reg_mcr, &regs->mcr);
 
@@ -970,7 +968,7 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
 		goto failed_map;
 	}
 
-	dev = alloc_candev(sizeof(struct flexcan_priv), 0);
+	dev = alloc_candev(sizeof(struct flexcan_priv), 1);
 	if (!dev) {
 		err = -ENOMEM;
 		goto failed_alloc;
@@ -978,7 +976,7 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
 
 	dev->netdev_ops = &flexcan_netdev_ops;
 	dev->irq = irq;
-	dev->flags |= IFF_ECHO; /* we support local echo in hardware */
+	dev->flags |= IFF_ECHO;
 
 	priv = netdev_priv(dev);
 	priv->can.clock.freq = clock_freq;
-- 
1.7.4.1
