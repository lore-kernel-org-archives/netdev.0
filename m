From: <srinivas.kandagatla@st.com>
Subject: [PATCH RFC 7/9] net: stmmac: use suspend functions for hibernation
Date: Mon, 18 Nov 2013 11:32:17 +0000
Message-ID: <1384774337-10347-1-git-send-email-srinivas.kandagatla@st.com>
References: <1384774256-10039-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <srinivas.kandagatla@st.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384774256-10039-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

In hibernation freeze case the driver just releases the resources like
dma buffers, irqs, unregisters the drivers and during restore it does
register, request the resources. This is not really necessary, as part
of power management all the data structures are intact, all the
previously allocated resources can be used after coming out of low
power.

This patch uses the suspend and resume callbacks for freeze and
restore which initializes the hardware correctly without unregistering
or releasing the resources, this should also help in reducing the time
to restore.

Also this patch fixes a bug in stmmac_pltfr_restore and
stmmac_pltfr_freeze where it tries to get hold of platform data via
dev_get_platdata call, which would return NULL in device tree cases and
the next if statement would crash as there is no NULL check.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    2 -
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   16 -------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   47 +++++--------------
 3 files changed, 13 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 8c3fed3..90350e9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -119,8 +119,6 @@ extern const struct stmmac_desc_ops ndesc_ops;
 extern const struct stmmac_hwtimestamp stmmac_ptp;
 int stmmac_ptp_register(struct stmmac_priv *priv);
 void stmmac_ptp_unregister(struct stmmac_priv *priv);
-int stmmac_freeze(struct net_device *ndev);
-int stmmac_restore(struct net_device *ndev);
 int stmmac_resume(struct net_device *ndev);
 int stmmac_suspend(struct net_device *ndev);
 int stmmac_dvr_remove(struct net_device *ndev);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 3b0c18a..5b4bd7d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2900,22 +2900,6 @@ int stmmac_resume(struct net_device *ndev)
 
 	return 0;
 }
-
-int stmmac_freeze(struct net_device *ndev)
-{
-	if (!ndev || !netif_running(ndev))
-		return 0;
-
-	return stmmac_release(ndev);
-}
-
-int stmmac_restore(struct net_device *ndev)
-{
-	if (!ndev || !netif_running(ndev))
-		return 0;
-
-	return stmmac_open(ndev);
-}
 #endif /* CONFIG_PM */
 
 /* Driver can be configured w/ and w/ both PCI and Platf drivers
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 3073c50..6bdda55 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -209,57 +209,36 @@ static int stmmac_pltfr_remove(struct platform_device *pdev)
 }
 
 #ifdef CONFIG_PM
-static int stmmac_pltfr_suspend(struct device *dev)
-{
-	struct net_device *ndev = dev_get_drvdata(dev);
-
-	return stmmac_suspend(ndev);
-}
-
-static int stmmac_pltfr_resume(struct device *dev)
-{
-	struct net_device *ndev = dev_get_drvdata(dev);
-
-	return stmmac_resume(ndev);
-}
-
-int stmmac_pltfr_freeze(struct device *dev)
+int stmmac_pltfr_suspend(struct device *dev)
 {
 	int ret;
-	struct plat_stmmacenet_data *plat_dat = dev_get_platdata(dev);
 	struct net_device *ndev = dev_get_drvdata(dev);
+	struct stmmac_priv *priv = netdev_priv(ndev);
 	struct platform_device *pdev = to_platform_device(dev);
 
-	ret = stmmac_freeze(ndev);
-	if (plat_dat->exit)
-		plat_dat->exit(pdev);
+	ret = stmmac_suspend(ndev);
+	if (priv->plat->exit)
+		priv->plat->exit(pdev);
 
 	return ret;
 }
 
-int stmmac_pltfr_restore(struct device *dev)
+int stmmac_pltfr_resume(struct device *dev)
 {
-	struct plat_stmmacenet_data *plat_dat = dev_get_platdata(dev);
 	struct net_device *ndev = dev_get_drvdata(dev);
+	struct stmmac_priv *priv = netdev_priv(ndev);
 	struct platform_device *pdev = to_platform_device(dev);
 
-	if (plat_dat->init)
-		plat_dat->init(pdev);
+	if (priv->plat->init)
+		priv->plat->init(pdev);
 
-	return stmmac_restore(ndev);
+	return stmmac_resume(ndev);
 }
-
-static const struct dev_pm_ops stmmac_pltfr_pm_ops = {
-	.suspend = stmmac_pltfr_suspend,
-	.resume = stmmac_pltfr_resume,
-	.freeze = stmmac_pltfr_freeze,
-	.thaw = stmmac_pltfr_restore,
-	.restore = stmmac_pltfr_restore,
-};
-#else
-static const struct dev_pm_ops stmmac_pltfr_pm_ops;
 #endif /* CONFIG_PM */
 
+static SIMPLE_DEV_PM_OPS(stmmac_pltfr_pm_ops,
+			stmmac_pltfr_suspend, stmmac_pltfr_resume);
+
 static const struct of_device_id stmmac_dt_ids[] = {
 	{ .compatible = "st,spear600-gmac"},
 	{ .compatible = "snps,dwmac-3.610"},
-- 
1.7.6.5
