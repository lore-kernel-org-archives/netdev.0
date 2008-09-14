From: Oliver Martin <oliver.martin@student.tuwien.ac.at>
Subject: Re: [PATCH] Re: ep93xx_eth PHY problems
Date: Sun, 14 Sep 2008 14:11:10 +0200
Message-ID: <20080914141110.18b42a42@ors.home>
References: <47CD4857.2060406@student.tuwien.ac.at>
	<20080321202202.129c1239@ors>
	<48CC72D4.1020001@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hvr@gnu.org, buytenh@wantstofly.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:1295 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754500AbYINMLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 08:11:17 -0400
Received: by ey-out-2122.google.com with SMTP id 6so709140eyi.37
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2008 05:11:14 -0700 (PDT)
In-Reply-To: <48CC72D4.1020001@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Sat, 13 Sep 2008 22:11:32 -0400 schrieb Jeff Garzik:

> Oliver Martin wrote:
> > Am Tue, 04 Mar 2008 14:02:15 +0100
> > schrieb Oliver Martin <oliver.martin@student.tuwien.ac.at>:
> >> Now I'm having different problems: When auto-negotiation is
> >> enabled, it sometimes randomly changes the link state:
> >>
> >> PHY: 0:01 - Link is Down
> >> PHY: 0:01 - Link is Up - 100/Full
> >>
> > 
> > I've found at least one part of the problem. The MDIO clock divisor
> > wasn't set again after the reset in ep93xx_start_hw. It was left at
> > the default, resulting in a 12.5 MHz clock, which the PHY (Micrel
> > KSZ8721BL) didn't like too much. Calling ep93xx_mdio_reset after
> > the reset fixed it, the link is now perfectly stable in
> > auto-negotiation mode.
> > 
> > There still seems to be another bug with auto-negotiation disabled:
> > It doesn't switch to 1000 Mbps any more, but most times it doesn't
> > stay in the intended configuration either. I haven't done any
> > extensive testing of this yet, though.
> > 
> > Signed-off-by: Oliver Martin <oliver.martin@student.tuwien.ac.at>
> 
> Testing feedback?  Lennert ack?

We're currently using a variation of my original patch, which didn't
handle ifdown correctly (there's a similar reset there). With the
current setup, everything seems stable, but we still have some rather
hackish workarounds for the original issue in our startup scripts.
I don't have the hardware right now, but we'll specifically test
without them both with and without auto-negotiation next week and
report the results.


Index: linux-2.6.26/drivers/net/arm/ep93xx_eth.c
===================================================================
--- linux-2.6.26.orig/drivers/net/arm/ep93xx_eth.c	2008-07-25 03:13:33.000000000 +0200
+++ linux-2.6.26/drivers/net/arm/ep93xx_eth.c	2008-07-25 03:14:52.000000000 +0200
@@ -535,6 +535,22 @@
 	return 1;
 }
 
+static int ep93xx_mdio_reset(struct mii_bus *bus)
+{
+	struct ep93xx_priv *ep = bus->priv;
+
+	u32 selfctl = rdl(ep, REG_SELFCTL);
+
+	selfctl &= ~(REG_SELFCTL_MDCDIV_MSK | REG_SELFCTL_PSPRS);
+
+	selfctl |= (ep->mdc_divisor - 1) << REG_SELFCTL_MDCDIV_OFS;
+	selfctl |= REG_SELFCTL_PSPRS;
+
+	wrl(ep, REG_SELFCTL, selfctl);
+
+	return 0;
+}
+
 static int ep93xx_start_hw(struct net_device *dev)
 {
 	struct ep93xx_priv *ep = netdev_priv(dev);
@@ -553,6 +569,9 @@
 		return 1;
 	}
 
+	/* The reset cleared REG_SELFCTL, so set the MDC divisor again */
+	ep93xx_mdio_reset(&ep->mii_bus);
+
 	/* Receive descriptor ring.  */
 	addr = ep->descs_dma_addr + offsetof(struct ep93xx_descs, rdesc);
 	wrl(ep, REG_RXDQBADD, addr);
@@ -625,6 +644,9 @@
 
 	if (i == 10)
 		printk(KERN_CRIT DRV_MODULE_NAME ": hw failed to reset\n");
+
+	/* The reset cleared REG_SELFCTL, so set the MDC divisor again */
+	ep93xx_mdio_reset(&ep->mii_bus);
 }
 
 static int ep93xx_open(struct net_device *dev)
@@ -776,22 +798,6 @@
 	return 0;
 }
 
-static int ep93xx_mdio_reset(struct mii_bus *bus)
-{
-	struct ep93xx_priv *ep = bus->priv;
-
-	u32 selfctl = rdl(ep, REG_SELFCTL);
-
-	selfctl &= ~(REG_SELFCTL_MDCDIV_MSK | REG_SELFCTL_PSPRS);
-
-	selfctl |= (ep->mdc_divisor - 1) << REG_SELFCTL_MDCDIV_OFS;
-	selfctl |= REG_SELFCTL_PSPRS;
-
-	wrl(ep, REG_SELFCTL, selfctl);
-
-	return 0;
-}
-
 
 static void ep93xx_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
