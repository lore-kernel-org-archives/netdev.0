From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 8/9] isdn/gigaset: fix bas_gigaset interrupt read error handling
Date: Fri,  1 Oct 2010 01:35:42 +0200 (CEST)
Message-ID: <20100930-patch-gigaset-08.tilman@imap.cc>
References: <20100930-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100930-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rework the handling of USB errors in interrupt input reads
to clear halts correctly, delay URB resubmission after errors,
limit retries, and improve error recovery.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/bas-gigaset.c |  106 +++++++++++++++++++++++++++++++-----
 1 files changed, 93 insertions(+), 13 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 540f6d0..71e3fde 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -109,6 +109,9 @@ struct bas_cardstate {
 
 	struct urb		*urb_int_in;	/* URB for interrupt pipe */
 	unsigned char		*int_in_buf;
+	struct work_struct	int_in_wq;	/* for usb_clear_halt() */
+	struct timer_list	timer_int_in;	/* int read retry delay */
+	int			retry_int_in;
 
 	spinlock_t		lock;		/* locks all following */
 	int			basstate;	/* bitmap (BS_*) */
@@ -595,6 +598,62 @@ static int atread_submit(struct cardstate *cs, int timeout)
 	return 0;
 }
 
+/* int_in_work
+ * workqueue routine to clear halt on interrupt in endpoint
+ */
+
+static void int_in_work(struct work_struct *work)
+{
+	struct bas_cardstate *ucs =
+		container_of(work, struct bas_cardstate, int_in_wq);
+	struct urb *urb = ucs->urb_int_in;
+	struct cardstate *cs = urb->context;
+	int rc;
+
+	/* clear halt condition */
+	rc = usb_clear_halt(ucs->udev, urb->pipe);
+	gig_dbg(DEBUG_USBREQ, "clear_halt: %s", get_usb_rcmsg(rc));
+	if (rc == 0)
+		/* success, resubmit interrupt read URB */
+		rc = usb_submit_urb(urb, GFP_ATOMIC);
+	if (rc != 0 && rc != -ENODEV) {
+		dev_err(cs->dev, "clear halt failed: %s\n", get_usb_rcmsg(rc));
+		rc = usb_lock_device_for_reset(ucs->udev, ucs->interface);
+		if (rc == 0) {
+			rc = usb_reset_device(ucs->udev);
+			usb_unlock_device(ucs->udev);
+		}
+	}
+	ucs->retry_int_in = 0;
+}
+
+/* int_in_resubmit
+ * timer routine for interrupt read delayed resubmit
+ * argument:
+ *	controller state structure
+ */
+static void int_in_resubmit(unsigned long data)
+{
+	struct cardstate *cs = (struct cardstate *) data;
+	struct bas_cardstate *ucs = cs->hw.bas;
+	int rc;
+
+	if (ucs->retry_int_in++ >= BAS_RETRY) {
+		dev_err(cs->dev, "interrupt read: giving up after %d tries\n",
+			ucs->retry_int_in);
+		usb_queue_reset_device(ucs->interface);
+		return;
+	}
+
+	gig_dbg(DEBUG_USBREQ, "%s: retry %d", __func__, ucs->retry_int_in);
+	rc = usb_submit_urb(ucs->urb_int_in, GFP_ATOMIC);
+	if (rc != 0 && rc != -ENODEV) {
+		dev_err(cs->dev, "could not resubmit interrupt URB: %s\n",
+			get_usb_rcmsg(rc));
+		usb_queue_reset_device(ucs->interface);
+	}
+}
+
 /* read_int_callback
  * USB completion handler for interrupt pipe input
  * called by the USB subsystem in interrupt context
@@ -615,19 +674,29 @@ static void read_int_callback(struct urb *urb)
 
 	switch (status) {
 	case 0:			/* success */
+		ucs->retry_int_in = 0;
 		break;
+	case -EPIPE:			/* endpoint stalled */
+		schedule_work(&ucs->int_in_wq);
+		/* fall through */
 	case -ENOENT:			/* cancelled */
 	case -ECONNRESET:		/* cancelled (async) */
 	case -EINPROGRESS:		/* pending */
-		/* ignore silently */
+	case -ENODEV:			/* device removed */
+	case -ESHUTDOWN:		/* device shut down */
+		/* no further action necessary */
 		gig_dbg(DEBUG_USBREQ, "%s: %s",
 			__func__, get_usb_statmsg(status));
 		return;
-	case -ENODEV:			/* device removed */
-	case -ESHUTDOWN:		/* device shut down */
-		gig_dbg(DEBUG_USBREQ, "%s: device disconnected", __func__);
+	case -EPROTO:			/* protocol error or unplug */
+	case -EILSEQ:
+	case -ETIME:
+		/* resubmit after delay */
+		gig_dbg(DEBUG_USBREQ, "%s: %s",
+			__func__, get_usb_statmsg(status));
+		mod_timer(&ucs->timer_int_in, jiffies + HZ / 10);
 		return;
