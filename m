From: akpm@osdl.org
Subject: [patch 10/10] EMAC: fix ibm_emac autonegotiation result parsing
Date: Tue, 04 Jan 2005 21:59:36 -0800
Message-ID: <200501050559.j055xj614727@mail.osdl.org>
Cc: davem@davemloft.net, netdev@oss.sgi.com, akpm@osdl.org,
        mporter@kernel.crashing.org, ebs@ebshome.net
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Matt Porter <mporter@kernel.crashing.org>

Fix aneg result parsing in ibm_emac driver.

Signed-off-by: Eugene Surovegin <ebs@ebshome.net>
Signed-off-by: Matt Porter <mporter@kernel.crashing.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/ibm_emac/ibm_emac_phy.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff -puN drivers/net/ibm_emac/ibm_emac_phy.c~fix-ibm_emac-autonegotiation-result-parsing drivers/net/ibm_emac/ibm_emac_phy.c
--- 25/drivers/net/ibm_emac/ibm_emac_phy.c~fix-ibm_emac-autonegotiation-result-parsing	2005-01-04 21:57:36.578573496 -0800
+++ 25-akpm/drivers/net/ibm_emac/ibm_emac_phy.c	2005-01-04 21:57:36.581573040 -0800
@@ -191,17 +191,18 @@ static int genmii_read_link(struct mii_p
 	u16 lpa;
 
 	if (phy->autoneg) {
-		lpa = phy_read(phy, MII_LPA);
+		lpa = phy_read(phy, MII_LPA) & phy_read(phy, MII_ADVERTISE);
 
-		if (lpa & (LPA_10FULL | LPA_100FULL))
-			phy->duplex = DUPLEX_FULL;
-		else
-			phy->duplex = DUPLEX_HALF;
-		if (lpa & (LPA_100FULL | LPA_100HALF))
-			phy->speed = SPEED_100;
-		else
-			phy->speed = SPEED_10;
+		phy->speed = SPEED_10;
+		phy->duplex = DUPLEX_HALF;
 		phy->pause = 0;
+
+		if (lpa & (LPA_100FULL | LPA_100HALF)) {
+			phy->speed = SPEED_100;
+			if (lpa & LPA_100FULL)
+				phy->duplex = DUPLEX_FULL;
+		} else if (lpa & LPA_10FULL)
+			phy->duplex = DUPLEX_FULL;
 	}
 	/* On non-aneg, we assume what we put in BMCR is the speed,
 	 * though magic-aneg shouldn't prevent this case from occurring
_
