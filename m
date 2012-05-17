From: Federico Vaga <federico.vaga@gmail.com>
Subject: [PATCH] STA2X11 CAN: CAN driver for the STA2X11 board
Date: Thu, 17 May 2012 22:59:24 +0200
Message-ID: <1337288364-17572-1-git-send-email-federico.vaga@gmail.com>
Cc: Federico vaga <federico.vaga@gmail.com>,
	Giancarlo Asnaghi <giancarlo.asnaghi@st.com>,
	Alan Cox <alan@linux.intel.com>
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Federico Vaga <federico.vaga@gmail.com>
Acked-by: Giancarlo Asnaghi <giancarlo.asnaghi@st.com>
Cc: Alan Cox <alan@linux.intel.com>
---
 drivers/net/can/Kconfig       |   11 +
 drivers/net/can/Makefile      |    1 +
 drivers/net/can/sta2x11_can.c | 1085 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 1097 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/can/sta2x11_can.c

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index bb709fd..5b1baef 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -122,6 +122,17 @@ source "drivers/net/can/usb/Kconfig"
 
 source "drivers/net/can/softing/Kconfig"
 
+config CAN_STA2X11
+	depends on CAN_DEV && HAS_IOMEM && MFD_STA2X11
+	tristate "CAN STA2X11"
+	---help---
+	  Driver for the STA2x11 CAN controller
+	  Supports CAN protocol version 2.0 part A and B
+	  Bit rates up to 1 MBit/s
+	  32 Message Objects
+	  Programmable loop-back mode for self-test operation
+	  8-bit non-multiplex Motorola HC08 compatible module interface
+
 config CAN_DEBUG_DEVICES
 	bool "CAN devices debugging messages"
 	depends on CAN
diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
index 938be37..00474b6 100644
--- a/drivers/net/can/Makefile
+++ b/drivers/net/can/Makefile
@@ -22,5 +22,6 @@ obj-$(CONFIG_CAN_BFIN)		+= bfin_can.o
 obj-$(CONFIG_CAN_JANZ_ICAN3)	+= janz-ican3.o
 obj-$(CONFIG_CAN_FLEXCAN)	+= flexcan.o
 obj-$(CONFIG_PCH_CAN)		+= pch_can.o
+obj-$(CONFIG_CAN_STA2X11)	+= sta2x11_can.o
 
 ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
