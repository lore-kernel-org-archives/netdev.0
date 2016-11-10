From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH] [v2] net: phy: phy drivers should not set SUPPORTED_[Asym_]Pause
Date: Thu, 10 Nov 2016 17:46:01 -0600
Message-ID: <1478821561-26498-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        jon.mason@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:54364 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934560AbcKJXqI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 18:46:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of having individual PHY drivers set the SUPPORTED_Pause and
SUPPORTED_Asym_Pause flags, phylib itself should set those flags.
During autonegotiation, the PHYs will determine whether to enable
pause frame support.

Pause frames are a feature that is supported by the MAC.  It is the MAC
that generates the frames and that processes them.  The PHY can only be
configured to allow them to pass through.

So the new process is:

1) Phylib sets the SUPPORTED_Pause and SUPPORTED_AsymPause bits in
phydev->supported.  This indicates that the PHY supports pause frames.

2) The MAC driver checks phydev->supported before it calls phy_start().
If (SUPPORTED_Pause | SUPPORTED_AsymPause) is set, then the MAC driver
sets those bits in phydev->advertising, if it wants to enable pause
frame support.

3) When the link state changes, the MAC driver checks phydev->pause and
phydev->asym_pause,  If the bits are set, then it enables the corresponding
features in the MAC.  The algorithm is:

	if (phydev->pause)
		The MAC should be programmed to receive and honor
                pause frames it receives, i.e. enable receive flow control.

	if (phydev->pause != phydev->asym_pause)
		The MAC should be programmed to transmit pause
		frames when needed, i.e. enable transmit flow control.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---

v2: set the Pause bits in phy_probe()
    update broadcom.c which was recently changed

 drivers/net/phy/bcm-cygnus.c |  3 +--
 drivers/net/phy/bcm63xx.c    |  5 ++---
 drivers/net/phy/bcm7xxx.c    |  6 ++----
 drivers/net/phy/broadcom.c   | 42 ++++++++++++++----------------------------
 drivers/net/phy/icplus.c     |  6 ++----
 drivers/net/phy/intel-xway.c | 24 ++++++++----------------
 drivers/net/phy/micrel.c     | 30 ++++++++++++------------------
 drivers/net/phy/microchip.c  |  3 +--
 drivers/net/phy/national.c   |  2 +-
 drivers/net/phy/phy_device.c |  7 +++++++
 drivers/net/phy/smsc.c       | 18 ++++++------------
 drivers/net/phy/ste10Xp.c    |  4 ++--
 12 files changed, 58 insertions(+), 92 deletions(-)

diff --git a/drivers/net/phy/bcm-cygnus.c b/drivers/net/phy/bcm-cygnus.c
index 49bbc68..12c6d49 100644
--- a/drivers/net/phy/bcm-cygnus.c
+++ b/drivers/net/phy/bcm-cygnus.c
@@ -134,8 +134,7 @@ static int bcm_cygnus_resume(struct phy_device *phydev)
 	.phy_id        = PHY_ID_BCM_CYGNUS,
 	.phy_id_mask   = 0xfffffff0,
 	.name          = "Broadcom Cygnus PHY",
-	.features      = PHY_GBIT_FEATURES |
-			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.features      = PHY_GBIT_FEATURES,
 	.config_init   = bcm_cygnus_config_init,
 	.config_aneg   = genphy_config_aneg,
 	.read_status   = genphy_read_status,
diff --git a/drivers/net/phy/bcm63xx.c b/drivers/net/phy/bcm63xx.c
index e741bf6..5e9922e 100644
--- a/drivers/net/phy/bcm63xx.c
+++ b/drivers/net/phy/bcm63xx.c
@@ -48,8 +48,7 @@ static int bcm63xx_config_init(struct phy_device *phydev)
 	.phy_id		= 0x00406000,
 	.phy_id_mask	= 0xfffffc00,
 	.name		= "Broadcom BCM63XX (1)",
-	/* ASYM_PAUSE bit is marked RO in datasheet, so don't cheat */
-	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT | PHY_IS_INTERNAL,
 	.config_init	= bcm63xx_config_init,
 	.config_aneg	= genphy_config_aneg,
