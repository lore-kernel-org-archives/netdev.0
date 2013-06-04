From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: [PATCH] ethernet/arc/arc_emac - Add new driver
Date: Tue, 4 Jun 2013 16:21:50 +0400
Message-ID: <1370348510-23754-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	"Paul Gortmaker" <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Steven J. Hill" <sjhill@mips.com>, <linux-kernel@vger.kernel.org>,
	<devicetree-discuss@lists.ozlabs.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Driver for non-standard on-chip ethernet device ARC EMAC 10/100,
instantiated in some legacy ARC (Synopsys) FPGA Boards such as
ARCAngel4/ML50x.

This is based off of current Linus tree, build tested for x86.

Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
Reviewed-by: Vineet Gupta <vgupta@synopsys.com>
Reviewed-by: Mischa Jonker <mjonker@synopsys.com>

Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: Mischa Jonker <mjonker@synopsys.com>
Cc: Grant Likely <grant.likely@linaro.org>
Cc: Rob Herring <rob.herring@calxeda.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "Steven J. Hill" <sjhill@mips.com>
Cc: linux-kernel@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
---
 drivers/net/ethernet/Kconfig             |    1 +
 drivers/net/ethernet/Makefile            |    1 +
 drivers/net/ethernet/arc/Kconfig         |   29 +
 drivers/net/ethernet/arc/Makefile        |    6 +
 drivers/net/ethernet/arc/arc_emac_main.c |  905 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/arc/arc_emac_main.h |   82 +++
 drivers/net/ethernet/arc/arc_emac_mdio.c |  181 ++++++
 drivers/net/ethernet/arc/arc_emac_mdio.h |   22 +
 drivers/net/ethernet/arc/arc_emac_regs.h |   73 +++
 9 files changed, 1300 insertions(+)
 create mode 100644 drivers/net/ethernet/arc/Kconfig
 create mode 100644 drivers/net/ethernet/arc/Makefile
 create mode 100644 drivers/net/ethernet/arc/arc_emac_main.c
 create mode 100644 drivers/net/ethernet/arc/arc_emac_main.h
 create mode 100644 drivers/net/ethernet/arc/arc_emac_mdio.c
 create mode 100644 drivers/net/ethernet/arc/arc_emac_mdio.h
 create mode 100644 drivers/net/ethernet/arc/arc_emac_regs.h

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index ed956e0..c986521 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -23,6 +23,7 @@ source "drivers/net/ethernet/aeroflex/Kconfig"
 source "drivers/net/ethernet/alteon/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
+source "drivers/net/ethernet/arc/Kconfig"
 source "drivers/net/ethernet/atheros/Kconfig"
 source "drivers/net/ethernet/cadence/Kconfig"
 source "drivers/net/ethernet/adi/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 8268d85..ceed1d3 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -9,6 +9,7 @@ obj-$(CONFIG_GRETH) += aeroflex/
 obj-$(CONFIG_NET_VENDOR_ALTEON) += alteon/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
+obj-$(CONFIG_NET_VENDOR_ARC) += arc/
 obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/
 obj-$(CONFIG_NET_CADENCE) += cadence/
 obj-$(CONFIG_NET_BFIN) += adi/