-	default:		/* severe trouble */
+	default:		/* other errors: just resubmit */
 		dev_warn(cs->dev, "interrupt read: %s\n",
 			 get_usb_statmsg(status));
 		goto resubmit;
@@ -705,6 +774,13 @@ static void read_int_callback(struct urb *urb)
 			break;
 		}
 		spin_lock_irqsave(&cs->lock, flags);
+		if (ucs->basstate & BS_ATRDPEND) {
+			spin_unlock_irqrestore(&cs->lock, flags);
+			dev_warn(cs->dev,
+	"HD_RECEIVEATDATA_ACK(%d) during HD_READ_ATMESSAGE(%d) ignored\n",
+				 l, ucs->rcvbuf_size);
+			break;
+		}
 		if (ucs->rcvbuf_size) {
 			/* throw away previous buffer - we have no queue */
 			dev_err(cs->dev,
@@ -717,7 +793,6 @@ static void read_int_callback(struct urb *urb)
 		if (ucs->rcvbuf == NULL) {
 			spin_unlock_irqrestore(&cs->lock, flags);
 			dev_err(cs->dev, "out of memory receiving AT data\n");
-			error_reset(cs);
 			break;
 		}
 		ucs->rcvbuf_size = l;
@@ -727,13 +802,10 @@ static void read_int_callback(struct urb *urb)
 			kfree(ucs->rcvbuf);
 			ucs->rcvbuf = NULL;
 			ucs->rcvbuf_size = 0;
-			if (rc != -ENODEV) {
-				spin_unlock_irqrestore(&cs->lock, flags);
-				error_reset(cs);
-				break;
-			}
 		}
 		spin_unlock_irqrestore(&cs->lock, flags);
+		if (rc < 0 && rc != -ENODEV)
+			error_reset(cs);
 		break;
 
 	case HD_RESET_INTERRUPT_PIPE_ACK:
@@ -2138,7 +2210,9 @@ static int gigaset_initcshw(struct cardstate *cs)
 	setup_timer(&ucs->timer_ctrl, req_timeout, (unsigned long) cs);
 	setup_timer(&ucs->timer_atrdy, atrdy_timeout, (unsigned long) cs);
 	setup_timer(&ucs->timer_cmd_in, cmd_in_timeout, (unsigned long) cs);
+	setup_timer(&ucs->timer_int_in, int_in_resubmit, (unsigned long) cs);
 	init_waitqueue_head(&ucs->waitqueue);
+	INIT_WORK(&ucs->int_in_wq, int_in_work);
 
 	return 1;
 }
@@ -2286,6 +2360,7 @@ static int gigaset_probe(struct usb_interface *interface,
 			get_usb_rcmsg(rc));
 		goto error;
 	}
+	ucs->retry_int_in = 0;
 
 	/* tell the device that the driver is ready */
 	rc = req_submit(cs->bcs, HD_DEVICE_INIT_ACK, 0, 0);
@@ -2338,10 +2413,12 @@ static void gigaset_disconnect(struct usb_interface *interface)
 	/* stop driver (common part) */
 	gigaset_stop(cs);
 
-	/* stop timers and URBs, free ressources */
+	/* stop delayed work and URBs, free ressources */
 	del_timer_sync(&ucs->timer_ctrl);
 	del_timer_sync(&ucs->timer_atrdy);
 	del_timer_sync(&ucs->timer_cmd_in);
+	del_timer_sync(&ucs->timer_int_in);
+	cancel_work_sync(&ucs->int_in_wq);
 	freeurbs(cs);
 	usb_set_intfdata(interface, NULL);
 	kfree(ucs->rcvbuf);
@@ -2404,12 +2481,14 @@ static int gigaset_suspend(struct usb_interface *intf, pm_message_t message)
 		/* in case of timeout, proceed anyway */
 	}
 
-	/* kill all URBs and timers that might still be pending */
+	/* kill all URBs and delayed work that might still be pending */
 	usb_kill_urb(ucs->urb_ctrl);
 	usb_kill_urb(ucs->urb_int_in);
 	del_timer_sync(&ucs->timer_ctrl);
 	del_timer_sync(&ucs->timer_atrdy);
 	del_timer_sync(&ucs->timer_cmd_in);
+	del_timer_sync(&ucs->timer_int_in);
+	cancel_work_sync(&ucs->int_in_wq);
 
 	gig_dbg(DEBUG_SUSPEND, "suspend complete");
 	return 0;
@@ -2431,6 +2510,7 @@ static int gigaset_resume(struct usb_interface *intf)
 			get_usb_rcmsg(rc));
 		return rc;
 	}
+	ucs->retry_int_in = 0;
 
 	/* clear suspend flag to reallow activity */
 	update_basstate(ucs, 0, BS_SUSPEND);
-- 
1.7.3.15.g442cb
