From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH ISDN] Add check for usb_alloc_urb() result
Date: Fri, 13 Jul 2012 10:59:46 +0200
Message-ID: <1342169986-24268-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org, rucsoftsec@gmail.com, m.bachem@gmx.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:50994 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752875Ab2GMI7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 04:59:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

usb_alloc_urb() return value needs to be checked to avoid
later NULL pointer access.
Reported by rucsoftsec@gmail.com via bugzilla.kernel.org #44601.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/hardware/mISDN/hfcsusb.c |   18 +++++++++++++-----
 drivers/isdn/hisax/hfc_usb.c          |   18 +++++++++++++-----
 2 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index c65c344..114f3bc 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -2084,13 +2084,21 @@ hfcsusb_probe(struct usb_interface *intf, const struct usb_device_id *id)
 	/* create the control pipes needed for register access */
 	hw->ctrl_in_pipe = usb_rcvctrlpipe(hw->dev, 0);
 	hw->ctrl_out_pipe = usb_sndctrlpipe(hw->dev, 0);
+
+	driver_info = (struct hfcsusb_vdata *)
+		      hfcsusb_idtab[vend_idx].driver_info;
+
 	hw->ctrl_urb = usb_alloc_urb(0, GFP_KERNEL);
+	if (!hw->ctrl_urb) {
+		pr_warn("%s: No memory for control urb\n",
+			driver_info->vend_name);
+		kfree(hw);
+		return -ENOMEM;
+	}
 
-	driver_info =
-		(struct hfcsusb_vdata *)hfcsusb_idtab[vend_idx].driver_info;
-	printk(KERN_DEBUG "%s: %s: detected \"%s\" (%s, if=%d alt=%d)\n",
-	       hw->name, __func__, driver_info->vend_name,
-	       conf_str[small_match], ifnum, alt_used);
+	pr_info("%s: %s: detected \"%s\" (%s, if=%d alt=%d)\n",
+		hw->name, __func__, driver_info->vend_name,
+		conf_str[small_match], ifnum, alt_used);
 
 	if (setup_instance(hw, dev->dev.parent))
 		return -EIO;
diff --git a/drivers/isdn/hisax/hfc_usb.c b/drivers/isdn/hisax/hfc_usb.c
index 84f9c81..849a807 100644
--- a/drivers/isdn/hisax/hfc_usb.c
+++ b/drivers/isdn/hisax/hfc_usb.c
@@ -1483,13 +1483,21 @@ hfc_usb_probe(struct usb_interface *intf, const struct usb_device_id *id)
 				usb_rcvctrlpipe(context->dev, 0);
 			context->ctrl_out_pipe =
 				usb_sndctrlpipe(context->dev, 0);
+
+			driver_info = (hfcsusb_vdata *)
+				      hfcusb_idtab[vend_idx].driver_info;
+
 			context->ctrl_urb = usb_alloc_urb(0, GFP_KERNEL);
 
-			driver_info =
-				(hfcsusb_vdata *) hfcusb_idtab[vend_idx].
-				driver_info;
-			printk(KERN_INFO "HFC-S USB: detected \"%s\"\n",
-			       driver_info->vend_name);
+			if (!context->ctrl_urb) {
+				pr_warn("%s: No memory for control urb\n",
+					driver_info->vend_name);
+				kfree(context);
+				return -ENOMEM;
+			}
+
+			pr_info("HFC-S USB: detected \"%s\"\n",
+				driver_info->vend_name);
 
 			DBG(HFCUSB_DBG_INIT,
 			    "HFC-S USB: Endpoint-Config: %s (if=%d alt=%d), E-Channel(%d)",
-- 
1.7.7
