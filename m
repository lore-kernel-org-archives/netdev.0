From: Petr Malat <oss@malat.biz>
Subject: [PATCH] phy: fix phy_device_free memory leak
Date: Tue, 19 Feb 2013 20:36:46 +0100
Message-ID: <20130219193646.GA10851@bordel.klfree.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Petr Malat <oss@malat.biz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:43772 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933341Ab3BSTdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 14:33:16 -0500
Received: by mail-ea0-f173.google.com with SMTP id i1so2962202eaa.4
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 11:33:13 -0800 (PST)
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
Name is freed by phy_device_free(). In the case a device is released 
trough kobject_cleanup()->device_release()->phy_device_release(), the name
is set to NULL and it is not freed by phy_device_free(), because it will 
be freed later by kobject_cleanup().

Signed-off-by: Petr Malat <oss@malat.biz>
---
Please put me on CC, I'm not signed into the mailing list.

--- linux-v2.6.32.60.orig/drivers/net/phy/phy_device.c	2013-02-06 19:44:11.000000000 +0100
+++ linux-v2.6.32.60/drivers/net/phy/phy_device.c	2013-02-06 20:56:57.000000000 +0100
@@ -41,12 +41,16 @@ MODULE_LICENSE("GPL");
 
 void phy_device_free(struct phy_device *phydev)
 {
+	kfree(phydev->dev.kobj.name);
 	kfree(phydev);
 }
 EXPORT_SYMBOL(phy_device_free);
 
 static void phy_device_release(struct device *dev)
 {
+	/* Name will be freed by kobject_cleanup() */
+	dev->kobj.name = NULL; 
+
 	phy_device_free(to_phy_device(dev));
 }
 