@@ -61,7 +60,7 @@ static int bcm63xx_config_init(struct phy_device *phydev)
 	.phy_id		= 0x002bdc00,
 	.phy_id_mask	= 0xfffffc00,
 	.name		= "Broadcom BCM63XX (2)",
-	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT | PHY_IS_INTERNAL,
 	.config_init	= bcm63xx_config_init,
 	.config_aneg	= genphy_config_aneg,
diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 9636da0..c1629df 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -308,8 +308,7 @@ static int bcm7xxx_suspend(struct phy_device *phydev)
 	.phy_id		= (_oui),					\
 	.phy_id_mask	= 0xfffffff0,					\
 	.name		= _name,					\
-	.features	= PHY_GBIT_FEATURES |				\
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,	\
+	.features	= PHY_GBIT_FEATURES,				\
 	.flags		= PHY_IS_INTERNAL,				\
 	.config_init	= bcm7xxx_28nm_config_init,			\
 	.config_aneg	= genphy_config_aneg,				\
@@ -322,8 +321,7 @@ static int bcm7xxx_suspend(struct phy_device *phydev)
 	.phy_id         = (_oui),					\
 	.phy_id_mask    = 0xfffffff0,					\
 	.name           = _name,					\
-	.features       = PHY_BASIC_FEATURES |				\
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,	\
+	.features       = PHY_BASIC_FEATURES,				\
 	.flags          = PHY_IS_INTERNAL,				\
 	.config_init    = bcm7xxx_config_init,				\
 	.config_aneg    = genphy_config_aneg,				\
diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index b1e32e9..1c990c8 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -540,8 +540,7 @@ static int brcm_fet_config_intr(struct phy_device *phydev)
 	.phy_id		= PHY_ID_BCM5411,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5411",
-	.features	= PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
@@ -552,8 +551,7 @@ static int brcm_fet_config_intr(struct phy_device *phydev)
 	.phy_id		= PHY_ID_BCM5421,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5421",
-	.features	= PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
@@ -564,8 +562,7 @@ static int brcm_fet_config_intr(struct phy_device *phydev)
 	.phy_id		= PHY_ID_BCM5461,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5461",
-	.features	= PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
@@ -576,8 +573,7 @@ static int brcm_fet_config_intr(struct phy_device *phydev)
 	.phy_id		= PHY_ID_BCM54612E,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM54612E",
-	.features	= PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= bcm54612e_config_aneg,
@@ -588,8 +584,7 @@ static int brcm_fet_config_intr(struct phy_device *phydev)
 	.phy_id		= PHY_ID_BCM54616S,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM54616S",
-	.features	= PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
@@ -600,8 +595,7 @@ static int brcm_fet_config_intr(struct phy_device *phydev)
 	.phy_id		= PHY_ID_BCM5464,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5464",
-	.features	= PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
@@ -612,8 +606,7 @@ static int brcm_fet_config_intr(struct phy_device *phydev)
 	.phy_id		= PHY_ID_BCM5481,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5481",
-	.features	= PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= bcm5481_config_aneg,
@@ -624,8 +617,7 @@ static int brcm_fet_config_intr(struct phy_device *phydev)
 	.phy_id         = PHY_ID_BCM54810,
 	.phy_id_mask    = 0xfffffff0,
 	.name           = "Broadcom BCM54810",
-	.features       = PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.features       = PHY_GBIT_FEATURES,
 	.flags          = PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init    = bcm54xx_config_init,
 	.config_aneg    = bcm5481_config_aneg,
@@ -636,8 +628,7 @@ static int brcm_fet_config_intr(struct phy_device *phydev)
 	.phy_id		= PHY_ID_BCM5482,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5482",
-	.features	= PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm5482_config_init,
 	.config_aneg	= genphy_config_aneg,
@@ -648,8 +639,7 @@ static int brcm_fet_config_intr(struct phy_device *phydev)
 	.phy_id		= PHY_ID_BCM50610,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM50610",
-	.features	= PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
@@ -660,8 +650,7 @@ static int brcm_fet_config_intr(struct phy_device *phydev)
 	.phy_id		= PHY_ID_BCM50610M,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM50610M",
