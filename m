From: Bhupesh Sharma <bhupesh.sharma@freescale.com>
Subject: [PATCH V2 1/1] net: can: Remodel FlexCAN register read/write APIs for BE instances
Date: Fri, 4 Jul 2014 18:31:21 +0530
Message-ID: <1404478881-21853-1-git-send-email-bhupesh.sharma@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <wg@grandegger.com>, <netdev@vger.kernel.org>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>
To: <mkl@pengutronix.de>, <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The FlexCAN IP on certain SoCs like (Freescale's LS1021A) is
modelled in a big-endian fashion, i.e. the registers and the
message buffers are organized in a BE way.

More details about the LS1021A SoC can be seen here:
http://www.freescale.com/webapp/sps/site/prod_summary.jsp?code=LS1021A&nodeId=018rH325E4017B#

This patch ensures that the register read/write APIs are remodelled
to address such cases, while ensuring that existing platforms (where
the FlexCAN IP was modelled in LE way) do not break.

Tested on LS1021A-QDS board.

Signed-off-by: Bhupesh Sharma <bhupesh.sharma@freescale.com>
---
Changes since v1:
- Addressed Marc's review comments.
- Also tried on ARM big-endian kernel

Rebased against v3.16-rc2

 drivers/net/can/flexcan.c |  192 +++++++++++++++++++++++++++------------------
 1 file changed, 114 insertions(+), 78 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index f425ec2..fb1050a 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -214,12 +214,20 @@ struct flexcan_priv {
 	struct flexcan_platform_data *pdata;
 	const struct flexcan_devtype_data *devtype_data;
 	struct regulator *reg_xceiver;
+
+	/* Read and Write APIs */
+	u32 (*read)(void __iomem *addr);
+	void (*write)(u32 val, void __iomem *addr);
 };
 
 static struct flexcan_devtype_data fsl_p1010_devtype_data = {
 	.features = FLEXCAN_HAS_BROKEN_ERR_STATE,
 };
+
 static struct flexcan_devtype_data fsl_imx28_devtype_data;
+
+static struct flexcan_devtype_data fsl_ls1021a_devtype_data;
+
 static struct flexcan_devtype_data fsl_imx6q_devtype_data = {
 	.features = FLEXCAN_HAS_V10_FEATURES,
 };
@@ -237,32 +245,38 @@ static const struct can_bittiming_const flexcan_bittiming_const = {
 };
 
 /*
- * Abstract off the read/write for arm versus ppc. This
- * assumes that PPC uses big-endian registers and everything
- * else uses little-endian registers, independent of CPU
- * endianess.
+ * FlexCAN module is essentially modelled as a little-endian IP in most
+ * SoCs, i.e the registers as well as the message buffer areas are
+ * implemented in a little-endian fashion.
+ *
+ * However there are some SoCs (e.g. LS1021A) which implement the FlexCAN
+ * module in a big-endian fashion (i.e the registers as well as the
+ * message buffer areas are implemented in a big-endian way).
+ *
+ * In addition, the FlexCAN module can be found on SoCs having ARM or
+ * PPC cores. So, we need to abstract off the register read/write
+ * functions, ensuring that these cater to all the combinations of module
+ * endianess and underlying CPU endianess.
  */
-#if defined(CONFIG_PPC)
-static inline u32 flexcan_read(void __iomem *addr)
+static inline u32 flexcan_read_le(void __iomem *addr)
 {
-	return in_be32(addr);
+	return ioread32(addr);
 }
 
-static inline void flexcan_write(u32 val, void __iomem *addr)
+static inline void flexcan_write_le(u32 val, void __iomem *addr)
 {
-	out_be32(addr, val);
+	iowrite32(val, addr);
 }
-#else
-static inline u32 flexcan_read(void __iomem *addr)
+
+static inline u32 flexcan_read_be(void __iomem *addr)
 {
-	return readl(addr);
+	return ioread32be(addr);
 }
 
-static inline void flexcan_write(u32 val, void __iomem *addr)
+static inline void flexcan_write_be(u32 val, void __iomem *addr)
 {
-	writel(val, addr);
+	iowrite32be(val, addr);
 }
-#endif
 
 static inline int flexcan_transceiver_enable(const struct flexcan_priv *priv)
 {
@@ -293,14 +307,14 @@ static int flexcan_chip_enable(struct flexcan_priv *priv)
 	unsigned int timeout = FLEXCAN_TIMEOUT_US / 10;
 	u32 reg;
 
-	reg = flexcan_read(&regs->mcr);
+	reg = priv->read(&regs->mcr);
 	reg &= ~FLEXCAN_MCR_MDIS;
-	flexcan_write(reg, &regs->mcr);
+	priv->write(reg, &regs->mcr);
 
-	while (timeout-- && (flexcan_read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK))
+	while (timeout-- && (priv->read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK))
 		usleep_range(10, 20);
 
-	if (flexcan_read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK)
+	if (priv->read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK)
 		return -ETIMEDOUT;
 
 	return 0;
@@ -312,14 +326,14 @@ static int flexcan_chip_disable(struct flexcan_priv *priv)
 	unsigned int timeout = FLEXCAN_TIMEOUT_US / 10;
 	u32 reg;
 
-	reg = flexcan_read(&regs->mcr);
+	reg = priv->read(&regs->mcr);
 	reg |= FLEXCAN_MCR_MDIS;
-	flexcan_write(reg, &regs->mcr);
+	priv->write(reg, &regs->mcr);
 
-	while (timeout-- && !(flexcan_read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK))
+	while (timeout-- && !(priv->read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK))
 		usleep_range(10, 20);
 
-	if (!(flexcan_read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK))
+	if (!(priv->read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK))
 		return -ETIMEDOUT;
 
 	return 0;
@@ -331,14 +345,14 @@ static int flexcan_chip_freeze(struct flexcan_priv *priv)
 	unsigned int timeout = 1000 * 1000 * 10 / priv->can.bittiming.bitrate;
 	u32 reg;
 
-	reg = flexcan_read(&regs->mcr);
+	reg = priv->read(&regs->mcr);
 	reg |= FLEXCAN_MCR_HALT;
-	flexcan_write(reg, &regs->mcr);
+	priv->write(reg, &regs->mcr);
 
-	while (timeout-- && !(flexcan_read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK))
+	while (timeout-- && !(priv->read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK))
 		usleep_range(100, 200);
 
-	if (!(flexcan_read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK))
+	if (!(priv->read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK))
 		return -ETIMEDOUT;
 
 	return 0;
@@ -350,14 +364,14 @@ static int flexcan_chip_unfreeze(struct flexcan_priv *priv)
 	unsigned int timeout = FLEXCAN_TIMEOUT_US / 10;
 	u32 reg;
 
-	reg = flexcan_read(&regs->mcr);
+	reg = priv->read(&regs->mcr);
 	reg &= ~FLEXCAN_MCR_HALT;
-	flexcan_write(reg, &regs->mcr);
+	priv->write(reg, &regs->mcr);
 
-	while (timeout-- && (flexcan_read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK))
+	while (timeout-- && (priv->read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK))
 		usleep_range(10, 20);
 
-	if (flexcan_read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK)
+	if (priv->read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK)
 		return -ETIMEDOUT;
 
 	return 0;
@@ -368,11 +382,11 @@ static int flexcan_chip_softreset(struct flexcan_priv *priv)
 	struct flexcan_regs __iomem *regs = priv->base;
 	unsigned int timeout = FLEXCAN_TIMEOUT_US / 10;
 
-	flexcan_write(FLEXCAN_MCR_SOFTRST, &regs->mcr);
-	while (timeout-- && (flexcan_read(&regs->mcr) & FLEXCAN_MCR_SOFTRST))
+	priv->write(FLEXCAN_MCR_SOFTRST, &regs->mcr);
+	while (timeout-- && (priv->read(&regs->mcr) & FLEXCAN_MCR_SOFTRST))
 		usleep_range(10, 20);
 
-	if (flexcan_read(&regs->mcr) & FLEXCAN_MCR_SOFTRST)
+	if (priv->read(&regs->mcr) & FLEXCAN_MCR_SOFTRST)
 		return -ETIMEDOUT;
 
 	return 0;
@@ -383,7 +397,7 @@ static int flexcan_get_berr_counter(const struct net_device *dev,
 {
 	const struct flexcan_priv *priv = netdev_priv(dev);
 	struct flexcan_regs __iomem *regs = priv->base;
-	u32 reg = flexcan_read(&regs->ecr);
+	u32 reg = priv->read(&regs->ecr);
 
 	bec->txerr = (reg >> 0) & 0xff;
 	bec->rxerr = (reg >> 8) & 0xff;
@@ -416,17 +430,17 @@ static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (cf->can_dlc > 0) {
 		u32 data = be32_to_cpup((__be32 *)&cf->data[0]);
-		flexcan_write(data, &regs->cantxfg[FLEXCAN_TX_BUF_ID].data[0]);
+		priv->write(data, &regs->cantxfg[FLEXCAN_TX_BUF_ID].data[0]);
 	}
 	if (cf->can_dlc > 3) {
 		u32 data = be32_to_cpup((__be32 *)&cf->data[4]);
-		flexcan_write(data, &regs->cantxfg[FLEXCAN_TX_BUF_ID].data[1]);
+		priv->write(data, &regs->cantxfg[FLEXCAN_TX_BUF_ID].data[1]);
 	}
 
 	can_put_echo_skb(skb, dev, 0);
 
-	flexcan_write(can_id, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_id);
-	flexcan_write(ctrl, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_ctrl);
+	priv->write(can_id, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_id);
+	priv->write(ctrl, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_ctrl);
 
 	return NETDEV_TX_OK;
 }
@@ -609,8 +623,8 @@ static void flexcan_read_fifo(const struct net_device *dev,
 	struct flexcan_mb __iomem *mb = &regs->cantxfg[0];
 	u32 reg_ctrl, reg_id;
 
-	reg_ctrl = flexcan_read(&mb->can_ctrl);
-	reg_id = flexcan_read(&mb->can_id);
+	reg_ctrl = priv->read(&mb->can_ctrl);
+	reg_id = priv->read(&mb->can_id);
 	if (reg_ctrl & FLEXCAN_MB_CNT_IDE)
 		cf->can_id = ((reg_id >> 0) & CAN_EFF_MASK) | CAN_EFF_FLAG;
 	else
@@ -620,12 +634,12 @@ static void flexcan_read_fifo(const struct net_device *dev,
 		cf->can_id |= CAN_RTR_FLAG;
 	cf->can_dlc = get_can_dlc((reg_ctrl >> 16) & 0xf);
 
-	*(__be32 *)(cf->data + 0) = cpu_to_be32(flexcan_read(&mb->data[0]));
-	*(__be32 *)(cf->data + 4) = cpu_to_be32(flexcan_read(&mb->data[1]));
+	*(__be32 *)(cf->data + 0) = cpu_to_be32(priv->read(&mb->data[0]));
+	*(__be32 *)(cf->data + 4) = cpu_to_be32(priv->read(&mb->data[1]));
 
 	/* mark as read */
-	flexcan_write(FLEXCAN_IFLAG_RX_FIFO_AVAILABLE, &regs->iflag1);
-	flexcan_read(&regs->timer);
+	priv->write(FLEXCAN_IFLAG_RX_FIFO_AVAILABLE, &regs->iflag1);
+	priv->read(&regs->timer);
 }
 
 static int flexcan_read_frame(struct net_device *dev)
@@ -663,17 +677,17 @@ static int flexcan_poll(struct napi_struct *napi, int quota)
 	 * The error bits are cleared on read,
 	 * use saved value from irq handler.
 	 */
-	reg_esr = flexcan_read(&regs->esr) | priv->reg_esr;
+	reg_esr = priv->read(&regs->esr) | priv->reg_esr;
 
 	/* handle state changes */
 	work_done += flexcan_poll_state(dev, reg_esr);
 
 	/* handle RX-FIFO */
-	reg_iflag1 = flexcan_read(&regs->iflag1);
+	reg_iflag1 = priv->read(&regs->iflag1);
 	while (reg_iflag1 & FLEXCAN_IFLAG_RX_FIFO_AVAILABLE &&
 	       work_done < quota) {
 		work_done += flexcan_read_frame(dev);
-		reg_iflag1 = flexcan_read(&regs->iflag1);
+		reg_iflag1 = priv->read(&regs->iflag1);
 	}
 
 	/* report bus errors */
@@ -683,8 +697,8 @@ static int flexcan_poll(struct napi_struct *napi, int quota)
 	if (work_done < quota) {
 		napi_complete(napi);
 		/* enable IRQs */
-		flexcan_write(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
-		flexcan_write(priv->reg_ctrl_default, &regs->ctrl);
+		priv->write(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
+		priv->write(priv->reg_ctrl_default, &regs->ctrl);
 	}
 
 	return work_done;
@@ -698,11 +712,11 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
 	struct flexcan_regs __iomem *regs = priv->base;
 	u32 reg_iflag1, reg_esr;
 
-	reg_iflag1 = flexcan_read(&regs->iflag1);
-	reg_esr = flexcan_read(&regs->esr);
+	reg_iflag1 = priv->read(&regs->iflag1);
+	reg_esr = priv->read(&regs->esr);
 	/* ACK all bus error and state change IRQ sources */
 	if (reg_esr & FLEXCAN_ESR_ALL_INT)
-		flexcan_write(reg_esr & FLEXCAN_ESR_ALL_INT, &regs->esr);
+		priv->write(reg_esr & FLEXCAN_ESR_ALL_INT, &regs->esr);
 
 	/*
 	 * schedule NAPI in case of:
@@ -718,16 +732,16 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
 		 * save them for later use.
 		 */
 		priv->reg_esr = reg_esr & FLEXCAN_ESR_ERR_BUS;
-		flexcan_write(FLEXCAN_IFLAG_DEFAULT &
+		priv->write(FLEXCAN_IFLAG_DEFAULT &
 			~FLEXCAN_IFLAG_RX_FIFO_AVAILABLE, &regs->imask1);
-		flexcan_write(priv->reg_ctrl_default & ~FLEXCAN_CTRL_ERR_ALL,
+		priv->write(priv->reg_ctrl_default & ~FLEXCAN_CTRL_ERR_ALL,
 		       &regs->ctrl);
 		napi_schedule(&priv->napi);
 	}
 
 	/* FIFO overflow */
 	if (reg_iflag1 & FLEXCAN_IFLAG_RX_FIFO_OVERFLOW) {
-		flexcan_write(FLEXCAN_IFLAG_RX_FIFO_OVERFLOW, &regs->iflag1);
+		priv->write(FLEXCAN_IFLAG_RX_FIFO_OVERFLOW, &regs->iflag1);
 		dev->stats.rx_over_errors++;
 		dev->stats.rx_errors++;
 	}
@@ -737,7 +751,7 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
 		stats->tx_bytes += can_get_echo_skb(dev, 0);
 		stats->tx_packets++;
 		can_led_event(dev, CAN_LED_EVENT_TX);
-		flexcan_write((1 << FLEXCAN_TX_BUF_ID), &regs->iflag1);
+		priv->write((1 << FLEXCAN_TX_BUF_ID), &regs->iflag1);
 		netif_wake_queue(dev);
 	}
 
@@ -751,7 +765,7 @@ static void flexcan_set_bittiming(struct net_device *dev)
 	struct flexcan_regs __iomem *regs = priv->base;
 	u32 reg;
 
-	reg = flexcan_read(&regs->ctrl);
+	reg = priv->read(&regs->ctrl);
 	reg &= ~(FLEXCAN_CTRL_PRESDIV(0xff) |
 		 FLEXCAN_CTRL_RJW(0x3) |
 		 FLEXCAN_CTRL_PSEG1(0x7) |
@@ -775,11 +789,11 @@ static void flexcan_set_bittiming(struct net_device *dev)
 		reg |= FLEXCAN_CTRL_SMP;
 
 	netdev_info(dev, "writing ctrl=0x%08x\n", reg);
-	flexcan_write(reg, &regs->ctrl);
+	priv->write(reg, &regs->ctrl);
 
 	/* print chip status */
 	netdev_dbg(dev, "%s: mcr=0x%08x ctrl=0x%08x\n", __func__,
-		   flexcan_read(&regs->mcr), flexcan_read(&regs->ctrl));
+		   priv->read(&regs->mcr), priv->read(&regs->ctrl));
 }
 
 /*
@@ -819,14 +833,14 @@ static int flexcan_chip_start(struct net_device *dev)
 	 * disable local echo
 	 *
 	 */
-	reg_mcr = flexcan_read(&regs->mcr);
+	reg_mcr = priv->read(&regs->mcr);
 	reg_mcr &= ~FLEXCAN_MCR_MAXMB(0xff);
 	reg_mcr |= FLEXCAN_MCR_FRZ | FLEXCAN_MCR_FEN | FLEXCAN_MCR_HALT |
 		FLEXCAN_MCR_SUPV | FLEXCAN_MCR_WRN_EN |
 		FLEXCAN_MCR_IDAM_C | FLEXCAN_MCR_SRX_DIS |
 		FLEXCAN_MCR_MAXMB(FLEXCAN_TX_BUF_ID);
 	netdev_dbg(dev, "%s: writing mcr=0x%08x", __func__, reg_mcr);
-	flexcan_write(reg_mcr, &regs->mcr);
+	priv->write(reg_mcr, &regs->mcr);
 
 	/*
 	 * CTRL
@@ -840,7 +854,7 @@ static int flexcan_chip_start(struct net_device *dev)
 	 * enable bus off interrupt
 	 * (== FLEXCAN_CTRL_ERR_STATE)
 	 */
-	reg_ctrl = flexcan_read(&regs->ctrl);
+	reg_ctrl = priv->read(&regs->ctrl);
 	reg_ctrl &= ~FLEXCAN_CTRL_TSYN;
 	reg_ctrl |= FLEXCAN_CTRL_BOFF_REC | FLEXCAN_CTRL_LBUF |
 		FLEXCAN_CTRL_ERR_STATE;
@@ -856,19 +870,19 @@ static int flexcan_chip_start(struct net_device *dev)
 	/* save for later use */
 	priv->reg_ctrl_default = reg_ctrl;
 	netdev_dbg(dev, "%s: writing ctrl=0x%08x", __func__, reg_ctrl);
-	flexcan_write(reg_ctrl, &regs->ctrl);
+	priv->write(reg_ctrl, &regs->ctrl);
 
 	/* Abort any pending TX, mark Mailbox as INACTIVE */
-	flexcan_write(FLEXCAN_MB_CNT_CODE(0x4),
+	priv->write(FLEXCAN_MB_CNT_CODE(0x4),
 		      &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_ctrl);
 
 	/* acceptance mask/acceptance code (accept everything) */
-	flexcan_write(0x0, &regs->rxgmask);
-	flexcan_write(0x0, &regs->rx14mask);
-	flexcan_write(0x0, &regs->rx15mask);
+	priv->write(0x0, &regs->rxgmask);
+	priv->write(0x0, &regs->rx14mask);
+	priv->write(0x0, &regs->rx15mask);
 
 	if (priv->devtype_data->features & FLEXCAN_HAS_V10_FEATURES)
-		flexcan_write(0x0, &regs->rxfgmask);
+		priv->write(0x0, &regs->rxfgmask);
 
 	err = flexcan_transceiver_enable(priv);
 	if (err)
@@ -882,11 +896,11 @@ static int flexcan_chip_start(struct net_device *dev)
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
 
 	/* enable FIFO interrupts */
-	flexcan_write(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
+	priv->write(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
 
 	/* print chip status */
 	netdev_dbg(dev, "%s: reading mcr=0x%08x ctrl=0x%08x\n", __func__,
-		   flexcan_read(&regs->mcr), flexcan_read(&regs->ctrl));
+		   priv->read(&regs->mcr), priv->read(&regs->ctrl));
 
 	return 0;
 
@@ -913,8 +927,8 @@ static void flexcan_chip_stop(struct net_device *dev)
 	flexcan_chip_disable(priv);
 
 	/* Disable all interrupts */
-	flexcan_write(0, &regs->imask1);
-	flexcan_write(priv->reg_ctrl_default & ~FLEXCAN_CTRL_ERR_ALL,
+	priv->write(0, &regs->imask1);
+	priv->write(priv->reg_ctrl_default & ~FLEXCAN_CTRL_ERR_ALL,
 		      &regs->ctrl);
 
 	flexcan_transceiver_disable(priv);
@@ -1032,26 +1046,26 @@ static int register_flexcandev(struct net_device *dev)
 	err = flexcan_chip_disable(priv);
 	if (err)
 		goto out_disable_per;
-	reg = flexcan_read(&regs->ctrl);
+	reg = priv->read(&regs->ctrl);
 	reg |= FLEXCAN_CTRL_CLK_SRC;
-	flexcan_write(reg, &regs->ctrl);
+	priv->write(reg, &regs->ctrl);
 
 	err = flexcan_chip_enable(priv);
 	if (err)
 		goto out_chip_disable;
 
 	/* set freeze, halt and activate FIFO, restrict register access */
-	reg = flexcan_read(&regs->mcr);
+	reg = priv->read(&regs->mcr);
 	reg |= FLEXCAN_MCR_FRZ | FLEXCAN_MCR_HALT |
 		FLEXCAN_MCR_FEN | FLEXCAN_MCR_SUPV;
-	flexcan_write(reg, &regs->mcr);
+	priv->write(reg, &regs->mcr);
 
 	/*
 	 * Currently we only support newer versions of this core
 	 * featuring a RX FIFO. Older cores found on some Coldfire
 	 * derivates are not yet supported.
 	 */
-	reg = flexcan_read(&regs->mcr);
+	reg = priv->read(&regs->mcr);
 	if (!(reg & FLEXCAN_MCR_FEN)) {
 		netdev_err(dev, "Could not enable RX FIFO, unsupported core\n");
 		err = -ENODEV;
@@ -1079,6 +1093,8 @@ static void unregister_flexcandev(struct net_device *dev)
 static const struct of_device_id flexcan_of_match[] = {
 	{ .compatible = "fsl,imx6q-flexcan", .data = &fsl_imx6q_devtype_data, },
 	{ .compatible = "fsl,imx28-flexcan", .data = &fsl_imx28_devtype_data, },
+	{ .compatible = "fsl,ls1021a-flexcan",
+	  .data = &fsl_ls1021a_devtype_data, },
 	{ .compatible = "fsl,p1010-flexcan", .data = &fsl_p1010_devtype_data, },
 	{ /* sentinel */ },
 };
@@ -1101,6 +1117,7 @@ static int flexcan_probe(struct platform_device *pdev)
 	void __iomem *base;
 	int err, irq;
 	u32 clock_freq = 0;
+	bool core_is_little = true, module_is_little = true;
 
 	if (pdev->dev.of_node)
 		of_property_read_u32(pdev->dev.of_node,
@@ -1149,6 +1166,25 @@ static int flexcan_probe(struct platform_device *pdev)
 	dev->flags |= IFF_ECHO;
 
 	priv = netdev_priv(dev);
+
+	if (IS_ENABLED(CONFIG_CPU_BIG_ENDIAN))
+		core_is_little = false;
+
+	if (of_property_read_bool(dev->dev.of_node, "big-endian"))
+		module_is_little = false;
+
+	if ((core_is_little && module_is_little) ||
+	    (!core_is_little && !module_is_little)) {
+		priv->read = flexcan_read_le;
+		priv->write = flexcan_write_le;
+	}
+
+	if ((!core_is_little && module_is_little) ||
+	    (core_is_little && !module_is_little)) {
+		priv->read = flexcan_read_be;
+		priv->write = flexcan_write_be;
+	}
+
 	priv->can.clock.freq = clock_freq;
 	priv->can.bittiming_const = &flexcan_bittiming_const;
 	priv->can.do_set_mode = flexcan_set_mode;
-- 
1.7.9.5


