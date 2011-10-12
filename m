From: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] netdev/phy: Add driver for Broadcom BCM8706 10G Ethernet
 PHY
Date: Wed, 12 Oct 2011 11:06:23 -0700
Message-ID: <1318442783-29058-4-git-send-email-david.daney@cavium.com>
References: <1318442783-29058-1-git-send-email-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: afleming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1318442783-29058-1-git-send-email-david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a driver and PHY_ID number for said device.  This is a 10Gig PHY
which uses MII_ADDR_C45 addressing, it is always 10G full duplex, so
there is no autonegotiation.  All we do is report link state and send
interrupts when it changes.

If the PHY has a device tree of_node associated with it, the
"broadcom,c45-reg-init" property is used to supply register
initialization values when config_init() is called.

Signed-off-by: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 .../devicetree/bindings/net/broadcom-bcm8706.txt   |   28 +++
 drivers/net/phy/Kconfig                            |    5 +
 drivers/net/phy/Makefile                           |    1 +
 drivers/net/phy/bcm8706.c                          |  212 ++++++++++++++++++++
 include/linux/brcmphy.h                            |    1 +
 5 files changed, 247 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-bcm8706.txt
 create mode 100644 drivers/net/phy/bcm8706.c

diff --git a/Documentation/devicetree/bindings/net/broadcom-bcm8706.txt b/Documentation/devicetree/bindings/net/broadcom-bcm8706.txt
new file mode 100644
index 0000000..d58bea9
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/broadcom-bcm8706.txt
@@ -0,0 +1,28 @@
+The Broadcom BCM8706 is a 10G Ethernet PHY.  It has these bindings in
+addition to the standard PHY bindings.
+
+Compatible: Should contain "broadcom,bcm8706" and
+            "ethernet-phy-ieee802.3-c45"
+
+Optional Properties:
+
+- broadcom,c45-reg-init : one of more sets of 4 cells.  The first cell
+  is the device type, the second a register address, the third cell
+  contains a mask to be ANDed with the existing register value, and
+  the fourth cell is ORed with he result to yield the new register
+  value.
+
+Example:
+
+	ethernet-phy@5 {
+		reg = <5>;
+		compatible = "broadcom,bcm8706", "ethernet-phy-ieee802.3-c45";
+		interrupt-parent = <&gpio>;
+		interrupts = <12 8>; /* Pin 12, active low */
+		/*
+		 * Set PMD Digital Control Register for
+		 * GPIO[1] Tx/Rx
+		 * GPIO[0] R64 Sync Acquired
+		 */
+		broadcom,c45-reg-init = <1 0xc808 0xff8f 0x70>;
+	};
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 59b3b17..a99885f 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -62,6 +62,11 @@ config BCM63XX_PHY
 	---help---
 	  Currently supports the 6348 and 6358 PHYs.
 
+config BCM8706_PHY
+	tristate "Driver for Broadcom BCM8706 10G Ethernet PHY"
+	help
+	  Currently supports only the BCM8706 PHY.
+
 config ICPLUS_PHY
 	tristate "Drivers for ICPlus PHYs"
 	---help---
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index d1a1927..ec46398 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -12,6 +12,7 @@ obj-$(CONFIG_SMSC_PHY)		+= smsc.o
 obj-$(CONFIG_VITESSE_PHY)	+= vitesse.o
 obj-$(CONFIG_BROADCOM_PHY)	+= broadcom.o
 obj-$(CONFIG_BCM63XX_PHY)	+= bcm63xx.o
+obj-$(CONFIG_BCM8706_PHY)	+= bcm8706.o
 obj-$(CONFIG_ICPLUS_PHY)	+= icplus.o
 obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
 obj-$(CONFIG_LSI_ET1011C_PHY)	+= et1011c.o
