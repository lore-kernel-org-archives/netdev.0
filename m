From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] [net] phy: micrel: Fix build failure in
 ksz9031_config_init()
Date: Sat, 9 Jan 2016 16:55:24 +0100
Message-ID: <20160109155524.GB28813@lunn.ch>
References: <1452340757-29507-1-git-send-email-sedat.dilek@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roosen Henri <Henri.Roosen@ginzinger.com>,
	David Daney <david.daney@cavium.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sedat Dilek <sedat.dilek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44564 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754033AbcAIPz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jan 2016 10:55:28 -0500
Content-Disposition: inline
In-Reply-To: <1452340757-29507-1-git-send-email-sedat.dilek@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 09, 2016 at 12:59:17PM +0100, Sedat Dilek wrote:
> This fixes the following build failure seen in net.git#master on top of
> Linux v4.4-rc8+:

I'm pretty sure this is wrong. Here is why...

net.git has the fix:

commit b4c19f71252e3b6b8c6478fd712c592f00b11438
Author: Roosen Henri <Henri.Roosen@ginzinger.com>
Date:   Thu Jan 7 09:31:15 2016 +0100

    phy: micrel: Fix finding PHY properties in MAC node for KSZ9031.
    
    Commit 651df2183543 ("phy: micrel: Fix finding PHY properties in MAC
     node.") only fixes finding PHY properties in MAC node for KSZ9021. This
    commit applies the same fix for KSZ9031.
    
    Fixes: 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus, not the bus' parent.")
    Acked-by: Andrew Lunn <andrew@lunn.ch>
    Signed-off-by: Henri Roosen <henri.roosen@ginzinger.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index e13ad6cdcc22..7a5679982c03 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -470,9 +470,17 @@ static int ksz9031_config_init(struct phy_device *phydev)
                "txd2-skew-ps", "txd3-skew-ps"
        };
        static const char *control_skews[2] = {"txen-skew-ps", "rxdv-skew-ps"};
+       const struct device *dev_walker;
 
-       if (!of_node && dev->parent->of_node)
-               of_node = dev->parent->of_node;
+       /* The Micrel driver has a deprecated option to place phy OF
+        * properties in the MAC node. Walk up the tree of devices to
+        * find a device with an OF node.
+        */
+       dev_walker = &phydev->dev;
+       do {
+               of_node = dev_walker->of_node;
+               dev_walker = dev_walker->parent;
+       } while (!of_node && dev_walker);


This brings in the dev_walker, which uses phydev->dev. In net, that is
correct. My patches introducing MDIO device are not in net. They are
only in net-next.

In net-next, this fix does not yet appear. Hence it does not yet have
the change of ->dev to ->mdio.dev.

Somehow, next.git has both net.git and net-next.git. Hence you get the
build error.

Unfortunately, we cannot fix this yet. Your fix needs to go to
net-next. But first Dave needs to merge net.git into net-next.git, so
bringing in Henri's fix. Only then can your fix be applied. My guess
is, Dave will do that Sunday when Linus makes the release and opens
the merge window.

	 Andrew
