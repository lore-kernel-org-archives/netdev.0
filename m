From: David VomLehn <dvomlehn@cisco.com>
Subject: [Patch 1/1][RFC] NETDEV: Find network bugs by validating the
	sk_buff state
Date: Tue, 28 Apr 2009 21:05:01 -0700
Message-ID: <20090429040501.GA32074@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:40134 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbZD2EFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 00:05:03 -0400
Received: from sj-core-2.cisco.com (sj-core-2.cisco.com [171.71.177.254])
	by sj-dkim-1.cisco.com (8.12.11/8.12.11) with ESMTP id n3T452p1002111
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2009 21:05:02 -0700
Received: from cliff.cisco.com (cliff.cisco.com [171.69.11.141])
	by sj-core-2.cisco.com (8.13.8/8.13.8) with ESMTP id n3T451FZ013385
	for <netdev@vger.kernel.org>; Wed, 29 Apr 2009 04:05:01 GMT
Received: from cuplxvomd02.corp.sa.net ([64.101.20.155]) by cliff.cisco.com (8.6.12/8.6.5) with ESMTP id EAA07611 for <netdev@vger.kernel.org>; Wed, 29 Apr 2009 04:05:01 GMT
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It can be very difficult to find the cause of networking driver bugs due to
doing the wrong thing with an sk_buff, such as freeing or queuing them
twice. This can lead to varied errors that don't show up until much later and
cause nasty things like memory corruption.  The delayed effects can make it
very difficult to locate the cause of the errors. This patch adds code that
checks the state of sk_buffs at a few critical points, a strategy which is
lightweight and appears very effective.  It also records and prints information
that should help track down who did what to the buffer, making it easier to
determine exactly which code has a problem.

This code has low enough overhead to enable on production systems, which
is how we deploy it. It is a kernel debugging tool, however, and the default
is to leave it off.

Though already working, this is still a work in progress and I know of some
changes I want to make. It has twice found problems within an hour that
networking device driver developers had been trying to find for days/weeks, so
it might help someone fighting such problems right now.

Signed-off-by: David VomLehn <dvomlehn@cisco.com>
---
 include/linux/skbuff.h |  186 +++++++++++++++++++++++++++++++++++++++++++++++-
 lib/Kconfig.debug      |   12 +++
 net/core/skbuff.c      |  162 ++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 352 insertions(+), 8 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5fd3891..ea2fd11 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -44,6 +44,15 @@
 #define SKB_MAX_HEAD(X)		(SKB_MAX_ORDER((X), 0))
 #define SKB_MAX_ALLOC		(SKB_MAX_ORDER(0, 2))
 
