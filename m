From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH 3/4] net: phy: Add read driver for Microsemi PHYs.
Date: Wed, 24 Aug 2016 12:27:07 +0000
Message-ID: <646450A91FAED74E85C6E9C4D6E936A1453366A5@avsrvexchmbx1.microsemi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "Andrew Lunn (andrew@lunn.ch)" <andrew@lunn.ch>,
        Allan Nielsen <Allan.Nielsen@microsemi.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0044.outbound.protection.outlook.com ([104.47.40.44]:49068
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755062AbcHXMnc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 08:43:32 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>

PHY Read support will be added for VSC 85xx Microsemi PHYs.

Signed-off-by: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 drivers/net/phy/mscc.c | 25 +++++++++++++++++++++++++
 include/linux/mscc.h   |  8 ++++++++
 2 files changed, 33 insertions(+)

diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index 60d9d5f..5a74f81 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -194,6 +194,28 @@ static int vsc85xx_mac_if_get(struct phy_device *phyde=
v,
        return rc;
 }

+static int vsc85xx_phy_read_reg(struct phy_device *phydev,
+                               struct phy_reg_op *data)
+{
+       int rc =3D 0;
+       u16 reg_addr =3D data->reg;
+       u8  page =3D data->pg;
+       u16 reg_val;
+
+       if (page !=3D 0) {
+               mutex_lock(&phydev->lock);
+               rc =3D vsc85xx_phy_page_set(phydev, page);
+               reg_val =3D phy_read(phydev, reg_addr);
+               rc =3D vsc85xx_phy_page_set(phydev, 0);
+               mutex_unlock(&phydev->lock);
+       } else {
+               reg_val =3D phy_read(phydev, reg_addr);
+       }
+       data->val =3D reg_val;
+
+       return rc;
+}
+
 static int vsc85xx_features_set(struct phy_device *phydev)
 {
        int rc =3D 0;
@@ -225,6 +247,9 @@ static int vsc85xx_features_get(struct phy_device *phyd=
ev)
        case PHY_MAC_IF:
                rc =3D vsc85xx_mac_if_get(phydev, &ftrs->mac_if);
                break;
+       case PHY_READ_REG:
+               rc =3D vsc85xx_phy_read_reg(phydev, ftrs->data);
+               break;
        default:
                break;
        }
diff --git a/include/linux/mscc.h b/include/linux/mscc.h
index dcfd0ae..4265da7 100644
--- a/include/linux/mscc.h
+++ b/include/linux/mscc.h
@@ -12,6 +12,7 @@
 enum phy_features {
        PHY_EDGE_RATE_CONTROL =3D 0,
        PHY_MAC_IF            =3D 1,
+       PHY_READ_REG          =3D 2,
        PHY_SUPPORTED_FEATURES_MAX
 };

@@ -26,10 +27,17 @@ enum rgmii_rx_clock_delay {
        RGMII_RX_CLK_DELAY_3_4_NS =3D 7
 };

+struct phy_reg_op {
+       u16 reg;
+       u16 val;
+       u8  pg;
+};
+
 struct phy_features_t {
        enum phy_features cmd;           /* PHY Supported Features */
        u8   rate;                       /* Edge rate control */
        phy_interface_t mac_if;          /* MAC interface config */
+       struct phy_reg_op *data;         /* Read/Write register operatioins=
 */
 };

 #endif /*  __LINUX_MSCC_H */
--=20
2.7.4
