From: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
Subject: [PATCH] Fix stack corruption on some architectures
Date: Mon, 19 Aug 2013 13:37:27 -0700
Message-ID: <1376944647.5082.12.camel@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jan Dumon <j.dumon@option.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:59426 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131Ab3HSUhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 16:37:31 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so4737786pdi.27
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 13:37:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to get an interface specification if we know it's the
wrong one; trivial change. The big thing, though, was explained in the
#mipslinux IRC channel: 
[Mon 2013-08-19 12:28:21 PM PDT] <headless> guys, are you sure it's not "DMA off stack" case?
[Mon 2013-08-19 12:28:35 PM PDT] <headless> it's a known stack corruptor on non-coherent arches
[Mon 2013-08-19 12:31:48 PM PDT] <DonkeyHotei> headless: for usb/ehci?
[Mon 2013-08-19 12:34:11 PM PDT] <DonkeyHotei> headless: explain
[Mon 2013-08-19 12:35:38 PM PDT] <headless> usb_control_msg() (or other such func) should not use buffer on stack. DMA from/to stack is prohibited
[Mon 2013-08-19 12:35:58 PM PDT] <headless> and EHCI uses DMA on control xfers (as well as all the others)

Signed-off-by: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
---
 drivers/net/usb/hso.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index cba1d46..86292e6 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2816,13 +2816,16 @@ exit:
 static int hso_get_config_data(struct usb_interface *interface)
 {
 	struct usb_device *usbdev = interface_to_usbdev(interface);
-	u8 config_data[17];
+	u8 *config_data = kmalloc(17, GFP_KERNEL);
 	u32 if_num = interface->altsetting->desc.bInterfaceNumber;
 	s32 result;
 
+	if (!config_data)
+		return -ENOMEM;
 	if (usb_control_msg(usbdev, usb_rcvctrlpipe(usbdev, 0),
 			    0x86, 0xC0, 0, 0, config_data, 17,
 			    USB_CTRL_SET_TIMEOUT) != 0x11) {
+		kfree(config_data);
 		return -EIO;
 	}
 
@@ -2873,6 +2876,7 @@ static int hso_get_config_data(struct usb_interface *interface)
 	if (config_data[16] & 0x1)
 		result |= HSO_INFO_CRC_BUG;
 
+	kfree(config_data);
 	return result;
 }
 
@@ -2886,6 +2890,11 @@ static int hso_probe(struct usb_interface *interface,
 	struct hso_shared_int *shared_int;
 	struct hso_device *tmp_dev = NULL;
 
+	if (interface->cur_altsetting->desc.bInterfaceClass != 0xFF) {
+		dev_err(&interface->dev, "Not our interface\n");
+		return -ENODEV;
+	}
+
 	if_num = interface->altsetting->desc.bInterfaceNumber;
 
 	/* Get the interface/port specification from either driver_info or from
@@ -2895,10 +2904,6 @@ static int hso_probe(struct usb_interface *interface,
 	else
 		port_spec = hso_get_config_data(interface);
 
-	if (interface->cur_altsetting->desc.bInterfaceClass != 0xFF) {
-		dev_err(&interface->dev, "Not our interface\n");
-		return -ENODEV;
-	}
 	/* Check if we need to switch to alt interfaces prior to port
 	 * configuration */
 	if (interface->num_altsetting > 1)
-- 
1.7.9.5
