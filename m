From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: [PATCH v7] ethernet/arc/arc_emac - Add new driver
Date: Fri, 21 Jun 2013 11:20:41 +0400
Message-ID: <1371799241-27771-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"Joe Perches" <joe@perches.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	"Paul Gortmaker" <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>,
	<devicetree-discuss@lists.ozlabs.org>,
	Florian Fainelli <florian@openwrt.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Driver for non-standard on-chip ethernet device ARC EMAC 10/100,
instantiated in some legacy ARC (Synopsys) FPGA Boards such as
ARCAngel4/ML50x.

Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>

Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Joe Perches <joe@perches.com>
Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: Mischa Jonker <mjonker@synopsys.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Grant Likely <grant.likely@linaro.org>
Cc: Rob Herring <rob.herring@calxeda.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
Cc: Florian Fainelli <florian@openwrt.org>

---
Hi all,

please take a look at 7th re-spin of the patch.

Here I addressed another set of comments from Andy Shevchenko.

1. Re-use FIRST_OR_LAST_MASK more extensively.
2. Use write-specific barrier "wmb()" instead of generic "mb()".
3. Do netdev allocation as late as possible.
---
 Documentation/devicetree/bindings/net/arc_emac.txt |   38 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/arc/Kconfig                   |   31 +
 drivers/net/ethernet/arc/Makefile                  |    6 +
 drivers/net/ethernet/arc/emac.h                    |  214 ++++++
 drivers/net/ethernet/arc/emac_main.c               |  806 ++++++++++++++++++++
 drivers/net/ethernet/arc/emac_mdio.c               |  152 ++++
 8 files changed, 1249 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/arc_emac.txt
 create mode 100644 drivers/net/ethernet/arc/Kconfig
 create mode 100644 drivers/net/ethernet/arc/Makefile
 create mode 100644 drivers/net/ethernet/arc/emac.h
 create mode 100644 drivers/net/ethernet/arc/emac_main.c
 create mode 100644 drivers/net/ethernet/arc/emac_mdio.c

