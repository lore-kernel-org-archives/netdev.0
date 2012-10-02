From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 09/12] usbnet: sierra_net: apply introduced usb command APIs
Date: Tue,  2 Oct 2012 14:51:20 +0800
Message-ID: <1349160684-6627-10-git-send-email-ming.lei@canonical.com>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:41250 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233Ab2JBGwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 02:52:35 -0400
In-Reply-To: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/sierra_net.c |   45 ++++++++++++++++--------------------------
 1 file changed, 17 insertions(+), 28 deletions(-)

diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index c27d277..eb5c7a8 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -311,10 +311,9 @@ static int sierra_net_send_cmd(struct usbnet *dev,
 	struct sierra_net_data *priv = sierra_net_get_private(dev);
 	int  status;
 
-	status = usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
-			USB_CDC_SEND_ENCAPSULATED_COMMAND,
-			USB_DIR_OUT|USB_TYPE_CLASS|USB_RECIP_INTERFACE,	0,
-			priv->ifnum, cmd, cmdlen, USB_CTRL_SET_TIMEOUT);
+	status = usbnet_write_cmd(dev, USB_CDC_SEND_ENCAPSULATED_COMMAND,
+				  USB_DIR_OUT|USB_TYPE_CLASS|USB_RECIP_INTERFACE,
+				  0, priv->ifnum, cmd, cmdlen);
 
 	if (status != cmdlen && status != -ENODEV)
 		netdev_err(dev->net, "Submit %s failed %d\n", cmd_name, status);
@@ -632,32 +631,22 @@ static int sierra_net_change_mtu(struct net_device *net, int new_mtu)
 static int sierra_net_get_fw_attr(struct usbnet *dev, u16 *datap)
 {
 	int result = 0;
-	u16 *attrdata;
-
-	attrdata = kmalloc(sizeof(*attrdata), GFP_KERNEL);
-	if (!attrdata)
-		return -ENOMEM;
-
-	result = usb_control_msg(
-			dev->udev,
-			usb_rcvctrlpipe(dev->udev, 0),
-			/* _u8 vendor specific request */
-			SWI_USB_REQUEST_GET_FW_ATTR,
-			USB_DIR_IN | USB_TYPE_VENDOR,	/* __u8 request type */
-			0x0000,		/* __u16 value not used */
-			0x0000,		/* __u16 index  not used */
-			attrdata,	/* char *data */
-			sizeof(*attrdata),		/* __u16 size */
-			USB_CTRL_SET_TIMEOUT);	/* int timeout */
-
-	if (result < 0) {
-		kfree(attrdata);
+	u16 attrdata;
+
+	result = usbnet_read_cmd(dev,
+				/* _u8 vendor specific request */
+				SWI_USB_REQUEST_GET_FW_ATTR,
+				USB_DIR_IN | USB_TYPE_VENDOR,	/* __u8 request type */
+				0x0000,		/* __u16 value not used */
+				0x0000,		/* __u16 index  not used */
+				&attrdata,	/* char *data */
+				sizeof(attrdata)	/* __u16 size */
+				);
+
+	if (result < 0)
 		return -EIO;
-	}
-
-	*datap = le16_to_cpu(*attrdata);
 
-	kfree(attrdata);
+	*datap = le16_to_cpu(attrdata);
 	return result;
 }
 
-- 
1.7.9.5
