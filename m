From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC untested] ptr_ring: batched ring producer
Date: Wed, 12 Apr 2017 18:50:51 +0300
Message-ID: <1492011796-10922-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, brouer@redhat.com,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A known weakness in ptr_ring design is that it does not handle well the
situation when ring is almost empty: as entries are consumed they are
immediately used again by the producer, so consumer and producer keep
accessing/invalidating a shared cache line.

Batching seems to help somewhat but only if consumer is not
faster than producer. If it's faster, we still see lots of
cache line sharing.

Detect that consumer is fast by checking that there's enough space in
the ring for the whole batch.  In that case, write entries out in the
reverse order.  This removes cache sharing on all except the 1st line.

Notes:
	- as these are batched calls, it does not seem to be
	  worth-while to micro-optimize saving flags,
	  so a single _any variant is provided for now
	- vhost/tun would have to learn to use the batched
	  version if possible. We might need a producer_peek
	  variant that reports amount of space available.
	  Let me know and I'll write that.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

ringbench does not support batched produce yet so it'll take
me a bit of time to test this.
Posting untested for early feedback/flames.

Thanks!

 include/linux/ptr_ring.h | 54 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)

diff --git a/include/linux/ptr_ring.h b/include/linux/ptr_ring.h
index 6b2e0dd..783e7f5 100644
--- a/include/linux/ptr_ring.h
+++ b/include/linux/ptr_ring.h
@@ -163,6 +163,60 @@ static inline int ptr_ring_produce_bh(struct ptr_ring *r, void *ptr)
 	return ret;
 }
 
+
+static inline int ptr_ring_produce_batch_any(struct ptr_ring *r, void *ptr[], int batch)
+{
+	unsigned long flags;
+	int ret = -ENOSPC, n, i, producer;
+
+	spin_lock_irqsave(&r->producer_lock, flags);
+	if (unlikely(!batch)) {
+		ret = 0;
+		goto done;
+	}
+	if (unlikely(!r->size))
+		goto done;
+
+	producer = r->producer;
+	for (n = 0; n < batch; ++n) {
+		if (r->queue[producer]) {
+			break;
+		}
+		if (++producer >= r->size)
+			producer = 0;
+	}
+
+	if (!n)
+		goto done;
+
+	ret = n;
+
+	if (n < batch) {
+		/* Ring full. Produce normally. */
+		for (i = 0; i < n; ++i) {
+			r->queue[r->producer++] = ptr[i];
+			if (unlikely(r->producer >= r->size))
+				r->producer = 0;
+		}
+	} else {
+		/* Ring empty. Produce in the reverse order. */
+		for (i = n - 1; i >= 0; --i) {
+			if (--producer < 0)
+				producer = r->size - 1;
+			r->queue[producer] = ptr[i];
+		}
+		r->producer += batch;
+		if (unlikely(r->producer >= r->size))
+			r->producer -= r->size;
+	}
+
+
+done:
+	spin_unlock_irqrestore(&r->producer_lock, flags);
+
+	return ret;
+}
+
 /* Note: callers invoking this in a loop must use a compiler barrier,
  * for example cpu_relax(). Callers must take consumer_lock
  * if they dereference the pointer - see e.g. PTR_RING_PEEK_CALL.
-- 
MST