+/*
+ * Define the best-guess way to get the address of the caller.
+ */
+#ifdef	return_address
+#define	skb_return_address()	return_address()
+#else
+#define skb_return_address()	__builtin_return_address(0)
+#endif
+
 /* A. Checksumming of received packets by device.
  *
  *	NONE: device failed to checksum this packet.
@@ -251,6 +260,29 @@ typedef unsigned int sk_buff_data_t;
 typedef unsigned char *sk_buff_data_t;
 #endif
 
+/* States for a struct sk_buff */
+enum skb_check {
+	SKB_CHECK_INVALID,	/* Zero is a common corruption value, so make
+				 * an invalid value */
+	SKB_CHECK_FREE,		/* sk_buff is not allocated */
+	SKB_CHECK_ALLOCATED,	/* In used, but not queued */
+	SKB_CHECK_QUEUED,	/* On a queue */
+};
+
+/*
+ * Convert an skb_check to the corresponding mask
+ * @state:	The skb_check value to convert
+ * Returns the mask
+ */
+static inline unsigned skb_check2mask(enum skb_check state)
+{
+	return 1u << state;
+}
+
+#define SKB_CHECK_FREE_MASK		skb_check2mask(SKB_CHECK_FREE)
+#define SKB_CHECK_ALLOCATED_MASK	skb_check2mask(SKB_CHECK_ALLOCATED)
+#define SKB_CHECK_QUEUED_MASK		skb_check2mask(SKB_CHECK_QUEUED)
+
 /** 
  *	struct sk_buff - socket buffer
  *	@next: Next buffer in list
@@ -308,6 +340,10 @@ typedef unsigned char *sk_buff_data_t;
  *		done by skb DMA functions
  *	@secmark: security marking
  *	@vlan_tci: vlan tag control information
+ *	@magic: Magic number for sk_buff, should be SKB_CHECK_MAGIC
+ *	@check: State for consistency checking
+ *	@last_alloc: Address of caller who last allocated this sk_buff
+ *	@last_free: Address of caller who last freed this sk_buff
  */
 
 struct sk_buff {
@@ -398,6 +434,13 @@ struct sk_buff {
 	sk_buff_data_t		transport_header;
 	sk_buff_data_t		network_header;
 	sk_buff_data_t		mac_header;
+#ifdef	CONFIG_SKB_VALIDATE_STATE
+#define	SKB_CHECK_MAGIC		0xab1ec0de
+	__u32			magic;
+	enum skb_check		check;
+	void			*last_alloc;
+	void			*last_free;
+#endif
 	/* These elements must be at the end, see alloc_skb() for details.  */
 	sk_buff_data_t		tail;
 	sk_buff_data_t		end;
@@ -423,6 +466,123 @@ extern void skb_dma_unmap(struct device *dev, struct sk_buff *skb,
 			  enum dma_data_direction dir);
 #endif
 
+#ifdef	CONFIG_SKB_VALIDATE_STATE
+
+extern void skb_report_invalid(const struct sk_buff *skb);
+
+/**
+* Verify that the state of the sk_buff is as expected
+* @skb:	Pointer to the &struct sk_buff to validate
+* @expected:	Mask of valid states
+*/
+static inline void skb_check(const struct sk_buff *skb,
+	 unsigned expected)
+{
+	if (unlikely(skb->magic != SKB_CHECK_MAGIC ||
+		(skb_check2mask(skb->check) & expected) == 0))
+		skb_report_invalid(skb);
+}
+
+/**
+* Set the validate state of the &struct sk_buff to the given value
+* @skb:	Pointer to the &struct sk_buff whose state is to be set
+* @state:	Value to which the state should be set
+* Note that this requires that the magic number be set before setting the
+* state.
+*/
+static inline void skb_set_check(struct sk_buff *skb,
+	enum skb_check state)
+{
+	if (unlikely(skb->magic != SKB_CHECK_MAGIC))
+		skb_report_invalid(skb);
+	skb->check = state;
+}
+
+/**
+* Validate the current sk_buff state and set to a new value
+* @skb:	Pointer to the &sk_buff whose state is to be validated and set
+* @expected:	Expected state of the &sk_buff
+* @new:	New status of the &sk_buff
+*/
+static inline void skb_check_and_set(struct sk_buff *skb,
+	unsigned expected, enum skb_check new)
+{
+	skb_check(skb, expected);
+	skb_set_check(skb, new);
+}
+
+/**
+* Set the last_free element of the sk_buff
+* @skb:	Pointer to the &sk_buff whose last_free element is to be set
+* @last_free:	Address in the function that wanted to free the &sk_buff
+*/
+static inline void skb_set_last_free(struct sk_buff *skb, void *last_free)
+{
+	skb->last_free = last_free;
+}
+
+/**
+* Set the last_alloc element of the sk_buff
+* @skb:	Pointer to the &sk_buff whose last_alloc element is to be set
+* @last_alloc:	Address in the function that wanted to allocate an &sk_buff
+*/
+static inline void skb_set_last_alloc(struct sk_buff *skb, void *last_alloc)
+{
+	skb->last_alloc = last_alloc;
+}
+
+/**
+* Sets sk_buff up for state validation
+* @skb:	Pointer to the &sk_buff to be set
+*/
+static inline void skb_check_setup(struct sk_buff *skb)
+{
+	skb->magic = SKB_CHECK_MAGIC;
+	skb_set_check(skb, SKB_CHECK_ALLOCATED);
+}
+
+/**
+* Cleans state validation when the sk_buff is to be freed
+* @skb:	Poitner to the &sk_buff being freed
+*/
+static inline void skb_check_done(struct sk_buff *skb)
+{
+	skb_set_check(skb, SKB_CHECK_FREE);
+	skb->magic = 0;
+}
+#else
+static inline void skb_check(const struct sk_buff *skb,
+	unsigned expected)
+{
+}
+
+static inline void skb_set_check(struct sk_buff *skb,
+	enum skb_check state)
+{
+}
+
+static inline void skb_check_and_set(struct sk_buff *skb,
+	unsigned expected, enum skb_check new)
+{
+}
+
+static inline void skb_set_last_free(struct sk_buff *skb, void *last_free)
+{
+}
+
+static inline void skb_set_last_alloc(struct sk_buff *skb, void *last_alloc)
+{
+}
+
+static inline void skb_check_setup(struct sk_buff *skb)
+{
+}
+
+static inline void skb_check_done(struct sk_buff *skb)
+{
+}
+#endif
+
 extern void kfree_skb(struct sk_buff *skb);
 extern void consume_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
@@ -431,13 +591,27 @@ extern struct sk_buff *__alloc_skb(unsigned int size,
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
 {
-	return __alloc_skb(size, priority, 0, -1);
+	struct sk_buff *res;
+
+	res = __alloc_skb(size, priority, 0, -1);
+
+	if (res)
+		skb_set_last_alloc(res, skb_return_address());
+
+	return res;
 }
 
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
-	return __alloc_skb(size, priority, 1, -1);
+	struct sk_buff *res;
+
+	res = __alloc_skb(size, priority, 1, -1);
+
+	if (res)
+		skb_set_last_alloc(res, skb_return_address());
+
+	return res;
 }
 
 extern int skb_recycle_check(struct sk_buff *skb, int skb_size);
@@ -748,6 +922,8 @@ static inline struct sk_buff *skb_peek(struct sk_buff_head *list_)
 	struct sk_buff *list = ((struct sk_buff *)list_)->next;
 	if (list == (struct sk_buff *)list_)
 		list = NULL;
+	else
+		skb_check(list, SKB_CHECK_QUEUED_MASK);
 	return list;
 }
 
@@ -769,6 +945,8 @@ static inline struct sk_buff *skb_peek_tail(struct sk_buff_head *list_)
 	struct sk_buff *list = ((struct sk_buff *)list_)->prev;
 	if (list == (struct sk_buff *)list_)
 		list = NULL;
+	else
+		skb_check(list, SKB_CHECK_QUEUED_MASK);
 	return list;
 }
 