diff --git a/drivers/net/ethernet/arc/Kconfig b/drivers/net/ethernet/arc/Kconfig
new file mode 100644
index 0000000..4fa4872
--- /dev/null
+++ b/drivers/net/ethernet/arc/Kconfig
@@ -0,0 +1,29 @@
+#
+# ARC EMAC network device configuration
+#
+
+config NET_VENDOR_ARC
+	bool "ARC devices"
+	default y
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about ARC cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if NET_VENDOR_ARC
+
+config ARC_EMAC
+	tristate "ARC EMAC support"
+	select MII
+	select PHYLIB
+	---help---
+	  On some legacy ARC (Synopsys) FPGA boards such as ARCAngel4/ML50x
+	  non-standard on-chip ethernet device ARC EMAC 10/100 is used.
+	  Say Y here if you have such a board.  If unsure, say N.
+
+endif # NET_VENDOR_ARC
diff --git a/drivers/net/ethernet/arc/Makefile b/drivers/net/ethernet/arc/Makefile
new file mode 100644
index 0000000..f5b73e5
--- /dev/null
+++ b/drivers/net/ethernet/arc/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the ARC network device drivers.
+#
+
+arc_emac-objs := arc_emac_main.o arc_emac_mdio.o
+obj-$(CONFIG_ARC_EMAC) += arc_emac.o
diff --git a/drivers/net/ethernet/arc/arc_emac_main.c b/drivers/net/ethernet/arc/arc_emac_main.c
new file mode 100644
index 0000000..de2f94f
--- /dev/null
+++ b/drivers/net/ethernet/arc/arc_emac_main.c
@@ -0,0 +1,905 @@
+/*
+ * Copyright (C) 2004, 2007-2010, 2011-2013 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Driver for the ARC EMAC 10100 (Rev 5)
+ *
+ * Alexey Brodkin: June 2013
+ *  -Upsteaming
+ *  -Refactoring
+ *      = Use device-tree/OF for configuration
+ *      = Use libphy for phy management
+ *      = Remove non-NAPI code sections
+ *      = Remove ARC-specific BD management implementations
+ *      = Add ethtool functionality
+ *
+ * Vineet Gupta: June 2011
+ *  -Issues when working with 64b cache line size
+ *      = BD rings point to aligned location in an internal buffer
+ *      = added support for cache coherent BD Ring memory
+ *
+ * Vineet Gupta: May 2010
+ *  -Reduced foot-print of the main ISR (handling for error cases moved out
+ *      into a separate non-inline function).
+ *  -Driver Tx path optimized for small packets (which fit into 1 BD = 2K).
+ *      Any specifics for chaining are in a separate block of code.
+ *
+ * Vineet Gupta: Nov 2009
+ *  -Unified NAPI and Non-NAPI Code.
+ *  -API changes since 2.6.26 for making NAPI independent of netdevice
+ *  -Cutting a few checks in main Rx poll routine
+ *  -Tweaked NAPI implementation:
+ *      In poll mode, Original driver would always start sweeping BD chain
+ *      from BD-0 upto poll budget (40). And if it got over-budget it would
+ *      drop reminder of packets.
+ *      Instead now we remember last BD polled and in next
+ *      cycle, we resume from next BD onwards. That way in case of over-budget
+ *      no packet needs to be dropped.
+ *
+ * Vineet Gupta: Nov 2009
+ *  -Rewrote the driver register access macros so that multiple accesses
+ *   in same function use "anchor" reg to save the base addr causing
+ *   shorter instructions
+ *
+ * Amit Bhor, Sameer Dhavale: 2004
+ */
+
+#include <linux/etherdevice.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
+#include <linux/module.h>
+#include <linux/of_address.h>
+#include <linux/of_irq.h>
+#include <linux/of_mdio.h>
+#include <linux/of_net.h>
+#include <linux/of_platform.h>
+#include <linux/platform_device.h>
+
+#include "arc_emac_regs.h"
+#include "arc_emac_mdio.h"
+#include "arc_emac_main.h"
+
+#define DRV_NAME	"arc_emac"
+#define DRV_VERSION	"2.0"
+
+/**
+ * arc_emac_adjust_link - Adjust the PHY link speed/duplex.
+ * @net_dev:	Pointer to the net_device structure.
+ *
+ * This function is called to change the speed and duplex setting after
+ * auto negotiation is done by the PHY.
+ */
+static void
+arc_emac_adjust_link(struct net_device *net_dev)
+{
+	struct arc_emac_priv *priv = netdev_priv(net_dev);
+	struct phy_device *phydev = priv->phy_dev;
+	u32 reg;
+
+	int status_change = 0;
+
+	BUG_ON(!priv->phy_dev);
+
+	if (phydev->link && (priv->old_speed != phydev->speed)) {
+		/* speed changed */
+		switch (phydev->speed) {
+		case SPEED_10:
+		case SPEED_100:
+			break;
+		default:
+			netdev_warn(net_dev,
+				"Speed (%d) is not 10/100?\n", phydev->speed);
+			break;
+		}
+		priv->old_speed = phydev->speed;
+		status_change = 1;
+	}
+
+	if (phydev->link && (priv->old_duplex != phydev->duplex)) {
+		/* duplex mode changed */
+		reg = EMAC_REG_GET(priv->reg_base_addr, R_CTRL);
+		if (DUPLEX_FULL == phydev->duplex)
+			reg |= ENFL_MASK;
+		else
+			reg &= ~ENFL_MASK;
+		EMAC_REG_SET(priv->reg_base_addr, R_CTRL, reg);
+		priv->old_duplex = phydev->duplex;
+		status_change = 1;
+	}
+
+	if (phydev->link != priv->old_link) {
+		/* link state changed */
+		if (!phydev->link) {
+			/* link went down */
+			priv->old_speed = 0;
+			priv->old_duplex = -1;
+		}
+		priv->old_link = phydev->link;
+		status_change = 1;
+	}
+
+	if (status_change)
+		phy_print_status(phydev);
+}
+
+/**
+ * arc_emac_get_settings - Get PHY settings.
+ * @net_dev:	Pointer to net_device structure.
+ * @cmd:		Pointer to ethtool_cmd structure.
+ *
+ * This implements ethtool command for getting PHY settings. If PHY could
+ * not be found, the function returns -ENODEV. This function calls the
+ * relevant PHY ethtool API to get the PHY settings.
+ * Issue "ethtool ethX" under linux prompt to execute this function.
+ */
+static int arc_emac_get_settings(struct net_device *net_dev,
+		struct ethtool_cmd *cmd)
+{
+	struct arc_emac_priv *aup = netdev_priv(net_dev);
+
+	if (aup->phy_dev)
+		return phy_ethtool_gset(aup->phy_dev, cmd);
+
+	return -EINVAL;
+}
+
+/**
+ * arc_emac_set_settings - Set PHY settings as passed in the argument.
+ * @net_dev:	Pointer to net_device structure.
+ * @cmd:		Pointer to ethtool_cmd structure.
+ *
+ * This implements ethtool command for setting various PHY settings. If PHY
+ * could not be found, the function returns -ENODEV. This function calls the
+ * relevant PHY ethtool API to set the PHY.
+ * Issue e.g. "ethtool -s ethX speed 1000" under linux prompt to execute this
+ * function.
+ */
+static int arc_emac_set_settings(struct net_device *net_dev,
+		struct ethtool_cmd *cmd)
+{
+	struct arc_emac_priv *aup = netdev_priv(net_dev);
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (aup->phy_dev)
+		return phy_ethtool_sset(aup->phy_dev, cmd);
+
+	return -EINVAL;
+}
+
+/**
+ * arc_emac_get_drvinfo - Get EMAC driver information.
+ * @net_dev:	Pointer to net_device structure.
+ * @info:		Pointer to ethtool_drvinfo structure.
+ *
+ * This implements ethtool command for getting the driver information.
+ * Issue "ethtool -i ethX" under linux prompt to execute this function.
+ */
+static void arc_emac_get_drvinfo(struct net_device *net_dev,
+		struct ethtool_drvinfo *info)
+{
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+}
+
+static const struct ethtool_ops arc_emac_ethtool_ops = {
+	.get_settings = arc_emac_get_settings,
+	.set_settings = arc_emac_set_settings,
+	.get_drvinfo = arc_emac_get_drvinfo,
+	.get_link = ethtool_op_get_link,
+};
+
+static int arc_emac_poll(struct napi_struct *napi, int budget)
+{
+	struct net_device *net_dev = napi->dev;
+	struct arc_emac_priv *priv = netdev_priv(net_dev);
+	struct sk_buff *skb, *skbnew;
+	unsigned int i, loop, len, info, work_done = 0;
+
+	/* Loop thru the BD chain, but not always from 0.
+	 * Start from right after where we last saw a packet.
+	 */
+	i = priv->last_rx_bd;
+
+	for (loop = 0; loop < RX_BD_NUM; loop++) {
+		i = (i + 1) & (RX_BD_NUM - 1);
+
+		info = priv->rxbd[i].info;
+
+		/* BD contains a packet for CPU to grab */
+		if (likely((info & OWN_MASK) == FOR_CPU)) {
+
+			/* Make a note that we saw a packet at this BD.
+			 * So next time, driver starts from this + 1
+			 */
+			priv->last_rx_bd = i;
+
+			/* Packet fits in one BD (Non Fragmented) */
+			if (likely((info & (FRST_MASK | LAST_MASK)) ==
+				(FRST_MASK | LAST_MASK))) {
+
+				len = info & LEN_MASK;
+				priv->stats.rx_packets++;
+				priv->stats.rx_bytes += len;
+				skb = priv->rx_skbuff[i];
+
+				/* Get a new SKB from stack */
+				skbnew = netdev_alloc_skb(net_dev,
+					net_dev->mtu + EMAC_BUFFER_PAD);
+				if (!skbnew) {
+					netdev_err(net_dev,
+					"Out of memory, dropping packet\n");
+
+					/* Return buffer to EMAC */
+					priv->rxbd[i].info = FOR_EMAC |
+						(net_dev->mtu +
+						EMAC_BUFFER_PAD);
+					priv->stats.rx_dropped++;
+					continue;
+				}
+
+				/* Actually preparing the BD for next cycle
+				 * IP header align, eth is 14 bytes
+				 */
+				skb_reserve(skbnew, 2);
+				priv->rx_skbuff[i] = skbnew;
+
+				priv->rxbd[i].data = skbnew->data;
+				priv->rxbd[i].info = FOR_EMAC |
+					(net_dev->mtu + EMAC_BUFFER_PAD);
+
+				/* Prepare arrived pkt for delivery to stack */
+				dma_map_single(&net_dev->dev,
+						(void *)skb->data,
+						len, DMA_FROM_DEVICE);
+
+				skb->dev = net_dev;
+				/* Make room for data */
+				skb_put(skb, len - 4);
+				skb->protocol = eth_type_trans(skb, net_dev);
+
+				/* Correct NAPI semantics:
+				 * If work quota exceeded return don't de-queue
+				 * any further packets
+				 */
+				work_done++;
+				netif_receive_skb(skb);
+				if (work_done >= budget)
+					break;
+			} else {
+				/* Buffer chaining results in a significant
+				 * amount of additional bus overhead and thus
+				 * a higher CLK frequency is required or larger
+				 * FIFOs are required.
+				 * Because of that fact we don't support
+				 * chaining of receive packets. We preallocate
+				 * buffers of MTU size so incoming packets
+				 * won't be chained
+				 */
+				netdev_warn(net_dev,
+					"Rx chained, packet is larger than "
+					"device MTU (%d bytes)\n",
+					net_dev->mtu);
+
+				/* Return buffer to EMAC */
+				priv->rxbd[i].info = FOR_EMAC |
+					(net_dev->mtu + EMAC_BUFFER_PAD);
+				priv->stats.rx_length_errors++;
+			}
+		}	/* BD for CPU */
+	}		/* BD chain loop */
+
+	if (work_done < budget) {
+		napi_complete(napi);
+		EMAC_REG_OR(priv->reg_base_addr, R_ENABLE, RXINT_MASK);
+	}
+
+	return work_done;
+}
+
+/**
+ * arc_emac_intr - Global interrupt handler for EMAC.
+ * @irq:		irq number.
+ * @net_dev:	net_device pointer.
+ *
+ * returns: IRQ_HANDLED for all cases.
+ *
+ * ARC EMAC has only 1 interrupt line, and depending on bits raised in
+ * STATUS register we may tell what is a reason for interrupt to fire.
+ */
+static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
+{
+	struct net_device *net_dev = (struct net_device *)dev_instance;
+	struct arc_emac_priv *priv = netdev_priv(net_dev);
+	unsigned int status;
+
+	/* Read STATUS register from EMAC */
+	status = EMAC_REG_GET(priv->reg_base_addr, R_STATUS);
+
+	/* Mask all bits except "MDIO complete" */
+	status &= ~MDIO_MASK;
+
+	/* To reset any bit in STATUS register we need to write "1" in
+	 * corresponding bit. That's why we write only masked bits back.
+	 */
+	EMAC_REG_SET(priv->reg_base_addr, R_STATUS, status);
+
+	if (likely(status & (RXINT_MASK | TXINT_MASK))) {
+		if (status & RXINT_MASK) {
+			if (likely(napi_schedule_prep(&priv->napi))) {
+				EMAC_REG_CLR(priv->reg_base_addr, R_ENABLE,
+					RXINT_MASK);
+				__napi_schedule(&priv->napi);
+			}
+		}
+		if (status & TXINT_MASK) {
+			unsigned int i, info;
+			struct sk_buff *skb;
+
+			for (i = 0; i < TX_BD_NUM; i++) {
+				info = priv->txbd[priv->txbd_dirty].info;
+
+				if (info & (DROP | DEFR | LTCL | UFLO))
+					netdev_warn(net_dev,
+					"FIXME: add Tx errors to stats\n");
+
+				if ((info & FOR_EMAC) ||
+					!priv->txbd[priv->txbd_dirty].data)
+					break;
+
+				if (info & LAST_MASK) {
+					skb = priv->tx_skbuff[priv->txbd_dirty];
+					priv->stats.tx_packets++;
+					priv->stats.tx_bytes += skb->len;
+					/* return the sk_buff to system */
+					dev_kfree_skb_irq(skb);
+				}
+				priv->txbd[priv->txbd_dirty].data = 0x0;
+				priv->txbd[priv->txbd_dirty].info = 0x0;
+				priv->txbd_dirty =
+					(priv->txbd_dirty + 1) % TX_BD_NUM;
+			}
+		}
+	} else {
+		if (status & ERR_MASK) {
+			/* MSER/RXCR/RXFR/RXFL interrupt fires on corresponding
+			 * 8-bit error counter overrun.
+			 * Because of this fact we add 256 items each time
+			 * overrun interrupt happens.
+			 */
+
+			if (status & TXCH_MASK) {
+				priv->stats.tx_errors++;
+				priv->stats.tx_aborted_errors++;
+				netdev_err(priv->net_dev,
+					"Tx chaining error! txbd_dirty = %u\n",
+					priv->txbd_dirty);
+			} else if (status & MSER_MASK) {
+				priv->stats.rx_missed_errors += 255;
+				priv->stats.rx_errors += 255;
+			} else if (status & RXCR_MASK) {
+				priv->stats.rx_crc_errors += 255;
+				priv->stats.rx_errors += 255;
+			} else if (status & RXFR_MASK) {
+				priv->stats.rx_frame_errors += 255;
+				priv->stats.rx_errors += 255;
+			} else if (status & RXFL_MASK) {
+				priv->stats.rx_over_errors += 255;
+				priv->stats.rx_errors += 255;
+			} else {
+				netdev_err(priv->net_dev,
+					"unknown error. Status reg is 0x%x\n",
+					status);
+			}
+		}
+	}
+	return IRQ_HANDLED;
+}
+
+/**
+ * arc_emac_open - Open the network device.
+ * @net_dev:	Pointer to the network device.
+ *
+ * returns: 0, on success or non-zero error value on failure.
+ *
+ * This function sets the MAC address, requests and enables an IRQ
+ * for the EMAC device and starts the Tx queue.
+ * It also connects to the phy device.
+ */
+int arc_emac_open(struct net_device *net_dev)
+{
+	struct arc_emac_bd_t *bd;
+	struct sk_buff *skb;
+	int i;
+
+	struct arc_emac_priv *priv = netdev_priv(net_dev);
+
+	if (!priv->phy_node) {
+		netdev_err(net_dev, "arc_emac_open: phy device is absent\n");
+		return -ENODEV;
+	}
+
+	priv->phy_dev = of_phy_connect(net_dev, priv->phy_node,
+		arc_emac_adjust_link, 0,
+		PHY_INTERFACE_MODE_MII);
+
+	if (!priv->phy_dev) {
+		netdev_err(net_dev, "of_phy_connect() failed\n");
+		return -ENODEV;
+	}
+
+	netdev_info(net_dev, "connected to %s phy with id 0x%x\n",
+			priv->phy_dev->drv->name, priv->phy_dev->phy_id);
+
+	priv->phy_dev->autoneg = AUTONEG_ENABLE;
+	priv->phy_dev->speed = 0;
+	priv->phy_dev->duplex = 0;
+
+	/* We support only up-to 100mbps speeds */
+	priv->phy_dev->advertising =
+			priv->phy_dev->supported & PHY_BASIC_FEATURES;
+	priv->phy_dev->advertising |= ADVERTISED_Autoneg;
+
+	/* Restart auto negotiation */
+	phy_start_aneg(priv->phy_dev);
+
+	netif_start_queue(net_dev);
+
+	/* Allocate and set buffers for Rx BD's */
+	bd = priv->rxbd;
+	for (i = 0; i < RX_BD_NUM; i++) {
+		skb = dev_alloc_skb(net_dev->mtu + EMAC_BUFFER_PAD);
+
+		/* IP header Alignment (14 byte Ethernet header) */
+		skb_reserve(skb, 2);
+		priv->rx_skbuff[i] = skb;
+		bd->data = skb->data;
+
+		/* EMAC owns Rx descriptors */
+		bd->info = FOR_EMAC | (net_dev->mtu + EMAC_BUFFER_PAD);
+		bd++;
+	}
+
+	/* setup last seen to MAX, so driver starts from 0 */
+	priv->last_rx_bd = RX_BD_NUM - 1;
+
+	/* Allocate Tx BD's similar to Rx BD's. All Tx BD's owned by CPU */
+	bd = priv->txbd;
+	for (i = 0; i < TX_BD_NUM; i++) {
+		bd->data = 0;
+		bd->info = 0;
+		bd++;
+	}
+
+	/* Initialize logical address filter */
+	EMAC_REG_SET(priv->reg_base_addr, R_LAFL, 0);
+	EMAC_REG_SET(priv->reg_base_addr, R_LAFH, 0);
+
+	/* Set BD ring pointers for device side */
+	EMAC_REG_SET(priv->reg_base_addr, R_RX_RING,
+			(unsigned int)priv->rxbd_dma_hdl);
+
+	EMAC_REG_SET(priv->reg_base_addr, R_TX_RING,
+			(unsigned int)priv->rxbd_dma_hdl + RX_RING_SZ);
+
+	/* Set Poll rate so that it polls every 1 ms */
+	EMAC_REG_SET(priv->reg_base_addr, R_POLLRATE,
+			priv->clock_frequency / 1000000);
+
+	/* Enable interrupts. Note: interrupts wont actually come till we set
+	 * CONTROL below.
+	 */
+	EMAC_REG_SET(priv->reg_base_addr, R_ENABLE,
+			TXINT_MASK |	/* Transmit interrupt */
+			RXINT_MASK |	/* Receive interrupt */
+			ERR_MASK |	/* Error interrupt */
+			TXCH_MASK |	/* Transmit chaining error interrupt */
+			MSER_MASK);	/* Missed packet error */
+
+	/* Set CONTROL */
+	EMAC_REG_SET(priv->reg_base_addr, R_CTRL,
+			(RX_BD_NUM << 24) |	/* RX buffer desc table len */
+			(TX_BD_NUM << 16) |	/* TX buffer desc table len */
+			TXRN_MASK |		/* TX enable */
+			RXRN_MASK);		/* RX enable */
+
+	EMAC_REG_OR(priv->reg_base_addr, R_CTRL, EN_MASK);
+
+	netif_wake_queue(net_dev);
+	napi_enable(&priv->napi);
+
+	return 0;
+}
+
+/**
+ * arc_emac_stop - Close the network device.
+ * @net_dev:	Pointer to the network device.
+ *
+ * This function stops the Tx queue, disables interrupts and frees the IRQ for
+ * the EMAC device.
+ * It also disconnects the phy device associated with the EMAC device.
+ */
+int arc_emac_stop(struct net_device *net_dev)
+{
+	struct arc_emac_priv *priv = netdev_priv(net_dev);
+
+	napi_disable(&priv->napi);
+	netif_stop_queue(net_dev);
+
+	/* Disable interrupts */
+	EMAC_REG_CLR(priv->reg_base_addr, R_ENABLE,
+			TXINT_MASK |	/* Tx interrupt */
+			RXINT_MASK |	/* Rx interrupt */
+			ERR_MASK |	/* Error interrupt */
+			TXCH_MASK);	/* Transmit chaining error interrupt */
+
+	if (priv->phy_dev)
+		phy_disconnect(priv->phy_dev);
+	priv->phy_dev = NULL;
+
+	/* Disable EMAC */
+	EMAC_REG_CLR(priv->reg_base_addr, R_CTRL, EN_MASK);
+
+	return 0;
+}
+
+/**
+ * arc_emac_stats - Get system network statistics.
+ * @net_dev:	Pointer to net_device structure.
+ *
+ * Returns the address of the device statistics structure.
+ * Statistics are updated in interrupt handler.
+ */
+struct net_device_stats *arc_emac_stats(struct net_device *net_dev)
+{
+	unsigned long miss, rxerr, rxfram, rxcrc, rxoflow;
+	struct arc_emac_priv *priv = netdev_priv(net_dev);
+
+	rxerr = EMAC_REG_GET(priv->reg_base_addr, R_RXERR);
+	miss = EMAC_REG_GET(priv->reg_base_addr, R_MISS);
+
+	rxcrc = (rxerr & 0xff);
+	rxfram = (rxerr >> 8 & 0xff);
+	rxoflow = (rxerr >> 16 & 0xff);
+
+	priv->stats.rx_errors += miss;
+	priv->stats.rx_errors += rxcrc + rxfram + rxoflow;
+
+	priv->stats.rx_over_errors += rxoflow;
+	priv->stats.rx_frame_errors += rxfram;
+	priv->stats.rx_crc_errors += rxcrc;
+	priv->stats.rx_missed_errors += miss;
+
+	return &priv->stats;
+}
+
+/**
+ * arc_emac_tx - Starts the data transmission.
+ * @skb:		sk_buff pointer that contains data to be Transmitted.
+ * @net_dev:	Pointer to net_device structure.
+ *
+ * returns: NETDEV_TX_OK, on success
+ *		NETDEV_TX_BUSY, if any of the descriptors are not free.
+ *
+ * This function is invoked from upper layers to initiate transmission.
+ */
+int arc_emac_tx(struct sk_buff *skb, struct net_device *net_dev)
+{
+	int len, bitmask;
+	unsigned int info;
+	char *pkt;
+	struct arc_emac_priv *priv = netdev_priv(net_dev);
+
+	len = skb->len < ETH_ZLEN ? ETH_ZLEN : skb->len;
+	pkt = skb->data;
+	net_dev->trans_start = jiffies;
+
+	dma_map_single(&net_dev->dev, (void *)pkt, len, DMA_TO_DEVICE);
+
+	/* Set first bit */
+	bitmask = FRST_MASK;
+
+tx_next_chunk:
+
+	info = priv->txbd[priv->txbd_curr].info;
+	if (likely((info & OWN_MASK) == FOR_CPU)) {
+		priv->txbd[priv->txbd_curr].data = pkt;
+
+		/* This case handles 2 scenarios:
+		 * 1. pkt fits into 1 BD (2k)
+		 * 2. Last chunk of pkt (in multiples of 2k)
+		 */
+		if (likely(len <= TX_FIFO_SIZE)) {
+			priv->tx_skbuff[priv->txbd_curr] = skb;
+
+			/* Set data length, bit mask and give ownership to
+			 * EMAC This should be the last thing we do. EMAC
+			 * might immediately start sending
+			 */
+			priv->txbd[priv->txbd_curr].info =
+					FOR_EMAC |
+					bitmask |
+					LAST_MASK |
+					len;
+
+			/* Set TXPOLL bit to force a poll */
+			EMAC_REG_SET(priv->reg_base_addr, R_STATUS, TXPL_MASK);
+
+			priv->txbd_curr = (priv->txbd_curr + 1) % TX_BD_NUM;
+			return NETDEV_TX_OK;
+		} else {
+			/* if pkt > 2k, this case handles all non last chunks */
+			priv->txbd[priv->txbd_curr].info =
+					FOR_EMAC |
+					bitmask |
+					(len & (TX_FIFO_SIZE - 1));
+
+			/* clear the FIRST CHUNK bit */
+			bitmask = 0;
+
+			len -= TX_FIFO_SIZE;
+		}
+
+		priv->txbd_curr = (priv->txbd_curr + 1) % TX_BD_NUM;
+		goto tx_next_chunk;
+
+	} else {
+		return NETDEV_TX_BUSY;
+	}
+}
+
+/**
+ * arc_emac_set_address - Set the MAC address for this device.
+ * @net_dev:	Pointer to net_device structure.
+ * @p:			6 byte Address to be written as MAC address.
+ *
+ * This function copies the HW address from the sockaddr structure to the
+ * net_device structure and updates the address in HW.
+ *
+ * returns:	-EBUSY if the net device is busy or 0 if the address is set
+ *		successfully.
+ */
+int arc_emac_set_address(struct net_device *net_dev, void *p)
+{
+	struct sockaddr *addr = p;
+	struct arc_emac_priv *priv = netdev_priv(net_dev);
+
+	if (netif_running(net_dev))
+		return -EBUSY;
+
+	memcpy(net_dev->dev_addr, addr->sa_data, net_dev->addr_len);
+
+	EMAC_REG_SET(priv->reg_base_addr, R_ADDRL,
+			*(unsigned int *)net_dev->dev_addr);
+	EMAC_REG_SET(priv->reg_base_addr, R_ADDRH,
+			(*(unsigned int *)&net_dev->dev_addr[4]) & 0x0000ffff);
+
+	return 0;
+}
+
+static const struct net_device_ops arc_emac_netdev_ops = {
+	.ndo_open = arc_emac_open,
+	.ndo_stop = arc_emac_stop,
+	.ndo_start_xmit = arc_emac_tx,
+	.ndo_set_mac_address = arc_emac_set_address,
+	.ndo_get_stats = arc_emac_stats,
+};
+
+static int arc_emac_probe(struct platform_device *pdev)
+{
+	struct net_device *net_dev;
+	struct arc_emac_priv *priv;
+	int err;
+	unsigned int clock_frequency;
+	unsigned int id;
+	struct resource res_regs;
+#ifdef CONFIG_OF_IRQ
+	struct resource res_irq;
+#endif
+	const char *mac_addr = NULL;
+
+	/* no device tree device */
+	if (!pdev->dev.of_node)
+		return -ENODEV;
+
+	net_dev = alloc_etherdev(sizeof(struct arc_emac_priv));
+	if (!net_dev) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	SET_NETDEV_DEV(net_dev, &pdev->dev);
+
+	/* Populate our net_device structure */
+	net_dev->netdev_ops = &arc_emac_netdev_ops;
+	net_dev->ethtool_ops = &arc_emac_ethtool_ops;
+	net_dev->watchdog_timeo = TX_TIMEOUT;
+	/* FIXME :: no multicast support yet */
+	net_dev->flags &= ~IFF_MULTICAST;
+
+	priv = netdev_priv(net_dev);
+	priv->net_dev = net_dev;
+
+	/* Get phy from device tree */
+	priv->phy_node = of_parse_phandle(pdev->dev.of_node, "phy", 0);
+	if (!priv->phy_node) {
+		dev_err(&pdev->dev,
+			"failed to retrieve phy description from device tree\n");
+		err = -ENODEV;
+		goto out;
+	}
+
+	/* Get EMAC registers base address from device tree */
+	err = of_address_to_resource(pdev->dev.of_node, 0, &res_regs);
+	if (err) {
+		dev_err(&pdev->dev,
+			"failed to retrieve base register from device tree\n");
+		err = -ENODEV;
+		goto out;
+	}
+
+	if (!devm_request_mem_region(&pdev->dev, res_regs.start,
+			resource_size(&res_regs), pdev->name)) {
+		dev_err(&pdev->dev,
+			"failed to request memory region for base registers\n");
+		err = -ENXIO;
+		goto out;
+	}
+
+	priv->reg_base_addr = (void *) devm_ioremap_nocache(&pdev->dev,
+			res_regs.start, resource_size(&res_regs));
+	if (!priv->reg_base_addr) {
+		dev_err(&pdev->dev, "failed to ioremap MAC registers\n");
+		err = -ENXIO;
+		goto out;
+	}
+	dev_dbg(&pdev->dev,
+		"Registers base address is 0x%p\n", priv->reg_base_addr);
+
+	id = EMAC_REG_GET(priv->reg_base_addr, R_ID);
+	/* Check for EMAC revision 5 or 7, magic number */
+	if (!(id == 0x0005fd02 || id == 0x0007fd02)) {
+		dev_err(&pdev->dev,
+			"ARC EMAC not detected, read id=0x%x\n", id);
+		err = -ENODEV;
+		goto out;
+	}
+	dev_info(&pdev->dev, "ARC EMAC detected with id: 0x%x\n", id);
+
+	/* Get CPU clock frequency from device tree */
+	if (of_property_read_u32(pdev->dev.of_node, "clock-frequency",
+			&clock_frequency)) {
+		dev_err(&pdev->dev,
+			"can't read <clock-frequency> from device tree\n");
+		err = -EINVAL;
+		goto out;
+	}
+	priv->clock_frequency = clock_frequency;
+
+	/* Get IRQ from device tree */
+#ifdef CONFIG_OF_IRQ
+	err = of_irq_to_resource(pdev->dev.of_node, 0, &res_irq);
+	if (!err) {
+		dev_err(&pdev->dev,
+			"failed to retrieve <irq> value from device tree\n");
+		err = -ENODEV;
+		goto out;
+	}
+	net_dev->irq = res_irq.start;
+#endif
+	dev_info(&pdev->dev, "IRQ is %d\n", net_dev->irq);
+
+	/* Register interrupt handler for device */
+	err = devm_request_irq(&pdev->dev, net_dev->irq, arc_emac_intr, 0,
+			net_dev->name, net_dev);
+	if (err) {
+		dev_err(&pdev->dev, "could not allocate IRQ\n");
+		goto out;
+	}
+
+	/* Get MAC address from device tree */
+#ifdef CONFIG_OF_NET
+	mac_addr = of_get_mac_address(pdev->dev.of_node);
+#endif
+	if (!mac_addr || !is_valid_ether_addr(mac_addr))
+		eth_hw_addr_random(net_dev);
+	else
+		memcpy(net_dev->dev_addr, mac_addr, ETH_ALEN);
+
+	dev_info(&pdev->dev, "MAC address is now %pM\n", net_dev->dev_addr);
+
+	/* Allocate cache coherent memory for BD Rings - to avoid need to do
+	 * explicit uncached ".di" accesses, which can potentially screw-up
+	 */
+	priv->rxbd = (struct arc_emac_bd_t *)dmam_alloc_coherent(&pdev->dev,
+		RX_RING_SZ + TX_RING_SZ, &priv->rxbd_dma_hdl, GFP_KERNEL);
+
+	if (!priv->rxbd) {
+		dev_err(&pdev->dev, "failed to allocate data buffers\n");
+		err = -ENOMEM;
+		goto out;
+	}
+
+	priv->txbd = priv->rxbd + RX_BD_NUM;
+
+	/* To keep things simple - we just do 1 big allocation, instead of 2
+	 * separate ones for Rx and Tx Rings responsively
+	 */
+	priv->txbd_dma_hdl = priv->rxbd_dma_hdl + RX_RING_SZ;
+	dev_dbg(&pdev->dev, "EMAC Device addr: Rx Ring [0x%x], Tx Ring[%x]\n",
+		(unsigned int)priv->rxbd_dma_hdl,
+		(unsigned int)priv->txbd_dma_hdl);
+
+	priv->mdio_priv = devm_kzalloc(&pdev->dev, sizeof(struct arc_mdio_priv),
+		GFP_KERNEL);
+
+	if (!priv->mdio_priv) {
+		dev_err(&pdev->dev,
+			"cannot allocate memory for MDIO private structure\n");
+		err = -ENOMEM;
+		goto out;
+	}
+
+	priv->mdio_priv->reg_base_addr = priv->reg_base_addr;
+	priv->mdio_priv->dev = &pdev->dev;
+
+	err = arc_mdio_probe(pdev->dev.of_node, priv->mdio_priv);
+	if (err) {
+		dev_err(&pdev->dev, "failed to probe MII bus\n");
+		goto out;
+	}
+
+	netif_napi_add(net_dev, &priv->napi, arc_emac_poll, NAPI_WEIGHT);
+
+	err = register_netdev(net_dev);
+	if (err) {
+		netif_napi_del(&priv->napi);
+		dev_err(&pdev->dev, "failed to register network device\n");
+		goto out;
+	}
+
+	return 0;
+
+out:
+	free_netdev(net_dev);
+	return err;
+}
+
+static int arc_emac_remove(struct platform_device *pdev)
+{
+	struct net_device *net_dev = platform_get_drvdata(pdev);
+	struct arc_emac_priv *priv = netdev_priv(net_dev);
+
+	arc_mdio_remove(priv->mdio_priv);
+	unregister_netdev(net_dev);
+	netif_napi_del(&priv->napi);
+	free_netdev(net_dev);
+
+	return 0;
+}
+
+static const struct of_device_id arc_emac_dt_ids[] = {
+	{ .compatible = "snps,arc-emac" },
+	{ /* Sentinel */ }
+};
+MODULE_DEVICE_TABLE(of, arc_emac_dt_ids);
+
+static struct platform_driver arc_emac_driver = {
+		.probe = arc_emac_probe,
+		.remove = arc_emac_remove,
+		.driver = {
+			.name = DRV_NAME,
+			.owner = THIS_MODULE,
+			.of_match_table  = arc_emac_dt_ids,
+			},
+};
+
+module_platform_driver(arc_emac_driver);
+
+MODULE_AUTHOR("Alexey Brodkin <abrodkin@synopsys.com>");
+MODULE_DESCRIPTION("ARC EMAC driver");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/arc/arc_emac_main.h b/drivers/net/ethernet/arc/arc_emac_main.h
new file mode 100644
index 0000000..6f03d26
--- /dev/null
+++ b/drivers/net/ethernet/arc/arc_emac_main.h
@@ -0,0 +1,82 @@
+/*
+ * Copyright (C) 2004, 2007-2010, 2011-2013 Synopsys, Inc. (www.synopsys.com)
+ *
+ * Definitions for ARC EMAC device driver
+ */
+
+#ifndef ARC_EMAC_H
+#define ARC_EMAC_H
+
+/* Transmission timeout */
+#define TX_TIMEOUT (400*HZ/1000)
+
+#define NAPI_WEIGHT 40		/* Workload for NAPI */
+
+#define TX_FIFO_SIZE 0x800	/* EMAC Tx FIFO size */
+
+/* Assuming MTU=1500 (IP pkt: hdr+payload), we round off to next cache-line
+ * boundary: 1536 % {32,64,128} == 0
+ * This provides enough space for Ethernet header (14) and also ensures that
+ * buf-size passed to EMAC > max pkt rx (1514). Latter is due to a EMAC quirk
+ * wherein it can generate a chained pkt (with all data in first part, and
+ * an empty 2nd part - albeit with last bit set) when Rx-pkt-sz is exactly
+ * equal to buf-size: hence the need to keep buf-size slightly bigger than
+ * largest pkt.
+ */
+#define	EMAC_BUFFER_PAD 36
+
+struct arc_emac_bd_t {
+	unsigned int info;
+	void *data;
+};
+
+/* Number of Rx/Tx BD's */
+#define RX_BD_NUM	128
+#define TX_BD_NUM	128
+
+#define RX_RING_SZ  (RX_BD_NUM * sizeof(struct arc_emac_bd_t))
+#define TX_RING_SZ  (TX_BD_NUM * sizeof(struct arc_emac_bd_t))
+
+struct arc_emac_priv {
+	struct net_device_stats stats;
+	unsigned int clock_frequency;
+
+	/* Pointers to BD rings - CPU side */
+	struct arc_emac_bd_t *rxbd;
+	struct arc_emac_bd_t *txbd;
+
+	/* Pointers to BD rings - Device side */
+	dma_addr_t rxbd_dma_hdl;
+	dma_addr_t txbd_dma_hdl;
+
+	/* The actual socket buffers */
+	struct sk_buff *rx_skbuff[RX_BD_NUM];
+	struct sk_buff *tx_skbuff[TX_BD_NUM];
+	unsigned int txbd_curr;
+	unsigned int txbd_dirty;
+
+	/* Remember where driver last saw a packet, so next iteration it
+	 * starts from here and not 0
+	 */
+	unsigned int last_rx_bd;
+
+	struct napi_struct napi;
+
+	/* Storage for "arc_emac_adjust_link" */
+	int old_link;
+	int old_speed;
+	int old_duplex;
+
+	/* Devices */
+	struct device_node *phy_node;
+	struct phy_device *phy_dev;
+	struct net_device *net_dev;
+
+	/* MDIO private structure */
+	struct arc_mdio_priv *mdio_priv;
+
+	/* EMAC registers base address */
+	void *reg_base_addr;
+};
+
+#endif /* ARC_EMAC_H */
diff --git a/drivers/net/ethernet/arc/arc_emac_mdio.c b/drivers/net/ethernet/arc/arc_emac_mdio.c
new file mode 100644
index 0000000..f8cf5aa
--- /dev/null
+++ b/drivers/net/ethernet/arc/arc_emac_mdio.c
@@ -0,0 +1,181 @@
+/*
+ * Copyright (C) 2004, 2007-2010, 2011-2013 Synopsys, Inc. (www.synopsys.com)
+ *
+ * MDIO implementation for ARC EMAC
+ */
+
+#include <linux/delay.h>
+#include <linux/of_mdio.h>
+
+#include "arc_emac_regs.h"
+#include "arc_emac_mdio.h"
+
+/* Number of seconds we wait for "MDIO complete" flag to appear */
+#define ARC_MDIO_COMPLETE_POLL_COUNT	1
+
+/**
+ * arc_mdio_complete_wait - Waits until MDIO transaction is completed.
+ * @priv:	Pointer to ARC MDIO private data structure.
+ *
+ * returns:	0 on success, -ETIMEDOUT on a timeout.
+ */
+static inline int arc_mdio_complete_wait(struct arc_mdio_priv *priv)
+{
+	unsigned int status;
+	unsigned int count = (ARC_MDIO_COMPLETE_POLL_COUNT * 40);
+
+	while (1) {
+		/* Read STATUS register from EMAC */
+		status = EMAC_REG_GET(priv->reg_base_addr, R_STATUS);
+		/* Mask "MDIO complete" bit */
+		status &= MDIO_MASK;
+		if (status) {
+			/* Reset "MDIO complete" flag */
+			EMAC_REG_SET(priv->reg_base_addr, R_STATUS, status);
+			break;
+		}
+
+		/* Make sure we never get into infinite loop */
+		if (count-- == 0) {
+			WARN_ON(1);
+			/* Still we prefer to exit from this loop */
+			return -ETIMEDOUT;
+		}
+		msleep(25);
+	}
+	return 0;
+}
+
+/**
+ * arc_mdio_read - MDIO interface read function.
+ * @bus:		Pointer to MII bus structure.
+ * @phy_addr:	Address of the PHY device.
+ * @reg_num:	PHY register to read.
+ *
+ * returns:	The register contents on success, -ETIMEDOUT on a timeout.
+ *
+ * Reads the contents of the requested register from the requested PHY
+ * address.
+ */
+static int arc_mdio_read(struct mii_bus *bus, int phy_addr, int reg_num)
+{
+	int error;
+	unsigned int value;
+	struct arc_mdio_priv *priv = bus->priv;
+
+	EMAC_REG_SET(priv->reg_base_addr,
+		R_MDIO, 0x60020000 |
+		(phy_addr << 23) |
+		(reg_num << 18));
+
+	error = arc_mdio_complete_wait(priv);
+	if (error < 0)
+		return error;
+
+	value = EMAC_REG_GET(priv->reg_base_addr, R_MDIO) & 0xffff;
+
+	dev_dbg(priv->dev, "arc_mdio_read(phy_addr=%i, reg_num=%x) = %x\n",
+		phy_addr, reg_num, value);
+
+	return value;
+}
+
+/**
+ * arc_mdio_write - MDIO interface write function.
+ * @bus:		Pointer to MII bus structure.
+ * @phy_addr:	Address of the PHY device.
+ * @reg_num:	PHY register to write to.
+ * @value:		Value to be written into the register.
+ *
+ * returns:	0 on success, -ETIMEDOUT on a timeout.
+ *
+ * Writes the value to the requested register.
+ */
+static int arc_mdio_write(struct mii_bus *bus, int phy_addr,
+		int reg_num, u16 value)
+{
+	struct arc_mdio_priv *priv = bus->priv;
+
+	dev_dbg(priv->dev,
+		"arc_mdio_write(phy_addr=%i, reg_num=%x, value=%x)\n",
+		phy_addr, reg_num, value);
+
+	EMAC_REG_SET(priv->reg_base_addr, R_MDIO,
+		0x50020000 |
+		(phy_addr << 23) |
+		(reg_num << 18) |
+		(value & 0xffff));
+
+	return arc_mdio_complete_wait(priv);
+}
+
+/**
+ * arc_mdio_probe - MDIO probe function.
+ * @dev_node:	Pointer to device node.
+ * @priv:		Pointer to ARC MDIO private data structure.
+ *
+ * returns:	0 on success, -ENOMEM when mdiobus_alloc
+ * (to allocate memory for MII bus structure) fails.
+ *
+ * Sets up and registers the MDIO interface.
+ */
+int arc_mdio_probe(struct device_node *dev_node, struct arc_mdio_priv *priv)
+{
+	struct device_node *mdio_np;
+	struct mii_bus *bus;
+	int error;
+
+	bus = mdiobus_alloc();
+	if (!bus) {
+		error = -ENOMEM;
+		goto cleanup;
+	}
+
+	priv->bus = bus;
+	bus->priv = priv;
+	bus->name = "Synopsys MII Bus",
+	bus->read = &arc_mdio_read;
+	bus->write = &arc_mdio_write;
+
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%.8x",
+			(unsigned int)priv->reg_base_addr);
+
+	bus->parent = priv->dev;
+
+	mdio_np = of_find_node_by_name(NULL, "mdio");
+	if (!mdio_np) {
+		dev_err(priv->dev, "cannot find <mdio> in device tree\n");
+		error = -ENODEV;
+		goto cleanup;
+	}
+
+	error = of_mdiobus_register(bus, mdio_np);
+	if (error) {
+		dev_err(priv->dev,
+			"cannot register %s as MDIO bus\n", bus->name);
+		goto cleanup;
+	}
+
+	return 0;
+
+cleanup:
+	if (bus)
+		mdiobus_free(bus);
+
+	return error;
+}
+
+/**
+ * arc_mdio_remove - MDIO remove function.
+ * @priv:	Pointer to ARC MDIO private data structure.
+ *
+ * Unregisters the MDIO and frees any associate memory for MII bus.
+ */
+int arc_mdio_remove(struct arc_mdio_priv *priv)
+{
+	mdiobus_unregister(priv->bus);
+	mdiobus_free(priv->bus);
+	priv->bus = NULL;
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/arc/arc_emac_mdio.h b/drivers/net/ethernet/arc/arc_emac_mdio.h
new file mode 100644
index 0000000..9ddabf9
--- /dev/null
+++ b/drivers/net/ethernet/arc/arc_emac_mdio.h
@@ -0,0 +1,22 @@
+/*
+ * Copyright (C) 2004, 2007-2010, 2011-2013 Synopsys, Inc. (www.synopsys.com)
+ *
+ * Definitions for MDIO of ARC EMAC device driver
+ */
+
+#ifndef ARC_MDIO_H
+#define ARC_MDIO_H
+
+#include <linux/device.h>
+#include <linux/phy.h>
+
+struct arc_mdio_priv {
+	struct mii_bus *bus;
+	struct device *dev;
+	void *reg_base_addr; /* MAC registers base address */
+};
+
+int arc_mdio_probe(struct device_node *np, struct arc_mdio_priv *priv);
+int arc_mdio_remove(struct arc_mdio_priv *priv);
+
+#endif /* ARC_MDIO_H */
diff --git a/drivers/net/ethernet/arc/arc_emac_regs.h b/drivers/net/ethernet/arc/arc_emac_regs.h
new file mode 100644
index 0000000..14c85a2
--- /dev/null
+++ b/drivers/net/ethernet/arc/arc_emac_regs.h
@@ -0,0 +1,73 @@
+/*
+ * Copyright (C) 2004, 2007-2010, 2011-2013 Synopsys, Inc. (www.synopsys.com)
+ *
+ * Registers and bits definitions of ARC EMAC
+ */
+
+#ifndef ARC_EMAC_REGS_H
+#define ARC_EMAC_REGS_H
+
+/* STATUS and ENABLE Register bit masks */
+#define TXINT_MASK	(1<<0)	/* Transmit interrupt */
+#define RXINT_MASK	(1<<1)	/* Receive interrupt */
+#define ERR_MASK	(1<<2)	/* Error interrupt */
+#define TXCH_MASK	(1<<3)	/* Transmit chaining error interrupt */
+#define MSER_MASK	(1<<4)	/* Missed packet counter error */
+#define RXCR_MASK	(1<<8)	/* RXCRCERR counter rolled over  */
+#define RXFR_MASK	(1<<9)	/* RXFRAMEERR counter rolled over */
+#define RXFL_MASK	(1<<10)	/* RXOFLOWERR counter rolled over */
+#define MDIO_MASK	(1<<12)	/* MDIO complete interrupt */
+#define TXPL_MASK	(1<<31)	/* TXPOLL */
+
+/* CONTROL Register bit masks */
+#define EN_MASK		(1<<0)	/* VMAC enable */
+#define TXRN_MASK	(1<<3)	/* TX enable */
+#define RXRN_MASK	(1<<4)	/* RX enable */
+#define DSBC_MASK	(1<<8)	/* Disable receive broadcast */
+#define ENFL_MASK	(1<<10)	/* Enable Full-duplex */
+#define PROM_MASK	(1<<11)	/* Promiscuous mode */
+
+/* Buffer descriptor INFO bit masks */
+#define OWN_MASK	(1<<31)	/* 0-CPU owns buffer, 1-EMAC owns buffer */
+#define FRST_MASK	(1<<16)	/* First buffer in chain */
+#define LAST_MASK	(1<<17)	/* Last buffer in chain */
+#define LEN_MASK	0x000007FF	/* last 11 bits */
+#define CRLS		(1<<21)
+#define DEFR		(1<<22)
+#define DROP		(1<<23)
+#define RTRY		(1<<24)
+#define LTCL		(1<<28)
+#define UFLO		(1<<29)
+
+#define FOR_EMAC	OWN_MASK
+#define FOR_CPU		0
+
+/* ARC EMAC register set combines entries for MAC and MDIO */
+enum {
+	R_ID = 0,
+	R_STATUS,
+	R_ENABLE,
+	R_CTRL,
+	R_POLLRATE,
+	R_RXERR,
+	R_MISS,
+	R_TX_RING,
+	R_RX_RING,
+	R_ADDRL,
+	R_ADDRH,
+	R_LAFL,
+	R_LAFH,
+	R_MDIO,
+};
+
+#define EMAC_REG_SET(reg_base_addr, reg, val)	iowrite32((val), \
+							reg_base_addr + \
+							reg * sizeof(int))
+
+#define EMAC_REG_GET(reg_base_addr, reg)	ioread32(reg_base_addr + \
+							reg * sizeof(int))
+
+#define EMAC_REG_OR(b, r, v)  EMAC_REG_SET(b, r, EMAC_REG_GET(b, r) | (v))
+#define EMAC_REG_CLR(b, r, v) EMAC_REG_SET(b, r, EMAC_REG_GET(b, r) & ~(v))
+
+#endif /* ARC_EMAC_REGS_H */
-- 
1.7.10.4
