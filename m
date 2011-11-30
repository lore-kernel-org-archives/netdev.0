From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: [PATCH net-next v5 1/4] can: cc770: add driver
	core for the Bosch CC770 and Intel AN82527
Date: Wed, 30 Nov 2011 13:10:32 +0100
Message-ID: <1322655035-18809-2-git-send-email-wg@grandegger.com>
References: <1322655035-18809-1-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1322655035-18809-1-git-send-email-wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-users>
List-Post: <mailto:socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/Kconfig            |    2 +
 drivers/net/can/Makefile           |    1 +
 drivers/net/can/cc770/Kconfig      |    3 +
 drivers/net/can/cc770/Makefile     |    7 +
 drivers/net/can/cc770/cc770.c      |  881 ++++++++++++++++++++++++++++++++++++
 drivers/net/can/cc770/cc770.h      |  203 +++++++++
 include/linux/can/platform/cc770.h |   33 ++
 7 files changed, 1130 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/can/cc770/Kconfig
 create mode 100644 drivers/net/can/cc770/Makefile
 create mode 100644 drivers/net/can/cc770/cc770.c
 create mode 100644 drivers/net/can/cc770/cc770.h
 create mode 100644 include/linux/can/platform/cc770.h

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index f6c98fb..ab45758 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -116,6 +116,8 @@ source "drivers/net/can/sja1000/Kconfig"
 
 source "drivers/net/can/c_can/Kconfig"
 
+source "drivers/net/can/cc770/Kconfig"
+
 source "drivers/net/can/usb/Kconfig"
 
 source "drivers/net/can/softing/Kconfig"
diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
index 24ebfe8..938be37 100644
--- a/drivers/net/can/Makefile
+++ b/drivers/net/can/Makefile
@@ -14,6 +14,7 @@ obj-y				+= softing/
 obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
 obj-$(CONFIG_CAN_MSCAN)		+= mscan/
 obj-$(CONFIG_CAN_C_CAN)		+= c_can/
+obj-$(CONFIG_CAN_CC770)		+= cc770/
 obj-$(CONFIG_CAN_AT91)		+= at91_can.o
 obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
 obj-$(CONFIG_CAN_MCP251X)	+= mcp251x.o
