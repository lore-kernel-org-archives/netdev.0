From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-2.6 1/2] jme: GHC register control fix for new hardware
Date: Wed, 3 Dec 2008 18:41:39 +0800
Message-ID: <20081203103825.M4442@cooldavid.org>
References: <20080915165101.M68109@cooldavid.org> <48D27CDA.50501@pobox.com> <20081008215853.M53590@cooldavid.org>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
Cc: netdev@vger.kernel.org, Ethan <ethanhsiao@jmicron.com>,
	akeemting <akeem@jmicron.com>
To: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:42263 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268AbYLCKlv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2008 05:41:51 -0500
In-Reply-To: <20081008215853.M53590@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Jeff, David:

Due to the hardware design, except the first chip on the market,
other chips needs to setup the clock source for MAC processor
implicitly through Global Host Control Register(GHC).
(Strange design huh?)

10/100M uses the PCI-E as clock source, and 1G uses GPHY.

And I reordered the code a little, to make it easier to read.

Found-by: "Ethan" <ethanhsiao@jmicron.com>
Fixed-by: "akeemting" <akeem@jmicron.com>
Signed-off-by: "Guo-Fu Tseng" <cooldavid@cooldavid.org>

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 665e70d..49090ba 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -435,15 +435,18 @@ jme_check_link(struct net_device *netdev, int testonly)
 					GHC_DPX);
 		switch (phylink & PHY_LINK_SPEED_MASK) {
 		case PHY_LINK_SPEED_10M:
-			ghc |= GHC_SPEED_10M;
+			ghc |= GHC_SPEED_10M |
+				GHC_TO_CLK_PCIE | GHC_TXMAC_CLK_PCIE;
 			strcat(linkmsg, "10 Mbps, ");
 			break;
 		case PHY_LINK_SPEED_100M:
-			ghc |= GHC_SPEED_100M;
+			ghc |= GHC_SPEED_100M |
+				GHC_TO_CLK_PCIE | GHC_TXMAC_CLK_PCIE;
 			strcat(linkmsg, "100 Mbps, ");
 			break;
 		case PHY_LINK_SPEED_1000M:
-			ghc |= GHC_SPEED_1000M;
+			ghc |= GHC_SPEED_1000M |
+				GHC_TO_CLK_GPHY | GHC_TXMAC_CLK_GPHY;
 			strcat(linkmsg, "1000 Mbps, ");
 			break;
 		default:
@@ -463,14 +466,6 @@ jme_check_link(struct net_device *netdev, int testonly)
 				TXTRHD_TXREN |
 				((8 << TXTRHD_TXRL_SHIFT) & TXTRHD_TXRL));
 		}
-		strcat(linkmsg, (phylink & PHY_LINK_DUPLEX) ?
-					"Full-Duplex, " :
-					"Half-Duplex, ");
-
-		if (phylink & PHY_LINK_MDI_STAT)
-			strcat(linkmsg, "MDI-X");
-		else
-			strcat(linkmsg, "MDI");
 
 		gpreg1 = GPREG1_DEFAULT;
 		if (is_buggy250(jme->pdev->device, jme->chiprev)) {
@@ -492,11 +487,17 @@ jme_check_link(struct net_device *netdev, int testonly)
 				break;
 			}
 		}
-		jwrite32(jme, JME_GPREG1, gpreg1);
 
-		jme->reg_ghc = ghc;
+		jwrite32(jme, JME_GPREG1, gpreg1);
 		jwrite32(jme, JME_GHC, ghc);
+		jme->reg_ghc = ghc;
 
+		strcat(linkmsg, (phylink & PHY_LINK_DUPLEX) ?
+					"Full-Duplex, " :
+					"Half-Duplex, ");
+		strcat(linkmsg, (phylink & PHY_LINK_MDI_STAT) ?
+					"MDI-X" :
+					"MDI");
 		msg_link(jme, "Link is up at %s.\n", linkmsg);
 		netif_carrier_on(netdev);
 	} else {
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index f863aee..adaf3dd 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -815,16 +815,30 @@ static inline u32 smi_phy_addr(int x)
  * Global Host Control
  */
 enum jme_ghc_bit_mask {
-	GHC_SWRST	= 0x40000000,
-	GHC_DPX		= 0x00000040,
-	GHC_SPEED	= 0x00000030,
-	GHC_LINK_POLL	= 0x00000001,
+	GHC_SWRST		= 0x40000000,
+	GHC_DPX			= 0x00000040,
+	GHC_SPEED		= 0x00000030,
+	GHC_LINK_POLL		= 0x00000001,
 };
 
 enum jme_ghc_speed_val {
-	GHC_SPEED_10M	= 0x00000010,
-	GHC_SPEED_100M	= 0x00000020,
-	GHC_SPEED_1000M	= 0x00000030,
+	GHC_SPEED_10M		= 0x00000010,
+	GHC_SPEED_100M		= 0x00000020,
+	GHC_SPEED_1000M		= 0x00000030,
+};
+
+enum jme_ghc_to_clk {
+	GHC_TO_CLK_OFF		= 0x00000000,
+	GHC_TO_CLK_GPHY		= 0x00400000,
+	GHC_TO_CLK_PCIE		= 0x00800000,
+	GHC_TO_CLK_INVALID	= 0x00C00000,
+};
+
+enum jme_ghc_txmac_clk {
+	GHC_TXMAC_CLK_OFF	= 0x00000000,
+	GHC_TXMAC_CLK_GPHY	= 0x00100000,
+	GHC_TXMAC_CLK_PCIE	= 0x00200000,
+	GHC_TXMAC_CLK_INVALID	= 0x00300000,
 };
 
 /*

