From: akpm@linux-foundation.org
Subject: [patch 03/18] drivers/net/ns83820.c: add paramter to disable autonegotiation
Date: Fri, 10 Aug 2007 14:05:13 -0700
Message-ID: <200708102105.l7AL5ERH008951@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, dan@scannet.dk,
	bcrl@kvack.org, dan@hacker.dk, jgarzik@pobox.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52910 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760369AbXHJVGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:06:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Faerch <dan@scannet.dk>

Adds "ethtool command" support to driver.  Initially 2 commands are
implemented: force fullduplex and toggle autoneg.

Also added a "disable_autoneg" module argument to completely disable
autoneg on all cards using this driver.

Signed-off-by: Dan Faerch <dan@hacker.dk>
Cc: Benjamin LaHaise <bcrl@kvack.org>
Cc: Jeff Garzik <jgarzik@pobox.com>

[akpm: this is a previously-nacked patch, but the problem is real]

On Mon, 26 Jun 2006 12:29:28 -0400
Benjamin LaHaise <bcrl@kvack.org> wrote:

> On Sun, Jun 25, 2006 at 01:44:36AM -0700, akpm@osdl.org wrote:
> > 
> > From: Dan Faerch <dan@scannet.dk>
> > 
> > Adds "ethtool command" support to driver.  Initially 2 commands are
> > implemented: force fullduplex and toggle autoneg.
> 
> This part is good, although doing something for copper cards needs doing, 
> which probably means poking around to support the phy properly.
> 
> > Also added a "disable_autoneg" module argument to completely disable
> > autoneg on all cards using this driver.
> 
> This is the part I disagree with.  Are you sure it isn't a bug in the 
> link autonegotiation state machine for fibre cards?  It should be defaulting 
> to 1Gbit/full duplex if no autonegotiation is happening, and if it isn't 
> then that should be fixed instead of papering over things with a config 
> option.

Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ns83820.c |  183 +++++++++++++++++++++++++++++++++++++---
 1 files changed, 172 insertions(+), 11 deletions(-)

diff -puN drivers/net/ns83820.c~drivers-net-ns83820c-add-paramter-to-disable-auto drivers/net/ns83820.c
--- a/drivers/net/ns83820.c~drivers-net-ns83820c-add-paramter-to-disable-auto
+++ a/drivers/net/ns83820.c
@@ -1,4 +1,4 @@
-#define VERSION "0.22"
+#define VERSION "0.23"
 /* ns83820.c by Benjamin LaHaise with contributions.
  *
  * Questions/comments/discussion to linux-ns83820@kvack.org.
@@ -68,6 +68,9 @@
  *	20050406	0.22 -	improved DAC ifdefs from Andi Kleen
  *			     -	removal of dead code from Adrian Bunk
  *			     -	fix half duplex collision behaviour
+ *	20060213        0.23 -	Basic skeleton for adding ethtool commands.
+ *				Setting of autoneg & full-duplex via ethtool
+ *				by Dan Faerch <dan@hacker.dk>
  * Driver Overview
  * ===============
  *
@@ -124,8 +127,9 @@
 
 /* Global parameters.  See module_param near the bottom. */
 static int ihr = 2;
-static int reset_phy = 0;
-static int lnksts = 0;		/* CFG_LNKSTS bit polarity */
+static int reset_phy;
+static int lnksts;		/* CFG_LNKSTS bit polarity */
+static int disable_autoneg;
 
 /* Dprintk is used for more interesting debug events */
 #undef Dprintk
@@ -1247,6 +1251,154 @@ static struct net_device_stats *ns83820_
 	return &dev->stats;
 }
 