-	.features	= PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
@@ -672,8 +661,7 @@ static int brcm_fet_config_intr(struct phy_device *phydev)
 	.phy_id		= PHY_ID_BCM57780,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM57780",
-	.features	= PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
@@ -684,8 +672,7 @@ static int brcm_fet_config_intr(struct phy_device *phydev)
 	.phy_id		= PHY_ID_BCMAC131,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCMAC131",
-	.features	= PHY_BASIC_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= brcm_fet_config_init,
 	.config_aneg	= genphy_config_aneg,
@@ -696,8 +683,7 @@ static int brcm_fet_config_intr(struct phy_device *phydev)
 	.phy_id		= PHY_ID_BCM5241,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5241",
-	.features	= PHY_BASIC_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= brcm_fet_config_init,
 	.config_aneg	= genphy_config_aneg,
diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index e5f251b..22b51f0 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -225,8 +225,7 @@ static int ip101a_g_ack_interrupt(struct phy_device *phydev)
 	.phy_id		= 0x02430d90,
 	.name		= "ICPlus IP1001",
 	.phy_id_mask	= 0x0ffffff0,
-	.features	= PHY_GBIT_FEATURES | SUPPORTED_Pause |
-			  SUPPORTED_Asym_Pause,
+	.features	= PHY_GBIT_FEATURES,
 	.config_init	= &ip1001_config_init,
 	.config_aneg	= &genphy_config_aneg,
 	.read_status	= &genphy_read_status,
@@ -236,8 +235,7 @@ static int ip101a_g_ack_interrupt(struct phy_device *phydev)
 	.phy_id		= 0x02430c54,
 	.name		= "ICPlus IP101A/G",
 	.phy_id_mask	= 0x0ffffff0,
-	.features	= PHY_BASIC_FEATURES | SUPPORTED_Pause |
-			  SUPPORTED_Asym_Pause,
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.ack_interrupt	= ip101a_g_ack_interrupt,
 	.config_init	= &ip101a_g_config_init,
diff --git a/drivers/net/phy/intel-xway.c b/drivers/net/phy/intel-xway.c
index c300ab5..b1fd7bb 100644
--- a/drivers/net/phy/intel-xway.c
+++ b/drivers/net/phy/intel-xway.c
@@ -239,8 +239,7 @@ static int xway_gphy_config_intr(struct phy_device *phydev)
 		.phy_id		= PHY_ID_PHY11G_1_3,
 		.phy_id_mask	= 0xffffffff,
 		.name		= "Intel XWAY PHY11G (PEF 7071/PEF 7072) v1.3",
-		.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause |
-				   SUPPORTED_Asym_Pause),
+		.features	= PHY_GBIT_FEATURES,
 		.flags		= PHY_HAS_INTERRUPT,
 		.config_init	= xway_gphy_config_init,
 		.config_aneg	= xway_gphy14_config_aneg,
@@ -254,8 +253,7 @@ static int xway_gphy_config_intr(struct phy_device *phydev)
 		.phy_id		= PHY_ID_PHY22F_1_3,
 		.phy_id_mask	= 0xffffffff,
 		.name		= "Intel XWAY PHY22F (PEF 7061) v1.3",
-		.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
-				   SUPPORTED_Asym_Pause),
+		.features	= PHY_BASIC_FEATURES,
 		.flags		= PHY_HAS_INTERRUPT,
 		.config_init	= xway_gphy_config_init,
 		.config_aneg	= xway_gphy14_config_aneg,
@@ -269,8 +267,7 @@ static int xway_gphy_config_intr(struct phy_device *phydev)
 		.phy_id		= PHY_ID_PHY11G_1_4,
 		.phy_id_mask	= 0xffffffff,
 		.name		= "Intel XWAY PHY11G (PEF 7071/PEF 7072) v1.4",
-		.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause |
-				   SUPPORTED_Asym_Pause),
+		.features	= PHY_GBIT_FEATURES,
 		.flags		= PHY_HAS_INTERRUPT,
 		.config_init	= xway_gphy_config_init,
 		.config_aneg	= xway_gphy14_config_aneg,