diff --git a/drivers/net/phy/bcm8706.c b/drivers/net/phy/bcm8706.c
new file mode 100644
index 0000000..3a23e04
--- /dev/null
+++ b/drivers/net/phy/bcm8706.c
@@ -0,0 +1,212 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2011 Cavium, Inc.
+ */
+
+#include <linux/module.h>
+#include <linux/phy.h>
+#include <linux/brcmphy.h>
+#include <linux/of.h>
+
+#define BCM8706_PMD_RX_SIGNAL_DETECT	(MII_ADDR_C45 | 0x1000a)
+#define BCM8706_10GBASER_PCS_STATUS	(MII_ADDR_C45 | 0x30020)
+#define BCM8706_XGXS_LANE_STATUS	(MII_ADDR_C45 | 0x40018)
+
+#define BCM8706_LASI_CONTROL		(MII_ADDR_C45 | 0x39002)
+#define BCM8706_LASI_STATUS		(MII_ADDR_C45 | 0x39005)
+
+#ifdef CONFIG_OF_MDIO
+/*
+ * Set and/or override some configuration registers based on the
+ * broadcom,c45-reg-init property stored in the of_node for the phydev.
+ *
+ * broadcom,c45-reg-init = <devid reg mask value>,...;
+ *
+ * There may be one or more sets of <devid reg mask value>:
+ *
+ * devid: which sub-device to use.
+ * reg: the register.
+ * mask: if non-zero, ANDed with existing register value.
+ * value: ORed with the masked value and written to the regiser.
+ *
+ */
+static int bcm8706_of_reg_init(struct phy_device *phydev)
+{
+	const __be32 *paddr;
+	int len, i, ret;
+
+	if (!phydev->dev.of_node)
+		return 0;
+
+	paddr = of_get_property(phydev->dev.of_node,
+				"broadcom,c45-reg-init", &len);
+	if (!paddr || len < (4 * sizeof(*paddr)))
+		return 0;
+
+	ret = 0;
+	len /= sizeof(*paddr);
+	for (i = 0; i < len - 3; i += 4) {
+		u16 devid = be32_to_cpup(paddr + i);
+		u16 reg = be32_to_cpup(paddr + i + 1);
+		u16 mask = be32_to_cpup(paddr + i + 2);
+		u16 val_bits = be32_to_cpup(paddr + i + 3);
+		int val;
+		u32 regnum = MII_ADDR_C45 | (devid << 16) | reg;
+		val = 0;
+		if (mask) {
+			val = phy_read(phydev, regnum);
+			if (val < 0) {
+				ret = val;
+				goto err;
+			}
+			val &= mask;
+		}
+		val |= val_bits;
+
+		ret = phy_write(phydev, regnum, val);
+		if (ret < 0)
+			goto err;
+
+	}
+err:
+	return ret;
+}
+#else
+static int bcm8706_of_reg_init(struct phy_device *phydev)
+{
+	return 0;
+}
+#endif /* CONFIG_OF_MDIO */
+
+static int bcm8706_config_init(struct phy_device *phydev)
+{
+	phydev->supported = SUPPORTED_10000baseR_FEC;
+	phydev->advertising = ADVERTISED_10000baseR_FEC;
+	phydev->state = PHY_NOLINK;
+
+	bcm8706_of_reg_init(phydev);
+
+	return 0;
+}
+
+static int bcm8706_config_aneg(struct phy_device *phydev)
+{
+	return -EINVAL;
+}
+
+static int bcm8706_read_status(struct phy_device *phydev)
+{
+	int rx_signal_detect;
+	int pcs_status;
+	int xgxs_lane_status;
+
+	rx_signal_detect = phy_read(phydev, BCM8706_PMD_RX_SIGNAL_DETECT);
+	if (rx_signal_detect < 0)
+		return rx_signal_detect;
+
+	if ((rx_signal_detect & 1) == 0)
+		goto no_link;
+
+	pcs_status = phy_read(phydev, BCM8706_10GBASER_PCS_STATUS);
+	if (pcs_status < 0)
+		return pcs_status;
+
+	if ((pcs_status & 1) == 0)
+		goto no_link;
+
+	xgxs_lane_status = phy_read(phydev, BCM8706_XGXS_LANE_STATUS);
+	if (xgxs_lane_status < 0)
+		return xgxs_lane_status;
+
+	if ((xgxs_lane_status & 0x1000) == 0)
+		goto no_link;
+
+	phydev->speed = 10000;
+	phydev->link = 1;
+	phydev->duplex = 1;
+	return 0;
+
+no_link:
+	phydev->link = 0;
+	return 0;
+}
+
+static int bcm8706_config_intr(struct phy_device *phydev)
+{
+	int reg, err;
+
+	reg = phy_read(phydev, BCM8706_LASI_CONTROL);
+
+	if (reg < 0)
+		return reg;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		reg |= 1;
+	else
+		reg &= ~1;
+
+	err = phy_write(phydev, BCM8706_LASI_CONTROL, reg);
+	return err;
+}
+
+static int bcm8706_did_interrupt(struct phy_device *phydev)
+{
+	int reg;
+
+	reg = phy_read(phydev, BCM8706_LASI_STATUS);
+
+	if (reg < 0) {
+		dev_err(&phydev->dev,
+			"Error: Read of BCM8706_LASI_STATUS failed: %d\n", reg);
+		return 0;
+	}
+	return (reg & 1) != 0;
+}
+
+static int bcm8706_ack_interrupt(struct phy_device *phydev)
+{
+	/* Reading the LASI status clears it. */
+	bcm8706_did_interrupt(phydev);
+	return 0;
+}
+
+
+static struct phy_driver bcm8706_driver = {
+	.phy_id		= PHY_ID_BCM8706,
+	.phy_id_mask	= 0xffffffff,
+	.name		= "Broadcom BCM8706",
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_init	= bcm8706_config_init,
+	.config_aneg	= bcm8706_config_aneg,
+	.read_status	= bcm8706_read_status,
+	.ack_interrupt	= bcm8706_ack_interrupt,
+	.config_intr	= bcm8706_config_intr,
+	.did_interrupt	= bcm8706_did_interrupt,
+	.driver		= { .owner = THIS_MODULE },
+};
+
+static int __init bcm8706_init(void)
+{
+	int ret;
+
+	ret = phy_driver_register(&bcm8706_driver);
+
+	return ret;
+}
+module_init(bcm8706_init);
+
+static void __exit bcm8706_exit(void)
+{
+	phy_driver_unregister(&bcm8706_driver);
+}
+module_exit(bcm8706_exit);
+
+static struct mdio_device_id __maybe_unused bcm8706_tbl[] = {
+	{ PHY_ID_BCM8706, 0xffffffff },
+	{ }
+};
+
+MODULE_DEVICE_TABLE(mdio, bcm8706_tbl);
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index b840a49..e06a56a 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -9,6 +9,7 @@
 #define PHY_ID_BCM5464			0x002060b0
 #define PHY_ID_BCM5461			0x002060c0
 #define PHY_ID_BCM57780			0x03625d90
+#define PHY_ID_BCM8706			0x0143bdc1
 
 #define PHY_BCM_OUI_MASK		0xfffffc00
 #define PHY_BCM_OUI_1			0x00206000
-- 
1.7.2.3
