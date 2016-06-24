From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 04/15] drivers: net: cpsw: ethtool: fix accessing to suspended device
Date: Fri, 24 Jun 2016 21:23:44 +0300
Message-ID: <20160624182355.23515-5-grygorii.strashko@ti.com>
References: <20160624182355.23515-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, <devicetree@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160624182355.23515-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CPSW might be suspended by RPM if all ethX interfaces are down,
but it still could be accesible through ethtool interfce. In this case
ethtool operations, requiring registers access, will cause L3 errors and
CPSW crash.

ethtool callbcaks which need to access CPSW registers now:
.set_coalesce(), .get_ethtool_stats(), .set_pauseparam(), .get_regs()

Hence, fix it by adding .begin()/.complete() ethtool callbacks, which
will be called before/after each ethtool operation runs, and do CPSW
RPM handling in these callbacks. That way CPSW will be active while
handling ethtool requests.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 27 ++++++++++++++++++++++++++-
 1 file changed, 26 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index ba81d4e..5fea986 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1907,10 +1907,33 @@ static int cpsw_set_pauseparam(struct net_device *ndev,
 	priv->tx_pause = pause->tx_pause ? true : false;
 
 	for_each_slave(priv, _cpsw_adjust_link, priv, &link);
-
 	return 0;
 }
 
+static int cpsw_ethtool_op_begin(struct net_device *ndev)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	int ret;
+
+	ret = pm_runtime_get_sync(&priv->pdev->dev);
+	if (ret < 0) {
+		cpsw_err(priv, drv, "ethtool begin failed %d\n", ret);
+		pm_runtime_put_noidle(&priv->pdev->dev);
+	}
+
+	return ret;
+}
+
+static void cpsw_ethtool_op_complete(struct net_device *ndev)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	int ret;
+
+	ret = pm_runtime_put(&priv->pdev->dev);
+	if (ret < 0)
+		cpsw_err(priv, drv, "ethtool complete failed %d\n", ret);
+}
+
 static const struct ethtool_ops cpsw_ethtool_ops = {
 	.get_drvinfo	= cpsw_get_drvinfo,
 	.get_msglevel	= cpsw_get_msglevel,
@@ -1930,6 +1953,8 @@ static const struct ethtool_ops cpsw_ethtool_ops = {
 	.set_wol	= cpsw_set_wol,
 	.get_regs_len	= cpsw_get_regs_len,
 	.get_regs	= cpsw_get_regs,
+	.begin		= cpsw_ethtool_op_begin,
+	.complete	= cpsw_ethtool_op_complete,
 };
 
 static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
-- 
2.9.0
