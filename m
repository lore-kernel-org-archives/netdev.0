From: Dan Carpenter <error27@gmail.com>
Subject: [patch] Staging: vt6656: problems in error handling
Date: Tue, 10 Aug 2010 08:00:12 +0200
Message-ID: <20100810060012.GR9031@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andres More <more.andres@gmail.com>,
	Forest Bond <forest@alittletooquiet.net>,
	Jim Lieb <lieb@canonical.com>, devel@driverdev.osuosl.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:65088 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244Ab0HJGAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 02:00:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first kfree(pDevice) is pointless because pDevice is NULL.  The
second kfree(pDevice) is a double free because pDevice is the driver's
private data and that is already freed by free_netdev(netdev).  Also the
free_netdev() error path doesn't call usb_put_dev().

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/staging/vt6656/main_usb.c b/drivers/staging/vt6656/main_usb.c
index c528ef0..4fdf837 100644
--- a/drivers/staging/vt6656/main_usb.c
+++ b/drivers/staging/vt6656/main_usb.c
@@ -771,10 +771,9 @@ vt6656_probe(struct usb_interface *intf, const struct usb_device_id *id)
 
 	udev = usb_get_dev(udev);
 	netdev = alloc_etherdev(sizeof(DEVICE_INFO));
-
 	if (!netdev) {
 		printk(KERN_ERR DEVICE_NAME ": allocate net device failed\n");
-		kfree(pDevice);
+		rc = -ENOMEM;
 		goto err_nomem;
 	}
 
@@ -800,9 +799,7 @@ vt6656_probe(struct usb_interface *intf, const struct usb_device_id *id)
 	rc = register_netdev(netdev);
 	if (rc) {
 		printk(KERN_ERR DEVICE_NAME " Failed to register netdev\n");
-		free_netdev(netdev);
-		kfree(pDevice);
-		return -ENODEV;
+		goto err_netdev;
 	}
 
 	usb_device_reset(pDevice);
@@ -820,10 +817,12 @@ vt6656_probe(struct usb_interface *intf, const struct usb_device_id *id)
 
 	return 0;
 
+err_netdev:
+	free_netdev(netdev);
 err_nomem:
 	usb_put_dev(udev);
 
-	return -ENOMEM;
+	return rc;
 }
 
 static void device_free_tx_bufs(PSDevice pDevice)
