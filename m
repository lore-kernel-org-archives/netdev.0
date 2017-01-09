From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH] [v3] net: qcom/emac: add ethtool support
Date: Mon,  9 Jan 2017 12:03:12 -0600
Message-ID: <1483984992-21236-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, Alok Chauhan <alokc@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46188 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763466AbdAITeM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 14:34:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for some ethtool methods: get/set link settings, get/set
message level, get statistics, get link status, get ring params, get
pause params, and restart autonegotiation.

The code to collect the hardware statistics is moved into its own
function so that it can be used by "get statistics" method.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---

Notes:
    I don't trust my implementation of emac_get_pauseparam.  I feel like
    I'm missing something.
    
    v3: rebase onto latest net-next
    v2: added emac_get_pauseparam and emac_get_ringparam

 drivers/net/ethernet/qualcomm/emac/Makefile       |   2 +-
 drivers/net/ethernet/qualcomm/emac/emac-ethtool.c | 185 ++++++++++++++++++++++
 drivers/net/ethernet/qualcomm/emac/emac.c         |  52 +++---
 drivers/net/ethernet/qualcomm/emac/emac.h         |   3 +
 4 files changed, 221 insertions(+), 21 deletions(-)
 create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-ethtool.c

diff --git a/drivers/net/ethernet/qualcomm/emac/Makefile b/drivers/net/ethernet/qualcomm/emac/Makefile
index 7a66879..fc57ced 100644
--- a/drivers/net/ethernet/qualcomm/emac/Makefile
+++ b/drivers/net/ethernet/qualcomm/emac/Makefile
@@ -4,6 +4,6 @@
 
 obj-$(CONFIG_QCOM_EMAC) += qcom-emac.o
 
