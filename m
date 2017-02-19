From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH repost] ptr_ring: fix race conditions when resizing
Date: Sun, 19 Feb 2017 07:17:17 +0200
Message-ID: <1487171217-6641-1-git-send-email-mst__1457.21474332294$1487481481$gmane$org@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov@google.com>, stable@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38702 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751105AbdBSFRT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Feb 2017 00:17:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resizing currently drops consumer lock.  This can cause entries to be
reordered, which isn't good in itself.  More importantly, consumer can
detect a false ring empty condition and block forever.

Further, nesting of consumer within producer lock is problematic for
tun, since it produces entries in a BH, which causes a lock order
reversal:

       CPU0                    CPU1
       ----                    ----
  consume:
  lock(&(&r->consumer_lock)->rlock);
                               resize:
                               local_irq_disable();
                               lock(&(&r->producer_lock)->rlock);
                               lock(&(&r->consumer_lock)->rlock);
  <Interrupt>
  produce:
  lock(&(&r->producer_lock)->rlock);

To fix, nest producer lock within consumer lock during resize,
and keep consumer lock during the whole swap operation.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: stable@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>
Acked-by: Jason Wang <jasowang@redhat.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Dave, could you merge this before 4.10? If not - I can try.

 include/linux/ptr_ring.h | 36 +++++++++++++++++++++++++++++++-----
 1 file changed, 31 insertions(+), 5 deletions(-)

diff --git a/include/linux/ptr_ring.h b/include/linux/ptr_ring.h
index 2052011..6c70444 100644
--- a/include/linux/ptr_ring.h
+++ b/include/linux/ptr_ring.h
@@ -111,6 +111,11 @@ static inline int __ptr_ring_produce(struct ptr_ring *r, void *ptr)
 	return 0;
 }
 
+/*
+ * Note: resize (below) nests producer lock within consumer lock, so if you
+ * consume in interrupt or BH context, you must disable interrupts/BH when
+ * calling this.
+ */
 static inline int ptr_ring_produce(struct ptr_ring *r, void *ptr)
 {
 	int ret;
@@ -242,6 +247,11 @@ static inline void *__ptr_ring_consume(struct ptr_ring *r)
 	return ptr;
 }
 
+/*
+ * Note: resize (below) nests producer lock within consumer lock, so if you
+ * call this in interrupt or BH context, you must disable interrupts/BH when
+ * producing.
+ */
 static inline void *ptr_ring_consume(struct ptr_ring *r)
 {
 	void *ptr;
@@ -357,7 +367,7 @@ static inline void **__ptr_ring_swap_queue(struct ptr_ring *r, void **queue,
 	void **old;
 	void *ptr;
 
-	while ((ptr = ptr_ring_consume(r)))
+	while ((ptr = __ptr_ring_consume(r)))
 		if (producer < size)
 			queue[producer++] = ptr;
 		else if (destroy)
@@ -372,6 +382,12 @@ static inline void **__ptr_ring_swap_queue(struct ptr_ring *r, void **queue,
 	return old;
 }
 
+/*
+ * Note: producer lock is nested within consumer lock, so if you
+ * resize you must make sure all uses nest correctly.
+ * In particular if you consume ring in interrupt or BH context, you must
+ * disable interrupts/BH when doing so.
+ */
 static inline int ptr_ring_resize(struct ptr_ring *r, int size, gfp_t gfp,
 				  void (*destroy)(void *))
 {
@@ -382,17 +398,25 @@ static inline int ptr_ring_resize(struct ptr_ring *r, int size, gfp_t gfp,
 	if (!queue)
 		return -ENOMEM;
 
-	spin_lock_irqsave(&(r)->producer_lock, flags);
+	spin_lock_irqsave(&(r)->consumer_lock, flags);
+	spin_lock(&(r)->producer_lock);
 
 	old = __ptr_ring_swap_queue(r, queue, size, gfp, destroy);
 
-	spin_unlock_irqrestore(&(r)->producer_lock, flags);
+	spin_unlock(&(r)->producer_lock);
+	spin_unlock_irqrestore(&(r)->consumer_lock, flags);
 
 	kfree(old);
 
 	return 0;
 }
 
+/*
+ * Note: producer lock is nested within consumer lock, so if you
+ * resize you must make sure all uses nest correctly.
+ * In particular if you consume ring in interrupt or BH context, you must
+ * disable interrupts/BH when doing so.
+ */
 static inline int ptr_ring_resize_multiple(struct ptr_ring **rings, int nrings,
 					   int size,
 					   gfp_t gfp, void (*destroy)(void *))
@@ -412,10 +436,12 @@ static inline int ptr_ring_resize_multiple(struct ptr_ring **rings, int nrings,
 	}
 
 	for (i = 0; i < nrings; ++i) {
-		spin_lock_irqsave(&(rings[i])->producer_lock, flags);
+		spin_lock_irqsave(&(rings[i])->consumer_lock, flags);
+		spin_lock(&(rings[i])->producer_lock);
 		queues[i] = __ptr_ring_swap_queue(rings[i], queues[i],
 						  size, gfp, destroy);
-		spin_unlock_irqrestore(&(rings[i])->producer_lock, flags);
+		spin_unlock(&(rings[i])->producer_lock);
+		spin_unlock_irqrestore(&(rings[i])->consumer_lock, flags);
 	}
 
 	for (i = 0; i < nrings; ++i)
-- 
MST