diff --git a/drivers/net/can/sta2x11_can.c b/drivers/net/can/sta2x11_can.c
new file mode 100644
index 0000000..9194b02
--- /dev/null
+++ b/drivers/net/can/sta2x11_can.c
@@ -0,0 +1,1085 @@
+/*
+ * Copyright (c) 2010-2011 Wind River Systems, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/interrupt.h>
+#include <linux/debugfs.h>
+#include <linux/mfd/sta2x11-mfd.h>
+
+#include <linux/can.h>
+#include <linux/can/dev.h>
+#include <linux/can/error.h>
+
+#define PCI_DEVICE_ID_STMICRO_CAN	0xCC11
+
+#define CAN_CR			0x0	/* Control Register */
+#define CAN_CR_INI		0x01	/* Initialization */
+#define CAN_CR_IE		0x02	/* Interrupt Enable */
+#define CAN_CR_SIE		0x04	/* Status Interrupt Enable */
+#define CAN_CR_EIE		0x08	/* Error Interrupt Enable */
+#define CAN_CR_DAR		0x20	/* Disable Automatic Re-transmission */
+#define CAN_CR_CCE		0x40	/* Change Configuration Enable */
+#define CAN_CR_TME		0x80	/* Test Mode Enable */
+
+#define CAN_SR			0x04	/* Status Register */
+#define CAN_SR_LEC		0x07	/* Last Error Code */
+#define CAN_SR_LEC_STUFF	0x01	/* Stuff error */
+#define CAN_SR_LEC_FORM		0x02	/* Form error */
+#define CAN_SR_LEC_ACK		0x03	/* Acknowledgement error */
+#define CAN_SR_LEC_BIT1		0x04	/* Bit1 error */
+#define CAN_SR_LEC_BIT0		0x05	/* Bit0 error */
+#define CAN_SR_LEC_CRC		0x06	/* CRC error */
+#define CAN_SR_TXOK		0x08	/* Transmit Message Successfully */
+#define CAN_SR_RXOK		0x10	/* Receive Message Successfully */
+#define CAN_SR_EPAS		0x20	/* Error Passive */
+#define CAN_SR_WARN		0x40	/* Warning Status */
+#define CAN_SR_BOFF		0x80	/* Bus Off Status */
+
+#define CAN_ERR			0x08	/* Error Counter Register */
+#define CAN_ERR_TEC		0xFF	/* Transmit Error Counter */
+#define CAN_ERR_REC		0x7F00	/* Receive Error Counter */
+#define CAN_ERR_RP		0x8000	/* Receive Error Passive */
+
+#define CAN_BTR			0x0C	/* Bit Timing Register */
+
+#define CAN_BRPR		0x18	/* BRP Extension Register */
+
+#define CAN_IDR			0x10	/* Interrupt Identifier Register */
+#define CAN_IDR_STATUS		0x8000	/* Status Interrupt Identifier */
+
+#define CAN_TXR1R		0x100	/* Transmission Request Register */
+#define CAN_TXR2R		0x104	/* Transmission Request Register */
+
+#define CAN_ND1R		0x120	/* New Data Register */
+#define CAN_ND2R		0x124	/* New Data Register */
+
+#define CAN_IP1R		0x140	/* Interrupt Pending Register */
+#define CAN_IP2R		0x144	/* Interrupt Pending Register */
+
+#define CAN_MV1R		0x160	/* Message Valid Register */
+#define CAN_MV2R		0x164	/* Message Valid Register */
+
+#define CAN_IF1_CRR		0x20	/* Command Request Register */
+#define CAN_IF2_CRR		0x80	/* Command Request Register */
+#define CAN_IF_CRR_BUSY		0x8000  /* Busy Flag */
+#define CAN_IF_CRR_MSG		0x3F	/* Message Number */
+
+#define CAN_IF1_CMR		0x24	/* Command Mask Register */
+#define CAN_IF2_CMR		0x84	/* Command Mask Register */
+#define CAN_IF_CMR_WR		0x80	/* Write/Read to/from Message Object */
+#define CAN_IF_CMR_MSK		0x40	/* Transfer Mask Bits */
+#define CAN_IF_CMR_AR		0x20	/* Transfer Arbitration Bits */
+#define CAN_IF_CMR_CTL		0x10	/* Transfer Control Bits */
+#define CAN_IF_CMR_CPI		0x08	/* Clear Interrupt Pending Bit */
+#define CAN_IF_CMR_TXR		0x04	/* Clear TxRqst/NewDat Bit */
+#define CAN_IF_CMR_CND		0x04	/* Clear TxRqst/NewDat Bit */
+#define CAN_IF_CMR_D30		0x02	/* Transfer Data Bytes 3:0 */
+#define CAN_IF_CMR_C74		0x01	/* Transfer Data Bytes 7:4 */
+
+#define CAN_IF1_M1R		0x28	/* Mask Register */
+#define CAN_IF2_M1R		0x88	/* Mask Register */
+
+#define CAN_IF1_M2R		0x2C	/* Mask Register */
+#define CAN_IF2_M2R		0x8C	/* Mask Register */
+#define CAN_IF_M2R_MXTD		0x8000
+#define CAN_IF_M2R_MDIR		0x4000
+
+#define CAN_IF1_A1R		0x30	/* Message Arbitration Register */
+#define CAN_IF2_A1R		0x90	/* Message Arbitration Register */
+
+#define CAN_IF1_A2R		0x34	/* Message Arbitration Register */
+#define CAN_IF2_A2R		0x94	/* Message Arbitration Register */
+#define CAN_IF_A2R_MSGVAL	0x8000
+#define CAN_IF_A2R_XTD		0x4000
+#define CAN_IF_A2R_DIR		0x2000
+
+#define CAN_IF1_MCR		0x38	/* Message Control Register */
+#define CAN_IF2_MCR		0x98	/* Message Control Register */
+#define CAN_IF_MCR_NEWD		0x8000
+#define CAN_IF_MCR_MSGL		0x4000
+#define CAN_IF_MCR_INTP		0x2000
+#define CAN_IF_MCR_UMSK		0x1000
+#define CAN_IF_MCR_TXIE		0x800
+#define CAN_IF_MCR_RXIE		0x400
+#define CAN_IF_MCR_RMT		0x200
+#define CAN_IF_MCR_TXR		0x100
+#define CAN_IF_MCR_EOB		0x80
+
+#define CAN_IF1_DATA1		0x3C	/* Buffer Register */
+#define CAN_IF1_DATA2		0x40	/* Buffer Register */
+#define CAN_IF1_DATB1		0x44	/* Buffer Register */
+#define CAN_IF1_DATB2		0x48	/* Buffer Register */
+#define CAN_IF1_DATAV {CAN_IF1_DATA1, CAN_IF1_DATA2, \
+			CAN_IF1_DATB1, CAN_IF1_DATB2}
+
+#define CAN_IF2_DATA1		0x9C	/* Buffer Register */
+#define CAN_IF2_DATA2		0xA0	/* Buffer Register */
+#define CAN_IF2_DATB1		0xA4	/* Buffer Register */
+#define CAN_IF2_DATB2		0xA8	/* Buffer Register */
+#define CAN_IF2_DATAV {CAN_IF2_DATA1, CAN_IF2_DATA2, \
+			CAN_IF2_DATB1, CAN_IF2_DATB2}
+
+#define STA2X11_ECHO_SKB_MAX	1
+
+#define MSGOBJ_FIRST		0x01
+#define MSGOBJ_LAST		0x20
+
+/* max. number of interrupts handled in ISR */
+#define STA2X11_MAX_IRQ		20
+
+/*
+ * STA2X11 private data structure
+ */
+struct sta2x11_priv {
+	struct can_priv can;	/* must be the first member */
+	int open_time;
+	struct net_device *dev;
+	void __iomem *reg_base;	/* ioremap'ed address to registers */
+	struct dentry *dentry;
+	struct timer_list txtimer;
+};
+
+#define STA2X11_APB_FREQ 104000000
+
+/*
+ * 32 messages are available, but only 2 messages are used.
+ * TX and RX message objects
+ */
+#define STA2X11_OBJ_TX 1
+#define STA2X11_OBJ_RX 2
+
+static struct can_bittiming_const sta2x11_can_bittiming_const = {
+	.name = KBUILD_MODNAME,
+	.tseg1_min = 2,
+	.tseg1_max = 16,
+	.tseg2_min = 1,
+	.tseg2_max = 8,
+	.sjw_max = 4,
+	.brp_min = 1,
+	.brp_max = 1024,
+	.brp_inc = 1,
+};
+
+static void sta2x11_can_write_reg(struct sta2x11_priv *priv, uint32_t val, int reg)
+{
+	writel(val, priv->reg_base + reg);
+}
+
+static uint32_t sta2x11_can_read_reg(struct sta2x11_priv *priv, int reg)
+{
+	return readl(priv->reg_base + reg);
+}
+
+static void sta2x11_can_clear_interrupts(struct sta2x11_priv *priv)
+{
+	uint32_t mo;
+
+	sta2x11_can_write_reg(priv, CAN_IF_CMR_CPI, CAN_IF1_CMR);
+	for (mo = MSGOBJ_FIRST; mo <= MSGOBJ_LAST; mo++)
+		sta2x11_can_write_reg(priv, mo, CAN_IF1_CRR);
+}
+
+static void sta2x11_can_enable_objs(const struct net_device *dev)
+{
+	struct sta2x11_priv *priv = netdev_priv(dev);
+
+	/* RX message object */
+	/* command mask */
+	sta2x11_can_write_reg(priv, CAN_IF_CMR_WR | CAN_IF_CMR_AR |
+				    CAN_IF_CMR_MSK | CAN_IF_CMR_CTL,
+				    CAN_IF1_CMR);
+	/* mask */
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF1_M1R);
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF1_M2R);
+	/* arb */
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF1_A1R);
+	sta2x11_can_write_reg(priv, CAN_IF_A2R_MSGVAL, CAN_IF1_A2R);
+	/* control */
+	sta2x11_can_write_reg(priv, CAN_IF_MCR_RXIE | CAN_IF_MCR_UMSK |
+				    CAN_IF_MCR_EOB, CAN_IF1_MCR);
+
+	sta2x11_can_write_reg(priv, STA2X11_OBJ_RX, CAN_IF1_CRR);
+
+	/* TX message object */
+	/* command mask */
+	sta2x11_can_write_reg(priv, CAN_IF_CMR_WR | CAN_IF_CMR_AR |
+				    CAN_IF_CMR_CTL, CAN_IF1_CMR);
+	/* arb */
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF1_A1R);
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF1_A2R);
+	/* control */
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF1_MCR);
+	/* Write to RAM */
+	sta2x11_can_write_reg(priv, STA2X11_OBJ_TX, CAN_IF1_CRR);
+}
+
+static void sta2x11_can_disable_objs(struct sta2x11_priv *priv)
+{
+	/* RX message object */
+	/* command mask */
+	sta2x11_can_write_reg(priv, CAN_IF_CMR_WR | CAN_IF_CMR_AR |
+				    CAN_IF_CMR_CTL, CAN_IF1_CMR);
+	/* arb */
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF1_A1R);
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF1_A2R);
+	/* control */
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF1_MCR);
+	/* command */
+	sta2x11_can_write_reg(priv, STA2X11_OBJ_RX, CAN_IF1_CRR);
+
+	/* TX message object */
+	/* command mask */
+	sta2x11_can_write_reg(priv, CAN_IF_CMR_WR | CAN_IF_CMR_AR |
+				    CAN_IF_CMR_CTL, CAN_IF1_CMR);
+	/* arb */
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF1_A1R);
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF1_A2R);
+	/* control */
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF1_MCR);
+	/* command */
+	sta2x11_can_write_reg(priv, STA2X11_OBJ_TX, CAN_IF1_CRR);
+}
+
+static void sta2x11_can_reset_mode(struct net_device *dev)
+{
+	struct sta2x11_priv *priv = netdev_priv(dev);
+
+	if (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT) {
+		/* cancel timer handling tx request poll */
+		del_timer_sync(&priv->txtimer);
+	}
+
+	/* enable configuration and puts chip in bus-off, disable interrupts */
+	sta2x11_can_write_reg(priv, CAN_CR_CCE | CAN_CR_INI, CAN_CR);
+
+	priv->can.state = CAN_STATE_STOPPED;
+
+	sta2x11_can_clear_interrupts(priv);
+
+	/* clear status interrupt */
+	sta2x11_can_read_reg(priv, CAN_SR);
+	/* clear status register */
+	sta2x11_can_write_reg(priv, 0x0, CAN_SR);
+
+	/* disable all used message objects */
+	sta2x11_can_disable_objs(priv);
+}
+
+static void sta2x11_can_normal_mode(struct net_device *dev)
+{
+	struct sta2x11_priv *priv = netdev_priv(dev);
+	uint32_t ctrl;
+
+	sta2x11_can_clear_interrupts(priv);
+
+	/* clear status interrupt */
+	sta2x11_can_read_reg(priv, CAN_SR);
+	/* clear status register */
+	sta2x11_can_write_reg(priv, CAN_SR_LEC, CAN_SR);
+
+	/* enable all used message objects */
+	sta2x11_can_enable_objs(dev);
+
+	/* clear bus-off */
+	ctrl = CAN_CR_IE | CAN_CR_EIE;
+	if (priv->can.ctrlmode & CAN_CTRLMODE_BERR_REPORTING)
+		ctrl |= CAN_CR_SIE;
+
+	if (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT)
+		ctrl |= CAN_CR_DAR;
+
+	sta2x11_can_write_reg(priv, ctrl, CAN_CR);
+
+	priv->can.state = CAN_STATE_ERROR_ACTIVE;
+}
+
+static void sta2x11_can_chipset_init(struct net_device *dev)
+{
+	struct sta2x11_priv *priv = netdev_priv(dev);
+	struct pci_dev *pdev = to_pci_dev(dev->dev.parent);
+	int data_reg[] = CAN_IF1_DATAV;
+	uint32_t mo;
+	unsigned int i;
+
+
+	/* config clock and release device from reset */
+	sta2x11_apbreg_mask(pdev, APBREG_PCG, APBREG_CAN, 0);
+	sta2x11_apbreg_mask(pdev, APBREG_PUR, APBREG_CAN, 0);
+	msleep_interruptible(100);
+	sta2x11_apbreg_mask(pdev, APBREG_PCG, APBREG_CAN, APBREG_CAN);
+	sta2x11_apbreg_mask(pdev, APBREG_PUR, APBREG_CAN, APBREG_CAN);
+	msleep_interruptible(100);
+
+	/* enable configuration and put chip in bus-off, disable interrupts */
+	sta2x11_can_write_reg(priv, CAN_CR_CCE | CAN_CR_INI, CAN_CR);
+
+	/* clear status interrupt */
+	sta2x11_can_read_reg(priv, CAN_SR);
+	/* clear status register */
+	sta2x11_can_write_reg(priv, CAN_SR_LEC, CAN_SR);
+
+	sta2x11_can_clear_interrupts(priv);
+
+	/* Invalidate message objects */
+	/* command mask */
+	sta2x11_can_write_reg(priv, CAN_IF_CMR_WR | CAN_IF_CMR_MSK |
+				    CAN_IF_CMR_AR | CAN_IF_CMR_CTL |
+				    CAN_IF_CMR_D30 | CAN_IF_CMR_C74,
+				    CAN_IF1_CMR);
+	/* mask */
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF1_M1R);
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF1_M2R);
+	/* arb */
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF1_A1R);
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF1_A2R);
+	/* control */
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF1_MCR);
+	/* data */
+	for (i = 0; i < 4; i++)
+		sta2x11_can_write_reg(priv, 0x0, data_reg[i]);
+
+	/* send command to all 32 messages */
+	for (mo = MSGOBJ_FIRST; mo <= MSGOBJ_LAST; mo++)
+		sta2x11_can_write_reg(priv, mo, CAN_IF1_CRR);
+}
+
+static void sta2x11_can_start(struct net_device *dev)
+{
+	struct sta2x11_priv *priv = netdev_priv(dev);
+
+	if (priv->can.state != CAN_STATE_STOPPED)
+		sta2x11_can_reset_mode(dev);
+
+	sta2x11_can_normal_mode(dev);
+}
+
+static void sta2x11_can_write_data(struct sta2x11_priv *priv,
+			       struct can_frame *cf, u8 dlc)
+{
+	int data_reg[] = CAN_IF1_DATAV;
+	uint32_t val = 0;
+	int i;
+
+	for (i = 0; i < dlc; i++) {
+		if (i & 0x1) {
+			val |= cf->data[i] << 8;
+			sta2x11_can_write_reg(priv, val, data_reg[i / 2]);
+		} else {
+			val = cf->data[i];
+		}
+	}
+	/* if dlc is an even number the last byte must be write */
+	if (i & 0x1)
+		sta2x11_can_write_reg(priv, val, data_reg[i / 2]);
+
+}
+
+static void sta2x11_can_ar_config(struct sta2x11_priv *priv, uint32_t id,
+				  uint32_t dir)
+{
+	/* Arbitration configuration */
+	if (id & CAN_EFF_FLAG) { /* extended identifier */
+		id &= CAN_EFF_MASK;
+		sta2x11_can_write_reg(priv, id & 0xFFFF, CAN_IF1_A1R);
+		sta2x11_can_write_reg(priv, CAN_IF_A2R_MSGVAL | CAN_IF_A2R_XTD |
+					    dir | (id >> 16), CAN_IF1_A2R);
+	} else { /* standard identifier */
+		id &= CAN_SFF_MASK;
+		sta2x11_can_write_reg(priv, 0X0, CAN_IF1_A1R);
+		sta2x11_can_write_reg(priv, CAN_IF_A2R_MSGVAL | dir | (id << 2),
+					    CAN_IF1_A2R);
+	}
+}
+
+static int sta2x11_can_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct sta2x11_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	struct can_frame *cf = (struct can_frame *)skb->data;
+	uint32_t dlc, id, dir = 0, cmr, ctrl;
+
+	if (can_dropped_invalid_skb(dev, skb))
+		return NETDEV_TX_OK;
+
+	if ((sta2x11_can_read_reg(priv, CAN_TXR1R) & STA2X11_OBJ_TX)) {
+		dev_err(dev->dev.parent, "TX register is still occupied!\n");
+		return NETDEV_TX_BUSY;
+	}
+
+	/* It doesn't accept new message during transmission */
+	netif_stop_queue(dev);
+
+	dlc = cf->can_dlc & 0x0f;
+	id = cf->can_id;
+
+	/* Message Control Register configuration */
+	cmr = CAN_IF_CMR_WR | CAN_IF_CMR_AR | CAN_IF_CMR_CTL;
+	if (!(id & CAN_RTR_FLAG)) {
+		/* transmission */
+		dir = CAN_IF_A2R_DIR;
+		cmr |= CAN_IF_CMR_D30 | CAN_IF_CMR_C74;
+	}
+	sta2x11_can_write_reg(priv, cmr, CAN_IF1_CMR);
+
+	sta2x11_can_ar_config(priv, id, dir);
+
+	/* control */
+	ctrl = CAN_IF_MCR_TXR | CAN_IF_MCR_EOB;
+
+	if (dir) {
+		/* control */
+		ctrl |= dlc;
+		/* Write data to IF1 data registers */
+		sta2x11_can_write_data(priv, cf, dlc);
+	}
+
+	if (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT)
+		/* use polling in one-shot mode */
+		ctrl |= CAN_IF_MCR_NEWD;
+	else
+		ctrl |= CAN_IF_MCR_TXIE;
+
+	sta2x11_can_write_reg(priv, ctrl, CAN_IF1_MCR);
+
+	/* start data transfer to RAM by writing on CRR the destination */
+	sta2x11_can_write_reg(priv, STA2X11_OBJ_TX, CAN_IF1_CRR);
+
+	stats->tx_bytes += dlc;
+	dev->trans_start = jiffies;
+
+	can_put_echo_skb(skb, dev, 0);
+
+	if (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT) {
+		/*
+		 * when automatic re-transmission mode is disabled the txRqst
+		 * bit of the respective message buffer is not set,
+		 * we don't know if the transmission started or not ...
+		 */
+		mod_timer(&priv->txtimer, jiffies + HZ / 100);
+	}
+	return NETDEV_TX_OK;
+}
+
+static int sta2x11_can_err(struct net_device *dev, uint32_t status)
+{
+	struct sta2x11_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	struct can_frame *pcf;
+	struct sk_buff *skb;
+	uint32_t err, rec, tec, lec;
+	uint32_t can_data[4] = {0};
+	canid_t can_id = 0;
+	int i;
+
+	dev_dbg(dev->dev.parent, "status interrupt (0x%04x)\n", status);
+
+	if (status & CAN_SR_BOFF) {
+		if (priv->can.state != CAN_STATE_BUS_OFF) {
+			dev_dbg(dev->dev.parent, "entering busoff state\n");
+			/* disable interrupts */
+			sta2x11_can_write_reg(priv, CAN_CR_INI, CAN_CR);
+			can_id |= CAN_ERR_BUSOFF;
+			priv->can.state = CAN_STATE_BUS_OFF;
+			can_bus_off(dev);
+		}
+	} else if (status & CAN_SR_EPAS) {
+		if (priv->can.state != CAN_STATE_ERROR_PASSIVE) {
+			dev_dbg(dev->dev.parent,
+				"entering error passive state\n");
+			can_id |= CAN_ERR_CRTL;
+
+			err = sta2x11_can_read_reg(priv, CAN_ERR);
+			tec = (err & CAN_ERR_TEC);
+			rec = (err & CAN_ERR_REC) >> 8;
+
+			if (tec > rec)
+				can_data[1] |= CAN_ERR_CRTL_TX_PASSIVE;
+			else
+				can_data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
+
+			priv->can.state = CAN_STATE_ERROR_PASSIVE;
+			priv->can.can_stats.error_passive++;
+		}
+	} else if (status & CAN_SR_WARN) {
+		if (priv->can.state != CAN_STATE_ERROR_WARNING) {
+			dev_dbg(dev->dev.parent,
+				"entering error warning state\n");
+			can_id |= CAN_ERR_CRTL;
+
+			err = sta2x11_can_read_reg(priv, CAN_ERR);
+			tec = (err & CAN_ERR_TEC);
+			rec = (err & CAN_ERR_REC) >> 8;
+
+			if (tec > rec)
+				can_data[1] |= CAN_ERR_CRTL_TX_WARNING;
+			else
+				can_data[1] |= CAN_ERR_CRTL_RX_WARNING;
+
+			priv->can.state = CAN_STATE_ERROR_WARNING;
+			priv->can.can_stats.error_warning++;
+		}
+	} else if (priv->can.state != CAN_STATE_ERROR_ACTIVE) {
+		dev_dbg(dev->dev.parent, "entering error active state\n");
+		priv->can.state = CAN_STATE_ERROR_ACTIVE;
+	}
+
+	lec = status & CAN_SR_LEC;
+
+	if (lec && (lec != CAN_SR_LEC)) {
+		if (lec == CAN_SR_LEC_ACK) {
+			dev_dbg(dev->dev.parent, "ack error\n");
+			can_id |= CAN_ERR_ACK;
+			stats->tx_errors++;
+		} else {
+			priv->can.can_stats.bus_error++;
+			stats->rx_errors++;
+
+			can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
+			switch (lec) {
+			case CAN_SR_LEC_STUFF:
+				dev_dbg(dev->dev.parent, "stuff error\n");
+				can_data[2] |= CAN_ERR_PROT_STUFF;
+				break;
+			case CAN_SR_LEC_FORM:
+				dev_dbg(dev->dev.parent, "form error\n");
+				can_data[2] |= CAN_ERR_PROT_FORM;
+				break;
+			case CAN_SR_LEC_BIT1:
+				dev_dbg(dev->dev.parent, "bit1 error\n");
+				can_data[2] |= CAN_ERR_PROT_BIT1;
+				break;
+			case CAN_SR_LEC_BIT0:
+				dev_dbg(dev->dev.parent, "bit0 error\n");
+				can_data[2] |= CAN_ERR_PROT_BIT0;
+				break;
+			case CAN_SR_LEC_CRC:
+				dev_dbg(dev->dev.parent, "crc error\n");
+				can_data[3] |= CAN_ERR_PROT_LOC_CRC_SEQ;
+				break;
+			}
+		}
+	}
+
+	if (can_id) {
+		skb = alloc_can_err_skb(dev, &pcf);
+		if (unlikely(!skb))
+			return -ENOMEM;
+		pcf->can_id |= can_id;
+		for (i = 0; i < 4; i++)
+			pcf->data[i] = can_data[i];
+		netif_rx(skb);
+
+		stats->rx_packets++;
+		stats->rx_bytes += pcf->can_dlc;
+	}
+	return 0;
+}
+
+static int sta2x11_can_status_interrupt(struct net_device *dev)
+{
+	struct sta2x11_priv *priv = netdev_priv(dev);
+	uint32_t status;
+
+	/* get status */
+	status = sta2x11_can_read_reg(priv, CAN_SR);
+	/* reset the status register including RXOK and TXOK */
+	sta2x11_can_write_reg(priv, CAN_SR_LEC, CAN_SR);
+
+	return sta2x11_can_err(dev, status);
+}
+
+/*
+ * Reading data from the Interface Register 2
+ */
+static void sta2x11_can_read_data(struct sta2x11_priv *priv,
+			      struct can_frame *cf, u8 dlc)
+{
+	int data_reg[] = CAN_IF2_DATAV;
+	uint32_t val = 0;
+	int i;
+
+	for (i = 0; i < dlc; i++) {
+		if (i & 0x1) {
+			cf->data[i] = val >> 8;
+		} else {
+			val = sta2x11_can_read_reg(priv, data_reg[i / 2]);
+			cf->data[i] = val & 0xFF;
+		}
+	}
+}
+
+static void sta2x11_can_rx(struct net_device *dev, unsigned int mo, uint32_t ctrl)
+{
+	struct sta2x11_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	struct can_frame *cf;
+	struct sk_buff *skb;
+	uint32_t arb1, arb2;
+
+	skb = alloc_can_skb(dev, &cf);
+	if (skb == NULL)
+		return;
+
+	/* Read Arbitration 2 Register */
+	arb2 = sta2x11_can_read_reg(priv, CAN_IF2_A2R);
+	if (arb2 & CAN_IF_A2R_XTD) {
+		/* Massage has an extended identifier */
+		arb1 = sta2x11_can_read_reg(priv, CAN_IF2_A1R);
+		cf->can_id = (((arb2 & 0x1FFF) << 16) | arb1 | CAN_EFF_FLAG);
+	} else {
+		/* Massage hasn't an extended identifier */
+		cf->can_id = ((arb2 & 0x1FFF) >> 2);
+	}
+
+	if (arb2 & CAN_IF_A2R_DIR) {
+		cf->can_id |= CAN_RTR_FLAG;
+		cf->can_dlc = 0;
+	} else {
+		cf->can_dlc = get_can_dlc(ctrl & 0xF);
+		sta2x11_can_read_data(priv, cf, cf->can_dlc);
+	}
+
+	netif_rx(skb);
+
+	stats->rx_packets++;
+	stats->rx_bytes += cf->can_dlc;
+}
+
+static void sta2x11_can_rx_interrupt(struct net_device *dev, unsigned int mo)
+{
+	struct sta2x11_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	struct can_frame *pcf;
+	struct sk_buff *skb;
+	uint32_t ctrl;
+
+	/* clear interrupt, read control, data, arbitration */
+	sta2x11_can_write_reg(priv, CAN_IF_CMR_CPI | CAN_IF_CMR_CND |
+				    CAN_IF_CMR_AR | CAN_IF_CMR_CTL |
+				    CAN_IF_CMR_D30 | CAN_IF_CMR_C74,
+				    CAN_IF2_CMR);
+	sta2x11_can_write_reg(priv, mo, CAN_IF2_CRR);
+
+	ctrl = sta2x11_can_read_reg(priv, CAN_IF2_MCR);
+
+	if (ctrl & CAN_IF_MCR_MSGL) {
+		dev_dbg(dev->dev.parent, "rx overrun error\n");
+		stats->rx_over_errors++;
+		stats->rx_errors++;
+		skb = alloc_can_err_skb(dev, &pcf);
+		if (likely(skb)) {
+			pcf->can_id |= CAN_ERR_CRTL;
+			pcf->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
+			netif_rx(skb);
+
+			stats->rx_packets++;
+			stats->rx_bytes += pcf->can_dlc;
+		}
+	}
+
+	sta2x11_can_rx(dev, mo, ctrl);
+
+	/* reset message object */
+	sta2x11_can_write_reg(priv, CAN_IF_CMR_WR | CAN_IF_CMR_AR |
+				    CAN_IF_CMR_CTL, CAN_IF2_CMR);
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF2_M1R);
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF2_M2R);
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF2_A1R);
+	sta2x11_can_write_reg(priv, CAN_IF_A2R_MSGVAL, CAN_IF2_A2R);
+	sta2x11_can_write_reg(priv, CAN_IF_MCR_RXIE | CAN_IF_MCR_UMSK |
+				    CAN_IF_MCR_EOB, CAN_IF2_MCR);
+	sta2x11_can_write_reg(priv, mo, CAN_IF2_CRR);
+}
+
+static void sta2x11_can_tx_interrupt(struct net_device *dev, unsigned int mo)
+{
+	struct sta2x11_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+
+	/* clear interrupt */
+	sta2x11_can_write_reg(priv, CAN_IF_CMR_CPI | CAN_IF_CMR_CTL,
+				    CAN_IF2_CMR);
+	sta2x11_can_write_reg(priv, mo, CAN_IF2_CRR);
+
+	/* invalidate */
+	sta2x11_can_write_reg(priv, CAN_IF_CMR_WR | CAN_IF_CMR_AR,
+				    CAN_IF2_CMR);
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF2_A2R);
+	sta2x11_can_write_reg(priv, mo, CAN_IF2_CRR);
+
+	stats->tx_packets++;
+	can_get_echo_skb(dev, 0);
+	netif_wake_queue(dev);
+}
+
+static irqreturn_t sta2x11_can_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = (struct net_device *)dev_id;
+	struct sta2x11_priv *priv = netdev_priv(dev);
+	uint32_t intid;
+	int n = 0;
+
+	/* shared interrupts and IRQ off? */
+	if (priv->can.state == CAN_STATE_STOPPED)
+		return IRQ_NONE;
+
+	while (n < STA2X11_MAX_IRQ) {
+
+		/* read the highest pending interrupt request */
+		intid = sta2x11_can_read_reg(priv, CAN_IDR);
+		if (!intid)
+			break;
+
+		switch (intid) {
+		case CAN_IDR_STATUS:
+			sta2x11_can_status_interrupt(dev);
+			break;
+		case STA2X11_OBJ_RX:
+			sta2x11_can_rx_interrupt(dev, intid);
+			break;
+		case STA2X11_OBJ_TX:
+			sta2x11_can_tx_interrupt(dev, intid);
+			break;
+		default:
+			dev_err(dev->dev.parent, "Unexpected interrupt %i",
+				intid);
+			sta2x11_can_clear_interrupts(priv);
+			break;
+		}
+
+		n++;
+	}
+
+	return n ? IRQ_HANDLED : IRQ_NONE;
+}
+
+static int sta2x11_can_open(struct net_device *dev)
+{
+	struct sta2x11_priv *priv = netdev_priv(dev);
+	int err;
+
+	sta2x11_can_reset_mode(dev);
+
+	err = open_candev(dev);
+	if (err)
+		return err;
+
+	err = request_irq(dev->irq, &sta2x11_can_interrupt, 0 /* FIXME */,
+			  dev->name, (void *)dev);
+	if (err) {
+		close_candev(dev);
+		return -EAGAIN;
+	}
+
+	sta2x11_can_start(dev);
+	priv->open_time = jiffies;
+	netif_start_queue(dev);
+
+	return 0;
+}
+
+static int sta2x11_can_close(struct net_device *dev)
+{
+	struct sta2x11_priv *priv = netdev_priv(dev);
+
+	netif_stop_queue(dev);
+	sta2x11_can_reset_mode(dev);
+
+	free_irq(dev->irq, (void *)dev);
+	close_candev(dev);
+
+	priv->open_time = 0;
+
+	return 0;
+}
+
+static int sta2x11_can_set_bittiming(struct net_device *dev)
+{
+	struct sta2x11_priv *priv = netdev_priv(dev);
+	struct can_bittiming *bt = &priv->can.bittiming;
+	uint32_t reg;
+
+	reg = ((bt->prop_seg + bt->phase_seg1 - 1) & 0xf) |
+	    (((bt->phase_seg2 - 1) & 0x7) << 4);
+	reg <<= 8;
+	reg |= ((bt->brp - 1) & 0x3f) | (((bt->sjw - 1) & 0x3) << 6);
+	sta2x11_can_write_reg(priv, reg, CAN_BTR);
+
+	reg = ((bt->brp - 1) >> 6) & 0xf;
+	sta2x11_can_write_reg(priv, reg, CAN_BRPR);
+
+	return 0;
+}
+
+static int sta2x11_can_set_mode(struct net_device *dev, enum can_mode mode)
+{
+	struct sta2x11_priv *priv = netdev_priv(dev);
+
+	if (!priv->open_time)
+		return -EINVAL;
+
+	switch (mode) {
+	case CAN_MODE_START:
+		sta2x11_can_start(dev);
+		if (netif_queue_stopped(dev))
+			netif_wake_queue(dev);
+		break;
+
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static struct net_device *sta2x11_can_alloc(void)
+{
+	struct net_device *dev;
+	struct sta2x11_priv *priv;
+
+	dev = alloc_candev(sizeof(struct sta2x11_priv), STA2X11_ECHO_SKB_MAX);
+	if (!dev)
+		return NULL;
+
+	priv = netdev_priv(dev);
+
+	priv->dev = dev;
+
+	/* Configuring CAN */
+	priv->can.bittiming_const = &sta2x11_can_bittiming_const;
+	priv->can.do_set_bittiming = sta2x11_can_set_bittiming;
+	priv->can.do_set_mode = sta2x11_can_set_mode;
+	priv->can.clock.freq = STA2X11_APB_FREQ / 2;
+	priv->can.ctrlmode_supported = CAN_CTRLMODE_ONE_SHOT |
+				       CAN_CTRLMODE_BERR_REPORTING;
+
+	return dev;
+}
+
+static void sta2x11_can_free(struct net_device *dev)
+{
+	free_candev(dev);
+}
+
+static const struct net_device_ops sta2x11_can_netdev_ops = {
+	.ndo_open = sta2x11_can_open,
+	.ndo_stop = sta2x11_can_close,
+	.ndo_start_xmit = sta2x11_can_start_xmit,
+};
+
+static void sta2x11_can_tx_poll(unsigned long xdev)
+{
+	struct net_device *dev = (struct net_device *)xdev;
+	struct sta2x11_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+
+	if (sta2x11_can_read_reg(priv, CAN_ND1R) & STA2X11_OBJ_TX) {
+		dev_dbg(dev->dev.parent, "one-shot tx failed\n");
+		stats->tx_errors++;
+		stats->tx_dropped++;
+		can_free_echo_skb(dev, 0);
+	} else {
+		stats->tx_packets++;
+		can_get_echo_skb(dev, 0);
+	}
+
+	/* invalidate */
+	sta2x11_can_write_reg(priv, CAN_IF_CMR_WR | CAN_IF_CMR_AR,
+				    CAN_IF1_CMR);
+	sta2x11_can_write_reg(priv, 0x0, CAN_IF1_A2R);
+	sta2x11_can_write_reg(priv, STA2X11_OBJ_TX, CAN_IF1_CRR);
+
+	netif_wake_queue(dev);
+}
+
+static int sta2x11_can_register(struct net_device *dev)
+{
+	struct sta2x11_priv *priv = netdev_priv(dev);
+
+	/* local echo */
+	dev->flags |= IFF_ECHO;
+	dev->netdev_ops = &sta2x11_can_netdev_ops;
+
+	/* init timer handling tx request poll for one-shot mode */
+	init_timer(&priv->txtimer);
+	priv->txtimer.data = (unsigned long)dev;
+	priv->txtimer.function = sta2x11_can_tx_poll;
+
+	sta2x11_can_chipset_init(dev);
+	sta2x11_can_reset_mode(dev);
+
+	return register_candev(dev);
+}
+
+static void sta2x11_can_unregister(struct net_device *dev)
+{
+	sta2x11_can_reset_mode(dev);
+	unregister_candev(dev);
+}
+
+DEFINE_PCI_DEVICE_TABLE(sta2x11_can_pci_tbl) = {
+	{
+		PCI_DEVICE(PCI_VENDOR_ID_STMICRO, PCI_DEVICE_ID_STMICRO_CAN),
+		.driver_data = 0,
+	},
+	{},
+};
+
+/*
+ * Static definition of debugfs 32bit registers, on sta2x11 there is only
+ * one CAN bus
+ */
+#define REG(regname) {.name = #regname, .offset = regname}
+static struct debugfs_reg32 sta2x11_can_regs[] = {
+	REG(CAN_CR), REG(CAN_SR), REG(CAN_ERR), REG(CAN_BTR),
+	REG(CAN_BRPR), REG(CAN_IDR), REG(CAN_TXR1R), REG(CAN_TXR2R),
+	REG(CAN_ND1R), REG(CAN_ND2R), REG(CAN_IP1R), REG(CAN_IP2R),
+	REG(CAN_MV1R), REG(CAN_MV2R),
+};
+#undef REG
+static struct debugfs_regset32 sta2x11_can_regset = {
+	.regs = sta2x11_can_regs,
+	.nregs = ARRAY_SIZE(sta2x11_can_regs),
+};
+
+static int __devinit
+sta2x11_can_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+{
+	struct net_device *dev;
+	struct sta2x11_priv *priv;
+	int rc = 0;
+
+	rc = pci_enable_device(pdev);
+	if (rc) {
+		dev_err(&pdev->dev, "pci_enable_device FAILED\n");
+		goto out;
+	}
+
+	rc = pci_request_regions(pdev, KBUILD_MODNAME);
+	if (rc) {
+		dev_err(&pdev->dev, "pci_request_regions FAILED\n");
+		goto out_disable_device;
+	}
+
+	pci_set_master(pdev);
+	pci_enable_msi(pdev);
+
+	dev = sta2x11_can_alloc();
+	if (!dev) {
+		rc = -ENOMEM;
+		goto out_release_regions;
+	}
+
+	dev->irq = pdev->irq;
+	priv = netdev_priv(dev);
+
+	priv->reg_base = pci_iomap(pdev, 0, pci_resource_len(pdev, 0));
+
+	if (!priv->reg_base) {
+		dev_err(&pdev->dev,
+			"device has no PCI memory resources, "
+			"failing adapter\n");
+		rc = -ENOMEM;
+		goto out_kfree_sta2x11;
+	}
+
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
+	rc = sta2x11_can_register(dev);
+	if (rc) {
+		dev_err(&pdev->dev, "registering %s failed (err=%d)\n",
+			KBUILD_MODNAME, rc);
+		goto out_iounmap;
+	}
+
+	pci_set_drvdata(pdev, dev);
+
+	/* Configure debugfs */
+	sta2x11_can_regset.base = priv->reg_base;
+	priv->dentry = debugfs_create_regset32("sta2x11_can", S_IFREG | S_IRUGO,
+			NULL, &sta2x11_can_regset);
+
+	return 0;
+
+out_iounmap:
+	pci_iounmap(pdev, priv->reg_base);
+out_kfree_sta2x11:
+	sta2x11_can_free(dev);
+out_release_regions:
+	pci_disable_msi(pdev);
+	pci_release_regions(pdev);
+out_disable_device:
+	/*
+	 * do not call pci_disable_device on sta2x11 because it
+	 * break all other Bus masters on this EP
+	 */
+out:
+	return rc;
+}
+
+static void __devexit sta2x11_can_pci_remove(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct sta2x11_priv *priv = netdev_priv(dev);
+
+
+	if (priv->dentry)
+		debugfs_remove(priv->dentry);
+
+	pci_set_drvdata(pdev, NULL);
+
+	sta2x11_can_unregister(dev);
+	pci_iounmap(pdev, priv->reg_base);
+	sta2x11_can_free(dev);
+
+	pci_disable_msi(pdev);
+	pci_release_regions(pdev);
+	/*
+	 * do not call pci_disable_device on sta2x11 because it
+	 * break all other Bus masters on this EP
+	 */
+}
+
+static struct pci_driver sta2x11_pci_driver = {
+	.name = KBUILD_MODNAME,
+	.id_table = sta2x11_can_pci_tbl,
+	.probe = sta2x11_can_pci_probe,
+	.remove = __devexit_p(sta2x11_can_pci_remove),
+};
+
+static __init int sta2x11_can_init(void)
+{
+	return pci_register_driver(&sta2x11_pci_driver);
+}
+
+/* needs to be started after the sta2x11_apbreg driver */
+late_initcall(sta2x11_can_init);
+
+static __exit void sta2x11_can_exit(void)
+{
+	pci_unregister_driver(&sta2x11_pci_driver);
+}
+
+module_exit(sta2x11_can_exit);
+
+MODULE_AUTHOR("Wind River");
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_DESCRIPTION(KBUILD_MODNAME "CAN netdevice driver");
+MODULE_DEVICE_TABLE(pci, sta2x11_pci_tbl);
-- 
1.7.7.6

