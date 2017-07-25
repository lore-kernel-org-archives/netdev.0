From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH RFC 11/13] phylink: add support for MII ioctl access to Clause
 45 PHYs
Date: Tue, 25 Jul 2017 15:03:28 +0100
Message-ID: <E1da0Qq-0007MB-U1@rmk-PC.armlinux.org.uk>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:50912 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752320AbdGYODd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 10:03:33 -0400
In-Reply-To: <20170725140138.GK31807@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for reading and writing the clause 45 MII registers.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phylink.c | 157 ++++++++++++++++++++++++++++++++++++----------
 1 file changed, 124 insertions(+), 33 deletions(-)

diff --git a/drivers/net/phy/phylink.c b/drivers/net/phy/phylink.c
index 026060c95b82..dc0f4d7b7dd2 100644
--- a/drivers/net/phy/phylink.c
+++ b/drivers/net/phy/phylink.c
@@ -1127,16 +1127,93 @@ static int phylink_mii_emul_read(struct net_device *ndev, unsigned int reg,
 	return val;
 }
 
+static int phylink_phy_read(struct phylink *pl, unsigned int phy_id,
+			    unsigned int reg)
+{
+	struct phy_device *phydev = pl->phydev;
+	int prtad, devad;
+
+	if (mdio_phy_id_is_c45(phy_id)) {
+		prtad = mdio_phy_id_prtad(phy_id);
+		devad = mdio_phy_id_devad(phy_id);
+		devad = MII_ADDR_C45 | devad << 16 | reg;
+	} else if (phydev->is_c45) {
+		switch (reg) {
+		case MII_BMCR:
+		case MII_BMSR:
+		case MII_PHYSID1:
+		case MII_PHYSID2:
+			devad = __ffs(phydev->c45_ids.devices_in_package);
+			break;
+		case MII_ADVERTISE:
+		case MII_LPA:
+			if (!(phydev->c45_ids.devices_in_package & MDIO_DEVS_AN))
+				return -EINVAL;
+			devad = MDIO_MMD_AN;
+			if (reg == MII_ADVERTISE)
+				reg = MDIO_AN_ADVERTISE;
+			else
+				reg = MDIO_AN_LPA;
+			break;
+		default:
+			return -EINVAL;
+		}
+		prtad = phy_id;
+		devad = MII_ADDR_C45 | devad << 16 | reg;
+	} else {
+		prtad = phy_id;
+		devad = reg;
+	}
+	return mdiobus_read(pl->phydev->mdio.bus, prtad, devad);
+}
+
+static int phylink_phy_write(struct phylink *pl, unsigned int phy_id,
+			     unsigned int reg, unsigned int val)
+{
+	struct phy_device *phydev = pl->phydev;
+	int prtad, devad;
+
+	if (mdio_phy_id_is_c45(phy_id)) {
+		prtad = mdio_phy_id_prtad(phy_id);
+		devad = mdio_phy_id_devad(phy_id);
+		devad = MII_ADDR_C45 | devad << 16 | reg;
+	} else if (phydev->is_c45) {
+		switch (reg) {
+		case MII_BMCR:
+		case MII_BMSR:
+		case MII_PHYSID1:
+		case MII_PHYSID2:
+			devad = __ffs(phydev->c45_ids.devices_in_package);
+			break;
+		case MII_ADVERTISE:
+		case MII_LPA:
+			if (!(phydev->c45_ids.devices_in_package & MDIO_DEVS_AN))
+				return -EINVAL;
+			devad = MDIO_MMD_AN;
+			if (reg == MII_ADVERTISE)
+				reg = MDIO_AN_ADVERTISE;
+			else
+				reg = MDIO_AN_LPA;
+			break;
+		default:
+			return -EINVAL;
+		}
+		prtad = phy_id;
+		devad = MII_ADDR_C45 | devad << 16 | reg;
+	} else {
+		prtad = phy_id;
+		devad = reg;
+	}
+
+	return mdiobus_write(phydev->mdio.bus, prtad, devad, val);
+}
+
 static int phylink_mii_read(struct phylink *pl, unsigned int phy_id,
 			    unsigned int reg)
 {
 	struct phylink_link_state state;
 	int val = 0xffff;
 
-	/* PHYs only exist for MLO_AN_PHY and MLO_AN_SGMII */
-	if (pl->phydev)
-		return mdiobus_read(pl->phydev->mdio.bus, phy_id, reg);
-
 	switch (pl->link_an_mode) {
 	case MLO_AN_FIXED:
 		if (phy_id == 0) {
@@ -1169,12 +1246,6 @@ static int phylink_mii_read(struct phylink *pl, unsigned int phy_id,
 static int phylink_mii_write(struct phylink *pl, unsigned int phy_id,
 			     unsigned int reg, unsigned int val)
 {
-	/* PHYs only exist for MLO_AN_PHY and MLO_AN_SGMII */
-	if (pl->phydev) {
-		mdiobus_write(pl->phydev->mdio.bus, phy_id, reg, val);
-		return 0;
-	}
-
 	switch (pl->link_an_mode) {
 	case MLO_AN_FIXED:
 		break;
@@ -1193,36 +1264,56 @@ static int phylink_mii_write(struct phylink *pl, unsigned int phy_id,
 
 int phylink_mii_ioctl(struct phylink *pl, struct ifreq *ifr, int cmd)
 {
-	struct mii_ioctl_data *mii_data = if_mii(ifr);
-	int val, ret;
+	struct mii_ioctl_data *mii = if_mii(ifr);
+	int  ret;
 
 	WARN_ON(!lockdep_rtnl_is_held());
 
-	switch (cmd) {
-	case SIOCGMIIPHY:
-		mii_data->phy_id = pl->phydev ? pl->phydev->mdio.addr : 0;
-		/* fallthrough */
+	if (pl->phydev) {
+		/* PHYs only exist for MLO_AN_PHY and MLO_AN_SGMII */
+		switch (cmd) {
+		case SIOCGMIIPHY:
+			mii->phy_id = pl->phydev->mdio.addr;
+
+		case SIOCGMIIREG:
+			ret = phylink_phy_read(pl, mii->phy_id, mii->reg_num);
+			if (ret >= 0) {
+				mii->val_out = ret;
+				ret = 0;
+			}
+			break;
 
-	case SIOCGMIIREG:
-		val = phylink_mii_read(pl, mii_data->phy_id, mii_data->reg_num);
-		if (val < 0) {
-			ret = val;
-		} else {
-			mii_data->val_out = val;
-			ret = 0;
+		case SIOCSMIIREG:
+			ret = phylink_phy_write(pl, mii->phy_id, mii->reg_num,
+						mii->val_in);
+			break;
+
+		default:
+			ret = phy_mii_ioctl(pl->phydev, ifr, cmd);
+			break;
 		}
-		break;
+	} else {
+		switch (cmd) {
+		case SIOCGMIIPHY:
+			mii->phy_id = 0;
+
+		case SIOCGMIIREG:
+			ret = phylink_mii_read(pl, mii->phy_id, mii->reg_num);
+			if (ret >= 0) {
+				mii->val_out = ret;
+				ret = 0;
+			}
+			break;
 
-	case SIOCSMIIREG:
-		ret = phylink_mii_write(pl, mii_data->phy_id, mii_data->reg_num,
-					mii_data->val_in);
-		break;
+		case SIOCSMIIREG:
+			ret = phylink_mii_write(pl, mii->phy_id, mii->reg_num,
+						mii->val_in);
+			break;
 
-	default:
-		ret = -EOPNOTSUPP;
-		if (pl->phydev)
-			ret = phy_mii_ioctl(pl->phydev, ifr, cmd);
-		break;
+		default:
+			ret = -EOPNOTSUPP;
+			break;
+		}
 	}
 
 	return ret;
-- 
2.7.4
