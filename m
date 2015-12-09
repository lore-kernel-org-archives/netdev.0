From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] phy: micrel: Fix finding PHY properties in MAC node.
Date: Wed, 9 Dec 2015 19:52:51 +0100
Message-ID: <20151209185251.GA14995@lunn.ch>
References: <1449686226-14834-1-git-send-email-andrew@lunn.ch>
 <56687621.9010602@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	dinguyen@opensource.altera.com, david.daney@cavium.com
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34239 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753280AbbLISwz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2015 13:52:55 -0500
Content-Disposition: inline
In-Reply-To: <56687621.9010602@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> >index cf6312fafea5..2493d7c035f2 100644
> >--- a/drivers/net/phy/micrel.c
> >+++ b/drivers/net/phy/micrel.c
> >@@ -26,6 +26,7 @@
> >  #include <linux/module.h>
> >  #include <linux/phy.h>
> >  #include <linux/micrel_phy.h>
> >+#include <linux/netdevice.h>
> 
> No new types are introduced by the patch.  Why do we need an
> additional #include?

We probably don't.

It took my debug patch which printed additional information, and
stripped the prints out. One of those prints needed netdev, but since
it has now gone, we probably don't need the include.

   Andrew

 
> >  #include <linux/of.h>
> >  #include <linux/clk.h>
> >
> >@@ -339,9 +340,18 @@ static int ksz9021_config_init(struct phy_device *phydev)
> >  {
> >  	const struct device *dev = &phydev->dev;
> >  	const struct device_node *of_node = dev->of_node;
> >+	const struct device *dev_walker;
> >
> >-	if (!of_node && dev->parent->of_node)
> >-		of_node = dev->parent->of_node;
> >+	/* The Micrel driver has a deprecated option to place phy OF
> >+	 * properties in the MAC node. Walk up the tree of devices to
> >+	 * find a device with an OF node.
> >+	 */
> >+	dev_walker = &phydev->dev;
> >+	do {
> >+		of_node = dev_walker->of_node;
> >+		dev_walker = dev_walker->parent;
> >+
> >+	} while (!of_node && dev_walker);
> >
> >  	if (of_node) {
> >  		ksz9021_load_values_from_of(phydev, of_node,
> >
> 
