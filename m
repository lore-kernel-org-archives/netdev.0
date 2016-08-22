From: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: RE: [PATCH v1 1/1]  net: phy: Add edge-rate, mac-if, read, write
 func to Microsemi PHYs.
Date: Mon, 22 Aug 2016 14:57:51 +0530
Message-ID: <20160822092520.GA3804@microsemi.com>
References: <20160808134325.GA4376@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        Allan Nielsen <Allan.Nielsen@microsemi.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0079.outbound.protection.outlook.com ([104.47.33.79]:34816
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752226AbcHVJn3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 05:43:29 -0400
Content-Disposition: inline
In-Reply-To: <20160808134325.GA4376@microsemi.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

Can you please review this code?

Thanks,
Raju.

-----Original Message-----
From: Nagaraju Lakkaraju [mailto:Raju.Lakkaraju@microsemi.com] 
Sent: Monday, August 08, 2016 7:13 PM
To: netdev@vger.kernel.org
Cc: f.fainelli@gmail.com; Allan Nielsen
Subject: [PATCH v1 1/1] net: phy: Add edge-rate, mac-if, read, write func to Microsemi PHYs.

Hello,

As part of 2nd patch, Add Edge rate control, MAC Interface, Read and write driver functions add for Microsemi PHYs.

Please review and send your comments.

Thanks,
Raju.

>From 6303576768b5c5dcc0e35fb46c525337a3845557 Mon Sep 17 00:00:00 2001
From: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Date: Mon, 8 Aug 2016 18:51:36 +0530
Subject: [PATCH v1 1/1]  net: phy: Add edge-rate, mac-if, read, write func to  Microsemi PHYs.

Signed-off-by: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 drivers/net/phy/mscc.c     | 234 +++++++++++++++++++++++++++++++++++++++------
 drivers/net/phy/mscc_reg.h | 135 ++++++++++++++++++++++++++
 include/linux/mscc.h       |  45 +++++++++
 include/linux/phy.h        |   2 +
 4 files changed, 387 insertions(+), 29 deletions(-)  mode change 100644 => 100755 drivers/net/phy/mscc.c  create mode 100644 drivers/net/phy/mscc_reg.h  create mode 100644 include/linux/mscc.h  mode change 100644 => 100755 include/linux/phy.h

diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c old mode 100644 new mode 100755 index 49c7506..af7a441
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -11,34 +11,9 @@
 #include <linux/mdio.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <linux/mscc.h>

-enum rgmii_rx_clock_delay {
-       RGMII_RX_CLK_DELAY_0_2_NS = 0,
-       RGMII_RX_CLK_DELAY_0_8_NS = 1,
-       RGMII_RX_CLK_DELAY_1_1_NS = 2,
-       RGMII_RX_CLK_DELAY_1_7_NS = 3,
-       RGMII_RX_CLK_DELAY_2_0_NS = 4,
-       RGMII_RX_CLK_DELAY_2_3_NS = 5,
-       RGMII_RX_CLK_DELAY_2_6_NS = 6,
-       RGMII_RX_CLK_DELAY_3_4_NS = 7
-};
-
-#define MII_VSC85XX_INT_MASK              25
-#define MII_VSC85XX_INT_MASK_MASK         0xa000
-#define MII_VSC85XX_INT_STATUS            26
-
-#define MSCC_EXT_PAGE_ACCESS              31
-#define MSCC_PHY_PAGE_STANDARD            0x0000 /* Standard registers */
-#define MSCC_PHY_PAGE_EXTENDED_2          0x0002 /* Extended reg - page 2 */
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

 static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)  { @@ -84,7 +59,7 @@ static int vsc85xx_config_init(struct phy_device *phydev)

 static int vsc85xx_ack_interrupt(struct phy_device *phydev)  {
-       int rc;
+       int rc = 0;

        if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
                rc = phy_read(phydev, MII_VSC85XX_INT_STATUS); @@ -98,7 +73,7 @@ static int vsc85xx_config_intr(struct phy_device *phydev)

        if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
                rc = phy_write(phydev, MII_VSC85XX_INT_MASK,
-                                  MII_VSC85XX_INT_MASK_MASK);
+                              MII_VSC85XX_INT_MASK_MASK);
        } else {
                rc = phy_write(phydev, MII_VSC85XX_INT_MASK, 0);
                if (rc < 0)
@@ -109,6 +84,203 @@ static int vsc85xx_config_intr(struct phy_device *phydev)
        return rc;
 }

