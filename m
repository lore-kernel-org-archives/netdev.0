From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 49/50] staging: ced1401: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:06:12 +0800
Message-ID: <1373533573-12272-50-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>, devel@driverdev.osuosl.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:53536 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932611Ab3GKJNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:13:09 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: devel@driverdev.osuosl.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/staging/ced1401/usb1401.c |   35 +++++++++++++++++++----------------
 1 file changed, 19 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/ced1401/usb1401.c b/drivers/staging/ced1401/usb1401.c
index 97c55f9..70d2f43 100644
--- a/drivers/staging/ced1401/usb1401.c
+++ b/drivers/staging/ced1401/usb1401.c
@@ -265,6 +265,7 @@ static void ced_writechar_callback(struct urb *pUrb)
 {
 	DEVICE_EXTENSION *pdx = pUrb->context;
 	int nGot = pUrb->actual_length;	/*  what we transferred */
+	unsigned long flags;
 
 	if (pUrb->status) {	/*  sync/async unlink faults aren't errors */
 		if (!
@@ -275,24 +276,24 @@ static void ced_writechar_callback(struct urb *pUrb)
 				__func__, pUrb->status);
 		}
 
-		spin_lock(&pdx->err_lock);
+		spin_lock_irqsave(&pdx->err_lock, flags);
 		pdx->errors = pUrb->status;
-		spin_unlock(&pdx->err_lock);
+		spin_unlock_irqrestore(&pdx->err_lock, flags);
 		nGot = 0;	/*   and tidy up again if so */
 
-		spin_lock(&pdx->charOutLock);	/*  already at irq level */
+		spin_lock_irqsave(&pdx->charOutLock, flags);	/*  already at irq level */
 		pdx->dwOutBuffGet = 0;	/*  Reset the output buffer */
 		pdx->dwOutBuffPut = 0;
 		pdx->dwNumOutput = 0;	/*  Clear the char count */
 		pdx->bPipeError[0] = 1;	/*  Flag an error for later */
 		pdx->bSendCharsPending = false;	/*  Allow other threads again */
-		spin_unlock(&pdx->charOutLock);	/*  already at irq level */
+		spin_unlock_irqrestore(&pdx->charOutLock, flags);	/*  already at irq level */
 		dev_dbg(&pdx->interface->dev,
 			"%s - char out done, 0 chars sent", __func__);
 	} else {
 		dev_dbg(&pdx->interface->dev,
 			"%s - char out done, %d chars sent", __func__, nGot);
-		spin_lock(&pdx->charOutLock);	/*  already at irq level */
+		spin_lock_irqsave(&pdx->charOutLock, flags);	/*  already at irq level */
 		pdx->dwNumOutput -= nGot;	/*  Now adjust the char send buffer */
 		pdx->dwOutBuffGet += nGot;	/*  to match what we did */
 		if (pdx->dwOutBuffGet >= OUTBUF_SZ)	/*  Can't do this any earlier as data could be overwritten */
@@ -305,7 +306,7 @@ static void ced_writechar_callback(struct urb *pUrb)
 			unsigned int dwCount = pdx->dwNumOutput;	/*  maximum to send */
 			if ((pdx->dwOutBuffGet + dwCount) > OUTBUF_SZ)	/*  does it cross buffer end? */
 				dwCount = OUTBUF_SZ - pdx->dwOutBuffGet;
-			spin_unlock(&pdx->charOutLock);	/*  we are done with stuff that changes */
+			spin_unlock_irqrestore(&pdx->charOutLock, flags);	/*  we are done with stuff that changes */
 			memcpy(pdx->pCoherCharOut, pDat, dwCount);	/*  copy output data to the buffer */
 			usb_fill_bulk_urb(pdx->pUrbCharOut, pdx->udev,
 					  usb_sndbulkpipe(pdx->udev,
@@ -318,7 +319,7 @@ static void ced_writechar_callback(struct urb *pUrb)
 			iReturn = usb_submit_urb(pdx->pUrbCharOut, GFP_ATOMIC);
 			dev_dbg(&pdx->interface->dev, "%s n=%d>%s<", __func__,
 				dwCount, pDat);
-			spin_lock(&pdx->charOutLock);	/*  grab lock for errors */
+			spin_lock_irqsave(&pdx->charOutLock, flags);	/*  grab lock for errors */
 			if (iReturn) {
 				pdx->bPipeError[nPipe] = 1;	/*  Flag an error to be handled later */
 				pdx->bSendCharsPending = false;	/*  Allow other threads again */
@@ -329,7 +330,7 @@ static void ced_writechar_callback(struct urb *pUrb)
 			}
 		} else
 			pdx->bSendCharsPending = false;	/*  Allow other threads again */
-		spin_unlock(&pdx->charOutLock);	/*  already at irq level */
+		spin_unlock_irqrestore(&pdx->charOutLock, flags);	/*  already at irq level */
 	}
 }
 