diff --git a/Documentation/devicetree/bindings/net/arc_emac.txt b/Documentation/devicetree/bindings/net/arc_emac.txt
new file mode 100644
index 0000000..bcbc3f0
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/arc_emac.txt
@@ -0,0 +1,38 @@
+* Synopsys ARC EMAC 10/100 Ethernet driver (EMAC)
+
+Required properties:
+- compatible: Should be "snps,arc-emac"
+- reg: Address and length of the register set for the device
+- interrupts: Should contain the EMAC interrupts
+- clock-frequency: CPU frequency. It is needed to calculate and set polling
+period of EMAC.
+- max-speed: Maximum supported data-rate in Mbit/s. In some HW configurations
+bandwidth of external memory controller might be a limiting factor. That's why
+it's required to specify which data-rate is supported on current SoC or FPGA.
+For example if only 10 Mbit/s is supported (10BASE-T) set "10". If 100 Mbit/s is
+supported (100BASE-TX) set "100".
+- phy: PHY device attached to the EMAC via MDIO bus
+
+Child nodes of the driver are the individual PHY devices connected to the
+MDIO bus. They must have a "reg" property given the PHY address on the MDIO bus.
+
+Optional properties:
+- mac-address: 6 bytes, mac address
+
+Examples:
+
+	ethernet@c0fc2000 {
+		compatible = "snps,arc-emac";
+		reg = <0xc0fc2000 0x3c>;
+		interrupts = <6>;
+		mac-address = [ 00 11 22 33 44 55 ];
+		clock-frequency = <80000000>;
+		max-speed = <100>;
+		phy = <&phy0>;
+
+		#address-cells = <1>;
+		#size-cells = <0>;
+		phy0: ethernet-phy@0 {
+			reg = <1>;
+		};
+	};
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 4bedae2..98eec48 100644
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
index 183e3f4..b764c73 100644
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
index 0000000..514c57f
--- /dev/null
+++ b/drivers/net/ethernet/arc/Kconfig
@@ -0,0 +1,31 @@
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
+	depends on OF_IRQ
+	depends on OF_NET
+	---help---
+	  On some legacy ARC (Synopsys) FPGA boards such as ARCAngel4/ML50x
+	  non-standard on-chip ethernet device ARC EMAC 10/100 is used.
+	  Say Y here if you have such a board.  If unsure, say N.
+
+endif # NET_VENDOR_ARC
diff --git a/drivers/net/ethernet/arc/Makefile b/drivers/net/ethernet/arc/Makefile
new file mode 100644
index 0000000..00c8657
--- /dev/null
+++ b/drivers/net/ethernet/arc/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the ARC network device drivers.
+#
+
+arc_emac-objs := emac_main.o emac_mdio.o
+obj-$(CONFIG_ARC_EMAC) += arc_emac.o
diff --git a/drivers/net/ethernet/arc/emac.h b/drivers/net/ethernet/arc/emac.h
new file mode 100644
index 0000000..99adf0f
--- /dev/null
+++ b/drivers/net/ethernet/arc/emac.h
@@ -0,0 +1,214 @@
+/*
+ * Copyright (C) 2004-2013 Synopsys, Inc. (www.synopsys.com)
+ *
+ * Registers and bits definitions of ARC EMAC
+ */
+
+#ifndef ARC_EMAC_H
+#define ARC_EMAC_H
+
+#include <linux/device.h>
+#include <linux/dma-mapping.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
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
+#define TXPL_MASK	(1<<31)	/* Force polling of BD by EMAC */
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
+#define FIRST_MASK	(1<<16)	/* First buffer in chain */
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
+#define TX_TIMEOUT		(400*HZ/1000)	/* Transmission timeout */
+
+#define ARC_EMAC_NAPI_WEIGHT	40		/* Workload for NAPI */
+
+#define EMAC_BUFFER_SIZE	1536		/* EMAC buffer size */
+
+/**
+ * struct arc_emac_bd - EMAC buffer descriptor (BD).
+ *
+ * @info:	Contains status information on the buffer itself.
+ * @data:	32-bit byte addressable pointer to the packet data.
+ */
+struct arc_emac_bd {
+	__le32 info;
+	unsigned char *data;
+};
+
+/* Number of Rx/Tx BD's */
+#define RX_BD_NUM	128
+#define TX_BD_NUM	128
+
+#define RX_RING_SZ	(RX_BD_NUM * sizeof(struct arc_emac_bd))
+#define TX_RING_SZ	(TX_BD_NUM * sizeof(struct arc_emac_bd))
+
+/**
+ * struct buffer_state - Stores Rx/Tx buffer state.
+ * @sk_buff:	Pointer to socket buffer.
+ * @addr:	Start address of DMA-mapped memory region.
+ * @len:	Length of DMA-mapped memory region.
+ */
+struct buffer_state {
+	struct sk_buff *skb;
+	DEFINE_DMA_UNMAP_ADDR(addr);
+	DEFINE_DMA_UNMAP_LEN(len);
+};
+
+/**
+ * struct arc_emac_priv - Storage of EMAC's private information.
+ * @dev:	Pointer to the current device.
+ * @ndev:	Pointer to the current network device.
+ * @phy_dev:	Pointer to attached PHY device.
+ * @bus:	Pointer to the current MII bus.
+ * @regs:	Base address of EMAC memory-mapped control registers.
+ * @napi:	Structure for NAPI.
+ * @stats:	Network device statistics.
+ * @rxbd:	Pointer to Rx BD ring.
+ * @txbd:	Pointer to Tx BD ring.
+ * @rxbd_dma:	DMA handle for Rx BD ring.
+ * @txbd_dma:	DMA handle for Tx BD ring.
+ * @rx_buff:	Storage for Rx buffers states.
+ * @tx_buff:	Storage for Tx buffers states.
+ * @txbd_curr:	Index of Tx BD to use on the next "ndo_start_xmit".
+ * @txbd_dirty:	Index of Tx BD to free on the next Tx interrupt.
+ * @last_rx_bd:	Index of the last Rx BD we've got from EMAC.
+ * @link:	PHY's last seen link state.
+ * @duplex:	PHY's last set duplex mode.
+ * @speed:	PHY's last set speed.
+ * @max_speed:	Maximum supported by current system network data-rate.
+ */
+struct arc_emac_priv {
+	/* Devices */
+	struct device *dev;
+	struct net_device *ndev;
+	struct phy_device *phy_dev;
+	struct mii_bus *bus;
+
+	void __iomem *regs;
+
+	struct napi_struct napi;
+	struct net_device_stats stats;
+
+	struct arc_emac_bd *rxbd;
+	struct arc_emac_bd *txbd;
+
+	dma_addr_t rxbd_dma;
+	dma_addr_t txbd_dma;
+
+	struct buffer_state rx_buff[RX_BD_NUM];
+	struct buffer_state tx_buff[TX_BD_NUM];
+	unsigned int txbd_curr;
+	unsigned int txbd_dirty;
+
+	unsigned int last_rx_bd;
+
+	unsigned int link;
+	unsigned int duplex;
+	unsigned int speed;
+	unsigned int max_speed;
+};
+
+/**
+ * arc_reg_set - Sets EMAC register with provided value.
+ * @priv:	Pointer to ARC EMAC private data structure.
+ * @reg:	Register offset from base address.
+ * @value:	Value to set in register.
+ */
+static inline void arc_reg_set(struct arc_emac_priv *priv, int reg, int value)
+{
+	iowrite32(value, priv->regs + reg * sizeof(int));
+}
+
+/**
+ * arc_reg_get - Gets value of specified EMAC register.
+ * @priv:	Pointer to ARC EMAC private data structure.
+ * @reg:	Register offset from base address.
+ *
+ * returns:	Value of requested register.
+ */
+static inline unsigned int arc_reg_get(struct arc_emac_priv *priv, int reg)
+{
+	return ioread32(priv->regs + reg * sizeof(int));
+}
+
+/**
+ * arc_reg_or - Applies mask to specified EMAC register - ("reg" | "mask").
+ * @priv:	Pointer to ARC EMAC private data structure.
+ * @reg:	Register offset from base address.
+ * @mask:	Mask to apply to specified register.
+ *
+ * This function reads initial register value, then applies provided mask
+ * to it and then writes register back.
+ */
+static inline void arc_reg_or(struct arc_emac_priv *priv, int reg, int mask)
+{
+	unsigned int value = arc_reg_get(priv, reg);
+	arc_reg_set(priv, reg, value | mask);
+}
+
+/**
+ * arc_reg_clr - Applies mask to specified EMAC register - ("reg" & ~"mask").
+ * @priv:	Pointer to ARC EMAC private data structure.
+ * @reg:	Register offset from base address.
+ * @mask:	Mask to apply to specified register.
+ *
+ * This function reads initial register value, then applies provided mask
+ * to it and then writes register back.
+ */
+static inline void arc_reg_clr(struct arc_emac_priv *priv, int reg, int mask)
+{
+	unsigned int value = arc_reg_get(priv, reg);
+	arc_reg_set(priv, reg, value & ~mask);
+}
+
+int arc_mdio_probe(struct platform_device *pdev, struct arc_emac_priv *priv);
+int arc_mdio_remove(struct arc_emac_priv *priv);
+
+#endif /* ARC_EMAC_H */
diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
new file mode 100644
index 0000000..1606cfb
--- /dev/null
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -0,0 +1,806 @@
+/*
+ * Copyright (C) 2004-2013 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Driver for the ARC EMAC 10100 (hardware revision 5)
+ *
+ * Contributors:
+ *		Amit Bhor
+ *		Sameer Dhavale
+ *		Vineet Gupta
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
+
+#include "emac.h"
+
+#define DRV_NAME	"arc_emac"
+#define DRV_VERSION	"1.0"
+
+/**
+ * arc_emac_adjust_link - Adjust the PHY link duplex.
+ * @ndev:	Pointer to the net_device structure.
+ *
+ * This function is called to change the duplex setting after auto negotiation
+ * is done by the PHY.
+ */
+static void arc_emac_adjust_link(struct net_device *ndev)
+{
+	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct phy_device *phy_dev = priv->phy_dev;
+	unsigned int reg, state_changed = 0;
+
+	if (priv->link != phy_dev->link) {
+		priv->link = phy_dev->link;
+		state_changed = 1;
+	}
+
+	if (priv->speed != phy_dev->speed) {
+		priv->speed = phy_dev->speed;
+		state_changed = 1;
+	}
+
+	if (priv->duplex != phy_dev->duplex) {
+		reg = arc_reg_get(priv, R_CTRL);
+
+		if (DUPLEX_FULL == phy_dev->duplex)
+			reg |= ENFL_MASK;
+		else
+			reg &= ~ENFL_MASK;
+
+		arc_reg_set(priv, R_CTRL, reg);
+		priv->duplex = phy_dev->duplex;
+		state_changed = 1;
+	}
+
+	if (state_changed)
+		phy_print_status(phy_dev);
+}
+
+/**
+ * arc_emac_get_settings - Get PHY settings.
+ * @ndev:	Pointer to net_device structure.
+ * @cmd:	Pointer to ethtool_cmd structure.
+ *
+ * This implements ethtool command for getting PHY settings. If PHY could
+ * not be found, the function returns -ENODEV. This function calls the
+ * relevant PHY ethtool API to get the PHY settings.
+ * Issue "ethtool ethX" under linux prompt to execute this function.
+ */
+static int arc_emac_get_settings(struct net_device *ndev,
+				 struct ethtool_cmd *cmd)
+{
+	struct arc_emac_priv *priv = netdev_priv(ndev);
+
+	return phy_ethtool_gset(priv->phy_dev, cmd);
+}
+
+/**
+ * arc_emac_set_settings - Set PHY settings as passed in the argument.
+ * @ndev:	Pointer to net_device structure.
+ * @cmd:	Pointer to ethtool_cmd structure.
+ *
+ * This implements ethtool command for setting various PHY settings. If PHY
+ * could not be found, the function returns -ENODEV. This function calls the
+ * relevant PHY ethtool API to set the PHY.
+ * Issue e.g. "ethtool -s ethX speed 1000" under linux prompt to execute this
+ * function.
+ */
+static int arc_emac_set_settings(struct net_device *ndev,
+				 struct ethtool_cmd *cmd)
+{
+	struct arc_emac_priv *priv = netdev_priv(ndev);
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	return phy_ethtool_sset(priv->phy_dev, cmd);
+}
+
+/**
+ * arc_emac_get_drvinfo - Get EMAC driver information.
+ * @ndev:	Pointer to net_device structure.
+ * @info:	Pointer to ethtool_drvinfo structure.
+ *
+ * This implements ethtool command for getting the driver information.
+ * Issue "ethtool -i ethX" under linux prompt to execute this function.
+ */
+static void arc_emac_get_drvinfo(struct net_device *ndev,
+				 struct ethtool_drvinfo *info)
+{
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+}
+
+static const struct ethtool_ops arc_emac_ethtool_ops = {
+	.get_settings	= arc_emac_get_settings,
+	.set_settings	= arc_emac_set_settings,
+	.get_drvinfo	= arc_emac_get_drvinfo,
+	.get_link	= ethtool_op_get_link,
+};
+
+#define FIRST_OR_LAST_MASK	(FIRST_MASK | LAST_MASK)
+
+/**
+ * arc_emac_tx_clean - clears processed by EMAC Tx BDs.
+ * @ndev:	Pointer to the network device.
+ */
+static void arc_emac_tx_clean(struct net_device *ndev)
+{
+	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct net_device_stats *stats = &priv->stats;
+	unsigned int i;
+
+	for (i = 0; i < TX_BD_NUM; i++) {
+		unsigned int *txbd_dirty = &priv->txbd_dirty;
+		struct arc_emac_bd *txbd = &priv->txbd[*txbd_dirty];
+		struct buffer_state *tx_buff = &priv->tx_buff[*txbd_dirty];
+		struct sk_buff *skb = tx_buff->skb;
+		unsigned int info = le32_to_cpu(txbd->info);
+
+		*txbd_dirty = (*txbd_dirty + 1) % TX_BD_NUM;
+
+		if ((info & FOR_EMAC) || !txbd->data)
+			break;
+
+		if (unlikely(info & (DROP | DEFR | LTCL | UFLO))) {
+			stats->tx_errors++;
+			stats->tx_dropped++;
+
+			if (info & DEFR)
+				stats->tx_carrier_errors++;
+
+			if (info & LTCL)
+				stats->collisions++;
+
+			if (info & UFLO)
+				stats->tx_fifo_errors++;
+		} else if (likely(info & FIRST_OR_LAST_MASK)) {
+			stats->tx_packets++;
+			stats->tx_bytes += skb->len;
+		}
+
+		dma_unmap_single(&ndev->dev, dma_unmap_addr(&tx_buff, addr),
+				 dma_unmap_len(&tx_buff, len), DMA_TO_DEVICE);
+
+		/* return the sk_buff to system */
+		dev_kfree_skb_irq(skb);
+
+		txbd->data = 0;
+		txbd->info = 0;
+
+		if (netif_queue_stopped(ndev))
+			netif_wake_queue(ndev);
+	}
+}
+
+/**
+ * arc_emac_rx - processing of Rx packets.
+ * @ndev:	Pointer to the network device.
+ * @budget:	How many BDs to process on 1 call.
+ *
+ * returns:	Number of processed BDs
+ *
+ * Iterate through Rx BDs and deliver received packages to upper layer.
+ */
+static int arc_emac_rx(struct net_device *ndev, int budget)
+{
+	struct arc_emac_priv *priv = netdev_priv(ndev);
+	unsigned int work_done;
+
+	for (work_done = 0; work_done <= budget; work_done++) {
+		unsigned int *last_rx_bd = &priv->last_rx_bd;
+		struct net_device_stats *stats = &priv->stats;
+		struct buffer_state *rx_buff = &priv->rx_buff[*last_rx_bd];
+		struct arc_emac_bd *rxbd = &priv->rxbd[*last_rx_bd];
+		unsigned int buflen = EMAC_BUFFER_SIZE;
+		unsigned int pktlen, info = le32_to_cpu(rxbd->info);
+		struct sk_buff *skb;
+		dma_addr_t addr;
+
+		if (unlikely((info & OWN_MASK) == FOR_EMAC))
+			break;
+
+		/* Make a note that we saw a packet at this BD.
+		 * So next time, driver starts from this + 1
+		 */
+		*last_rx_bd = (*last_rx_bd + 1) % RX_BD_NUM;
+
+		if (unlikely((info & FIRST_OR_LAST_MASK) !=
+			     FIRST_OR_LAST_MASK)) {
+			/* We pre-allocate buffers of MTU size so incoming
+			 * packets won't be split/chained.
+			 */
+			if (net_ratelimit())
+				netdev_err(ndev, "incomplete packed received\n");
+
+			/* Return ownership to EMAC */
+			rxbd->info = cpu_to_le32(FOR_EMAC | buflen);
+			stats->rx_errors++;
+			stats->rx_length_errors++;
+			continue;
+		}
+
+		pktlen = info & LEN_MASK;
+		stats->rx_packets++;
+		stats->rx_bytes += pktlen;
+		skb = rx_buff->skb;
+		skb_put(skb, pktlen);
+		skb->dev = ndev;
+		skb->protocol = eth_type_trans(skb, ndev);
+
+		dma_unmap_single(&ndev->dev, dma_unmap_addr(&rx_buff, addr),
+				 dma_unmap_len(&rx_buff, len), DMA_FROM_DEVICE);
+
+		/* Prepare the BD for next cycle */
+		rx_buff->skb = netdev_alloc_skb_ip_align(ndev, buflen);
+		if (unlikely(!rx_buff->skb)) {
+			stats->rx_errors++;
+			/* Because receive_skb is below, increment rx_dropped */
+			stats->rx_dropped++;
+			continue;
+		}
+
+		/* receive_skb only if new skb was allocated to avoid holes */
+		netif_receive_skb(skb);
+
+		addr = dma_map_single(&ndev->dev, (void *)rx_buff->skb->data,
+				      buflen, DMA_FROM_DEVICE);
+		if (dma_mapping_error(&ndev->dev, addr)) {
+			if (net_ratelimit())
+				netdev_err(ndev, "cannot dma map\n");
+			dev_kfree_skb(rx_buff->skb);
+			stats->rx_errors++;
+			continue;
+		}
+		dma_unmap_addr_set(&rx_buff, mapping, addr);
+		dma_unmap_len_set(&rx_buff, len, buflen);
+
+		rxbd->data = (unsigned char *)cpu_to_le32(rx_buff->skb->data);
+
+		/* Make sure pointer to data buffer is set */
+		wmb();
+
+		/* Return ownership to EMAC */
+		rxbd->info = cpu_to_le32(FOR_EMAC | buflen);
+	}
+
+	return work_done;
+}
+
+/**
+ * arc_emac_poll - NAPI poll handler.
+ * @napi:	Pointer to napi_struct structure.
+ * @budget:	How many BDs to process on 1 call.
+ *
+ * returns:	Number of processed BDs
+ */
+static int arc_emac_poll(struct napi_struct *napi, int budget)
+{
+	struct net_device *ndev = napi->dev;
+	struct arc_emac_priv *priv = netdev_priv(ndev);
+	unsigned int work_done;
+
+	arc_emac_tx_clean(ndev);
+
+	work_done = arc_emac_rx(ndev, budget);
+	if (work_done < budget) {
+		napi_complete(napi);
+		arc_reg_or(priv, R_ENABLE, RXINT_MASK);
+	}
+
+	return work_done;
+}
+
+/**
+ * arc_emac_intr - Global interrupt handler for EMAC.
+ * @irq:		irq number.
+ * @dev_instance:	device instance.
+ *
+ * returns: IRQ_HANDLED for all cases.
+ *
+ * ARC EMAC has only 1 interrupt line, and depending on bits raised in
+ * STATUS register we may tell what is a reason for interrupt to fire.
+ */
+static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
+{
+	struct net_device *ndev = dev_instance;
+	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct net_device_stats *stats = &priv->stats;
+	unsigned int status;
+
+	status = arc_reg_get(priv, R_STATUS);
+	status &= ~MDIO_MASK;
+
+	/* Reset all flags except "MDIO complete" */
+	arc_reg_set(priv, R_STATUS, status);
+
+	if (status & RXINT_MASK) {
+		if (likely(napi_schedule_prep(&priv->napi))) {
+			arc_reg_clr(priv, R_ENABLE, RXINT_MASK);
+			__napi_schedule(&priv->napi);
+		}
+	}
+
+	if (status & ERR_MASK) {
+		/* MSER/RXCR/RXFR/RXFL interrupt fires on corresponding
+		 * 8-bit error counter overrun.
+		 */
+
+		if (status & MSER_MASK) {
+			stats->rx_missed_errors += 0x100;
+			stats->rx_errors += 0x100;
+		}
+
+		if (status & RXCR_MASK) {
+			stats->rx_crc_errors += 0x100;
+			stats->rx_errors += 0x100;
+		}
+
+		if (status & RXFR_MASK) {
+			stats->rx_frame_errors += 0x100;
+			stats->rx_errors += 0x100;
+		}
+
+		if (status & RXFL_MASK) {
+			stats->rx_over_errors += 0x100;
+			stats->rx_errors += 0x100;
+		}
+	}
+
+	return IRQ_HANDLED;
+}
+
+/**
+ * arc_emac_open - Open the network device.
+ * @ndev:	Pointer to the network device.
+ *
+ * returns: 0, on success or non-zero error value on failure.
+ *
+ * This function sets the MAC address, requests and enables an IRQ
+ * for the EMAC device and starts the Tx queue.
+ * It also connects to the phy device.
+ */
+static int arc_emac_open(struct net_device *ndev)
+{
+	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct phy_device *phy_dev = priv->phy_dev;
+	struct arc_emac_bd *bd;
+	struct sk_buff *skb;
+	int i;
+
+	phy_dev->autoneg = AUTONEG_ENABLE;
+	phy_dev->speed = 0;
+	phy_dev->duplex = 0;
+	phy_dev->advertising = phy_dev->supported;
+
+	if (priv->max_speed > 100) {
+		phy_dev->advertising &= PHY_GBIT_FEATURES;
+	} else if (priv->max_speed <= 100) {
+		phy_dev->advertising &= PHY_BASIC_FEATURES;
+		if (priv->max_speed <= 10) {
+			phy_dev->advertising &= ~SUPPORTED_100baseT_Half;
+			phy_dev->advertising &= ~SUPPORTED_100baseT_Full;
+		}
+	}
+
+	/* Allocate and set buffers for Rx BD's */
+	bd = priv->rxbd;
+	for (i = 0; i < RX_BD_NUM; i++) {
+		skb = netdev_alloc_skb_ip_align(ndev, EMAC_BUFFER_SIZE);
+		if (unlikely(!skb))
+			return -ENOMEM;
+
+		priv->rx_buff[i].skb = skb;
+		bd->data = (unsigned char *)cpu_to_le32(skb->data);
+
+		/* Make sure pointer to data buffer is set */
+		wmb();
+
+		/* Set ownership to EMAC */
+		bd->info = cpu_to_le32(FOR_EMAC | EMAC_BUFFER_SIZE);
+		bd++;
+	}
+
+	priv->last_rx_bd = 0;
+
+	/* Clean Tx BD's */
+	memset(priv->txbd, 0, TX_RING_SZ);
+
+	/* Initialize logical address filter */
+	arc_reg_set(priv, R_LAFL, 0);
+	arc_reg_set(priv, R_LAFH, 0);
+
+	/* Set BD ring pointers for device side */
+	arc_reg_set(priv, R_RX_RING, (unsigned int)priv->rxbd_dma);
+	arc_reg_set(priv, R_TX_RING, (unsigned int)priv->txbd_dma);
+
+	/* Enable interrupts */
+	arc_reg_set(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
+
+	/* Set CONTROL */
+	arc_reg_set(priv, R_CTRL,
+		     (RX_BD_NUM << 24) |	/* RX BD table length */
+		     (TX_BD_NUM << 16) |	/* TX BD table length */
+		     TXRN_MASK | RXRN_MASK);
+
+	napi_enable(&priv->napi);
+
+	/* Enable EMAC */
+	arc_reg_or(priv, R_CTRL, EN_MASK);
+
+	phy_start_aneg(priv->phy_dev);
+
+	netif_start_queue(ndev);
+
+	return 0;
+}
+
+/**
+ * arc_emac_stop - Close the network device.
+ * @ndev:	Pointer to the network device.
+ *
+ * This function stops the Tx queue, disables interrupts and frees the IRQ for
+ * the EMAC device.
+ * It also disconnects the PHY device associated with the EMAC device.
+ */
+static int arc_emac_stop(struct net_device *ndev)
+{
+	struct arc_emac_priv *priv = netdev_priv(ndev);
+
+	napi_disable(&priv->napi);
+	netif_stop_queue(ndev);
+
+	/* Disable interrupts */
+	arc_reg_clr(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
+
+	/* Disable EMAC */
+	arc_reg_clr(priv, R_CTRL, EN_MASK);
+
+	return 0;
+}
+
+/**
+ * arc_emac_stats - Get system network statistics.
+ * @ndev:	Pointer to net_device structure.
+ *
+ * Returns the address of the device statistics structure.
+ * Statistics are updated in interrupt handler.
+ */
+static struct net_device_stats *arc_emac_stats(struct net_device *ndev)
+{
+	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct net_device_stats *stats = &priv->stats;
+	unsigned long miss, rxerr;
+	u8 rxcrc, rxfram, rxoflow;
+
+	rxerr = arc_reg_get(priv, R_RXERR);
+	miss = arc_reg_get(priv, R_MISS);
+
+	rxcrc = rxerr;
+	rxfram = rxerr >> 8;
+	rxoflow = rxerr >> 16;
+
+	stats->rx_errors += miss;
+	stats->rx_errors += rxcrc + rxfram + rxoflow;
+
+	stats->rx_over_errors += rxoflow;
+	stats->rx_frame_errors += rxfram;
+	stats->rx_crc_errors += rxcrc;
+	stats->rx_missed_errors += miss;
+
+	return stats;
+}
+
+/**
+ * arc_emac_tx - Starts the data transmission.
+ * @skb:	sk_buff pointer that contains data to be Transmitted.
+ * @ndev:	Pointer to net_device structure.
+ *
+ * returns: NETDEV_TX_OK, on success
+ *		NETDEV_TX_BUSY, if any of the descriptors are not free.
+ *
+ * This function is invoked from upper layers to initiate transmission.
+ */
+static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct arc_emac_priv *priv = netdev_priv(ndev);
+	unsigned int len, *txbd_curr = &priv->txbd_curr;
+	struct net_device_stats *stats = &priv->stats;
+	__le32 *info = &priv->txbd[*txbd_curr].info;
+	dma_addr_t addr;
+
+	if (skb_padto(skb, ETH_ZLEN))
+		return NETDEV_TX_OK;
+
+	len = max_t(unsigned int, ETH_ZLEN, skb->len);
+
+	/* EMAC still holds this buffer in its possession.
+	 * CPU must not modify this buffer descriptor
+	 */
+	if (unlikely((le32_to_cpu(*info) & OWN_MASK) == FOR_EMAC)) {
+		netif_stop_queue(ndev);
+		return NETDEV_TX_BUSY;
+	}
+
+	addr = dma_map_single(&ndev->dev, (void *)skb->data, len,
+			      DMA_TO_DEVICE);
+
+	if (unlikely(dma_mapping_error(&ndev->dev, addr))) {
+		stats->tx_dropped++;
+		stats->tx_errors++;
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+	dma_unmap_addr_set(&priv->tx_buff[*txbd_curr], mapping, addr);
+	dma_unmap_len_set(&priv->tx_buff[*txbd_curr], len, len);
+
+	priv->tx_buff[*txbd_curr].skb = skb;
+	priv->txbd[*txbd_curr].data = (unsigned char *)cpu_to_le32(skb->data);
+
+	/* Make sure pointer to data buffer is set */
+	wmb();
+
+	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
+
+	/* Increment index to point to the next BD */
+	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;
+
+	/* Get "info" of the next BD */
+	info = &priv->txbd[*txbd_curr].info;
+
+	/* Check if if Tx BD ring is full - next BD is still owned by EMAC */
+	if (unlikely((le32_to_cpu(*info) & OWN_MASK) == FOR_EMAC))
+		netif_stop_queue(ndev);
+
+	arc_reg_set(priv, R_STATUS, TXPL_MASK);
+
+	skb_tx_timestamp(skb);
+
+	return NETDEV_TX_OK;
+}
+
+/**
+ * arc_emac_set_address - Set the MAC address for this device.
+ * @ndev:	Pointer to net_device structure.
+ * @p:		6 byte Address to be written as MAC address.
+ *
+ * This function copies the HW address from the sockaddr structure to the
+ * net_device structure and updates the address in HW.
+ *
+ * returns:	-EBUSY if the net device is busy or 0 if the address is set
+ *		successfully.
+ */
+static int arc_emac_set_address(struct net_device *ndev, void *p)
+{
+	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct sockaddr *addr = p;
+	unsigned int addr_low, addr_hi;
+
+	if (netif_running(ndev))
+		return -EBUSY;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
+
+	addr_low = le32_to_cpu(*(__le32 *) &ndev->dev_addr[0]);
+	addr_hi = le16_to_cpu(*(__le16 *) &ndev->dev_addr[4]);
+
+	arc_reg_set(priv, R_ADDRL, addr_low);
+	arc_reg_set(priv, R_ADDRH, addr_hi);
+
+	return 0;
+}
+
+static const struct net_device_ops arc_emac_netdev_ops = {
+	.ndo_open		= arc_emac_open,
+	.ndo_stop		= arc_emac_stop,
+	.ndo_start_xmit		= arc_emac_tx,
+	.ndo_set_mac_address	= arc_emac_set_address,
+	.ndo_get_stats		= arc_emac_stats,
+};
+
+static int arc_emac_probe(struct platform_device *pdev)
+{
+	struct resource res_regs, res_irq;
+	struct device_node *phy_node;
+	struct arc_emac_priv *priv;
+	struct net_device *ndev;
+	const char *mac_addr;
+	unsigned int id, clock_frequency;
+	int err;
+
+	if (!pdev->dev.of_node)
+		return -ENODEV;
+
+	/* Get PHY from device tree */
+	phy_node = of_parse_phandle(pdev->dev.of_node, "phy", 0);
+	if (!phy_node) {
+		dev_err(&pdev->dev, "failed to retrieve phy description from device tree\n");
+		return -ENODEV;
+	}
+
+	/* Get EMAC registers base address from device tree */
+	err = of_address_to_resource(pdev->dev.of_node, 0, &res_regs);
+	if (err) {
+		dev_err(&pdev->dev, "failed to retrieve registers base from device tree\n");
+		return -ENODEV;
+	}
+
+	/* Get CPU clock frequency from device tree */
+	if (of_property_read_u32(pdev->dev.of_node, "clock-frequency",
+				 &clock_frequency)) {
+		dev_err(&pdev->dev, "failed to retrieve <clock-frequency> from device tree\n");
+		return -EINVAL;
+	}
+
+	/* Get IRQ from device tree */
+	err = of_irq_to_resource(pdev->dev.of_node, 0, &res_irq);
+	if (!err) {
+		dev_err(&pdev->dev, "failed to retrieve <irq> value from device tree\n");
+		return -ENODEV;
+	}
+
+	ndev = alloc_etherdev(sizeof(struct arc_emac_priv));
+	if (!ndev)
+		return -ENOMEM;
+
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+
+	ndev->netdev_ops = &arc_emac_netdev_ops;
+	ndev->ethtool_ops = &arc_emac_ethtool_ops;
+	ndev->watchdog_timeo = TX_TIMEOUT;
+	/* FIXME :: no multicast support yet */
+	ndev->flags &= ~IFF_MULTICAST;
+
+	priv = netdev_priv(ndev);
+	priv->dev = &pdev->dev;
+	priv->ndev = ndev;
+
+	priv->regs = devm_ioremap_resource(&pdev->dev, &res_regs);
+	if (IS_ERR(priv->regs)) {
+		err = PTR_ERR(priv->regs);
+		goto out;
+	}
+	dev_dbg(&pdev->dev, "Registers base address is 0x%p\n", priv->regs);
+
+	id = arc_reg_get(priv, R_ID);
+
+	/* Check for EMAC revision 5 or 7, magic number */
+	if (!(id == 0x0005fd02 || id == 0x0007fd02)) {
+		dev_err(&pdev->dev, "ARC EMAC not detected, id=0x%x\n", id);
+		err = -ENODEV;
+		goto out;
+	}
+	dev_info(&pdev->dev, "ARC EMAC detected with id: 0x%x\n", id);
+
+	/* Set poll rate so that it polls every 1 ms */
+	arc_reg_set(priv, R_POLLRATE, clock_frequency / 1000000);
+
+	/* Get max speed of operation from device tree */
+	if (of_property_read_u32(pdev->dev.of_node, "max-speed",
+				 &priv->max_speed)) {
+		dev_err(&pdev->dev, "failed to retrieve <max-speed> from device tree\n");
+		err = -EINVAL;
+		goto out;
+	}
+
+	ndev->irq = res_irq.start;
+	dev_info(&pdev->dev, "IRQ is %d\n", ndev->irq);
+
+	/* Register interrupt handler for device */
+	err = devm_request_irq(&pdev->dev, ndev->irq, arc_emac_intr, 0,
+			       ndev->name, ndev);
+	if (err) {
+		dev_err(&pdev->dev, "could not allocate IRQ\n");
+		goto out;
+	}
+
+	/* Get MAC address from device tree */
+	mac_addr = of_get_mac_address(pdev->dev.of_node);
+
+	if (!mac_addr || !is_valid_ether_addr(mac_addr))
+		eth_hw_addr_random(ndev);
+	else
+		memcpy(ndev->dev_addr, mac_addr, ETH_ALEN);
+
+	dev_info(&pdev->dev, "MAC address is now %pM\n", ndev->dev_addr);
+
+	/* Do 1 allocation instead of 2 separate ones for Rx and Tx BD rings */
+	priv->rxbd = dmam_alloc_coherent(&pdev->dev, RX_RING_SZ + TX_RING_SZ,
+					 &priv->rxbd_dma, GFP_KERNEL);
+
+	if (!priv->rxbd) {
+		dev_err(&pdev->dev, "failed to allocate data buffers\n");
+		err = -ENOMEM;
+		goto out;
+	}
+
+	priv->txbd = priv->rxbd + RX_BD_NUM;
+
+	priv->txbd_dma = priv->rxbd_dma + RX_RING_SZ;
+	dev_dbg(&pdev->dev, "EMAC Device addr: Rx Ring [0x%x], Tx Ring[%x]\n",
+		(unsigned int)priv->rxbd_dma, (unsigned int)priv->txbd_dma);
+
+	err = arc_mdio_probe(pdev, priv);
+	if (err) {
+		dev_err(&pdev->dev, "failed to probe MII bus\n");
+		goto out;
+	}
+
+	priv->phy_dev = of_phy_connect(ndev, phy_node, arc_emac_adjust_link, 0,
+				       PHY_INTERFACE_MODE_MII);
+	if (!priv->phy_dev) {
+		dev_err(&pdev->dev, "of_phy_connect() failed\n");
+		err = -ENODEV;
+		goto out;
+	}
+
+	dev_info(&pdev->dev, "connected to %s phy with id 0x%x\n",
+		 priv->phy_dev->drv->name, priv->phy_dev->phy_id);
+
+	netif_napi_add(ndev, &priv->napi, arc_emac_poll, ARC_EMAC_NAPI_WEIGHT);
+
+	err = register_netdev(ndev);
+	if (err) {
+		netif_napi_del(&priv->napi);
+		dev_err(&pdev->dev, "failed to register network device\n");
+		goto out;
+	}
+
+	return 0;
+
+out:
+	free_netdev(ndev);
+	return err;
+}
+
+static int arc_emac_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct arc_emac_priv *priv = netdev_priv(ndev);
+
+	phy_disconnect(priv->phy_dev);
+	priv->phy_dev = NULL;
+	arc_mdio_remove(priv);
+	unregister_netdev(ndev);
+	netif_napi_del(&priv->napi);
+	free_netdev(ndev);
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
+	.probe = arc_emac_probe,
+	.remove = arc_emac_remove,
+	.driver = {
+		.name = DRV_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table  = arc_emac_dt_ids,
+		},
+};
+
+module_platform_driver(arc_emac_driver);
+
+MODULE_AUTHOR("Alexey Brodkin <abrodkin@synopsys.com>");
+MODULE_DESCRIPTION("ARC EMAC driver");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/arc/emac_mdio.c b/drivers/net/ethernet/arc/emac_mdio.c
new file mode 100644
index 0000000..26ba242
--- /dev/null
+++ b/drivers/net/ethernet/arc/emac_mdio.c
@@ -0,0 +1,152 @@
+/*
+ * Copyright (C) 2004-2013 Synopsys, Inc. (www.synopsys.com)
+ *
+ * MDIO implementation for ARC EMAC
+ */
+
+#include <linux/delay.h>
+#include <linux/of_mdio.h>
+#include <linux/platform_device.h>
+
+#include "emac.h"
+
+/* Number of seconds we wait for "MDIO complete" flag to appear */
+#define ARC_MDIO_COMPLETE_POLL_COUNT	1
+
+/**
+ * arc_mdio_complete_wait - Waits until MDIO transaction is completed.
+ * @priv:	Pointer to ARC EMAC private data structure.
+ *
+ * returns:	0 on success, -ETIMEDOUT on a timeout.
+ */
+static int arc_mdio_complete_wait(struct arc_emac_priv *priv)
+{
+	unsigned int i;
+
+	for (i = 0; i < ARC_MDIO_COMPLETE_POLL_COUNT * 40; i++) {
+		unsigned int status = arc_reg_get(priv, R_STATUS);
+
+		status &= MDIO_MASK;
+
+		if (status) {
+			/* Reset "MDIO complete" flag */
+			arc_reg_set(priv, R_STATUS, status);
+			return 0;
+		}
+
+		msleep(25);
+	}
+
+	return -ETIMEDOUT;
+}
+
+/**
+ * arc_mdio_read - MDIO interface read function.
+ * @bus:	Pointer to MII bus structure.
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
+	struct arc_emac_priv *priv = bus->priv;
+	unsigned int value;
+	int error;
+
+	arc_reg_set(priv, R_MDIO,
+		    0x60020000 | (phy_addr << 23) | (reg_num << 18));
+
+	error = arc_mdio_complete_wait(priv);
+	if (error < 0)
+		return error;
+
+	value = arc_reg_get(priv, R_MDIO) & 0xffff;
+
+	dev_dbg(priv->dev, "arc_mdio_read(phy_addr=%i, reg_num=%x) = %x\n",
+		phy_addr, reg_num, value);
+
+	return value;
+}
+
+/**
+ * arc_mdio_write - MDIO interface write function.
+ * @bus:	Pointer to MII bus structure.
+ * @phy_addr:	Address of the PHY device.
+ * @reg_num:	PHY register to write to.
+ * @value:	Value to be written into the register.
+ *
+ * returns:	0 on success, -ETIMEDOUT on a timeout.
+ *
+ * Writes the value to the requested register.
+ */
+static int arc_mdio_write(struct mii_bus *bus, int phy_addr,
+			  int reg_num, u16 value)
+{
+	struct arc_emac_priv *priv = bus->priv;
+
+	dev_dbg(priv->dev,
+		"arc_mdio_write(phy_addr=%i, reg_num=%x, value=%x)\n",
+		phy_addr, reg_num, value);
+
+	arc_reg_set(priv, R_MDIO,
+		     0x50020000 | (phy_addr << 23) | (reg_num << 18) | value);
+
+	return arc_mdio_complete_wait(priv);
+}
+
+/**
+ * arc_mdio_probe - MDIO probe function.
+ * @pdev:	Pointer to platform device.
+ * @priv:	Pointer to ARC EMAC private data structure.
+ *
+ * returns:	0 on success, -ENOMEM when mdiobus_alloc
+ * (to allocate memory for MII bus structure) fails.
+ *
+ * Sets up and registers the MDIO interface.
+ */
+int arc_mdio_probe(struct platform_device *pdev, struct arc_emac_priv *priv)
+{
+	struct mii_bus *bus;
+	int error;
+
+	bus = mdiobus_alloc();
+	if (!bus)
+		return -ENOMEM;
+
+	priv->bus = bus;
+	bus->priv = priv;
+	bus->parent = priv->dev;
+	bus->name = "Synopsys MII Bus",
+	bus->read = &arc_mdio_read;
+	bus->write = &arc_mdio_write;
+
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%s", pdev->name);
+
+	error = of_mdiobus_register(bus, pdev->dev.of_node);
+	if (error) {
+		dev_err(priv->dev, "cannot register MDIO bus %s\n", bus->name);
+		mdiobus_free(bus);
+		return error;
+	}
+
+	return 0;
+}
+
+/**
+ * arc_mdio_remove - MDIO remove function.
+ * @priv:	Pointer to ARC EMAC private data structure.
+ *
+ * Unregisters the MDIO and frees any associate memory for MII bus.
+ */
+int arc_mdio_remove(struct arc_emac_priv *priv)
+{
+	mdiobus_unregister(priv->bus);
+	mdiobus_free(priv->bus);
+	priv->bus = NULL;
+
+	return 0;
+}
-- 
1.7.10.4
