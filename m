From: David VomLehn <dvomlehn@cisco.com>
Subject: [PATCH][RFC] Check sk_buff states
Date: Mon, 7 Jun 2010 17:30:55 -0700
Message-ID: <20100608003055.GA29405@dvomlehn-lnx2.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: to@dvomlehn-lnx2.corp.sa.net, "netdev@vger.kernel.org"@cisco.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:42356 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376Ab0FHAa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 20:30:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This uses the oobparam and callsite infrastructure to implement sk_buff
state checking and error reporting. Possible states of an sk_buff are:
	SKB_STATE_FREE - Is not currently in use
	SKB_STATE_ALLOCATED - Has been allocated, but is not on a queue
	SKB_STATE_QUEUED - Is allocated and on a queue
Since there are only three states, two bits suffice to record the state of
an sk_buff structure, so checking for consistent state is easy. (For you
weenies, the fourth possible state *is* flagged as an error).

Some of the errors that can be detected are:
o	Double-freeing an skb_buff
o	Using kfree() instead of kfree_skb()
o	Queuing an sk_buffer that is already on a queue

Notes
o	Under relatively simple test conditions, .i.e. one Ethernet interface
	using an NFS filesystem, the number of call site IDs allocated
	can be quite small, small enough to fit in 6 bits. That would reduce
	the sk_buff growth to one byte. This is *not* a recommended
	configuration.

Restrictions
o	This code relies on fact that sk_buff memory is allocated from
	dedicated kmem_caches. Specifically:
	1.	It uses kmem_cache constructors to initialize fields used for
		checking state.
	2.	It assumes that the fields used to check state will either:
		a.	Not be modified between calling kmem_cache_free and
			kmem_cache_alloc_node, or
		b.	The kmem_cache constructor, will be called.
o	Since the state and callsite ID must not be zeroed by __alloc_skb(),
	it may not be possible to squeeze them into existing padding in
	the sk_buff structure. If so, the addition size added might be larger
	than the 12 bits presently configured.
o	There is some chance that use of kfree() instead of skb_free() will
	not be detected. Normally, when the skbuff freed with kfree() is
	reallocated, its state will still be SKB_STATE_ALLOCATED. Since
	alloc_skb() expects the state to be SKB_STATE_FREE, the error will
	be caught.  However, if the slab used for the skbuff gets returned
	to the buddy allocator and then reallocated to the kmem_cache,
	it will get re-initialized. This will set its state to SKB_STATE_FREE.
	Returning a slab to the buddy allocator is done much less frequently
	than allocation and freeing, so the bulk of these errors will be
	found.
o	Though this code should not have much of a performance or size
	impact, careful consideration should be given before enabling it
	in a production version of the kernel.

History
v2	Reduce the per-sk_buff overhead by shrinking the state and using
	call site IDs. Instead of storing the last allocation and free, only
	store the last state-changing operation.
v1	Original version

