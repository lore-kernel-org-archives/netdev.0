From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/2] via-velocity: fix the WOL bug on 1000M full duplex forced mode
Date: Thu, 9 Dec 2010 10:27:17 +0100
Message-ID: <20101209092717.GB4064@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, DavidLv@viatech.com.cn,
	ShirleyHu@viatech.com.cn, AndersMa@viatech.com.cn
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40157 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753856Ab0LIJ1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 04:27:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VIA velocity card can't be waken up by WOL tool on 1000M full
duplex forced mode. This patch fixes the bug.

Signed-off-by: David Lv <DavidLv@viatech.com.cn>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>

---
 drivers/net/via-velocity.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 95accb9..052b344 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -3001,16 +3001,18 @@ static int velocity_set_wol(struct velocity_info *vptr)
 
 		MII_REG_BITS_ON(BMCR_ANRESTART, MII_BMCR, vptr->mac_regs);
 
-	} else {
-		if (vptr->mii_status & VELOCITY_AUTONEG_ENABLE) {
-			if (PHYID_GET_PHY_ID(vptr->phy_id) == PHYID_CICADA_CS8201)
-				MII_REG_BITS_ON(AUXCR_MDPPS, MII_NCONFIG, vptr->mac_regs);
+	} else if (SPD_DPX_1000_FULL != vptr->options.spd_dpx) {
+		if (SPD_DPX_AUTO == vptr->options.spd_dpx) {
+			if (vptr->mii_status & VELOCITY_AUTONEG_ENABLE) {
+				if (PHYID_GET_PHY_ID(vptr->phy_id) == PHYID_CICADA_CS8201)
+					MII_REG_BITS_ON(AUXCR_MDPPS, MII_NCONFIG, vptr->mac_regs);
 
-			MII_REG_BITS_OFF(ADVERTISE_1000FULL | ADVERTISE_1000HALF, MII_CTRL1000, vptr->mac_regs);
-		}
+				MII_REG_BITS_OFF(ADVERTISE_1000FULL | ADVERTISE_1000HALF, MII_CTRL1000, vptr->mac_regs);
+			}
 
-		if (vptr->mii_status & VELOCITY_SPEED_1000)
-			MII_REG_BITS_ON(BMCR_ANRESTART, MII_BMCR, vptr->mac_regs);
+			if (vptr->mii_status & VELOCITY_SPEED_1000)
+				MII_REG_BITS_ON(BMCR_ANRESTART, MII_BMCR, vptr->mac_regs);
+		}
 
 		BYTE_REG_BITS_ON(CHIPGCR_FCMODE, &regs->CHIPGCR);
 
-- 
1.7.3.2

