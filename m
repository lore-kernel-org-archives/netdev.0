From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC v2] ptr_ring: add ptr_ring_unconsume
Date: Mon, 24 Apr 2017 19:01:08 +0300
Message-ID: <1493049492-3229-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jason Wang <jasowang@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:39670 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S972596AbdDXQBM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 12:01:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applications that consume a batch of entries in one go
can benefit from ability to return some of them back
into the ring.

Add an API for that - assuming there's space. If there's no space
naturally can't do this and have to drop entries, but this implies ring
is full so we'd likely drop some anyway.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Jason, if you add this and unconsume the outstanding packets
on backend disconnect, vhost close and reset, I think
we should apply your patch even if we don't yet know 100%
why it helps.

changes from v1:
- fix up coding style issues reported by Sergei Shtylyov


 include/linux/ptr_ring.h | 56 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 56 insertions(+)

diff --git a/include/linux/ptr_ring.h b/include/linux/ptr_ring.h
index 783e7f5..902afc2 100644
--- a/include/linux/ptr_ring.h
+++ b/include/linux/ptr_ring.h
@@ -457,6 +457,62 @@ static inline int ptr_ring_init(struct ptr_ring *r, int size, gfp_t gfp)
 	return 0;
 }
 
+/*
+ * Return entries into ring. Destroy entries that don't fit.
+ *
+ * Note: this is expected to be a rare slow path operation.
+ *
+ * Note: producer lock is nested within consumer lock, so if you
+ * resize you must make sure all uses nest correctly.
+ * In particular if you consume ring in interrupt or BH context, you must
+ * disable interrupts/BH when doing so.
+ */
+static inline void ptr_ring_unconsume(struct ptr_ring *r, void **batch, int n,
+				      void (*destroy)(void *))
+{
+	unsigned long flags;
+	int head;
+
+	spin_lock_irqsave(&r->consumer_lock, flags);
+	spin_lock(&r->producer_lock);
+
+	if (!r->size)
+		goto done;
+
+	/* 
+	 * Clean out buffered entries (for simplicity). This way following code
+	 * can test entries for NULL and if not assume they are valid.
+	 */
+	head = r->consumer_head - 1;
+	while (likely(head >= r->consumer_tail))
+		r->queue[head--] = NULL;
+	r->consumer_tail = r->consumer_head;
+
+	/*
+	 * Go over entries in batch, start moving head back and copy entries.
+	 * Stop when we run into previously unconsumed entries.
+	 */
+	while (n--) {
+		head = r->consumer_head - 1;
+		if (head < 0)
+			head = r->size - 1;
+		if (r->queue[head]) {
+			/* This batch entry will have to be destroyed. */
+			++n;
+			goto done;
+		}
+		r->queue[head] = batch[n];
+		r->consumer_tail = r->consumer_head = head;
+	}
+
+done:
+	/* Destroy all entries left in the batch. */
+	while (n--)
+		destroy(batch[n]);
+	spin_unlock(&r->producer_lock);
+	spin_unlock_irqrestore(&r->consumer_lock, flags);
+}
+
 static inline void **__ptr_ring_swap_queue(struct ptr_ring *r, void **queue,
 					   int size, gfp_t gfp,
 					   void (*destroy)(void *))
-- 
MST
