From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [1/1] netchannel subsystem.
Date: Tue, 16 May 2006 10:19:09 +0400
Message-ID: <20060516061909.GA28670@2ka.mipt.ru>
References: <200604261147.34221.kelly@au.ibm.com> <20060504.161148.44973535.davem@davemloft.net> <200605051248.42662.kelly@au.ibm.com> <200605161102.29472.kelly@au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Kelly Daly <kelly@au1.ibm.com>, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:39056 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751514AbWEPGUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 May 2006 02:20:25 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <200605161102.29472.kelly@au.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Let me also bring attention to another netchannel implementation.

Some design notes [blog copypasts, sorry if it is out of sync sometimes].

First of all, do not use sockets. Just forget that such interface
exists.
New receiving channel abstraction will be created by special syscall,
which allows to specify in creation time source IP range, or it can be
wildcarded to IPADDR_ANY.
Interrupt handler (or netif_receive_skb()) will check skb and try to get
netchannel, then skb will be linked into netchannel receive queue if
memory limits allow it and that is all. No protocol processing.
If hardware allows to split header from data it will be possible to
create zero-copy technique: when netchannel is selected in
netif_receive_skb() it will have ->alloc_data() callback which would
allow, for example, to allocate data from userspace mapped area.
When receiver is awakened after data has been added to netchannel, it
will call netchannel's ->get_data() callback which would allow to remap
data pages from skb into process' VMA.

Unified network cache will hold information about source and destination
IP addresses, or it's hashes for IPv6, information about ports and
well-defined IP protocols. 
It is built as two dimensional array of default 8 order (i.e. 64k
entries) with XOR hash. Comparison of Jenkins hash with XOR hash used in
TCP socket selection code can be found at [1].

Main problem here is routing cache. Linux is great in routing, it
supports several cache algorithms, which are extremely fast in
appropriate environments, but main question is "do we need routing for
netchannels"?. So it looks like netchannel either must include that
route interface or, if it will be designed as userspace-only
communication channel, implement own trivial pseudo-route algorithm.

Most of the drivers do not set skb->pkt_type, so it stays default
PACKET_HOST, which means that every packet, received by interface must
be checked to be valid for the system, which is a point to use standard
Linux routing, but from the other point of view, it is quite easy to
create own callback for IP address setup, which would update netchannel
routing table.

No one need an excuse to rewrite anything, so I will create own cache
for netchannels, which will be updated when IP addresses are changed.


Ok, basic interfaces have been created:

	* unified cache to store netchannels (IPv4 and stub for IPv6 hashes, 
		TCP and UDP)
	* skb queueing mechanism
	* netchannel creation/removing commands
	* netchannel's callback to allocate/free pages (for 
		example to get data from mapped area) not only from SLAB cache

There are only couple of things left (today maybe):

	* create netchannel's callback to move/copy data to userspace
	* create read data command
	* test new netchannel interface :) (it boots and works ok
		with netchannel interface turned on for usual sockets)


If you have read all above, here is link to hash comparison [1].

[1]. Compared Jenkins hash with XOR hash used in TCP socket selection code.
http://tservice.net.ru/~s0mbre/blog/2006/05/14#2006_05_14

And proof-of-concept patch itself.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/arch/i386/kernel/syscall_table.S b/arch/i386/kernel/syscall_table.S
index f48bef1..b69d7d3 100644
--- a/arch/i386/kernel/syscall_table.S
+++ b/arch/i386/kernel/syscall_table.S
@@ -315,3 +315,4 @@ ENTRY(sys_call_table)
 	.long sys_splice
 	.long sys_sync_file_range
 	.long sys_tee			/* 315 */
+	.long sys_netchannel_control
diff --git a/arch/x86_64/ia32/ia32entry.S b/arch/x86_64/ia32/ia32entry.S
index 5a92fed..fdfb997 100644
--- a/arch/x86_64/ia32/ia32entry.S
+++ b/arch/x86_64/ia32/ia32entry.S
@@ -696,4 +696,5 @@ ia32_sys_call_table:
 	.quad sys_sync_file_range
 	.quad sys_tee
 	.quad compat_sys_vmsplice
