From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Subject: [RFC PATCH 06/17] phy_driver: Add and use phy_driver_[un]register_multiple()
Date: Thu, 20 Oct 2011 17:00:13 -0400
Message-ID: <1319144425-15547-7-git-send-email-Kyle.D.Moffett@boeing.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Cc: Kyle Moffett <Kyle.D.Moffett@boeing.com>,
	"David S. Miller" <davem@conan.davemloft.net>,
	Greg Dietsche <Gregory.Dietsche@cuw.edu>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	David Daney <ddaney@caviumnetworks.com>,
	Arnaud Patard <arnaud.patard@rtp-net.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Baruch Siach <baruch@tkos.co.il>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Frysinger <vapier@gentoo.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 26.241.167.70.in-addr.border.exmeritus.com ([70.167.241.26]:35666
	"EHLO border.exmeritus.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751345Ab1JTVNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 17:13:22 -0400
In-Reply-To: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several of the PHY drivers are registering dozens of "phy_driver"
structures at load-time, with different IDs and variations on methods.
As a result, the error handling is exceptionally ugly.

The "marvell" driver already uses an array of "struct phy_driver" and
iterates over that to add the drivers, but even then its error handling
contains a bug (it will not unregister array item 0 on failure).

To resolve these problems, new functions phy_driver_register_multiple()
and phy_driver_unregister_multiple() are added which take an array and a
number of drivers and iterate over them internally.

All of the PHY driver files which register more than one "phy_driver"
are modified to use the new helpers.  This is a sizable net removal of
about 260 lines of code.

Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
---
 drivers/net/phy/bcm63xx.c    |   30 +++--------
 drivers/net/phy/broadcom.c   |  118 ++++++------------------------------------
 drivers/net/phy/cicada.c     |   32 +++---------
 drivers/net/phy/davicom.c    |   40 +++-----------
 drivers/net/phy/icplus.c     |   21 +++-----
 drivers/net/phy/lxt.c        |   40 +++-----------
 drivers/net/phy/marvell.c    |   22 ++------
 drivers/net/phy/micrel.c     |   61 ++++------------------
 drivers/net/phy/phy_device.c |   32 +++++++++++
 drivers/net/phy/realtek.c    |    6 +--
 drivers/net/phy/smsc.c       |   63 ++++-------------------
 drivers/net/phy/ste10Xp.c    |   20 +++-----
 drivers/net/phy/vitesse.c    |   45 ++++++----------
 include/linux/phy.h          |    2 +
 14 files changed, 138 insertions(+), 394 deletions(-)

diff --git a/drivers/net/phy/bcm63xx.c b/drivers/net/phy/bcm63xx.c
index c455f02..3b4258d 100644
--- a/drivers/net/phy/bcm63xx.c
+++ b/drivers/net/phy/bcm63xx.c
@@ -74,7 +74,7 @@ static int bcm63xx_config_intr(struct phy_device *phydev)
 	return err;
 }
 
