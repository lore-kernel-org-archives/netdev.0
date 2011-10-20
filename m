From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Subject: [RFC PATCH 05/17] phy_driver: Make .read_status()/.config_aneg() optional
Date: Thu, 20 Oct 2011 17:00:12 -0400
Message-ID: <1319144425-15547-6-git-send-email-Kyle.D.Moffett@boeing.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Cc: Kyle Moffett <Kyle.D.Moffett@boeing.com>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Dietsche <Gregory.Dietsche@cuw.edu>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	David Daney <ddaney@caviumnetworks.com>,
	Arnaud Patard <arnaud.patard@rtp-net.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Baruch Siach <baruch@tkos.co.il>,
	Thorsten Schubert <tshu@msc-ge.com>,
	David Decotigny <decot@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Mike Frysinger <vapier@gentoo.org>, linux-doc@vger.kernel.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Approximately 90% of the PHY drivers follow the PHY layer docs and
simply use &genphy_read_status and &genphy_config_aneg.  There would
seem to be little point in requiring them all to manually specify those
functions.

This patch makes it much easier for subsequent patches to split and
refactor the functionality of the .config_aneg() method.

Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
---
 Documentation/networking/phy.txt |   13 +++++--------
 drivers/net/phy/bcm63xx.c        |    4 ----
 drivers/net/phy/broadcom.c       |   20 --------------------
 drivers/net/phy/cicada.c         |    4 ----
 drivers/net/phy/davicom.c        |    4 ----
 drivers/net/phy/icplus.c         |    2 --
 drivers/net/phy/lxt.c            |    5 -----
 drivers/net/phy/marvell.c        |    6 ------
 drivers/net/phy/micrel.c         |   10 ----------
 drivers/net/phy/national.c       |    2 --
 drivers/net/phy/phy.c            |    5 ++++-
 drivers/net/phy/phy_device.c     |    2 --
 drivers/net/phy/qsemi.c          |    2 --
 drivers/net/phy/realtek.c        |    2 --
 drivers/net/phy/smsc.c           |   10 ----------
 drivers/net/phy/ste10Xp.c        |    4 ----
 drivers/net/phy/vitesse.c        |    4 ----
 include/linux/phy.h              |    8 +++++---
 18 files changed, 14 insertions(+), 93 deletions(-)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index 9eb1ba5..62f890e 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -261,14 +261,11 @@ Writing a PHY driver
    config_intr: Enable or disable interrupts
    remove: Does any driver take-down
 
