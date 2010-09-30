From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 2/9] isdn/gigaset: fix bas_gigaset AT read error handling
Date: Fri,  1 Oct 2010 01:34:40 +0200 (CEST)
Message-ID: <20100930-patch-gigaset-02.tilman@imap.cc>
References: <20100930-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:34819 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755435Ab0JAAbK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Sep 2010 20:31:10 -0400
In-Reply-To: <20100930-patch-gigaset-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rework the handling of USB errors in AT response reads
to fix a possible infinite retry loop and a memory leak,
and silence a few overly verbose kernel messages.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
CC: stable <stable@kernel.org>
---
 drivers/isdn/gigaset/bas-gigaset.c |   83 ++++++++++++++---------------------
 1 files changed, 33 insertions(+), 50 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index e143050..131976d 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -438,23 +438,27 @@ static void cmd_in_timeout(unsigned long data)
 		return;
 	}
 
-	if (ucs->retry_cmd_in++ < BAS_RETRY) {
-		dev_notice(cs->dev, "control read: timeout, retry %d\n",
-			   ucs->retry_cmd_in);
-		rc = atread_submit(cs, BAS_TIMEOUT);
-		if (rc >= 0 || rc == -ENODEV)
-			/* resubmitted or disconnected */
-			/* - bypass regular exit block */
-			return;
-	} else {
+	if (ucs->retry_cmd_in++ >= BAS_RETRY) {
 		dev_err(cs->dev,
 			"control read: timeout, giving up after %d tries\n",
 			ucs->retry_cmd_in);
+		kfree(ucs->rcvbuf);
+		ucs->rcvbuf = NULL;
+		ucs->rcvbuf_size = 0;
+		error_reset(cs);
+		return;
+	}
+
+	gig_dbg(DEBUG_USBREQ, "%s: timeout, retry %d",
+		__func__, ucs->retry_cmd_in);
+	rc = atread_submit(cs, BAS_TIMEOUT);
+	if (rc < 0) {
+		kfree(ucs->rcvbuf);
+		ucs->rcvbuf = NULL;
+		ucs->rcvbuf_size = 0;
+		if (rc != -ENODEV)
+			error_reset(cs);
 	}
-	kfree(ucs->rcvbuf);
-	ucs->rcvbuf = NULL;
-	ucs->rcvbuf_size = 0;
-	error_reset(cs);
 }
 
 /* read_ctrl_callback
@@ -470,18 +474,11 @@ static void read_ctrl_callback(struct urb *urb)
 	struct cardstate *cs = inbuf->cs;
 	struct bas_cardstate *ucs = cs->hw.bas;
 	int status = urb->status;
-	int have_data = 0;
 	unsigned numbytes;
 	int rc;
 
 	update_basstate(ucs, 0, BS_ATRDPEND);
 	wake_up(&ucs->waitqueue);
-
-	if (!ucs->rcvbuf_size) {
-		dev_warn(cs->dev, "%s: no receive in progress\n", __func__);
-		return;
-	}
-
 	del_timer(&ucs->timer_cmd_in);
 
 	switch (status) {
@@ -495,19 +492,10 @@ static void read_ctrl_callback(struct urb *urb)
 				numbytes = ucs->rcvbuf_size;
 		}
 
-		/* copy received bytes to inbuf */
-		have_data = gigaset_fill_inbuf(inbuf, ucs->rcvbuf, numbytes);
-
-		if (unlikely(numbytes < ucs->rcvbuf_size)) {
-			/* incomplete - resubmit for remaining bytes */
-			ucs->rcvbuf_size -= numbytes;
-			ucs->retry_cmd_in = 0;
-			rc = atread_submit(cs, BAS_TIMEOUT);
-			if (rc >= 0 || rc == -ENODEV)
-				/* resubmitted or disconnected */
-				/* - bypass regular exit block */
-				return;
-			error_reset(cs);
+		/* copy received bytes to inbuf, notify event layer */
+		if (gigaset_fill_inbuf(inbuf, ucs->rcvbuf, numbytes)) {
+			gig_dbg(DEBUG_INTR, "%s-->BH", __func__);
+			gigaset_schedule_event(cs);
 		}
 		break;
 
@@ -516,37 +504,32 @@ static void read_ctrl_callback(struct urb *urb)
 	case -EINPROGRESS:		/* pending */
 	case -ENODEV:			/* device removed */
 	case -ESHUTDOWN:		/* device shut down */
-		/* no action necessary */
+		/* no further action necessary */
 		gig_dbg(DEBUG_USBREQ, "%s: %s",
 			__func__, get_usb_statmsg(status));
 		break;
 
-	default:			/* severe trouble */
-		dev_warn(cs->dev, "control read: %s\n",
-			 get_usb_statmsg(status));
+	default:			/* other errors: retry */
 		if (ucs->retry_cmd_in++ < BAS_RETRY) {
-			dev_notice(cs->dev, "control read: retry %d\n",
-				   ucs->retry_cmd_in);
+			gig_dbg(DEBUG_USBREQ, "%s: %s, retry %d", __func__,
+				get_usb_statmsg(status), ucs->retry_cmd_in);
 			rc = atread_submit(cs, BAS_TIMEOUT);
-			if (rc >= 0 || rc == -ENODEV)
-				/* resubmitted or disconnected */
-				/* - bypass regular exit block */
+			if (rc >= 0)
+				/* successfully resubmitted, skip freeing */
 				return;
-		} else {
-			dev_err(cs->dev,
-				"control read: giving up after %d tries\n",
-				ucs->retry_cmd_in);
+			if (rc == -ENODEV)
+				/* disconnect, no further action necessary */
+				break;
 		}
+		dev_err(cs->dev, "control read: %s, giving up after %d tries\n",
+			get_usb_statmsg(status), ucs->retry_cmd_in);
 		error_reset(cs);
 	}
 
+	/* read finished, free buffer */
 	kfree(ucs->rcvbuf);
 	ucs->rcvbuf = NULL;
 	ucs->rcvbuf_size = 0;
-	if (have_data) {
-		gig_dbg(DEBUG_INTR, "%s-->BH", __func__);
-		gigaset_schedule_event(cs);
-	}
 }
 
 /* atread_submit
-- 
1.7.3.15.g442cb

