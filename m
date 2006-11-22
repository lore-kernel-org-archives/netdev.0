From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH RESEND] zd1211rw: Fix of a locking bug
Date: Wed, 22 Nov 2006 00:06:06 +0000 (GMT)
Message-ID: <20061122000606.6982A7B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:58699 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1756883AbWKVAGB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 19:06:01 -0500
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune@deine-taler.de>

This patch fixes the bug as reported in the kernel bug tracker
under the id 7244. The bug was simply that the interrupt lock has
been locked outside an interrupt without blocking the interrupt.

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
Signed-off-by: Daniel Drake <dsd@gentoo.org>
---

It appears that this patch was lost on its first submission.

 zd_usb.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -372,15 +372,6 @@ error:
 	return r;
 }
 
-static void disable_read_regs_int(struct zd_usb *usb)
-{
-	struct zd_usb_interrupt *intr = &usb->intr;
-
-	spin_lock(&intr->lock);
-	intr->read_regs_enabled = 0;
-	spin_unlock(&intr->lock);
-}
-
 #define urb_dev(urb) (&(urb)->dev->dev)
 
 static inline void handle_regs_int(struct urb *urb)
@@ -1163,10 +1154,19 @@ static void prepare_read_regs_int(struct
 {
 	struct zd_usb_interrupt *intr = &usb->intr;
 
-	spin_lock(&intr->lock);
+	spin_lock_irq(&intr->lock);
 	intr->read_regs_enabled = 1;
 	INIT_COMPLETION(intr->read_regs.completion);
-	spin_unlock(&intr->lock);
+	spin_unlock_irq(&intr->lock);
+}
+
+static void disable_read_regs_int(struct zd_usb *usb)
+{
+	struct zd_usb_interrupt *intr = &usb->intr;
+
+	spin_lock_irq(&intr->lock);
+	intr->read_regs_enabled = 0;
+	spin_unlock_irq(&intr->lock);
 }
 
 static int get_results(struct zd_usb *usb, u16 *values,
@@ -1178,7 +1178,7 @@ static int get_results(struct zd_usb *us
 	struct read_regs_int *rr = &intr->read_regs;
 	struct usb_int_regs *regs = (struct usb_int_regs *)rr->buffer;
 
-	spin_lock(&intr->lock);
+	spin_lock_irq(&intr->lock);
 
 	r = -EIO;
 	/* The created block size seems to be larger than expected.
@@ -1211,7 +1211,7 @@ static int get_results(struct zd_usb *us
 
 	r = 0;
 error_unlock:
-	spin_unlock(&intr->lock);
+	spin_unlock_irq(&intr->lock);
 	return r;
 }
 