@@ -831,6 +1009,8 @@ static inline void __skb_insert(struct sk_buff *newsk,
 				struct sk_buff *prev, struct sk_buff *next,
 				struct sk_buff_head *list)
 {
+	skb_check_and_set(newsk, SKB_CHECK_ALLOCATED_MASK,
+		SKB_CHECK_QUEUED);
 	newsk->next = next;
 	newsk->prev = prev;
 	next->prev  = prev->next = newsk;
@@ -985,6 +1165,8 @@ static inline void __skb_unlink(struct sk_buff *skb, struct sk_buff_head *list)
 {
 	struct sk_buff *next, *prev;
 
+	skb_check_and_set(skb, SKB_CHECK_QUEUED_MASK,
+		SKB_CHECK_ALLOCATED);
 	list->qlen--;
 	next	   = skb->next;
 	prev	   = skb->prev;
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index c6e854f..cffc74a 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -298,6 +298,18 @@ config DEBUG_OBJECTS_ENABLE_DEFAULT
         help
           Debug objects boot parameter default value
 
+config SKB_VALIDATE_STATE
+	bool "Validate state of networking buffers (struct sk_buff)"
+	depends on DEBUG_KERNEL && NET
+	default n
+	help
+	  Simple and quick checks to validate that sk_buffs are in the right
+	  state. Intended to catch errors, including, but not limited to,
+	  the following:
+	  - Double-freeing sk_buffs
+	  - Freeing sk_buffs that are still on a queue
+	  - Queuing sk_buffs that aren't allocated or that are already queued
+
 config DEBUG_SLAB
 	bool "Debug slab memory allocations"
 	depends on DEBUG_KERNEL && SLAB
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ce6356c..28d4d99 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -56,6 +56,7 @@
 #include <linux/init.h>
 #include <linux/scatterlist.h>
 #include <linux/errqueue.h>
+#include <linux/kallsyms.h>
 
 #include <net/protocol.h>
 #include <net/dst.h>
@@ -223,6 +224,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 		child->fclone = SKB_FCLONE_UNAVAILABLE;
 	}
 out:
+	skb_check_setup(skb);
 	return skb;
 nodata:
 	kmem_cache_free(cache, skb);
@@ -252,6 +254,7 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 
 	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
 	if (likely(skb)) {
+		skb_set_last_alloc(skb, skb_return_address());
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev = dev;
 	}
@@ -353,6 +356,9 @@ static void kfree_skbmem(struct sk_buff *skb)
 	struct sk_buff *other;
 	atomic_t *fclone_ref;
 
+	skb_check(skb, SKB_CHECK_ALLOCATED_MASK);
+	skb_check_done(skb);
+
 	switch (skb->fclone) {
 	case SKB_FCLONE_UNAVAILABLE:
 		kmem_cache_free(skbuff_head_cache, skb);
@@ -412,19 +418,34 @@ static void skb_release_all(struct sk_buff *skb)
 	skb_release_data(skb);
 }
 
+/*
+ *	__kfree_skb_nomark - very private function
+ *	@skb: buffer
+ *	Free an sk_buff. Release anything attached to the buffer.
+ *	Clean the state. This is an internal helper function. Users should
+ *	always call kfree_skb, but they don't. Instead, lots of them call
+ *	__kfree_skb, so this is a static function that they *can't* call.
+ */
+static void kfree_skb_markfree(struct sk_buff *skb, void *last_free)
+{
+	skb_release_all(skb);
+	kfree_skbmem(skb);
+	skb_set_last_free(skb, last_free);
+}
+
 /**
  *	__kfree_skb - private function
  *	@skb: buffer
  *
  *	Free an sk_buff. Release anything attached to the buffer.
  *	Clean the state. This is an internal helper function. Users should
- *	always call kfree_skb
+ *	always call kfree_skb, but they don't. So this calls a static
+ *	function that they can't call.
  */
 
 void __kfree_skb(struct sk_buff *skb)
 {
-	skb_release_all(skb);
-	kfree_skbmem(skb);
+	kfree_skb_markfree(skb, skb_return_address());
 }
 EXPORT_SYMBOL(__kfree_skb);
 
@@ -464,7 +485,7 @@ void consume_skb(struct sk_buff *skb)
 		smp_rmb();
 	else if (likely(!atomic_dec_and_test(&skb->users)))
 		return;
-	__kfree_skb(skb);
+	kfree_skb_markfree(skb, skb_return_address());
 }
 EXPORT_SYMBOL(consume_skb);
 
