From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [1/1] netwrok tree allocator. Sending and receiving zero-copy support.
Date: Sun, 27 Aug 2006 00:40:55 +0400
Message-ID: <20060826204054.GA25820@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42148 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750746AbWHZUle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2006 16:41:34 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

This patch introduce network-based receiving and sending zero-copy
support. Receiving side is used for zero-copy sniffer (patch introduce
full receiving support for all network allocations including netlink,
unix socket and so on), sending side zero-copy is used for userspace
network stack.

Receiving zero-copy support.
Information about each network allocation is stored into special buffer
accessible from userspace through read/write for special char device.
This information is added when skb is freed, so data placed there is
valid. Such approach does not allow to store transient state of the
data, for example encrypted IPsec packets if decryption happens
in-place, to store such states it is required to copy information into
allocated buffer (which then can be immediately freed, or decryption can
happen from source do destination buffers).
Userspace can mmap whole allocation pool (using special commands via
ioctl() to get appropriate information) and thus access data without any
copy. There is _no_ overhead in such sniffer except one atomic operation
(and delayed freeing which can lead to increased memory usage, or (like
implemented) if introduced maximum amount of "locked" by sniffer data,
there is only extremely small overhead introduced by reading/writing
meta-information assotiated for each allocation (very small amount of
copy).

Sending zero-copy support.
Sending is performaed in two steps. First one is allocation, new object
can be accessed without any copy like described above (and actually can
be used with things like kevents to implement proposed by Ulrich Drepper 
"DMA" allocation (allocation of data, which can be used both by kernel
and userspace without additional copies)). Second step is data commit,
where allocated packet is attached to special skb and pushed into the
stack using dst_output().

Above extensions are possible due to design of network allocator.
Performance test for NTA shows very noticeble performance improvement
over existing SLAB one (details can be found on project homepage [1]).

I have not run promised performance test for zero-copy sniffer yet 
(I'm going to vacations to Finland and Sweden until 31 Aug).

Interested reader can find all userspace applications (zero-copy sniffer
and sending program) on project homepage [1] (server will be turned on
on Monday 28).

Sniffer development uncovered very strange (and I would not call it
correct) behaviour of Linux startup process - there is extremely
enormous amount of continuous allocations of (likely netlink) network
messages (several tens of thousands) during device enumerations and
initial system startup on my test system (FC2 or 3, small number of
external devices). Initial suspicious is kobject_uevent, second one is
probably HAL. That flow of allocations eventually stops, but number of
allocated messages can cover any set of devices in system like 
Blue Gene.

1. Network tree allocator. Sending and receiving zero-copy networking.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=nta

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 19c96d4..cf3ae3b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -327,16 +327,29 @@ #include <linux/slab.h>
 
 #include <asm/system.h>
 
+extern void *avl_alloc(unsigned int size, gfp_t gfp_mask);
+extern void avl_free(void *ptr, unsigned int size);
+extern int avl_init(void);
+
 extern void kfree_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *__alloc_skb(unsigned int size,
 				   gfp_t priority, int fclone);
+extern struct sk_buff *__alloc_skb_emtpy(unsigned int size,
+				   gfp_t priority);
+
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
 {
 	return __alloc_skb(size, priority, 0);
 }
 
+static inline struct sk_buff *alloc_skb_empty(unsigned int size,
+					gfp_t priority)
+{
+	return __alloc_skb_emtpy(size, priority);
+}
+
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
diff --git a/net/core/Makefile b/net/core/Makefile
index 2645ba4..d86d468 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -10,6 +10,8 @@ obj-$(CONFIG_SYSCTL) += sysctl_net_core.
 obj-y		     += dev.o ethtool.o dev_mcast.o dst.o netevent.o \
 			neighbour.o rtnetlink.o utils.o link_watch.o filter.o
 
+obj-y += alloc/
+
 obj-$(CONFIG_XFRM) += flow.o
 obj-$(CONFIG_SYSFS) += net-sysfs.o
 obj-$(CONFIG_NET_DIVERT) += dv.o
diff --git a/net/core/alloc/Makefile b/net/core/alloc/Makefile
new file mode 100644
index 0000000..779eba2
--- /dev/null
+++ b/net/core/alloc/Makefile
@@ -0,0 +1,3 @@
+obj-y		:= allocator.o
+
+allocator-y	:= avl.o zc.o
diff --git a/net/core/alloc/avl.c b/net/core/alloc/avl.c
new file mode 100644
index 0000000..d9fc491
--- /dev/null
+++ b/net/core/alloc/avl.c
@@ -0,0 +1,769 @@
+/*
+ * 	avl.c
+ * 
+ * 2006 Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * All rights reserved.
+ * 
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/percpu.h>
+#include <linux/list.h>
+#include <linux/mm.h>
+#include <linux/skbuff.h>
+
+#include "avl.h"
+
+struct avl_allocator_data avl_allocator[NR_CPUS];
+
+#define avl_ptr_to_chunk(ptr, size)	(struct avl_chunk *)(ptr + size)
+
+/*
+ * Get node pointer from address.
+ */
+static inline struct avl_node *avl_get_node_ptr(unsigned long ptr)
+{
+	struct page *page = virt_to_page(ptr);
+	struct avl_node *node = (struct avl_node *)(page->lru.next);
+
+	return node;
+}
+
+/*
+ * Set node pointer for page for given address.
+ */
+static void avl_set_node_ptr(unsigned long ptr, struct avl_node *node, int order)
+{
+	int nr_pages = 1<<order, i;
+	struct page *page = virt_to_page(ptr);
+	
+	for (i=0; i<nr_pages; ++i) {
+		page->lru.next = (void *)node;
+		page++;
+	}
+}
+
+/*
+ * Get allocation CPU from address.
+ */
+static inline int avl_get_cpu_ptr(unsigned long ptr)
+{
+	struct page *page = virt_to_page(ptr);
+	int cpu = (int)(unsigned long)(page->lru.prev);
+
+	return cpu;
+}
+
+/*
+ * Set allocation cpu for page for given address.
+ */
+static void avl_set_cpu_ptr(unsigned long ptr, int cpu, int order)
+{
+	int nr_pages = 1<<order, i;
+	struct page *page = virt_to_page(ptr);
+			
+	for (i=0; i<nr_pages; ++i) {
+		page->lru.prev = (void *)(unsigned long)cpu;
+		page++;
+	}
+}
+
+/*
+ * Convert pointer to node's value.
+ * Node's value is a start address for contiguous chunk bound to given node.
+ */
+static inline unsigned long avl_ptr_to_value(void *ptr)
+{
+	struct avl_node *node = avl_get_node_ptr((unsigned long)ptr);
+	return node->value;
+}
+
+/*
+ * Convert pointer into offset from start address of the contiguous chunk
+ * allocated for appropriate node.
+ */
+static inline int avl_ptr_to_offset(void *ptr)
+{
+	return ((unsigned long)ptr - avl_ptr_to_value(ptr))/AVL_MIN_SIZE;
+}
+
+/*
+ * Count number of bits set down (until first unset is met in a mask) 
+ * to the smaller addresses including bit at @pos in @mask.
+ */
+unsigned int avl_count_set_down(unsigned long *mask, unsigned int pos)
+{
+	unsigned int stop, bits = 0;
+	int idx;
+	unsigned long p, m;
+
+	idx = pos/BITS_PER_LONG;
+	pos = pos%BITS_PER_LONG;
+
+	while (idx >= 0) {
+		m = (~0UL>>pos)<<pos;
+		p = mask[idx] | m;
+
+		if (!(mask[idx] & m))
+			break;
+
+		stop = fls(~p);
+
+		if (!stop) {
+			bits += pos + 1;
+			pos = BITS_PER_LONG - 1;
+			idx--;
+		} else {
+			bits += pos - stop + 1;
+			break;
+		}
+	}
+
+	return bits;
+}
+
+/*
+ * Count number of bits set up (until first unset is met in a mask) 
+ * to the bigger addresses including bit at @pos in @mask.
+ */
+unsigned int avl_count_set_up(unsigned long *mask, unsigned int mask_num, 
+		unsigned int pos)
+{
+	unsigned int idx, stop, bits = 0;
+	unsigned long p, m;
+
+	idx = pos/BITS_PER_LONG;
+	pos = pos%BITS_PER_LONG;
+
+	while (idx < mask_num) {
+		if (!pos)
+			m = 0;
+		else
+			m = (~0UL<<(BITS_PER_LONG-pos))>>(BITS_PER_LONG-pos);
+		p = mask[idx] | m;
+
+		if (!(mask[idx] & ~m))
+			break;
+
+		stop = ffs(~p);
+
+		if (!stop) {
+			bits += BITS_PER_LONG - pos;
+			pos = 0;
+			idx++;
+		} else {
+			bits += stop - pos - 1;
+			break;
+		}
+	}
+
+	return bits;
+}
+
+/*
+ * Fill @num bits from position @pos up with bit value @bit in a @mask.
+ */
+
+static void avl_fill_bits(unsigned long *mask, unsigned int mask_size, 
+		unsigned int pos, unsigned int num, unsigned int bit)
+{
+	unsigned int idx, start;
+
+	idx = pos/BITS_PER_LONG;
+	start = pos%BITS_PER_LONG;
+
+	while (num && idx < mask_size) {
+		unsigned long m = ((~0UL)>>start)<<start;
+
+		if (start + num <= BITS_PER_LONG) {
+			unsigned long upper_bits = BITS_PER_LONG - (start+num);
+
+			m = (m<<upper_bits)>>upper_bits;
+		}
+
+		if (bit)
+			mask[idx] |= m;
+		else
+			mask[idx] &= ~m;
+
+		if (start + num <= BITS_PER_LONG)
+			num = 0;
+		else {
+			num -= BITS_PER_LONG - start;
+			start = 0;
+			idx++;
+		}
+	}
+}
+
+/*
+ * Add free chunk into array.
+ */
+static inline void avl_container_insert(struct avl_container *c, unsigned int pos, int cpu)
+{
+	list_add_tail(&c->centry, &avl_allocator[cpu].avl_container_array[pos]);
+}
+
+/*
+ * Fill zc_data structure for given pointer and node.
+ */
+static void __avl_fill_zc(struct zc_data *zc, void *ptr, unsigned int size, struct avl_node *node)
+{
+	u32 off;
+	
+	off = ((unsigned long)node & ~PAGE_MASK)/sizeof(struct avl_node)*(1U<<node->entry->avl_node_order)*PAGE_SIZE;
+	
+	zc->off = off+avl_ptr_to_offset(ptr)*AVL_MIN_SIZE;
+	zc->data.ptr = ptr;
+	zc->size = size;
+	zc->entry = node->entry->avl_entry_num;
+	zc->cpu = avl_get_cpu_ptr((unsigned long)ptr);
+}
+
+void avl_fill_zc(struct zc_data *zc, void *ptr, unsigned int size)
+{
+	struct avl_node *node = avl_get_node_ptr((unsigned long)ptr);
+
+	__avl_fill_zc(zc, ptr, size, node);
+
+	printk("%s: ptr: %p, size: %u, node: entry: %u, order: %u, number: %u.\n",
+			__func__, ptr, size, node->entry->avl_entry_num, 
+			node->entry->avl_node_order, node->entry->avl_node_num);
+}
+
+/*
+ * Update zero-copy information in given @node.
+ * @node - node where given pointer @ptr lives
+ * @num - number of @AVL_MIN_SIZE chunks given pointer @ptr embeds
+ */
+static void avl_update_zc(struct avl_node *node, void *ptr, unsigned int size)
+{
+	struct zc_control *ctl = &zc_sniffer;
+	unsigned long flags;
+
+	spin_lock_irqsave(&ctl->zc_lock, flags);
+	if (ctl->zc_used < ctl->zc_num) {
+		struct zc_data *zc = &ctl->zcb[ctl->zc_pos];
+		struct avl_chunk *ch = avl_ptr_to_chunk(ptr, size);
+
+		if (++ctl->zc_pos >= ctl->zc_num)
+			ctl->zc_pos = 0;
+	
+		atomic_inc(&ch->refcnt);
+
+		__avl_fill_zc(zc, ptr, size, node);
+
+		ctl->zc_used++;
+		wake_up(&ctl->zc_wait);
+
+		ulog("%s: used: %u, pos: %u, num: %u, ptr: %p, size: %u.\n",
+				__func__, ctl->zc_used, ctl->zc_pos, ctl->zc_num, ptr, zc->size);
+	}
+	spin_unlock_irqrestore(&ctl->zc_lock, flags);
+}
+
+/*
+ * Update node's bitmask of free/used chunks.
+ * If processed chunk size is bigger than requested one, 
+ * split it and add the rest into list of free chunks with appropriate size.
+ */
+static void avl_update_node(struct avl_container *c, unsigned int cpos, unsigned int size)
+{
+	struct avl_node *node = avl_get_node_ptr((unsigned long)c->ptr);
+	unsigned int num = AVL_ALIGN(size + sizeof(struct avl_chunk))/AVL_MIN_SIZE;
+
+	BUG_ON(cpos < num - 1);
+
+	avl_fill_bits(node->mask, ARRAY_SIZE(node->mask), avl_ptr_to_offset(c->ptr), num, 0);
+
+	if (cpos != num-1) {
+		void *ptr = c->ptr + AVL_ALIGN(size + sizeof(struct avl_chunk));
+
+		c = ptr;
+		c->ptr = ptr;
+
+		cpos -= num;
+
+		avl_container_insert(c, cpos, smp_processor_id());
+	}
+}
+
+/*
+ * Dereference free chunk into container and add it into list of free
+ * chunks with appropriate size.
+ */
+static int avl_container_add(void *ptr, unsigned int size, int cpu)
+{
+	struct avl_container *c = ptr;
+	unsigned int pos = AVL_ALIGN(size)/AVL_MIN_SIZE-1;
+
+	if (!size)
+		return -EINVAL;
+
+	c->ptr = ptr;
+	avl_container_insert(c, pos, cpu);
+
+	return 0;
+}
+
+/*
+ * Dequeue first free chunk from the list.
+ */
+static inline struct avl_container *avl_dequeue(struct list_head *head)
+{
+	struct avl_container *cnt;
+
+	cnt = list_entry(head->next, struct avl_container, centry);
+	list_del(&cnt->centry);
+
+	return cnt;
+}
+
+/*
+ * Add new node entry int network allocator.
+ * must be called with disabled preemtpion.
+ */
+static void avl_node_entry_commit(struct avl_node_entry *entry, int cpu)
+{
+	int i, idx, off;
+
+	idx = off = 0;
+	for (i=0; i<entry->avl_node_num; ++i) {
+		struct avl_node *node;
+
+		node = &entry->avl_node_array[idx][off];
+
+		if (++off >= AVL_NODES_ON_PAGE) {
+			idx++;
+			off = 0;
+		}
+
+		node->entry = entry;
+
+		avl_set_cpu_ptr(node->value, cpu, entry->avl_node_order);
+		avl_set_node_ptr(node->value, node, entry->avl_node_order);
+		avl_container_add((void *)node->value, (1<<entry->avl_node_order)<<PAGE_SHIFT, cpu);
+	}
+
+	spin_lock(&avl_allocator[cpu].avl_node_lock);
+	entry->avl_entry_num = avl_allocator[cpu].avl_entry_num;
+	list_add_tail(&entry->node_entry, &avl_allocator[cpu].avl_node_list);
+	avl_allocator[cpu].avl_entry_num++;
+	spin_unlock(&avl_allocator[cpu].avl_node_lock);
+
+	printk("Network allocator cache has grown: entry: %u, number: %u, order: %u.\n",
+			entry->avl_entry_num, entry->avl_node_num, entry->avl_node_order);
+}
+
+/*
+ * Simple cache growing function - allocate as much as possible,
+ * but no more than @AVL_NODE_NUM pages when there is a need for that.
+ */
+static struct avl_node_entry *avl_node_entry_alloc(gfp_t gfp_mask, int order)
+{
+	struct avl_node_entry *entry;
+	int i, num = 0, idx, off, j;
+	unsigned long ptr;
+
+	entry = kzalloc(sizeof(struct avl_node_entry), gfp_mask);
+	if (!entry)
+		return NULL;
+
+	entry->avl_node_array = kzalloc(AVL_NODE_PAGES * sizeof(void *), gfp_mask);
+	if (!entry->avl_node_array)
+		goto err_out_free_entry;
+
+	for (i=0; i<AVL_NODE_PAGES; ++i) {
+		entry->avl_node_array[i] = (struct avl_node *)__get_free_page(gfp_mask);
+		if (!entry->avl_node_array[i]) {
+			num = i;
+			goto err_out_free;
+		}
+	}
+
+	idx = off = 0;
+
+	for (i=0; i<AVL_NODE_NUM; ++i) {
+		struct avl_node *node;
+
+		ptr = __get_free_pages(gfp_mask | __GFP_ZERO, order);
+		if (!ptr)
+			break;
+
+		node = &entry->avl_node_array[idx][off];
+
+		if (++off >= AVL_NODES_ON_PAGE) {
+			idx++;
+			off = 0;
+		}
+
+		for (j=0; j<(1<<order); ++j)
+			get_page(virt_to_page(ptr + (j<<PAGE_SHIFT)));
+
+		node->value = ptr;
+		memset(node->mask, 0, sizeof(node->mask));
+		avl_fill_bits(node->mask, ARRAY_SIZE(node->mask), 0, ((1<<order)<<PAGE_SHIFT)/AVL_MIN_SIZE, 1);
+	}
+
+	ulog("%s: entry: %p, node: %u, node_pages: %lu, node_num: %lu, order: %d, allocated: %d, container: %u, max_size: %u, min_size: %u, bits: %u.\n", 
+		__func__, entry, sizeof(struct avl_node), AVL_NODE_PAGES, AVL_NODE_NUM, order, 
+		i, AVL_CONTAINER_ARRAY_SIZE, AVL_MAX_SIZE, AVL_MIN_SIZE, ((1<<order)<<PAGE_SHIFT)/AVL_MIN_SIZE);
+
+	if (i == 0)
+		goto err_out_free;
+
+	entry->avl_node_num = i;
+	entry->avl_node_order = order;
+
+	return entry;
+
+err_out_free:
+	for (i=0; i<AVL_NODE_PAGES; ++i)
+		free_page((unsigned long)entry->avl_node_array[i]);
+err_out_free_entry:
+	kfree(entry);
+	return NULL;
+}
+
+/*
+ * Allocate memory region with given size and mode.
+ * If allocation fails due to unsupported order, otherwise
+ * allocate new node entry with given mode and try to allocate again
+ * Cache growing happens only with 0-order allocations.
+ */
+void *avl_alloc(unsigned int size, gfp_t gfp_mask)
+{
+	unsigned int i, try = 0, osize = size;
+	void *ptr = NULL;
+	unsigned long flags;
+
+	size = AVL_ALIGN(size + sizeof(struct avl_chunk));
+
+	if (size > AVL_MAX_SIZE || size < AVL_MIN_SIZE) {
+		/*
+		 * Print info about unsupported order so user could send a "bug report"
+		 * or increase initial allocation order.
+		 */
+		if (get_order(size) > AVL_ORDER && net_ratelimit()) {
+			printk(KERN_INFO "%s: Failed to allocate %u bytes with %02x mode, order %u, max order %u.\n", 
+					__func__, size, gfp_mask, get_order(size), AVL_ORDER);
+			WARN_ON(1);
+		}
+
+		return NULL;
+	}
+
+	local_irq_save(flags);
+repeat:
+	for (i=size/AVL_MIN_SIZE-1; i<AVL_CONTAINER_ARRAY_SIZE; ++i) {
+		struct list_head *head = &avl_allocator[smp_processor_id()].avl_container_array[i];
+		struct avl_container *c;
+
+		if (!list_empty(head)) {
+			struct avl_chunk *ch;
+
+			c = avl_dequeue(head);
+			ptr = c->ptr;
+
+			ch = avl_ptr_to_chunk(ptr, osize);
+			atomic_set(&ch->refcnt, 1);
+			ch->canary = AVL_CANARY;
+			ch->size = osize;
+
+			avl_update_node(c, i, osize);
+			break;
+		}
+	}
+	local_irq_restore(flags);
+#if 1
+	if (!ptr && !try) {
+		struct avl_node_entry *entry;
+		
+		try = 1;
+
+		entry = avl_node_entry_alloc(gfp_mask, get_order(size));
+		if (entry) {
+			local_irq_save(flags);
+			avl_node_entry_commit(entry, smp_processor_id());
+			goto repeat;
+		}
+			
+	}
+#endif
+	if (unlikely(!ptr && try))
+		if (net_ratelimit())
+			printk("%s: Failed to allocate %u bytes.\n", __func__, size);
+
+
+
+	return ptr;
+}
+
+/*
+ * Remove free chunk from the list.
+ */
+static inline struct avl_container *avl_search_container(void *ptr, unsigned int idx, int cpu)
+{
+	struct avl_container *c = ptr;
+	
+	list_del(&c->centry);
+	c->ptr = ptr;
+
+	return c;
+}
+
+/*
+ * Combine neighbour free chunks into the one with bigger size
+ * and put new chunk into list of free chunks with appropriate size.
+ */
+static void avl_combine(struct avl_node *node, void *lp, unsigned int lbits, void *rp, unsigned int rbits, 
+		void *cur_ptr, unsigned int cur_bits, int cpu)
+{
+	struct avl_container *lc, *rc, *c;
+	unsigned int idx;
+	void *ptr;
+
+	lc = rc = c = NULL;
+	idx = cur_bits - 1;
+	ptr = cur_ptr;
+
+	c = (struct avl_container *)cur_ptr;
+	c->ptr = cur_ptr;
+	
+	if (rp) {
+		rc = avl_search_container(rp, rbits-1, cpu);
+		if (!rc) {
+			printk(KERN_ERR "%p.%p: Failed to find a container for right pointer %p, rbits: %u.\n", 
+					node, cur_ptr, rp, rbits);
+			BUG();
+		}
+
+		c = rc;
+		idx += rbits;
+		ptr = c->ptr;
+	}
+
+	if (lp) {
+		lc = avl_search_container(lp, lbits-1, cpu);
+		if (!lc) {
+			printk(KERN_ERR "%p.%p: Failed to find a container for left pointer %p, lbits: %u.\n", 
+					node, cur_ptr, lp, lbits);
+			BUG();
+		}
+
+		idx += lbits;
+		ptr = c->ptr;
+	}
+	avl_container_insert(c, idx, cpu);
+}
+
+/*
+ * Free memory region of given size.
+ * Must be called on the same CPU where allocation happend
+ * with disabled interrupts.
+ */
+static void __avl_free_local(void *ptr, unsigned int size)
+{
+	unsigned long val = avl_ptr_to_value(ptr);
+	unsigned int pos, idx, sbits = AVL_ALIGN(size)/AVL_MIN_SIZE;
+	unsigned int rbits, lbits, cpu = avl_get_cpu_ptr(val);
+	struct avl_node *node;
+	unsigned long p;
+	void *lp, *rp;
+
+	node = avl_get_node_ptr((unsigned long)ptr);
+
+	pos = avl_ptr_to_offset(ptr);
+	idx = pos/BITS_PER_LONG;
+
+	p = node->mask[idx] >> (pos%BITS_PER_LONG);
+	
+	if ((p & 1)) {
+		if (net_ratelimit())
+			printk(KERN_ERR "%p.%p: Broken pointer: value: %lx, pos: %u, idx: %u, mask: %lx, p: %lx.\n", 
+				node, ptr, val, pos, idx, node->mask[idx], p);
+		return;
+	}
+
+	avl_fill_bits(node->mask, ARRAY_SIZE(node->mask), pos, sbits, 1);
+
+	lp = rp = NULL;
+	rbits = lbits = 0;
+
+	idx = (pos+sbits)/BITS_PER_LONG;
+	p = (pos+sbits)%BITS_PER_LONG;
+
+	if ((node->mask[idx] >> p) & 1) {
+		lbits = avl_count_set_up(node->mask, ARRAY_SIZE(node->mask), pos+sbits);
+		if (lbits) {
+			lp = (void *)(val + (pos + sbits)*AVL_MIN_SIZE);
+		}
+	}
+
+	if (pos) {
+		idx = (pos-1)/BITS_PER_LONG;
+		p = (pos-1)%BITS_PER_LONG;
+		if ((node->mask[idx] >> p) & 1) {
+			rbits = avl_count_set_down(node->mask, pos-1);
+			if (rbits) {
+				rp = (void *)(val + (pos-rbits)*AVL_MIN_SIZE);
+			}
+		}
+	}
+
+	avl_combine(node, lp, lbits, rp, rbits, ptr, sbits, cpu);
+}
+
+/*
+ * Free memory region of given size.
+ * If freeing CPU is not the same as allocation one, chunk will 
+ * be placed into list of to-be-freed objects on allocation CPU,
+ * otherwise chunk will be freed and combined with neighbours.
+ * Must be called with disabled interrupts.
+ */
+static void __avl_free(void *ptr, unsigned int size)
+{
+	int cpu = avl_get_cpu_ptr((unsigned long)ptr);
+
+	if (cpu != smp_processor_id()) {
+		struct avl_free_list *l, *this = ptr;
+		struct avl_allocator_data *alloc = &avl_allocator[cpu];
+
+		this->cpu = smp_processor_id();
+		this->size = size;
+
+		spin_lock(&alloc->avl_free_lock);
+		l = alloc->avl_free_list_head;
+		alloc->avl_free_list_head = this;
+		this->next = l;
+		spin_unlock(&alloc->avl_free_lock);
+		return;
+	}
+
+	__avl_free_local(ptr, size);
+}
+
+/*
+ * Free memory region of given size without sniffer data update.
+ */
+void avl_free_no_zc(void *ptr, unsigned int size)
+{
+	unsigned long flags;
+	struct avl_free_list *l;
+	struct avl_allocator_data *alloc;
+	struct avl_chunk *ch = avl_ptr_to_chunk(ptr, size);
+
+	if (unlikely((ch->canary != AVL_CANARY) || ch->size != size)) {
+		printk("Freeing destroyed object: ptr: %p, size: %u, canary: %x, must be %x, refcnt: %d, saved size: %u.\n",
+				ptr, size, ch->canary, AVL_CANARY, atomic_read(&ch->refcnt), ch->size);
+		return;
+	}
+
+	if (atomic_dec_and_test(&ch->refcnt)) {
+		local_irq_save(flags);
+		__avl_free(ptr, size);
+		
+		alloc = &avl_allocator[smp_processor_id()];
+
+		while (alloc->avl_free_list_head) {
+			spin_lock(&alloc->avl_free_lock);
+			l = alloc->avl_free_list_head;
+			alloc->avl_free_list_head = l->next;
+			spin_unlock(&alloc->avl_free_lock);
+			__avl_free_local(l, l->size);
+		}
+		local_irq_restore(flags);
+	}
+}
+
+/*
+ * Free memory region of given size.
+ */
+void avl_free(void *ptr, unsigned int size)
+{
+	struct avl_chunk *ch = avl_ptr_to_chunk(ptr, size);
+
+	if (unlikely((ch->canary != AVL_CANARY) || ch->size != size)) {
+		printk("Freeing destroyed object: ptr: %p, size: %u, canary: %x, must be %x, refcnt: %d, saved size: %u.\n",
+				ptr, size, ch->canary, AVL_CANARY, atomic_read(&ch->refcnt), ch->size);
+		return;
+	}
+	avl_update_zc(avl_get_node_ptr((unsigned long)ptr), ptr, size);
+	avl_free_no_zc(ptr, size);
+}
+
+/*
+ * Initialize per-cpu allocator data.
+ */
+static int avl_init_cpu(int cpu)
+{
+	unsigned int i;
+	struct avl_allocator_data *alloc = &avl_allocator[cpu];
+	struct avl_node_entry *entry;
+
+	spin_lock_init(&alloc->avl_free_lock);
+	spin_lock_init(&alloc->avl_node_lock);
+	INIT_LIST_HEAD(&alloc->avl_node_list);
+
+	alloc->avl_container_array = kzalloc(sizeof(struct list_head) * AVL_CONTAINER_ARRAY_SIZE, GFP_KERNEL);
+	if (!alloc->avl_container_array)
+		goto err_out_exit;
+
+	for (i=0; i<AVL_CONTAINER_ARRAY_SIZE; ++i)
+		INIT_LIST_HEAD(&alloc->avl_container_array[i]);
+
+	entry = avl_node_entry_alloc(GFP_KERNEL, AVL_ORDER);
+	if (!entry)
+		goto err_out_free_container;
+
+	avl_node_entry_commit(entry, cpu);
+
+	return 0;
+
+err_out_free_container:
+	kfree(alloc->avl_container_array);
+err_out_exit:
+	return -ENOMEM;
+}
+
+/*
+ * Initialize network allocator.
+ */
+int avl_init(void)
+{
+	int err, cpu;
+
+	for_each_possible_cpu(cpu) {
+		err = avl_init_cpu(cpu);
+		if (err)
+			goto err_out;
+	}
+
+	err = avl_init_zc();
+
+	printk(KERN_INFO "Network tree allocator has been initialized.\n");
+	return 0;
+
+err_out:
+	panic("Failed to initialize network allocator.\n");
+
+	return -ENOMEM;
+}
diff --git a/net/core/alloc/avl.h b/net/core/alloc/avl.h
new file mode 100644
index 0000000..044d6a2
--- /dev/null
+++ b/net/core/alloc/avl.h
@@ -0,0 +1,223 @@
+/*
+ * 	avl.h
+ * 
+ * 2006 Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * All rights reserved.
+ * 
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHAAVLBILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef __AVL_H
+#define __AVL_H
+
+/*
+ * Zero-copy allocation control block.
+ * @ptr - pointer to allocated data.
+ * @off - offset inside given @avl_node_entry pages (absolute number of bytes)
+ * @size - size of the appropriate object
+ * @entry - number of @avl_node_entry which holds allocated object
+ * @number - number of @order-order pages in given @avl_node_entry
+ */
+
+struct zc_data
+{
+	union {
+		__u32		data[2];
+		void		*ptr;
+	} data;
+	__u32			off;
+	__u32			size;
+
+	__u32			entry;
+	__u32			cpu;
+};
+
+#define ZC_MAX_ENTRY_NUM	1000
+
+/*
+ * Zero-copy allocation request.
+ * @type - type of the message - ipv4/ipv6/...
+ * @res_len - length of reserved area at the beginning.
+ * @data - allocation control block.
+ */
+struct zc_alloc_ctl
+{
+	__u16		type;
+	__u16		res_len;
+	struct zc_data	zc;
+};
+
+struct zc_entry_status
+{
+	__u16		node_order, node_num;
+};
+
+struct zc_status
+{
+	unsigned int	entry_num;
+	struct zc_entry_status	entry[ZC_MAX_ENTRY_NUM];
+};
+
+#define ZC_ALLOC	_IOWR('Z', 1, struct zc_alloc_ctl)
+#define ZC_COMMIT	_IOR('Z', 2, struct zc_alloc_ctl)
+#define ZC_SET_CPU	_IOR('Z', 3, int)
+#define ZC_STATUS	_IOWR('Z', 4, struct zc_status)
+
+#define AVL_ORDER		2	/* Maximum allocation order */
+#define AVL_BITS		7	/* Must cover maximum number of pages used for allocation pools */
+
+#ifdef __KERNEL__
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/wait.h>
+#include <linux/spinlock.h>
+#include <asm/page.h>
+
+//#define AVL_DEBUG
+
+#ifdef AVL_DEBUG
+#define ulog(f, a...) printk(f, ##a)
+#else
+#define ulog(f, a...)
+#endif
+
+/*
+ * Network tree allocator variables.
+ */
+
+#define AVL_CANARY		0xc0d0e0f0
+
+#define AVL_ALIGN_SIZE		L1_CACHE_BYTES
+#define AVL_ALIGN(x) 		ALIGN(x, AVL_ALIGN_SIZE)
+
+#define AVL_NODES_ON_PAGE	(PAGE_SIZE/sizeof(struct avl_node))
+#define AVL_NODE_NUM		(1UL<<AVL_BITS)
+#define AVL_NODE_PAGES		((AVL_NODE_NUM+AVL_NODES_ON_PAGE-1)/AVL_NODES_ON_PAGE)
+
+#define AVL_MIN_SIZE		AVL_ALIGN_SIZE
+#define AVL_MAX_SIZE		((1<<AVL_ORDER) << PAGE_SHIFT)
+
+#define AVL_CONTAINER_ARRAY_SIZE	(AVL_MAX_SIZE/AVL_MIN_SIZE)
+
+struct avl_node_entry;
+
+/*
+ * Meta-information container for each contiguous block used in allocation.
+ * @value - start address of the contiguous block.
+ * @mask - bitmask of free and empty chunks [1 - free, 0 - used].
+ * @entry - pointer to parent node entry.
+ */
+struct avl_node
+{
+	unsigned long		value;
+	DECLARE_BITMAP(mask, AVL_MAX_SIZE/AVL_MIN_SIZE);
+	struct avl_node_entry	*entry;
+};
+
+/*
+ * Free chunks are dereferenced into this structure and placed into LIFO list.
+ */
+
+struct avl_container
+{
+	void			*ptr;
+	struct list_head	centry;
+};
+
+/*
+ * When freeing happens on different than allocation CPU,
+ * chunk is dereferenced into this structure and placed into
+ * single-linked list in allocation CPU private area.
+ */
+
+struct avl_free_list
+{
+	struct avl_free_list		*next;
+	unsigned int			size;
+	unsigned int			cpu;
+};
+
+/*
+ * This structure is placed after each allocated chunk and contains
+ * @canary - used to check memory overflow and reference counter for
+ * given memory region, which is used for example for zero-copy access.
+ * @size - used to check that freeing size is exactly the size of the object.
+ */
+
+struct avl_chunk
+{
+	unsigned int			canary, size;
+	atomic_t			refcnt;
+};
+
+/*
+ * Each array of nodes is places into dynamically grown list.
+ * @avl_node_array - array of nodes (linked into pages)
+ * @node_entry - entry in avl_allocator_data.avl_node_list.
+ * @avl_node_order - allocation order for each node in @avl_node_array
+ * @avl_node_num - number of nodes in @avl_node_array
+ * @avl_entry_num - number of this entry inside allocator
+ */
+
+struct avl_node_entry
+{
+	struct avl_node 	**avl_node_array;
+	struct list_head	node_entry;
+	u32			avl_entry_num;
+	u16 			avl_node_order, avl_node_num;
+};
+
+/*
+ * Main per-cpu allocator structure.
+ * @avl_container_array - array of lists of free chunks indexed by size of the elements
+ * @avl_free_list_head - single-linked list of objects, which were started to be freed on different CPU
+ * @avl_free_list_map_head - single-linked list of objects, which map update was started on different CPU
+ * @avl_free_lock - lock protecting avl_free_list_head
+ * @avl_node_list - list of avl_node_entry'es
+ * @avl_node_lock - lock used to protect avl_node_list from access from zero-copy devices.
+ * @entry_num - number of entries inside allocator.
+ */
+struct avl_allocator_data
+{
+	struct list_head 	*avl_container_array;
+	struct avl_free_list 	*avl_free_list_head;
+	struct avl_free_list 	*avl_free_map_list_head;
+	spinlock_t 		avl_free_lock;
+	struct list_head 	avl_node_list;
+	spinlock_t 		avl_node_lock;
+	u32			avl_entry_num;
+};
+
+void *avl_alloc(unsigned int size, gfp_t gfp_mask);
+void avl_free(void *ptr, unsigned int size);
+void avl_free_no_zc(void *ptr, unsigned int size);
+
+int avl_init_zc(void);
+int avl_init(void);
+void avl_fill_zc(struct zc_data *zc, void *ptr, unsigned int size);
+
+struct zc_control
+{
+	struct zc_data		*zcb;
+	unsigned int		zc_num, zc_used, zc_pos;
+	spinlock_t		zc_lock;
+	wait_queue_head_t	zc_wait;
+};
+
+extern struct zc_control zc_sniffer;
+extern struct avl_allocator_data avl_allocator[NR_CPUS];
+
+#endif /* __KERNEL__ */
+#endif /* __AVL_H */
diff --git a/net/core/alloc/zc.c b/net/core/alloc/zc.c
new file mode 100644
index 0000000..fcb386a
--- /dev/null
+++ b/net/core/alloc/zc.c
@@ -0,0 +1,483 @@
+/*
+ * 	zc.c
+ * 
+ * 2006 Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * All rights reserved.
+ * 
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/percpu.h>
+#include <linux/list.h>
+#include <linux/mm.h>
+#include <linux/fs.h>
+#include <linux/poll.h>
+#include <linux/ioctl.h>
+#include <linux/skbuff.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
+#include <linux/ip.h>
+#include <net/flow.h>
+#include <net/dst.h>
+#include <net/route.h>
+#include <asm/uaccess.h>
+
+#include "avl.h"
+
+struct zc_private
+{
+	struct zc_data	*zcb;
+	struct mutex	lock;
+	int		cpu;
+};
+
+static char zc_name[] = "zc";
+static int zc_major;
+struct zc_control zc_sniffer;
+
+static int zc_release(struct inode *inode, struct file *file)
+{
+	struct zc_private *priv = file->private_data;
+
+	kfree(priv);
+	return 0;
+}
+
+static int zc_open(struct inode *inode, struct file *file)
+{
+	struct zc_private *priv;
+	struct zc_control *ctl = &zc_sniffer;
+
+	priv = kzalloc(sizeof(struct zc_private) + ctl->zc_num * sizeof(struct zc_data), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+	priv->zcb = (struct zc_data *)(priv+1);
+	priv->cpu = 0; /* Use CPU0 by default */
+	mutex_init(&priv->lock);
+
+	file->private_data = priv;
+
+	return 0;
+}
+
+static int zc_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	struct zc_private *priv = file->private_data;
+	struct avl_allocator_data *alloc = &avl_allocator[priv->cpu];
+	struct avl_node_entry *e;
+	unsigned long flags, start = vma->vm_start;
+	int err = 0, idx, off;
+	unsigned int i, j, st, num, total_num;
+
+	st = vma->vm_pgoff;
+	total_num = (vma->vm_end - vma->vm_start)/PAGE_SIZE;
+
+	printk("%s: start: %lx, end: %lx, total_num: %u, st: %u.\n", __func__, start, vma->vm_end, total_num, st);
+
+	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+	vma->vm_flags |= VM_RESERVED;
+	vma->vm_file = file;
+
+	spin_lock_irqsave(&alloc->avl_node_lock, flags);
+	list_for_each_entry(e, &alloc->avl_node_list, node_entry) {
+		if (st >= e->avl_node_num*(1U<<e->avl_node_order)) {
+#if 0
+			printk("%s: continue on cpu: %d, e: %p, total_num: %u, node_num: %u, node_order: %u, pages_in_node: %u, st: %u.\n", 
+					__func__, priv->cpu, e, total_num, e->avl_node_num, e->avl_node_order, 
+					e->avl_node_num*(1U<<e->avl_node_order), st);
+#endif
+			st -= e->avl_node_num*(1U<<e->avl_node_order);
+			continue;
+		}
+		num = min_t(unsigned int, total_num, e->avl_node_num*(1<<e->avl_node_order));
+
+		printk("%s: cpu: %d, e: %p, total_num: %u, node_num: %u, node_order: %u, st: %u, num: %u.\n", 
+				__func__, priv->cpu, e, total_num, e->avl_node_num, e->avl_node_order, st, num);
+
+		idx = 0;
+		off = st;
+		for (i=st; i<num; ++i) {
+			struct avl_node *node = &e->avl_node_array[idx][off];
+
+			if (++off >= AVL_NODES_ON_PAGE) {
+				idx++;
+				off = 0;
+			}
+
+			for (j=0; (j<(1<<e->avl_node_order)) && (i<num); ++j, ++i) {
+				unsigned long virt = node->value + (j<<PAGE_SHIFT);
+				err = vm_insert_page(vma, start, virt_to_page(virt));
+				if (err) {
+					printk("\n%s: Failed to insert page for addr %lx into %lx, err: %d.\n",
+							__func__, virt, start, err);
+					break;
+				}
+				start += PAGE_SIZE;
+			}
+		}
+		if (err)
+			break;
+		total_num -= num;
+
+		if (total_num == 0)
+			break;
+	}
+	spin_unlock_irqrestore(&alloc->avl_node_lock, flags);
+
+	return err;
+}
+
+static ssize_t zc_write(struct file *file, const char __user *buf, size_t size, loff_t *off)
+{
+	ssize_t sz = 0;
+	struct zc_private *priv = file->private_data;
+	unsigned long flags;
+	unsigned int req_num = size/sizeof(struct zc_data), cnum, csize, i;
+	struct zc_control *ctl = &zc_sniffer;
+
+	while (size) {
+		cnum = min_t(unsigned int, req_num, ctl->zc_num);
+		csize = cnum*sizeof(struct zc_data);
+
+		if (copy_from_user(priv->zcb, buf, csize)) {
+			printk("%s: copy_from_user() failed.\n", __func__);
+			break;
+		}
+
+		spin_lock_irqsave(&ctl->zc_lock, flags);
+		for (i=0; i<cnum; ++i)
+			avl_free_no_zc(priv->zcb[i].data.ptr, priv->zcb[i].size);
+		ctl->zc_used -= cnum;
+		spin_unlock_irqrestore(&ctl->zc_lock, flags);
+
+		sz += csize;
+		size -= csize;
+		buf += csize;
+	}
+
+	return sz;
+}
+
+static ssize_t zc_read(struct file *file, char __user *buf, size_t size, loff_t *off)
+{
+	ssize_t sz = 0;
+	struct zc_private *priv = file->private_data;
+	unsigned long flags;
+	unsigned int pos, req_num = size/sizeof(struct zc_data), cnum, csize;
+	struct zc_control *ctl = &zc_sniffer;
+
+	wait_event_interruptible(ctl->zc_wait, ctl->zc_used > 0);
+
+	spin_lock_irqsave(&ctl->zc_lock, flags);
+	cnum = min_t(unsigned int, req_num, ctl->zc_used);
+	csize = cnum*sizeof(struct zc_data);
+	if (ctl->zc_used) {
+		if (ctl->zc_pos >= ctl->zc_used) {
+			pos = ctl->zc_pos - ctl->zc_used;
+			memcpy(priv->zcb, &ctl->zcb[pos], csize);
+		} else {
+			memcpy(priv->zcb, &ctl->zcb[0], csize);
+			pos = ctl->zc_num - (ctl->zc_used - ctl->zc_pos);
+			memcpy(&priv->zcb[ctl->zc_pos], &ctl->zcb[pos], 
+					(ctl->zc_used - ctl->zc_pos)*sizeof(struct zc_data));
+		}
+	}
+	spin_unlock_irqrestore(&ctl->zc_lock, flags);
+
+	sz = csize;
+
+	if (copy_to_user(buf, priv->zcb, cnum*sizeof(struct zc_data)))
+		sz = -EFAULT;
+
+	return sz;
+}
+
+static unsigned int zc_poll(struct file *file, struct poll_table_struct *wait)
+{
+	struct zc_control *ctl = &zc_sniffer;
+	unsigned int poll_flags = 0;
+	
+	poll_wait(file, &ctl->zc_wait, wait);
+
+	if (ctl->zc_used)
+		poll_flags = POLLIN | POLLRDNORM;
+
+	return poll_flags;
+}
+
+static int zc_ctl_alloc(struct zc_alloc_ctl *ctl, void __user *arg)
+{
+	void *ptr;
+	unsigned int size = SKB_DATA_ALIGN(ctl->zc.size) + sizeof(struct skb_shared_info);
+
+	ptr = avl_alloc(size, GFP_KERNEL);
+	if (!ptr)
+		return -ENOMEM;
+
+	avl_fill_zc(&ctl->zc, ptr, ctl->zc.size);
+
+	memset(ptr, 0, size);
+	
+	if (copy_to_user(arg, ctl, sizeof(struct zc_alloc_ctl))) {
+		avl_free(ptr, size);
+		return -EFAULT;
+	}
+
+	return 0;
+}
+
+static int netchannel_ip_route_output_flow(struct rtable **rp, struct flowi *flp, int flags)
+{
+	int err;
+
+	err = __ip_route_output_key(rp, flp);
+	if (err)
+		return err;
+
+	if (flp->proto) {
+		if (!flp->fl4_src)
+			flp->fl4_src = (*rp)->rt_src;
+		if (!flp->fl4_dst)
+			flp->fl4_dst = (*rp)->rt_dst;
+	}
+
+	return 0;
+}
+
+struct dst_entry *netchannel_route_get_raw(u32 faddr, u16 fport, 
+		u32 laddr, u16 lport, u8 proto)
+{
+	struct rtable *rt;
+	struct flowi fl = { .oif = 0,
+			    .nl_u = { .ip4_u =
+				      { .daddr = faddr,
+					.saddr = laddr,
+					.tos = 0 } },
+			    .proto = proto,
+			    .uli_u = { .ports =
+				       { .sport = lport,
+					 .dport = fport } } };
+
+	if (netchannel_ip_route_output_flow(&rt, &fl, 0))
+		goto no_route;
+	return dst_clone(&rt->u.dst);
+
+no_route:
+	return NULL;
+}
+
+static int zc_ctl_commit(struct zc_alloc_ctl *ctl)
+{
+	struct iphdr *iph;
+	void *data;
+	struct sk_buff *skb;
+	unsigned int data_len;
+	struct skb_shared_info *shinfo;
+	u16 *thdr;
+
+	printk("%s: ptr: %p, size: %u, reserved: %u, type: %x.\n", 
+			__func__, ctl->zc.data.ptr, ctl->zc.size, ctl->res_len, ctl->type);
+	
+	if (ctl->type != 0)
+		return -ENOTSUPP;
+
+	data = ctl->zc.data.ptr;
+	iph = (struct iphdr *)(data + ctl->res_len);
+	data_len = ntohs(iph->tot_len);
+	thdr = (u16 *)(((u8 *)iph) + (iph->ihl<<2));
+
+	skb = alloc_skb_empty(ctl->zc.size, GFP_KERNEL);
+	if (!skb)
+		return -ENOMEM;
+
+	skb->head = data;
+	skb->data = data;
+	skb->tail = data;
+	skb->end  = data + ctl->zc.size;
+	
+	shinfo = skb_shinfo(skb);
+	atomic_set(&shinfo->dataref, 1);
+	shinfo->nr_frags  = 0;
+	shinfo->gso_size = 0;
+	shinfo->gso_segs = 0;
+	shinfo->gso_type = 0;
+	shinfo->ip6_frag_id = 0;
+	shinfo->frag_list = NULL;
+
+	skb->csum = 0;
+	skb_reserve(skb, ctl->res_len);
+	skb_put(skb, data_len-ctl->res_len);
+
+	printk("%u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, proto: %u, len: %u, skb_len: %u.\n", 
+			NIPQUAD(iph->saddr), ntohs(thdr[0]), 
+			NIPQUAD(iph->daddr), ntohs(thdr[1]), 
+			iph->protocol, data_len, skb->len);
+
+	skb->dst = netchannel_route_get_raw(
+			iph->daddr, thdr[1], 
+			iph->saddr, thdr[0], 
+			iph->protocol);
+	if (!skb->dst) {
+		printk("%s: failed to get route.\n", __func__);
+		goto err_out_free;
+	}
+
+	skb->h.th = (void *)thdr;
+	skb->nh.iph = iph;
+
+	printk("%u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, proto: %u, dev: %s, skb: %p, data: %p.\n", 
+			NIPQUAD(iph->saddr), ntohs(thdr[0]), 
+			NIPQUAD(iph->daddr), ntohs(thdr[1]), 
+			iph->protocol, skb->dst->dev ? skb->dst->dev->name : "<NULL>",
+			skb, skb->data);
+
+	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, skb->dst->dev, dst_output);
+
+err_out_free:
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
+struct zc_status *zc_get_status(int cpu, unsigned int start)
+{
+	unsigned long flags;
+	struct avl_node_entry *e;
+	struct avl_allocator_data *alloc = &avl_allocator[cpu];
+	struct zc_status *st;
+	struct zc_entry_status *es;
+	unsigned int num = 0;
+
+	st = kmalloc(sizeof(struct zc_status), GFP_KERNEL);
+	if (!st)
+		return NULL;
+	
+	spin_lock_irqsave(&alloc->avl_node_lock, flags);
+	list_for_each_entry(e, &alloc->avl_node_list, node_entry) {
+		if (e->avl_entry_num >= start && num < ZC_MAX_ENTRY_NUM) {
+			es = &st->entry[num];
+
+			es->node_order = e->avl_node_order;
+			es->node_num = e->avl_node_num;
+			num++;
+		}
+	}
+	spin_unlock_irqrestore(&alloc->avl_node_lock, flags);
+
+	st->entry_num = num;
+
+	return st;
+}
+
+static int zc_ioctl(struct inode *inode, struct file *file, unsigned int cmd, unsigned long arg)
+{
+	struct zc_alloc_ctl ctl;
+	struct zc_private *priv = file->private_data;
+	int cpu, ret = -EINVAL;
+	unsigned int start;
+	struct zc_status *st;
+
+	mutex_lock(&priv->lock);
+
+	switch (cmd) {
+		case ZC_ALLOC:
+		case ZC_COMMIT:
+			if (copy_from_user(&ctl, (void __user *)arg, sizeof(struct zc_alloc_ctl))) {
+				ret = -EFAULT;
+				break;
+			}
+
+			if (cmd == ZC_ALLOC) 
+				ret = zc_ctl_alloc(&ctl, (void __user *)arg);
+			else
+				ret = zc_ctl_commit(&ctl);
+			break;
+		case ZC_SET_CPU:
+			if (copy_from_user(&cpu, (void __user *)arg, sizeof(int))) {
+				ret = -EFAULT;
+				break;
+			}
+			if (cpu < NR_CPUS && cpu >= 0) {
+				priv->cpu = cpu;
+				ret = 0;
+			}
+			break;
+		case ZC_STATUS:
+			if (copy_from_user(&start, (void __user *)arg, sizeof(unsigned int))) {
+				printk("%s: failed to read initial entry number.\n", __func__);
+				ret = -EFAULT;
+				break;
+			}
+
+			st = zc_get_status(priv->cpu, start);
+			if (!st) {
+				ret = -ENOMEM;
+				break;
+			}
+
+			ret = 0;
+			if (copy_to_user((void __user *)arg, st, sizeof(struct zc_status))) {
+				printk("%s: failed to write CPU%d status.\n", __func__, priv->cpu);
+				ret = -EFAULT;
+			}
+			kfree(st);
+			break;
+	}
+
+	mutex_unlock(&priv->lock);
+
+	return ret;
+}
+
+static struct file_operations zc_ops = {
+	.poll		= &zc_poll,
+	.ioctl		= &zc_ioctl,
+	.open 		= &zc_open,
+	.release 	= &zc_release,
+	.read		= &zc_read,
+	.write		= &zc_write,
+	.mmap 		= &zc_mmap,
+	.owner 		= THIS_MODULE,
+};
+
+int avl_init_zc(void)
+{
+	struct zc_control *ctl = &zc_sniffer;
+
+	ctl->zc_num = 1024;
+	init_waitqueue_head(&ctl->zc_wait);
+	spin_lock_init(&ctl->zc_lock);
+	ctl->zcb = kmalloc(ctl->zc_num * sizeof(struct zc_data), GFP_KERNEL);
+	if (!ctl->zcb)
+		return -ENOMEM;
+
+	zc_major = register_chrdev(0, zc_name, &zc_ops);
+       	if (zc_major < 0) {
+		printk(KERN_ERR "Failed to register %s char device: err=%d. Zero-copy is disabled.\n", 
+				zc_name, zc_major);
+		return -EINVAL;
+	}
+
+	printk(KERN_INFO "Network zero-copy sniffer has been enabled with %d major number.\n", zc_major);
+
+	return 0;
+}
+
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 022d889..7eec140 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -125,6 +125,33 @@ EXPORT_SYMBOL(skb_truesize_bug);
  *
  */
 
