From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.9-rc net driver fixes
Date: Sat, 28 Aug 2004 20:21:36 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040829002136.GA14255@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/e1000/e1000_param.c      |    2 
 drivers/net/ibm_emac/ibm_emac.h      |   32 +++++++--------
 drivers/net/ibm_emac/ibm_emac_core.c |   74 ++++++++++++++++++++++-------------
 drivers/net/ibm_emac/ibm_emac_core.h |    2 
 drivers/net/sis900.c                 |    1 
 5 files changed, 66 insertions(+), 45 deletions(-)

through these ChangeSets:

<mporter@kernel.crashing.org> (04/08/28 1.1914)
   [PATCH] ibm_emac driver updates
   
   Optimizes transmit windows for improved performance and to prevent
   TX underruns. Fixes driver registration error handling. Fixes ZMII
   and RGMII thinkos. Fixes for MDIO handling issues from Ralph
   Siemsen. Please apply.
   
   Signed-off-by: Matt Porter <mporter@kernel.crashing.org>

<tharbaugh@lnxi.com> (04/08/28 1.1913)
   [netdrvr e1000] disable DITR, which apparently hurts performance

<akpm@osdl.org> (04/08/28 1.1912)
   [PATCH] Problem with SiS900 - Unknown PHY
   
   From: Laurent <laurent@gobio2.net>
   
   Some time ago, I sent on this list a mail about my strange problem with my
   SiS900 network card (Subject was Sluggish performances with FreeBSD)
   
   To sum up, when my card is in 100Mb mode, I have poor throughput but in
   10Mb, all seems normal.
   
   After some tests, it seems these results was due to a misdetection of the
   PHY device.  mii-tool reports :
   
    product info: vendor 08:00:17, model 3 rev 0
   
   and after some search on the web, I found it's a NS DP83847 which is very
   similar.
   
   Signed-off-by: Andrew Morton <akpm@osdl.org>

diff -Nru a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
--- a/drivers/net/e1000/e1000_param.c	2004-08-28 20:20:30 -04:00
+++ b/drivers/net/e1000/e1000_param.c	2004-08-28 20:20:30 -04:00
@@ -212,7 +212,7 @@
 #define MAX_TXABSDELAY            0xFFFF
 #define MIN_TXABSDELAY                 0
 
-#define DEFAULT_ITR                    1
+#define DEFAULT_ITR                 8000
 #define MAX_ITR                   100000
 #define MIN_ITR                      100
 
diff -Nru a/drivers/net/ibm_emac/ibm_emac.h b/drivers/net/ibm_emac/ibm_emac.h
--- a/drivers/net/ibm_emac/ibm_emac.h	2004-08-28 20:20:30 -04:00
+++ b/drivers/net/ibm_emac/ibm_emac.h	2004-08-28 20:20:30 -04:00
@@ -228,6 +228,21 @@
 	 (desc & EMAC_BAD_RX_PACKET)
 #endif
 
+/* SoC implementation specific EMAC register defaults */
+#if defined(CONFIG_440GP)
+#define EMAC_RWMR_DEFAULT		0x80009000
+#define EMAC_TMR0_DEFAULT		0x00000000
+#define EMAC_TMR1_DEFAULT		0xf8640000
+#elif defined(CONFIG_440GX)
+#define EMAC_RWMR_DEFAULT		0x1000a200
+#define EMAC_TMR0_DEFAULT		EMAC_TMR0_TFAE_2_32
+#define EMAC_TMR1_DEFAULT		0xa00f0000
+#else
+#define EMAC_RWMR_DEFAULT		0x0f002000
+#define EMAC_TMR0_DEFAULT		0x00000000
+#define EMAC_TMR1_DEFAULT		0x380f0000
+#endif				/* CONFIG_440GP */
+
 /* Revision specific EMAC register defaults */
 #ifdef CONFIG_IBM_EMAC4
 #define EMAC_M1_DEFAULT			(EMAC_M1_BASE | \
@@ -236,7 +251,7 @@
 #define EMAC_RMR_DEFAULT		(EMAC_RMR_BASE | \
 					EMAC_RMR_RFAF_128_2048)
 #define EMAC_TMR0_XMIT			(EMAC_TMR0_GNP0 | \
-					EMAC_TMR0_TFAE_128_2048)
+					EMAC_TMR0_DEFAULT)
 #define EMAC_TRTR_DEFAULT		EMAC_TRTR_1024
 #else				/* !CONFIG_IBM_EMAC4 */
 #define EMAC_M1_DEFAULT			EMAC_M1_BASE