Signed-off-by: David VomLehn <dvomlehn@cisco.com>
---
 include/linux/sched.h  |    5 +
 include/linux/skbuff.h |  279 +++++++++++++++++++++++++++++++++++++++++++++++-
 kernel/fork.c          |    3 +
 kernel/module.c        |    2 +
 lib/Kconfig.debug      |   53 +++++++++
 net/core/Makefile      |    2 +-
 net/core/skbuff.c      |  188 ++++++++++++++++++++++++++++++++-
 7 files changed, 523 insertions(+), 9 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index f118809..e6a39e1 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -91,6 +91,7 @@ struct sched_param {
 #include <linux/kobject.h>
 #include <linux/latencytop.h>
 #include <linux/cred.h>
+#include <net/callsite-types.h>
 
 #include <asm/processor.h>
 
@@ -1389,6 +1390,10 @@ struct task_struct {
 	int softirqs_enabled;
 	int softirq_context;
 #endif
+#ifdef CONFIG_DEBUG_SKB_STATE_CHANGES
+	/* Stack of calls using callsite ID logging */
+	CALLSITE_TOP(skb_callsite_top);
+#endif
 #ifdef CONFIG_LOCKDEP
 # define MAX_LOCK_DEPTH 48UL
 	u64 curr_chain_key;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bf243fc..0bd52ea 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -29,6 +29,7 @@
 #include <linux/rcupdate.h>
 #include <linux/dmaengine.h>
 #include <linux/hrtimer.h>
+#include <net/callsite.h>
 
 /* Don't change this without changing skb_csum_unnecessary! */
 #define CHECKSUM_NONE 0
@@ -88,7 +89,7 @@
  *			  about CHECKSUM_UNNECESSARY. 8)
  *	NETIF_F_IPV6_CSUM about as dumb as the last one but does IPv6 instead.
  *
- *	Any questions? No questions, good. 		--ANK
+ *	Any questions? No questions, good.		--ANK
  */
 
 struct net_device;
@@ -254,6 +255,32 @@ typedef unsigned int sk_buff_data_t;
 typedef unsigned char *sk_buff_data_t;
 #endif
 
+/* States for a struct sk_buff */
+enum skb_check_state {
+	SKB_STATE_INVALID,	/* Zero is a common corruption value, so make
+				 * an invalid value */
+	SKB_STATE_FREE,		/* sk_buff is not allocated */
+	SKB_STATE_ALLOCATED,	/* In used, but not queued */
+	SKB_STATE_QUEUED,	/* On a queue */
+	SKB_STATE_NUM		/* Number of states */
+};
+
+#define SKB_VALIDATE_STATE_SIZE			2 /* ilog2(SKB_STATE_NUM) */
+
+/*
+ * Convert an skb_check to the corresponding mask
+ * @state:	The skb_check value to convert
+ * Returns the mask
+ */
+static inline unsigned skb_check2mask(enum skb_check_state state)
+{
+	return 1u << state;
+}
+
+#define SKB_STATE_FREE_MASK		(1 << SKB_STATE_FREE)
+#define SKB_STATE_ALLOCATED_MASK	(1 << SKB_STATE_ALLOCATED)
+#define SKB_STATE_QUEUED_MASK		(1 << SKB_STATE_QUEUED)
+
 /** 
  *	struct sk_buff - socket buffer
  *	@next: Next buffer in list
@@ -308,6 +335,8 @@ typedef unsigned char *sk_buff_data_t;
  *		done by skb DMA functions
  *	@secmark: security marking
  *	@vlan_tci: vlan tag control information
+ *	@state: State for consistency checking
+ *	@last_op: Address of caller who last changed the sk_buff state
  */
 
 struct sk_buff {
@@ -409,6 +438,14 @@ struct sk_buff {
 				*data;
 	unsigned int		truesize;
 	atomic_t		users;
+#ifdef CONFIG_DEBUG_SKB_STATE_CHANGES
+	/* private: */
+	/* These are set by the constructor called by the slab cache allocator
+	 * and should not be zeroed with the rest of the sk_buff. */
+	unsigned int	state:SKB_VALIDATE_STATE_SIZE;
+	unsigned int	last_op:CONFIG_DEBUG_SKB_ID_WIDTH;
+	/* public: */
+#endif
 };
 
 #ifdef __KERNEL__
@@ -484,6 +521,130 @@ static inline struct rtable *skb_rtable(const struct sk_buff *skb)
 	return (struct rtable *)skb_dst(skb);
 }
 
+#ifdef CONFIG_DEBUG_SKB_STATE_CHANGES
+extern struct callsite_set skb_callsite_set;
+
+extern void skb_report_invalid(const struct sk_buff *skb, unsigned expected);
+
+static inline void skb_callsite_task_init(struct task_struct *p)
+{
+	callsite_top_init(&p->skb_callsite_top);
+}
+
+/**
+* skb_check - verify that the state of the sk_buff is as expected
+* @skb:		Pointer to the &struct sk_buff to validate
+* @expected:	Mask of valid states
+*/
+static inline void skb_check(const struct sk_buff *skb, unsigned expected)
+{
+	if (unlikely((skb_check2mask(skb->state) & expected) == 0))
+		skb_report_invalid(skb, expected);
+}
+
+/**
+* skb_check_and_set - validate the current sk_buff state and set to a new value
+* @skb:	Pointer to the &sk_buff whose state is to be validated and set
+* @expected:	Expected state of the &sk_buff
+* @new_state:	New state of the &sk_buff
+*/
+static inline void skb_check_and_set(struct sk_buff *skb, unsigned expected,
+	enum skb_check_state new_state)
+{
+	skb_check(skb, expected);
+	skb->state = new_state;
+}
+
+/**
+ * skb_check_and_set_state - Check and set the state for specific function
+ * @skb:	Pointer to the &sk_buff whose state is to be validated and set
+ * @expected:	Expected state mask for the &sk_buff
+ * @state:	New state for the sk_buff
+ */
+static inline void skb_check_and_set_state(struct sk_buff *skb,
+	unsigned expected, enum skb_check_state state)
+{
+	skb_check_and_set(skb, expected, state);
+	skb->last_op = callsite_get_id(&current->skb_callsite_top);
+}
+
+/**
+ * skb_check_and_set_alloc - Check and set the state for allocation function
+ * @skb:	Pointer to the &sk_buff whose state is to be validated and set
+ * @expected:	Expected state mask for the &sk_buff
+ *
+ * We allow %NULL values for skb, in which case we do nothing.
+ */
+static inline void skb_check_and_set_alloc(struct sk_buff *skb,
+	unsigned expected)
+{
+	if (likely(skb))
+		skb_check_and_set_state(skb, expected, SKB_STATE_ALLOCATED);
+}
+
+/**
+ * skb_check_and_set_free - Check and set the state for free function
+ * @skb:	Pointer to the &sk_buff whose state is to be validated and set
+ * @expected:	Expected state mask for the &sk_buff
+ *
+ * %NULL values for skb are valid in this case, which causes the check to be
+ * skipped.
+ */
+static inline void skb_check_and_set_free(struct sk_buff *skb,
+	unsigned expected)
+{
+	if (likely(skb))
+		skb_check_and_set_state(skb, expected, SKB_STATE_FREE);
+}
+
+/**
+ * skb_check_and_set_queue - Check and set the state for queuing functions
+ * @skb:	Pointer to the &sk_buff whose state is to be validated and set
+ * @expected:	Expected state mask for the &sk_buff
+ *
+ * %NULL values for skb are valid in this case, which causes the check to be
+ * skipped.
+ */
+static inline void skb_check_and_set_queued(struct sk_buff *skb,
+	unsigned expected)
+{
+	skb_check_and_set_state(skb, expected, SKB_STATE_QUEUED);
+}
+#else
+static inline void skb_callsite_task_init(struct task_struct *p)
+{
+}
+
+static inline void skb_check(const struct sk_buff *skb, unsigned expected)
+{
+}
+
+static inline void skb_check_and_set(struct sk_buff *skb, unsigned expected,
+	const enum skb_check_state new_state)
+{
+}
+
+static inline void skb_check_and_set_state(struct sk_buff *skb,
+	unsigned expected, enum skb_check_state state)
+{
+}
+
+static inline void skb_check_and_set_alloc(struct sk_buff *skb,
+	unsigned expected)
+{
+}
+
+static inline void skb_check_and_set_free(struct sk_buff *skb,
+	unsigned expected)
+{
+}
+
+static inline void skb_check_and_set_queued(struct sk_buff *skb,
+	unsigned expected)
+{
+}
+#endif
+
 extern void kfree_skb(struct sk_buff *skb);
 extern void consume_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
@@ -886,6 +1047,7 @@ static inline void __skb_insert(struct sk_buff *newsk,
 				struct sk_buff *prev, struct sk_buff *next,
 				struct sk_buff_head *list)
 {
+	skb_check_and_set_queued(newsk, SKB_STATE_ALLOCATED_MASK);
 	newsk->next = next;
 	newsk->prev = prev;
 	next->prev  = prev->next = newsk;
@@ -1040,6 +1202,8 @@ static inline void __skb_unlink(struct sk_buff *skb, struct sk_buff_head *list)
 {
 	struct sk_buff *next, *prev;
 
+	skb_check_and_set_state(skb, SKB_STATE_QUEUED_MASK,
+		SKB_STATE_ALLOCATED);
 	list->qlen--;
 	next	   = skb->next;
 	prev	   = skb->prev;
@@ -1116,8 +1280,8 @@ static inline void skb_fill_page_desc(struct sk_buff *skb, int i,
 extern void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page,
 			    int off, int size);
 
-#define SKB_PAGE_ASSERT(skb) 	BUG_ON(skb_shinfo(skb)->nr_frags)
-#define SKB_FRAG_ASSERT(skb) 	BUG_ON(skb_has_frags(skb))
+#define SKB_PAGE_ASSERT(skb)	BUG_ON(skb_shinfo(skb)->nr_frags)
+#define SKB_FRAG_ASSERT(skb)	BUG_ON(skb_has_frags(skb))
 #define SKB_LINEAR_ASSERT(skb)  BUG_ON(skb_is_nonlinear(skb))
 
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
@@ -1554,9 +1718,9 @@ extern struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask);
  *	netdev_alloc_page - allocate a page for ps-rx on a specific device
  *	@dev: network device to receive on
  *
- * 	Allocate a new page node local to the specified device.
+ *	Allocate a new page node local to the specified device.
  *
- * 	%NULL is returned if there is no free memory.
+ *	%NULL is returned if there is no free memory.
  */
 static inline struct page *netdev_alloc_page(struct net_device *dev)
 {
@@ -2144,5 +2308,110 @@ static inline void skb_forward_csum(struct sk_buff *skb)
 }
 
 bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
+
+#ifdef CONFIG_DEBUG_SKB_STATE_CHANGES
+/*
+ * Macros used to call functions that record the location of the last operation
+ * performed on an sk_buff. We use these instead of using the CALLSITE_CALL*
+ * macros directly so that we can redefine them in skbuff.c
+ */
+#define	SKB_CALL(fn, arg1, ...) ({					\
+		CALLSITE_CALL(&current->skb_callsite_top,		\
+			&skb_callsite_set, fn, arg1, ##__VA_ARGS__);	\
+	})
+
+#define	SKB_CALL_VOID(fn, arg1, ...) do {				\
+		CALLSITE_CALL_VOID(&current->skb_callsite_top,	\
+			&skb_callsite_set, fn, arg1, ##__VA_ARGS__);	\
+	} while (0)
+/*
+ * Macros that cover functions that call callsite_get_id() directly or
+ * indirectly. The macros must be defined after all of the functions are
+ * defined so that we don't have a covered function calling a covered function.
+ */
+#define kfree_skb(skb)							\
+	SKB_CALL_VOID(kfree_skb, skb)
+#define consume_skb(skb)						\
+	SKB_CALL_VOID(consume_skb, skb)
+#define __kfree_skb(skb)						\
+	SKB_CALL_VOID(__kfree_skb, skb)
+#define __alloc_skb(size, priority, fclone, node)			\
+	SKB_CALL(__alloc_skb, size, priority, fclone, node)
+#define alloc_skb(size, priority)					\
+	SKB_CALL(alloc_skb, size, priority)
+#define skb_recycle_check(skb, skb_size)				\
+	SKB_CALL(skb_recycle_check, skb, skb_size)
+#define alloc_skb_fclone(size, priority)				\
+	SKB_CALL(alloc_skb_fclone, size, priority)
+#define skb_morph(dst, src)						\
+	SKB_CALL(skb_morph, dst, src)
+#define skb_clone(skb, priority)					\
+	SKB_CALL(skb_clone, skb, priority)
+#define skb_copy(skb, priority)						\
+	SKB_CALL(skb_copy, skb, priority)
+#define pskb_copy(skb, gfp_mask)					\
+	SKB_CALL(pskb_copy, skb, gfp_mask)
+#define skb_realloc_headroom(skb, headroom)				\
+	SKB_CALL(skb_realloc_headroom, skb, headroom)
+#define skb_copy_expand(skb, newheadroom, newtailroom, priority)	\
+	SKB_CALL(skb_copy_expand, skb, newheadroom, newtailroom, priority)
+#define skb_cow_data(skb, tailbits, trailer)				\
+	SKB_CALL(skb_cow_data, skb, tailbits, trailer)
+#define skb_share_check(skb, pri)					\
+	SKB_CALL(skb_share_check, skb, pri)
+#define skb_unshare(skb, pri)						\
+	SKB_CALL(skb_unshare, skb, pri)
+#define __pskb_pull_tail(skb, delta)					\
+	SKB_CALL(__pskb_pull_tail, skb, delta)
+#define ___pskb_trim(skb, len)						\
+	SKB_CALL(___pskb_trim, skb, len)
+#define __pskb_trim(skb, len)						\
+	SKB_CALL(__pskb_trim, skb, len)
+#define pskb_trim(skb, len)						\
+	SKB_CALL(pskb_trim, skb, len)
+#define skb_queue_purge(list)						\
+	SKB_CALL_VOID(skb_queue_purge, list)
+#define __skb_queue_purge(list)						\
+	SKB_CALL_VOID(__skb_queue_purge, list)
+#define __dev_alloc_skb(length, gfp_mask)				\
+	SKB_CALL(__dev_alloc_skb, length, gfp_mask)
+#define dev_alloc_skb(length)						\
+	SKB_CALL(dev_alloc_skb, length)
+#define __netdev_alloc_skb(dev, length, gfp_mask)			\
+	SKB_CALL(__netdev_alloc_skb, dev, length, gfp_mask)
+#define netdev_alloc_skb(dev, length)					\
+	SKB_CALL(netdev_alloc_skb, dev, length)
+#define skb_segment(skb, features)					\
+	SKB_CALL(skb_segment, skb, features)
+#define nf_conntrack_put_reasm(skb)					\
+	SKB_CALL(nf_conntrack_put_reasm, skb)
+#define __skb_insert(newsk, prev, next, list)				\
+	SKB_CALL_VOID(__skb_insert, newsk, prev, next, list)
+#define __skb_queue_after(list, prev, newsk)				\
+	SKB_CALL_VOID(__skb_queue_after, list, prev, newsk)
+#define __skb_queue_before(list, prev, newsk)				\
+	SKB_CALL_VOID(__skb_queue_before, list, prev, newsk)
+#define skb_queue_head(list, newsk)					\
+	SKB_CALL_VOID(skb_queue_head, list, newsk)
+#define __skb_queue_head(list, newsk)					\
+	SKB_CALL_VOID(__skb_queue_head, list, newsk)
+#define skb_queue_tail(list, newsk)					\
+	SKB_CALL_VOID(skb_queue_tail, list, newsk)
+#define __skb_queue_tail(list, newsk)					\
+	SKB_CALL_VOID(__skb_queue_tail, list, newsk)
+#define skb_unlink(skb, list)						\
+	SKB_CALL_VOID(skb_unlink, skb, list)
+#define __skb_unlink(skb, list)						\
+	SKB_CALL_VOID(__skb_unlink, skb, list)
+#define skb_dequeue(list)						\
+	SKB_CALL(skb_dequeue, list)
+#define __skb_dequeue(list)						\
+	SKB_CALL(__skb_dequeue, list)
+#define skb_dequeue_tail(list)						\
+	SKB_CALL(skb_dequeue_tail, list)
+#define __skb_dequeue_tail(list)					\
+	SKB_CALL(__skb_dequeue_tail, list)
+
+#endif	/* CONFIG_DEBUG_SKB_STATE_CHANGES */
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index b6cce14..13b90a5 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1093,6 +1093,9 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 #else
 	p->hardirqs_enabled = 0;
 #endif
+#ifdef CONFIG_DEBUG_SKB_STATE_CHANGES
+	skb_callsite_task_init(p);
+#endif
 	p->hardirq_enable_ip = 0;
 	p->hardirq_enable_event = 0;
 	p->hardirq_disable_ip = _THIS_IP_;
diff --git a/kernel/module.c b/kernel/module.c
index 8c6b428..7e4d615 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -55,6 +55,7 @@
 #include <linux/async.h>
 #include <linux/percpu.h>
 #include <linux/kmemleak.h>
+#include <net/callsite.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/module.h>
@@ -788,6 +789,7 @@ SYSCALL_DEFINE2(delete_module, const char __user *, name_user,
 	/* Store the name of the last unloaded module for diagnostic purposes */
 	strlcpy(last_unloaded_module, mod->name, sizeof(last_unloaded_module));
 	ddebug_remove_module(mod->name);
+	callsite_remove_module(mod);
 
 	free_module(mod);
 	return 0;
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index e722e9d..27a9a3e 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -315,6 +315,59 @@ config DEBUG_OBJECTS_ENABLE_DEFAULT
         help
           Debug objects boot parameter default value
 
+config DEBUG_SKB_STATE_CHANGES
+	bool "Validate state of networking buffers (struct sk_buff)"
+	depends on DEBUG_KERNEL && NET
+	default n
+	select CALLSITE
+	help
+	  Simple and quick checks to validate that sk_buffs are in the right
+	  state. Intended to catch errors, including, but not limited to,
+	  the following:
+	  - Double-freeing sk_buffs
+	  - Freeing sk_buffs that are still on a queue
+	  - Using kfree instead of kfree_skb (might miss some instances)
+
+config DEBUG_SKB_ID_WIDTH
+	int "Maximum number of bits used to track sk_buff call sites"
+	depends on DEBUG_SKB_STATE_CHANGES
+	range 6 16
+	default 10
+	help
+	  The sk_buff state validation code tracks the location of the last
+	  state-changing operation within each sk_buff. To minimize memory
+	  usage, it stores IDs instead of the address. This value specifies
+	  the maximum number of bits allocated for the ID. If this value is
+	  too small, sk_buff state validation is still done, but it will not
+	  be possible to determine the location where the state was last
+	  changed.
+
+	  If in doubt, leave this at its default setting.
+
+config CALLSITE
+	bool
+	help
+	  Enable code that dynamically generates small tags from code
+	  addresses, which allows reduced overhead in structures that need
+	  to store call location information. This is typically used for
+	  track sites at which calls are made for debugging.
+
+config CALLSITE_TERSE
+	bool "Use terse reporting of call sites"
+	default "n"
+	depends on DEBUG_KERNEL
+	help
+	  When call site IDs are being used to store references to locations
+	  where specific functions are called, the call sites can be reported
+	  either as a file name/line number pair or using the "%pS" format.
+	  Although using file name and line numbers is more readable, it takes
+	  significantly more space. The "%pS" format will report the location
+	  corresponding to the start of the line where the call to the skb_*
+	  function is located. There are generally multiple instructions that
+	  must be skipped to find the actual location of the call, which may
+	  actually have been expanded inline. Thus, using this option is only
+	  for those comfortable with looking at disassembled C code.
+
 config DEBUG_SLAB
 	bool "Debug slab memory allocations"
 	depends on DEBUG_KERNEL && SLAB && !KMEMCHECK
diff --git a/net/core/Makefile b/net/core/Makefile
index 51c3eec..8cbb6f8 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -18,4 +18,4 @@ obj-$(CONFIG_NET_DMA) += user_dma.o
 obj-$(CONFIG_FIB_RULES) += fib_rules.o
 obj-$(CONFIG_TRACEPOINTS) += net-traces.o
 obj-$(CONFIG_NET_DROP_MONITOR) += drop_monitor.o
-
+obj-$(CONFIG_CALLSITE) += callsite.o
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9f07e74..f320ea9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -57,12 +57,14 @@
 #include <linux/init.h>
 #include <linux/scatterlist.h>
 #include <linux/errqueue.h>
+#include <linux/kallsyms.h>
 
 #include <net/protocol.h>
 #include <net/dst.h>
 #include <net/sock.h>
 #include <net/checksum.h>
 #include <net/xfrm.h>
+#include <net/callsite.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -70,6 +72,21 @@
 
 #include "kmap_skb.h"
 
+#ifdef CONFIG_DEBUG_SKB_STATE_CHANGES
+/*
+ * In this file, we never want to use the macros that use the CALLSITE_CALL*
+ * macros to call functions. Doing so would interpose a callsite_stackframe
+ * between the user's call and the call in this file, which would cause
+ * an uninteresting callsite to be recorded. Instead, we define macros that
+ * just call the functions.
+ */
+#undef SKB_CALL
+#define	SKB_CALL(fn, arg1, ...) fn(arg1, ##__VA_ARGS__)
+
+#undef SKB_CALL_VOID
+#define	SKB_CALL_VOID(fn, arg1, ...) fn(arg1, ##__VA_ARGS__)
+#endif
+
 static struct kmem_cache *skbuff_head_cache __read_mostly;
 static struct kmem_cache *skbuff_fclone_cache __read_mostly;
 
@@ -193,7 +210,8 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	/*
 	 * Only clear those fields we need to clear, not those that we will
 	 * actually initialise below. Hence, don't put any more fields after
-	 * the tail pointer in struct sk_buff!
+	 * the tail pointer in struct sk_buff! (Unless you don't *want* them
+	 * to be cleared, such as with the sk_buff validation fields)
 	 */
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->truesize = size + sizeof(struct sk_buff);
@@ -224,6 +242,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 
 		child->fclone = SKB_FCLONE_UNAVAILABLE;
 	}
+	skb_check_and_set_alloc(skb, SKB_STATE_FREE_MASK);
 out:
 	return skb;
 nodata:
@@ -312,6 +331,7 @@ static void skb_drop_list(struct sk_buff **listp)
 	do {
 		struct sk_buff *this = list;
 		list = list->next;
+		skb_check_and_set_queued(this, SKB_STATE_QUEUED_MASK);
 		kfree_skb(this);
 	} while (list);
 }