+static int vsc85xx_soft_reset(struct phy_device *phydev) {
+       int rc;
+       u16 reg_val;
+
+       reg_val = phy_read(phydev, MII_BMCR);
+       reg_val |= BMCR_RESET;
+       rc = phy_write(phydev, MII_BMCR, reg_val);
+
+       return rc;
+}
+
+static int vsc85xx_edge_rate_cntl_set(struct phy_device *phydev,
+                                     u8     *rate)
+{
+       int rc;
+       u16 reg_val;
+       u8  edge_rate = *rate;
+
+       mutex_lock(&phydev->lock);
+       rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
+       if (rc != 0)
+               goto out_unlock;
+       reg_val = phy_read(phydev, MSCC_PHY_WOL_MAC_CONTROL);
+       reg_val &= ~(EDGE_RATE_CNTL_MASK);
+       reg_val |= (edge_rate << EDGE_RATE_CNTL_POS);
+       phy_write(phydev, MSCC_PHY_WOL_MAC_CONTROL, reg_val);
+       rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
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
+       rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
+       if (rc != 0)
+               goto out_unlock;
+       reg_val = phy_read(phydev, MSCC_PHY_WOL_MAC_CONTROL);
+       reg_val &= EDGE_RATE_CNTL_MASK;
+       *rate = reg_val >> EDGE_RATE_CNTL_POS;
+       rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
+
+out_unlock:
+       mutex_unlock(&phydev->lock);
+
+       return rc;
+}
+
+static int vsc85xx_mac_if_set(struct phy_device *phydev,
+                             phy_interface_t   *interface)
+{
+       int rc;
+       u16 reg_val;
+
+       mutex_lock(&phydev->lock);
+       reg_val = phy_read(phydev, MSCC_PHY_EXT_PHY_CNTL_1);
+       switch (*interface) {
+       case PHY_INTERFACE_MODE_RGMII:
+               reg_val &= ~(MAC_IF_SELECTION_MASK);
+               reg_val |= (MAC_IF_SELECTION_RGMII << MAC_IF_SELECTION_POS);
+               break;
+       case PHY_INTERFACE_MODE_RMII:
+               reg_val &= ~(MAC_IF_SELECTION_MASK);
+               reg_val |= (MAC_IF_SELECTION_RMII << MAC_IF_SELECTION_POS);
+               break;
+       case PHY_INTERFACE_MODE_MII:
+       case PHY_INTERFACE_MODE_GMII:
+       default:
+               reg_val &= ~(MAC_IF_SELECTION_MASK);
+               reg_val |= (MAC_IF_SELECTION_GMII << MAC_IF_SELECTION_POS);
+               break;
+       }
+       rc = phy_write(phydev, MSCC_PHY_EXT_PHY_CNTL_1, reg_val);
+       if (rc != 0)
+               goto out_unlock;
+
+       rc = vsc85xx_soft_reset(phydev);
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
+       int rc = 0;
+       u16 reg_val;
+
+       reg_val = phy_read(phydev, MSCC_PHY_EXT_PHY_CNTL_1);
+       reg_val = ((reg_val & MAC_IF_SELECTION_MASK) >> MAC_IF_SELECTION_POS);
+       if (reg_val == MAC_IF_SELECTION_RGMII)
+               *interface = PHY_INTERFACE_MODE_RGMII;
+       else if (reg_val == MAC_IF_SELECTION_RMII)
+               *interface = PHY_INTERFACE_MODE_RMII;
+       else
+               *interface = PHY_INTERFACE_MODE_GMII;
+
+       return rc;
+}
+
+static int vsc85xx_phy_write_reg(struct phy_device *phydev,
+                                struct phy_reg_op *data) {
+       int rc = 0;
+       u16 reg_addr = data->reg;
+       u16 reg_val = data->val;
+       u8  page = data->pg;
+
+       if (page != 0) {
+               mutex_lock(&phydev->lock);
+               rc = vsc85xx_phy_page_set(phydev, page);
+               reg_val = phy_write(phydev, reg_addr, reg_val);
+               rc = vsc85xx_phy_page_set(phydev, 0);
+               mutex_unlock(&phydev->lock);
+       } else {
+               reg_val = phy_write(phydev, reg_addr, reg_val);
+       }
+
+       return rc;
+}
+
+static int vsc85xx_phy_read_reg(struct phy_device *phydev,
+                               struct phy_reg_op *data) {
+       int rc = 0;
+       u16 reg_addr = data->reg;
+       u8  page = data->pg;
+       u16 reg_val;
+
+       if (page != 0) {
+               mutex_lock(&phydev->lock);
+               rc = vsc85xx_phy_page_set(phydev, page);
+               reg_val = phy_read(phydev, reg_addr);
+               rc = vsc85xx_phy_page_set(phydev, 0);
+               mutex_unlock(&phydev->lock);
+       } else {
+               reg_val = phy_read(phydev, reg_addr);
+       }
+       data->val = reg_val;
+
+       return rc;
+}
+
+static int vsc85xx_features_set(struct phy_device *phydev) {
+       int rc = 0;
+       struct phy_features_t *ftrs = (struct phy_features_t 
+*)phydev->priv;
+
+       switch (ftrs->cmd) {
+       case PHY_EDGE_RATE_CONTROL:
+               rc = vsc85xx_edge_rate_cntl_set(phydev, &ftrs->rate);
+               break;
+       case PHY_MAC_IF:
+               rc = vsc85xx_mac_if_set(phydev, &ftrs->mac_if);
+               break;
+       case PHY_WRITE_REG:
+               rc = vsc85xx_phy_write_reg(phydev, ftrs->data);
+               break;
+       default:
+               break;
+       }
+
+       return rc;
+}
+
+static int vsc85xx_features_get(struct phy_device *phydev) {
+       int rc = 0;
+       struct phy_features_t *ftrs = (struct phy_features_t 
+*)phydev->priv;
+
+       switch (ftrs->cmd) {
+       case PHY_EDGE_RATE_CONTROL:
+               rc = vsc85xx_edge_rate_cntl_get(phydev, &ftrs->rate);
+               break;
+       case PHY_MAC_IF:
+               rc = vsc85xx_mac_if_get(phydev, &ftrs->mac_if);
+               break;
+       case PHY_READ_REG:
+               rc = vsc85xx_phy_read_reg(phydev, ftrs->data);
+               break;
+       default:
+               break;
+       }
+
+       return rc;
+}
+
 /* Microsemi VSC85xx PHYs */
 static struct phy_driver vsc85xx_driver[] = {  { @@ -126,6 +298,8 @@ static struct phy_driver vsc85xx_driver[] = {
        .config_intr    = &vsc85xx_config_intr,
        .suspend                = &genphy_suspend,
        .resume                 = &genphy_resume,
+       .phy_features_set = &vsc85xx_features_set,
+       .phy_features_get = &vsc85xx_features_get,
 },
 {
        .phy_id                 = PHY_ID_VSC8541,
@@ -142,6 +316,8 @@ static struct phy_driver vsc85xx_driver[] = {
        .config_intr    = &vsc85xx_config_intr,
        .suspend                = &genphy_suspend,
        .resume                 = &genphy_resume,
+       .phy_features_set = &vsc85xx_features_set,
+       .phy_features_get = &vsc85xx_features_get,
 }

 };
diff --git a/drivers/net/phy/mscc_reg.h b/drivers/net/phy/mscc_reg.h new file mode 100644 index 0000000..ddb825c
--- /dev/null
+++ b/drivers/net/phy/mscc_reg.h
@@ -0,0 +1,135 @@
+/*
+ * Driver for Microsemi VSC85xx PHYs
+ *
+ * Author: Nagaraju Lakkaraju
+ * License: Dual MIT/GPL
+ * Copyright (c) 2016 Microsemi Corporation  */
+
+#ifndef __MSCC_REG_H
+#define __MSCC_REG_H
+
+/* Microsemi VSC85xx PHY registers */
+/* IEEE 802. Std Registers */
+#define MSCC_PHY_BYPASS_CONTROL        18
+#define DISABLE_HP_AUTO_MDIX_MASK      0x0080
+#define DISABLE_PAIR_SWAP_CORR_MASK    0x0020
+#define DISABLE_POLARITY_CORR_MASK     0x0010
+
+#define MSCC_PHY_EXT_PHY_CNTL_1        23
+#define MAC_IF_SELECTION_MASK          0x1800
+#define MAC_IF_SELECTION_GMII          0
+#define MAC_IF_SELECTION_RMII          1
+#define MAC_IF_SELECTION_RGMII         2
+#define MAC_IF_SELECTION_POS           11
+#define FAR_END_LOOPBACK_MODE_MASK     0x0008
+
+#define MSCC_PHY_EXT_PHY_CNTL_2        24
+#define CONNECTOR_LOOPBACK_MASK        0x0001
+#define JUMBO_PACKET_MODE_MASK         0x0030
+#define JUMBO_PACKET_MODE_POS          4
+
+#define MII_VSC85XX_INT_MASK           25
+#define MII_VSC85XX_INT_MASK_MDINT     0x8000
+#define MII_VSC85XX_INT_MASK_SPEED     0x4000
+#define MII_VSC85XX_INT_MASK_LINK      0x2000
+#define MII_VSC85XX_INT_MASK_DUPLEX    0x1000
+#define MII_VSC85XX_INT_MASK_ANEG_ERR  0x0800 #define 
+MII_VSC85XX_INT_MASK_ANEG_COM  0x0400
+#define MII_VSC85XX_INT_MASK_POE       0x0200
+#define MII_VSC85XX_INT_MASK_SYM       0x0100
+#define MII_VSC85XX_INT_MASK_FLF       0x0080
+#define MII_VSC85XX_INT_MASK_WOL       0x0040
+#define MII_VSC85XX_INT_MASK_EXT       0x0020
+#define MII_VSC85XX_INT_MASK_RESV      0x0010
+#define MII_VSC85XX_INT_MASK_FCI       0x0008
+#define MII_VSC85XX_INT_MASK_LDI       0x0004
+#define MII_VSC85XX_INT_MASK_MSE       0x0002
+#define MII_VSC85XX_INT_MASK_RX_ER     0x0001
+#define MII_VSC85XX_INT_MASK_MASK      0xa000
+
+#define MII_VSC85XX_INT_STATUS         26
+#define MSCC_PHY_DEV_AUX_CNTL          28
+#define HP_AUTO_MDIX_X_OVER_IND_MASK   0x2000
+#define ACTIPHY_TIME_OUT_BIT_7         0x0080
+#define ACTIPHY_TIME_OUT_BIT_2         0x0004
+#define ACTIPHY_TIME_OUT_MASK          0x0084
+#define ACTIPHY_MODE_ENT               0x0040
+
+#define MSCC_EXT_PAGE_ACCESS           31
+#define MSCC_PHY_PAGE_STANDARD         0x0000 /* Standard registers */
+#define MSCC_PHY_PAGE_EXTENDED         0x0001 /* Extended registers */
+#define MSCC_PHY_PAGE_EXTENDED_2       0x0002 /* Extended registers - page 2 */
+#define MSCC_PHY_PAGE_EXTENDED_3       0x0003 /* Extended registers - page 3 */
+#define MSCC_PHY_PAGE_EXTENDED_4       0x0004 /* Extended registers - page 4 */
+#define MSCC_PHY_PAGE_GPIO             0x0010 /* GPIO registers */
+
+/* Extended Page 1 Registers */
+#define MSCC_PHY_EXT_MODE_CNTL         19
+#define FORCE_MDI_CROSSOVER_MASK       0x000C
+#define FORCE_MDI_CROSSOVER_NORMAL     0
+#define FORCE_MDI_CROSSOVER_MDI        2
+#define FORCE_MDI_CROSSOVER_MDIX       3
+#define FORCE_MDI_CROSSOVER_POS        2
+
+#define MSCC_PHY_ACTIPHY_CNTL          20
+#define ACTIPHY_SLEEP_TIMER_MASK       0x6000
+#define ACTIPHY_SLEEP_TIMER_POS        13
+#define ACTIPHY_WAKEUP_TIMER_MASK      0x1800
+#define ACTIPHY_WAKEUP_TIMER_POS       11
+#define LINK_SPD_DOWNSHIFT_EN          0x0010
+#define LINK_SPD_DOWNSHIFT_CNTL_POS    2
+#define LINK_SPD_DOWNSHIFT_CNTL_MASK   0x000C
+
+#define MSCC_PHY_POE_MISC              23
+#define INLINE_POE_DETECTION           0x0400
+#define INLINE_POE_STATUS_MASK         0x0300
+#define INLINE_POE_STATUS_POS          8
+
+/* Extended Page 2 Registers */
+#define MSCC_PHY_RGMII_CNTL            20
+#define FLF2_ENABLE                    0x8000
+#define SOF_ENABLE                     0x1000
+#define RGMII_RX_CLK_DELAY_MASK        0x0070
+#define RGMII_RX_CLK_DELAY_POS         4
+
+#define MSCC_PHY_WOL_LOWER_MAC_ADDR    21
+#define MSCC_PHY_WOL_MID_MAC_ADDR      22
+#define MSCC_PHY_WOL_UPPER_MAC_ADDR    23
+#define MSCC_PHY_WOL_LOWER_PASSWD      24
+#define MSCC_PHY_WOL_MID_PASSWD        25
+#define MSCC_PHY_WOL_UPPER_PASSWD      26
+
+#define MSCC_PHY_WOL_MAC_CONTROL       27
+#define EDGE_RATE_CNTL_POS             5
+#define EDGE_RATE_CNTL_MASK            0x00E0
+#define SECURE_ON_ENABLE               0x8000
+#define SECURE_ON_PASSWD_LEN_4         0x4000
+
+#define MSCC_PHY_RING_RESI_CONTROL     30
+#define RR_STARTUP_ENABLE              0x8000
+#define RR_ADVERTISE_ENABLE            0x4000
+#define RR_LP_ADVERTISE                0x2000
+#define RR_FORCE_ENABLE                0x1000
+#define RR_STATUS_MASK                 0x0030
+#define RR_STATUS_POS                  4
+
+/* GPIO registers */
+#define MSCC_GPIO_CONTROL_2            14
+#define COMA_MODE_EN                   0x2000
+#define COMA_MODE_OUTPUT               0x1000
+#define COMA_MODE_INPUT                0x0800
+
+#define MSCC_RECOVERED_CLK_CONTROL     23
+#define RCVRD_CLK_EN                   0x8000
+#define CLK_FREQUENCY_SELECT_MASK      0x0700
+#define CLK_SQUELCH_LVL_MASK           0x0030
+#define CLK_SELECTION_MASK             0x0007
+#define CLK_FREQUENCY_SELECT_POS       8
+#define CLK_SQUELCH_LVL_POS            4
+
+/* Microsemi PHY ID's */
+#define PHY_ID_VSC8531                 0x00070570
+#define PHY_ID_VSC8541                 0x00070770
+
+#endif /* __MSCC_REG_H */
diff --git a/include/linux/mscc.h b/include/linux/mscc.h new file mode 100644 index 0000000..b2cf373
--- /dev/null
+++ b/include/linux/mscc.h
@@ -0,0 +1,45 @@
+/*
+ * Driver for Microsemi VSC85xx PHYs
+ *
+ * Author: Nagaraju Lakkaraju
+ * License: Dual MIT/GPL
+ * Copyright (c) 2016 Microsemi Corporation  */
+
+#ifndef __LINUX_MSCC_H
+#define __LINUX_MSCC_H
+
+enum phy_features {
+       PHY_EDGE_RATE_CONTROL = 0,
+       PHY_MAC_IF            = 1,
+       PHY_READ_REG          = 2,
+       PHY_WRITE_REG         = 3,
+       PHY_SUPPORTED_FEATURES_MAX
+};
+
+enum rgmii_rx_clock_delay {
+       RGMII_RX_CLK_DELAY_0_2_NS = 0,
+       RGMII_RX_CLK_DELAY_0_8_NS = 1,
+       RGMII_RX_CLK_DELAY_1_1_NS = 2,
+       RGMII_RX_CLK_DELAY_1_7_NS = 3,
+       RGMII_RX_CLK_DELAY_2_0_NS = 4,
+       RGMII_RX_CLK_DELAY_2_3_NS = 5,
+       RGMII_RX_CLK_DELAY_2_6_NS = 6,
+       RGMII_RX_CLK_DELAY_3_4_NS = 7
+};
+
+struct phy_reg_op {
+       u16 reg;
+       u16 val;
+       u8  pg;
+};
+
+struct phy_features_t {
+       enum phy_features cmd;           /* PHY Supported Features */
+       u8   rate;                       /* Edge rate control */
+       phy_interface_t mac_if;          /* MAC interface config */
+       struct phy_reg_op *data;         /* Read/Write register operatioins */
+};
+
+#endif /*  __LINUX_MSCC_H */
+
diff --git a/include/linux/phy.h b/include/linux/phy.h old mode 100644 new mode 100755 index 2d24b28..8ec4c09
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -586,6 +586,8 @@ struct phy_driver {
        void (*get_strings)(struct phy_device *dev, u8 *data);
        void (*get_stats)(struct phy_device *dev,
                          struct ethtool_stats *stats, u64 *data);
+       int (*phy_features_set)(struct phy_device *dev);
+       int (*phy_features_get)(struct phy_device *dev);
 };
 #define to_phy_driver(d) container_of(to_mdio_common_driver(d),                \
                                      struct phy_driver, mdiodrv)
