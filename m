From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v2] skb_array: array based FIFO for skbs
Date: Thu, 19 May 2016 15:15:30 +0300
Message-ID: <1463659932-14570-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>, brouer@redhat.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A simple array based FIFO of pointers.  Intended for net stack so uses
skbs for type safety, but we can replace with with void * if others find
it useful outside of net stack.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Still untested, fixed the bug pointed out by Eric.
Posting since several people expressed interest in
helping test this.

Note: SKB_ARRAY_MIN_SIZE is a heuristic. It can be increased
to more than 2 cache lines, or even to INT_MAX to disable
the heuristic completely.

 include/linux/skb_array.h | 115 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 115 insertions(+)
 create mode 100644 include/linux/skb_array.h

diff --git a/include/linux/skb_array.h b/include/linux/skb_array.h
new file mode 100644
index 0000000..fd4ff23
--- /dev/null
+++ b/include/linux/skb_array.h
@@ -0,0 +1,115 @@
+/*
+ * See Documentation/skb-array.txt for more information.
+ */
+
+#ifndef _LINUX_SKB_ARRAY_H
+#define _LINUX_SKB_ARRAY_H 1
+
+#include <linux/spinlock.h>
+#include <linux/cache.h>
+#include <linux/types.h>
+#include <linux/compiler.h>
+#include <linux/cache.h>
+#include <linux/slab.h>
+#include <asm/errno.h>
+
+struct sk_buff;
+
+struct skb_array {
+	int producer ____cacheline_aligned_in_smp;
+	spinlock_t producer_lock;
+	int consumer ____cacheline_aligned_in_smp;
+	spinlock_t consumer_lock;
+	/* Shared consumer/producer data */
+	int size ____cacheline_aligned_in_smp; /* max entries in queue */
+	struct sk_buff **queue;
+};
+
+#define SKB_ARRAY_MIN_SIZE (2 * (0x1 << cache_line_size()) / \
+			    sizeof (struct sk_buff *))
+
+static inline int __skb_array_produce(struct skb_array *a,
+				       struct sk_buff *skb)
+{
+	/* Try to start from beginning: good for cache utilization as we'll
+	 * keep reusing the same cache line.
+	 * Produce at least SKB_ARRAY_MIN_SIZE entries before trying to do this,
+	 * to reduce bouncing cache lines between them.
+	 */
+	if (a->producer >= SKB_ARRAY_MIN_SIZE && !a->queue[0])
+		a->producer = 0;
+	if (a->queue[a->producer])
+		return -ENOSPC;
+	a->queue[a->producer] = skb;
+	if (unlikely(++a->producer > a->size))
+		a->producer = 0;
+	return 0;
+}
+
+static inline int skb_array_produce_bh(struct skb_array *a,
+				       struct sk_buff *skb)
+{
+	int ret;
+
+	spin_lock_bh(&a->producer_lock);
+	ret = __skb_array_produce(a, skb);
+	spin_unlock_bh(&a->producer_lock);
+
+	return ret;
+}
+
+static inline struct sk_buff *__skb_array_peek(struct skb_array *a)
+{
+	if (a->queue[a->consumer])
+		return a->queue[a->consumer];
+
+	/* Check whether producer started at the beginning. */
+	if (unlikely(a->consumer >= SKB_ARRAY_MIN_SIZE && a->queue[0])) {
+		a->consumer = 0;
+		return a->queue[0];
+	}
+
+	return NULL;
+}
+
+static inline void __skb_array_consume(struct skb_array *a)
+{
+	a->queue[a->consumer++] = NULL;
+	if (unlikely(a->consumer > a->size))
+		a->consumer = 0;
+}
+
+static inline struct sk_buff *skb_array_consume_bh(struct skb_array *a)
+{
+	struct sk_buff *skb;
+
+	spin_lock_bh(&a->producer_lock);
+	skb = __skb_array_peek(a);
+	if (skb)
+		__skb_array_consume(a);
+	spin_unlock_bh(&a->producer_lock);
+
+	return skb;
+}
+
+static inline int skb_array_init(struct skb_array *a, int size, gfp_t gfp)
+{
+	a->queue = kmalloc(ALIGN(size * sizeof *(a->queue), SMP_CACHE_BYTES),
+			   gfp);
+	if (!a->queue)
+		return -ENOMEM;
+
+	a->size = size;
+	a->producer = a->consumer = 0;
+	spin_lock_init(&a->producer_lock);
+	spin_lock_init(&a->consumer_lock);
+
+	return 0;
+}
+
+static inline void skb_array_cleanup(struct skb_array *a)
+{
+	kfree(a->queue);
+}
+
+#endif /* _LINUX_SKB_ARRAY_H  */
-- 
MST
