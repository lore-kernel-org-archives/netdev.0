From: Thomas Scariah <thomasscariah@gmail.com>
Subject: [PATCH 1/1]  ethtool : added get_phy_stats,get_strings,get_sset_count
Date: Mon, 27 Mar 2017 15:42:50 +0530
Message-ID: <1490609570-3571-1-git-send-email-thomasscariah@gmail.com>
Cc: nsekhar@ti.com, grygorii.strashko@ti.com, davem@davemloft.net,
        drivshin@allworx.com, mugunthanvnm@ti.com,
        ivan.khoronzhuk@linaro.org, thomas.scariah@harman.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        thomasscariah@gmail.com
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Scariah, Thomas" <thomas.scariah@harman.com>

 Added functions to support ethtool to print the phy statistics and error
 information along with other ethtool statistics. This will help ethtool
 information to know the error is from physical layer or MAC layer.
 This is an enahancement for ethtool to accommodate phy statistics

Signed-off-by: Thomas Scariah <thomasscariah@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c |   16 ++++++++++++-
 drivers/net/phy/micrel.c       |   50 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/phy.c          |   23 ++++++++++++++++++
 include/linux/phy.h            |   14 +++++++++++
 4 files changed, 102 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 3f48bb9..26d2dc5 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1001,9 +1001,16 @@ update_return:
 
 static int cpsw_get_sset_count(struct net_device *ndev, int sset)
 {
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	int slave_no = cpsw_slave_index(priv);
+	int count;
+
 	switch (sset) {
 	case ETH_SS_STATS:
-		return CPSW_STATS_LEN;
+		count = CPSW_STATS_LEN;
+		count += phy_ethtool_get_sset_count(priv->slaves[slave_no].phy,
+						    sset);
+		return count;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -1011,6 +1018,8 @@ static int cpsw_get_sset_count(struct net_device *ndev, int sset)
 
 static void cpsw_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
 {
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	int slave_no = cpsw_slave_index(priv);
 	u8 *p = data;
 	int i;
 
@@ -1021,6 +1030,8 @@ static void cpsw_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
 			       ETH_GSTRING_LEN);
 			p += ETH_GSTRING_LEN;
 		}
+		phy_ethtool_get_strings(priv->slaves[slave_no].phy,
+					stringset, p);
 		break;
 	}
 }
@@ -1031,6 +1042,7 @@ static void cpsw_get_ethtool_stats(struct net_device *ndev,
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	struct cpdma_chan_stats rx_stats;
 	struct cpdma_chan_stats tx_stats;
+	int slave_no = cpsw_slave_index(priv);
 	u32 val;
 	u8 *p;
 	int i, ret;
@@ -1067,6 +1079,8 @@ static void cpsw_get_ethtool_stats(struct net_device *ndev,
 		}
 	}
 
+	phy_ethtool_get_stats(priv->slaves[slave_no].phy, stats,
+			      &data[CPSW_STATS_LEN]);
 	pm_runtime_put(&priv->pdev->dev);
 }
 
diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index e13ad6c..492acbf 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -287,6 +287,53 @@ static int kszphy_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+struct ks8051_phy_stat {
+	char name[ETH_GSTRING_LEN];
+	u16 offset;
+};
+
+static const struct ks8051_phy_stat ks8051_phy_stats[] = {
+	{ "PHY RX Error Counter", 0x15 },
+};
+
+#define KS8051_STATS_LEN ARRAY_SIZE(ks8051_phy_stats)
+
+static int ks8051_get_sset_count(struct phy_device *phydev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return KS8051_STATS_LEN;
+	default:
+		return 0;
+	}
+}
+
+static void ks8051_get_strings(struct phy_device *phydev, u32 stringset,
+			       u8 *data)
+{
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < KS8051_STATS_LEN; i++)
+			memcpy(data + i * ETH_GSTRING_LEN,
+			       ks8051_phy_stats[i].name, ETH_GSTRING_LEN);
+	break;
+	}
+}
+
+static void ks8051_get_phy_stats(struct phy_device *phydev,
+				 struct ethtool_stats *stats, u64 *data)
+{
+	u32 i;
+	u32 val;
+
+	for (i = 0; i < KS8051_STATS_LEN; i++) {
+		val = phy_read(phydev, ks8051_phy_stats[i].offset);
+		data[i] = val;
+	}
+}
+
 static int ksz9021_load_values_from_of(struct phy_device *phydev,
 				       const struct device_node *of_node,
 				       u16 reg,
@@ -724,6 +771,9 @@ static struct phy_driver ksphy_driver[] = {
 	.probe		= kszphy_probe,
 	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.get_phy_stats  = ks8051_get_phy_stats,
+	.get_strings    = ks8051_get_strings,
+	.get_sset_count = ks8051_get_sset_count,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 47cd306..25b66cd 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1262,3 +1262,26 @@ void phy_ethtool_get_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol)
 		phydev->drv->get_wol(phydev, wol);
 }
 EXPORT_SYMBOL(phy_ethtool_get_wol);
+
+int phy_ethtool_get_sset_count(struct phy_device *phydev, int sset)
+{
+	if (phydev->drv->get_sset_count)
+		return phydev->drv->get_sset_count(phydev, sset);
+	return 0;
+}
+EXPORT_SYMBOL(phy_ethtool_get_sset_count);
+
+void phy_ethtool_get_strings(struct phy_device *phydev, u32 stringset, u8 *data)
+{
+	if (phydev->drv->get_strings)
+		phydev->drv->get_strings(phydev, stringset, data);
+}
+EXPORT_SYMBOL(phy_ethtool_get_strings);
+
+void phy_ethtool_get_stats(struct phy_device *phydev,
+			   struct ethtool_stats *stats, u64 *data)
+{
+	if (phydev->drv->get_phy_stats)
+		phydev->drv->get_phy_stats(phydev, stats, data);
+}
+EXPORT_SYMBOL(phy_ethtool_get_stats);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 05fde31..4f14368 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -589,6 +589,15 @@ struct phy_driver {
 	int (*module_eeprom)(struct phy_device *dev,
 			     struct ethtool_eeprom *ee, u8 *data);
 
+	/* Request for phy statitsics information and printing statistics
+	 * information from ethtool stats. So Rx stats, Tx stats and error
+	 * information can be read from
+	 */
+	void (*get_phy_stats)(struct phy_device *, struct ethtool_stats *,
+			      u64 *);
+	void (*get_strings)(struct phy_device *, u32 stringset, u8 *);
+	int  (*get_sset_count)(struct phy_device *, int);
+
 	struct device_driver driver;
 };
 #define to_phy_driver(d) container_of(d, struct phy_driver, driver)
@@ -816,6 +825,11 @@ int phy_ethtool_get_eee(struct phy_device *phydev, struct ethtool_eee *data);
 int phy_ethtool_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol);
 void phy_ethtool_get_wol(struct phy_device *phydev,
 			 struct ethtool_wolinfo *wol);
+int phy_ethtool_get_sset_count(struct phy_device *phydev, int sset);
+void phy_ethtool_get_strings(struct phy_device *phydev, u32 stringset,
+			     u8 *data);
+void phy_ethtool_get_stats(struct phy_device *phydev,
+			   struct ethtool_stats *stats, u64 *data);
 
 int __init mdio_bus_init(void);
 void mdio_bus_exit(void);
-- 
1.7.9.5
