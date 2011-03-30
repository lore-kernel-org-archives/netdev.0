From: Simon Wood <simon-wM4F9T/ekXmXDw4h08c5KA@public.gmane.org>
Subject: [PATCH] pl25a1_support
Date: Tue, 29 Mar 2011 21:44:27 -0600
Message-ID: <1301456667-1648-1-git-send-email-simon@mungewell.org>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>,
	Simon Wood <simon-wM4F9T/ekXmXDw4h08c5KA@public.gmane.org>
To: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Adds support for 'Windows Easy Transfer' cables based around the
Prolific PL-25A1 chip (includes Belkin F5U258 & F5U279)

Patch originally suggested by David Brownell here:
http://www.mail-archive.com/netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg61926.html

Modified to work with latest kernel, tested with F5U279.

Signed-off-by: Simon Wood <simon-wM4F9T/ekXmXDw4h08c5KA@public.gmane.org>
---
 drivers/net/usb/Kconfig |    2 +-
 drivers/net/usb/plusb.c |   33 ++++++++++++++++++++++++++-------
 2 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 6f600cc..85fec06 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -258,7 +258,7 @@ config USB_NET_NET1080
 	  optionally with LEDs that indicate traffic
 
 config USB_NET_PLUSB
-	tristate "Prolific PL-2301/2302 based cables"
+	tristate "Prolific PL-2301/2302/25A1 based cables"
 	# if the handshake/init/reset problems, from original 'plusb',
 	# are ever resolved ... then remove "experimental"
 	depends on USB_USBNET && EXPERIMENTAL
diff --git a/drivers/net/usb/plusb.c b/drivers/net/usb/plusb.c
index 08ad269..a20afac 100644
--- a/drivers/net/usb/plusb.c
+++ b/drivers/net/usb/plusb.c
@@ -45,6 +45,14 @@
  * seems to get wedged under load.  Prolific docs are weak, and
  * don't identify differences between PL2301 and PL2302, much less
  * anything to explain the different PL2302 versions observed.
+ *
+ * NOTE:  pl2501 has several modes, including pl2301 and pl2302
+ * compatibility.   Some docs suggest the difference between 2301
+ * and 2302 is only to make MS-Windows use a different driver...
+ *
+ * pl25a1 glue based on patch from Tony Gibbs.  Prolific "docs" on
+ * this chip are as usual incomplete about what control messages
+ * are supported.
  */
 
 /*
@@ -89,13 +97,17 @@ static int pl_reset(struct usbnet *dev)
 	/* some units seem to need this reset, others reject it utterly.
 	 * FIXME be more like "naplink" or windows drivers.
 	 */
-	(void) pl_set_QuickLink_features(dev,
+	int     status;
+
+        status = pl_set_QuickLink_features(dev,
 		PL_S_EN|PL_RESET_OUT|PL_RESET_IN|PL_PEER_E);
+	if (status != 0 && netif_msg_probe(dev))
+		netif_dbg(dev, link, dev->net, "pl_reset --> %d\n", status);
 	return 0;
 }
 
 static const struct driver_info	prolific_info = {
-	.description =	"Prolific PL-2301/PL-2302",
+	.description =  "Prolific PL-2301/PL-2302/PL-25A1",
 	.flags =	FLAG_NO_SETINT,
 		/* some PL-2302 versions seem to fail usb_set_interface() */
 	.reset =	pl_reset,
@@ -110,7 +122,7 @@ static const struct driver_info	prolific_info = {
  */
 
 static const struct usb_device_id	products [] = {
-
+/* full speed cables */
 {
 	USB_DEVICE(0x067b, 0x0000),	// PL-2301
 	.driver_info =	(unsigned long) &prolific_info,
@@ -118,7 +130,14 @@ static const struct usb_device_id	products [] = {
 	USB_DEVICE(0x067b, 0x0001),	// PL-2302
 	.driver_info =	(unsigned long) &prolific_info,
 },
-
+/* high speed cables */
+{
+	USB_DEVICE(0x067b, 0x25a1),     /* PL-25A1, no eeprom */
+	.driver_info =  (unsigned long) &prolific_info,
+}, {
+	USB_DEVICE(0x050d, 0x258a),     /* Belkin F5U258/F5U279 (PL-25A1) */
+	.driver_info =  (unsigned long) &prolific_info,
+},
 	{ },		// END
 };
 MODULE_DEVICE_TABLE(usb, products);
@@ -134,16 +153,16 @@ static struct usb_driver plusb_driver = {
 
 static int __init plusb_init(void)
 {
- 	return usb_register(&plusb_driver);
+	return usb_register(&plusb_driver);
 }
 module_init(plusb_init);
 
 static void __exit plusb_exit(void)
 {
- 	usb_deregister(&plusb_driver);
+	usb_deregister(&plusb_driver);
 }
 module_exit(plusb_exit);
 
 MODULE_AUTHOR("David Brownell");
-MODULE_DESCRIPTION("Prolific PL-2301/2302 USB Host to Host Link Driver");
+MODULE_DESCRIPTION("Prolific PL-2301/2302/25A1 USB Host to Host Link Driver");
 MODULE_LICENSE("GPL");
-- 
1.7.0.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
