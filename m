From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] phylib: fix premature freeing of struct mii_bus
Date: Sun, 9 Nov 2008 05:34:47 +0100
Message-ID: <20081109043447.GB17630@xi.wantstofly.org>
References: <20081107210617.GS32552@xi.wantstofly.org> <20081109015950.GX32552@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jeff@garzik.org, Bryan Wu <cooloney@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:52672 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899AbYKIEeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2008 23:34:50 -0500
Content-Disposition: inline
In-Reply-To: <20081109015950.GX32552@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 09, 2008 at 02:59:50AM +0100, Lennert Buytenhek wrote:

> > From: Lennert Buytenhek <buytenh@wantstofly.org>
> > 
> > Commit 46abc02175b3c246dd5141d878f565a8725060c9 ("phylib: give mdio
> > buses a device tree presence") added a call to device_unregister() in
> > a situation where the caller did not expect the reference count on
> > the embedded kobject to be dropped, but device_unregister() does drop
> > that reference count.  The right function to use in this situation
> > is device_del(), which unregisters the device from the system like
> > device_unregister() does, but without dropping the reference count.
> 
> Wait a minute -- the original code _is_ correct.  mdiobus_register()
> bumps the refcount to two (once because of device_initialize(), once
> because of device_add()), mdiobus_unregister() drops it back to one,
> and mdiobus_free() drops it to zero.

I was thrown off by a different bug here.  The original code is not
correct after all, and mdiobus_unregister() does have a bug where it
drops the refcount by one too many.  So the patch in the original
mail was correct, but the commit message was not.

Can you please use this message+patch instead?



commit 19e92973fc187125af02cefabc043359a962e5be
Author: Lennert Buytenhek <buytenh@wantstofly.org>
Date:   Sun Nov 9 05:02:11 2008 +0100

    phylib: fix premature freeing of struct mii_bus
    
    Commit 46abc02175b3c246dd5141d878f565a8725060c9 ("phylib: give mdio
    buses a device tree presence") added a call to device_unregister() in
    a situation where the caller did not intend for the device to be
    freed yet, but apart from just unregistering the device from the
    system, device_unregister() does an additional put_device() that is
    intended to free it.
    
    The right function to use in this situation is device_del(), which
    unregisters the device from the system like device_unregister() does,
    but without dropping the reference count an additional time.
    
    Bug report from Bryan Wu <cooloney@kernel.org>.
    
    Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
    Tested-by: Bryan Wu <cooloney@kernel.org>

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 6671e2d..df06301 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -135,7 +135,7 @@ void mdiobus_unregister(struct mii_bus *bus)
 	BUG_ON(bus->state != MDIOBUS_REGISTERED);
 	bus->state = MDIOBUS_UNREGISTERED;
 
-	device_unregister(&bus->dev);
+	device_del(&bus->dev);
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
 		if (bus->phy_map[i])
 			device_unregister(&bus->phy_map[i]->dev);
