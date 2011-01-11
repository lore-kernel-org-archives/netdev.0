From: nobuhiro.iwamatsu.yj@renesas.com
Subject: [PATCH v2] sh: sh_eth: Add support ethtool
Date: Tue, 11 Jan 2011 20:58:29 +0900
Message-ID: <1294747109-11511-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: linux-sh@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com,
	bhutchings@solarflare.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

This commit supports following functions.
 - get_drvinfo
 - get_settings
 - set_settings
 - nway_reset
 - get_msglevel
 - set_msglevel
 - get_link
 - get_strings
 - get_ethtool_stats
 - get_sset_count

About other function, the device does not support.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 v2: reverted one part of the checks of checkpatch.pl.
       foo *bar -> foo * bar.
	 changed function copying of net_device_stats from *for* to memcopy.
 
 drivers/net/sh_eth.c |  186 ++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 174 insertions(+), 12 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 819c175..0b2cb7d 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -32,6 +32,7 @@
 #include <linux/io.h>
 #include <linux/pm_runtime.h>
 #include <linux/slab.h>
+#include <linux/ethtool.h>
 #include <asm/cacheflush.h>
 
 #include "sh_eth.h"
@@ -817,6 +818,19 @@ static int sh_eth_rx(struct net_device *ndev)
 	return 0;
 }
 
+static void sh_eth_linkdown(u32 ioaddr)
+{
+	/* Link Down : disable tx and rx */
+	ctrl_outl(ctrl_inl(ioaddr + ECMR) &
+		~(ECMR_RE | ECMR_TE), ioaddr + ECMR);
+}
+
+static void sh_eth_linkup(u32 ioaddr)
+{
+	ctrl_outl(ctrl_inl(ioaddr + ECMR) |
+		(ECMR_RE | ECMR_TE), ioaddr + ECMR);
+}
+
 /* error control function */
 static void sh_eth_error(struct net_device *ndev, int intr_status)
 {
@@ -843,11 +857,9 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 				if (mdp->ether_link_active_low)
 					link_stat = ~link_stat;
 			}
-			if (!(link_stat & PHY_ST_LINK)) {
-				/* Link Down : disable tx and rx */
-				writel(readl(ioaddr + ECMR) &
-					  ~(ECMR_RE | ECMR_TE), ioaddr + ECMR);
-			} else {
+			if (!(link_stat & PHY_ST_LINK))
+				sh_eth_linkdown(ioaddr);
+			else {
 				/* Link Up */
 				writel(readl(ioaddr + EESIPR) &
 					  ~DMAC_M_ECI, ioaddr + EESIPR);
@@ -857,8 +869,7 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 				writel(readl(ioaddr + EESIPR) |
 					  DMAC_M_ECI, ioaddr + EESIPR);
 				/* enable tx and rx */
-				writel(readl(ioaddr + ECMR) |
-					  (ECMR_RE | ECMR_TE), ioaddr + ECMR);
+				sh_eth_linkup(ioaddr);
 			}
 		}
 	}
@@ -1063,6 +1074,154 @@ static int sh_eth_phy_start(struct net_device *ndev)
 	return 0;
 }
 
