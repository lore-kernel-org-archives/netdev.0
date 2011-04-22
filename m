From: Subhasish Ghosh <subhasish@mistralsolutions.com>
Subject: [PATCH v4 1/1] can: add pruss CAN driver.
Date: Fri, 22 Apr 2011 17:41:07 +0530
Message-ID: <1303474267-6344-2-git-send-email-subhasish@mistralsolutions.com>
References: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>
Cc: linux-arm-kernel@lists.infradead.org, m-watkins@ti.com,
	nsekhar@ti.com, sachi@mistralsolutions.com,
	Subhasish Ghosh <subhasish@mistralsolutions.com>,
	Wolfgang Grandegger <wg@grandegger.com> (maintainer:CAN NETWORK
	DRIVERS),
	socketcan-core@lists.berlios.de (open list:CAN NETWORK DRIVERS),
	netdev@vger.kernel.org (open list:CAN NETWORK DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: davinci-linux-open-source@linux.davincidsp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:53690 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753697Ab1DVLvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 07:51:24 -0400
In-Reply-To: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the CAN device emulated on PRUSS.

Signed-off-by: Subhasish Ghosh <subhasish@mistralsolutions.com>
---
 drivers/net/can/Kconfig     |    7 +
 drivers/net/can/Makefile    |    1 +
 drivers/net/can/pruss_can.c | 1074 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 1082 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/can/pruss_can.c

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index 5dec456..4682a4f 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -111,6 +111,13 @@ config PCH_CAN
 	  embedded processor.
 	  This driver can access CAN bus.
 
+config CAN_TI_DA8XX_PRU
+	depends on CAN_DEV && ARCH_DAVINCI && ARCH_DAVINCI_DA850
+	tristate "PRU based CAN emulation for DA8XX"
+	---help---
+	Enable this to emulate a CAN controller on the PRU of DA8XX.
+	If not sure, mark N
+
 source "drivers/net/can/mscan/Kconfig"
 
 source "drivers/net/can/sja1000/Kconfig"
diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
index 53c82a7..d0b7cbd 100644
--- a/drivers/net/can/Makefile
+++ b/drivers/net/can/Makefile
@@ -15,6 +15,7 @@ obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
 obj-$(CONFIG_CAN_MSCAN)		+= mscan/
 obj-$(CONFIG_CAN_AT91)		+= at91_can.o
 obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
+obj-$(CONFIG_CAN_TI_DA8XX_PRU)	+= pruss_can.o
 obj-$(CONFIG_CAN_MCP251X)	+= mcp251x.o
 obj-$(CONFIG_CAN_BFIN)		+= bfin_can.o
 obj-$(CONFIG_CAN_JANZ_ICAN3)	+= janz-ican3.o
diff --git a/drivers/net/can/pruss_can.c b/drivers/net/can/pruss_can.c
new file mode 100644
index 0000000..7702509
--- /dev/null
+++ b/drivers/net/can/pruss_can.c
@@ -0,0 +1,1074 @@
+/*
+ *  TI DA8XX PRU CAN Emulation device driver
+ *  Author: subhasish@mistralsolutions.com
+ *
+ *  This driver supports TI's PRU CAN Emulation and the
+ *  specs for the same is available at <http://www.ti.com>
+ *
+ *  Copyright (C) 2010, 2011 Texas Instruments Incorporated
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation version 2.
+ *
+ *  This program is distributed as is WITHOUT ANY WARRANTY of any
+ *  kind, whether express or implied; without even the implied warranty
+ *  of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/bitops.h>
+#include <linux/interrupt.h>
+#include <linux/errno.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/platform_device.h>
+#include <linux/firmware.h>
+#include <linux/clk.h>
+#include <linux/types.h>
+#include <linux/sysfs.h>
+#include <linux/can.h>
+#include <linux/can/dev.h>
+#include <linux/can/error.h>
+#include <linux/mfd/pruss.h>
+
+#define PRUSS_CAN_RX_PRU_0			PRUSS_NUM0
+#define PRUSS_CAN_TX_PRU_1			PRUSS_NUM1
+#define PRUSS_CAN_TX_SYS_EVT			34
+#define PRUSS_CAN_RX_SYS_EVT			33
+#define PRUSS_CAN_ARM2DSP_SYS_EVT		32
+#define PRUSS_CAN_DELAY_LOOP_LENGTH		2
+#define PRUSS_CAN_TIMER_SETUP_DELAY		14
+#define PRUSS_CAN_GPIO_SETUP_DELAY		150
+#define PRUSS_CAN_TX_GBL_STAT_REG		(PRUSS_PRU1_BASE_ADDRESS + 0x04)
+#define PRUSS_CAN_TX_INTR_MASK_REG		(PRUSS_PRU1_BASE_ADDRESS + 0x08)
+#define PRUSS_CAN_TX_INTR_STAT_REG		(PRUSS_PRU1_BASE_ADDRESS + 0x0C)
+#define PRUSS_CAN_TX_MBOX0_STAT_REG		(PRUSS_PRU1_BASE_ADDRESS + 0x10)
+#define PRUSS_CAN_TX_ERR_CNTR_REG		(PRUSS_PRU1_BASE_ADDRESS + 0x30)
+#define PRUSS_CAN_TX_INT_STAT			0x2
+#define PRUSS_CAN_MBOX_OFFSET			0x40
+#define PRUSS_CAN_MBOX_SIZE			0x10
+#define PRUSS_CAN_MBOX_STAT_OFFSET		0x10
+#define PRUSS_CAN_MBOX_STAT_SIZE		0x04
+#define PRUSS_CAN_GBL_STAT_REG_VAL		0x00000040
+#define PRUSS_CAN_INTR_MASK_REG_VAL		0x00004000
+#define PRUSS_CAN_TIMING_VAL_TX			(PRUSS_PRU1_BASE_ADDRESS + 0xC0)
+#define PRUSS_CAN_TIMING_SETUP			(PRUSS_PRU1_BASE_ADDRESS + 0xC4)
+#define PRUSS_CAN_RX_GBL_STAT_REG		(PRUSS_PRU0_BASE_ADDRESS + 0x04)
+#define PRUSS_CAN_RX_INTR_MASK_REG		(PRUSS_PRU0_BASE_ADDRESS + 0x08)
+#define PRUSS_CAN_RX_INTR_STAT_REG		(PRUSS_PRU0_BASE_ADDRESS + 0x0C)
+#define PRUSS_CAN_RX_ERR_CNTR_REG		(PRUSS_PRU0_BASE_ADDRESS + 0x34)
+#define PRUSS_CAN_TIMING_VAL_RX			(PRUSS_PRU0_BASE_ADDRESS + 0xD0)
+#define PRUSS_CAN_BIT_TIMING_VAL_RX		(PRUSS_PRU0_BASE_ADDRESS + 0xD4)
+#define PRUSS_CAN_ID_MAP			(PRUSS_PRU0_BASE_ADDRESS + 0xF0)
+#define PRUSS_CAN_ERROR_ACTIVE			128
+#define PRUSS_CAN_GBL_STAT_REG_MASK		0x1F
+#define PRUSS_CAN_GBL_STAT_REG_SET_TX		0x80
+#define PRUSS_CAN_GBL_STAT_REG_SET_RX		0x40
+#define PRUSS_CAN_GBL_STAT_REG_STOP_TX		0x7F
+#define PRUSS_CAN_GBL_STAT_REG_STOP_RX		0xBF
+#define PRUSS_CAN_SET_TX_REQ			0x00000080
+#define PRUSS_CAN_STD_FRAME_MASK		18
+#define PRUSS_CAN_START				1
+#define PRUSS_CAN_MB_MIN			0
+#define PRUSS_CAN_MB_MAX			7
+#define PRUSS_CAN_MID_IDE			BIT(29)
+#define PRUSS_CAN_ISR_BIT_CCI			BIT(15)
+#define PRUSS_CAN_ISR_BIT_ESI			BIT(14)
+#define PRUSS_CAN_ISR_BIT_SRDI			BIT(13)
+#define PRUSS_CAN_ISR_BIT_RRI			BIT(8)
+#define PRUSS_CAN_GSR_BIT_EPM			BIT(4)
+#define PRUSS_CAN_GSR_BIT_BFM			BIT(3)
+#define PRUSS_CAN_RTR_BUFF_NUM			8
+#define PRUSS_DEF_NAPI_WEIGHT			8
+#define PRUSS_CAN_DRV_NAME "da8xx_pruss_can"
+#define PRUSS_CAN_DRV_DESC "TI PRU CAN Controller Driver v1.0"
+
+enum can_tx_dir {
+	TRANSMIT = 1,
+	RECEIVE
+};
+
+struct can_mbox {
+	canid_t can_id;
+	u8 data[8];
+	u16 datalength;
+	u16 crc;
+};
+
+struct can_emu_cntx {
+	enum can_tx_dir txdir;
+	struct can_mbox mbox;
+	u32 mboxno;
+	u8 pruno;
+	u32 gbl_stat;
+	u32 intr_stat;
+	u32 mbox_stat;
+};
+
+struct can_emu_priv {
+	struct can_priv can;
+	struct napi_struct napi;
+	struct net_device *ndev;
+	struct device *dev;
+	struct clk *clk_timer;
+	struct can_emu_cntx can_tx_cntx;
+	struct can_emu_cntx can_rx_cntx;
+	unsigned int clk_freq_pru;
+	unsigned int trx_irq;
+	unsigned int tx_head;
+	unsigned int tx_tail;
+	unsigned int tx_next;
+	unsigned int mbx_id[8];
+};
+
+static struct can_bittiming_const pru_can_bittiming_const = {
+	.name = PRUSS_CAN_DRV_NAME,
+	.tseg1_min = 1,
+	.tseg1_max = 16,
+	.tseg2_min = 1,
+	.tseg2_max = 8,
+	.sjw_max = 4,
+	.brp_min = 1,
+	.brp_max = 256,
+	.brp_inc = 1,
+};
+
+static int pru_can_mbox_write(struct device *dev,
+			struct can_emu_cntx *emu_cntx)
+{
+	u32 offset = 0;
+
+	offset = PRUSS_PRU1_BASE_ADDRESS + PRUSS_CAN_MBOX_OFFSET
+			+ (PRUSS_CAN_MBOX_SIZE * emu_cntx->mboxno);
+
+	pruss_writel_multi(dev, offset, (u32 *) &(emu_cntx->mbox), 4);
+
+	return 0;
+}
+
+static int pru_can_mbox_read(struct device *dev,
+			struct can_emu_cntx *emu_cntx)
+{
+	u32 offset = 0;
+
+	offset = PRUSS_PRU0_BASE_ADDRESS + PRUSS_CAN_MBOX_OFFSET
+			+ (PRUSS_CAN_MBOX_SIZE * emu_cntx->mboxno);
+
+	pruss_readl_multi(dev, offset, (u32 *) &emu_cntx->mbox, 4);
+
+	return 0;
+}
+
+static int pru_can_rx_id_set(struct device *dev, u32 nodeid, u32 mboxno)
+{
+	pruss_writel(dev, (PRUSS_CAN_ID_MAP + (mboxno * 4)), nodeid);
+
+	return 0;
+}
+
+static int pru_can_intr_stat_get(struct device *dev,
+		struct can_emu_cntx *emu_cntx)
+{
+	if (emu_cntx->pruno == PRUCORE_1)
+		pruss_readl(dev, PRUSS_CAN_TX_INTR_STAT_REG,
+				&emu_cntx->intr_stat);
+	else if (emu_cntx->pruno == PRUCORE_0)
+		pruss_readl(dev, PRUSS_CAN_RX_INTR_STAT_REG,
+				&emu_cntx->intr_stat);
+	else
+		return -EINVAL;
+
+	return 0;
+}
+
+static int pru_can_gbl_stat_get(struct device *dev,
+		struct can_emu_cntx *emu_cntx)
+{
+	if (emu_cntx->pruno == PRUCORE_1)
+		pruss_readl(dev, PRUSS_CAN_TX_GBL_STAT_REG,
+				&emu_cntx->gbl_stat);
+	else if (emu_cntx->pruno == PRUCORE_0)
+		pruss_readl(dev, PRUSS_CAN_RX_GBL_STAT_REG,
+				&emu_cntx->gbl_stat);
+	else
+		return -EINVAL;
+	return 0;
+}
+
+static int pru_can_tx_mode_set(struct device *dev, bool transfer_flag,
+					enum can_tx_dir ecan_trx)
+{
+	u32 value;
+
+	if (ecan_trx == TRANSMIT) {
+		pruss_readl(dev, PRUSS_CAN_RX_GBL_STAT_REG, &value);
+		if (transfer_flag) {
+			value &= PRUSS_CAN_GBL_STAT_REG_MASK;
+			value |= PRUSS_CAN_GBL_STAT_REG_SET_TX;
+		} else
+			value &= PRUSS_CAN_GBL_STAT_REG_STOP_TX;
+
+		pruss_writel(dev, PRUSS_CAN_RX_GBL_STAT_REG, value);
+		pruss_writel(dev, PRUSS_CAN_TX_GBL_STAT_REG, value);
+	} else if (ecan_trx == RECEIVE) {
+		pruss_readl(dev, PRUSS_CAN_RX_GBL_STAT_REG, &value);
+		if (transfer_flag) {
+			value &= PRUSS_CAN_GBL_STAT_REG_MASK;
+			value |= PRUSS_CAN_GBL_STAT_REG_SET_RX;
+		} else
+			value &= PRUSS_CAN_GBL_STAT_REG_STOP_RX;
+
+		pruss_writel(dev, PRUSS_CAN_RX_GBL_STAT_REG, value);
+		pruss_writel(dev, PRUSS_CAN_TX_GBL_STAT_REG, value);
+	} else
+		return -EINVAL;
+
+	return 0;
+}
+
+static u32 pruss_intc_init[19][3] = {
+	{PRUSS_INTC_POLARITY0,		PRU_INTC_REGMAP_MASK,	0xFFFFFFFF},
+	{PRUSS_INTC_POLARITY1,		PRU_INTC_REGMAP_MASK,	0xFFFFFFFF},
+	{PRUSS_INTC_TYPE0,		PRU_INTC_REGMAP_MASK,	0x1C000000},
+	{PRUSS_INTC_TYPE1,		PRU_INTC_REGMAP_MASK,	0},
+	{PRUSS_INTC_GLBLEN,		0,			1},
+	{PRUSS_INTC_HOSTMAP0,		PRU_INTC_REGMAP_MASK,	0x03020100},
+	{PRUSS_INTC_HOSTMAP1,		PRU_INTC_REGMAP_MASK,	0x07060504},
+	{PRUSS_INTC_HOSTMAP2,		PRU_INTC_REGMAP_MASK,	0x0000908},
+	{PRUSS_INTC_CHANMAP0,		PRU_INTC_REGMAP_MASK,	0},
+	{PRUSS_INTC_CHANMAP8,		PRU_INTC_REGMAP_MASK,	0x00020200},
+	{PRUSS_INTC_STATIDXCLR,		0,			32},
+	{PRUSS_INTC_STATIDXCLR,		0,			19},
+	{PRUSS_INTC_ENIDXSET,		0,			19},
+	{PRUSS_INTC_STATIDXCLR,		0,			18},
+	{PRUSS_INTC_ENIDXSET,		0,			18},
+	{PRUSS_INTC_STATIDXCLR,		0,			34},
+	{PRUSS_INTC_ENIDXSET,		0,			34},
+	{PRUSS_INTC_ENIDXSET,		0,			32},
+	{PRUSS_INTC_HOSTINTEN,		0,			5}
+};
+
+static int pru_can_emu_init(struct device *dev, u32 pruclock)
+{
+	u32 value[8] = {[0 ... 7] = 1};
+	u32 i;
+
+	/* PRU Internal Registers Initializations */
+	pruss_writel_multi(dev, PRUSS_CAN_TX_MBOX0_STAT_REG, value, 8);
+
+	*value = PRUSS_CAN_GBL_STAT_REG_VAL;
+	pruss_writel(dev, PRUSS_CAN_TX_GBL_STAT_REG, value[0]);
+	pruss_writel(dev, PRUSS_CAN_RX_GBL_STAT_REG, value[0]);
+
+	*value = PRUSS_CAN_INTR_MASK_REG_VAL;
+	pruss_writel(dev, PRUSS_CAN_TX_INTR_MASK_REG, value[0]);
+	pruss_writel(dev, PRUSS_CAN_RX_INTR_MASK_REG, value[0]);
+
+	for (i = 0; i < 19; i++)
+		(i < 12) ?	pruss_rmwl(dev, pruss_intc_init[i][0],
+						pruss_intc_init[i][1],
+						pruss_intc_init[i][2]) :
+				pruss_idx_writel(dev, pruss_intc_init[i][0],
+						pruss_intc_init[i][2]);
+	return 0;
+}
+
+static void pru_can_emu_exit(struct device *dev)
+{
+	pruss_disable(dev, PRUSS_CAN_RX_PRU_0);
+	pruss_disable(dev, PRUSS_CAN_TX_PRU_1);
+}
+
+static int pru_can_tx(struct device *dev, u8 mboxnumber, u8 pruno)
+{
+	u32 value = 0;
+
+	if (PRUCORE_1 == pruno) {
+		value = PRUSS_CAN_SET_TX_REQ;
+		pruss_writel(dev, ((PRUSS_PRU1_BASE_ADDRESS +
+				(PRUSS_CAN_MBOX_STAT_OFFSET +
+				(PRUSS_CAN_MBOX_STAT_SIZE * mboxnumber)))
+				& 0xFFFF), value);
+	} else if (PRUCORE_0 == pruno) {
+		pruss_readl(dev, PRUSS_CAN_RX_INTR_STAT_REG, &value);
+		value = value & ~(1 << mboxnumber);
+		pruss_writel(dev, PRUSS_CAN_RX_INTR_STAT_REG, value);
+		value = 0;
+		pruss_writel(dev, ((PRUSS_PRU0_BASE_ADDRESS +
+				(PRUSS_CAN_MBOX_STAT_OFFSET +
+				(PRUSS_CAN_MBOX_STAT_SIZE * mboxnumber)))
+				& 0xFFFF), value);
+	} else
+		return -EINVAL;
+	return 0;
+}
+
+static int pru_can_reset_tx(struct device *dev)
+{
+	pruss_idx_writel(dev, PRUSS_INTC_STATIDXCLR, PRUSS_CAN_ARM2DSP_SYS_EVT);
+	pruss_idx_writel(dev, PRUSS_INTC_ENIDXSET, PRUSS_CAN_ARM2DSP_SYS_EVT);
+	pruss_idx_writel(dev, PRUSS_INTC_STATIDXSET, PRUSS_CAN_ARM2DSP_SYS_EVT);
+	return 0;
+}
+
+static void pru_can_mask_ints(struct device *dev, u32 trx, bool enable)
+{
+	u32 value = 0;
+
+	value = (trx == PRUSS_CAN_TX_PRU_1) ?
+		PRUSS_CAN_TX_SYS_EVT : PRUSS_CAN_RX_SYS_EVT;
+	enable ? pruss_idx_writel(dev, PRUSS_INTC_ENIDXSET, value) :
+		pruss_idx_writel(dev, PRUSS_INTC_ENIDXCLR, value);
+}
+
+static unsigned int pru_can_get_error_cnt(struct device *dev, u8 pruno)
+{
+	u32 value = 0;
+
+	if (pruno == PRUSS_CAN_RX_PRU_0)
+		pruss_readl(dev, PRUSS_CAN_RX_ERR_CNTR_REG, &value);
+	else if (pruno == PRUSS_CAN_TX_PRU_1)
+		pruss_readl(dev, PRUSS_CAN_TX_ERR_CNTR_REG, &value);
+	else
+		return -EINVAL;
+
+	return value;
+}
+
+static unsigned int pru_can_get_intc_status(struct device *dev)
+{
+	u32 value = 0;
+
+	pruss_readl(dev, PRUSS_INTC_STATCLRINT1, &value);
+	return value;
+}
+
+static void pru_can_clr_intc_status(struct device *dev, u32 trx)
+{
+	u32 value = 0;
+
+	value = (trx == PRUSS_CAN_TX_PRU_1) ?
+		PRUSS_CAN_TX_SYS_EVT : PRUSS_CAN_RX_SYS_EVT;
+	pruss_idx_writel(dev, PRUSS_INTC_STATIDXCLR, value);
+}
+
+static int pru_can_get_state(const struct net_device *ndev,
+					enum can_state *state)
+{
+	struct can_emu_priv *priv = netdev_priv(ndev);
+	*state = priv->can.state;
+
+	return 0;
+}
+
+static int pru_can_set_bittiming(struct net_device *ndev)
+{
+	struct can_emu_priv *priv = netdev_priv(ndev);
+	struct can_bittiming *bt = &priv->can.bittiming;
+	u32 value;
+
+	value = priv->can.clock.freq / bt->bitrate;
+	pruss_writel(priv->dev, PRUSS_CAN_TIMING_VAL_TX, value);
+	pruss_writel(priv->dev, PRUSS_CAN_BIT_TIMING_VAL_RX, value);
+
+	value = (bt->phase_seg2 + bt->phase_seg1 +
+			bt->prop_seg + 1) * bt->brp;
+	value = (value >> 1) - PRUSS_CAN_TIMER_SETUP_DELAY;
+	value = (value << 16) | value;
+	pruss_writel(priv->dev, PRUSS_CAN_TIMING_VAL_RX, value);
+
+	value = (PRUSS_CAN_GPIO_SETUP_DELAY *
+		(priv->clk_freq_pru / 1000000) / 1000) /
+		PRUSS_CAN_DELAY_LOOP_LENGTH;
+
+	pruss_writel(priv->dev, PRUSS_CAN_TIMING_SETUP, value);
+	return 0;
+}
+
+static void pru_can_stop(struct net_device *ndev)
+{
+	struct can_emu_priv *priv = netdev_priv(ndev);
+
+	pru_can_mask_ints(priv->dev, PRUSS_CAN_TX_PRU_1, false);
+	pru_can_mask_ints(priv->dev, PRUSS_CAN_RX_PRU_0, false);
+	pru_can_reset_tx(priv->dev);
+	priv->can.state = CAN_STATE_STOPPED;
+}
+
+/*
+ * This is to just set the can state to ERROR_ACTIVE
+ *	ip link set canX up type can bitrate 125000
+ */
+static void pru_can_start(struct net_device *ndev)
+{
+	struct can_emu_priv *priv = netdev_priv(ndev);
+
+	if (priv->can.state != CAN_STATE_STOPPED)
+		pru_can_stop(ndev);
+
+	pru_can_mask_ints(priv->dev, PRUSS_CAN_TX_PRU_1, true);
+	pru_can_mask_ints(priv->dev, PRUSS_CAN_RX_PRU_0, true);
+
+	pru_can_gbl_stat_get(priv->dev, &priv->can_tx_cntx);
+	pru_can_gbl_stat_get(priv->dev, &priv->can_rx_cntx);
+
+	if (PRUSS_CAN_GSR_BIT_EPM & priv->can_tx_cntx.gbl_stat)
+		priv->can.state = CAN_STATE_ERROR_PASSIVE;
+	else if (PRUSS_CAN_GSR_BIT_BFM & priv->can_tx_cntx.gbl_stat)
+		priv->can.state = CAN_STATE_BUS_OFF;
+	else
+		priv->can.state = CAN_STATE_ERROR_ACTIVE;
+}
+
+static int pru_can_set_mode(struct net_device *ndev, enum can_mode mode)
+{
+	int ret = 0;
+
+	switch (mode) {
+	case CAN_MODE_START:
+		pru_can_start(ndev);
+		netif_wake_queue(ndev);
+		break;
+	default:
+		ret = -EOPNOTSUPP;
+		break;
+	}
+	return ret;
+}
+
+static netdev_tx_t pru_can_start_xmit(struct sk_buff *skb,
+					struct net_device *ndev)
+{
+	struct can_emu_priv *priv = netdev_priv(ndev);
+	struct can_frame *cf = (struct can_frame *)skb->data;
+	int count;
+	u8 *data = cf->data;
+	u8 dlc = cf->can_dlc;
+	u8 *pdata = NULL;
+
+	if (can_dropped_invalid_skb(ndev, skb))
+		return NETDEV_TX_OK;
+
+	netif_stop_queue(ndev);
+	if (cf->can_id & CAN_EFF_FLAG)	/* Extended frame format */
+		priv->can_tx_cntx.mbox.can_id =
+		    (cf->can_id & CAN_EFF_MASK) | PRUSS_CAN_MID_IDE;
+	else			/* Standard frame format */
+		priv->can_tx_cntx.mbox.can_id =
+		    (cf->can_id & CAN_SFF_MASK) << PRUSS_CAN_STD_FRAME_MASK;
+
+	if (cf->can_id & CAN_RTR_FLAG)	/* Remote transmission request */
+		priv->can_tx_cntx.mbox.can_id |= CAN_RTR_FLAG;
+
+	pdata = &priv->can_tx_cntx.mbox.data[0] + (dlc - 1);
+	for (count = 0; count < (u8) dlc; count++)
+		*pdata-- = *data++;
+
+	priv->can_tx_cntx.mbox.datalength = (u16) dlc;
+	priv->can_tx_cntx.mbox.crc = 0;
+/*
+ * search for the next available mbx
+ * if the next mbx is busy, then try the next + 1
+ * do this until the head is reached.
+ * if still unable to tx, stop accepting any packets
+ * if able to tx and the head is reached, then reset next to tail, i.e mbx0
+ * if head is not reached, then just point to the next mbx
+ */
+	for (; priv->tx_next <= priv->tx_head; priv->tx_next++) {
+		priv->can_tx_cntx.mboxno = priv->tx_next;
+		if (-1 == pru_can_mbox_write(priv->dev,
+					&priv->can_tx_cntx)) {
+			if (priv->tx_next == priv->tx_head) {
+				priv->tx_next = priv->tx_tail;
+				netif_stop_queue(ndev);	/* IF stalled */
+				dev_err(priv->dev,
+					"%s: no tx mbx available", __func__);
+				return NETDEV_TX_BUSY;
+			} else
+				continue;
+		} else {
+			/* set transmit request */
+			pru_can_tx(priv->dev, priv->tx_next,
+						PRUSS_CAN_TX_PRU_1);
+			pru_can_tx_mode_set(priv->dev, false, RECEIVE);
+			pru_can_tx_mode_set(priv->dev, true, TRANSMIT);
+			pru_can_reset_tx(priv->dev);
+			priv->tx_next++;
+			can_put_echo_skb(skb, ndev, 0);
+			break;
+		}
+	}
+	if (priv->tx_next > priv->tx_head)
+		priv->tx_next = priv->tx_tail;
+
+	return NETDEV_TX_OK;
+}
+
+static int pru_can_rx(struct net_device *ndev, u32 mbxno)
+{
+	struct can_emu_priv *priv = netdev_priv(ndev);
+	struct net_device_stats *stats = &ndev->stats;
+	struct can_frame *cf;
+	struct sk_buff *skb;
+	u8 *data = NULL;
+	u8 *pdata = NULL;
+	int count = 0;
+
+	skb = alloc_can_skb(ndev, &cf);
+	if (!skb) {
+		if (printk_ratelimit())
+			dev_err(priv->dev,
+				"alloc_can_skb() failed\n");
+		return -ENOMEM;
+	}
+	data = cf->data;
+	/* get payload */
+	priv->can_rx_cntx.mboxno = mbxno;
+	if (pru_can_mbox_read(priv->dev, &priv->can_rx_cntx)) {
+		dev_err(priv->dev, "failed to get data from mailbox\n");
+		return -EAGAIN;
+	}
+	/* give ownweship to pru */
+	pru_can_tx(priv->dev, mbxno, PRUSS_CAN_RX_PRU_0);
+
+	/* get data length code */
+	cf->can_dlc = get_can_dlc(priv->can_rx_cntx.mbox.datalength & 0xF);
+	if (cf->can_dlc <= 4) {
+		pdata = &priv->can_rx_cntx.mbox.data[4] + (4 - cf->can_dlc);
+		for (count = 0; count < cf->can_dlc; count++)
+			*data++ = *pdata++;
+	} else {
+		pdata = &priv->can_rx_cntx.mbox.data[4];
+		for (count = 0; count < 4; count++)
+			*data++ = *pdata++;
+		pdata = &priv->can_rx_cntx.mbox.data[3] - (cf->can_dlc - 5);
+		for (count = 0; count < cf->can_dlc - 4; count++)
+			*data++ = *pdata++;
+	}
+
+	/* get id extended or std */
+	if (priv->can_rx_cntx.mbox.can_id & PRUSS_CAN_MID_IDE)
+		cf->can_id = (priv->can_rx_cntx.mbox.can_id & CAN_EFF_MASK)
+								| CAN_EFF_FLAG;
+	else
+		cf->can_id = (priv->can_rx_cntx.mbox.can_id >> 18)
+							& CAN_SFF_MASK;
+
+	if (priv->can_rx_cntx.mbox.can_id & CAN_RTR_FLAG)
+		cf->can_id |= CAN_RTR_FLAG;
+
+	stats->rx_bytes += cf->can_dlc;
+	netif_receive_skb(skb);
+	stats->rx_packets++;
+	return 0;
+}
+
+static int pru_can_err(struct net_device *ndev, int int_status,
+			     int err_status)
+{
+	struct can_emu_priv *priv = netdev_priv(ndev);
+	struct net_device_stats *stats = &ndev->stats;
+	struct can_frame *cf;
+	struct sk_buff *skb;
+	u32 tx_err_cnt, rx_err_cnt;
+
+	skb = alloc_can_err_skb(ndev, &cf);
+	if (!skb) {
+		if (printk_ratelimit())
+			dev_err(priv->dev,
+				"alloc_can_err_skb() failed\n");
+		return -ENOMEM;
+	}
+
+	if (err_status & PRUSS_CAN_GSR_BIT_EPM) {	/* error passive int */
+		priv->can.state = CAN_STATE_ERROR_PASSIVE;
+		++priv->can.can_stats.error_passive;
+		cf->can_id |= CAN_ERR_CRTL;
+		tx_err_cnt = pru_can_get_error_cnt(priv->dev,
+						PRUSS_CAN_TX_PRU_1);
+		rx_err_cnt = pru_can_get_error_cnt(priv->dev,
+						PRUSS_CAN_RX_PRU_0);
+		if (tx_err_cnt > PRUSS_CAN_ERROR_ACTIVE - 1)
+			cf->data[1] |= CAN_ERR_CRTL_TX_PASSIVE;
+		if (rx_err_cnt > PRUSS_CAN_ERROR_ACTIVE - 1)
+			cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
+
+		dev_dbg(priv->ndev->dev.parent, "Error passive interrupt\n");
+	}
+
+	if (err_status & PRUSS_CAN_GSR_BIT_BFM) {
+		priv->can.state = CAN_STATE_BUS_OFF;
+		cf->can_id |= CAN_ERR_BUSOFF;
+		/*
+		 *      Disable all interrupts in bus-off to avoid int hog
+		 *      this should be handled by the pru
+		 */
+		pru_can_mask_ints(priv->dev, PRUSS_CAN_TX_PRU_1, false);
+		pru_can_mask_ints(priv->dev, PRUSS_CAN_RX_PRU_0, false);
+		can_bus_off(ndev);
+		dev_dbg(priv->ndev->dev.parent, "Bus off mode\n");
+	}
+
+	netif_rx(skb);
+	stats->rx_packets++;
+	stats->rx_bytes += cf->can_dlc;
+	return 0;
+}
+
+static int pru_can_rx_poll(struct napi_struct *napi, int quota)
+{
+	struct net_device *ndev = napi->dev;
+	struct can_emu_priv *priv = netdev_priv(ndev);
+	u32 bit_set, mbxno = 0;
+	u32 num_pkts = 0;
+
+	if (!netif_running(ndev))
+		return 0;
+
+	do {
+		/* rx int sys_evt -> 33 */
+		pru_can_clr_intc_status(priv->dev, PRUSS_CAN_RX_PRU_0);
+		if (pru_can_intr_stat_get(priv->dev, &priv->can_rx_cntx))
+			return num_pkts;
+
+		if (PRUSS_CAN_ISR_BIT_RRI & priv->can_rx_cntx.intr_stat) {
+			mbxno = PRUSS_CAN_RTR_BUFF_NUM;
+			pru_can_rx(ndev, mbxno);
+			num_pkts++;
+		} else {
+			/* Extract the mboxno from the status */
+			bit_set = fls(priv->can_rx_cntx.intr_stat & 0xFF);
+			if (bit_set) {
+				num_pkts++;
+				mbxno = bit_set - 1;
+				if (PRUSS_CAN_ISR_BIT_ESI & priv->can_rx_cntx.
+				    intr_stat) {
+					pru_can_gbl_stat_get(priv->dev,
+						&priv->can_rx_cntx);
+						pru_can_err(ndev,
+					priv->can_rx_cntx.intr_stat,
+					priv->can_rx_cntx.gbl_stat);
+				} else
+					pru_can_rx(ndev, mbxno);
+			} else
+				break;
+		}
+	} while (((PRUSS_CAN_TX_INT_STAT & pru_can_get_intc_status(priv->dev))
+						&& (num_pkts < quota)));
+
+	/* Enable packet interrupt if all pkts are handled */
+	if (!(PRUSS_CAN_TX_INT_STAT & pru_can_get_intc_status(priv->dev))) {
+		napi_complete(napi);
+		/* Re-enable RX mailbox interrupts */
+		pru_can_mask_ints(priv->dev, PRUSS_CAN_RX_PRU_0, true);
+	}
+	return num_pkts;
+}
+
+static irqreturn_t pru_tx_can_intr(int irq, void *dev_id)
+{
+	struct net_device *ndev = dev_id;
+	struct can_emu_priv *priv = netdev_priv(ndev);
+	struct net_device_stats *stats = &ndev->stats;
+	u32 bit_set, mbxno;
+
+	pru_can_intr_stat_get(priv->dev, &priv->can_tx_cntx);
+	if ((PRUSS_CAN_ISR_BIT_CCI & priv->can_tx_cntx.intr_stat)
+	    || (PRUSS_CAN_ISR_BIT_SRDI & priv->can_tx_cntx.intr_stat)) {
+		dev_dbg(priv->ndev->dev.parent, "tx_int_status = 0x%X\n",
+			    priv->can_tx_cntx.intr_stat);
+		can_free_echo_skb(ndev, 0);
+	} else {
+		bit_set = fls(priv->can_tx_cntx.intr_stat & 0xFF);
+		if (!bit_set) {
+			dev_err(priv->dev, "%s: invalid mailbox number\n",
+								__func__);
+			can_free_echo_skb(ndev, 0);
+		} else {
+			mbxno = bit_set - 1;
+			if (PRUSS_CAN_ISR_BIT_ESI & priv->can_tx_cntx.
+								intr_stat) {
+				/* read gsr and ack pru */
+				pru_can_gbl_stat_get(priv->dev,
+							&priv->can_tx_cntx);
+				pru_can_err(ndev, priv->can_tx_cntx.intr_stat,
+						priv->can_tx_cntx.gbl_stat);
+			} else {
+				stats->tx_packets++;
+				/* stats->tx_bytes += dlc; */
+				/*can_get_echo_skb(ndev, 0);*/
+			}
+		}
+	}
+	netif_wake_queue(ndev);
+	can_get_echo_skb(ndev, 0);
+	pru_can_tx_mode_set(priv->dev, true, RECEIVE);
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t pru_rx_can_intr(int irq, void *dev_id)
+{
+	struct net_device *ndev = dev_id;
+	struct can_emu_priv *priv = netdev_priv(ndev);
+	u32 intc_status = 0;
+
+	intc_status = pru_can_get_intc_status(priv->dev);
+
+	/* tx int sys_evt -> 34 */
+	if (intc_status & 4) {
+		pru_can_clr_intc_status(priv->dev, PRUSS_CAN_TX_PRU_1);
+		return pru_tx_can_intr(irq, dev_id);
+	}
+	/* Disable RX mailbox interrupts and let NAPI reenable them */
+	if (intc_status & 2) {
+		pru_can_mask_ints(priv->dev, PRUSS_CAN_RX_PRU_0, false);
+		napi_schedule(&priv->napi);
+	}
+
+	return IRQ_HANDLED;
+}
+
+static int pru_can_open(struct net_device *ndev)
+{
+	struct can_emu_priv *priv = netdev_priv(ndev);
+	s32 err;
+
+	/* register interrupt handler */
+	err = request_irq(priv->trx_irq, &pru_rx_can_intr, IRQF_SHARED,
+						"pru_can_irq", ndev);
+	if (err) {
+		dev_err(priv->dev, "error requesting rx interrupt\n");
+		goto exit_trx_irq;
+	}
+	err = open_candev(ndev);
+	if (err) {
+		dev_err(priv->dev, "open_candev() failed %d\n", err);
+		goto exit_open;
+	}
+
+	pru_can_emu_init(priv->dev, priv->can.clock.freq);
+	priv->tx_tail = PRUSS_CAN_MB_MIN;
+	priv->tx_head = PRUSS_CAN_MB_MAX;
+	pru_can_start(ndev);
+	napi_enable(&priv->napi);
+	netif_start_queue(ndev);
+	return 0;
+
+exit_open:
+	free_irq(priv->trx_irq, ndev);
+exit_trx_irq:
+	return err;
+}
+
+static int pru_can_close(struct net_device *ndev)
+{
+	struct can_emu_priv *priv = netdev_priv(ndev);
+
+	netif_stop_queue(ndev);
+	napi_disable(&priv->napi);
+	close_candev(ndev);
+	free_irq(priv->trx_irq, ndev);
+	return 0;
+}
+
+static const struct net_device_ops pru_can_netdev_ops = {
+	.ndo_open		= pru_can_open,
+	.ndo_stop		= pru_can_close,
+	.ndo_start_xmit		= pru_can_start_xmit,
+};
+
+/* Shows all the mailbox IDs */
+static ssize_t pru_sysfs_mbx_id_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct can_emu_priv *priv = netdev_priv(to_net_dev(dev));
+
+	return snprintf(buf, PAGE_SIZE, "<mbx_no:mbx_id>\n"
+					"0:0x%X 1:0x%X 2:0x%X 3:0x%X "
+					"4:0x%X 5:0x%X 6:0x%X 7:0x%X\n",
+					priv->mbx_id[0], priv->mbx_id[1],
+					priv->mbx_id[2], priv->mbx_id[3],
+					priv->mbx_id[4], priv->mbx_id[5],
+					priv->mbx_id[6], priv->mbx_id[7]);
+}
+
+/*
+ * Sets Mailbox IDs
+ * This should be programmed as mbx_num:mbx_id (in hex)
+ * eg: $ echo 0:0x123 > /sys/class/net/can0/mbx_id
+ */
+static ssize_t pru_sysfs_mbx_id_set(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct net_device *ndev = to_net_dev(dev);
+	struct can_emu_priv *priv = netdev_priv(ndev);
+	unsigned long can_id;
+	unsigned long mbx_num;
+	char mbx[2] = {*buf, '\0'}; /* mbx num */
+	ssize_t ret = count;
+	s32 err;
+
+	if (ndev->flags & IFF_UP) {
+		ret = -EBUSY;
+		goto out;
+	}
+
+	if (*(buf + 1) != ':') {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	err = strict_strtoul(mbx, 0, &mbx_num);
+	if (err) {
+		ret = err;
+		goto out;
+	}
+
+	if (mbx_num > 7) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	err = strict_strtoul((buf + 2), 0, &can_id);
+	if (err) {
+		ret = err;
+		goto out;
+	}
+
+	priv->mbx_id[mbx_num] = can_id;
+	pru_can_rx_id_set(priv->dev, priv->mbx_id[mbx_num], mbx_num);
+
+	return ret;
+out:
+	dev_err(priv->dev, "invalid buffer format\n");
+	return ret;
+}
+
+static DEVICE_ATTR(mbx_id, S_IWUSR | S_IRUGO,
+	pru_sysfs_mbx_id_show, pru_sysfs_mbx_id_set);
+
+static struct attribute *pru_sysfs_attrs[] = {
+	&dev_attr_mbx_id.attr,
+	NULL,
+};
+
+static struct attribute_group pru_sysfs_attr_group = {
+	.attrs = pru_sysfs_attrs,
+};
+
+static int __devinit pru_can_probe(struct platform_device *pdev)
+{
+	struct net_device *ndev = NULL;
+	const struct da850_evm_pruss_can_data *pdata;
+	struct can_emu_priv *priv = NULL;
+	struct device *dev = &pdev->dev;
+	struct clk *clk_pruss;
+	const struct firmware *fw_rx;
+	const struct firmware *fw_tx;
+	u32 err;
+
+	pdata = dev->platform_data;
+	if (!pdata) {
+		dev_err(&pdev->dev, "platform data not found\n");
+		return -EINVAL;
+	}
+	(pdata->setup)();
+
+	ndev = alloc_candev(sizeof(struct can_emu_priv), PRUSS_CAN_MB_MAX + 1);
+	if (!ndev) {
+		dev_err(&pdev->dev, "alloc_candev failed\n");
+		err = -ENOMEM;
+		goto probe_exit;
+	}
+
+	ndev->sysfs_groups[0] = &pru_sysfs_attr_group;
+
+	priv = netdev_priv(ndev);
+
+	priv->trx_irq = platform_get_irq(to_platform_device(dev->parent), 0);
+	if (!priv->trx_irq) {
+		dev_err(&pdev->dev, "unable to get pru "
+						"interrupt resources!\n");
+		err = -ENODEV;
+		goto probe_exit;
+	}
+
+	priv->ndev = ndev;
+	priv->dev = dev;
+
+	priv->can.bittiming_const = &pru_can_bittiming_const;
+	priv->can.do_set_bittiming = pru_can_set_bittiming;
+	priv->can.do_set_mode = pru_can_set_mode;
+	priv->can.do_get_state = pru_can_get_state;
+	priv->can_tx_cntx.pruno = PRUSS_CAN_TX_PRU_1;
+	priv->can_rx_cntx.pruno = PRUSS_CAN_RX_PRU_0;
+
+	/* we support local echo, no arp */
+	ndev->flags |= (IFF_ECHO | IFF_NOARP);
+
+	/* pdev->dev->device_private->driver_data = ndev */
+	platform_set_drvdata(pdev, ndev);
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+	ndev->netdev_ops = &pru_can_netdev_ops;
+
+	priv->clk_timer = clk_get(&pdev->dev, "pll1_sysclk2");
+	if (IS_ERR(priv->clk_timer)) {
+		dev_err(&pdev->dev, "no timer clock available\n");
+		err = PTR_ERR(priv->clk_timer);
+		priv->clk_timer = NULL;
+		goto probe_exit_candev;
+	}
+
+	priv->can.clock.freq = clk_get_rate(priv->clk_timer);
+
+	clk_pruss = clk_get(NULL, "pruss");
+	if (IS_ERR(clk_pruss)) {
+		dev_err(&pdev->dev, "no clock available: pruss\n");
+		err = -ENODEV;
+		goto probe_exit_clk;
+	}
+	priv->clk_freq_pru = clk_get_rate(clk_pruss);
+	clk_put(clk_pruss);
+
+	err = register_candev(ndev);
+	if (err) {
+		dev_err(&pdev->dev, "register_candev() failed\n");
+		err = -ENODEV;
+		goto probe_exit_clk;
+	}
+
+	err = request_firmware(&fw_tx, "PRU_CAN_Emulation_Tx.bin",
+			&pdev->dev);
+	if (err) {
+		dev_err(&pdev->dev, "can't load firmware\n");
+		err = -ENODEV;
+		goto probe_exit_clk;
+	}
+
+	dev_info(&pdev->dev, "fw_tx size %d. downloading...\n", fw_tx->size);
+
+	err = request_firmware(&fw_rx, "PRU_CAN_Emulation_Rx.bin",
+			&pdev->dev);
+	if (err) {
+		dev_err(&pdev->dev, "can't load firmware\n");
+		err = -ENODEV;
+		goto probe_release_fw;
+	}
+	dev_info(&pdev->dev, "fw_rx size %d. downloading...\n", fw_rx->size);
+
+	/* init the pru */
+	pru_can_emu_init(priv->dev, priv->can.clock.freq);
+	udelay(200);
+
+	netif_napi_add(ndev, &priv->napi, pru_can_rx_poll,
+					PRUSS_DEF_NAPI_WEIGHT);
+
+	pruss_enable(priv->dev, PRUSS_CAN_RX_PRU_0);
+	pruss_enable(priv->dev, PRUSS_CAN_TX_PRU_1);
+
+	/* download firmware into pru */
+	err = pruss_load(priv->dev, PRUSS_CAN_RX_PRU_0,
+		(u32 *)fw_rx->data, (fw_rx->size / 4));
+	if (err) {
+		dev_err(&pdev->dev, "firmware download error\n");
+		err = -ENODEV;
+		goto probe_release_fw_1;
+	}
+	release_firmware(fw_rx);
+	err = pruss_load(priv->dev, PRUSS_CAN_TX_PRU_1,
+		(u32 *)fw_tx->data, (fw_tx->size / 4));
+	if (err) {
+		dev_err(&pdev->dev, "firmware download error\n");
+		err = -ENODEV;
+		goto probe_release_fw_1;
+	}
+	release_firmware(fw_tx);
+
+	pruss_run(priv->dev, PRUSS_CAN_RX_PRU_0);
+	pruss_run(priv->dev, PRUSS_CAN_TX_PRU_1);
+
+	dev_info(&pdev->dev,
+		 "%s device registered (trx_irq = %d,  clk = %d)\n",
+		 PRUSS_CAN_DRV_NAME, priv->trx_irq, priv->can.clock.freq);
+
+	return 0;
+
+probe_release_fw_1:
+	release_firmware(fw_rx);
+probe_release_fw:
+	release_firmware(fw_tx);
+probe_exit_clk:
+	clk_put(priv->clk_timer);
+probe_exit_candev:
+	if (NULL != ndev)
+		free_candev(ndev);
+probe_exit:
+	return err;
+}
+
+static int __devexit pru_can_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct can_emu_priv *priv = netdev_priv(ndev);
+
+	pru_can_stop(ndev);
+	pru_can_emu_exit(priv->dev);
+	clk_put(priv->clk_timer);
+	unregister_candev(ndev);
+	free_candev(ndev);
+	platform_set_drvdata(pdev, NULL);
+	return 0;
+}
+
+#ifdef CONFIG_PM
+static int pru_can_suspend(struct platform_device *pdev,
+			pm_message_t mesg)
+{
+	dev_info(&pdev->dev, "%s not yet implemented\n", __func__);
+	return 0;
+}
+
+static int pru_can_resume(struct platform_device *pdev)
+{
+	dev_info(&pdev->dev, "%s not yet implemented\n", __func__);
+	return 0;
+}
+#else
+#define pru_can_suspend NULL
+#define pru_can_resume NULL
+#endif
+
+static struct platform_driver omapl_pru_can_driver = {
+	.probe		= pru_can_probe,
+	.remove		= __devexit_p(pru_can_remove),
+	.suspend	= pru_can_suspend,
+	.resume		= pru_can_resume,
+	.driver		= {
+		.name	= PRUSS_CAN_DRV_NAME,
+		.owner	= THIS_MODULE,
+	},
+};
+
+static int __init pru_can_init(void)
+{
+	pr_debug(KERN_INFO PRUSS_CAN_DRV_DESC "\n");
+	return platform_driver_register(&omapl_pru_can_driver);
+}
+
+module_init(pru_can_init);
+
+static void __exit pru_can_exit(void)
+{
+	pr_debug(KERN_INFO PRUSS_CAN_DRV_DESC " unloaded\n");
+	platform_driver_unregister(&omapl_pru_can_driver);
+}
+
+module_exit(pru_can_exit);
+
+MODULE_AUTHOR("Subhasish Ghosh <subhasish@mistralsolutions.com>");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("omapl pru CAN netdevice driver");
-- 
1.7.2.3

