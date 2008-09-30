From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 3/3] phylib: give mdio buses a device tree presence
Date: Tue, 30 Sep 2008 05:04:19 +0200
Message-ID: <20080930030419.GD3251@xi.wantstofly.org>
References: <20080929021400.GE21560@xi.wantstofly.org> <425FFC3E-EAE1-4BE3-89CD-9A6363BBAFA7@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Byron Bradley <byron.bbradley@gmail.com>,
	Tim Ellis <tim.ellis@mac.com>, Imre Kaloz <kaloz@openwrt.org>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:37875 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbYI3DEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 23:04:20 -0400
Content-Disposition: inline
In-Reply-To: <425FFC3E-EAE1-4BE3-89CD-9A6363BBAFA7@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 05:45:01PM -0500, Andy Fleming wrote:

> >Introduce the mdio_bus class, and give each 'struct mii_bus' its own
> >'struct device', so that mii_bus objects are represented in the device
> >tree and can be found by querying the device tree.
> >
> >Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> >---
> >drivers/net/phy/mdio_bus.c |   74 +++++++++++++++++++++++++++++++++++ 
> >++++++--
> >include/linux/phy.h        |    8 +++++
> >2 files changed, 78 insertions(+), 4 deletions(-)
> >
> >diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> >index d206691..f9c27ac 100644
> >--- a/drivers/net/phy/mdio_bus.c
> >+++ b/drivers/net/phy/mdio_bus.c
> >@@ -43,11 +43,35 @@
> > */
> >struct mii_bus *mdiobus_alloc(void)
> >{
> >-	return kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
> >+	struct mii_bus *bus;
> >+
> >+	bus = kzalloc(sizeof(*bus), GFP_KERNEL);
> >+	if (bus != NULL)
> >+		bus->state = MDIOBUS_ALLOCATED;
> >+
> >+	return bus;
> >}
> >EXPORT_SYMBOL(mdiobus_alloc);
> 
> Do we really need all this state tracking?  Doesn't the device layer  
> do this for us?  I looked through other driver subsystems, and I  
> didn't see anything like this.  Can we rearchitect this so that we're  
> not having to track allocation/registration state?

I modeled it after struct net_device's state tracking.  It's "necessary"
for one case, which is mdiobus_alloc() + mdiobus_free() without an
intervening mdiobus_register/unregister() pair (e.g. what happens when
the mii bus driver's setup function encounters an error halfway through
and frees the mii bus without ever registering it).  In that case, we
need to just call kfree() instead of put_device(), since the embedded
struct device will never have been registered.  struct net_device has
this same issue, and deals with it in the same way.

Also, MDIOBUS_ALLOCATED starts at 1 to make sure that any users not
using mdiobus_alloc() (i.e. ones that still embed a struct mii_bus in
one of their own structs) are caught and dealt with.  But that part
isn't really necessary.  Some of the other states aren't strictly
necessary either, but are just there to make sure you call stuff in
the right order.
