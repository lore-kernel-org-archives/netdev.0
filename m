From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH 4/4] usbnet: make device out of suspend before calling usbnet_read[write]_cmd
Date: Mon, 29 Oct 2012 15:45:09 +0800
Message-ID: <1351496709-26934-5-git-send-email-ming.lei@canonical.com>
References: <1351496709-26934-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1351496709-26934-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patche gets the runtime PM reference count before calling
usbnet_read[write]_cmd, and puts it after completion of the
usbnet_read[write]_cmd, so that the usb control message can always
be sent to one active device in the non-PM context.

Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/usbnet.c |   18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index a7fb074..74caa67 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1673,8 +1673,13 @@ out:
 int usbnet_read_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
 		    u16 value, u16 index, void *data, u16 size)
 {
-	return __usbnet_read_cmd(dev, cmd, reqtype, value, index,
-				 data, size);
+	int ret;
+	if (usb_autopm_get_interface(dev->intf) < 0)
+		return -ENODEV;
+	ret = __usbnet_read_cmd(dev, cmd, reqtype, value, index,
+				data, size);
+	usb_autopm_put_interface(dev->intf);
+	return ret;
 }
 EXPORT_SYMBOL_GPL(usbnet_read_cmd);
 
@@ -1685,8 +1690,13 @@ EXPORT_SYMBOL_GPL(usbnet_read_cmd);
 int usbnet_write_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
 		     u16 value, u16 index, const void *data, u16 size)
 {
-	return __usbnet_write_cmd(dev, cmd, reqtype, value, index,
-				  data, size);
+	int ret;
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

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
