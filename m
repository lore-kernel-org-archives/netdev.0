From: Andreas Irestal <andreas.irestal@axis.com>
Subject: [RFC PATCH] net:Add basic DWC Ethernet QoS Driver
Date: Thu, 8 May 2014 13:49:02 +0200
Message-ID: <201405081349.03139.Andreas.Irestal@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "grant.likely@linaro.org" <grant.likely@linaro.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"maxime.ripard@free-electrons.com" <maxime.ripard@free-electrons.com>,
	"abrodkin@synopsys.com" <abrodkin@synopsys.com>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"sr@denx.de" <sr@denx.de>,
	"jonas.jensen@gmail.com" <jonas.jensen@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Jesper Nilsson <jespern@axis.com>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an early version of a driver for the Synopsys DWC Ethernet QoS IP
version 4. Unfortunately, version 4.00a and onwards of this IP is totally
different from earlier versions used in the STMicroelectronics drivers. Both
functionality and registers are different. As this is my first network driver
I am submitting an RFC to catch design flaws and bad coding standards at an
early stage. Also, others looking at this IP could hopefully be helped by this
early code.

The driver is quite inefficient, yet still functional (Gbit only) and uses a
polling-driven TX-approach. For the RX side NAPI and interrupts are used.
There are still quite a lot of work to do. Link handling, more robust
error-handling, HW Checksumming, scatter-gather and TCP Segmentation and
checksum offloading to name a few.

All code has been developed and tested using an FPGA implementation of the IP,
with an ARM Cortex A9 as the main CPU, running Linux 3.13.

Signed-off-by: Andreas Irestaal <Andreas.Irestal@axis.com>
---
 drivers/net/ethernet/Kconfig                |    1 +
 drivers/net/ethernet/Makefile               |    1 +
 drivers/net/ethernet/synopsys/Kconfig       |   24 +
 drivers/net/ethernet/synopsys/Makefile      |    5 +
 drivers/net/ethernet/synopsys/dwc_eth_qos.c |  710 +++++++++++++++++++++++++++
 drivers/net/ethernet/synopsys/dwc_eth_qos.h |  308 ++++++++++++
 6 files changed, 1049 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/synopsys/Kconfig
 create mode 100644 drivers/net/ethernet/synopsys/Makefile
 create mode 100644 drivers/net/ethernet/synopsys/dwc_eth_qos.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc_eth_qos.h

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 506b024..64e8189 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -157,6 +157,7 @@ source "drivers/net/ethernet/sgi/Kconfig"
 source "drivers/net/ethernet/smsc/Kconfig"
 source "drivers/net/ethernet/stmicro/Kconfig"
 source "drivers/net/ethernet/sun/Kconfig"
+source "drivers/net/ethernet/synopsys/Kconfig"
 source "drivers/net/ethernet/tehuti/Kconfig"
 source "drivers/net/ethernet/ti/Kconfig"
 source "drivers/net/ethernet/tile/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index c0b8789..57e4967 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -68,6 +68,7 @@ obj-$(CONFIG_NET_VENDOR_SGI) += sgi/
 obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
 obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
+obj-$(CONFIG_NET_VENDOR_SYNOPSYS) += synopsys/
 obj-$(CONFIG_NET_VENDOR_TEHUTI) += tehuti/
 obj-$(CONFIG_NET_VENDOR_TI) += ti/
 obj-$(CONFIG_TILE_NET) += tile/
