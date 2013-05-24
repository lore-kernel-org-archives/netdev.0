From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: [PATCH 1/1] net: micrel : ks8851-ml: add dt support
Date: Fri, 24 May 2013 11:01:22 +0200
Message-ID: <1369386082-8941-1-git-send-email-plagnioj@jcrosoft.com>
Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	netdev@vger.kernel.org
To: devicetree-discuss@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 10.mo1.mail-out.ovh.net ([178.32.96.102]:54575 "EHLO
	mo1.mail-out.ovh.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760076Ab3EXKY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 06:24:57 -0400
Received: from mail645.ha.ovh.net (b6.ovh.net [213.186.33.56])
	by mo1.mail-out.ovh.net (Postfix) with SMTP id 78F6EFF9E65
	for <netdev@vger.kernel.org>; Fri, 24 May 2013 11:05:39 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Cc: netdev@vger.kernel.org
---
 .../devicetree/bindings/net/micrel-ks8851.txt      |    9 ++++++
 drivers/net/ethernet/micrel/ks8851_mll.c           |   33 +++++++++++++++-----
 2 files changed, 35 insertions(+), 7 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/micrel-ks8851.txt

diff --git a/Documentation/devicetree/bindings/net/micrel-ks8851.txt b/Documentation/devicetree/bindings/net/micrel-ks8851.txt
new file mode 100644
index 0000000..11ace3c
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/micrel-ks8851.txt
@@ -0,0 +1,9 @@
+Micrel KS8851 Ethernet mac
+
+Required properties:
+- compatible = "micrel,ks8851-ml" of parallel interface
+- reg : 2 physical address and size of registers for data and command
+- interrupts : interrupt connection
+
+Optional properties:
+- local-mac-address : Ethernet mac address to use
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index ddaf138..5fed734 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -35,6 +35,9 @@
 #include <linux/delay.h>
 #include <linux/slab.h>
 #include <linux/ks8851_mll.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
+#include <linux/of_net.h>
 
 #define	DRV_NAME	"ks8851_mll"
 
@@ -1524,6 +1527,13 @@ static int ks_hw_init(struct ks_net *ks)
 	return true;
 }
 
+#if defined(CONFIG_OF)
+static const struct of_device_id ks8851_ml_dt_ids[] = {
+	{ .compatible = "micrel,ks8851-mll" },
+	{ /* sentinel */ }
+};
+MODULE_DEVICE_TABLE(of, ks8851_ml_dt_ids);
+#endif
 
 static int ks8851_probe(struct platform_device *pdev)
 {
@@ -1532,7 +1542,7 @@ static int ks8851_probe(struct platform_device *pdev)
 	struct net_device *netdev;
 	struct ks_net *ks;
 	u16 id, data;
-	struct ks8851_mll_platform_data *pdata;
+	const char *mac;
 
 	io_d = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	io_c = platform_get_resource(pdev, IORESOURCE_MEM, 1);
@@ -1619,13 +1629,21 @@ static int ks8851_probe(struct platform_device *pdev)
 	ks_wrreg16(ks, KS_OBCR, data | OBCR_ODS_16MA);
 
 	/* overwriting the default MAC address */
-	pdata = pdev->dev.platform_data;
-	if (!pdata) {
-		netdev_err(netdev, "No platform data\n");
-		err = -ENODEV;
-		goto err_pdata;
+	if (pdev->dev.of_node) {
+		mac = of_get_mac_address(pdev->dev.of_node);
+		if (mac)
+			memcpy(ks->mac_addr, mac, ETH_ALEN);
+	} else {
+		struct ks8851_mll_platform_data *pdata;
+
+		pdata = pdev->dev.platform_data;
+		if (!pdata) {
+			netdev_err(netdev, "No platform data\n");
+			err = -ENODEV;
+			goto err_pdata;
+		}
+		memcpy(ks->mac_addr, pdata->mac_addr, ETH_ALEN);
 	}
-	memcpy(ks->mac_addr, pdata->mac_addr, 6);
 	if (!is_valid_ether_addr(ks->mac_addr)) {
 		/* Use random MAC address if none passed */
 		eth_random_addr(ks->mac_addr);
@@ -1680,6 +1698,7 @@ static struct platform_driver ks8851_platform_driver = {
 	.driver = {
 		.name = DRV_NAME,
 		.owner = THIS_MODULE,
+		.of_match_table	= of_match_ptr(ks8851_ml_dt_ids),
 	},
 	.probe = ks8851_probe,
 	.remove = ks8851_remove,
-- 
1.7.10.4
