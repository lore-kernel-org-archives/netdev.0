From: Oliver Neukum <oneukum@suse.com>
Subject: [PATCH] cdc-acm: fix NULL pointer reference
Date: Thu,  7 Jan 2016 11:01:00 +0100
Message-ID: <1452160860-2752-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: davem@davemloft.net, netdev@vger.kernel.org, galkin-vv@yandex.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47590 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752806AbcAGKDN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2016 05:03:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The union descriptor must be checked. Its usage was conditional
before the parser was introduced. This is important, because
many RNDIS device, which also use the common parser, have
bogus extra descriptors.

Signed-off-by: Oliver Neukum <oneukum@suse.com>
Tested-by: Vasily Galkin <galkin-vv@yandex.ru>
---
 drivers/net/usb/cdc_ether.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 3da70bf..7cba2c3 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -160,6 +160,12 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 	info->u = header.usb_cdc_union_desc;
 	info->header = header.usb_cdc_header_desc;
 	info->ether = header.usb_cdc_ether_desc;
+	if (!info->u) {
+		if (rndis)
+			goto skip;
+		else /* in that case a quirk is mandatory */
+			goto bad_desc;
+	}
 	/* we need a master/control interface (what we're
 	 * probed with) and a slave/data interface; union
 	 * descriptors sort this all out.
@@ -256,7 +262,7 @@ skip:
 			goto bad_desc;
 		}
 
-	} else if (!info->header || !info->u || (!rndis && !info->ether)) {
+	} else if (!info->header || (!rndis && !info->ether)) {
 		dev_dbg(&intf->dev, "missing cdc %s%s%sdescriptor\n",
 			info->header ? "" : "header ",
 			info->u ? "" : "union ",
-- 
2.1.4
