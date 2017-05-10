From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V3 1/9] ptr_ring: add ptr_ring_unconsume
Date: Wed, 10 May 2017 10:37:53 +0800
Message-ID: <1494383881-6811-2-git-send-email-jasowang@redhat.com>
References: <1494383881-6811-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494383881-6811-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>

Applications that consume a batch of entries in one go
can benefit from ability to return some of them back
into the ring.

Add an API for that - assuming there's space. If there's no space
naturally can't do this and have to drop entries, but this implies ring
is full so we'd likely drop some anyway.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/linux/ptr_ring.h | 55 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 55 insertions(+)

diff --git a/include/linux/ptr_ring.h b/include/linux/ptr_ring.h
index 6c70444..5476f68 100644
--- a/include/linux/ptr_ring.h
+++ b/include/linux/ptr_ring.h
@@ -359,6 +359,61 @@ static inline int ptr_ring_init(struct ptr_ring *r, int size, gfp_t gfp)
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
+	while (n) {
+		head = r->consumer_head - 1;
+		if (head < 0)
+			head = r->size - 1;
+		if (r->queue[head]) {
+			/* This batch entry will have to be destroyed. */
+			goto done;
+		}
+		r->queue[head] = batch[--n];
+		r->consumer_tail = r->consumer_head = head;
+	}
+
+done:
+	/* Destroy all entries left in the batch. */
+	while (n)
+		destroy(batch[--n]);
+	spin_unlock(&r->producer_lock);
+	spin_unlock_irqrestore(&r->consumer_lock, flags);
+}
+
 static inline void **__ptr_ring_swap_queue(struct ptr_ring *r, void **queue,
 					   int size, gfp_t gfp,
 					   void (*destroy)(void *))
-- 
2.7.4
