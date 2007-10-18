From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/3][BNX2]: Fix Serdes WoL bug.
Date: Wed, 17 Oct 2007 19:39:23 -0700
Message-ID: <1192675163.9449.13.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mann@vmware.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3895 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762215AbXJRBms (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 21:42:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Fix Serdes WoL bug.

The bug is in the code in bnx2_set_power_state() that assumes copper
devices when setting up WoL.  This is no longer true after adding WoL
support for Serdes devices.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 78ed633..2a79ffc 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3079,14 +3079,18 @@ bnx2_set_power_state(struct bnx2 *bp, pci_power_t state)
 			autoneg = bp->autoneg;
 			advertising = bp->advertising;
 
-			bp->autoneg = AUTONEG_SPEED;
-			bp->advertising = ADVERTISED_10baseT_Half |
-				ADVERTISED_10baseT_Full |
-				ADVERTISED_100baseT_Half |
-				ADVERTISED_100baseT_Full |
-				ADVERTISED_Autoneg;
+			if (bp->phy_port == PORT_TP) {
+				bp->autoneg = AUTONEG_SPEED;
+				bp->advertising = ADVERTISED_10baseT_Half |
+					ADVERTISED_10baseT_Full |
+					ADVERTISED_100baseT_Half |
+					ADVERTISED_100baseT_Full |
+					ADVERTISED_Autoneg;
+			}
 
-			bnx2_setup_copper_phy(bp);
+			spin_lock_bh(&bp->phy_lock);
+			bnx2_setup_phy(bp, bp->phy_port);
+			spin_unlock_bh(&bp->phy_lock);
 
 			bp->autoneg = autoneg;
 			bp->advertising = advertising;
@@ -3097,10 +3101,16 @@ bnx2_set_power_state(struct bnx2 *bp, pci_power_t state)
 
 			/* Enable port mode. */
 			val &= ~BNX2_EMAC_MODE_PORT;
-			val |= BNX2_EMAC_MODE_PORT_MII |
-			       BNX2_EMAC_MODE_MPKT_RCVD |
+			val |= BNX2_EMAC_MODE_MPKT_RCVD |
 			       BNX2_EMAC_MODE_ACPI_RCVD |
 			       BNX2_EMAC_MODE_MPKT;
+			if (bp->phy_port == PORT_TP)
+				val |= BNX2_EMAC_MODE_PORT_MII;
+			else {
+				val |= BNX2_EMAC_MODE_PORT_GMII;
+				if (bp->line_speed == SPEED_2500)
+					val |= BNX2_EMAC_MODE_25G_MODE;
+			}
 
 			REG_WR(bp, BNX2_EMAC_MODE, val);
 


