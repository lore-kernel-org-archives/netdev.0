From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V4 04/10] ptr_ring: introduce batch dequeuing
Date: Wed, 10 May 2017 11:36:16 +0800
Message-ID: <1494387382-19916-5-git-send-email-jasowang@redhat.com>
References: <1494387382-19916-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494387382-19916-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduce a batched version of consuming, consumer can
dequeue more than one pointers from the ring at a time. We don't care
about the reorder of reading here so no need for compiler barrier.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/linux/ptr_ring.h | 65 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 65 insertions(+)

diff --git a/include/linux/ptr_ring.h b/include/linux/ptr_ring.h
index 796b90f..d8c97ec 100644
--- a/include/linux/ptr_ring.h
+++ b/include/linux/ptr_ring.h
@@ -278,6 +278,22 @@ static inline void *__ptr_ring_consume(struct ptr_ring *r)
 	return ptr;
 }
 
+static inline int __ptr_ring_consume_batched(struct ptr_ring *r,
+					     void **array, int n)
+{
+	void *ptr;
+	int i;
+
+	for (i = 0; i < n; i++) {
+		ptr = __ptr_ring_consume(r);
+		if (!ptr)
+			break;
+		array[i] = ptr;
+	}
+
+	return i;
+}
+
 /*
  * Note: resize (below) nests producer lock within consumer lock, so if you
  * call this in interrupt or BH context, you must disable interrupts/BH when
@@ -328,6 +344,55 @@ static inline void *ptr_ring_consume_bh(struct ptr_ring *r)
 	return ptr;
 }
 
+static inline int ptr_ring_consume_batched(struct ptr_ring *r,
+					   void **array, int n)
+{
+	int ret;
+
+	spin_lock(&r->consumer_lock);
+	ret = __ptr_ring_consume_batched(r, array, n);
+	spin_unlock(&r->consumer_lock);
+
+	return ret;
+}
+
+static inline int ptr_ring_consume_batched_irq(struct ptr_ring *r,
+					       void **array, int n)
+{
+	int ret;
+
+	spin_lock_irq(&r->consumer_lock);
+	ret = __ptr_ring_consume_batched(r, array, n);
+	spin_unlock_irq(&r->consumer_lock);
+
+	return ret;
+}
+
+static inline int ptr_ring_consume_batched_any(struct ptr_ring *r,
+					       void **array, int n)
+{
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&r->consumer_lock, flags);
+	ret = __ptr_ring_consume_batched(r, array, n);
+	spin_unlock_irqrestore(&r->consumer_lock, flags);
+
+	return ret;
+}
+
+static inline int ptr_ring_consume_batched_bh(struct ptr_ring *r,
+					      void **array, int n)
+{
+	int ret;
+
+	spin_lock_bh(&r->consumer_lock);
+	ret = __ptr_ring_consume_batched(r, array, n);
+	spin_unlock_bh(&r->consumer_lock);
+
+	return ret;
+}
+
 /* Cast to structure type and call a function without discarding from FIFO.
  * Function must return a value.
  * Callers must take consumer_lock.
-- 
2.7.4
