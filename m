From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH 4/4] net: phy: Add write driver for Microsemi PHYs.
Date: Wed, 24 Aug 2016 12:29:57 +0000
Message-ID: <646450A91FAED74E85C6E9C4D6E936A1453366BB@avsrvexchmbx1.microsemi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "Andrew Lunn (andrew@lunn.ch)" <andrew@lunn.ch>,
        Allan Nielsen <Allan.Nielsen@microsemi.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0085.outbound.protection.outlook.com ([104.47.33.85]:22944
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754593AbcHXMaT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 08:30:19 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>

PHY write register support will be added for VSC 85xx Microsemi PHYs.

Signed-off-by: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 drivers/net/phy/mscc.c | 24 ++++++++++++++++++++++++
 include/linux/mscc.h   |  1 +
 2 files changed, 25 insertions(+)

diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index 5a74f81..9315fde 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -194,6 +194,27 @@ static int vsc85xx_mac_if_get(struct phy_device *phyde=
v,
        return rc;
 }

+static int vsc85xx_phy_write_reg(struct phy_device *phydev,
+                                struct phy_reg_op *data)
+{
+       int rc;
+       u16 reg_addr =3D data->reg;
+       u16 reg_val =3D data->val;
+       u8  page =3D data->pg;
+
+       if (page !=3D 0) {
+               mutex_lock(&phydev->lock);
+               vsc85xx_phy_page_set(phydev, page);
+               rc =3D phy_write(phydev, reg_addr, reg_val);
+               vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
+               mutex_unlock(&phydev->lock);
+       } else {
+               rc =3D phy_write(phydev, reg_addr, reg_val);
+       }
+
+       return rc;
+}
+
 static int vsc85xx_phy_read_reg(struct phy_device *phydev,
                                struct phy_reg_op *data)
 {
@@ -228,6 +249,9 @@ static int vsc85xx_features_set(struct phy_device *phyd=
ev)
        case PHY_MAC_IF:
                rc =3D vsc85xx_mac_if_set(phydev, &ftrs->mac_if);
                break;
+       case PHY_WRITE_REG:
+               rc =3D vsc85xx_phy_write_reg(phydev, ftrs->data);
+               break;
        default:
                break;
        }
diff --git a/include/linux/mscc.h b/include/linux/mscc.h
index 4265da7..b2cf373 100644
--- a/include/linux/mscc.h
+++ b/include/linux/mscc.h
@@ -13,6 +13,7 @@ enum phy_features {
        PHY_EDGE_RATE_CONTROL =3D 0,
        PHY_MAC_IF            =3D 1,
        PHY_READ_REG          =3D 2,
+       PHY_WRITE_REG         =3D 3,
        PHY_SUPPORTED_FEATURES_MAX
 };

--=20
2.7.4
