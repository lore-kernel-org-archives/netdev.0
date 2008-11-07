From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [BUG] rmmod bfin_mac netdev driver module will cause system crash.
Date: Fri, 7 Nov 2008 10:24:50 +0100
Message-ID: <20081107092450.GG32552@xi.wantstofly.org>
References: <386072610811040045w2944a856jd55809f0a7532dbd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>,
	Byron Bradley <byron.bbradley@gmail.com>,
	Tim Ellis <tim.ellis@mac.com>, Imre Kaloz <kaloz@openwrt.org>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: Bryan Wu <cooloney@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:51559 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbYKGJYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 04:24:52 -0500
Content-Disposition: inline
In-Reply-To: <386072610811040045w2944a856jd55809f0a7532dbd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 04, 2008 at 04:45:13PM +0800, Bryan Wu wrote:

> Hi Lennert,

Hi Bryan,


> I got a regression since I update our blackfin kernel to the lastest
> 2.6.28-rc2 which includes your phylib patches.
> Please find the tracker here:
> https://blackfin.uclinux.org/gf/project/uclinux-dist/tracker/?action=TrackerItemEdit&tracker_id=141&tracker_item_id=4595
> 
> Briefly, the calling chain is:
> in bfin_mac_remove(), mdiobus_unregister() ->
> device_unregister(&bus->dev); -> put_device() -> kobject_put() ->
> kref_put(&kobj->kref, kobject_release); -> kobject_release() ->
> kobject_cleanup() -> mdiobus_release().
> So in mdiobus_unregister() bus->state = MDIOBUS_UNREGISTERED; but in
> mdiobus_release(), this BUG_ON will fire:
> BUG_ON(bus->state != MDIOBUS_RELEASED);
> 
> How about this patch?
> 
> ---
> Index: drivers/net/phy/mdio_bus.c
> ===================================================================
> --- drivers/net/phy/mdio_bus.c	(revision 5575)
> +++ drivers/net/phy/mdio_bus.c	(working copy)
> @@ -134,13 +134,16 @@
>  	int i;
> 
>  	BUG_ON(bus->state != MDIOBUS_REGISTERED);
> -	bus->state = MDIOBUS_UNREGISTERED;
> 
> +	bus->state = MDIOBUS_RELEASED;
> +
>  	device_unregister(&bus->dev);
>  	for (i = 0; i < PHY_MAX_ADDR; i++) {
>  		if (bus->phy_map[i])
>  			device_unregister(&bus->phy_map[i]->dev);
>  	}
> +
> +	bus->state = MDIOBUS_UNREGISTERED;
>  }
>  EXPORT_SYMBOL(mdiobus_unregister);
> ---

Actually, what I think should be done is this.  Can you try that?


diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index d0ed1ef..536bda1 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -136,7 +136,7 @@ void mdiobus_unregister(struct mii_bus *bus)
 	BUG_ON(bus->state != MDIOBUS_REGISTERED);
 	bus->state = MDIOBUS_UNREGISTERED;
 
-	device_unregister(&bus->dev);
+	device_del(&bus->dev);
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
 		if (bus->phy_map[i])
 			device_unregister(&bus->phy_map[i]->dev);
