From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] plusb.c patched to support Belkin F5U258 USB host-to-host cable
Date: Sat, 16 Feb 2008 12:41:02 -0800
Message-ID: <200802161241.02468.david-b@pacbell.net>
References: <200802141557_MC3-1-FBB3-3DA7@compuserve.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: NETDEV mailing list <netdev@vger.kernel.org>,
	Linux USB mailing list <majordomo@vger.kernel.org>
To: tony_gibbs <Tony_Gibbs@compuserve.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp106.sbc.mail.mud.yahoo.com ([68.142.198.205]:21251 "HELO
	smtp106.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755939AbYBPUlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2008 15:41:08 -0500
In-Reply-To: <200802141557_MC3-1-FBB3-3DA7@compuserve.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a patch with cleanups and without various encoding bugs.
Can you verify it still works?

Also, some of the Prolific chips use some bizarre control requests,
which by all rights should not be needed.  They seem to exist only
to cope with things the device firmware should have handled ... like
resetting one end of a link after it's unplugged.

When you test this, please enable CONFIG_USB_DEBUG and let us know
if those the host software still needs to do that reset ... or at
least, whether the diagnostic appears.

- Dave

====== CUT HERE
Some plusb driver updates:  pl25a1 support (based on info from
Tony Gibbs), and various cleanups.

---
 drivers/net/usb/Kconfig |    2 -
 drivers/net/usb/plusb.c |   52 ++++++++++++++++++++++++++++++++----------------
 2 files changed, 36 insertions(+), 18 deletions(-)

--- g26.orig/drivers/net/usb/plusb.c	2008-02-16 11:49:04.000000000 -0800
+++ g26/drivers/net/usb/plusb.c	2008-02-16 12:28:54.000000000 -0800
@@ -17,9 +17,6 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-// #define	DEBUG			// error path messages, extra info
-// #define	VERBOSE			// more; success messages
-
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
@@ -45,6 +42,14 @@
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
@@ -86,16 +91,20 @@ pl_set_QuickLink_features(struct usbnet 
 
 static int pl_reset(struct usbnet *dev)
 {
+	int	status;
+
 	/* some units seem to need this reset, others reject it utterly.
 	 * FIXME be more like "naplink" or windows drivers.
 	 */
-	(void) pl_set_QuickLink_features(dev,
+	status = pl_set_QuickLink_features(dev,
 		PL_S_EN|PL_RESET_OUT|PL_RESET_IN|PL_PEER_E);
+	if (status != 0 && netif_msg_probe(dev))
+		devdbg(dev, "pl_reset --> %d\n", status);
 	return 0;
 }
 
 static const struct driver_info	prolific_info = {
-	.description =	"Prolific PL-2301/PL-2302",
+	.description =	"Prolific PL-2301/PL-2302/PL-25A1",
 	.flags =	FLAG_NO_SETINT,
 		/* some PL-2302 versions seem to fail usb_set_interface() */
 	.reset =	pl_reset,
@@ -110,16 +119,25 @@ static const struct driver_info	prolific
  */
 
 static const struct usb_device_id	products [] = {
+	/* full speed cables */
+	{
+		USB_DEVICE(0x067b, 0x0000),	/* PL-2301 */
+		.driver_info =	(unsigned long) &prolific_info,
+	}, {
+		USB_DEVICE(0x067b, 0x0001),	/* PL-2302 */
+		.driver_info =	(unsigned long) &prolific_info,
+	},
+
+	/* high speed cables */
+	{
+		USB_DEVICE(0x067b, 0x25a1),	/* PL-25A1, no eeprom */
+		.driver_info =	(unsigned long) &prolific_info,
+	}, {
+		USB_DEVICE(0x050d, 0x258a),     /* Belkin F5U258 (PL-25A1) */
+		.driver_info =	(unsigned long) &prolific_info,
+	},
 
-{
-	USB_DEVICE(0x067b, 0x0000),	// PL-2301
-	.driver_info =	(unsigned long) &prolific_info,
-}, {
-	USB_DEVICE(0x067b, 0x0001),	// PL-2302
-	.driver_info =	(unsigned long) &prolific_info,
-},
-
-	{ },		// END
+	{ },		/* END */
 };
 MODULE_DEVICE_TABLE(usb, products);
 
@@ -134,16 +152,16 @@ static struct usb_driver plusb_driver = 
 
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
--- g26.orig/drivers/net/usb/Kconfig	2008-02-16 12:23:13.000000000 -0800
+++ g26/drivers/net/usb/Kconfig	2008-02-16 12:23:39.000000000 -0800
@@ -208,7 +208,7 @@ config USB_NET_NET1080
 	  optionally with LEDs that indicate traffic
 
 config USB_NET_PLUSB
-	tristate "Prolific PL-2301/2302 based cables"
+	tristate "Prolific PL-2301/2302/25A1 based cables"
 	# if the handshake/init/reset problems, from original 'plusb',
 	# are ever resolved ... then remove "experimental"
 	depends on USB_USBNET && EXPERIMENTAL
