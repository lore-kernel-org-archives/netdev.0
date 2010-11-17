From: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 1/2] of/phylib: Use device tree properties to initialize
	Marvell PHYs.
Date: Wed, 17 Nov 2010 15:54:30 -0800
Message-ID: <1290038071-13296-2-git-send-email-ddaney@caviumnetworks.com>
References: <1290038071-13296-1-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
	Arnaud Patard <arnaud.patard-dQbF7i+pzddAfugRpC6u6w@public.gmane.org>, Cyril Chemparathy <cyril-l0cyMroinI0@public.gmane.org>
To: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1290038071-13296-1-git-send-email-ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Some aspects of PHY initialization are board dependent, things like
indicator LED connections and some clocking modes cannot be determined
by probing.  The dev_flags element of struct phy_device can be used to
control these things if an appropriate value can be passed from the
Ethernet driver.  We run into problems however if the PHY connections
are specified by the device tree.  There is no way for the Ethernet
driver to know what flags it should pass.

If we are using the device tree, the struct phy_device will be
populated with the device tree node corresponding to the PHY, and we
can extract extra configuration information from there.

The next question is what should the format of that information be?
It is highly device specific, and the device tree representation
should not be tied to any arbitrary kernel defined constants.  A
straight forward representation is just to specify the exact bits that
should be set using the "marvell,reg-init" property:

      phy5: ethernet-phy@5 {
	reg = <5>;
	device_type = "ethernet-phy";
	marvell,reg-init =
		<0x00030010 0x5777>, /* Reg 3,16 <- 0x5777 */
		<0x00030011 0x00aa>, /* Reg 3,17 <- 0x00aa */
		<0x00030012 0x4105>, /* Reg 3,18 <- 0x4105 */
		<0x00030013 0x0060>; /* Reg 3,19 <- 0x0060 */
		<0x00020015 0x00300000>; /* clear bits 4..5 of Reg 2,21 */
      };

The Marvell PHYs have a page select register at register 22 (0x16), we
can specify any register by its page and register number.  These are
encoded in the high and low parts of the first word.  The second word
contains a mask and value to be ORed in its high and low parts.  The
new marvell_of_reg_init function leaves the page select register
unchanged, so a call to it can be dropped into the .config_init
functions without unduly affecting the state of the PHY.

If CONFIG_OF is not set, there is no of_node, or no "marvell,reg-init"
property, the PHY initialization is unchanged.

Signed-off-by: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Cc: Cyril Chemparathy <cyril-l0cyMroinI0@public.gmane.org>
Cc: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Cc: Arnaud Patard <arnaud.patard-dQbF7i+pzddAfugRpC6u6w@public.gmane.org>
Cc: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
---
 drivers/net/phy/marvell.c |   91 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 91 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index f0bd1a1..33ad654 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -30,6 +30,7 @@
 #include <linux/ethtool.h>
 #include <linux/phy.h>
 #include <linux/marvell_phy.h>
+#include <linux/of.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -186,6 +187,85 @@ static int marvell_config_aneg(struct phy_device *phydev)
 	return 0;
 }
 
+#ifndef CONFIG_OF
+static int marvell_of_reg_init(struct phy_device *phydev)
+{
+	return 0;
+}
+#else
+/*
+ * Set and/or override some configuration registers based on the
+ * marvell,reg-init property stored in the of_node for the phydev.
+ *
+ * marvell,reg-init = <reg-spec val-spec>,...;
+ *
+ * There may be one or more  pairs of <reg-spec val-spec>:
+ * reg-spec [16..31]: Page address.
+ * reg-spec [0..15]: Register address.
+ *
+ * val-spec [16..31]: Mask bits.
+ * val-spec [0..15]: Register bits.
+ */
+static int marvell_of_reg_init(struct phy_device *phydev)
+{
+	const __be32 *paddr;
+	int len, i, saved_page, current_page, page_changed, ret;
+
+	if (!phydev->dev.of_node)
+		return 0;
+
+	paddr = of_get_property(phydev->dev.of_node, "marvell,reg-init", &len);
+	if (!paddr || len < (2 * sizeof(u32)))
+		return 0;
+
+	saved_page = phy_read(phydev, 22);
+	if (saved_page < 0)
+		return saved_page;
+	page_changed = 0;
+	current_page = saved_page;
+
+	ret = 0;
+	len /= sizeof(u32);
+	for (i = 0; i < len / 2; i += 2) {
+		u32 reg_spec =  be32_to_cpup(&paddr[i]);
+		u32 val_spec =  be32_to_cpup(&paddr[i + 1]);
+		u16 reg = reg_spec & 0xffff;
+		u16 reg_page = reg_spec >> 16;
+		u16 val_bits = val_spec & 0xffff;
+		u16 mask = val_spec >> 16;
+		int val;
+
+		if (reg_page != current_page) {
+			ret = phy_write(phydev, 22, reg_page);
+			if (ret < 0)
+				goto err;
+			current_page = reg_page;
+			page_changed = 1;
+		}
+
+		val = 0;
+		if (mask) {
+			val = phy_read(phydev, reg);
+			if (val < 0) {
+				ret = val;
+				goto err;
+			}
+			val &= mask;
+		}
+		val |= val_bits;
+
+		ret = phy_write(phydev, reg, (u16)val);
+		if (ret < 0)
+			goto err;
+
+	}
+err:
+	if (page_changed)
+		ret = phy_write(phydev, 22, saved_page);
+	return ret;
+}
+#endif /* CONFIG_OF */
+
 static int m88e1121_config_aneg(struct phy_device *phydev)
 {
 	int err, oldpage, mscr;
@@ -368,6 +448,9 @@ static int m88e1111_config_init(struct phy_device *phydev)
 			return err;
 	}
 
+	err = marvell_of_reg_init(phydev);
+	if (err < 0)
+		return err;
 
 	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
 	if (err < 0)
@@ -420,6 +503,10 @@ static int m88e1118_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
+	err = marvell_of_reg_init(phydev);
+	if (err < 0)
+		return err;
+
 	/* Reset address */
 	err = phy_write(phydev, 0x16, 0x0);
 	if (err < 0)
@@ -491,6 +578,10 @@ static int m88e1145_config_init(struct phy_device *phydev)
 		}
 	}
 
+	err = marvell_of_reg_init(phydev);
+	if (err < 0)
+		return err;
+
 	return 0;
 }
 
-- 
1.7.2.3
