From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 1/3] net: phy: Fix PHY module checks
Date: Tue,  7 Feb 2017 23:37:44 -0800
Message-ID: <20170208073746.10963-2-f.fainelli@gmail.com>
References: <20170208073746.10963-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        maowenan@huawei.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:35370 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932440AbdBHHhv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 02:37:51 -0500
Received: by mail-ot0-f196.google.com with SMTP id 65so17113268otq.2
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 23:37:51 -0800 (PST)
In-Reply-To: <20170208073746.10963-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Generic PHY drivers gets assigned after we checked that the current PHY
driver is NULL, so we need to check a few things before we can safely
derference d->driver. Update phy_attach_direct() and phy_detach() accordingly
to be resilient to these cases.

Even though the Generic PHY driver defaults to phy_probe() which can hardly
fail at the moment, let's fix the label so we don't call phy_detach() on a
network device we have not attached yet.

Fixes: cafe8df8b9bc ("net: phy: Fix lack of reference count on PHY driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy_device.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 0d8f4d3847f6..bde240bf8d7b 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -920,7 +920,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 		return -EIO;
 	}
 
-	if (!try_module_get(d->driver->owner)) {
+	if (d->driver && !try_module_get(d->driver->owner)) {
 		dev_err(&dev->dev, "failed to get the device driver module\n");
 		return -EIO;
 	}
@@ -943,7 +943,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 			err = device_bind_driver(d);
 
 		if (err)
-			goto error;
+			goto error_put_device;
 	}
 
 	if (phydev->attached_dev) {
@@ -981,6 +981,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 
 error:
 	phy_detach(phydev);
+error_put_device:
 	put_device(d);
 	module_put(d->driver->owner);
 	if (ndev_owner != bus->owner)
@@ -1065,7 +1066,8 @@ void phy_detach(struct phy_device *phydev)
 	bus = phydev->mdio.bus;
 
 	put_device(&phydev->mdio.dev);
-	module_put(phydev->mdio.dev.driver->owner);
+	if (phydev->mdio.dev.driver)
+		module_put(phydev->mdio.dev.driver->owner);
 	if (ndev_owner != bus->owner)
 		module_put(bus->owner);
 }
-- 
2.9.3
