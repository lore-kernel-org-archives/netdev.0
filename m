From: Wolfgang Denk <wd@denx.de>
Subject: [PATCH v2] fs_enet/mii-fec.c: fix MII speed calculation
Date: Tue, 14 Jul 2009 15:42:46 +0200
Message-ID: <1247578966-9847-1-git-send-email-wd@denx.de>
References: <1244751543-21977-2-git-send-email-wd@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Wolfgang Denk <wd@denx.de>
To: linuxppc-dev@ozlabs.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1244751543-21977-2-git-send-email-wd@denx.de>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

The MII speed calculation was based on the CPU clock (ppc_proc_freq),
but for MPC512x we must use the bus clock instead.

This patch makes it use the correct clock and makes sure we don't
clobber reserved bits in the MII_SPEED register.

Signed-off-by: Wolfgang Denk <wd@denx.de>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: Kumar Gala <galak@kernel.crashing.org>
Cc: <netdev@vger.kernel.org>
---
Note 1: This patch is a rewrite of a previous posting:
        http://patchwork.ozlabs.org/patch/28584/
Note 2: Function mpc5xxx_get_mii_speed() was introduced for re-use
        in a later patch to drivers/net/fec_mpc52xx.c and
	drivers/net/fec_mpc52xx_phy.c, which also contain code to
	calculate the MII speed without taking care to check for
	overflow or to write only the bits that belong to the
	MII_SPEED field when setting the MII speed.

 arch/powerpc/sysdev/mpc5xxx_clocks.c |   37 ++++++++++++++++++++++++++++++++++
 drivers/net/fs_enet/mii-fec.c        |   13 +++++++++--
 2 files changed, 47 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/sysdev/mpc5xxx_clocks.c b/arch/powerpc/sysdev/mpc5xxx_clocks.c
index 34e12f9..e26d12b 100644
--- a/arch/powerpc/sysdev/mpc5xxx_clocks.c
+++ b/arch/powerpc/sysdev/mpc5xxx_clocks.c
@@ -31,3 +31,40 @@ mpc5xxx_get_bus_frequency(struct device_node *node)
 	return p_bus_freq ? *p_bus_freq : 0;
 }
 EXPORT_SYMBOL(mpc5xxx_get_bus_frequency);
+
+/**
+ *	mpc5xxx_get_mii_speed - Get the MII_SPEED value
+ *	@node:	device node
+ *
+ *	Returns the MII_SPEED value for MPC512x and MPC52xx systems.
+ *	The value gets computed such that the resulting MDC frequency
+ *	is 2.5 MHz or lower.
+ */
+
+int
+mpc5xxx_get_mii_speed(struct of_device *ofdev)
+{
+	unsigned int clock, speed;
+
+	clock = mpc5xxx_get_bus_frequency(ofdev->node);
+
+	if (!clock) {
+		dev_err(&ofdev->dev, "could not determine IPS/IPB clock\n");
+		return -ENODEV;
+	}
+
+	/* scale for a MII clock <= 2.5 MHz */
+	speed = (clock + 2499999) / 2500000;
+
+	/* only 6 bits available for MII speed */
+	if (speed > 0x3F) {
+		speed = 0x3F;
+		dev_err(&ofdev->dev,
+			"MII clock (%d MHz) exceeds max (2.5 MHz)\n",
+			clock / speed);
+	}
+
+	/* Field is in bits 25:30 of MII_SPEED register */
+	return speed << 1;
+}
+EXPORT_SYMBOL(mpc5xxx_get_mii_speed);
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index 75a0999..a28d39f 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -36,6 +36,7 @@
 #include <asm/pgtable.h>
 #include <asm/irq.h>
 #include <asm/uaccess.h>
+#include <asm/mpc5xxx.h>
 
 #include "fs_enet.h"
 #include "fec.h"
@@ -103,7 +104,6 @@ static int fs_enet_fec_mii_reset(struct mii_bus *bus)
 static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
                                         const struct of_device_id *match)
 {
-	struct device_node *np = NULL;
 	struct resource res;
 	struct mii_bus *new_bus;
 	struct fec_info *fec;
@@ -133,13 +133,20 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 	if (!fec->fecp)
 		goto out_fec;
 
-	fec->mii_speed = ((ppc_proc_freq + 4999999) / 5000000) << 1;
+	if (of_device_is_compatible(ofdev->node, "fsl,mpc5121-fec-mdio")) {
+		i = mpc5xxx_get_mii_speed(ofdev);
+		if (i < 0)
+			goto out_unmap_regs;
+		fec->mii_speed = i;
+	} else {
+		fec->mii_speed = ((ppc_proc_freq + 4999999) / 5000000) << 1;
+	}
 
 	setbits32(&fec->fecp->fec_r_cntrl, FEC_RCNTRL_MII_MODE);
 	setbits32(&fec->fecp->fec_ecntrl, FEC_ECNTRL_PINMUX |
 	                                  FEC_ECNTRL_ETHER_EN);
 	out_be32(&fec->fecp->fec_ievent, FEC_ENET_MII);
-	out_be32(&fec->fecp->fec_mii_speed, fec->mii_speed);
+	clrsetbits_be32(&fec->fecp->fec_mii_speed, 0x7E, fec->mii_speed);
 
 	new_bus->phy_mask = ~0;
 	new_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
-- 
1.6.0.6
