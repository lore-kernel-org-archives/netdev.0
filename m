From: olof@lixom.net (Olof Johansson)
Subject: [PATCH] [1/2] phylib: cleanup marvell.c a bit
Date: Tue, 3 Jul 2007 16:23:46 -0500
Message-ID: <20070703212346.GB26181@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:54856 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755041AbXGCVNQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 17:13:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simplify the marvell driver init a bit: Make the supported devices an
array instead of explicitly registering each structure. This makes it
considerably easier to add new devices down the road.


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: mainline/drivers/net/phy/marvell.c
===================================================================
--- mainline.orig/drivers/net/phy/marvell.c
+++ mainline/drivers/net/phy/marvell.c
@@ -238,77 +238,71 @@ static int m88e1145_config_init(struct p
 	return 0;
 }
 
-static struct phy_driver m88e1101_driver = {
-	.phy_id = 0x01410c60,
-	.phy_id_mask = 0xfffffff0,
-	.name = "Marvell 88E1101",
-	.features = PHY_GBIT_FEATURES,
-	.flags = PHY_HAS_INTERRUPT,
-	.config_aneg = &marvell_config_aneg,
-	.read_status = &genphy_read_status,
-	.ack_interrupt = &marvell_ack_interrupt,
-	.config_intr = &marvell_config_intr,
-	.driver = {.owner = THIS_MODULE,},
-};
-
-static struct phy_driver m88e1111_driver = {
-	.phy_id = 0x01410cc0,
-	.phy_id_mask = 0xfffffff0,
-	.name = "Marvell 88E1111",
-	.features = PHY_GBIT_FEATURES,
-	.flags = PHY_HAS_INTERRUPT,
-	.config_aneg = &marvell_config_aneg,
-	.read_status = &genphy_read_status,
-	.ack_interrupt = &marvell_ack_interrupt,
-	.config_intr = &marvell_config_intr,
-	.config_init = &m88e1111_config_init,
-	.driver = {.owner = THIS_MODULE,},
-};
-
-static struct phy_driver m88e1145_driver = {
-	.phy_id = 0x01410cd0,
-	.phy_id_mask = 0xfffffff0,
-	.name = "Marvell 88E1145",
-	.features = PHY_GBIT_FEATURES,
-	.flags = PHY_HAS_INTERRUPT,
-	.config_init = &m88e1145_config_init,
-	.config_aneg = &marvell_config_aneg,
-	.read_status = &genphy_read_status,
-	.ack_interrupt = &marvell_ack_interrupt,
-	.config_intr = &marvell_config_intr,
-	.driver = {.owner = THIS_MODULE,},
+static struct phy_driver marvell_drivers[] = {
+	{
+		.phy_id = 0x01410c60,
+		.phy_id_mask = 0xfffffff0,
+		.name = "Marvell 88E1101",
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.config_aneg = &marvell_config_aneg,
+		.read_status = &genphy_read_status,
+		.ack_interrupt = &marvell_ack_interrupt,
+		.config_intr = &marvell_config_intr,
+		.driver = {.owner = THIS_MODULE,},
+	},
+	{
+		.phy_id = 0x01410cc0,
+		.phy_id_mask = 0xfffffff0,
+		.name = "Marvell 88E1111",
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.config_init = &m88e1111_config_init,
+		.config_aneg = &marvell_config_aneg,
+		.read_status = &genphy_read_status,
+		.ack_interrupt = &marvell_ack_interrupt,
+		.config_intr = &marvell_config_intr,
+		.driver = {.owner = THIS_MODULE,},
+	},
+	{
+		.phy_id = 0x01410cd0,
+		.phy_id_mask = 0xfffffff0,
+		.name = "Marvell 88E1145",
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.config_init = &m88e1145_config_init,
+		.config_aneg = &marvell_config_aneg,
+		.read_status = &genphy_read_status,
+		.ack_interrupt = &marvell_ack_interrupt,
+		.config_intr = &marvell_config_intr,
+		.driver = {.owner = THIS_MODULE,},
+	}
 };
 
 static int __init marvell_init(void)
 {
 	int ret;
+	int i;
 
-	ret = phy_driver_register(&m88e1101_driver);
-	if (ret)
-		return ret;
-
-	ret = phy_driver_register(&m88e1111_driver);
-	if (ret)
-		goto err1111;
-
-	ret = phy_driver_register(&m88e1145_driver);
-	if (ret)
-		goto err1145;
+	for (i = 0; i < ARRAY_SIZE(marvell_drivers); i++) {
+		ret = phy_driver_register(&marvell_drivers[i]);
 
-	return 0;
+		if (ret) {
+			while (i-- > 0)
+				phy_driver_unregister(&marvell_drivers[i]);
+			return ret;
+		}
+	}
 
-err1145:
-	phy_driver_unregister(&m88e1111_driver);
-err1111:
-	phy_driver_unregister(&m88e1101_driver);
-	return ret;
+	return 0;
 }
 
 static void __exit marvell_exit(void)
 {
-	phy_driver_unregister(&m88e1101_driver);
-	phy_driver_unregister(&m88e1111_driver);
-	phy_driver_unregister(&m88e1145_driver);
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(marvell_drivers); i++)
+		phy_driver_unregister(&marvell_drivers[i]);
 }
 
 module_init(marvell_init);
