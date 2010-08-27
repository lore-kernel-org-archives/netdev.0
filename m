From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Subject: [PATCH 2/2] sky2: Add unidirectional fiber link support
Date: Fri, 27 Aug 2010 15:42:18 -0400
Message-ID: <1282938138-17844-3-git-send-email-Kyle.D.Moffett@boeing.com>
References: <1282938138-17844-1-git-send-email-Kyle.D.Moffett@boeing.com>
Cc: Kyle Moffett <kyle@moffetthome.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Kyle Moffett <Kyle.D.Moffett@boeing.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1282938138-17844-1-git-send-email-Kyle.D.Moffett@boeing.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some sky2 fiber hardware seems to support configuring unidirectional
fiber links (using the phy bit PHY_M_FIB_FORCE_LNK).  There are three
parts to enabling this hardware support:

  (1) Allow DUPLEX_TXONLY/DUPLEX_RXONLY to be passed in via ethtool
  (2) Correctly configure the PHY using the new duplex values
  (3) Make sure the initial PHY link-up interrupt does not get lost

It may be possible to use the special DUPLEX_RXONLY operation mode to
disable the fiber transmitter entirely, but in practice we can safely
leave the chipset in regular full-duplex forced-link mode.

Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
---
 drivers/net/sky2.c |   80 ++++++++++++++++++++++++++++++++++-----------------
 drivers/net/sky2.h |    2 +-
 2 files changed, 54 insertions(+), 28 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 7985165..6fc915b 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -387,6 +387,10 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 		/* disable Automatic Crossover */
 
 		ctrl &= ~PHY_M_PC_MDIX_MSK;
+
+		/* If we have a transmit-only link then force the fiber on */
+		if (sky2->duplex == DUPLEX_TXONLY)
+			ctrl |= PHY_M_FIB_FORCE_LNK;
 	}
 
 	gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
@@ -462,7 +466,7 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 			break;
 		}
 
-		if (sky2->duplex == DUPLEX_FULL) {
+		if (sky2->duplex != DUPLEX_HALF) {
 			reg |= GM_GPCR_DUP_FULL;
 			ctrl |= PHY_CT_DUP_MD;
 		} else if (sky2->speed < SPEED_1000)
@@ -1667,6 +1671,15 @@ static int sky2_up(struct net_device *dev)
 
 	netif_info(sky2, ifup, dev, "enabling interface\n");
 
+	/* 
+	 * Once interrupts are reenabled, reset the PHY again to make sure
+	 * that we didn't miss a link-up interrupt.  This is especially
+	 * likely to occur if we're in fiber-txonly mode, as a link-up
+	 * interrupt is generated almost immediately after we finish
+	 * programming the PHY.
+	 */
+	sky2_phy_reinit(sky2);
+
 	return 0;
 
 err_out:
@@ -2053,12 +2066,18 @@ static void sky2_link_up(struct sky2_port *sky2)
 {
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
-	static const char *fc_name[] = {
+	static const char const *fc_name[] = {
 		[FC_NONE]	= "none",
 		[FC_TX]		= "tx",
 		[FC_RX]		= "rx",
 		[FC_BOTH]	= "both",
 	};
+	static const char const *duplex_name[] = {
+		[DUPLEX_HALF]   = "half",
+		[DUPLEX_FULL]   = "full",
+		[DUPLEX_TXONLY] = "txonly",
+		[DUPLEX_RXONLY] = "rxonly",
+	};
 
 	sky2_enable_rx_tx(sky2);
 
@@ -2073,10 +2092,10 @@ static void sky2_link_up(struct sky2_port *sky2)
 		    LINKLED_ON | LINKLED_BLINK_OFF | LINKLED_LINKSYNC_OFF);
 
 	netif_info(sky2, link, sky2->netdev,
-		   "Link is up at %d Mbps, %s duplex, flow control %s\n",
-		   sky2->speed,
-		   sky2->duplex == DUPLEX_FULL ? "full" : "half",
-		   fc_name[sky2->flow_status]);
+		"Link is up at %d Mbps, %s duplex, flow control %s\n",
+		sky2->speed,
+		duplex_name[sky2->duplex],
+		fc_name[sky2->flow_status]);
 }
 
 static void sky2_link_down(struct sky2_port *sky2)
@@ -3462,39 +3481,46 @@ static int sky2_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		sky2->duplex = -1;
 		sky2->speed = -1;
 	} else {
-		u32 setting;
+		u32 setting = supported;
 
+		/* Check the specified speed */
 		switch (ecmd->speed) {
 		case SPEED_1000:
-			if (ecmd->duplex == DUPLEX_FULL)
-				setting = SUPPORTED_1000baseT_Full;
-			else if (ecmd->duplex == DUPLEX_HALF)
-				setting = SUPPORTED_1000baseT_Half;
-			else
-				return -EINVAL;
+			setting &= ~(	SUPPORTED_1000baseT_Full |
+					SUPPORTED_1000baseT_Half );
 			break;
 		case SPEED_100:
-			if (ecmd->duplex == DUPLEX_FULL)
-				setting = SUPPORTED_100baseT_Full;
-			else if (ecmd->duplex == DUPLEX_HALF)
-				setting = SUPPORTED_100baseT_Half;
-			else
-				return -EINVAL;
+			setting &= ~(	SUPPORTED_100baseT_Full |
+					SUPPORTED_100baseT_Half );
 			break;
-
 		case SPEED_10:
-			if (ecmd->duplex == DUPLEX_FULL)
-				setting = SUPPORTED_10baseT_Full;
-			else if (ecmd->duplex == DUPLEX_HALF)
-				setting = SUPPORTED_10baseT_Half;
-			else
-				return -EINVAL;
+			setting &= ~(	SUPPORTED_10baseT_Full |
+					SUPPORTED_10baseT_Half );
+			break;
+		default:
+			return -EINVAL;
+		}
+
+		/* Check the specified duplex */
+		switch (ecmd->duplex) {
+		case DUPLEX_HALF:
+			setting &= ~(	SUPPORTED_1000baseT_Half |
+					SUPPORTED_100baseT_Half  |
+					SUPPORTED_10baseT_Half   );
+			break;
+		case DUPLEX_FULL:
+		case DUPLEX_RXONLY:
+		case DUPLEX_TXONLY:
+			setting &= ~(	SUPPORTED_1000baseT_Full |
+					SUPPORTED_100baseT_Full  |
+					SUPPORTED_10baseT_Full   );
 			break;
 		default:
 			return -EINVAL;
 		}
 
-		if ((setting & supported) == 0)
+		/* Make sure we have a valid mode */
+		if (!setting)
 			return -EINVAL;
 
 		sky2->speed = ecmd->speed;
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 084eff2..81980a4 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -2246,7 +2246,7 @@ struct sky2_port {
 	u16		     advertising;	/* ADVERTISED_ bits */
 	u16		     speed;		/* SPEED_1000, SPEED_100, ... */
 	u8		     wol;		/* WAKE_ bits */
-	u8		     duplex;		/* DUPLEX_HALF, DUPLEX_FULL */
+	u8		     duplex;		/* DUPLEX_HALF, DUPLEX_FULL, ... */
 	u16		     flags;
 #define SKY2_FLAG_RX_CHECKSUM		0x0001
 #define SKY2_FLAG_AUTO_SPEED		0x0002
-- 
1.7.1
