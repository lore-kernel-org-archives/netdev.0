From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2] net: phy: Relax error checking on sysfs_create_link()
Date: Sat, 27 May 2017 10:42:25 -0700
Message-ID: <20170527174225.9447-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, Woojung.Huh@microchip.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34292 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750727AbdE0Rm3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 13:42:29 -0400
Received: by mail-oi0-f65.google.com with SMTP id w10so6227703oif.1
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 10:42:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some Ethernet drivers will attach/connect to a PHY device before calling
register_netdevice() which is responsible for calling netdev_register_kobject()
which would do the network device's kobject initialization. In such a case,
sysfs_create_link() would return -ENOENT because the network device's kobject
is not ready yet, and we would fail to connect to the PHY device.

In order to keep things simple and symetrical, we just take the success path as
indicative of the ability to access the network device's kobject, and create
the second link if that's the case.

Fixes: 5568363f0cb3 ("net: phy: Create sysfs reciprocal links for attached_dev/phydev")
Reported-by: Woojung Hung <Woojung.Huh@microchip.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- make sure phydev->sysfs_links is set to false before setting again

 drivers/net/phy/phy_device.c | 30 ++++++++++++++++++++++--------
 include/linux/phy.h          |  2 ++
 2 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index f84414b8f2ee..37a1e98908e3 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -960,15 +960,27 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 
 	phydev->attached_dev = dev;
 	dev->phydev = phydev;
+
+	/* Some Ethernet drivers try to connect to a PHY device before
+	 * calling register_netdevice() -> netdev_register_kobject() and
+	 * does the dev->dev.kobj initialization. Here we only check for
+	 * success which indicates that the network device kobject is
+	 * ready. Once we do that we still need to keep track of whether
+	 * links were successfully set up or not for phy_detach() to
+	 * remove them accordingly.
+	 */
+	phydev->sysfs_links = false;
+
 	err = sysfs_create_link(&phydev->mdio.dev.kobj, &dev->dev.kobj,
 				"attached_dev");
-	if (err)
-		goto error;
+	if (!err) {
+		err = sysfs_create_link(&dev->dev.kobj, &phydev->mdio.dev.kobj,
+					"phydev");
+		if (err)
+			goto error;
 
-	err = sysfs_create_link(&dev->dev.kobj, &phydev->mdio.dev.kobj,
-				"phydev");
-	if (err)
-		goto error;
+		phydev->sysfs_links = true;
+	}
 
 	phydev->dev_flags = flags;
 
@@ -1059,8 +1071,10 @@ void phy_detach(struct phy_device *phydev)
 	struct mii_bus *bus;
 	int i;
 
-	sysfs_remove_link(&dev->dev.kobj, "phydev");
-	sysfs_remove_link(&phydev->mdio.dev.kobj, "attached_dev");
+	if (phydev->sysfs_links) {
+		sysfs_remove_link(&dev->dev.kobj, "phydev");
+		sysfs_remove_link(&phydev->mdio.dev.kobj, "attached_dev");
+	}
 	phydev->attached_dev->phydev = NULL;
 	phydev->attached_dev = NULL;
 	phy_suspend(phydev);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 5a808a26e4cf..58f1b45a4c44 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -363,6 +363,7 @@ struct phy_c45_device_ids {
  * is_pseudo_fixed_link: Set to true if this phy is an Ethernet switch, etc.
  * has_fixups: Set to true if this phy has fixups/quirks.
  * suspended: Set to true if this phy has been suspended successfully.
+ * sysfs_links: Internal boolean tracking sysfs symbolic links setup/removal.
  * state: state of the PHY for management purposes
  * dev_flags: Device-specific flags used by the PHY driver.
  * link_timeout: The number of timer firings to wait before the
@@ -399,6 +400,7 @@ struct phy_device {
 	bool is_pseudo_fixed_link;
 	bool has_fixups;
 	bool suspended;
+	bool sysfs_links;
 
 	enum phy_state state;
 
-- 
2.11.0
