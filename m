From: Pete Zaitcev <zaitcev@redhat.com>
Subject: p54usb: Don't run DMA off code segment
Date: Mon, 16 Jul 2007 23:10:51 -0700
Message-ID: <20070716231051.0971d9c0.zaitcev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: zaitcev@redhat.com, netdev@vger.kernel.org, cebbert@redhat.com,
	linville@redhat.com
To: flamingice@sourmilk.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41807 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751858AbXGQGJl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2007 02:09:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Passing a pointer into the code segment to DMA API is invalid. Most of the
time, you just DMA garbage into the device, but sometimes the controller
gets a bad address and then you see this:

usbcore: registered new interface driver prism54usb
usb 3-1: new full speed USB device using uhci_hcd and address 2
usb 3-1: not running at top speed; connect to a high speed hub
usb 3-1: configuration #1 chosen from 1 choice
uhci_hcd 0000:00:1d.2: host system error, PCI problems?
uhci_hcd 0000:00:1d.2: host controller halted, very bad!
uhci_hcd 0000:00:1d.2: HC died; cleaning up
p54usb: reset failed!
prism54usb: probe of 3-1:1.0 failed with error -110

See:
 https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=242638

Signed-off-by: Pete Zaitcev <zaitcev@redhat.com>

--- linux-2.6.23-0.15.rc0.git1.fc8/drivers/net/wireless/mac80211/p54/prism54usb.c	2007-07-16 20:16:00.000000000 -0700
+++ linux-2.6.23-0.15.rc0.git1.fc8-p54u/drivers/net/wireless/mac80211/p54/prism54usb.c	2007-07-16 22:07:33.000000000 -0700
@@ -375,22 +375,23 @@ static int p54u_upload_firmware_3887(str
 	struct x2_header *hdr;
 	unsigned long timeout;
 
-	err = p54u_bulk_msg(priv, P54U_PIPE_DATA, start_string, 4);
-	if (err) {
-		printk(KERN_ERR "p54usb: reset failed!\n");
-		return err;
-	}
-
 	tmp = buf = kmalloc(P54U_FW_BLOCK, GFP_KERNEL);
 	if (!buf) {
 		printk(KERN_ERR "p54usb: cannot allocate firmware upload buffer!\n");
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto err_bufalloc;
+	}
+
+	memcpy(buf, start_string, 4);
+	if ((err = p54u_bulk_msg(priv, P54U_PIPE_DATA, buf, 4)) != 0) {
+		printk(KERN_ERR "p54usb: reset failed! (%d)\n", err);
+		goto err_reset;
 	}
 
 	err = request_firmware(&fw_entry, "isl3887usb_bare", &priv->udev->dev);
 	if (err) {
 		printk(KERN_ERR "p54usb: cannot find firmware (isl3887usb_bare)!\n");
-		return err;
+		goto err_req_fw_failed;
 	}
 
 	p54_parse_firmware(dev, fw_entry);
@@ -499,7 +500,10 @@ static int p54u_upload_firmware_3887(str
 
   err_upload_failed:
 	release_firmware(fw_entry);
+  err_req_fw_failed:
+  err_reset:
 	kfree(buf);
+  err_bufalloc:
 	return err;
 }
 
