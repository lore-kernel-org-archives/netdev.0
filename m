From: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Subject: [PATCH] bas_gigaset: fix pre_reset handling
Date: Wed, 24 Oct 2012 20:44:32 +0200
Message-ID: <20121024-patch-gigaset-01.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, gigaset307x-common-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hansjoerg Lipp <hjlipp-S0/GAf8tV78@public.gmane.org>,
        i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
To: Karsten Keil <isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Unsubscribe: <https://www.isdn4linux.de/mailman/options/i4ldeveloper>,
 <mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.isdn4linux.de/pipermail/i4ldeveloper/>
List-Post: <mailto:i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Help: <mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=help>
List-Subscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
 <mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=subscribe>
Errors-To: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
Sender: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
List-Id: netdev.vger.kernel.org

The delayed work function int_in_work() may call usb_reset_device()
and thus, indirectly, the driver's pre_reset method. Trying to
cancel the work synchronously in that situation would deadlock.
Fix by avoiding cancel_work_sync() in the pre_reset method.

If the reset was NOT initiated by int_in_work() this might cause
int_in_work() to run after the post_reset method, with urb_int_in
already resubmitted, so handle that case gracefully.

Signed-off-by: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
---
 drivers/isdn/gigaset/bas-gigaset.c |   19 ++++++++++++++++---
 1 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 5275887..c44950d 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -617,7 +617,13 @@ static void int_in_work(struct work_struct *work)
 	if (rc == 0)
 		/* success, resubmit interrupt read URB */
 		rc = usb_submit_urb(urb, GFP_ATOMIC);
-	if (rc != 0 && rc != -ENODEV) {
+
+	switch (rc) {
+	case 0:		/* success */
+	case -ENODEV:	/* device gone */
+	case -EINVAL:	/* URB already resubmitted, or terminal badness */
+		break;
+	default:	/* failure: try to recover by resetting the device */
 		dev_err(cs->dev, "clear halt failed: %s\n", get_usb_rcmsg(rc));
 		rc = usb_lock_device_for_reset(ucs->udev, ucs->interface);
 		if (rc == 0) {
@@ -2442,7 +2448,9 @@ static void gigaset_disconnect(struct usb_interface *interface)
 }
 
 /* gigaset_suspend
- * This function is called before the USB connection is suspended.
+ * This function is called before the USB connection is suspended
+ * or before the USB device is reset.
+ * In the latter case, message == PMSG_ON.
  */
 static int gigaset_suspend(struct usb_interface *intf, pm_message_t message)
 {
@@ -2498,7 +2506,12 @@ static int gigaset_suspend(struct usb_interface *intf, pm_message_t message)
 	del_timer_sync(&ucs->timer_atrdy);
 	del_timer_sync(&ucs->timer_cmd_in);
 	del_timer_sync(&ucs->timer_int_in);
-	cancel_work_sync(&ucs->int_in_wq);
+
+	/* don't try to cancel int_in_wq from within reset as it
+	 * might be the one requesting the reset
+	 */
+	if (message.event != PM_EVENT_ON)
+		cancel_work_sync(&ucs->int_in_wq);
 
 	gig_dbg(DEBUG_SUSPEND, "suspend complete");
 	return 0;
-- 
1.7.3.4
