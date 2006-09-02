From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [1/1] netwrok allocator. Sending and receiving zero-copy support. Benchmark.
Date: Sat, 2 Sep 2006 18:17:44 +0400
Message-ID: <20060902141744.GA18023@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="mP3DRpeJDSE+ciuQ"
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:14489 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751097AbWIBOSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2006 10:18:30 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--mP3DRpeJDSE+ciuQ
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline

Hello.

This patch introduce network-based receiving and sending zero-copy
support. Receiving side is used for zero-copy sniffer (it is possible to
dump all network allocations including netlink, unix socket and so on), 
sending side zero-copy is used for userspace netchannels network stack
implementation [4].

Receiving zero-copy support.
Information about each network allocation is stored in special buffer
accessible from userspace through read/write for special char device.
This information is added when skb is freed, so data placed there is
valid. Such approach does not allow to store transient state of the
data, for example encrypted IPsec packets if decryption happens
in-place, to store such states it is required to copy information into
allocated buffer (which then can be immediately freed, or decryption can
happen from source do destination buffers).
Userspace can mmap whole allocation pool (using special commands via
ioctl() to get appropriate information) and thus access data without any
copy. 
Zero-copy sniffer has following overheads: 
several atomic operations (in the worst case one atomic_set(), one 
atomic_inc() and one or two atomic_dec_and_test()), 
one lock (bad global lock per sniffer device), which is held when 
information about new packet is being put into sniffer's queue when skb
is freed,
delayed freeing which can lead to increased memory usage, or (like
implemented) if introduced maximum amount of "locked" data by sniffer,
some packets can be dropped by sniffer.

Sending zero-copy support.
Sending is performaed in two steps. First one is allocation, new object
can be accessed without any copy like described above (and actually can
be used with things like kevents to implement proposed by Ulrich Drepper 
"DMA" allocation (allocation of data, which can be used both by kernel
and userspace without additional copies)). Second step is data commit,
where allocated packet is attached to special skb and pushed into the
stack using dst_output().

Above extensions are possible due to design of network allocator.
Benchmark test for NTA shows very noticeble performance improvement
over existing SLAB one (epoll based web server showed 40% improvement 
in number of processed requests per second, details can be found on 
project homepage [1]).

For testing zero-copy sniffer I ran scp over 100Mb lan and dump header
into the file. Graph for both tcpdump and zero-copy sniffer sequence
numbers is attached. Test shows that there are no dropped packets by
sniffer (although for scp of big file over 100Mb lan tcpdump does not
drop packets too), in my current environment it is not very exciting
test though.

When both sniffers dump the whole traffic into /dev/null, CPU usage for
zero-copy sniffer is about 2 times less than with tcpdump.

Interested reader can find all userspace applications (zero-copy sniffer
and sending program) on project homepage [1].