@@ -284,8 +281,7 @@ static int xway_gphy_config_intr(struct phy_device *phydev)
 		.phy_id		= PHY_ID_PHY22F_1_4,
 		.phy_id_mask	= 0xffffffff,
 		.name		= "Intel XWAY PHY22F (PEF 7061) v1.4",
-		.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
-				   SUPPORTED_Asym_Pause),
+		.features	= PHY_BASIC_FEATURES,
 		.flags		= PHY_HAS_INTERRUPT,
 		.config_init	= xway_gphy_config_init,
 		.config_aneg	= xway_gphy14_config_aneg,
@@ -299,8 +295,7 @@ static int xway_gphy_config_intr(struct phy_device *phydev)
 		.phy_id		= PHY_ID_PHY11G_1_5,
 		.phy_id_mask	= 0xffffffff,
 		.name		= "Intel XWAY PHY11G (PEF 7071/PEF 7072) v1.5 / v1.6",
-		.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause |
-				   SUPPORTED_Asym_Pause),
+		.features	= PHY_GBIT_FEATURES,
 		.flags		= PHY_HAS_INTERRUPT,
 		.config_init	= xway_gphy_config_init,
 		.config_aneg	= genphy_config_aneg,
@@ -314,8 +309,7 @@ static int xway_gphy_config_intr(struct phy_device *phydev)
 		.phy_id		= PHY_ID_PHY22F_1_5,
 		.phy_id_mask	= 0xffffffff,
 		.name		= "Intel XWAY PHY22F (PEF 7061) v1.5 / v1.6",
-		.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
-				   SUPPORTED_Asym_Pause),
+		.features	= PHY_BASIC_FEATURES,
 		.flags		= PHY_HAS_INTERRUPT,
 		.config_init	= xway_gphy_config_init,
 		.config_aneg	= genphy_config_aneg,
@@ -329,8 +323,7 @@ static int xway_gphy_config_intr(struct phy_device *phydev)
 		.phy_id		= PHY_ID_PHY11G_VR9,
 		.phy_id_mask	= 0xffffffff,
 		.name		= "Intel XWAY PHY11G (xRX integrated)",
-		.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause |
-				   SUPPORTED_Asym_Pause),
+		.features	= PHY_GBIT_FEATURES,
 		.flags		= PHY_HAS_INTERRUPT,
 		.config_init	= xway_gphy_config_init,
 		.config_aneg	= genphy_config_aneg,
@@ -344,8 +337,7 @@ static int xway_gphy_config_intr(struct phy_device *phydev)
 		.phy_id		= PHY_ID_PHY22F_VR9,
 		.phy_id_mask	= 0xffffffff,
 		.name		= "Intel XWAY PHY22F (xRX integrated)",
-		.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
-				   SUPPORTED_Asym_Pause),
+		.features	= PHY_BASIC_FEATURES,
 		.flags		= PHY_HAS_INTERRUPT,
 		.config_init	= xway_gphy_config_init,
 		.config_aneg	= genphy_config_aneg,
diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 081df68..76cc727 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -790,7 +790,7 @@ static int kszphy_probe(struct phy_device *phydev)
 	.phy_id		= PHY_ID_KS8737,
 	.phy_id_mask	= MICREL_PHY_ID_MASK,
 	.name		= "Micrel KS8737",
-	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ks8737_type,
 	.config_init	= kszphy_config_init,
@@ -807,8 +807,7 @@ static int kszphy_probe(struct phy_device *phydev)
 	.phy_id		= PHY_ID_KSZ8021,
 	.phy_id_mask	= 0x00ffffff,
 	.name		= "Micrel KSZ8021 or KSZ8031",
-	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
-			   SUPPORTED_Asym_Pause),
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz8021_type,
 	.probe		= kszphy_probe,
@@ -826,8 +825,7 @@ static int kszphy_probe(struct phy_device *phydev)
 	.phy_id		= PHY_ID_KSZ8031,
 	.phy_id_mask	= 0x00ffffff,
 	.name		= "Micrel KSZ8031",
-	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
-			   SUPPORTED_Asym_Pause),
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz8021_type,
 	.probe		= kszphy_probe,
