From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 01/12] lib: array based lock free queue
Date: Wed, 30 Dec 2015 09:51:03 -0800
Message-ID: <20151230175103.26257.75334.stgit@john-Precision-Tower-5810>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com
To: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33312 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755044AbbL3RvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:51:24 -0500
Received: by mail-pa0-f47.google.com with SMTP id cy9so141161457pac.0
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 09:51:24 -0800 (PST)
In-Reply-To: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initial implementation of an array based lock free queue. This works
is originally done by Jesper Dangaard Brouer and I've grabbed it made
only minor tweaks at the moment and plan to use it with the 'tc'
subsystem although it is general enough to be used elsewhere.

Certainly this implementation can be furthered optimized and improved
but it is a good base implementation.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/alf_queue.h |  368 +++++++++++++++++++++++++++++++++++++++++++++
 lib/Makefile              |    2 
 lib/alf_queue.c           |   42 +++++
 3 files changed, 411 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/alf_queue.h
 create mode 100644 lib/alf_queue.c

diff --git a/include/linux/alf_queue.h b/include/linux/alf_queue.h
new file mode 100644
index 0000000..dac304e
--- /dev/null
+++ b/include/linux/alf_queue.h
@@ -0,0 +1,368 @@
+#ifndef _LINUX_ALF_QUEUE_H
+#define _LINUX_ALF_QUEUE_H
+/* linux/alf_queue.h
+ *
+ * ALF: Array-based Lock-Free queue
+ *
+ * Queue properties
+ *  - Array based for cache-line optimization
+ *  - Bounded by the array size
+ *  - FIFO Producer/Consumer queue, no queue traversal supported
+ *  - Very fast
+ *  - Designed as a queue for pointers to objects
+ *  - Bulk enqueue and dequeue support
+ *  - Supports combinations of Multi and Single Producer/Consumer
+ *
+ * Copyright (C) 2014, Red Hat, Inc.,
+ *  by Jesper Dangaard Brouer and Hannes Frederic Sowa
+ *  for licensing details see kernel-base/COPYING
+ */
+#include <linux/compiler.h>
+#include <linux/kernel.h>
+
+struct alf_actor {
+	u32 head;
+	u32 tail;
+};
+
+struct alf_queue {
+	u32 size;
+	u32 mask;
+	u32 flags;
+	struct alf_actor producer ____cacheline_aligned_in_smp;
+	struct alf_actor consumer ____cacheline_aligned_in_smp;
+	void *ring[0] ____cacheline_aligned_in_smp;
+};
+
+struct alf_queue *alf_queue_alloc(u32 size, gfp_t gfp);
+void		  alf_queue_free(struct alf_queue *q);
+
+/* Helpers for LOAD and STORE of elements, have been split-out because:
+ *  1. They can be reused for both "Single" and "Multi" variants
+ *  2. Allow us to experiment with (pipeline) optimizations in this area.
+ */
+/* Only a single of these helpers will survive upstream submission */
+#define __helper_alf_enqueue_store __helper_alf_enqueue_store_unroll
+#define __helper_alf_dequeue_load  __helper_alf_dequeue_load_unroll
+
+static inline void
+__helper_alf_enqueue_store_unroll(u32 p_head, struct alf_queue *q,
+				  void **ptr, const u32 n)
+{
+	int i, iterations = n & ~3UL;
+	u32 index = p_head & q->mask;
+
+	if (likely((index + n) <= q->mask)) {
+		/* Can save masked-AND knowing we cannot wrap */
+		/* Loop unroll */
+		for (i = 0; i < iterations; i += 4, index += 4) {
+			q->ring[index]   = ptr[i];
+			q->ring[index+1] = ptr[i+1];
+			q->ring[index+2] = ptr[i+2];
+			q->ring[index+3] = ptr[i+3];
+		}
+		/* Remainder handling */
+		switch (n & 0x3) {
+		case 3:
+			q->ring[index]   = ptr[i];
+			q->ring[index+1] = ptr[i+1];
+			q->ring[index+2] = ptr[i+2];
+			break;
+		case 2:
+			q->ring[index]   = ptr[i];
+			q->ring[index+1] = ptr[i+1];
+			break;
+		case 1:
+			q->ring[index] = ptr[i];
+		}
+	} else {
+		/* Fall-back to "mask" version */
+		for (i = 0; i < n; i++, index++)
+			q->ring[index & q->mask] = ptr[i];
+	}
+}
+
+static inline void
+__helper_alf_dequeue_load_unroll(u32 c_head, struct alf_queue *q,
+				 void **ptr, const u32 elems)
+{
+	int i, iterations = elems & ~3UL;
+	u32 index = c_head & q->mask;
+
+	if (likely((index + elems) <= q->mask)) {
+		/* Can save masked-AND knowing we cannot wrap */
+		/* Loop unroll */
+		for (i = 0; i < iterations; i += 4, index += 4) {
+			ptr[i]   = q->ring[index];
+			ptr[i+1] = q->ring[index+1];
+			ptr[i+2] = q->ring[index+2];
+			ptr[i+3] = q->ring[index+3];
+		}
+		/* Remainder handling */
+		switch (elems & 0x3) {
+		case 3:
+			ptr[i]   = q->ring[index];
+			ptr[i+1] = q->ring[index+1];
+			ptr[i+2] = q->ring[index+2];
+			break;
+		case 2:
+			ptr[i]   = q->ring[index];
+			ptr[i+1] = q->ring[index+1];
+			break;
+		case 1:
+			ptr[i]   = q->ring[index];
+		}
+	} else {
+		/* Fall-back to "mask" version */
+		for (i = 0; i < elems; i++, index++)
+			ptr[i] = q->ring[index & q->mask];
+	}
+}
+
+/* Main Multi-Producer ENQUEUE
+ *
+ * Even-though current API have a "fixed" semantics of aborting if it
+ * cannot enqueue the full bulk size.  Users of this API should check
+ * on the returned number of enqueue elements match, to verify enqueue
+ * was successful.  This allow us to introduce a "variable" enqueue
+ * scheme later.
+ *
+ * Not preemption safe. Multiple CPUs can enqueue elements, but the
+ * same CPU is not allowed to be preempted and access the same
+ * queue. Due to how the tail is updated, this can result in a soft
+ * lock-up. (Same goes for alf_mc_dequeue).
+ */
+static inline int
+alf_mp_enqueue(const u32 n;
+	       struct alf_queue *q, void *ptr[n], const u32 n)
+{
+	u32 p_head, p_next, c_tail, space;
+
+	/* Reserve part of the array for enqueue STORE/WRITE */
+	do {
+		p_head = ACCESS_ONCE(q->producer.head);
+		c_tail = ACCESS_ONCE(q->consumer.tail);/* as smp_load_aquire */
+
+		space = q->size + c_tail - p_head;
+		if (n > space)
+			return 0;
+
+		p_next = p_head + n;
+	}
+	while (unlikely(cmpxchg(&q->producer.head, p_head, p_next) != p_head));
+
+	/* The memory barrier of smp_load_acquire(&q->consumer.tail)
+	 * is satisfied by cmpxchg implicit full memory barrier
+	 */
+
+	/* STORE the elems into the queue array */
+	__helper_alf_enqueue_store(p_head, q, ptr, n);
+	smp_wmb(); /* Write-Memory-Barrier matching dequeue LOADs */
+
+	/* Wait for other concurrent preceding enqueues not yet done,
+	 * this part make us none-wait-free and could be problematic
+	 * in case of congestion with many CPUs
+	 */
+	while (unlikely(ACCESS_ONCE(q->producer.tail) != p_head))
+		cpu_relax();
+	/* Mark this enq done and avail for consumption */
+	ACCESS_ONCE(q->producer.tail) = p_next;
+
+	return n;
+}
+
+/* Main Multi-Consumer DEQUEUE */
+static inline int
+alf_mc_dequeue(const u32 n;
+	       struct alf_queue *q, void *ptr[n], const u32 n)
+{
+	u32 c_head, c_next, p_tail, elems;
+
+	/* Reserve part of the array for dequeue LOAD/READ */
+	do {
+		c_head = ACCESS_ONCE(q->consumer.head);
+		p_tail = ACCESS_ONCE(q->producer.tail);
+
+		elems = p_tail - c_head;
+
+		if (elems == 0)
+			return 0;
+		else
+			elems = min(elems, n);
+
+		c_next = c_head + elems;
+	}
+	while (unlikely(cmpxchg(&q->consumer.head, c_head, c_next) != c_head));
+
+	/* LOAD the elems from the queue array.
+	 *   We don't need a smb_rmb() Read-Memory-Barrier here because
+	 *   the above cmpxchg is an implied full Memory-Barrier.
+	 */
+	__helper_alf_dequeue_load(c_head, q, ptr, elems);
+
+	/* Wait for other concurrent preceding dequeues not yet done */
+	while (unlikely(ACCESS_ONCE(q->consumer.tail) != c_head))
+		cpu_relax();
+	/* Mark this deq done and avail for producers */
+	smp_store_release(&q->consumer.tail, c_next);
+	/* Archs with weak Memory Ordering need a memory barrier
+	 * (store_release) here.  As the STORE to q->consumer.tail,
+	 * must happen after the dequeue LOADs.  Paired with enqueue
+	 * implicit full-MB in cmpxchg.
+	 */
+
+	return elems;
+}
+
+/* #define ASSERT_DEBUG_SPSC 1 */
+#ifndef ASSERT_DEBUG_SPSC
+#define ASSERT(x) do { } while (0)
+#else
+#define ASSERT(x)							\
+	do {								\
+		if (unlikely(!(x))) {					\
+			pr_crit("Assertion failed %s:%d: \"%s\"\n",	\
+				__FILE__, __LINE__, #x);		\
+			BUG();						\
+		}							\
+	} while (0)
+#endif
+
+/* Main SINGLE Producer ENQUEUE
+ *  caller MUST make sure preemption is disabled
+ */
+static inline int
+alf_sp_enqueue(const u32 n;
+	       struct alf_queue *q, void *ptr[n], const u32 n)
+{
+	u32 p_head, p_next, c_tail, space;
+
+	/* Reserve part of the array for enqueue STORE/WRITE */
+	p_head = q->producer.head;
+	smp_rmb(); /* for consumer.tail write, making sure deq loads are done */
+	c_tail = ACCESS_ONCE(q->consumer.tail);
+
+	space = q->size + c_tail - p_head;
+	if (n > space)
+		return 0;
+
+	p_next = p_head + n;
+	ASSERT(ACCESS_ONCE(q->producer.head) == p_head);
+	q->producer.head = p_next;
+
+	/* STORE the elems into the queue array */
+	__helper_alf_enqueue_store(p_head, q, ptr, n);
+	smp_wmb(); /* Write-Memory-Barrier matching dequeue LOADs */
+
+	/* Assert no other CPU (or same CPU via preemption) changed queue */
+	ASSERT(ACCESS_ONCE(q->producer.tail) == p_head);
+
+	/* Mark this enq done and avail for consumption */
+	ACCESS_ONCE(q->producer.tail) = p_next;
+
+	return n;
+}
+
+/* Main SINGLE Consumer DEQUEUE
+ *  caller MUST make sure preemption is disabled
+ */
+static inline int
+alf_sc_dequeue(const u32 n;
+	       struct alf_queue *q, void *ptr[n], const u32 n)
+{
+	u32 c_head, c_next, p_tail, elems;
+
+	/* Reserve part of the array for dequeue LOAD/READ */
+	c_head = q->consumer.head;
+	p_tail = ACCESS_ONCE(q->producer.tail);
+
+	elems = p_tail - c_head;
+
+	if (elems == 0)
+		return 0;
+	else
+		elems = min(elems, n);
+
+	c_next = c_head + elems;
+	ASSERT(ACCESS_ONCE(q->consumer.head) == c_head);
+	q->consumer.head = c_next;
+
+	smp_rmb(); /* Read-Memory-Barrier matching enq STOREs */
+	__helper_alf_dequeue_load(c_head, q, ptr, elems);
+
+	/* Archs with weak Memory Ordering need a memory barrier here.
+	 * As the STORE to q->consumer.tail, must happen after the
+	 * dequeue LOADs. Dequeue LOADs have a dependent STORE into
+	 * ptr, thus a smp_wmb() is enough.
+	 */
+	smp_wmb();
+
+	/* Assert no other CPU (or same CPU via preemption) changed queue */
+	ASSERT(ACCESS_ONCE(q->consumer.tail) == c_head);
+
+	/* Mark this deq done and avail for producers */
+	ACCESS_ONCE(q->consumer.tail) = c_next;
+
+	return elems;
+}
+
+static inline bool
+alf_queue_empty(struct alf_queue *q)
+{
+	u32 c_tail = ACCESS_ONCE(q->consumer.tail);
+	u32 p_tail = ACCESS_ONCE(q->producer.tail);
+
+	/* The empty (and initial state) is when consumer have reached
+	 * up with producer.
+	 *
+	 * DOUBLE-CHECK: Should we use producer.head, as this indicate
+	 * a producer is in-progress(?)
+	 */
+	return c_tail == p_tail;
+}
+
+static inline int
+alf_queue_count(struct alf_queue *q)
+{
+	u32 c_head = ACCESS_ONCE(q->consumer.head);
+	u32 p_tail = ACCESS_ONCE(q->producer.tail);
+	u32 elems;
+
+	/* Due to u32 arithmetic the values are implicitly
+	 * masked/modulo 32-bit, thus saving one mask operation
+	 */
+	elems = p_tail - c_head;
+	/* Thus, same as:
+	 *  elems = (p_tail - c_head) & q->mask;
+	 */
+	return elems;
+}
+
+static inline int
+alf_queue_avail_space(struct alf_queue *q)
+{
+	u32 p_head = ACCESS_ONCE(q->producer.head);
+	u32 c_tail = ACCESS_ONCE(q->consumer.tail);
+	u32 space;
+
+	/* The max avail space is q->size and
+	 * the empty state is when (consumer == producer)
+	 */
+
+	/* Due to u32 arithmetic the values are implicitly
+	 * masked/modulo 32-bit, thus saving one mask operation
+	 */
+	space = q->size + c_tail - p_head;
+	/* Thus, same as:
+	 *  space = (q->size + c_tail - p_head) & q->mask;
+	 */
+	return space;
+}
+
+static inline void
+alf_queue_flush(struct alf_queue *q)
+{
+
+}
+
+#endif /* _LINUX_ALF_QUEUE_H */
diff --git a/lib/Makefile b/lib/Makefile
index 180dd4d..6b7b161 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -27,7 +27,7 @@ obj-y += bcd.o div64.o sort.o parser.o halfmd4.o debug_locks.o random32.o \
 	 gcd.o lcm.o list_sort.o uuid.o flex_array.o iov_iter.o clz_ctz.o \
 	 bsearch.o find_bit.o llist.o memweight.o kfifo.o \
 	 percpu-refcount.o percpu_ida.o rhashtable.o reciprocal_div.o \
-	 once.o
+	 once.o alf_queue.o
 obj-y += string_helpers.o
 obj-$(CONFIG_TEST_STRING_HELPERS) += test-string_helpers.o
 obj-y += hexdump.o
diff --git a/lib/alf_queue.c b/lib/alf_queue.c
new file mode 100644
index 0000000..ac026ad
--- /dev/null
+++ b/lib/alf_queue.c
@@ -0,0 +1,42 @@
+/*
+ * lib/alf_queue.c
+ *
+ * ALF: Array-based Lock-Free queue
+ *  - Main implementation in: include/linux/alf_queue.h
+ *
+ * Copyright (C) 2014, Red Hat, Inc.,
+ *  by Jesper Dangaard Brouer and Hannes Frederic Sowa
+ */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/alf_queue.h>
+#include <linux/log2.h>
+
+struct alf_queue *alf_queue_alloc(u32 size, gfp_t gfp)
+{
+	struct alf_queue *q;
+	size_t mem_size;
+
+	if (!(is_power_of_2(size)) || size > 65536)
+		return ERR_PTR(-EINVAL);
+
+	/* The ring array is allocated together with the queue struct */
+	mem_size = size * sizeof(void *) + sizeof(struct alf_queue);
+	q = kzalloc(mem_size, gfp);
+	if (!q)
+		return ERR_PTR(-ENOMEM);
+
+	q->size = size;
+	q->mask = size - 1;
+
+	return q;
+}
+EXPORT_SYMBOL_GPL(alf_queue_alloc);
+
+void alf_queue_free(struct alf_queue *q)
+{
+	kfree(q);
+}
+EXPORT_SYMBOL_GPL(alf_queue_free);
