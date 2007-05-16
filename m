From: Eugene Surovegin <ebs@ebshome.net>
Subject: [PATCH 2/3] ibm_emac: improved PHY support
Date: Wed, 16 May 2007 11:59:48 -0700
Message-ID: <20070516185948.GB14704@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-embedded@ozlabs.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Jeff Haran <jharan@brocade.com>, Jeff Garzik <jeff@garzik.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.ebshome.net ([208.106.21.240]:50919 "EHLO gate.ebshome.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756579AbXEPS7t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 14:59:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Original patch is from Jeff Haran  <jharan@brocade.com> with my minor style
fixes. His comments follow:

The first problem was in the function that configures the PHY for
autonegotiation, genmii_setup_aneg(). The original code does a
read/modify/write of the autonegotiation advertizement register (reg 4),
followed by a read/modify/write of the control register (reg 0). While
the original code follows the proper procedure as per reading the IEEE
specs, what I found is that on at least one PHY model (National DP83843)
the read of the control register comes back with the soft reset bit set
(bit 15). Because of the read/modify/write operation, this causes the
write to write a 1 back to the reset bit, which initiates a software
reset of the PHY. This software reset causes the PHY to return to its
power up state which advertizes all modes of operation, thus negating
the write to the autoneg advertizement register. The modification is to
spin reading the control register until the soft reset bit is clear
before doing the modify/write.
The second problem was in the function that configures the PHY for
forced operation, genmii_setup_forced(). The original code initiates a
software reset operation via a write of a 1 to bit 15 of the control
register (reg 0), but then proceeds to do a second write to that same
register without waiting until that reset bit is cleared by the PHY
itself (which according to the IEEE specs indicates that the PHY reset
is complete). This is a violation of how one is supposed to use this
software reset feature of these PHYs and I believe was the cause of
mysterious, difficult to reproduce link failures that we've observed on
some of our systems that use this driver. The fix is to modify the
function so that it spins waiting for the reset bit to clear after doing
the soft reset and before doing the subsequent write.

Signed-off-by: Jeff Haran <jharan@brocade.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Signed-off-by: Eugene Surovegin <ebs@ebshome.net>

---
 drivers/net/ibm_emac/ibm_emac_phy.c |   60 ++++++++++++++++++++++++++---------
 1 files changed, 45 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ibm_emac/ibm_emac_phy.c b/drivers/net/ibm_emac/ibm_emac_phy.c
index 9074f76..e57862b 100644
--- a/drivers/net/ibm_emac/ibm_emac_phy.c
+++ b/drivers/net/ibm_emac/ibm_emac_phy.c
@@ -22,6 +22,7 @@
 
 #include <asm/ocp.h>
 
+#include "ibm_emac_core.h"
 #include "ibm_emac_phy.h"
 
 static inline int phy_read(struct mii_phy *phy, int reg)
@@ -34,11 +35,39 @@ static inline void phy_write(struct mii_phy *phy, int reg, int val)
 	phy->mdio_write(phy->dev, phy->address, reg, val);
 }
 
-int mii_reset_phy(struct mii_phy *phy)
+/*
+ * polls MII_BMCR until BMCR_RESET bit clears or operation times out.
+ *
+ * returns:
+ *	>= 0 => success, value in BMCR returned to caller
+ *	-EBUSY => failure, RESET bit never cleared
+ *	otherwise => failure, lower level PHY read failed
+ */
+static int mii_spin_reset_complete(struct mii_phy *phy)
 {
 	int val;
 	int limit = 10000;
 
+	while (limit--) {
+		val = phy_read(phy, MII_BMCR);
+		if (val >= 0 && !(val & BMCR_RESET))
+			return val;	/* success */
+		udelay(10);
+	}
+	if (val & BMCR_RESET)
+		val = -EBUSY;
+
+	if (net_ratelimit())
+		printk(KERN_ERR "emac%d: PHY reset timeout (%d)\n", 
+		       ((struct ocp_enet_private *)phy->dev->priv)->def->index,
+		       val);
+	return val;		    
+}
+
+int mii_reset_phy(struct mii_phy *phy)
+{
+	int val;
+
 	val = phy_read(phy, MII_BMCR);
 	val &= ~BMCR_ISOLATE;
 	val |= BMCR_RESET;
@@ -46,16 +75,11 @@ int mii_reset_phy(struct mii_phy *phy)
 
 	udelay(300);
 
-	while (limit--) {
-		val = phy_read(phy, MII_BMCR);
-		if (val >= 0 && (val & BMCR_RESET) == 0)
-			break;
-		udelay(10);
-	}
-	if ((val & BMCR_ISOLATE) && limit > 0)
+	val = mii_spin_reset_complete(phy);
+	if (val >= 0 && (val & BMCR_ISOLATE))
 		phy_write(phy, MII_BMCR, val & ~BMCR_ISOLATE);
 
-	return limit <= 0;
+	return val < 0;
 }
 
 static int genmii_setup_aneg(struct mii_phy *phy, u32 advertise)
@@ -102,8 +126,14 @@ static int genmii_setup_aneg(struct mii_phy *phy, u32 advertise)
 	}
 
 	/* Start/Restart aneg */
-	ctl = phy_read(phy, MII_BMCR);
-	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
+	/* on some PHYs (e.g. National DP83843) a write to MII_ADVERTISE
+	 * causes BMCR_RESET to be set on the next read of MII_BMCR, which
+	 * if not checked for causes the PHY to be reset below */
+	ctl = mii_spin_reset_complete(phy);
+	if (ctl < 0)
+		return ctl;
+
+	ctl |= BMCR_ANENABLE | BMCR_ANRESTART;
 	phy_write(phy, MII_BMCR, ctl);
 
 	return 0;
@@ -118,13 +148,13 @@ static int genmii_setup_forced(struct mii_phy *phy, int speed, int fd)
 	phy->duplex = fd;
 	phy->pause = phy->asym_pause = 0;
 
+	/* First reset the PHY */
+	mii_reset_phy(phy);
+
 	ctl = phy_read(phy, MII_BMCR);
 	if (ctl < 0)
 		return ctl;
-	ctl &= ~(BMCR_FULLDPLX | BMCR_SPEED100 | BMCR_ANENABLE);
-
-	/* First reset the PHY */
-	phy_write(phy, MII_BMCR, ctl | BMCR_RESET);
+	ctl &= ~(BMCR_FULLDPLX | BMCR_SPEED100 | BMCR_ANENABLE | BMCR_SPEED1000);
 
 	/* Select speed & duplex */
 	switch (speed) {
