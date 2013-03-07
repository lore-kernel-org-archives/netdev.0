From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 1/3] driver: net: ethernet: cpsw: implement ethtool get/set phy setting
Date: Thu, 7 Mar 2013 18:00:19 +0530
Message-ID: <1362659421-11884-2-git-send-email-mugunthanvnm@ti.com>
References: <1362659421-11884-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <b-cousson@ti.com>, <paul@pwsan.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1362659421-11884-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements get/set of the phy settings via ethtool apis

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |    3 +++
 drivers/net/ethernet/ti/cpsw.c                 |   32 ++++++++++++++++++++++++
 include/linux/platform_data/cpsw.h             |    1 +
 3 files changed, 36 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index ecfdf75..8d61300 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -20,6 +20,7 @@ Required properties:
 - cpts_clock_shift	: Denominator to convert input clock ticks into nanoseconds
 - phy_id		: Specifies slave phy id
 - mac-address		: Specifies slave MAC address
+- ethtool-active-slave	: Specifies the slave to use for ethtool command
 
 Optional properties:
 - ti,hwmods		: Must be "cpgmac0"
@@ -50,6 +51,7 @@ Examples:
 		cpts_active_slave = <0>;
 		cpts_clock_mult = <0x80000000>;
 		cpts_clock_shift = <29>;
+		ethtool-active-slave = <0>;
 		cpsw_emac0: slave@0 {
 			phy_id = <&davinci_mdio>, <0>;
 			/* Filled in by U-Boot */
@@ -76,6 +78,7 @@ Examples:
 		cpts_active_slave = <0>;
 		cpts_clock_mult = <0x80000000>;
 		cpts_clock_shift = <29>;
+		ethtool-active-slave = <0>;
 		cpsw_emac0: slave@0 {
 			phy_id = <&davinci_mdio>, <0>;
 			/* Filled in by U-Boot */
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 01ffbc4..fa91eec 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1244,12 +1244,41 @@ static int cpsw_get_ts_info(struct net_device *ndev,
 	return 0;
 }
 
+#define cpsw_slave_phy_index(priv)			\
+	((priv->data.dual_emac) ? priv->emac_port :	\
+	priv->data.ethtool_active_slave)
+
+static int cpsw_get_settings(struct net_device *ndev,
+			     struct ethtool_cmd *ecmd)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	int slave_no = cpsw_slave_phy_index(priv);
+
+	if (priv->slaves[slave_no].phy)
+		return phy_ethtool_gset(priv->slaves[slave_no].phy, ecmd);
+	else
+		return -EOPNOTSUPP;
+}
+
+static int cpsw_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	int slave_no = cpsw_slave_phy_index(priv);
+
+	if (priv->slaves[slave_no].phy)
+		return phy_ethtool_sset(priv->slaves[slave_no].phy, ecmd);
+	else
+		return -EOPNOTSUPP;
+}
+
 static const struct ethtool_ops cpsw_ethtool_ops = {
 	.get_drvinfo	= cpsw_get_drvinfo,
 	.get_msglevel	= cpsw_get_msglevel,
 	.set_msglevel	= cpsw_set_msglevel,
 	.get_link	= ethtool_op_get_link,
 	.get_ts_info	= cpsw_get_ts_info,
+	.get_settings	= cpsw_get_settings,
+	.set_settings	= cpsw_set_settings,
 };
 
 static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
@@ -1346,6 +1375,9 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	if (!of_property_read_u32(node, "dual_emac", &prop))
 		data->dual_emac = prop;
 
+	if (!of_property_read_u32(node, "ethtool-active-slave", &prop))
+		data->ethtool_active_slave = prop;
+
 	/*
 	 * Populate all the child nodes here...
 	 */
diff --git a/include/linux/platform_data/cpsw.h b/include/linux/platform_data/cpsw.h
index 798fb80..e87e5cb 100644
--- a/include/linux/platform_data/cpsw.h
+++ b/include/linux/platform_data/cpsw.h
@@ -39,6 +39,7 @@ struct cpsw_platform_data {
 	u32	mac_control;	/* Mac control register */
 	u16	default_vlan;	/* Def VLAN for ALE lookup in VLAN aware mode*/
 	bool	dual_emac;	/* Enable Dual EMAC mode */
+	u32	ethtool_active_slave; /* ethtool slave */
 };
 
 #endif /* __CPSW_H__ */
-- 
1.7.9.5

