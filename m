From: David Lv <davidlv.linux@gmail.com>
Subject: [PATCH 2/2] via-velocity: fix the WOL bug on 1000M full duplex forced mode
Date: Wed, 8 Dec 2010 13:47:19 +0800
Message-ID: <AANLkTi=+r4cjE-3RJgrsrVaPBz0Ok_7XqZ+dxZgFCCUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	DavidLv@viatech.com.cn, ShirleyHu@viatech.com.cn,
	AndersMa@viatech.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55564 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792Ab0LHFrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 00:47:20 -0500
Received: by wyb28 with SMTP id 28so726361wyb.19
        for <netdev@vger.kernel.org>; Tue, 07 Dec 2010 21:47:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VIA velocity card can't be waken up by WOL tool on 1000M full
duplex forced mode.
This patch fixes the bug.
Thanks!

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

-			MII_REG_BITS_OFF(ADVERTISE_1000FULL | ADVERTISE_1000HALF,
MII_CTRL1000, vptr->mac_regs);
-		}
+				MII_REG_BITS_OFF(ADVERTISE_1000FULL | ADVERTISE_1000HALF,
MII_CTRL1000, vptr->mac_regs);
+			}

-		if (vptr->mii_status & VELOCITY_SPEED_1000)
-			MII_REG_BITS_ON(BMCR_ANRESTART, MII_BMCR, vptr->mac_regs);
+			if (vptr->mii_status & VELOCITY_SPEED_1000)
+				MII_REG_BITS_ON(BMCR_ANRESTART, MII_BMCR, vptr->mac_regs);
+		}

 		BYTE_REG_BITS_ON(CHIPGCR_FCMODE, &regs->CHIPGCR);

-- 
1.7.3.2
