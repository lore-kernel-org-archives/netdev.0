From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 1/2] net: use cmpxchg instead of spinlock in ptr rings
Date: Thu, 10 Nov 2016 20:44:08 -0800
Message-ID: <20161111044408.1547.92737.stgit@john-Precision-Tower-5810>
References: <20161111043857.1547.70337.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161111043857.1547.70337.stgit@john-Precision-Tower-5810>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


---
 include/linux/ptr_ring_ll.h |  136 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/skb_array.h   |   25 ++++++++
 2 files changed, 161 insertions(+)
 create mode 100644 include/linux/ptr_ring_ll.h

diff --git a/include/linux/ptr_ring_ll.h b/include/linux/ptr_ring_ll.h
new file mode 100644
index 0000000..bcb11f3
--- /dev/null
+++ b/include/linux/ptr_ring_ll.h
@@ -0,0 +1,136 @@
+/*
+ *	Definitions for the 'struct ptr_ring_ll' datastructure.
+ *
+ *	Author:
+ *		John Fastabend <john.r.fastabend@intel.com>
+ *
+ *	Copyright (C) 2016 Intel Corp.
+ *
+ *	This program is free software; you can redistribute it and/or modify it
+ *	under the terms of the GNU General Public License as published by the
+ *	Free Software Foundation; either version 2 of the License, or (at your
+ *	option) any later version.
+ *
+ *	This is a limited-size FIFO maintaining pointers in FIFO order, with
+ *	one CPU producing entries and another consuming entries from a FIFO.
+ *	extended from ptr_ring_ll to use cmpxchg over spin lock.
+ */
+
+#ifndef _LINUX_PTR_RING_LL_H
+#define _LINUX_PTR_RING_LL_H 1
+
+#ifdef __KERNEL__
+#include <linux/spinlock.h>
+#include <linux/cache.h>
+#include <linux/types.h>
+#include <linux/compiler.h>
+#include <linux/cache.h>
+#include <linux/slab.h>
+#include <asm/errno.h>
+#endif
+
+struct ptr_ring_ll {
+	u32 prod_size;
+	u32 prod_mask;
+	u32 prod_head;
+	u32 prod_tail;
+	u32 cons_size;
+	u32 cons_mask;
+	u32 cons_head;
+	u32 cons_tail;
+
+	void **queue;
+};
+
+/* Note: callers invoking this in a loop must use a compiler barrier,
+ * for example cpu_relax(). Callers must hold producer_lock.
+ */
+static inline int __ptr_ring_ll_produce(struct ptr_ring_ll *r, void *ptr)
+{
+	u32 ret, head, tail, next, slots, mask;
+
+	do {
+		head = READ_ONCE(r->prod_head);
+		mask = READ_ONCE(r->prod_mask);
+		tail = READ_ONCE(r->cons_tail);
+
+		slots = mask + tail - head;
+		if (slots < 1)
+			return -ENOMEM;
+
+		next = head + 1;
+		ret = cmpxchg(&r->prod_head, head, next);
+	} while (ret != head);
+
+	r->queue[head & mask] = ptr;
+	smp_wmb();
+
+	while (r->prod_tail != head)
+		cpu_relax();
+
+	r->prod_tail = next;
+	return 0;
+}
+
+static inline void *__ptr_ring_ll_consume(struct ptr_ring_ll *r)
+{
+	u32 ret, head, tail, next, slots, mask;
+	void *ptr;
+
+	do {
+		head = READ_ONCE(r->cons_head);
+		mask = READ_ONCE(r->cons_mask);
+		tail = READ_ONCE(r->prod_tail);
+
+		slots = tail - head;
+		if (slots < 1)
+			return ERR_PTR(-ENOMEM);
+
+		next = head + 1;
+		ret = cmpxchg(&r->cons_head, head, next);
+	} while (ret != head);
+
+	ptr = r->queue[head & mask];
+	smp_rmb();
+
+	while (r->cons_tail != head)
+		cpu_relax();
+
+	r->cons_tail = next;
+	return ptr;
+}
+
+static inline void **__ptr_ring_ll_init_queue_alloc(int size, gfp_t gfp)
+{
+	return kzalloc(ALIGN(size * sizeof(void *), SMP_CACHE_BYTES), gfp);
+}
+
+static inline int ptr_ring_ll_init(struct ptr_ring_ll *r, int size, gfp_t gfp)
+{
+	r->queue = __ptr_ring_init_queue_alloc(size, gfp);
+	if (!r->queue)
+		return -ENOMEM;
+
+	r->prod_size = r->cons_size = size;
+	r->prod_mask = r->cons_mask = size - 1;
+	r->prod_tail = r->prod_head = 0;
+	r->cons_tail = r->prod_tail = 0;
+
+	return 0;
+}
+
+static inline void ptr_ring_ll_cleanup(struct ptr_ring_ll *r, void (*destroy)(void *))
+{
+	if (destroy) {
+		void *ptr;
+
+		ptr = __ptr_ring_ll_consume(r);
+		while (!IS_ERR_OR_NULL(ptr)) {
+			destroy(ptr);
+			ptr = __ptr_ring_ll_consume(r);
+		}
+	}
+	kfree(r->queue);
+}
+
+#endif /* _LINUX_PTR_RING_LL_H  */
diff --git a/include/linux/skb_array.h b/include/linux/skb_array.h
index f4dfade..9b43dfd 100644
--- a/include/linux/skb_array.h
+++ b/include/linux/skb_array.h
@@ -22,6 +22,7 @@
 
 #ifdef __KERNEL__
 #include <linux/ptr_ring.h>
