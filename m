From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: [RFC 1/4] [flexcan] Abstract off read/write for big/little endian.
Date: Fri,  5 Aug 2011 23:05:01 -0500
Message-ID: <1312603504-30282-2-git-send-email-holt@sgi.com>
References: <1312603504-30282-1-git-send-email-holt@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1312603504-30282-1-git-send-email-holt-sJ/iWh9BUns@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

First step in converting the flexcan driver from supporting just arm to
supporting both arm and powerpc architectures.

Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 drivers/net/can/flexcan.c |  140 ++++++++++++++++++++++++++------------------
 1 files changed, 83 insertions(+), 57 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 67d9fc0..74b1706 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -196,6 +196,31 @@ static struct can_bittiming_const flexcan_bittiming_const = {
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
@@ -216,9 +241,9 @@ static inline void flexcan_chip_enable(struct flexcan_priv *priv)
 	struct flexcan_regs __iomem *regs = priv->base;
 	u32 reg;
 
-	reg = readl(&regs->mcr);
+	reg = flexcan_read(&regs->mcr);
 	reg &= ~FLEXCAN_MCR_MDIS;
-	writel(reg, &regs->mcr);
+	flexcan_write(reg, &regs->mcr);
 
 	udelay(10);
 }
@@ -228,9 +253,9 @@ static inline void flexcan_chip_disable(struct flexcan_priv *priv)
 	struct flexcan_regs __iomem *regs = priv->base;
 	u32 reg;
 
-	reg = readl(&regs->mcr);
+	reg = flexcan_read(&regs->mcr);
 	reg |= FLEXCAN_MCR_MDIS;
-	writel(reg, &regs->mcr);
+	flexcan_write(reg, &regs->mcr);
 }
 
 static int flexcan_get_berr_counter(const struct net_device *dev,
@@ -238,7 +263,7 @@ static int flexcan_get_berr_counter(const struct net_device *dev,
 {
 	const struct flexcan_priv *priv = netdev_priv(dev);
 	struct flexcan_regs __iomem *regs = priv->base;
-	u32 reg = readl(&regs->ecr);
+	u32 reg = flexcan_read(&regs->ecr);
 
 	bec->txerr = (reg >> 0) & 0xff;
 	bec->rxerr = (reg >> 8) & 0xff;
@@ -272,15 +297,15 @@ static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
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
 
@@ -468,8 +493,8 @@ static void flexcan_read_fifo(const struct net_device *dev,
 	struct flexcan_mb __iomem *mb = &regs->cantxfg[0];
 	u32 reg_ctrl, reg_id;
 
-	reg_ctrl = readl(&mb->can_ctrl);
-	reg_id = readl(&mb->can_id);
+	reg_ctrl = flexcan_read(&mb->can_ctrl);
+	reg_id = flexcan_read(&mb->can_id);
 	if (reg_ctrl & FLEXCAN_MB_CNT_IDE)
 		cf->can_id = ((reg_id >> 0) & CAN_EFF_MASK) | CAN_EFF_FLAG;
 	else
@@ -479,12 +504,12 @@ static void flexcan_read_fifo(const struct net_device *dev,
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
@@ -520,17 +545,17 @@ static int flexcan_poll(struct napi_struct *napi, int quota)
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
@@ -540,8 +565,8 @@ static int flexcan_poll(struct napi_struct *napi, int quota)
 	if (work_done < quota) {
 		napi_complete(napi);
 		/* enable IRQs */
-		writel(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
-		writel(priv->reg_ctrl_default, &regs->ctrl);
+		flexcan_write(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
+		flexcan_write(priv->reg_ctrl_default, &regs->ctrl);
 	}
 
 	return work_done;
@@ -555,9 +580,9 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
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
@@ -573,16 +598,16 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
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
@@ -591,7 +616,7 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
 	if (reg_iflag1 & (1 << FLEXCAN_TX_BUF_ID)) {
 		/* tx_bytes is incremented in flexcan_start_xmit */
 		stats->tx_packets++;
-		writel((1 << FLEXCAN_TX_BUF_ID), &regs->iflag1);
+		flexcan_write((1 << FLEXCAN_TX_BUF_ID), &regs->iflag1);
 		netif_wake_queue(dev);
 	}
 
@@ -605,7 +630,7 @@ static void flexcan_set_bittiming(struct net_device *dev)
 	struct flexcan_regs __iomem *regs = priv->base;
 	u32 reg;
 
-	reg = readl(&regs->ctrl);
+	reg = flexcan_read(&regs->ctrl);
 	reg &= ~(FLEXCAN_CTRL_PRESDIV(0xff) |
 		 FLEXCAN_CTRL_RJW(0x3) |
 		 FLEXCAN_CTRL_PSEG1(0x7) |
@@ -629,11 +654,11 @@ static void flexcan_set_bittiming(struct net_device *dev)
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
@@ -654,10 +679,10 @@ static int flexcan_chip_start(struct net_device *dev)
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
@@ -679,12 +704,12 @@ static int flexcan_chip_start(struct net_device *dev)
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
@@ -702,7 +727,7 @@ static int flexcan_chip_start(struct net_device *dev)
 	 * (FLEXCAN_CTRL_ERR_MSK), too. Otherwise we don't get any
 	 * warning or bus passive interrupts.
 	 */
-	reg_ctrl = readl(&regs->ctrl);
+	reg_ctrl = flexcan_read(&regs->ctrl);
 	reg_ctrl &= ~FLEXCAN_CTRL_TSYN;
 	reg_ctrl |= FLEXCAN_CTRL_BOFF_REC | FLEXCAN_CTRL_LBUF |
 		FLEXCAN_CTRL_ERR_STATE | FLEXCAN_CTRL_ERR_MSK;
@@ -710,38 +735,39 @@ static int flexcan_chip_start(struct net_device *dev)
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
 
@@ -763,12 +789,12 @@ static void flexcan_chip_stop(struct net_device *dev)
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
@@ -860,24 +886,24 @@ static int __devinit register_flexcandev(struct net_device *dev)
 
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
