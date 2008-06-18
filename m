From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH net-next] rndis_host: pass buffer length to rndis_command
Date: Wed, 18 Jun 2008 15:40:12 +0300
Message-ID: <20080618124011.11920.98218.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dbrownell@users.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:47789 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbYFRMkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 08:40:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass buffer length to rndis_command so that rndis_command can read full
response buffer from device instead of max CONTROL_BUFFER_SIZE bytes.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 drivers/net/usb/rndis_host.c      |   14 +++++++-------
 drivers/net/wireless/rndis_wlan.c |    4 ++--
 include/linux/usb/rndis_host.h    |    3 ++-
 3 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index ae467f1..61c98be 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -74,7 +74,7 @@ EXPORT_SYMBOL_GPL(rndis_status);
  * Call context is likely probe(), before interface name is known,
  * which is why we won't try to use it in the diagnostics.
  */
-int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf)
+int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf, int buflen)
 {
 	struct cdc_state	*info = (void *) &dev->data;
 	int			master_ifnum;
@@ -121,7 +121,7 @@ int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf)
 			USB_CDC_GET_ENCAPSULATED_RESPONSE,
 			USB_DIR_IN | USB_TYPE_CLASS | USB_RECIP_INTERFACE,
 			0, master_ifnum,
-			buf, CONTROL_BUFFER_SIZE,
+			buf, buflen,
 			RNDIS_CONTROL_TIMEOUT_MS);
 		if (likely(retval >= 8)) {
 			msg_len = le32_to_cpu(buf->msg_len);
@@ -239,7 +239,7 @@ static int rndis_query(struct usbnet *dev, struct usb_interface *intf,
 	u.get->len = cpu_to_le32(in_len);
 	u.get->offset = ccpu2(20);
 
-	retval = rndis_command(dev, u.header);
+	retval = rndis_command(dev, u.header, CONTROL_BUFFER_SIZE);
 	if (unlikely(retval < 0)) {
 		dev_err(&intf->dev, "RNDIS_MSG_QUERY(0x%08x) failed, %d\n",
 				oid, retval);
@@ -328,7 +328,7 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 	u.init->max_transfer_size = cpu_to_le32(dev->rx_urb_size);
 
 	net->change_mtu = NULL;
-	retval = rndis_command(dev, u.header);
+	retval = rndis_command(dev, u.header, CONTROL_BUFFER_SIZE);
 	if (unlikely(retval < 0)) {
 		/* it might not even be an RNDIS device!! */
 		dev_err(&intf->dev, "RNDIS init failed, %d\n", retval);
@@ -409,7 +409,7 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 	u.set->offset = ccpu2((sizeof *u.set) - 8);
 	*(__le32 *)(u.buf + sizeof *u.set) = RNDIS_DEFAULT_FILTER;
 
-	retval = rndis_command(dev, u.header);
+	retval = rndis_command(dev, u.header, CONTROL_BUFFER_SIZE);
 	if (unlikely(retval < 0)) {
 		dev_err(&intf->dev, "rndis set packet filter, %d\n", retval);
 		goto halt_fail_and_release;
@@ -424,7 +424,7 @@ halt_fail_and_release:
 	memset(u.halt, 0, sizeof *u.halt);
 	u.halt->msg_type = RNDIS_MSG_HALT;
 	u.halt->msg_len = ccpu2(sizeof *u.halt);
-	(void) rndis_command(dev, (void *)u.halt);
+	(void) rndis_command(dev, (void *)u.halt, CONTROL_BUFFER_SIZE);
 fail_and_release:
 	usb_set_intfdata(info->data, NULL);
 	usb_driver_release_interface(driver_of(intf), info->data);
@@ -449,7 +449,7 @@ void rndis_unbind(struct usbnet *dev, struct usb_interface *intf)
 	if (halt) {
 		halt->msg_type = RNDIS_MSG_HALT;
 		halt->msg_len = ccpu2(sizeof *halt);
-		(void) rndis_command(dev, (void *)halt);
+		(void) rndis_command(dev, (void *)halt, CONTROL_BUFFER_SIZE);
 		kfree(halt);
 	}
 
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index a36d2c8..f001f2a 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -448,7 +448,7 @@ static int rndis_query_oid(struct usbnet *dev, __le32 oid, void *data, int *len)
 	u.get->msg_len = ccpu2(sizeof *u.get);
 	u.get->oid = oid;
 
-	ret = rndis_command(dev, u.header);
+	ret = rndis_command(dev, u.header, buflen);
 	if (ret == 0) {
 		ret = le32_to_cpu(u.get_c->len);
 		*len = (*len > ret) ? ret : *len;
@@ -498,7 +498,7 @@ static int rndis_set_oid(struct usbnet *dev, __le32 oid, void *data, int len)
 	u.set->handle = ccpu2(0);
 	memcpy(u.buf + sizeof(*u.set), data, len);
 
-	ret = rndis_command(dev, u.header);
+	ret = rndis_command(dev, u.header, buflen);
 	if (ret == 0)
 		ret = rndis_error_status(u.set_c->status);
 
diff --git a/include/linux/usb/rndis_host.h b/include/linux/usb/rndis_host.h
index 29d6458..0a6e6d4 100644
--- a/include/linux/usb/rndis_host.h
+++ b/include/linux/usb/rndis_host.h
@@ -260,7 +260,8 @@ struct rndis_keepalive_c {	/* IN (optionally OUT) */
 
 
 extern void rndis_status(struct usbnet *dev, struct urb *urb);
-extern int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf);
+extern int
+rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf, int buflen);
 extern int
 generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags);
 extern void rndis_unbind(struct usbnet *dev, struct usb_interface *intf);

