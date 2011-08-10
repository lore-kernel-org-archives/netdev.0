From: Robin Holt <holt@sgi.com>
Subject: [PATCH v11 2/5] flexcan: Abstract off read/write for big/little endian.
Date: Wed, 10 Aug 2011 11:27:47 -0500
Message-ID: <1312993670-23999-3-git-send-email-holt@sgi.com>
References: <1312993670-23999-1-git-send-email-holt@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	U Bhaskar-B22300 <B22300@freescale.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	PPC list <linuxppc-dev@lists.ozlabs.org>
To: Robin Holt <holt@sgi.com>, Kumar Gala <galak@kernel.crashing.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	U Bhaskar-B22300 <B22300@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:35560 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751887Ab1HJQ2c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2011 12:28:32 -0400
In-Reply-To: <1312993670-23999-1-git-send-email-holt@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make flexcan driver handle register reads in the appropriate endianess.
This was a basic search and replace and then define some inlines.

Signed-off-by: Robin Holt <holt@sgi.com>
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
Cc: U Bhaskar-B22300 <B22300@freescale.com>
Cc: socketcan-core@lists.berlios.de
Cc: netdev@vger.kernel.org
Cc: PPC list <linuxppc-dev@lists.ozlabs.org>
---
 drivers/net/can/flexcan.c |  140 ++++++++++++++++++++++++++------------------
 1 files changed, 83 insertions(+), 57 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 586b2cd..68cbe52 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -190,6 +190,31 @@ static struct can_bittiming_const flexcan_bittiming_const = {
 };
 
 /*
+ * Abstract off the read/write for arm versus ppc.
+ */
+#if defined(__BIG_ENDIAN)
+static inline u32 flexcan_read(void __iomem *addr)
+{
+	return in_be32(addr);
+}
+
+static inline void flexcan_write(u32 val, void __iomem *addr)
+{
+	out_be32(addr, val);
+}
+#else
+static inline u32 flexcan_read(void __iomem *addr)
+{
+	return readl(addr);
+}
+
+static inline void flexcan_write(u32 val, void __iomem *addr)
+{
+	writel(val, addr);
+}
+#endif
+
+/*
  * Swtich transceiver on or off
  */
 static void flexcan_transceiver_switch(const struct flexcan_priv *priv, int on)
@@ -210,9 +235,9 @@ static inline void flexcan_chip_enable(struct flexcan_priv *priv)
 	struct flexcan_regs __iomem *regs = priv->base;
 	u32 reg;
 
-	reg = readl(&regs->mcr);
+	reg = flexcan_read(&regs->mcr);
 	reg &= ~FLEXCAN_MCR_MDIS;
-	writel(reg, &regs->mcr);
+	flexcan_write(reg, &regs->mcr);
 
 	udelay(10);
 }
@@ -222,9 +247,9 @@ static inline void flexcan_chip_disable(struct flexcan_priv *priv)
 	struct flexcan_regs __iomem *regs = priv->base;
 	u32 reg;
 
-	reg = readl(&regs->mcr);
+	reg = flexcan_read(&regs->mcr);
 	reg |= FLEXCAN_MCR_MDIS;
