From: Paul Stewart <pstew@chromium.org>
Subject: [PATCH] usbnet: Resubmit interrupt URB more often
Date: Tue, 19 Apr 2011 09:35:25 -0700
Message-ID: <20110419164703.5A6A82052B@glenhelen.mtv.corp.google.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:52306 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135Ab1DSQrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 12:47:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I previously sent a patch to resubmit the interrupt URB when
coming out of suspend.  I haven't seen much activity on the
list about it, and thought I'd send a slight variant of this
change.  This one unconditionally resubmits the interrupt urb
in usbnet_bh.  The consequences for resubmitting the URB often
are not large.  In most HCI cases this just means usb_submit_urb
returns immediately and leaves the previous request outstanding.

Doing things this way allows us to avoid keeping track of the
URB transmit status, which may change silently over suspend-
resume transitions and is not tracked in any way currently by
usbnet.

I've designed this change on two types of systems: the first
class of system leaves USB devices powered during suspend.
This might silently cause the interrupt URB to disappear (or at
least not be resubmitted in intr_complete).  Resubmission after
system resume will prevent this from causing problems.

The second class of device are those which shut down the device
during suspend.  During a suspend-resume cycle, the device is
re-enumerated at system resume, and for whatever reason
usbnet_resume may be called on the device during the call-tree
from usbnet_open-> usb_autopm_get_interface, which may cause a
race where the first change above may cause the bh to submit the
interrupt urb before usbnet_open() does.  As a result, I've added
an EALREADY check and a fix to urb.c to send one.

Signed-off-by: Paul Stewart <pstew@chromium.org>
Cc: David S. Miller <davem@davemloft.net>

---
 drivers/net/usb/usbnet.c |   12 +++++++++++-
 drivers/usb/core/urb.c   |    5 +++--
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 02d25c7..3b3c169 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -636,7 +636,10 @@ static int usbnet_open (struct net_device *net)
 	/* start any status interrupt transfer */
 	if (dev->interrupt) {
 		retval = usb_submit_urb (dev->interrupt, GFP_KERNEL);
-		if (retval < 0) {
+		if (retval == -EALREADY) {
+			// It is not an error if interrupt urb is alredy active
+			retval = 0;
+		} else if (retval < 0) {
 			if (netif_msg_ifup (dev))
 				deverr (dev, "intr submit %d", retval);
 			goto done;
@@ -1065,6 +1068,10 @@ static void usbnet_bh (unsigned long param)
 		if (dev->txq.qlen < TX_QLEN (dev))
 			netif_wake_queue (dev->net);
 	}
+
+	// Re-submit interrupt urb (doesn't hurt to retry)
+	if (netif_running (dev->net))
+		usb_submit_urb (dev->interrupt, GFP_KERNEL);
 }
 
 
@@ -1285,6 +1292,9 @@ int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
 		 * wake the device
 		 */
 		netif_device_attach (dev->net);
+		// Stop interrupt urbs while in suspend
+		if (dev->interrupt)
+			usb_kill_urb(dev->interrupt);
 	}
 	return 0;
 }
diff --git a/drivers/usb/core/urb.c b/drivers/usb/core/urb.c
index 4342bd9..e4dbb29 100644
--- a/drivers/usb/core/urb.c
+++ b/drivers/usb/core/urb.c
@@ -295,7 +295,9 @@ int usb_submit_urb(struct urb *urb, gfp_t mem_flags)
 	struct usb_host_endpoint	*ep;
 	int				is_out;
 
-	if (!urb || urb->hcpriv || !urb->complete)
+	if (urb->hcpriv)
+		return -EALREADY;
+	if (!urb || !urb->complete)
 		return -EINVAL;
 	dev = urb->dev;
 	if ((!dev) || (dev->state < USB_STATE_DEFAULT))
@@ -807,4 +809,3 @@ int usb_anchor_empty(struct usb_anchor *anchor)
 }
 
 EXPORT_SYMBOL_GPL(usb_anchor_empty);
-
-- 
1.7.3.1

