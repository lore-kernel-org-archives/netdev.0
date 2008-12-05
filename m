From: David Miller <davem@davemloft.net>
Subject: Re: sumgem problems with initializiation order at a 1000SX SERDES
 card [experimental patch]
Date: Thu, 04 Dec 2008 17:33:24 -0800 (PST)
Message-ID: <20081204.173324.136036003.davem@davemloft.net>
References: <20081125103029.GD12605@lemon.iwr.uni-heidelberg.de>
	<20081126.011809.241693537.davem@davemloft.net>
	<20081128000059.GA13712@lemon.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hermann.Lauer@iwr.uni-heidelberg.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60352
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752117AbYLEBdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 20:33:25 -0500
In-Reply-To: <20081128000059.GA13712@lemon.iwr.uni-heidelberg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hermann Lauer <Hermann.Lauer@iwr.uni-heidelberg.de>
Date: Fri, 28 Nov 2008 01:00:59 +0100

> Will try to add the missing if clauses to the patch as time allows
> me, comments are welcome.

Again, thanks for doing this work.

We don't want to run this code on MDIO phys, so at least a test
is needed to guard this new code.

And this new code is just a copy of the PHY init sequence on
PCS, so we should split that out into a helper function instead
of duplicating it.

Any time gem_reset() is invoked, the PCS is going to need to be
reset like this, so let's do the advertisement reinit there.

Does this version of the fix work for you?

diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 1349e41..bb7a478 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -1142,6 +1142,70 @@ static int gem_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static void gem_pcs_reset(struct gem *gp)
+{
+	int limit;
+	u32 val;
+
+	/* Reset PCS unit. */
+	val = readl(gp->regs + PCS_MIICTRL);
+	val |= PCS_MIICTRL_RST;
+	writel(val, gp->regs + PCS_MIICTRL);
+
+	limit = 32;
+	while (readl(gp->regs + PCS_MIICTRL) & PCS_MIICTRL_RST) {
+		udelay(100);
+		if (limit-- <= 0)
+			break;
+	}
+	if (limit <= 0)
+		printk(KERN_WARNING "%s: PCS reset bit would not clear.\n",
+		       gp->dev->name);
+}
+
+static void gem_pcs_reinit_adv(struct gem *gp)
+{
+	u32 val;
+
+	/* Make sure PCS is disabled while changing advertisement
+	 * configuration.
+	 */
+	val = readl(gp->regs + PCS_CFG);
+	val &= ~(PCS_CFG_ENABLE | PCS_CFG_TO);
+	writel(val, gp->regs + PCS_CFG);
+
+	/* Advertise all capabilities except assymetric
+	 * pause.
+	 */
+	val = readl(gp->regs + PCS_MIIADV);
+	val |= (PCS_MIIADV_FD | PCS_MIIADV_HD |
+		PCS_MIIADV_SP | PCS_MIIADV_AP);
+	writel(val, gp->regs + PCS_MIIADV);
+
+	/* Enable and restart auto-negotiation, disable wrapback/loopback,
+	 * and re-enable PCS.
+	 */
+	val = readl(gp->regs + PCS_MIICTRL);
+	val |= (PCS_MIICTRL_RAN | PCS_MIICTRL_ANE);
+	val &= ~PCS_MIICTRL_WB;
+	writel(val, gp->regs + PCS_MIICTRL);
+
+	val = readl(gp->regs + PCS_CFG);
+	val |= PCS_CFG_ENABLE;
+	writel(val, gp->regs + PCS_CFG);
+
+	/* Make sure serialink loopback is off.  The meaning
+	 * of this bit is logically inverted based upon whether
+	 * you are in Serialink or SERDES mode.
+	 */
+	val = readl(gp->regs + PCS_SCTRL);
+	if (gp->phy_type == phy_serialink)
+		val &= ~PCS_SCTRL_LOOP;
+	else
+		val |= PCS_SCTRL_LOOP;
+	writel(val, gp->regs + PCS_SCTRL);
+}
+
 #define STOP_TRIES 32
 
 /* Must be invoked under gp->lock and gp->tx_lock. */
