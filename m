From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH,RESEND] phylib: fix premature freeing of struct mii_bus
Date: Tue, 18 Nov 2008 15:33:07 +0100
Message-ID: <20081118143307.GA12255@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bryan Wu <cooloney@kernel.org>, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:48805 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234AbYKROdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 09:33:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