+#include <linux/ptr_ring_ll.h>
 #include <linux/skbuff.h>
 #include <linux/if_vlan.h>
 #endif
@@ -30,6 +31,10 @@ struct skb_array {
 	struct ptr_ring ring;
 };
 
+struct skb_array_ll {
+	struct ptr_ring_ll ring;
+};
+
 /* Might be slightly faster than skb_array_full below, but callers invoking
  * this in a loop must use a compiler barrier, for example cpu_relax().
  */
@@ -43,6 +48,11 @@ static inline bool skb_array_full(struct skb_array *a)
 	return ptr_ring_full(&a->ring);
 }
 
+static inline int skb_array_ll_produce(struct skb_array_ll *a, struct sk_buff *skb)
+{
+	return __ptr_ring_ll_produce(&a->ring, skb);
+}
+
 static inline int skb_array_produce(struct skb_array *a, struct sk_buff *skb)
 {
 	return ptr_ring_produce(&a->ring, skb);
@@ -92,6 +102,11 @@ static inline bool skb_array_empty_any(struct skb_array *a)
 	return ptr_ring_empty_any(&a->ring);
 }
 
+static inline struct sk_buff *skb_array_ll_consume(struct skb_array_ll *a)
+{
+	return __ptr_ring_ll_consume(&a->ring);
+}
+
 static inline struct sk_buff *skb_array_consume(struct skb_array *a)
 {
 	return ptr_ring_consume(&a->ring);
@@ -146,6 +161,11 @@ static inline int skb_array_peek_len_any(struct skb_array *a)
 	return PTR_RING_PEEK_CALL_ANY(&a->ring, __skb_array_len_with_tag);
 }
 
+static inline int skb_array_ll_init(struct skb_array_ll *a, int size, gfp_t gfp)
+{
+	return ptr_ring_ll_init(&a->ring, size, gfp);
+}
+
 static inline int skb_array_init(struct skb_array *a, int size, gfp_t gfp)
 {
 	return ptr_ring_init(&a->ring, size, gfp);
@@ -170,6 +190,11 @@ static inline int skb_array_resize_multiple(struct skb_array **rings,
 					__skb_array_destroy_skb);
 }
 
+static inline void skb_array_ll_cleanup(struct skb_array_ll *a)
+{
+	ptr_ring_ll_cleanup(&a->ring, __skb_array_destroy_skb);
+}
+
 static inline void skb_array_cleanup(struct skb_array *a)
 {
 	ptr_ring_cleanup(&a->ring, __skb_array_destroy_skb);