@@ -505,8 +506,9 @@ static void staged_callback(struct urb *pUrb)
 	unsigned int nGot = pUrb->actual_length;	/*  what we transferred */
 	bool bCancel = false;
 	bool bRestartCharInput;	/*  used at the end */
+	unsigned long flags;
 
-	spin_lock(&pdx->stagedLock);	/*  stop ReadWriteMem() action while this routine is running */
+	spin_lock_irqsave(&pdx->stagedLock, flags);	/*  stop ReadWriteMem() action while this routine is running */
 	pdx->bStagedUrbPending = false;	/*  clear the flag for staged IRP pending */
 
 	if (pUrb->status) {	/*  sync/async unlink faults aren't errors */
@@ -679,7 +681,7 @@ static void staged_callback(struct urb *pUrb)
 	bRestartCharInput = !bCancel && (pdx->dwDMAFlag == MODE_CHAR)
 	    && !pdx->bXFerWaiting;
 
-	spin_unlock(&pdx->stagedLock);	/*  Finally release the lock again */
+	spin_unlock_irqrestore(&pdx->stagedLock, flags);	/*  Finally release the lock again */
 
 	/*  This is not correct as dwDMAFlag is protected by the staged lock, but it is treated */
 	/*  in Allowi as if it were protected by the char lock. In any case, most systems will */
@@ -1093,6 +1095,7 @@ static void ced_readchar_callback(struct urb *pUrb)
 {
 	DEVICE_EXTENSION *pdx = pUrb->context;
 	int nGot = pUrb->actual_length;	/*  what we transferred */
+	unsigned long flags;
 
 	if (pUrb->status) {	/*  Do we have a problem to handle? */
 		int nPipe = pdx->nPipes == 4 ? 1 : 0;	/*  The pipe number to use for error */
@@ -1108,19 +1111,19 @@ static void ced_readchar_callback(struct urb *pUrb)
 				"%s - 0 chars pUrb->status=%d (shutdown?)",
 				__func__, pUrb->status);
 
-		spin_lock(&pdx->err_lock);
+		spin_lock_irqsave(&pdx->err_lock, flags);
 		pdx->errors = pUrb->status;
-		spin_unlock(&pdx->err_lock);
+		spin_unlock_irqrestore(&pdx->err_lock, flags);
 		nGot = 0;	/*   and tidy up again if so */
 
-		spin_lock(&pdx->charInLock);	/*  already at irq level */
+		spin_lock_irqsave(&pdx->charInLock, flags);	/*  already at irq level */
 		pdx->bPipeError[nPipe] = 1;	/*  Flag an error for later */
 	} else {
 		if ((nGot > 1) && ((pdx->pCoherCharIn[0] & 0x7f) == 0x1b)) {	/*  Esc sequence? */
 			Handle1401Esc(pdx, &pdx->pCoherCharIn[1], nGot - 1);	/*  handle it */
-			spin_lock(&pdx->charInLock);	/*  already at irq level */
+			spin_lock_irqsave(&pdx->charInLock, flags);	/*  already at irq level */
 		} else {
-			spin_lock(&pdx->charInLock);	/*  already at irq level */
+			spin_lock_irqsave(&pdx->charInLock, flags);	/*  already at irq level */
 			if (nGot > 0) {
 				unsigned int i;
 				if (nGot < INBUF_SZ) {
@@ -1147,7 +1150,7 @@ static void ced_readchar_callback(struct urb *pUrb)
 	}
 
 	pdx->bReadCharsPending = false;	/*  No longer have a pending read */
-	spin_unlock(&pdx->charInLock);	/*  already at irq level */
+	spin_unlock_irqrestore(&pdx->charInLock, flags);	/*  already at irq level */
 
 	Allowi(pdx);	/*  see if we can do the next one */
 }
-- 
1.7.9.5
