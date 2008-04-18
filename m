From: akpm@linux-foundation.org
Subject: [patch 3/3] hci_usb.h: fix hard-to-trigger race
Date: Fri, 18 Apr 2008 13:46:54 -0700
Message-ID: <200804182046.m3IKksxT014631@imap1.linux-foundation.org>
Cc: hidave.darkstar@gmail.com, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org, pavel@ucw.cz,
	pavel@suse.cz
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47821 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753853AbYDRUrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 16:47:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Machek <pavel@ucw.cz>

If someone tries to _urb_unlink while _urb_queue_head is running, he'll see
_urb->queue == NULL and fail to do any locking.  Prevent that from happening
by strategically placed barriers.

Signed-off-by: Pavel Machek <pavel@suse.cz>
Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Dave Young <hidave.darkstar@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/bluetooth/hci_usb.h |   21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff -puN drivers/bluetooth/hci_usb.h~hci_usbh-fix-hard-to-trigger-race drivers/bluetooth/hci_usb.h
--- a/drivers/bluetooth/hci_usb.h~hci_usbh-fix-hard-to-trigger-race
+++ a/drivers/bluetooth/hci_usb.h
@@ -70,7 +70,8 @@ static inline void _urb_queue_head(struc
 {
 	unsigned long flags;
 	spin_lock_irqsave(&q->lock, flags);
-	list_add(&_urb->list, &q->head); _urb->queue = q;
+	/* _urb_unlink needs to know which spinlock to use, thus mb(). */
+	_urb->queue = q; mb(); list_add(&_urb->list, &q->head);
 	spin_unlock_irqrestore(&q->lock, flags);
 }
 
@@ -78,19 +79,23 @@ static inline void _urb_queue_tail(struc
 {
 	unsigned long flags;
 	spin_lock_irqsave(&q->lock, flags);
-	list_add_tail(&_urb->list, &q->head); _urb->queue = q;
+	/* _urb_unlink needs to know which spinlock to use, thus mb(). */
+	_urb->queue = q; mb(); list_add_tail(&_urb->list, &q->head);
 	spin_unlock_irqrestore(&q->lock, flags);
 }
 
 static inline void _urb_unlink(struct _urb *_urb)
 {
-	struct _urb_queue *q = _urb->queue;
+	struct _urb_queue *q;
 	unsigned long flags;
-	if (q) {
-		spin_lock_irqsave(&q->lock, flags);
-		list_del(&_urb->list); _urb->queue = NULL;
-		spin_unlock_irqrestore(&q->lock, flags);
-	}
+
+	mb();
+	q = _urb->queue;
+	/* If q is NULL, it will die at easy-to-debug NULL pointer dereference.
+	   No need to BUG(). */
+	spin_lock_irqsave(&q->lock, flags);
+	list_del(&_urb->list); _urb->queue = NULL;
+	spin_unlock_irqrestore(&q->lock, flags);
 }
 
 struct hci_usb {
_