@@ -357,11 +377,14 @@ static void kfree_skbmem(struct sk_buff *skb)
 
 	switch (skb->fclone) {
 	case SKB_FCLONE_UNAVAILABLE:
+		skb_check_and_set_free(skb, SKB_STATE_ALLOCATED_MASK);
 		kmem_cache_free(skbuff_head_cache, skb);
 		break;
 
 	case SKB_FCLONE_ORIG:
 		fclone_ref = (atomic_t *) (skb + 2);
+		skb_check_and_set_free(skb, SKB_STATE_ALLOCATED_MASK);
+
 		if (atomic_dec_and_test(fclone_ref))
 			kmem_cache_free(skbuff_fclone_cache, skb);
 		break;
@@ -374,6 +397,7 @@ static void kfree_skbmem(struct sk_buff *skb)
 		 * fast-cloning again.
 		 */
 		skb->fclone = SKB_FCLONE_UNAVAILABLE;
+		skb_check_and_set_free(skb, SKB_STATE_ALLOCATED_MASK);
 
 		if (atomic_dec_and_test(fclone_ref))
 			kmem_cache_free(skbuff_fclone_cache, other);
@@ -639,6 +663,7 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 		n->fclone = SKB_FCLONE_UNAVAILABLE;
 	}
 
+	skb_check_and_set_alloc(n, SKB_STATE_FREE_MASK);
 	return __skb_clone(n, skb);
 }
 EXPORT_SYMBOL(skb_clone);
