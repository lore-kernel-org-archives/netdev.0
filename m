From: Robin Holt <holt@sgi.com>
Subject: [RFC 4/4] [flexcan] Add support for FLEXCAN_DEBUG
Date: Thu,  4 Aug 2011 21:06:19 -0500
Message-ID: <1312509979-13226-5-git-send-email-holt@sgi.com>
References: <1312509979-13226-1-git-send-email-holt@sgi.com>
Cc: Robin Holt <holt@sgi.com>, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org
To: Robin Holt <holt@sgi.com>, Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:47531 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755200Ab1HECGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2011 22:06:22 -0400
In-Reply-To: <1312509979-13226-1-git-send-email-holt@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a wrapper function for a register dump when a developer defines
FLEXCAN_DEBUG.

Signed-off-by: Robin Holt <holt@sgi.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Cc: socketcan-core@lists.berlios.de
Cc: netdev@vger.kernel.org
---
 drivers/net/can/flexcan.c |   40 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index fbb61c6..96684ca 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -316,6 +316,38 @@ static inline unsigned long flexcan_clk_get_rate(struct clk *clk)
 
 #endif
 
+#if defined(FLEXCAN_DEBUG)
+void _flexcan_reg_dump(struct net_device *dev, const char *file, int line,
+		       const char *func)
+{
+	const struct flexcan_priv *priv = netdev_priv(dev);
+	struct flexcan_regs __iomem *regs = priv->base;
+
+	printk(KERN_INFO "flexcan_reg_dump:%s:%d:%s()\n", file, line, func);
+	printk(KERN_INFO
+		"\t  mcr 0x%08x  ctrl 0x%08x timer 0x%08x   rxg 0x%08x",
+		flexcan_read(&regs->mcr),
+		flexcan_read(&regs->ctrl),
+		flexcan_read(&regs->timer),
+		flexcan_read(&regs->rxgmask));
+	printk(KERN_INFO
+		"\t rx14 0x%08x  rx15 0x%08x   ecr 0x%08x   esr 0x%08x",
+		flexcan_read(&regs->rx14mask),
+		flexcan_read(&regs->rx15mask),
+		flexcan_read(&regs->ecr),
+		flexcan_read(&regs->esr));
+	printk(KERN_INFO
+		"\timsk2 0x%08x imsk1 0x%08x iflg2 0x%08x iflg1 0x%08x",
+		flexcan_read(&regs->imask2),
+		flexcan_read(&regs->imask1),
+		flexcan_read(&regs->iflag2),
+		flexcan_read(&regs->iflag1));
+}
+#define flexcan_reg_dump(_d) _flexcan_reg_dump(_d, __FILE__, __LINE__, __func__)
+#else
+#define flexcan_reg_dump(_d)
+#endif
+
 /*
  * Swtich transceiver on or off
  */
@@ -376,6 +408,8 @@ static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 can_id;
 	u32 ctrl = FLEXCAN_MB_CNT_CODE(0xc) | (cf->can_dlc << 16);
 
+	flexcan_reg_dump(dev);
+
 	if (can_dropped_invalid_skb(dev, skb))
 		return NETDEV_TX_OK;
 
@@ -408,6 +442,8 @@ static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* tx_packets is incremented in flexcan_irq */
 	stats->tx_bytes += cf->can_dlc;
 
+	flexcan_reg_dump(dev);
+
 	return NETDEV_TX_OK;
 }
 
@@ -676,6 +712,8 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
 	struct flexcan_regs __iomem *regs = priv->base;
 	u32 reg_iflag1, reg_esr;
 
+	flexcan_reg_dump(dev);
+
 	reg_iflag1 = flexcan_read(&regs->iflag1);
 	reg_esr = flexcan_read(&regs->esr);
 	flexcan_write(FLEXCAN_ESR_ERR_INT, &regs->esr);	/* ACK err IRQ */
@@ -716,6 +754,8 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
 		netif_wake_queue(dev);
 	}
 
+	flexcan_reg_dump(dev);
+
 	return IRQ_HANDLED;
 }
 
-- 
1.7.2.1

