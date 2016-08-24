From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH 1/4] net: phy: Add Edge-rate driver for Microsemi PHYs.
Date: Wed, 24 Aug 2016 12:20:03 +0000
Message-ID: <646450A91FAED74E85C6E9C4D6E936A145336681@avsrvexchmbx1.microsemi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "Andrew Lunn (andrew@lunn.ch)" <andrew@lunn.ch>,
        Allan Nielsen <Allan.Nielsen@microsemi.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0073.outbound.protection.outlook.com ([104.47.33.73]:37888
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751119AbcHXMeb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 08:34:31 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Edge rate control support will be added for VSC 85xx Microsemi PHYs.

Signed-off-by: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 drivers/net/phy/mscc.c | 109 +++++++++++++++++++++++++++++++++++++--------=
----
 include/linux/mscc.h   |  34 +++++++++++++++
 include/linux/phy.h    |   2 +
 3 files changed, 118 insertions(+), 27 deletions(-)
 create mode 100644 include/linux/mscc.h

diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index 6cc3036..963bf64 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -11,34 +11,9 @@
 #include <linux/mdio.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <linux/mscc.h>

-enum rgmii_rx_clock_delay {
-       RGMII_RX_CLK_DELAY_0_2_NS =3D 0,
-       RGMII_RX_CLK_DELAY_0_8_NS =3D 1,
-       RGMII_RX_CLK_DELAY_1_1_NS =3D 2,
-       RGMII_RX_CLK_DELAY_1_7_NS =3D 3,
-       RGMII_RX_CLK_DELAY_2_0_NS =3D 4,
-       RGMII_RX_CLK_DELAY_2_3_NS =3D 5,
-       RGMII_RX_CLK_DELAY_2_6_NS =3D 6,
-       RGMII_RX_CLK_DELAY_3_4_NS =3D 7
-};
-
-#define MII_VSC85XX_INT_MASK              25
-#define MII_VSC85XX_INT_MASK_MASK         0xa000
-#define MII_VSC85XX_INT_STATUS            26
-
-#define MSCC_EXT_PAGE_ACCESS              31
-#define MSCC_PHY_PAGE_STANDARD            0x0000 /* Standard registers */
-#define MSCC_PHY_PAGE_EXTENDED_2          0x0002 /* Extended reg - page 2 =
*/
-
-/* Extended Page 2 Registers */
-#define MSCC_PHY_RGMII_CNTL                       20
-#define RGMII_RX_CLK_DELAY_MASK                   0x0070
-#define RGMII_RX_CLK_DELAY_POS            4
-
-/* Microsemi PHY ID's */
-#define PHY_ID_VSC8531                            0x00070570
-#define PHY_ID_VSC8541                            0x00070770
+#include "mscc_reg.h"

 static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 {
@@ -109,6 +84,82 @@ static int vsc85xx_config_intr(struct phy_device *phyde=
v)
        return rc;
 }

+static int vsc85xx_edge_rate_cntl_set(struct phy_device *phydev,
+                                     u8     *rate)
+{
+       int rc;
+       u16 reg_val;
+       u8  edge_rate =3D *rate;
+
+       mutex_lock(&phydev->lock);
+       rc =3D vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
+       if (rc !=3D 0)
+               goto out_unlock;
+       reg_val =3D phy_read(phydev, MSCC_PHY_WOL_MAC_CONTROL);
+       reg_val &=3D ~(EDGE_RATE_CNTL_MASK);
+       reg_val |=3D (edge_rate << EDGE_RATE_CNTL_POS);
+       phy_write(phydev, MSCC_PHY_WOL_MAC_CONTROL, reg_val);
+       rc =3D vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
+
+out_unlock:
+       mutex_unlock(&phydev->lock);
+
+       return rc;
+}
+
+static int vsc85xx_edge_rate_cntl_get(struct phy_device *phydev,
+                                     u8     *rate)
+{
+       int rc;
+       u16 reg_val;
+
+       mutex_lock(&phydev->lock);
+       rc =3D vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
+       if (rc !=3D 0)
+               goto out_unlock;
+       reg_val =3D phy_read(phydev, MSCC_PHY_WOL_MAC_CONTROL);
+       reg_val &=3D EDGE_RATE_CNTL_MASK;
+       *rate =3D reg_val >> EDGE_RATE_CNTL_POS;
+       rc =3D vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
+
+out_unlock:
+       mutex_unlock(&phydev->lock);
+
+       return rc;
+}
+
+static int vsc85xx_features_set(struct phy_device *phydev)
+{
+       int rc =3D 0;
+       struct phy_features_t *ftrs =3D (struct phy_features_t *)phydev->pr=
iv;
+
+       switch (ftrs->cmd) {
+       case PHY_EDGE_RATE_CONTROL:
+               rc =3D vsc85xx_edge_rate_cntl_set(phydev, &ftrs->rate);
+               break;
+       default:
+               break;
+       }
+
+       return rc;
+}
+
+static int vsc85xx_features_get(struct phy_device *phydev)
+{
+       int rc =3D 0;
+       struct phy_features_t *ftrs =3D (struct phy_features_t *)phydev->pr=
iv;
+
+       switch (ftrs->cmd) {
+       case PHY_EDGE_RATE_CONTROL:
+               rc =3D vsc85xx_edge_rate_cntl_get(phydev, &ftrs->rate);
+               break;
+       default:
+               break;
+       }
+
+       return rc;
+}
+
 /* Microsemi VSC85xx PHYs */
 static struct phy_driver vsc85xx_driver[] =3D {
 {
@@ -126,6 +177,8 @@ static struct phy_driver vsc85xx_driver[] =3D {
        .config_intr    =3D &vsc85xx_config_intr,
        .suspend                =3D &genphy_suspend,
        .resume                 =3D &genphy_resume,
+       .phy_features_set =3D &vsc85xx_features_set,
+       .phy_features_get =3D &vsc85xx_features_get,
 },
 {
        .phy_id                 =3D PHY_ID_VSC8541,
@@ -142,6 +195,8 @@ static struct phy_driver vsc85xx_driver[] =3D {
        .config_intr    =3D &vsc85xx_config_intr,
        .suspend                =3D &genphy_suspend,
        .resume                 =3D &genphy_resume,
+       .phy_features_set =3D &vsc85xx_features_set,
+       .phy_features_get =3D &vsc85xx_features_get,
 }

 };
diff --git a/include/linux/mscc.h b/include/linux/mscc.h
new file mode 100644
index 0000000..b80a2ac
--- /dev/null
+++ b/include/linux/mscc.h
@@ -0,0 +1,34 @@
+/*
+ * Driver for Microsemi VSC85xx PHYs
+ *
+ * Author: Nagaraju Lakkaraju
+ * License: Dual MIT/GPL
+ * Copyright (c) 2016 Microsemi Corporation
+ */
+
+#ifndef __LINUX_MSCC_H
+#define __LINUX_MSCC_H
+
+enum phy_features {
+       PHY_EDGE_RATE_CONTROL =3D 0,
+       PHY_SUPPORTED_FEATURES_MAX
+};
+
+enum rgmii_rx_clock_delay {
+       RGMII_RX_CLK_DELAY_0_2_NS =3D 0,
+       RGMII_RX_CLK_DELAY_0_8_NS =3D 1,
+       RGMII_RX_CLK_DELAY_1_1_NS =3D 2,
+       RGMII_RX_CLK_DELAY_1_7_NS =3D 3,
+       RGMII_RX_CLK_DELAY_2_0_NS =3D 4,
+       RGMII_RX_CLK_DELAY_2_3_NS =3D 5,
+       RGMII_RX_CLK_DELAY_2_6_NS =3D 6,
+       RGMII_RX_CLK_DELAY_3_4_NS =3D 7
+};
+
+struct phy_features_t {
+       enum phy_features cmd;           /* PHY Supported Features */
+       u8   rate;                       /* Edge rate control */
+};
+
+#endif /*  __LINUX_MSCC_H */
+
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 2d24b28..8ec4c09 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -586,6 +586,8 @@ struct phy_driver {
        void (*get_strings)(struct phy_device *dev, u8 *data);
        void (*get_stats)(struct phy_device *dev,
                          struct ethtool_stats *stats, u64 *data);
+       int (*phy_features_set)(struct phy_device *dev);
+       int (*phy_features_get)(struct phy_device *dev);
 };
 #define to_phy_driver(d) container_of(to_mdio_common_driver(d),           =
     \
                                      struct phy_driver, mdiodrv)
--=20
2.7.4
