From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] tuntap: introduce tx skb ring
Date: Wed, 18 May 2016 19:26:38 +0300
Message-ID: <20160518191148-mutt-send-email-mst@redhat.com>
References: <1463361421-4397-1-git-send-email-jasowang@redhat.com>
 <1463370998.18194.74.camel@edumazet-glaptop3.roam.corp.google.com>
 <57397C14.1080701@redhat.com>
 <20160518101359.37f5343b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160518101359.37f5343b@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2016 at 10:13:59AM +0200, Jesper Dangaard Brouer wrote:
> I agree. It is sad to see everybody is implementing the same thing,
> open coding an array/circular based ring buffer.  This kind of code is
> hard to maintain and get right with barriers etc.  We can achieve the
> same performance with a generic implementation, by inlining the help
> function calls.

So my testing seems to show that at least for the common usecase
in networking, which isn't lockless, circular buffer
with indices does not perform that well, because
each index access causes a cache line to bounce between
CPUs, and index access causes stalls due to the dependency.

By comparison, an array of pointers where NULL means invalid
and !NULL means valid, can be updated without messing up barriers
at all and does not have this issue.

You also mentioned cache pressure caused by using large queues, and I
think it's a significant issue. tun has a queue of 1000 entries by
default and that's 8K already.

So, I had an idea: with an array of pointers we could actually use
only part of the ring as long as it stays mostly empty.
We do want to fill at least two cache lines to prevent producer
and consumer from writing over the same cache line all the time.
This is SKB_ARRAY_MIN_SIZE logic below.

Pls take a look at the implementation below.  It's a straight port from virtio
unit test, so should work fine, except the SKB_ARRAY_MIN_SIZE hack that
I added.  Today I run out of time for testing this.  Posting for early
flames/feedback.

It's using skb pointers but we switching to void * would be easy at cost
of type safety, though it appears that people want lockless  push
etc so I'm not sure of the value.

--->
skb_array: array based FIFO for skbs

A simple array based FIFO of pointers.
Intended for net stack so uses skbs for type
safety, but we can replace with with void *
if others find it useful outside of net stack.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/include/linux/skb_array.h b/include/linux/skb_array.h
new file mode 100644
index 0000000..a67cc8b
--- /dev/null
+++ b/include/linux/skb_array.h
@@ -0,0 +1,116 @@
+/*
+ * See Documentation/skbular-buffers.txt for more information.
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
+	if (unlikely(++a->consumer > a->size))
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
