From: Samuel Ortiz <samuel.ortiz@nokia.com>
Subject: [PATCH] IrDA: irda-usb, unregister netdev when patch upload fails
Date: Fri, 14 Apr 2006 13:16:07 +0300
Message-ID: <20060414101607.GA32724@irie>
Reply-To: Samuel Ortiz <samuel.ortiz@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: IrDA users <irda-users@lists.sourceforge.net>,
	Jean Tourrilhes <jt@hpl.hp.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw-ext11.nokia.com ([131.228.20.170]:62867 "EHLO
	mgw-ext11.nokia.com") by vger.kernel.org with ESMTP id S965136AbWDNK3q
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 06:29:46 -0400
To: "ext David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

In the STIR421x case, when the firmware upload fails, we need to unregister_netdev. Otherwise we hit a BUG on free_netdev(), if sysfs is enabled.
 
Signed-off-by: Samuel Ortiz <samuel.ortiz@nokia.com>

diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 606243d..96bdb73 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -1815,14 +1815,14 @@ static int irda_usb_probe(struct usb_int
 		self->needspatch = (ret < 0);
 		if (ret < 0) {
 			printk("patch_device failed\n");
-			goto err_out_4;
+			goto err_out_5;
 		}
 
 		/* replace IrDA class descriptor with what patched device is now reporting */
 		irda_desc = irda_usb_find_class_desc (self->usbintf);
 		if (irda_desc == NULL) {
 			ret = -ENODEV;
-			goto err_out_4;
+			goto err_out_5;
 		}
 		if (self->irda_desc)
 			kfree (self->irda_desc);
@@ -1832,6 +1832,8 @@ static int irda_usb_probe(struct usb_int
 
 	return 0;
 
+err_out_5:
+	unregister_netdev(self->netdev);
 err_out_4:
 	kfree(self->speed_buff);
 err_out_3:
