From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v3 1/3] net: phy: Fix PHY module checks and NULL deref in phy_attach_direct()
Date: Wed,  8 Feb 2017 16:13:59 -0800
Message-ID: <20170209001401.2564-2-f.fainelli@gmail.com>
References: <20170209001401.2564-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        maowenan <maowenan@huawei.com>, andrew@lunn.ch,
        rmk+kernel@armlinux.org.uk, festevam@gmail.com,
        davem@davemloft.net, nikita.yoush@cogentembedded.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35405 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751073AbdBIAk6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 19:40:58 -0500
Received: by mail-qt0-f194.google.com with SMTP id s58so25546296qtc.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 16:39:46 -0800 (PST)
In-Reply-To: <20170209001401.2564-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Generic PHY drivers gets assigned after we checked that the current
PHY driver is NULL, so we need to check a few things before we can
safely dereference d->driver. This would be causing a NULL deference to
occur when a system binds to the Generic PHY driver. Update
phy_attach_direct() to do the following:

- grab the driver module reference after we have assigned the Generic
  PHY drivers accordingly

- update the error path to clean up the module reference in case the
  Generic PHY probe function fails

Fixes: cafe8df8b9bc ("net: phy: Fix lack of reference count on PHY driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy_device.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 0d8f4d3847f6..d63d190a95ef 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -908,6 +908,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 	struct module *ndev_owner = dev->dev.parent->driver->owner;
 	struct mii_bus *bus = phydev->mdio.bus;
 	struct device *d = &phydev->mdio.dev;
+	bool using_genphy = false;
 	int err;
 
 	/* For Ethernet device drivers that register their own MDIO bus, we
@@ -938,12 +939,22 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 			d->driver =
 				&genphy_driver[GENPHY_DRV_1G].mdiodrv.driver;
 
+		using_genphy = true;
+	}
+
+	if (!try_module_get(d->driver->owner)) {
+		dev_err(&dev->dev, "failed to get the device driver module\n");
+		err = -EIO;
+		goto error_put_device;
+	}
+
+	if (using_genphy) {
 		err = d->driver->probe(d);
 		if (err >= 0)
 			err = device_bind_driver(d);
 
 		if (err)
-			goto error;
+			goto error_module_put;
 	}
 
 	if (phydev->attached_dev) {
@@ -981,6 +992,9 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 
 error:
 	phy_detach(phydev);
+error_module_put:
+	module_put(d->driver->owner);
+error_put_device:
 	put_device(d);
 	module_put(d->driver->owner);
 	if (ndev_owner != bus->owner)
-- 
2.9.3