+
+/**
+ * 	__alloc_skb_empty - allocate an empty network buffer
+ *	@size: size to allocate
+ *	@gfp_mask: allocation mask
+ */
+
+struct sk_buff *__alloc_skb_emtpy(unsigned int size, gfp_t gfp_mask)
+{
+	struct skb_shared_info *shinfo;
+	struct sk_buff *skb;
+
+	/* Get the HEAD */
+	skb = kmem_cache_alloc(skbuff_head_cache, gfp_mask & ~__GFP_DMA);
+	if (!skb)
+		goto out;
+
+	memset(skb, 0, offsetof(struct sk_buff, truesize));
+	
+	size = SKB_DATA_ALIGN(size);
+	skb->truesize = size + sizeof(struct sk_buff);
+	atomic_set(&skb->users, 1);
+
+out:
+	return skb;
+}
+
 /**
  *	__alloc_skb	-	allocate a network buffer
  *	@size: size to allocate
@@ -156,7 +183,7 @@ struct sk_buff *__alloc_skb(unsigned int
 
 	/* Get the DATA. Size must match skb_add_mtu(). */
 	size = SKB_DATA_ALIGN(size);
-	data = ____kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
+	data = avl_alloc(size + sizeof(struct skb_shared_info), gfp_mask);
 	if (!data)
 		goto nodata;
 
