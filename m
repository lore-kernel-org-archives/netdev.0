From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 12/12] usbnet: make device out of suspend before calling usbnet_read/write_cmd
Date: Tue,  2 Oct 2012 14:51:23 +0800
Message-ID: <1349160684-6627-13-git-send-email-ming.lei@canonical.com>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:39032 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754397Ab2JBGw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 02:52:59 -0400
In-Reply-To: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patche gets the runtime PM reference count before calling
usb_control_msg, and puts it after completion of the
usb_control_msg, so that the usb control message can always be
sent to one active device.

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/usbnet.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 3b51554..3f4bc69 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1609,9 +1609,11 @@ int usbnet_read_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
 			goto out;
 	}
 
+	usb_autopm_get_interface(dev->intf);
 	err = usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
 			      cmd, reqtype, value, index, buf, size,
 			      USB_CTRL_GET_TIMEOUT);
+	usb_autopm_put_interface(dev->intf);
 	if (err > 0 && err <= size)
 		memcpy(data, buf, err);
 	kfree(buf);
@@ -1636,9 +1638,11 @@ int usbnet_write_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
 			goto out;
 	}
 
+	usb_autopm_get_interface(dev->intf);
 	err = usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
 			      cmd, reqtype, value, index, buf, size,
 			      USB_CTRL_SET_TIMEOUT);
+	usb_autopm_put_interface(dev->intf);
 	kfree(buf);
 
 out:
-- 
1.7.9.5
