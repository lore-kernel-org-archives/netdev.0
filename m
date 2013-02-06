From: Petr Malat <oss@malat.biz>
Subject: [PATCH]: fix phy_device_free memory leak
Date: Thu, 7 Feb 2013 00:07:57 +0100
Message-ID: <201302070007.57434.oss@malat.biz>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: oss@malat.biz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:32819 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755489Ab3BFXHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 18:07:18 -0500
Received: by mail-ee0-f42.google.com with SMTP id b47so1020338eek.15
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 15:07:17 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
there is a memory leak in phy_device handling:
phy_device_create() sets name of kobject using dev_set_name(), which allocates 
memory using kvasprintf(), but this memory isn't freed if the underlying 
device isn't registered properly, because kobject_cleanup() is not called in 
that case. This can happen (and actually is happening on our machines) if 
phy_device_register(), called by mdiobus_scan(), fails. I fixed this by the 
attached patch, so far it's working fine.

Patch description:
Name is freed by phy_device_free(). In the case a device is released trough 
kobject_cleanup()->device_release()->phy_device_release(), the name is set to 
NULL and it is not freed by phy_device_free(), because it will be freed later 
by kobject_cleanup().

Please put me on CC, I'm not signed into the mailing list.

   Petr


--- a/drivers/net/phy/phy_device.c	2013-02-06 19:44:11.000000000 +0100
+++ b/drivers/net/phy/phy_device.c	2013-02-06 20:56:57.000000000 +0100
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
