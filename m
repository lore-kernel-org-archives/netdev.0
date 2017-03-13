From: Alban <albeu@free.fr>
Subject: [PATCH 2/7] ath9k: ahb: Add OF support
Date: Mon, 13 Mar 2017 22:05:10 +0100
Message-ID: <1489439116-4233-2-git-send-email-albeu@free.fr>
References: <1489439116-4233-1-git-send-email-albeu@free.fr>
Cc: John Crispin <john@phrozen.org>, Alban <albeu@free.fr>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489439116-4233-1-git-send-email-albeu@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow registering ath9k AHB devices defined in DT. This just add the
compatible strings to allow matching the driver and setting the proper
device ID.

Signed-off-by: Alban <albeu@free.fr>
---
 drivers/net/wireless/ath/ath9k/ahb.c | 47 +++++++++++++++++++++++++++++++++---
 1 file changed, 43 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ahb.c b/drivers/net/wireless/ath/ath9k/ahb.c
index 2bd982c..36a2645 100644
--- a/drivers/net/wireless/ath/ath9k/ahb.c
+++ b/drivers/net/wireless/ath/ath9k/ahb.c
@@ -18,6 +18,7 @@
 
 #include <linux/nl80211.h>
 #include <linux/platform_device.h>
+#include <linux/of_device.h>
 #include <linux/module.h>
 #include "ath9k.h"
 
@@ -49,6 +50,33 @@ static const struct platform_device_id ath9k_platform_id_table[] = {
 	{},
 };
 
+#ifdef CONFIG_OF
+static const struct of_device_id ath_ahb_of_match[] = {
+	{
+		.compatible = "qca,ar9100-wmac",
+		.data = (void *)AR5416_AR9100_DEVID
+	},
+	{
+		.compatible = "qca,ar9330-wmac",
+		.data = (void *)AR9300_DEVID_AR9330
+	},
+	{
+		.compatible = "qca,ar9340-wmac",
+		.data = (void *)AR9300_DEVID_AR9340
+	},
+	{
+		.compatible = "qca,qca9550-wmac",
+		.data = (void *)AR9300_DEVID_QCA955X
+	},
+	{
+		.compatible = "qca,qca9530-wmac",
+		.data = (void *)AR9300_DEVID_AR953X
+	},
+	{},
+};
+MODULE_DEVICE_TABLE(of, ath_ahb_of_match);
+#endif
+
 /* return bus cachesize in 4B word units */
 static void ath_ahb_read_cachesize(struct ath_common *common, int *csz)
 {
@@ -79,10 +107,20 @@ static int ath_ahb_probe(struct platform_device *pdev)
 	int ret = 0;
 	struct ath_hw *ah;
 	char hw_name[64];
+	u16 devid;
 
-	if (!dev_get_platdata(&pdev->dev)) {
-		dev_err(&pdev->dev, "no platform data specified\n");
-		return -EINVAL;
+	if (id) {
+		devid = id->driver_data;
+	} else {
+		const struct of_device_id *match;
+
+		match = of_match_device(ath_ahb_of_match, &pdev->dev);
+		if (!match) {
+			dev_err(&pdev->dev, "no device match found\n");
+			return -EINVAL;
+		}
+
+		devid = (u16)(unsigned long)match->data;
 	}
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -127,7 +165,7 @@ static int ath_ahb_probe(struct platform_device *pdev)
 		goto err_free_hw;
 	}
 
-	ret = ath9k_init_device(id->driver_data, sc, &ath_ahb_bus_ops);
+	ret = ath9k_init_device(devid, sc, &ath_ahb_bus_ops);
 	if (ret) {
 		dev_err(&pdev->dev, "failed to initialize device\n");
 		goto err_irq;
@@ -167,6 +205,7 @@ static struct platform_driver ath_ahb_driver = {
 	.remove     = ath_ahb_remove,
 	.driver		= {
 		.name	= "ath9k",
+		.of_match_table = of_match_ptr(ath_ahb_of_match),
 	},
 	.id_table    = ath9k_platform_id_table,
 };
-- 
2.7.4
