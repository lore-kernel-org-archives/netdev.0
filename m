From: Oliver Martin <oliver.martin@student.tuwien.ac.at>
Subject: Re: [PATCH] Re: ep93xx_eth PHY problems
Date: Wed, 17 Sep 2008 11:13:52 +0200
Message-ID: <20080917111352.6810d370@ors.home>
References: <47CD4857.2060406@student.tuwien.ac.at>
	<20080321202202.129c1239@ors>
	<48CC72D4.1020001@garzik.org>
	<20080914141110.18b42a42@ors.home>
	<20080916125125.GA18961@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org, hvr@gnu.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.185]:45207 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397AbYIQJN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 05:13:58 -0400
Received: by gv-out-0910.google.com with SMTP id e6so1524981gvc.37
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2008 02:13:56 -0700 (PDT)
In-Reply-To: <20080916125125.GA18961@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Tue, 16 Sep 2008 14:51:25 +0200 schrieb Lennert Buytenhek:
> 
> OK, can you provide a commit message for this so that I can add it to
> http://git.wantstofly.org/?p=ep93xx_eth.git/.git;a=summary and ask
> Jeff to pull it?
> 

Previously, the MDIO clock divisor wasn't set again after the reset in
ep93xx_start_hw. It was left at the default, resulting in a 12.5 MHz
clock, which the PHY on our TS-7260 (Micrel KSZ8721BL) didn't like too
much. Calling ep93xx_mdio_reset after the reset fixed the problems we
were having. This small update to the previous patch also adds a call to
ep93xx_mdio_reset in ep93xx_stop_hw.

Signed-off-by: Oliver Martin <oliver.martin@student.tuwien.ac.at>

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