@@ -1248,6 +1273,7 @@ unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta)
 		/* Free pulled out fragments. */
 		while ((list = skb_shinfo(skb)->frag_list) != insp) {
 			skb_shinfo(skb)->frag_list = list->next;
+			skb_check_and_set_queued(list, SKB_STATE_QUEUED_MASK);
 			kfree_skb(list);
 		}
 		/* And insert new clone at head. */
@@ -2646,6 +2672,7 @@ skip_fraglist:
 err:
 	while ((skb = segs)) {
 		segs = skb->next;
+		skb_check_and_set_queued(skb, SKB_STATE_QUEUED_MASK);
 		kfree_skb(skb);
 	}
 	return ERR_PTR(err);
@@ -2760,19 +2787,69 @@ done:
 }
 EXPORT_SYMBOL_GPL(skb_gro_receive);
 
+#ifdef	CONFIG_DEBUG_SKB_STATE_CHANGES
+/*
+ * skb_add_callsite_id_set - Register the sk_buff callsite ID set information
+ */
+static void skb_add_callsite_id_set(void)
+{
+	callsite_set_register(&skb_callsite_set);
+}
+
+/*
+ * Initialize an sk_buff for state validation
+ * @skb:	Pointer to the sk_buff to initialize
+ */
+static void skb_kmem_cache_ctor(struct sk_buff *skb)
+{
+	skb->state = SKB_STATE_FREE;
+	skb->last_op = CALLSITE_UNSET;
+}
+
+/*
+ * Initialize an sk_buff from skb_head_cache for state validation
+ * @c:	Pointer to the associated kmem_cache structure
+ * @p:	Pointer to the particular object in the cache to be initialized
+ */
+static void skb_head_cache_ctor(void *p)
+{
+	skb_kmem_cache_ctor((struct sk_buff *) p);
+}
+
+/*
+ * Initialize an sk_buff from skb_clone_cache for state validation
+ * @c:	Pointer to the associated kmem_cache structure
+ * @p:	Pointer to the particular object in the cache to be initialized
+ */
+static void skb_fclone_cache_ctor(void *p)
+{
+	struct sk_buff *skb = p;
+	skb_kmem_cache_ctor(skb);
+	skb_kmem_cache_ctor(skb + 1);
+}
+#else
+static void skb_add_callsite_id_set(void)
+{
+}
+
+#define	skb_head_cache_ctor	NULL
+#define	skb_fclone_cache_ctor	NULL
+#endif
+
 void __init skb_init(void)
 {
 	skbuff_head_cache = kmem_cache_create("skbuff_head_cache",
 					      sizeof(struct sk_buff),
 					      0,
 					      SLAB_HWCACHE_ALIGN|SLAB_PANIC,
-					      NULL);
+					      skb_head_cache_ctor);
 	skbuff_fclone_cache = kmem_cache_create("skbuff_fclone_cache",
 						(2*sizeof(struct sk_buff)) +
 						sizeof(atomic_t),
 						0,
 						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
-						NULL);
+						skb_fclone_cache_ctor);
+	skb_add_callsite_id_set();
 }
 
 /**
@@ -3069,3 +3146,108 @@ void __skb_warn_lro_forwarding(const struct sk_buff *skb)
 			   " while LRO is enabled\n", skb->dev->name);
 }
 EXPORT_SYMBOL(__skb_warn_lro_forwarding);
+
+#ifdef	CONFIG_DEBUG_SKB_STATE_CHANGES
+
+struct callsite_set skb_callsite_set = CALLSITE_SET_INIT("skb_callset_set",
+	skb_callsite_set, CONFIG_DEBUG_SKB_ID_WIDTH);
+EXPORT_SYMBOL(skb_callsite_set);
+
+static const char *skb_check_names[] = {
+	[SKB_STATE_INVALID] =	"Invalid",
+	[SKB_STATE_FREE] =	"Free",
+	[SKB_STATE_ALLOCATED] =	"Allocated",
+	[SKB_STATE_QUEUED] =	"Queued",
+};
+
+/*
+* Returns a string corresponding to the current sk_buff check state.
+* @state:	State whose name is to be determined
+* Returns a pointer to the corresponding string. If the state isn't
+* valid, it will return a pointer to a string indicating an invalid
+* state.
+*/
+static const char *skb_check_name(enum skb_check_state state)
+{
+	const char	*result;
+
+	if (state >= ARRAY_SIZE(skb_check_names))
+		result = skb_check_names[SKB_STATE_INVALID];
+
+	else {
+		result = skb_check_names[state];
+
+		if (!result)
+			result = skb_check_names[SKB_STATE_INVALID];
+	}
+
+	return result;
+}
+
+/*
+* Reports an invalid state
+* @skb:		Pointer to the &struct sk_buff with an invalid state
+* @expected:	Mask of valid states
+*/
+void skb_report_invalid(const struct sk_buff *skb, unsigned expected)
+{
+#define	INDENT "     "
+	unsigned		nbytes;
+	enum skb_check_state	actual = skb->state;
+	enum skb_check_state	i;
+
+	pr_err("Invalid sk_buff detected at 0x%p state %d (%s)\n",
+		skb, actual, skb_check_name(actual));
+
+	pr_err("Valid states:");
+	for (i = 0; i < SKB_STATE_NUM; i++) {
+		if (skb_check2mask(i) & expected)
+			pr_cont(" %s", skb_check_name(i));
+	}
+	pr_cont("\n");
+
+	/* Print the last allocation and free. The specific address is that
+	 * of the call to the inline *_trace function and so could be slightly
+	 * different than the call to the *_log function, but it will
+	 * be very close. */
+	pr_err(INDENT "last operation: ");
+	callsite_print_where_by_id(&skb_callsite_set, skb->last_op);
+
+	/* If we seem to be in reasonable shape, try to dump a bit of the
+	 * buffer so that we have more debugging information. Note that we
+	 * only try this if the state of the buffer indicates that we should
+	 * be able to trust the sk_buff buffer pointers */
+	switch (skb->state) {
+	case SKB_STATE_ALLOCATED:
+	case SKB_STATE_QUEUED:
+		/* Only try to do the dump if we don't have fragments because
+		 * the system might be in too bad a shape to do the mapping
+		 * into the kernel virtual address space. */
+		if (skb_is_nonlinear(skb))
+			pr_err("sk_buff is non-linear; skipping print\n");
+
+		else {
+			nbytes = min(96u, (size_t) (skb->end - skb->head));
+			pr_err("sk_buff contents (data offset from head: 0x%x "
+				"bytes)\n", skb->data - skb->head);
+			print_hex_dump(KERN_ERR, "", DUMP_PREFIX_OFFSET, 16, 1,
+				skb->head, nbytes, 0);
+		}
+		break;
+	default:
+		pr_err("sk_buff is neither allocated nor queued; "
+			"skipping print\n");
+		break;
+	}
+
+	/*
+	 * There is a good chance that the system is compromised when this is
+	 * called, but it is possible the problem is limited to a single
+	 * driver and may not recur very frequently. Since we are dealing with
+	 * networking code, minor errors may be corrected, so BUG() instead
+	 * of panicing.
+	 */
+	BUG();
+}
+EXPORT_SYMBOL(skb_report_invalid);
+#endif
