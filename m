From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Netchannels: netchannel vs. socket. 2:0.
Date: Thu, 8 Jun 2006 21:15:55 +0400
Message-ID: <20060608171555.GA10273@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:36802 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S964838AbWFHRQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 13:16:11 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After some enhancements made for netchannel subsystem I'm pleased to
announce, that netchannel subsystem outperforms existing layered design
both in CPU usage and network speed.

Well, after such pretentious introduction I want to cool things down.
CPU usage is about 1-2% less for netchannels and network performance is
about 1-2 MB higher and sometimes exceeds 84 MB/sec which, I think, 
is maximum for given network setup (e1000 receive, r8169 send, 1500 MTU).

It is stable and 100% reproductible result.

Performance graph and patch are attached.

Interesting note, that netchannel copy_to_user() setup slightly 
outperforms memcpy() setup.

I have some doubts that stock socket TCP code was used in Van Jacobson 
netchannel implementation, especially in the final benchmarks, because
of his words about userspace TCP processing, which sometimes pushes to read 
RFC 793 and do some coding...


Previous patches, userspace utility, design and implementatin details
can be found at project's homepage [1].

1. Netchannel homepage.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=netchannel

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/arch/i386/kernel/syscall_table.S b/arch/i386/kernel/syscall_table.S
index f48bef1..7a4a758 100644
--- a/arch/i386/kernel/syscall_table.S
+++ b/arch/i386/kernel/syscall_table.S
@@ -315,3 +315,5 @@ ENTRY(sys_call_table)
 	.long sys_splice
 	.long sys_sync_file_range
 	.long sys_tee			/* 315 */
+	.long sys_vmsplice
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
diff --git a/include/asm-i386/unistd.h b/include/asm-i386/unistd.h
index eb4b152..777cd85 100644
--- a/include/asm-i386/unistd.h
+++ b/include/asm-i386/unistd.h
@@ -322,8 +322,9 @@
 #define __NR_sync_file_range	314
 #define __NR_tee		315
 #define __NR_vmsplice		316
+#define __NR_netchannel_control	317
 
