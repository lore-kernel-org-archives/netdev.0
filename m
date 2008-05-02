From: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Subject: [patch 1/1] hci_usb.h: fix hard-to-trigger race
Date: Fri, 02 May 2008 13:39:55 -0700
Message-ID: <200805022039.m42KdtYe013613@imap1.linux-foundation.org>
Cc: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	pavel-+ZI9xUNit7I@public.gmane.org, pavel-AlSwsSmVLrQ@public.gmane.org
To: hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>

If someone tries to _urb_unlink while _urb_queue_head is running, he'll see
_urb->queue == NULL and fail to do any locking.  Prevent that from happening
by strategically placed barriers.

Signed-off-by: Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Cc: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
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
