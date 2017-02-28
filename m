From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH net-next v3 3/3] net: ethernet: bgmac: driver power manangement
Date: Tue, 28 Feb 2017 13:51:01 -0500
Message-ID: <1488307861-12118-4-git-send-email-jon.mason@broadcom.com>
References: <1488307861-12118-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Joey Zhong <zhongx@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488307861-12118-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joey Zhong <zhongx@broadcom.com>

Implement suspend/resume callbacks in the bgmac driver. This makes sure
that we de-initialize and re-initialize the hardware correctly before
entering suspend and when resuming.

Signed-off-by: Joey Zhong <zhongx@broadcom.com>
Signed-off-by: Jon Mason <jon.mason@broadcom.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac-platform.c | 34 +++++++++++++++++
 drivers/net/ethernet/broadcom/bgmac.c          | 51 ++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bgmac.h          |  2 +
 3 files changed, 87 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac-platform.c b/drivers/net/ethernet/broadcom/bgmac-platform.c
index 5a3d0b7..ce47728 100644
--- a/drivers/net/ethernet/broadcom/bgmac-platform.c
+++ b/drivers/net/ethernet/broadcom/bgmac-platform.c
@@ -21,8 +21,12 @@
 #include <linux/of_net.h>
 #include "bgmac.h"
 
+#define NICPM_PADRING_CFG		0x00000004
 #define NICPM_IOMUX_CTRL		0x00000008
 
+#define NICPM_PADRING_CFG_INIT_VAL	0x74000000
+#define NICPM_IOMUX_CTRL_INIT_VAL_AX	0x21880000
+
 #define NICPM_IOMUX_CTRL_INIT_VAL	0x3196e000
 #define NICPM_IOMUX_CTRL_SPD_SHIFT	10
 #define NICPM_IOMUX_CTRL_SPD_10M	0
@@ -108,6 +112,10 @@ static void bgmac_nicpm_speed_set(struct net_device *net_dev)
 	if (!bgmac->plat.nicpm_base)
 		return;
 
+	/* SET RGMII IO CONFIG */
+	writel(NICPM_PADRING_CFG_INIT_VAL,
+	       bgmac->plat.nicpm_base + NICPM_PADRING_CFG);
+
 	val = NICPM_IOMUX_CTRL_INIT_VAL;
 	switch (bgmac->net_dev->phydev->speed) {
 	default:
@@ -239,6 +247,31 @@ static int bgmac_remove(struct platform_device *pdev)
 	return 0;
 }
 
+#ifdef CONFIG_PM
+static int bgmac_suspend(struct device *dev)
+{
+	struct bgmac *bgmac = dev_get_drvdata(dev);
+
+	return bgmac_enet_suspend(bgmac);
+}
+
+static int bgmac_resume(struct device *dev)
+{
+	struct bgmac *bgmac = dev_get_drvdata(dev);
+
+	return bgmac_enet_resume(bgmac);
+}
+
+static const struct dev_pm_ops bgmac_pm_ops = {
+	.suspend = bgmac_suspend,
+	.resume = bgmac_resume
+};
+
+#define BGMAC_PM_OPS (&bgmac_pm_ops)
+#else
+#define BGMAC_PM_OPS NULL
+#endif /* CONFIG_PM */
+
 static const struct of_device_id bgmac_of_enet_match[] = {
 	{.compatible = "brcm,amac",},
 	{.compatible = "brcm,nsp-amac",},
@@ -252,6 +285,7 @@ static struct platform_driver bgmac_enet_driver = {
 	.driver = {
 		.name  = "bgmac-enet",
 		.of_match_table = bgmac_of_enet_match,
+		.pm = BGMAC_PM_OPS
 	},
 	.probe = bgmac_probe,
 	.remove = bgmac_remove,
diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 6b7782f..7f516a2 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1480,6 +1480,7 @@ int bgmac_enet_probe(struct bgmac *bgmac)
 
 	net_dev->irq = bgmac->irq;
 	SET_NETDEV_DEV(net_dev, bgmac->dev);
+	dev_set_drvdata(bgmac->dev, bgmac);
 
 	if (!is_valid_ether_addr(net_dev->dev_addr)) {
 		dev_err(bgmac->dev, "Invalid MAC addr: %pM\n",
@@ -1552,5 +1553,55 @@ void bgmac_enet_remove(struct bgmac *bgmac)
 }
 EXPORT_SYMBOL_GPL(bgmac_enet_remove);
 
+int bgmac_enet_suspend(struct bgmac *bgmac)
+{
+	if (!netif_running(bgmac->net_dev))
+		return 0;
+
+	phy_stop(bgmac->net_dev->phydev);
+
+	netif_stop_queue(bgmac->net_dev);
+
+	napi_disable(&bgmac->napi);
+
+	netif_tx_lock(bgmac->net_dev);
+	netif_device_detach(bgmac->net_dev);
+	netif_tx_unlock(bgmac->net_dev);
+
+	bgmac_chip_intrs_off(bgmac);
+	bgmac_chip_reset(bgmac);
+	bgmac_dma_cleanup(bgmac);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(bgmac_enet_suspend);
+
+int bgmac_enet_resume(struct bgmac *bgmac)
+{
+	int rc;
+
+	if (!netif_running(bgmac->net_dev))
+		return 0;
+
+	rc = bgmac_dma_init(bgmac);
+	if (rc)
+		return rc;
+
+	bgmac_chip_init(bgmac);
+
+	napi_enable(&bgmac->napi);
+
+	netif_tx_lock(bgmac->net_dev);
+	netif_device_attach(bgmac->net_dev);
+	netif_tx_unlock(bgmac->net_dev);
+
+	netif_start_queue(bgmac->net_dev);
+
+	phy_start(bgmac->net_dev->phydev);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(bgmac_enet_resume);
+
 MODULE_AUTHOR("Rafał Miłecki");
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index a75ed35..c181876 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -537,6 +537,8 @@ int bgmac_enet_probe(struct bgmac *bgmac);
 void bgmac_enet_remove(struct bgmac *bgmac);
 void bgmac_adjust_link(struct net_device *net_dev);
 int bgmac_phy_connect_direct(struct bgmac *bgmac);
+int bgmac_enet_suspend(struct bgmac *bgmac);
+int bgmac_enet_resume(struct bgmac *bgmac);
 
 struct mii_bus *bcma_mdio_mii_register(struct bgmac *bgmac);
 void bcma_mdio_mii_unregister(struct mii_bus *mii_bus);
-- 
2.7.4
