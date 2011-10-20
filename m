From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Subject: [RFC PATCH 13/17] mpc836x: Move board-specific bcm5481 fixup out of
 the PHY driver
Date: Thu, 20 Oct 2011 17:00:20 -0400
Message-ID: <1319144425-15547-14-git-send-email-Kyle.D.Moffett@boeing.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, Paul Mackerras <paulus@samba.org>,
 Kyle Moffett <Kyle.D.Moffett@boeing.com>
To: linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

By comparing the BCM5481 registers modified in the ->config_aneg()
method with the datasheet I have for the BCM5482, it appears that the
register writes are adjusting signal timing to work around a known
trace-length issue on the PCB.

Such hardware workarounds don't belong in the generic driver, and should
instead be placed in a board-specific PHY fixup.

NOTE: Needs testing by somebody with the hardware.

Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
---
 arch/powerpc/platforms/83xx/mpc836x_rdk.c |   35 ++++++++++++++++++++++++++++
 drivers/net/phy/broadcom.c                |   36 -----------------------------
 2 files changed, 35 insertions(+), 36 deletions(-)

diff --git a/arch/powerpc/platforms/83xx/mpc836x_rdk.c b/arch/powerpc/platforms/83xx/mpc836x_rdk.c
index b0090aa..b7cc607 100644
--- a/arch/powerpc/platforms/83xx/mpc836x_rdk.c
+++ b/arch/powerpc/platforms/83xx/mpc836x_rdk.c
@@ -14,6 +14,7 @@
 
 #include <linux/kernel.h>
 #include <linux/pci.h>
+#include <linux/phy.h>
 #include <linux/of_platform.h>
 #include <linux/io.h>
 #include <asm/prom.h>
@@ -38,6 +39,36 @@ static int __init mpc836x_rdk_declare_of_platform_devices(void)
 }
 machine_device_initcall(mpc836x_rdk, mpc836x_rdk_declare_of_platform_devices);
 
+static int mpc836x_rdk_bcm5481_fixup(struct phy_device *phydev)
+{
+	int reg;
+
+	if (phydev->interface != PHY_INTERFACE_MODE_RGMII_RXID)
+		return;
+
+	/*
+	 * There is no BCM5481 specification available, so down
+	 * here is everything we know about "register 0x18". This
+	 * at least helps BCM5481 to successfuly receive packets
+	 * on MPC8360E-RDK board. Peter Barada <peterb@logicpd.com>
+	 * says: "This sets delay between the RXD and RXC signals
+	 * instead of using trace lengths to achieve timing".
+	 */
+
+	/* Set RDX clk delay. */
+	reg = 0x7 | (0x7 << 12);
+	phy_write(phydev, 0x18, reg);
+	reg = phy_read(phydev, 0x18);
+	if (reg < 0)
+		return reg;
+
+	/* Set RDX-RXC skew. */
+	reg |= (1 << 8);
+	/* Write bits 14:0. */
+	reg |= (1 << 15);
+	return phy_write(phydev, 0x18, reg);
+}
+
 static void __init mpc836x_rdk_setup_arch(void)
 {
 #ifdef CONFIG_PCI
@@ -54,6 +85,10 @@ static void __init mpc836x_rdk_setup_arch(void)
 #ifdef CONFIG_QUICC_ENGINE
 	qe_reset();
 #endif
+#ifdef CONFIG_BROADCOM_PHY
+	phy_register_fixup_for_uid(0x0143bca0, 0xfffffff0,
+			&mpc836x_rdk_bcm5481_phy_fixup);
+#endif
 }
 
 static void __init mpc836x_rdk_init_IRQ(void)
diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 1b83f75..8c03ebc 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -539,41 +539,6 @@ static int bcm54xx_config_intr(struct phy_device *phydev)
 	return err;
 }
 
-static int bcm5481_config_aneg(struct phy_device *phydev)
-{
-	int ret;
-
-	/* Aneg firsly. */
-	ret = genphy_config_aneg(phydev);
-
-	/* Then we can set up the delay. */
-	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) {
-		u16 reg;
-
-		/*
-		 * There is no BCM5481 specification available, so down
-		 * here is everything we know about "register 0x18". This
-		 * at least helps BCM5481 to successfuly receive packets
-		 * on MPC8360E-RDK board. Peter Barada <peterb@logicpd.com>
-		 * says: "This sets delay between the RXD and RXC signals
-		 * instead of using trace lengths to achieve timing".
-		 */
-
-		/* Set RDX clk delay. */
-		reg = 0x7 | (0x7 << 12);
-		phy_write(phydev, 0x18, reg);
-
-		reg = phy_read(phydev, 0x18);
-		/* Set RDX-RXC skew. */
-		reg |= (1 << 8);
-		/* Write bits 14:0. */
-		reg |= (1 << 15);
-		phy_write(phydev, 0x18, reg);
-	}
-
-	return ret;
-}
-
 static int brcm_phy_setbits(struct phy_device *phydev, int reg, int set)
 {
 	int val;
@@ -736,7 +701,6 @@ static struct phy_driver broadcom_drivers[] = { {
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
-	.config_aneg	= bcm5481_config_aneg,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
-- 
1.7.2.5