@@ -244,20 +259,5 @@
 #define EMAC_TMR0_XMIT			EMAC_TMR0_GNP0
 #define EMAC_TRTR_DEFAULT		EMAC_TRTR_1600
 #endif				/* CONFIG_IBM_EMAC4 */
-
-/* SoC implementation specific EMAC register defaults */
-#if defined(CONFIG_440GP)
-#define EMAC_RWMR_DEFAULT		0x80009000
-#define EMAC_TMR0_DEFAULT		0x00000000
-#define EMAC_TMR1_DEFAULT		0xf8640000
-#elif defined(CONFIG_440GX)
-#define EMAC_RWMR_DEFAULT		0x1000a200
-#define EMAC_TMR0_DEFAULT		EMAC_TMR0_TFAE_128_2048
-#define EMAC_TMR1_DEFAULT		0x88810000
-#else
-#define EMAC_RWMR_DEFAULT		0x0f002000
-#define EMAC_TMR0_DEFAULT		0x00000000
-#define EMAC_TMR1_DEFAULT		0x380f0000
-#endif				/* CONFIG_440GP */
 
 #endif
diff -Nru a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
--- a/drivers/net/ibm_emac/ibm_emac_core.c	2004-08-28 20:20:30 -04:00
+++ b/drivers/net/ibm_emac/ibm_emac_core.c	2004-08-28 20:20:30 -04:00
@@ -90,23 +90,24 @@
 
 #define RGMII_PRIV(ocpdev) ((struct ibm_ocp_rgmii*)ocp_get_drvdata(ocpdev))
 
-static unsigned int rgmii_enable[] =
-    { RGMII_RTBI, RGMII_RGMII, RGMII_TBI, RGMII_GMII };
+static unsigned int rgmii_enable[] = {
+	RGMII_RTBI,
+	RGMII_RGMII,
+	RGMII_TBI,
+	RGMII_GMII
+};
 
-static unsigned int rgmii_speed_mask[] = { 0,
-	0,
+static unsigned int rgmii_speed_mask[] = {
 	RGMII_MII2_SPDMASK,
 	RGMII_MII3_SPDMASK
 };
 
-static unsigned int rgmii_speed100[] = { 0,
-	0,
+static unsigned int rgmii_speed100[] = {
 	RGMII_MII2_100MB,
 	RGMII_MII3_100MB
 };
 
-static unsigned int rgmii_speed1000[] = { 0,
-	0,
+static unsigned int rgmii_speed1000[] = {
 	RGMII_MII2_1000MB,
 	RGMII_MII3_1000MB
 };
@@ -122,11 +123,21 @@
 	 ~(ZMII_MDI0 | ZMII_MDI1 | ZMII_MDI3)},
 	{ZMII_SMII3, ZMII_RMII3, ZMII_MII3, ~(ZMII_MDI0 | ZMII_MDI1 | ZMII_MDI2)}
 };
-static unsigned int mdi_enable[] =
-    { ZMII_MDI0, ZMII_MDI1, ZMII_MDI2, ZMII_MDI3 };
+
+static unsigned int mdi_enable[] = {
+	ZMII_MDI0,
+	ZMII_MDI1,
+	ZMII_MDI2,
+	ZMII_MDI3
+};
 
 static unsigned int zmii_speed = 0x0;
-static unsigned int zmii_speed100[] = { ZMII_MII0_100MB, ZMII_MII1_100MB };
+static unsigned int zmii_speed100[] = {
+	ZMII_MII0_100MB,
+	ZMII_MII1_100MB,
+	ZMII_MII2_100MB,
+	ZMII_MII3_100MB
+};
 
 /* Since multiple EMACs share MDIO lines in various ways, we need
  * to avoid re-using the same PHY ID in cases where the arch didn't
@@ -367,6 +378,7 @@
 
 int emac_phy_read(struct net_device *dev, int mii_id, int reg)
 {
+	int count;
 	uint32_t stacr;
 	struct ocp_enet_private *fep = dev->priv;
 	emac_t *emacp = fep->emacp;
@@ -385,9 +397,13 @@
 		emacp = fep->emacp;
 	}
 
-	udelay(MDIO_DELAY);
+	count = 0;
+	while ((((stacr = in_be32(&emacp->em0stacr)) & EMAC_STACR_OC) == 0)
+					&& (count++ < MDIO_DELAY))
+		udelay(1);
+	MDIO_DEBUG((" (count was %d)\n", count));
 
-	if ((in_be32(&emacp->em0stacr) & EMAC_STACR_OC) == 0) {
+	if ((stacr & EMAC_STACR_OC) == 0) {
 		printk(KERN_WARNING "%s: PHY read timeout #1!\n", dev->name);
 		return -1;
 	}
@@ -398,8 +414,11 @@
 
 	out_be32(&emacp->em0stacr, stacr);
 
-	udelay(MDIO_DELAY);
-	stacr = in_be32(&emacp->em0stacr);
+	count = 0;
+	while ((((stacr = in_be32(&emacp->em0stacr)) & EMAC_STACR_OC) == 0)
+					&& (count++ < MDIO_DELAY))
+		udelay(1);
+	MDIO_DEBUG((" (count was %d)\n", count));
 
 	if ((stacr & EMAC_STACR_OC) == 0) {
 		printk(KERN_WARNING "%s: PHY read timeout #2!\n", dev->name);
@@ -419,6 +438,7 @@
 
 void emac_phy_write(struct net_device *dev, int mii_id, int reg, int data)
 {
+	int count;
 	uint32_t stacr;
 	struct ocp_enet_private *fep = dev->priv;
 	emac_t *emacp = fep->emacp;
@@ -437,9 +457,13 @@
 		emacp = fep->emacp;
 	}
 
-	udelay(MDIO_DELAY);
+	count = 0;
+	while ((((stacr = in_be32(&emacp->em0stacr)) & EMAC_STACR_OC) == 0)
+					&& (count++ < MDIO_DELAY))
+		udelay(1);
+	MDIO_DEBUG((" (count was %d)\n", count));
 
-	if ((in_be32(&emacp->em0stacr) & EMAC_STACR_OC) == 0) {
+	if ((stacr & EMAC_STACR_OC) == 0) {
 		printk(KERN_WARNING "%s: PHY write timeout #2!\n", dev->name);
 		return;
 	}
@@ -451,9 +475,12 @@
 
 	out_be32(&emacp->em0stacr, stacr);
 
-	udelay(MDIO_DELAY);
+	while (((stacr = in_be32(&emacp->em0stacr) & EMAC_STACR_OC) == 0)
+					&& (count++ < 5000))
+		udelay(1);
+	MDIO_DEBUG((" (count was %d)\n", count));
 
-	if ((in_be32(&emacp->em0stacr) & EMAC_STACR_OC) == 0)
+	if ((stacr & EMAC_STACR_OC) == 0)
 		printk(KERN_WARNING "%s: PHY write timeout #2!\n", dev->name);
 
 	/* Check for a write error */
@@ -1940,8 +1967,6 @@
 
 static int __init emac_init(void)
 {
-	int rc;
-
 	printk(KERN_INFO DRV_NAME ": " DRV_DESC ", version " DRV_VERSION "\n");
 	printk(KERN_INFO "Maintained by " DRV_AUTHOR "\n");
 
@@ -1950,13 +1975,8 @@
 		       skb_res);
 		skb_res = 2;
 	}
