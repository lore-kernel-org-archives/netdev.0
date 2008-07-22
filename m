From: David Brownell <david-b@pacbell.net>
Subject: [patch 2.6.26] rndis_host:  support WM6 devices as modems
Date: Tue, 22 Jul 2008 13:55:58 -0700
Message-ID: <200807221355.59207.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Adam Williamson <awilliamson@mandriva.com>,
	john.carr@unrouted.co.uk, Thomas Backlund <tmb@mandriva.org>
To: Network development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp116.sbc.mail.sp1.yahoo.com ([69.147.64.89]:38236 "HELO
	smtp116.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753292AbYGVU4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 16:56:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Backlund <tmb@mandriva.org>

This patch allows Windows Mobile 6 devices to be used for
tethering -- that is, used as modems.  It was requested by
AdamW in kernel bugzilla:

  http://bugzilla.kernel.org/show_bug.cgi?id=11119

and Mandriva kernel-discuss list.  It is tested and confirmed
to work by Peterl:

  http://forum.eeeuser.com/viewtopic.php?pid=323543#p323543

This patch is based on the patch in the above kernel bugzilla,
which is from the usb-rndis-lite tree.

[ dbrownell@users.sourceforge.net: misc fixes ]
Signed-off-by: Thomas Backlund <tmb@mandriva.org>
Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
---
 drivers/net/usb/cdc_ether.c  |   11 ++++++++++-
 drivers/net/usb/rndis_host.c |    4 ++++
 2 files changed, 14 insertions(+), 1 deletion(-)

--- a/drivers/net/usb/cdc_ether.c	2008-07-22 13:37:42.000000000 -0700
+++ b/drivers/net/usb/cdc_ether.c	2008-07-22 13:42:09.000000000 -0700
@@ -50,10 +50,18 @@ static int is_activesync(struct usb_inte
 		&& desc->bInterfaceProtocol == 1;
 }
 
+static int is_wireless_rndis(struct usb_interface_descriptor *desc)
+{
+	return desc->bInterfaceClass == USB_CLASS_WIRELESS_CONTROLLER
+		&& desc->bInterfaceSubClass == 1
+		&& desc->bInterfaceProtocol == 3;
+}
+
 #else
 
 #define is_rndis(desc)		0
 #define is_activesync(desc)	0
+#define is_wireless_rndis(desc)	0
 
 #endif
 
@@ -110,7 +118,8 @@ int usbnet_generic_cdc_bind(struct usbne
 	 * of cdc-acm, it'll fail RNDIS requests cleanly.
 	 */
 	rndis = is_rndis(&intf->cur_altsetting->desc)
-		|| is_activesync(&intf->cur_altsetting->desc);
+		|| is_activesync(&intf->cur_altsetting->desc)
+		|| is_wireless_rndis(&intf->cur_altsetting->desc);
 
 	memset(info, 0, sizeof *info);
 	info->control = intf;
--- a/drivers/net/usb/rndis_host.c	2008-07-22 13:37:42.000000000 -0700
+++ b/drivers/net/usb/rndis_host.c	2008-07-22 13:38:21.000000000 -0700
@@ -576,6 +576,10 @@ static const struct usb_device_id	produc
 	/* "ActiveSync" is an undocumented variant of RNDIS, used in WM5 */
 	USB_INTERFACE_INFO(USB_CLASS_MISC, 1, 1),
 	.driver_info = (unsigned long) &rndis_info,
+}, {
+	/* RNDIS for tethering */
+	USB_INTERFACE_INFO(USB_CLASS_WIRELESS_CONTROLLER, 1, 3),
+	.driver_info = (unsigned long) &rndis_info,
 },
 	{ },		// END
 };
