From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH v2] zd1211rw: Convert installer CDROM device into WLAN device
Date: Sun, 13 Aug 2006 12:15:29 +0100 (BST)
Message-ID: <20060813111529.6A58D8E7987@zog.reactivated.net>
Cc: kune@deine-taler.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:1250 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1750989AbWHMLP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 07:15:29 -0400
To: linville@tuxdriver.com
Cc: netdev@vger.kernel.org
Cc: mb@bu3sch.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some devices identify themselves as a virtual USB CDROM drive. The virtual CD
includes the windows driver. We aren't interested in this, so we eject the
virtual CDROM and then the real wireless device appears.

Patch fixed over the earlier version to not leak cmd, thanks to Michael Buesch
for spotting that.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -46,6 +46,8 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x079b, 0x0062), .driver_info = DEVICE_ZD1211B },
+	/* "Driverless" devices that need ejecting */
+	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{}
 };
 
@@ -914,6 +916,55 @@ static void print_id(struct usb_device *
 #define print_id(udev) do { } while (0)
 #endif
 
+static int eject_installer(struct usb_interface *intf)
+{
+	struct usb_device *udev = interface_to_usbdev(intf);
+	struct usb_host_interface *iface_desc = &intf->altsetting[0];
+	struct usb_endpoint_descriptor *endpoint;
+	unsigned char *cmd;
+	u8 bulk_out_ep;
+	int r;
+
+	/* Find bulk out endpoint */
+	endpoint = &iface_desc->endpoint[1].desc;
+	if ((endpoint->bEndpointAddress & USB_TYPE_MASK) == USB_DIR_OUT &&
+	    (endpoint->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK) ==
+	    USB_ENDPOINT_XFER_BULK) {
+		bulk_out_ep = endpoint->bEndpointAddress;
+	} else {
+		dev_err(&udev->dev,
+			"zd1211rw: Could not find bulk out endpoint\n");
+		return -ENODEV;
+	}
+
+	cmd = kzalloc(31, GFP_KERNEL);
+	if (cmd == NULL)
+		return -ENODEV;
+
+	/* USB bulk command block */
+	cmd[0] = 0x55;	/* bulk command signature */
+	cmd[1] = 0x53;	/* bulk command signature */
+	cmd[2] = 0x42;	/* bulk command signature */
+	cmd[3] = 0x43;	/* bulk command signature */
+	cmd[14] = 6;	/* command length */
+
+	cmd[15] = 0x1b;	/* SCSI command: START STOP UNIT */
+	cmd[19] = 0x2;	/* eject disc */
+
+	dev_info(&udev->dev, "Ejecting virtual installer media...\n");
+	r = usb_bulk_msg(udev, usb_sndbulkpipe(udev, bulk_out_ep),
+		cmd, 31, NULL, 2000);
+	kfree(cmd);
+	if (r)
+		return r;
+
+	/* At this point, the device disconnects and reconnects with the real
+	 * ID numbers. */
+
+	usb_set_intfdata(intf, NULL);
+	return 0;
+}
+
 static int probe(struct usb_interface *intf, const struct usb_device_id *id)
 {
 	int r;
@@ -922,6 +973,9 @@ static int probe(struct usb_interface *i
 
 	print_id(udev);
 
+	if (id->driver_info & DEVICE_INSTALLER)
+		return eject_installer(intf);
+
 	switch (udev->speed) {
 	case USB_SPEED_LOW:
 	case USB_SPEED_FULL:
@@ -987,6 +1041,11 @@ static void disconnect(struct usb_interf
 	struct zd_mac *mac = zd_netdev_mac(netdev);
 	struct zd_usb *usb = &mac->chip.usb;
 
+	/* Either something really bad happened, or we're just dealing with
+	 * a DEVICE_INSTALLER. */
+	if (netdev == NULL)
+		return;
+
 	dev_dbg_f(zd_usb_dev(usb), "\n");
 
 	zd_netdev_disconnect(netdev);
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.h
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_usb.h
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.h
@@ -30,6 +30,7 @@
 enum devicetype {
 	DEVICE_ZD1211  = 0,
 	DEVICE_ZD1211B = 1,
+	DEVICE_INSTALLER = 2,
 };
 
 enum endpoints {