@@ -223,7 +250,7 @@ struct sk_buff *alloc_skb_from_cache(kme
 
 	/* Get the DATA. */
 	size = SKB_DATA_ALIGN(size);
-	data = kmem_cache_alloc(cp, gfp_mask);
+	data = avl_alloc(size, gfp_mask);
 	if (!data)
 		goto nodata;
 
@@ -313,7 +340,7 @@ static void skb_release_data(struct sk_b
 		if (skb_shinfo(skb)->frag_list)
 			skb_drop_fraglist(skb);
 
-		kfree(skb->head);
+		avl_free(skb->head, skb->end - skb->head + sizeof(struct skb_shared_info));
 	}
 }
 
@@ -688,7 +715,7 @@ int pskb_expand_head(struct sk_buff *skb
 
 	size = SKB_DATA_ALIGN(size);
 
-	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
+	data = avl_alloc(size + sizeof(struct skb_shared_info), gfp_mask);
 	if (!data)
 		goto nodata;
 
@@ -2057,6 +2084,9 @@ void __init skb_init(void)
 						NULL, NULL);
 	if (!skbuff_fclone_cache)
 		panic("cannot create skbuff cache");
+
+	if (avl_init())
+		panic("Failed to initialize network tree allocator.\n");
 }
 
 EXPORT_SYMBOL(___pskb_trim);

-- 
	Evgeniy Polyakov