+	.quad sys_netchannel_control
 ia32_syscall_end:		
diff --git a/include/asm-x86_64/unistd.h b/include/asm-x86_64/unistd.h
index feb77cb..08c230e 100644
--- a/include/asm-x86_64/unistd.h
+++ b/include/asm-x86_64/unistd.h
@@ -617,8 +617,10 @@ __SYSCALL(__NR_tee, sys_tee)
 __SYSCALL(__NR_sync_file_range, sys_sync_file_range)
 #define __NR_vmsplice		278
 __SYSCALL(__NR_vmsplice, sys_vmsplice)
+#define __NR_netchannel_control	279
+__SYSCALL(__NR_vmsplice, sys_netchannel_control)
 
-#define __NR_syscall_max __NR_vmsplice
+#define __NR_syscall_max __NR_netchannel_control
 
 #ifndef __NO_STUBS
 
diff --git a/include/linux/netchannel.h b/include/linux/netchannel.h
new file mode 100644
index 0000000..4e65c9b
--- /dev/null
+++ b/include/linux/netchannel.h
@@ -0,0 +1,73 @@
+/*
+ * 	netchannel.h
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
+#ifndef __NETCHANNEL_H
+#define __NETCHANNEL_H
+
+#include <linux/types.h>
+
+enum netchannel_commands {
+	NETCHANNEL_CREATE = 0,
+	NETCHANNEL_REMOVE,
+	NETCHANNEL_BIND,
+	NETCHANNEL_READ,
+};
+
+struct unetchannel
+{
+	__u32			src, dst;		/* source/destination hashes */
+	__u16			sport, dport;		/* source/destination ports */
+	__u8			proto;			/* IP protocol number */
+	__u8			listen;
+	__u8			reserved[2];
+};
+
+struct unetchannel_control
+{
+	struct unetchannel	unc;
+	__u32			cmd;
+	__u32			len;
+};
+
+#ifdef __KERNEL__
+
+struct netchannel
+{
+	struct hlist_node	node;
+	atomic_t		refcnt;
+	struct rcu_head		rcu_head;
+	struct unetchannel	unc;
+	unsigned long		hit;
+
+	struct page *		(*nc_alloc_page)(unsigned int size);
+	void			(*nc_free_page)(struct page *page);
+
+	struct sk_buff_head 	list;
+};
+
+struct netchannel_cache_head
+{
+	struct hlist_head	head;
+	struct mutex		mutex;
+};
+
+#endif /* __KERNEL__ */
+#endif /* __NETCHANNEL_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a461b51..9924911 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -684,6 +684,15 @@ extern void		dev_queue_xmit_nit(struct s
 
 extern void		dev_init(void);
 
