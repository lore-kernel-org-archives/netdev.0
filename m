From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 1/8] ethoc: Add device tree configuration
Date: Thu, 25 Nov 2010 13:30:25 +0100
Message-ID: <1290688232-25142-2-git-send-email-jonas@southpole.se>
References: <1290688232-25142-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:38967 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752038Ab0KYMaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 07:30:35 -0500
In-Reply-To: <1290688232-25142-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the ability to describe ethernet devices via a flattened
device tree.  As device tree remains an optional feature, these bits all
need to be guarded by CONFIG_OF ifdefs.

MAC address is settable via the device tree parameter "local-mac-address";
however, the selection of the phy id is limited to probing, for now.

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |   32 ++++++++++++++++++++++++++++++--
 1 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index c5a2fe0..9ea3c54 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -19,6 +19,7 @@
 #include <linux/platform_device.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
+#include <linux/of.h>
 #include <net/ethoc.h>
 
 static int buffer_size = 0x8000; /* 32 KBytes */
@@ -982,10 +983,23 @@ static int __devinit ethoc_probe(struct platform_device *pdev)
 
 	/* Allow the platform setup code to pass in a MAC address. */
 	if (pdev->dev.platform_data) {
-		struct ethoc_platform_data *pdata =
-			(struct ethoc_platform_data *)pdev->dev.platform_data;
+		struct ethoc_platform_data *pdata = pdev->dev.platform_data;
 		memcpy(netdev->dev_addr, pdata->hwaddr, IFHWADDRLEN);
 		priv->phy_id = pdata->phy_id;
+	} else {
+		priv->phy_id = -1;
+
+#ifdef CONFIG_OF
+		{
+		const uint8_t* mac;
+
+		mac = of_get_property(pdev->dev.of_node,
+				      "local-mac-address",
+				      NULL);
+		if (mac)
+			memcpy(netdev->dev_addr, mac, IFHWADDRLEN);
+		}
+#endif
 	}
 
 	/* Check that the given MAC address is valid. If it isn't, read the
@@ -1113,6 +1127,16 @@ static int ethoc_resume(struct platform_device *pdev)
 # define ethoc_resume  NULL
 #endif
 
+#ifdef CONFIG_OF
+static struct of_device_id ethoc_match[] = {
+	{
+		.compatible = "opencores,ethoc",
+	},
+	{},
+};
+MODULE_DEVICE_TABLE(of, ethoc_match);
+#endif
+
 static struct platform_driver ethoc_driver = {
 	.probe   = ethoc_probe,
 	.remove  = __devexit_p(ethoc_remove),
@@ -1120,6 +1144,10 @@ static struct platform_driver ethoc_driver = {
 	.resume  = ethoc_resume,
 	.driver  = {
 		.name = "ethoc",
+		.owner = THIS_MODULE,
+#ifdef CONFIG_OF
+		.of_match_table = ethoc_match,
+#endif
 	},
 };
 
-- 
1.7.1