-static struct phy_driver bcm63xx_1_driver = {
+static struct phy_driver bcm63xx_drivers[] = { {
 	.phy_id		= 0x00406000,
 	.phy_id_mask	= 0xfffffc00,
 	.name		= "Broadcom BCM63XX (1)",
@@ -85,10 +85,8 @@ static struct phy_driver bcm63xx_1_driver = {
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
@@ -98,30 +96,18 @@ static struct phy_driver bcm63xx_2_driver = {
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
+	return phy_driver_register_multiple(bcm63xx_drivers,
+			ARRAY_SIZE(bcm63xx_drivers));
 }
 
 static void __exit bcm63xx_phy_exit(void)
 {
-	phy_driver_unregister(&bcm63xx_1_driver);
-	phy_driver_unregister(&bcm63xx_2_driver);
+	phy_driver_unregister_multiple(bcm63xx_drivers,
+			ARRAY_SIZE(bcm63xx_drivers));
 }
 
 module_init(bcm63xx_phy_init);
diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index f220264..1b83f75 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -684,7 +684,7 @@ static int brcm_fet_config_intr(struct phy_device *phydev)
 	return err;
 }
 
-static struct phy_driver bcm5411_driver = {
+static struct phy_driver broadcom_drivers[] = { {
 	.phy_id		= PHY_ID_BCM5411,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5411",
@@ -695,9 +695,7 @@ static struct phy_driver bcm5411_driver = {
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
@@ -708,9 +706,7 @@ static struct phy_driver bcm5421_driver = {
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
@@ -721,9 +717,7 @@ static struct phy_driver bcm5461_driver = {
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
@@ -734,9 +728,7 @@ static struct phy_driver bcm5464_driver = {
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
@@ -748,9 +740,7 @@ static struct phy_driver bcm5481_driver = {
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
@@ -762,9 +752,7 @@ static struct phy_driver bcm5482_driver = {
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
@@ -775,9 +763,7 @@ static struct phy_driver bcm50610_driver = {
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
@@ -788,9 +774,7 @@ static struct phy_driver bcm50610m_driver = {
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
@@ -801,9 +785,7 @@ static struct phy_driver bcm57780_driver = {
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
@@ -814,9 +796,7 @@ static struct phy_driver bcmac131_driver = {
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
@@ -827,84 +807,18 @@ static struct phy_driver bcm5241_driver = {
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
+	return phy_driver_register_multiple(broadcom_drivers,
+			ARRAY_SIZE(broadcom_drivers));
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
+	phy_driver_unregister_multiple(broadcom_drivers,
+			ARRAY_SIZE(broadcom_drivers));
 }
 
 module_init(broadcom_init);
diff --git a/drivers/net/phy/cicada.c b/drivers/net/phy/cicada.c
index c409ca2..9c805cd 100644
--- a/drivers/net/phy/cicada.c
+++ b/drivers/net/phy/cicada.c
@@ -101,8 +101,8 @@ static int cis820x_config_intr(struct phy_device *phydev)
 	return err;
 }
 
-/* Cicada 8201, a.k.a Vitesse VSC8201 */
-static struct phy_driver cis8201_driver = {
+static struct phy_driver cicada_drivers[] = { {
+	/* Cicada 8201, a.k.a Vitesse VSC8201 */
 	.phy_id		= 0x000fc410,
 	.name		= "Cicada Cis8201",
 	.phy_id_mask	= 0x000ffff0,
@@ -112,10 +112,7 @@ static struct phy_driver cis8201_driver = {
 	.ack_interrupt	= &cis820x_ack_interrupt,
 	.config_intr	= &cis820x_config_intr,
 	.driver 	= { .owner = THIS_MODULE,},
-};
-
-/* Cicada 8204 */
-static struct phy_driver cis8204_driver = {
+}, {
 	.phy_id		= 0x000fc440,
 	.name		= "Cicada Cis8204",
 	.phy_id_mask	= 0x000fffc0,
@@ -125,31 +122,18 @@ static struct phy_driver cis8204_driver = {
 	.ack_interrupt	= &cis820x_ack_interrupt,
 	.config_intr	= &cis820x_config_intr,
 	.driver 	= { .owner = THIS_MODULE,},
-};
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
+	return phy_driver_register_multiple(cicada_drivers,
+			ARRAY_SIZE(cicada_drivers));
 }
 
 static void __exit cicada_exit(void)
 {
-	phy_driver_unregister(&cis8204_driver);
-	phy_driver_unregister(&cis8201_driver);
+	phy_driver_unregister_multiple(cicada_drivers,
+			ARRAY_SIZE(cicada_drivers));
 }
 
 module_init(cicada_init);
diff --git a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
index 5249e1e..435be46 100644
--- a/drivers/net/phy/davicom.c
+++ b/drivers/net/phy/davicom.c
@@ -149,7 +149,7 @@ static int dm9161_ack_interrupt(struct phy_device *phydev)
 	return (err < 0) ? err : 0;
 }
 
-static struct phy_driver dm9161e_driver = {
+static struct phy_driver davicom_drivers[] = { {
 	.phy_id		= 0x0181b880,
 	.name		= "Davicom DM9161E",
 	.phy_id_mask	= 0x0ffffff0,
@@ -157,9 +157,7 @@ static struct phy_driver dm9161e_driver = {
 	.config_init	= dm9161_config_init,
 	.config_aneg	= dm9161_config_aneg,
 	.driver		= { .owner = THIS_MODULE,},
-};
-
-static struct phy_driver dm9161a_driver = {
+}, {
 	.phy_id		= 0x0181b8a0,
 	.name		= "Davicom DM9161A",
 	.phy_id_mask	= 0x0ffffff0,
@@ -167,9 +165,7 @@ static struct phy_driver dm9161a_driver = {
 	.config_init	= dm9161_config_init,
 	.config_aneg	= dm9161_config_aneg,
 	.driver		= { .owner = THIS_MODULE,},
-};
-
-static struct phy_driver dm9131_driver = {
+}, {
 	.phy_id		= 0x00181b80,
 	.name		= "Davicom DM9131",
 	.phy_id_mask	= 0x0ffffff0,
@@ -178,38 +174,18 @@ static struct phy_driver dm9131_driver = {
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
+	return phy_driver_register_multiple(davicom_drivers,
+			ARRAY_SIZE(davicom_drivers));
 }
 
 static void __exit davicom_exit(void)
 {
-	phy_driver_unregister(&dm9161e_driver);
-	phy_driver_unregister(&dm9161a_driver);
-	phy_driver_unregister(&dm9131_driver);
+	phy_driver_unregister_multiple(davicom_drivers,
+			ARRAY_SIZE(davicom_drivers));
 }
 
 module_init(davicom_init);
diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index 28a190e..b23c78f 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -131,7 +131,7 @@ static int ip175c_config_aneg(struct phy_device *phydev)
 	return 0;
 }
 
-static struct phy_driver ip175c_driver = {
+static struct phy_driver icplus_drivers[] = { {
 	.phy_id		= 0x02430d80,
 	.name		= "ICPlus IP175C",
 	.phy_id_mask	= 0x0ffffff0,
@@ -142,9 +142,7 @@ static struct phy_driver ip175c_driver = {
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
@@ -154,23 +152,18 @@ static struct phy_driver ip1001_driver = {
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
-	return phy_driver_register(&ip175c_driver);
+	return phy_driver_register_multiple(icplus_drivers,
+			ARRAY_SIZE(icplus_drivers));
 }
 
 static void __exit icplus_exit(void)
 {
-	phy_driver_unregister(&ip1001_driver);
-	phy_driver_unregister(&ip175c_driver);
+	phy_driver_unregister_multiple(icplus_drivers,
+			ARRAY_SIZE(icplus_drivers));
 }
 
 module_init(icplus_init);
diff --git a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
index 0ed7e51..902d2d1 100644
--- a/drivers/net/phy/lxt.c
+++ b/drivers/net/phy/lxt.c
@@ -149,7 +149,7 @@ static int lxt973_config_aneg(struct phy_device *phydev)
 	return phydev->priv ? 0 : genphy_config_aneg(phydev);
 }
 
-static struct phy_driver lxt970_driver = {
+static struct phy_driver lxt_drivers[] = { {
 	.phy_id		= 0x78100000,
 	.name		= "LXT970",
 	.phy_id_mask	= 0xfffffff0,
@@ -159,9 +159,7 @@ static struct phy_driver lxt970_driver = {
 	.ack_interrupt	= lxt970_ack_interrupt,
 	.config_intr	= lxt970_config_intr,
 	.driver 	= { .owner = THIS_MODULE,},
-};
-
-static struct phy_driver lxt971_driver = {
+}, {
 	.phy_id		= 0x001378e0,
 	.name		= "LXT971",
 	.phy_id_mask	= 0xfffffff0,
@@ -170,9 +168,7 @@ static struct phy_driver lxt971_driver = {
 	.ack_interrupt	= lxt971_ack_interrupt,
 	.config_intr	= lxt971_config_intr,
 	.driver 	= { .owner = THIS_MODULE,},
-};
-
-static struct phy_driver lxt973_driver = {
+}, {
 	.phy_id		= 0x00137a10,
 	.name		= "LXT973",
 	.phy_id_mask	= 0xfffffff0,
@@ -181,38 +177,18 @@ static struct phy_driver lxt973_driver = {
 	.probe		= lxt973_probe,
 	.config_aneg	= lxt973_config_aneg,
 	.driver 	= { .owner = THIS_MODULE,},
-};
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
+	return phy_driver_register_multiple(lxt_drivers,
+			ARRAY_SIZE(lxt_drivers));
 }
 
 static void __exit lxt_exit(void)
 {
-	phy_driver_unregister(&lxt970_driver);
-	phy_driver_unregister(&lxt971_driver);
-	phy_driver_unregister(&lxt973_driver);
+	phy_driver_unregister_multiple(lxt_drivers,
+			ARRAY_SIZE(lxt_drivers));
 }
 
 module_init(lxt_init);
diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index e4beb96..9aaae96 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -832,28 +832,14 @@ static struct phy_driver marvell_drivers[] = {
 
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
+	return phy_driver_register_multiple(marvell_drivers,
+			ARRAY_SIZE(marvell_drivers));
 }
 
 static void __exit marvell_exit(void)
 {
-	int i;
-
-	for (i = 0; i < ARRAY_SIZE(marvell_drivers); i++)
-		phy_driver_unregister(&marvell_drivers[i]);
+	phy_driver_unregister_multiple(marvell_drivers,
+			ARRAY_SIZE(marvell_drivers));
 }
 
 module_init(marvell_init);
diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 1404b3c..1359a2e 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -114,7 +114,7 @@ static int ks8051_config_init(struct phy_device *phydev)
 	return 0;
 }
 
-static struct phy_driver ks8737_driver = {
+static struct phy_driver ksphy_drivers[] = { {
 	.phy_id		= PHY_ID_KS8737,
 	.phy_id_mask	= 0x00fffff0,
 	.name		= "Micrel KS8737",
@@ -124,9 +124,7 @@ static struct phy_driver ks8737_driver = {
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
@@ -137,9 +135,7 @@ static struct phy_driver ks8041_driver = {
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
@@ -150,9 +146,7 @@ static struct phy_driver ks8051_driver = {
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
-};
-
-static struct phy_driver ks8001_driver = {
+}, {
 	.phy_id		= PHY_ID_KS8001,
 	.name		= "Micrel KS8001 or KS8721",
 	.phy_id_mask	= 0x00fffff0,
@@ -162,9 +156,7 @@ static struct phy_driver ks8001_driver = {
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
-};
-
-static struct phy_driver ksz9021_driver = {
+}, {
 	.phy_id		= PHY_ID_KSZ9021,
 	.phy_id_mask	= 0x000fff10,
 	.name		= "Micrel KSZ9021 Gigabit PHY",
@@ -175,51 +167,18 @@ static struct phy_driver ksz9021_driver = {
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
+	return phy_driver_register_multiple(ksphy_drivers,
+			ARRAY_SIZE(ksphy_drivers));
 }
 
 static void __exit ksphy_exit(void)
 {
-	phy_driver_unregister(&ks8001_driver);
-	phy_driver_unregister(&ks8737_driver);
-	phy_driver_unregister(&ksz9021_driver);
-	phy_driver_unregister(&ks8041_driver);
-	phy_driver_unregister(&ks8051_driver);
+	phy_driver_unregister_multiple(ksphy_drivers,
+			ARRAY_SIZE(ksphy_drivers));
 }
 
 module_init(ksphy_init);
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index f1d8352..8990e87 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1012,6 +1012,38 @@ void phy_driver_unregister(struct phy_driver *drv)
 }
 EXPORT_SYMBOL(phy_driver_unregister);
 
+/**
+ * phy_driver_register_multiple - register an array of phy_drivers
+ * @drivers: array of phy_drivers to register
+ */
+int phy_driver_register_multiple(struct phy_driver *drivers,
+		unsigned long nr_drivers)
+{
+	unsigned long i;
+	for (i = 0; i < nr_drivers; i++) {
+		int retval = phy_driver_register(&drivers[i]);
+		if (retval) {
+			/*
+			 * A failure occurred, so unregister everything that
+			 * was already successfully registered.
+			 */
+			phy_driver_unregister_multiple__(drivers, i);
+			return retval;
+		}
+	}
+	return 0;
+}
+EXPORT_SYMBOL(phy_driver_register_multiple);
+
+void phy_driver_unregister_multiple(struct phy_driver *drivers,
+		unsigned long nr_drivers)
+{
+	unsigned long i;
+	for (i = nr_drivers; i > 0; i++)
+		phy_driver_unregister(drvs[i-1]);
+}
+EXPORT_SYMBOL(phy_driver_unregister_multiple);
+
 static struct phy_driver genphy_driver = {
 	.phy_id		= 0xffffffff,
 	.phy_id_mask	= 0xffffffff,
diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index 1a00deb..0172248 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -62,11 +62,7 @@ static struct phy_driver rtl821x_driver = {
 
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
index a8aa088..eb05b0f 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -80,7 +80,7 @@ static int lan911x_config_init(struct phy_device *phydev)
 	return smsc_phy_ack_interrupt(phydev);
 }
 
-static struct phy_driver lan83c185_driver = {
+static struct phy_driver smsc_drivers[] = { {
 	.phy_id		= 0x0007c0a0, /* OUI=0x00800f, Model#=0x0a */
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "SMSC LAN83C185",
@@ -100,9 +100,7 @@ static struct phy_driver lan83c185_driver = {
 	.resume		= genphy_resume,
 
 	.driver		= { .owner = THIS_MODULE, }
-};
-
-static struct phy_driver lan8187_driver = {
+}, {
 	.phy_id		= 0x0007c0b0, /* OUI=0x00800f, Model#=0x0b */
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "SMSC LAN8187",
@@ -122,9 +120,7 @@ static struct phy_driver lan8187_driver = {
 	.resume		= genphy_resume,
 
 	.driver		= { .owner = THIS_MODULE, }
-};
-
-static struct phy_driver lan8700_driver = {
+}, {
 	.phy_id		= 0x0007c0c0, /* OUI=0x00800f, Model#=0x0c */
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "SMSC LAN8700",
@@ -144,9 +140,7 @@ static struct phy_driver lan8700_driver = {
 	.resume		= genphy_resume,
 
 	.driver		= { .owner = THIS_MODULE, }
-};
-
-static struct phy_driver lan911x_int_driver = {
+}, {
 	.phy_id		= 0x0007c0d0, /* OUI=0x00800f, Model#=0x0d */
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "SMSC LAN911x Internal PHY",
@@ -166,9 +160,7 @@ static struct phy_driver lan911x_int_driver = {
 	.resume		= genphy_resume,
 
 	.driver		= { .owner = THIS_MODULE, }
-};
-
-static struct phy_driver lan8710_driver = {
+}, {
 	.phy_id		= 0x0007c0f0, /* OUI=0x00800f, Model#=0x0f */
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "SMSC LAN8710/LAN8720",
@@ -188,53 +180,18 @@ static struct phy_driver lan8710_driver = {
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
+	return phy_driver_register_multiple(smsc_drivers,
+			ARRAY_SIZE(smsc_drivers));
 }
 
 static void __exit smsc_exit(void)
 {
-	phy_driver_unregister (&lan8710_driver);
-	phy_driver_unregister (&lan911x_int_driver);
-	phy_driver_unregister (&lan8700_driver);
-	phy_driver_unregister (&lan8187_driver);
-	phy_driver_unregister (&lan83c185_driver);
+	phy_driver_unregister_multiple(smsc_drivers,
+			ARRAY_SIZE(smsc_drivers));
 }
 
 MODULE_DESCRIPTION("SMSC PHY driver");
diff --git a/drivers/net/phy/ste10Xp.c b/drivers/net/phy/ste10Xp.c
index 45cde8f..855589c 100644
--- a/drivers/net/phy/ste10Xp.c
+++ b/drivers/net/phy/ste10Xp.c
@@ -81,7 +81,7 @@ static int ste10Xp_ack_interrupt(struct phy_device *phydev)
 	return 0;
 }
 
-static struct phy_driver ste101p_pdriver = {
+static struct phy_driver ste10Xp_drivers[] = { {
 	.phy_id = STE101P_PHY_ID,
 	.phy_id_mask = 0xfffffff0,
 	.name = "STe101p",
@@ -93,9 +93,7 @@ static struct phy_driver ste101p_pdriver = {
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
@@ -107,22 +105,18 @@ static struct phy_driver ste100p_pdriver = {
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
+	return phy_driver_register_multiple(ste10Xp_drivers,
+			ARRAY_SIZE(ste10Xp_drivers));
 }
 
 static void __exit ste10Xp_exit(void)
 {
-	phy_driver_unregister(&ste100p_pdriver);
-	phy_driver_unregister(&ste101p_pdriver);
+	phy_driver_unregister_multiple(ste10Xp_drivers,
+			ARRAY_SIZE(ste10Xp_drivers));
 }
 
 module_init(ste10Xp_init);
diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 20ea438..82f808e 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -128,19 +128,6 @@ static int vsc82xx_config_intr(struct phy_device *phydev)
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
-	.ack_interrupt	= &vsc824x_ack_interrupt,
-	.config_intr	= &vsc82xx_config_intr,
-	.driver 	= { .owner = THIS_MODULE,},
-};
-
 static int vsc8221_config_init(struct phy_device *phydev)
 {
 	int err;
@@ -153,8 +140,17 @@ static int vsc8221_config_init(struct phy_device *phydev)
 	   Options are 802.3Z SerDes or SGMII */
 }
 
-/* Vitesse 8221 */
-static struct phy_driver vsc8221_driver = {
+static struct phy_driver vitesse_drivers[] = { {
+	.phy_id		= PHY_ID_VSC8244,
+	.name		= "Vitesse VSC8244",
+	.phy_id_mask	= 0x000fffc0,
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_init	= &vsc824x_config_init,
+	.ack_interrupt	= &vsc824x_ack_interrupt,
+	.config_intr	= &vsc82xx_config_intr,
+	.driver		= { .owner = THIS_MODULE, },
+}, {
 	.phy_id		= PHY_ID_VSC8221,
 	.phy_id_mask	= 0x000ffff0,
 	.name		= "Vitesse VSC8221",
@@ -163,26 +159,19 @@ static struct phy_driver vsc8221_driver = {
 	.config_init	= &vsc8221_config_init,
 	.ack_interrupt	= &vsc824x_ack_interrupt,
 	.config_intr	= &vsc82xx_config_intr,
-	.driver 	= { .owner = THIS_MODULE,},
-};
+	.driver		= { .owner = THIS_MODULE, },
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
+	return phy_driver_register_multiple(vitesse_drivers,
+			ARRAY_SIZE(vitesse_drivers));
 }
 
 static void __exit vsc82xx_exit(void)
 {
-	phy_driver_unregister(&vsc8244_driver);
-	phy_driver_unregister(&vsc8221_driver);
+	phy_driver_unregister_multiple(vitesse_drivers,
+			ARRAY_SIZE(vitesse_drivers));
 }
 
 module_init(vsc82xx_init);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index a55a6c4..c6bbb38 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -505,7 +505,9 @@ int genphy_read_status(struct phy_device *phydev);
 int genphy_suspend(struct phy_device *phydev);
 int genphy_resume(struct phy_device *phydev);
 void phy_driver_unregister(struct phy_driver *drv);
+void phy_driver_unregister_multiple(struct phy_driver *drvs, unsigned long nr);
 int phy_driver_register(struct phy_driver *new_driver);
+int phy_driver_register_multiple(struct phy_driver *drvs, unsigned long nr);
 void phy_state_machine(struct work_struct *work);
 void phy_start_machine(struct phy_device *phydev,
 		void (*handler)(struct net_device *));
-- 
1.7.2.5