+#ifdef CONFIG_NETCHANNEL
+extern int netchannel_recv(struct sk_buff *skb);
+#else
+static int netchannel_recv(struct sk_buff *skb) 
+{ 
+	return -1;
+}
+#endif
+
 extern int		netdev_nit;
 extern int		netdev_budget;
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f8f2347..accd00b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -301,6 +301,7 @@ struct sk_buff {
  *	Handling routines are only of interest to the kernel
  */
 #include <linux/slab.h>
+#include <linux/netchannel.h>
 
 #include <asm/system.h>
 
@@ -314,6 +315,17 @@ static inline struct sk_buff *alloc_skb(
 	return __alloc_skb(size, priority, 0);
 }
 
+#ifdef CONFIG_NETCHANNEL
+extern struct sk_buff *netchannel_alloc(struct unetchannel *unc, unsigned int header_size, 
+		unsigned int total_size, gfp_t gfp_mask);
+#else
+static struct sk_buff *netchannel_alloc(struct unetchannel *unc, unsigned int header_size, 
+		unsigned int total_size, gfp_t gfp_mask)
+{
+	return NULL;
+}
+#endif
+
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 3996960..296929d 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -582,4 +582,6 @@ asmlinkage long sys_tee(int fdin, int fd
 asmlinkage long sys_sync_file_range(int fd, loff_t offset, loff_t nbytes,
 					unsigned int flags);
 
+asmlinkage int sys_netchannel_control(void __user *arg);
+
 #endif
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 5433195..1747fc3 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -132,3 +132,5 @@ cond_syscall(sys_mincore);
 cond_syscall(sys_madvise);
 cond_syscall(sys_mremap);
 cond_syscall(sys_remap_file_pages);
+
+cond_syscall(sys_netchannel_control);
diff --git a/net/Kconfig b/net/Kconfig
index 4193cdc..465e37b 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -66,6 +66,14 @@ source "net/ipv6/Kconfig"
 
 endif # if INET
 
+config NETCHANNEL
+	bool "Network channels"
+	---help---
+	  Network channels are peer-to-peer abstraction, which allows to create
+	  high performance communications. 
+	  Main advantages are unified address cache, protocol processing moved
+	  to userspace, receiving zero-copy support and other interesting features.
+
 menuconfig NETFILTER
 	bool "Network packet filtering (replaces ipchains)"
 	---help---
diff --git a/net/core/Makefile b/net/core/Makefile
index 79fe12c..7119812 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -16,3 +16,4 @@ obj-$(CONFIG_NET_DIVERT) += dv.o
 obj-$(CONFIG_NET_PKTGEN) += pktgen.o
 obj-$(CONFIG_WIRELESS_EXT) += wireless.o
 obj-$(CONFIG_NETPOLL) += netpoll.o
+obj-$(CONFIG_NETCHANNEL) += netchannel.o
diff --git a/net/core/dev.c b/net/core/dev.c
index 9ab3cfa..2721111 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1712,6 +1712,10 @@ int netif_receive_skb(struct sk_buff *sk
 		}
 	}
 
+	ret = netchannel_recv(skb);
+	if (!ret)
+		goto out;
+
 #ifdef CONFIG_NET_CLS_ACT
 	if (pt_prev) {
 		ret = deliver_skb(skb, pt_prev, orig_dev);
diff --git a/net/core/netchannel.c b/net/core/netchannel.c
new file mode 100644
index 0000000..5b3b2bb
--- /dev/null
+++ b/net/core/netchannel.c
@@ -0,0 +1,583 @@
+/*
+ * 	netchannel.c
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
+#include <linux/types.h>
+#include <linux/unistd.h>
+#include <linux/linkage.h>
+#include <linux/notifier.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/skbuff.h>
+#include <linux/errno.h>
+
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+
+#include <linux/netdevice.h>
+#include <linux/inetdevice.h>
+#include <net/addrconf.h>
+
+#include <asm/uaccess.h>
+
+static unsigned int netchannel_hash_order = 8;
+static struct netchannel_cache_head ***netchannel_hash_table;
+static kmem_cache_t *netchannel_cache;
+
+static int netchannel_inetaddr_notifier_call(struct notifier_block *, unsigned long, void *);
+static struct notifier_block netchannel_inetaddr_notifier = {
+	.notifier_call = &netchannel_inetaddr_notifier_call
+};
+
+#ifdef CONFIG_IPV6
+static int netchannel_inet6addr_notifier_call(struct notifier_block *, unsigned long, void *);
+static struct notifier_block netchannel_inet6addr_notifier = {
+	.notifier_call = &netchannel_inet6addr_notifier_call
+};
+#endif
+
+static inline unsigned int netchannel_hash(struct unetchannel *unc)
+{
+	unsigned int h = (unc->dst ^ unc->dport) ^ (unc->src ^ unc->sport);
+	h ^= h >> 16;
+	h ^= h >> 8;
+	h ^= unc->proto;
+	return h & ((1 << 2*netchannel_hash_order) - 1);
+}
+
+static inline void netchannel_convert_hash(unsigned int hash, unsigned int *col, unsigned int *row)
+{
+	*row = hash & ((1 << netchannel_hash_order) - 1);
+	*col = (hash >> netchannel_hash_order) & ((1 << netchannel_hash_order) - 1);
+}
+
+static struct netchannel_cache_head *netchannel_bucket(struct unetchannel *unc)
+{
+	unsigned int hash = netchannel_hash(unc);
+	unsigned int col, row;
+
+	netchannel_convert_hash(hash, &col, &row);
+	return netchannel_hash_table[col][row];
+}
+
+static inline int netchannel_hash_equal_full(struct unetchannel *unc1, struct unetchannel *unc2)
+{
+	return (unc1->dport == unc2->dport) && (unc1->dst == unc2->dst) &&
+				(unc1->sport == unc2->sport) && (unc1->src == unc2->src) && 
+				(unc1->proto == unc2->proto);
+}
+
+static inline int netchannel_hash_equal_dest(struct unetchannel *unc1, struct unetchannel *unc2)
+{
+	return ((unc1->dport == unc2->dport) && (unc1->dst == unc2->dst) && (unc1->proto == unc2->proto));
+}
+
+static struct netchannel *netchannel_check_dest(struct unetchannel *unc, struct netchannel_cache_head *bucket)
+{
+	struct netchannel *nc;
+	struct hlist_node *node;
+	int found = 0;
+	
+	hlist_for_each_entry_rcu(nc, node, &bucket->head, node) {
+		if (netchannel_hash_equal_dest(&nc->unc, unc)) {
+			found = 1;
+			break;
+		}
+	}
+
+	return (found)?nc:NULL;
+}
+
+static struct netchannel *netchannel_check_full(struct unetchannel *unc, struct netchannel_cache_head *bucket)
+{
+	struct netchannel *nc;
+	struct hlist_node *node;
+	int found = 0;
+	
+	hlist_for_each_entry_rcu(nc, node, &bucket->head, node) {
+		if (netchannel_hash_equal_full(&nc->unc, unc)) {
+			found = 1;
+			break;
+		}
+	}
+
+	return (found)?nc:NULL;
+}
+
+static void netchannel_free_rcu(struct rcu_head *rcu)
+{
+	struct netchannel *nc = container_of(rcu, struct netchannel, rcu_head);
+
+	kmem_cache_free(netchannel_cache, nc);
+}
+
+static inline void netchannel_get(struct netchannel *nc)
+{
+	atomic_inc(&nc->refcnt);
+}
+
+static inline void netchannel_put(struct netchannel *nc)
+{
+	if (atomic_dec_and_test(&nc->refcnt))
+		call_rcu(&nc->rcu_head, &netchannel_free_rcu);
+}
+
+
+static int netchannel_convert_skb_ipv6(struct sk_buff *skb, struct unetchannel *unc)
+{
+	/*
+	 * Hash IP addresses into src/dst. Setup TCP/UDP ports.
+	 * Not supported yet.
+	 */
+	return -1;
+}
+
+static int netchannel_convert_skb_ipv4(struct sk_buff *skb, struct unetchannel *unc)
+{
+	struct iphdr *iph;
+	u32 len;
+	struct tcphdr *th;
+	struct udphdr *uh;
+
+	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+		goto inhdr_error;
+
+	iph = skb->nh.iph;
+
+	if (iph->ihl < 5 || iph->version != 4)
+		goto inhdr_error;
+
+	if (!pskb_may_pull(skb, iph->ihl*4))
+		goto inhdr_error;
+
+	iph = skb->nh.iph;
+
+	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
+		goto inhdr_error;
+
+	len = ntohs(iph->tot_len);
+	if (skb->len < len || len < (iph->ihl*4))
+		goto inhdr_error;
+
+	unc->dst = iph->daddr;
+	unc->src = iph->saddr;
+	unc->proto = iph->protocol;
+
+	len = skb->len;
+
+	switch (unc->proto) {
+		case IPPROTO_TCP:
+			if (!pskb_may_pull(skb, sizeof(struct tcphdr)))
+				goto inhdr_error;
+			th = skb->h.th;
+
+			if (th->doff < sizeof(struct tcphdr) / 4)
+				goto inhdr_error;
+
+			unc->dport = th->dest;
+			unc->sport = th->source;
+			break;
+		case IPPROTO_UDP:
+			if (!pskb_may_pull(skb, sizeof(struct udphdr)))
+				goto inhdr_error;
+			uh = skb->h.uh;
+
+			if (ntohs(uh->len) > len || ntohs(uh->len) < sizeof(*uh))
+				goto inhdr_error;
+
+			unc->dport = uh->dest;
+			unc->sport = uh->source;
+			break;
+		default:
+			goto inhdr_error;
+	}
+
+	return 0;
+
+inhdr_error:
+	return -1;
+}
+
+static int netchannel_convert_skb(struct sk_buff *skb, struct unetchannel *unc)
+{
+	if (skb->pkt_type == PACKET_OTHERHOST)
+		return -1;
+
+	switch (skb->protocol) {
+		case ETH_P_IP:
+			return netchannel_convert_skb_ipv4(skb, unc);
+		case ETH_P_IPV6:
+			return netchannel_convert_skb_ipv6(skb, unc);
+		default:
+			return -1;
+	}
+}
+
+/*
+ * By design netchannels allow to "allocate" data
+ * not only from SLAB cache, but get it from mapped area
+ * or from VFS cache (requires process' context or preallocation).
+ */
+struct sk_buff *netchannel_alloc(struct unetchannel *unc, unsigned int header_size, 
+		unsigned int total_size, gfp_t gfp_mask)
+{
+	struct netchannel *nc;
+	struct netchannel_cache_head *bucket;
+	int err;
+	struct sk_buff *skb = NULL;
+	unsigned int size, pnum, i;
+
+	skb = alloc_skb(header_size, gfp_mask);
+	if (!skb)
+		return NULL;
+
+	rcu_read_lock();
+	bucket = netchannel_bucket(unc);
+	nc = netchannel_check_full(unc, bucket);
+	if (!nc) {
+		err = -ENODEV;
+		goto err_out_free_skb;
+	}
+
+	if (!nc->nc_alloc_page || !nc->nc_free_page) {
+		err = -EINVAL;
+		goto err_out_free_skb;
+	}
+
+	netchannel_get(nc);
+
+	size = total_size - header_size;
+	pnum = PAGE_ALIGN(size) >> PAGE_SHIFT;
+
+	for (i=0; i<pnum; ++i) {
+		unsigned int cs = min_t(unsigned int, PAGE_SIZE, size);
+		struct page *page;
+
+		page = nc->nc_alloc_page(cs);
+		if (!page)
+			break;
+		
+		skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags, page, 0, cs);
+		
+		skb->len	+= cs;
+		skb->data_len	+= cs;
+		skb->truesize	+= cs;
+
+		size -= cs;
+	}
+
+	if (i < pnum) {
+		pnum = i;
+		err = -ENOMEM;
+		goto err_out_free_frags;
+	}
+
+	rcu_read_unlock();
+
+	return skb;
+
+err_out_free_frags:
+	for (i=0; i<pnum; ++i) {
+		unsigned int cs = skb_shinfo(skb)->frags[i].size;
+		struct page *page = skb_shinfo(skb)->frags[i].page;
+		
+		nc->nc_free_page(page);
+
+		skb->len	-= cs;
+		skb->data_len	-= cs;
+		skb->truesize	-= cs;
+	}
+
+err_out_free_skb:
+	kfree_skb(skb);
+	return NULL;
+}
+
+int netchannel_recv(struct sk_buff *skb)
+{
+	struct netchannel *nc;
+	struct unetchannel unc;
+	struct netchannel_cache_head *bucket;
+	int err;
+
+	if (!netchannel_hash_table)
+		return -ENODEV;
+
+	rcu_read_lock();
+
+	err = netchannel_convert_skb(skb, &unc);
+	if (err)
+		goto unlock;
+
+	bucket = netchannel_bucket(&unc);
+	nc = netchannel_check_full(&unc, bucket);
+	if (!nc) {
+		err = -ENODEV;
+		goto unlock;
+	}
+
+	nc->hit++;
+
+	skb_queue_tail(&nc->list, skb);
+
+unlock:
+	rcu_read_unlock();
+	return err;
+}
+
+static int netchannel_create(struct unetchannel *unc)
+{
+	struct netchannel *nc;
+	int err = -ENOMEM;
+	struct netchannel_cache_head *bucket;
+	
+	if (!netchannel_hash_table)
+		return -ENODEV;
+
+	bucket = netchannel_bucket(unc);
+
+	mutex_lock(&bucket->mutex);
+
+	if (netchannel_check_full(unc, bucket)) {
+		err = -EEXIST;
+		goto out_unlock;
+	}
+
+	if (unc->listen && netchannel_check_dest(unc, bucket)) {
+		err = -EEXIST;
+		goto out_unlock;
+	}
+
+	nc = kmem_cache_alloc(netchannel_cache, GFP_KERNEL);
+	if (!nc)
+		goto out_exit;
+
+	memset(nc, 0, sizeof(struct netchannel));
+	
+	nc->hit = 0;
+	skb_queue_head_init(&nc->list);
+	atomic_set(&nc->refcnt, 1);
+	memcpy(&nc->unc, unc, sizeof(struct unetchannel));
+
+	hlist_add_head_rcu(&nc->node, &bucket->head);
+
+out_unlock:
+	mutex_unlock(&bucket->mutex);
+out_exit:
+	printk("netchannel: create %u.%u.%u.%u:%d -> %u.%u.%u.%u:%d, proto: %d, err: %d.\n",
+			NIPQUAD(unc->src), unc->sport, NIPQUAD(unc->dst), unc->dport, unc->proto, err);
+
+	return err;
+}
+
+static int netchannel_remove(struct unetchannel *unc)
+{
+	struct netchannel *nc;
+	int err = -ENODEV;
+	struct netchannel_cache_head *bucket;
+	unsigned long hit = 0;
+	
+	if (!netchannel_hash_table)
+		return -ENODEV;
+	
+	bucket = netchannel_bucket(unc);
+
+	mutex_lock(&bucket->mutex);
+
+	nc = netchannel_check_full(unc, bucket);
+	if (!nc)
+		nc = netchannel_check_dest(unc, bucket);
+
+	if (!nc)
+		goto out_unlock;
+	
+	hlist_del_rcu(&nc->node);
+	hit = nc->hit;
+	
+	netchannel_put(nc);
+	err = 0;
+
+out_unlock:
+	mutex_unlock(&bucket->mutex);
+	printk("netchannel: remove %u.%u.%u.%u:%d -> %u.%u.%u.%u:%d, proto: %d, err: %d, hit: %lu.\n",
+			NIPQUAD(unc->src), unc->sport, NIPQUAD(unc->dst), unc->dport, unc->proto, err, 
+			hit);
+	return 0;
+}
+
+asmlinkage int sys_netchannel_control(void __user *arg)
+{
+	struct unetchannel_control ctl;
+	int ret;
+	
+	if (!netchannel_hash_table)
+		return -ENODEV;
+
+	if (copy_from_user(&ctl, arg, sizeof(struct unetchannel_control)))
+		return -ERESTARTSYS;
+
+	switch (ctl.cmd) {
+		case NETCHANNEL_CREATE:
+		case NETCHANNEL_BIND:
+			ret = netchannel_create(&ctl.unc);
+			break;
+		case NETCHANNEL_REMOVE:
+			ret = netchannel_remove(&ctl.unc);
+			break;
+		default:
+			ret = -EINVAL;
+			break;
+	}
+
+	return ret;
+}
+
+static inline void netchannel_dump_addr(struct in_ifaddr *ifa, char *str)
+{
+	printk("netchannel: %s %u.%u.%u.%u/%u.%u.%u.%u\n", str, NIPQUAD(ifa->ifa_local), NIPQUAD(ifa->ifa_mask));
+}
+
+static int netchannel_inetaddr_notifier_call(struct notifier_block *this, unsigned long event, void *ptr)
+{
+	struct in_ifaddr *ifa = ptr;
+	
+	printk("netchannel: inet event=%lx, ifa=%p.\n", event, ifa);
+	
+	switch (event) {
+		case NETDEV_UP:
+			netchannel_dump_addr(ifa, "add");
+			break;
+		case NETDEV_DOWN:
+			netchannel_dump_addr(ifa, "del");
+			break;
+		default:
+			netchannel_dump_addr(ifa, "unk");
+			break;
+	}
+	
+	return NOTIFY_DONE;
+}
+
+#ifdef CONFIG_IPV6
+static int netchannel_inet6addr_notifier_call(struct notifier_block *this, unsigned long event, void *ptr)
+{
+	struct inet6_ifaddr *ifa = ptr;
+	
+	printk("netchannel: inet6 event=%lx, ifa=%p.\n", event, ifa);
+	return NOTIFY_DONE;
+}
+#endif
+
+static int __init netchannel_init(void)
+{
+	unsigned int i, j, size;
+	int err = -ENOMEM;
+
+	size = (1 << netchannel_hash_order);
+
+	netchannel_hash_table = kzalloc(size * sizeof(void *), GFP_KERNEL);
+	if (!netchannel_hash_table)
+		goto err_out_exit;
+
+	for (i=0; i<size; ++i) {
+		struct netchannel_cache_head **col;
+
+		col = kzalloc(size * sizeof(void *), GFP_KERNEL);
+		if (!col)
+			break;
+		
+		for (j=0; j<size; ++j) {
+			struct netchannel_cache_head *head;
+
+			head = kzalloc(sizeof(struct netchannel_cache_head), GFP_KERNEL);
+			if (!head)
+				break;
+
+			INIT_HLIST_HEAD(&head->head);
+			mutex_init(&head->mutex);
+
+			col[j] = head;
+		}
+		
+		if (j<size && j>0) {
+			while (j >= 0)
+				kfree(col[j--]);
+			kfree(col);
+			break;
+		}
+
+		netchannel_hash_table[i] = col;
+	}
+
+	if (i<size) {
+		size = i;
+		goto err_out_free;
+	}
+
+	netchannel_cache = kmem_cache_create("netchannel", sizeof(struct netchannel), 0, 0,
+			NULL, NULL);
+	if (!netchannel_cache)
+		goto err_out_free;
+
+	register_inetaddr_notifier(&netchannel_inetaddr_notifier);
+#ifdef CONFIG_IPV6
+	register_inet6addr_notifier(&netchannel_inet6addr_notifier);
+#endif
+
+	printk("netchannel: Created %u order two-dimensional hash table.\n", 
+			netchannel_hash_order);
+
+	return 0;
+
+err_out_free:
+	for (i=0; i<size; ++i) {
+		for (j=0; j<(1 << netchannel_hash_order); ++j)
+			kfree(netchannel_hash_table[i][j]);
+		kfree(netchannel_hash_table[i]);
+	}
+	kfree(netchannel_hash_table);
+err_out_exit:
+	
+	printk("netchannel: Failed to create %u order two-dimensional hash table.\n", 
+			netchannel_hash_order);
+	return err;
+}
+
+static void __exit netchannel_exit(void)
+{
+	unsigned int i, j;
+
+	unregister_inetaddr_notifier(&netchannel_inetaddr_notifier);
+#ifdef CONFIG_IPV6
+	unregister_inet6addr_notifier(&netchannel_inet6addr_notifier);
+#endif
+	kmem_cache_destroy(netchannel_cache);
+
+	for (i=0; i<(1 << netchannel_hash_order); ++i) {
+		for (j=0; j<(1 << netchannel_hash_order); ++j)
+			kfree(netchannel_hash_table[i][j]);
+		kfree(netchannel_hash_table[i]);
+	}
+	kfree(netchannel_hash_table);
+}
+
+late_initcall(netchannel_init);

-- 
	Evgeniy Polyakov