@@ -494,6 +515,7 @@ int skb_recycle_check(struct sk_buff *skb, int skb_size)
 	if (skb_shared(skb) || skb_cloned(skb))
 		return 0;
 
+	skb_check(skb, SKB_CHECK_ALLOCATED_MASK);
 	skb_release_head_state(skb);
 	shinfo = skb_shinfo(skb);
 	atomic_set(&shinfo->dataref, 1);
@@ -507,6 +529,7 @@ int skb_recycle_check(struct sk_buff *skb, int skb_size)
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->data = skb->head + NET_SKB_PAD;
 	skb_reset_tail_pointer(skb);
+	skb_check_setup(skb);
 
 	return 1;
 }
@@ -514,6 +537,9 @@ EXPORT_SYMBOL(skb_recycle_check);
 
 static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 {
+	skb_check(old, SKB_CHECK_ALLOCATED_MASK | SKB_CHECK_QUEUED_MASK);
+	skb_check_setup(new);
+
 	new->tstamp		= old->tstamp;
 	new->dev		= old->dev;
 	new->transport_header	= old->transport_header;
@@ -684,6 +710,7 @@ struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
 	 *	Allocate the copy buffer
 	 */
 	struct sk_buff *n;
+
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 	n = alloc_skb(skb->end + skb->data_len, gfp_mask);
 #else
@@ -724,6 +751,7 @@ struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
 	 *	Allocate the copy buffer
 	 */
 	struct sk_buff *n;
+
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 	n = alloc_skb(skb->end, gfp_mask);
 #else
@@ -785,6 +813,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 {
 	int i;
 	u8 *data;
+
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 	int size = nhead + skb->end + ntail;
 #else
@@ -797,6 +826,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	if (skb_shared(skb))
 		BUG();
 
+	skb_check(skb, SKB_CHECK_ALLOCATED_MASK | SKB_CHECK_QUEUED_MASK);
 	size = SKB_DATA_ALIGN(size);
 
 	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
@@ -1283,6 +1313,8 @@ int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len)
 	int i, copy;
 	int start = skb_headlen(skb);
 
+	skb_check(skb, SKB_CHECK_ALLOCATED_MASK | SKB_CHECK_QUEUED_MASK);
+
 	if (offset > (int)skb->len - len)
 		goto fault;
 
@@ -1590,6 +1622,8 @@ int skb_store_bits(struct sk_buff *skb, int offset, const void *from, int len)
 	int i, copy;
 	int start = skb_headlen(skb);
 
+	skb_check(skb, SKB_CHECK_ALLOCATED_MASK | SKB_CHECK_QUEUED_MASK);
+
 	if (offset > (int)skb->len - len)
 		goto fault;
 
@@ -2753,19 +2787,35 @@ done:
 }
 EXPORT_SYMBOL_GPL(skb_gro_receive);
 
