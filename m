From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH v2 3/3] drivers: net: cpsw: Add support for multicast/broadcast rate limit
Date: Wed, 9 Jul 2014 12:44:10 +0530
Message-ID: <1404890050-4020-4-git-send-email-mugunthanvnm@ti.com>
References: <1404890050-4020-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-api@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404890050-4020-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for multicast/broadcast rate limit feature via ethtool coalesce.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 80 ++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 78 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index a6117e6..2a984e6 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -403,6 +403,8 @@ struct cpsw_priv {
 	bool irq_enabled;
 	struct cpts *cpts;
 	u32 emac_port;
+	u32 rx_max_mcast;
+	u32 rx_max_bcast;
 };
 
 struct cpsw_stats {
@@ -871,11 +873,13 @@ static int cpsw_get_coalesce(struct net_device *ndev,
 	struct cpsw_priv *priv = netdev_priv(ndev);
 
 	coal->rx_coalesce_usecs = priv->coal_intvl;
+	coal->rx_max_mcast = priv->rx_max_mcast;
+	coal->rx_max_bcast = priv->rx_max_bcast;
 	return 0;
 }
 
-static int cpsw_set_coalesce(struct net_device *ndev,
-				struct ethtool_coalesce *coal)
+static int cpsw_set_coalesce_usecs(struct net_device *ndev,
+				   struct ethtool_coalesce *coal)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	u32 int_ctrl;
@@ -933,6 +937,74 @@ static int cpsw_set_coalesce(struct net_device *ndev,
 	return 0;
 }
 
+static int cpsw_set_coalesce_mcast(struct net_device *ndev,
+				   struct ethtool_coalesce *coal)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	int port;
+
+	priv->rx_max_mcast = coal->rx_max_mcast;
+
+	if (priv->data.dual_emac)
+		port = priv->emac_port;
+	else
+		port = priv->data.active_slave;
+
+	cpsw_ale_control_set(priv->ale, port, ALE_PORT_MCAST_LIMIT,
+			     coal->rx_max_mcast);
+
+	dev_dbg(priv->dev, "rx_max_mcast set to %d\n", priv->rx_max_mcast);
+	return 0;
+}
+
+static int cpsw_set_coalesce_bcast(struct net_device *ndev,
+				   struct ethtool_coalesce *coal)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	int port;
+
+	priv->rx_max_bcast = coal->rx_max_bcast;
+
+	if (priv->data.dual_emac)
+		port = priv->emac_port + 1;
+	else
+		port = priv->data.active_slave + 1;
+
+	cpsw_ale_control_set(priv->ale, port, ALE_PORT_BCAST_LIMIT,
+			     coal->rx_max_bcast);
+
+	dev_dbg(priv->dev, "rx_max_mcast set to %d\n", priv->rx_max_bcast);
+	return 0;
+}
+
+static int cpsw_set_coalesce(struct net_device *ndev,
+			     struct ethtool_coalesce *coal)
+{
+	int ret = -EINVAL;
+
+	if (coal->rx_coalesce_usecs) {
+		ret = cpsw_set_coalesce_usecs(ndev, coal);
+		if (ret) {
+			dev_err(&ndev->dev, "set rx-usecs failed\n");
+			return ret;
+		}
+	}
+
+	ret = cpsw_set_coalesce_mcast(ndev, coal);
+	if (ret) {
+		dev_err(&ndev->dev, "set coalesce rx-max-mcast failed\n");
+		return ret;
+	}
+
+	ret = cpsw_set_coalesce_bcast(ndev, coal);
+	if (ret) {
+		dev_err(&ndev->dev, "set coalesce rx-max-bcast failed\n");
+		return ret;
+	}
+
+	return ret;
+}
+
 static int cpsw_get_sset_count(struct net_device *ndev, int sset)
 {
 	switch (sset) {
@@ -1227,6 +1299,10 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		/* enable statistics collection only on all ports */
 		__raw_writel(0x7, &priv->regs->stat_port_en);
 
+		/* Enable rate limit feature in the switch for rx only */
+		cpsw_ale_control_set(priv->ale, 0, ALE_RATE_LIMIT, 1);
+		cpsw_ale_control_set(priv->ale, 0, ALE_RATE_LIMIT_TX, 0);
+
 		if (WARN_ON(!priv->data.rx_descs))
 			priv->data.rx_descs = 128;
 
-- 
2.0.0.390.gcb682f8
