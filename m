From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH] phy: marvell: add link partner advertised modes
Date: Thu, 24 Sep 2015 00:07:17 +0100
Message-ID: <E1Zet89-0003P6-Ee@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:42870 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755310AbbIWXHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 19:07:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Read the standard link partner advertisment registers and store it in
phydev->lp_advertising, so ethtool can report this information to
userspace via ethtool.  Zero it as per genphy if autonegotiation is
disabled.  Tested with a Marvell 88E1512 PHY.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/phy/marvell.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index e6897b6a8a53..5de8d5827536 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -785,6 +785,7 @@ static int marvell_read_status(struct phy_device *phydev)
 	int adv;
 	int err;
 	int lpa;
+	int lpagb;
 	int status = 0;
 
 	/* Update the link, but return if there
@@ -802,10 +803,17 @@ static int marvell_read_status(struct phy_device *phydev)
 		if (lpa < 0)
 			return lpa;
 
+		lpagb = phy_read(phydev, MII_STAT1000);
+		if (lpagb < 0)
+			return lpagb;
+
 		adv = phy_read(phydev, MII_ADVERTISE);
 		if (adv < 0)
 			return adv;
 
+		phydev->lp_advertising = mii_stat1000_to_ethtool_lpa_t(lpagb) |
+					 mii_lpa_to_ethtool_lpa_t(lpa);
+
 		lpa &= adv;
 
 		if (status & MII_M1011_PHY_STATUS_FULLDUPLEX)
@@ -853,6 +861,7 @@ static int marvell_read_status(struct phy_device *phydev)
 			phydev->speed = SPEED_10;
 
 		phydev->pause = phydev->asym_pause = 0;
+		phydev->lp_advertising = 0;
 	}
 
 	return 0;
-- 
2.1.0