diff --git a/drivers/net/ethernet/synopsys/Kconfig b/drivers/net/ethernet/synopsys/Kconfig
new file mode 100644
index 0000000..90dceb2
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/Kconfig
@@ -0,0 +1,24 @@
+#
+# Synopsys network device configuration
+#
+
+config NET_VENDOR_SYNOPSYS
+	bool "Synopsys devices"
+	default y
+	---help---
+	  If you have a network (Ethernet) device belonging to this class, say Y
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Synopsys devices. If you say Y, you will be asked
+	  for your specific device in the following questions.
+
+if NET_VENDOR_SYNOPSYS
+
+config SYNOPSYS_DWC_ETH_QOS
+	tristate "Sypnopsys DWC Ethernet QOS v4.00a support"
+	select PHYLIB
+	---help---
+	  This driver supports the DWC Ethernet QoS from Synopsys
+
+endif # NET_VENDOR_SYNOPSYS
diff --git a/drivers/net/ethernet/synopsys/Makefile b/drivers/net/ethernet/synopsys/Makefile
new file mode 100644
index 0000000..7a37572
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Synopsys network device drivers.
+#
+
+obj-$(CONFIG_SYNOPSYS_DWC_ETH_QOS) += dwc_eth_qos.o
diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
new file mode 100644
index 0000000..bd37802
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -0,0 +1,710 @@
+/*  Synopsys DWC Ethernet: Linux driver for Ethernet
+ *
+ *  This is a driver for the Synopsys DWC Ethernet IP version 4.00a. This
+ *  version introduced a lot of changes which breaks backwards compatibility
+ *  with version 3 of the same IP (Used in ST Micro drivers).
+ *
+ *  This driver only support basic functionality and Gigabit Ethernet Only. It
+ *  uses polling for TX and IRQ-driven RX with NAPI support. No hardware
+ *  checksumming or scatter-gather are supported. There are many things left to
+ *  implement: Scatter-gather, TCP Segmentation Offloading, HW Checksumming,
+ *  IRQ-driven TX, link handling, and a lot of general error handling.
+ *
+ *  Copyright (C) 2014 Axis Communications AB.
+ *
+ *  This program is free software; you can redistribute it and/or modify it
+ *  under the terms and conditions of the GNU General Public License,
+ *  version 2, as published by the Free Software Foundation.
+ */
+
+#include <linux/clk.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/io.h>
+#include <linux/stat.h>
+
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/delay.h>
+#include <linux/mm.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/platform_device.h>
+#include <linux/phy.h>
+#include <linux/mii.h>
+#include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <linux/vmalloc.h>
+#include <linux/version.h>
+#include <linux/of.h>
+#include <linux/interrupt.h>
+#include <linux/clocksource.h>
+#include <linux/net_tstamp.h>
+#include <linux/pm_runtime.h>
+#include <linux/of_net.h>
+#include <linux/of_address.h>
+#include <linux/of_mdio.h>
+#include <linux/timer.h>
+#include "dwc_eth_qos.h"
+
+#define DRIVER_NAME			"dwceqos"
+#define DRIVER_DESCRIPTION		"Synopsys DWC Ethernet QoS driver"
+#define DRIVER_VERSION			"0.1"
+
+#ifdef DWCEQOS_DEBUG
+static void dwceqos_write(void __iomem *p, u32 offset, u32 v)
+{
+	printk(KERN_DEBUG "Write: Addr=%08x, Data=%08x\n", (u32)p + offset , v);
+	writel(v, p + offset);
+}
+
+static u32 dwceqos_read(void __iomem *p, u32 offset)
+{
+	u32 v = 0;
+	v = readl(p + offset);
+	printk(KERN_DEBUG "Read: Addr=%08x, Data=%08x\n", (u32)p + offset, v);
+	return v;
+}
+#else
+#define dwceqos_read(base, reg)						\
+	__raw_readl(((void __iomem *)(base)) + (reg))
+#define dwceqos_write(base, reg, val)					\
+	__raw_writel((val), ((void __iomem *)(base)) + (reg))
+#endif
+
+/* DMA ring descriptor. These are used as support descriptors for the HW DMA */
+struct ring_info {
+	struct sk_buff *skb;
+	dma_addr_t mapping;
+	size_t len;
+};
+
+struct net_local {
+	void __iomem *baseaddr;
+	struct clk *phy_ref_clk;
+	struct clk *apb_pclk;
+
+	struct net_device *ndev;
+	struct platform_device *pdev;
+
+	volatile struct dwc_eth_qos_txdesc *tx_descs;
+	volatile struct dwc_eth_qos_rxdesc *rx_descs;
+
+	void *tx_buf;
+
+	struct ring_info *rx_skb;
+
+	dma_addr_t tx_descs_addr;
+	dma_addr_t rx_descs_addr;
+
+	u32 next_tx;
+	u32 next_rx;
+
+	struct napi_struct napi;
+
+	struct net_device_stats stats;
+	spinlock_t rx_lock;
+};
+
+/* Allocate DMA helper structure at position given by index */
+static void dwceqos_alloc_rxring_desc(struct net_local *lp, int index)
+{
+	struct sk_buff *new_skb;
+	u32 new_skb_baddr = 0;
+	new_skb = netdev_alloc_skb(lp->ndev, DWCEQOS_RX_BUF_SIZE);
+	if (!new_skb) {
+		dev_err(&lp->ndev->dev, "alloc_skb error for desc %d\n", index);
+		goto out;
+	}
+
+	/* Get dma handle of skb->data */
+	new_skb_baddr = (u32)dma_map_single(lp->ndev->dev.parent,
+		new_skb->data, DWCEQOS_RX_BUF_SIZE, DMA_FROM_DEVICE);
+	if (dma_mapping_error(lp->ndev->dev.parent, new_skb_baddr)) {
+		dev_err(&lp->pdev->dev, "DMA map error\n");
+		dev_kfree_skb(new_skb);
+		new_skb = NULL;
+	}
+out:
+	lp->rx_skb[index].skb = new_skb;
+	lp->rx_skb[index].mapping = new_skb_baddr;
+	lp->rx_skb[index].len = DWCEQOS_RX_BUF_SIZE;
+
+	return;
+}
+
+static void dwceqos_mtl_init(struct net_local *lp)
+{
+	dwceqos_write(lp->baseaddr, DWCEQOS_MTL_OP_MODE, 0x00000060);
+}
+
+static void dwceqos_mtl_tx_init(struct net_local *lp)
+{
+	dwceqos_write(lp->baseaddr, DWCEQOS_MTL_TXQ0_OP_MODE,
+			DWCEQOS_MTL_TXQ_EN);
+}
+
+static void dwceqos_mtl_rx_init(struct net_local *lp)
+{
+	dwceqos_write(lp->baseaddr, DWCEQOS_MTL_RXQ0_OP_MODE,
+		DWCEQOS_MTL_RXQ_RQS256 | DWCEQOS_MTL_RXQ_DIS_TCP_EF |
+		DWCEQOS_MTL_RXQ_FEP | DWCEQOS_MTL_RXQ_FUP |
+		DWCEQOS_MTL_RXQ_RTC32);
+}
+
+static void dwceqos_mac_rx_init(struct net_local *lp)
+{
+	u32 val;
+	dwceqos_write(lp->baseaddr, DWCEQOS_MAC_RXQ_CTRL0, 2);
+	val = DWCEQOS_MAC_PKT_FILTER_RX_ALL | DWCEQOS_MAC_PKT_FILTER_PCF_ALL |
+		DWCEQOS_MAC_PKT_FILTER_PROMISCUOUS;
+	dwceqos_write(lp->baseaddr, DWCEQOS_MAC_PKT_FILTER, val);
+}
+
+static int dwceqos_mac_enable(struct net_local *lp)
+{
+	dwceqos_write(lp->baseaddr, DWCEQOS_MAC_CFG,
+		DWCEQOS_MAC_CFG_DM | DWCEQOS_MAC_CFG_TE |
+		DWCEQOS_MAC_CFG_RE);
+	return 0;
+}
+
+static void dwceqos_dma_wake_rx(struct net_local *lp)
+{
+	u32 offset;
+	offset = DWCEQOS_RX_DCNT * sizeof(struct dwc_eth_qos_rxdesc);
+	dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_RXDESC_TAIL,
+		(u32)lp->rx_descs_addr + offset);
+}
+
+static inline void dwceqos_dma_rx_start(struct net_local *lp)
+{
+	dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_RX_CTRL,
+		DWCEQOS_DMA_CH0_TXRX_CONTROL_START |
+		DWCEQOS_DMA_CH0_TXRX_CONTROL_PBL16 |
+		DWCEQOS_RX_BUF_SIZE);
+	dwceqos_dma_wake_rx(lp);
+}
+
+static inline void dwceqos_dma_tx_start(struct net_local *lp)
+{
+	dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_TX_CTRL,
+		DWCEQOS_DMA_CH0_TXRX_CONTROL_START |
+		DWCEQOS_DMA_CH0_TXRX_CONTROL_PBL16);
+}
+
+static void dwceqos_dma_setmode(struct net_local *lp)
+{
+	dwceqos_write(lp->baseaddr, DWCEQOS_DMA_MODE,
+		DWCEQOS_DMA_MODE_TXPR | DWCEQOS_DMA_MODE_DA);
+	dwceqos_write(lp->baseaddr, DWCEQOS_DMA_SYSBUS_MODE,
+		DWCEQOS_DMA_SYSBUS_MB);
+}
+
+static void dwceqos_dma_txenable(struct net_local *lp)
+{
+	u32 val;
+	val = DWCEQOS_DMA_CH0_TXRX_CONTROL_PBL16 |
+		DWCEQOS_DMA_CH0_TXRX_CONTROL_START;
+	dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_TX_CTRL, val);
+}
+
+static void dwceqos_dma_rx_enable(struct net_local *lp)
+{
+	u32 val;
+	val = DWCEQOS_DMA_CH0_TXRX_CONTROL_PBL16 |
+		DWCEQOS_RX_BUF_SIZE | DWCEQOS_DMA_CH0_TXRX_CONTROL_START;
+	dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_RX_CTRL, val);
+}
+
+/* Initialize DMA descriptors to their start values */
+static void dwceqos_dma_prepare(struct net_local *lp)
+{
+	int i;
+	for (i = 0; i < DWCEQOS_TX_DCNT; ++i) {
+		lp->tx_descs[i].tdes0.raw = 0;
+		lp->tx_descs[i].tdes1.raw = 0;
+		lp->tx_descs[i].tdes2.raw = 0;
+		lp->tx_descs[i].tdes3.raw = 0;
+	}
+
+	for (i = 0; i < DWCEQOS_RX_DCNT; ++i) {
+		lp->rx_descs[i].rdes0.rd.buffer1 = lp->rx_skb[i].mapping;
+		lp->rx_descs[i].rdes1.raw = 0;
+		lp->rx_descs[i].rdes2.rd.buffer2 = 0;
+		lp->rx_descs[i].rdes3.raw = 0;
+		lp->rx_descs[i].rdes3.rd.buf1v = 1;
+		lp->rx_descs[i].rdes3.rd.inte = 1;
+		lp->rx_descs[i].rdes3.rd.own = 1;
+	}
+	lp->next_tx = 0;
+	lp->next_rx = 0;
+}
+
+/* Allocate and initiate DMA rings for TX and RX. Also allocates RX buffers for
+ * incoming packets.
+ */
+static int dwceqos_dma_alloc(struct net_local *lp)
+{
+	u32 size;
+	int i;
+
+	size = DWCEQOS_RX_DCNT * sizeof(struct ring_info);
+	lp->rx_skb = kzalloc(size, GFP_KERNEL);
+	if (!lp->rx_skb) {
+		dev_err(&lp->pdev->dev, "Unable to allocate ring descriptor area\n");
+		return -ENOMEM;
+	}
+
+	/* Allocate DMA descriptors */
+	size = DWCEQOS_TX_DCNT * sizeof(struct dwc_eth_qos_txdesc);
+	lp->tx_descs = dma_alloc_coherent(&lp->pdev->dev, size,
+			&lp->tx_descs_addr, 0);
+	if (!lp->tx_descs) {
+		dev_err(&lp->pdev->dev, "Failed to allocate TX DMA descriptors\n");
+		/* Should deallocate memory here */
+		return -ENOMEM;
+	}
+	size = DWCEQOS_RX_DCNT * sizeof(struct dwc_eth_qos_rxdesc);
+	lp->rx_descs = dma_alloc_coherent(&lp->pdev->dev, size,
+			&lp->rx_descs_addr, 0);
+	if (!lp->rx_descs) {
+		dev_err(&lp->pdev->dev, "Failed to allocate RX DMA descriptors\n");
+		/* Should deallocate memory here */
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < DWCEQOS_RX_DCNT; ++i) {
+		dwceqos_alloc_rxring_desc(lp, i);
+		if (!(lp->rx_skb[lp->next_rx].skb)) {
+			dev_err(&lp->pdev->dev, "Unable to map descriptor %d to DMA\n",
+				lp->next_rx);
+			/* What error code to return for mapping error? */
+			return -1;
+		}
+	}
+
+	dwceqos_dma_prepare(lp);
+
+	/* Tell HW where to look*/
+	dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_RXDESC_RING_LEN,
+		DWCEQOS_RX_DCNT-1);
+	dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_TXDESC_RING_LEN,
+		DWCEQOS_TX_DCNT-1);
+	dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_RXDESC_LIST_ADDR,
+		(u32)lp->rx_descs_addr);
+	dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_TXDESC_LIST_ADDR,
+		(u32)lp->tx_descs_addr);
+	return 0;
+}
+
+/* Checks if there are any available incoming packets ready for processing */
+int dwceqos_packet_avail(struct net_local *lp)
+{
+	return !lp->rx_descs[lp->next_rx].rdes3.wr.own;
+}
+
+/* Free DMA descriptor area */
+static void dwceqos_dma_free(struct net_local *lp)
+{
+	u32 size;
+	size = DWCEQOS_TX_DCNT * sizeof(struct dwc_eth_qos_txdesc);
+	if (lp->tx_descs)
+		dma_free_coherent(&lp->pdev->dev, size,
+			lp->tx_descs, lp->tx_descs_addr);
+	size = DWCEQOS_RX_DCNT * sizeof(struct dwc_eth_qos_rxdesc);
+	if (lp->rx_descs)
+		dma_free_coherent(&lp->pdev->dev, size,
+			lp->rx_descs, lp->rx_descs_addr);
+}
+
+/* HW transmit function. */
+static void dwceqos_dma_xmit(struct net_local *lp, void *data, int len)
+{
+	u32 regval;
+	int i = lp->next_tx;
+	int dwc_wait;
+	dma_addr_t dma_handle;
+
+	dma_handle = dma_map_single(lp->ndev->dev.parent,
+		data, DWCEQOS_RX_BUF_SIZE, DMA_TO_DEVICE);
+	if (dma_mapping_error(lp->ndev->dev.parent, dma_handle)) {
+		dev_err(&lp->pdev->dev, "DMA Mapping error\n");
+		return;
+	}
+
+	lp->tx_descs[i].tdes0.rd.buffer1 = dma_handle;
+	lp->tx_descs[i].tdes2.rd.buf1len = len;
+	lp->tx_descs[i].tdes3.rd.fl = len;
+	lp->tx_descs[i].tdes3.rd.fd = 1;
+	lp->tx_descs[i].tdes3.rd.ld = 1;
+	lp->tx_descs[i].tdes3.rd.own = 1;
+
+	/* Issue Transmit Poll by writing address of next free descriptor */
+	regval = lp->tx_descs_addr + (i+1) * sizeof(struct dwc_eth_qos_txdesc);
+	dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_TXDESC_TAIL, regval);
+
+	/* Set poll wait timeout to 2 seconds */
+	dwc_wait = 200;
+
+	while (lp->tx_descs[i].tdes3.wr.own) {
+		mdelay(10);
+		if (!dwc_wait--)
+			break;
+	}
+	if (lp->tx_descs[i].tdes3.wr.own)
+		dev_err(&lp->pdev->dev, "Failed to transmit: Timed out\n");
+
+	lp->next_tx = (lp->next_tx + 1) % DWCEQOS_TX_DCNT;
+	dma_unmap_single(lp->ndev->dev.parent,
+			dma_handle, DWCEQOS_RX_BUF_SIZE, DMA_TO_DEVICE);
+}
+
+/* Store HW Addr in MAC registers. Source Address Replacement not used yet */
+static void dwceqos_set_hwaddr(struct net_local *lp)
+{
+	u32 val;
+
+	val = DWCEQOS_MAC_ADDR_HI_EN | (lp->ndev->dev_addr[0] << 8) |
+		(lp->ndev->dev_addr[1]);
+	dwceqos_write(lp->baseaddr, DWCEQOS_MAC_ADDR_HI, val);
+	val = (lp->ndev->dev_addr[2] << 24) | (lp->ndev->dev_addr[3] << 16) |
+		(lp->ndev->dev_addr[4] << 8)  | (lp->ndev->dev_addr[5]);
+	dwceqos_write(lp->baseaddr, DWCEQOS_MAC_ADDR_LO, val);
+}
+
+/* DMA reset. When issued also resets all MTL and MAC registers as well */
+static void dwceqos_dma_reset(struct net_local *lp)
+{
+	/* Wait 5 seconds for DMA reset*/
+	int i = 5000;
+	dwceqos_write(lp->baseaddr, DWCEQOS_DMA_MODE, 1);
+
+	do {
+		mdelay(1);
+	} while ((dwceqos_read(lp->baseaddr, DWCEQOS_DMA_MODE) & 0x1) && i--);
+}
+
+/* Interrupt handler. So far only RX interrupts are used */
+static irqreturn_t dwceqos_interrupt(int irq, void *dev_id)
+{
+	struct net_device *ndev = dev_id;
+	struct net_local *lp = netdev_priv(ndev);
+
+	u32 cause;
+	u32 val;
+
+	cause = dwceqos_read(lp->baseaddr, DWCEQOS_DMA_INT_STAT);
+	if (cause & 0x00000001) {
+		/* DMA Channel 0 Interrupt. Assume RX interrupt for now */
+		val = dwceqos_read(lp->baseaddr, DWCEQOS_DMA_CH0_STAT);
+		/* Ack */
+		dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_STAT, val);
+		if (val & 0x00000040)
+			napi_schedule(&lp->napi);
+	} else if (unlikely(!cause)) {
+		return IRQ_NONE;
+	}
+	return IRQ_HANDLED;
+}
+
+static int dwceqos_open(struct net_device *ndev)
+{
+	/* Allocate Buffers & DMA Descr. + Initiate DMA descriptors */
+	struct net_local *lp = netdev_priv(ndev);
+
+	/* Set up hardware. It looks like order of writes is important here.
+	 * Only gigatbit support, no advanced MTL or MAC configuration yet.
+	 */
+	dwceqos_dma_reset(lp);
+	dwceqos_mtl_init(lp);
+	dwceqos_mtl_tx_init(lp);
+	dwceqos_dma_setmode(lp);
+	dwceqos_dma_alloc(lp);
+	dwceqos_dma_wake_rx(lp);
+	dwceqos_dma_txenable(lp);
+	dwceqos_mtl_rx_init(lp);
+	dwceqos_mac_rx_init(lp);
+	dwceqos_dma_rx_enable(lp);
+	dwceqos_dma_wake_rx(lp);
+	dwceqos_set_hwaddr(lp);
+	dwceqos_mac_enable(lp);
+
+	/* Enable RX Interrupts */
+	dwceqos_write(lp->baseaddr, DWCEQOS_DMA_CH0_INT_EN, 0x00010040);
+
+	napi_enable(&lp->napi);
+	netif_carrier_on(ndev);
+	netif_start_queue(ndev);
+	return 0;
+}
+
+
+int dwceqos_stop(struct net_device *ndev)
+{
+	struct net_local *lp = netdev_priv(ndev);
+	dwceqos_dma_free(lp);
+	netif_stop_queue(ndev);
+	napi_disable(&lp->napi);
+	netif_carrier_off(ndev);
+	return 0;
+}
+
+/* Receive one packet and return skb */
+struct sk_buff *
+dwceqos_recv_packet(struct net_local *lp)
+{
+	struct sk_buff *skb;
+	u32 len;
+
+	skb = lp->rx_skb[lp->next_rx].skb;
+	len = lp->rx_descs[lp->next_rx].rdes3.wr.length;
+
+	/* Unmap old buffer */
+	dma_unmap_single(lp->ndev->dev.parent, lp->rx_skb[lp->next_rx].mapping,
+		lp->rx_skb[lp->next_rx].len, DMA_FROM_DEVICE);
+	skb_put(skb, len);
+	skb->protocol = eth_type_trans(skb, lp->ndev);
+	skb->ip_summed = 0;
+
+	/* Initialize new Buffer descriptor */
+	dwceqos_alloc_rxring_desc(lp, lp->next_rx);
+	if (!(lp->rx_skb[lp->next_rx].skb)) {
+		dev_err(&lp->pdev->dev, "Unable to map descriptor %d to DMA\n",
+			lp->next_rx);
+		return NULL;
+	}
+
+	/* Initialize new DMA descriptor */
+	lp->rx_descs[lp->next_rx].rdes0.rd.buffer1 =
+		lp->rx_skb[lp->next_rx].mapping;
+	lp->rx_descs[lp->next_rx].rdes1.raw = 0;
+	lp->rx_descs[lp->next_rx].rdes2.rd.buffer2 = 0;
+	lp->rx_descs[lp->next_rx].rdes3.raw = 0;
+	lp->rx_descs[lp->next_rx].rdes3.rd.buf1v = 1;
+	lp->rx_descs[lp->next_rx].rdes3.rd.inte = 1;
+	lp->rx_descs[lp->next_rx].rdes3.rd.own = 1;
+	lp->next_rx = (lp->next_rx + 1) % DWCEQOS_RX_DCNT;
+	return skb;
+}
+
+
+/* NAPI poll routine */
+int dwceqos_rx_poll(struct napi_struct *napi, int budget)
+{
+	struct net_local *lp = container_of(napi, struct net_local, napi);
+	int npackets = 0;
+	struct sk_buff *skb;
+
+	spin_lock(&lp->rx_lock);
+	while (npackets < budget && dwceqos_packet_avail(lp)) {
+
+		skb = dwceqos_recv_packet(lp);
+		if (!skb)
+			break;
+
+		netif_receive_skb(skb);
+
+		lp->stats.rx_packets++;
+		lp->stats.rx_bytes += skb->len;
+		npackets++;
+	}
+	if (npackets < budget)
+		napi_complete(napi);
+
+	spin_unlock(&lp->rx_lock);
+	return npackets;
+}
+
+/* Main transmit function called from kernel */
+int dwceqos_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	int len;
+	struct net_local *lp = netdev_priv(ndev);
+	char *data;
+	data = skb->data;
+	len = skb->len;
+
+	/* Send packet on wire */
+	dwceqos_dma_xmit(lp, data, len);
+
+	skb_tx_timestamp(skb);
+
+	ndev->stats.tx_bytes += len;
+	dev_kfree_skb(skb);
+
+	return 0;
+}
+
+struct net_device_ops dwceq_netdev_ops;
+
+#ifdef CONFIG_OF
+static inline int dwceqos_probe_config_dt(struct platform_device *pdev)
+{
+	struct net_device *ndev;
+	const void *mac_address;
+
+	ndev = platform_get_drvdata(pdev);
+	/* Set the MAC address. */
+	mac_address = of_get_mac_address(pdev->dev.of_node);
+	if (mac_address)
+		memcpy(ndev->dev_addr, mac_address, ETH_ALEN);
+	else
+		dev_warn(&pdev->dev, "No MAC address found\n");
+	return 0;
+}
+#else
+static inline int dwceqos_probe_config_dt()
+{
+	return -ENOSYS;
+}
+#endif
+
+
+/**
+ * dwceqos_probe - Platform driver probe
+ * @pdev: Pointer to platform device structure
+ *
+ * Return 0 on success, negative value if error
+ */
+int dwceqos_probe(struct platform_device *pdev)
+{
+	struct resource *r_mem = NULL;
+	struct resource *r_irq = NULL;
+	struct net_device *ndev;
+	struct net_local *lp;
+	int ret = -ENXIO;
+
+	r_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	r_irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	if (!r_mem || !r_irq) {
+		dev_err(&pdev->dev, "no IO resource defined.\n");
+		return -ENXIO;
+	}
+	ndev = alloc_etherdev(sizeof(*lp));
+	if (!ndev) {
+		dev_err(&pdev->dev, "etherdev allocation failed.\n");
+		return -ENOMEM;
+	}
+
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+
+	lp = netdev_priv(ndev);
+	lp->ndev = ndev;
+	lp->pdev = pdev;
+
+	lp->baseaddr = devm_ioremap_resource(&pdev->dev, r_mem);
+	if (IS_ERR(lp->baseaddr)) {
+		dev_err(&pdev->dev, "failed to map baseaddress.\n");
+		ret = PTR_ERR(lp->baseaddr);
+		goto err_out_free_netdev;
+	}
+
+
+	dev_dbg(&lp->pdev->dev, "BASEADDRESS hw: %p virt: %p\n",
+			(void *)r_mem->start, lp->baseaddr);
+
+	ndev->irq = platform_get_irq(pdev, 0);
+	ndev->netdev_ops = &dwceq_netdev_ops;
+	ndev->base_addr = r_mem->start;
+	ndev->features = 0;
+
+	netif_napi_add(ndev, &lp->napi, dwceqos_rx_poll, 64);
+
+	ret = register_netdev(ndev);
+	if (ret) {
+		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
+		goto err_out_free_netdev;
+	}
+
+	lp->apb_pclk = devm_clk_get(&pdev->dev, "apb_pclk");
+	if (IS_ERR(lp->apb_pclk)) {
+		dev_err(&pdev->dev, "apb_pclk clock not found.\n");
+		ret = PTR_ERR(lp->apb_pclk);
+		goto err_out_unregister_netdev;
+	}
+	lp->phy_ref_clk = devm_clk_get(&pdev->dev, "phy_ref_clk");
+	if (IS_ERR(lp->phy_ref_clk)) {
+		dev_err(&pdev->dev, "phy_ref_clk clock not found.\n");
+		ret = PTR_ERR(lp->phy_ref_clk);
+		goto err_out_unregister_netdev;
+	}
+
+	ret = clk_prepare_enable(lp->apb_pclk);
+	if (ret) {
+		dev_err(&pdev->dev, "Unable to enable APER clock.\n");
+		goto err_out_unregister_netdev;
+	}
+	ret = clk_prepare_enable(lp->phy_ref_clk);
+	if (ret) {
+		dev_err(&pdev->dev, "Unable to enable device clock.\n");
+		goto err_out_clk_dis_aper;
+	}
+
+	platform_set_drvdata(pdev, ndev);
+	ret = dwceqos_probe_config_dt(pdev);
+	if (ret) {
+		dev_err(&lp->pdev->dev, "Unable to retrieve DT, error %d\n", ret);
+		goto err_out_dis_aper;
+	}
+	dev_info(&lp->pdev->dev, "pdev->id %d, baseaddr 0x%08lx, irq %d\n",
+			pdev->id, ndev->base_addr, ndev->irq);
+
+	ret = devm_request_irq(&pdev->dev, ndev->irq, &dwceqos_interrupt, 0,
+		ndev->name, ndev);
+	if (ret) {
+		dev_err(&lp->pdev->dev, "Unable to request IRQ %p, error %d\n",
+			r_irq, ret);
+		goto err_out_unregister_clk_notifier;
+	}
+
+	return 0;
+
+err_out_unregister_clk_notifier:
+	clk_disable_unprepare(lp->phy_ref_clk);
+err_out_clk_dis_aper:
+	clk_disable_unprepare(lp->apb_pclk);
+err_out_unregister_netdev:
+	unregister_netdev(ndev);
+err_out_free_netdev:
+	free_netdev(ndev);
+	platform_set_drvdata(pdev, NULL);
+	return ret;
+}
+
+int dwceqos_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	unregister_netdev(ndev);
+	free_netdev(ndev);
+	return 0;
+}
+
+struct net_device_ops dwceq_netdev_ops = {
+	.ndo_open	= dwceqos_open,
+	.ndo_stop	= dwceqos_stop,
+	.ndo_start_xmit	= dwceqos_start_xmit,
+};
+
+struct of_device_id dwceq_of_match[] = {
+	{ .compatible = "dwc,qos-ethernet", },
+	{}
+};
+MODULE_DEVICE_TABLE(of, dwceq_of_match);
+
+struct platform_driver dwceqos_driver = {
+	.probe   = dwceqos_probe,
+	.remove  = dwceqos_remove,
+	.driver  = {
+		.name  = DRIVER_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table = dwceq_of_match,
+	},
+};
+
+module_platform_driver(dwceqos_driver);
+
+MODULE_DESCRIPTION("DWC Ethernet QoS v4.00a driver");
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Andreas Irestaal");
diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.h b/drivers/net/ethernet/synopsys/dwc_eth_qos.h
new file mode 100644
index 0000000..9aa84a0
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.h
@@ -0,0 +1,308 @@
+#ifndef DWC_ETH_QOS_H
+#define DWC_ETH_QOS_H
+
+#define DWCEQOS_RX_BUF_SIZE 2048
+
+#define DWCEQOS_RX_DCNT 16
+#define DWCEQOS_TX_DCNT 16
+
+/* DMA Registers */
+#define DWCEQOS_DMA_MODE			0x1000
+#define DWCEQOS_DMA_SYSBUS_MODE			0x1004
+#define DWCEQOS_DMA_INT_STAT			0x1008
+#define DWCEQOS_DMA_DEBUG_STAT0			0x100c
+#define DWCEQOS_DMA_DEBUG_STAT1			0x1010
+#define DWCEQOS_DMA_DEBUG_STAT2			0x1014
+#define DWCEQOS_DMA_CH0_CTRL			0x1100
+#define DWCEQOS_DMA_CH0_TX_CTRL			0x1104
+#define DWCEQOS_DMA_CH0_RX_CTRL			0x1108
+#define DWCEQOS_DMA_CH0_TXDESC_LIST_ADDR	0x1114
+#define DWCEQOS_DMA_CH0_RXDESC_LIST_ADDR	0x111C
+#define DWCEQOS_DMA_CH0_TXDESC_TAIL		0x1120
+#define DWCEQOS_DMA_CH0_RXDESC_TAIL		0x1128
+#define DWCEQOS_DMA_CH0_TXDESC_RING_LEN		0x112c
+#define DWCEQOS_DMA_CH0_RXDESC_RING_LEN		0x1130
+#define DWCEQOS_DMA_CH0_INT_EN			0x1134
+#define DWCEQOS_DMA_CH0_INT_WATCHDOG_T		0x1138
+#define DWCEQOS_DMA_CH0_SLOT_FUNC_CTRL_STAT	0x113c
+#define DWCEQOS_DMA_CH0_CUR_APP_TXDESC		0x1144
+#define DWCEQOS_DMA_CH0_CUR_APP_RXDESC		0x114c
+#define DWCEQOS_DMA_CH0_CUR_APP_TXBUF		0x1154
+#define DWCEQOS_DMA_CH0_CUR_APP_RXBUF		0x115c
+#define DWCEQOS_DMA_CH0_STAT			0x1160
+
+/* MAC Registers */
+#define DWCEQOS_MAC_CFG				0x0000
+#define DWCEQOS_MAC_EXT_CFG			0x0004
+#define DWCEQOS_MAC_PACKET_FILTER		0x0008
+#define DWCEQOS_MAC_RXQ_CTRL0			0x00a0
+#define DWCEQOS_MAC_IE				0x00b4
+#define DWCEQOS_MAC_RX_TX_STATUS		0x00b8
+#define DWCEQOS_MAC_PHYIF_CTRL_STATUS		0x00f8
+#define DWCEQOS_MAC_DEBUG			0x0114
+#define DWCEQOS_MAC_HW_FEATURE0			0x011c
+#define DWCEQOS_MAC_HW_FEATURE1			0x0120
+#define DWCEQOS_MAC_HW_FEATURE2			0x0124
+#define DWCEQOS_MAC_ADDR_HI			0x0300
+#define DWCEQOS_MAC_ADDR_LO			0x0304
+#define DWCEQOS_MAC_MDIO_ADDR			0x0200
+#define DWCEQOS_MAC_MDIO_DATA			0x0204
+#define DWCEQOS_MAC_PKT_FILTER			0x8
+
+/* MTL Registers */
+#define DWCEQOS_MTL_OP_MODE			0x0c00
+#define DWCEQOS_MTL_DEUBIG_CTRL			0x0c08
+#define DWCEQOS_MTL_DEBUG_STATUS		0x0c0c
+#define DWCEQOS_MTL_FIFO_DEBUG_DATA		0x0c10
+#define DWCEQOS_MTL_INT_STATUS			0x0c20
+#define DWCEQOS_MTL_RXQ0_DMA_MAP0		0x0c30
+#define DWCEQOS_MTL_RXQ0_DMA_MAP1		0x0c34
+#define DWCEQOS_MTL_TXQ0_OP_MODE		0x0d00
+#define DWCEQOS_MTL_TXQ0_UNDERFLOW		0x0d04
+#define DWCEQOS_MTL_TXQ0_DEBUG			0x0d08
+#define DWCEQOS_MTL_TXQ0_ETS_STATUS		0x0d14
+#define DWCEQOS_MTL_TXQ0_QUANTUM		0x0d18
+#define DWCEQOS_MTL_TXQ0_INT_CTRL_STATUS	0x0d2c
+#define DWCEQOS_MTL_RXQ0_OP_MODE		0x0d30
+#define DWCEQOS_MTL_RXQ0_MISSED_PACKET_OF_CNT	0x0d34
+#define DWCEQOS_MTL_RXQ0_DEBUG			0x0d38
+#define DWCEQOS_MTL_RXQ0_CTRL			0x0d3c
+
+
+/* Fields/constants */
+#define DWCEQOS_DMA_MODE_SWR			1
+#define DWCEQOS_DMA_MODE_TXPR			(1 << 11)
+#define DWCEQOS_DMA_MODE_DA			(1 << 1)
+#define DWCEQOS_DMA_SYSBUS_MB			(1 << 14)
+
+#define DWCEQOS_DMA_CH0_TXRX_CONTROL_PBL16	(1 << 20)
+#define DWCEQOS_DMA_CH0_TXRX_CONTROL_OSP	(1 << 4)
+#define DWCEQOS_DMA_CH0_TXRX_CONTROL_START	1
+
+#define DWCEQOS_MTL_TXQ_TTC32			0
+#define DWCEQOS_MTL_TXQ_EN			(1 << 3)
+#define DWCEQOS_MTL_RXQ_EN			(1 << 3)
+#define DWCEQOS_MTL_TXQ_TSF			(1 << 1)
+
+#define DWCEQOS_MTL_TXQ0_DEBUG_TRQSTS		(1 << 4)
+#define DWCEQOS_MTL_TXQ0_DEBUG_TRCSTS		(3 << 3)
+#define DWCEQOS_MTL_TXQ0_DEBUG_TRCSTS_READ	(1 << 3)
+
+#define DWCEQOS_MTL_RXQ_RQS256			(3 << 20)
+#define DWCEQOS_MTL_RXQ_RTC128			3
+#define DWCEQOS_MTL_RXQ_RTC32			1
+
+#define DWCEQOS_MTL_RXQ_DIS_TCP_EF		(1 << 6)
+#define DWCEQOS_MTL_RXQ_FEP			(1 << 4)
+#define DWCEQOS_MTL_RXQ_FUP			(1 << 3)
+
+#define DWCEQOS_MAC_CFG_PS			(1 << 15)
+#define DWCEQOS_MAC_CFG_DM			(1 << 13)
+#define DWCEQOS_MAC_CFG_TE			(1 << 1)
+#define DWCEQOS_MAC_CFG_RE			1
+
+#define DWCEQOS_MAC_CFG_SARC_A0			(3 << 28)
+#define DWCEQOS_MAC_CFG_SARC_A1			(7 << 28)
+
+#define DWCEQOS_MAC_PKT_FILTER_RX_ALL		(1 << 31)
+#define DWCEQOS_MAC_PKT_FILTER_PCF_ALL		(2 << 6)
+#define DWCEQOS_MAC_PKT_FILTER_PROMISCUOUS	(1 << 0)
+
+#define DWCEQOS_MAC_MDIO_ADDR_CSR_20_30_MHZ	(2 << 8)
+#define DWCEQOS_MAC_MDIO_ADDR_WRITE		(1 << 2)
+#define DWCEQOS_MAC_MDIO_ADDR_READ		(3 << 2)
+#define DWCEQOS_MAC_MDIO_ADDR_BUSY		1
+
+#define DWCEQOS_MAC_ADDR_HI_EN			(1 << 31)
+
+
+#define DWCEQOS_MAC_INT_RXSTSIE			(1 << 14)
+
+/* DMA Structs */
+struct tdes0_rd {
+	u32 buffer1;
+};
+
+struct tdes1_rd {
+	u32 buffer2;
+};
+
+struct tdes2_rd {
+	u32 buf1len:14;
+	u32 vtir:2;
+	u32 buf2len:14;
+	u32 ttse:1;
+	u32 ioc:1;
+};
+
+struct tdes3_rd {
+	u32 fl:15;
+	u32 tiplh:1;
+	u32 cic:2;
+	u32 tse:1;
+	u32 slotnum:4;
+	u32 saic:3;
+	u32 cpc:2;
+	u32 ld:1;
+	u32 fd:1;
+	u32 ctxt:1;
+	u32 own:1;
+};
+
+struct tdes0_wr {
+	u32 ts_lo;
+};
+
+struct tdes1_wr {
+	u32 ts_hi;
+};
+
+struct tdes2_wr {
+	u32 rsvd;
+};
+
+struct tdes3_wr {
+	u32 ihe:1;
+	u32 db:1;
+	u32 uf:1;
+	u32 ed:1;
+	u32 cc:4;
+	u32 ec:1;
+	u32 lc:1;
+	u32 nc:1;
+	u32 loc:1;
+	u32 pce:1;
+	u32 ff:1;
+	u32 jt:1;
+	u32 es:1;
+	u32 rsvd1:1;
+	u32 ttss:1;
+	u32 rsvd:10;
+	u32 ld:1;
+	u32 fd:1;
+	u32 ctxt:1;
+	u32 own:1;
+};
+
+struct rdes0_rd {
+	u32 buffer1;
+};
+
+struct rdes1_rd {
+	u32 reserved;
+};
+
+struct rdes2_rd {
+	u32 buffer2;
+};
+
+struct rdes3_rd {
+	u32 rsvd1:24;
+	u32 buf1v:1;
+	u32 buf2v:1;
+	u32 rsvd:4;
+	u32 inte:1;
+	u32 own:1;
+};
+
+struct rdes0_wr {
+	u32 vt:16;
+	u32 rsvd:16;
+};
+
+struct rdes1_wr {
+	u32 pt:3;
+	u32 iphe:1;
+	u32 ipv4:1;
+	u32 ipv6:1;
+	u32 ipcb:1;
+	u32 ipce:1;
+	u32 pmt:4;
+	u32 pft:1;
+	u32 pv:1;
+	u32 tsa:1;
+	u32 td:1;
+	u32 ipt1c:16;
+};
+
+struct rdes2_wr {
+	u32 hl:10;
+	u32 arprcvf:1;
+	u32 arpnr:1;
+	u32 rsvd:3;
+	u32 vf:1;
+	u32 saf:1;
+	u32 daf:1;
+	u32 hf:1;
+	u32 madrm:8;
+	u32 l3fm:1;
+	u32 l4fm:1;
+	u32 l3l4fm:3;
+};
+
+struct rdes3_wr {
+	u32 length:15;
+	u32 es:1;
+	u32 lt:3;
+	u32 de:1;
+	u32 re:1;
+	u32 oe:1;
+	u32 rwt:1;
+	u32 gp:1;
+	u32 ce:1;
+	u32 rs0v:1;
+	u32 rs1v:1;
+	u32 rs2v:1;
+	u32 ld:1;
+	u32 fd:1;
+	u32 ctxt:1;
+	u32 own:1;
+};
+
+struct dwc_eth_qos_txdesc {
+	union {
+		struct tdes0_rd rd;
+		struct tdes0_wr wr;
+		u32 raw;
+	} tdes0;
+	union {
+		struct tdes1_rd rd;
+		struct tdes1_wr wr;
+		u32 raw;
+	} tdes1;
+	union {
+		struct tdes2_rd rd;
+		struct tdes2_wr wr;
+		u32 raw;
+	} tdes2;
+	union {
+		struct tdes3_rd rd;
+		struct tdes3_wr wr;
+		u32 raw;
+	} tdes3;
+};
+
+struct dwc_eth_qos_rxdesc {
+	union {
+		struct rdes0_rd rd;
+		struct rdes0_wr wr;
+		u32 raw;
+	} rdes0;
+	union {
+		struct rdes1_rd rd;
+		struct rdes1_wr wr;
+		u32 raw;
+	} rdes1;
+	union {
+		struct rdes2_rd rd;
+		struct rdes2_wr wr;
+		u32 raw;
+	} rdes2;
+	union {
+		struct rdes3_rd rd;
+		struct rdes3_wr wr;
+		u32 raw;
+	} rdes3;
+};
+
+#endif
-- 
1.7.2.5
