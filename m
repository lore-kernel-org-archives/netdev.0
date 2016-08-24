From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH 2/4] net: phy: Add MAC-IF driver for Microsemi PHYs.
Date: Wed, 24 Aug 2016 12:24:13 +0000
Message-ID: <646450A91FAED74E85C6E9C4D6E936A145336694@avsrvexchmbx1.microsemi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "Andrew Lunn (andrew@lunn.ch)" <andrew@lunn.ch>,
        Allan Nielsen <Allan.Nielsen@microsemi.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0072.outbound.protection.outlook.com ([104.47.33.72]:55671
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755049AbcHXMYT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 08:24:19 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>

MAC Interface support will be added for VSC 85xx Microsemi PHYs.

Signed-off-by: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 drivers/net/phy/mscc.c | 72 ++++++++++++++++++++++++++++++++++++++++++++++=
++++
 include/linux/mscc.h   |  2 ++
 2 files changed, 74 insertions(+)

diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index 963bf64..60d9d5f 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -84,6 +84,18 @@ static int vsc85xx_config_intr(struct phy_device *phydev=
)
        return rc;
 }

+static int vsc85xx_soft_reset(struct phy_device *phydev)
+{
+       int rc;
+       u16 reg_val;
+
+       reg_val =3D phy_read(phydev, MII_BMCR);
+       reg_val |=3D BMCR_RESET;
+       rc =3D phy_write(phydev, MII_BMCR, reg_val);
+
+       return rc;
+}
+
 static int vsc85xx_edge_rate_cntl_set(struct phy_device *phydev,
                                      u8     *rate)
 {
@@ -128,6 +140,60 @@ out_unlock:
        return rc;
 }

+static int vsc85xx_mac_if_set(struct phy_device *phydev,
+                             phy_interface_t   *interface)
+{
+       int rc;
+       u16 reg_val;
+
+       mutex_lock(&phydev->lock);
+       reg_val =3D phy_read(phydev, MSCC_PHY_EXT_PHY_CNTL_1);
+       switch (*interface) {
+       case PHY_INTERFACE_MODE_RGMII:
+               reg_val &=3D ~(MAC_IF_SELECTION_MASK);
+               reg_val |=3D (MAC_IF_SELECTION_RGMII << MAC_IF_SELECTION_PO=
S);
+               break;
+       case PHY_INTERFACE_MODE_RMII:
+               reg_val &=3D ~(MAC_IF_SELECTION_MASK);
+               reg_val |=3D (MAC_IF_SELECTION_RMII << MAC_IF_SELECTION_POS=
);
+               break;
+       case PHY_INTERFACE_MODE_MII:
+       case PHY_INTERFACE_MODE_GMII:
+       default:
+               reg_val &=3D ~(MAC_IF_SELECTION_MASK);
+               reg_val |=3D (MAC_IF_SELECTION_GMII << MAC_IF_SELECTION_POS=
);
+               break;
+       }
+       rc =3D phy_write(phydev, MSCC_PHY_EXT_PHY_CNTL_1, reg_val);
+       if (rc !=3D 0)
+               goto out_unlock;
+
+       rc =3D vsc85xx_soft_reset(phydev);
+
+out_unlock:
+       mutex_unlock(&phydev->lock);
+
+       return rc;
+}
+
+static int vsc85xx_mac_if_get(struct phy_device *phydev,
+                             phy_interface_t   *interface)
+{
+       int rc =3D 0;
+       u16 reg_val;
+
+       reg_val =3D phy_read(phydev, MSCC_PHY_EXT_PHY_CNTL_1);
+       reg_val =3D ((reg_val & MAC_IF_SELECTION_MASK) >> MAC_IF_SELECTION_=
POS);
+       if (reg_val =3D=3D MAC_IF_SELECTION_RGMII)
+               *interface =3D PHY_INTERFACE_MODE_RGMII;
+       else if (reg_val =3D=3D MAC_IF_SELECTION_RMII)
+               *interface =3D PHY_INTERFACE_MODE_RMII;
+       else
+               *interface =3D PHY_INTERFACE_MODE_GMII;
+
+       return rc;
+}
+
 static int vsc85xx_features_set(struct phy_device *phydev)
 {
        int rc =3D 0;
@@ -137,6 +203,9 @@ static int vsc85xx_features_set(struct phy_device *phyd=
ev)
        case PHY_EDGE_RATE_CONTROL:
                rc =3D vsc85xx_edge_rate_cntl_set(phydev, &ftrs->rate);
                break;
+       case PHY_MAC_IF:
+               rc =3D vsc85xx_mac_if_set(phydev, &ftrs->mac_if);
+               break;
        default:
                break;
        }
@@ -153,6 +222,9 @@ static int vsc85xx_features_get(struct phy_device *phyd=
ev)
        case PHY_EDGE_RATE_CONTROL:
                rc =3D vsc85xx_edge_rate_cntl_get(phydev, &ftrs->rate);
                break;
+       case PHY_MAC_IF:
+               rc =3D vsc85xx_mac_if_get(phydev, &ftrs->mac_if);
+               break;
        default:
                break;
        }
diff --git a/include/linux/mscc.h b/include/linux/mscc.h
index b80a2ac..dcfd0ae 100644
--- a/include/linux/mscc.h
+++ b/include/linux/mscc.h
@@ -11,6 +11,7 @@

 enum phy_features {
        PHY_EDGE_RATE_CONTROL =3D 0,
+       PHY_MAC_IF            =3D 1,
        PHY_SUPPORTED_FEATURES_MAX
 };

@@ -28,6 +29,7 @@ enum rgmii_rx_clock_delay {
 struct phy_features_t {
        enum phy_features cmd;           /* PHY Supported Features */
        u8   rate;                       /* Edge rate control */
+       phy_interface_t mac_if;          /* MAC interface config */
 };

 #endif /*  __LINUX_MSCC_H */
--=20
2.7.4
