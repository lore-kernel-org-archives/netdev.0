From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH v2 1/5] usbnet: introduce usbnet_read[write]_cmd_nopm
Date: Sun,  4 Nov 2012 19:16:29 +0800
Message-ID: <1352027793-6608-2-git-send-email-ming.lei@canonical.com>
References: <1352027793-6608-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1352027793-6608-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch introduces the below two helpers to prepare for solving
the usbnet runtime PM problem, which may cause some network utilities
(ifconfig, ethtool,...) touch a suspended device.

	usbnet_read_cmd_nopm()
	usbnet_write_cmd_nopm()

The above two helpers should be called by usbnet resume/suspend
callback to avoid deadlock.

Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/usbnet.c   |   62 ++++++++++++++++++++++++++++++++++++++++----
 include/linux/usb/usbnet.h |    4 +++
 2 files changed, 61 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 09ea47a..a7fb074 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1614,8 +1614,8 @@ void usbnet_device_suggests_idle(struct usbnet *dev)
 EXPORT_SYMBOL(usbnet_device_suggests_idle);
 
 /*-------------------------------------------------------------------------*/
-int usbnet_read_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
-		    u16 value, u16 index, void *data, u16 size)
+static int __usbnet_read_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
+			     u16 value, u16 index, void *data, u16 size)
 {
 	void *buf = NULL;
 	int err = -ENOMEM;
@@ -1639,10 +1639,10 @@ int usbnet_read_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
 out:
 	return err;
 }
-EXPORT_SYMBOL_GPL(usbnet_read_cmd);
 
-int usbnet_write_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
-		     u16 value, u16 index, const void *data, u16 size)
+static int __usbnet_write_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
+			      u16 value, u16 index, const void *data,
+			      u16 size)
 {
 	void *buf = NULL;
 	int err = -ENOMEM;
@@ -1665,8 +1665,56 @@ int usbnet_write_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
 out:
 	return err;
 }
+
+/*
+ * The function can't be called inside suspend/resume callback,
+ * otherwise deadlock will be caused.
+ */
+int usbnet_read_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
+		    u16 value, u16 index, void *data, u16 size)
+{
+	return __usbnet_read_cmd(dev, cmd, reqtype, value, index,
+				 data, size);
+}
+EXPORT_SYMBOL_GPL(usbnet_read_cmd);
+
+/*
+ * The function can't be called inside suspend/resume callback,
+ * otherwise deadlock will be caused.
+ */
+int usbnet_write_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
+		     u16 value, u16 index, const void *data, u16 size)
+{
+	return __usbnet_write_cmd(dev, cmd, reqtype, value, index,
+				  data, size);
+}
 EXPORT_SYMBOL_GPL(usbnet_write_cmd);
 
+/*
+ * The function can be called inside suspend/resume callback safely
+ * and should only be called by suspend/resume callback generally.
+ */
+int usbnet_read_cmd_nopm(struct usbnet *dev, u8 cmd, u8 reqtype,
+			  u16 value, u16 index, void *data, u16 size)
+{
+	return __usbnet_read_cmd(dev, cmd, reqtype, value, index,
+				 data, size);
+}
+EXPORT_SYMBOL_GPL(usbnet_read_cmd_nopm);
+
+/*
+ * The function can be called inside suspend/resume callback safely
+ * and should only be called by suspend/resume callback generally.
+ */
+int usbnet_write_cmd_nopm(struct usbnet *dev, u8 cmd, u8 reqtype,
+			  u16 value, u16 index, const void *data,
+			  u16 size)
+{
+	return __usbnet_write_cmd(dev, cmd, reqtype, value, index,
+				  data, size);
+}
+EXPORT_SYMBOL_GPL(usbnet_write_cmd_nopm);
+
 static void usbnet_async_cmd_cb(struct urb *urb)
 {
 	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
@@ -1680,6 +1728,10 @@ static void usbnet_async_cmd_cb(struct urb *urb)
 	usb_free_urb(urb);
 }
 
+/*
+ * The caller must make sure that device can't be put into suspend
+ * state until the control URB completes.
+ */
 int usbnet_write_cmd_async(struct usbnet *dev, u8 cmd, u8 reqtype,
 			   u16 value, u16 index, const void *data, u16 size)
 {
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 4410e416..9bbeabf 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -167,6 +167,10 @@ extern int usbnet_read_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
 		    u16 value, u16 index, void *data, u16 size);
 extern int usbnet_write_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
 		    u16 value, u16 index, const void *data, u16 size);
+extern int usbnet_read_cmd_nopm(struct usbnet *dev, u8 cmd, u8 reqtype,
+		    u16 value, u16 index, void *data, u16 size);
+extern int usbnet_write_cmd_nopm(struct usbnet *dev, u8 cmd, u8 reqtype,
+		    u16 value, u16 index, const void *data, u16 size);
 extern int usbnet_write_cmd_async(struct usbnet *dev, u8 cmd, u8 reqtype,
 		    u16 value, u16 index, const void *data, u16 size);
 
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
