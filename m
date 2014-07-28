From: Oliver Neukum <oneukum@suse.de>
Subject: [PATCH] cdc-ether: clean packet filter upon probe
Date: Mon, 28 Jul 2014 10:56:36 +0200
Message-ID: <1406537796-20156-1-git-send-email-oneukum@suse.de>
Cc: Oliver Neukum <oneukum@suse.de>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47973 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751394AbaG1I4k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2014 04:56:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are devices that don't do reset all the way. So the packet filter should
be set to a sane initial value. Failure to do so leads to intermittent failures
of DHCP on some systems under some conditions.

Signed-off-by: Oliver Neukum <oneukum@suse.de>
---
 drivers/net/usb/cdc_ether.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 9ea4bfe..2a32d91 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -341,6 +341,22 @@ next_desc:
 		usb_driver_release_interface(driver, info->data);
 		return -ENODEV;
 	}
+
+	/* Some devices don't initialise properly. In particular
+	 * the packet filter is not reset. There are devices that
+	 * don't do reset all the way. So the packet filter should
+	 * be set to a sane initial value.
+	 */
+	usb_control_msg(dev->udev,
+			usb_sndctrlpipe(dev->udev, 0),
+			USB_CDC_SET_ETHERNET_PACKET_FILTER,
+			USB_TYPE_CLASS | USB_RECIP_INTERFACE,
+			USB_CDC_PACKET_TYPE_ALL_MULTICAST | USB_CDC_PACKET_TYPE_DIRECTED | USB_CDC_PACKET_TYPE_BROADCAST,
+			intf->cur_altsetting->desc.bInterfaceNumber,
+			NULL,
+			0,
+			USB_CTRL_SET_TIMEOUT
+		);
 	return 0;
 
 bad_desc:
-- 
1.8.4.5
