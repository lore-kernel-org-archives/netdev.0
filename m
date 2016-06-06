From: Manfred Schlaegl <manfred.schlaegl@ginzinger.com>
Subject: [PATCH] net: phy: smsc: reintroduced unconditional soft reset
Date: Mon, 6 Jun 2016 10:47:47 +0200
Message-ID: <575538B3.8030406@ginzinger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Gwenhael Goavec-Merou <gwenhael.goavec-merou@armadeus.com>,
	Manfred Schlaegl <manfred.schlaegl@gmx.at>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We detected some problems using the smsc lan8720a in combination with
i.MX28 and tracked this down to commit 21009686662f ("net: phy: smsc: move
smsc_phy_config_init reset part in a soft_reset function")
With 2100968666 the generic soft reset is replaced by a specific function
which handles power down state correctly. But additionally the soft reset
itself got conditional and is therefore also only performed if the phy is
in power down state.

This patch keeps the conditional wake up from power down, but
re-introduces the unconditional soft reset using the generic soft reset
function.
It was tested on linux-4.1.25 and linux-4.7.0-rc2.

Signed-off-by: Manfred Schlaegl <manfred.schlaegl@ginzinger.com>
---
 drivers/net/phy/smsc.c | 17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 2e21e93..b62c4aa 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -75,22 +75,13 @@ static int smsc_phy_reset(struct phy_device *phydev)
 	 * in all capable mode before using it.
 	 */
 	if ((rc & MII_LAN83C185_MODE_MASK) == MII_LAN83C185_MODE_POWERDOWN) {
-		int timeout = 50000;
-
-		/* set "all capable" mode and reset the phy */
+		/* set "all capable" mode */
 		rc |= MII_LAN83C185_MODE_ALL;
 		phy_write(phydev, MII_LAN83C185_SPECIAL_MODES, rc);
-		phy_write(phydev, MII_BMCR, BMCR_RESET);
-
-		/* wait end of reset (max 500 ms) */
-		do {
-			udelay(10);
-			if (timeout-- == 0)
-				return -1;
-			rc = phy_read(phydev, MII_BMCR);
-		} while (rc & BMCR_RESET);
 	}
-	return 0;
+
+	/* reset the phy */
+	return genphy_soft_reset(phydev);
 }
 
 static int lan911x_config_init(struct phy_device *phydev)
-- 
2.1.4
