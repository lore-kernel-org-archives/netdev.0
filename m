From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH] gianfar: Free/iounmap memory after an error in mii bus initialization
Date: Thu, 18 Sep 2008 16:37:54 -0500
Message-ID: <1221773874-3273-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, danielm77@spray.se,
	akpm@linux-foundation.org, Andy Fleming <afleming@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:37580 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754631AbYIRVh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 17:37:59 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m8ILbtvx007264
	for <netdev@vger.kernel.org>; Thu, 18 Sep 2008 14:37:56 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id m8ILbsOt006512
	for <netdev@vger.kernel.org>; Thu, 18 Sep 2008 16:37:55 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent changes to MII bus initialization code added exit points which
didn't free or iounmap the bus before returning.

This was reported as bug #11372

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar_mii.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index ebcfb27..4804ec1 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -211,19 +211,21 @@ static int gfar_mdio_probe(struct device *dev)
 	gfar_write(&enet_regs->tbipa, 0);
 	for (i = PHY_MAX_ADDR; i > 0; i--) {
 		u32 phy_id;
-		int r;
 
-		r = get_phy_id(new_bus, i, &phy_id);
-		if (r)
-			return r;
+		err = get_phy_id(new_bus, i, &phy_id);
+		if (err)
+			goto bus_register_fail;
 
 		if (phy_id == 0xffffffff)
 			break;
 	}
 
 	/* The bus is full.  We don't support using 31 PHYs, sorry */
-	if (i == 0)
-		return -EBUSY;
+	if (i == 0) {
+		err = -EBUSY;
+
+		goto bus_register_fail;
+	}
 
 	gfar_write(&enet_regs->tbipa, i);
 
-- 
1.5.4.GIT

