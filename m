From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/3] net: phy: Create sysfs reciprocal links for attached_dev/phydev
Date: Thu, 25 May 2017 09:21:41 -0700
Message-ID: <20170525162143.18319-2-f.fainelli@gmail.com>
References: <20170525162143.18319-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:33702 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1165402AbdEYQVu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 12:21:50 -0400
Received: by mail-qk0-f194.google.com with SMTP id o85so30718329qkh.0
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 09:21:49 -0700 (PDT)
In-Reply-To: <20170525162143.18319-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is currently no way for a program scanning /sys to know whether a
network device is attached to a particular PHY device, just like the PHY
device is not pointed back to its attached network device.

Create a symbolic link in the network device's namespace named "phydev"
which points to the PHY device and create a symbolic link in the PHY
device's namespace named "attached_dev" that points back to the network
device. These links are set up during phy_attach_direct() and removed
during phy_detach() for symetry.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy_device.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 1219eeab69d1..8151477c7027 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -960,6 +960,15 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 
 	phydev->attached_dev = dev;
 	dev->phydev = phydev;
+	err = sysfs_create_link(&phydev->mdio.dev.kobj, &dev->dev.kobj,
+				"attached_dev");
+	if (err)
+		goto error;
+
+	err = sysfs_create_link(&dev->dev.kobj, &phydev->mdio.dev.kobj,
+				"phydev");
+	if (err)
+		goto error;
 
 	phydev->dev_flags = flags;
 
@@ -1050,6 +1059,8 @@ void phy_detach(struct phy_device *phydev)
 	struct mii_bus *bus;
 	int i;
 
+	sysfs_remove_link(&dev->dev.kobj, "phydev");
+	sysfs_remove_link(&phydev->mdio.dev.kobj, "attached_dev");
 	phydev->attached_dev->phydev = NULL;
 	phydev->attached_dev = NULL;
 	phy_suspend(phydev);
-- 
2.9.3
