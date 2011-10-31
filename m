From: "Reuben Dowle" <Reuben.Dowle@navico.com>
Subject: [PATCH] flexcan: Fix CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK
Date: Tue, 1 Nov 2011 11:18:03 +1300
Message-ID: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA1DD@exch01-aklnz.MARINE.NET.INT>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <linux-can@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently the flexcan driver uses hardware local echo. This blindly echos all transmitted frames to all receiving sockets, regardless what CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK are set to.

This patch now submits transmitted frames to be echoed in the transmit complete interrupt, preserving the reference to the sending socket. This allows the can protocol to correctly handle the local echo.

Signed-off-by: Reuben Dowle <reuben.dowle@navico.com>

---
 drivers/net/can/flexcan.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index e023379..542ada8 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -302,7 +302,7 @@ static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	flexcan_write(can_id, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_id);
 	flexcan_write(ctrl, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_ctrl);
 
-	kfree_skb(skb);
+	can_put_echo_skb(skb, dev, 0);
 
 	/* tx_packets is incremented in flexcan_irq */
 	stats->tx_bytes += cf->can_dlc;
@@ -612,6 +612,7 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
 		/* tx_bytes is incremented in flexcan_start_xmit */
 		stats->tx_packets++;
 		flexcan_write((1 << FLEXCAN_TX_BUF_ID), &regs->iflag1);
+		can_get_echo_skb(dev, 0);
 		netif_wake_queue(dev);
 	}
 
@@ -670,6 +671,8 @@ static int flexcan_chip_start(struct net_device *dev)
 	int err;
 	u32 reg_mcr, reg_ctrl;
 
+	can_free_echo_skb(dev, 0);
+
 	/* enable module */
 	flexcan_chip_enable(priv);
 
@@ -697,12 +700,13 @@ static int flexcan_chip_start(struct net_device *dev)
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
 
@@ -970,7 +974,7 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
 		goto failed_map;
 	}
 
-	dev = alloc_candev(sizeof(struct flexcan_priv), 0);
+	dev = alloc_candev(sizeof(struct flexcan_priv), 1);
 	if (!dev) {
 		err = -ENOMEM;
 		goto failed_alloc;
@@ -978,7 +982,14 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
 
 	dev->netdev_ops = &flexcan_netdev_ops;
 	dev->irq = irq;
-	dev->flags |= IFF_ECHO; /* we support local echo in hardware */
+
+	/* Driver supports local echo.
+	 * We support local echo in hardware, however this is not used because
+	 * hardware local echo loses the sending socket reference
+	 * (thus CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK socket options
+	 *  would not work)
+	 */
+	dev->flags |= IFF_ECHO;
 
 	priv = netdev_priv(dev);
 	priv->can.clock.freq = clock_freq;