-	writel(reg, &regs->mcr);
+	flexcan_write(reg, &regs->mcr);
 }
 
 static int flexcan_get_berr_counter(const struct net_device *dev,
@@ -232,7 +257,7 @@ static int flexcan_get_berr_counter(const struct net_device *dev,
 {
 	const struct flexcan_priv *priv = netdev_priv(dev);
 	struct flexcan_regs __iomem *regs = priv->base;
-	u32 reg = readl(&regs->ecr);
+	u32 reg = flexcan_read(&regs->ecr);
 
 	bec->txerr = (reg >> 0) & 0xff;
 	bec->rxerr = (reg >> 8) & 0xff;
@@ -266,15 +291,15 @@ static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (cf->can_dlc > 0) {
 		u32 data = be32_to_cpup((__be32 *)&cf->data[0]);
-		writel(data, &regs->cantxfg[FLEXCAN_TX_BUF_ID].data[0]);
+		flexcan_write(data, &regs->cantxfg[FLEXCAN_TX_BUF_ID].data[0]);
 	}
 	if (cf->can_dlc > 3) {
 		u32 data = be32_to_cpup((__be32 *)&cf->data[4]);
-		writel(data, &regs->cantxfg[FLEXCAN_TX_BUF_ID].data[1]);
+		flexcan_write(data, &regs->cantxfg[FLEXCAN_TX_BUF_ID].data[1]);
 	}
 
-	writel(can_id, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_id);
-	writel(ctrl, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_ctrl);
+	flexcan_write(can_id, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_id);
+	flexcan_write(ctrl, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_ctrl);
 
 	kfree_skb(skb);
 
@@ -462,8 +487,8 @@ static void flexcan_read_fifo(const struct net_device *dev,
 	struct flexcan_mb __iomem *mb = &regs->cantxfg[0];
 	u32 reg_ctrl, reg_id;
 
-	reg_ctrl = readl(&mb->can_ctrl);
-	reg_id = readl(&mb->can_id);
+	reg_ctrl = flexcan_read(&mb->can_ctrl);
+	reg_id = flexcan_read(&mb->can_id);
 	if (reg_ctrl & FLEXCAN_MB_CNT_IDE)
 		cf->can_id = ((reg_id >> 0) & CAN_EFF_MASK) | CAN_EFF_FLAG;
 	else
@@ -473,12 +498,12 @@ static void flexcan_read_fifo(const struct net_device *dev,
 		cf->can_id |= CAN_RTR_FLAG;
 	cf->can_dlc = get_can_dlc((reg_ctrl >> 16) & 0xf);
 
-	*(__be32 *)(cf->data + 0) = cpu_to_be32(readl(&mb->data[0]));
-	*(__be32 *)(cf->data + 4) = cpu_to_be32(readl(&mb->data[1]));
+	*(__be32 *)(cf->data + 0) = cpu_to_be32(flexcan_read(&mb->data[0]));
+	*(__be32 *)(cf->data + 4) = cpu_to_be32(flexcan_read(&mb->data[1]));
 
 	/* mark as read */
-	writel(FLEXCAN_IFLAG_RX_FIFO_AVAILABLE, &regs->iflag1);
-	readl(&regs->timer);
+	flexcan_write(FLEXCAN_IFLAG_RX_FIFO_AVAILABLE, &regs->iflag1);
+	flexcan_read(&regs->timer);
 }
 
 static int flexcan_read_frame(struct net_device *dev)
@@ -514,17 +539,17 @@ static int flexcan_poll(struct napi_struct *napi, int quota)
 	 * The error bits are cleared on read,
 	 * use saved value from irq handler.
 	 */
-	reg_esr = readl(&regs->esr) | priv->reg_esr;
+	reg_esr = flexcan_read(&regs->esr) | priv->reg_esr;
 
 	/* handle state changes */
 	work_done += flexcan_poll_state(dev, reg_esr);
 
 	/* handle RX-FIFO */
-	reg_iflag1 = readl(&regs->iflag1);
+	reg_iflag1 = flexcan_read(&regs->iflag1);
 	while (reg_iflag1 & FLEXCAN_IFLAG_RX_FIFO_AVAILABLE &&
 	       work_done < quota) {
 		work_done += flexcan_read_frame(dev);
-		reg_iflag1 = readl(&regs->iflag1);
+		reg_iflag1 = flexcan_read(&regs->iflag1);
 	}
 
 	/* report bus errors */
@@ -534,8 +559,8 @@ static int flexcan_poll(struct napi_struct *napi, int quota)
 	if (work_done < quota) {
 		napi_complete(napi);
 		/* enable IRQs */
-		writel(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
-		writel(priv->reg_ctrl_default, &regs->ctrl);
+		flexcan_write(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
+		flexcan_write(priv->reg_ctrl_default, &regs->ctrl);
 	}
 
 	return work_done;
@@ -549,9 +574,9 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
 	struct flexcan_regs __iomem *regs = priv->base;
 	u32 reg_iflag1, reg_esr;
 
-	reg_iflag1 = readl(&regs->iflag1);
-	reg_esr = readl(&regs->esr);
-	writel(FLEXCAN_ESR_ERR_INT, &regs->esr);	/* ACK err IRQ */
+	reg_iflag1 = flexcan_read(&regs->iflag1);
+	reg_esr = flexcan_read(&regs->esr);
+	flexcan_write(FLEXCAN_ESR_ERR_INT, &regs->esr);	/* ACK err IRQ */
 
 	/*
 	 * schedule NAPI in case of:
@@ -567,16 +592,16 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
 		 * save them for later use.
 		 */
 		priv->reg_esr = reg_esr & FLEXCAN_ESR_ERR_BUS;
-		writel(FLEXCAN_IFLAG_DEFAULT & ~FLEXCAN_IFLAG_RX_FIFO_AVAILABLE,
-		       &regs->imask1);
-		writel(priv->reg_ctrl_default & ~FLEXCAN_CTRL_ERR_ALL,
+		flexcan_write(FLEXCAN_IFLAG_DEFAULT &
+			~FLEXCAN_IFLAG_RX_FIFO_AVAILABLE, &regs->imask1);
+		flexcan_write(priv->reg_ctrl_default & ~FLEXCAN_CTRL_ERR_ALL,
 		       &regs->ctrl);
 		napi_schedule(&priv->napi);
 	}
 
 	/* FIFO overflow */
 	if (reg_iflag1 & FLEXCAN_IFLAG_RX_FIFO_OVERFLOW) {
-		writel(FLEXCAN_IFLAG_RX_FIFO_OVERFLOW, &regs->iflag1);
+		flexcan_write(FLEXCAN_IFLAG_RX_FIFO_OVERFLOW, &regs->iflag1);
 		dev->stats.rx_over_errors++;
 		dev->stats.rx_errors++;
 	}
@@ -585,7 +610,7 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
 	if (reg_iflag1 & (1 << FLEXCAN_TX_BUF_ID)) {
 		/* tx_bytes is incremented in flexcan_start_xmit */
 		stats->tx_packets++;
-		writel((1 << FLEXCAN_TX_BUF_ID), &regs->iflag1);
+		flexcan_write((1 << FLEXCAN_TX_BUF_ID), &regs->iflag1);
 		netif_wake_queue(dev);
 	}
 
@@ -599,7 +624,7 @@ static void flexcan_set_bittiming(struct net_device *dev)
 	struct flexcan_regs __iomem *regs = priv->base;
 	u32 reg;
 
-	reg = readl(&regs->ctrl);
+	reg = flexcan_read(&regs->ctrl);
 	reg &= ~(FLEXCAN_CTRL_PRESDIV(0xff) |
 		 FLEXCAN_CTRL_RJW(0x3) |
 		 FLEXCAN_CTRL_PSEG1(0x7) |
@@ -623,11 +648,11 @@ static void flexcan_set_bittiming(struct net_device *dev)
 		reg |= FLEXCAN_CTRL_SMP;
 
 	dev_info(dev->dev.parent, "writing ctrl=0x%08x\n", reg);
-	writel(reg, &regs->ctrl);
+	flexcan_write(reg, &regs->ctrl);
 
 	/* print chip status */
 	dev_dbg(dev->dev.parent, "%s: mcr=0x%08x ctrl=0x%08x\n", __func__,
-		readl(&regs->mcr), readl(&regs->ctrl));
+		flexcan_read(&regs->mcr), flexcan_read(&regs->ctrl));
 }
 
 /*
@@ -648,10 +673,10 @@ static int flexcan_chip_start(struct net_device *dev)
 	flexcan_chip_enable(priv);
 
 	/* soft reset */
-	writel(FLEXCAN_MCR_SOFTRST, &regs->mcr);
+	flexcan_write(FLEXCAN_MCR_SOFTRST, &regs->mcr);
 	udelay(10);
 
-	reg_mcr = readl(&regs->mcr);
+	reg_mcr = flexcan_read(&regs->mcr);
 	if (reg_mcr & FLEXCAN_MCR_SOFTRST) {
 		dev_err(dev->dev.parent,
 			"Failed to softreset can module (mcr=0x%08x)\n",
@@ -673,12 +698,12 @@ static int flexcan_chip_start(struct net_device *dev)
 	 * choose format C
 	 *
 	 */
-	reg_mcr = readl(&regs->mcr);
+	reg_mcr = flexcan_read(&regs->mcr);
 	reg_mcr |= FLEXCAN_MCR_FRZ | FLEXCAN_MCR_FEN | FLEXCAN_MCR_HALT |
 		FLEXCAN_MCR_SUPV | FLEXCAN_MCR_WRN_EN |
 		FLEXCAN_MCR_IDAM_C;
 	dev_dbg(dev->dev.parent, "%s: writing mcr=0x%08x", __func__, reg_mcr);
-	writel(reg_mcr, &regs->mcr);
+	flexcan_write(reg_mcr, &regs->mcr);
 
 	/*
 	 * CTRL
@@ -696,7 +721,7 @@ static int flexcan_chip_start(struct net_device *dev)
 	 * (FLEXCAN_CTRL_ERR_MSK), too. Otherwise we don't get any
 	 * warning or bus passive interrupts.
 	 */
-	reg_ctrl = readl(&regs->ctrl);
+	reg_ctrl = flexcan_read(&regs->ctrl);
 	reg_ctrl &= ~FLEXCAN_CTRL_TSYN;
 	reg_ctrl |= FLEXCAN_CTRL_BOFF_REC | FLEXCAN_CTRL_LBUF |
 		FLEXCAN_CTRL_ERR_STATE | FLEXCAN_CTRL_ERR_MSK;
@@ -704,38 +729,39 @@ static int flexcan_chip_start(struct net_device *dev)
 	/* save for later use */
 	priv->reg_ctrl_default = reg_ctrl;
 	dev_dbg(dev->dev.parent, "%s: writing ctrl=0x%08x", __func__, reg_ctrl);
-	writel(reg_ctrl, &regs->ctrl);
+	flexcan_write(reg_ctrl, &regs->ctrl);
 
 	for (i = 0; i < ARRAY_SIZE(regs->cantxfg); i++) {
-		writel(0, &regs->cantxfg[i].can_ctrl);
-		writel(0, &regs->cantxfg[i].can_id);
-		writel(0, &regs->cantxfg[i].data[0]);
-		writel(0, &regs->cantxfg[i].data[1]);
+		flexcan_write(0, &regs->cantxfg[i].can_ctrl);
+		flexcan_write(0, &regs->cantxfg[i].can_id);
+		flexcan_write(0, &regs->cantxfg[i].data[0]);
+		flexcan_write(0, &regs->cantxfg[i].data[1]);
 
 		/* put MB into rx queue */
-		writel(FLEXCAN_MB_CNT_CODE(0x4), &regs->cantxfg[i].can_ctrl);
+		flexcan_write(FLEXCAN_MB_CNT_CODE(0x4),
+			&regs->cantxfg[i].can_ctrl);
 	}
 
 	/* acceptance mask/acceptance code (accept everything) */
-	writel(0x0, &regs->rxgmask);
-	writel(0x0, &regs->rx14mask);
-	writel(0x0, &regs->rx15mask);
+	flexcan_write(0x0, &regs->rxgmask);
+	flexcan_write(0x0, &regs->rx14mask);
+	flexcan_write(0x0, &regs->rx15mask);
 
 	flexcan_transceiver_switch(priv, 1);
 
 	/* synchronize with the can bus */
-	reg_mcr = readl(&regs->mcr);
+	reg_mcr = flexcan_read(&regs->mcr);
 	reg_mcr &= ~FLEXCAN_MCR_HALT;
-	writel(reg_mcr, &regs->mcr);
+	flexcan_write(reg_mcr, &regs->mcr);
 
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
 
 	/* enable FIFO interrupts */
-	writel(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
+	flexcan_write(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
 
 	/* print chip status */
 	dev_dbg(dev->dev.parent, "%s: reading mcr=0x%08x ctrl=0x%08x\n",
-		__func__, readl(&regs->mcr), readl(&regs->ctrl));
+		__func__, flexcan_read(&regs->mcr), flexcan_read(&regs->ctrl));
 
 	return 0;
 
@@ -757,12 +783,12 @@ static void flexcan_chip_stop(struct net_device *dev)
 	u32 reg;
 
 	/* Disable all interrupts */
-	writel(0, &regs->imask1);
+	flexcan_write(0, &regs->imask1);
 
 	/* Disable + halt module */
-	reg = readl(&regs->mcr);
+	reg = flexcan_read(&regs->mcr);
 	reg |= FLEXCAN_MCR_MDIS | FLEXCAN_MCR_HALT;
-	writel(reg, &regs->mcr);
+	flexcan_write(reg, &regs->mcr);
 
 	flexcan_transceiver_switch(priv, 0);
 	priv->can.state = CAN_STATE_STOPPED;
@@ -854,24 +880,24 @@ static int __devinit register_flexcandev(struct net_device *dev)
 
 	/* select "bus clock", chip must be disabled */
 	flexcan_chip_disable(priv);
-	reg = readl(&regs->ctrl);
+	reg = flexcan_read(&regs->ctrl);
 	reg |= FLEXCAN_CTRL_CLK_SRC;
-	writel(reg, &regs->ctrl);
+	flexcan_write(reg, &regs->ctrl);
 
 	flexcan_chip_enable(priv);
 
 	/* set freeze, halt and activate FIFO, restrict register access */
-	reg = readl(&regs->mcr);
+	reg = flexcan_read(&regs->mcr);
 	reg |= FLEXCAN_MCR_FRZ | FLEXCAN_MCR_HALT |
 		FLEXCAN_MCR_FEN | FLEXCAN_MCR_SUPV;
-	writel(reg, &regs->mcr);
+	flexcan_write(reg, &regs->mcr);
 
 	/*
 	 * Currently we only support newer versions of this core
 	 * featuring a RX FIFO. Older cores found on some Coldfire
 	 * derivates are not yet supported.
 	 */
-	reg = readl(&regs->mcr);
+	reg = flexcan_read(&regs->mcr);
 	if (!(reg & FLEXCAN_MCR_FEN)) {
 		dev_err(dev->dev.parent,
 			"Could not enable RX FIFO, unsupported core\n");
-- 
1.7.2.1

