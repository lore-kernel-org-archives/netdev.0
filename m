From: Mark Asselstine <mark.asselstine@windriver.com>
Subject: [PATCH] Remove cli()/sti() calls from HYSDN driver.
Date: Thu,  1 May 2008 16:16:52 -0400
Message-ID: <1209673012-10500-1-git-send-email-mark.asselstine@windriver.com>
Cc: asselsm@gmail.com, Mark Asselstine <mark.asselstine@windriver.com>
To: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62863 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750903AbYEAURZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2008 16:17:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From looking at this driver the use of cli()/sti() within the do/while
was a way to ensure interrupts were only disabled for short periods of
time while the bulk of the time interrupts were free to occur. The
use of the spin lock has eliminated the need to play with interrupts
in this way while still allowing for IO to be protected.

The remaining 3 sti() calls seem unneeded now that at no other point
in the driver is there a call to cli().

Signed-off-by: Mark Asselstine <mark.asselstine@windriver.com>
---
 drivers/isdn/hysdn/boardergo.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/isdn/hysdn/boardergo.c b/drivers/isdn/hysdn/boardergo.c
index 6cdbad3..3eb096f 100644
--- a/drivers/isdn/hysdn/boardergo.c
+++ b/drivers/isdn/hysdn/boardergo.c
@@ -64,10 +64,11 @@ ergo_interrupt(int intno, void *dev_id)
 }				/* ergo_interrupt */
 
 /******************************************************************************/
-/* ergo_irq_bh is the function called by the immediate kernel task list after */
-/* being activated with queue_task and no interrupts active. This task is the */
-/* only one handling data transfer from or to the card after booting. The task */
-/* may be queued from everywhere (interrupts included).                       */
+/* ergo_irq_bh will be called as part of the kernel clearing its shared work  */
+/* queue sometime after a call to schedule_work has been made passing our     */
+/* work_struct. This task is the only one handling data transfer from or to   */
+/* the card after booting. The task may be queued from everywhere             */
+/* (interrupts included).                                                     */
 /******************************************************************************/
 static void
 ergo_irq_bh(struct work_struct *ugli_api)
@@ -90,7 +91,6 @@ ergo_irq_bh(struct work_struct *ugli_api)
 	card->hw_lock = 1;	/* we now lock the hardware */
 
 	do {
-		sti();		/* reenable other ints */
 		again = 0;	/* assume loop not to be repeated */
 
 		if (!dpr->ToHyFlag) {
@@ -110,7 +110,6 @@ ergo_irq_bh(struct work_struct *ugli_api)
 				again = 1;	/* restart loop */
 			}
 		}		/* a message has arrived for us */
-		cli();		/* no further ints */
 		if (again) {
 			dpr->ToHyInt = 1;
 			dpr->ToPcInt = 1;	/* interrupt to E1 for all cards */
@@ -242,7 +241,6 @@ ergo_writebootimg(struct HYSDN_CARD *card, unsigned char *buf,
 		byteout(card->iobase + PCI9050_USER_IO, PCI9050_E1_RUN);	/* start E1 processor */
 		/* the interrupts are still masked */
 
-		sti();
 		msleep_interruptible(20);		/* Timeout 20ms */
 
 		if (((tDpramBootSpooler *) card->dpram)->Len != DPRAM_SPOOLER_DATA_SIZE) {
@@ -276,7 +274,6 @@ ergo_writebootseq(struct HYSDN_CARD *card, unsigned char *buf, int len)
 	dst = sp->Data;		/* point to data in spool structure */
 	buflen = sp->Len;	/* maximum len of spooled data */
 	wr_mirror = sp->WrPtr;	/* only once read */
-	sti();
 
 	/* try until all bytes written or error */
 	i = 0x1000;		/* timeout value */
@@ -380,7 +377,6 @@ ergo_waitpofready(struct HYSDN_CARD *card)
 #endif /* CONFIG_HYSDN_CAPI */
 			return (0);	/* success */
 		}		/* data has arrived */
-		sti();
 		msleep_interruptible(50);		/* Timeout 50ms */
 	}			/* wait until timeout */
 
-- 
1.5.5.1

