From: Bhupesh Sharma <bhupesh.sharma@st.com>
Subject: [PATCH net-next-2.6 v2 1/1] can: c_can: Added support for Bosch C_CAN controller
Date: Wed, 15 Dec 2010 15:28:50 +0530
Message-ID: <1292407130-19791-1-git-send-email-bhupesh.sharma@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Socketcan-core@lists.berlios.de>,
	Bhupesh Sharma <bhupesh.sharma@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:49519 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751917Ab0LOKAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 05:00:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bosch C_CAN controller is a full-CAN implementation which is compliant
to CAN protocol version 2.0 part A and B. Bosch C_CAN user manual can be
obtained from:
http://www.semiconductors.bosch.de/pdf/Users_Manual_C_CAN.pdf

This patch adds the support for this controller.
The following are the design choices made while writing the controller driver:
1. Interface Register set IF1 has be used only in the current design.
2. Out of the 32 Message objects available, 16 are kept aside for RX purposes
   and the rest for TX purposes.
3. NAPI implementation is such that both the TX and RX paths function in
   polling mode.

Changes since V1:
1. Implemented C_CAN as a platform driver with means of providing the
   platform details and register offsets which may vary for different SoCs
   through platform data struct.
2. Implemented NAPI.
3. Removed memcpy calls globally.
4. Implemented CAN_CTRLMODE_*
5. Implemented and used priv->can.do_get_berr_counter.
6. Implemented c_can registers as a struct instead of enum.
7. Improved the TX path by implementing routines to get next Tx and echo msg
   objects.

Signed-off-by: Bhupesh Sharma <bhupesh.sharma@st.com>
---
 drivers/net/can/Kconfig  |    7 +
 drivers/net/can/Makefile |    1 +
 drivers/net/can/c_can.c  | 1217 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 1225 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/can/c_can.c

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index 9d9e453..25d9d2e 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -41,6 +41,13 @@ config CAN_AT91
 	---help---
 	  This is a driver for the SoC CAN controller in Atmel's AT91SAM9263.
 
+config CAN_C_CAN
+	tristate "Bosch C_CAN controller"
+	depends on CAN_DEV
+	---help---
+	  If you say yes to this option, support will be included for the
+	  Bosch C_CAN controller.
+
 config CAN_TI_HECC
 	depends on CAN_DEV && ARCH_OMAP3
 	tristate "TI High End CAN Controller"
diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
index 0057537..b6cbe74 100644
--- a/drivers/net/can/Makefile
+++ b/drivers/net/can/Makefile
@@ -12,6 +12,7 @@ obj-y				+= usb/
 obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
 obj-$(CONFIG_CAN_MSCAN)		+= mscan/
 obj-$(CONFIG_CAN_AT91)		+= at91_can.o
+obj-$(CONFIG_CAN_C_CAN)		+= c_can.o
 obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
 obj-$(CONFIG_CAN_MCP251X)	+= mcp251x.o
 obj-$(CONFIG_CAN_BFIN)		+= bfin_can.o
