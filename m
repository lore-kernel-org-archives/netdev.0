From: Brian Hill <brian@houston-radar.com>
Subject: [PATCH] net: phy: Correctly handle MII ioctl which changes autonegotiation.
Date: Tue, 11 Nov 2014 13:39:39 -0700
Message-ID: <5462740B.8010503@houston-radar.com>
References: <5462210F.7040306@houston-radar.com>	<546222F3.7080705@houston-radar.com> <20141111.152146.2216423846831865994.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:33695 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbaKKUjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 15:39:41 -0500
Received: by mail-ie0-f172.google.com with SMTP id at20so12283893iec.17
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 12:39:41 -0800 (PST)
In-Reply-To: <20141111.152146.2216423846831865994.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When advertised capabilities are changed with mii-tool, such as:
mii-tool -A 10baseT
the existing handler has two errors.

- An actual PHY register value is provided by mii-tool, and this
  must be mapped to internal state with mii_adv_to_ethtool_adv_t().
- The PHY state machine needs to be told that autonegotiation has
  again been performed.  If not, the MAC will not be notified of
  the new link speed and duplex, resulting in a possible config
  mismatch.

Signed-off-by: Brian Hill <Brian@houston-radar.com>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c |   36 ++++++++++++++++++++++++------------
 1 file changed, 24 insertions(+), 12 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index c94e2a2..d40ca35 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -352,6 +352,7 @@ int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd)
 {
 	struct mii_ioctl_data *mii_data = if_mii(ifr);
 	u16 val = mii_data->val_in;
+	bool change_autoneg = false;
 
 	switch (cmd) {
 	case SIOCGMIIPHY:
@@ -367,22 +368,29 @@ int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd)
 		if (mii_data->phy_id == phydev->addr) {
 			switch (mii_data->reg_num) {
 			case MII_BMCR:
-				if ((val & (BMCR_RESET | BMCR_ANENABLE)) == 0)
+				if ((val & (BMCR_RESET | BMCR_ANENABLE)) == 0) {
+					if (phydev->autoneg == AUTONEG_ENABLE)
+						change_autoneg = true;
 					phydev->autoneg = AUTONEG_DISABLE;
-				else
+					if (val & BMCR_FULLDPLX)
+						phydev->duplex = DUPLEX_FULL;
+					else
+						phydev->duplex = DUPLEX_HALF;
+					if (val & BMCR_SPEED1000)
+						phydev->speed = SPEED_1000;
+					else if (val & BMCR_SPEED100)
+						phydev->speed = SPEED_100;
+					else phydev->speed = SPEED_10;
+				}
+				else {
+					if (phydev->autoneg == AUTONEG_DISABLE)
+						change_autoneg = true;
 					phydev->autoneg = AUTONEG_ENABLE;
-				if (!phydev->autoneg && (val & BMCR_FULLDPLX))
-					phydev->duplex = DUPLEX_FULL;
-				else
-					phydev->duplex = DUPLEX_HALF;
-				if (!phydev->autoneg && (val & BMCR_SPEED1000))
-					phydev->speed = SPEED_1000;
-				else if (!phydev->autoneg &&
-					 (val & BMCR_SPEED100))
-					phydev->speed = SPEED_100;
+				}
 				break;
 			case MII_ADVERTISE:
-				phydev->advertising = val;
+				phydev->advertising = mii_adv_to_ethtool_adv_t(val);
+				change_autoneg = true;
 				break;
 			default:
 				/* do nothing */
@@ -396,6 +404,10 @@ int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd)
 		if (mii_data->reg_num == MII_BMCR &&
 		    val & BMCR_RESET)
 			return phy_init_hw(phydev);
+
+		if (change_autoneg)
+			return phy_start_aneg(phydev);
+
 		return 0;
 
 	case SIOCSHWTSTAMP:
-- 
1.7.9.5