@@ -845,8 +843,7 @@ static int kszphy_probe(struct phy_device *phydev)
 	.phy_id		= PHY_ID_KSZ8041,
 	.phy_id_mask	= MICREL_PHY_ID_MASK,
 	.name		= "Micrel KSZ8041",
-	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
-				| SUPPORTED_Asym_Pause),
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz8041_type,
 	.probe		= kszphy_probe,
@@ -864,8 +861,7 @@ static int kszphy_probe(struct phy_device *phydev)
 	.phy_id		= PHY_ID_KSZ8041RNLI,
 	.phy_id_mask	= MICREL_PHY_ID_MASK,
 	.name		= "Micrel KSZ8041RNLI",
-	.features	= PHY_BASIC_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz8041_type,
 	.probe		= kszphy_probe,
@@ -883,8 +879,7 @@ static int kszphy_probe(struct phy_device *phydev)
 	.phy_id		= PHY_ID_KSZ8051,
 	.phy_id_mask	= MICREL_PHY_ID_MASK,
 	.name		= "Micrel KSZ8051",
-	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
-				| SUPPORTED_Asym_Pause),
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz8051_type,
 	.probe		= kszphy_probe,
@@ -902,7 +897,7 @@ static int kszphy_probe(struct phy_device *phydev)
 	.phy_id		= PHY_ID_KSZ8001,
 	.name		= "Micrel KSZ8001 or KS8721",
 	.phy_id_mask	= 0x00fffffc,
-	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz8041_type,
 	.probe		= kszphy_probe,
@@ -920,7 +915,7 @@ static int kszphy_probe(struct phy_device *phydev)
 	.phy_id		= PHY_ID_KSZ8081,
 	.name		= "Micrel KSZ8081 or KSZ8091",
 	.phy_id_mask	= MICREL_PHY_ID_MASK,
-	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz8081_type,
 	.probe		= kszphy_probe,
@@ -938,7 +933,7 @@ static int kszphy_probe(struct phy_device *phydev)
 	.phy_id		= PHY_ID_KSZ8061,
 	.name		= "Micrel KSZ8061",
 	.phy_id_mask	= MICREL_PHY_ID_MASK,
-	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
@@ -954,7 +949,7 @@ static int kszphy_probe(struct phy_device *phydev)
 	.phy_id		= PHY_ID_KSZ9021,
 	.phy_id_mask	= 0x000ffffe,
 	.name		= "Micrel KSZ9021 Gigabit PHY",
-	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause),
+	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz9021_type,
 	.config_init	= ksz9021_config_init,
@@ -973,7 +968,7 @@ static int kszphy_probe(struct phy_device *phydev)
 	.phy_id		= PHY_ID_KSZ9031,
 	.phy_id_mask	= MICREL_PHY_ID_MASK,
 	.name		= "Micrel KSZ9031 Gigabit PHY",
-	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause),
+	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz9021_type,
 	.config_init	= ksz9031_config_init,
@@ -990,7 +985,6 @@ static int kszphy_probe(struct phy_device *phydev)
 	.phy_id		= PHY_ID_KSZ8873MLL,
 	.phy_id_mask	= MICREL_PHY_ID_MASK,
 	.name		= "Micrel KSZ8873MLL Switch",
