From: Petr Malat <oss@malat.biz>
Subject: [PATCH v2] phy: Fix phy_device_free memory leak
Date: Thu, 28 Feb 2013 12:01:52 +0100
Message-ID: <20130228110152.GA26262@bordel.klfree.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oss@malat.biz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:42274 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163Ab3B1K6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 05:58:12 -0500
Received: by mail-ee0-f45.google.com with SMTP id b57so1310578eek.4
        for <netdev@vger.kernel.org>; Thu, 28 Feb 2013 02:58:11 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Petr Malat <oss@malat.biz>

Fix memory leak in phy_device_free() for the case when phy_device*
returned by phy_device_create() is not registered in the system.

Bug description:
phy_device_create() sets name of kobject using dev_set_name(), which 
allocates memory using kvasprintf(), but this memory isn't freed if 
the underlying device isn't registered properly, because kobject_cleanup()
is not called in that case. This can happen (and actually is happening on 
our machines) if phy_device_register(), called by mdiobus_scan(), fails. 

Patch description:
Embedded struct device is initialized in phy_device_create() and it 
counterpart phy_device_free() just drops one reference to the device,
which leads to proper deinitialization including releasing the kobject 
name memory.

Signed-off-by: Petr Malat <oss@malat.biz>
---
Updated according to according to David Miller proposal - put_device is
used to release the memory now.

Please put me on CC, I'm not signed into the mailing list.

--- linux-3.8/drivers/net/phy/phy_device.c.orig	2013-02-19 00:58:34.000000000 +0100
+++ linux-3.8/drivers/net/phy/phy_device.c	2013-02-28 11:20:51.841528627 +0100
@@ -44,13 +44,13 @@ MODULE_LICENSE("GPL");
 
 void phy_device_free(struct phy_device *phydev)
 {
-	kfree(phydev);
+	put_device(&phydev->dev);
 }
 EXPORT_SYMBOL(phy_device_free);
 
 static void phy_device_release(struct device *dev)
 {
-	phy_device_free(to_phy_device(dev));
+	kfree(to_phy_device(dev));
 }
 
 static struct phy_driver genphy_driver;
@@ -201,6 +201,8 @@ struct phy_device *phy_device_create(str
 	   there's no driver _already_ loaded. */
 	request_module(MDIO_MODULE_PREFIX MDIO_ID_FMT, MDIO_ID_ARGS(phy_id));
 
+	device_initialize(&dev->dev);
+
 	return dev;
 }
 EXPORT_SYMBOL(phy_device_create);
@@ -363,9 +365,9 @@ int phy_device_register(struct phy_devic
 	/* Run all of the fixups for this PHY */
 	phy_scan_fixups(phydev);
 
-	err = device_register(&phydev->dev);
+	err = device_add(&phydev->dev);
 	if (err) {
-		pr_err("phy %d failed to register\n", phydev->addr);
+		pr_err("PHY %d failed to add\n", phydev->addr);
 		goto out;
 	}
 
