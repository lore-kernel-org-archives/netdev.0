From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: kernel BUG at drivers/net/phy/mdio_bus.c:165!
Date: Wed, 17 Dec 2008 03:29:46 +0100
Message-ID: <m3ej07zg85.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:34004 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752534AbYLQC3s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2008 21:29:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kernel BUG at drivers/net/phy/mdio_bus.c:165!
Unable to handle kernel NULL pointer dereference at virtual address 00000000

How?

mdiobus_alloc() sets bus->state = MDIOBUS_ALLOCATED.

mdiobus_register() sets bus->state = MDIOBUS_REGISTERED but then can
   fail (mdiobus_scan()) returning an error to the caller.

The caller aborts correctly with mdiobus_free() which does:
        if (bus->state == MDIOBUS_ALLOCATED) {
                kfree(bus);
                return;
        }

        BUG_ON(bus->state != MDIOBUS_UNREGISTERED);

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -105,8 +105,6 @@ int mdiobus_register(struct mii_bus *bus)
 		return -EINVAL;
 	}
 
-	bus->state = MDIOBUS_REGISTERED;
-
 	mutex_init(&bus->mdio_lock);
 
 	if (bus->reset)
@@ -123,6 +121,9 @@ int mdiobus_register(struct mii_bus *bus)
 		}
 	}
 
+	if (!err)
+		bus->state = MDIOBUS_REGISTERED;
+
 	pr_info("%s: probed\n", bus->name);
 
 	return err;

-- 
Krzysztof Halasa