@@ -1168,6 +1232,9 @@ static void gem_reset(struct gem *gp)
 
 	if (limit <= 0)
 		printk(KERN_ERR "%s: SW reset is ghetto.\n", gp->dev->name);
+
+	if (gp->phy_type == phy_serialink || gp->phy_type == phy_serdes)
+		gem_pcs_reinit_adv(gp);
 }
 
 /* Must be invoked under gp->lock and gp->tx_lock. */
@@ -1324,7 +1391,7 @@ static int gem_set_link_modes(struct gem *gp)
 	    	   gp->phy_type == phy_serdes) {
 		u32 pcs_lpa = readl(gp->regs + PCS_MIILP);
 
-		if (pcs_lpa & PCS_MIIADV_FD)
+		if ((pcs_lpa & PCS_MIIADV_FD) || gp->phy_type == phy_serdes)
 			full_duplex = 1;
 		speed = SPEED_1000;
 	}
@@ -1488,6 +1555,9 @@ static void gem_link_timer(unsigned long data)
 			val = readl(gp->regs + PCS_MIISTAT);
 
 		if ((val & PCS_MIISTAT_LS) != 0) {
+			if (gp->lstate == link_up)
+				goto restart;
+
 			gp->lstate = link_up;
 			netif_carrier_on(gp->dev);
 			(void)gem_set_link_modes(gp);
@@ -1708,61 +1778,8 @@ static void gem_init_phy(struct gem *gp)
 		if (gp->phy_mii.def && gp->phy_mii.def->ops->init)
 			gp->phy_mii.def->ops->init(&gp->phy_mii);
 	} else {
-		u32 val;
-		int limit;
-
-		/* Reset PCS unit. */
-		val = readl(gp->regs + PCS_MIICTRL);
-		val |= PCS_MIICTRL_RST;
-		writel(val, gp->regs + PCS_MIICTRL);
-
-		limit = 32;
-		while (readl(gp->regs + PCS_MIICTRL) & PCS_MIICTRL_RST) {
-			udelay(100);
-			if (limit-- <= 0)
-				break;
-		}
-		if (limit <= 0)
-			printk(KERN_WARNING "%s: PCS reset bit would not clear.\n",
-			       gp->dev->name);
-
-		/* Make sure PCS is disabled while changing advertisement
-		 * configuration.
-		 */
-		val = readl(gp->regs + PCS_CFG);
-		val &= ~(PCS_CFG_ENABLE | PCS_CFG_TO);
-		writel(val, gp->regs + PCS_CFG);
-
-		/* Advertise all capabilities except assymetric
-		 * pause.
-		 */
-		val = readl(gp->regs + PCS_MIIADV);
-		val |= (PCS_MIIADV_FD | PCS_MIIADV_HD |
-			PCS_MIIADV_SP | PCS_MIIADV_AP);
-		writel(val, gp->regs + PCS_MIIADV);
-
-		/* Enable and restart auto-negotiation, disable wrapback/loopback,
-		 * and re-enable PCS.
-		 */
-		val = readl(gp->regs + PCS_MIICTRL);
-		val |= (PCS_MIICTRL_RAN | PCS_MIICTRL_ANE);
-		val &= ~PCS_MIICTRL_WB;
-		writel(val, gp->regs + PCS_MIICTRL);
-
-		val = readl(gp->regs + PCS_CFG);
-		val |= PCS_CFG_ENABLE;
-		writel(val, gp->regs + PCS_CFG);
-
-		/* Make sure serialink loopback is off.  The meaning
-		 * of this bit is logically inverted based upon whether
-		 * you are in Serialink or SERDES mode.
-		 */
-		val = readl(gp->regs + PCS_SCTRL);
-		if (gp->phy_type == phy_serialink)
-			val &= ~PCS_SCTRL_LOOP;
-		else
-			val |= PCS_SCTRL_LOOP;
-		writel(val, gp->regs + PCS_SCTRL);
+		gem_pcs_reset(gp);
+		gem_pcs_reinit_adv(gp);
 	}
 
 	/* Default aneg parameters */
