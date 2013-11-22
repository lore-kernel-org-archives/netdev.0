From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH 2/5] net: MOXA ART: connect to PHY and add ethtool support
Date: Fri, 22 Nov 2013 15:57:19 +0100
Message-ID: <1385132242-3204-2-git-send-email-jonas.jensen@gmail.com>
References: <1385132242-3204-1-git-send-email-jonas.jensen@gmail.com>
Cc: davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385132242-3204-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The kernel now has a MDIO bus driver and a phy_driver (RTL8201CP),
connect to this PHY using OF and add ethtool support.

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    Applies to next-20131122

 drivers/net/ethernet/moxa/moxart_ether.c | 179 ++++++++++++++++++++++++++++++-
 drivers/net/ethernet/moxa/moxart_ether.h |   1 +
 2 files changed, 179 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 3c14afd..bcc6005 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -26,9 +26,15 @@
 #include <linux/of_irq.h>
 #include <linux/crc32.h>
 #include <linux/crc32c.h>
+#include <linux/phy.h>
+#include <linux/of_mdio.h>
 
 #include "moxart_ether.h"
 
+#define DRV_NAME                "moxart-ethernet"
+#define DRV_VERSION             "0.2"
+#define MOXART_NUM_STATS        16
+
 static inline void moxart_emac_write(struct net_device *ndev,
 				     unsigned int reg, unsigned long value)
 {
@@ -61,6 +67,145 @@ static int moxart_set_mac_address(struct net_device *ndev, void *addr)
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
+	info->n_stats = MOXART_NUM_STATS;
+}
+
+static int moxart_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	if (!priv->phy_dev)
+		return -ENODEV;
+
+	return phy_ethtool_gset(priv->phy_dev, cmd);
+}
+
+static int moxart_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	if (!priv->phy_dev)
+		return -ENODEV;
+
+	return phy_ethtool_sset(priv->phy_dev, cmd);
+}
+
+static int moxart_nway_reset(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	if (!priv->phy_dev)
+		return -EINVAL;
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
+	.set_settings           = moxart_set_settings,
+	.get_settings           = moxart_get_settings,
+	.get_drvinfo            = moxart_get_drvinfo,
+	.nway_reset             = moxart_nway_reset,
+	.get_link               = ethtool_op_get_link,
+	.get_ethtool_stats      = moxart_get_ethtool_stats,
+	.get_sset_count         = moxart_get_sset_count,
+	.get_strings            = moxart_get_strings,
+};
+
+static int moxart_do_ioctl(struct net_device *ndev, struct ifreq *ir, int cmd)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	if (!netif_running(ndev))
+		return -EINVAL;
+
+	if (!priv->phy_dev)
+		return -ENODEV;
+
+	return phy_mii_ioctl(priv->phy_dev, ir, cmd);
+}
+
 static void moxart_mac_free_memory(struct net_device *ndev)
 {
 	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
@@ -169,6 +314,10 @@ static int moxart_mac_open(struct net_device *ndev)
 	moxart_update_mac_address(ndev);
 	moxart_mac_setup_desc_ring(ndev);
 	moxart_mac_enable(ndev);
+
+	if (priv->phy_dev)
+		phy_start(priv->phy_dev);
+
 	netif_start_queue(ndev);
 
 	netdev_dbg(ndev, "%s: IMR=0x%x, MACCR=0x%x\n",
@@ -184,6 +333,9 @@ static int moxart_mac_stop(struct net_device *ndev)
 
 	napi_disable(&priv->napi);
 
+	if (priv->phy_dev)
+		phy_stop(priv->phy_dev);
+
 	netif_stop_queue(ndev);
 
 	/* disable all interrupts */
@@ -429,12 +581,22 @@ static struct net_device_ops moxart_netdev_ops = {
 	.ndo_set_mac_address	= moxart_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_do_ioctl           = moxart_do_ioctl,
 };
 
+static void moxart_adjust_link(struct net_device *ndev)
+{
+#ifdef DEBUG
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	phy_print_status(priv->phy_dev);
+#endif
+}
+
 static int moxart_mac_probe(struct platform_device *pdev)
 {
 	struct device *p_dev = &pdev->dev;
-	struct device_node *node = p_dev->of_node;
+	struct device_node *node = p_dev->of_node, *phy_node;
 	struct net_device *ndev;
 	struct moxart_mac_priv_t *priv;
 	struct resource *res;
@@ -455,6 +617,20 @@ static int moxart_mac_probe(struct platform_device *pdev)
 	priv = netdev_priv(ndev);
 	priv->ndev = ndev;
 
+	phy_node = of_parse_phandle(node, "phy-handle", 0);
+	if (!phy_node)
+		dev_err(p_dev, "of_parse_phandle failed\n");
+
+	if (phy_node) {
+		priv->phy_dev = of_phy_connect(priv->ndev, phy_node,
+					       &moxart_adjust_link,
+					       0, PHY_INTERFACE_MODE_MII);
+		if (!priv->phy_dev) {
+			dev_err(p_dev, "of_phy_connect failed\n");
+			ret = -ENODEV;
+		}
+	}
+
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	ndev->base_addr = res->start;
 	priv->base = devm_ioremap_resource(p_dev, res);
@@ -516,6 +692,7 @@ static int moxart_mac_probe(struct platform_device *pdev)
 	ndev->irq = irq;
 
 	SET_NETDEV_DEV(ndev, &pdev->dev);
+	SET_ETHTOOL_OPS(ndev, &moxart_ethtool_ops);
 
 	ret = register_netdev(ndev);
 	if (ret) {
diff --git a/drivers/net/ethernet/moxa/moxart_ether.h b/drivers/net/ethernet/moxa/moxart_ether.h
index 2be9280..193618e 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.h
+++ b/drivers/net/ethernet/moxa/moxart_ether.h
@@ -297,6 +297,7 @@ struct moxart_mac_priv_t {
 	unsigned int reg_imr;
 	struct napi_struct napi;
 	struct net_device *ndev;
+	struct phy_device *phy_dev;
 
 	dma_addr_t rx_base;
 	dma_addr_t rx_mapping[RX_DESC_NUM];
-- 
1.8.2.1