Limitations of current version (introduced not due to design problems,
but intentionally to test various special usage cases):
 - use NTA only for netdev_alloc_skb() and sk_stream_alloc_pskb().
 - always compile zero-copy sniffer in, which increases memory usage
   and adds described above overhead.
 - skb_copy() always allocate data from SLAB allocator, although it
   could check if original skb's data was allocated through NTA, but I
   think that skb_copy() is completely incompatible with high
   performance.
 - it is possible to eliminate several atomic operations (I'm lazy).
 - debug code (poisoning of the tail of the buffer and additional
   reference counter) is always compiled in.


I would like to ask that should I make some steps for preparing that code
for inclusion, and if so it would be good to start to discuss it, or if
that code is not very interesting, so I will use it only for my own
netchannels [3] developemnt. At this stage I do not copy his message to 
linux-kernel@ and linux-mm@ mail lists, since practice shows that it is
not always the right way to solve technical problems.

Thank you.

1. Network tree allocator. 
http://tservice.net.ru/~s0mbre/old/?section=projects&item=nta

2. Sending and receiving zero-copy networking.
http://tservice.net.ru/~s0mbre/blog/devel/networking/zcs/index.html

3. Netchannels implementation.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=netchannel

4. Userspace network stack.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=unetstack

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 80e8ca0..4aba97b 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1680,7 +1680,7 @@ vortex_open(struct net_device *dev)
 			vp->rx_ring[i].next = cpu_to_le32(vp->rx_ring_dma + sizeof(struct boom_rx_desc) * (i+1));
 			vp->rx_ring[i].status = 0;	/* Clear complete bit. */
 			vp->rx_ring[i].length = cpu_to_le32(PKT_BUF_SZ | LAST_FRAG);
-			skb = dev_alloc_skb(PKT_BUF_SZ);
+			skb = netdev_alloc_skb(dev, PKT_BUF_SZ);
 			vp->rx_skbuff[i] = skb;
 			if (skb == NULL)
 				break;			/* Bad news!  */
@@ -2405,7 +2405,7 @@ static int vortex_rx(struct net_device *
 			int pkt_len = rx_status & 0x1fff;
 			struct sk_buff *skb;
 
-			skb = dev_alloc_skb(pkt_len + 5);
+			skb = netdev_alloc_skb(dev, pkt_len + 5);
 			if (vortex_debug > 4)
 				printk(KERN_DEBUG "Receiving packet size %d status %4.4x.\n",
 					   pkt_len, rx_status);
@@ -2486,7 +2486,7 @@ boomerang_rx(struct net_device *dev)
 
 			/* Check if the packet is long enough to just accept without
 			   copying to a properly sized skbuff. */
-			if (pkt_len < rx_copybreak && (skb = dev_alloc_skb(pkt_len + 2)) != 0) {
+			if (pkt_len < rx_copybreak && (skb = netdev_alloc_skb(dev, pkt_len + 2)) != 0) {
 				skb->dev = dev;
 				skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
 				pci_dma_sync_single_for_cpu(VORTEX_PCI(vp), dma, PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
@@ -2525,7 +2525,7 @@ boomerang_rx(struct net_device *dev)
 		struct sk_buff *skb;
 		entry = vp->dirty_rx % RX_RING_SIZE;
 		if (vp->rx_skbuff[entry] == NULL) {
-			skb = dev_alloc_skb(PKT_BUF_SZ);
+			skb = netdev_alloc_skb(dev, PKT_BUF_SZ);
 			if (skb == NULL) {
 				static unsigned long last_jif;
 				if (time_after(jiffies, last_jif + 10 * HZ)) {
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 19c96d4..bb1018c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -282,7 +282,8 @@ struct sk_buff {
 				nfctinfo:3;
 	__u8			pkt_type:3,
 				fclone:2,
-				ipvs_property:1;
+				ipvs_property:1,
+				nta:1;
 	__be16			protocol;
 
 	void			(*destructor)(struct sk_buff *skb);
@@ -327,22 +328,43 @@ #include <linux/slab.h>
 
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
+extern struct sk_buff *__alloc_skb_nta(unsigned int size, gfp_t gfp_mask,
+			    int fclone);
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
 	return __alloc_skb(size, priority, 1);
 }
 
+static inline struct sk_buff *alloc_skb_nta(unsigned int size,
+					gfp_t priority, int fclone)
+{
+	return __alloc_skb_nta(size, priority, fclone);
+}
+
 extern struct sk_buff *alloc_skb_from_cache(kmem_cache_t *cp,
 					    unsigned int size,
 					    gfp_t priority);
diff --git a/include/net/sock.h b/include/net/sock.h
index 324b3ea..6af3198 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1178,7 +1178,7 @@ static inline struct sk_buff *sk_stream_
 	int hdr_len;
 
 	hdr_len = SKB_DATA_ALIGN(sk->sk_prot->max_header);
-	skb = alloc_skb_fclone(size + hdr_len, gfp);
+	skb = alloc_skb_nta(size + hdr_len, gfp, 1);
 	if (skb) {
 		skb->truesize += mem;
 		if (sk_stream_wmem_schedule(sk, skb->truesize)) {
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
index 0000000..8fe7016
--- /dev/null
+++ b/net/core/alloc/avl.c
@@ -0,0 +1,767 @@
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
+	off = ((unsigned long)node & ~PAGE_MASK)/sizeof(struct avl_node)*((1U<<node->entry->avl_node_order)<<PAGE_SHIFT);
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
index 0000000..2a72b9f
--- /dev/null
+++ b/net/core/alloc/avl.h
@@ -0,0 +1,224 @@
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
+
+	__u32			off;
+	__u32			size;
+
+	__u32			entry;
+	__u32			cpu;
+};
+
+#define ZC_MAX_ENTRY_NUM	170
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
index 0000000..f321218
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
+		for (i=st; i<num;) {
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
index 022d889..27f2b9b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -125,6 +125,104 @@ EXPORT_SYMBOL(skb_truesize_bug);
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
+/**
+ *	__alloc_skb_nta	-	allocate a network buffer
+ *	@size: size to allocate
+ *	@gfp_mask: allocation mask
+ *	@fclone: allocate from fclone cache instead of head cache
+ *		and allocate a cloned (child) skb
+ *
+ *	Allocate a new &sk_buff. The returned buffer has no headroom and a
+ *	tail room of size bytes. The object has a reference count of one.
+ *	The return is the buffer. On a failure the return is %NULL.
+ *
+ *	Buffers may only be allocated from interrupts using a @gfp_mask of
+ *	%GFP_ATOMIC.
+ *
+ *	This function uses special network allocator.
+ */
+struct sk_buff *__alloc_skb_nta(unsigned int size, gfp_t gfp_mask,
+			    int fclone)
+{
+	kmem_cache_t *cache;
+	struct skb_shared_info *shinfo;
+	struct sk_buff *skb;
+	u8 *data;
+
+	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
+
+	/* Get the HEAD */
+	skb = kmem_cache_alloc(cache, gfp_mask & ~__GFP_DMA);
+	if (!skb)
+		goto out;
+
+	/* Get the DATA. Size must match skb_add_mtu(). */
+	size = SKB_DATA_ALIGN(size);
+	data = avl_alloc(size + sizeof(struct skb_shared_info), gfp_mask);
+	if (!data)
+		goto nodata;
+
+	memset(skb, 0, offsetof(struct sk_buff, truesize));
+	skb->truesize = size + sizeof(struct sk_buff);
+	skb->nta = 1;
+	atomic_set(&skb->users, 1);
+	skb->head = data;
+	skb->data = data;
+	skb->tail = data;
+	skb->end  = data + size;
+	/* make sure we initialize shinfo sequentially */
+	shinfo = skb_shinfo(skb);
+	atomic_set(&shinfo->dataref, 1);
+	shinfo->nr_frags  = 0;
+	shinfo->gso_size = 0;
+	shinfo->gso_segs = 0;
+	shinfo->gso_type = 0;
+	shinfo->ip6_frag_id = 0;
+	shinfo->frag_list = NULL;
+
+	if (fclone) {
+		struct sk_buff *child = skb + 1;
+		atomic_t *fclone_ref = (atomic_t *) (child + 1);
+
+		skb->fclone = SKB_FCLONE_ORIG;
+		atomic_set(fclone_ref, 1);
+
+		child->fclone = SKB_FCLONE_UNAVAILABLE;
+	}
+out:
+	return skb;
+nodata:
+	kmem_cache_free(cache, skb);
+	skb = NULL;
+	goto out;
+}
+
 /**
  *	__alloc_skb	-	allocate a network buffer
  *	@size: size to allocate
@@ -267,7 +365,7 @@ struct sk_buff *__netdev_alloc_skb(struc
 {
 	struct sk_buff *skb;
 
-	skb = alloc_skb(length + NET_SKB_PAD, gfp_mask);
+	skb = __alloc_skb_nta(length + NET_SKB_PAD, gfp_mask, 0);
 	if (likely(skb))
 		skb_reserve(skb, NET_SKB_PAD);
 	return skb;
@@ -313,7 +411,10 @@ static void skb_release_data(struct sk_b
 		if (skb_shinfo(skb)->frag_list)
 			skb_drop_fraglist(skb);
 
-		kfree(skb->head);
+		if (skb->nta)
+			avl_free(skb->head, skb->end - skb->head + sizeof(struct skb_shared_info));
+		else
+			kfree(skb->head);
 	}
 }
 
@@ -494,6 +595,7 @@ #ifdef CONFIG_NET_CLS_ACT
 #endif
 	skb_copy_secmark(n, skb);
 #endif
+	C(nta);
 	C(truesize);
 	atomic_set(&n->users, 1);
 	C(head);
@@ -678,7 +780,7 @@ out:
 int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		     gfp_t gfp_mask)
 {
-	int i;
+	int i, nta = skb->nta;
 	u8 *data;
 	int size = nhead + (skb->end - skb->head) + ntail;
 	long off;
@@ -687,8 +789,10 @@ int pskb_expand_head(struct sk_buff *skb
 		BUG();
 
 	size = SKB_DATA_ALIGN(size);
-
-	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
+	if (nta)
+		data = avl_alloc(size + sizeof(struct skb_shared_info), gfp_mask);
+	else
+		data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
 	if (!data)
 		goto nodata;
 
@@ -714,6 +818,7 @@ int pskb_expand_head(struct sk_buff *skb
 	skb->mac.raw += off;
 	skb->h.raw   += off;
 	skb->nh.raw  += off;
+	skb->nta      = nta;
 	skb->cloned   = 0;
 	skb->nohdr    = 0;
 	atomic_set(&skb_shinfo(skb)->dataref, 1);
@@ -2057,6 +2162,9 @@ void __init skb_init(void)
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

--mP3DRpeJDSE+ciuQ
Content-Type: image/png
Content-Disposition: attachment; filename="sending_seq.png"
Content-Transfer-Encoding: base64

iVBORw0KGgoAAAANSUhEUgAAAoAAAAHPEAIAAAAc2SATAAAACXBIWXMAAAsSAAALEgHS3X78
AAAaNUlEQVR42u3d4ZKcuBWAUbM17//K5Eevs9iMNAJJIOmeU5VUatwGGkFnPgvobd/3fd9/
AQAAwNL+sQsAAACIQAADAAAQwlIBvG3btm0jrGs7cagBAAC8a5EAfj59P/dOn9d7/NMjGQwA
APCu6QP4GJxtl1myLnELAAAwi6/Z30B5+p4z1ROwAQAA4pg+gEukZolLLmb+/O/yVG41J2xW
GQAAWMkIE5AhAvgjn5THwai/rDoV2/XbCQAAMKMet69eFSiAZ7zg2UXaY560RsfoYHSMC0bH
6Bgdo8O9cXlX6O8BTg1D6lQ5X958/jcM87cAAABjmn4GuOTe3dR9uff+Tei4tPMS2q4LAACA
VjZhNtyQuGwDAOCiEe4txLFnb+T30ud/v7uvQl8CDQA1tpPn124UcCzJj8jHbf7ofebzudW3
wPAMAQwAlx1/4c7fbvPWthkjYF4lWZv/7C15DTEJYABoZoQ5KPNgxGHud1VXx7Tk9b2PE5k9
i0BfgwQAz8s/FvH463v+/qiSX6pKlnBvXfd+cSxZzr3XHF+ZSqCSb2poNRY99mHJ9pS89/Pf
zf+tmvf1/DF29QjMb/k476vVWJS865Jz563Put7J2mqbx/x/ns+Wjr2d7xDAAHBZyTP/r4ZZ
/hev8l9/yy8dvLqu8l/7ysOs5jXl4/XMWLTdh+VbePWITW1nq/f1zDFW/q7v7c9+x0b5GNWP
xTP7udU+LPkcO38daeqzt+Q1rbaZuQhgALjp3qxjyXKe3OZ+a0l9MeF5jz3z3vuNRb/3Ndov
2ff2YT5vUsdGjy1PraX+ffUezZFzq3xM699F/p8Ayl/z5Lg/eXamfyLX/yOAAaCjyLMEJXMm
68X/2uPe6n09OZ9Wsnyzecd9Nf6YOk9T7+Y4kqI3xUOwAOCyml8TR35EynHmpObrQ+5dnn3+
u/e2p3ybW41F261668h8Zo01x0b+iE2tq9VduDN+5pzPndRsfNt9Ne/joOo/2/1jyvjMAAPA
ZSX3AJe8pmZdZ+c73966oLft/il5TM7Vn7Qdix7jfm978kfL1ctBnzyee88Ap7ZktPfV+9y5
elQ8P6atPsdGOw6fJcKzx5h/pRhuSCZ7yhwA63jyAUU9thNHr6OifG/Mcr479lbaS5///e6+
MgMMAPxr9VkR1j967Qfnu2OPPAEMAPzBo2sgzlnsbIpp2z7/+RwDn//kfr4SAQwAABRxue/4
++QYsfdev2r6fngKNAAwtPqnUtev3SjgWBo5fd/dt88/9fqTrKn/rnsvK6fvhxlgAGBQIz+k
xzwYOCN67s/alK1Z79oZLIABgMmM8Eu2X/SJQ9yWfyaUPX/7nbi9MuIrZ7AABgCml3+S7fFX
0vxXcVz9vuX87PTVddV/b2rNuvLfl1s+G99vLHrsw5LtKXnvqW9j7vG+nj/Gyo/Amu0p//7q
/HnaarzufZ/27787euLmmQEGAHhByde0XA2zfEiU/8p+9Vfw8nWVJ0r5L/o1rykfr2fGou0+
LN/Cq0dsajtbva9njrF777rm2HjmWK0fr3Qgjh6OEe7yzRPAAMDQ7s06liznyW3ut5bzXFar
PLin31j0e1+jXdx7bx+es63k2Bjt7B7rs+f7udw58lHopghgAGB6ke9OLJm3XC/+1x73Vu+r
fk57bb/j9hi6qegd7Qj5Pm6P9+5GeJzVPb4GCQAYVM383shfOXOcnav5eqd7l2ef/+697Snf
5lZj0Xar3joyn1ljzbGRP2J7j9f5OKyJ9j+/HOjv0B318+Gzx3P/nXqnxz89ZvCo7/UdZoAB
gEGV3ANc8pqadZ2dH/nz1gW9bfdPfnvyjw56Zix6jPu97ckfLT89AfjN47nfDHD+oVw1x+FP
7+vz6plmcXvMyqaWaQb4m3PQhRDDDUn26XkAwOxG/n7jkbeHtY+K9Hkx3xym7EyN7+/98+an
ihlgAIBHPT87B22P3rbLnOv+29/7QeLOSgADALxg/NwV5NSb9x5UibsqAQwAANwkcZmLAAYA
AJIkLisRwAAAEJrEJQ4BDAAAi5O48CGAAQBgYuIWyglgAAAYmsSFVgQwAAC8TOLCMwQwAAB0
J3FhBAIYAACqzBu3HxKXOAQwAAD8wPwtrEEAAwCAxIUQXg7gbdu2Pz9o9n3fr5zA5yXULO3q
elPLr39fAAC0JXGB1wI4FZD5sEx/KDyXl8ctPG9t2/cFAEA5iQvkuQT6G+URm8pgAAB6mDFx
xS2MY6kAPl54nMrX408kKwDAaCQu0M9rAXycO61fWv5S5JIZ3fOW5HP66vu6F9uiHQBYj8SF
1c/xNpXXw8szwCXztFeXcG8YSu7jLV+Le4ABgMgkLjCmQPcAzxifghkAGI0HTQE/nWu105z9
DPcU6Kuv7zFbm1ra+YJq87oAwHokLrCql+Ot5B7XJ19zdct7fA/wvXuPAQDKSVzgSeM0zjSz
l3HmWgUwAFBP4gLjGKdxprkHWAoCAHzMG7cfEhd4S6CHYAEAzML8LUAPAhgA4AUSF+B5AhgA
oAuJCzAaAQwAcJPEBZiLAAYASJoxccUtQIoABgBCk7gAcQhgAGBZLlEG4EgAAwATk7gAlBPA
AMDQJC4ArQhgAOBlEheAZwhgAKA7iQvACAQwANCAZykDMD4BDAD8wPwtAGsQwACAxAUgBAEM
ACFIXAAQwACwCIkLAHkCGAAmMG/cfkhcAEYggAFgCOZvAaA3AQwAD5G4APAuAQwAzUhcABiZ
AAaACyQuAMxLAAPAH2ZMXHELACUEMADhSFwAiEkAA7AgiQsAnAlgAKYkcQGAqwQwAIOSuABA
WwIYgBd4ljIA8DwBDEAXEhcAGI0ABuAmiQsAzEUAA/CNeeP2Q+ICAGcCGCAoiQsARCOAAZbl
EmUAgCMBDDAxiQsAUE4AAwxN4gIAtCKAAV42Y+KKWwBgRosE8LZt25+/Pu77vvf85eyzxtRa
nt8eYEzmbwEAxjF9AKdCNB+ordZ4Xsvz2wO8S+ICAMzCJdDfKI/YVAYDa30mSFwAgBUECmCX
JQMpEhcAIILpA/g4B5t6TcmM7nkJx5+Up3JqafdiW7RDKxIXAOAZ+Tp71yIzwKm4LR+Gkvt4
ywfbPcDwPM9SBgAgL9Al0DPGp2CGI4kLADC+kunJtyz7FOiav5ta2vmRV+Z1ofUZLXEBAOhl
2XuAU89qTr3m3hpT8ezeXThzFy4AAO9a9h7ge69ptUa5S0wSFwCAkfkeYOACiQsAwLwEMPCv
eeP2Q+ICAJAngCEQiQsAQGQCGJbiEmUAAEgRwDAZiQsAAPcIYBiOxAUAgB4EMLxgxsQVtwAA
zE4AQxcSFwAARiOA4SaJCwAAcxHAkCRxAQBgJQKYoDxoCgAAohHALEviAgAARwKYiUlcAACg
nABmaBIXAABoRQDzMokLAAA8QwDTkbgFAADGIYCpInEBAIBZCGB+IHEBAIA1CGAkLgAAEIIA
DkHiAgAACODpiVsAAIASAngCEhcAAKCeAB7IOXTHT1+JCwAAzEIAD+QTk6NFr8QFAADWIICR
uAAAQAgCeHHiFgAA4EMAD+Texc8SFwAAoIQAHsj5HmBxCwAA0Mo/dgEAAAARCGAAAABCEMAA
AACEIIABAAAIQQADAAAQggAGAAAgBAEMAABACAIYAACAEL7eXf22bdu2HX+y7/u+7zVLqFna
1fWmll//vgAAAGjrtQBOBWQ+LFOezMvjFp63tu37AgAAoBWXQH8jNat8jthjBttvAAAAI/ta
6c0cQzQ1B3v8iflYAACAOF4L4NTc6b0ozV+KXHJZ8nlL8jn95PuqXw4AAMAzRr5Cdvp7gMtf
Wf64rJr7dd0DDAAAMKalLoHOmzE+BTMAADCXkttR3zLNQ7DyD6Zqu8xUdp4vbzavCwAAMIuX
463kHtcnX3N1y3t8D/C9e48BAADGNE7jTDN7GWeuVQADAAArGadxprkEWgoCAABQY5oABgAA
gBoCGAAAgBAEMAAAACEIYAAAAEIQwAAAAIQggAEAAAhBAAMAABCCAAYAACAEAQwAAEAIAhgA
AIAQBDAAAAAhCGAAAABCEMAAAACEIIABAAAIQQADAAAQggAGAAAgBAEMAABACAIYAACAEAQw
AAAAIQhgAAAAQhDAAAAAhCCAAQAACEEAAwAAEIIABgAAIAQBDAAAQAgCGAAAgBAEMAAAACEI
YAAAAEIQwAAAAIQggAEAAAhBAAMAABCCAAYAACAEAQwAAEAIAhgAAIAQBDAAAAAhCGAAAABC
+FrjbWzbtm3b8Sf7vu/73nuNqbU8vz0AAADkTR/AqRDNB2qrNZ7X8vz2AAAAUMIl0N84z98e
f36M2GMG228AAAAjW+QS6BIuSwYAAIhs+gBOzcFevSz5vITjT8pTuWR7yol2AABgLiNfIRvo
HuD8MJQEc9vtAQAA4EmBLoGeMT4FMwAAMJfUdOAI2xb6IVipYUhl5/nyZvO6AAAAswhxD3Db
+3JTX4DUY10AAAC0ssgl0CV52TZB80uTuwAAAKPxPcAAAACEIIABAAAIQQADAAAQggAGAAAg
BAEMAABACAIYAACAEAQwAAAAIQhgAAAAQhDAAAAAhCCAAQAACEEAAwAAEIIABgAAIAQBDAAA
QAgCGAAAgBAEMAAAACEIYAAAAEIQwAAAAIQggAEAAAhBAAMAABCCAAYAACAEAQwAAEAIAhgA
AIAQBDAAAAAhCGAAAABCEMAAAACEIIABAAAIQQADAAAQggAGAAAgBAEMAABACAIYAACAEAQw
AAAAIQhgAAAAQhDAAAAAhCCAAQAACEEAAwAAEIIABgAAIISvt1a8bdu2bak/3fd93/cnl3Nv
+1PLP29Vvy0BAACgxGsBXJ6ONUvr4Zi+5wxOhXE+mAEAAOhtoEugx0nEVISft/CYwQ4mAACA
kX2t9GaOIZqagz3+xHwsAABAHEMEcP3cb/5S5JLLks95nM/plNTS7r070Q4AAMxl5Ctkp58B
7vG4rJogdw8wAADAmF4O4CezcMb4FMwAAMBcSm5Hfcs03wOcfzBV22WmsvN8ebN5XQAAgFlM
cAl0PjhL7rlte19u/r7itusCAACglWlmL+PMtd57+BYAAMCYxmmcaS6BloIAAADUmCaAAQAA
oIYABgAAIAQBDAAAQAgCGAAAgBAEMAAAACEIYAAAAEIQwAAAAIQggAEAAAhBAAMAABCCAAYA
ACAEAQwAAEAIAhgAAIAQBDAAAAAhCGAAAABCEMAAAACEIIABAAAIQQADAAAQggAGAAAgBAEM
AABACAIYAACAEAQwAAAAIQhgAAAAQhDAAAAAhCCAAQAACEEAAwAAEIIABgAAIAQBDAAAQAgC
GAAAgBAEMAAAACEIYAAAAEIQwAAAAIQggAEAAAhBAAMAABCCAAYAACAEAQwAAEAIX7O/gW3b
tm1L/em+7/u+91tvavnnreq3JQAAAJSYPoDLE7SVY/qeMzgVxvlgBgAAoLcFL4GuT81UPJ+X
fMxgBxMAAMDIpp8BLueyZAAAgMiWCuCrlx+fL2Y+/+nnf5encmpp92JbtAMAAHMZ+QrZ0DPA
RyX38ZavxT3AAAAAo1kkgEvycsb4FMwAAMBcUtOBI2xb6O8BTg1DKjvPlzeb1wUAAJhFiEug
296Xm/oCpB7rAgAAoJVFArgkL9sm6HqXWwMAAKwt9CXQAAAAxCGAAQAACEEAAwAAEIIABgAA
IAQBDAAAQAgCGAAAgBAEMAAAACEIYAAAAEIQwAAAAIQggAEAAAhBAAMAABCCAAYAACAEAQwA
AEAIAhgAAIAQvuwCAAAAftu2bUv/6b7v+7zvTQADAACEkk/clQlgAACAxfRL3OOS55sNFsAA
AADTeWsW1yXQAAAANBP3EuXeBDAAAMDDxk/cuWd6UwQwAABAcxJ3RAIYAADgBok7HwEMAADw
LYm7GgEMAAAENMuDpiRuSwIYAABYkvlb/iaAAQCASUlcrhHAAADAsCQuLQlgAADgRRKX5whg
AACgq5ETV9zGIoABAIBKEpc5CGAAACDDJcqsQwADAEBwEpcoBDAAACxP4sKvXwIYAACWIHHh
ZwIYAACmIHGhlgAGAIBBeJYy9PVyAG/b3yf5vl87tc5LqFna1fWmll//vgAAWIv5W3jfawGc
Csh8WOZO1qdO1+MWnre27fsCAGAeEhdGN9wl0CMkYnnEpjIYAIAVSVyY21L3AB8vPE7l698f
Dz4gAAD4j8SFlU1/D/BxOalLkUtmdM9bks/plNTSat5X/XIAAJghbj/8vsf8Z9qo59rLAVx/
r2z5K8sfl1VzSbN7gAEA3mP+FsgJ9DVIM8anYAYA+JPEhdGV3I76lmkCuMfMaurvppZ2vqDa
vC4AQGsSF+jl5Xgrucf1yddc3fIe3wN8795jAIB5SFyId86P0TjTzF7GmWsVwADA/EZOXL9f
wdPGaZxpLoGWggAAI5G4wHwCPQQLAIAyLlEG1iSAAQACkrhARAIYAGBJEhfgbwIYAGBSEhfg
GgEMADAsiQvQkgAGAHjF+HH7IXGBdQhgAIBOzN8CjEUAAwDcJnEBZiKAAQAyJC7AOgQwABCc
xAWIQgADAMsbOXHFLcBzBDAAsACJC8DPBDAAMDiXKAPQhgAGAF4ncQF4ggAGAB4gcQF4nwAG
AJqQuACMTgADAIUkLgBzE8AAwK8Z4vZD4gJwnwAGgCDM3wIQnQAGgGVIXADIEcAAMBGJCwD3
CWAAGIrEBYBeBDAAPEbcAsCbBDAANCRxAWBcAhgALpG4ADArAQwAf5G4ALAmAQxAQBIXACIS
wAAsaeTEFbcA8A4BDMCkJC4AcI0ABmBALlEGANoTwAC8QuICAE8TwAB0InEBgLEIYABuk7gA
wEwEMADfErcAwGoEMEBYEhcAiGWRAN62v3+N2/e+vzZ91phay/PbA/AdiQsA8J/pAzgVovlA
bbXG81qe3x4gNokLAFBq2Uuga1KzPGJTGQzQjsQFAGgj0D3ALksGRjVy4vqcBADWEeIe4JIZ
3fMSjj8pT+XU0u7FtmiHVUhcACCKc8WMY5EALrlcOT8MJcFcPtjuAYZ4JC4AwOgCXQI9Y3wK
ZhiDu3ABAEqlpgNH2LbQ3wOcmpVNZef5kVfmdWGlz4Oxt9DnDABArekDuOSe27b35ebTt+26
gHYkLgBAdMveA3zvNa3WKHfhDRIXAICc0JdAA7ORuAAA3CeAgUGIWwAA+hLAwGMkLgAAbxLA
QEMSFwCAcQlg4BKJCwDArAQw8BeJCwDAmgQwBDRy4opbAAB6EcCwGPO3AADwPQEM05G4AABw
hwCGAUlcAABoTwDDKyQuAAA8TQBDJxIXAADGIoDhBnELAADzEcDwLYkLAACrEcCEJXEBACAW
AczCJC4AAPAfAczUJC4AAFBKADOs8eP2Q+ICAMAcBDAvMn8LAAA8RwDTlcQFAABGIYCpJHEB
AIA5CGB+JHEBAIAVCGB+jZ244hYAAGhDAAchcQEAgOgE8DIkLgAAQI4AnoK7cAEAAGoJ4MGN
k74SFwAAmJsA5v8kLgAAsDIBPJTe870SFwAAiEsAD+UTqDUZLHEBAAC+J4CnI3EBAADuEMCD
k7sAAABt/GMXAAAAEIEABgAAIAQBDAAAQAgCGAAAgBBeewjWtuW+7GffSx/+1Go597Y/tfzz
VvXbEgAAAEq8/BToVln4ZF4e0/ecwakwzgczszj+04bRNDoYHeOC0TE6RsfoMBeXQP9w2px/
fjyRjhlsvwEAAIxsiO8BbvXvNPnluCwZAAAgstcuyk3F6tVLhUuWU3JZcsm9xOWXN9fEtvlk
AABgVe9OQ37N/rZ7PC6r5n5d9wADAACMaYhLoJ8xS3yKZAAAgB5eewjW1Qt98w+marsNqQQ9
XyxtXhcAAGAWL8dbyb2yT77m6pb7HmAAAIBZTDN7aa4VAACAGpISAACAEP6xCwAAAIhAAAMA
ABCCAJ5AzZOuqdmro70mzrgcGZ0xxyU/Rkbn3ZFy1jhrjM69MXLuOHeMToSzRgBPcJCdv36J
+r1av+effE20o/3ovE+MzvP2BOfOjOeXcRnt3DE6754R/h9nxrPG6DhrasZFAE9wkB0/Dvwy
0Xav3tvzT74GozPLWBidEUbEWeMzzejU8Jk2y5lidHym1YyLACYQzzw3OtTzpXRGhHtj5Ndl
gBF82QXAmPxaP+aIGB24etbkZ654d3SOPzEu459BvCU1vzrj6AhgYDj+D29M+XsX7R9nCvnz
hfHHyDkFKamzY8azxiXQwED88gH3zprz/Lw9A8zL7wP0I4AHVXKrN2/t+SdfE0fJezc6746O
c2fMz6vzU1LHeQCJs8ZZM/v5ZXSMjtFZb1wM3gScZm33ZP6kvbrnn3yN0TE6o41RyVdTGJ3n
x8i4OGuMjtFZ+9PM6DhrasbFCQYAAEAILoEGAAAgBAEMAABACAIYAACAEAQwAAAAIQhgAAAA
QhDAAAAAhCCAAQAACEEAAwAAEIIABgAAIAQBDAAAQAgCGAAAgBAEMAAAACF81fzlbdu2bdv3
fd/3e68p+dPjT+4tp8f76q38vdcs5/yn51eWvObd8aoZzVb7GQAAGN/XWys+Zsk5UVLRkn/l
COHads+U/Lx+OflllqTj1fGa6xgDAADWcPMS6JKMSb0mFWBX06jVcq6+r9nVp929ROwRlr2P
MQAAYCWXA7j+sucSz8+/mffbDnrspatz1yXbAwAAUO5rlg2NE6ipucoe9wCn9m3+0uXy+dVW
s8Tni5lT77F8jW33MwAAML4LAfzM3O8zy3xy+a2259525pdzNRdTy2m7zVcfu1XzTwPuAQYA
gDguzwCn5t/yDzoa567RmvfFM+xzAACghwv3AO8nx59ffU3+ktqS+CxZzlFqXrFkm8/LGefe
1N4P/RrhnebHrv7YAAAAIqhKgn7fA1x+EWz5WvJLqN/mxgNTfO/uLK/p8X3C9Uepe4ABACCO
QHNi9eE65iyiuU0AAIAS/wPPHFakBdI9dAAAAABJRU5ErkJggg==

--mP3DRpeJDSE+ciuQ--

-- 
VGER BF report: U 0.499855
