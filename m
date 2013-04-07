From: Lars-Peter Clausen <lars@metafoo.de>
Subject: [PATCH 2/2] net: ks8851: Use dev_pm_ops
Date: Sun,  7 Apr 2013 11:33:04 +0200
Message-ID: <1365327184-22956-2-git-send-email-lars@metafoo.de>
References: <1365327184-22956-1-git-send-email-lars@metafoo.de>
Cc: Ben Dooks <ben-linux@fluff.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Lars-Peter Clausen <lars@metafoo.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365327184-22956-1-git-send-email-lars@metafoo.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_pm_ops instead of the deprecated legacy suspend/resume callbacks.

Signed-off-by: Lars-Peter Clausen <lars@metafoo.de>
---
 drivers/net/ethernet/micrel/ks8851.c | 37 +++++++++++++++++++-----------------
 1 file changed, 20 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 84ca876..2d786b4 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1364,35 +1364,39 @@ static int ks8851_read_selftest(struct ks8851_net *ks)
 
 /* driver bus management functions */
 
-#ifdef CONFIG_PM
-static int ks8851_suspend(struct spi_device *spi, pm_message_t state)
+#ifdef CONFIG_PM_SLEEP
+
+static int ks8851_suspend(struct device *dev)
 {
-	struct ks8851_net *ks = dev_get_drvdata(&spi->dev);
-	struct net_device *dev = ks->netdev;
+	struct ks8851_net *ks = dev_get_drvdata(dev);
+	struct net_device *netdev = ks->netdev;
 
-	if (netif_running(dev)) {
-		netif_device_detach(dev);
-		ks8851_net_stop(dev);
+	if (netif_running(netdev)) {
+		netif_device_detach(netdev);
+		ks8851_net_stop(netdev);
 	}
 
 	return 0;
 }
 
-static int ks8851_resume(struct spi_device *spi)
+static int ks8851_resume(struct device *dev)
 {
-	struct ks8851_net *ks = dev_get_drvdata(&spi->dev);
-	struct net_device *dev = ks->netdev;
+	struct ks8851_net *ks = dev_get_drvdata(dev);
+	struct net_device *netdev = ks->netdev;
 
-	if (netif_running(dev)) {
-		ks8851_net_open(dev);
-		netif_device_attach(dev);
+	if (netif_running(netdev)) {
+		ks8851_net_open(netdev);
+		netif_device_attach(netdev);
 	}
 
 	return 0;
 }
+
+static SIMPLE_DEV_PM_OPS(ks8851_pm_ops, ks8851_suspend, ks8851_resume);
+#define KS8851_PM_OPS (&ks8851_pm_ops)
+
 #else
-#define ks8851_suspend NULL
-#define ks8851_resume NULL
+#define KS8851_PM_OPS NULL
 #endif
 
 static int ks8851_probe(struct spi_device *spi)
@@ -1532,11 +1536,10 @@ static struct spi_driver ks8851_driver = {
 	.driver = {
 		.name = "ks8851",
 		.owner = THIS_MODULE,
+		.pm = KS8851_PM_OPS,
 	},
 	.probe = ks8851_probe,
 	.remove = ks8851_remove,
-	.suspend = ks8851_suspend,
-	.resume = ks8851_resume,
 };
 module_spi_driver(ks8851_driver);
 
-- 
1.8.0
