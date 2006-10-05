From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/4] skge: pause mapping for fiber
Date: Thu, 05 Oct 2006 15:49:51 -0700
Message-ID: <20061005225209.419641008@osdl.org>
References: <20061005224949.456192755@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:8656 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932434AbWJEXz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 19:55:29 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-fiber-half.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do correct mapping of pause and duplex when using 1000BaseX fiber
versions of the board.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


---
 drivers/net/skge.c |   38 +++++++++++++++++++++-----------------
 1 file changed, 21 insertions(+), 17 deletions(-)

--- linux-2.6.orig/drivers/net/skge.c
+++ linux-2.6/drivers/net/skge.c
@@ -197,8 +197,8 @@ static u32 skge_supported_modes(const st
 		else if (hw->chip_id == CHIP_ID_YUKON)
 			supported &= ~SUPPORTED_1000baseT_Half;
 	} else
-		supported = SUPPORTED_1000baseT_Full | SUPPORTED_FIBRE
-			| SUPPORTED_Autoneg;
+		supported = SUPPORTED_1000baseT_Full | SUPPORTED_1000baseT_Half
+			| SUPPORTED_FIBRE | SUPPORTED_Autoneg;
 
 	return supported;
 }
@@ -1018,6 +1018,14 @@ static const u16 phy_pause_map[] = {
 	[FLOW_MODE_REM_SEND]  = PHY_AN_PAUSE_CAP | PHY_AN_PAUSE_ASYM,
 };
 
+/* special defines for FIBER (88E1011S only) */
+static const u16 fiber_pause_map[] = {
+	[FLOW_MODE_NONE]	= PHY_X_P_NO_PAUSE,
+	[FLOW_MODE_LOC_SEND]	= PHY_X_P_ASYM_MD,
+	[FLOW_MODE_SYMMETRIC]	= PHY_X_P_SYM_MD,
+	[FLOW_MODE_REM_SEND]	= PHY_X_P_BOTH_MD,
+};
+
 
 /* Check status of Broadcom phy link */
 static void bcom_check_link(struct skge_hw *hw, int port)
@@ -1207,17 +1215,7 @@ static void xm_phy_init(struct skge_port
 		if (skge->advertising & ADVERTISED_1000baseT_Full)
 			ctrl |= PHY_X_AN_FD;
 
-		switch(skge->flow_control) {
-		case FLOW_MODE_NONE:
-			ctrl |= PHY_X_P_NO_PAUSE;
-			break;
-		case FLOW_MODE_LOC_SEND:
-			ctrl |= PHY_X_P_ASYM_MD;
-			break;
-		case FLOW_MODE_SYMMETRIC:
-			ctrl |= PHY_X_P_BOTH_MD;
-			break;
-		}
+		ctrl |= fiber_pause_map[skge->flow_control];
 
 		xm_phy_write(hw, port, PHY_XMAC_AUNE_ADV, ctrl);
 
@@ -1796,11 +1794,17 @@ static void yukon_init(struct skge_hw *h
 				adv |= PHY_M_AN_10_FD;
 			if (skge->advertising & ADVERTISED_10baseT_Half)
 				adv |= PHY_M_AN_10_HD;
-		} else	/* special defines for FIBER (88E1011S only) */
-			adv |= PHY_M_AN_1000X_AHD | PHY_M_AN_1000X_AFD;
 
-		/* Set Flow-control capabilities */
-		adv |= phy_pause_map[skge->flow_control];
+			/* Set Flow-control capabilities */
+			adv |= phy_pause_map[skge->flow_control];
+		} else {
+			if (skge->advertising & ADVERTISED_1000baseT_Full)
+				adv |= PHY_M_AN_1000X_AFD;
+			if (skge->advertising & ADVERTISED_1000baseT_Half)
+				adv |= PHY_M_AN_1000X_AHD;
+
+			adv |= fiber_pause_map[skge->flow_control];
+		}
 
 		/* Restart Auto-negotiation */
 		ctrl |= PHY_CT_ANE | PHY_CT_RE_CFG;

--
Stephen Hemminger <shemminger@osdl.org>