+static void sh_eth_get_drvinfo(struct net_device *ndev,
+			struct ethtool_drvinfo *info)
+{
+	strncpy(info->driver, "sh_eth", sizeof(info->driver) - 1);
+	strcpy(info->version, "N/A");
+	strcpy(info->fw_version, "N/A");
+	strlcpy(info->bus_info, dev_name(ndev->dev.parent),
+		sizeof(info->bus_info));
+}
+
+static int sh_eth_get_settings(struct net_device *ndev,
+			struct ethtool_cmd *ecmd)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&mdp->lock, flags);
+	ret = phy_ethtool_gset(mdp->phydev, ecmd);
+	spin_unlock_irqrestore(&mdp->lock, flags);
+
+	return ret;
+}
+
+static int sh_eth_set_settings(struct net_device *ndev,
+		struct ethtool_cmd *ecmd)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	unsigned long flags;
+	int ret;
+	u32 ioaddr = ndev->base_addr;
+
+	spin_lock_irqsave(&mdp->lock, flags);
+
+	/* disable tx and rx */
+	sh_eth_linkdown(ioaddr);
+
+	ret = phy_ethtool_sset(mdp->phydev, ecmd);
+	if (ret)
+		goto error_exit;
+
+	if (ecmd->duplex == DUPLEX_FULL)
+		mdp->duplex = 1;
+	else
+		mdp->duplex = 0;
+
+	if (mdp->cd->set_duplex)
+		mdp->cd->set_duplex(ndev);
+
+error_exit:
+	mdelay(100);
+
+	/* enable tx and rx */
+	sh_eth_linkup(ioaddr);
+
+	spin_unlock_irqrestore(&mdp->lock, flags);
+
+	return ret;
+}
+
+static int sh_eth_nway_reset(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&mdp->lock, flags);
+	ret = phy_start_aneg(mdp->phydev);
+	spin_unlock_irqrestore(&mdp->lock, flags);
+
+	return ret;
+}
+
+static u32 sh_eth_get_msglevel(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	return mdp->msg_enable;
+}
+
+static void sh_eth_set_msglevel(struct net_device *ndev, u32 value)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	mdp->msg_enable = value;
+}
+
+static const char sh_eth_gstrings_stats[][ETH_GSTRING_LEN] = {
+	"rx_packets", "tx_packets", "rx_bytes", "tx_bytes", "rx_errors",
+	"tx_errors", "rx_dropped", "tx_dropped", "multicast", "collisions",
+	"rx_length_errors", "rx_over_errors", "rx_crc_errors",
+	"rx_frame_errors", "rx_fifo_errors", "rx_missed_errors",
+	"tx_aborted_errors", "tx_carrier_errors", "tx_fifo_errors",
+	"tx_heartbeat_errors", "tx_window_errors",
+	/* device-specific stats */
+	"rx_current", "tx_current",
+	"rx_dirty", "tx_dirty",
+};
+#define SH_ETH_NET_STATS_LEN  21
+#define SH_ETH_STATS_LEN  ARRAY_SIZE(sh_eth_gstrings_stats)
+
+static int sh_eth_get_sset_count(struct net_device *netdev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return SH_ETH_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void sh_eth_get_ethtool_stats(struct net_device *ndev,
+			struct ethtool_stats *stats, u64 *data)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int i = SH_ETH_NET_STATS_LEN;
+
+	memcpy(data, (unsigned long *)&ndev->stats,
+				SH_ETH_NET_STATS_LEN * sizeof(unsigned long));
+
+	/* device-specific stats */
+	data[i++] = mdp->cur_rx;
+	data[i++] = mdp->cur_tx;
+	data[i++] = mdp->dirty_rx;
+	data[i++] = mdp->dirty_tx;
+}
+
+static void sh_eth_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
+{
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(data, *sh_eth_gstrings_stats,
+					sizeof(sh_eth_gstrings_stats));
+		break;
+	}
+}
+
+static struct ethtool_ops sh_eth_ethtool_ops = {
+	.get_drvinfo	= sh_eth_get_drvinfo,
+	.get_settings	= sh_eth_get_settings,
+	.set_settings	= sh_eth_set_settings,
+	.nway_reset		= sh_eth_nway_reset,
+	.get_msglevel	= sh_eth_get_msglevel,
+	.set_msglevel	= sh_eth_set_msglevel,
+	.get_link		= ethtool_op_get_link,
+	.get_strings	= sh_eth_get_strings,
+	.get_ethtool_stats  = sh_eth_get_ethtool_stats,
+	.get_sset_count     = sh_eth_get_sset_count,
+};
+
 /* network device open function */
 static int sh_eth_open(struct net_device *ndev)
 {
@@ -1073,8 +1232,8 @@ static int sh_eth_open(struct net_device *ndev)
 
 	ret = request_irq(ndev->irq, sh_eth_interrupt,
 #if defined(CONFIG_CPU_SUBTYPE_SH7763) || \
-    defined(CONFIG_CPU_SUBTYPE_SH7764) || \
-    defined(CONFIG_CPU_SUBTYPE_SH7757)
+	defined(CONFIG_CPU_SUBTYPE_SH7764) || \
+	defined(CONFIG_CPU_SUBTYPE_SH7757)
 				IRQF_SHARED,
 #else
 				0,
@@ -1232,11 +1391,11 @@ static int sh_eth_close(struct net_device *ndev)
 	sh_eth_ring_free(ndev);
 
 	/* free DMA buffer */
-	ringsize = sizeof(struct sh_eth_rxdesc) * RX_RING_SIZE;
+	ringsize = sizeof(struct sh_eth_rxdesc) *RX_RING_SIZE;
 	dma_free_coherent(NULL, ringsize, mdp->rx_ring, mdp->rx_desc_dma);
 
 	/* free DMA buffer */
-	ringsize = sizeof(struct sh_eth_txdesc) * TX_RING_SIZE;
+	ringsize = sizeof(struct sh_eth_txdesc) *TX_RING_SIZE;
 	dma_free_coherent(NULL, ringsize, mdp->tx_ring, mdp->tx_desc_dma);
 
 	pm_runtime_put_sync(&mdp->pdev->dev);
@@ -1497,8 +1656,11 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 
 	/* set function */
 	ndev->netdev_ops = &sh_eth_netdev_ops;
+	SET_ETHTOOL_OPS(ndev, &sh_eth_ethtool_ops);
 	ndev->watchdog_timeo = TX_TIMEOUT;
 
+	/* debug message level */
+	mdp->msg_enable = (1 << 3) - 1;
 	mdp->post_rx = POST_RX >> (devno << 1);
 	mdp->post_fw = POST_FW >> (devno << 1);
 
@@ -1572,7 +1734,7 @@ static int sh_eth_runtime_nop(struct device *dev)
 	return 0;
 }
 
-static struct dev_pm_ops sh_eth_dev_pm_ops = {
+static const struct dev_pm_ops sh_eth_dev_pm_ops = {
 	.runtime_suspend = sh_eth_runtime_nop,
 	.runtime_resume = sh_eth_runtime_nop,
 };
-- 
1.7.2.3

