From: Hermann Lauer <Hermann.Lauer@iwr.uni-heidelberg.de>
Subject: Re: sumgem problems with initializiation order at a 1000SX SERDES card [experimental patch]
Date: Fri, 28 Nov 2008 01:00:59 +0100
Message-ID: <20081128000059.GA13712@lemon.iwr.uni-heidelberg.de>
References: <20081125103029.GD12605@lemon.iwr.uni-heidelberg.de> <20081126.011809.241693537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="HlL+5n6rz5pIUxbD"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.uni-heidelberg.de ([129.206.100.212]:42111 "EHLO
	relay.uni-heidelberg.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437AbYK1Age (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 19:36:34 -0500
Content-Disposition: inline
In-Reply-To: <20081126.011809.241693537.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Attached is an experimental patch which made my 1000SX sungem card (with phy_serdes) working.
As suspected, reinitialising the PCS part after the global reset in gem_reinit_chip()
gets autonegotiation working and the link is established also after an ifconfig up
command now. Access through the card did not show any errors so far.

Will try to add the missing if clauses to the patch as time allows me, comments are welcome.

Hermann

-- 
Netzwerkadministration/Zentrale Dienste, Interdiziplinaeres 
Zentrum fuer wissenschaftliches Rechnen der Universitaet Heidelberg
IWR; INF 368; 69120 Heidelberg; Tel: (06221)54-8236 Fax: -5224
Email: Hermann.Lauer@iwr.uni-heidelberg.de
--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sungem-serdes.patch"

--- linux-2.6.24-2.6.24/drivers/net/sungem.c.2627	2008-11-28 00:40:58.000000000 +0100
+++ linux-2.6.24-2.6.24/drivers/net/sungem.c	2008-11-28 00:34:46.000000000 +0100
@@ -1324,7 +1324,7 @@
 	    	   gp->phy_type == phy_serdes) {
 		u32 pcs_lpa = readl(gp->regs + PCS_MIILP);
 
-		if (pcs_lpa & PCS_MIIADV_FD)
+		if ((pcs_lpa & PCS_MIIADV_FD) || gp->phy_type == phy_serdes)
 			full_duplex = 1;
 		speed = SPEED_1000;
 	}
@@ -1488,6 +1488,9 @@
 			val = readl(gp->regs + PCS_MIISTAT);
 
 		if ((val & PCS_MIISTAT_LS) != 0) {
+		  if (gp->lstate == link_up)
+			 goto restart;
+
 			gp->lstate = link_up;
 			netif_carrier_on(gp->dev);
 			(void)gem_set_link_modes(gp);
@@ -1714,7 +1717,7 @@
 		/* Reset PCS unit. */
 		val = readl(gp->regs + PCS_MIICTRL);
 		val |= PCS_MIICTRL_RST;
-		writeb(val, gp->regs + PCS_MIICTRL);
+		writel(val, gp->regs + PCS_MIICTRL);
 
 		limit = 32;
 		while (readl(gp->regs + PCS_MIICTRL) & PCS_MIICTRL_RST) {
@@ -2095,12 +2098,51 @@
 /* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_reinit_chip(struct gem *gp)
 {
+  int val;
 	/* Reset the chip */
 	gem_reset(gp);
 
 	/* Make sure ints are disabled */
 	gem_disable_ints(gp);
 
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
+	  val &= ~PCS_SCTRL_LOOP;
+	else
+	  val |= PCS_SCTRL_LOOP;
+	writel(val, gp->regs + PCS_SCTRL);
+
 	/* Allocate & setup ring buffers */
 	gem_init_rings(gp);
 

--HlL+5n6rz5pIUxbD--