-#define NR_syscalls 317
+#define NR_syscalls 318
 
 /*
  * user-visible error numbers are in the range -1 - -128: see
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
index 0000000..ed426e6
--- /dev/null
+++ b/include/linux/netchannel.h
@@ -0,0 +1,118 @@
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
+	NETCHANNEL_DUMP,
+};
+
+enum netchannel_type {
+	NETCHANNEL_COPY_USER = 0,
+	NETCHANNEL_MMAP,
+	NETCHANEL_VM_HACK,
+};
+
+struct unetchannel
+{
+	__u32			src, dst;		/* source/destination hashes */
+	__u16			sport, dport;		/* source/destination ports */
+	__u8			proto;			/* IP protocol number */
+	__u8			type;			/* Netchannel type */
+	__u8			memory_limit_order;	/* Memor limit order */
+	__u8			init_stat_work;		/* Start statistic dumping */
+};
+
+struct unetchannel_control
+{
+	struct unetchannel	unc;
+	__u32			cmd;
+	__u32			len;
+	__u32			flags;
+	__u32			timeout;
+	unsigned int		fd;
+};
+
+#ifdef __KERNEL__
+
+struct netchannel_stat
+{
+	u64			enter;
+	u64			ready;
+	u64			recv;
+	u64			empty;
+	u64			null;
+	u64			backlog;
+	u64			backlog_err;
+	u64			eat;
+};
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
+	int			(*nc_read_data)(struct netchannel *, unsigned int *timeout, unsigned int *len, void *arg);
+
+	struct sk_buff_head 	recv_queue;
+	wait_queue_head_t	wait;
+
+	unsigned int		qlen;
+
+	void			*priv;
+
+	struct inode 		*inode;
+
+	struct work_struct	work;
+
+	struct netchannel_stat	stat;
+};
+
+struct netchannel_cache_head
+{
+	struct hlist_head	head;
+	struct mutex		mutex;
+};
+
+#define NETCHANNEL_MAX_ORDER	31
+#define NETCHANNEL_MIN_ORDER	PAGE_SHIFT
+
+struct netchannel_mmap
+{
+	struct page		**page;
+	unsigned int		pnum;
+	unsigned int		poff;
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
index f8f2347..69f0c32 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -265,7 +265,8 @@ struct sk_buff {
 				nfctinfo:3;
 	__u8			pkt_type:3,
 				fclone:2,
-				ipvs_property:1;
+				ipvs_property:1,
+				netchannel:1;
 	__be16			protocol;
 
 	void			(*destructor)(struct sk_buff *skb);
@@ -314,6 +315,18 @@ static inline struct sk_buff *alloc_skb(
 	return __alloc_skb(size, priority, 0);
 }
 
+#ifdef CONFIG_NETCHANNEL
+struct unetchannel;
+extern struct sk_buff *netchannel_alloc(struct unetchannel *unc, unsigned int header_size, 
+		unsigned int total_size, gfp_t gfp_mask);
+#else
+static struct sk_buff *netchannel_alloc(void *unc, unsigned int header_size, 
+		unsigned int total_size, gfp_t gfp_mask)
+{
+	return NULL;
+}
+#endif
+
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 9ab2ddd..036a221 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -298,6 +298,7 @@ extern int csum_partial_copy_fromiovecen
 
 extern int verify_iovec(struct msghdr *m, struct iovec *iov, char *address, int mode);
 extern int memcpy_toiovec(struct iovec *v, unsigned char *kdata, int len);
+extern int memcpy_toiovec_copy(struct iovec *v, unsigned char *kdata, int len);
 extern int move_addr_to_user(void *kaddr, int klen, void __user *uaddr, int __user *ulen);
 extern int move_addr_to_kernel(void __user *uaddr, int ulen, void *kaddr);
 extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 3996960..8c22875 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -582,4 +582,6 @@ asmlinkage long sys_tee(int fdin, int fd
 asmlinkage long sys_sync_file_range(int fd, loff_t offset, loff_t nbytes,
 					unsigned int flags);
 
+asmlinkage long sys_netchannel_control(void __user *arg);
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
diff --git a/net/core/datagram.c b/net/core/datagram.c
index aecddcc..3db8873 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -235,6 +235,8 @@ void skb_kill_datagram(struct sock *sk, 
 
 EXPORT_SYMBOL(skb_kill_datagram);
 
+typedef int (* copy_iovec_t)(struct iovec *iov, unsigned char *kdata, int len);
+
 /**
  *	skb_copy_datagram_iovec - Copy a datagram to an iovec.
  *	@skb: buffer to copy
@@ -249,12 +251,13 @@ int skb_copy_datagram_iovec(const struct
 {
 	int start = skb_headlen(skb);
 	int i, copy = start - offset;
+	copy_iovec_t func = (skb->netchannel)?&memcpy_toiovec_copy:&memcpy_toiovec;
 
 	/* Copy header. */
 	if (copy > 0) {
 		if (copy > len)
 			copy = len;
-		if (memcpy_toiovec(to, skb->data + offset, copy))
+		if (func(to, skb->data + offset, copy))
 			goto fault;
 		if ((len -= copy) == 0)
 			return 0;
@@ -277,7 +280,7 @@ int skb_copy_datagram_iovec(const struct
 			if (copy > len)
 				copy = len;
 			vaddr = kmap(page);
-			err = memcpy_toiovec(to, vaddr + frag->page_offset +
+			err = func(to, vaddr + frag->page_offset +
 					     offset - start, copy);
 			kunmap(page);
 			if (err)
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
diff --git a/net/core/iovec.c b/net/core/iovec.c
index 65e4b56..8d19ed7 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -98,6 +98,23 @@ int memcpy_toiovec(struct iovec *iov, un
 	return 0;
 }
 
+int memcpy_toiovec_copy(struct iovec *iov, unsigned char *kdata, int len)
+{
+	while (len > 0) {
+		if (iov->iov_len) {
+			int copy = min_t(unsigned int, iov->iov_len, len);
+			memcpy(iov->iov_base, kdata, copy);
+			kdata += copy;
+			len -= copy;
+			iov->iov_len -= copy;
+			iov->iov_base += copy;
+		}
+		iov++;
+	}
+
+	return 0;
+}
+
 /*
  *	Copy iovec to kernel. Returns -EFAULT on error.
  *
@@ -237,3 +254,4 @@ EXPORT_SYMBOL(csum_partial_copy_fromiove
 EXPORT_SYMBOL(memcpy_fromiovec);
 EXPORT_SYMBOL(memcpy_fromiovecend);
 EXPORT_SYMBOL(memcpy_toiovec);
+EXPORT_SYMBOL(memcpy_toiovec_copy);
diff --git a/net/core/netchannel.c b/net/core/netchannel.c
new file mode 100644
index 0000000..d053d3d
--- /dev/null
+++ b/net/core/netchannel.c
@@ -0,0 +1,1201 @@
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
+#include <linux/file.h>
+#include <linux/skbuff.h>
+#include <linux/errno.h>
+#include <linux/highmem.h>
+#include <linux/workqueue.h>
+#include <linux/netchannel.h>
+
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <net/tcp.h>
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
+static void netchannel_mmap_cleanup(struct netchannel *nc)
+{
+	unsigned int i;
+	struct netchannel_mmap *m = nc->priv;
+
+	for (i=0; i<m->pnum; ++i)
+		__free_page(m->page[i]);
+
+	kfree(m);
+}
+
+static void netchannel_cleanup(struct netchannel *nc)
+{
+	switch (nc->unc.type) {
+		case NETCHANNEL_COPY_USER:
+			break;
+		case NETCHANNEL_MMAP:
+			netchannel_mmap_cleanup(nc);
+			break;
+		default:
+			break;
+	}
+}
+
+static void netchannel_free_rcu(struct rcu_head *rcu)
+{
+	struct netchannel *nc = container_of(rcu, struct netchannel, rcu_head);
+
+	netchannel_cleanup(nc);
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
+static inline void netchannel_dump_info_unc(struct unetchannel *unc, char *prefix, unsigned long hit, int err)
+{
+	u32 src, dst;
+	u16 sport, dport;
+	
+	dst = unc->dst;
+	src = unc->src;
+	dport = ntohs(unc->dport);
+	sport = ntohs(unc->sport);
+
+	printk(KERN_NOTICE "netchannel: %s %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, "
+			"proto: %u, type: %u, order: %u, hit: %lu, err: %d.\n",
+			prefix, NIPQUAD(src), sport, NIPQUAD(dst), dport, 
+			unc->proto, unc->type, unc->memory_limit_order, hit, err);
+}
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
+	if (pskb_trim_rcsum(skb, len))
+		goto inhdr_error;
+
+	unc->dst = iph->daddr;
+	unc->src = iph->saddr;
+	unc->proto = iph->protocol;
+
+	len = skb->len;
+
+	skb->h.raw = skb->nh.raw + iph->ihl*4;
+
+	switch (unc->proto) {
+		case IPPROTO_TCP:
+		case IPPROTO_UDP:
+			unc->sport = ((u16 *)skb->h.raw)[0];
+			unc->dport = ((u16 *)skb->h.raw)[1];
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
+	switch (ntohs(skb->protocol)) {
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
+#if 0
+	if (nc->qlen + skb->len > (1 << nc->unc.memory_limit_order)) {
+		kfree_skb(skb);
+		err = 0;
+		goto unlock;
+	}
+#endif
+	nc->qlen += skb->len;
+	skb_queue_tail(&nc->recv_queue, skb);
+	wake_up(&nc->wait);
+
+unlock:
+	rcu_read_unlock();
+	
+	return err;
+}
+
+static int netchannel_wait_for_packet(struct netchannel *nc, long *timeo_p)
+{
+	int error = 0;
+	DEFINE_WAIT(wait);
+
+	prepare_to_wait_exclusive(&nc->wait, &wait, TASK_INTERRUPTIBLE);
+
+	if (skb_queue_empty(&nc->recv_queue)) {
+		if (signal_pending(current))
+			goto interrupted;
+
+		*timeo_p = schedule_timeout(*timeo_p);
+	}
+out:
+	finish_wait(&nc->wait, &wait);
+	return error;
+interrupted:
+	error = (*timeo_p == MAX_SCHEDULE_TIMEOUT) ? -ERESTARTSYS : -EINTR;
+	goto out;
+}
+
+static struct sk_buff *netchannel_get_skb(struct netchannel *nc, unsigned int *timeout, int *error)
+{
+	struct sk_buff *skb = NULL;
+	long tm = *timeout;
+
+	*error = 0;
+
+	while (1) {
+		skb = skb_dequeue(&nc->recv_queue);
+		if (skb) {
+			nc->qlen -= skb->len;
+			break;
+		}
+
+		if (*timeout) {
+			*error = netchannel_wait_for_packet(nc, &tm);
+			if (*error) {
+				*timeout = tm;
+				skb = skb_dequeue(&nc->recv_queue);
+				break;
+			}
+			tm = *timeout;
+		} else {
+			*error = -EAGAIN;
+			break;
+		}
+	}
+
+	return skb;
+}
+
+static int netchannel_copy_to_user_tcp(struct netchannel *nc, unsigned int *timeout, unsigned int *len, void *arg)
+{
+	struct tcphdr *th;
+	int err = -ENODEV;
+	struct socket *sock;
+	struct sock *sk;
+	struct sk_buff *skb;
+	struct iovec iov;
+	struct msghdr msg;
+	unsigned flags = MSG_DONTWAIT;
+	unsigned int size = *len, read = 0, osize = *len;
+	unsigned int slen, process;
+	unsigned int tm = *timeout;
+
+	if (!nc->inode)
+		goto err_out;
+	sock = SOCKET_I(nc->inode);
+	if (!sock || !sock->sk)
+		goto err_out;
+
+	sk = sock->sk;
+
+	while (size) {
+		msg.msg_control=NULL;
+		msg.msg_controllen=0;
+		msg.msg_iovlen=1;
+		msg.msg_iov=&iov;
+		msg.msg_name=NULL;
+		msg.msg_namelen=0;
+		msg.msg_flags = flags;
+		iov.iov_len=size;
+		iov.iov_base=arg;
+
+		nc->stat.enter++;
+
+		err = sock_recvmsg(sock, &msg, iov.iov_len, flags);
+
+		if (err > 0) {
+			size -= err;
+			read += err;
+
+			if (!size) {
+				err = 0;
+				nc->stat.ready++;
+				break;
+			}
+		} else if (err && err != -EAGAIN)
+			break;
+
+		err = 0;
+		process = 0;
+		slen = 0;
+
+		nc->stat.recv++;
+
+		while (slen < 2*osize) {
+#if 1
+			if (skb_queue_empty(&nc->recv_queue) && slen > osize) {
+				nc->stat.empty++;
+				break;
+			}
+#endif
+			skb = netchannel_get_skb(nc, &tm, &err);
+			if (!skb) {
+				nc->stat.null++;
+				break;
+			}
+			skb->netchannel = nc->unc.type & 1;
+
+			__skb_pull(skb, skb->nh.iph->ihl*4);
+
+			skb->h.raw = skb->data;
+
+			th = skb->h.th;
+			TCP_SKB_CB(skb)->seq = ntohl(th->seq);
+			TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
+						    skb->len - th->doff * 4);
+			TCP_SKB_CB(skb)->ack_seq = ntohl(th->ack_seq);
+			TCP_SKB_CB(skb)->when	 = 0;
+			TCP_SKB_CB(skb)->flags	 = skb->nh.iph->tos;
+			TCP_SKB_CB(skb)->sacked	 = 0;
+
+			nc->stat.backlog++;
+						
+			if (sk->sk_backlog_rcv) {
+				err = sk->sk_backlog_rcv(sk, skb);
+				if (err) {
+					nc->stat.backlog_err++;
+					break;
+				}
+			}
+
+			slen += skb->len;
+
+			nc->stat.eat++;
+		}
+
+		if (err)
+			break;
+	}
+
+	*timeout = tm;
+	*len = read;
+
+	return err;
+
+err_out:
+	return err;
+}
+
+static int netchannel_copy_to_user(struct netchannel *nc, unsigned int *timeout, unsigned int *len, void *arg)
+{
+	unsigned int copied;
+	struct sk_buff *skb;
+	struct iovec to;
+	int err;
+
+	skb = netchannel_get_skb(nc, timeout, &err);
+	if (!skb)
+		return err;
+
+	to.iov_base = arg;
+	to.iov_len = *len;
+
+	copied = skb->len;
+	if (copied > *len)
+		copied = *len;
+
+	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
+		err = skb_copy_datagram_iovec(skb, 0, &to, copied);
+	} else {
+		err = skb_copy_and_csum_datagram_iovec(skb,0, &to);
+	}
+
+	*len = (err == 0)?copied:0;
+
+	kfree_skb(skb);
+
+	return err;
+}
+
+int netchannel_skb_copy_datagram(const struct sk_buff *skb, int offset,
+			    void *to, int len)
+{
+	int start = skb_headlen(skb);
+	int i, copy = start - offset;
+
+	/* Copy header. */
+	if (copy > 0) {
+		if (copy > len)
+			copy = len;
+		memcpy(to, skb->data + offset, copy);
+
+		if ((len -= copy) == 0)
+			return 0;
+		offset += copy;
+		to += copy;
+	}
+
+	/* Copy paged appendix. Hmm... why does this look so complicated? */
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		int end;
+
+		BUG_TRAP(start <= offset + len);
+
+		end = start + skb_shinfo(skb)->frags[i].size;
+		if ((copy = end - offset) > 0) {
+			u8  *vaddr;
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+			struct page *page = frag->page;
+
+			if (copy > len)
+				copy = len;
+			vaddr = kmap(page);
+			memcpy(to, vaddr + frag->page_offset +
+					     offset - start, copy);
+			kunmap(page);
+			if (!(len -= copy))
+				return 0;
+			offset += copy;
+			to += copy;
+		}
+		start = end;
+	}
+
+	if (skb_shinfo(skb)->frag_list) {
+		struct sk_buff *list = skb_shinfo(skb)->frag_list;
+
+		for (; list; list = list->next) {
+			int end;
+
+			BUG_TRAP(start <= offset + len);
+
+			end = start + list->len;
+			if ((copy = end - offset) > 0) {
+				if (copy > len)
+					copy = len;
+				if (netchannel_skb_copy_datagram(list,
+							    offset - start,
+							    to, copy))
+					goto fault;
+				if ((len -= copy) == 0)
+					return 0;
+				offset += copy;
+				to += copy;
+			}
+			start = end;
+		}
+	}
+	if (!len)
+		return 0;
+
+fault:
+	return -EFAULT;
+}
+
+static int netchannel_copy_to_mem(struct netchannel *nc, unsigned int *timeout, unsigned int *len, void *arg)
+{
+	struct netchannel_mmap *m = nc->priv;
+	unsigned int copied, skb_offset = 0;
+	struct sk_buff *skb;
+	int err;
+
+	skb = netchannel_get_skb(nc, timeout, &err);
+	if (!skb)
+		return err;
+
+	copied = skb->len;
+
+	while (copied) {
+		int pnum = ((m->poff % PAGE_SIZE) % m->pnum);
+		struct page *page = m->page[pnum];
+		void *page_map, *ptr;
+		unsigned int sz, left;
+
+		left = PAGE_SIZE - (m->poff % (PAGE_SIZE - 1));
+		sz = min_t(unsigned int, left, copied);
+
+		if (!sz) {
+			err = -ENOSPC;
+			goto err_out;
+		}
+
+		page_map = kmap_atomic(page, KM_USER0);
+		if (!page_map) {
+			err = -ENOMEM;
+			goto err_out;
+		}
+		ptr = page_map + (m->poff % (PAGE_SIZE - 1));
+
+		err = netchannel_skb_copy_datagram(skb, skb_offset, ptr, sz);
+		if (err) {
+			kunmap_atomic(page_map, KM_USER0);
+			goto err_out;
+		}
+		kunmap_atomic(page_map, KM_USER0);
+
+		copied -= sz;
+		m->poff += sz;
+		skb_offset += sz;
+#if 1
+		if (m->poff >= PAGE_SIZE * m->pnum) {
+			//netchannel_dump_info_unc(&nc->unc, "rewind", nc->hit, 0);
+			m->poff = 0;
+		}
+#endif
+	}
+	*len = skb->len;
+
+	err = 0;
+
+err_out:
+	kfree_skb(skb);
+
+	return err;
+}
+
+static int netchannel_mmap_setup(struct netchannel *nc)
+{
+	struct netchannel_mmap *m;
+	unsigned int i, pnum;
+
+	pnum = nc->unc.memory_limit_order - NETCHANNEL_MIN_ORDER;
+
+	m = kzalloc(sizeof(struct netchannel_mmap) + sizeof(struct page *) * pnum, GFP_KERNEL);
+	if (!m)
+		return -ENOMEM;
+
+	m->page = (struct page **)(m + 1);
+	m->pnum = pnum;
+
+	for (i=0; i<pnum; ++i) {
+		m->page[i] = alloc_page(GFP_KERNEL);
+		if (!m->page[i])
+			break;
+	}
+
+	if (i < pnum) {
+		pnum = i;
+		goto err_out_free;
+	}
+
+	nc->priv = m;
+
+	switch (nc->unc.proto) {
+		case IPPROTO_TCP:
+			nc->nc_read_data = &netchannel_copy_to_user_tcp;
+			break;
+		case IPPROTO_UDP:
+		default:
+			nc->nc_read_data = &netchannel_copy_to_mem;
+			break;
+	}
+
+	return 0;
+
+err_out_free:
+	for (i=0; i<pnum; ++i)
+		__free_page(m->page[i]);
+
+	kfree(m);
+
+	return -ENOMEM;
+	
+}
+
+static int netchannel_copy_user_setup(struct netchannel *nc)
+{
+	int ret = 0;
+	
+	switch (nc->unc.proto) {
+		case IPPROTO_UDP:
+			nc->nc_read_data = &netchannel_copy_to_user;
+			break;
+		case IPPROTO_TCP:
+			nc->nc_read_data = &netchannel_copy_to_user_tcp;
+			break;
+		default:
+			ret = -EINVAL;
+			break;
+	}
+
+	return ret;
+}
+
+static int netchannel_setup(struct netchannel *nc)
+{
+	int ret = 0;
+
+	if (nc->unc.memory_limit_order > NETCHANNEL_MAX_ORDER)
+		nc->unc.memory_limit_order = NETCHANNEL_MAX_ORDER;
+
+	if (nc->unc.memory_limit_order < NETCHANNEL_MIN_ORDER)
+		nc->unc.memory_limit_order = NETCHANNEL_MIN_ORDER;
+	
+	switch (nc->unc.type) {
+		case NETCHANNEL_COPY_USER:
+			ret = netchannel_copy_user_setup(nc);
+			break;
+		case NETCHANNEL_MMAP:
+			ret = netchannel_mmap_setup(nc);
+			break;
+		default:
+			ret = -EINVAL;
+			break;
+	}
+
+	return ret;
+}
+
+static int netchannel_bind(struct unetchannel_control *ctl)
+{
+	struct netchannel *nc;
+	int err = -EINVAL, fput_needed;
+	struct netchannel_cache_head *bucket;
+	struct file *file;
+	struct inode *inode;
+
+	file = fget_light(ctl->fd, &fput_needed);
+	if (!file)
+		goto err_out_exit;
+
+	inode = igrab(file->f_dentry->d_inode);
+	if (!inode)
+		goto err_out_fput;
+
+	bucket = netchannel_bucket(&ctl->unc);
+	
+	mutex_lock(&bucket->mutex);
+	
+	nc = netchannel_check_full(&ctl->unc, bucket);
+	if (!nc) {
+		err = -ENODEV;
+		goto err_out_unlock;
+	}
+
+	nc->inode = inode;
+
+	fput_light(file, fput_needed);
+	mutex_unlock(&bucket->mutex);
+
+	return 0;
+
+err_out_unlock:
+	mutex_unlock(&bucket->mutex);
+err_out_fput:
+	fput_light(file, fput_needed);
+err_out_exit:
+	return err;
+}
+
+static void netchannel_dump_stat(struct netchannel *nc)
+{
+	printk("netchannel: enter: %llu, ready: %llu, recv: %llu, empty: %llu, null: %llu, backlog: %llu, backlog_err: %llu, eat: %llu.\n",
+			nc->stat.enter, nc->stat.ready, nc->stat.recv, nc->stat.empty, nc->stat.null, nc->stat.backlog,
+			nc->stat.backlog_err, nc->stat.eat);
+}
+
+static void netchannel_work(void *data)
+{
+	struct netchannel *nc = data;
+	
+	netchannel_dump_info_unc(&nc->unc, "work", nc->hit, 0);
+
+	if (nc->inode) {
+		struct socket *sock;
+		struct sock *sk;
+
+		sock = SOCKET_I(nc->inode);
+		if (!sock || !sock->sk)
+			goto out;
+
+		sk = sock->sk;
+		printk("netchannel: sk: %p, skb_qlen: %u, nc_qlen: %u.\n", 
+				sk, skb_queue_len(&nc->recv_queue), nc->qlen);
+	}
+	netchannel_dump_stat(nc);
+out:
+	schedule_delayed_work(&nc->work, msecs_to_jiffies(1000*nc->unc.init_stat_work));
+}
+
+static int netchannel_create(struct unetchannel *unc)
+{
+	struct netchannel *nc;
+	int err = -ENOMEM;
+	struct netchannel_cache_head *bucket;
+	
+	nc = kmem_cache_alloc(netchannel_cache, GFP_KERNEL);
+	if (!nc)
+		return -ENOMEM;
+
+	memset(nc, 0, sizeof(struct netchannel));
+	
+	nc->hit = 0;
+	skb_queue_head_init(&nc->recv_queue);
+	init_waitqueue_head(&nc->wait);
+	atomic_set(&nc->refcnt, 1);
+	memcpy(&nc->unc, unc, sizeof(struct unetchannel));
+
+	err = netchannel_setup(nc);
+	if (err)
+		goto err_out_free;
+	
+	bucket = netchannel_bucket(unc);
+	
+	mutex_lock(&bucket->mutex);
+	
+	if (netchannel_check_full(unc, bucket)) {
+		err = -EEXIST;
+		goto err_out_unlock;
+	}
+
+	hlist_add_head_rcu(&nc->node, &bucket->head);
+	err = 0;
+
+	mutex_unlock(&bucket->mutex);
+	
+	netchannel_dump_info_unc(unc, "create", 0, err);
+
+	INIT_WORK(&nc->work, netchannel_work, nc);
+	if (nc->unc.init_stat_work)
+		schedule_delayed_work(&nc->work, msecs_to_jiffies(1000*nc->unc.init_stat_work));
+
+	return err;
+
+err_out_unlock:
+	mutex_unlock(&bucket->mutex);
+
+	netchannel_cleanup(nc);
+
+err_out_free:
+	kmem_cache_free(netchannel_cache, nc);
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
+	if (nc->unc.init_stat_work) {
+		cancel_rearming_delayed_work(&nc->work);
+		flush_scheduled_work();
+	}
+	
+	if (nc->inode) {
+		iput(nc->inode);
+		nc->inode = NULL;
+	}
+	
+	netchannel_put(nc);
+	err = 0;
+
+out_unlock:
+	mutex_unlock(&bucket->mutex);
+	netchannel_dump_info_unc(unc, "remove", hit, err);
+	return err;
+}
+
+static int netchannel_recv_data(struct unetchannel_control *ctl, void __user *data)
+{
+	int ret = -ENODEV;
+	struct netchannel_cache_head *bucket;
+	struct netchannel *nc;
+	
+	bucket = netchannel_bucket(&ctl->unc);
+
+	mutex_lock(&bucket->mutex);
+
+	nc = netchannel_check_full(&ctl->unc, bucket);
+	if (!nc)
+		nc = netchannel_check_dest(&ctl->unc, bucket);
+
+	if (!nc)
+		goto err_out_unlock;
+
+	netchannel_get(nc);
+	mutex_unlock(&bucket->mutex);
+
+	ret = nc->nc_read_data(nc, &ctl->timeout, &ctl->len, data);
+	
+	netchannel_put(nc);
+	return ret;
+
+err_out_unlock:
+	mutex_unlock(&bucket->mutex);
+	return ret;
+}
+
+static int netchannel_dump_info(struct unetchannel *unc)
+{
+	struct netchannel_cache_head *bucket;
+	struct netchannel *nc;
+	char *ncs = "none";
+	unsigned long hit = 0;
+	int err;
+	
+	bucket = netchannel_bucket(unc);
+
+	mutex_lock(&bucket->mutex);
+	nc = netchannel_check_full(unc, bucket);
+	if (!nc) {
+		nc = netchannel_check_dest(unc, bucket);
+		if (nc)
+			ncs = "dest";
+	} else 
+		ncs = "full";
+	if (nc)
+		hit = nc->hit;
+	mutex_unlock(&bucket->mutex);
+	err = (nc)?0:-ENODEV;
+
+	netchannel_dump_info_unc(unc, ncs, hit, err);
+
+	return err;
+}
+
+asmlinkage long sys_netchannel_control(void __user *arg)
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
+			ret = netchannel_create(&ctl.unc);
+			break;
+		case NETCHANNEL_BIND:
+			ret = netchannel_bind(&ctl);
+			break;
+		case NETCHANNEL_REMOVE:
+			ret = netchannel_remove(&ctl.unc);
+			break;
+		case NETCHANNEL_READ:
+			ret = netchannel_recv_data(&ctl, arg + sizeof(struct unetchannel_control));
+			break;
+		case NETCHANNEL_DUMP:
+			ret = netchannel_dump_info(&ctl.unc);
+			break;
+		default:
+			ret = -EINVAL;
+			break;
+	}
+	
+	if (copy_to_user(arg, &ctl, sizeof(struct unetchannel_control)))
+		return -ERESTARTSYS;
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
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index fb3770f..f979fd6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -437,6 +437,7 @@ struct sk_buff *skb_clone(struct sk_buff
 	C(pkt_type);
 	C(ip_summed);
 	C(priority);
+	C(netchannel);
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	C(ipvs_property);
 #endif
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 672950e..eb2dc12 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -727,7 +727,10 @@ int tcp_v4_conn_request(struct sock *sk,
 #endif
 
 	/* Never answer to SYNs send to broadcast or multicast */
-	if (((struct rtable *)skb->dst)->rt_flags &
+	if (!skb->dst) {
+		if (MULTICAST(daddr))
+			goto drop;
+	} else if (((struct rtable *)skb->dst)->rt_flags &
 	    (RTCF_BROADCAST | RTCF_MULTICAST))
 		goto drop;
 
@@ -924,15 +927,21 @@ static struct sock *tcp_v4_hnd_req(struc
 	struct iphdr *iph = skb->nh.iph;
 	struct sock *nsk;
 	struct request_sock **prev;
+	int iif;
 	/* Find possible connection requests. */
 	struct request_sock *req = inet_csk_search_req(sk, &prev, th->source,
 						       iph->saddr, iph->daddr);
 	if (req)
 		return tcp_check_req(sk, skb, req, prev);
 
+	if (!skb->dst)
+		iif = 0;
+	else
+		iif = inet_iif(skb);
+
 	nsk = __inet_lookup_established(&tcp_hashinfo, skb->nh.iph->saddr,
 					th->source, skb->nh.iph->daddr,
-					ntohs(th->dest), inet_iif(skb));
+					ntohs(th->dest), iif);
 
 	if (nsk) {
 		if (nsk->sk_state != TCP_TIME_WAIT) {

-- 
	Evgeniy Polyakov
