From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH 2/4] net: bcm63xx: Use platform_register/unregister_drivers()
Date: Wed,  2 Dec 2015 17:30:27 +0100
Message-ID: <1449073829-12438-2-git-send-email-thierry.reding@gmail.com>
References: <1449073829-12438-1-git-send-email-thierry.reding@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:33496 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbbLBQad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 11:30:33 -0500
In-Reply-To: <1449073829-12438-1-git-send-email-thierry.reding@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thierry Reding <treding@nvidia.com>

These new helpers simplify implementing multi-driver modules and
properly handle failure to register one driver by unregistering all
previously registered drivers.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
Applies on top of next-20151127.

 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 28 ++++++++--------------------
 1 file changed, 8 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 8b1929e9f698..a54bafad3538 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -2884,33 +2884,21 @@ struct platform_driver bcm63xx_enet_shared_driver = {
 	},
 };
 
+static struct platform_driver * const drivers[] = {
+	&bcm63xx_enet_shared_driver,
+	&bcm63xx_enet_driver,
+	&bcm63xx_enetsw_driver,
+};
+
 /* entry point */
 static int __init bcm_enet_init(void)
 {
-	int ret;
-
-	ret = platform_driver_register(&bcm63xx_enet_shared_driver);
-	if (ret)
-		return ret;
-
-	ret = platform_driver_register(&bcm63xx_enet_driver);
-	if (ret)
-		platform_driver_unregister(&bcm63xx_enet_shared_driver);
-
-	ret = platform_driver_register(&bcm63xx_enetsw_driver);
-	if (ret) {
-		platform_driver_unregister(&bcm63xx_enet_driver);
-		platform_driver_unregister(&bcm63xx_enet_shared_driver);
-	}
-
-	return ret;
+	return platform_register_drivers(drivers, ARRAY_SIZE(drivers));
 }
 
 static void __exit bcm_enet_exit(void)
 {
-	platform_driver_unregister(&bcm63xx_enet_driver);
-	platform_driver_unregister(&bcm63xx_enetsw_driver);
-	platform_driver_unregister(&bcm63xx_enet_shared_driver);
+	platform_unregister_drivers(drivers, ARRAY_SIZE(drivers));
 }
 
 
-- 
2.5.0
