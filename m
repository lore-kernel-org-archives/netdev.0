From: ganesanr@broadcom.com
Subject: [PATCH 1/2] NET: ethernet/netlogic: Netlogic XLR/XLS GMAC
 driver
Date: Tue, 29 Jan 2013 14:41:38 +0530
Message-ID: <1359450699-26141-1-git-send-email-ganesanr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ganesan Ramalingam" <ganesanr@broadcom.com>
To: linux-mips@linux-mips.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1114 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754949Ab3A2JMF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 04:12:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesan Ramalingam <ganesanr@broadcom.com>

Add support for the Network Accelerator Engine on Netlogic XLR/XLS
MIPS SoCs. The XLR/XLS NAE blocks can be configured as one 10G
interface or four 1G interfaces. This driver supports blocks
with 1G ports.

Signed-off-by: Ganesan Ramalingam <ganesanr@broadcom.com>
---
 This patch has to be merged through netdev tree.
 Please review and let me know if there are any comments or suggestions.

 drivers/net/ethernet/Kconfig            |    1 +
 drivers/net/ethernet/Makefile           |    1 +
 drivers/net/ethernet/netlogic/Kconfig   |    8 +
 drivers/net/ethernet/netlogic/Makefile  |    1 +
 drivers/net/ethernet/netlogic/xlr_net.c | 1132 +++++++++++++++++++++++++++++++
 drivers/net/ethernet/netlogic/xlr_net.h | 1098 ++++++++++++++++++++++++++++++
 6 files changed, 2241 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/netlogic/Kconfig
 create mode 100644 drivers/net/ethernet/netlogic/Makefile
 create mode 100644 drivers/net/ethernet/netlogic/xlr_net.c
 create mode 100644 drivers/net/ethernet/netlogic/xlr_net.h

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index e4ff389..5a8c9dc 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -168,5 +168,6 @@ source "drivers/net/ethernet/via/Kconfig"
 source "drivers/net/ethernet/wiznet/Kconfig"
 source "drivers/net/ethernet/xilinx/Kconfig"
 source "drivers/net/ethernet/xircom/Kconfig"
+source "drivers/net/ethernet/netlogic/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index d447307..cef1593 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -75,3 +75,4 @@ obj-$(CONFIG_NET_VENDOR_VIA) += via/
 obj-$(CONFIG_NET_VENDOR_WIZNET) += wiznet/
 obj-$(CONFIG_NET_VENDOR_XILINX) += xilinx/
 obj-$(CONFIG_NET_VENDOR_XIRCOM) += xircom/