-qcom-emac-objs := emac.o emac-mac.o emac-phy.o emac-sgmii.o \
+qcom-emac-objs := emac.o emac-mac.o emac-phy.o emac-sgmii.o emac-ethtool.o \
 		  emac-sgmii-fsm9900.o emac-sgmii-qdf2432.o \
 		  emac-sgmii-qdf2400.o
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c b/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c
new file mode 100644
index 0000000..cfc57d2
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c
@@ -0,0 +1,185 @@
+/* Copyright (c) 2016, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include "emac.h"
+
+static const char * const emac_ethtool_stat_strings[] = {
+	"rx_ok",
+	"rx_bcast",
+	"rx_mcast",
+	"rx_pause",
+	"rx_ctrl",
+	"rx_fcs_err",
+	"rx_len_err",
+	"rx_byte_cnt",
+	"rx_runt",
+	"rx_frag",
+	"rx_sz_64",
+	"rx_sz_65_127",
+	"rx_sz_128_255",
+	"rx_sz_256_511",
+	"rx_sz_512_1023",
+	"rx_sz_1024_1518",
+	"rx_sz_1519_max",
+	"rx_sz_ov",
+	"rx_rxf_ov",
+	"rx_align_err",
+	"rx_bcast_byte_cnt",
+	"rx_mcast_byte_cnt",
+	"rx_err_addr",
+	"rx_crc_align",
+	"rx_jabbers",
+	"tx_ok",
+	"tx_bcast",
+	"tx_mcast",
+	"tx_pause",
+	"tx_exc_defer",
+	"tx_ctrl",
+	"tx_defer",
+	"tx_byte_cnt",
+	"tx_sz_64",
+	"tx_sz_65_127",
+	"tx_sz_128_255",
+	"tx_sz_256_511",
+	"tx_sz_512_1023",
+	"tx_sz_1024_1518",
+	"tx_sz_1519_max",
+	"tx_1_col",
+	"tx_2_col",
+	"tx_late_col",
+	"tx_abort_col",
+	"tx_underrun",
+	"tx_rd_eop",
+	"tx_len_err",
+	"tx_trunc",
+	"tx_bcast_byte",
+	"tx_mcast_byte",
+	"tx_col",
+};
+
+#define EMAC_STATS_LEN	ARRAY_SIZE(emac_ethtool_stat_strings)
+
+static u32 emac_get_msglevel(struct net_device *netdev)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+
+	return adpt->msg_enable;
+}
+
+static void emac_set_msglevel(struct net_device *netdev, u32 data)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+
+	adpt->msg_enable = data;
+}
+
+static int emac_get_sset_count(struct net_device *netdev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return EMAC_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void emac_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
+{
+	unsigned int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < EMAC_STATS_LEN; i++) {
+			strlcpy(data, emac_ethtool_stat_strings[i],
+				ETH_GSTRING_LEN);
+			data += ETH_GSTRING_LEN;
+		}
+		break;
+	}
+}
+
+static void emac_get_ethtool_stats(struct net_device *netdev,
+				   struct ethtool_stats *stats,
+				   u64 *data)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+
+	spin_lock(&adpt->stats.lock);
+
+	emac_update_hw_stats(adpt);
+	memcpy(data, &adpt->stats, EMAC_STATS_LEN * sizeof(u64));
+
+	spin_unlock(&adpt->stats.lock);
+}
+
+static int emac_nway_reset(struct net_device *netdev)
+{
+	struct phy_device *phydev = netdev->phydev;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return genphy_restart_aneg(phydev);
+}
+
+static void emac_get_ringparam(struct net_device *netdev,
+			       struct ethtool_ringparam *ring)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+
+	ring->rx_max_pending = EMAC_MAX_RX_DESCS;
+	ring->tx_max_pending = EMAC_MAX_TX_DESCS;
+	ring->rx_pending = adpt->rx_desc_cnt;
+	ring->tx_pending = adpt->tx_desc_cnt;
+}
+
+static void emac_get_pauseparam(struct net_device *netdev,
+				struct ethtool_pauseparam *pause)
+{
+	struct phy_device *phydev = netdev->phydev;
+
+	if (phydev) {
+		if (phydev->autoneg)
+			pause->autoneg = 1;
+		if (phydev->pause)
+			pause->rx_pause = 1;
+		if (phydev->pause != phydev->asym_pause)
+			pause->tx_pause = 1;
+	}
+}
+
+static const struct ethtool_ops emac_ethtool_ops = {
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
+
+	.get_msglevel    = emac_get_msglevel,
+	.set_msglevel    = emac_set_msglevel,
+
+	.get_sset_count  = emac_get_sset_count,
+	.get_strings = emac_get_strings,
+	.get_ethtool_stats = emac_get_ethtool_stats,
+
+	.get_ringparam = emac_get_ringparam,
+	.get_pauseparam = emac_get_pauseparam,
+
+	.nway_reset = emac_nway_reset,
+
+	.get_link = ethtool_op_get_link,
+};
+
+void emac_set_ethtool_ops(struct net_device *netdev)
+{
+	netdev->ethtool_ops = &emac_ethtool_ops;
+}
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index 40ebe01..6ffe192 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -311,45 +311,56 @@ static int emac_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	return phy_mii_ioctl(netdev->phydev, ifr, cmd);
 }
 
-/* Provide network statistics info for the interface */
-static void emac_get_stats64(struct net_device *netdev,
-			     struct rtnl_link_stats64 *net_stats)
+/**
+ * emac_update_hw_stats - read the EMAC stat registers
+ *
+ * Reads the stats registers and write the values to adpt->stats.
+ *
+ * adpt->stats.lock must be held while calling this function,
+ * and while reading from adpt->stats.
+ */
+void emac_update_hw_stats(struct emac_adapter *adpt)
 {
-	struct emac_adapter *adpt = netdev_priv(netdev);
-	unsigned int addr = REG_MAC_RX_STATUS_BIN;
 	struct emac_stats *stats = &adpt->stats;
 	u64 *stats_itr = &adpt->stats.rx_ok;
-	u32 val;
-
-	spin_lock(&stats->lock);
+	void __iomem *base = adpt->base;
+	unsigned int addr;
 
+	addr = REG_MAC_RX_STATUS_BIN;
 	while (addr <= REG_MAC_RX_STATUS_END) {
-		val = readl_relaxed(adpt->base + addr);
-		*stats_itr += val;
+		*stats_itr += readl_relaxed(base + addr);
 		stats_itr++;
 		addr += sizeof(u32);
 	}
 
 	/* additional rx status */
-	val = readl_relaxed(adpt->base + EMAC_RXMAC_STATC_REG23);
-	adpt->stats.rx_crc_align += val;
-	val = readl_relaxed(adpt->base + EMAC_RXMAC_STATC_REG24);
-	adpt->stats.rx_jabbers += val;
+	stats->rx_crc_align += readl_relaxed(base + EMAC_RXMAC_STATC_REG23);
+	stats->rx_jabbers += readl_relaxed(base + EMAC_RXMAC_STATC_REG24);
 
 	/* update tx status */
 	addr = REG_MAC_TX_STATUS_BIN;
-	stats_itr = &adpt->stats.tx_ok;
+	stats_itr = &stats->tx_ok;
 
 	while (addr <= REG_MAC_TX_STATUS_END) {
-		val = readl_relaxed(adpt->base + addr);
-		*stats_itr += val;
-		++stats_itr;
+		*stats_itr += readl_relaxed(base + addr);
+		stats_itr++;
 		addr += sizeof(u32);
 	}
 
 	/* additional tx status */
-	val = readl_relaxed(adpt->base + EMAC_TXMAC_STATC_REG25);
-	adpt->stats.tx_col += val;
+	stats->tx_col += readl_relaxed(base + EMAC_TXMAC_STATC_REG25);
+}
+
+/* Provide network statistics info for the interface */
+static void emac_get_stats64(struct net_device *netdev,
+			     struct rtnl_link_stats64 *net_stats)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+	struct emac_stats *stats = &adpt->stats;
+
+	spin_lock(&stats->lock);
+
+	emac_update_hw_stats(adpt);
 
 	/* return parsed statistics */
 	net_stats->rx_packets = stats->rx_ok;
@@ -618,6 +629,7 @@ static int emac_probe(struct platform_device *pdev)
 
 	dev_set_drvdata(&pdev->dev, netdev);
 	SET_NETDEV_DEV(netdev, &pdev->dev);
+	emac_set_ethtool_ops(netdev);
 
 	adpt = netdev_priv(netdev);
 	adpt->netdev = netdev;
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.h b/drivers/net/ethernet/qualcomm/emac/emac.h
index 0c76e6c..4b8483c 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.h
+++ b/drivers/net/ethernet/qualcomm/emac/emac.h
@@ -332,4 +332,7 @@ struct emac_adapter {
 void emac_reg_update32(void __iomem *addr, u32 mask, u32 val);
 irqreturn_t emac_isr(int irq, void *data);
 
+void emac_set_ethtool_ops(struct net_device *netdev);
+void emac_update_hw_stats(struct emac_adapter *adpt);
+
 #endif /* _EMAC_H_ */
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