-	.features	= (SUPPORTED_Pause | SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG,
 	.config_init	= kszphy_config_init,
 	.config_aneg	= ksz8873mll_config_aneg,
@@ -1004,7 +998,7 @@ static int kszphy_probe(struct phy_device *phydev)
 	.phy_id		= PHY_ID_KSZ886X,
 	.phy_id_mask	= MICREL_PHY_ID_MASK,
 	.name		= "Micrel KSZ886X Switch",
-	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
diff --git a/drivers/net/phy/microchip.c b/drivers/net/phy/microchip.c
index 7c00e50..4c83229 100644
--- a/drivers/net/phy/microchip.c
+++ b/drivers/net/phy/microchip.c
@@ -112,8 +112,7 @@ static int lan88xx_set_wol(struct phy_device *phydev,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Microchip LAN88xx",
 
-	.features	= (PHY_GBIT_FEATURES |
-			   SUPPORTED_Pause | SUPPORTED_Asym_Pause),
+	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
 	.probe		= lan88xx_probe,
diff --git a/drivers/net/phy/national.c b/drivers/net/phy/national.c
index 2a1b490..2addf1d 100644
--- a/drivers/net/phy/national.c
+++ b/drivers/net/phy/national.c
@@ -133,7 +133,7 @@ static int ns_config_init(struct phy_device *phydev)
 	.phy_id = DP83865_PHY_ID,
 	.phy_id_mask = 0xfffffff0,
 	.name = "NatSemi DP83865",
-	.features = PHY_GBIT_FEATURES | SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.features = PHY_GBIT_FEATURES,
 	.flags = PHY_HAS_INTERRUPT,
 	.config_init = ns_config_init,
 	.config_aneg = genphy_config_aneg,
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 49a1c98..eab5333 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1598,6 +1598,13 @@ static int phy_probe(struct device *dev)
 	of_set_phy_supported(phydev);
 	phydev->advertising = phydev->supported;
 
+	/* Report that the PHYs can support passing pause frames.  During
+	 * autonegotiation, the PHYs will determine if they should allow
+	 * pause frames to pass.  The MAC driver should then use that result
+	 * to determine whether to enable flow control via pause frames.
+	 */
+	phydev->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
+
 	/* Set the state to READY by default */
 	phydev->state = PHY_READY;
 
diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index b62c4aa..fb32eaf 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -168,8 +168,7 @@ static int smsc_phy_probe(struct phy_device *phydev)
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "SMSC LAN83C185",
 
-	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
-				| SUPPORTED_Asym_Pause),
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
 	.probe		= smsc_phy_probe,
@@ -191,8 +190,7 @@ static int smsc_phy_probe(struct phy_device *phydev)
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "SMSC LAN8187",
 
-	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
-				| SUPPORTED_Asym_Pause),
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
 	.probe		= smsc_phy_probe,
@@ -214,8 +212,7 @@ static int smsc_phy_probe(struct phy_device *phydev)
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "SMSC LAN8700",
 
-	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
-				| SUPPORTED_Asym_Pause),
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
 	.probe		= smsc_phy_probe,
@@ -237,8 +234,7 @@ static int smsc_phy_probe(struct phy_device *phydev)
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "SMSC LAN911x Internal PHY",
 
-	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
-				| SUPPORTED_Asym_Pause),
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
 	.probe		= smsc_phy_probe,
@@ -259,8 +255,7 @@ static int smsc_phy_probe(struct phy_device *phydev)
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "SMSC LAN8710/LAN8720",
 
-	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
-				| SUPPORTED_Asym_Pause),
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
 	.probe		= smsc_phy_probe,
@@ -282,8 +277,7 @@ static int smsc_phy_probe(struct phy_device *phydev)
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "SMSC LAN8740",
 
-	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
-				| SUPPORTED_Asym_Pause),
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
 	.probe		= smsc_phy_probe,
diff --git a/drivers/net/phy/ste10Xp.c b/drivers/net/phy/ste10Xp.c
index d00cfb6..1af1a4a 100644
--- a/drivers/net/phy/ste10Xp.c
+++ b/drivers/net/phy/ste10Xp.c
@@ -86,7 +86,7 @@ static int ste10Xp_ack_interrupt(struct phy_device *phydev)
 	.phy_id = STE101P_PHY_ID,
 	.phy_id_mask = 0xfffffff0,
 	.name = "STe101p",
-	.features = PHY_BASIC_FEATURES | SUPPORTED_Pause,
+	.features = PHY_BASIC_FEATURES,
 	.flags = PHY_HAS_INTERRUPT,
 	.config_init = ste10Xp_config_init,
 	.config_aneg = genphy_config_aneg,
@@ -99,7 +99,7 @@ static int ste10Xp_ack_interrupt(struct phy_device *phydev)
 	.phy_id = STE100P_PHY_ID,
 	.phy_id_mask = 0xffffffff,
 	.name = "STe100p",
-	.features = PHY_BASIC_FEATURES | SUPPORTED_Pause,
+	.features = PHY_BASIC_FEATURES,
 	.flags = PHY_HAS_INTERRUPT,
 	.config_init = ste10Xp_config_init,
 	.config_aneg = genphy_config_aneg,
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