diff --git a/drivers/net/can/cc770/Kconfig b/drivers/net/can/cc770/Kconfig
new file mode 100644
index 0000000..225131b
--- /dev/null
+++ b/drivers/net/can/cc770/Kconfig
@@ -0,0 +1,3 @@
+menuconfig CAN_CC770
+	tristate "Bosch CC770 and Intel AN82527 devices"
+	depends on CAN_DEV && HAS_IOMEM
diff --git a/drivers/net/can/cc770/Makefile b/drivers/net/can/cc770/Makefile
new file mode 100644
index 0000000..34e8180
--- /dev/null
+++ b/drivers/net/can/cc770/Makefile
@@ -0,0 +1,7 @@
+#
+#  Makefile for the Bosch CC770 CAN controller drivers.
+#
+
+obj-$(CONFIG_CAN_CC770) += cc770.o
+
+ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
diff --git a/drivers/net/can/cc770/cc770.c b/drivers/net/can/cc770/cc770.c
new file mode 100644
index 0000000..7668967
--- /dev/null
+++ b/drivers/net/can/cc770/cc770.c
@@ -0,0 +1,881 @@
+/*
+ * Core driver for the CC770 and AN82527 CAN controllers
+ *
+ * Copyright (C) 2009, 2011 Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the version 2 of the GNU General Public License
+ * as published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/types.h>
+#include <linux/fcntl.h>
+#include <linux/interrupt.h>
+#include <linux/ptrace.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/if_ether.h>
+#include <linux/skbuff.h>
+#include <linux/delay.h>
+
+#include <linux/can.h>
+#include <linux/can/dev.h>
+#include <linux/can/error.h>
+#include <linux/can/dev.h>
+#include <linux/can/platform/cc770.h>
+
+#include "cc770.h"
+
+MODULE_AUTHOR("Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>");
+MODULE_LICENSE("GPL v2");
+MODULE_DESCRIPTION(KBUILD_MODNAME "CAN netdevice driver");
+
+/*
+ * The CC770 is a CAN controller from Bosch, which is 100% compatible
+ * with the AN82527 from Intel, but with "bugs" being fixed and some
+ * additional functionality, mainly:
+ *
+ * 1. RX and TX error counters are readable.
+ * 2. Support of silent (listen-only) mode.
+ * 3. Message object 15 can receive all types of frames, also RTR and EFF.
+ *
+ * Details are available from Bosch's "CC770_Product_Info_2007-01.pdf",
+ * which explains in detail the compatibility between the CC770 and the
+ * 82527. This driver use the additional functionality 3. on real CC770
+ * devices. Unfortunately, the CC770 does still not store the message
+ * identifier of received remote transmission request frames and
+ * therefore it's set to 0.
+ *
+ * The message objects 1..14 can be used for TX and RX while the message
+ * objects 15 is optimized for RX. It has a shadow register for reliable
+ * data receiption under heavy bus load. Therefore it makes sense to use
+ * this message object for the needed use case. The frame type (EFF/SFF)
+ * for the message object 15 can be defined via kernel module parameter
+ * "msgobj15_eff". If not equal 0, it will receive 29-bit EFF frames,
+ * otherwise 11 bit SFF messages.
+ */
+static int msgobj15_eff;
+module_param(msgobj15_eff, int, S_IRUGO);
+MODULE_PARM_DESC(msgobj15_eff, "Extended 29-bit frames for message object 15 "
+		 "(default: 11-bit standard frames)");
+
+static int i82527_compat;
+module_param(i82527_compat, int, S_IRUGO);
+MODULE_PARM_DESC(i82527_compat, "Strict Intel 82527 comptibility mode "
+		 "without using additional functions");
+
+/*
+ * This driver uses the last 5 message objects 11..15. The definitions
+ * and structure below allows to configure and assign them to the real
+ * message object.
+ */
+static unsigned char cc770_obj_flags[CC770_OBJ_MAX] = {
+	[CC770_OBJ_RX0] = CC770_OBJ_FLAG_RX,
+	[CC770_OBJ_RX1] = CC770_OBJ_FLAG_RX | CC770_OBJ_FLAG_EFF,
+	[CC770_OBJ_RX_RTR0] = CC770_OBJ_FLAG_RX | CC770_OBJ_FLAG_RTR,
+	[CC770_OBJ_RX_RTR1] = CC770_OBJ_FLAG_RX | CC770_OBJ_FLAG_RTR |
+			      CC770_OBJ_FLAG_EFF,
+	[CC770_OBJ_TX] = 0,
+};
+
+static struct can_bittiming_const cc770_bittiming_const = {
+	.name = KBUILD_MODNAME,
+	.tseg1_min = 1,
+	.tseg1_max = 16,
+	.tseg2_min = 1,
+	.tseg2_max = 8,
+	.sjw_max = 4,
+	.brp_min = 1,
+	.brp_max = 64,
+	.brp_inc = 1,
+};
+
+static inline int intid2obj(unsigned int intid)
+{
+	if (intid == 2)
+		return 0;
+	else
+		return MSGOBJ_LAST + 2 - intid;
+}
+
+static void enable_all_objs(const struct net_device *dev)
+{
+	struct cc770_priv *priv = netdev_priv(dev);
+	u8 msgcfg;
+	unsigned char obj_flags;
+	unsigned int o, mo;
+
+	for (o = 0; o < ARRAY_SIZE(priv->obj_flags); o++) {
+		obj_flags = priv->obj_flags[o];
+		mo = obj2msgobj(o);
+
+		if (obj_flags & CC770_OBJ_FLAG_RX) {
+			/*
+			 * We don't need extra objects for RTR and EFF if
+			 * the additional CC770 functions are enabled.
+			 */
+			if (priv->control_normal_mode & CTRL_EAF) {
+				if (o > 0)
+					continue;
+				netdev_dbg(dev, "Message object %d for "
+					   "RX data, RTR, SFF and EFF\n", mo);
+			} else {
+				netdev_dbg(dev,
+					   "Message object %d for RX %s %s\n",
+					   mo, obj_flags & CC770_OBJ_FLAG_RTR ?
+					   "RTR" : "data",
+					   obj_flags & CC770_OBJ_FLAG_EFF ?
+					   "EFF" : "SFF");
+			}
+
+			if (obj_flags & CC770_OBJ_FLAG_EFF)
+				msgcfg = MSGCFG_XTD;
+			else
+				msgcfg = 0;
+			if (obj_flags & CC770_OBJ_FLAG_RTR)
+				msgcfg |= MSGCFG_DIR;
+
+			cc770_write_reg(priv, msgobj[mo].config, msgcfg);
+			cc770_write_reg(priv, msgobj[mo].ctrl0,
+					MSGVAL_SET | TXIE_RES |
+					RXIE_SET | INTPND_RES);
+
+			if (obj_flags & CC770_OBJ_FLAG_RTR)
+				cc770_write_reg(priv, msgobj[mo].ctrl1,
+						NEWDAT_RES | CPUUPD_SET |
+						TXRQST_RES | RMTPND_RES);
+			else
+				cc770_write_reg(priv, msgobj[mo].ctrl1,
+						NEWDAT_RES | MSGLST_RES |
+						TXRQST_RES | RMTPND_RES);
+		} else {
+			netdev_dbg(dev, "Message object %d for "
+				   "TX data, RTR, SFF and EFF\n", mo);
+
+			cc770_write_reg(priv, msgobj[mo].ctrl1,
+					RMTPND_RES | TXRQST_RES |
+					CPUUPD_RES | NEWDAT_RES);
+			cc770_write_reg(priv, msgobj[mo].ctrl0,
+					MSGVAL_RES | TXIE_RES |
+					RXIE_RES | INTPND_RES);
+		}
+	}
+}
+
+static void disable_all_objs(const struct cc770_priv *priv)
+{
+	int o, mo;
+
+	for (o = 0; o <  ARRAY_SIZE(priv->obj_flags); o++) {
+		mo = obj2msgobj(o);
+
+		if (priv->obj_flags[o] & CC770_OBJ_FLAG_RX) {
+			if (o > 0 && priv->control_normal_mode & CTRL_EAF)
+				continue;
+
+			cc770_write_reg(priv, msgobj[mo].ctrl1,
+					NEWDAT_RES | MSGLST_RES |
+					TXRQST_RES | RMTPND_RES);
+			cc770_write_reg(priv, msgobj[mo].ctrl0,
+					MSGVAL_RES | TXIE_RES |
+					RXIE_RES | INTPND_RES);
+		} else {
+			/* Clear message object for send */
+			cc770_write_reg(priv, msgobj[mo].ctrl1,
+					RMTPND_RES | TXRQST_RES |
+					CPUUPD_RES | NEWDAT_RES);
+			cc770_write_reg(priv, msgobj[mo].ctrl0,
+					MSGVAL_RES | TXIE_RES |
+					RXIE_RES | INTPND_RES);
+		}
+	}
+}
+
+static void set_reset_mode(struct net_device *dev)
+{
+	struct cc770_priv *priv = netdev_priv(dev);
+
+	/* Enable configuration and puts chip in bus-off, disable interrupts */
+	cc770_write_reg(priv, control, CTRL_CCE | CTRL_INI);
+
+	priv->can.state = CAN_STATE_STOPPED;
+
+	/* Clear interrupts */
+	cc770_read_reg(priv, interrupt);
+
+	/* Clear status register */
+	cc770_write_reg(priv, status, 0);
+
+	/* Disable all used message objects */
+	disable_all_objs(priv);
+}
+
+static void set_normal_mode(struct net_device *dev)
+{
+	struct cc770_priv *priv = netdev_priv(dev);
+
+	/* Clear interrupts */
+	cc770_read_reg(priv, interrupt);
+
+	/* Clear status register and pre-set last error code */
+	cc770_write_reg(priv, status, STAT_LEC_MASK);
+
+	/* Enable all used message objects*/
+	enable_all_objs(dev);
+
+	/*
+	 * Clear bus-off, interrupts only for errors,
+	 * not for status change
+	 */
+	cc770_write_reg(priv, control, priv->control_normal_mode);
+
+	priv->can.state = CAN_STATE_ERROR_ACTIVE;
+}
+
+static void chipset_init(struct cc770_priv *priv)
+{
+	int mo, id, data;
+
+	/* Enable configuration and put chip in bus-off, disable interrupts */
+	cc770_write_reg(priv, control, (CTRL_CCE | CTRL_INI));
+
+	/* Set CLKOUT divider and slew rates */
+	cc770_write_reg(priv, clkout, priv->clkout);
+
+	/* Configure CPU interface / CLKOUT enable */
+	cc770_write_reg(priv, cpu_interface, priv->cpu_interface);
+
+	/* Set bus configuration  */
+	cc770_write_reg(priv, bus_config, priv->bus_config);
+
+	/* Clear interrupts */
+	cc770_read_reg(priv, interrupt);
+
+	/* Clear status register */
+	cc770_write_reg(priv, status, 0);
+
+	/* Clear and invalidate message objects */
+	for (mo = MSGOBJ_FIRST; mo <= MSGOBJ_LAST; mo++) {
+		cc770_write_reg(priv, msgobj[mo].ctrl0,
+				INTPND_UNC | RXIE_RES |
+				TXIE_RES | MSGVAL_RES);
+		cc770_write_reg(priv, msgobj[mo].ctrl0,
+				INTPND_RES | RXIE_RES |
+				TXIE_RES | MSGVAL_RES);
+		cc770_write_reg(priv, msgobj[mo].ctrl1,
+				NEWDAT_RES | MSGLST_RES |
+				TXRQST_RES | RMTPND_RES);
+		for (data = 0; data < 8; data++)
+			cc770_write_reg(priv, msgobj[mo].data[data], 0);
+		for (id = 0; id < 4; id++)
+			cc770_write_reg(priv, msgobj[mo].id[id], 0);
+		cc770_write_reg(priv, msgobj[mo].config, 0);
+	}
+
+	/* Set all global ID masks to "don't care" */
+	cc770_write_reg(priv, global_mask_std[0], 0);
+	cc770_write_reg(priv, global_mask_std[1], 0);
+	cc770_write_reg(priv, global_mask_ext[0], 0);
+	cc770_write_reg(priv, global_mask_ext[1], 0);
+	cc770_write_reg(priv, global_mask_ext[2], 0);
+	cc770_write_reg(priv, global_mask_ext[3], 0);
+
+}
+
+static int cc770_probe_chip(struct net_device *dev)
+{
+	struct cc770_priv *priv = netdev_priv(dev);
+
+	/* Enable configuration, put chip in bus-off, disable ints */
+	cc770_write_reg(priv, control, CTRL_CCE | CTRL_EAF | CTRL_INI);
+	/* Configure cpu interface / CLKOUT disable */
+	cc770_write_reg(priv, cpu_interface, priv->cpu_interface);
+
+	/*
+	 * Check if hardware reset is still inactive or maybe there
+	 * is no chip in this address space
+	 */
+	if (cc770_read_reg(priv, cpu_interface) & CPUIF_RST) {
+		netdev_info(dev, "probing @0x%p failed (reset)\n",
+			    priv->reg_base);
+		return -ENODEV;
+	}
+
+	/* Write and read back test pattern (some arbitrary values) */
+	cc770_write_reg(priv, msgobj[1].data[1], 0x25);
+	cc770_write_reg(priv, msgobj[2].data[3], 0x52);
+	cc770_write_reg(priv, msgobj[10].data[6], 0xc3);
+	if ((cc770_read_reg(priv, msgobj[1].data[1]) != 0x25) ||
+	    (cc770_read_reg(priv, msgobj[2].data[3]) != 0x52) ||
+	    (cc770_read_reg(priv, msgobj[10].data[6]) != 0xc3)) {
+		netdev_info(dev, "probing @0x%p failed (pattern)\n",
+			    priv->reg_base);
+		return -ENODEV;
+	}
+
+	/* Check if this chip is a CC770 supporting additional functions */
+	if (cc770_read_reg(priv, control) & CTRL_EAF)
+		priv->control_normal_mode |= CTRL_EAF;
+
+	return 0;
+}
+
+static void cc770_start(struct net_device *dev)
+{
+	struct cc770_priv *priv = netdev_priv(dev);
+
+	/* leave reset mode */
+	if (priv->can.state != CAN_STATE_STOPPED)
+		set_reset_mode(dev);
+
+	/* leave reset mode */
+	set_normal_mode(dev);
+}
+
+static int cc770_set_mode(struct net_device *dev, enum can_mode mode)
+{
+	switch (mode) {
+	case CAN_MODE_START:
+		cc770_start(dev);
+		netif_wake_queue(dev);
+		break;
+
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static int cc770_set_bittiming(struct net_device *dev)
+{
+	struct cc770_priv *priv = netdev_priv(dev);
+	struct can_bittiming *bt = &priv->can.bittiming;
+	u8 btr0, btr1;
+
+	btr0 = ((bt->brp - 1) & 0x3f) | (((bt->sjw - 1) & 0x3) << 6);
+	btr1 = ((bt->prop_seg + bt->phase_seg1 - 1) & 0xf) |
+		(((bt->phase_seg2 - 1) & 0x7) << 4);
+	if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES)
+		btr1 |= 0x80;
+
+	netdev_info(dev, "setting BTR0=0x%02x BTR1=0x%02x\n", btr0, btr1);
+
+	cc770_write_reg(priv, bit_timing_0, btr0);
+	cc770_write_reg(priv, bit_timing_1, btr1);
+
+	return 0;
+}
+
+static int cc770_get_berr_counter(const struct net_device *dev,
+				  struct can_berr_counter *bec)
+{
+	struct cc770_priv *priv = netdev_priv(dev);
+
+	bec->txerr = cc770_read_reg(priv, tx_error_counter);
+	bec->rxerr = cc770_read_reg(priv, rx_error_counter);
+
+	return 0;
+}
+
+static netdev_tx_t cc770_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct cc770_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	struct can_frame *cf = (struct can_frame *)skb->data;
+	unsigned int mo = obj2msgobj(CC770_OBJ_TX);
+	u8 dlc, rtr;
+	u32 id;
+	int i;
+
+	if (can_dropped_invalid_skb(dev, skb))
+		return NETDEV_TX_OK;
+
+	if ((cc770_read_reg(priv,
+			    msgobj[mo].ctrl1) & TXRQST_UNC) == TXRQST_SET) {
+		netdev_err(dev, "TX register is still occupied!\n");
+		return NETDEV_TX_BUSY;
+	}
+
+	netif_stop_queue(dev);
+
+	dlc = cf->can_dlc;
+	id = cf->can_id;
+	if (cf->can_id & CAN_RTR_FLAG)
+		rtr = 0;
+	else
+		rtr = MSGCFG_DIR;
+	cc770_write_reg(priv, msgobj[mo].ctrl1,
+			RMTPND_RES | TXRQST_RES | CPUUPD_SET | NEWDAT_RES);
+	cc770_write_reg(priv, msgobj[mo].ctrl0,
+			MSGVAL_SET | TXIE_SET | RXIE_RES | INTPND_RES);
+	if (id & CAN_EFF_FLAG) {
+		id &= CAN_EFF_MASK;
+		cc770_write_reg(priv, msgobj[mo].config,
+				(dlc << 4) | rtr | MSGCFG_XTD);
+		cc770_write_reg(priv, msgobj[mo].id[3], id << 3);
+		cc770_write_reg(priv, msgobj[mo].id[2], id >> 5);
+		cc770_write_reg(priv, msgobj[mo].id[1], id >> 13);
+		cc770_write_reg(priv, msgobj[mo].id[0], id >> 21);
+	} else {
+		id &= CAN_SFF_MASK;
+		cc770_write_reg(priv, msgobj[mo].config, (dlc << 4) | rtr);
+		cc770_write_reg(priv, msgobj[mo].id[0], id >> 3);
+		cc770_write_reg(priv, msgobj[mo].id[1], id << 5);
+	}
+
+	for (i = 0; i < dlc; i++)
+		cc770_write_reg(priv, msgobj[mo].data[i], cf->data[i]);
+
+	cc770_write_reg(priv, msgobj[mo].ctrl1,
+			RMTPND_RES | TXRQST_SET | CPUUPD_RES | NEWDAT_UNC);
+
+	stats->tx_bytes += dlc;
+
+	can_put_echo_skb(skb, dev, 0);
+
+	/*
+	 * HM: We had some cases of repeated IRQs so make sure the
+	 * INT is acknowledged I know it's already further up, but
+	 * doing again fixed the issue
+	 */
+	cc770_write_reg(priv, msgobj[mo].ctrl0,
+			MSGVAL_UNC | TXIE_UNC | RXIE_UNC | INTPND_RES);
+
+	return NETDEV_TX_OK;
+}
+
+static void cc770_rx(struct net_device *dev, unsigned int mo, u8 ctrl1)
+{
+	struct cc770_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	struct can_frame *cf;
+	struct sk_buff *skb;
+	u8 config;
+	u32 id;
+	int i;
+
+	skb = alloc_can_skb(dev, &cf);
+	if (!skb)
+		return;
+
+	config = cc770_read_reg(priv, msgobj[mo].config);
+
+	if (ctrl1 & RMTPND_SET) {
+		/*
+		 * Unfortunately, the chip does not store the real message
+		 * identifier of the received remote transmission request
+		 * frame. Therefore we set it to 0.
+		 */
+		cf->can_id = CAN_RTR_FLAG;
+		if (config & MSGCFG_XTD)
+			cf->can_id |= CAN_EFF_FLAG;
+		cf->can_dlc = 0;
+	} else {
+		if (config & MSGCFG_XTD) {
+			id = cc770_read_reg(priv, msgobj[mo].id[3]);
+			id |= cc770_read_reg(priv, msgobj[mo].id[2]) << 8;
+			id |= cc770_read_reg(priv, msgobj[mo].id[1]) << 16;
+			id |= cc770_read_reg(priv, msgobj[mo].id[0]) << 24;
+			id >>= 3;
+			id |= CAN_EFF_FLAG;
+		} else {
+			id = cc770_read_reg(priv, msgobj[mo].id[1]);
+			id |= cc770_read_reg(priv, msgobj[mo].id[0]) << 8;
+			id >>= 5;
+		}
+
+		cf->can_id = id;
+		cf->can_dlc = get_can_dlc((config & 0xf0) >> 4);
+		for (i = 0; i < cf->can_dlc; i++)
+			cf->data[i] = cc770_read_reg(priv, msgobj[mo].data[i]);
+	}
+	netif_rx(skb);
+
+	stats->rx_packets++;
+	stats->rx_bytes += cf->can_dlc;
+}
+
+static int cc770_err(struct net_device *dev, u8 status)
+{
+	struct cc770_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	struct can_frame *cf;
+	struct sk_buff *skb;
+	u8 lec;
+
+	netdev_dbg(dev, "status interrupt (%#x)\n", status);
+
+	skb = alloc_can_err_skb(dev, &cf);
+	if (!skb)
+		return -ENOMEM;
+
+	/* Use extended functions of the CC770 */
+	if (priv->control_normal_mode & CTRL_EAF) {
+		cf->data[6] = cc770_read_reg(priv, tx_error_counter);
+		cf->data[7] = cc770_read_reg(priv, rx_error_counter);
+	}
+
+	if (status & STAT_BOFF) {
+		/* Disable interrupts */
+		cc770_write_reg(priv, control, CTRL_INI);
+		cf->can_id |= CAN_ERR_BUSOFF;
+		priv->can.state = CAN_STATE_BUS_OFF;
+		can_bus_off(dev);
+	} else if (status & STAT_WARN) {
+		cf->can_id |= CAN_ERR_CRTL;
+		/* Only the CC770 does show error passive */
+		if (cf->data[7] > 127) {
+			cf->data[1] = CAN_ERR_CRTL_RX_PASSIVE |
+				CAN_ERR_CRTL_TX_PASSIVE;
+			priv->can.state = CAN_STATE_ERROR_PASSIVE;
+			priv->can.can_stats.error_passive++;
+		} else {
+			cf->data[1] = CAN_ERR_CRTL_RX_WARNING |
+				CAN_ERR_CRTL_TX_WARNING;
+			priv->can.state = CAN_STATE_ERROR_WARNING;
+			priv->can.can_stats.error_warning++;
+		}
+	} else {
+		/* Back to error avtive */
+		cf->can_id |= CAN_ERR_PROT;
+		cf->data[2] = CAN_ERR_PROT_ACTIVE;
+		priv->can.state = CAN_STATE_ERROR_ACTIVE;
+	}
+
+	lec = status & STAT_LEC_MASK;
+	if (lec < 7 && lec > 0) {
+		if (lec == STAT_LEC_ACK) {
+			cf->can_id |= CAN_ERR_ACK;
+		} else {
+			cf->can_id |= CAN_ERR_PROT;
+			switch (lec) {
+			case STAT_LEC_STUFF:
+				cf->data[2] |= CAN_ERR_PROT_STUFF;
+				break;
+			case STAT_LEC_FORM:
+				cf->data[2] |= CAN_ERR_PROT_FORM;
+				break;
+			case STAT_LEC_BIT1:
+				cf->data[2] |= CAN_ERR_PROT_BIT1;
+				break;
+			case STAT_LEC_BIT0:
+				cf->data[2] |= CAN_ERR_PROT_BIT0;
+				break;
+			case STAT_LEC_CRC:
+				cf->data[3] |= CAN_ERR_PROT_LOC_CRC_SEQ;
+				break;
+			}
+		}
+	}
+
+	netif_rx(skb);
+
+	stats->rx_packets++;
+	stats->rx_bytes += cf->can_dlc;
+
+	return 0;
+}
+
+static int cc770_status_interrupt(struct net_device *dev)
+{
+	struct cc770_priv *priv = netdev_priv(dev);
+	u8 status;
+
+	status = cc770_read_reg(priv, status);
+	/* Reset the status register including RXOK and TXOK */
+	cc770_write_reg(priv, status, STAT_LEC_MASK);
+
+	if (status & (STAT_WARN | STAT_BOFF) ||
+	    (status & STAT_LEC_MASK) != STAT_LEC_MASK) {
+		cc770_err(dev, status);
+		return status & STAT_BOFF;
+	}
+
+	return 0;
+}
+
+static void cc770_rx_interrupt(struct net_device *dev, unsigned int o)
+{
+	struct cc770_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	unsigned int mo = obj2msgobj(o);
+	u8 ctrl1;
+	int n = CC770_MAX_MSG;
+
+	while (n--) {
+		ctrl1 = cc770_read_reg(priv, msgobj[mo].ctrl1);
+
+		if (!(ctrl1 & NEWDAT_SET))  {
+			/* Check for RTR if additional functions are enabled */
+			if (priv->control_normal_mode & CTRL_EAF) {
+				if (!(cc770_read_reg(priv, msgobj[mo].ctrl0) &
+				      INTPND_SET))
+					break;
+			} else {
+				break;
+			}
+		}
+
+		if (ctrl1 & MSGLST_SET) {
+			stats->rx_over_errors++;
+			stats->rx_errors++;
+		}
+		if (mo < MSGOBJ_LAST)
+			cc770_write_reg(priv, msgobj[mo].ctrl1,
+					NEWDAT_RES | MSGLST_RES |
+					TXRQST_UNC | RMTPND_UNC);
+		cc770_rx(dev, mo, ctrl1);
+
+		cc770_write_reg(priv, msgobj[mo].ctrl0,
+				MSGVAL_SET | TXIE_RES |
+				RXIE_SET | INTPND_RES);
+		cc770_write_reg(priv, msgobj[mo].ctrl1,
+				NEWDAT_RES | MSGLST_RES |
+				TXRQST_RES | RMTPND_RES);
+	}
+}
+
+static void cc770_rtr_interrupt(struct net_device *dev, unsigned int o)
+{
+	struct cc770_priv *priv = netdev_priv(dev);
+	unsigned int mo = obj2msgobj(o);
+	u8 ctrl0, ctrl1;
+	int n = CC770_MAX_MSG;
+
+	while (n--) {
+		ctrl0 = cc770_read_reg(priv, msgobj[mo].ctrl0);
+		if (!(ctrl0 & INTPND_SET))
+			break;
+
+		ctrl1 = cc770_read_reg(priv, msgobj[mo].ctrl1);
+		cc770_rx(dev, mo, ctrl1);
+
+		cc770_write_reg(priv, msgobj[mo].ctrl0,
+				MSGVAL_SET | TXIE_RES |
+				RXIE_SET | INTPND_RES);
+		cc770_write_reg(priv, msgobj[mo].ctrl1,
+				NEWDAT_RES | CPUUPD_SET |
+				TXRQST_RES | RMTPND_RES);
+	}
+}
+
+static void cc770_tx_interrupt(struct net_device *dev, unsigned int o)
+{
+	struct cc770_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	unsigned int mo = obj2msgobj(o);
+
+	/* Nothing more to send, switch off interrupts */
+	cc770_write_reg(priv, msgobj[mo].ctrl0,
+			MSGVAL_RES | TXIE_RES | RXIE_RES | INTPND_RES);
+	/*
+	 * We had some cases of repeated IRQ so make sure the
+	 * INT is acknowledged
+	 */
+	cc770_write_reg(priv, msgobj[mo].ctrl0,
+			MSGVAL_UNC | TXIE_UNC | RXIE_UNC | INTPND_RES);
+
+	stats->tx_packets++;
+	can_get_echo_skb(dev, 0);
+	netif_wake_queue(dev);
+}
+
+irqreturn_t cc770_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = (struct net_device *)dev_id;
+	struct cc770_priv *priv = netdev_priv(dev);
+	u8 intid;
+	int o, n = 0;
+
+	/* Shared interrupts and IRQ off? */
+	if (priv->can.state == CAN_STATE_STOPPED)
+		return IRQ_NONE;
+
+	if (priv->pre_irq)
+		priv->pre_irq(priv);
+
+	while (n < CC770_MAX_IRQ) {
+		/* Read the highest pending interrupt request */
+		intid = cc770_read_reg(priv, interrupt);
+		if (!intid)
+			break;
+		n++;
+
+		if (intid == 1) {
+			/* Exit in case of bus-off */
+			if (cc770_status_interrupt(dev))
+				break;
+		} else {
+			o = intid2obj(intid);
+
+			if (o >= CC770_OBJ_MAX) {
+				netdev_err(dev, "Unexpected interrupt id %d\n",
+					   intid);
+				continue;
+			}
+
+			if (priv->obj_flags[o] & CC770_OBJ_FLAG_RTR)
+				cc770_rtr_interrupt(dev, o);
+			else if (priv->obj_flags[o] & CC770_OBJ_FLAG_RX)
+				cc770_rx_interrupt(dev, o);
+			else
+				cc770_tx_interrupt(dev, o);
+		}
+	}
+
+	if (priv->post_irq)
+		priv->post_irq(priv);
+
+	if (n >= CC770_MAX_IRQ)
+		netdev_dbg(dev, "%d messages handled in ISR", n);
+
+	return (n) ? IRQ_HANDLED : IRQ_NONE;
+}
+
+static int cc770_open(struct net_device *dev)
+{
+	struct cc770_priv *priv = netdev_priv(dev);
+	int err;
+
+	/* set chip into reset mode */
+	set_reset_mode(dev);
+
+	/* common open */
+	err = open_candev(dev);
+	if (err)
+		return err;
+
+	err = request_irq(dev->irq, &cc770_interrupt, priv->irq_flags,
+			  dev->name, dev);
+	if (err) {
+		close_candev(dev);
+		return -EAGAIN;
+	}
+
+	/* init and start chip */
+	cc770_start(dev);
+
+	netif_start_queue(dev);
+
+	return 0;
+}
+
+static int cc770_close(struct net_device *dev)
+{
+	netif_stop_queue(dev);
+	set_reset_mode(dev);
+
+	free_irq(dev->irq, dev);
+	close_candev(dev);
+
+	return 0;
+}
+
+struct net_device *alloc_cc770dev(int sizeof_priv)
+{
+	struct net_device *dev;
+	struct cc770_priv *priv;
+
+	dev = alloc_candev(sizeof(struct cc770_priv) + sizeof_priv,
+			   CC770_ECHO_SKB_MAX);
+	if (!dev)
+		return NULL;
+
+	priv = netdev_priv(dev);
+
+	priv->dev = dev;
+	priv->can.bittiming_const = &cc770_bittiming_const;
+	priv->can.do_set_bittiming = cc770_set_bittiming;
+	priv->can.do_set_mode = cc770_set_mode;
+	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES;
+
+	memcpy(priv->obj_flags, cc770_obj_flags, sizeof(cc770_obj_flags));
+
+	if (sizeof_priv)
+		priv->priv = (void *)priv + sizeof(struct cc770_priv);
+
+	return dev;
+}
+EXPORT_SYMBOL_GPL(alloc_cc770dev);
+
+void free_cc770dev(struct net_device *dev)
+{
+	free_candev(dev);
+}
+EXPORT_SYMBOL_GPL(free_cc770dev);
+
+static const struct net_device_ops cc770_netdev_ops = {
+	.ndo_open = cc770_open,
+	.ndo_stop = cc770_close,
+	.ndo_start_xmit = cc770_start_xmit,
+};
+
+int register_cc770dev(struct net_device *dev)
+{
+	struct cc770_priv *priv = netdev_priv(dev);
+	int err;
+
+	err = cc770_probe_chip(dev);
+	if (err)
+		return err;
+
+	dev->netdev_ops = &cc770_netdev_ops;
+
+	dev->flags |= IFF_ECHO;	/* we support local echo */
+
+	/* Should we use additional functions? */
+	if (!i82527_compat && priv->control_normal_mode & CTRL_EAF) {
+		priv->can.do_get_berr_counter = cc770_get_berr_counter;
+		priv->control_normal_mode = CTRL_IE | CTRL_EAF | CTRL_EIE;
+		netdev_dbg(dev, "i82527 mode with additional functions\n");
+	} else {
+		priv->control_normal_mode = CTRL_IE | CTRL_EIE;
+		netdev_dbg(dev, "strict i82527 compatibility mode\n");
+	}
+
+	chipset_init(priv);
+	set_reset_mode(dev);
+
+	return register_candev(dev);
+}
+EXPORT_SYMBOL_GPL(register_cc770dev);
+
+void unregister_cc770dev(struct net_device *dev)
+{
+	set_reset_mode(dev);
+	unregister_candev(dev);
+}
+EXPORT_SYMBOL_GPL(unregister_cc770dev);
+
+static __init int cc770_init(void)
+{
+	if (msgobj15_eff) {
+		cc770_obj_flags[CC770_OBJ_RX0] |= CC770_OBJ_FLAG_EFF;
+		cc770_obj_flags[CC770_OBJ_RX1] &= ~CC770_OBJ_FLAG_EFF;
+	}
+
+	pr_info("CAN netdevice driver\n");
+
+	return 0;
+}
+module_init(cc770_init);
+
+static __exit void cc770_exit(void)
+{
+	pr_info("driver removed\n");
+}
+module_exit(cc770_exit);
diff --git a/drivers/net/can/cc770/cc770.h b/drivers/net/can/cc770/cc770.h
new file mode 100644
index 0000000..a1739db
--- /dev/null
+++ b/drivers/net/can/cc770/cc770.h
@@ -0,0 +1,203 @@
+/*
+ * Core driver for the CC770 and AN82527 CAN controllers
+ *
+ * Copyright (C) 2009, 2011 Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the version 2 of the GNU General Public License
+ * as published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef CC770_DEV_H
+#define CC770_DEV_H
+
+#include <linux/can/dev.h>
+
+struct cc770_msgobj {
+	u8 ctrl0;
+	u8 ctrl1;
+	u8 id[4];
+	u8 config;
+	u8 data[8];
+	u8 dontuse;		/* padding */
+} __packed;
+
+struct cc770_regs {
+	union {
+		struct cc770_msgobj msgobj[16]; /* Message object 1..15 */
+		struct {
+			u8 control;		/* Control Register */
+			u8 status;		/* Status Register */
+			u8 cpu_interface;	/* CPU Interface Register */
+			u8 dontuse1;
+			u8 high_speed_read[2];	/* High Speed Read */
+			u8 global_mask_std[2];	/* Standard Global Mask */
+			u8 global_mask_ext[4];	/* Extended Global Mask */
+			u8 msg15_mask[4];	/* Message 15 Mask */
+			u8 dontuse2[15];
+			u8 clkout;		/* Clock Out Register */
+			u8 dontuse3[15];
+			u8 bus_config;		/* Bus Configuration Register */
+			u8 dontuse4[15];
+			u8 bit_timing_0;	/* Bit Timing Register byte 0 */
+			u8 dontuse5[15];
+			u8 bit_timing_1;	/* Bit Timing Register byte 1 */
+			u8 dontuse6[15];
+			u8 interrupt;		/* Interrupt Register */
+			u8 dontuse7[15];
+			u8 rx_error_counter;	/* Receive Error Counter */
+			u8 dontuse8[15];
+			u8 tx_error_counter;	/* Transmit Error Counter */
+			u8 dontuse9[31];
+			u8 p1_conf;
+			u8 dontuse10[15];
+			u8 p2_conf;
+			u8 dontuse11[15];
+			u8 p1_in;
+			u8 dontuse12[15];
+			u8 p2_in;
+			u8 dontuse13[15];
+			u8 p1_out;
+			u8 dontuse14[15];
+			u8 p2_out;
+			u8 dontuse15[15];
+			u8 serial_reset_addr;
+		};
+	};
+} __packed;
+
+/* Control Register (0x00) */
+#define CTRL_INI	0x01	/* Initialization */
+#define CTRL_IE		0x02	/* Interrupt Enable */
+#define CTRL_SIE	0x04	/* Status Interrupt Enable */
+#define CTRL_EIE	0x08	/* Error Interrupt Enable */
+#define CTRL_EAF	0x20	/* Enable additional functions */
+#define CTRL_CCE	0x40	/* Change Configuration Enable */
+
+/* Status Register (0x01) */
+#define STAT_LEC_STUFF	0x01	/* Stuff error */
+#define STAT_LEC_FORM	0x02	/* Form error */
+#define STAT_LEC_ACK	0x03	/* Acknowledgement error */
+#define STAT_LEC_BIT1	0x04	/* Bit1 error */
+#define STAT_LEC_BIT0	0x05	/* Bit0 error */
+#define STAT_LEC_CRC	0x06	/* CRC error */
+#define STAT_LEC_MASK	0x07	/* Last Error Code mask */
+#define STAT_TXOK	0x08	/* Transmit Message Successfully */
+#define STAT_RXOK	0x10	/* Receive Message Successfully */
+#define STAT_WAKE	0x20	/* Wake Up Status */
+#define STAT_WARN	0x40	/* Warning Status */
+#define STAT_BOFF	0x80	/* Bus Off Status */
+
+/*
+ * CPU Interface Register (0x02)
+ * Clock Out Register (0x1f)
+ * Bus Configuration Register (0x2f)
+ *
+ * see include/linux/can/platform/cc770.h
+ */
+
+/* Message Control Register 0 (Base Address + 0x0) */
+#define INTPND_RES	0x01	/* No Interrupt pending */
+#define INTPND_SET	0x02	/* Interrupt pending */
+#define INTPND_UNC	0x03
+#define RXIE_RES	0x04	/* Receive Interrupt Disable */
+#define RXIE_SET	0x08	/* Receive Interrupt Enable */
+#define RXIE_UNC	0x0c
+#define TXIE_RES	0x10	/* Transmit Interrupt Disable */
+#define TXIE_SET	0x20	/* Transmit Interrupt Enable */
+#define TXIE_UNC	0x30
+#define MSGVAL_RES	0x40	/* Message Invalid */
+#define MSGVAL_SET	0x80	/* Message Valid */
+#define MSGVAL_UNC	0xc0
+
+/* Message Control Register 1 (Base Address + 0x01) */
+#define NEWDAT_RES	0x01	/* No New Data */
+#define NEWDAT_SET	0x02	/* New Data */
+#define NEWDAT_UNC	0x03
+#define MSGLST_RES	0x04	/* No Message Lost */
+#define MSGLST_SET	0x08	/* Message Lost */
+#define MSGLST_UNC	0x0c
+#define CPUUPD_RES	0x04	/* No CPU Updating */
+#define CPUUPD_SET	0x08	/* CPU Updating */
+#define CPUUPD_UNC	0x0c
+#define TXRQST_RES	0x10	/* No Transmission Request */
+#define TXRQST_SET	0x20	/* Transmission Request */
+#define TXRQST_UNC	0x30
+#define RMTPND_RES	0x40	/* No Remote Request Pending */
+#define RMTPND_SET	0x80	/* Remote Request Pending */
+#define RMTPND_UNC	0xc0
+
+/* Message Configuration Register (Base Address + 0x06) */
+#define MSGCFG_XTD	0x04	/* Extended Identifier */
+#define MSGCFG_DIR	0x08	/* Direction is Transmit */
+
+#define MSGOBJ_FIRST	1
+#define MSGOBJ_LAST	15
+
+#define CC770_IO_SIZE	0x100
+#define CC770_MAX_IRQ	20	/* max. number of interrupts handled in ISR */
+#define CC770_MAX_MSG	4	/* max. number of messages handled in ISR */
+
+#define CC770_ECHO_SKB_MAX	1
+
+#define cc770_read_reg(priv, member)					\
+	priv->read_reg(priv, offsetof(struct cc770_regs, member))
+
+#define cc770_write_reg(priv, member, value)				\
+	priv->write_reg(priv, offsetof(struct cc770_regs, member), value)
+
+/*
+ * Message objects and flags used by this driver
+ */
+#define CC770_OBJ_FLAG_RX	0x01
+#define CC770_OBJ_FLAG_RTR	0x02
+#define CC770_OBJ_FLAG_EFF	0x04
+
+enum {
+	CC770_OBJ_RX0 = 0,	/* for receiving normal messages */
+	CC770_OBJ_RX1,		/* for receiving normal messages */
+	CC770_OBJ_RX_RTR0,	/* for receiving remote transmission requests */
+	CC770_OBJ_RX_RTR1,	/* for receiving remote transmission requests */
+	CC770_OBJ_TX,		/* for sending messages */
+	CC770_OBJ_MAX
+};
+
+#define obj2msgobj(o)	(MSGOBJ_LAST - (o)) /* message object 11..15 */
+
+/*
+ * CC770 private data structure
+ */
+struct cc770_priv {
+	struct can_priv can;	/* must be the first member */
+	struct sk_buff *echo_skb;
+
+	/* the lower-layer is responsible for appropriate locking */
+	u8 (*read_reg)(const struct cc770_priv *priv, int reg);
+	void (*write_reg)(const struct cc770_priv *priv, int reg, u8 val);
+	void (*pre_irq)(const struct cc770_priv *priv);
+	void (*post_irq)(const struct cc770_priv *priv);
+
+	void *priv;		/* for board-specific data */
+	struct net_device *dev;
+
+	void __iomem *reg_base;	 /* ioremap'ed address to registers */
+	unsigned long irq_flags; /* for request_irq() */
+
+	unsigned char obj_flags[CC770_OBJ_MAX];
+	u8 control_normal_mode;	/* Control register for normal mode */
+	u8 cpu_interface;	/* CPU interface register */
+	u8 clkout;		/* Clock out register */
+	u8 bus_config;		/* Bus conffiguration register */
+};
+
+struct net_device *alloc_cc770dev(int sizeof_priv);
+void free_cc770dev(struct net_device *dev);
+int register_cc770dev(struct net_device *dev);
+void unregister_cc770dev(struct net_device *dev);
+
+#endif /* CC770_DEV_H */
diff --git a/include/linux/can/platform/cc770.h b/include/linux/can/platform/cc770.h
new file mode 100644
index 0000000..7702641
--- /dev/null
+++ b/include/linux/can/platform/cc770.h
@@ -0,0 +1,33 @@
+#ifndef _CAN_PLATFORM_CC770_H_
+#define _CAN_PLATFORM_CC770_H_
+
+/* CPU Interface Register (0x02) */
+#define CPUIF_CEN	0x01	/* Clock Out Enable */
+#define CPUIF_MUX	0x04	/* Multiplex */
+#define CPUIF_SLP	0x08	/* Sleep */
+#define CPUIF_PWD	0x10	/* Power Down Mode */
+#define CPUIF_DMC	0x20	/* Divide Memory Clock */
+#define CPUIF_DSC	0x40	/* Divide System Clock */
+#define CPUIF_RST	0x80	/* Hardware Reset Status */
+
+/* Clock Out Register (0x1f) */
+#define CLKOUT_CD_MASK  0x0f	/* Clock Divider mask */
+#define CLKOUT_SL_MASK	0x30	/* Slew Rate mask */
+#define CLKOUT_SL_SHIFT	4
+
+/* Bus Configuration Register (0x2f) */
+#define BUSCFG_DR0	0x01	/* Disconnect RX0 Input / Select RX input */
+#define BUSCFG_DR1	0x02	/* Disconnect RX1 Input / Silent mode */
+#define BUSCFG_DT1	0x08	/* Disconnect TX1 Output */
+#define BUSCFG_POL	0x20	/* Polarity dominant or recessive */
+#define BUSCFG_CBY	0x40	/* Input Comparator Bypass */
+
+struct cc770_platform_data {
+	u32 osc_freq;	/* CAN bus oscillator frequency in Hz */
+
+	u8 cir;		/* CPU Interface Register */
+	u8 cor;		/* Clock Out Register */
+	u8 bcr;		/* Bus Configuration Register */
+};
+
+#endif	/* !_CAN_PLATFORM_CC770_H_ */
-- 
1.7.4.1
