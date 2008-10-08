From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 1/3] jme: Added half-duplex mode and IPv6 RSS fix
Date: Thu, 9 Oct 2008 05:56:01 +0800
Message-ID: <20081008215205.M37765@cooldavid.org>
References: <20080915165101.M68109@cooldavid.org> <48D27CDA.50501@pobox.com>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
Cc: netdev@vger.kernel.org, Ethan <ethanhsiao@jmicron.com>,
	akeemting <akeem@jmicron.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 220-133-139-86.HINET-IP.hinet.net ([220.133.139.86]:59307 "EHLO
	cooldavid.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754406AbYJHV43 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 17:56:29 -0400
In-Reply-To: <48D27CDA.50501@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Jeff, David:

This patch:

    1. Set bit 5 of GPREG1 to 1 to enable hardware workaround for half-duplex
       mode. Which the MAC processor generates CRS/COL by itself instead of
       receive it from PHY processor.

    2. Set bit 6 of GPREG1 to 1 to enable hardware workaround that masks the
       MAC processor working right while calculating IPv6 RSS in 10/100
       mode.

    3. Group the workaround codes all together.

    The patch is also available at:
    http://cooldavid.org/download/jme.net-next-2.6.20081009.1.patch

    Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index f292df5..635f616 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -190,7 +190,7 @@ jme_reset_mac_processor(struct jme_adapter *jme)
 	else
 		gpreg0 = GPREG0_DEFAULT;
 	jwrite32(jme, JME_GPREG0, gpreg0);
-	jwrite32(jme, JME_GPREG1, 0);
+	jwrite32(jme, JME_GPREG1, GPREG1_DEFAULT);
 }
 
 static inline void
@@ -365,7 +365,7 @@ static int
 jme_check_link(struct net_device *netdev, int testonly)
 {
 	struct jme_adapter *jme = netdev_priv(netdev);
-	u32 phylink, ghc, cnt = JME_SPDRSV_TIMEOUT, bmcr;
+	u32 phylink, ghc, cnt = JME_SPDRSV_TIMEOUT, bmcr, gpreg1;
 	char linkmsg[64];
 	int rc = 0;
 
@@ -437,37 +437,22 @@ jme_check_link(struct net_device *netdev, int testonly)
 		case PHY_LINK_SPEED_10M:
 			ghc |= GHC_SPEED_10M;
 			strcat(linkmsg, "10 Mbps, ");
-			if (is_buggy250(jme->pdev->device, jme->chiprev))
-				jme_set_phyfifoa(jme);
 			break;
 		case PHY_LINK_SPEED_100M:
 			ghc |= GHC_SPEED_100M;
 			strcat(linkmsg, "100 Mbps, ");
-			if (is_buggy250(jme->pdev->device, jme->chiprev))
-				jme_set_phyfifob(jme);
 			break;
 		case PHY_LINK_SPEED_1000M:
 			ghc |= GHC_SPEED_1000M;
 			strcat(linkmsg, "1000 Mbps, ");
-			if (is_buggy250(jme->pdev->device, jme->chiprev))
-				jme_set_phyfifoa(jme);
 			break;
 		default:
 			break;
 		}
-		ghc |= (phylink & PHY_LINK_DUPLEX) ? GHC_DPX : 0;
-
-		strcat(linkmsg, (phylink & PHY_LINK_DUPLEX) ?
-					"Full-Duplex, " :
-					"Half-Duplex, ");
-
-		if (phylink & PHY_LINK_MDI_STAT)
-			strcat(linkmsg, "MDI-X");
-		else
-			strcat(linkmsg, "MDI");
 
 		if (phylink & PHY_LINK_DUPLEX) {
 			jwrite32(jme, JME_TXMCS, TXMCS_DEFAULT);
+			ghc |= GHC_DPX;
 		} else {
 			jwrite32(jme, JME_TXMCS, TXMCS_DEFAULT |
 						TXMCS_BACKOFF |
@@ -478,6 +463,36 @@ jme_check_link(struct net_device *netdev, int testonly)
 				TXTRHD_TXREN |
 				((8 << TXTRHD_TXRL_SHIFT) & TXTRHD_TXRL));
 		}
+		strcat(linkmsg, (phylink & PHY_LINK_DUPLEX) ?
+					"Full-Duplex, " :
+					"Half-Duplex, ");
+
+		if (phylink & PHY_LINK_MDI_STAT)
+			strcat(linkmsg, "MDI-X");
+		else
+			strcat(linkmsg, "MDI");
+
+		gpreg1 = GPREG1_DEFAULT;
+		if (is_buggy250(jme->pdev->device, jme->chiprev)) {
+			if (!(phylink & PHY_LINK_DUPLEX))
+				gpreg1 |= GPREG1_HALFMODEPATCH;
+			switch (phylink & PHY_LINK_SPEED_MASK) {
+			case PHY_LINK_SPEED_10M:
+				jme_set_phyfifoa(jme);
+				gpreg1 |= GPREG1_RSSPATCH;
+				break;
+			case PHY_LINK_SPEED_100M:
+				jme_set_phyfifob(jme);
+				gpreg1 |= GPREG1_RSSPATCH;
+				break;
+			case PHY_LINK_SPEED_1000M:
+				jme_set_phyfifoa(jme);
+				break;
+			default:
+				break;
+			}
+		}
+		jwrite32(jme, JME_GPREG1, gpreg1);
 
 		jme->reg_ghc = ghc;
 		jwrite32(jme, JME_GHC, ghc);
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index b296884..9fdf20a 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -964,6 +964,36 @@ enum jme_gpreg0_vals {
 };
 
 /*
+ * General Purpose REG-1
+ * Note: All theses bits defined here are for
+ *       Chip mode revision 0x11 only
+ */
+enum jme_gpreg1_masks {
+	GPREG1_INTRDELAYUNIT	= 0x00000018,
+	GPREG1_INTRDELAYENABLE	= 0x00000007,
+};
+
+enum jme_gpreg1_vals {
+	GPREG1_RSSPATCH		= 0x00000040,
+	GPREG1_HALFMODEPATCH	= 0x00000020,
+
+	GPREG1_INTDLYUNIT_16NS	= 0x00000000,
+	GPREG1_INTDLYUNIT_256NS	= 0x00000008,
+	GPREG1_INTDLYUNIT_1US	= 0x00000010,
+	GPREG1_INTDLYUNIT_16US	= 0x00000018,
+
+	GPREG1_INTDLYEN_1U	= 0x00000001,
+	GPREG1_INTDLYEN_2U	= 0x00000002,
+	GPREG1_INTDLYEN_3U	= 0x00000003,
+	GPREG1_INTDLYEN_4U	= 0x00000004,
+	GPREG1_INTDLYEN_5U	= 0x00000005,
+	GPREG1_INTDLYEN_6U	= 0x00000006,
+	GPREG1_INTDLYEN_7U	= 0x00000007,
+
+	GPREG1_DEFAULT		= 0x00000000,
+};
+
+/*
  * Interrupt Status Bits
  */
 enum jme_interrupt_bits {

