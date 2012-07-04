From: Christian Hohnstaedt <chohnstaedt@innominate.com>
Subject: [PATCH] phylib: Support registering a bunch of drivers
Date: Wed, 4 Jul 2012 17:44:34 +0200
Message-ID: <20120704154434.GZ19422@elara.bln.innominate.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.innominate.com ([77.245.32.75]:58679 "EHLO
	home.innominate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754341Ab2GDPog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 11:44:36 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by home.innominate.com (Postfix) with ESMTP id 23E5923244
	for <netdev@vger.kernel.org>; Wed,  4 Jul 2012 17:44:35 +0200 (CEST)
Received: from home.innominate.com ([127.0.0.1])
	by localhost (innominate.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id bxTwarHhqR7l for <netdev@vger.kernel.org>;
	Wed,  4 Jul 2012 17:44:35 +0200 (CEST)
Received: from elara.bln.innominate.local (elara.bln.innominate.local [10.1.140.6])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(No client certificate requested)
	by home.innominate.com (Postfix) with ESMTPS id E5AAD230BC
	for <netdev@vger.kernel.org>; Wed,  4 Jul 2012 17:44:34 +0200 (CEST)
Received: from chris by elara.bln.innominate.local with local (Exim 4.72)
	(envelope-from <chohnstaedt@innominate.com>)
	id 1SmRko-0001IG-SX
	for netdev@vger.kernel.org; Wed, 04 Jul 2012 17:44:34 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If registering of one of them fails, all already registered drivers
of this module will be unregistered.

Use the new register/unregister functions in all drivers
registering more than one driver.

amd.c, realtek.c: Simplify: directly return registration result.

Tested with broadcom.c
All others compile-tested.

Signed-off-by: Christian Hohnstaedt <chohnstaedt@innominate.com>
---
 drivers/net/phy/amd.c        |    8 +---
 drivers/net/phy/bcm63xx.c    |   31 +++--------
 drivers/net/phy/bcm87xx.c    |   24 +++------
 drivers/net/phy/broadcom.c   |  119 ++++++------------------------------------
 drivers/net/phy/cicada.c     |   35 ++++---------
 drivers/net/phy/davicom.c    |   41 +++-----------
 drivers/net/phy/icplus.c     |   31 +++--------
 drivers/net/phy/lxt.c        |   47 ++++------------
 drivers/net/phy/marvell.c    |   22 ++------
 drivers/net/phy/micrel.c     |   62 ++++------------------
 drivers/net/phy/phy_device.c |   25 +++++++++
 drivers/net/phy/realtek.c    |    6 +--
 drivers/net/phy/smsc.c       |   64 ++++-------------------
 drivers/net/phy/ste10Xp.c    |   21 +++-----
 drivers/net/phy/vitesse.c    |   52 ++++++++-----------
 include/linux/phy.h          |    2 +
 16 files changed, 159 insertions(+), 431 deletions(-)

diff --git a/drivers/net/phy/amd.c b/drivers/net/phy/amd.c
index cfabd5f..a3fb5ce 100644
--- a/drivers/net/phy/amd.c
+++ b/drivers/net/phy/amd.c
@@ -77,13 +77,7 @@ static struct phy_driver am79c_driver = {
 
 static int __init am79c_init(void)
 {
-	int ret;
-
-	ret = phy_driver_register(&am79c_driver);
-	if (ret)
-		return ret;
-
-	return 0;
+	return phy_driver_register(&am79c_driver);
 }
 
 static void __exit am79c_exit(void)
diff --git a/drivers/net/phy/bcm63xx.c b/drivers/net/phy/bcm63xx.c
index cd802eb..d936ca8 100644
--- a/drivers/net/phy/bcm63xx.c
+++ b/drivers/net/phy/bcm63xx.c
@@ -71,7 +71,8 @@ static int bcm63xx_config_intr(struct phy_device *phydev)
 	return err;
 }
 
-static struct phy_driver bcm63xx_1_driver = {
+static struct phy_driver bcm63xx_driver[] = {
+{
 	.phy_id		= 0x00406000,
 	.phy_id_mask	= 0xfffffc00,
 	.name		= "Broadcom BCM63XX (1)",
@@ -84,10 +85,8 @@ static struct phy_driver bcm63xx_1_driver = {
 	.ack_interrupt	= bcm63xx_ack_interrupt,
 	.config_intr	= bcm63xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
-};
-
-/* same phy as above, with just a different OUI */
-static struct phy_driver bcm63xx_2_driver = {
+}, {
+	/* same phy as above, with just a different OUI */
 	.phy_id		= 0x002bdc00,
 	.phy_id_mask	= 0xfffffc00,
 	.name		= "Broadcom BCM63XX (2)",
@@ -99,30 +98,18 @@ static struct phy_driver bcm63xx_2_driver = {
 	.ack_interrupt	= bcm63xx_ack_interrupt,
 	.config_intr	= bcm63xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
-};
+} };
 
 static int __init bcm63xx_phy_init(void)
 {
-	int ret;
-
-	ret = phy_driver_register(&bcm63xx_1_driver);
-	if (ret)
-		goto out_63xx_1;
-	ret = phy_driver_register(&bcm63xx_2_driver);
-	if (ret)
-		goto out_63xx_2;
-	return ret;
-
-out_63xx_2:
-	phy_driver_unregister(&bcm63xx_1_driver);
-out_63xx_1:
-	return ret;
+	return phy_drivers_register(bcm63xx_driver,
+		ARRAY_SIZE(bcm63xx_driver));
 }
 
 static void __exit bcm63xx_phy_exit(void)
 {
-	phy_driver_unregister(&bcm63xx_1_driver);
-	phy_driver_unregister(&bcm63xx_2_driver);
+	phy_drivers_unregister(bcm63xx_driver,
+		ARRAY_SIZE(bcm63xx_driver));
 }
 
 module_init(bcm63xx_phy_init);
diff --git a/drivers/net/phy/bcm87xx.c b/drivers/net/phy/bcm87xx.c
index f5f0562..8d02ae5 100644
--- a/drivers/net/phy/bcm87xx.c
+++ b/drivers/net/phy/bcm87xx.c
@@ -186,7 +186,8 @@ static int bcm8727_match_phy_device(struct phy_device *phydev)
 	return phydev->c45_ids.device_ids[4] == PHY_ID_BCM8727;
 }
 
-static struct phy_driver bcm8706_driver = {
+static struct phy_driver bcm87xx_driver[] = {
+{
 	.phy_id		= PHY_ID_BCM8706,
 	.phy_id_mask	= 0xffffffff,
 	.name		= "Broadcom BCM8706",
@@ -199,9 +200,7 @@ static struct phy_driver bcm8706_driver = {
 	.did_interrupt	= bcm87xx_did_interrupt,
 	.match_phy_device = bcm8706_match_phy_device,
 	.driver		= { .owner = THIS_MODULE },
-};
-
-static struct phy_driver bcm8727_driver = {
+}, {
 	.phy_id		= PHY_ID_BCM8727,
 	.phy_id_mask	= 0xffffffff,
 	.name		= "Broadcom BCM8727",
@@ -214,25 +213,18 @@ static struct phy_driver bcm8727_driver = {
 	.did_interrupt	= bcm87xx_did_interrupt,
 	.match_phy_device = bcm8727_match_phy_device,
 	.driver		= { .owner = THIS_MODULE },
-};
+} };
 
 static int __init bcm87xx_init(void)
 {
-	int ret;
-
-	ret = phy_driver_register(&bcm8706_driver);
-	if (ret)
-		goto err;
-
-	ret = phy_driver_register(&bcm8727_driver);
-err:
-	return ret;
+	return phy_drivers_register(bcm87xx_driver,
+		ARRAY_SIZE(bcm87xx_driver));
 }
 module_init(bcm87xx_init);
 
 static void __exit bcm87xx_exit(void)
 {
-	phy_driver_unregister(&bcm8706_driver);
-	phy_driver_unregister(&bcm8727_driver);
+	phy_drivers_unregister(bcm87xx_driver,
+		ARRAY_SIZE(bcm87xx_driver));
 }
 module_exit(bcm87xx_exit);
diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 60338ff..2e3694b 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -682,7 +682,8 @@ static int brcm_fet_config_intr(struct phy_device *phydev)
 	return err;
 }
 
-static struct phy_driver bcm5411_driver = {
+static struct phy_driver broadcom_drivers[] = {
+{
 	.phy_id		= PHY_ID_BCM5411,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5411",
@@ -695,9 +696,7 @@ static struct phy_driver bcm5411_driver = {
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
-};
-
-static struct phy_driver bcm5421_driver = {
+}, {
 	.phy_id		= PHY_ID_BCM5421,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5421",
@@ -710,9 +709,7 @@ static struct phy_driver bcm5421_driver = {
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
-};
-
-static struct phy_driver bcm5461_driver = {
+}, {
 	.phy_id		= PHY_ID_BCM5461,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5461",
@@ -725,9 +722,7 @@ static struct phy_driver bcm5461_driver = {
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
-};
-
-static struct phy_driver bcm5464_driver = {
+}, {
 	.phy_id		= PHY_ID_BCM5464,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5464",
@@ -740,9 +735,7 @@ static struct phy_driver bcm5464_driver = {
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
-};
-
-static struct phy_driver bcm5481_driver = {
+}, {
 	.phy_id		= PHY_ID_BCM5481,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5481",
@@ -755,9 +748,7 @@ static struct phy_driver bcm5481_driver = {
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
-};
-
-static struct phy_driver bcm5482_driver = {
+}, {
 	.phy_id		= PHY_ID_BCM5482,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5482",
@@ -770,9 +761,7 @@ static struct phy_driver bcm5482_driver = {
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
-};
-
-static struct phy_driver bcm50610_driver = {
+}, {
 	.phy_id		= PHY_ID_BCM50610,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM50610",
@@ -785,9 +774,7 @@ static struct phy_driver bcm50610_driver = {
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
-};
-
-static struct phy_driver bcm50610m_driver = {
+}, {
 	.phy_id		= PHY_ID_BCM50610M,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM50610M",
@@ -800,9 +787,7 @@ static struct phy_driver bcm50610m_driver = {
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
-};
-
-static struct phy_driver bcm57780_driver = {
+}, {
 	.phy_id		= PHY_ID_BCM57780,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM57780",
@@ -815,9 +800,7 @@ static struct phy_driver bcm57780_driver = {
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
-};
-
-static struct phy_driver bcmac131_driver = {
+}, {
 	.phy_id		= PHY_ID_BCMAC131,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCMAC131",
@@ -830,9 +813,7 @@ static struct phy_driver bcmac131_driver = {
 	.ack_interrupt	= brcm_fet_ack_interrupt,
 	.config_intr	= brcm_fet_config_intr,
 	.driver		= { .owner = THIS_MODULE },
-};
-
-static struct phy_driver bcm5241_driver = {
+}, {
 	.phy_id		= PHY_ID_BCM5241,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5241",
@@ -845,84 +826,18 @@ static struct phy_driver bcm5241_driver = {
 	.ack_interrupt	= brcm_fet_ack_interrupt,
 	.config_intr	= brcm_fet_config_intr,
 	.driver		= { .owner = THIS_MODULE },
-};
+} };
 
 static int __init broadcom_init(void)
 {
-	int ret;
-
-	ret = phy_driver_register(&bcm5411_driver);
-	if (ret)
-		goto out_5411;
-	ret = phy_driver_register(&bcm5421_driver);
-	if (ret)
-		goto out_5421;
-	ret = phy_driver_register(&bcm5461_driver);
-	if (ret)
-		goto out_5461;
-	ret = phy_driver_register(&bcm5464_driver);
-	if (ret)
-		goto out_5464;
-	ret = phy_driver_register(&bcm5481_driver);
-	if (ret)
-		goto out_5481;
-	ret = phy_driver_register(&bcm5482_driver);
-	if (ret)
-		goto out_5482;
-	ret = phy_driver_register(&bcm50610_driver);
-	if (ret)
-		goto out_50610;
-	ret = phy_driver_register(&bcm50610m_driver);
-	if (ret)
-		goto out_50610m;
-	ret = phy_driver_register(&bcm57780_driver);
-	if (ret)
-		goto out_57780;
-	ret = phy_driver_register(&bcmac131_driver);
-	if (ret)
-		goto out_ac131;
-	ret = phy_driver_register(&bcm5241_driver);
-	if (ret)
-		goto out_5241;
-	return ret;
-
-out_5241:
-	phy_driver_unregister(&bcmac131_driver);
-out_ac131:
-	phy_driver_unregister(&bcm57780_driver);
-out_57780:
-	phy_driver_unregister(&bcm50610m_driver);
-out_50610m:
-	phy_driver_unregister(&bcm50610_driver);
-out_50610:
-	phy_driver_unregister(&bcm5482_driver);
-out_5482:
-	phy_driver_unregister(&bcm5481_driver);
-out_5481:
-	phy_driver_unregister(&bcm5464_driver);
-out_5464:
-	phy_driver_unregister(&bcm5461_driver);
-out_5461:
-	phy_driver_unregister(&bcm5421_driver);
-out_5421:
-	phy_driver_unregister(&bcm5411_driver);
-out_5411:
-	return ret;
+	return phy_drivers_register(broadcom_drivers,
+		ARRAY_SIZE(broadcom_drivers));
 }
 
 static void __exit broadcom_exit(void)
 {
-	phy_driver_unregister(&bcm5241_driver);
-	phy_driver_unregister(&bcmac131_driver);
-	phy_driver_unregister(&bcm57780_driver);
-	phy_driver_unregister(&bcm50610m_driver);
-	phy_driver_unregister(&bcm50610_driver);
-	phy_driver_unregister(&bcm5482_driver);
-	phy_driver_unregister(&bcm5481_driver);
-	phy_driver_unregister(&bcm5464_driver);
-	phy_driver_unregister(&bcm5461_driver);
-	phy_driver_unregister(&bcm5421_driver);
-	phy_driver_unregister(&bcm5411_driver);
+	phy_drivers_unregister(broadcom_drivers,
+		ARRAY_SIZE(broadcom_drivers));
 }
 
 module_init(broadcom_init);
diff --git a/drivers/net/phy/cicada.c b/drivers/net/phy/cicada.c
index d281731..16d6960 100644
--- a/drivers/net/phy/cicada.c
+++ b/drivers/net/phy/cicada.c
@@ -102,7 +102,8 @@ static int cis820x_config_intr(struct phy_device *phydev)
 }
 
 /* Cicada 8201, a.k.a Vitesse VSC8201 */
-static struct phy_driver cis8201_driver = {
+static struct phy_driver cis820x_driver[] = {
+{
 	.phy_id		= 0x000fc410,
 	.name		= "Cicada Cis8201",
 	.phy_id_mask	= 0x000ffff0,
@@ -113,11 +114,8 @@ static struct phy_driver cis8201_driver = {
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &cis820x_ack_interrupt,
 	.config_intr	= &cis820x_config_intr,
-	.driver 	= { .owner = THIS_MODULE,},
-};
-
-/* Cicada 8204 */
-static struct phy_driver cis8204_driver = {
+	.driver		= { .owner = THIS_MODULE,},
+}, {
 	.phy_id		= 0x000fc440,
 	.name		= "Cicada Cis8204",
 	.phy_id_mask	= 0x000fffc0,
@@ -128,32 +126,19 @@ static struct phy_driver cis8204_driver = {
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &cis820x_ack_interrupt,
 	.config_intr	= &cis820x_config_intr,
-	.driver 	= { .owner = THIS_MODULE,},
-};
+	.driver		= { .owner = THIS_MODULE,},
+} };
 
 static int __init cicada_init(void)
 {
-	int ret;
-
-	ret = phy_driver_register(&cis8204_driver);
-	if (ret)
-		goto err1;
-
-	ret = phy_driver_register(&cis8201_driver);
-	if (ret)
-		goto err2;
-	return 0;
-
-err2:
-	phy_driver_unregister(&cis8204_driver);
-err1:
-	return ret;
+	return phy_drivers_register(cis820x_driver,
+		ARRAY_SIZE(cis820x_driver));
 }
 
 static void __exit cicada_exit(void)
 {
-	phy_driver_unregister(&cis8204_driver);
-	phy_driver_unregister(&cis8201_driver);
+	phy_drivers_unregister(cis820x_driver,
+		ARRAY_SIZE(cis820x_driver));
 }
 
 module_init(cicada_init);
diff --git a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
index 5f59cc0..a8eb820 100644
--- a/drivers/net/phy/davicom.c
+++ b/drivers/net/phy/davicom.c
@@ -144,7 +144,8 @@ static int dm9161_ack_interrupt(struct phy_device *phydev)
 	return (err < 0) ? err : 0;
 }
 
-static struct phy_driver dm9161e_driver = {
+static struct phy_driver dm91xx_driver[] = {
+{
 	.phy_id		= 0x0181b880,
 	.name		= "Davicom DM9161E",
 	.phy_id_mask	= 0x0ffffff0,
@@ -153,9 +154,7 @@ static struct phy_driver dm9161e_driver = {
 	.config_aneg	= dm9161_config_aneg,
 	.read_status	= genphy_read_status,
 	.driver		= { .owner = THIS_MODULE,},
-};
-
-static struct phy_driver dm9161a_driver = {
+}, {
 	.phy_id		= 0x0181b8a0,
 	.name		= "Davicom DM9161A",
 	.phy_id_mask	= 0x0ffffff0,
@@ -164,9 +163,7 @@ static struct phy_driver dm9161a_driver = {
 	.config_aneg	= dm9161_config_aneg,
 	.read_status	= genphy_read_status,
 	.driver		= { .owner = THIS_MODULE,},
-};
-
-static struct phy_driver dm9131_driver = {
+}, {
 	.phy_id		= 0x00181b80,
 	.name		= "Davicom DM9131",
 	.phy_id_mask	= 0x0ffffff0,
@@ -177,38 +174,18 @@ static struct phy_driver dm9131_driver = {
 	.ack_interrupt	= dm9161_ack_interrupt,
 	.config_intr	= dm9161_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
-};
+} };
 
 static int __init davicom_init(void)
 {
-	int ret;
-
-	ret = phy_driver_register(&dm9161e_driver);
-	if (ret)
-		goto err1;
-
-	ret = phy_driver_register(&dm9161a_driver);
-	if (ret)
-		goto err2;
-
-	ret = phy_driver_register(&dm9131_driver);
-	if (ret)
-		goto err3;
-	return 0;
-
- err3:
-	phy_driver_unregister(&dm9161a_driver);
- err2:
-	phy_driver_unregister(&dm9161e_driver);
- err1:
-	return ret;
+	return phy_drivers_register(dm91xx_driver,
+		ARRAY_SIZE(dm91xx_driver));
 }
 
 static void __exit davicom_exit(void)
 {
-	phy_driver_unregister(&dm9161e_driver);
-	phy_driver_unregister(&dm9161a_driver);
-	phy_driver_unregister(&dm9131_driver);
+	phy_drivers_unregister(dm91xx_driver,
+		ARRAY_SIZE(dm91xx_driver));
 }
 
 module_init(davicom_init);
diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index 47f8e89..0d2f04f 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -202,7 +202,8 @@ static int ip101a_g_ack_interrupt(struct phy_device *phydev)
 	return 0;
 }
 
-static struct phy_driver ip175c_driver = {
+static struct phy_driver icplus_driver[] = {
+{
 	.phy_id		= 0x02430d80,
 	.name		= "ICPlus IP175C",
 	.phy_id_mask	= 0x0ffffff0,
@@ -213,9 +214,7 @@ static struct phy_driver ip175c_driver = {
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
-};
-
-static struct phy_driver ip1001_driver = {
+}, {
 	.phy_id		= 0x02430d90,
 	.name		= "ICPlus IP1001",
 	.phy_id_mask	= 0x0ffffff0,
@@ -227,9 +226,7 @@ static struct phy_driver ip1001_driver = {
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
-};
-
-static struct phy_driver ip101a_g_driver = {
+}, {
 	.phy_id		= 0x02430c54,
 	.name		= "ICPlus IP101A/G",
 	.phy_id_mask	= 0x0ffffff0,
@@ -243,28 +240,18 @@ static struct phy_driver ip101a_g_driver = {
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
-};
+} };
 
 static int __init icplus_init(void)
 {
-	int ret = 0;
-
-	ret = phy_driver_register(&ip1001_driver);
-	if (ret < 0)
-		return -ENODEV;
-
-	ret = phy_driver_register(&ip101a_g_driver);
-	if (ret < 0)
-		return -ENODEV;
-
-	return phy_driver_register(&ip175c_driver);
+	return phy_drivers_register(icplus_driver,
+		ARRAY_SIZE(icplus_driver));
 }
 
 static void __exit icplus_exit(void)
 {
-	phy_driver_unregister(&ip1001_driver);
-	phy_driver_unregister(&ip101a_g_driver);
-	phy_driver_unregister(&ip175c_driver);
+	phy_drivers_unregister(icplus_driver,
+		ARRAY_SIZE(icplus_driver));
 }
 
 module_init(icplus_init);
diff --git a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
index 6f6e8b6..f679cfe 100644
--- a/drivers/net/phy/lxt.c
+++ b/drivers/net/phy/lxt.c
@@ -149,7 +149,8 @@ static int lxt973_config_aneg(struct phy_device *phydev)
 	return phydev->priv ? 0 : genphy_config_aneg(phydev);
 }
 
-static struct phy_driver lxt970_driver = {
+static struct phy_driver lxt97x_driver[] = {
+{
 	.phy_id		= 0x78100000,
 	.name		= "LXT970",
 	.phy_id_mask	= 0xfffffff0,
@@ -160,10 +161,8 @@ static struct phy_driver lxt970_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= lxt970_ack_interrupt,
 	.config_intr	= lxt970_config_intr,
-	.driver 	= { .owner = THIS_MODULE,},
-};
-
-static struct phy_driver lxt971_driver = {
+	.driver		= { .owner = THIS_MODULE,},
+}, {
 	.phy_id		= 0x001378e0,
 	.name		= "LXT971",
 	.phy_id_mask	= 0xfffffff0,
@@ -173,10 +172,8 @@ static struct phy_driver lxt971_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= lxt971_ack_interrupt,
 	.config_intr	= lxt971_config_intr,
-	.driver 	= { .owner = THIS_MODULE,},
-};
-
-static struct phy_driver lxt973_driver = {
+	.driver		= { .owner = THIS_MODULE,},
+}, {
 	.phy_id		= 0x00137a10,
 	.name		= "LXT973",
 	.phy_id_mask	= 0xfffffff0,
@@ -185,39 +182,19 @@ static struct phy_driver lxt973_driver = {
 	.probe		= lxt973_probe,
 	.config_aneg	= lxt973_config_aneg,
 	.read_status	= genphy_read_status,
-	.driver 	= { .owner = THIS_MODULE,},
-};
+	.driver		= { .owner = THIS_MODULE,},
+} };
 
 static int __init lxt_init(void)
 {
-	int ret;
-
-	ret = phy_driver_register(&lxt970_driver);
-	if (ret)
-		goto err1;
-
-	ret = phy_driver_register(&lxt971_driver);
-	if (ret)
-		goto err2;
-
-	ret = phy_driver_register(&lxt973_driver);
-	if (ret)
-		goto err3;
-	return 0;
-
- err3:
-	phy_driver_unregister(&lxt971_driver);
- err2:
-	phy_driver_unregister(&lxt970_driver);
- err1:
-	return ret;
+	return phy_drivers_register(lxt97x_driver,
+		ARRAY_SIZE(lxt97x_driver));
 }
 
 static void __exit lxt_exit(void)
 {
-	phy_driver_unregister(&lxt970_driver);
-	phy_driver_unregister(&lxt971_driver);
-	phy_driver_unregister(&lxt973_driver);
+	phy_drivers_unregister(lxt97x_driver,
+		ARRAY_SIZE(lxt97x_driver));
 }
 
 module_init(lxt_init);
diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 418928d..5d2a3f2 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -826,28 +826,14 @@ static struct phy_driver marvell_drivers[] = {
 
 static int __init marvell_init(void)
 {
-	int ret;
-	int i;
-
-	for (i = 0; i < ARRAY_SIZE(marvell_drivers); i++) {
-		ret = phy_driver_register(&marvell_drivers[i]);
-
-		if (ret) {
-			while (i-- > 0)
-				phy_driver_unregister(&marvell_drivers[i]);
-			return ret;
-		}
-	}
-
-	return 0;
+	return phy_drivers_register(marvell_drivers,
+		 ARRAY_SIZE(marvell_drivers));
 }
 
 static void __exit marvell_exit(void)
 {
-	int i;
-
-	for (i = 0; i < ARRAY_SIZE(marvell_drivers); i++)
-		phy_driver_unregister(&marvell_drivers[i]);
+	phy_drivers_unregister(marvell_drivers,
+		 ARRAY_SIZE(marvell_drivers));
 }
 
 module_init(marvell_init);
diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 9d6c80c..2c9b5a2 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -114,7 +114,8 @@ static int ks8051_config_init(struct phy_device *phydev)
 	return 0;
 }
 
-static struct phy_driver ks8737_driver = {
+static struct phy_driver ksphy_driver[] = {
+{
 	.phy_id		= PHY_ID_KS8737,
 	.phy_id_mask	= 0x00fffff0,
 	.name		= "Micrel KS8737",
@@ -126,9 +127,7 @@ static struct phy_driver ks8737_driver = {
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= ks8737_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
-};
-
-static struct phy_driver ks8041_driver = {
+}, {
 	.phy_id		= PHY_ID_KS8041,
 	.phy_id_mask	= 0x00fffff0,
 	.name		= "Micrel KS8041",
@@ -141,9 +140,7 @@ static struct phy_driver ks8041_driver = {
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
-};
-
-static struct phy_driver ks8051_driver = {
+}, {
 	.phy_id		= PHY_ID_KS8051,
 	.phy_id_mask	= 0x00fffff0,
 	.name		= "Micrel KS8051",
@@ -156,9 +153,7 @@ static struct phy_driver ks8051_driver = {
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
-};
-
-static struct phy_driver ks8001_driver = {
+}, {
 	.phy_id		= PHY_ID_KS8001,
 	.name		= "Micrel KS8001 or KS8721",
 	.phy_id_mask	= 0x00ffffff,
@@ -170,9 +165,7 @@ static struct phy_driver ks8001_driver = {
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
-};
-
-static struct phy_driver ksz9021_driver = {
+}, {
 	.phy_id		= PHY_ID_KSZ9021,
 	.phy_id_mask	= 0x000ffffe,
 	.name		= "Micrel KSZ9021 Gigabit PHY",
@@ -185,51 +178,18 @@ static struct phy_driver ksz9021_driver = {
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= ksz9021_config_intr,
 	.driver		= { .owner = THIS_MODULE, },
-};
+} };
 
 static int __init ksphy_init(void)
 {
-	int ret;
-
-	ret = phy_driver_register(&ks8001_driver);
-	if (ret)
-		goto err1;
-
-	ret = phy_driver_register(&ksz9021_driver);
-	if (ret)
-		goto err2;
-
-	ret = phy_driver_register(&ks8737_driver);
-	if (ret)
-		goto err3;
-	ret = phy_driver_register(&ks8041_driver);
-	if (ret)
-		goto err4;
-	ret = phy_driver_register(&ks8051_driver);
-	if (ret)
-		goto err5;
-
-	return 0;
-
-err5:
-	phy_driver_unregister(&ks8041_driver);
-err4:
-	phy_driver_unregister(&ks8737_driver);
-err3:
-	phy_driver_unregister(&ksz9021_driver);
-err2:
-	phy_driver_unregister(&ks8001_driver);
-err1:
-	return ret;
+	return phy_drivers_register(ksphy_driver,
+		ARRAY_SIZE(ksphy_driver));
 }
 
 static void __exit ksphy_exit(void)
 {
-	phy_driver_unregister(&ks8001_driver);
-	phy_driver_unregister(&ks8737_driver);
-	phy_driver_unregister(&ksz9021_driver);
-	phy_driver_unregister(&ks8041_driver);
-	phy_driver_unregister(&ks8051_driver);
+	phy_drivers_unregister(ksphy_driver,
+		ARRAY_SIZE(ksphy_driver));
 }
 
 module_init(ksphy_init);
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 47e02e7..7d49e6c 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1079,12 +1079,37 @@ int phy_driver_register(struct phy_driver *new_driver)
 }
 EXPORT_SYMBOL(phy_driver_register);
 
+int phy_drivers_register(struct phy_driver *new_driver, int n)
+{
+	int i, ret = 0;
+
+	for (i = 0; i < n; i++) {
+		ret = phy_driver_register(new_driver + i);
+		if (ret) {
+			while (i-- > 0)
+				phy_driver_unregister(new_driver + i);
+			break;
+		}
+	}
+	return ret;
+}
+EXPORT_SYMBOL(phy_drivers_register);
+
 void phy_driver_unregister(struct phy_driver *drv)
 {
 	driver_unregister(&drv->driver);
 }
 EXPORT_SYMBOL(phy_driver_unregister);
 
+void phy_drivers_unregister(struct phy_driver *drv, int n)
+{
+	int i;
+	for (i = 0; i < n; i++) {
+		phy_driver_unregister(drv + i);
+	}
+}
+EXPORT_SYMBOL(phy_drivers_unregister);
+
 static struct phy_driver genphy_driver = {
 	.phy_id		= 0xffffffff,
 	.phy_id_mask	= 0xffffffff,
diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index f414ffb..72f9347 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -65,11 +65,7 @@ static struct phy_driver rtl821x_driver = {
 
 static int __init realtek_init(void)
 {
-	int ret;
-
-	ret = phy_driver_register(&rtl821x_driver);
-
-	return ret;
+	return phy_driver_register(&rtl821x_driver);
 }
 
 static void __exit realtek_exit(void)
diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index fc3e7e9..5fb677b1 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -61,7 +61,8 @@ static int lan911x_config_init(struct phy_device *phydev)
 	return smsc_phy_ack_interrupt(phydev);
 }
 
-static struct phy_driver lan83c185_driver = {
+static struct phy_driver smsc_phy_driver[] = {
+{
 	.phy_id		= 0x0007c0a0, /* OUI=0x00800f, Model#=0x0a */
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "SMSC LAN83C185",
@@ -83,9 +84,7 @@ static struct phy_driver lan83c185_driver = {
 	.resume		= genphy_resume,
 
 	.driver		= { .owner = THIS_MODULE, }
-};
-
-static struct phy_driver lan8187_driver = {
+}, {
 	.phy_id		= 0x0007c0b0, /* OUI=0x00800f, Model#=0x0b */
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "SMSC LAN8187",
@@ -107,9 +106,7 @@ static struct phy_driver lan8187_driver = {
 	.resume		= genphy_resume,
 
 	.driver		= { .owner = THIS_MODULE, }
-};
-
-static struct phy_driver lan8700_driver = {
+}, {
 	.phy_id		= 0x0007c0c0, /* OUI=0x00800f, Model#=0x0c */
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "SMSC LAN8700",
@@ -131,9 +128,7 @@ static struct phy_driver lan8700_driver = {
 	.resume		= genphy_resume,
 
 	.driver		= { .owner = THIS_MODULE, }
-};
-
-static struct phy_driver lan911x_int_driver = {
+}, {
 	.phy_id		= 0x0007c0d0, /* OUI=0x00800f, Model#=0x0d */
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "SMSC LAN911x Internal PHY",
@@ -155,9 +150,7 @@ static struct phy_driver lan911x_int_driver = {
 	.resume		= genphy_resume,
 
 	.driver		= { .owner = THIS_MODULE, }
-};
-
-static struct phy_driver lan8710_driver = {
+}, {
 	.phy_id		= 0x0007c0f0, /* OUI=0x00800f, Model#=0x0f */
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "SMSC LAN8710/LAN8720",
@@ -179,53 +172,18 @@ static struct phy_driver lan8710_driver = {
 	.resume		= genphy_resume,
 
 	.driver		= { .owner = THIS_MODULE, }
-};
+} };
 
 static int __init smsc_init(void)
 {
-	int ret;
-
-	ret = phy_driver_register (&lan83c185_driver);
-	if (ret)
-		goto err1;
-
-	ret = phy_driver_register (&lan8187_driver);
-	if (ret)
-		goto err2;
-
-	ret = phy_driver_register (&lan8700_driver);
-	if (ret)
-		goto err3;
-
-	ret = phy_driver_register (&lan911x_int_driver);
-	if (ret)
-		goto err4;
-
-	ret = phy_driver_register (&lan8710_driver);
-	if (ret)
-		goto err5;
-
-	return 0;
-
-err5:
-	phy_driver_unregister (&lan911x_int_driver);
-err4:
-	phy_driver_unregister (&lan8700_driver);
-err3:
-	phy_driver_unregister (&lan8187_driver);
-err2:
-	phy_driver_unregister (&lan83c185_driver);
-err1:
-	return ret;
+	return phy_drivers_register(smsc_phy_driver,
+		ARRAY_SIZE(smsc_phy_driver));
 }
 
 static void __exit smsc_exit(void)
 {
-	phy_driver_unregister (&lan8710_driver);
-	phy_driver_unregister (&lan911x_int_driver);
-	phy_driver_unregister (&lan8700_driver);
-	phy_driver_unregister (&lan8187_driver);
-	phy_driver_unregister (&lan83c185_driver);
+	return phy_drivers_unregister(smsc_phy_driver,
+		ARRAY_SIZE(smsc_phy_driver));
 }
 
 MODULE_DESCRIPTION("SMSC PHY driver");
diff --git a/drivers/net/phy/ste10Xp.c b/drivers/net/phy/ste10Xp.c
index 187a2fa..5e1eb13 100644
--- a/drivers/net/phy/ste10Xp.c
+++ b/drivers/net/phy/ste10Xp.c
@@ -81,7 +81,8 @@ static int ste10Xp_ack_interrupt(struct phy_device *phydev)
 	return 0;
 }
 
-static struct phy_driver ste101p_pdriver = {
+static struct phy_driver ste10xp_pdriver[] = {
+{
 	.phy_id = STE101P_PHY_ID,
 	.phy_id_mask = 0xfffffff0,
 	.name = "STe101p",
@@ -95,9 +96,7 @@ static struct phy_driver ste101p_pdriver = {
 	.suspend = genphy_suspend,
 	.resume = genphy_resume,
 	.driver = {.owner = THIS_MODULE,}
-};
-
-static struct phy_driver ste100p_pdriver = {
+}, {
 	.phy_id = STE100P_PHY_ID,
 	.phy_id_mask = 0xffffffff,
 	.name = "STe100p",
@@ -111,22 +110,18 @@ static struct phy_driver ste100p_pdriver = {
 	.suspend = genphy_suspend,
 	.resume = genphy_resume,
 	.driver = {.owner = THIS_MODULE,}
-};
+} };
 
 static int __init ste10Xp_init(void)
 {
-	int retval;
-
-	retval = phy_driver_register(&ste100p_pdriver);
-	if (retval < 0)
-		return retval;
-	return phy_driver_register(&ste101p_pdriver);
+	return phy_drivers_register(ste10xp_pdriver,
+		ARRAY_SIZE(ste10xp_pdriver));
 }
 
 static void __exit ste10Xp_exit(void)
 {
-	phy_driver_unregister(&ste100p_pdriver);
-	phy_driver_unregister(&ste101p_pdriver);
+	phy_drivers_unregister(ste10xp_pdriver,
+		ARRAY_SIZE(ste10xp_pdriver));
 }
 
 module_init(ste10Xp_init);
diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 0ec8e09..939ebbe 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -138,21 +138,6 @@ static int vsc82xx_config_intr(struct phy_device *phydev)
 	return err;
 }
 
-/* Vitesse 824x */
-static struct phy_driver vsc8244_driver = {
-	.phy_id		= PHY_ID_VSC8244,
-	.name		= "Vitesse VSC8244",
-	.phy_id_mask	= 0x000fffc0,
-	.features	= PHY_GBIT_FEATURES,
-	.flags		= PHY_HAS_INTERRUPT,
-	.config_init	= &vsc824x_config_init,
-	.config_aneg	= &genphy_config_aneg,
-	.read_status	= &genphy_read_status,
-	.ack_interrupt	= &vsc824x_ack_interrupt,
-	.config_intr	= &vsc82xx_config_intr,
-	.driver 	= { .owner = THIS_MODULE,},
-};
-
 static int vsc8221_config_init(struct phy_device *phydev)
 {
 	int err;
@@ -165,8 +150,22 @@ static int vsc8221_config_init(struct phy_device *phydev)
 	   Options are 802.3Z SerDes or SGMII */
 }
 
-/* Vitesse 8221 */
-static struct phy_driver vsc8221_driver = {
+/* Vitesse 824x */
+static struct phy_driver vsc82xx_driver[] = {
+{
+	.phy_id		= PHY_ID_VSC8244,
+	.name		= "Vitesse VSC8244",
+	.phy_id_mask	= 0x000fffc0,
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_init	= &vsc824x_config_init,
+	.config_aneg	= &genphy_config_aneg,
+	.read_status	= &genphy_read_status,
+	.ack_interrupt	= &vsc824x_ack_interrupt,
+	.config_intr	= &vsc82xx_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
+}, {
+	/* Vitesse 8221 */
 	.phy_id		= PHY_ID_VSC8221,
 	.phy_id_mask	= 0x000ffff0,
 	.name		= "Vitesse VSC8221",
@@ -177,26 +176,19 @@ static struct phy_driver vsc8221_driver = {
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &vsc824x_ack_interrupt,
 	.config_intr	= &vsc82xx_config_intr,
-	.driver 	= { .owner = THIS_MODULE,},
-};
+	.driver		= { .owner = THIS_MODULE,},
+} };
 
 static int __init vsc82xx_init(void)
 {
-	int err;
-
-	err = phy_driver_register(&vsc8244_driver);
-	if (err < 0)
-		return err;
-	err = phy_driver_register(&vsc8221_driver);
-	if (err < 0)
-		phy_driver_unregister(&vsc8244_driver);
-	return err;
+	return phy_drivers_register(vsc82xx_driver,
+		ARRAY_SIZE(vsc82xx_driver));
 }
 
 static void __exit vsc82xx_exit(void)
 {
-	phy_driver_unregister(&vsc8244_driver);
-	phy_driver_unregister(&vsc8221_driver);
+	return phy_drivers_unregister(vsc82xx_driver,
+		ARRAY_SIZE(vsc82xx_driver));
 }
 
 module_init(vsc82xx_init);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index c35299e..93b3cf7 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -533,7 +533,9 @@ int genphy_read_status(struct phy_device *phydev);
 int genphy_suspend(struct phy_device *phydev);
 int genphy_resume(struct phy_device *phydev);
 void phy_driver_unregister(struct phy_driver *drv);
+void phy_drivers_unregister(struct phy_driver *drv, int n);
 int phy_driver_register(struct phy_driver *new_driver);
+int phy_drivers_register(struct phy_driver *new_driver, int n);
 void phy_state_machine(struct work_struct *work);
 void phy_start_machine(struct phy_device *phydev,
 		void (*handler)(struct net_device *));
-- 
1.7.2.5