-	rc = ocp_register_driver(&emac_driver);
-	if (rc < 0) {
-		ocp_unregister_driver(&emac_driver);
-		return -ENODEV;
-	}
 
-	return 0;
+	return ocp_register_driver(&emac_driver);
 }
 
 static void __exit emac_exit(void)
diff -Nru a/drivers/net/ibm_emac/ibm_emac_core.h b/drivers/net/ibm_emac/ibm_emac_core.h
--- a/drivers/net/ibm_emac/ibm_emac_core.h	2004-08-28 20:20:30 -04:00
+++ b/drivers/net/ibm_emac/ibm_emac_core.h	2004-08-28 20:20:30 -04:00
@@ -67,7 +67,7 @@
 #define TX_TIMEOUT		(2*HZ)
 
 /* MDIO latency delay */
-#define MDIO_DELAY		50
+#define MDIO_DELAY		250
 
 /* Power managment shift registers */
 #define IBM_CPM_EMMII	0	/* Shift value for MII */
diff -Nru a/drivers/net/sis900.c b/drivers/net/sis900.c
--- a/drivers/net/sis900.c	2004-08-28 20:20:30 -04:00
+++ b/drivers/net/sis900.c	2004-08-28 20:20:30 -04:00
@@ -124,6 +124,7 @@
 	{ "AMD 79C901 HomePNA PHY",		0x0000, 0x6B90, HOME},
 	{ "ICS LAN PHY",			0x0015, 0xF440, LAN },
 	{ "NS 83851 PHY",			0x2000, 0x5C20, MIX },
+	{ "NS 83847 PHY",                       0x2000, 0x5C30, MIX },
 	{ "Realtek RTL8201 PHY",		0x0000, 0x8200, LAN },
 	{ "VIA 6103 PHY",			0x0101, 0x8f20, LAN },
 	{NULL,},
