From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 1/3] phy/marvell: Make non-aneg speed/duplex forcing work
 for 88E1111 PHYs
Date: Thu, 10 Sep 2009 06:01:30 +0400
Message-ID: <20090910020130.GA31083@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andy Fleming <afleming@freescale.com>,
	Timur Tabi <timur@freescale.com>,
	Li Yang <leoli@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:26211 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751530AbZIJCB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 22:01:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to specs, when auto-negotiation is disabled, Marvell PHYs need
a software reset after changing speed/duplex forcing bits. Otherwise,
the modified bits have no effect.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/phy/marvell.c |   21 ++++++++++++++++++++-
 1 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index dd6f54d..6f69b9b 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -155,8 +155,27 @@ static int marvell_config_aneg(struct phy_device *phydev)
 		return err;
 
 	err = genphy_config_aneg(phydev);
+	if (err < 0)
+		return err;
 
-	return err;
+	if (phydev->autoneg != AUTONEG_ENABLE) {
+		int bmcr;
+
+		/*
+		 * A write to speed/duplex bits (that is performed by
+		 * genphy_config_aneg() call above) must be followed by
+		 * a software reset. Otherwise, the write has no effect.
+		 */
+		bmcr = phy_read(phydev, MII_BMCR);
+		if (bmcr < 0)
+			return bmcr;
+
+		err = phy_write(phydev, MII_BMCR, bmcr | BMCR_RESET);
+		if (err < 0)
+			return err;
+	}
+
+	return 0;
 }
 
 static int m88e1121_config_aneg(struct phy_device *phydev)
-- 
1.6.3.3

