From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH v3 4/7] net: moxa: add ethtool support
Date: Mon, 20 Jan 2014 12:13:16 +0100
Message-ID: <1390216399-27028-4-git-send-email-jonas.jensen@gmail.com>
References: <1390216399-27028-1-git-send-email-jonas.jensen@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, f.fainelli@gmail.com,
	bhutchings@solarflare.com, Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:39577 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbaATLN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 06:13:59 -0500
In-Reply-To: <1390216399-27028-1-git-send-email-jonas.jensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add and assign ethtool_ops callback functions.

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    Applies to next-20140120

 drivers/net/ethernet/moxa/moxart_ether.c | 121 +++++++++++++++++++++++++++++++
 1 file changed, 121 insertions(+)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index c19bff2..ca892bb 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -31,6 +31,10 @@
 
 #include "moxart_ether.h"
 
+#define DRV_NAME		"moxart-ethernet"
+#define DRV_VERSION		"0.2"
+#define MOXART_NUM_STATS	ARRAY_SIZE(ethtool_stats_keys)
+
 static inline void moxart_emac_write(struct net_device *ndev,
 				     unsigned int reg, unsigned long value)
 {
@@ -63,6 +67,122 @@ static int moxart_set_mac_address(struct net_device *ndev, void *addr)
 	return 0;
 }
 
+static struct {
+	const char str[ETH_GSTRING_LEN];
+} ethtool_stats_keys[] = {
+	{ "tx_ok_mcol_2to15" },
+	{ "tx_ok_1col" },
+	{ "rx_frame_pause" },
+	{ "frame_align_err" },
+	{ "err_col_late_16" },
+	{ "err_col_16" },
+	{ "rx_runt" },
+	{ "late_col" },
+	{ "crc_err" },
+	{ "rx_ftl" },
+	{ "rx_fifo_full" },
+	{ "rx_col" },
+	{ "rx_bcast" },
+	{ "rx_mcast" },
+	{ "rx_ok" },
+	{ "tx_ok" },
+};
+
+static void moxart_get_drvinfo(struct net_device *ndev,
+			       struct ethtool_drvinfo *info)
+{
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, dev_name(&ndev->dev), sizeof(info->bus_info));
+}
+
+static int moxart_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	return phy_ethtool_gset(priv->phy_dev, cmd);
+}
+
+static int moxart_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	return phy_ethtool_sset(priv->phy_dev, cmd);
+}
+
+static int moxart_nway_reset(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	return genphy_restart_aneg(priv->phy_dev);
+}
+
+static void moxart_get_ethtool_stats(struct net_device *ndev,
+				     struct ethtool_stats *estats,
+				     u64 *tmp_stats)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+	u32 s;
+	int i = 0;
+
+	s = readl(priv->base + REG_TX_COL_COUNTER);
+	tmp_stats[i++] = s & 0xffff0000;
+	tmp_stats[i++] = s & 0x0000ffff;
+	s = readl(priv->base + REG_RPF_AEP_COUNTER);
+	tmp_stats[i++] = s & 0xffff0000;
+	tmp_stats[i++] = s & 0x0000ffff;
+	s = readl(priv->base + REG_XM_PG_COUNTER);
+	tmp_stats[i++] = s & 0xffff0000;
+	tmp_stats[i++] = s & 0x0000ffff;
+	s = readl(priv->base + REG_RUNT_TLC_COUNTER);
+	tmp_stats[i++] = s & 0xffff0000;
+	tmp_stats[i++] = s & 0x0000ffff;
+	s = readl(priv->base + REG_CRC_FTL_COUNTER);
+	tmp_stats[i++] = s & 0xffff0000;
+	tmp_stats[i++] = s & 0x0000ffff;
+	s = readl(priv->base + REG_RLC_RCC_COUNTER);
+	tmp_stats[i++] = s & 0xffff0000;
+	tmp_stats[i++] = s & 0x0000ffff;
+	tmp_stats[i++] = readl(priv->base + REG_BROC_COUNTER);
+	tmp_stats[i++] = readl(priv->base + REG_MULCA_COUNTER);
+	tmp_stats[i++] = readl(priv->base + REG_XP_COUNTER);
+	tmp_stats[i++] = readl(priv->base + REG_RP_COUNTER);
+}
+
+static int moxart_get_sset_count(struct net_device *netdev,
+					int string_set)
+{
+	switch (string_set) {
+	case ETH_SS_STATS:
+		return MOXART_NUM_STATS;
+	default:
+		return -EINVAL;
+	}
+}
+
+static void moxart_get_strings(struct net_device *dev, u32 stringset, u8 *data)
+{
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(data, &ethtool_stats_keys, sizeof(ethtool_stats_keys));
+		break;
+	default:
+		WARN_ON(1);
+		break;
+	}
+}
+
+static const struct ethtool_ops moxart_ethtool_ops = {
+	.set_settings		= moxart_set_settings,
+	.get_settings		= moxart_get_settings,
+	.get_drvinfo		= moxart_get_drvinfo,
+	.nway_reset		= moxart_nway_reset,
+	.get_link		= ethtool_op_get_link,
+	.get_ethtool_stats	= moxart_get_ethtool_stats,
+	.get_sset_count		= moxart_get_sset_count,
+	.get_strings		= moxart_get_strings,
+};
+
 static int moxart_do_ioctl(struct net_device *ndev, struct ifreq *ir, int cmd)
 {
 	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
@@ -612,6 +732,7 @@ static int moxart_mac_probe(struct platform_device *pdev)
 	ndev->irq = irq;
 
 	SET_NETDEV_DEV(ndev, &pdev->dev);
+	SET_ETHTOOL_OPS(ndev, &moxart_ethtool_ops);
 
 	ret = register_netdev(ndev);
 	if (ret) {
-- 
1.8.2.1
