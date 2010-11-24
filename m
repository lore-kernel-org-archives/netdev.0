From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 1/8] ethoc: Add device tree configuration
Date: Wed, 24 Nov 2010 14:40:51 +0100
Message-ID: <1290606058-26703-2-git-send-email-jonas@southpole.se>
References: <1290606058-26703-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:38157 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755310Ab0KXOCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 09:02:51 -0500
In-Reply-To: <1290606058-26703-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the ability to describe ethernet devices via a flattened
device tree.  As device tree remains an optional feature, these bits all
need to be guarded by CONFIG_OF ifdefs.

MAC address is settable via the device tree parameter "local-mac-address";
however, the selection of the phy id is limited to probing, for now.

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |   31 ++++++++++++++++++++++++++++++-
 1 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index c5a2fe0..6b4b9e1 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -19,6 +19,7 @@
 #include <linux/platform_device.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
+#include <linux/of.h>
 #include <net/ethoc.h>
 
 static int buffer_size = 0x8000; /* 32 KBytes */
@@ -986,7 +987,21 @@ static int __devinit ethoc_probe(struct platform_device *pdev)
 			(struct ethoc_platform_data *)pdev->dev.platform_data;
 		memcpy(netdev->dev_addr, pdata->hwaddr, IFHWADDRLEN);
 		priv->phy_id = pdata->phy_id;
-	}
+	} else {
+		priv->phy_id = -1;
+
+#ifdef CONFIG_OF
+		{
+		uint8_t* mac;
+
+		mac = (uint8_t*)of_get_property(pdev->dev.of_node,
+						"local-mac-address",
+						NULL);
+		if (mac)
+			memcpy(netdev->dev_addr, mac, IFHWADDRLEN);
+		}
+#endif
+	} 
 
 	/* Check that the given MAC address is valid. If it isn't, read the
 	 * current MAC from the controller. */
@@ -1113,6 +1128,16 @@ static int ethoc_resume(struct platform_device *pdev)
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
@@ -1120,6 +1145,10 @@ static struct platform_driver ethoc_driver = {
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

