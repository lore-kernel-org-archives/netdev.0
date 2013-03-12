From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v2 3/5] driver: net: ethernet: cpsw: implement ethtool get/set phy setting
Date: Tue, 12 Mar 2013 14:46:36 +0530
Message-ID: <1363079798-18147-4-git-send-email-mugunthanvnm@ti.com>
References: <1363079798-18147-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <b-cousson@ti.com>, <paul@pwsan.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1363079798-18147-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements get/set of the phy settings via ethtool apis

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c |   29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 98aa17a..83ce890 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -139,6 +139,10 @@ do {								\
 			disable_irq_nosync(priv->irqs_table[i]); \
 	} while (0);
 
+#define cpsw_slave_index(priv)				\
+		((priv->data.dual_emac) ? priv->emac_port :	\
+		priv->data.active_slave)
+
 static int debug_level;
 module_param(debug_level, int, 0);
 MODULE_PARM_DESC(debug_level, "cpsw debug level (NETIF_MSG bits)");
@@ -1244,12 +1248,37 @@ static int cpsw_get_ts_info(struct net_device *ndev,
 	return 0;
 }
 
+static int cpsw_get_settings(struct net_device *ndev,
+			     struct ethtool_cmd *ecmd)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	int slave_no = cpsw_slave_index(priv);
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
+	int slave_no = cpsw_slave_index(priv);
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
-- 
1.7.9.5