diff --git a/drivers/net/can/c_can.c b/drivers/net/can/c_can.c
new file mode 100644
index 0000000..c281c17
--- /dev/null
+++ b/drivers/net/can/c_can.c
@@ -0,0 +1,1217 @@
+/*
+ * CAN bus driver for Bosch C_CAN controller
+ *
+ * Copyright (C) 2010 ST Microelectronics
+ * Bhupesh Sharma <bhupesh.sharma@st.com>
+ *
+ * Borrowed heavily from the C_CAN driver originally written by:
+ * Copyright (C) 2007
+ * - Sascha Hauer, Marc Kleine-Budde, Pengutronix <s.hauer@pengutronix.de>
+ * - Simon Kallweit, intefo AG <simon.kallweit@intefo.ch>
+ *
+ * Bosch C_CAN controller is compliant to CAN protocol version 2.0 part A and B.
+ * Bosch C_CAN user manual can be obtained from:
+ * http://www.semiconductors.bosch.de/pdf/Users_Manual_C_CAN.pdf
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#include <linux/kernel.h>
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/if_ether.h>
+#include <linux/list.h>
+#include <linux/delay.h>
+#include <linux/workqueue.h>
+#include <linux/io.h>
+#include <linux/platform_device.h>
+#include <linux/clk.h>
+
+#include <linux/can.h>
+#include <linux/can/dev.h>
+#include <linux/can/error.h>
+
+#define DRV_NAME "c_can"
+
+/* control register */
+#define CONTROL_TEST		(1 << 7)
+#define CONTROL_CCE		(1 << 6)
+#define CONTROL_DISABLE_AR	(1 << 5)
+#define CONTROL_ENABLE_AR	(0 << 5)
+#define CONTROL_EIE		(1 << 3)
+#define CONTROL_SIE		(1 << 2)
+#define CONTROL_IE		(1 << 1)
+#define CONTROL_INIT		(1 << 0)
+
+/* test register */
+#define TEST_RX			(1 << 7)
+#define TEST_TX1		(1 << 6)
+#define TEST_TX2		(1 << 5)
+#define TEST_LBACK		(1 << 4)
+#define TEST_SILENT		(1 << 3)
+#define TEST_BASIC		(1 << 2)
+
+/* status register */
+#define STATUS_BOFF		(1 << 7)
+#define STATUS_EWARN		(1 << 6)
+#define STATUS_EPASS		(1 << 5)
+#define STATUS_RXOK		(1 << 4)
+#define STATUS_TXOK		(1 << 3)
+#define STATUS_LEC_MASK		0x07
+#define LEC_STUFF_ERROR		1
+#define LEC_FORM_ERROR		2
+#define LEC_ACK_ERROR		3
+#define LEC_BIT1_ERROR		4
+#define LEC_BIT0_ERROR		5
+#define LEC_CRC_ERROR		6
+
+/* error counter register */
+#define ERR_COUNTER_TEC_MASK	0xff
+#define ERR_COUNTER_TEC_SHIFT	0x0
+#define ERR_COUNTER_REC_SHIFT	8
+#define ERR_COUNTER_REC_MASK	(0x7f << ERR_COUNTER_REC_SHIFT)
+#define ERR_COUNTER_RP_SHIFT	15
+#define ERR_COUNTER_RP_MASK	(0x1 << ERR_COUNTER_RP_SHIFT)
+
+/* bit-timing register */
+#define BTR_BRP_MASK		0x3f
+#define BTR_BRP_SHIFT		0
+#define BTR_SJW_SHIFT		6
+#define BTR_SJW_MASK		(0x3 << BTR_SJW_SHIFT)
+#define BTR_TSEG1_SHIFT		8
+#define BTR_TSEG1_MASK		(0xf << BTR_TSEG1_SHIFT)
+#define BTR_TSEG2_SHIFT		12
+#define BTR_TSEG2_MASK		(0x7 << BTR_TSEG2_SHIFT)
+
+/* brp extension register */
+#define BRP_EXT_BRPE_MASK	0x0f
+#define BRP_EXT_BRPE_SHIFT	0
+
+/* IFx command request */
+#define IF_COMR_BUSY		(1 << 15)
+
+/* IFx command mask */
+#define IF_COMM_WR		(1 << 7)
+#define IF_COMM_MASK		(1 << 6)
+#define IF_COMM_ARB		(1 << 5)
+#define IF_COMM_CONTROL		(1 << 4)
+#define IF_COMM_CLR_INT_PND	(1 << 3)
+#define IF_COMM_TXRQST		(1 << 2)
+#define IF_COMM_DATAA		(1 << 1)
+#define IF_COMM_DATAB		(1 << 0)
+#define IF_COMM_ALL		(IF_COMM_MASK | IF_COMM_ARB | \
+				IF_COMM_CONTROL | IF_COMM_TXRQST | \
+				IF_COMM_DATAA | IF_COMM_DATAB)
+
+/* IFx arbitration */
+#define IF_ARB_MSGVAL		(1 << 15)
+#define IF_ARB_MSGXTD		(1 << 14)
+#define IF_ARB_TRANSMIT		(1 << 13)
+
+/* IFx message control */
+#define IF_MCONT_NEWDAT		(1 << 15)
+#define IF_MCONT_MSGLST		(1 << 14)
+#define IF_MCONT_INTPND		(1 << 13)
+#define IF_MCONT_UMASK		(1 << 12)
+#define IF_MCONT_TXIE		(1 << 11)
+#define IF_MCONT_RXIE		(1 << 10)
+#define IF_MCONT_RMTEN		(1 << 9)
+#define IF_MCONT_TXRQST		(1 << 8)
+#define IF_MCONT_EOB		(1 << 7)
+
+/*
+ * IFx register masks:
+ * allow easy operation on 16-bit registers when the
+ * argument is 32-bit instead
+ */
+#define IFX_WRITE_LOW_16BIT(x)	(x & 0xFFFF)
+#define IFX_WRITE_HIGH_16BIT(x)	((x & 0xFFFF0000) >> 16)
+
+/* message object split */
+#define C_CAN_NO_OF_OBJECTS	31
+#define C_CAN_MSG_OBJ_RX_NUM	16
+#define C_CAN_MSG_OBJ_TX_NUM	16
+
+#define C_CAN_MSG_OBJ_RX_FIRST	0
+#define C_CAN_MSG_OBJ_RX_LAST	(C_CAN_MSG_OBJ_RX_FIRST + \
+				C_CAN_MSG_OBJ_RX_NUM - 1)
+
+#define C_CAN_MSG_OBJ_TX_FIRST	(C_CAN_MSG_OBJ_RX_LAST + 1)
+#define C_CAN_MSG_OBJ_TX_LAST	(C_CAN_MSG_OBJ_TX_FIRST + \
+				C_CAN_MSG_OBJ_TX_NUM - 1)
+#define C_CAN_NEXT_MSG_OBJ_MASK	(C_CAN_MSG_OBJ_TX_NUM - 1)
+#define RECEIVE_OBJECT_BITS	0x0000ffff
+
+/* status interrupt */
+#define STATUS_INTERRUPT	0x8000
+
+/* napi related */
+#define C_CAN_NAPI_WEIGHT	C_CAN_MSG_OBJ_RX_NUM
+
+/* c_can IF registers */
+struct c_can_if_regs {
+	u16 com_reg;
+	u16 com_mask;
+	u16 mask1;
+	u16 mask2;
+	u16 arb1;
+	u16 arb2;
+	u16 msg_cntrl;
+	u16 data_a1;
+	u16 data_a2;
+	u16 data_b1;
+	u16 data_b2;
+	u16 _reserved[13];
+};
+
+/* c_can hardware registers */
+struct c_can_regs {
+	u16 control;
+	u16 status;
+	u16 error_counter;
+	u16 btr;
+	u16 ir;
+	u16 test;
+	u16 brp_ext;
+	u16 _reserved1;
+	struct c_can_if_regs ifreg[2]; /* [0] = IF1 and [1] = IF2 */
+	u16 _reserved2[8];
+	u16 txrqst1;
+	u16 txrqst2;
+	u16 _reserved3[6];
+	u16 newdat1;
+	u16 newdat2;
+	u16 _reserved4[6];
+	u16 intpnd1;
+	u16 intpnd2;
+	u16 _reserved5[6];
+	u16 msgval1;
+	u16 msgval2;
+	u16 _reserved6[6];
+};
+
+/*
+ * c_can error types:
+ * Bus errors (BUS_OFF, ERROR_WARNING, ERROR_PASSIVE) are supported
+ */
+enum c_can_bus_error_types {
+	C_CAN_NO_ERROR = 0,
+	C_CAN_BUS_OFF,
+	C_CAN_ERROR_WARNING,
+	C_CAN_ERROR_PASSIVE
+};
+
+enum c_can_interrupt_mode {
+	ENABLE_MODULE_INTERRUPT = 0,
+	DISABLE_MODULE_INTERRUPT,
+	ENABLE_ALL_INTERRUPTS,
+	DISABLE_ALL_INTERRUPTS
+};
+
+/* c_can private data structure */
+struct c_can_priv {
+	struct can_priv can;	/* must be the first member */
+	struct napi_struct napi;
+	struct net_device *dev;
+	int tx_object;
+	int current_status;
+	int last_status;
+	u16 (*read_reg) (struct c_can_priv *priv, void *reg);
+	void (*write_reg) (struct c_can_priv *priv, void *reg, u16 val);
+	struct c_can_regs __iomem *reg_base;
+	unsigned long irq_flags; /* for request_irq() */
+	unsigned int tx_next;
+	unsigned int tx_echo;
+	struct clk *clk;
+};
+
+static struct can_bittiming_const c_can_bittiming_const = {
+	.name = DRV_NAME,
+	.tseg1_min = 2,		/* Time segment 1 = prop_seg + phase_seg1 */
+	.tseg1_max = 16,
+	.tseg2_min = 1,		/* Time segment 2 = phase_seg2 */
+	.tseg2_max = 8,
+	.sjw_max = 4,
+	.brp_min = 1,
+	.brp_max = 1024,	/* 6-bit BRP field + 4-bit BRPE field*/
+	.brp_inc = 1,
+};
+
+static inline int get_tx_next_msg_obj(const struct c_can_priv *priv)
+{
+	return (priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) +
+			C_CAN_MSG_OBJ_TX_FIRST;
+}
+
+static inline int get_tx_echo_msg_obj(const struct c_can_priv *priv)
+{
+	return (priv->tx_echo & C_CAN_NEXT_MSG_OBJ_MASK) +
+			C_CAN_MSG_OBJ_TX_FIRST;
+}
+
+/* 16-bit c_can registers can be arranged differently in the memory
+ * architecture of different implementations. For example: 16-bit
+ * registers can be aligned to a 16-bit boundary or 32-bit boundary etc.
+ * Handle the same by providing a common read/write interface.
+ */
+static u16 c_can_read_reg_aligned_to_16bit(void *reg)
+{
+	return readw(reg);
+}
+
+static void c_can_write_reg_aligned_to_16bit(void *reg, u16 val)
+{
+	writew(val, reg);
+}
+
+static u16 c_can_read_reg_aligned_to_32bit(struct c_can_priv *priv, void *reg)
+{
+	return readw(reg + (u32)reg - (u32)priv->reg_base);
+}
+
+static void c_can_write_reg_aligned_to_32bit(struct c_can_priv *priv,
+					void *reg, u16 val)
+{
+	writew(val, reg + (u32)reg - (u32)priv->reg_base);
+}
+
+static u32 c_can_read_reg32(struct c_can_priv *priv, void *reg)
+{
+	u32 val = priv->read_reg(priv, reg);
+	val |= ((u32) priv->read_reg(priv, reg + 2)) << 16;
+	return val;
+}
+
+static inline int c_can_configure_interrupts(struct c_can_priv *priv,
+					enum c_can_interrupt_mode intr_mode)
+{
+	unsigned int cntrl_save = priv->read_reg(priv,
+						&priv->reg_base->control);
+
+	switch (intr_mode) {
+	case ENABLE_MODULE_INTERRUPT:
+		cntrl_save |= CONTROL_IE;
+		break;
+	case DISABLE_MODULE_INTERRUPT:
+		cntrl_save &= ~CONTROL_IE;
+		break;
+	case ENABLE_ALL_INTERRUPTS:
+		cntrl_save |= (CONTROL_SIE | CONTROL_EIE | CONTROL_IE);
+		break;
+	case DISABLE_ALL_INTERRUPTS:
+		cntrl_save &= ~(CONTROL_EIE | CONTROL_IE | CONTROL_SIE);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	priv->write_reg(priv, &priv->reg_base->control, cntrl_save);
+
+	return 0;
+}
+
+static inline int c_can_object_get(struct net_device *dev,
+					int iface, int objno, int mask)
+{
+	struct c_can_priv *priv = netdev_priv(dev);
+	int timeout = (6 / priv->can.clock.freq);
+
+	priv->write_reg(priv, &priv->reg_base->ifreg[iface].com_mask,
+			IFX_WRITE_LOW_16BIT(mask));
+	priv->write_reg(priv, &priv->reg_base->ifreg[iface].com_reg,
+			IFX_WRITE_LOW_16BIT(objno + 1));
+
+	/* as per specs, after writting the message object number in the
+	 * IF command request register the transfer b/w interface
+	 * register and message RAM must be complete in 6 CAN-CLK
+	 * period. The delay accounts for the same
+	 */
+	udelay(timeout);
+	if ((priv->read_reg(priv, &priv->reg_base->ifreg[iface].com_reg)) &
+			IF_COMR_BUSY) {
+		dev_info(dev->dev.parent, "timed out in object get\n");
+		return -ETIMEDOUT;
+	}
+
+	return 0;
+}
+
+static inline int c_can_object_put(struct net_device *dev,
+					int iface, int objno, int mask)
+{
+	struct c_can_priv *priv = netdev_priv(dev);
+	int timeout = (6 / priv->can.clock.freq);
+
+	priv->write_reg(priv, &priv->reg_base->ifreg[iface].com_mask,
+			(IF_COMM_WR | IFX_WRITE_LOW_16BIT(mask)));
+	priv->write_reg(priv, &priv->reg_base->ifreg[iface].com_reg,
+			IFX_WRITE_LOW_16BIT(objno + 1));
+
+	/* as per specs, after writting the message object number in the
+	 * IF command request register the transfer b/w interface
+	 * register and message RAM must be complete in 6 CAN-CLK
+	 * period. The delay accounts for the same
+	 */
+	udelay(timeout);
+	if ((priv->read_reg(priv, &priv->reg_base->ifreg[iface].com_reg)) &
+			IF_COMR_BUSY) {
+		dev_info(dev->dev.parent, "timed out in object put\n");
+		return -ETIMEDOUT;
+	}
+
+	return 0;
+}
+
+int c_can_write_msg_object(struct net_device *dev,
+			int iface, struct can_frame *frame, int objno)
+{
+	u16 flags = 0;
+	unsigned int id;
+	struct c_can_priv *priv = netdev_priv(dev);
+
+	if (frame->can_id & CAN_EFF_FLAG) {
+		id = frame->can_id & CAN_EFF_MASK;
+		flags |= IF_ARB_MSGXTD;
+	} else
+		id = ((frame->can_id & CAN_SFF_MASK) << 18);
+
+	if (!(frame->can_id & CAN_RTR_FLAG))
+		flags |= IF_ARB_TRANSMIT;
+
+	flags |= IF_ARB_MSGVAL;
+
+	priv->write_reg(priv, &priv->reg_base->ifreg[iface].arb1,
+				IFX_WRITE_LOW_16BIT(id));
+	priv->write_reg(priv, &priv->reg_base->ifreg[iface].arb2, flags |
+				IFX_WRITE_HIGH_16BIT(id));
+
+	priv->write_reg(priv, &priv->reg_base->ifreg[iface].data_a1,
+			(*(u16 *)(frame->data)));
+	priv->write_reg(priv, &priv->reg_base->ifreg[iface].data_a2,
+			(*(u32 *)(frame->data)) >> 16);
+
+	if (frame->can_dlc > 4) {
+		priv->write_reg(priv, &priv->reg_base->ifreg[iface].data_b1,
+			(*(u16 *)(frame->data + 4)));
+		priv->write_reg(priv, &priv->reg_base->ifreg[iface].data_b2,
+			(*(u32 *)(frame->data + 4)) >> 16);
+	} else
+		*(u32 *)(frame->data + 4) = 0;
+
+	return frame->can_dlc;
+}
+
+static int c_can_read_msg_object(struct net_device *dev, int iface, int objno)
+{
+	u16 flags;
+	int ctrl;
+	unsigned int val, data;
+	struct c_can_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	struct sk_buff *skb;
+	struct can_frame *frame;
+
+	skb = alloc_can_skb(dev, &frame);
+	if (!skb) {
+		stats->rx_dropped++;
+		return -ENOMEM;
+	}
+
+	val = c_can_object_get(dev, iface, objno, IF_COMM_ALL &
+						~IF_COMM_TXRQST);
+	if (val < 0)
+		return val;
+
+	ctrl = priv->read_reg(priv, &priv->reg_base->ifreg[iface].msg_cntrl);
+	if (ctrl & IF_MCONT_MSGLST) {
+		stats->rx_errors++;
+		dev_info(dev->dev.parent, "msg lost in buffer %d\n", objno);
+	}
+
+	frame->can_dlc = get_can_dlc(ctrl & 0x0F);
+	data = priv->read_reg(priv, &priv->reg_base->ifreg[iface].data_a1) |
+		(priv->read_reg(priv, &priv->reg_base->ifreg[iface].data_a2) <<
+			16);
+	*(u32 *)(frame->data) = data;
+	if (frame->can_dlc > 4) {
+		data = priv->read_reg(priv,
+				&priv->reg_base->ifreg[iface].data_b1) |
+			(priv->read_reg(priv,
+				&priv->reg_base->ifreg[iface].data_b2) <<
+				16);
+		*(u32 *)(frame->data + 4) = data;
+	} else
+		*(u32 *)(frame->data + 4) = 0;
+
+	flags =	priv->read_reg(priv, &priv->reg_base->ifreg[iface].arb2);
+	val = priv->read_reg(priv, &priv->reg_base->ifreg[iface].arb1) |
+		(flags << 16);
+
+	if (flags & IF_ARB_MSGXTD)
+		frame->can_id = (val & CAN_EFF_MASK) | CAN_EFF_FLAG;
+	else
+		frame->can_id = (val >> 18) & CAN_SFF_MASK;
+
+	if (flags & IF_ARB_TRANSMIT)
+		frame->can_id |= CAN_RTR_FLAG;
+
+	priv->write_reg(priv, &priv->reg_base->ifreg[iface].msg_cntrl, ctrl &
+			~(IF_MCONT_MSGLST | IF_MCONT_INTPND | IF_MCONT_NEWDAT));
+
+	val = c_can_object_put(dev, iface, objno, IF_COMM_CONTROL);
+	if (val < 0)
+		return val;
+
+	netif_receive_skb(skb);
+
+	stats->rx_packets++;
+	stats->rx_bytes += frame->can_dlc;
+
+	return 0;
+}
+
+static int c_can_setup_receive_object(struct net_device *dev, int iface,
+					int objno, unsigned int mask,
+					unsigned int id, unsigned int mcont)
+{
+	int ret;
+	struct c_can_priv *priv = netdev_priv(dev);
+
+	priv->write_reg(priv, &priv->reg_base->ifreg[iface].mask1,
+			IFX_WRITE_LOW_16BIT(mask));
+	priv->write_reg(priv, &priv->reg_base->ifreg[iface].mask2,
+			IFX_WRITE_HIGH_16BIT(mask));
+
+	priv->write_reg(priv, &priv->reg_base->ifreg[iface].arb1,
+			IFX_WRITE_LOW_16BIT(id));
+	priv->write_reg(priv, &priv->reg_base->ifreg[iface].arb2,
+			(IF_ARB_MSGVAL | IFX_WRITE_HIGH_16BIT(id)));
+
+	priv->write_reg(priv, &priv->reg_base->ifreg[iface].msg_cntrl, mcont);
+	ret = c_can_object_put(dev, iface, objno, IF_COMM_ALL &
+						~IF_COMM_TXRQST);
+	if (ret < 0)
+		return ret;
+
+	dev_dbg(dev->dev.parent, "obj no:%d, msgval:0x%08x\n", objno,
+			c_can_read_reg32(priv, &priv->reg_base->msgval1));
+
+	return 0;
+}
+
+static int c_can_inval_msg_object(struct net_device *dev, int iface, int objno)
+{
+	int ret;
+	struct c_can_priv *priv = netdev_priv(dev);
+
+	priv->write_reg(priv, &priv->reg_base->ifreg[iface].arb1, 0);
+	priv->write_reg(priv, &priv->reg_base->ifreg[iface].arb2, 0);
+	priv->write_reg(priv, &priv->reg_base->ifreg[iface].msg_cntrl, 0);
+
+	ret = c_can_object_put(dev, iface, objno,
+				IF_COMM_ARB | IF_COMM_CONTROL);
+	if (ret < 0)
+		return ret;
+
+	dev_dbg(dev->dev.parent, "obj no:%d, msgval:0x%08x\n", objno,
+			c_can_read_reg32(priv, &priv->reg_base->msgval1));
+
+	return 0;
+}
+
+static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
+					struct net_device *dev)
+{
+	u32 val;
+	u32 msg_obj_no;
+	struct c_can_priv *priv = netdev_priv(dev);
+	struct can_frame *frame = (struct can_frame *)skb->data;
+
+	if (can_dropped_invalid_skb(dev, skb))
+		return NETDEV_TX_OK;
+
+	msg_obj_no = get_tx_next_msg_obj(priv);
+
+	/* prepare message object for transmission */
+	val = c_can_write_msg_object(dev, 0, frame, msg_obj_no);
+
+	/* enable interrupt for this message object */
+	priv->write_reg(priv, &priv->reg_base->ifreg[0].msg_cntrl,
+			IF_MCONT_TXIE | IF_MCONT_TXRQST | IF_MCONT_EOB |
+			(val & 0xf));
+	val = c_can_object_put(dev, 0, msg_obj_no, IF_COMM_ALL);
+	if (val < 0)
+		return val;
+
+	can_put_echo_skb(skb, dev, msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
+
+	priv->tx_next++;
+	if ((priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) == 0)
+		netif_stop_queue(dev);
+
+	return NETDEV_TX_OK;
+}
+
+static int c_can_set_bittiming(struct net_device *dev)
+{
+	unsigned int reg_btr, reg_brpe, ctrl_save;
+	u8 brp, brpe, sjw, tseg1, tseg2;
+	u32 ten_bit_brp;
+	struct c_can_priv *priv = netdev_priv(dev);
+	const struct can_bittiming *bt = &priv->can.bittiming;
+
+	/* c_can provides a 6-bit brp and 4-bit brpe fields */
+	ten_bit_brp = bt->brp - 1;
+	brp = ten_bit_brp & BTR_BRP_MASK;
+	brpe = ten_bit_brp >> 6;
+
+	sjw = bt->sjw - 1;
+	tseg1 = bt->prop_seg + bt->phase_seg1 - 1;
+	tseg2 = bt->phase_seg2 - 1;
+
+	reg_btr = ((brp) | (sjw << BTR_SJW_SHIFT) | (tseg1 << BTR_TSEG1_SHIFT) |
+			(tseg2 << BTR_TSEG2_SHIFT));
+
+	reg_brpe = brpe & BRP_EXT_BRPE_MASK;
+
+	dev_dbg(dev->dev.parent,
+			"brp = %d, brpe = %d, sjw = %d, seg1 = %d, seg2 = %d\n",
+			brp, brpe, sjw, tseg1, tseg2);
+	dev_dbg(dev->dev.parent, "setting BTR to %04x\n", reg_btr);
+	dev_dbg(dev->dev.parent, "setting BRPE to %04x\n", reg_brpe);
+
+	ctrl_save = priv->read_reg(priv, &priv->reg_base->control);
+	priv->write_reg(priv, &priv->reg_base->control,
+			ctrl_save | CONTROL_CCE | CONTROL_INIT);
+	priv->write_reg(priv, &priv->reg_base->btr, reg_btr);
+	priv->write_reg(priv, &priv->reg_base->brp_ext, reg_brpe);
+	priv->write_reg(priv, &priv->reg_base->control, ctrl_save);
+
+	return 0;
+}
+
+/*
+ * Configure C_CAN message objects for Tx and Rx purposes:
+ * C_CAN provides a total of 32 message objects that can be configured
+ * either for Tx or Rx purposes. Here the first 16 message objects are used as
+ * a reception FIFO. The end of reception FIFO is signified by the EoB bit
+ * being SET. The remaining 16 message objects are kept aside for Tx purposes.
+ * See user guide document for further details on configuring message
+ * objects.
+ */
+static int c_can_configure_msg_objects(struct net_device *dev)
+{
+	int i;
+
+	/* first invalidate all message objects */
+	for (i = 0; i <= C_CAN_NO_OF_OBJECTS; i++)
+		c_can_inval_msg_object(dev, 0, i);
+
+	/* setup receive message objects */
+	for (i = C_CAN_MSG_OBJ_RX_FIRST + 1 ; i < C_CAN_MSG_OBJ_RX_LAST; i++)
+		c_can_setup_receive_object(dev, 0, i, 0, 0,
+			((IF_MCONT_RXIE | IF_MCONT_UMASK) & ~IF_MCONT_EOB));
+
+	c_can_setup_receive_object(dev, 0, C_CAN_MSG_OBJ_RX_LAST, 0, 0,
+				IF_MCONT_EOB | IF_MCONT_RXIE | IF_MCONT_UMASK);
+	return 0;
+}
+
+/*
+ * Configure C_CAN chip:
+ * - enable/disable auto-retransmission
+ * - set operating mode
+ * - configure message objects
+ */
+static int c_can_chip_config(struct net_device *dev)
+{
+	struct c_can_priv *priv = netdev_priv(dev);
+
+	if (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT)
+		/* disable automatic retransmission */
+		priv->write_reg(priv, &priv->reg_base->control,
+				CONTROL_DISABLE_AR);
+	else
+		/* enable automatic retransmission */
+		priv->write_reg(priv, &priv->reg_base->control,
+				CONTROL_ENABLE_AR);
+
+	if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
+		/* loopback mode : useful for self-test function */
+		priv->write_reg(priv, &priv->reg_base->control, (CONTROL_EIE |
+				CONTROL_SIE | CONTROL_IE | CONTROL_TEST));
+		priv->write_reg(priv, &priv->reg_base->test, TEST_LBACK);
+	} else if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY) {
+		/* silent mode : bus-monitoring mode */
+		priv->write_reg(priv, &priv->reg_base->control, (CONTROL_EIE |
+				CONTROL_SIE | CONTROL_IE | CONTROL_TEST));
+		priv->write_reg(priv, &priv->reg_base->test, TEST_SILENT);
+	} else if (priv->can.ctrlmode & (CAN_CTRLMODE_LISTENONLY &
+					CAN_CTRLMODE_LOOPBACK)) {
+		/* loopback + silent mode : useful for hot self-test */
+		priv->write_reg(priv, &priv->reg_base->control, (CONTROL_EIE |
+				CONTROL_SIE | CONTROL_IE | CONTROL_TEST));
+		priv->write_reg(priv, &priv->reg_base->test,
+				(TEST_LBACK | TEST_SILENT));
+	} else
+		/* normal mode*/
+		priv->write_reg(priv, &priv->reg_base->control,
+				(CONTROL_EIE | CONTROL_SIE | CONTROL_IE));
+
+	/* configure message objects */
+	c_can_configure_msg_objects(dev);
+
+	return 0;
+}
+
+static int c_can_start(struct net_device *dev)
+{
+	int err;
+	struct c_can_priv *priv = netdev_priv(dev);
+
+	/* enable status change, error and module interrupts */
+	c_can_configure_interrupts(priv, ENABLE_ALL_INTERRUPTS);
+
+	/* basic c_can configuration */
+	err = c_can_chip_config(dev);
+	if (err)
+		return err;
+
+	priv->can.state = CAN_STATE_ERROR_ACTIVE;
+
+	/* reset tx helper pointers */
+	priv->tx_next = priv->tx_echo = 0;
+
+	return 0;
+}
+
+static int c_can_stop(struct net_device *dev)
+{
+	struct c_can_priv *priv = netdev_priv(dev);
+
+	/* disable all interrupts */
+	c_can_configure_interrupts(priv, DISABLE_ALL_INTERRUPTS);
+
+	/* set the state as STOPPED */
+	priv->can.state = CAN_STATE_STOPPED;
+
+	return 0;
+}
+
+static int c_can_set_mode(struct net_device *dev, enum can_mode mode)
+{
+	switch (mode) {
+	case CAN_MODE_START:
+		c_can_start(dev);
+		netif_wake_queue(dev);
+		dev_info(dev->dev.parent,
+				"c_can CAN_MODE_START requested\n");
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static int c_can_get_state(const struct net_device *dev,
+				enum can_state *state)
+{
+	struct c_can_priv *priv = netdev_priv(dev);
+
+	*state = priv->can.state;
+
+	return 0;
+}
+
+static int c_can_get_berr_counter(const struct net_device *dev,
+					struct can_berr_counter *bec)
+{
+	unsigned int reg_err_counter;
+	struct c_can_priv *priv = netdev_priv(dev);
+
+	reg_err_counter = priv->read_reg(priv, &priv->reg_base->error_counter);
+	bec->rxerr = ((reg_err_counter & ERR_COUNTER_REC_MASK) >>
+				ERR_COUNTER_REC_SHIFT);
+	bec->txerr = (reg_err_counter & ERR_COUNTER_TEC_MASK);
+
+	return 0;
+}
+
+/*
+ * theory of operation:
+ *
+ * priv->tx_echo holds the number of the oldest can_frame put for
+ * transmission into the hardware, but not yet ACKed by the CAN tx
+ * complete IRQ.
+ *
+ * We iterate from priv->tx_echo to priv->tx_next and check if the
+ * packet has been transmitted, echo it back to the CAN framework. If
+ * we discover a not yet transmitted package, stop looking for more.
+ */
+static void c_can_do_tx(struct net_device *dev)
+{
+	u32 val;
+	u32 msg_obj_no;
+	struct c_can_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+
+	for (/* nix */; (priv->tx_next - priv->tx_echo) > 0; priv->tx_echo++) {
+		msg_obj_no = get_tx_echo_msg_obj(priv);
+		c_can_inval_msg_object(dev, 0, msg_obj_no);
+		val = c_can_read_reg32(priv, &priv->reg_base->txrqst1);
+		if (!(val & (1 << msg_obj_no))) {
+			can_get_echo_skb(dev,
+					msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
+			stats->tx_bytes += priv->read_reg(priv,
+					&priv->reg_base->ifreg[0].msg_cntrl)
+					& 0xF;
+			stats->tx_packets++;
+		}
+	}
+
+	/* restart queue if wrap-up or if queue stalled on last pkt */
+	if (((priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) != 0) ||
+			((priv->tx_echo & C_CAN_NEXT_MSG_OBJ_MASK) == 0))
+		netif_wake_queue(dev);
+}
+
+/*
+ * c_can_do_rx_poll - read multiple CAN messages from message objects
+ */
+static int c_can_do_rx_poll(struct net_device *dev, int quota)
+{
+	u32 num_rx_pkts = 0;
+	unsigned int msg_obj;
+	struct c_can_priv *priv = netdev_priv(dev);
+	u32 val = c_can_read_reg32(priv, &priv->reg_base->newdat1);
+
+	while (val & RECEIVE_OBJECT_BITS) {
+		for (msg_obj = C_CAN_MSG_OBJ_RX_FIRST;
+				msg_obj <= C_CAN_MSG_OBJ_RX_LAST; msg_obj++) {
+			if (val & (1 << msg_obj)) {
+				c_can_read_msg_object(dev, 0, msg_obj);
+				num_rx_pkts++;
+				quota--;
+			}
+		}
+
+		val = c_can_read_reg32(priv, &priv->reg_base->newdat1);
+	}
+
+	return num_rx_pkts;
+}
+
+static int c_can_err(struct net_device *dev,
+				enum c_can_bus_error_types error_type,
+				int lec_type)
+{
+	unsigned int reg_err_counter;
+	unsigned int rx_err_passive;
+	struct c_can_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	struct can_frame *cf;
+	struct sk_buff *skb;
+	struct can_berr_counter bec;
+
+	/* propogate the error condition to the CAN stack */
+	skb = alloc_can_err_skb(dev, &cf);
+	if (unlikely(!skb))
+		return 0;
+
+	c_can_get_berr_counter(dev, &bec);
+	reg_err_counter = priv->read_reg(priv, &priv->reg_base->error_counter);
+	rx_err_passive = ((reg_err_counter & ERR_COUNTER_RP_MASK) >>
+				ERR_COUNTER_RP_SHIFT);
+
+	if (error_type & C_CAN_ERROR_WARNING) {
+		/* error warning state */
+		priv->can.can_stats.error_warning++;
+		priv->can.state = CAN_STATE_ERROR_WARNING;
+		cf->can_id |= CAN_ERR_CRTL;
+		if (bec.rxerr > 96)
+			cf->data[1] = CAN_ERR_CRTL_RX_WARNING;
+		if (bec.txerr > 96)
+			cf->data[1] = CAN_ERR_CRTL_TX_WARNING;
+	}
+	if (error_type & C_CAN_ERROR_PASSIVE) {
+		/* error passive state */
+		priv->can.can_stats.error_passive++;
+		priv->can.state = CAN_STATE_ERROR_PASSIVE;
+		cf->can_id |= CAN_ERR_CRTL;
+		if (rx_err_passive)
+			cf->data[1] = CAN_ERR_CRTL_RX_PASSIVE;
+		if (bec.txerr > 127)
+			cf->data[1] = CAN_ERR_CRTL_TX_PASSIVE;
+	}
+	if (error_type & C_CAN_BUS_OFF) {
+		/* bus-off state */
+		priv->can.state = CAN_STATE_BUS_OFF;
+		cf->can_id |= CAN_ERR_BUSOFF;
+		/* disable all interrupts in bus-off mode to ensure that
+		 * the CPU is not hogged down
+		 */
+		c_can_configure_interrupts(priv, DISABLE_ALL_INTERRUPTS);
+		can_bus_off(dev);
+	}
+
+	/* check for 'last error code' which tells us the
+	 * type of the last error to occur on the CAN bus
+	 */
+	if (lec_type) {
+		/* common for all type of bus errors */
+		priv->can.can_stats.bus_error++;
+		stats->rx_errors++;
+		cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
+		cf->data[2] |= CAN_ERR_PROT_UNSPEC;
+
+		if (lec_type & LEC_STUFF_ERROR) {
+			dev_info(dev->dev.parent, "stuff error\n");
+			cf->data[2] |= CAN_ERR_PROT_STUFF;
+		}
+		if (lec_type & LEC_FORM_ERROR) {
+			dev_info(dev->dev.parent, "form error\n");
+			cf->data[2] |= CAN_ERR_PROT_FORM;
+		}
+		if (lec_type & LEC_ACK_ERROR) {
+			dev_info(dev->dev.parent, "ack error\n");
+			cf->data[2] |= (CAN_ERR_PROT_LOC_ACK |
+					CAN_ERR_PROT_LOC_ACK_DEL);
+		}
+		if (lec_type & LEC_BIT1_ERROR) {
+			dev_info(dev->dev.parent, "bit1 error\n");
+			cf->data[2] |= CAN_ERR_PROT_BIT1;
+		}
+		if (lec_type & LEC_BIT0_ERROR) {
+			dev_info(dev->dev.parent, "bit0 error\n");
+			cf->data[2] |= CAN_ERR_PROT_BIT0;
+		}
+		if (lec_type & LEC_CRC_ERROR) {
+			dev_info(dev->dev.parent, "CRC error\n");
+			cf->data[2] |= (CAN_ERR_PROT_LOC_CRC_SEQ |
+					CAN_ERR_PROT_LOC_CRC_DEL);
+		}
+	}
+
+	netif_receive_skb(skb);
+	stats->rx_packets++;
+	stats->rx_bytes += cf->can_dlc;
+
+	return 1;
+}
+
+static int c_can_poll(struct napi_struct *napi, int quota)
+{
+	u16 irqstatus;
+	int lec_type = 0;
+	int work_done = 0;
+	struct net_device *dev = napi->dev;
+	struct c_can_priv *priv = netdev_priv(dev);
+	enum c_can_bus_error_types error_type = C_CAN_NO_ERROR;
+
+	irqstatus = priv->read_reg(priv, &priv->reg_base->ir);
+
+	/* status events have the highest priority */
+	if (irqstatus == STATUS_INTERRUPT) {
+		priv->current_status = priv->read_reg(priv,
+					&priv->reg_base->status);
+
+		/* handle Tx/Rx events */
+		if (priv->current_status & STATUS_TXOK)
+			priv->write_reg(priv, &priv->reg_base->status,
+					(priv->current_status & ~STATUS_TXOK));
+
+		if (priv->current_status & STATUS_RXOK)
+			priv->write_reg(priv, &priv->reg_base->status,
+					(priv->current_status & ~STATUS_RXOK));
+
+		/* handle bus error events */
+		if (priv->current_status & STATUS_EWARN) {
+			dev_info(dev->dev.parent,
+					"entered error warning state\n");
+			error_type = C_CAN_ERROR_WARNING;
+		}
+		if ((priv->current_status & STATUS_EPASS) &&
+				(!(priv->last_status & STATUS_EPASS))) {
+			dev_info(dev->dev.parent,
+					"entered error passive state\n");
+			error_type = C_CAN_ERROR_PASSIVE;
+		}
+		if ((priv->current_status & STATUS_BOFF) &&
+				(!(priv->last_status & STATUS_BOFF))) {
+			dev_info(dev->dev.parent,
+					"entered bus off state\n");
+			error_type = C_CAN_BUS_OFF;
+		}
+		if (priv->current_status & STATUS_LEC_MASK)
+			lec_type = (priv->current_status & STATUS_LEC_MASK);
+
+		/* handle bus recovery events */
+		if ((!(priv->current_status & STATUS_EPASS)) &&
+				(priv->last_status & STATUS_EPASS)) {
+			dev_info(dev->dev.parent,
+					"left error passive state\n");
+			priv->can.state = CAN_STATE_ERROR_ACTIVE;
+		}
+		if ((!(priv->current_status & STATUS_BOFF)) &&
+				(priv->last_status & STATUS_BOFF)) {
+			dev_info(dev->dev.parent,
+					"left bus off state\n");
+			priv->can.state = CAN_STATE_ERROR_ACTIVE;
+		}
+
+		priv->last_status = priv->current_status;
+
+		/* handle error on the bus */
+		if (error_type != C_CAN_NO_ERROR)
+			work_done += c_can_err(dev, error_type, lec_type);
+	} else if ((irqstatus > C_CAN_MSG_OBJ_RX_FIRST) &&
+			(irqstatus <= C_CAN_MSG_OBJ_RX_LAST)) {
+		/* handle events corresponding to receive message objects */
+		work_done += c_can_do_rx_poll(dev, (quota - work_done));
+		quota--;
+	} else if ((irqstatus > C_CAN_MSG_OBJ_TX_FIRST) &&
+			(irqstatus <= C_CAN_MSG_OBJ_TX_LAST)) {
+		/* handle events corresponding to transmit message objects */
+		c_can_do_tx(dev);
+	}
+
+	if (work_done < quota) {
+		napi_complete(napi);
+		/* enable all IRQs */
+		c_can_configure_interrupts(priv, ENABLE_ALL_INTERRUPTS);
+	}
+
+	return work_done;
+}
+
+static irqreturn_t c_can_isr(int irq, void *dev_id)
+{
+	struct net_device *dev = (struct net_device *)dev_id;
+	struct c_can_priv *priv = netdev_priv(dev);
+
+	/* disable all interrupts and schedule the NAPI */
+	c_can_configure_interrupts(priv, DISABLE_ALL_INTERRUPTS);
+	napi_schedule(&priv->napi);
+
+	return IRQ_HANDLED;
+}
+
+static int c_can_open(struct net_device *dev)
+{
+	int err;
+	struct c_can_priv *priv = netdev_priv(dev);
+
+	/* open the can device */
+	err = open_candev(dev);
+	if (err) {
+		dev_err(dev->dev.parent, "failed to open can device\n");
+		return err;
+	}
+
+	/* register interrupt handler */
+	err = request_irq(dev->irq, &c_can_isr, priv->irq_flags, dev->name,
+				(void *)dev);
+	if (err < 0) {
+		dev_err(dev->dev.parent, "failed to attach interrupt\n");
+		goto exit_irq_fail;
+	}
+
+	/* start the c_can controller */
+	err = c_can_start(dev);
+	if (err)
+		goto exit_start_fail;
+	napi_enable(&priv->napi);
+
+	netif_start_queue(dev);
+
+	return 0;
+
+exit_start_fail:
+	free_irq(dev->irq, dev);
+exit_irq_fail:
+	close_candev(dev);
+	return err;
+}
+
+static int c_can_close(struct net_device *dev)
+{
+	struct c_can_priv *priv = netdev_priv(dev);
+
+	netif_stop_queue(dev);
+	napi_disable(&priv->napi);
+	c_can_stop(dev);
+	free_irq(dev->irq, dev);
+	close_candev(dev);
+
+	return 0;
+}
+
+static const struct net_device_ops c_can_netdev_ops = {
+	.ndo_open = c_can_open,
+	.ndo_stop = c_can_close,
+	.ndo_start_xmit = c_can_start_xmit,
+};
+
+static int c_can_probe(struct platform_device *pdev)
+{
+	int ret;
+	void __iomem *addr;
+	struct net_device *dev;
+	struct c_can_priv *priv;
+	struct resource *mem, *irq;
+	struct clk *clk;
+
+	/* get the appropriate clk */
+	clk = clk_get(&pdev->dev, NULL);
+	if (IS_ERR(clk)) {
+		dev_err(&pdev->dev, "no clock defined\n");
+		ret = -ENODEV;
+		goto exit;
+	}
+
+	/* get the platform data */
+	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	if (!mem || (irq <= 0)) {
+		ret = -ENODEV;
+		goto exit_free_clk;
+	}
+
+	if (!request_mem_region(mem->start, resource_size(mem), DRV_NAME)) {
+		dev_err(&pdev->dev, "resource unavailable\n");
+		ret = -ENODEV;
+		goto exit_free_clk;
+	}
+
+	addr = ioremap(mem->start, resource_size(mem));
+	if (!addr) {
+		dev_err(&pdev->dev, "failed to map can port\n");
+		ret = -ENOMEM;
+		goto exit_release_mem;
+	}
+
+	/* allocate the c_can device */
+	dev = alloc_candev(sizeof(struct c_can_priv), C_CAN_MSG_OBJ_TX_NUM);
+	if (!dev) {
+		ret = -ENOMEM;
+		goto exit_iounmap;
+	}
+
+	priv = netdev_priv(dev);
+
+	priv->irq_flags = irq->flags;
+	priv->reg_base = addr;
+	priv->can.clock.freq = clk_get_rate(clk);
+	priv->clk = clk;
+
+	switch (mem->flags & IORESOURCE_MEM_TYPE_MASK) {
+	case IORESOURCE_MEM_32BIT:
+		priv->read_reg = c_can_read_reg_aligned_to_32bit;
+		priv->write_reg = c_can_write_reg_aligned_to_32bit;
+		break;
+	case IORESOURCE_MEM_16BIT:
+	default:
+		priv->read_reg = c_can_read_reg_aligned_to_16bit;
+		priv->write_reg = c_can_write_reg_aligned_to_16bit;
+		break;
+	}
+
+	priv->dev = dev;
+	priv->can.bittiming_const = &c_can_bittiming_const;
+	priv->can.do_set_bittiming = c_can_set_bittiming;
+	priv->can.do_get_state = c_can_get_state;
+	priv->can.do_set_mode = c_can_set_mode;
+	priv->can.do_get_berr_counter = c_can_get_berr_counter;
+	priv->can.ctrlmode_supported = CAN_CTRLMODE_ONE_SHOT |
+					CAN_CTRLMODE_LOOPBACK |
+					CAN_CTRLMODE_LISTENONLY |
+					CAN_CTRLMODE_BERR_REPORTING;
+
+	netif_napi_add(dev, &priv->napi, c_can_poll, C_CAN_NAPI_WEIGHT);
+
+	dev->irq = irq->start;
+	dev->flags |= IFF_ECHO;	/* we support local echo */
+	dev->netdev_ops = &c_can_netdev_ops;
+	platform_set_drvdata(pdev, dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
+	ret = register_candev(dev);
+	if (ret) {
+		dev_err(&pdev->dev, "registering %s failed (err=%d)\n",
+			DRV_NAME, ret);
+		goto exit_free_device;
+	}
+
+	dev_info(&pdev->dev, "%s device registered (reg_base=%p, irq=%d)\n",
+		 DRV_NAME, priv->reg_base, dev->irq);
+	return 0;
+
+exit_free_device:
+	platform_set_drvdata(pdev, NULL);
+	free_candev(dev);
+exit_iounmap:
+	iounmap(addr);
+exit_release_mem:
+	release_mem_region(mem->start, resource_size(mem));
+exit_free_clk:
+	clk_put(clk);
+exit:
+	dev_err(&pdev->dev, "probe failed\n");
+
+	return ret;
+}
+
+static int c_can_remove(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct c_can_priv *priv = netdev_priv(dev);
+	struct resource *mem;
+
+	/* disable all interrupts */
+	c_can_configure_interrupts(priv, DISABLE_ALL_INTERRUPTS);
+
+	unregister_candev(dev);
+	platform_set_drvdata(pdev, NULL);
+
+	free_candev(dev);
+	iounmap(priv->reg_base);
+
+	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	release_mem_region(mem->start, resource_size(mem));
+
+	clk_put(priv->clk);
+
+	return 0;
+}
+
+static struct platform_driver c_can_driver = {
+	.driver		= {
+		.name	= DRV_NAME,
+		.owner = THIS_MODULE,
+	},
+	.probe		= c_can_probe,
+	.remove		= c_can_remove,
+};
+
+static int __init c_can_init(void)
+{
+	return platform_driver_register(&c_can_driver);
+}
+module_init(c_can_init);
+
+static void __exit c_can_exit(void)
+{
+	platform_driver_unregister(&c_can_driver);
+}
+module_exit(c_can_exit);
+
+MODULE_AUTHOR("Bhupesh Sharma <bhupesh.sharma@st.com>");
+MODULE_LICENSE("GPL v2");
+MODULE_DESCRIPTION("CAN bus driver for Bosch C_CAN controller");
-- 
1.6.0.2

