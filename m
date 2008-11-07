From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] phylib: fix premature freeing of struct mii_bus
Date: Fri, 7 Nov 2008 22:06:17 +0100
Message-ID: <20081107210617.GS32552@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:42968 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbYKGVGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 16:06:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>

Commit 46abc02175b3c246dd5141d878f565a8725060c9 ("phylib: give mdio
buses a device tree presence") added a call to device_unregister() in
a situation where the caller did not expect the reference count on
the embedded kobject to be dropped, but device_unregister() does drop
that reference count.  The right function to use in this situation
is device_del(), which unregisters the device from the system like
device_unregister() does, but without dropping the reference count.

Bug report from Bryan Wu <cooloney@kernel.org>.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Tested-by: Bryan Wu <cooloney@kernel.org>
--
2.6.27 is not affected.

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