- Of these, only config_aneg and read_status are required to be
- assigned by the driver code.  The rest are optional.  Also, it is
- preferred to use the generic phy driver's versions of these two
- functions if at all possible: genphy_read_status and
- genphy_config_aneg.  If this is not possible, it is likely that
- you only need to perform some actions before and after invoking
- these functions, and so your functions will wrap the generic
- ones.
+ All of these functions are optional.  It is strongly preferred to use the
+ generic phy driver's versions of these two functions if at all possible:
+ genphy_read_status and genphy_config_aneg.  If this is not possible, it is
+ likely that you only need to perform some actions before and after invoking
+ these functions, and so your functions will wrap the generic ones.
 
  Feel free to look at the Marvell, Cicada, and Davicom drivers in
  drivers/net/phy/ for examples (the lxt and qsemi drivers have
diff --git a/drivers/net/phy/bcm63xx.c b/drivers/net/phy/bcm63xx.c
index e16f98c..c455f02 100644
--- a/drivers/net/phy/bcm63xx.c
+++ b/drivers/net/phy/bcm63xx.c
@@ -82,8 +82,6 @@ static struct phy_driver bcm63xx_1_driver = {
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= bcm63xx_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm63xx_ack_interrupt,
 	.config_intr	= bcm63xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
@@ -97,8 +95,6 @@ static struct phy_driver bcm63xx_2_driver = {
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= bcm63xx_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm63xx_ack_interrupt,
 	.config_intr	= bcm63xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index d84c422..f220264 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -692,8 +692,6 @@ static struct phy_driver bcm5411_driver = {
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
@@ -707,8 +705,6 @@ static struct phy_driver bcm5421_driver = {
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
@@ -722,8 +718,6 @@ static struct phy_driver bcm5461_driver = {
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
@@ -737,8 +731,6 @@ static struct phy_driver bcm5464_driver = {
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
@@ -753,7 +745,6 @@ static struct phy_driver bcm5481_driver = {
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= bcm5481_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
@@ -767,7 +758,6 @@ static struct phy_driver bcm5482_driver = {
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm5482_config_init,
-	.config_aneg	= genphy_config_aneg,
 	.read_status	= bcm5482_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
@@ -782,8 +772,6 @@ static struct phy_driver bcm50610_driver = {
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
@@ -797,8 +785,6 @@ static struct phy_driver bcm50610m_driver = {
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
@@ -812,8 +798,6 @@ static struct phy_driver bcm57780_driver = {
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
@@ -827,8 +811,6 @@ static struct phy_driver bcmac131_driver = {
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= brcm_fet_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= brcm_fet_ack_interrupt,
 	.config_intr	= brcm_fet_config_intr,
 	.driver		= { .owner = THIS_MODULE },
@@ -842,8 +824,6 @@ static struct phy_driver bcm5241_driver = {
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= brcm_fet_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= brcm_fet_ack_interrupt,
 	.config_intr	= brcm_fet_config_intr,
 	.driver		= { .owner = THIS_MODULE },
diff --git a/drivers/net/phy/cicada.c b/drivers/net/phy/cicada.c
index d281731..c409ca2 100644
--- a/drivers/net/phy/cicada.c
+++ b/drivers/net/phy/cicada.c
@@ -109,8 +109,6 @@ static struct phy_driver cis8201_driver = {
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= &cis820x_config_init,
-	.config_aneg	= &genphy_config_aneg,
-	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &cis820x_ack_interrupt,
 	.config_intr	= &cis820x_config_intr,
 	.driver 	= { .owner = THIS_MODULE,},
@@ -124,8 +122,6 @@ static struct phy_driver cis8204_driver = {
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= &cis820x_config_init,
-	.config_aneg	= &genphy_config_aneg,
-	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &cis820x_ack_interrupt,
 	.config_intr	= &cis820x_config_intr,
 	.driver 	= { .owner = THIS_MODULE,},
diff --git a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
index 2f774ac..5249e1e 100644
--- a/drivers/net/phy/davicom.c
+++ b/drivers/net/phy/davicom.c
@@ -156,7 +156,6 @@ static struct phy_driver dm9161e_driver = {
 	.features	= PHY_BASIC_FEATURES,
 	.config_init	= dm9161_config_init,
 	.config_aneg	= dm9161_config_aneg,
-	.read_status	= genphy_read_status,
 	.driver		= { .owner = THIS_MODULE,},
 };
 
@@ -167,7 +166,6 @@ static struct phy_driver dm9161a_driver = {
 	.features	= PHY_BASIC_FEATURES,
 	.config_init	= dm9161_config_init,
 	.config_aneg	= dm9161_config_aneg,
-	.read_status	= genphy_read_status,
 	.driver		= { .owner = THIS_MODULE,},
 };
 
@@ -177,8 +175,6 @@ static struct phy_driver dm9131_driver = {
 	.phy_id_mask	= 0x0ffffff0,
 	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= dm9161_ack_interrupt,
 	.config_intr	= dm9161_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index 2969dac..28a190e 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -151,8 +151,6 @@ static struct phy_driver ip1001_driver = {
 	.features	= PHY_GBIT_FEATURES | SUPPORTED_Pause |
 			  SUPPORTED_Asym_Pause,
 	.config_init	= &ip1001_config_init,
-	.config_aneg	= &genphy_config_aneg,
-	.read_status	= &genphy_read_status,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
diff --git a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
index 6f6e8b6..0ed7e51 100644
--- a/drivers/net/phy/lxt.c
+++ b/drivers/net/phy/lxt.c
@@ -156,8 +156,6 @@ static struct phy_driver lxt970_driver = {
 	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= lxt970_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= lxt970_ack_interrupt,
 	.config_intr	= lxt970_config_intr,
 	.driver 	= { .owner = THIS_MODULE,},
@@ -169,8 +167,6 @@ static struct phy_driver lxt971_driver = {
 	.phy_id_mask	= 0xfffffff0,
 	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= lxt971_ack_interrupt,
 	.config_intr	= lxt971_config_intr,
 	.driver 	= { .owner = THIS_MODULE,},
@@ -184,7 +180,6 @@ static struct phy_driver lxt973_driver = {
 	.flags		= 0,
 	.probe		= lxt973_probe,
 	.config_aneg	= lxt973_config_aneg,
-	.read_status	= genphy_read_status,
 	.driver 	= { .owner = THIS_MODULE,},
 };
 
diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index e8b9c53..e4beb96 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -725,7 +725,6 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.config_aneg = &marvell_config_aneg,
-		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
 		.driver = { .owner = THIS_MODULE },
@@ -738,7 +737,6 @@ static struct phy_driver marvell_drivers[] = {
 		.flags = PHY_HAS_INTERRUPT,
 		.config_init = &m88e1111_config_init,
 		.config_aneg = &marvell_config_aneg,
-		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
 		.driver = { .owner = THIS_MODULE },
@@ -764,7 +762,6 @@ static struct phy_driver marvell_drivers[] = {
 		.flags = PHY_HAS_INTERRUPT,
 		.config_init = &m88e1118_config_init,
 		.config_aneg = &m88e1118_config_aneg,
-		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
 		.driver = {.owner = THIS_MODULE,},
@@ -803,7 +800,6 @@ static struct phy_driver marvell_drivers[] = {
 		.flags = PHY_HAS_INTERRUPT,
 		.config_init = &m88e1145_config_init,
 		.config_aneg = &marvell_config_aneg,
-		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
 		.driver = { .owner = THIS_MODULE },
@@ -816,7 +812,6 @@ static struct phy_driver marvell_drivers[] = {
 		.flags = PHY_HAS_INTERRUPT,
 		.config_init = &m88e1149_config_init,
 		.config_aneg = &m88e1118_config_aneg,
-		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
 		.driver = { .owner = THIS_MODULE },
@@ -829,7 +824,6 @@ static struct phy_driver marvell_drivers[] = {
 		.flags = PHY_HAS_INTERRUPT,
 		.config_init = &m88e1111_config_init,
 		.config_aneg = &marvell_config_aneg,
-		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
 		.driver = { .owner = THIS_MODULE },
diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 590f902..1404b3c 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -121,8 +121,6 @@ static struct phy_driver ks8737_driver = {
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= ks8737_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
@@ -136,8 +134,6 @@ static struct phy_driver ks8041_driver = {
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
@@ -151,8 +147,6 @@ static struct phy_driver ks8051_driver = {
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= ks8051_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
@@ -165,8 +159,6 @@ static struct phy_driver ks8001_driver = {
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
@@ -180,8 +172,6 @@ static struct phy_driver ksz9021_driver = {
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= ksz9021_config_intr,
 	.driver		= { .owner = THIS_MODULE, },
diff --git a/drivers/net/phy/national.c b/drivers/net/phy/national.c
index 04bb8fc..9eca50e 100644
--- a/drivers/net/phy/national.c
+++ b/drivers/net/phy/national.c
@@ -132,8 +132,6 @@ static struct phy_driver dp83865_driver = {
 	.features = PHY_GBIT_FEATURES | SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags = PHY_HAS_INTERRUPT,
 	.config_init = ns_config_init,
-	.config_aneg = genphy_config_aneg,
-	.read_status = genphy_read_status,
 	.ack_interrupt = ns_ack_interrupt,
 	.config_intr = ns_config_intr,
 	.driver = {.owner = THIS_MODULE,}
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 3cbda08..cc7f353 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -395,7 +395,10 @@ int phy_start_aneg(struct phy_device *phydev)
 	if (AUTONEG_DISABLE == phydev->autoneg)
 		phy_sanitize_settings(phydev);
 
-	err = phydev->drv->config_aneg(phydev);
+	if (phydev->drv->config_aneg)
+		err = phydev->drv->config_aneg(phydev);
+	else
+		err = genphy_config_aneg(phydev);
 
 	if (err < 0)
 		goto out_unlock;
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index ff109fe..f1d8352 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1018,8 +1018,6 @@ static struct phy_driver genphy_driver = {
 	.name		= "Generic PHY",
 	.config_init	= genphy_config_init,
 	.features	= 0,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= {.owner= THIS_MODULE, },
diff --git a/drivers/net/phy/qsemi.c b/drivers/net/phy/qsemi.c
index fe0d0a1..5a120a8c 100644
--- a/drivers/net/phy/qsemi.c
+++ b/drivers/net/phy/qsemi.c
@@ -118,8 +118,6 @@ static struct phy_driver qs6612_driver = {
 	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= qs6612_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.ack_interrupt	= qs6612_ack_interrupt,
 	.config_intr	= qs6612_config_intr,
 	.driver 	= { .owner = THIS_MODULE,},
diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index a4eae75..1a00deb 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -55,8 +55,6 @@ static struct phy_driver rtl821x_driver = {
 	.phy_id_mask	= 0x001fffff,
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
-	.config_aneg	= &genphy_config_aneg,
-	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &rtl821x_ack_interrupt,
 	.config_intr	= &rtl821x_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 342505c..a8aa088 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -90,8 +90,6 @@ static struct phy_driver lan83c185_driver = {
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
 	/* basic functions */
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.config_init	= smsc_phy_config_init,
 
 	/* IRQ related */
@@ -114,8 +112,6 @@ static struct phy_driver lan8187_driver = {
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
 	/* basic functions */
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.config_init	= smsc_phy_config_init,
 
 	/* IRQ related */
@@ -138,8 +134,6 @@ static struct phy_driver lan8700_driver = {
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
 	/* basic functions */
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.config_init	= smsc_phy_config_init,
 
 	/* IRQ related */
@@ -162,8 +156,6 @@ static struct phy_driver lan911x_int_driver = {
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
 	/* basic functions */
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.config_init	= lan911x_config_init,
 
 	/* IRQ related */
@@ -186,8 +178,6 @@ static struct phy_driver lan8710_driver = {
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
 	/* basic functions */
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
 	.config_init	= smsc_phy_config_init,
 
 	/* IRQ related */
diff --git a/drivers/net/phy/ste10Xp.c b/drivers/net/phy/ste10Xp.c
index 187a2fa..45cde8f 100644
--- a/drivers/net/phy/ste10Xp.c
+++ b/drivers/net/phy/ste10Xp.c
@@ -88,8 +88,6 @@ static struct phy_driver ste101p_pdriver = {
 	.features = PHY_BASIC_FEATURES | SUPPORTED_Pause,
 	.flags = PHY_HAS_INTERRUPT,
 	.config_init = ste10Xp_config_init,
-	.config_aneg = genphy_config_aneg,
-	.read_status = genphy_read_status,
 	.ack_interrupt = ste10Xp_ack_interrupt,
 	.config_intr = ste10Xp_config_intr,
 	.suspend = genphy_suspend,
@@ -104,8 +102,6 @@ static struct phy_driver ste100p_pdriver = {
 	.features = PHY_BASIC_FEATURES | SUPPORTED_Pause,
 	.flags = PHY_HAS_INTERRUPT,
 	.config_init = ste10Xp_config_init,
-	.config_aneg = genphy_config_aneg,
-	.read_status = genphy_read_status,
 	.ack_interrupt = ste10Xp_ack_interrupt,
 	.config_intr = ste10Xp_config_intr,
 	.suspend = genphy_suspend,
diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 5d8f6e1..20ea438 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -136,8 +136,6 @@ static struct phy_driver vsc8244_driver = {
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= &vsc824x_config_init,
-	.config_aneg	= &genphy_config_aneg,
-	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &vsc824x_ack_interrupt,
 	.config_intr	= &vsc82xx_config_intr,
 	.driver 	= { .owner = THIS_MODULE,},
@@ -163,8 +161,6 @@ static struct phy_driver vsc8221_driver = {
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= &vsc8221_config_init,
-	.config_aneg	= &genphy_config_aneg,
-	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &vsc824x_ack_interrupt,
 	.config_intr	= &vsc82xx_config_intr,
 	.driver 	= { .owner = THIS_MODULE,},
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 54fc413..a55a6c4 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -349,8 +349,7 @@ struct phy_device {
  * flags: A bitfield defining certain other features this PHY
  *   supports (like interrupts)
  *
- * The drivers must implement config_aneg and read_status.  All
- * other functions are optional. Note that none of these
+ * All functions are optional.  Note that none of these
  * functions should be called from interrupt time.  The goal is
  * for the bus read/write functions to be able to block when the
  * bus transaction is happening, and be freed up by an interrupt
@@ -493,7 +492,10 @@ int phy_start_aneg(struct phy_device *phydev);
 int phy_stop_interrupts(struct phy_device *phydev);
 
 static inline int phy_read_status(struct phy_device *phydev) {
-	return phydev->drv->read_status(phydev);
+	if (phydev->drv->read_status)
+		return phydev->drv->read_status(phydev);
+	else
+		return genphy_read_status(phydev);
 }
 
 int genphy_restart_aneg(struct phy_device *phydev);
-- 
1.7.2.5

