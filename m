From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 5/9] isdn/gigaset: bas_gigaset timer cleanup
Date: Fri,  1 Oct 2010 01:35:11 +0200 (CEST)
Message-ID: <20100930-patch-gigaset-05.tilman@imap.cc>
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

Use setup_timer() and mod_timer() instead of direct assignment to
timer structure members, simplify the argument of one timer routine,
and make extra sure all timers are stopped during suspend.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/bas-gigaset.c |   65 +++++++++++++++++------------------
 1 files changed, 32 insertions(+), 33 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 131976d..e865c5d 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -588,10 +588,7 @@ static int atread_submit(struct cardstate *cs, int timeout)
 
 	if (timeout > 0) {
 		gig_dbg(DEBUG_USBREQ, "setting timeout of %d/10 secs", timeout);
-		ucs->timer_cmd_in.expires = jiffies + timeout * HZ / 10;
-		ucs->timer_cmd_in.data = (unsigned long) cs;
-		ucs->timer_cmd_in.function = cmd_in_timeout;
-		add_timer(&ucs->timer_cmd_in);
+		mod_timer(&ucs->timer_cmd_in, jiffies + timeout * HZ / 10);
 	}
 	return 0;
 }
@@ -1356,12 +1353,12 @@ error:
 /* req_timeout
  * timeout routine for control output request
  * argument:
- *	B channel control structure
+ *	controller state structure
  */
 static void req_timeout(unsigned long data)
 {
-	struct bc_state *bcs = (struct bc_state *) data;
-	struct bas_cardstate *ucs = bcs->cs->hw.bas;
+	struct cardstate *cs = (struct cardstate *) data;
+	struct bas_cardstate *ucs = cs->hw.bas;
 	int pending;
 	unsigned long flags;
 
@@ -1378,38 +1375,44 @@ static void req_timeout(unsigned long data)
 		break;
 
 	case HD_OPEN_ATCHANNEL:
-		dev_err(bcs->cs->dev, "timeout opening AT channel\n");
-		error_reset(bcs->cs);
+		dev_err(cs->dev, "timeout opening AT channel\n");
+		error_reset(cs);
 		break;
 
-	case HD_OPEN_B2CHANNEL:
 	case HD_OPEN_B1CHANNEL:
-		dev_err(bcs->cs->dev, "timeout opening channel %d\n",
-			bcs->channel + 1);
-		error_hangup(bcs);
+		dev_err(cs->dev, "timeout opening channel 1\n");
+		error_hangup(&cs->bcs[0]);
+		break;
+
+	case HD_OPEN_B2CHANNEL:
+		dev_err(cs->dev, "timeout opening channel 2\n");
+		error_hangup(&cs->bcs[1]);
 		break;
 
 	case HD_CLOSE_ATCHANNEL:
-		dev_err(bcs->cs->dev, "timeout closing AT channel\n");
-		error_reset(bcs->cs);
+		dev_err(cs->dev, "timeout closing AT channel\n");
+		error_reset(cs);
 		break;
 
-	case HD_CLOSE_B2CHANNEL:
 	case HD_CLOSE_B1CHANNEL:
-		dev_err(bcs->cs->dev, "timeout closing channel %d\n",
-			bcs->channel + 1);
-		error_reset(bcs->cs);
+		dev_err(cs->dev, "timeout closing channel 1\n");
+		error_reset(cs);
+		break;
+
+	case HD_CLOSE_B2CHANNEL:
+		dev_err(cs->dev, "timeout closing channel 2\n");
+		error_reset(cs);
 		break;
 
 	case HD_RESET_INTERRUPT_PIPE:
 		/* error recovery escalation */
-		dev_err(bcs->cs->dev,
+		dev_err(cs->dev,
 			"reset interrupt pipe timeout, attempting USB reset\n");
-		usb_queue_reset_device(bcs->cs->hw.bas->interface);
+		usb_queue_reset_device(ucs->interface);
 		break;
 
 	default:
-		dev_warn(bcs->cs->dev, "request 0x%02x timed out, clearing\n",
+		dev_warn(cs->dev, "request 0x%02x timed out, clearing\n",
 			 pending);
 	}
 
@@ -1540,10 +1543,7 @@ static int req_submit(struct bc_state *bcs, int req, int val, int timeout)
 
 	if (timeout > 0) {
 		gig_dbg(DEBUG_USBREQ, "setting timeout of %d/10 secs", timeout);
-		ucs->timer_ctrl.expires = jiffies + timeout * HZ / 10;
-		ucs->timer_ctrl.data = (unsigned long) bcs;
-		ucs->timer_ctrl.function = req_timeout;
-		add_timer(&ucs->timer_ctrl);
+		mod_timer(&ucs->timer_ctrl, jiffies + timeout * HZ / 10);
 	}
 
 	spin_unlock_irqrestore(&ucs->lock, flags);
@@ -1809,10 +1809,7 @@ static int atwrite_submit(struct cardstate *cs, unsigned char *buf, int len)
 	if (!(update_basstate(ucs, BS_ATTIMER, BS_ATREADY) & BS_ATTIMER)) {
 		gig_dbg(DEBUG_OUTPUT, "setting ATREADY timeout of %d/10 secs",
 			ATRDY_TIMEOUT);
-		ucs->timer_atrdy.expires = jiffies + ATRDY_TIMEOUT * HZ / 10;
-		ucs->timer_atrdy.data = (unsigned long) cs;
-		ucs->timer_atrdy.function = atrdy_timeout;
-		add_timer(&ucs->timer_atrdy);
+		mod_timer(&ucs->timer_atrdy, jiffies + ATRDY_TIMEOUT * HZ / 10);
 	}
 	return 0;
 }
@@ -2114,9 +2111,9 @@ static int gigaset_initcshw(struct cardstate *cs)
 	ucs->pending = 0;
 
 	ucs->basstate = 0;
-	init_timer(&ucs->timer_ctrl);
-	init_timer(&ucs->timer_atrdy);
-	init_timer(&ucs->timer_cmd_in);
+	setup_timer(&ucs->timer_ctrl, req_timeout, (unsigned long) cs);
+	setup_timer(&ucs->timer_atrdy, atrdy_timeout, (unsigned long) cs);
+	setup_timer(&ucs->timer_cmd_in, cmd_in_timeout, (unsigned long) cs);
 	init_waitqueue_head(&ucs->waitqueue);
 
 	return 1;
@@ -2387,6 +2384,8 @@ static int gigaset_suspend(struct usb_interface *intf, pm_message_t message)
 	usb_kill_urb(ucs->urb_ctrl);
 	usb_kill_urb(ucs->urb_int_in);
 	del_timer_sync(&ucs->timer_ctrl);
+	del_timer_sync(&ucs->timer_atrdy);
+	del_timer_sync(&ucs->timer_cmd_in);
 
 	gig_dbg(DEBUG_SUSPEND, "suspend complete");
 	return 0;
-- 
1.7.3.15.g442cb