+#ifdef	CONFIG_SKB_VALIDATE_STATE
+/*
+ * Initialize an sk_buff for state validation
+ * @c:	Pointer to the associated kmem_cache structure
+ * @p:	Pointer to the particular object in the cache to be initialized
+ */
+static void skbuff_kmem_cache_ctor(void *p)
+{
+	struct sk_buff *skb = p;
+	skb->last_alloc = NULL;
+	skb->last_free = NULL;
+}
+#else
+#define	skbuff_kmem_cache_ctor	NULL
+#endif
+
 void __init skb_init(void)
 {
 	skbuff_head_cache = kmem_cache_create("skbuff_head_cache",
 					      sizeof(struct sk_buff),
 					      0,
 					      SLAB_HWCACHE_ALIGN|SLAB_PANIC,
-					      NULL);
+					      skbuff_kmem_cache_ctor);
 	skbuff_fclone_cache = kmem_cache_create("skbuff_fclone_cache",
 						(2*sizeof(struct sk_buff)) +
 						sizeof(atomic_t),
 						0,
 						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
-						NULL);
+						skbuff_kmem_cache_ctor);
 }
 
 /**
@@ -3035,3 +3085,103 @@ void __skb_warn_lro_forwarding(const struct sk_buff *skb)
 			   " while LRO is enabled\n", skb->dev->name);
 }
 EXPORT_SYMBOL(__skb_warn_lro_forwarding);
+
+#ifdef	CONFIG_SKB_VALIDATE_STATE
+static const char *skb_check_names[] = {
+	[SKB_CHECK_INVALID] =	"Invalid",
+	[SKB_CHECK_FREE] =	"Free",
+	[SKB_CHECK_ALLOCATED] =	"Allocated",
+	[SKB_CHECK_QUEUED] =	"Queued",
+};
+
+/*
+* Returns a string corresponding to the current sk_buff check state.
+* @state:	State whose name is to be determined
+* Returns a pointer to the corresponding string. If the state isn't
+* valid, it will return a pointer to a string indicating an invalid
+* state.
+*/
+static const char *skb_check_name(enum skb_check state)
+{
+	const char	*result;
+
+	if (state >= ARRAY_SIZE(skb_check_names))
+		result = skb_check_names[SKB_CHECK_INVALID];
+
+	else {
+		result = skb_check_names[state];
+
+		if (!result)
+			result = skb_check_names[SKB_CHECK_INVALID];
+	}
+
+	return result;
+}
+
+/*
+* Reports an invalid state
+* @skb:	Pointer to the &struct sk_buff with an invalid state
+*/
+void skb_report_invalid(const struct sk_buff *skb)
+{
+#define	INDENT "     "
+	unsigned	nbytes;
+	enum skb_check	actual = skb->check;
+
+	pr_err("Invalid sk_buff at 0x%p: magic 0x%x state %d (%s)\n",
+		skb, skb->magic, actual, skb_check_name(actual));
+
+	/* Print the last allocation and free. Two issues to be aware of:
+	 * o	We use may have used __builtin_return_address to get the
+	 *	caller's address, which might be not quite right due to things
+	 *	like function inlining. For example, it may be the caller of
+	 *	the caller to the sk_buff allocation or free function. You
+	 *	may have to use some judgement to figure out where things were
+	 *	actually called.
+	 * o	If this sk_buff has never been freed, the value could be
+	 *	anything at all. This is the price we pay for not initializing
+	 *	sk_buffs as they are allocated by the sl*b allocator, but the
+	 *	return we get is much better performance than if we turned on
+	 *	the sl*b debugger.  */
+	pr_err(INDENT "last allocation: ");
+	print_ip_sym((unsigned long) skb->last_alloc);
+	pr_err(INDENT "last free: ");
+	print_ip_sym((unsigned long) skb->last_free);
+
+	/* If we seem to be in reasonable shape, try to dump a bit of the
+	 * buffer so that we have more debugging information. Note that we
+	 * only try this if the state of the buffer indicates that we should
+	 * be able to trust the sk_buff buffer pointers */
+	switch (skb->check) {
+	case SKB_CHECK_ALLOCATED:
+	case SKB_CHECK_QUEUED:
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
+	 * networking code, minor errors may be corrected, so we don't panic.
+	 */
+	BUG();
+#undef INDENT
+}
+#endif
