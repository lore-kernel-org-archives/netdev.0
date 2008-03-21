From: Oliver Martin <oliver.martin@student.tuwien.ac.at>
Subject: [PATCH] Re: ep93xx_eth PHY problems
Date: Fri, 21 Mar 2008 20:22:02 +0100
Message-ID: <20080321202202.129c1239@ors>
References: <47CD4857.2060406@student.tuwien.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hvr@gnu.org, buytenh@wantstofly.org
To: Oliver Martin <oliver.martin@student.tuwien.ac.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:23502 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754424AbYCUTWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 15:22:18 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1448488fgb.17
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 12:22:16 -0700 (PDT)
In-Reply-To: <47CD4857.2060406@student.tuwien.ac.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Tue, 04 Mar 2008 14:02:15 +0100
schrieb Oliver Martin <oliver.martin@student.tuwien.ac.at>:
> 
> Now I'm having different problems: When auto-negotiation is enabled,
> it sometimes randomly changes the link state:
> 
> PHY: 0:01 - Link is Down
> PHY: 0:01 - Link is Up - 100/Full
> 

I've found at least one part of the problem. The MDIO clock divisor
wasn't set again after the reset in ep93xx_start_hw. It was left at the
default, resulting in a 12.5 MHz clock, which the PHY (Micrel KSZ8721BL)
didn't like too much. Calling ep93xx_mdio_reset after the reset fixed
it, the link is now perfectly stable in auto-negotiation mode.

There still seems to be another bug with auto-negotiation disabled: It
doesn't switch to 1000 Mbps any more, but most times it doesn't stay in
the intended configuration either. I haven't done any extensive
testing of this yet, though.

Signed-off-by: Oliver Martin <oliver.martin@student.tuwien.ac.at>

--- linux-2.6.24-phy/drivers/net/arm/ep93xx_eth.c.orig	2008-03-19 15:18:29.000000000 +0100
+++ linux-2.6.24-phy/drivers/net/arm/ep93xx_eth.c	2008-03-19 15:43:44.000000000 +0100
@@ -535,6 +535,22 @@ err:
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
@@ -553,6 +569,9 @@ static int ep93xx_start_hw(struct net_de
 		return 1;
 	}
 
+	/* The reset cleared REG_SELFCTL, so set the MDC divisor again */
+	ep93xx_mdio_reset(&ep->mii_bus);
+
 	/* Receive descriptor ring.  */
 	addr = ep->descs_dma_addr + offsetof(struct ep93xx_descs, rdesc);
 	wrl(ep, REG_RXDQBADD, addr);
@@ -776,22 +795,6 @@ static int ep93xx_mdio_write(struct mii_
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