+obj-$(CONFIG_NETLOGIC_XLR_NET) += netlogic/
diff --git a/drivers/net/ethernet/netlogic/Kconfig b/drivers/net/ethernet/netlogic/Kconfig
new file mode 100644
index 0000000..3e83854
--- /dev/null
+++ b/drivers/net/ethernet/netlogic/Kconfig
@@ -0,0 +1,8 @@
+config NETLOGIC_XLR_NET
+	bool "Netlogic XLR/XLS network device"
+	default y
+        select PHYLIB
+	depends on CPU_XLR
+	---help---
+	This driver support Netlogic XLR/XLS on chip gigabit
+	Ethernet.
diff --git a/drivers/net/ethernet/netlogic/Makefile b/drivers/net/ethernet/netlogic/Makefile
new file mode 100644
index 0000000..7fc927a
--- /dev/null
+++ b/drivers/net/ethernet/netlogic/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_NETLOGIC_XLR_NET) += xlr_net.o
diff --git a/drivers/net/ethernet/netlogic/xlr_net.c b/drivers/net/ethernet/netlogic/xlr_net.c
new file mode 100644
index 0000000..adc32da
--- /dev/null
+++ b/drivers/net/ethernet/netlogic/xlr_net.c
@@ -0,0 +1,1132 @@
+/*
+ * Copyright (c) 2003-2012 Broadcom Corporation
+ * All Rights Reserved
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the Broadcom
+ * license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY BROADCOM ``AS IS'' AND ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL BROADCOM OR CONTRIBUTORS BE LIABLE
+ * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+#include <linux/phy.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/smp.h>
+#include <linux/ethtool.h>
+#include <linux/module.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/jiffies.h>
+#include <linux/interrupt.h>
+#include <linux/platform_device.h>
+
+#include <asm/netlogic/haldefs.h>
+#include <asm/netlogic/xlr/iomap.h>
+#include <asm/netlogic/xlr/fmn.h>
+#include <asm/netlogic/xlr/pic.h>
+#include <asm/netlogic/xlr/platform_net.h>
+#include <asm/netlogic/xlr/xlr.h>
+#include <asm/netlogic/mips-extns.h>
+#include <asm/netlogic/common.h>
+
+#include "xlr_net.h"
+
+static inline void xlr_reg_update(unsigned long base_addr,
+		u32 off, u32 val, u32 mask)
+{
+	u32 tmp;
+
+	tmp = nlm_read_reg(base_addr, off);
+	nlm_write_reg(base_addr, off, (tmp & ~mask) | (val & mask));
+}
+
+/*
+ * Table of net_device pointers indexed by port, this will be used to
+ * lookup the net_device corresponding to a port by the message ring handler.
+ *
+ * Maximum ports in XLR/XLS is 8(8 GMAC on XLS, 4 GMAC + 2 XGMAC on XLR)
+ */
+static struct net_device *mac_to_ndev[8];
+
+static inline struct sk_buff *mac_get_skb_back_ptr(void *addr)
+{
+	struct sk_buff **back_ptr;
+
+	/* this function should be used only for newly allocated packets.
+	 * It assumes the first cacheline is for the back pointer related
+	 * book keeping info.
+	 */
+	back_ptr = (struct sk_buff **)(addr - MAC_SKB_BACK_PTR_SIZE);
+	return *back_ptr;
+}
+
+static inline void mac_put_skb_back_ptr(struct sk_buff *skb)
+{
+	struct sk_buff **back_ptr = (struct sk_buff **)skb->data;
+
+	/* this function should be used only for newly allocated packets.
+	 * It assumes the first cacheline is for the back pointer related
+	 * book keeping info.
+	 */
+	skb_reserve(skb, MAC_SKB_BACK_PTR_SIZE);
+	*back_ptr = skb;
+}
+
+static int send_to_rfr_fifo(struct xlr_net_priv *priv, void *addr)
+{
+	struct nlm_fmn_msg msg;
+	int ret = 0, num_try = 0, stnid;
+	unsigned long paddr, mflags;
+
+	paddr = virt_to_bus(addr);
+	msg.msg0 = (u64)paddr & 0xffffffffe0ULL;
+	msg.msg1 = 0;
+	msg.msg2 = 0;
+	msg.msg3 = 0;
+	stnid = priv->nd->rfr_station;
+	do {
+		mflags = nlm_cop2_enable();
+		ret = nlm_fmn_send(1, 0, stnid, &msg);
+		nlm_cop2_restore(mflags);
+		if (ret == 0)
+			return 0;
+	} while (++num_try < 10000);
+
+	pr_err("Send to RFR failed in RX path\n");
+	return ret;
+}
+
+static inline struct sk_buff *xlr_alloc_skb(void)
+{
+	struct sk_buff *skb;
+
+	/* skb->data is cache aligned */
+	skb = alloc_skb(XLR_RX_BUF_SIZE, GFP_ATOMIC);
+	if (!skb) {
+		pr_err("SKB allocation failed\n");
+		return NULL;
+	}
+	mac_put_skb_back_ptr(skb);
+	return skb;
+}
+
+static void xlr_net_fmn_handler(int bkt, int src_stnid, int size,
+		int code, struct nlm_fmn_msg *msg, void *arg)
+{
+	struct sk_buff *skb, *skb_new = NULL;
+	struct net_device *ndev;
+	struct xlr_net_priv *priv;
+	u64 length, port;
+	void *addr;
+
+	length = (msg->msg0 >> 40) & 0x3fff;
+	if (length == 0) {
+		addr = bus_to_virt(msg->msg0 & 0xffffffffffULL);
+		dev_kfree_skb_any(addr);
+	} else if (length) {
+		addr = bus_to_virt(msg->msg0 & 0xffffffffe0ULL);
+		length = length - BYTE_OFFSET - MAC_CRC_LEN;
+		port = msg->msg0 & 0x0f;
+		if (src_stnid == FMN_STNID_GMAC1)
+			port = port + 4;
+		skb = mac_get_skb_back_ptr(addr);
+		skb->dev = mac_to_ndev[port];
+		ndev = skb->dev;
+		priv = netdev_priv(ndev);
+
+		/* 16 byte IP header align */
+		skb_reserve(skb, BYTE_OFFSET);
+		skb_put(skb, length);
+		skb->protocol = eth_type_trans(skb, skb->dev);
+		skb->dev->last_rx = jiffies;
+		netif_rx(skb);
+		/* Fill rx ring */
+		skb_new = xlr_alloc_skb();
+		if (skb_new)
+			send_to_rfr_fifo(priv, skb_new->data);
+	}
+	return;
+}
+
+/* Ethtool operation */
+static int xlr_get_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
+{
+	return 0;
+}
+
+static int xlr_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
+{
+	return 0;
+}
+
+static void xlr_get_drvinfo(struct net_device *ndev,
+		struct ethtool_drvinfo *drvinfo)
+{
+	return;
+}
+
+static u32 xlr_get_link(struct net_device *ndev)
+{
+	return 0;
+}
+
+static struct ethtool_ops xlr_ethtool_ops = {
+	.get_settings = xlr_get_settings,
+	.set_settings = xlr_set_settings,
+	.get_drvinfo = xlr_get_drvinfo,
+	.get_link = xlr_get_link,
+};
+
+
+/* Net operations */
+static int xlr_net_fill_rx_ring(struct net_device *ndev)
+{
+	struct sk_buff *skb;
+	struct xlr_net_priv *priv = netdev_priv(ndev);
+	int i;
+
+	for (i = 0; i < MAX_FRIN_SPILL/2; i++) {
+		skb = xlr_alloc_skb();
+		if (!skb)
+			return -ENOMEM;
+		send_to_rfr_fifo(priv, skb->data);
+	}
+	pr_info("Rx ring setup done\n");
+	return 0;
+}
+
+static int xlr_net_open(struct net_device *ndev)
+{
+	u32 err;
+	struct xlr_net_priv *priv = netdev_priv(ndev);
+	struct phy_device *phydev = priv->mii_bus->phy_map[priv->phy_addr];
+
+	/* schedule a link state check */
+	phy_start(phydev);
+
+	err = phy_start_aneg(phydev);
+	if (err) {
+		pr_err("Autoneg failed\n");
+		return err;
+	}
+
+	/* Setup the speed from PHY to internal reg*/
+	xlr_set_gmac_speed(priv);
+	netif_tx_start_all_queues(ndev);
+	return 0;
+}
+
+static int xlr_net_stop(struct net_device *ndev)
+{
+	struct xlr_net_priv *priv = netdev_priv(ndev);
+	struct phy_device *phydev = priv->mii_bus->phy_map[priv->phy_addr];
+
+	phy_stop(phydev);
+	netif_tx_stop_all_queues(ndev);
+	return 0;
+}
+
+static void xlr_make_tx_desc(struct nlm_fmn_msg *msg, unsigned long addr,
+		struct sk_buff *skb)
+{
+	unsigned long physkb = virt_to_phys(skb);
+	int cpu_core = nlm_core_id();
+	int fr_stn_id = cpu_core * 8 + XLR_FB_STN;	/* FB to 6th bucket */
+	msg->msg0 = (((u64)1 << 63)	|	/* End of packet descriptor */
+		((u64)127 << 54)	|	/* No Free back */
+		(u64)skb->len << 40	|	/* Length of data */
+		((u64)addr));
+	msg->msg1 = (((u64)1 << 63)	|
+		((u64)fr_stn_id << 54)	|	/* Free back id */
+		(u64)0 << 40		|	/* Set len to 0 */
+		((u64)physkb  & 0xffffffff));	/* 32bit address */
+	msg->msg2 = msg->msg3 = 0;
+}
+
+static void __maybe_unused xlr_wakeup_queue(unsigned long dev)
+{
+	struct net_device *ndev = (struct net_device *) dev;
+	struct xlr_net_priv *priv = netdev_priv(ndev);
+	struct phy_device *phydev = priv->mii_bus->phy_map[priv->phy_addr];
+
+	if (phydev->link)
+		netif_tx_wake_queue(netdev_get_tx_queue(ndev, priv->wakeup_q));
+}
+
+static netdev_tx_t xlr_net_start_xmit(struct sk_buff *skb,
+		struct net_device *ndev)
+{
+	struct nlm_fmn_msg msg;
+	struct xlr_net_priv *priv = netdev_priv(ndev);
+	int ret;
+	u16 qmap;
+	u32 flags;
+
+	qmap = skb->queue_mapping;
+	xlr_make_tx_desc(&msg, virt_to_phys(skb->data), skb);
+	flags = nlm_cop2_enable();
+	ret = nlm_fmn_send(2, 0, priv->nd->tx_stnid, &msg);
+	nlm_cop2_restore(flags);
+	return NETDEV_TX_OK;
+}
+
+static u16 xlr_net_select_queue(struct net_device *ndev, struct sk_buff *skb)
+{
+	return (u16)smp_processor_id();
+}
+
+static void xlr_hw_set_mac_addr(struct net_device *ndev)
+{
+	struct xlr_net_priv *priv = netdev_priv(ndev);
+
+	/* set mac station address */
+	nlm_write_reg(priv->base_addr, R_MAC_ADDR0,
+		((ndev->dev_addr[5] << 24) | (ndev->dev_addr[4] << 16) |
+		(ndev->dev_addr[3] << 8) | (ndev->dev_addr[2])));
+	nlm_write_reg(priv->base_addr, R_MAC_ADDR0 + 1,
+		((ndev->dev_addr[1] << 24) | (ndev->dev_addr[0] << 16)));
+
+	nlm_write_reg(priv->base_addr, R_MAC_ADDR_MASK2, 0xffffffff);
+	nlm_write_reg(priv->base_addr, R_MAC_ADDR_MASK2 + 1, 0xffffffff);
+	nlm_write_reg(priv->base_addr, R_MAC_ADDR_MASK3, 0xffffffff);
+	nlm_write_reg(priv->base_addr, R_MAC_ADDR_MASK3 + 1, 0xffffffff);
+
+	nlm_write_reg(priv->base_addr, R_MAC_FILTER_CONFIG,
+		(1 << O_MAC_FILTER_CONFIG__BROADCAST_EN) |
+		(1 << O_MAC_FILTER_CONFIG__ALL_MCAST_EN) |
+		(1 << O_MAC_FILTER_CONFIG__MAC_ADDR0_VALID));
+
+	if (priv->nd->phy_interface == PHY_INTERFACE_MODE_RGMII ||
+			priv->nd->phy_interface == PHY_INTERFACE_MODE_SGMII)
+		xlr_reg_update(priv->base_addr, R_IPG_IFG, MAC_B2B_IPG, 0x7f);
+}
+
+static int xlr_net_set_mac_addr(struct net_device *ndev, void *data)
+{
+	int err;
+
+	err = eth_mac_addr(ndev, data);
+	if (err)
+		return err;
+	xlr_hw_set_mac_addr(ndev);
+	return 0;
+}
+
+static void xlr_set_rx_mode(struct net_device *ndev)
+{
+	struct xlr_net_priv *priv = netdev_priv(ndev);
+	u32 regval;
+
+	regval = nlm_read_reg(priv->base_addr, R_MAC_FILTER_CONFIG);
+
+	if (ndev->flags & IFF_PROMISC) {
+		regval |= (1 << O_MAC_FILTER_CONFIG__BROADCAST_EN) |
+		(1 << O_MAC_FILTER_CONFIG__PAUSE_FRAME_EN) |
+		(1 << O_MAC_FILTER_CONFIG__ALL_MCAST_EN) |
+		(1 << O_MAC_FILTER_CONFIG__ALL_UCAST_EN);
+	} else {
+		regval &= ~((1 << O_MAC_FILTER_CONFIG__PAUSE_FRAME_EN) |
+		(1 << O_MAC_FILTER_CONFIG__ALL_UCAST_EN));
+	}
+
+	nlm_write_reg(priv->base_addr, R_MAC_FILTER_CONFIG, regval);
+}
+
+static void xlr_stats(struct net_device *ndev, struct net_device_stats *stats)
+{
+	struct xlr_net_priv *priv = netdev_priv(ndev);
+
+	stats->rx_packets = nlm_read_reg(priv->base_addr, RX_PACKET_COUNTER);
+	stats->tx_packets = nlm_read_reg(priv->base_addr, TX_PACKET_COUNTER);
+	stats->rx_bytes = nlm_read_reg(priv->base_addr, RX_BYTE_COUNTER);
+	stats->tx_bytes = nlm_read_reg(priv->base_addr, TX_BYTE_COUNTER);
+	stats->tx_errors = nlm_read_reg(priv->base_addr, TX_FCS_ERROR_COUNTER);
+	stats->rx_dropped = nlm_read_reg(priv->base_addr,
+			RX_DROP_PACKET_COUNTER);
+	stats->tx_dropped = nlm_read_reg(priv->base_addr,
+			TX_DROP_FRAME_COUNTER);
+
+	stats->multicast = nlm_read_reg(priv->base_addr,
+			RX_MULTICAST_PACKET_COUNTER);
+	stats->collisions = nlm_read_reg(priv->base_addr,
+			TX_TOTAL_COLLISION_COUNTER);
+
+	stats->rx_length_errors = nlm_read_reg(priv->base_addr,
+			RX_FRAME_LENGTH_ERROR_COUNTER);
+	stats->rx_over_errors = nlm_read_reg(priv->base_addr,
+			RX_DROP_PACKET_COUNTER);
+	stats->rx_crc_errors = nlm_read_reg(priv->base_addr,
+			RX_FCS_ERROR_COUNTER);
+	stats->rx_frame_errors = nlm_read_reg(priv->base_addr,
+			RX_ALIGNMENT_ERROR_COUNTER);
+
+	stats->rx_fifo_errors = nlm_read_reg(priv->base_addr,
+			RX_DROP_PACKET_COUNTER);
+	stats->rx_missed_errors = nlm_read_reg(priv->base_addr,
+			RX_CARRIER_SENSE_ERROR_COUNTER);
+
+	stats->rx_errors = (stats->rx_over_errors + stats->rx_crc_errors +
+			stats->rx_frame_errors + stats->rx_fifo_errors +
+			stats->rx_missed_errors);
+
+	stats->tx_aborted_errors = nlm_read_reg(priv->base_addr,
+			TX_EXCESSIVE_COLLISION_PACKET_COUNTER);
+	stats->tx_carrier_errors = nlm_read_reg(priv->base_addr,
+			TX_DROP_FRAME_COUNTER);
+	stats->tx_fifo_errors = nlm_read_reg(priv->base_addr,
+			TX_DROP_FRAME_COUNTER);
+}
+
+struct net_device_stats *xlr_get_stats(struct net_device *ndev)
+{
+	struct net_device_stats *stats = &ndev->stats;
+
+	xlr_stats(ndev, stats);
+	return stats;
+}
+
+static struct net_device_ops xlr_netdev_ops = {
+	.ndo_open = xlr_net_open,
+	.ndo_stop = xlr_net_stop,
+	.ndo_start_xmit = xlr_net_start_xmit,
+	.ndo_select_queue = xlr_net_select_queue,
+	.ndo_set_mac_address = xlr_net_set_mac_addr,
+	.ndo_set_rx_mode = xlr_set_rx_mode,
+	.ndo_get_stats = xlr_get_stats,
+};
+
+/* Gmac init */
+static void *xlr_config_spill(struct xlr_net_priv *priv, int reg_start_0,
+		int reg_start_1, int reg_size, int size)
+{
+	void *spill;
+	unsigned long base;
+	unsigned long phys_addr;
+	u32 spill_size;
+
+	base = priv->base_addr;
+	spill_size = size;
+	spill = kmalloc(spill_size + SMP_CACHE_BYTES, GFP_ATOMIC);
+	if (!spill)
+		pr_err("Unable to allocate memory for spill area!\n");
+
+	spill = PTR_ALIGN(spill, SMP_CACHE_BYTES);
+	phys_addr = virt_to_phys(spill);
+	dev_dbg(&priv->ndev->dev, "Allocated spill %d bytes at %lx\n",
+			size, phys_addr);
+	nlm_write_reg(base, reg_start_0, (phys_addr >> 5) & 0xffffffff);
+	nlm_write_reg(base, reg_start_1, ((u64)phys_addr >> 37) & 0x07);
+	nlm_write_reg(base, reg_size, spill_size);
+
+	return spill;
+}
+
+/*
+ * Configure the 6 FIFO's that are used by the network accelarator to
+ * communicate with the rest of the XLx device. 4 of the FIFO's are for
+ * packets from NA --> cpu (called Class FIFO's) and 2 are for feeding
+ * the NA with free descriptors.
+ */
+static void xlr_config_fifo_spill_area(struct xlr_net_priv *priv)
+{
+	priv->frin_spill = xlr_config_spill(priv,
+			R_REG_FRIN_SPILL_MEM_START_0,
+			R_REG_FRIN_SPILL_MEM_START_1,
+			R_REG_FRIN_SPILL_MEM_SIZE,
+			MAX_FRIN_SPILL *
+			sizeof(u64));
+	priv->frout_spill = xlr_config_spill(priv,
+			R_FROUT_SPILL_MEM_START_0,
+			R_FROUT_SPILL_MEM_START_1,
+			R_FROUT_SPILL_MEM_SIZE,
+			MAX_FROUT_SPILL *
+			sizeof(u64));
+	priv->class_0_spill = xlr_config_spill(priv,
+			R_CLASS0_SPILL_MEM_START_0,
+			R_CLASS0_SPILL_MEM_START_1,
+			R_CLASS0_SPILL_MEM_SIZE,
+			MAX_CLASS_0_SPILL *
+			sizeof(u64));
+	priv->class_1_spill = xlr_config_spill(priv,
+			R_CLASS1_SPILL_MEM_START_0,
+			R_CLASS1_SPILL_MEM_START_1,
+			R_CLASS1_SPILL_MEM_SIZE,
+			MAX_CLASS_1_SPILL *
+			sizeof(u64));
+	priv->class_2_spill = xlr_config_spill(priv,
+			R_CLASS2_SPILL_MEM_START_0,
+			R_CLASS2_SPILL_MEM_START_1,
+			R_CLASS2_SPILL_MEM_SIZE,
+			MAX_CLASS_2_SPILL *
+			sizeof(u64));
+	priv->class_3_spill = xlr_config_spill(priv,
+			R_CLASS3_SPILL_MEM_START_0,
+			R_CLASS3_SPILL_MEM_START_1,
+			R_CLASS3_SPILL_MEM_SIZE,
+			MAX_CLASS_3_SPILL *
+			sizeof(u64));
+}
+
+/* Configure PDE to Round-Robin distribution of packets to the
+ * available cpu */
+static void xlr_config_pde(struct xlr_net_priv *priv)
+{
+	int i = 0, num_cpu_core = 0;
+	u64 bkt_map = 0;
+
+	/* Each core has 8 buckets(station) */
+	num_cpu_core = hweight32(nlm_current_node()->coremask);
+	for (i = 0; i < num_cpu_core; i++)
+		bkt_map |= (0xff << (i * 8));
+
+	nlm_write_reg(priv->base_addr, R_PDE_CLASS_0, (bkt_map & 0xffffffff));
+	nlm_write_reg(priv->base_addr, R_PDE_CLASS_0 + 1,
+			((bkt_map >> 32) & 0xffffffff));
+
+	nlm_write_reg(priv->base_addr, R_PDE_CLASS_1, (bkt_map & 0xffffffff));
+	nlm_write_reg(priv->base_addr, R_PDE_CLASS_1 + 1,
+			((bkt_map >> 32) & 0xffffffff));
+
+	nlm_write_reg(priv->base_addr, R_PDE_CLASS_2, (bkt_map & 0xffffffff));
+	nlm_write_reg(priv->base_addr, R_PDE_CLASS_2 + 1,
+			((bkt_map >> 32) & 0xffffffff));
+
+	nlm_write_reg(priv->base_addr, R_PDE_CLASS_3, (bkt_map & 0xffffffff));
+	nlm_write_reg(priv->base_addr, R_PDE_CLASS_3 + 1,
+			((bkt_map >> 32) & 0xffffffff));
+}
+
+/* Setup the Message ring credits, bucket size and other
+ * common configuration */
+static void xlr_config_common(struct xlr_net_priv *priv)
+{
+	struct xlr_fmn_info *gmac = priv->nd->gmac_fmn_info;
+	int start_stn_id = gmac->start_stn_id;
+	int end_stn_id = gmac->end_stn_id;
+	int *bucket_size = priv->nd->bucket_size;
+	int i, j;
+
+	/* Setting non-core MsgBktSize(0x321 - 0x325) */
+	for (i = start_stn_id; i <= end_stn_id; i++) {
+		nlm_write_reg(priv->base_addr,
+				R_GMAC_RFR0_BUCKET_SIZE + i - start_stn_id,
+				bucket_size[i]);
+	}
+
+	/* Setting non-core Credit counter register
+	 * Distributing Gmac's credit to CPU's*/
+	for (i = 0; i < 8; i++) {
+		for (j = 0; j < 8; j++)
+			nlm_write_reg(priv->base_addr,
+					(R_CC_CPU0_0 + (i * 8)) + j,
+					gmac->credit_config[(i * 8) + j]);
+	}
+
+	nlm_write_reg(priv->base_addr, R_MSG_TX_THRESHOLD, 3);
+	nlm_write_reg(priv->base_addr, R_DMACR0, 0xffffffff);
+	nlm_write_reg(priv->base_addr, R_DMACR1, 0xffffffff);
+	nlm_write_reg(priv->base_addr, R_DMACR2, 0xffffffff);
+	nlm_write_reg(priv->base_addr, R_DMACR3, 0xffffffff);
+	nlm_write_reg(priv->base_addr, R_FREEQCARVE, 0);
+
+	xlr_net_fill_rx_ring(priv->ndev);
+	nlm_register_fmn_handler(start_stn_id, end_stn_id, xlr_net_fmn_handler,
+					NULL);
+}
+
+static void xlr_config_translate_table(struct xlr_net_priv *priv)
+{
+	u32 cpu_mask;
+	u32 val;
+	int bkts[32]; /* one bucket is assumed for each cpu */
+	int b1, b2, c1, c2, i, j, k;
+	int use_bkt;
+
+	use_bkt = 0;
+	cpu_mask = nlm_current_node()->coremask;
+
+	pr_info("Using %s-based distribution\n",
+			(use_bkt) ? "bucket" : "class");
+	j = 0;
+	for (i = 0; i < 32; i++) {
+		if ((1 << i) & cpu_mask) {
+			/* for each cpu, mark the 4+threadid bucket */
+			bkts[j] = ((i / 4) * 8) + (i % 4);
+			j++;
+		}
+	}
+
+	/*configure the 128 * 9 Translation table to send to available buckets*/
+	k = 0;
+	c1 = 3;
+	c2 = 0;
+	for (i = 0; i < 64; i++) {
+		/* On use_bkt set the b0, b1 are used, else
+		 * the 4 classes are used, here implemented
+		 * a logic to distribute the packets to the
+		 * buckets equally or based on the class
+		 */
+		c1 = (c1 + 1) & 3;
+		c2 = (c1 + 1) & 3;
+		b1 = bkts[k];
+		k = (k + 1) % j;
+		b2 = bkts[k];
+		k = (k + 1) % j;
+		val = ((c1 << 23) | (b1 << 17) | (use_bkt << 16) |
+				(c2 << 7) | (b2 << 1) | (use_bkt << 0));
+
+		val = ((c1 << 23) | (b1 << 17) | (use_bkt << 16) |
+				(c2 << 7) | (b2 << 1) | (use_bkt << 0));
+		dev_dbg(&priv->ndev->dev, "Table[%d] b1=%d b2=%d c1=%d c2=%d\n",
+				i, b1, b2, c1, c2);
+		nlm_write_reg(priv->base_addr, R_TRANSLATETABLE + i, val);
+		c1 = c2;
+	}
+}
+
+static void xlr_config_parser(struct xlr_net_priv *priv)
+{
+	u32 val;
+
+	/* Mark it as ETHERNET type */
+	nlm_write_reg(priv->base_addr, R_L2TYPE_0, 0x01);
+
+	/* Use 7bit CRChash for flow classification with 127 as CRC polynomial*/
+	nlm_write_reg(priv->base_addr, R_PARSERCONFIGREG,
+			((0x7f << 8) | (1 << 1)));
+
+	/* configure the parser : L2 Type is configured in the bootloader */
+	/* extract IP: src, dest protocol */
+	nlm_write_reg(priv->base_addr, R_L3CTABLE,
+			(9 << 20) | (1 << 19) | (1 << 18) | (0x01 << 16) |
+			(0x0800 << 0));
+	nlm_write_reg(priv->base_addr, R_L3CTABLE + 1,
+			(9 << 25) | (1 << 21) | (12 << 14) | (4 << 10) |
+			(16 << 4) | 4);
+
+	/* Configure to extract SRC port and Dest port for TCP and UDP pkts */
+	nlm_write_reg(priv->base_addr, R_L4CTABLE, 6);
+	nlm_write_reg(priv->base_addr, R_L4CTABLE + 2, 17);
+	val = ((0 << 21) | (2 << 17) | (2 << 11) | (2 << 7));
+	nlm_write_reg(priv->base_addr, R_L4CTABLE + 1, val);
+	nlm_write_reg(priv->base_addr, R_L4CTABLE + 3, val);
+
+	xlr_config_translate_table(priv);
+}
+
+static int xlr_phy_write(u64 base_addr, int phy_addr, int regnum, u16 val)
+{
+	unsigned long timeout, stoptime, checktime;
+	int timedout;
+
+	/* 100ms timeout*/
+	timeout = msecs_to_jiffies(100);
+	stoptime = jiffies + timeout;
+	timedout = 0;
+
+	nlm_write_reg(base_addr, R_MII_MGMT_ADDRESS, (phy_addr << 8) | regnum);
+
+	/* Write the data which starts the write cycle */
+	nlm_write_reg(base_addr, R_MII_MGMT_WRITE_DATA, (u32) val);
+
+	/* poll for the read cycle to complete */
+	while (!timedout) {
+		checktime = jiffies;
+		if (nlm_read_reg(base_addr, R_MII_MGMT_INDICATORS) == 0)
+			break;
+		timedout = time_after(checktime, stoptime);
+	}
+	if (timedout) {
+		pr_info("Phy device write err: device busy");
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+static int xlr_phy_read(u64 base_addr, int phy_addr, int regnum)
+{
+	unsigned long timeout, stoptime, checktime;
+	int timedout;
+
+	/* 100ms timeout*/
+	timeout = msecs_to_jiffies(100);
+	stoptime = jiffies + timeout;
+	timedout = 0;
+
+	/* setup the phy reg to be used */
+	nlm_write_reg(base_addr, R_MII_MGMT_ADDRESS,
+			(phy_addr << 8) | (regnum << 0));
+
+	/* Issue the read command */
+	nlm_write_reg(base_addr, R_MII_MGMT_COMMAND,
+			(1 << O_MII_MGMT_COMMAND__rstat));
+
+
+	/* poll for the read cycle to complete */
+	while (!timedout) {
+		checktime = jiffies;
+		if (nlm_read_reg(base_addr, R_MII_MGMT_INDICATORS) == 0)
+			break;
+		timedout = time_after(checktime, stoptime);
+	}
+	if (timedout) {
+		pr_info("Phy device read err: device busy");
+		return -EBUSY;
+	}
+
+	/* clear the read cycle */
+	nlm_write_reg(base_addr, R_MII_MGMT_COMMAND, 0);
+
+	/* Read the data */
+	return nlm_read_reg(base_addr, R_MII_MGMT_STATUS);
+}
+
+static int xlr_mii_write(struct mii_bus *bus, int phy_addr, int regnum, u16 val)
+{
+	struct xlr_net_priv *priv = bus->priv;
+	int ret;
+
+	ret = xlr_phy_write(priv->mii_addr, phy_addr, regnum, val);
+	dev_dbg(&priv->ndev->dev, "mii_write phy %d : %d <- %x [%x]\n",
+			phy_addr, regnum, val, ret);
+	return ret;
+}
+
+static int xlr_mii_read(struct mii_bus *bus, int phy_addr, int regnum)
+{
+	struct xlr_net_priv *priv = bus->priv;
+	int ret;
+
+	ret =  xlr_phy_read(priv->mii_addr, phy_addr, regnum);
+	dev_dbg(&priv->ndev->dev, "mii_read phy %d : %d [%x]\n",
+			phy_addr, regnum, ret);
+	return ret;
+}
+
+/* XLR ports are RGMII. XLS ports are SGMII mostly except the port0,
+ * which can be configured either SGMII or RGMII, considered SGMII
+ * by default, if board setup to RGMII the port_type need to set
+ * accordingly.Serdes and PCS layer need to configured for SGMII
+ */
+static void xlr_sgmii_init(struct xlr_net_priv *priv)
+{
+	u64 mmio_gpio;
+	int phy;
+
+	xlr_phy_write(priv->serdes_addr, 26, 0, 0x6DB0);
+	xlr_phy_write(priv->serdes_addr, 26, 1, 0xFFFF);
+	xlr_phy_write(priv->serdes_addr, 26, 2, 0xB6D0);
+	xlr_phy_write(priv->serdes_addr, 26, 3, 0x00FF);
+	xlr_phy_write(priv->serdes_addr, 26, 4, 0x0000);
+	xlr_phy_write(priv->serdes_addr, 26, 5, 0x0000);
+	xlr_phy_write(priv->serdes_addr, 26, 6, 0x0005);
+	xlr_phy_write(priv->serdes_addr, 26, 7, 0x0001);
+	xlr_phy_write(priv->serdes_addr, 26, 8, 0x0000);
+	xlr_phy_write(priv->serdes_addr, 26, 9, 0x0000);
+	xlr_phy_write(priv->serdes_addr, 26, 10, 0x0000);
+
+	/* program  GPIO values for serdes init parameters */
+	mdelay(1000);
+	mmio_gpio = nlm_mmio_base(NETLOGIC_IO_GPIO_OFFSET);
+	nlm_write_reg(mmio_gpio, 0x20, 0x7e6802);
+	nlm_write_reg(mmio_gpio, 0x10, 0x7104);
+	mdelay(1000);
+
+	mdelay(100);
+	nlm_write_reg(mmio_gpio, 0x22, 0x7e6802);
+	nlm_write_reg(mmio_gpio, 0x21, 0x7104);
+	mdelay(100);
+
+
+	/* enable autoneg - more magic */
+	phy = priv->port_id % 4 + 27;
+	xlr_phy_write(priv->pcs_addr, phy, 0, 0x1000);
+	mdelay(1000);
+	xlr_phy_write(priv->pcs_addr, phy, 0, 0x0200);
+	mdelay(1000);
+}
+
+void xlr_set_gmac_speed(struct xlr_net_priv *priv)
+{
+	struct phy_device *phydev = priv->mii_bus->phy_map[priv->phy_addr];
+	int speed;
+
+	if (phydev->interface == PHY_INTERFACE_MODE_SGMII)
+		xlr_sgmii_init(priv);
+
+	if (phydev->speed != priv->phy_speed) {
+		pr_info("change %d to %d\n", priv->phy_speed, phydev->speed);
+		speed = phydev->speed;
+		if (speed == SPEED_1000) {
+			/* Set interface to Byte mode */
+			nlm_write_reg(priv->base_addr, R_MAC_CONFIG_2, 0x7217);
+			priv->phy_speed = speed;
+		} else if (speed == SPEED_100 || speed == SPEED_10) {
+			/* Set interface to Nibble mode */
+			nlm_write_reg(priv->base_addr, R_MAC_CONFIG_2, 0x7117);
+			priv->phy_speed = speed;
+		}
+		/* Set SGMII speed in Interface controll reg */
+		if (phydev->interface == PHY_INTERFACE_MODE_SGMII) {
+			if (speed == SPEED_10)
+				nlm_write_reg(priv->base_addr,
+					R_INTERFACE_CONTROL, SGMII_SPEED_10);
+			if (speed == SPEED_100)
+				nlm_write_reg(priv->base_addr,
+					R_INTERFACE_CONTROL, SGMII_SPEED_100);
+			if (speed == SPEED_1000)
+				nlm_write_reg(priv->base_addr,
+					R_INTERFACE_CONTROL, SGMII_SPEED_1000);
+		}
+		if (speed == SPEED_10)
+			nlm_write_reg(priv->base_addr, R_CORECONTROL, 0x2);
+		if (speed == SPEED_100)
+			nlm_write_reg(priv->base_addr, R_CORECONTROL, 0x1);
+		if (speed == SPEED_1000)
+			nlm_write_reg(priv->base_addr, R_CORECONTROL, 0x0);
+	}
+	pr_info("gmac%d : %dMbps\n", priv->port_id, priv->phy_speed);
+}
+
+static void xlr_gmac_link_adjust(struct net_device *ndev)
+{
+	struct xlr_net_priv *priv = netdev_priv(ndev);
+	struct phy_device *phydev = priv->mii_bus->phy_map[priv->phy_addr];
+	u32 intreg;
+
+	intreg = nlm_read_reg(priv->base_addr, R_INTREG);
+	if (phydev->link) {
+		if (phydev->speed != priv->phy_speed) {
+			pr_info("gmac%d : Link up\n", priv->port_id);
+			xlr_set_gmac_speed(priv);
+		}
+	} else {
+		pr_info("gmac%d : Link down\n", priv->port_id);
+		xlr_set_gmac_speed(priv);
+	}
+}
+
+static int xlr_mii_probe(struct xlr_net_priv *priv)
+{
+	struct phy_device *phydev = priv->mii_bus->phy_map[priv->phy_addr];
+
+	if (!phydev) {
+		pr_err("no PHY found on phy_addr %d\n", priv->phy_addr);
+		return -ENODEV;
+	}
+
+	/* Attach MAC to PHY */
+	phydev = phy_connect(priv->ndev, dev_name(&phydev->dev),
+			&xlr_gmac_link_adjust, 0, priv->nd->phy_interface);
+
+	if (IS_ERR(phydev)) {
+		pr_err("could not attach PHY\n");
+		return PTR_ERR(phydev);
+	}
+	phydev->supported &= (ADVERTISED_10baseT_Full
+				| ADVERTISED_10baseT_Half
+				| ADVERTISED_100baseT_Full
+				| ADVERTISED_100baseT_Half
+				| ADVERTISED_1000baseT_Full
+				| ADVERTISED_Autoneg
+				| ADVERTISED_MII);
+
+	phydev->advertising = phydev->supported;
+	pr_info("attached PHY driver [%s] (mii_bus:phy_addr=%s\n",
+		phydev->drv->name, dev_name(&phydev->dev));
+	return 0;
+}
+
+static int xlr_setup_mdio(struct xlr_net_priv *priv,
+		struct platform_device *pdev)
+{
+	int err;
+
+	priv->phy_addr = priv->nd->phy_addr;
+	priv->mii_bus = mdiobus_alloc();
+	if (!priv->mii_bus) {
+		pr_err("mdiobus alloc failed\n");
+		return -ENOMEM;
+	}
+
+	priv->mii_bus->priv = priv;
+	priv->mii_bus->name = "xlr-mdio";
+	snprintf(priv->mii_bus->id, MII_BUS_ID_SIZE, "%s-%d",
+			priv->mii_bus->name, priv->port_id);
+	priv->mii_bus->read = xlr_mii_read;
+	priv->mii_bus->write = xlr_mii_write;
+	priv->mii_bus->parent = &pdev->dev;
+	priv->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
+	priv->mii_bus->irq[priv->phy_addr] = priv->ndev->irq;
+
+	/* Scan only the enabled address */
+	priv->mii_bus->phy_mask = ~(1 << priv->phy_addr);
+
+	/* setting clock divisor to 54 */
+	nlm_write_reg(priv->base_addr, R_MII_MGMT_CONFIG, 0x7);
+
+	err = mdiobus_register(priv->mii_bus);
+	if (err) {
+		mdiobus_free(priv->mii_bus);
+		pr_err("mdio bus registration failed\n");
+		return err;
+	}
+
+	pr_info("Registerd mdio bus id : %s\n", priv->mii_bus->id);
+	err = xlr_mii_probe(priv);
+	if (err) {
+		mdiobus_free(priv->mii_bus);
+		return err;
+	}
+	return 0;
+}
+
+static void xlr_port_enable(struct xlr_net_priv *priv)
+{
+	/* Setup MAC_CONFIG reg */
+	if (nlm_chip_is_xls() &&
+			priv->nd->phy_interface == PHY_INTERFACE_MODE_RGMII)
+		xlr_reg_update(priv->base_addr, R_RX_CONTROL,
+			(1 << O_RX_CONTROL__RGMII), (1 << O_RX_CONTROL__RGMII));
+
+	/* Rx Tx enable */
+	xlr_reg_update(priv->base_addr, R_MAC_CONFIG_1,
+		((1 << O_MAC_CONFIG_1__rxen) | (1 << O_MAC_CONFIG_1__txen) |
+		(1 << O_MAC_CONFIG_1__rxfc) | (1 << O_MAC_CONFIG_1__txfc)),
+		((1 << O_MAC_CONFIG_1__rxen) | (1 << O_MAC_CONFIG_1__txen) |
+		(1 << O_MAC_CONFIG_1__rxfc) | (1 << O_MAC_CONFIG_1__txfc)));
+
+	/* Setup tx control reg */
+	xlr_reg_update(priv->base_addr, R_TX_CONTROL,
+		((1 << O_TX_CONTROL__TxEnable) |
+		(512 << O_TX_CONTROL__TxThreshold)), 0x3fff);
+
+	/* Setup rx control reg */
+	xlr_reg_update(priv->base_addr, R_RX_CONTROL,
+		1 << O_RX_CONTROL__RxEnable, 1 << O_RX_CONTROL__RxEnable);
+}
+
+static void xlr_port_disable(struct xlr_net_priv *priv)
+{
+	/* Setup MAC_CONFIG reg */
+	/* Rx Tx disable*/
+	xlr_reg_update(priv->base_addr, R_MAC_CONFIG_1,
+		((1 << O_MAC_CONFIG_1__rxen) | (1 << O_MAC_CONFIG_1__txen) |
+		(1 << O_MAC_CONFIG_1__rxfc) | (1 << O_MAC_CONFIG_1__txfc)),
+		0x0);
+
+	/* Setup tx control reg */
+	xlr_reg_update(priv->base_addr, R_TX_CONTROL,
+		((1 << O_TX_CONTROL__TxEnable) |
+		(512 << O_TX_CONTROL__TxThreshold)), 0);
+
+	/* Setup rx control reg */
+	xlr_reg_update(priv->base_addr, R_RX_CONTROL,
+		1 << O_RX_CONTROL__RxEnable, 0);
+}
+
+/* Initialization of gmac */
+static int xlr_gmac_init(struct xlr_net_priv *priv,
+		struct platform_device *pdev)
+{
+	int ret;
+
+	pr_info("Initializing the gmac%d\n", priv->port_id);
+
+	xlr_port_disable(priv);
+	nlm_write_reg(priv->base_addr, R_DESC_PACK_CTRL,
+			(1 << O_DESC_PACK_CTRL__MaxEntry)
+			| (BYTE_OFFSET << O_DESC_PACK_CTRL__ByteOffset)
+			| (1600 << O_DESC_PACK_CTRL__RegularSize));
+
+	ret = xlr_setup_mdio(priv, pdev);
+	if (ret)
+		return ret;
+	xlr_port_enable(priv);
+
+	/* Enable Full-duplex/1000Mbps/CRC */
+	nlm_write_reg(priv->base_addr, R_MAC_CONFIG_2, 0x7217);
+	/* speed 2.5Mhz */
+	nlm_write_reg(priv->base_addr, R_CORECONTROL, 0x02);
+	/* Setup Interrupt mask reg */
+	nlm_write_reg(priv->base_addr, R_INTMASK,
+		(1 << O_INTMASK__TxIllegal)	|
+		(1 << O_INTMASK__MDInt)		|
+		(1 << O_INTMASK__TxFetchError)	|
+		(1 << O_INTMASK__P2PSpillEcc)	|
+		(1 << O_INTMASK__TagFull)	|
+		(1 << O_INTMASK__Underrun)	|
+		(1 << O_INTMASK__Abort)
+		);
+
+	/* Clear all stats */
+	xlr_reg_update(priv->base_addr, R_STATCTRL,
+		0, 1 << O_STATCTRL__ClrCnt);
+	xlr_reg_update(priv->base_addr, R_STATCTRL,
+		1 << O_STATCTRL__ClrCnt, 1 << O_STATCTRL__ClrCnt);
+	return 0;
+}
+
+static int xlr_net_probe(struct platform_device *pdev)
+{
+	struct xlr_net_priv *priv = NULL;
+	struct net_device *ndev;
+	struct resource *res;
+	int mac, err;
+
+	mac = pdev->id;
+	ndev = alloc_etherdev_mq(sizeof(struct xlr_net_priv), 32);
+	if (!ndev) {
+		pr_err("Allocation of Ethernet device failed\n");
+		return -ENOMEM;
+	}
+
+	priv = netdev_priv(ndev);
+	priv->pdev = pdev;
+	priv->ndev = ndev;
+	priv->port_id = mac;
+	priv->nd = (struct xlr_net_data *)pdev->dev.platform_data;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (res == NULL) {
+		pr_err("No memory resource for MAC %d\n", mac);
+		err = -ENODEV;
+		goto err_gmac;
+	}
+
+	ndev->base_addr = (unsigned long) devm_request_and_ioremap
+		(&pdev->dev, res);
+	if (!ndev->base_addr) {
+		dev_err(&pdev->dev,
+				"devm_request_and_ioremap failed\n");
+		return -EBUSY;
+	}
+
+	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	if (res == NULL) {
+		pr_err("No irq resource for MAC %d\n", mac);
+		err = -ENODEV;
+		goto err_gmac;
+	}
+	ndev->irq = res->start;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	if (res == NULL) {
+		pr_err("No mii resource for MAC %d\n", mac);
+		err = -ENODEV;
+		goto err_gmac;
+	}
+	priv->mii_addr = res->start;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 2);
+	if (res == NULL) {
+		pr_err("No serdes resource for MAC %d\n", mac);
+		err = -ENODEV;
+		goto err_gmac;
+	}
+	priv->serdes_addr = res->start;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 3);
+	if (res == NULL) {
+		pr_err("No pcs resource for MAC %d\n", mac);
+		err = -ENODEV;
+		goto err_gmac;
+	}
+	priv->pcs_addr = res->start;
+
+	priv->base_addr = ndev->base_addr;
+	mac_to_ndev[mac] = ndev;
+
+	ndev->netdev_ops = &xlr_netdev_ops;
+	ndev->watchdog_timeo = 1000 * HZ;
+
+	/* Setup Mac address and Rx mode */
+	eth_hw_addr_random(ndev);
+	xlr_hw_set_mac_addr(ndev);
+	xlr_set_rx_mode(ndev);
+
+	priv->num_rx_desc += MAX_NUM_DESC_SPILL;
+	SET_ETHTOOL_OPS(ndev, &xlr_ethtool_ops);
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+
+	/* Common registers, do one time initialization */
+	if (mac == 0 || mac == 4) {
+		xlr_config_fifo_spill_area(priv);
+		/* Configure PDE to Round-Robin pkt distribution */
+		xlr_config_pde(priv);
+		xlr_config_parser(priv);
+	}
+	/* Call init with respect to port */
+	if (strcmp(res->name, "gmac") == 0) {
+		err = xlr_gmac_init(priv, pdev);
+		if (err) {
+			pr_err("gmac%d init failed\n", mac);
+			goto err_gmac;
+		}
+	}
+
+	if (mac == 0 || mac == 4)
+		xlr_config_common(priv);
+
+	err = register_netdev(ndev);
+	if (err)
+		goto err_netdev;
+	platform_set_drvdata(pdev, priv);
+	return 0;
+
+err_netdev:
+	mdiobus_free(priv->mii_bus);
+err_gmac:
+	free_netdev(ndev);
+	return err;
+}
+
+static int xlr_net_remove(struct platform_device *pdev)
+{
+	struct xlr_net_priv *priv = platform_get_drvdata(pdev);
+	unregister_netdev(priv->ndev);
+	mdiobus_unregister(priv->mii_bus);
+	mdiobus_free(priv->mii_bus);
+	free_netdev(priv->ndev);
+	return 0;
+}
+
+static struct platform_driver xlr_net_driver = {
+	.probe		= xlr_net_probe,
+	.remove		= xlr_net_remove,
+	.driver		= {
+		.name	= "xlr-net",
+		.owner	= THIS_MODULE,
+	},
+};
+
+module_platform_driver(xlr_net_driver);
+
+MODULE_AUTHOR("Ganesan Ramalingam <ganesanr@broadcom.com>");
+MODULE_DESCRIPTION("Ethernet driver for Netlogic XLR/XLS");
+MODULE_LICENSE("GPL v2");
+MODULE_ALIAS("platform:xlr-net");
diff --git a/drivers/net/ethernet/netlogic/xlr_net.h b/drivers/net/ethernet/netlogic/xlr_net.h
new file mode 100644
index 0000000..d4129d9
--- /dev/null
+++ b/drivers/net/ethernet/netlogic/xlr_net.h
@@ -0,0 +1,1098 @@
+/*
+ * Copyright (c) 2003-2012 Broadcom Corporation
+ * All Rights Reserved
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the Broadcom
+ * license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY BROADCOM ``AS IS'' AND ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL BROADCOM OR CONTRIBUTORS BE LIABLE
+ * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+/* #define MAC_SPLIT_MODE */
+
+#define MAC_SPACING                 0x400
+#define XGMAC_SPACING               0x400
+
+/* PE-MCXMAC register and bit field definitions */
+#define R_MAC_CONFIG_1                                              0x00
+#define   O_MAC_CONFIG_1__srst                                      31
+#define   O_MAC_CONFIG_1__simr                                      30
+#define   O_MAC_CONFIG_1__hrrmc                                     18
+#define   W_MAC_CONFIG_1__hrtmc                                      2
+#define   O_MAC_CONFIG_1__hrrfn                                     16
+#define   W_MAC_CONFIG_1__hrtfn                                      2
+#define   O_MAC_CONFIG_1__intlb                                      8
+#define   O_MAC_CONFIG_1__rxfc                                       5
+#define   O_MAC_CONFIG_1__txfc                                       4
+#define   O_MAC_CONFIG_1__srxen                                      3
+#define   O_MAC_CONFIG_1__rxen                                       2
+#define   O_MAC_CONFIG_1__stxen                                      1
+#define   O_MAC_CONFIG_1__txen                                       0
+#define R_MAC_CONFIG_2                                              0x01
+#define   O_MAC_CONFIG_2__prlen                                     12
+#define   W_MAC_CONFIG_2__prlen                                      4
+#define   O_MAC_CONFIG_2__speed                                      8
+#define   W_MAC_CONFIG_2__speed                                      2
+#define   O_MAC_CONFIG_2__hugen                                      5
+#define   O_MAC_CONFIG_2__flchk                                      4
+#define   O_MAC_CONFIG_2__crce                                       1
+#define   O_MAC_CONFIG_2__fulld                                      0
+#define R_IPG_IFG                                                   0x02
+#define   O_IPG_IFG__ipgr1                                          24
+#define   W_IPG_IFG__ipgr1                                           7
+#define   O_IPG_IFG__ipgr2                                          16
+#define   W_IPG_IFG__ipgr2                                           7
+#define   O_IPG_IFG__mifg                                            8
+#define   W_IPG_IFG__mifg                                            8
+#define   O_IPG_IFG__ipgt                                            0
+#define   W_IPG_IFG__ipgt                                            7
+#define R_HALF_DUPLEX                                               0x03
+#define   O_HALF_DUPLEX__abebt                                      24
+#define   W_HALF_DUPLEX__abebt                                       4
+#define   O_HALF_DUPLEX__abebe                                      19
+#define   O_HALF_DUPLEX__bpnb                                       18
+#define   O_HALF_DUPLEX__nobo                                       17
+#define   O_HALF_DUPLEX__edxsdfr                                    16
+#define   O_HALF_DUPLEX__retry                                      12
+#define   W_HALF_DUPLEX__retry                                       4
+#define   O_HALF_DUPLEX__lcol                                        0
+#define   W_HALF_DUPLEX__lcol                                       10
+#define R_MAXIMUM_FRAME_LENGTH                                      0x04
+#define   O_MAXIMUM_FRAME_LENGTH__maxf                               0
+#define   W_MAXIMUM_FRAME_LENGTH__maxf                              16
+#define R_TEST                                                      0x07
+#define   O_TEST__mbof                                               3
+#define   O_TEST__rthdf                                              2
+#define   O_TEST__tpause                                             1
+#define   O_TEST__sstct                                              0
+#define R_MII_MGMT_CONFIG                                           0x08
+#define   O_MII_MGMT_CONFIG__scinc                                   5
+#define   O_MII_MGMT_CONFIG__spre                                    4
+#define   O_MII_MGMT_CONFIG__clks                                    3
+#define   W_MII_MGMT_CONFIG__clks                                    3
+#define R_MII_MGMT_COMMAND                                          0x09
+#define   O_MII_MGMT_COMMAND__scan                                   1
+#define   O_MII_MGMT_COMMAND__rstat                                  0
+#define R_MII_MGMT_ADDRESS                                          0x0A
+#define   O_MII_MGMT_ADDRESS__fiad                                   8
+#define   W_MII_MGMT_ADDRESS__fiad                                   5
+#define   O_MII_MGMT_ADDRESS__fgad                                   5
+#define   W_MII_MGMT_ADDRESS__fgad                                   0
+#define R_MII_MGMT_WRITE_DATA                                       0x0B
+#define   O_MII_MGMT_WRITE_DATA__ctld                                0
+#define   W_MII_MGMT_WRITE_DATA__ctld                               16
+#define R_MII_MGMT_STATUS                                           0x0C
+#define R_MII_MGMT_INDICATORS                                       0x0D
+#define   O_MII_MGMT_INDICATORS__nvalid                              2
+#define   O_MII_MGMT_INDICATORS__scan                                1
+#define   O_MII_MGMT_INDICATORS__busy                                0
+#define R_INTERFACE_CONTROL                                         0x0E
+#define   O_INTERFACE_CONTROL__hrstint                              31
+#define   O_INTERFACE_CONTROL__tbimode                              27
+#define   O_INTERFACE_CONTROL__ghdmode                              26
+#define   O_INTERFACE_CONTROL__lhdmode                              25
+#define   O_INTERFACE_CONTROL__phymod                               24
+#define   O_INTERFACE_CONTROL__hrrmi                                23
+#define   O_INTERFACE_CONTROL__rspd                                 16
+#define   O_INTERFACE_CONTROL__hr100                                15
+#define   O_INTERFACE_CONTROL__frcq                                 10
+#define   O_INTERFACE_CONTROL__nocfr                                 9
+#define   O_INTERFACE_CONTROL__dlfct                                 8
+#define   O_INTERFACE_CONTROL__enjab                                 0
+#define R_INTERFACE_STATUS                                         0x0F
+#define   O_INTERFACE_STATUS__xsdfr                                  9
+#define   O_INTERFACE_STATUS__ssrr                                   8
+#define   W_INTERFACE_STATUS__ssrr                                   5
+#define   O_INTERFACE_STATUS__miilf                                  3
+#define   O_INTERFACE_STATUS__locar                                  2
+#define   O_INTERFACE_STATUS__sqerr                                  1
+#define   O_INTERFACE_STATUS__jabber                                 0
+#define R_STATION_ADDRESS_LS                                       0x10
+#define R_STATION_ADDRESS_MS                                       0x11
+
+/* A-XGMAC register and bit field definitions */
+#define R_XGMAC_CONFIG_0    0x00
+#define   O_XGMAC_CONFIG_0__hstmacrst               31
+#define   O_XGMAC_CONFIG_0__hstrstrctl              23
+#define   O_XGMAC_CONFIG_0__hstrstrfn               22
+#define   O_XGMAC_CONFIG_0__hstrsttctl              18
+#define   O_XGMAC_CONFIG_0__hstrsttfn               17
+#define   O_XGMAC_CONFIG_0__hstrstmiim              16
+#define   O_XGMAC_CONFIG_0__hstloopback             8
+#define R_XGMAC_CONFIG_1    0x01
+#define   O_XGMAC_CONFIG_1__hsttctlen               31
+#define   O_XGMAC_CONFIG_1__hsttfen                 30
+#define   O_XGMAC_CONFIG_1__hstrctlen               29
+#define   O_XGMAC_CONFIG_1__hstrfen                 28
+#define   O_XGMAC_CONFIG_1__tfen                    26
+#define   O_XGMAC_CONFIG_1__rfen                    24
+#define   O_XGMAC_CONFIG_1__hstrctlshrtp            12
+#define   O_XGMAC_CONFIG_1__hstdlyfcstx             10
+#define   W_XGMAC_CONFIG_1__hstdlyfcstx              2
+#define   O_XGMAC_CONFIG_1__hstdlyfcsrx              8
+#define   W_XGMAC_CONFIG_1__hstdlyfcsrx              2
+#define   O_XGMAC_CONFIG_1__hstppen                  7
+#define   O_XGMAC_CONFIG_1__hstbytswp                6
+#define   O_XGMAC_CONFIG_1__hstdrplt64               5
+#define   O_XGMAC_CONFIG_1__hstprmscrx               4
+#define   O_XGMAC_CONFIG_1__hstlenchk                3
+#define   O_XGMAC_CONFIG_1__hstgenfcs                2
+#define   O_XGMAC_CONFIG_1__hstpadmode               0
+#define   W_XGMAC_CONFIG_1__hstpadmode               2
+#define R_XGMAC_CONFIG_2    0x02
+#define   O_XGMAC_CONFIG_2__hsttctlfrcp             31
+#define   O_XGMAC_CONFIG_2__hstmlnkflth             27
+#define   O_XGMAC_CONFIG_2__hstalnkflth             26
+#define   O_XGMAC_CONFIG_2__rflnkflt                24
+#define   W_XGMAC_CONFIG_2__rflnkflt                 2
+#define   O_XGMAC_CONFIG_2__hstipgextmod            16
+#define   W_XGMAC_CONFIG_2__hstipgextmod             5
+#define   O_XGMAC_CONFIG_2__hstrctlfrcp             15
+#define   O_XGMAC_CONFIG_2__hstipgexten              5
+#define   O_XGMAC_CONFIG_2__hstmipgext               0
+#define   W_XGMAC_CONFIG_2__hstmipgext               5
+#define R_XGMAC_CONFIG_3    0x03
+#define   O_XGMAC_CONFIG_3__hstfltrfrm              31
+#define   W_XGMAC_CONFIG_3__hstfltrfrm              16
+#define   O_XGMAC_CONFIG_3__hstfltrfrmdc            15
+#define   W_XGMAC_CONFIG_3__hstfltrfrmdc            16
+#define R_XGMAC_STATION_ADDRESS_LS      0x04
+#define   O_XGMAC_STATION_ADDRESS_LS__hstmacadr0    0
+#define   W_XGMAC_STATION_ADDRESS_LS__hstmacadr0    32
+#define R_XGMAC_STATION_ADDRESS_MS      0x05
+#define R_XGMAC_MAX_FRAME_LEN           0x08
+#define   O_XGMAC_MAX_FRAME_LEN__hstmxfrmwctx       16
+#define   W_XGMAC_MAX_FRAME_LEN__hstmxfrmwctx       14
+#define   O_XGMAC_MAX_FRAME_LEN__hstmxfrmbcrx        0
+#define   W_XGMAC_MAX_FRAME_LEN__hstmxfrmbcrx       16
+#define R_XGMAC_REV_LEVEL               0x0B
+#define   O_XGMAC_REV_LEVEL__revlvl                  0
+#define   W_XGMAC_REV_LEVEL__revlvl                 15
+#define R_XGMAC_MIIM_COMMAND            0x10
+#define   O_XGMAC_MIIM_COMMAND__hstldcmd             3
+#define   O_XGMAC_MIIM_COMMAND__hstmiimcmd           0
+#define   W_XGMAC_MIIM_COMMAND__hstmiimcmd           3
+#define R_XGMAC_MIIM_FILED              0x11
+#define   O_XGMAC_MIIM_FILED__hststfield            30
+#define   W_XGMAC_MIIM_FILED__hststfield             2
+#define   O_XGMAC_MIIM_FILED__hstopfield            28
+#define   W_XGMAC_MIIM_FILED__hstopfield             2
+#define   O_XGMAC_MIIM_FILED__hstphyadx             23
+#define   W_XGMAC_MIIM_FILED__hstphyadx              5
+#define   O_XGMAC_MIIM_FILED__hstregadx             18
+#define   W_XGMAC_MIIM_FILED__hstregadx              5
+#define   O_XGMAC_MIIM_FILED__hsttafield            16
+#define   W_XGMAC_MIIM_FILED__hsttafield             2
+#define   O_XGMAC_MIIM_FILED__miimrddat              0
+#define   W_XGMAC_MIIM_FILED__miimrddat             16
+#define R_XGMAC_MIIM_CONFIG             0x12
+#define   O_XGMAC_MIIM_CONFIG__hstnopram             7
+#define   O_XGMAC_MIIM_CONFIG__hstclkdiv             0
+#define   W_XGMAC_MIIM_CONFIG__hstclkdiv             7
+#define R_XGMAC_MIIM_LINK_FAIL_VECTOR   0x13
+#define   O_XGMAC_MIIM_LINK_FAIL_VECTOR__miimlfvec   0
+#define   W_XGMAC_MIIM_LINK_FAIL_VECTOR__miimlfvec  32
+#define R_XGMAC_MIIM_INDICATOR          0x14
+#define   O_XGMAC_MIIM_INDICATOR__miimphylf          4
+#define   O_XGMAC_MIIM_INDICATOR__miimmoncplt        3
+#define   O_XGMAC_MIIM_INDICATOR__miimmonvld         2
+#define   O_XGMAC_MIIM_INDICATOR__miimmon            1
+#define   O_XGMAC_MIIM_INDICATOR__miimbusy           0
+
+/* GMAC stats registers */
+#define R_RBYT							    0x27
+#define R_RPKT							    0x28
+#define R_RFCS							    0x29
+#define R_RMCA							    0x2A
+#define R_RBCA							    0x2B
+#define R_RXCF							    0x2C
+#define R_RXPF							    0x2D
+#define R_RXUO							    0x2E
+#define R_RALN							    0x2F
+#define R_RFLR							    0x30
+#define R_RCDE							    0x31
+#define R_RCSE							    0x32
+#define R_RUND							    0x33
+#define R_ROVR							    0x34
+#define R_TBYT							    0x38
+#define R_TPKT							    0x39
+#define R_TMCA							    0x3A
+#define R_TBCA							    0x3B
+#define R_TXPF							    0x3C
+#define R_TDFR							    0x3D
+#define R_TEDF							    0x3E
+#define R_TSCL							    0x3F
+#define R_TMCL							    0x40
+#define R_TLCL							    0x41
+#define R_TXCL							    0x42
+#define R_TNCL							    0x43
+#define R_TJBR							    0x46
+#define R_TFCS							    0x47
+#define R_TXCF							    0x48
+#define R_TOVR							    0x49
+#define R_TUND							    0x4A
+#define R_TFRG							    0x4B
+
+/* Glue logic register and bit field definitions */
+#define R_MAC_ADDR0                                                 0x50
+#define R_MAC_ADDR1                                                 0x52
+#define R_MAC_ADDR2                                                 0x54
+#define R_MAC_ADDR3                                                 0x56
+#define R_MAC_ADDR_MASK2                                            0x58
+#define R_MAC_ADDR_MASK3                                            0x5A
+#define R_MAC_FILTER_CONFIG                                         0x5C
+#define   O_MAC_FILTER_CONFIG__BROADCAST_EN                         10
+#define   O_MAC_FILTER_CONFIG__PAUSE_FRAME_EN                       9
+#define   O_MAC_FILTER_CONFIG__ALL_MCAST_EN                         8
+#define   O_MAC_FILTER_CONFIG__ALL_UCAST_EN                         7
+#define   O_MAC_FILTER_CONFIG__HASH_MCAST_EN                        6
+#define   O_MAC_FILTER_CONFIG__HASH_UCAST_EN                        5
+#define   O_MAC_FILTER_CONFIG__ADDR_MATCH_DISC                      4
+#define   O_MAC_FILTER_CONFIG__MAC_ADDR3_VALID                      3
+#define   O_MAC_FILTER_CONFIG__MAC_ADDR2_VALID                      2
+#define   O_MAC_FILTER_CONFIG__MAC_ADDR1_VALID                      1
+#define   O_MAC_FILTER_CONFIG__MAC_ADDR0_VALID                      0
+#define R_HASH_TABLE_VECTOR                                         0x30
+#define R_TX_CONTROL                                                 0x0A0
+#define   O_TX_CONTROL__Tx15Halt                                     31
+#define   O_TX_CONTROL__Tx14Halt                                     30
+#define   O_TX_CONTROL__Tx13Halt                                     29
+#define   O_TX_CONTROL__Tx12Halt                                     28
+#define   O_TX_CONTROL__Tx11Halt                                     27
+#define   O_TX_CONTROL__Tx10Halt                                     26
+#define   O_TX_CONTROL__Tx9Halt                                      25
+#define   O_TX_CONTROL__Tx8Halt                                      24
+#define   O_TX_CONTROL__Tx7Halt                                      23
+#define   O_TX_CONTROL__Tx6Halt                                      22
+#define   O_TX_CONTROL__Tx5Halt                                      21
+#define   O_TX_CONTROL__Tx4Halt                                      20
+#define   O_TX_CONTROL__Tx3Halt                                      19
+#define   O_TX_CONTROL__Tx2Halt                                      18
+#define   O_TX_CONTROL__Tx1Halt                                      17
+#define   O_TX_CONTROL__Tx0Halt                                      16
+#define   O_TX_CONTROL__TxIdle                                       15
+#define   O_TX_CONTROL__TxEnable                                     14
+#define   O_TX_CONTROL__TxThreshold                                  0
+#define   W_TX_CONTROL__TxThreshold                                  14
+#define R_RX_CONTROL                                                 0x0A1
+#define   O_RX_CONTROL__RGMII                                        10
+#define   O_RX_CONTROL__SoftReset			             2
+#define   O_RX_CONTROL__RxHalt                                       1
+#define   O_RX_CONTROL__RxEnable                                     0
+#define R_DESC_PACK_CTRL                                            0x0A2
+#define   O_DESC_PACK_CTRL__ByteOffset                              17
+#define   W_DESC_PACK_CTRL__ByteOffset                              3
+#define   O_DESC_PACK_CTRL__PrePadEnable                            16
+#define   O_DESC_PACK_CTRL__MaxEntry                                14
+#define   W_DESC_PACK_CTRL__MaxEntry                                2
+#define   O_DESC_PACK_CTRL__RegularSize                             0
+#define   W_DESC_PACK_CTRL__RegularSize                             14
+#define R_STATCTRL                                                  0x0A3
+#define   O_STATCTRL__OverFlowEn                                    4
+#define   O_STATCTRL__GIG                                           3
+#define   O_STATCTRL__Sten                                          2
+#define   O_STATCTRL__ClrCnt                                        1
+#define   O_STATCTRL__AutoZ                                         0
+#define R_L2ALLOCCTRL                                               0x0A4
+#define   O_L2ALLOCCTRL__TxL2Allocate                               9
+#define   W_L2ALLOCCTRL__TxL2Allocate                               9
+#define   O_L2ALLOCCTRL__RxL2Allocate                               0
+#define   W_L2ALLOCCTRL__RxL2Allocate                               9
+#define R_INTMASK                                                   0x0A5
+#define   O_INTMASK__Spi4TxError                                     28
+#define   O_INTMASK__Spi4RxError                                     27
+#define   O_INTMASK__RGMIIHalfDupCollision                           27
+#define   O_INTMASK__Abort                                           26
+#define   O_INTMASK__Underrun                                        25
+#define   O_INTMASK__DiscardPacket                                   24
+#define   O_INTMASK__AsyncFifoFull                                   23
+#define   O_INTMASK__TagFull                                         22
+#define   O_INTMASK__Class3Full                                      21
+#define   O_INTMASK__C3EarlyFull                                     20
+#define   O_INTMASK__Class2Full                                      19
+#define   O_INTMASK__C2EarlyFull                                     18
+#define   O_INTMASK__Class1Full                                      17
+#define   O_INTMASK__C1EarlyFull                                     16
+#define   O_INTMASK__Class0Full                                      15
+#define   O_INTMASK__C0EarlyFull                                     14
+#define   O_INTMASK__RxDataFull                                      13
+#define   O_INTMASK__RxEarlyFull                                     12
+#define   O_INTMASK__RFreeEmpty                                      9
+#define   O_INTMASK__RFEarlyEmpty                                    8
+#define   O_INTMASK__P2PSpillEcc                                     7
+#define   O_INTMASK__FreeDescFull                                    5
+#define   O_INTMASK__FreeEarlyFull                                   4
+#define   O_INTMASK__TxFetchError                                    3
+#define   O_INTMASK__StatCarry                                       2
+#define   O_INTMASK__MDInt                                           1
+#define   O_INTMASK__TxIllegal                                       0
+#define R_INTREG                                                    0x0A6
+#define   O_INTREG__Spi4TxError                                     28
+#define   O_INTREG__Spi4RxError                                     27
+#define   O_INTREG__RGMIIHalfDupCollision                           27
+#define   O_INTREG__Abort                                           26
+#define   O_INTREG__Underrun                                        25
+#define   O_INTREG__DiscardPacket                                   24
+#define   O_INTREG__AsyncFifoFull                                   23
+#define   O_INTREG__TagFull                                         22
+#define   O_INTREG__Class3Full                                      21
+#define   O_INTREG__C3EarlyFull                                     20
+#define   O_INTREG__Class2Full                                      19
+#define   O_INTREG__C2EarlyFull                                     18
+#define   O_INTREG__Class1Full                                      17
+#define   O_INTREG__C1EarlyFull                                     16
+#define   O_INTREG__Class0Full                                      15
+#define   O_INTREG__C0EarlyFull                                     14
+#define   O_INTREG__RxDataFull                                      13
+#define   O_INTREG__RxEarlyFull                                     12
+#define   O_INTREG__RFreeEmpty                                      9
+#define   O_INTREG__RFEarlyEmpty                                    8
+#define   O_INTREG__P2PSpillEcc                                     7
+#define   O_INTREG__FreeDescFull                                    5
+#define   O_INTREG__FreeEarlyFull                                   4
+#define   O_INTREG__TxFetchError                                    3
+#define   O_INTREG__StatCarry                                       2
+#define   O_INTREG__MDInt                                           1
+#define   O_INTREG__TxIllegal                                       0
+#define R_TXRETRY                                                   0x0A7
+#define   O_TXRETRY__CollisionRetry                                 6
+#define   O_TXRETRY__BusErrorRetry                                  5
+#define   O_TXRETRY__UnderRunRetry                                  4
+#define   O_TXRETRY__Retries                                        0
+#define   W_TXRETRY__Retries                                        4
+#define R_CORECONTROL                                               0x0A8
+#define   O_CORECONTROL__ErrorThread                                4
+#define   W_CORECONTROL__ErrorThread                                7
+#define   O_CORECONTROL__Shutdown                                   2
+#define   O_CORECONTROL__Speed                                      0
+#define   W_CORECONTROL__Speed                                      2
+#define R_BYTEOFFSET0                                               0x0A9
+#define R_BYTEOFFSET1                                               0x0AA
+#define R_L2TYPE_0                                                  0x0F0
+#define   O_L2TYPE__ExtraHdrProtoSize                               26
+#define   W_L2TYPE__ExtraHdrProtoSize                               5
+#define   O_L2TYPE__ExtraHdrProtoOffset                             20
+#define   W_L2TYPE__ExtraHdrProtoOffset                             6
+#define   O_L2TYPE__ExtraHeaderSize                                 14
+#define   W_L2TYPE__ExtraHeaderSize                                 6
+#define   O_L2TYPE__ProtoOffset                                     8
+#define   W_L2TYPE__ProtoOffset                                     6
+#define   O_L2TYPE__L2HdrOffset                                     2
+#define   W_L2TYPE__L2HdrOffset                                     6
+#define   O_L2TYPE__L2Proto                                         0
+#define   W_L2TYPE__L2Proto                                         2
+#define R_L2TYPE_1                                                  0xF0
+#define R_L2TYPE_2                                                  0xF0
+#define R_L2TYPE_3                                                  0xF0
+#define R_PARSERCONFIGREG                                           0x100
+#define   O_PARSERCONFIGREG__CRCHashPoly                            8
+#define   W_PARSERCONFIGREG__CRCHashPoly                            7
+#define   O_PARSERCONFIGREG__PrePadOffset                           4
+#define   W_PARSERCONFIGREG__PrePadOffset                           4
+#define   O_PARSERCONFIGREG__UseCAM                                 2
+#define   O_PARSERCONFIGREG__UseHASH                                1
+#define   O_PARSERCONFIGREG__UseProto                               0
+#define R_L3CTABLE                                                  0x140
+#define   O_L3CTABLE__Offset0                                       25
+#define   W_L3CTABLE__Offset0                                       7
+#define   O_L3CTABLE__Len0                                          21
+#define   W_L3CTABLE__Len0                                          4
+#define   O_L3CTABLE__Offset1                                       14
+#define   W_L3CTABLE__Offset1                                       7
+#define   O_L3CTABLE__Len1                                          10
+#define   W_L3CTABLE__Len1                                          4
+#define   O_L3CTABLE__Offset2                                       4
+#define   W_L3CTABLE__Offset2                                       6
+#define   O_L3CTABLE__Len2                                          0
+#define   W_L3CTABLE__Len2                                          4
+#define   O_L3CTABLE__L3HdrOffset                                   26
+#define   W_L3CTABLE__L3HdrOffset                                   6
+#define   O_L3CTABLE__L4ProtoOffset                                 20
+#define   W_L3CTABLE__L4ProtoOffset                                 6
+#define   O_L3CTABLE__IPChksumCompute                               19
+#define   O_L3CTABLE__L4Classify                                    18
+#define   O_L3CTABLE__L2Proto                                       16
+#define   W_L3CTABLE__L2Proto                                       2
+#define   O_L3CTABLE__L3ProtoKey                                    0
+#define   W_L3CTABLE__L3ProtoKey                                    16
+#define R_L4CTABLE                                                  0x160
+#define   O_L4CTABLE__Offset0                                       21
+#define   W_L4CTABLE__Offset0                                       6
+#define   O_L4CTABLE__Len0                                          17
+#define   W_L4CTABLE__Len0                                          4
+#define   O_L4CTABLE__Offset1                                       11
+#define   W_L4CTABLE__Offset1                                       6
+#define   O_L4CTABLE__Len1                                          7
+#define   W_L4CTABLE__Len1                                          4
+#define   O_L4CTABLE__TCPChksumEnable                               0
+#define R_CAM4X128TABLE                                             0x172
+#define   O_CAM4X128TABLE__ClassId                                  7
+#define   W_CAM4X128TABLE__ClassId                                  2
+#define   O_CAM4X128TABLE__BucketId                                 1
+#define   W_CAM4X128TABLE__BucketId                                 6
+#define   O_CAM4X128TABLE__UseBucket                                0
+#define R_CAM4X128KEY                                               0x180
+#define R_TRANSLATETABLE                                            0x1A0
+#define R_DMACR0                                                    0x200
+#define   O_DMACR0__Data0WrMaxCr                                    27
+#define   W_DMACR0__Data0WrMaxCr                                    3
+#define   O_DMACR0__Data0RdMaxCr                                    24
+#define   W_DMACR0__Data0RdMaxCr                                    3
+#define   O_DMACR0__Data1WrMaxCr                                    21
+#define   W_DMACR0__Data1WrMaxCr                                    3
+#define   O_DMACR0__Data1RdMaxCr                                    18
+#define   W_DMACR0__Data1RdMaxCr                                    3
+#define   O_DMACR0__Data2WrMaxCr                                    15
+#define   W_DMACR0__Data2WrMaxCr                                    3
+#define   O_DMACR0__Data2RdMaxCr                                    12
+#define   W_DMACR0__Data2RdMaxCr                                    3
+#define   O_DMACR0__Data3WrMaxCr                                    9
+#define   W_DMACR0__Data3WrMaxCr                                    3
+#define   O_DMACR0__Data3RdMaxCr                                    6
+#define   W_DMACR0__Data3RdMaxCr                                    3
+#define   O_DMACR0__Data4WrMaxCr                                    3
+#define   W_DMACR0__Data4WrMaxCr                                    3
+#define   O_DMACR0__Data4RdMaxCr                                    0
+#define   W_DMACR0__Data4RdMaxCr                                    3
+#define R_DMACR1                                                    0x201
+#define   O_DMACR1__Data5WrMaxCr                                    27
+#define   W_DMACR1__Data5WrMaxCr                                    3
+#define   O_DMACR1__Data5RdMaxCr                                    24
+#define   W_DMACR1__Data5RdMaxCr                                    3
+#define   O_DMACR1__Data6WrMaxCr                                    21
+#define   W_DMACR1__Data6WrMaxCr                                    3
+#define   O_DMACR1__Data6RdMaxCr                                    18
+#define   W_DMACR1__Data6RdMaxCr                                    3
+#define   O_DMACR1__Data7WrMaxCr                                    15
+#define   W_DMACR1__Data7WrMaxCr                                    3
+#define   O_DMACR1__Data7RdMaxCr                                    12
+#define   W_DMACR1__Data7RdMaxCr                                    3
+#define   O_DMACR1__Data8WrMaxCr                                    9
+#define   W_DMACR1__Data8WrMaxCr                                    3
+#define   O_DMACR1__Data8RdMaxCr                                    6
+#define   W_DMACR1__Data8RdMaxCr                                    3
+#define   O_DMACR1__Data9WrMaxCr                                    3
+#define   W_DMACR1__Data9WrMaxCr                                    3
+#define   O_DMACR1__Data9RdMaxCr                                    0
+#define   W_DMACR1__Data9RdMaxCr                                    3
+#define R_DMACR2                                                    0x202
+#define   O_DMACR2__Data10WrMaxCr                                   27
+#define   W_DMACR2__Data10WrMaxCr                                   3
+#define   O_DMACR2__Data10RdMaxCr                                   24
+#define   W_DMACR2__Data10RdMaxCr                                   3
+#define   O_DMACR2__Data11WrMaxCr                                   21
+#define   W_DMACR2__Data11WrMaxCr                                   3
+#define   O_DMACR2__Data11RdMaxCr                                   18
+#define   W_DMACR2__Data11RdMaxCr                                   3
+#define   O_DMACR2__Data12WrMaxCr                                   15
+#define   W_DMACR2__Data12WrMaxCr                                   3
+#define   O_DMACR2__Data12RdMaxCr                                   12
+#define   W_DMACR2__Data12RdMaxCr                                   3
+#define   O_DMACR2__Data13WrMaxCr                                   9
+#define   W_DMACR2__Data13WrMaxCr                                   3
+#define   O_DMACR2__Data13RdMaxCr                                   6
+#define   W_DMACR2__Data13RdMaxCr                                   3
+#define   O_DMACR2__Data14WrMaxCr                                   3
+#define   W_DMACR2__Data14WrMaxCr                                   3
+#define   O_DMACR2__Data14RdMaxCr                                   0
+#define   W_DMACR2__Data14RdMaxCr                                   3
+#define R_DMACR3                                                    0x203
+#define   O_DMACR3__Data15WrMaxCr                                   27
+#define   W_DMACR3__Data15WrMaxCr                                   3
+#define   O_DMACR3__Data15RdMaxCr                                   24
+#define   W_DMACR3__Data15RdMaxCr                                   3
+#define   O_DMACR3__SpClassWrMaxCr                                  21
+#define   W_DMACR3__SpClassWrMaxCr                                  3
+#define   O_DMACR3__SpClassRdMaxCr                                  18
+#define   W_DMACR3__SpClassRdMaxCr                                  3
+#define   O_DMACR3__JumFrInWrMaxCr                                  15
+#define   W_DMACR3__JumFrInWrMaxCr                                  3
+#define   O_DMACR3__JumFrInRdMaxCr                                  12
+#define   W_DMACR3__JumFrInRdMaxCr                                  3
+#define   O_DMACR3__RegFrInWrMaxCr                                  9
+#define   W_DMACR3__RegFrInWrMaxCr                                  3
+#define   O_DMACR3__RegFrInRdMaxCr                                  6
+#define   W_DMACR3__RegFrInRdMaxCr                                  3
+#define   O_DMACR3__FrOutWrMaxCr                                    3
+#define   W_DMACR3__FrOutWrMaxCr                                    3
+#define   O_DMACR3__FrOutRdMaxCr                                    0
+#define   W_DMACR3__FrOutRdMaxCr                                    3
+#define R_REG_FRIN_SPILL_MEM_START_0                                0x204
+#define   O_REG_FRIN_SPILL_MEM_START_0__RegFrInSpillMemStart0        0
+#define   W_REG_FRIN_SPILL_MEM_START_0__RegFrInSpillMemStart0       32
+#define R_REG_FRIN_SPILL_MEM_START_1                                0x205
+#define   O_REG_FRIN_SPILL_MEM_START_1__RegFrInSpillMemStart1        0
+#define   W_REG_FRIN_SPILL_MEM_START_1__RegFrInSpillMemStart1        3
+#define R_REG_FRIN_SPILL_MEM_SIZE                                   0x206
+#define   O_REG_FRIN_SPILL_MEM_SIZE__RegFrInSpillMemSize             0
+#define   W_REG_FRIN_SPILL_MEM_SIZE__RegFrInSpillMemSize            32
+#define R_FROUT_SPILL_MEM_START_0                                   0x207
+#define   O_FROUT_SPILL_MEM_START_0__FrOutSpillMemStart0             0
+#define   W_FROUT_SPILL_MEM_START_0__FrOutSpillMemStart0            32
+#define R_FROUT_SPILL_MEM_START_1                                   0x208
+#define   O_FROUT_SPILL_MEM_START_1__FrOutSpillMemStart1             0
+#define   W_FROUT_SPILL_MEM_START_1__FrOutSpillMemStart1             3
+#define R_FROUT_SPILL_MEM_SIZE                                      0x209
+#define   O_FROUT_SPILL_MEM_SIZE__FrOutSpillMemSize                  0
+#define   W_FROUT_SPILL_MEM_SIZE__FrOutSpillMemSize                 32
+#define R_CLASS0_SPILL_MEM_START_0                                  0x20A
+#define   O_CLASS0_SPILL_MEM_START_0__Class0SpillMemStart0           0
+#define   W_CLASS0_SPILL_MEM_START_0__Class0SpillMemStart0          32
+#define R_CLASS0_SPILL_MEM_START_1                                  0x20B
+#define   O_CLASS0_SPILL_MEM_START_1__Class0SpillMemStart1           0
+#define   W_CLASS0_SPILL_MEM_START_1__Class0SpillMemStart1           3
+#define R_CLASS0_SPILL_MEM_SIZE                                     0x20C
+#define   O_CLASS0_SPILL_MEM_SIZE__Class0SpillMemSize                0
+#define   W_CLASS0_SPILL_MEM_SIZE__Class0SpillMemSize               32
+#define R_JUMFRIN_SPILL_MEM_START_0                                 0x20D
+#define   O_JUMFRIN_SPILL_MEM_START_0__JumFrInSpillMemStar0          0
+#define   W_JUMFRIN_SPILL_MEM_START_0__JumFrInSpillMemStar0         32
+#define R_JUMFRIN_SPILL_MEM_START_1                                 0x20E
+#define   O_JUMFRIN_SPILL_MEM_START_1__JumFrInSpillMemStart1         0
+#define   W_JUMFRIN_SPILL_MEM_START_1__JumFrInSpillMemStart1         3
+#define R_JUMFRIN_SPILL_MEM_SIZE                                    0x20F
+#define   O_JUMFRIN_SPILL_MEM_SIZE__JumFrInSpillMemSize              0
+#define   W_JUMFRIN_SPILL_MEM_SIZE__JumFrInSpillMemSize             32
+#define R_CLASS1_SPILL_MEM_START_0                                  0x210
+#define   O_CLASS1_SPILL_MEM_START_0__Class1SpillMemStart0           0
+#define   W_CLASS1_SPILL_MEM_START_0__Class1SpillMemStart0          32
+#define R_CLASS1_SPILL_MEM_START_1                                  0x211
+#define   O_CLASS1_SPILL_MEM_START_1__Class1SpillMemStart1           0
+#define   W_CLASS1_SPILL_MEM_START_1__Class1SpillMemStart1           3
+#define R_CLASS1_SPILL_MEM_SIZE                                     0x212
+#define   O_CLASS1_SPILL_MEM_SIZE__Class1SpillMemSize                0
+#define   W_CLASS1_SPILL_MEM_SIZE__Class1SpillMemSize               32
+#define R_CLASS2_SPILL_MEM_START_0                                  0x213
+#define   O_CLASS2_SPILL_MEM_START_0__Class2SpillMemStart0           0
+#define   W_CLASS2_SPILL_MEM_START_0__Class2SpillMemStart0          32
+#define R_CLASS2_SPILL_MEM_START_1                                  0x214
+#define   O_CLASS2_SPILL_MEM_START_1__Class2SpillMemStart1           0
+#define   W_CLASS2_SPILL_MEM_START_1__Class2SpillMemStart1           3
+#define R_CLASS2_SPILL_MEM_SIZE                                     0x215
+#define   O_CLASS2_SPILL_MEM_SIZE__Class2SpillMemSize                0
+#define   W_CLASS2_SPILL_MEM_SIZE__Class2SpillMemSize               32
+#define R_CLASS3_SPILL_MEM_START_0                                  0x216
+#define   O_CLASS3_SPILL_MEM_START_0__Class3SpillMemStart0           0
+#define   W_CLASS3_SPILL_MEM_START_0__Class3SpillMemStart0          32
+#define R_CLASS3_SPILL_MEM_START_1                                  0x217
+#define   O_CLASS3_SPILL_MEM_START_1__Class3SpillMemStart1           0
+#define   W_CLASS3_SPILL_MEM_START_1__Class3SpillMemStart1           3
+#define R_CLASS3_SPILL_MEM_SIZE                                     0x218
+#define   O_CLASS3_SPILL_MEM_SIZE__Class3SpillMemSize                0
+#define   W_CLASS3_SPILL_MEM_SIZE__Class3SpillMemSize               32
+#define R_REG_FRIN1_SPILL_MEM_START_0                               0x219
+#define R_REG_FRIN1_SPILL_MEM_START_1                               0x21a
+#define R_REG_FRIN1_SPILL_MEM_SIZE                                  0x21b
+#define R_SPIHNGY0                                                  0x219
+#define   O_SPIHNGY0__EG_HNGY_THRESH_0                              24
+#define   W_SPIHNGY0__EG_HNGY_THRESH_0                              7
+#define   O_SPIHNGY0__EG_HNGY_THRESH_1                              16
+#define   W_SPIHNGY0__EG_HNGY_THRESH_1                              7
+#define   O_SPIHNGY0__EG_HNGY_THRESH_2                              8
+#define   W_SPIHNGY0__EG_HNGY_THRESH_2                              7
+#define   O_SPIHNGY0__EG_HNGY_THRESH_3                              0
+#define   W_SPIHNGY0__EG_HNGY_THRESH_3                              7
+#define R_SPIHNGY1                                                  0x21A
+#define   O_SPIHNGY1__EG_HNGY_THRESH_4                              24
+#define   W_SPIHNGY1__EG_HNGY_THRESH_4                              7
+#define   O_SPIHNGY1__EG_HNGY_THRESH_5                              16
+#define   W_SPIHNGY1__EG_HNGY_THRESH_5                              7
+#define   O_SPIHNGY1__EG_HNGY_THRESH_6                              8
+#define   W_SPIHNGY1__EG_HNGY_THRESH_6                              7
+#define   O_SPIHNGY1__EG_HNGY_THRESH_7                              0
+#define   W_SPIHNGY1__EG_HNGY_THRESH_7                              7
+#define R_SPIHNGY2                                                  0x21B
+#define   O_SPIHNGY2__EG_HNGY_THRESH_8                              24
+#define   W_SPIHNGY2__EG_HNGY_THRESH_8                              7
+#define   O_SPIHNGY2__EG_HNGY_THRESH_9                              16
+#define   W_SPIHNGY2__EG_HNGY_THRESH_9                              7
+#define   O_SPIHNGY2__EG_HNGY_THRESH_10                             8
+#define   W_SPIHNGY2__EG_HNGY_THRESH_10                             7
+#define   O_SPIHNGY2__EG_HNGY_THRESH_11                             0
+#define   W_SPIHNGY2__EG_HNGY_THRESH_11                             7
+#define R_SPIHNGY3                                                  0x21C
+#define   O_SPIHNGY3__EG_HNGY_THRESH_12                             24
+#define   W_SPIHNGY3__EG_HNGY_THRESH_12                             7
+#define   O_SPIHNGY3__EG_HNGY_THRESH_13                             16
+#define   W_SPIHNGY3__EG_HNGY_THRESH_13                             7
+#define   O_SPIHNGY3__EG_HNGY_THRESH_14                             8
+#define   W_SPIHNGY3__EG_HNGY_THRESH_14                             7
+#define   O_SPIHNGY3__EG_HNGY_THRESH_15                             0
+#define   W_SPIHNGY3__EG_HNGY_THRESH_15                             7
+#define R_SPISTRV0                                                  0x21D
+#define   O_SPISTRV0__EG_STRV_THRESH_0                              24
+#define   W_SPISTRV0__EG_STRV_THRESH_0                              7
+#define   O_SPISTRV0__EG_STRV_THRESH_1                              16
+#define   W_SPISTRV0__EG_STRV_THRESH_1                              7
+#define   O_SPISTRV0__EG_STRV_THRESH_2                              8
+#define   W_SPISTRV0__EG_STRV_THRESH_2                              7
+#define   O_SPISTRV0__EG_STRV_THRESH_3                              0
+#define   W_SPISTRV0__EG_STRV_THRESH_3                              7
+#define R_SPISTRV1                                                  0x21E
+#define   O_SPISTRV1__EG_STRV_THRESH_4                              24
+#define   W_SPISTRV1__EG_STRV_THRESH_4                              7
+#define   O_SPISTRV1__EG_STRV_THRESH_5                              16
+#define   W_SPISTRV1__EG_STRV_THRESH_5                              7
+#define   O_SPISTRV1__EG_STRV_THRESH_6                              8
+#define   W_SPISTRV1__EG_STRV_THRESH_6                              7
+#define   O_SPISTRV1__EG_STRV_THRESH_7                              0
+#define   W_SPISTRV1__EG_STRV_THRESH_7                              7
+#define R_SPISTRV2                                                  0x21F
+#define   O_SPISTRV2__EG_STRV_THRESH_8                              24
+#define   W_SPISTRV2__EG_STRV_THRESH_8                              7
+#define   O_SPISTRV2__EG_STRV_THRESH_9                              16
+#define   W_SPISTRV2__EG_STRV_THRESH_9                              7
+#define   O_SPISTRV2__EG_STRV_THRESH_10                             8
+#define   W_SPISTRV2__EG_STRV_THRESH_10                             7
+#define   O_SPISTRV2__EG_STRV_THRESH_11                             0
+#define   W_SPISTRV2__EG_STRV_THRESH_11                             7
+#define R_SPISTRV3                                                  0x220
+#define   O_SPISTRV3__EG_STRV_THRESH_12                             24
+#define   W_SPISTRV3__EG_STRV_THRESH_12                             7
+#define   O_SPISTRV3__EG_STRV_THRESH_13                             16
+#define   W_SPISTRV3__EG_STRV_THRESH_13                             7
+#define   O_SPISTRV3__EG_STRV_THRESH_14                             8
+#define   W_SPISTRV3__EG_STRV_THRESH_14                             7
+#define   O_SPISTRV3__EG_STRV_THRESH_15                             0
+#define   W_SPISTRV3__EG_STRV_THRESH_15                             7
+#define R_TXDATAFIFO0                                               0x221
+#define   O_TXDATAFIFO0__Tx0DataFifoStart                           24
+#define   W_TXDATAFIFO0__Tx0DataFifoStart                           7
+#define   O_TXDATAFIFO0__Tx0DataFifoSize                            16
+#define   W_TXDATAFIFO0__Tx0DataFifoSize                            7
+#define   O_TXDATAFIFO0__Tx1DataFifoStart                           8
+#define   W_TXDATAFIFO0__Tx1DataFifoStart                           7
+#define   O_TXDATAFIFO0__Tx1DataFifoSize                            0
+#define   W_TXDATAFIFO0__Tx1DataFifoSize                            7
+#define R_TXDATAFIFO1                                               0x222
+#define   O_TXDATAFIFO1__Tx2DataFifoStart                           24
+#define   W_TXDATAFIFO1__Tx2DataFifoStart                           7
+#define   O_TXDATAFIFO1__Tx2DataFifoSize                            16
+#define   W_TXDATAFIFO1__Tx2DataFifoSize                            7
+#define   O_TXDATAFIFO1__Tx3DataFifoStart                           8
+#define   W_TXDATAFIFO1__Tx3DataFifoStart                           7
+#define   O_TXDATAFIFO1__Tx3DataFifoSize                            0
+#define   W_TXDATAFIFO1__Tx3DataFifoSize                            7
+#define R_TXDATAFIFO2                                               0x223
+#define   O_TXDATAFIFO2__Tx4DataFifoStart                           24
+#define   W_TXDATAFIFO2__Tx4DataFifoStart                           7
+#define   O_TXDATAFIFO2__Tx4DataFifoSize                            16
+#define   W_TXDATAFIFO2__Tx4DataFifoSize                            7
+#define   O_TXDATAFIFO2__Tx5DataFifoStart                           8
+#define   W_TXDATAFIFO2__Tx5DataFifoStart                           7
+#define   O_TXDATAFIFO2__Tx5DataFifoSize                            0
+#define   W_TXDATAFIFO2__Tx5DataFifoSize                            7
+#define R_TXDATAFIFO3                                               0x224
+#define   O_TXDATAFIFO3__Tx6DataFifoStart                           24
+#define   W_TXDATAFIFO3__Tx6DataFifoStart                           7
+#define   O_TXDATAFIFO3__Tx6DataFifoSize                            16
+#define   W_TXDATAFIFO3__Tx6DataFifoSize                            7
+#define   O_TXDATAFIFO3__Tx7DataFifoStart                           8
+#define   W_TXDATAFIFO3__Tx7DataFifoStart                           7
+#define   O_TXDATAFIFO3__Tx7DataFifoSize                            0
+#define   W_TXDATAFIFO3__Tx7DataFifoSize                            7
+#define R_TXDATAFIFO4                                               0x225
+#define   O_TXDATAFIFO4__Tx8DataFifoStart                           24
+#define   W_TXDATAFIFO4__Tx8DataFifoStart                           7
+#define   O_TXDATAFIFO4__Tx8DataFifoSize                            16
+#define   W_TXDATAFIFO4__Tx8DataFifoSize                            7
+#define   O_TXDATAFIFO4__Tx9DataFifoStart                           8
+#define   W_TXDATAFIFO4__Tx9DataFifoStart                           7
+#define   O_TXDATAFIFO4__Tx9DataFifoSize                            0
+#define   W_TXDATAFIFO4__Tx9DataFifoSize                            7
+#define R_TXDATAFIFO5                                               0x226
+#define   O_TXDATAFIFO5__Tx10DataFifoStart                          24
+#define   W_TXDATAFIFO5__Tx10DataFifoStart                          7
+#define   O_TXDATAFIFO5__Tx10DataFifoSize                           16
+#define   W_TXDATAFIFO5__Tx10DataFifoSize                           7
+#define   O_TXDATAFIFO5__Tx11DataFifoStart                          8
+#define   W_TXDATAFIFO5__Tx11DataFifoStart                          7
+#define   O_TXDATAFIFO5__Tx11DataFifoSize                           0
+#define   W_TXDATAFIFO5__Tx11DataFifoSize                           7
+#define R_TXDATAFIFO6                                               0x227
+#define   O_TXDATAFIFO6__Tx12DataFifoStart                          24
+#define   W_TXDATAFIFO6__Tx12DataFifoStart                          7
+#define   O_TXDATAFIFO6__Tx12DataFifoSize                           16
+#define   W_TXDATAFIFO6__Tx12DataFifoSize                           7
+#define   O_TXDATAFIFO6__Tx13DataFifoStart                          8
+#define   W_TXDATAFIFO6__Tx13DataFifoStart                          7
+#define   O_TXDATAFIFO6__Tx13DataFifoSize                           0
+#define   W_TXDATAFIFO6__Tx13DataFifoSize                           7
+#define R_TXDATAFIFO7                                               0x228
+#define   O_TXDATAFIFO7__Tx14DataFifoStart                          24
+#define   W_TXDATAFIFO7__Tx14DataFifoStart                          7
+#define   O_TXDATAFIFO7__Tx14DataFifoSize                           16
+#define   W_TXDATAFIFO7__Tx14DataFifoSize                           7
+#define   O_TXDATAFIFO7__Tx15DataFifoStart                          8
+#define   W_TXDATAFIFO7__Tx15DataFifoStart                          7
+#define   O_TXDATAFIFO7__Tx15DataFifoSize                           0
+#define   W_TXDATAFIFO7__Tx15DataFifoSize                           7
+#define R_RXDATAFIFO0                                               0x229
+#define   O_RXDATAFIFO0__Rx0DataFifoStart                           24
+#define   W_RXDATAFIFO0__Rx0DataFifoStart                           7
+#define   O_RXDATAFIFO0__Rx0DataFifoSize                            16
+#define   W_RXDATAFIFO0__Rx0DataFifoSize                            7
+#define   O_RXDATAFIFO0__Rx1DataFifoStart                           8
+#define   W_RXDATAFIFO0__Rx1DataFifoStart                           7
+#define   O_RXDATAFIFO0__Rx1DataFifoSize                            0
+#define   W_RXDATAFIFO0__Rx1DataFifoSize                            7
+#define R_RXDATAFIFO1                                               0x22A
+#define   O_RXDATAFIFO1__Rx2DataFifoStart                           24
+#define   W_RXDATAFIFO1__Rx2DataFifoStart                           7
+#define   O_RXDATAFIFO1__Rx2DataFifoSize                            16
+#define   W_RXDATAFIFO1__Rx2DataFifoSize                            7
+#define   O_RXDATAFIFO1__Rx3DataFifoStart                           8
+#define   W_RXDATAFIFO1__Rx3DataFifoStart                           7
+#define   O_RXDATAFIFO1__Rx3DataFifoSize                            0
+#define   W_RXDATAFIFO1__Rx3DataFifoSize                            7
+#define R_RXDATAFIFO2                                               0x22B
+#define   O_RXDATAFIFO2__Rx4DataFifoStart                           24
+#define   W_RXDATAFIFO2__Rx4DataFifoStart                           7
+#define   O_RXDATAFIFO2__Rx4DataFifoSize                            16
+#define   W_RXDATAFIFO2__Rx4DataFifoSize                            7
+#define   O_RXDATAFIFO2__Rx5DataFifoStart                           8
+#define   W_RXDATAFIFO2__Rx5DataFifoStart                           7
+#define   O_RXDATAFIFO2__Rx5DataFifoSize                            0
+#define   W_RXDATAFIFO2__Rx5DataFifoSize                            7
+#define R_RXDATAFIFO3                                               0x22C
+#define   O_RXDATAFIFO3__Rx6DataFifoStart                           24
+#define   W_RXDATAFIFO3__Rx6DataFifoStart                           7
+#define   O_RXDATAFIFO3__Rx6DataFifoSize                            16
+#define   W_RXDATAFIFO3__Rx6DataFifoSize                            7
+#define   O_RXDATAFIFO3__Rx7DataFifoStart                           8
+#define   W_RXDATAFIFO3__Rx7DataFifoStart                           7
+#define   O_RXDATAFIFO3__Rx7DataFifoSize                            0
+#define   W_RXDATAFIFO3__Rx7DataFifoSize                            7
+#define R_RXDATAFIFO4                                               0x22D
+#define   O_RXDATAFIFO4__Rx8DataFifoStart                           24
+#define   W_RXDATAFIFO4__Rx8DataFifoStart                           7
+#define   O_RXDATAFIFO4__Rx8DataFifoSize                            16
+#define   W_RXDATAFIFO4__Rx8DataFifoSize                            7
+#define   O_RXDATAFIFO4__Rx9DataFifoStart                           8
+#define   W_RXDATAFIFO4__Rx9DataFifoStart                           7
+#define   O_RXDATAFIFO4__Rx9DataFifoSize                            0
+#define   W_RXDATAFIFO4__Rx9DataFifoSize                            7
+#define R_RXDATAFIFO5                                               0x22E
+#define   O_RXDATAFIFO5__Rx10DataFifoStart                          24
+#define   W_RXDATAFIFO5__Rx10DataFifoStart                          7
+#define   O_RXDATAFIFO5__Rx10DataFifoSize                           16
+#define   W_RXDATAFIFO5__Rx10DataFifoSize                           7
+#define   O_RXDATAFIFO5__Rx11DataFifoStart                          8
+#define   W_RXDATAFIFO5__Rx11DataFifoStart                          7
+#define   O_RXDATAFIFO5__Rx11DataFifoSize                           0
+#define   W_RXDATAFIFO5__Rx11DataFifoSize                           7
+#define R_RXDATAFIFO6                                               0x22F
+#define   O_RXDATAFIFO6__Rx12DataFifoStart                          24
+#define   W_RXDATAFIFO6__Rx12DataFifoStart                          7
+#define   O_RXDATAFIFO6__Rx12DataFifoSize                           16
+#define   W_RXDATAFIFO6__Rx12DataFifoSize                           7
+#define   O_RXDATAFIFO6__Rx13DataFifoStart                          8
+#define   W_RXDATAFIFO6__Rx13DataFifoStart                          7
+#define   O_RXDATAFIFO6__Rx13DataFifoSize                           0
+#define   W_RXDATAFIFO6__Rx13DataFifoSize                           7
+#define R_RXDATAFIFO7                                               0x230
+#define   O_RXDATAFIFO7__Rx14DataFifoStart                          24
+#define   W_RXDATAFIFO7__Rx14DataFifoStart                          7
+#define   O_RXDATAFIFO7__Rx14DataFifoSize                           16
+#define   W_RXDATAFIFO7__Rx14DataFifoSize                           7
+#define   O_RXDATAFIFO7__Rx15DataFifoStart                          8
+#define   W_RXDATAFIFO7__Rx15DataFifoStart                          7
+#define   O_RXDATAFIFO7__Rx15DataFifoSize                           0
+#define   W_RXDATAFIFO7__Rx15DataFifoSize                           7
+#define R_XGMACPADCALIBRATION                                       0x231
+#define R_FREEQCARVE                                                0x233
+#define R_SPI4STATICDELAY0                                          0x240
+#define   O_SPI4STATICDELAY0__DataLine7                             28
+#define   W_SPI4STATICDELAY0__DataLine7                             4
+#define   O_SPI4STATICDELAY0__DataLine6                             24
+#define   W_SPI4STATICDELAY0__DataLine6                             4
+#define   O_SPI4STATICDELAY0__DataLine5                             20
+#define   W_SPI4STATICDELAY0__DataLine5                             4
+#define   O_SPI4STATICDELAY0__DataLine4                             16
+#define   W_SPI4STATICDELAY0__DataLine4                             4
+#define   O_SPI4STATICDELAY0__DataLine3                             12
+#define   W_SPI4STATICDELAY0__DataLine3                             4
+#define   O_SPI4STATICDELAY0__DataLine2                             8
+#define   W_SPI4STATICDELAY0__DataLine2                             4
+#define   O_SPI4STATICDELAY0__DataLine1                             4
+#define   W_SPI4STATICDELAY0__DataLine1                             4
+#define   O_SPI4STATICDELAY0__DataLine0                             0
+#define   W_SPI4STATICDELAY0__DataLine0                             4
+#define R_SPI4STATICDELAY1                                          0x241
+#define   O_SPI4STATICDELAY1__DataLine15                            28
+#define   W_SPI4STATICDELAY1__DataLine15                            4
+#define   O_SPI4STATICDELAY1__DataLine14                            24
+#define   W_SPI4STATICDELAY1__DataLine14                            4
+#define   O_SPI4STATICDELAY1__DataLine13                            20
+#define   W_SPI4STATICDELAY1__DataLine13                            4
+#define   O_SPI4STATICDELAY1__DataLine12                            16
+#define   W_SPI4STATICDELAY1__DataLine12                            4
+#define   O_SPI4STATICDELAY1__DataLine11                            12
+#define   W_SPI4STATICDELAY1__DataLine11                            4
+#define   O_SPI4STATICDELAY1__DataLine10                            8
+#define   W_SPI4STATICDELAY1__DataLine10                            4
+#define   O_SPI4STATICDELAY1__DataLine9                             4
+#define   W_SPI4STATICDELAY1__DataLine9                             4
+#define   O_SPI4STATICDELAY1__DataLine8                             0
+#define   W_SPI4STATICDELAY1__DataLine8                             4
+#define R_SPI4STATICDELAY2                                          0x242
+#define   O_SPI4STATICDELAY0__TxStat1                               8
+#define   W_SPI4STATICDELAY0__TxStat1                               4
+#define   O_SPI4STATICDELAY0__TxStat0                               4
+#define   W_SPI4STATICDELAY0__TxStat0                               4
+#define   O_SPI4STATICDELAY0__RxControl                             0
+#define   W_SPI4STATICDELAY0__RxControl                             4
+#define R_SPI4CONTROL                                               0x243
+#define   O_SPI4CONTROL__StaticDelay                                2
+#define   O_SPI4CONTROL__LVDS_LVTTL                                 1
+#define   O_SPI4CONTROL__SPI4Enable                                 0
+#define R_CLASSWATERMARKS                                           0x244
+#define   O_CLASSWATERMARKS__Class0Watermark                        24
+#define   W_CLASSWATERMARKS__Class0Watermark                        5
+#define   O_CLASSWATERMARKS__Class1Watermark                        16
+#define   W_CLASSWATERMARKS__Class1Watermark                        5
+#define   O_CLASSWATERMARKS__Class3Watermark                        0
+#define   W_CLASSWATERMARKS__Class3Watermark                        5
+#define R_RXWATERMARKS1                                              0x245
+#define   O_RXWATERMARKS__Rx0DataWatermark                          24
+#define   W_RXWATERMARKS__Rx0DataWatermark                          7
+#define   O_RXWATERMARKS__Rx1DataWatermark                          16
+#define   W_RXWATERMARKS__Rx1DataWatermark                          7
+#define   O_RXWATERMARKS__Rx3DataWatermark                          0
+#define   W_RXWATERMARKS__Rx3DataWatermark                          7
+#define R_RXWATERMARKS2                                              0x246
+#define   O_RXWATERMARKS__Rx4DataWatermark                          24
+#define   W_RXWATERMARKS__Rx4DataWatermark                          7
+#define   O_RXWATERMARKS__Rx5DataWatermark                          16
+#define   W_RXWATERMARKS__Rx5DataWatermark                          7
+#define   O_RXWATERMARKS__Rx6DataWatermark                          8
+#define   W_RXWATERMARKS__Rx6DataWatermark                          7
+#define   O_RXWATERMARKS__Rx7DataWatermark                          0
+#define   W_RXWATERMARKS__Rx7DataWatermark                          7
+#define R_RXWATERMARKS3                                              0x247
+#define   O_RXWATERMARKS__Rx8DataWatermark                          24
+#define   W_RXWATERMARKS__Rx8DataWatermark                          7
+#define   O_RXWATERMARKS__Rx9DataWatermark                          16
+#define   W_RXWATERMARKS__Rx9DataWatermark                          7
+#define   O_RXWATERMARKS__Rx10DataWatermark                         8
+#define   W_RXWATERMARKS__Rx10DataWatermark                         7
+#define   O_RXWATERMARKS__Rx11DataWatermark                         0
+#define   W_RXWATERMARKS__Rx11DataWatermark                         7
+#define R_RXWATERMARKS4                                              0x248
+#define   O_RXWATERMARKS__Rx12DataWatermark                         24
+#define   W_RXWATERMARKS__Rx12DataWatermark                         7
+#define   O_RXWATERMARKS__Rx13DataWatermark                         16
+#define   W_RXWATERMARKS__Rx13DataWatermark                         7
+#define   O_RXWATERMARKS__Rx14DataWatermark                         8
+#define   W_RXWATERMARKS__Rx14DataWatermark                         7
+#define   O_RXWATERMARKS__Rx15DataWatermark                         0
+#define   W_RXWATERMARKS__Rx15DataWatermark                         7
+#define R_FREEWATERMARKS                                            0x249
+#define   O_FREEWATERMARKS__FreeOutWatermark                        16
+#define   W_FREEWATERMARKS__FreeOutWatermark                        16
+#define   O_FREEWATERMARKS__JumFrWatermark                          8
+#define   W_FREEWATERMARKS__JumFrWatermark                          7
+#define   O_FREEWATERMARKS__RegFrWatermark                          0
+#define   W_FREEWATERMARKS__RegFrWatermark                          7
+#define R_EGRESSFIFOCARVINGSLOTS                                    0x24a
+
+#define CTRL_RES0           0
+#define CTRL_RES1           1
+#define CTRL_REG_FREE       2
+#define CTRL_JUMBO_FREE     3
+#define CTRL_CONT           4
+#define CTRL_EOP            5
+#define CTRL_START          6
+#define CTRL_SNGL           7
+
+#define CTRL_B0_NOT_EOP     0
+#define CTRL_B0_EOP         1
+
+#define R_ROUND_ROBIN_TABLE                 0
+#define R_PDE_CLASS_0                       0x300
+#define R_PDE_CLASS_1                       0x302
+#define R_PDE_CLASS_2                       0x304
+#define R_PDE_CLASS_3                       0x306
+
+#define R_MSG_TX_THRESHOLD                  0x308
+
+#define R_GMAC_JFR0_BUCKET_SIZE              0x320
+#define R_GMAC_RFR0_BUCKET_SIZE              0x321
+#define R_GMAC_TX0_BUCKET_SIZE              0x322
+#define R_GMAC_TX1_BUCKET_SIZE              0x323
+#define R_GMAC_TX2_BUCKET_SIZE              0x324
+#define R_GMAC_TX3_BUCKET_SIZE              0x325
+#define R_GMAC_JFR1_BUCKET_SIZE              0x326
+#define R_GMAC_RFR1_BUCKET_SIZE              0x327
+
+#define R_XGS_TX0_BUCKET_SIZE               0x320
+#define R_XGS_TX1_BUCKET_SIZE               0x321
+#define R_XGS_TX2_BUCKET_SIZE               0x322
+#define R_XGS_TX3_BUCKET_SIZE               0x323
+#define R_XGS_TX4_BUCKET_SIZE               0x324
+#define R_XGS_TX5_BUCKET_SIZE               0x325
+#define R_XGS_TX6_BUCKET_SIZE               0x326
+#define R_XGS_TX7_BUCKET_SIZE               0x327
+#define R_XGS_TX8_BUCKET_SIZE               0x328
+#define R_XGS_TX9_BUCKET_SIZE               0x329
+#define R_XGS_TX10_BUCKET_SIZE              0x32A
+#define R_XGS_TX11_BUCKET_SIZE              0x32B
+#define R_XGS_TX12_BUCKET_SIZE              0x32C
+#define R_XGS_TX13_BUCKET_SIZE              0x32D
+#define R_XGS_TX14_BUCKET_SIZE              0x32E
+#define R_XGS_TX15_BUCKET_SIZE              0x32F
+#define R_XGS_JFR_BUCKET_SIZE               0x330
+#define R_XGS_RFR_BUCKET_SIZE               0x331
+
+#define R_CC_CPU0_0                         0x380
+#define R_CC_CPU1_0                         0x388
+#define R_CC_CPU2_0                         0x390
+#define R_CC_CPU3_0                         0x398
+#define R_CC_CPU4_0                         0x3a0
+#define R_CC_CPU5_0                         0x3a8
+#define R_CC_CPU6_0                         0x3b0
+#define R_CC_CPU7_0                         0x3b8
+
+#define XLR_GMAC_BLK_SZ		            (XLR_IO_GMAC_1_OFFSET - \
+		XLR_IO_GMAC_0_OFFSET)
+
+/* Constants used for configuring the devices */
+
+#define XLR_FB_STN			6 /* Bucket used for Tx freeback */
+
+#define MAC_B2B_IPG                     88
+
+#define	XLR_NET_PREPAD_LEN		32
+
+/* frame sizes need to be cacheline aligned */
+#define MAX_FRAME_SIZE                  (1536 + XLR_NET_PREPAD_LEN)
+#define MAX_FRAME_SIZE_JUMBO            9216
+
+#define MAC_SKB_BACK_PTR_SIZE           SMP_CACHE_BYTES
+#define MAC_PREPAD                      0
+#define BYTE_OFFSET                     2
+#define XLR_RX_BUF_SIZE                 (MAX_FRAME_SIZE + BYTE_OFFSET + \
+		MAC_PREPAD + MAC_SKB_BACK_PTR_SIZE + SMP_CACHE_BYTES)
+#define MAC_CRC_LEN                     4
+#define MAX_NUM_MSGRNG_STN_CC           128
+#define MAX_MSG_SND_ATTEMPTS		100	/* 13 stns x 4 entry msg/stn +
+						   headroom */
+
+#define MAC_FRIN_TO_BE_SENT_THRESHOLD   16
+
+#define MAX_NUM_DESC_SPILL		1024
+#define MAX_FRIN_SPILL                  (MAX_NUM_DESC_SPILL << 2)
+#define MAX_FROUT_SPILL                 (MAX_NUM_DESC_SPILL << 2)
+#define MAX_CLASS_0_SPILL               (MAX_NUM_DESC_SPILL << 2)
+#define MAX_CLASS_1_SPILL               (MAX_NUM_DESC_SPILL << 2)
+#define MAX_CLASS_2_SPILL               (MAX_NUM_DESC_SPILL << 2)
+#define MAX_CLASS_3_SPILL               (MAX_NUM_DESC_SPILL << 2)
+
+enum {
+	SGMII_SPEED_10 = 0x00000000,
+	SGMII_SPEED_100 = 0x02000000,
+	SGMII_SPEED_1000 = 0x04000000,
+};
+
+enum tsv_rsv_reg {
+	TX_RX_64_BYTE_FRAME = 0x20,
+	TX_RX_64_127_BYTE_FRAME,
+	TX_RX_128_255_BYTE_FRAME,
+	TX_RX_256_511_BYTE_FRAME,
+	TX_RX_512_1023_BYTE_FRAME,
+	TX_RX_1024_1518_BYTE_FRAME,
+	TX_RX_1519_1522_VLAN_BYTE_FRAME,
+
+	RX_BYTE_COUNTER = 0x27,
+	RX_PACKET_COUNTER,
+	RX_FCS_ERROR_COUNTER,
+	RX_MULTICAST_PACKET_COUNTER,
+	RX_BROADCAST_PACKET_COUNTER,
+	RX_CONTROL_FRAME_PACKET_COUNTER,
+	RX_PAUSE_FRAME_PACKET_COUNTER,
+	RX_UNKNOWN_OP_CODE_COUNTER,
+	RX_ALIGNMENT_ERROR_COUNTER,
+	RX_FRAME_LENGTH_ERROR_COUNTER,
+	RX_CODE_ERROR_COUNTER,
+	RX_CARRIER_SENSE_ERROR_COUNTER,
+	RX_UNDERSIZE_PACKET_COUNTER,
+	RX_OVERSIZE_PACKET_COUNTER,
+	RX_FRAGMENTS_COUNTER,
+	RX_JABBER_COUNTER,
+	RX_DROP_PACKET_COUNTER,
+
+	TX_BYTE_COUNTER   = 0x38,
+	TX_PACKET_COUNTER,
+	TX_MULTICAST_PACKET_COUNTER,
+	TX_BROADCAST_PACKET_COUNTER,
+	TX_PAUSE_CONTROL_FRAME_COUNTER,
+	TX_DEFERRAL_PACKET_COUNTER,
+	TX_EXCESSIVE_DEFERRAL_PACKET_COUNTER,
+	TX_SINGLE_COLLISION_PACKET_COUNTER,
+	TX_MULTI_COLLISION_PACKET_COUNTER,
+	TX_LATE_COLLISION_PACKET_COUNTER,
+	TX_EXCESSIVE_COLLISION_PACKET_COUNTER,
+	TX_TOTAL_COLLISION_COUNTER,
+	TX_PAUSE_FRAME_HONERED_COUNTER,
+	TX_DROP_FRAME_COUNTER,
+	TX_JABBER_FRAME_COUNTER,
+	TX_FCS_ERROR_COUNTER,
+	TX_CONTROL_FRAME_COUNTER,
+	TX_OVERSIZE_FRAME_COUNTER,
+	TX_UNDERSIZE_FRAME_COUNTER,
+	TX_FRAGMENT_FRAME_COUNTER,
+
+	CARRY_REG_1 = 0x4c,
+	CARRY_REG_2 = 0x4d,
+};
+
+struct xlr_net_priv {
+	unsigned long base_addr;
+	struct net_device *ndev;
+	struct mii_bus *mii_bus;
+	int num_rx_desc;
+	int phy_addr;	/* PHY addr on MDIO bus */
+	int pcs_id;	/* PCS id on MDIO bus */
+	int port_id;	/* Port(gmac/xgmac) number, i.e 0-7 */
+	u64 mii_addr;
+	u64 serdes_addr;
+	u64 pcs_addr;
+	int phy_speed;
+	int port_type;
+	struct timer_list queue_timer;
+	int wakeup_q;
+	struct platform_device *pdev;
+	struct xlr_net_data *nd;
+
+	u64 *frin_spill;
+	u64 *frout_spill;
+	u64 *class_0_spill;
+	u64 *class_1_spill;
+	u64 *class_2_spill;
+	u64 *class_3_spill;
+};
+
+extern void xlr_set_gmac_speed(struct xlr_net_priv *priv);
-- 
1.7.6
