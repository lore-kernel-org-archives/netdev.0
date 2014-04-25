From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/4] net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver
Date: Thu, 24 Apr 2014 18:08:57 -0700
Message-ID: <1398388140-8003-2-git-send-email-f.fainelli@gmail.com>
References: <1398388140-8003-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:37300 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbaDYBJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 21:09:24 -0400
Received: by mail-pd0-f179.google.com with SMTP id g10so2513446pdj.24
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 18:09:23 -0700 (PDT)
In-Reply-To: <1398388140-8003-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SYSTEMPORT is the latest Ethernet MAC hardware block used on newer
BCM7xxx Set Top Box SoCs in conjunction with an internal Ethernet
switch. This patch adds support for this hardware block along with the
following hardware features:

- support for hardware checksum offload (transmit and receive)
- support for the 32 transmit queues
- MIB counters reading

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- moved TX reclaim logic into per-queue NAPI context
- fixed multiline functions formatting

 drivers/net/ethernet/broadcom/bcmsysport.c | 1614 ++++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bcmsysport.h |  677 ++++++++++++
 2 files changed, 2291 insertions(+)
 create mode 100644 drivers/net/ethernet/broadcom/bcmsysport.c
 create mode 100644 drivers/net/ethernet/broadcom/bcmsysport.h

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
new file mode 100644
index 000000000000..4dc8d1e9829b
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -0,0 +1,1614 @@
+/*
+ * Broadcom BCM7xxx System Port Ethernet MAC driver
+ *
+ * Copyright (C) 2014 Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#define pr_fmt(fmt)	KBUILD_MODNAME ": " fmt
+
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/platform_device.h>
+#include <linux/of.h>
+#include <linux/of_net.h>
+#include <linux/of_mdio.h>
+#include <linux/phy.h>
+#include <linux/phy_fixed.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
+
+#include "bcmsysport.h"
+
+/* I/O accessors register helpers */
+#define BCM_SYSPORT_IO_MACRO(name, offset) \
+static inline u32 name##_readl(struct bcm_sysport_priv *priv, u32 off)	\
+{									\
+	u32 reg = __raw_readl(priv->base + offset + off);		\
+	return reg;							\
+}									\
+static inline void name##_writel(struct bcm_sysport_priv *priv,		\
+				  u32 val, u32 off)			\
+{									\
+	__raw_writel(val, priv->base + offset + off);			\
+}									\
+
+BCM_SYSPORT_IO_MACRO(intrl2_0, SYS_PORT_INTRL2_0_OFFSET);
+BCM_SYSPORT_IO_MACRO(intrl2_1, SYS_PORT_INTRL2_1_OFFSET);
+BCM_SYSPORT_IO_MACRO(umac, SYS_PORT_UMAC_OFFSET);
+BCM_SYSPORT_IO_MACRO(tdma, SYS_PORT_TDMA_OFFSET);
+BCM_SYSPORT_IO_MACRO(rdma, SYS_PORT_RDMA_OFFSET);
+BCM_SYSPORT_IO_MACRO(rxchk, SYS_PORT_RXCHK_OFFSET);
+BCM_SYSPORT_IO_MACRO(txchk, SYS_PORT_TXCHK_OFFSET);
+BCM_SYSPORT_IO_MACRO(rbuf, SYS_PORT_RBUF_OFFSET);
+BCM_SYSPORT_IO_MACRO(tbuf, SYS_PORT_TBUF_OFFSET);
+BCM_SYSPORT_IO_MACRO(topctrl, SYS_PORT_TOPCTRL_OFFSET);
+
+/* L2-interrupt masking/unmasking helpers, does automatic saving of the applied
+ * mask in a software copy to avoid CPU_MASK_STATUS reads in hot-paths.
+  */
+#define BCM_SYSPORT_INTR_L2(which)	\
+static inline void intrl2_##which##_mask_clear(struct bcm_sysport_priv *priv, \
+						u32 mask)		\
+{									\
+	intrl2_##which##_writel(priv, mask, INTRL2_CPU_MASK_CLEAR);	\
+	priv->irq##which##_mask &= ~(mask);				\
+}									\
+static inline void intrl2_##which##_mask_set(struct bcm_sysport_priv *priv, \
+						u32 mask)		\
+{									\
+	intrl2_## which##_writel(priv, mask, INTRL2_CPU_MASK_SET);	\
+	priv->irq##which##_mask |= (mask);				\
+}									\
+
+BCM_SYSPORT_INTR_L2(0)
+BCM_SYSPORT_INTR_L2(1)
+
+/* Register accesses to GISB/RBUS registers are expensive (few hundred
+ * nanoseconds), so keep the check for 64-bits explicit here to save
+ * one register write per-packet on 32-bits platforms.
+ */
+static inline void dma_desc_set_addr(struct bcm_sysport_priv *priv,
+				     void __iomem *d,
+				     dma_addr_t addr)
+{
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+	__raw_writel(upper_32_bits(addr) & DESC_ADDR_HI_MASK,
+			d + DESC_ADDR_HI_STATUS_LEN);
+#endif
+	__raw_writel(lower_32_bits(addr), d + DESC_ADDR_LO);
+}
+
+static inline void tdma_port_write_desc_addr(struct bcm_sysport_priv *priv,
+						struct dma_desc *desc,
+						unsigned int port)
+{
+	/* Ports are latched, so write upper address first */
+	tdma_writel(priv, desc->addr_status_len, TDMA_WRITE_PORT_HI(port));
+	tdma_writel(priv, desc->addr_lo, TDMA_WRITE_PORT_LO(port));
+}
+
+/* Ethtool operations */
+static int bcm_sysport_set_settings(struct net_device *dev,
+				    struct ethtool_cmd *cmd)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	return phy_ethtool_sset(priv->phydev, cmd);
+}
+
+static int bcm_sysport_get_settings(struct net_device *dev,
+					struct ethtool_cmd *cmd)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	return phy_ethtool_gset(priv->phydev, cmd);
+}
+
+static int bcm_sysport_set_rx_csum(struct net_device *dev,
+					netdev_features_t wanted)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	u32 reg;
+
+	priv->rx_csum_en = !!(wanted & NETIF_F_RXCSUM);
+	reg = rxchk_readl(priv, RXCHK_CONTROL);
+	if (priv->rx_csum_en)
+		reg |= RXCHK_EN;
+	else
+		reg &= ~RXCHK_EN;
+
+	/* If UniMAC forwards CRC, we need to skip over it to get
+	 * a valid CHK bit to be set in the per-packet status word
+	 */
+	if (priv->rx_csum_en && priv->crc_fwd)
+		reg |= RXCHK_SKIP_FCS;
+	else
+		reg &= ~RXCHK_SKIP_FCS;
+
+	rxchk_writel(priv, reg, RXCHK_CONTROL);
+
+	return 0;
+}
+
+static int bcm_sysport_set_tx_csum(struct net_device *dev,
+					netdev_features_t wanted)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	u32 reg;
+
+	/* Hardware transmit checksum requires us to enable the Transmit status
+	 * block prepended to the packet contents
+	 */
+	priv->tsb_en = !!(wanted & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM));
+	reg = tdma_readl(priv, TDMA_CONTROL);
+	if (priv->tsb_en)
+		reg |= TSB_EN;
+	else
+		reg &= ~TSB_EN;
+	tdma_writel(priv, reg, TDMA_CONTROL);
+
+	return 0;
+}
+
+static int bcm_sysport_set_features(struct net_device *dev,
+					netdev_features_t features)
+{
+	netdev_features_t changed = features ^ dev->features;
+	netdev_features_t wanted = dev->wanted_features;
+	int ret = 0;
+
+	if (changed & NETIF_F_RXCSUM)
+		ret = bcm_sysport_set_rx_csum(dev, wanted);
+	if (changed & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM))
+		ret = bcm_sysport_set_tx_csum(dev, wanted);
+
+	return ret;
+}
+
+/* Hardware counters must be kept in sync because the order/offset
+ * is important here (order in structure declaration = order in hardware)
+ */
+static const struct bcm_sysport_stats bcm_sysport_gstrings_stats[] = {
+	/* general stats */
+	STAT_NETDEV(rx_packets),
+	STAT_NETDEV(tx_packets),
+	STAT_NETDEV(rx_bytes),
+	STAT_NETDEV(tx_bytes),
+	STAT_NETDEV(rx_errors),
+	STAT_NETDEV(tx_errors),
+	STAT_NETDEV(rx_dropped),
+	STAT_NETDEV(tx_dropped),
+	STAT_NETDEV(multicast),
+	/* UniMAC RSV counters */
+	STAT_MIB_RX("rx_64_octets", mib.rx.pkt_cnt.cnt_64),
+	STAT_MIB_RX("rx_65_127_oct", mib.rx.pkt_cnt.cnt_127),
+	STAT_MIB_RX("rx_128_255_oct", mib.rx.pkt_cnt.cnt_255),
+	STAT_MIB_RX("rx_256_511_oct", mib.rx.pkt_cnt.cnt_511),
+	STAT_MIB_RX("rx_512_1023_oct", mib.rx.pkt_cnt.cnt_1023),
+	STAT_MIB_RX("rx_1024_1518_oct", mib.rx.pkt_cnt.cnt_1518),
+	STAT_MIB_RX("rx_vlan_1519_1522_oct", mib.rx.pkt_cnt.cnt_mgv),
+	STAT_MIB_RX("rx_1522_2047_oct", mib.rx.pkt_cnt.cnt_2047),
+	STAT_MIB_RX("rx_2048_4095_oct", mib.rx.pkt_cnt.cnt_4095),
+	STAT_MIB_RX("rx_4096_9216_oct", mib.rx.pkt_cnt.cnt_9216),
+	STAT_MIB_RX("rx_pkts", mib.rx.pkt),
+	STAT_MIB_RX("rx_bytes", mib.rx.bytes),
+	STAT_MIB_RX("rx_multicast", mib.rx.mca),
+	STAT_MIB_RX("rx_broadcast", mib.rx.bca),
+	STAT_MIB_RX("rx_fcs", mib.rx.fcs),
+	STAT_MIB_RX("rx_control", mib.rx.cf),
+	STAT_MIB_RX("rx_pause", mib.rx.pf),
+	STAT_MIB_RX("rx_unknown", mib.rx.uo),
+	STAT_MIB_RX("rx_align", mib.rx.aln),
+	STAT_MIB_RX("rx_outrange", mib.rx.flr),
+	STAT_MIB_RX("rx_code", mib.rx.cde),
+	STAT_MIB_RX("rx_carrier", mib.rx.fcr),
+	STAT_MIB_RX("rx_oversize", mib.rx.ovr),
+	STAT_MIB_RX("rx_jabber", mib.rx.jbr),
+	STAT_MIB_RX("rx_mtu_err", mib.rx.mtue),
+	STAT_MIB_RX("rx_good_pkts", mib.rx.pok),
+	STAT_MIB_RX("rx_unicast", mib.rx.uc),
+	STAT_MIB_RX("rx_ppp", mib.rx.ppp),
+	STAT_MIB_RX("rx_crc", mib.rx.rcrc),
+	/* UniMAC TSV counters */
+	STAT_MIB_TX("tx_64_octets", mib.tx.pkt_cnt.cnt_64),
+	STAT_MIB_TX("tx_65_127_oct", mib.tx.pkt_cnt.cnt_127),
+	STAT_MIB_TX("tx_128_255_oct", mib.tx.pkt_cnt.cnt_255),
+	STAT_MIB_TX("tx_256_511_oct", mib.tx.pkt_cnt.cnt_511),
+	STAT_MIB_TX("tx_512_1023_oct", mib.tx.pkt_cnt.cnt_1023),
+	STAT_MIB_TX("tx_1024_1518_oct", mib.tx.pkt_cnt.cnt_1518),
+	STAT_MIB_TX("tx_vlan_1519_1522_oct", mib.tx.pkt_cnt.cnt_mgv),
+	STAT_MIB_TX("tx_1522_2047_oct", mib.tx.pkt_cnt.cnt_2047),
+	STAT_MIB_TX("tx_2048_4095_oct", mib.tx.pkt_cnt.cnt_4095),
+	STAT_MIB_TX("tx_4096_9216_oct", mib.tx.pkt_cnt.cnt_9216),
+	STAT_MIB_TX("tx_pkts", mib.tx.pkts),
+	STAT_MIB_TX("tx_multicast", mib.tx.mca),
+	STAT_MIB_TX("tx_broadcast", mib.tx.bca),
+	STAT_MIB_TX("tx_pause", mib.tx.pf),
+	STAT_MIB_TX("tx_control", mib.tx.cf),
+	STAT_MIB_TX("tx_fcs_err", mib.tx.fcs),
+	STAT_MIB_TX("tx_oversize", mib.tx.ovr),
+	STAT_MIB_TX("tx_defer", mib.tx.drf),
+	STAT_MIB_TX("tx_excess_defer", mib.tx.edf),
+	STAT_MIB_TX("tx_single_col", mib.tx.scl),
+	STAT_MIB_TX("tx_multi_col", mib.tx.mcl),
+	STAT_MIB_TX("tx_late_col", mib.tx.lcl),
+	STAT_MIB_TX("tx_excess_col", mib.tx.ecl),
+	STAT_MIB_TX("tx_frags", mib.tx.frg),
+	STAT_MIB_TX("tx_total_col", mib.tx.ncl),
+	STAT_MIB_TX("tx_jabber", mib.tx.jbr),
+	STAT_MIB_TX("tx_bytes", mib.tx.bytes),
+	STAT_MIB_TX("tx_good_pkts", mib.tx.pok),
+	STAT_MIB_TX("tx_unicast", mib.tx.uc),
+	/* UniMAC RUNT counters */
+	STAT_RUNT("rx_runt_pkts", mib.rx_runt_cnt),
+	STAT_RUNT("rx_runt_valid_fcs", mib.rx_runt_fcs),
+	STAT_RUNT("rx_runt_inval_fcs_align", mib.rx_runt_fcs_align),
+	STAT_RUNT("rx_runt_bytes", mib.rx_runt_bytes),
+	/* RXCHK misc statistics */
+	STAT_RXCHK("rxchk_bad_csum", mib.rxchk_bad_csum, RXCHK_BAD_CSUM_CNTR),
+	STAT_RXCHK("rxchk_other_pkt_disc", mib.rxchk_other_pkt_disc,
+			RXCHK_OTHER_DISC_CNTR),
+	/* RBUF misc statistics */
+	STAT_RBUF("rbuf_ovflow_cnt", mib.rbuf_ovflow_cnt, RBUF_OVFL_DISC_CNTR),
+	STAT_RBUF("rbuf_err_cnt", mib.rbuf_err_cnt, RBUF_ERR_PKT_CNTR),
+};
+
+#define BCM_SYSPORT_STATS_LEN	ARRAY_SIZE(bcm_sysport_gstrings_stats)
+
+static void bcm_sysport_get_drvinfo(struct net_device *dev,
+					struct ethtool_drvinfo *info)
+{
+	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
+	strlcpy(info->version, "0.1", sizeof(info->version));
+	strlcpy(info->bus_info, "platform", sizeof(info->bus_info));
+	info->n_stats = BCM_SYSPORT_STATS_LEN;
+}
+
+static u32 bcm_sysport_get_msglvl(struct net_device *dev)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+
+	return priv->msg_enable;
+}
+
+static void bcm_sysport_set_msglvl(struct net_device *dev, u32 enable)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+
+	priv->msg_enable = enable;
+}
+
+static int bcm_sysport_get_sset_count(struct net_device *dev, int string_set)
+{
+	switch (string_set) {
+	case ETH_SS_STATS:
+		return BCM_SYSPORT_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void bcm_sysport_get_strings(struct net_device *dev,
+					u32 stringset, u8 *data)
+{
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < BCM_SYSPORT_STATS_LEN; i++) {
+			memcpy(data + i * ETH_GSTRING_LEN,
+				bcm_sysport_gstrings_stats[i].stat_string,
+				ETH_GSTRING_LEN);
+		}
+		break;
+	default:
+		break;
+	}
+}
+
+static void bcm_sysport_update_mib_counters(struct bcm_sysport_priv *priv)
+{
+	int i, j = 0;
+
+	for (i = 0; i < BCM_SYSPORT_STATS_LEN; i++) {
+		const struct bcm_sysport_stats *s;
+		u8 offset = 0;
+		u32 val = 0;
+		char *p;
+
+		s = &bcm_sysport_gstrings_stats[i];
+		switch (s->type) {
+		case BCM_SYSPORT_STAT_NETDEV:
+			continue;
+		case BCM_SYSPORT_STAT_MIB_RX:
+		case BCM_SYSPORT_STAT_MIB_TX:
+		case BCM_SYSPORT_STAT_RUNT:
+			if (s->type != BCM_SYSPORT_STAT_MIB_RX)
+				offset = UMAC_MIB_STAT_OFFSET;
+			val = umac_readl(priv, UMAC_MIB_START + j + offset);
+			break;
+		case BCM_SYSPORT_STAT_RXCHK:
+			val = rxchk_readl(priv, s->reg_offset);
+			if (val == ~0)
+				rxchk_writel(priv, 0, s->reg_offset);
+			break;
+		case BCM_SYSPORT_STAT_RBUF:
+			val = rbuf_readl(priv, s->reg_offset);
+			if (val == ~0)
+				rbuf_writel(priv, 0, s->reg_offset);
+			break;
+		}
+
+		j += s->stat_sizeof;
+		p = (char *)priv + s->stat_offset;
+		*(u32 *)p = val;
+	}
+
+	netif_dbg(priv, hw, priv->netdev, "updated MIB counters\n");
+}
+
+static void bcm_sysport_get_stats(struct net_device *dev,
+					struct ethtool_stats *stats, u64 *data)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	int i;
+
+	if (netif_running(dev))
+		bcm_sysport_update_mib_counters(priv);
+
+	for (i =  0; i < BCM_SYSPORT_STATS_LEN; i++) {
+		const struct bcm_sysport_stats *s;
+		char *p;
+
+		s = &bcm_sysport_gstrings_stats[i];
+		if (s->type == BCM_SYSPORT_STAT_NETDEV)
+			p = (char *)&dev->stats;
+		else
+			p = (char *)priv;
+		p += s->stat_offset;
+		data[i] = *(u32 *)p;
+	}
+}
+
+static void bcm_sysport_free_cb(struct bcm_sysport_cb *cb)
+{
+	dev_kfree_skb_any(cb->skb);
+	cb->skb = NULL;
+	dma_unmap_addr_set(cb, dma_addr, 0);
+}
+
+static int bcm_sysport_rx_refill(struct bcm_sysport_priv *priv,
+				 struct bcm_sysport_cb *cb)
+{
+	struct device *kdev = &priv->pdev->dev;
+	struct net_device *ndev = priv->netdev;
+	dma_addr_t mapping;
+	int ret;
+
+	cb->skb = netdev_alloc_skb(priv->netdev, RX_BUF_LENGTH);
+	if (!cb->skb) {
+		netif_err(priv, rx_err, ndev, "SKB alloc failed\n");
+		return -ENOMEM;
+	}
+
+	mapping = dma_map_single(kdev, cb->skb->data,
+				RX_BUF_LENGTH, DMA_FROM_DEVICE);
+	ret = dma_mapping_error(kdev, mapping);
+	if (ret) {
+		bcm_sysport_free_cb(cb);
+		netif_err(priv, rx_err, ndev, "DMA mapping failure\n");
+		return ret;
+	}
+
+	dma_unmap_addr_set(cb, dma_addr, mapping);
+	dma_desc_set_addr(priv, priv->rx_bd_assign_ptr, mapping);
+
+	priv->rx_bd_assign_index++;
+	priv->rx_bd_assign_index &= (priv->num_rx_bds - 1);
+	priv->rx_bd_assign_ptr = priv->rx_bds +
+		(priv->rx_bd_assign_index * DESC_SIZE);
+
+	netif_dbg(priv, rx_status, ndev, "RX refill\n");
+
+	return 0;
+}
+
+static int bcm_sysport_alloc_rx_bufs(struct bcm_sysport_priv *priv)
+{
+	struct bcm_sysport_cb *cb;
+	int ret = 0;
+	unsigned int i;
+
+	for (i = 0; i < priv->num_rx_bds; i++) {
+		cb = &priv->rx_cbs[priv->rx_bd_assign_index];
+		if (cb->skb)
+			continue;
+
+		ret = bcm_sysport_rx_refill(priv, cb);
+		if (ret)
+			break;
+	}
+
+	return ret;
+}
+
+/* Poll the hardware for up to budget packets to process */
+static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
+					unsigned int budget)
+{
+	struct device *kdev = &priv->pdev->dev;
+	struct net_device *ndev = priv->netdev;
+	unsigned int processed = 0, to_process;
+	struct bcm_sysport_cb *cb;
+	struct sk_buff *skb;
+	unsigned int p_index;
+	u16 len, status;
+	struct rsb *rsb;
+
+	/* Determine how much we should process since last call */
+	p_index = rdma_readl(priv, RDMA_PROD_INDEX);
+	p_index &= RDMA_PROD_INDEX_MASK;
+
+	if (p_index < priv->rx_c_index)
+		to_process = (RDMA_CONS_INDEX_MASK + 1) -
+			priv->rx_c_index + p_index;
+	else
+		to_process = p_index - priv->rx_c_index;
+
+	netif_dbg(priv, rx_status, ndev,
+			"p_index=%d rx_c_index=%d to_process=%d\n",
+			p_index, priv->rx_c_index, to_process);
+
+	while ((processed < to_process) &&
+		(processed < budget)) {
+
+		cb = &priv->rx_cbs[priv->rx_read_ptr];
+		skb = cb->skb;
+		dma_unmap_single(kdev, dma_unmap_addr(cb, dma_addr),
+				dma_unmap_len(cb, dma_len), DMA_FROM_DEVICE);
+
+		/* Extract the Receive Status Block prepended */
+		rsb = (struct rsb *)skb->data;
+		len = (rsb->rx_status_len >> DESC_LEN_SHIFT) & DESC_LEN_MASK;
+		status = (rsb->rx_status_len >> DESC_STATUS_SHIFT) &
+			DESC_STATUS_MASK;
+
+		processed++;
+		priv->rx_read_ptr++;
+		if (priv->rx_read_ptr == priv->num_rx_bds)
+			priv->rx_read_ptr = 0;
+
+		netif_dbg(priv, rx_status, ndev,
+				"p=%d, c=%d, rd_ptr=%d, len=%d, flag=0x%04x\n",
+				p_index, priv->rx_c_index, priv->rx_read_ptr,
+				len, status);
+
+		if (unlikely(!skb)) {
+			netif_err(priv, rx_err, ndev, "out of memory!\n");
+			ndev->stats.rx_dropped++;
+			ndev->stats.rx_errors++;
+			goto refill;
+		}
+
+		if (unlikely(!(status & DESC_EOP) || !(status & DESC_SOP))) {
+			netif_err(priv, rx_status, ndev, "fragmented packet!\n");
+			ndev->stats.rx_dropped++;
+			ndev->stats.rx_errors++;
+			bcm_sysport_free_cb(cb);
+			goto refill;
+		}
+
+		if (unlikely(status & (RX_STATUS_ERR | RX_STATUS_OVFLOW))) {
+			netif_err(priv, rx_err, ndev, "error packet\n");
+			if (RX_STATUS_OVFLOW)
+				ndev->stats.rx_over_errors++;
+			ndev->stats.rx_dropped++;
+			ndev->stats.rx_errors++;
+			bcm_sysport_free_cb(cb);
+			goto refill;
+		}
+
+		skb_put(skb, len);
+
+		/* Hardware validated our checksum */
+		if (likely(status & DESC_L4_CSUM))
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+		/* Hardware pre-pends packets with 2bytes between Ethernet
+		 * and IP header plus we have the Receive Status Block, strip
+		 * off all of this from the SKB.
+		 */
+		skb_pull(skb, sizeof(*rsb) + 2);
+		len -= (sizeof(*rsb) + 2);
+
+		/* UniMAC may forward CRC */
+		if (priv->crc_fwd) {
+			skb_trim(skb, len - ETH_FCS_LEN);
+			len -= ETH_FCS_LEN;
+		}
+
+		skb->protocol = eth_type_trans(skb, ndev);
+		ndev->stats.rx_packets++;
+		ndev->stats.rx_bytes += len;
+
+		napi_gro_receive(&priv->napi, skb);
+refill:
+		bcm_sysport_rx_refill(priv, cb);
+	}
+
+	return processed;
+}
+
+static void bcm_sysport_tx_reclaim_one(struct bcm_sysport_priv *priv,
+					struct bcm_sysport_cb *cb,
+					unsigned int *bytes_compl,
+					unsigned int *pkts_compl)
+{
+	struct device *kdev = &priv->pdev->dev;
+	struct net_device *ndev = priv->netdev;
+
+	if (cb->skb) {
+		ndev->stats.tx_bytes += cb->skb->len;
+		*bytes_compl += cb->skb->len;
+		dma_unmap_single(kdev, dma_unmap_addr(cb, dma_addr),
+				dma_unmap_len(cb, dma_len),
+				DMA_TO_DEVICE);
+		ndev->stats.tx_packets++;
+		(*pkts_compl)++;
+		bcm_sysport_free_cb(cb);
+	/* SKB fragment */
+	} else if (dma_unmap_addr(cb, dma_addr)) {
+		ndev->stats.tx_bytes += dma_unmap_len(cb, dma_len);
+		dma_unmap_page(kdev, dma_unmap_addr(cb, dma_addr),
+				dma_unmap_len(cb, dma_len), DMA_TO_DEVICE);
+		dma_unmap_addr_set(cb, dma_addr, 0);
+	}
+}
+
+/* Reclaim queued SKBs for transmission completion, lockless version */
+static unsigned int __bcm_sysport_tx_reclaim(struct bcm_sysport_priv *priv,
+					     struct bcm_sysport_tx_ring *ring)
+{
+	struct net_device *ndev = priv->netdev;
+	unsigned int c_index, last_c_index, last_tx_cn, num_tx_cbs;
+	unsigned int pkts_compl = 0, bytes_compl = 0;
+	struct bcm_sysport_cb *cb;
+	struct netdev_queue *txq;
+	u32 hw_ind;
+
+	txq = netdev_get_tx_queue(ndev, ring->index);
+
+	/* Compute how many descriptors have been processed since last call */
+	hw_ind = tdma_readl(priv, TDMA_DESC_RING_PROD_CONS_INDEX(ring->index));
+	c_index = (hw_ind >> RING_CONS_INDEX_SHIFT) & RING_CONS_INDEX_MASK;
+	ring->p_index = (hw_ind & RING_PROD_INDEX_MASK);
+
+	last_c_index = ring->c_index;
+	num_tx_cbs = ring->size;
+
+	c_index &= (num_tx_cbs - 1);
+
+	if (c_index >= last_c_index)
+		last_tx_cn = c_index - last_c_index;
+	else
+		last_tx_cn = num_tx_cbs - last_c_index + c_index;
+
+	netif_dbg(priv, tx_done, ndev,
+			"ring=%d c_index=%d last_tx_cn=%d last_c_index=%d\n",
+			ring->index, c_index, last_tx_cn, last_c_index);
+
+	while (last_tx_cn-- > 0) {
+		cb = ring->cbs + last_c_index;
+		bcm_sysport_tx_reclaim_one(priv, cb, &bytes_compl, &pkts_compl);
+
+		ring->desc_count++;
+		last_c_index++;
+		last_c_index &= (num_tx_cbs - 1);
+	}
+
+	ring->c_index = c_index;
+
+	if (netif_tx_queue_stopped(txq) && pkts_compl)
+		netif_tx_wake_queue(txq);
+
+	netif_dbg(priv, tx_done, ndev,
+			"ring=%d c_index=%d pkts_compl=%d, bytes_compl=%d\n",
+			ring->index, ring->c_index, pkts_compl, bytes_compl);
+
+	return pkts_compl;
+}
+
+/* Locked version of the per-ring TX reclaim routine */
+static unsigned int bcm_sysport_tx_reclaim(struct bcm_sysport_priv *priv,
+					   struct bcm_sysport_tx_ring *ring)
+{
+	unsigned int released;
+
+	spin_lock(&ring->lock);
+	released = __bcm_sysport_tx_reclaim(priv, ring);
+	spin_unlock(&ring->lock);
+
+	return released;
+}
+
+static int bcm_sysport_tx_poll(struct napi_struct *napi, int budget)
+{
+	struct bcm_sysport_tx_ring *ring =
+		container_of(napi, struct bcm_sysport_tx_ring, napi);
+	unsigned int work_done = 0;
+
+	work_done = bcm_sysport_tx_reclaim(ring->priv, ring);
+
+	if (work_done < budget) {
+		napi_complete(napi);
+		/* re-enable TX interrupt */
+		intrl2_1_mask_clear(ring->priv, BIT(ring->index));
+	}
+
+	return work_done;
+}
+
+static void bcm_sysport_tx_reclaim_all(struct bcm_sysport_priv *priv)
+{
+	unsigned int q;
+
+	for (q = 0; q < priv->netdev->num_tx_queues; q++)
+		bcm_sysport_tx_reclaim(priv, &priv->tx_rings[q]);
+}
+
+static int bcm_sysport_poll(struct napi_struct *napi, int budget)
+{
+	struct bcm_sysport_priv *priv =
+		container_of(napi, struct bcm_sysport_priv, napi);
+	unsigned int work_done = 0;
+
+	work_done = bcm_sysport_desc_rx(priv, budget);
+
+	priv->rx_c_index += work_done;
+	priv->rx_c_index &= RDMA_CONS_INDEX_MASK;
+	rdma_writel(priv, priv->rx_c_index, RDMA_CONS_INDEX);
+
+	if (work_done < budget) {
+		napi_complete(napi);
+		/* re-enable RX interrupts */
+		intrl2_0_mask_clear(priv, INTRL2_0_RDMA_MBDONE);
+	}
+
+	return work_done;
+}
+
+
+/* RX and misc interrupt routine */
+static irqreturn_t bcm_sysport_rx_isr(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+
+	priv->irq0_stat = intrl2_0_readl(priv, INTRL2_CPU_STATUS) &
+			  ~intrl2_0_readl(priv, INTRL2_CPU_MASK_STATUS);
+	intrl2_0_writel(priv, priv->irq0_stat, INTRL2_CPU_CLEAR);
+
+	if (unlikely(priv->irq0_stat == 0)) {
+		netdev_warn(priv->netdev, "spurious RX interrupt\n");
+		return IRQ_NONE;
+	}
+
+	if (priv->irq0_stat & INTRL2_0_RDMA_MBDONE) {
+		if (likely(napi_schedule_prep(&priv->napi))) {
+			/* disable RX interrupts */
+			intrl2_0_mask_set(priv, INTRL2_0_RDMA_MBDONE);
+			__napi_schedule(&priv->napi);
+		}
+	}
+
+	/* TX ring is full, perform a full reclaim since we do not know
+	 * which one would trigger this interrupt
+	 */
+	if (priv->irq0_stat & INTRL2_0_TX_RING_FULL)
+		bcm_sysport_tx_reclaim_all(priv);
+
+	return IRQ_HANDLED;
+}
+
+/* TX interrupt service routine */
+static irqreturn_t bcm_sysport_tx_isr(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	struct bcm_sysport_tx_ring *txr;
+	unsigned int ring;
+
+	priv->irq1_stat = intrl2_1_readl(priv, INTRL2_CPU_STATUS) &
+				~intrl2_1_readl(priv, INTRL2_CPU_MASK_STATUS);
+	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
+
+	if (unlikely(priv->irq1_stat == 0)) {
+		netdev_warn(priv->netdev, "spurious TX interrupt\n");
+		return IRQ_NONE;
+	}
+
+	for (ring = 0; ring < dev->num_tx_queues; ring++) {
+		if (!(priv->irq1_stat & BIT(ring)))
+			continue;
+
+		txr = &priv->tx_rings[ring];
+
+		if (likely(napi_schedule_prep(&txr->napi))) {
+			intrl2_1_mask_set(priv, BIT(ring));
+			__napi_schedule(&txr->napi);
+		}
+	}
+
+	return IRQ_HANDLED;
+}
+
+static int bcm_sysport_insert_tsb(struct sk_buff *skb, struct net_device *dev)
+{
+	struct sk_buff *nskb;
+	struct tsb *tsb;
+	u32 csum_info;
+	u8 ip_proto;
+	u16 csum_start;
+	u16 ip_ver;
+
+	/* Re-allocate SKB if needed */
+	if (unlikely(skb_headroom(skb) < sizeof(*tsb))) {
+		nskb = skb_realloc_headroom(skb, sizeof(*tsb));
+		dev_kfree_skb(skb);
+		if (!nskb) {
+			dev->stats.tx_errors++;
+			dev->stats.tx_dropped++;
+			return -ENOMEM;
+		}
+		skb = nskb;
+	}
+
+	tsb = (struct tsb *)skb_push(skb, sizeof(*tsb));
+	/* Zero-out TSB by default */
+	memset(tsb, 0, sizeof(*tsb));
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		ip_ver = htons(skb->protocol);
+		switch (ip_ver) {
+		case ETH_P_IP:
+			ip_proto = ip_hdr(skb)->protocol;
+			break;
+		case ETH_P_IPV6:
+			ip_proto = ipv6_hdr(skb)->nexthdr;
+			break;
+		default:
+			return 0;
+		}
+
+		/* Get the checksum offset and the L4 (transport) offset */
+		csum_start = skb_checksum_start_offset(skb) - sizeof(*tsb);
+		csum_info = (csum_start + skb->csum_offset) & L4_CSUM_PTR_MASK;
+		csum_info |= (csum_start << L4_PTR_SHIFT);
+
+		if (ip_proto == IPPROTO_TCP || ip_proto == IPPROTO_UDP) {
+			csum_info |= L4_LENGTH_VALID;
+			if (ip_proto == IPPROTO_UDP && ip_ver == ETH_P_IP)
+				csum_info |= L4_UDP;
+		} else
+			csum_info = 0;
+
+		tsb->l4_ptr_dest_map = csum_info;
+	}
+
+	return 0;
+}
+
+static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
+				    struct net_device *dev)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	struct device *kdev = &priv->pdev->dev;
+	struct bcm_sysport_tx_ring *ring;
+	struct bcm_sysport_cb *cb;
+	struct netdev_queue *txq;
+	struct dma_desc *desc;
+	dma_addr_t mapping;
+	u32 len_status;
+	u16 queue;
+	int ret;
+
+	queue = skb_get_queue_mapping(skb);
+	txq = netdev_get_tx_queue(dev, queue);
+	ring = &priv->tx_rings[queue];
+
+	/* lock against tx reclaim in BH context */
+	spin_lock(&ring->lock);
+	if (unlikely(ring->desc_count == 0)) {
+		netif_tx_stop_queue(txq);
+		netdev_err(dev, "queue %d awake and ring full!\n", queue);
+		ret = NETDEV_TX_BUSY;
+		goto out;
+	}
+
+	/* Insert TSB and checksum infos */
+	if (priv->tsb_en) {
+		ret = bcm_sysport_insert_tsb(skb, dev);
+		if (ret) {
+			ret = NETDEV_TX_OK;
+			goto out;
+		}
+	}
+
+	mapping = dma_map_single(kdev, skb->data, skb->len, DMA_TO_DEVICE);
+	if (dma_mapping_error(kdev, mapping)) {
+		netif_err(priv, tx_err, dev, "DMA map failed at %p (len=%d)\n",
+				skb->data, skb->len);
+		ret = NETDEV_TX_OK;
+		goto out;
+	}
+
+	/* Remember the SKB for future freeing */
+	cb = &ring->cbs[ring->curr_desc];
+	cb->skb = skb;
+	dma_unmap_addr_set(cb, dma_addr, mapping);
+	dma_unmap_len_set(cb, dma_len, skb->len);
+
+	/* Fetch a descriptor entry from our pool */
+	desc = ring->desc_cpu;
+
+	desc->addr_lo = lower_32_bits(mapping);
+	len_status = upper_32_bits(mapping) & DESC_ADDR_HI_MASK;
+	len_status |= (skb->len << DESC_LEN_SHIFT);
+	len_status |= (DESC_SOP | DESC_EOP | TX_STATUS_APP_CRC) <<
+			DESC_STATUS_SHIFT;
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		len_status |= (DESC_L4_CSUM << DESC_STATUS_SHIFT);
+
+	ring->curr_desc++;
+	if (ring->curr_desc == ring->size)
+		ring->curr_desc = 0;
+	ring->desc_count--;
+
+	/* Ensure write completion of the descriptor status/length
+	 * in DRAM before the System Port WRITE_PORT register latches
+	 * the value
+	 */
+	wmb();
+	desc->addr_status_len = len_status;
+	wmb();
+
+	/* Write this descriptor address to the RING write port */
+	tdma_port_write_desc_addr(priv, desc, ring->index);
+
+	/* Check ring space and update SW control flow */
+	if (ring->desc_count == 0)
+		netif_tx_stop_queue(txq);
+
+	netif_dbg(priv, tx_queued, dev, "ring=%d desc_count=%d, curr_desc=%d\n",
+			ring->index, ring->desc_count, ring->curr_desc);
+
+	ret = NETDEV_TX_OK;
+out:
+	spin_unlock(&ring->lock);
+	return ret;
+}
+
+static void bcm_sysport_tx_timeout(struct net_device *dev)
+{
+	netdev_warn(dev, "transmit timeout!\n");
+
+	dev->trans_start = jiffies;
+	dev->stats.tx_errors++;
+
+	netif_tx_wake_all_queues(dev);
+}
+
+/* phylib adjust link callback */
+static void bcm_sysport_adj_link(struct net_device *dev)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phydev;
+	unsigned int changed = 0;
+	u32 cmd_bits = 0, reg;
+
+	if (priv->old_link != phydev->link) {
+		changed = 1;
+		priv->old_link = phydev->link;
+	}
+
+	if (priv->old_duplex != phydev->duplex) {
+		changed = 1;
+		priv->old_duplex = phydev->duplex;
+	}
+
+	switch (phydev->speed) {
+	case SPEED_2500:
+		cmd_bits = CMD_SPEED_2500;
+		break;
+	case SPEED_1000:
+		cmd_bits = CMD_SPEED_1000;
+		break;
+	case SPEED_100:
+		cmd_bits = CMD_SPEED_100;
+		break;
+	case SPEED_10:
+		cmd_bits = CMD_SPEED_10;
+		break;
+	default:
+		break;
+	}
+	cmd_bits <<= CMD_SPEED_SHIFT;
+
+	if (phydev->duplex == DUPLEX_HALF)
+		cmd_bits |= CMD_HD_EN;
+
+	if (priv->old_pause != phydev->pause) {
+		changed = 1;
+		priv->old_pause = phydev->pause;
+	}
+
+	if (!phydev->pause)
+		cmd_bits |= CMD_RX_PAUSE_IGNORE | CMD_TX_PAUSE_IGNORE;
+
+	reg = umac_readl(priv, UMAC_CMD);
+	reg &= ~((CMD_SPEED_MASK << CMD_SPEED_SHIFT) |
+			CMD_HD_EN | CMD_RX_PAUSE_IGNORE |
+			CMD_TX_PAUSE_IGNORE);
+	reg |= cmd_bits;
+	umac_writel(priv, reg, UMAC_CMD);
+
+	if (changed)
+		phy_print_status(priv->phydev);
+}
+
+static int bcm_sysport_init_tx_ring(struct bcm_sysport_priv *priv,
+				    unsigned int index)
+{
+	struct bcm_sysport_tx_ring *ring = &priv->tx_rings[index];
+	struct device *kdev = &priv->pdev->dev;
+	size_t size;
+	void *p;
+	u32 reg;
+
+	/* Simple descriptors partitioning for now */
+	size = 256;
+
+	/* We just need one DMA descriptor which is DMA-able, since writing to
+	 * the port will allocate a new descriptor in its internal linked-list
+	 */
+	p = dma_zalloc_coherent(kdev, 1, &ring->desc_dma, GFP_KERNEL);
+	if (!p) {
+		netif_err(priv, hw, priv->netdev, "DMA alloc failed\n");
+		return -ENOMEM;
+	}
+
+	ring->cbs = kzalloc(sizeof(struct bcm_sysport_cb) * size, GFP_KERNEL);
+	if (!ring->cbs) {
+		netif_err(priv, hw, priv->netdev, "CB allocation failed\n");
+		return -ENOMEM;
+	}
+
+	/* Initialize SW view of the ring */
+	spin_lock_init(&ring->lock);
+	ring->priv = priv;
+	netif_napi_add(priv->netdev, &ring->napi, bcm_sysport_tx_poll, 64);
+	ring->index = index;
+	ring->size = size;
+	ring->alloc_size = ring->size;
+	ring->desc_cpu = p;
+	ring->desc_count = ring->size;
+	ring->curr_desc = 0;
+
+	/* Initialize HW ring */
+	tdma_writel(priv, RING_EN, TDMA_DESC_RING_HEAD_TAIL_PTR(index));
+	tdma_writel(priv, 0, TDMA_DESC_RING_COUNT(index));
+	tdma_writel(priv, 1, TDMA_DESC_RING_INTR_CONTROL(index));
+	tdma_writel(priv, 0, TDMA_DESC_RING_PROD_CONS_INDEX(index));
+	tdma_writel(priv, RING_IGNORE_STATUS, TDMA_DESC_RING_MAPPING(index));
+	tdma_writel(priv, 0, TDMA_DESC_RING_PCP_DEI_VID(index));
+
+	/* Program the number of descriptors as MAX_THRESHOLD and half of
+	 * its size for the hysteresis trigger
+	 */
+	tdma_writel(priv, ring->size |
+			1 << RING_HYST_THRESH_SHIFT,
+			TDMA_DESC_RING_MAX_HYST(index));
+
+	/* Enable the ring queue in the arbiter */
+	reg = tdma_readl(priv, TDMA_TIER1_ARB_0_QUEUE_EN);
+	reg |= (1 << index);
+	tdma_writel(priv, reg, TDMA_TIER1_ARB_0_QUEUE_EN);
+
+	napi_enable(&ring->napi);
+
+	netif_dbg(priv, hw, priv->netdev,
+			"TDMA cfg, size=%d, desc_cpu=%p\n",
+			ring->size, ring->desc_cpu);
+
+	return 0;
+}
+
+static void bcm_sysport_fini_tx_ring(struct bcm_sysport_priv *priv,
+					unsigned int index)
+{
+	struct bcm_sysport_tx_ring *ring = &priv->tx_rings[index];
+	struct device *kdev = &priv->pdev->dev;
+	u32 reg;
+
+	/* Caller should stop the TDMA engine */
+	reg = tdma_readl(priv, TDMA_STATUS);
+	if (!(reg & TDMA_DISABLED))
+		netdev_warn(priv->netdev, "TDMA not stopped!\n");
+
+	napi_disable(&ring->napi);
+	netif_napi_del(&ring->napi);
+
+	bcm_sysport_tx_reclaim(priv, ring);
+
+	kfree(ring->cbs);
+	ring->cbs = NULL;
+
+	if (ring->desc_dma) {
+		dma_free_coherent(kdev, 1, ring->desc_cpu, ring->desc_dma);
+		ring->desc_dma = 0;
+	}
+	ring->size = 0;
+	ring->alloc_size = 0;
+
+	netif_dbg(priv, hw, priv->netdev, "TDMA fini done\n");
+}
+
+/* RDMA helper */
+static inline int rdma_enable_set(struct bcm_sysport_priv *priv,
+					unsigned int enable)
+{
+	unsigned int timeout = 1000;
+	u32 reg;
+
+	reg = rdma_readl(priv, RDMA_CONTROL);
+	if (enable)
+		reg |= RDMA_EN;
+	else
+		reg &= ~RDMA_EN;
+	rdma_writel(priv, reg, RDMA_CONTROL);
+
+	/* Poll for RMDA disabling completion */
+	do {
+		reg = rdma_readl(priv, RDMA_STATUS);
+		if (!!(reg & RDMA_DISABLED) == !enable)
+			return 0;
+		usleep_range(1000, 2000);
+	} while (timeout-- > 0);
+
+	netdev_err(priv->netdev, "timeout waiting for RDMA to finish\n");
+
+	return -ETIMEDOUT;
+}
+
+/* TDMA helper */
+static inline int tdma_enable_set(struct bcm_sysport_priv *priv,
+					unsigned int enable)
+{
+	unsigned int timeout = 1000;
+	u32 reg;
+
+	reg = tdma_readl(priv, TDMA_CONTROL);
+	if (enable)
+		reg |= TDMA_EN;
+	else
+		reg &= ~TDMA_EN;
+	tdma_writel(priv, reg, TDMA_CONTROL);
+
+	/* Poll for TMDA disabling completion */
+	do {
+		reg = tdma_readl(priv, TDMA_STATUS);
+		if (!!(reg & TDMA_DISABLED) == !enable)
+			return 0;
+
+		usleep_range(1000, 2000);
+	} while (timeout-- > 0);
+
+	netdev_err(priv->netdev, "timeout waiting for TDMA to finish\n");
+
+	return -ETIMEDOUT;
+}
+
+static int bcm_sysport_init_rx_ring(struct bcm_sysport_priv *priv)
+{
+	u32 reg;
+	int ret;
+
+	/* Initialize SW view of the RX ring */
+	priv->num_rx_bds = NUM_RX_DESC;
+	priv->rx_bds = priv->base + SYS_PORT_RDMA_OFFSET;
+	priv->rx_bd_assign_ptr = priv->rx_bds;
+	priv->rx_bd_assign_index = 0;
+	priv->rx_c_index = 0;
+	priv->rx_read_ptr = 0;
+	priv->rx_cbs = kzalloc(priv->num_rx_bds *
+				sizeof(struct bcm_sysport_cb), GFP_KERNEL);
+	if (!priv->rx_cbs) {
+		netif_err(priv, hw, priv->netdev, "CB allocation failed\n");
+		return -ENOMEM;
+	}
+
+	ret = bcm_sysport_alloc_rx_bufs(priv);
+	if (ret) {
+		netif_err(priv, hw, priv->netdev, "SKB allocation failed\n");
+		return ret;
+	}
+
+	/* Initialize HW, ensure RDMA is disabled */
+	reg = rdma_readl(priv, RDMA_STATUS);
+	if (!(reg & RDMA_DISABLED))
+		rdma_enable_set(priv, 0);
+
+	rdma_writel(priv, 0, RDMA_WRITE_PTR_LO);
+	rdma_writel(priv, 0, RDMA_WRITE_PTR_HI);
+	rdma_writel(priv, 0, RDMA_PROD_INDEX);
+	rdma_writel(priv, 0, RDMA_CONS_INDEX);
+	rdma_writel(priv, priv->num_rx_bds << RDMA_RING_SIZE_SHIFT |
+			  RX_BUF_LENGTH, RDMA_RING_BUF_SIZE);
+	/* Operate the queue in ring mode */
+	rdma_writel(priv, 0, RDMA_START_ADDR_HI);
+	rdma_writel(priv, 0, RDMA_START_ADDR_LO);
+	rdma_writel(priv, 0, RDMA_END_ADDR_HI);
+	rdma_writel(priv, NUM_HW_RX_DESC_WORDS - 1, RDMA_END_ADDR_LO);
+
+	rdma_writel(priv, 1, RDMA_MBDONE_INTR);
+
+	netif_dbg(priv, hw, priv->netdev,
+			"RDMA cfg, num_rx_bds=%d, rx_bds=%p\n",
+			priv->num_rx_bds, priv->rx_bds);
+
+	return 0;
+}
+
+static void bcm_sysport_fini_rx_ring(struct bcm_sysport_priv *priv)
+{
+	struct bcm_sysport_cb *cb;
+	unsigned int i;
+	u32 reg;
+
+	/* Caller should ensure RDMA is disabled */
+	reg = rdma_readl(priv, RDMA_STATUS);
+	if (!(reg & RDMA_DISABLED))
+		netdev_warn(priv->netdev, "RDMA not stopped!\n");
+
+	for (i = 0; i < priv->num_rx_bds; i++) {
+		cb = &priv->rx_cbs[i];
+		if (dma_unmap_addr(cb, dma_addr))
+			dma_unmap_single(&priv->pdev->dev,
+					dma_unmap_addr(cb, dma_addr),
+					RX_BUF_LENGTH, DMA_FROM_DEVICE);
+		bcm_sysport_free_cb(cb);
+	}
+
+	kfree(priv->rx_cbs);
+	priv->rx_cbs = NULL;
+
+	netif_dbg(priv, hw, priv->netdev, "RDMA fini done\n");
+}
+
+static void bcm_sysport_set_rx_mode(struct net_device *dev)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	u32 reg;
+
+	reg = umac_readl(priv, UMAC_CMD);
+	if (dev->flags & IFF_PROMISC)
+		reg |= CMD_PROMISC;
+	else
+		reg &= ~CMD_PROMISC;
+	umac_writel(priv, reg, UMAC_CMD);
+
+	/* No support for ALLMULTI */
+	if (dev->flags & IFF_ALLMULTI)
+		return;
+}
+
+static inline void umac_enable_set(struct bcm_sysport_priv *priv,
+					unsigned int enable)
+{
+	u32 reg;
+
+	reg = umac_readl(priv, UMAC_CMD);
+	if (enable)
+		reg |= CMD_RX_EN | CMD_TX_EN;
+	else
+		reg &= ~(CMD_RX_EN | CMD_TX_EN);
+	umac_writel(priv, reg, UMAC_CMD);
+}
+
+static inline int umac_reset(struct bcm_sysport_priv *priv)
+{
+	unsigned int timeout = 0;
+	u32 reg;
+	int ret = 0;
+
+	umac_writel(priv, 0, UMAC_CMD);
+	while (timeout++ < 1000) {
+		reg = umac_readl(priv, UMAC_CMD);
+		if (!(reg & CMD_SW_RESET))
+			break;
+
+		udelay(1);
+	}
+
+	if (timeout == 1000) {
+		dev_err(&priv->pdev->dev,
+			"timeout waiting for MAC to come out of reset\n");
+		ret = -ETIMEDOUT;
+	}
+
+	return ret;
+}
+
+static void umac_set_hw_addr(struct bcm_sysport_priv *priv,
+				unsigned char *addr)
+{
+	umac_writel(priv, (addr[0] << 24) | (addr[1] << 16) |
+			(addr[2] << 8) | addr[3], UMAC_MAC0);
+	umac_writel(priv, (addr[4] << 8) | addr[5], UMAC_MAC1);
+}
+
+static void topctrl_flush(struct bcm_sysport_priv *priv)
+{
+	topctrl_writel(priv, RX_FLUSH, RX_FLUSH_CNTL);
+	topctrl_writel(priv, TX_FLUSH, TX_FLUSH_CNTL);
+	mdelay(1);
+	topctrl_writel(priv, 0, RX_FLUSH_CNTL);
+	topctrl_writel(priv, 0, TX_FLUSH_CNTL);
+}
+
+static int bcm_sysport_open(struct net_device *dev)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	unsigned int i;
+	u32 reg;
+	int ret;
+
+	/* Reset UniMAC */
+	ret = umac_reset(priv);
+	if (ret) {
+		netdev_err(dev, "UniMAC reset failed\n");
+		return ret;
+	}
+
+	/* Flush TX and RX FIFOs at TOPCTRL level */
+	topctrl_flush(priv);
+
+	/* Disable the UniMAC RX/TX */
+	umac_enable_set(priv, 0);
+
+	/* Enable RBUF 2bytes alignment and Receive Status Block */
+	reg = rbuf_readl(priv, RBUF_CONTROL);
+	reg |= RBUF_4B_ALGN | RBUF_RSB_EN;
+	rbuf_writel(priv, reg, RBUF_CONTROL);
+
+	/* Set maximum frame length */
+	umac_writel(priv, UMAC_MAX_MTU_SIZE, UMAC_MAX_FRAME_LEN);
+
+	/* Set MAC address */
+	umac_set_hw_addr(priv, dev->dev_addr);
+
+	/* Read CRC forward */
+	priv->crc_fwd = !!(umac_readl(priv, UMAC_CMD) & CMD_CRC_FWD);
+
+	priv->phydev = of_phy_connect_fixed_link(dev, bcm_sysport_adj_link,
+							priv->phy_interface);
+	if (!priv->phydev) {
+		netdev_err(dev, "could not attach to PHY\n");
+		return -ENODEV;
+	}
+
+	/* Reset house keeping link status */
+	priv->old_duplex = -1;
+	priv->old_link = -1;
+	priv->old_pause = -1;
+
+	/* mask all interrupts and request them */
+	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_MASK_SET);
+	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
+	intrl2_0_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
+	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_MASK_SET);
+	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
+	intrl2_1_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
+
+	ret = request_irq(priv->irq0, bcm_sysport_rx_isr, 0, dev->name, dev);
+	if (ret) {
+		netdev_err(dev, "failed to request RX interrupt\n");
+		goto out_phy_disconnect;
+	}
+
+	ret = request_irq(priv->irq1, bcm_sysport_tx_isr, 0, dev->name, dev);
+	if (ret) {
+		netdev_err(dev, "failed to request TX interrupt\n");
+		goto out_free_irq0;
+	}
+
+	/* Initialize both hardware and software ring */
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		ret = bcm_sysport_init_tx_ring(priv, i);
+		if (ret) {
+			netdev_err(dev, "failed to initialize TX ring %d\n",
+					i);
+			goto out_free_tx_ring;
+		}
+	}
+
+	/* Initialize linked-list */
+	tdma_writel(priv, TDMA_LL_RAM_INIT_BUSY, TDMA_STATUS);
+
+	/* Initialize RX ring */
+	ret = bcm_sysport_init_rx_ring(priv);
+	if (ret) {
+		netdev_err(dev, "failed to initialize RX ring\n");
+		goto out_free_rx_ring;
+	}
+
+	/* Turn on RDMA */
+	ret = rdma_enable_set(priv, 1);
+	if (ret)
+		goto out_free_rx_ring;
+
+	/* Enable RX interrupt and TX ring full interrupt */
+	intrl2_0_mask_clear(priv, INTRL2_0_RDMA_MBDONE | INTRL2_0_TX_RING_FULL);
+
+	/* Turn on TDMA */
+	ret = tdma_enable_set(priv, 1);
+	if (ret)
+		goto out_clear_rx_int;
+
+	/* Enable NAPI */
+	napi_enable(&priv->napi);
+
+	/* Turn on UniMAC TX/RX */
+	umac_enable_set(priv, 1);
+
+	phy_start(priv->phydev);
+
+	/* Enable TX interrupts for the 32 TXQs */
+	intrl2_1_mask_clear(priv, 0xffffffff);
+
+	/* Last call before we start the real business */
+	netif_tx_start_all_queues(dev);
+
+	return 0;
+
+out_clear_rx_int:
+	intrl2_0_mask_set(priv, INTRL2_0_RDMA_MBDONE | INTRL2_0_TX_RING_FULL);
+out_free_rx_ring:
+	bcm_sysport_fini_rx_ring(priv);
+out_free_tx_ring:
+	for (i = 0; i < dev->num_tx_queues; i++)
+		bcm_sysport_fini_tx_ring(priv, i);
+	free_irq(priv->irq1, dev);
+out_free_irq0:
+	free_irq(priv->irq0, dev);
+out_phy_disconnect:
+	phy_disconnect(priv->phydev);
+	return ret;
+}
+
+static int bcm_sysport_stop(struct net_device *dev)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	unsigned int i;
+	u32 reg;
+	int ret;
+
+	/* stop all software from updating hardware */
+	netif_tx_stop_all_queues(dev);
+	napi_disable(&priv->napi);
+	phy_stop(priv->phydev);
+
+	/* mask all interrupts */
+	intrl2_0_mask_set(priv, 0xffffffff);
+	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
+	intrl2_1_mask_set(priv, 0xffffffff);
+	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
+
+	/* Disable UniMAC RX */
+	reg = umac_readl(priv, UMAC_CMD);
+	reg &= ~CMD_RX_EN;
+	umac_writel(priv, reg, UMAC_CMD);
+
+	ret = tdma_enable_set(priv, 0);
+	if (ret) {
+		netdev_err(dev, "timeout disabling RDMA\n");
+		return ret;
+	}
+
+	/* Wait for a maximum packet size to be drained */
+	usleep_range(2000, 3000);
+
+	ret = rdma_enable_set(priv, 0);
+	if (ret) {
+		netdev_err(dev, "timeout disabling TDMA\n");
+		return ret;
+	}
+
+	/* Disable UniMAC TX */
+	reg = umac_readl(priv, UMAC_CMD);
+	reg &= ~CMD_TX_EN;
+	umac_writel(priv, reg, UMAC_CMD);
+
+	/* Free RX/TX rings SW structures */
+	for (i = 0; i < dev->num_tx_queues; i++)
+		bcm_sysport_fini_tx_ring(priv, i);
+	bcm_sysport_fini_rx_ring(priv);
+
+	free_irq(priv->irq0, dev);
+	free_irq(priv->irq1, dev);
+
+	/* Disconnect from PHY */
+	phy_disconnect(priv->phydev);
+
+	return 0;
+}
+
+static struct ethtool_ops bcm_sysport_ethtool_ops = {
+	.get_settings		= bcm_sysport_get_settings,
+	.set_settings		= bcm_sysport_set_settings,
+	.get_drvinfo		= bcm_sysport_get_drvinfo,
+	.get_msglevel		= bcm_sysport_get_msglvl,
+	.set_msglevel		= bcm_sysport_set_msglvl,
+	.get_link		= ethtool_op_get_link,
+	.get_strings		= bcm_sysport_get_strings,
+	.get_ethtool_stats	= bcm_sysport_get_stats,
+	.get_sset_count		= bcm_sysport_get_sset_count,
+};
+
+static const struct net_device_ops bcm_sysport_netdev_ops = {
+	.ndo_start_xmit		= bcm_sysport_xmit,
+	.ndo_tx_timeout		= bcm_sysport_tx_timeout,
+	.ndo_open		= bcm_sysport_open,
+	.ndo_stop		= bcm_sysport_stop,
+	.ndo_set_features	= bcm_sysport_set_features,
+	.ndo_set_rx_mode	= bcm_sysport_set_rx_mode,
+};
+
+#define REV_FMT	"v%2x.%02x"
+
+static int bcm_sysport_probe(struct platform_device *pdev)
+{
+	struct bcm_sysport_priv *priv;
+	struct device_node *dn;
+	struct net_device *dev;
+	const void *macaddr;
+	struct resource *r;
+	u32 txq, rxq;
+	int ret;
+
+	dn = pdev->dev.of_node;
+	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+
+	/* Read the Transmit/Receive Queue properties */
+	if (of_property_read_u32(dn, "systemport,num-txq", &txq))
+		txq = TDMA_NUM_RINGS;
+	if (of_property_read_u32(dn, "systemport,num-rxq", &rxq))
+		rxq = 1;
+
+	dev = alloc_etherdev_mqs(sizeof(*priv), txq, rxq);
+	if (!dev)
+		return -ENOMEM;
+
+	/* Initialize private members */
+	priv = netdev_priv(dev);
+
+	priv->irq0 = platform_get_irq(pdev, 0);
+	priv->irq1 = platform_get_irq(pdev, 1);
+	if (priv->irq0 <= 0 || priv->irq1 <= 0) {
+		dev_err(&pdev->dev, "invalid interrupts\n");
+		ret = -EINVAL;
+		goto err;
+	}
+
+	priv->base = devm_request_and_ioremap(&pdev->dev, r);
+	if (!priv->base) {
+		dev_err(&pdev->dev, "register remap failed\n");
+		ret = -ENOMEM;
+		goto err;
+	}
+
+	priv->netdev = dev;
+	priv->pdev = pdev;
+
+	priv->phy_interface = of_get_phy_mode(dn);
+	/* Default to GMII interface mode */
+	if (priv->phy_interface < 0)
+		priv->phy_interface = PHY_INTERFACE_MODE_GMII;
+
+	/* Initialize netdevice members */
+	macaddr = of_get_mac_address(dn);
+	if (!macaddr || !is_valid_ether_addr(macaddr)) {
+		dev_warn(&pdev->dev, "using random Ethernet MAC\n");
+		random_ether_addr(dev->dev_addr);
+	} else {
+		ether_addr_copy(dev->dev_addr, macaddr);
+	}
+
+	SET_NETDEV_DEV(dev, &pdev->dev);
+	dev_set_drvdata(&pdev->dev, dev);
+	SET_ETHTOOL_OPS(dev, &bcm_sysport_ethtool_ops);
+	dev->netdev_ops = &bcm_sysport_netdev_ops;
+	netif_napi_add(dev, &priv->napi, bcm_sysport_poll, 64);
+
+	/* HW supported features, none enabled by default */
+	dev->hw_features |= NETIF_F_RXCSUM | NETIF_F_HIGHDMA |
+				NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+
+	/* Set the needed headroom once and for all */
+	BUILD_BUG_ON(sizeof(struct tsb) != 8);
+	dev->needed_headroom += sizeof(struct tsb);
+
+	/* We are interfaced to a switch which handles the multicast
+	 * filtering for us, so we do not support programming any
+	 * multicast hash table in this Ethernet MAC.
+	 */
+	dev->flags &= ~IFF_MULTICAST;
+
+	ret = register_netdev(dev);
+	if (ret) {
+		dev_err(&pdev->dev, "failed to register net_device\n");
+		goto err;
+	}
+
+	priv->rev = topctrl_readl(priv, REV_CNTL) & REV_MASK;
+	dev_info(&pdev->dev,
+		"Broadcom SYSTEMPORT" REV_FMT
+		" at 0x%p (irqs: %d, %d, TXQs: %d, RXQs: %d)\n",
+		(priv->rev >> 8) & 0xff, priv->rev & 0xff,
+		priv->base, priv->irq0, priv->irq1, txq, rxq);
+
+	return 0;
+err:
+	free_netdev(dev);
+	return ret;
+}
+
+static int bcm_sysport_remove(struct platform_device *pdev)
+{
+	struct net_device *dev = dev_get_drvdata(&pdev->dev);
+
+	/* Not much to do, ndo_close has been called
+	 * and we use managed allocations
+	 */
+	unregister_netdev(dev);
+	free_netdev(dev);
+	dev_set_drvdata(&pdev->dev, NULL);
+
+	return 0;
+}
+
+static const struct of_device_id bcm_sysport_of_match[] = {
+	{ .compatible = "brcm,systemport-v1.00" },
+	{ .compatible = "brcm,systemport" },
+	{ /* sentinel */ }
+};
+
+static struct platform_driver bcm_sysport_driver = {
+	.probe	= bcm_sysport_probe,
+	.remove	= bcm_sysport_remove,
+	.driver =  {
+		.name = "brcm-systemport",
+		.owner = THIS_MODULE,
+		.of_match_table = bcm_sysport_of_match,
+	},
+};
+module_platform_driver(bcm_sysport_driver);
+
+MODULE_AUTHOR("Broadcom Corporation");
+MODULE_DESCRIPTION("Broadcom System Port Ethernet MAC driver");
+MODULE_ALIAS("platform:brcm-systemport");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
new file mode 100644
index 000000000000..a0441e7c83cd
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -0,0 +1,677 @@
+/*
+ * Broadcom BCM7xxx System Port Ethernet MAC driver
+ *
+ * Copyright (C) 2014 Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef __BCM_SYSPORT_H
+#define __BCM_SYSPORT_H
+
+#include <linux/if_vlan.h>
+
+/* Receive/transmit descriptor format */
+#define DESC_ADDR_HI_STATUS_LEN	0x00
+#define  DESC_ADDR_HI_SHIFT	0
+#define  DESC_ADDR_HI_MASK	0xff
+#define  DESC_STATUS_SHIFT	8
+#define  DESC_STATUS_MASK	0x3ff
+#define  DESC_LEN_SHIFT		18
+#define  DESC_LEN_MASK		0x7fff
+#define DESC_ADDR_LO		0x04
+
+/* HW supports 40-bit addressing hence the */
+#define DESC_SIZE		(WORDS_PER_DESC * sizeof(u32))
+
+/* Default RX buffer allocation size */
+#define RX_BUF_LENGTH		2048
+
+/* Body(1500) + EH_SIZE(14) + VLANTAG(4) + BRCMTAG(6) + FCS(4) = 1528.
+ * 1536 is multiple of 256 bytes
+ */
+#define ENET_BRCM_TAG_LEN	6
+#define ENET_PAD		8
+#define UMAC_MAX_MTU_SIZE	(ETH_DATA_LEN + ETH_HLEN + VLAN_HLEN + \
+				 ENET_BRCM_TAG_LEN + ETH_FCS_LEN + ENET_PAD)
+
+/* Transmit status block */
+struct tsb {
+	u32 pcp_dei_vid;
+#define PCP_DEI_MASK		0xf
+#define VID_SHIFT		4
+#define VID_MASK		0xfff
+	u32 l4_ptr_dest_map;
+#define L4_CSUM_PTR_MASK	0x1ff
+#define L4_PTR_SHIFT		9
+#define L4_PTR_MASK		0x1ff
+#define L4_UDP			(1 << 18)
+#define L4_LENGTH_VALID		(1 << 19)
+#define DEST_MAP_SHIFT		20
+#define DEST_MAP_MASK		0x1ff
+};
+
+/* Receive status block uses the same
+ * definitions as the DMA descriptor
+ */
+struct rsb {
+	u32 rx_status_len;
+	u32 brcm_egress_tag;
+};
+
+/* Common Receive/Transmit status bits */
+#define DESC_L4_CSUM		(1 << 7)
+#define DESC_SOP		(1 << 8)
+#define DESC_EOP		(1 << 9)
+
+/* Receive Status bits */
+#define RX_STATUS_UCAST			0
+#define RX_STATUS_BCAST			0x04
+#define RX_STATUS_MCAST			0x08
+#define RX_STATUS_L2_MCAST		0x0c
+#define RX_STATUS_ERR			(1 << 4)
+#define RX_STATUS_OVFLOW		(1 << 5)
+#define RX_STATUS_PARSE_FAIL		(1 << 6)
+
+/* Transmit Status bits */
+#define TX_STATUS_VLAN_NO_ACT		0x00
+#define TX_STATUS_VLAN_PCP_TSB		0x01
+#define TX_STATUS_VLAN_QUEUE		0x02
+#define TX_STATUS_VLAN_VID_TSB		0x03
+#define TX_STATUS_OWR_CRC		(1 << 2)
+#define TX_STATUS_APP_CRC		(1 << 3)
+#define TX_STATUS_BRCM_TAG_NO_ACT	0
+#define TX_STATUS_BRCM_TAG_ZERO		0x10
+#define TX_STATUS_BRCM_TAG_ONE_QUEUE	0x20
+#define TX_STATUS_BRCM_TAG_ONE_TSB	0x30
+#define TX_STATUS_SKIP_BYTES		(1 << 6)
+
+/* Specific register definitions */
+#define SYS_PORT_TOPCTRL_OFFSET		0
+#define REV_CNTL			0x00
+#define  REV_MASK			0xffff
+
+#define RX_FLUSH_CNTL			0x04
+#define  RX_FLUSH			(1 << 0)
+
+#define TX_FLUSH_CNTL			0x08
+#define  TX_FLUSH			(1 << 0)
+
+#define MISC_CNTL			0x0c
+#define  SYS_CLK_SEL			(1 << 0)
+#define  TDMA_EOP_SEL			(1 << 1)
+
+/* Level-2 Interrupt controller offsets and defines */
+#define SYS_PORT_INTRL2_0_OFFSET	0x200
+#define SYS_PORT_INTRL2_1_OFFSET	0x240
+#define INTRL2_CPU_STATUS		0x00
+#define INTRL2_CPU_SET			0x04
+#define INTRL2_CPU_CLEAR		0x08
+#define INTRL2_CPU_MASK_STATUS		0x0c
+#define INTRL2_CPU_MASK_SET		0x10
+#define INTRL2_CPU_MASK_CLEAR		0x14
+
+/* Level-2 instance 0 interrupt bits */
+#define INTRL2_0_GISB_ERR		(1 << 0)
+#define INTRL2_0_RBUF_OVFLOW		(1 << 1)
+#define INTRL2_0_TBUF_UNDFLOW		(1 << 2)
+#define INTRL2_0_MPD			(1 << 3)
+#define INTRL2_0_BRCM_MATCH_TAG		(1 << 4)
+#define INTRL2_0_RDMA_MBDONE		(1 << 5)
+#define INTRL2_0_OVER_MAX_THRESH	(1 << 6)
+#define INTRL2_0_BELOW_HYST_THRESH	(1 << 7)
+#define INTRL2_0_FREE_LIST_EMPTY	(1 << 8)
+#define INTRL2_0_TX_RING_FULL		(1 << 9)
+#define INTRL2_0_DESC_ALLOC_ERR		(1 << 10)
+#define INTRL2_0_UNEXP_PKTSIZE_ACK	(1 << 11)
+
+/* RXCHK offset and defines */
+#define SYS_PORT_RXCHK_OFFSET		0x300
+
+#define RXCHK_CONTROL			0x00
+#define  RXCHK_EN			(1 << 0)
+#define  RXCHK_SKIP_FCS			(1 << 1)
+#define  RXCHK_BAD_CSUM_DIS		(1 << 2)
+#define  RXCHK_BRCM_TAG_EN		(1 << 3)
+#define  RXCHK_BRCM_TAG_MATCH_SHIFT	4
+#define  RXCHK_BRCM_TAG_MATCH_MASK	0xff
+#define  RXCHK_PARSE_TNL		(1 << 12)
+#define  RXCHK_VIOL_EN			(1 << 13)
+#define  RXCHK_VIOL_DIS			(1 << 14)
+#define  RXCHK_INCOM_PKT		(1 << 15)
+#define  RXCHK_V6_DUPEXT_EN		(1 << 16)
+#define  RXCHK_V6_DUPEXT_DIS		(1 << 17)
+#define  RXCHK_ETHERTYPE_DIS		(1 << 18)
+#define  RXCHK_L2_HDR_DIS		(1 << 19)
+#define  RXCHK_L3_HDR_DIS		(1 << 20)
+#define  RXCHK_MAC_RX_ERR_DIS		(1 << 21)
+#define  RXCHK_PARSE_AUTH		(1 << 22)
+
+#define RXCHK_BRCM_TAG0			0x04
+#define RXCHK_BRCM_TAG(i)		((i) * RXCHK_BRCM_TAG0)
+#define RXCHK_BRCM_TAG0_MASK		0x24
+#define RXCHK_BRCM_TAG_MASK(i)		((i) * RXCHK_BRCM_TAG0_MASK)
+#define RXCHK_BRCM_TAG_MATCH_STATUS	0x44
+#define RXCHK_ETHERTYPE			0x48
+#define RXCHK_BAD_CSUM_CNTR		0x4C
+#define RXCHK_OTHER_DISC_CNTR		0x50
+
+/* TXCHCK offsets and defines */
+#define SYS_PORT_TXCHK_OFFSET		0x380
+#define TXCHK_PKT_RDY_THRESH		0x00
+
+/* Receive buffer offset and defines */
+#define SYS_PORT_RBUF_OFFSET		0x400
+
+#define RBUF_CONTROL			0x00
+#define  RBUF_RSB_EN			(1 << 0)
+#define  RBUF_4B_ALGN			(1 << 1)
+#define  RBUF_BRCM_TAG_STRIP		(1 << 2)
+#define  RBUF_BAD_PKT_DISC		(1 << 3)
+#define  RBUF_RESUME_THRESH_SHIFT	4
+#define  RBUF_RESUME_THRESH_MASK	0xff
+#define  RBUF_OK_TO_SEND_SHIFT		12
+#define  RBUF_OK_TO_SEND_MASK		0xff
+#define  RBUF_CRC_REPLACE		(1 << 20)
+#define  RBUF_OK_TO_SEND_MODE		(1 << 21)
+#define  RBUF_RSB_SWAP			(1 << 22)
+#define  RBUF_ACPI_EN			(1 << 23)
+
+#define RBUF_PKT_RDY_THRESH		0x04
+
+#define RBUF_STATUS			0x08
+#define  RBUF_WOL_MODE			(1 << 0)
+#define  RBUF_MPD			(1 << 1)
+#define  RBUF_ACPI			(1 << 2)
+
+#define RBUF_OVFL_DISC_CNTR		0x0c
+#define RBUF_ERR_PKT_CNTR		0x10
+
+/* Transmit buffer offset and defines */
+#define SYS_PORT_TBUF_OFFSET		0x600
+
+#define TBUF_CONTROL			0x00
+#define  TBUF_BP_EN			(1 << 0)
+#define  TBUF_MAX_PKT_THRESH_SHIFT	1
+#define  TBUF_MAX_PKT_THRESH_MASK	0x1f
+#define  TBUF_FULL_THRESH_SHIFT		8
+#define  TBUF_FULL_THRESH_MASK		0x1f
+
+/* UniMAC offset and defines */
+#define SYS_PORT_UMAC_OFFSET		0x800
+
+#define UMAC_CMD			0x008
+#define  CMD_TX_EN			(1 << 0)
+#define  CMD_RX_EN			(1 << 1)
+#define  CMD_SPEED_SHIFT		2
+#define  CMD_SPEED_10			0
+#define  CMD_SPEED_100			1
+#define  CMD_SPEED_1000			2
+#define  CMD_SPEED_2500			3
+#define  CMD_SPEED_MASK			3
+#define  CMD_PROMISC			(1 << 4)
+#define  CMD_PAD_EN			(1 << 5)
+#define  CMD_CRC_FWD			(1 << 6)
+#define  CMD_PAUSE_FWD			(1 << 7)
+#define  CMD_RX_PAUSE_IGNORE		(1 << 8)
+#define  CMD_TX_ADDR_INS		(1 << 9)
+#define  CMD_HD_EN			(1 << 10)
+#define  CMD_SW_RESET			(1 << 13)
+#define  CMD_LCL_LOOP_EN		(1 << 15)
+#define  CMD_AUTO_CONFIG		(1 << 22)
+#define  CMD_CNTL_FRM_EN		(1 << 23)
+#define  CMD_NO_LEN_CHK			(1 << 24)
+#define  CMD_RMT_LOOP_EN		(1 << 25)
+#define  CMD_PRBL_EN			(1 << 27)
+#define  CMD_TX_PAUSE_IGNORE		(1 << 28)
+#define  CMD_TX_RX_EN			(1 << 29)
+#define  CMD_RUNT_FILTER_DIS		(1 << 30)
+
+#define UMAC_MAC0			0x00c
+#define UMAC_MAC1			0x010
+#define UMAC_MAX_FRAME_LEN		0x014
+
+#define UMAC_TX_FLUSH			0x334
+
+#define UMAC_MIB_START			0x400
+
+/* There is a 0xC gap between the end of RX and beginning of TX stats and then
+ * between the end of TX stats and the beginning of the RX RUNT
+ */
+#define UMAC_MIB_STAT_OFFSET		0xc
+
+#define UMAC_MIB_CTRL			0x580
+#define  MIB_RX_CNT_RST			(1 << 0)
+#define  MIB_RUNT_CNT_RST		(1 << 1)
+#define  MIB_TX_CNT_RST			(1 << 2)
+#define UMAC_MDF_CTRL			0x650
+#define UMAC_MDF_ADDR			0x654
+
+/* Receive DMA offset and defines */
+#define SYS_PORT_RDMA_OFFSET		0x2000
+
+#define RDMA_CONTROL			0x1000
+#define  RDMA_EN			(1 << 0)
+#define  RDMA_RING_CFG			(1 << 1)
+#define  RDMA_DISC_EN			(1 << 2)
+#define  RDMA_BUF_DATA_OFFSET_SHIFT	4
+#define  RDMA_BUF_DATA_OFFSET_MASK	0x3ff
+
+#define RDMA_STATUS			0x1004
+#define  RDMA_DISABLED			(1 << 0)
+#define  RDMA_DESC_RAM_INIT_BUSY	(1 << 1)
+#define  RDMA_BP_STATUS			(1 << 2)
+
+#define RDMA_SCB_BURST_SIZE		0x1008
+
+#define RDMA_RING_BUF_SIZE		0x100c
+#define  RDMA_RING_SIZE_SHIFT		16
+
+#define RDMA_WRITE_PTR_HI		0x1010
+#define RDMA_WRITE_PTR_LO		0x1014
+#define RDMA_PROD_INDEX			0x1018
+#define  RDMA_PROD_INDEX_MASK		0xffff
+
+#define RDMA_CONS_INDEX			0x101c
+#define  RDMA_CONS_INDEX_MASK		0xffff
+
+#define RDMA_START_ADDR_HI		0x1020
+#define RDMA_START_ADDR_LO		0x1024
+#define RDMA_END_ADDR_HI		0x1028
+#define RDMA_END_ADDR_LO		0x102c
+
+#define RDMA_MBDONE_INTR		0x1030
+#define  RDMA_INTR_THRESH_MASK		0xff
+#define  RDMA_TIMEOUT_SHIFT		16
+#define  RDMA_TIMEOUT_MASK		0xffff
+
+#define RDMA_XON_XOFF_THRESH		0x1034
+#define  RDMA_XON_XOFF_THRESH_MASK	0xffff
+#define  RDMA_XOFF_THRESH_SHIFT		16
+
+#define RDMA_READ_PTR_HI		0x1038
+#define RDMA_READ_PTR_LO		0x103c
+
+#define RDMA_OVERRIDE			0x1040
+#define  RDMA_LE_MODE			(1 << 0)
+#define  RDMA_REG_MODE			(1 << 1)
+
+#define RDMA_TEST			0x1044
+#define  RDMA_TP_OUT_SEL		(1 << 0)
+#define  RDMA_MEM_SEL			(1 << 1)
+
+#define RDMA_DEBUG			0x1048
+
+/* Transmit DMA offset and defines */
+#define TDMA_NUM_RINGS			32	/* rings = queues */
+#define TDMA_PORT_SIZE			DESC_SIZE /* two 32-bits words */
+
+#define SYS_PORT_TDMA_OFFSET		0x4000
+#define TDMA_WRITE_PORT_OFFSET		0x0000
+#define TDMA_WRITE_PORT_HI(i)		(TDMA_WRITE_PORT_OFFSET + \
+					(i) * TDMA_PORT_SIZE)
+#define TDMA_WRITE_PORT_LO(i)		(TDMA_WRITE_PORT_OFFSET + \
+					sizeof(u32) + (i) * TDMA_PORT_SIZE)
+
+#define TDMA_READ_PORT_OFFSET		(TDMA_WRITE_PORT_OFFSET + \
+					(TDMA_NUM_RINGS * TDMA_PORT_SIZE))
+#define TDMA_READ_PORT_HI(i)		(TDMA_READ_PORT_OFFSET + \
+					(i) * TDMA_PORT_SIZE)
+#define TDMA_READ_PORT_LO(i)		(TDMA_READ_PORT_OFFSET + \
+					sizeof(u32) + (i) * TDMA_PORT_SIZE)
+
+#define TDMA_READ_PORT_CMD_OFFSET	(TDMA_READ_PORT_OFFSET + \
+					(TDMA_NUM_RINGS * TDMA_PORT_SIZE))
+#define TDMA_READ_PORT_CMD(i)		(TDMA_READ_PORT_CMD_OFFSET + \
+					(i) * sizeof(u32))
+
+#define TDMA_DESC_RING_00_BASE		(TDMA_READ_PORT_CMD_OFFSET + \
+					(TDMA_NUM_RINGS * sizeof(u32)))
+
+/* Register offsets and defines relatives to a specific ring number */
+#define RING_HEAD_TAIL_PTR		0x00
+#define  RING_HEAD_MASK			0x7ff
+#define  RING_TAIL_SHIFT		11
+#define  RING_TAIL_MASK			0x7ff
+#define  RING_FLUSH			(1 << 24)
+#define  RING_EN			(1 << 25)
+
+#define RING_COUNT			0x04
+#define  RING_COUNT_MASK		0x7ff
+#define  RING_BUFF_DONE_SHIFT		11
+#define  RING_BUFF_DONE_MASK		0x7ff
+
+#define RING_MAX_HYST			0x08
+#define  RING_MAX_THRESH_MASK		0x7ff
+#define  RING_HYST_THRESH_SHIFT		11
+#define  RING_HYST_THRESH_MASK		0x7ff
+
+#define RING_INTR_CONTROL		0x0c
+#define  RING_INTR_THRESH_MASK		0x7ff
+#define  RING_EMPTY_INTR_EN		(1 << 15)
+#define  RING_TIMEOUT_SHIFT		16
+#define  RING_TIMEOUT_MASK		0xffff
+
+#define RING_PROD_CONS_INDEX		0x10
+#define  RING_PROD_INDEX_MASK		0xffff
+#define  RING_CONS_INDEX_SHIFT		16
+#define  RING_CONS_INDEX_MASK		0xffff
+
+#define RING_MAPPING			0x14
+#define  RING_QID_MASK			0x3
+#define  RING_PORT_ID_SHIFT		3
+#define  RING_PORT_ID_MASK		0x7
+#define  RING_IGNORE_STATUS		(1 << 6)
+#define  RING_FAILOVER_EN		(1 << 7)
+#define  RING_CREDIT_SHIFT		8
+#define  RING_CREDIT_MASK		0xffff
+
+#define RING_PCP_DEI_VID		0x18
+#define  RING_VID_MASK			0x7ff
+#define  RING_DEI			(1 << 12)
+#define  RING_PCP_SHIFT			13
+#define  RING_PCP_MASK			0x7
+#define  RING_PKT_SIZE_ADJ_SHIFT	16
+#define  RING_PKT_SIZE_ADJ_MASK		0xf
+
+#define TDMA_DESC_RING_SIZE		28
+
+/* Defininition for a given TX ring base address */
+#define TDMA_DESC_RING_BASE(i)		(TDMA_DESC_RING_00_BASE + \
+					((i) * TDMA_DESC_RING_SIZE))
+
+/* Ring indexed register addreses */
+#define TDMA_DESC_RING_HEAD_TAIL_PTR(i)	(TDMA_DESC_RING_BASE(i) + \
+					RING_HEAD_TAIL_PTR)
+#define TDMA_DESC_RING_COUNT(i)		(TDMA_DESC_RING_BASE(i) + \
+					RING_COUNT)
+#define TDMA_DESC_RING_MAX_HYST(i)	(TDMA_DESC_RING_BASE(i) + \
+					RING_MAX_HYST)
+#define TDMA_DESC_RING_INTR_CONTROL(i)	(TDMA_DESC_RING_BASE(i) + \
+					RING_INTR_CONTROL)
+#define TDMA_DESC_RING_PROD_CONS_INDEX(i) \
+					(TDMA_DESC_RING_BASE(i) + \
+					RING_PROD_CONS_INDEX)
+#define TDMA_DESC_RING_MAPPING(i)	(TDMA_DESC_RING_BASE(i) + \
+					RING_MAPPING)
+#define TDMA_DESC_RING_PCP_DEI_VID(i)	(TDMA_DESC_RING_BASE(i) + \
+					RING_PCP_DEI_VID)
+
+#define TDMA_CONTROL			0x600
+#define  TDMA_EN			(1 << 0)
+#define  TSB_EN				(1 << 1)
+#define  TSB_SWAP			(1 << 2)
+#define  ACB_ALGO			(1 << 3)
+#define  BUF_DATA_OFFSET_SHIFT		4
+#define  BUF_DATA_OFFSET_MASK		0x3ff
+#define  VLAN_EN			(1 << 14)
+#define  SW_BRCM_TAG			(1 << 15)
+#define  WNC_KPT_SIZE_UPDATE		(1 << 16)
+#define  SYNC_PKT_SIZE			(1 << 17)
+#define  ACH_TXDONE_DELAY_SHIFT		18
+#define  ACH_TXDONE_DELAY_MASK		0xff
+
+#define TDMA_STATUS			0x604
+#define  TDMA_DISABLED			(1 << 0)
+#define  TDMA_LL_RAM_INIT_BUSY		(1 << 1)
+
+#define TDMA_SCB_BURST_SIZE		0x608
+#define TDMA_OVER_MAX_THRESH_STATUS	0x60c
+#define TDMA_OVER_HYST_THRESH_STATUS	0x610
+#define TDMA_TPID			0x614
+
+#define TDMA_FREE_LIST_HEAD_TAIL_PTR	0x618
+#define  TDMA_FREE_HEAD_MASK		0x7ff
+#define  TDMA_FREE_TAIL_SHIFT		11
+#define  TDMA_FREE_TAIL_MASK		0x7ff
+
+#define TDMA_FREE_LIST_COUNT		0x61c
+#define  TDMA_FREE_LIST_COUNT_MASK	0x7ff
+
+#define TDMA_TIER2_ARB_CTRL		0x620
+#define  TDMA_ARB_MODE_RR		0
+#define  TDMA_ARB_MODE_WEIGHT_RR	0x1
+#define  TDMA_ARB_MODE_STRICT		0x2
+#define  TDMA_ARB_MODE_DEFICIT_RR	0x3
+#define  TDMA_CREDIT_SHIFT		4
+#define  TDMA_CREDIT_MASK		0xffff
+
+#define TDMA_TIER1_ARB_0_CTRL		0x624
+#define  TDMA_ARB_EN			(1 << 0)
+
+#define TDMA_TIER1_ARB_0_QUEUE_EN	0x628
+#define TDMA_TIER1_ARB_1_CTRL		0x62c
+#define TDMA_TIER1_ARB_1_QUEUE_EN	0x630
+#define TDMA_TIER1_ARB_2_CTRL		0x634
+#define TDMA_TIER1_ARB_2_QUEUE_EN	0x638
+#define TDMA_TIER1_ARB_3_CTRL		0x63c
+#define TDMA_TIER1_ARB_3_QUEUE_EN	0x640
+
+#define TDMA_SCB_ENDIAN_OVERRIDE	0x644
+#define  TDMA_LE_MODE			(1 << 0)
+#define  TDMA_REG_MODE			(1 << 1)
+
+#define TDMA_TEST			0x648
+#define  TDMA_TP_OUT_SEL		(1 << 0)
+#define  TDMA_MEM_TM			(1 << 1)
+
+#define TDMA_DEBUG			0x64c
+
+/* Transmit/Receive descriptor */
+struct dma_desc {
+	u32	addr_status_len;
+	u32	addr_lo;
+};
+
+/* Number of Receive hardware descriptor words */
+#define NUM_HW_RX_DESC_WORDS		1024
+/* Real number of usable descriptors */
+#define NUM_RX_DESC			(NUM_HW_RX_DESC_WORDS / WORDS_PER_DESC)
+
+/* Internal linked-list RAM has up to 1536 entries */
+#define NUM_TX_DESC			1536
+
+#define WORDS_PER_DESC			(sizeof(struct dma_desc) / sizeof(u32))
+
+/* Rx/Tx common counter group.*/
+struct bcm_sysport_pkt_counters {
+	u32	cnt_64;		/* RO Received/Transmited 64 bytes packet */
+	u32	cnt_127;	/* RO Rx/Tx 127 bytes packet */
+	u32	cnt_255;	/* RO Rx/Tx 65-255 bytes packet */
+	u32	cnt_511;	/* RO Rx/Tx 256-511 bytes packet */
+	u32	cnt_1023;	/* RO Rx/Tx 512-1023 bytes packet */
+	u32	cnt_1518;	/* RO Rx/Tx 1024-1518 bytes packet */
+	u32	cnt_mgv;	/* RO Rx/Tx 1519-1522 good VLAN packet */
+	u32	cnt_2047;	/* RO Rx/Tx 1522-2047 bytes packet*/
+	u32	cnt_4095;	/* RO Rx/Tx 2048-4095 bytes packet*/
+	u32	cnt_9216;	/* RO Rx/Tx 4096-9216 bytes packet*/
+};
+
+/* RSV, Receive Status Vector */
+struct bcm_sysport_rx_counters {
+	struct  bcm_sysport_pkt_counters pkt_cnt;
+	u32	pkt;		/* RO (0x428) Received pkt count*/
+	u32	bytes;		/* RO Received byte count */
+	u32	mca;		/* RO # of Received multicast pkt */
+	u32	bca;		/* RO # of Receive broadcast pkt */
+	u32	fcs;		/* RO # of Received FCS error  */
+	u32	cf;		/* RO # of Received control frame pkt*/
+	u32	pf;		/* RO # of Received pause frame pkt */
+	u32	uo;		/* RO # of unknown op code pkt */
+	u32	aln;		/* RO # of alignment error count */
+	u32	flr;		/* RO # of frame length out of range count */
+	u32	cde;		/* RO # of code error pkt */
+	u32	fcr;		/* RO # of carrier sense error pkt */
+	u32	ovr;		/* RO # of oversize pkt*/
+	u32	jbr;		/* RO # of jabber count */
+	u32	mtue;		/* RO # of MTU error pkt*/
+	u32	pok;		/* RO # of Received good pkt */
+	u32	uc;		/* RO # of unicast pkt */
+	u32	ppp;		/* RO # of PPP pkt */
+	u32	rcrc;		/* RO (0x470),# of CRC match pkt */
+};
+
+/* TSV, Transmit Status Vector */
+struct bcm_sysport_tx_counters {
+	struct bcm_sysport_pkt_counters pkt_cnt;
+	u32	pkts;		/* RO (0x4a8) Transmited pkt */
+	u32	mca;		/* RO # of xmited multicast pkt */
+	u32	bca;		/* RO # of xmited broadcast pkt */
+	u32	pf;		/* RO # of xmited pause frame count */
+	u32	cf;		/* RO # of xmited control frame count */
+	u32	fcs;		/* RO # of xmited FCS error count */
+	u32	ovr;		/* RO # of xmited oversize pkt */
+	u32	drf;		/* RO # of xmited deferral pkt */
+	u32	edf;		/* RO # of xmited Excessive deferral pkt*/
+	u32	scl;		/* RO # of xmited single collision pkt */
+	u32	mcl;		/* RO # of xmited multiple collision pkt*/
+	u32	lcl;		/* RO # of xmited late collision pkt */
+	u32	ecl;		/* RO # of xmited excessive collision pkt*/
+	u32	frg;		/* RO # of xmited fragments pkt*/
+	u32	ncl;		/* RO # of xmited total collision count */
+	u32	jbr;		/* RO # of xmited jabber count*/
+	u32	bytes;		/* RO # of xmited byte count */
+	u32	pok;		/* RO # of xmited good pkt */
+	u32	uc;		/* RO (0x0x4f0)# of xmited unitcast pkt */
+};
+
+struct bcm_sysport_mib {
+	struct bcm_sysport_rx_counters rx;
+	struct bcm_sysport_tx_counters tx;
+	u32 rx_runt_cnt;
+	u32 rx_runt_fcs;
+	u32 rx_runt_fcs_align;
+	u32 rx_runt_bytes;
+	u32 rxchk_bad_csum;
+	u32 rxchk_other_pkt_disc;
+	u32 rbuf_ovflow_cnt;
+	u32 rbuf_err_cnt;
+};
+
+/* HW maintains a large list of counters */
+enum bcm_sysport_stat_type {
+	BCM_SYSPORT_STAT_NETDEV = -1,
+	BCM_SYSPORT_STAT_MIB_RX,
+	BCM_SYSPORT_STAT_MIB_TX,
+	BCM_SYSPORT_STAT_RUNT,
+	BCM_SYSPORT_STAT_RXCHK,
+	BCM_SYSPORT_STAT_RBUF,
+};
+
+/* Macros to help define ethtool statistics */
+#define STAT_NETDEV(m) { \
+	.stat_string = __stringify(m), \
+	.stat_sizeof = sizeof(((struct net_device_stats *)0)->m), \
+	.stat_offset = offsetof(struct net_device_stats, m), \
+	.type = BCM_SYSPORT_STAT_NETDEV, \
+}
+
+#define STAT_MIB(str, m, _type) { \
+	.stat_string = str, \
+	.stat_sizeof = sizeof(((struct bcm_sysport_priv *)0)->m), \
+	.stat_offset = offsetof(struct bcm_sysport_priv, m), \
+	.type = _type, \
+}
+
+#define STAT_MIB_RX(str, m) STAT_MIB(str, m, BCM_SYSPORT_STAT_MIB_RX)
+#define STAT_MIB_TX(str, m) STAT_MIB(str, m, BCM_SYSPORT_STAT_MIB_TX)
+#define STAT_RUNT(str, m) STAT_MIB(str, m, BCM_SYSPORT_STAT_RUNT)
+
+#define STAT_RXCHK(str, m, ofs) { \
+	.stat_string = str, \
+	.stat_sizeof = sizeof(((struct bcm_sysport_priv *)0)->m), \
+	.stat_offset = offsetof(struct bcm_sysport_priv, m), \
+	.type = BCM_SYSPORT_STAT_RXCHK, \
+	.reg_offset = ofs, \
+}
+
+#define STAT_RBUF(str, m, ofs) { \
+	.stat_string = str, \
+	.stat_sizeof = sizeof(((struct bcm_sysport_priv *)0)->m), \
+	.stat_offset = offsetof(struct bcm_sysport_priv, m), \
+	.type = BCM_SYSPORT_STAT_RBUF, \
+	.reg_offset = ofs, \
+}
+
+struct bcm_sysport_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	int stat_sizeof;
+	int stat_offset;
+	enum bcm_sysport_stat_type type;
+	/* reg offset from UMAC base for misc counters */
+	u16 reg_offset;
+};
+
+/* Software house keeping helper structure */
+struct bcm_sysport_cb {
+	struct sk_buff	*skb;		/* SKB for RX packets */
+	void __iomem	*bd_addr;	/* Buffer descriptor PHYS addr */
+
+	DEFINE_DMA_UNMAP_ADDR(dma_addr);
+	DEFINE_DMA_UNMAP_LEN(dma_len);
+};
+
+/* Software view of the TX ring */
+struct bcm_sysport_tx_ring {
+	spinlock_t	lock;		/* Ring lock for tx reclaim/xmit */
+	struct napi_struct napi;	/* NAPI per tx queue */
+	dma_addr_t	desc_dma;	/* DMA cookie */
+	unsigned int	index;		/* Ring index */
+	unsigned int	size;		/* Ring current size */
+	unsigned int	alloc_size;	/* Ring one-time allocated size */
+	unsigned int	desc_count;	/* Number of descriptors */
+	unsigned int	curr_desc;	/* Current descriptor */
+	unsigned int	c_index;	/* Last consumer index */
+	unsigned int	p_index;	/* Current producer index */
+	struct bcm_sysport_cb *cbs;	/* Transmit control blocks */
+	struct dma_desc	*desc_cpu;	/* CPU view of the descriptor */
+	struct bcm_sysport_priv *priv;	/* private context backpointer */
+};
+
+/* Driver private structure */
+struct bcm_sysport_priv {
+	void __iomem		*base;
+	u32			irq0_stat;
+	u32			irq0_mask;
+	u32			irq1_stat;
+	u32			irq1_mask;
+	struct napi_struct	napi ____cacheline_aligned;
+	struct net_device	*netdev;
+	struct platform_device	*pdev;
+	int			irq0;
+	int			irq1;
+
+	/* Transmit rings */
+	struct bcm_sysport_tx_ring tx_rings[TDMA_NUM_RINGS];
+
+	/* Receive queue */
+	void __iomem		*rx_bds;
+	void __iomem		*rx_bd_assign_ptr;
+	unsigned int		rx_bd_assign_index;
+	struct bcm_sysport_cb	*rx_cbs;
+	unsigned int		num_rx_bds;
+	unsigned int		rx_read_ptr;
+	unsigned int		rx_c_index;
+
+	/* PHY device */
+	struct phy_device	*phydev;
+	phy_interface_t		phy_interface;
+	int			old_pause;
+	int			old_link;
+	int			old_duplex;
+
+	/* Misc fields */
+	unsigned int		rx_csum_en:1;
+	unsigned int		tsb_en:1;
+	unsigned int		crc_fwd:1;
+	u16			rev;
+
+	/* MIB related fields */
+	struct bcm_sysport_mib	mib;
+
+	/* Ethtool */
+	u32			msg_enable;
+};
+#endif /* __BCM_SYSPORT_H */
-- 
1.9.1
