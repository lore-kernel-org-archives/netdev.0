From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH 2/3] Add support for the Cicada 8201 PHY
Date: Wed, 28 Jun 2006 21:13:23 -0500
Message-ID: <20060628211323.63bf260e.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:32212 "EHLO
	de01egw02.freescale.net") by vger.kernel.org with ESMTP
	id S1751689AbWF2CNp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 22:13:45 -0400
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for the Cicada 8201 PHY, a.k.a Vitesse VSC8201.  This PHY is present on the MPC8349mITX.

Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
Signed-off-by: Andy Fleming <afleming@freescale.com>
---

 drivers/net/phy/cicada.c |   42 ++++++++++++++++++++++++++++++++++++------
 1 files changed, 36 insertions(+), 6 deletions(-)

9834dea86d3620e223584ebc2b04fda4e44092a9
diff --git a/drivers/net/phy/cicada.c b/drivers/net/phy/cicada.c
index 7d8d534..b755c86 100644
--- a/drivers/net/phy/cicada.c
+++ b/drivers/net/phy/cicada.c
@@ -104,7 +104,22 @@ static int cis820x_config_intr(struct ph
 	return err;
 }
 
-/* Cicada 820x */
+/* Cicada 8201, a.k.a Vitesse VSC8201 */
+static struct phy_driver cis8201_driver = {
+	.phy_id		= 0x000fc410,
+	.name		= "Cicada Cis8201",
+	.phy_id_mask	= 0x000ffff0,
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_init	= &cis820x_config_init,
+	.config_aneg	= &genphy_config_aneg,
+	.read_status	= &genphy_read_status,
+	.ack_interrupt	= &cis820x_ack_interrupt,
+	.config_intr	= &cis820x_config_intr,
+	.driver 	= { .owner = THIS_MODULE,},
+};
+
+/* Cicada 8204 */
 static struct phy_driver cis8204_driver = {
 	.phy_id		= 0x000fc440,
 	.name		= "Cicada Cis8204",
@@ -119,15 +134,30 @@ static struct phy_driver cis8204_driver 
 	.driver 	= { .owner = THIS_MODULE,},
 };
 
-static int __init cis8204_init(void)
+static int __init cicada_init(void)
 {
-	return phy_driver_register(&cis8204_driver);
+	int ret;
+
+	ret = phy_driver_register(&cis8204_driver);
+	if (ret)
+		goto err1;
+
+	ret = phy_driver_register(&cis8201_driver);
+	if (ret)
+		goto err2;
+	return 0;
+
+err2:
+	phy_driver_unregister(&cis8204_driver);
+err1:
+	return ret;
 }
 
-static void __exit cis8204_exit(void)
+static void __exit cicada_exit(void)
 {
 	phy_driver_unregister(&cis8204_driver);
+	phy_driver_unregister(&cis8201_driver);
 }
 
-module_init(cis8204_init);
-module_exit(cis8204_exit);
+module_init(cicada_init);
+module_exit(cicada_exit);
-- 
1.2.4

