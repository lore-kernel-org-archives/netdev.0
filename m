From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v3 5/5] usbnet: runtime wake up device before calling usbnet_{read|write}_cmd
Date: Tue,  6 Nov 2012 09:45:41 +0800
Message-ID: <1352166341-27616-6-git-send-email-ming.lei@canonical.com>
References: <1352166341-27616-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:52748 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932947Ab2KFBqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 20:46:43 -0500
In-Reply-To: <1352166341-27616-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch gets the runtime PM reference count before calling
usbnet_{read|write}_cmd, and puts it after completion of the
usbnet_{read|write}_cmd, so that the usb control message can always
be sent to one active device in the non-PM context.

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/usbnet.c |   20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index a7fb074..08c4759 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1673,8 +1673,14 @@ out:
 int usbnet_read_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
 		    u16 value, u16 index, void *data, u16 size)
 {
-	return __usbnet_read_cmd(dev, cmd, reqtype, value, index,
-				 data, size);
+	int ret;
+
+	if (usb_autopm_get_interface(dev->intf) < 0)
+		return -ENODEV;
+	ret = __usbnet_read_cmd(dev, cmd, reqtype, value, index,
+				data, size);
+	usb_autopm_put_interface(dev->intf);
+	return ret;
 }
 EXPORT_SYMBOL_GPL(usbnet_read_cmd);
 
@@ -1685,8 +1691,14 @@ EXPORT_SYMBOL_GPL(usbnet_read_cmd);
 int usbnet_write_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
 		     u16 value, u16 index, const void *data, u16 size)
 {
-	return __usbnet_write_cmd(dev, cmd, reqtype, value, index,
-				  data, size);
+	int ret;
+
+	if (usb_autopm_get_interface(dev->intf) < 0)
+		return -ENODEV;
+	ret = __usbnet_write_cmd(dev, cmd, reqtype, value, index,
+				 data, size);
+	usb_autopm_put_interface(dev->intf);
+	return ret;
 }
 EXPORT_SYMBOL_GPL(usbnet_write_cmd);
 
-- 
1.7.9.5
