From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH 2/3][RESEND] phylib: marvell: add support for TX-only and
 RX-only Internal Delay
Date: Mon, 26 Nov 2007 16:17:52 -0600
Message-ID: <20071126161752.5b4bd09d.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Li Yang <leoli@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:57687 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754821AbXKZWS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 17:18:27 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Previously, Internal Delay specification implied the delay be
applied to both TX and RX.  This patch allows for separate TX/RX-only
internal delay specification.

Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
Tested-by: Anton Vorontsov <avorontsov@ru.mvista.com>
Acked-by: Li Yang <leoli@freescale.com>
---
 drivers/net/phy/marvell.c |   26 +++++++++++++++++---------
 1 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 035fd41..f057407 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -143,21 +143,29 @@ static int m88e1111_config_init(struct phy_device *phydev)
 	int err;
 
 	if ((phydev->interface == PHY_INTERFACE_MODE_RGMII) ||
-	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)) {
+	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) ||
+	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
+	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)) {
 		int temp;
 
-		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) {
-			temp = phy_read(phydev, MII_M1111_PHY_EXT_CR);
-			if (temp < 0)
-				return temp;
+		temp = phy_read(phydev, MII_M1111_PHY_EXT_CR);
+		if (temp < 0)
+			return temp;
 
+		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) {
 			temp |= (MII_M1111_RX_DELAY | MII_M1111_TX_DELAY);
-
-			err = phy_write(phydev, MII_M1111_PHY_EXT_CR, temp);
-			if (err < 0)
-				return err;
+		} else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) {
+			temp &= ~MII_M1111_TX_DELAY;
+			temp |= MII_M1111_RX_DELAY;
+		} else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID) {
+			temp &= ~MII_M1111_RX_DELAY;
+			temp |= MII_M1111_TX_DELAY;
 		}
 
+		err = phy_write(phydev, MII_M1111_PHY_EXT_CR, temp);
+		if (err < 0)
+			return err;
+
 		temp = phy_read(phydev, MII_M1111_PHY_EXT_SR);
 		if (temp < 0)
 			return temp;
-- 
1.5.2.2

