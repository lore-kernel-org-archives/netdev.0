From: Jane Li <jiel@marvell.com>
Subject: [PATCH] net: mvneta: support suspend and resume
Date: Wed, 15 Mar 2017 15:08:34 +0800
Message-ID: <1489561714-2368-1-git-send-email-jiel@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <jszhang@marvell.com>, Jane Li <jiel@marvell.com>
To: <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add basic support for handling suspend and resume.

Signed-off-by: Jane Li <jiel@marvell.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 44 +++++++++++++++++++++++++++++++++++
 1 file changed, 44 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 61dd446..4f16342 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -4405,6 +4405,49 @@ static int mvneta_remove(struct platform_device *pdev)
 	return 0;
 }
 
+#ifdef CONFIG_PM_SLEEP
+static int mvneta_suspend(struct device *device)
+{
+	struct net_device *dev = dev_get_drvdata(device);
+	struct mvneta_port *pp = netdev_priv(dev);
+
+	if (netif_running(dev))
+		mvneta_stop(dev);
+	netif_device_detach(dev);
+	clk_disable_unprepare(pp->clk_bus);
+	clk_disable_unprepare(pp->clk);
+	return 0;
+}
+
+static int mvneta_resume(struct device *device)
+{
+	struct net_device *dev = dev_get_drvdata(device);
+	struct mvneta_port *pp = netdev_priv(dev);
+	int err;
+
+	clk_prepare_enable(pp->clk);
+	clk_prepare_enable(pp->clk_bus);
+	mvneta_defaults_set(pp);
+	err = mvneta_port_power_up(pp, pp->phy_interface);
+	if (err < 0) {
+		dev_err(device, "can't power up port\n");
+		return err;
+	}
+
+	if (pp->use_inband_status)
+		mvneta_fixed_link_update(pp, dev->phydev);
+
+	netif_device_attach(dev);
+	if (netif_running(dev))
+		mvneta_open(dev);
+	return 0;
+}
+#endif
+
+static const struct dev_pm_ops mvneta_pm_ops = {
+	SET_LATE_SYSTEM_SLEEP_PM_OPS(mvneta_suspend, mvneta_resume)
+};
+
 static const struct of_device_id mvneta_match[] = {
 	{ .compatible = "marvell,armada-370-neta" },
 	{ .compatible = "marvell,armada-xp-neta" },
@@ -4419,6 +4462,7 @@ static int mvneta_remove(struct platform_device *pdev)
 	.driver = {
 		.name = MVNETA_DRIVER_NAME,
 		.of_match_table = mvneta_match,
+		.pm = &mvneta_pm_ops,
 	},
 };
 
-- 
1.9.1