+/* Let ethtool retrieve info */
+static int ns83820_get_settings(struct net_device *ndev,
+				struct ethtool_cmd *cmd)
+{
+	struct ns83820 *dev = PRIV(ndev);
+	u32 cfg, tanar, tbicr;
+	int have_optical = 0;
+	int fullduplex   = 0;
+
+	/*
+	 * Here's the list of available ethtool commands from other drivers:
+	 *	cmd->advertising =
+	 *	cmd->speed =
+	 *	cmd->duplex =
+	 *	cmd->port = 0;
+	 *	cmd->phy_address =
+	 *	cmd->transceiver = 0;
+	 *	cmd->autoneg =
+	 *	cmd->maxtxpkt = 0;
+	 *	cmd->maxrxpkt = 0;
+	 */
+
+	/* read current configuration */
+	cfg   = readl(dev->base + CFG) ^ SPDSTS_POLARITY;
+	tanar = readl(dev->base + TANAR);
+	tbicr = readl(dev->base + TBICR);
+
+	if (dev->CFG_cache & CFG_TBI_EN) {
+		/* we have an optical interface */
+		have_optical = 1;
+		fullduplex = (cfg & CFG_DUPSTS) ? 1 : 0;
+
+	} else {
+		/* We have copper */
+		fullduplex = (cfg & CFG_DUPSTS) ? 1 : 0;
+        }
+
+	cmd->supported = SUPPORTED_Autoneg;
+
+	/* we have optical interface */
+	if (dev->CFG_cache & CFG_TBI_EN) {
+		cmd->supported |= SUPPORTED_1000baseT_Half |
+					SUPPORTED_1000baseT_Full |
+					SUPPORTED_FIBRE;
+		cmd->port       = PORT_FIBRE;
+	} /* TODO: else copper related  support */
+
+	cmd->duplex = fullduplex ? DUPLEX_FULL : DUPLEX_HALF;
+	switch (cfg / CFG_SPDSTS0 & 3) {
+	case 2:
+		cmd->speed = SPEED_1000;
+		break;
+	case 1:
+		cmd->speed = SPEED_100;
+		break;
+	default:
+		cmd->speed = SPEED_10;
+		break;
+	}
+	cmd->autoneg = (tbicr & TBICR_MR_AN_ENABLE) ? 1: 0;
+	return 0;
+}
+
+/* Let ethool change settings*/
+static int ns83820_set_settings(struct net_device *ndev,
+				struct ethtool_cmd *cmd)
+{
+	struct ns83820 *dev = PRIV(ndev);
+	u32 cfg, tanar;
+	int have_optical = 0;
+	int fullduplex   = 0;
+
+	/* read current configuration */
+	cfg = readl(dev->base + CFG) ^ SPDSTS_POLARITY;
+	tanar = readl(dev->base + TANAR);
+
+	if (dev->CFG_cache & CFG_TBI_EN) {
+		/* we have optical */
+		have_optical = 1;
+		fullduplex   = (tanar & TANAR_FULL_DUP);
+
+	} else {
+		/* we have copper */
+		fullduplex = cfg & CFG_DUPSTS;
+	}
+
+	spin_lock_irq(&dev->misc_lock);
+	spin_lock(&dev->tx_lock);
+
+	/* Set duplex */
+	if (cmd->duplex != fullduplex) {
+		if (have_optical) {
+			/*set full duplex*/
+			if (cmd->duplex == DUPLEX_FULL) {
+				/* force full duplex */
+				writel(readl(dev->base + TXCFG)
+					| TXCFG_CSI | TXCFG_HBI | TXCFG_ATP,
+					dev->base + TXCFG);
+				writel(readl(dev->base + RXCFG) | RXCFG_RX_FD,
+					dev->base + RXCFG);
+				/* Light up full duplex LED */
+				writel(readl(dev->base + GPIOR) | GPIOR_GP1_OUT,
+					dev->base + GPIOR);
+			} else {
+				/*TODO: set half duplex */
+			}
+
+           	} else {
+			/*we have copper*/
+			/* TODO: Set duplex for copper cards */
+		}
+		printk(KERN_INFO "%s: Duplex set via ethtool\n",
+		ndev->name);
+	}
+
+	/* Set autonegotiation */
+	if ((disable_autoneg && cmd->autoneg != AUTONEG_DISABLE) ||
+			(!disable_autoneg && cmd->autoneg != AUTONEG_ENABLE)) {
+		if (cmd->autoneg == AUTONEG_ENABLE) {
+			disable_autoneg = 0;
+
+			/* restart auto negotiation */
+			writel(TBICR_MR_AN_ENABLE | TBICR_MR_RESTART_AN,
+				dev->base + TBICR);
+			writel(TBICR_MR_AN_ENABLE, dev->base + TBICR);
+				dev->linkstate = LINK_AUTONEGOTIATE;
+
+			printk(KERN_INFO "%s: autoneg enabled via ethtool\n",
+				ndev->name);
+		} else {
+			disable_autoneg = 1;
+
+			/* disable auto negotiation */
+			writel(0x00000000, dev->base + TBICR);
+		}
+
+		printk(KERN_INFO "%s: autoneg %s via ethtool\n", ndev->name,
+				cmd->autoneg ? "ENABLED" : "DISABLED");
+	}
+
+	phy_intr(ndev);
+	spin_unlock(&dev->tx_lock);
+	spin_unlock_irq(&dev->misc_lock);
+
+	return 0;
+}
+/* end ethtool get/set support -df */
+
 static void ns83820_get_drvinfo(struct net_device *ndev, struct ethtool_drvinfo *info)
 {
 	struct ns83820 *dev = PRIV(ndev);
@@ -1263,8 +1415,10 @@ static u32 ns83820_get_link(struct net_d
 }
 
 static const struct ethtool_ops ops = {
-	.get_drvinfo = ns83820_get_drvinfo,
-	.get_link = ns83820_get_link
+	.get_settings    = ns83820_get_settings,
+	.set_settings    = ns83820_set_settings,
+	.get_drvinfo     = ns83820_get_drvinfo,
+	.get_link        = ns83820_get_link
 };
 
 /* this function is called in irq context from the ISR */
@@ -1968,12 +2122,16 @@ static int __devinit ns83820_init_one(st
 		       | TANAR_HALF_DUP | TANAR_FULL_DUP,
 		       dev->base + TANAR);
 
-		/* start auto negotiation */
-		writel(TBICR_MR_AN_ENABLE | TBICR_MR_RESTART_AN,
-		       dev->base + TBICR);
-		writel(TBICR_MR_AN_ENABLE, dev->base + TBICR);
-		dev->linkstate = LINK_AUTONEGOTIATE;
-
+		if (!disable_autoneg) {
+		       /* start auto negotiation */
+			writel(TBICR_MR_AN_ENABLE | TBICR_MR_RESTART_AN,
+				dev->base + TBICR);
+			writel(TBICR_MR_AN_ENABLE, dev->base + TBICR);
+			dev->linkstate = LINK_AUTONEGOTIATE;
+		} else {
+			 printk(KERN_INFO "%s: Skipping autonegotiation\n",
+				 ndev->name);
+		}
 		dev->CFG_cache |= CFG_MODE_1000;
 	}
 
@@ -2193,5 +2351,8 @@ MODULE_PARM_DESC(ihr, "Time in 100 us in
 module_param(reset_phy, int, 0);
 MODULE_PARM_DESC(reset_phy, "Set to 1 to reset the PHY on startup");
 
+module_param(disable_autoneg, int, 0);
+MODULE_PARM_DESC(disable_autoneg, "Set to 1 to disable autoneg");
+
 module_init(ns83820_init);
 module_exit(ns83820_exit);
_
