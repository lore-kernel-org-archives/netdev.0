From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Netchannels: progress report. Sending benchmark.
Date: Mon, 10 Jul 2006 17:23:22 +0400
Message-ID: <20060710132321.GA585@2ka.mipt.ru>
References: <20060608171555.GA10273@2ka.mipt.ru> <20060613173321.GA648@2ka.mipt.ru> <20060629093801.GA6049@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:30137 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1161162AbWGJNXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2006 09:23:37 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060629093801.GA6049@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After week vacations I'm pleased to announce following progress report.

Numbers for small packets (80 bytes) bulk sending:

 * netchannel: 57 MB/sec, ~80% CPU usage
 * socket: 22 MB/sec, ~90% CPU usage

Receiving side is netcat server, which dumps received data into
/dev/null

Actually it is not 100% correct to call that results correct, since 
it uses hackish optimisations, which can lead to broken behaviour for 
non-bulk transfers or transfers over bad lines. If some of them are
removed, speed drops to 54 MB/sec for 80 bytes packets, and if socket
analog for NODELAY flag is set, i.e. each packet is immediately being
sent when it has been written, speed drops down to 16 MB/sec (socket
with SO_NODELAY was not tested though).

Netchannel homepage:
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
@@ -696,4 +696,5 @@ #endif
 	.quad sys_sync_file_range
 	.quad sys_tee
 	.quad compat_sys_vmsplice
+	.quad sys_netchannel_control
 ia32_syscall_end:		
diff --git a/include/asm-i386/unistd.h b/include/asm-i386/unistd.h
index eb4b152..777cd85 100644
--- a/include/asm-i386/unistd.h
+++ b/include/asm-i386/unistd.h
@@ -322,8 +322,9 @@ #define __NR_splice		313
 #define __NR_sync_file_range	314
 #define __NR_tee		315
 #define __NR_vmsplice		316
+#define __NR_netchannel_control	317
 
-#define NR_syscalls 317
+#define NR_syscalls 318
 
 /*
  * user-visible error numbers are in the range -1 - -128: see
diff --git a/include/asm-x86_64/unistd.h b/include/asm-x86_64/unistd.h
index feb77cb..4459bad 100644
--- a/include/asm-x86_64/unistd.h
+++ b/include/asm-x86_64/unistd.h
@@ -617,8 +617,10 @@ #define __NR_sync_file_range	277
 __SYSCALL(__NR_sync_file_range, sys_sync_file_range)
 #define __NR_vmsplice		278
 __SYSCALL(__NR_vmsplice, sys_vmsplice)
+#define __NR_netchannel_control	279
+__SYSCALL(__NR_netchannel_control, sys_netchannel_control)
 
-#define __NR_syscall_max __NR_vmsplice
+#define __NR_syscall_max __NR_netchannel_control
 
 #ifndef __NO_STUBS
 
diff --git a/include/linux/netchannel.h b/include/linux/netchannel.h
new file mode 100644
index 0000000..6041ee6
--- /dev/null
+++ b/include/linux/netchannel.h
@@ -0,0 +1,142 @@
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
+	NETCHANNEL_RECV,
+	NETCHANNEL_SEND,
+	NETCHANNEL_DUMP,
+	NETCHANNEL_CONNECT,
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
+	__u32			faddr, laddr;		/* foreign/local hashes */
+	__u16			fport, lport;		/* foreign/local ports */
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
+struct netchannel;
+
+struct common_protocol
+{
+	unsigned int		size;
+
+	int 			(*connect)(struct netchannel *);
+	int 			(*destroy)(struct netchannel *);
+
+	int 			(*process_in)(struct netchannel *, void *, unsigned int);
+	int 			(*process_out)(struct netchannel *, void *, unsigned int);
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
+	int			(*nc_recv_data)(struct netchannel *, unsigned int *timeout, unsigned int *len, void *arg);
+	int			(*nc_send_data)(struct netchannel *, unsigned int *timeout, unsigned int *len, void *arg);
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
+
+	struct common_protocol	*proto;
+	struct dst_entry	*dst;
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
+extern struct common_protocol atcp_common_protocol;
+
+extern struct sk_buff *netchannel_get_skb(struct netchannel *nc, unsigned int *timeout, int *error);
+struct dst_entry *netchannel_route_get_raw(struct netchannel *nc);
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
index f8f2347..ba82aa2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -314,6 +314,18 @@ static inline struct sk_buff *alloc_skb(
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
diff --git a/net/core/dev.c b/net/core/dev.c
index 9ab3cfa..2721111 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1712,6 +1712,10 @@ #endif
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
index 0000000..20a09d8
--- /dev/null
+++ b/net/core/netchannel.c
@@ -0,0 +1,1188 @@
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
+	unsigned int h = (unc->faddr ^ unc->fport) ^ (unc->laddr ^ unc->lport);
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
+	return (unc1->fport == unc2->fport) && (unc1->faddr == unc2->faddr) &&
+				(unc1->lport == unc2->lport) && (unc1->laddr == unc2->laddr) && 
+				(unc1->proto == unc2->proto);
+}
+
+static inline int netchannel_hash_equal_dest(struct unetchannel *unc1, struct unetchannel *unc2)
+{
+	return ((unc1->fport == unc2->fport) && (unc1->faddr == unc2->faddr) && (unc1->proto == unc2->proto));
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
+	kfree(nc->proto);
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
+	printk(KERN_NOTICE "netchannel: %s %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, "
+			"proto: %u, type: %u, order: %u, hit: %lu, err: %d.\n",
+			prefix, NIPQUAD(unc->laddr), ntohs(unc->lport), NIPQUAD(unc->faddr), ntohs(unc->fport), 
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
+	unc->faddr = iph->saddr;
+	unc->laddr = iph->daddr;
+	unc->proto = iph->protocol;
+
+	len = skb->len;
+
+	skb->h.raw = skb->nh.raw + iph->ihl*4;
+
+	switch (unc->proto) {
+		case IPPROTO_TCP:
+		case IPPROTO_UDP:
+			unc->fport = ((u16 *)skb->h.raw)[0];
+			unc->lport = ((u16 *)skb->h.raw)[1];
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
+	//printk("\n%s: skb: %p, size: %u.\n", __func__, skb, skb->len);
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
+struct sk_buff *netchannel_get_skb(struct netchannel *nc, unsigned int *timeout, int *error)
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
+static int netchannel_copy_to_user_tcp(struct netchannel *nc, unsigned int *timeout, unsigned int *len, void *buf)
+{
+	int ret = nc->proto->process_in(nc, buf, *len);
+	if (ret < 0)
+		return ret;
+	*len = ret;
+	return 0;
+}
+
+static int netchannel_copy_from_user_tcp(struct netchannel *nc, unsigned int *timeout, unsigned int *len, void *buf)
+{
+	int ret = nc->proto->process_out(nc, buf, *len);
+	if (ret < 0)
+		return ret;
+	*len = ret;
+	return 0;
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
+			nc->proto = kzalloc(atcp_common_protocol.size, GFP_KERNEL);
+			if (!nc->proto)
+				goto err_out_free;
+			memcpy(nc->proto, &atcp_common_protocol, sizeof(struct common_protocol));
+			nc->nc_recv_data = &netchannel_copy_to_user_tcp;
+			nc->nc_send_data = &netchannel_copy_from_user_tcp;
+			break;
+		case IPPROTO_UDP:
+		default:
+			nc->nc_recv_data = &netchannel_copy_to_mem;
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
+			nc->nc_recv_data = &netchannel_copy_to_user;
+			break;
+		case IPPROTO_TCP:
+			nc->proto = kzalloc(atcp_common_protocol.size, GFP_KERNEL);
+			if (!nc->proto) {
+				ret = -ENOMEM;
+				break;
+			}
+			memcpy(nc->proto, &atcp_common_protocol, sizeof(struct common_protocol));
+			nc->nc_recv_data = &netchannel_copy_to_user_tcp;
+			nc->nc_send_data = &netchannel_copy_from_user_tcp;
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
+	printk(KERN_NOTICE "netchannel: enter: %llu, ready: %llu, recv: %llu, empty: %llu, null: %llu, backlog: %llu, backlog_err: %llu, eat: %llu.\n",
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
+		printk(KERN_NOTICE "netchannel: sk: %p, skb_qlen: %u, nc_qlen: %u.\n", 
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
+	nc->dst = netchannel_route_get_raw(nc);
+	if (!nc->dst) {
+		err = -ENODEV;
+		goto err_out_cleanup;
+	}
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
+	dst_release(nc->dst);
+err_out_cleanup:
+	netchannel_cleanup(nc);
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
+	if (nc->proto->destroy)
+		nc->proto->destroy(nc);
+	
+	if (nc->inode) {
+		iput(nc->inode);
+		nc->inode = NULL;
+	}
+	dst_release(nc->dst);
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
+static int netchannel_send_data(struct unetchannel_control *ctl, void __user *data)
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
+	ret = nc->nc_send_data(nc, &ctl->timeout, &ctl->len, data);
+	
+	netchannel_put(nc);
+	return ret;
+
+err_out_unlock:
+	mutex_unlock(&bucket->mutex);
+	return ret;
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
+	ret = nc->nc_recv_data(nc, &ctl->timeout, &ctl->len, data);
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
+static int netchannel_connect(struct unetchannel *unc)
+{
+	struct netchannel *nc;
+	int err = -ENODEV;
+	struct netchannel_cache_head *bucket;
+	
+	bucket = netchannel_bucket(unc);
+	
+	mutex_lock(&bucket->mutex);
+	nc = netchannel_check_full(unc, bucket);
+	if (!nc)
+		goto err_out_unlock;
+	netchannel_get(nc);
+	mutex_unlock(&bucket->mutex);
+
+	err = 0;
+	if (nc->proto->connect)
+		err = nc->proto->connect(nc);
+	netchannel_put(nc);
+
+	return err;
+
+err_out_unlock:
+	mutex_unlock(&bucket->mutex);
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
+		case NETCHANNEL_CONNECT:
+			ret = netchannel_connect(&ctl.unc);
+			break;
+		case NETCHANNEL_BIND:
+			ret = netchannel_bind(&ctl);
+			break;
+		case NETCHANNEL_REMOVE:
+			ret = netchannel_remove(&ctl.unc);
+			break;
+		case NETCHANNEL_RECV:
+			ret = netchannel_recv_data(&ctl, arg + sizeof(struct unetchannel_control));
+			break;
+		case NETCHANNEL_SEND:
+			ret = netchannel_send_data(&ctl, arg + sizeof(struct unetchannel_control));
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
+	printk(KERN_NOTICE "netchannel: %s %u.%u.%u.%u/%u.%u.%u.%u\n", str, NIPQUAD(ifa->ifa_local), NIPQUAD(ifa->ifa_mask));
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
+	printk(KERN_NOTICE "netchannel: inet6 event=%lx, ifa=%p.\n", event, ifa);
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
+	printk(KERN_NOTICE "netchannel: Created %u order two-dimensional hash table.\n", 
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
+	printk(KERN_NOTICE "netchannel: Failed to create %u order two-dimensional hash table.\n", 
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
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index e40f753..6ea6379 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -428,6 +428,11 @@ config INET_TCP_DIAG
 	depends on INET_DIAG
 	def_tristate INET_DIAG
 
+config ATCP
+	bool "TCP: altenative TCP stack used for netchannels"
+	---help---
+	  Extremely lightweight RFC compliant TCP stack used for netchannels.
+
 config TCP_CONG_ADVANCED
 	bool "TCP: advanced congestion control"
 	---help---
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 9ef50a0..25c122f 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -42,6 +42,7 @@ obj-$(CONFIG_TCP_CONG_HYBLA) += tcp_hybl
 obj-$(CONFIG_TCP_CONG_HTCP) += tcp_htcp.o
 obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vegas.o
 obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
+obj-$(CONFIG_ATCP) += atcp.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o
diff --git a/net/ipv4/atcp.c b/net/ipv4/atcp.c
new file mode 100644
index 0000000..f17bec3
--- /dev/null
+++ b/net/ipv4/atcp.c
@@ -0,0 +1,1482 @@
+/*
+ * 	atcp.c
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
+#include <linux/skbuff.h>
+#include <linux/random.h>
+#include <linux/netchannel.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
+
+#include <net/tcp.h>
+#include <net/route.h>
+
+//#define ATCP_DEBUG
+
+#ifdef ATCP_DEBUG
+#define ulog(f, a...) printk(f, ##a)
+#else
+#define ulog(f, a...)
+#endif
+
+#if 0
+enum {
+	TCP_ESTABLISHED = 1,
+	TCP_SYN_SENT,
+	TCP_SYN_RECV,
+	TCP_FIN_WAIT1,
+	TCP_FIN_WAIT2,
+	TCP_TIME_WAIT,
+	TCP_CLOSE,
+	TCP_CLOSE_WAIT,
+	TCP_LAST_ACK,
+	TCP_LISTEN,
+	TCP_CLOSING
+};
+#endif
+
+#define packet_timestamp	(__u32)jiffies
+
+#define TCP_MAX_WSCALE	14
+static __u8 atcp_offer_wscale = 8;
+
+static __u32 atcp_max_qlen = 1024*10;
+
+struct atcp_protocol
+{
+	struct common_protocol	cproto;
+
+	struct netchannel	*nc;
+
+	__u32			state;
+
+	__u32			snd_una;
+	__u32			snd_nxt;
+	__u16			snd_wnd;
+	__u32			snd_wl1;
+	__u32			snd_wl2;
+	__u32			iss;
+
+	__u32			rcv_nxt;
+	__u16			rcv_wnd;
+	__u16			rcv_wup;
+	__u32			irs;
+
+	__u8			rwscale, swscale;
+	__u16			mss;
+	__u32			tsval, tsecr;
+	__u32			ack_sent, ack_missed, sent_without_reading;
+
+	struct sk_buff_head	ofo_queue;
+
+	struct sk_buff_head	retransmit_queue;
+	struct skb_timeval	first_packet_ts;
+	__u32			retransmit_timeout;
+
+	__u32			seq_read;
+
+	__u32			snd_cwnd, snd_ssthresh, in_flight, in_flight_bytes, cong;
+
+	__u32			qlen;
+};
+
+struct state_machine
+{
+	__u32		state;
+	int		(*run)(struct atcp_protocol *, struct sk_buff *);
+};
+
+static inline struct atcp_protocol *atcp_convert(struct common_protocol *cproto)
+{
+	return (struct atcp_protocol *)cproto;
+}
+
+static inline __u32 skb_rwin(struct atcp_protocol *tp, struct sk_buff *skb)
+{
+	__u32 rwin = ntohs(skb->h.th->window);
+	return (rwin << tp->rwscale);
+}
+
+static inline __u32 tp_rwin(struct atcp_protocol *tp)
+{
+	__u32 rwin = tp->rcv_wnd;
+	return rwin << tp->rwscale;
+}
+
+static inline __u32 tp_swin(struct atcp_protocol *tp)
+{
+	__u32 swin = tp->snd_wnd;
+	return swin << tp->swscale;
+}
+
+static inline int beforeeq(__u32 seq1, __u32 seq2)
+{
+        return (__s32)(seq1-seq2) <= 0;
+}
+
+static inline int aftereq(__u32 seq1, __u32 seq2)
+{
+	return (__s32)(seq2-seq1) <= 0;
+}
+
+struct atcp_option
+{
+	__u8		kind, length;
+	int		(*callback)(struct atcp_protocol *tp, struct sk_buff *skb, __u8 *data);
+};
+
+struct atcp_option_timestamp
+{
+	__u8			kind, length;
+	__u32			tsval, tsecr;
+} __attribute__ ((packed));
+
+struct atcp_option_nop
+{
+	__u8			kind;
+} __attribute__ ((packed));
+
+struct atcp_option_mss
+{
+	__u8			kind, length;
+	__u16			mss;
+} __attribute__ ((packed));
+
+struct atcp_option_wscale
+{
+	__u8			kind, length;
+	__u8			wscale;
+} __attribute__ ((packed));
+
+#define TCP_OPT_NOP	1
+#define TCP_OPT_MSS	2
+#define TCP_OPT_WSCALE	3
+#define TCP_OPT_TS	8
+
+static int atcp_opt_mss(struct atcp_protocol *tp, struct sk_buff *skb __attribute__ ((unused)), __u8 *data)
+{
+	tp->mss = ntohs(((__u16 *)data)[0]);
+	ulog("%s: mss: %u.\n", __func__, tp->mss);
+	return 0;
+}
+
+static int atcp_opt_wscale(struct atcp_protocol *tp, struct sk_buff *skb __attribute__ ((unused)), __u8 *data)
+{
+	if ((skb->h.th->syn) && ((tp->state == TCP_SYN_SENT) || (tp->state == TCP_SYN_SENT))) {
+		tp->rwscale = data[0];
+		if (tp->rwscale > TCP_MAX_WSCALE)
+			tp->rwscale = TCP_MAX_WSCALE;
+		tp->swscale = atcp_offer_wscale;
+		ulog("%s: rwscale: %u, swscale: %u.\n", __func__, tp->rwscale, tp->swscale);
+	}
+	return 0;
+}
+
+static int atcp_opt_ts(struct atcp_protocol *tp, struct sk_buff *skb, __u8 *data)
+{
+	__u32 seq = TCP_SKB_CB(skb)->seq;
+	__u32 end_seq = TCP_SKB_CB(skb)->end_seq;
+	__u32 packet_tsval = ntohl(((__u32 *)data)[0]);
+
+	if (!skb->h.th->ack)
+		return 0;
+
+	/* PAWS check */
+	if ((tp->state == TCP_ESTABLISHED) && before(packet_tsval, tp->tsecr)) {
+		ulog("%s: PAWS failed: packet: seq: %u, end_seq: %u, tsval: %u, tsecr: %u, host tsval: %u, tsecr: %u.\n",
+				__func__, seq, end_seq, packet_tsval, ntohl(((__u32 *)data)[1]), tp->tsval, tp->tsecr);
+		return 1;
+	}
+	
+	if (between(tp->ack_sent, seq, end_seq))
+		tp->tsecr = packet_tsval;
+	return 0;
+}
+
+static struct atcp_option atcp_supported_options[] = {
+	[TCP_OPT_NOP] = {.kind = TCP_OPT_NOP, .length = 1},
+	[TCP_OPT_MSS] = {.kind = TCP_OPT_MSS, .length = 4, .callback = &atcp_opt_mss},
+	[TCP_OPT_WSCALE] = {.kind = TCP_OPT_WSCALE, .length = 3, .callback = &atcp_opt_wscale},
+	[TCP_OPT_TS] = {.kind = TCP_OPT_TS, .length = 10, .callback = &atcp_opt_ts},
+};
+
+#define TCP_FLAG_SYN	0x1
+#define TCP_FLAG_ACK	0x2
+#define TCP_FLAG_RST	0x4
+#define TCP_FLAG_PSH	0x8
+#define TCP_FLAG_FIN	0x10
+
+static inline void atcp_set_state(struct atcp_protocol *tp, __u32 state)
+{
+	ulog("state change: %u -> %u.\n", tp->state, state);
+	tp->state = state;
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
+struct dst_entry *netchannel_route_get_raw(struct netchannel *nc)
+{
+	struct rtable *rt;
+	struct flowi fl = { .oif = 0,
+			    .nl_u = { .ip4_u =
+				      { .daddr = nc->unc.faddr,
+					.saddr = nc->unc.laddr,
+					.tos = 0 } },
+			    .proto = nc->unc.proto,
+			    .uli_u = { .ports =
+				       { .sport = nc->unc.lport,
+					 .dport = nc->unc.fport } } };
+
+	if (netchannel_ip_route_output_flow(&rt, &fl, 0))
+		goto no_route;
+	return dst_clone(&rt->u.dst);
+
+no_route:
+	return NULL;
+}
+
+static inline struct dst_entry *netchannel_route_get(struct netchannel *nc)
+{
+	if (nc->dst && nc->dst->obsolete && nc->dst->ops->check(nc->dst, 0) == NULL) {
+		dst_release(nc->dst);
+		nc->dst = netchannel_route_get_raw(nc);
+		if (!nc->dst)
+			return NULL;
+	}
+	return dst_clone(nc->dst);
+}
+
+void netchannel_route_put(struct dst_entry *dst)
+{
+	/* dst_entry is being freed when skb is released in NIC */
+}
+
+static int transmit_data(struct sk_buff *skb, struct atcp_protocol *tp)
+{
+#ifdef ATCP_DEBUG
+	{
+		struct tcphdr *th = skb->h.th;
+
+		ulog("S %u.%u.%u.%u:%u <-> %u.%u.%u.%u:%u : seq: %u, ack: %u, win: %u [%u], doff: %u, "
+			"s: %u, a: %u, p: %u, r: %u, f: %u, len: %u, state: %u, skb: %p, csum: %04x.\n",
+			NIPQUAD(tp->nc->unc.laddr), ntohs(tp->nc->unc.lport),
+			NIPQUAD(tp->nc->unc.faddr), ntohs(tp->nc->unc.fport),
+			ntohl(th->seq), ntohl(th->ack_seq), ntohs(th->window), tp_rwin(tp), th->doff,
+			th->syn, th->ack, th->psh, th->rst, th->fin,
+			skb->len, tp->state, skb, th->check);
+	}
+#endif
+	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, skb->dst->dev, dst_output);
+}
+
+static int ip_build_header(struct netchannel *nc, struct sk_buff *skb)
+{
+	struct iphdr *iph;
+
+	skb->nh.iph = iph = (struct iphdr *)skb_push(skb, sizeof(struct iphdr));
+	if (!iph)
+		return -ENOMEM;
+
+	iph->saddr = nc->unc.laddr;
+	iph->daddr = nc->unc.faddr;
+	iph->tos = 0;
+	iph->tot_len = htons(skb->len);
+	iph->ttl = 64;
+	iph->id = 0;
+	iph->frag_off = htons(0x4000);
+	iph->version = 4;
+	iph->ihl = 5;
+	iph->protocol = nc->unc.proto;
+
+	ip_send_check(iph);
+
+	return 0;
+}
+
+static int atcp_build_header(struct atcp_protocol *tp, struct sk_buff *skb, __u32 flags, __u8 doff)
+{
+	struct tcphdr *th;
+	struct atcp_option_nop *nop;
+	struct atcp_option_timestamp *ts;
+
+	nop = (struct atcp_option_nop *)skb_push(skb, sizeof(struct atcp_option_nop));
+	nop->kind = 1;
+	nop = (struct atcp_option_nop *)skb_push(skb, sizeof(struct atcp_option_nop));
+	nop->kind = 1;
+
+	ts = (struct atcp_option_timestamp *)skb_push(skb, sizeof(struct atcp_option_timestamp));
+	ts->kind = atcp_supported_options[TCP_OPT_TS].kind;
+	ts->length = atcp_supported_options[TCP_OPT_TS].length;
+	ts->tsval = htonl(packet_timestamp);
+	ts->tsecr = htonl(tp->tsecr);
+
+	skb->h.th = th = (struct tcphdr *)skb_push(skb, sizeof(struct tcphdr));
+	memset(th, 0, sizeof(struct tcphdr));
+
+#if 0
+	ulog("%s: len:%d head:%p data:%p tail:%p end:%p dev:%s\n",
+	       __func__, skb->len, skb->head, skb->data, skb->tail, skb->end,
+	       skb->dev ? skb->dev->name : "<NULL>");
+#endif
+	th->source = tp->nc->unc.lport;
+	th->dest = tp->nc->unc.fport;
+	th->seq = htonl(tp->snd_nxt);
+	th->ack_seq = htonl(tp->rcv_nxt);
+
+	if (flags & TCP_FLAG_SYN)
+		th->syn = 1;
+	if (flags & TCP_FLAG_ACK)
+		th->ack = 1;
+	if (flags & TCP_FLAG_PSH)
+		th->psh = 1;
+	if (flags & TCP_FLAG_RST)
+		th->rst = 1;
+	if (flags & TCP_FLAG_FIN)
+		th->fin = 1;
+	th->urg = 0;
+	th->urg_ptr = 0;
+	th->window = htons(tp->snd_wnd);
+	//th->window = 0xffff;
+
+	th->doff = 5 + 3 + doff;
+
+	skb->csum = 0;
+	th->check = tcp_v4_check(th, skb->len, tp->nc->unc.laddr, tp->nc->unc.faddr,
+			 csum_partial((char *)th, skb->len, 0));
+
+	TCP_SKB_CB(skb)->seq = tp->snd_nxt;
+	TCP_SKB_CB(skb)->end_seq = tp->snd_nxt + skb->len - (th->doff<<2);
+	TCP_SKB_CB(skb)->ack_seq = tp->rcv_nxt;
+
+	if (skb->len - (th->doff<<2)) {
+		tp->in_flight++;
+		tp->in_flight_bytes += skb->len - (th->doff << 2);
+	}
+	tp->snd_nxt += th->syn + th->fin + skb->len - (th->doff<<2);
+	tp->ack_sent = tp->rcv_nxt;
+
+	return ip_build_header(tp->nc, skb);
+}
+
+static int atcp_send_data(struct atcp_protocol *tp, struct sk_buff *skb, __u32 flags, __u8 doff)
+{
+	int err;
+
+	err = atcp_build_header(tp, skb, flags, doff);
+	if (err) {
+		kfree_skb(skb);
+		return err;
+	}
+	return transmit_data(skb, tp);
+}
+
+static int atcp_send_bit(struct atcp_protocol *tp, __u32 flags)
+{
+	struct sk_buff *skb;
+	int err;
+
+	skb = alloc_skb(MAX_TCP_HEADER, GFP_KERNEL);
+	if (!skb) {
+		err = -ENOMEM;
+		goto err_out_exit;
+	}
+
+	skb->dst = netchannel_route_get(tp->nc);
+	if (!skb->dst) {
+		err = -ENODEV;
+		goto err_out_free;
+	}
+
+	skb_reserve(skb, MAX_TCP_HEADER);
+
+	return atcp_send_data(tp, skb, flags, 0);
+
+err_out_free:
+	kfree_skb(skb);
+err_out_exit:
+	return err;
+}
+
+static int atcp_listen(struct atcp_protocol *tp, struct sk_buff *skb)
+{
+	int err;
+	struct tcphdr *th = skb->h.th;
+
+	if (th->rst)
+		return 0;
+	if (th->ack)
+		return -1;
+
+	if (th->syn) {
+		tp->irs = ntohl(th->seq);
+		tp->rcv_nxt = ntohl(th->seq)+1;
+		get_random_bytes(&tp->iss, sizeof(tp->iss));
+
+		err = atcp_send_bit(tp, TCP_FLAG_SYN|TCP_FLAG_ACK);
+		if (err < 0)
+			return err;
+		atcp_set_state(tp, TCP_SYN_RECV);
+	}
+
+	return 0;
+}
+
+static void atcp_cleanup_queue(struct sk_buff_head *head, __u32 *qlen)
+{
+	struct sk_buff *skb, *n = skb_peek(head);
+
+	if (!n)
+		return;
+
+	do {
+		skb = n->next;
+		__skb_unlink(n, head);
+		if (qlen)
+			*qlen -= n->len;
+		kfree_skb(n);
+		n = skb;
+	} while (n != (struct sk_buff *)head);
+}
+
+static void atcp_check_retransmit_queue(struct atcp_protocol *tp, __u32 ack)
+{
+	struct sk_buff *skb, *n = skb_peek(&tp->retransmit_queue);
+	int removed = 0;
+
+	if (!n)
+		goto out;
+
+	do {
+		__u32 seq, end_seq;
+
+		seq = TCP_SKB_CB(n)->seq;
+		end_seq = TCP_SKB_CB(n)->end_seq;
+
+		if (!seq && !end_seq && n->len)
+			break;
+
+		if (after(end_seq, ack))
+			break;
+		else {
+			struct tcphdr *th = n->h.th;
+			struct iphdr *iph = n->nh.iph;
+			u32 size = ntohs(iph->tot_len) - (iph->ihl<<2) - (th->doff << 2);
+			
+			tp->in_flight--;
+			tp->in_flight_bytes -= size;
+			ulog("%s: ack: %u, snd_una: %u, removing: seq: %u, end_seq: %u, ts: %u.%u, in_flight: %u [%u], dec: %u.\n", 
+					__func__, ack, tp->snd_una, seq, end_seq, n->tstamp.off_sec, n->tstamp.off_usec, 
+					tp->in_flight, tp->in_flight_bytes, size);
+			skb = n->next;
+			__skb_unlink(n, &tp->retransmit_queue);
+			tp->qlen -= n->len;
+			kfree_skb(n);
+			n = skb;
+			removed++;
+
+			if (n != (struct sk_buff *)&tp->retransmit_queue)
+				tp->first_packet_ts = n->tstamp;
+		}
+	} while (n != (struct sk_buff *)&tp->retransmit_queue);
+out:
+	ulog("%s: removed: %d, in_flight: %u [%u], cwnd: %u.\n", __func__, removed, tp->in_flight, tp->in_flight_bytes, tp->snd_cwnd);
+}
+
+static inline int atcp_retransmit_time(struct atcp_protocol *tp)
+{
+	return (after(packet_timestamp, tp->first_packet_ts.off_sec + tp->retransmit_timeout));
+}
+
+static void atcp_retransmit(struct atcp_protocol *tp)
+{
+	struct sk_buff *skb = skb_peek(&tp->retransmit_queue), *nskb;
+	int retransmitted = 0;
+
+	if (tp->state == TCP_CLOSE) {
+		atcp_cleanup_queue(&tp->retransmit_queue, &tp->qlen);
+		return;
+	}
+
+	if (!skb)
+		goto out;
+
+	do {
+		if (after(packet_timestamp, skb->tstamp.off_sec + tp->retransmit_timeout)) {
+			__u32 seq = TCP_SKB_CB(skb)->seq;
+			__u32 end_seq = TCP_SKB_CB(skb)->end_seq;
+
+			ulog("%s: skb: %p, seq: %u, end_seq: %u, ts: %u.%u, time: %u.\n", 
+				__func__, skb, seq, end_seq, skb->tstamp.off_sec, skb->tstamp.off_usec, packet_timestamp);
+
+			if (!seq && !end_seq && skb->len)
+				break;
+
+			nskb = skb_clone(skb, GFP_KERNEL);
+			if (nskb) {
+				transmit_data(nskb, tp);
+				retransmitted++;
+			}
+		} else
+			break;
+	} while ((skb = skb->next) != (struct sk_buff *)&tp->retransmit_queue);
+out:
+	return;
+	//ulog("%s: retransmitted: %d.\n", __func__, retransmitted);
+}
+
+static void skb_queue_order(struct sk_buff *skb, struct sk_buff_head *head)
+{
+	struct sk_buff *next = skb_peek(head);
+	unsigned int nseq = TCP_SKB_CB(skb)->seq;
+	unsigned int nend_seq = TCP_SKB_CB(skb)->end_seq;
+
+	ulog("ofo queue: seq: %u, end_seq: %u.\n", nseq, nend_seq);
+
+	if (!next) {
+		skb_get(skb);
+		__skb_queue_tail(head, skb);
+		goto out;
+	}
+
+	do {
+		unsigned int seq = TCP_SKB_CB(next)->seq;
+		unsigned int end_seq = TCP_SKB_CB(next)->end_seq;
+
+		if (beforeeq(seq, nseq) && aftereq(end_seq, nend_seq)) {
+			ulog("Collapse 1: seq: %u, end_seq: %u removed by seq: %u, end_seq: %u.\n",
+					nseq, nend_seq, seq, end_seq);
+			kfree_skb(skb);
+			skb = NULL;
+			break;
+		}
+
+		if (beforeeq(nseq, seq) && aftereq(nend_seq, end_seq)) {
+			struct sk_buff *prev = next->prev;
+
+			__skb_unlink(next, head);
+
+			ulog("Collapse 2: seq: %u, end_seq: %u removed by seq: %u, end_seq: %u.\n",
+					seq, end_seq, nseq, nend_seq);
+
+			kfree_skb(next);
+			if (prev == (struct sk_buff *)head)
+				break;
+			next = prev;
+			seq = TCP_SKB_CB(next)->seq;
+			end_seq = TCP_SKB_CB(next)->end_seq;
+		}
+		if (after(seq, nseq))
+			break;
+	} while ((next = next->next) != (struct sk_buff *)head);
+
+	if (skb) {
+		ulog("Inserting seq: %u, end_seq: %u.\n", nseq, nend_seq);
+		skb_get(skb);
+		skb_insert(next, skb, head);
+	}
+out:
+	ulog("ofo dump: ");
+	next = (struct sk_buff *)head;
+	while ((next = next->next) != (struct sk_buff *)head) {
+		ulog("%u - %u, ", TCP_SKB_CB(next)->seq, TCP_SKB_CB(next)->end_seq);
+	}
+	ulog("\n");
+}
+
+static void skb_queue_check(struct atcp_protocol *tp, struct sk_buff_head *head)
+{
+	struct sk_buff *next = skb_peek(head);
+
+	if (!next)
+		return;
+
+	do {
+		unsigned int seq = TCP_SKB_CB(next)->seq;
+		unsigned int end_seq = TCP_SKB_CB(next)->end_seq;
+
+		if (before(tp->rcv_nxt, seq))
+			break;
+
+		tp->rcv_nxt = max_t(unsigned int, end_seq, tp->rcv_nxt);
+	} while ((next = next->next) != (struct sk_buff *)head);
+
+	ulog("ACKed: rcv_nxt: %u.\n", tp->rcv_nxt);
+}
+
+static int atcp_syn_sent(struct atcp_protocol *tp, struct sk_buff *skb)
+{
+	struct tcphdr *th = skb->h.th;
+	__u32 seq = htonl(th->seq);
+	__u32 ack = htonl(th->ack_seq);
+#if 0
+	ulog("%s: a: %d, s: %d, ack: %u, seq: %u, iss: %u, snd_nxt: %u, snd_una: %u.\n",
+			__func__, th->ack, th->syn, ack, seq, tp->iss, tp->snd_nxt, tp->snd_una);
+#endif
+	if (th->ack) {
+		if (beforeeq(ack, tp->iss) || after(ack, tp->snd_nxt))
+			return (th->rst)?0:-1;
+		if (between(ack, tp->snd_una, tp->snd_nxt)) {
+			if (th->rst) {
+				atcp_set_state(tp, TCP_CLOSE);
+				return 0;
+			}
+		}
+	}
+
+	if (th->rst)
+		return 0;
+
+	if (th->syn) {
+		tp->rcv_nxt = seq+1;
+		tp->irs = seq;
+		if (th->ack) {
+			tp->snd_una = ack;
+			atcp_check_retransmit_queue(tp, ack);
+		}
+
+		if (after(tp->snd_una, tp->iss)) {
+			atcp_set_state(tp, TCP_ESTABLISHED);
+			tp->seq_read = seq + 1;
+			return atcp_send_bit(tp, TCP_FLAG_ACK);
+		}
+
+		atcp_set_state(tp, TCP_SYN_RECV);
+		tp->snd_nxt = tp->iss;
+		return atcp_send_bit(tp, TCP_FLAG_ACK|TCP_FLAG_SYN);
+	}
+
+	return 0;
+}
+
+static int atcp_syn_recv(struct atcp_protocol *tp, struct sk_buff *skb)
+{
+	struct tcphdr *th = skb->h.th;
+	__u32 ack = ntohl(th->ack_seq);
+
+	if (th->rst) {
+		atcp_set_state(tp, TCP_CLOSE);
+		return 0;
+	}
+
+	if (th->ack) {
+		if (between(ack, tp->snd_una, tp->snd_nxt)) {
+			tp->seq_read = ntohl(th->seq) + 1;
+			atcp_set_state(tp, TCP_ESTABLISHED);
+			return 0;
+		}
+	}
+
+	if (th->fin) {
+		atcp_set_state(tp, TCP_CLOSE_WAIT);
+		return 0;
+	}
+
+	return -1;
+}
+
+static void atcp_process_ack(struct atcp_protocol *tp, struct sk_buff *skb)
+{
+	__u32 ack = TCP_SKB_CB(skb)->ack_seq;
+	struct sk_buff *n = skb_peek(&tp->retransmit_queue);
+
+	if (!n)
+		return;
+
+	do {
+		__u32 ret_end_seq;
+
+		if (!n->h.raw)
+			break;
+		
+		ret_end_seq = TCP_SKB_CB(n)->end_seq;
+		skb = n->next;
+
+		if (before(ret_end_seq, ack)) {
+			__skb_unlink(n, &tp->retransmit_queue);
+			kfree_skb(n);
+		}
+		n = skb;
+	} while (n != (struct sk_buff *)&tp->retransmit_queue);
+}
+
+static int atcp_in_slow_start(struct atcp_protocol *tp)
+{
+	return tp->snd_cwnd * tp->mss <= tp->snd_ssthresh;
+}
+
+static void atcp_congestion(struct atcp_protocol *tp)
+{
+	__u32 min_wind = min_t(unsigned int, tp->snd_cwnd*tp->mss, tp_rwin(tp));
+	tp->snd_ssthresh = max_t(unsigned int, tp->mss * 2, min_wind/2);
+	if (tp->snd_cwnd == 1)
+		return;
+	tp->snd_cwnd >>= 1;
+	tp->cong++;
+}
+
+static int atcp_established(struct atcp_protocol *tp, struct sk_buff *skb)
+{
+	struct tcphdr *th = skb->h.th;
+	int err = -EINVAL;
+	__u32 seq = TCP_SKB_CB(skb)->seq;
+	__u32 end_seq = TCP_SKB_CB(skb)->end_seq;
+	__u32 ack = TCP_SKB_CB(skb)->ack_seq;
+	__u32 rwin = tp_rwin(tp);
+
+	if (before(seq, tp->rcv_nxt)) {
+		err = 0;
+		goto out;
+	}
+
+	if (after(end_seq, tp->rcv_nxt + rwin)) {
+		ulog("%s: 1: seq: %u, size: %u, rcv_nxt: %u, rcv_wnd: %u.\n", 
+				__func__, seq, skb->len, tp->rcv_nxt, rwin);
+		goto out;
+	}
+
+	if (th->rst)
+		goto out;
+
+	ulog("%s: seq: %u, end_seq: %u, ack: %u, snd_una: %u, snd_nxt: %u, snd_wnd: %u, rcv_nxt: %u, rcv_wnd: %u, cwnd: %u.\n",
+			__func__, seq, end_seq, ack, 
+			tp->snd_una, tp->snd_nxt, tp_swin(tp), 
+			tp->rcv_nxt, rwin, tp->snd_cwnd);
+
+	if (between(ack, tp->snd_una, tp->snd_nxt)) {
+		tp->snd_cwnd++;
+		tp->snd_una = ack;
+		atcp_check_retransmit_queue(tp, ack);
+	} else if (before(ack, tp->snd_una)) {
+		ulog("%s: duplicate 3 ack: %u, snd_una: %u, snd_nxt: %u, snd_wnd: %u, snd_wl1: %u, snd_wl2: %u.\n",
+				__func__, ack, tp->snd_una, tp->snd_nxt, tp_swin(tp), tp->snd_wl1, tp->snd_wl2);
+		atcp_congestion(tp);
+		atcp_check_retransmit_queue(tp, ack);
+		return 0;
+	} else if (after(ack, tp->snd_nxt)) {
+		err = atcp_send_bit(tp, TCP_FLAG_ACK);
+		if (err < 0)
+			goto out;
+	}
+
+	if (beforeeq(seq, tp->rcv_nxt) && aftereq(end_seq, tp->rcv_nxt)) {
+		tp->rcv_nxt = end_seq;
+		skb_queue_check(tp, &tp->ofo_queue);
+	} else {
+		/*
+		 * Out of order packet.
+		 */
+		err = 0;
+		goto out;
+	}
+
+	if (!skb->len) {
+		atcp_process_ack(tp, skb);
+	} else {
+		skb_queue_order(skb, &tp->ofo_queue);
+
+		if (atcp_in_slow_start(tp) || ++tp->ack_missed >= 3) {
+			tp->ack_missed = 0;
+			err = atcp_send_bit(tp, TCP_FLAG_ACK);
+			if (err < 0)
+				goto out;
+		}
+	}
+
+	if (before(tp->snd_wl1, seq) || ((tp->snd_wl1 == seq) && beforeeq(tp->snd_wl2, ack))) {
+		tp->snd_wnd = ntohs(th->window);
+		tp->snd_wl1 = seq;
+		tp->snd_wl2 = ack;
+	}
+
+	if (th->fin) {
+		atcp_set_state(tp, TCP_CLOSE_WAIT);
+		err = 0;
+	}
+
+	err = skb->len;
+out:
+	ulog("%s: return: %d.\n", __func__, err);
+	return err;
+}
+
+static int atcp_fin_wait1(struct atcp_protocol *tp, struct sk_buff *skb)
+{
+	int err;
+	struct tcphdr *th = skb->h.th;
+
+	if (th->fin) {
+		if (th->ack) {
+			/* Start time-wait timer... */
+			atcp_set_state(tp, TCP_TIME_WAIT);
+		} else
+			atcp_set_state(tp, TCP_CLOSING);
+		return 0;
+	}
+
+	err = atcp_established(tp, skb);
+	if (err < 0)
+		return err;
+	atcp_set_state(tp, TCP_FIN_WAIT2);
+	return 0;
+}
+
+static int atcp_fin_wait2(struct atcp_protocol *tp, struct sk_buff *skb)
+{
+	struct tcphdr *th = skb->h.th;
+
+	if (th->fin) {
+		/* Start time-wait timer... */
+		return 0;
+	}
+
+	return atcp_established(tp, skb);
+}
+
+static int atcp_close_wait(struct atcp_protocol *tp, struct sk_buff *skb)
+{
+	struct tcphdr *th = skb->h.th;
+
+	if (th->fin)
+		return 0;
+
+	return atcp_established(tp, skb);
+}
+
+static int atcp_closing(struct atcp_protocol *tp, struct sk_buff *skb)
+{
+	int err;
+	struct tcphdr *th = skb->h.th;
+
+	if (th->fin)
+		return 0;
+
+	err = atcp_established(tp, skb);
+	if (err < 0)
+		return err;
+	atcp_set_state(tp, TCP_TIME_WAIT);
+	return 0;
+}
+
+static int atcp_last_ack(struct atcp_protocol *tp, struct sk_buff *skb)
+{
+	struct tcphdr *th = skb->h.th;
+
+	if (th->fin)
+		return 0;
+
+	atcp_set_state(tp, TCP_CLOSE);
+	return 0;
+}
+
+static int atcp_time_wait(struct atcp_protocol *tp, struct sk_buff *skb)
+{
+	return atcp_send_bit(tp, TCP_FLAG_ACK);
+}
+
+static int atcp_close(struct atcp_protocol *tp, struct sk_buff *skb)
+{
+	struct tcphdr *th = skb->h.th;
+
+	atcp_cleanup_queue(&tp->retransmit_queue, &tp->qlen);
+	atcp_cleanup_queue(&tp->ofo_queue, NULL);
+
+	if (!th->rst)
+		return -1;
+	return 0;
+}
+
+static struct state_machine atcp_state_machine[] = {
+	{ .state = 0, .run = NULL},
+	{ .state = TCP_ESTABLISHED, .run = atcp_established, },
+	{ .state = TCP_SYN_SENT, .run = atcp_syn_sent, },
+	{ .state = TCP_SYN_RECV, .run = atcp_syn_recv, },
+	{ .state = TCP_FIN_WAIT1, .run = atcp_fin_wait1, },
+	{ .state = TCP_FIN_WAIT2, .run = atcp_fin_wait2, },
+	{ .state = TCP_TIME_WAIT, .run = atcp_time_wait, },
+	{ .state = TCP_CLOSE, .run = atcp_close, },
+	{ .state = TCP_CLOSE_WAIT, .run = atcp_close_wait, },
+	{ .state = TCP_LAST_ACK, .run = atcp_last_ack, },
+	{ .state = TCP_LISTEN, .run = atcp_listen, },
+	{ .state = TCP_CLOSING, .run = atcp_closing, },
+};
+
+static int atcp_connect(struct netchannel *nc)
+{
+	struct atcp_protocol *tp = atcp_convert(nc->proto);
+	int err;
+	struct sk_buff *skb;
+	struct atcp_option_mss *mss;
+	struct atcp_option_wscale *wscale;
+	struct atcp_option_nop *nop;
+
+	get_random_bytes(&tp->iss, sizeof(tp->iss));
+	tp->snd_wnd = 4096;
+	tp->snd_nxt = tp->iss;
+	tp->rcv_wnd = 0xffff;
+	tp->rwscale = 0;
+	tp->swscale = 0;
+	tp->snd_cwnd = 1;
+	tp->mss = 1460;
+	tp->snd_ssthresh = 0xffff;
+	tp->retransmit_timeout = 10;
+	tp->tsval = packet_timestamp;
+	tp->tsecr = 0;
+	tp->nc = nc;
+	skb_queue_head_init(&tp->retransmit_queue);
+	skb_queue_head_init(&tp->ofo_queue);
+
+	skb = alloc_skb(MAX_TCP_HEADER, GFP_KERNEL);
+	if (!skb)
+		return -ENOMEM;
+
+	skb->dst = netchannel_route_get(nc);
+	if (!skb->dst) {
+		kfree_skb(skb);
+		return -ENODEV;
+	}
+
+	skb_reserve(skb, MAX_TCP_HEADER);
+
+	mss = (struct atcp_option_mss *)skb_push(skb, sizeof(struct atcp_option_mss));
+	mss->kind = TCP_OPT_MSS;
+	mss->length = atcp_supported_options[TCP_OPT_MSS].length;
+	mss->mss = htons(tp->mss);
+
+	nop = (struct atcp_option_nop *)skb_push(skb, sizeof(struct atcp_option_nop));
+	nop->kind = 1;
+	
+	wscale = (struct atcp_option_wscale *)skb_push(skb, sizeof(struct atcp_option_wscale));
+	wscale->kind = TCP_OPT_WSCALE;
+	wscale->length = atcp_supported_options[TCP_OPT_WSCALE].length;
+	wscale->wscale = atcp_offer_wscale;
+
+	err = atcp_send_data(tp, skb, TCP_FLAG_SYN, skb->len/4);
+	if (err < 0)
+		return err;
+	atcp_set_state(tp, TCP_SYN_SENT);
+	return 0;
+}
+
+static int atcp_parse_options(struct atcp_protocol *tp, struct sk_buff *skb)
+{
+	struct tcphdr *th = skb->h.th;
+	int optsize = (th->doff<<2) - sizeof(struct tcphdr);
+	__u8 *opt = (__u8 *)skb->h.raw + sizeof(struct tcphdr);
+	int err = 0;
+
+	if (optsize < 0)
+		return -EINVAL;
+
+	while (optsize) {
+		__u8 kind = *opt++;
+		__u8 len; 
+
+		if (kind == 1) {
+			optsize--;
+			continue;
+		} else if (kind == 0)
+			break;
+		else
+			len = *opt++;
+
+		//ulog("%s: kind: %u, len: %u, optsize: %d.\n", __func__, kind, len, optsize);
+
+		if (kind < sizeof(atcp_supported_options)/sizeof(atcp_supported_options[0])) {
+			if (optsize < len) {
+				err = -EINVAL;
+				break;
+			}
+			if (atcp_supported_options[kind].callback) {
+				err = atcp_supported_options[kind].callback(tp, skb, opt);
+				if (err)
+					break;
+			}
+		}
+		opt += len - 2;
+		optsize -= len;
+	}
+	return err;
+}
+
+static int atcp_state_machine_run(struct atcp_protocol *tp, struct sk_buff *skb)
+{
+	int err = -EINVAL, broken = 1;
+	struct tcphdr *th = skb->h.th;
+	__u16 rwin = skb_rwin(tp, skb);
+	__u32 seq = TCP_SKB_CB(skb)->seq;
+	__u32 ack = TCP_SKB_CB(skb)->ack_seq;
+
+	ulog("R %u.%u.%u.%u:%u <-> %u.%u.%u.%u:%u : seq: %u, ack: %u, win: %u [%u], doff: %u, "
+			"s: %u, a: %u, p: %u, r: %u, f: %u, len: %u, state: %u, skb: %p.\n",
+		NIPQUAD(tp->nc->unc.laddr), ntohs(tp->nc->unc.lport),
+		NIPQUAD(tp->nc->unc.faddr), ntohs(tp->nc->unc.fport),
+		seq, ack, ntohs(th->window), rwin, th->doff,
+		th->syn, th->ack, th->psh, th->rst, th->fin,
+		skb->len, tp->state, skb);
+
+	tp->rcv_wnd = ntohs(th->window);
+
+	/* Some kind of header prediction. */
+	if ((tp->state == TCP_ESTABLISHED) && (seq == tp->rcv_nxt)) {
+		int sz;
+
+		err = atcp_established(tp, skb);
+		if (err < 0)
+			goto out;
+		sz = err;
+		err = atcp_parse_options(tp, skb);
+		if (err >= 0)
+			err = sz;
+		goto out;
+	}
+
+	err = atcp_parse_options(tp, skb);
+	if (err < 0)
+		goto out;
+	if (err > 0)
+		return atcp_send_bit(tp, TCP_FLAG_ACK);
+
+	if (tp->state == TCP_SYN_SENT) {
+		err = atcp_state_machine[tp->state].run(tp, skb);
+	} else {
+		if (!skb->len && ((!rwin && seq == tp->rcv_nxt) || 
+					(rwin && (aftereq(seq, tp->rcv_nxt) && before(seq, tp->rcv_nxt + rwin)))))
+				broken = 0;
+		else if ((aftereq(seq, tp->rcv_nxt) && before(seq, tp->rcv_nxt + rwin)) &&
+					(aftereq(seq, tp->rcv_nxt) && before(seq+skb->len-1, tp->rcv_nxt + rwin)))
+				broken = 0;
+
+		if (broken && !th->rst) {
+			ulog("R broken: rwin: %u, seq: %u, rcv_nxt: %u, size: %u.\n", 
+					rwin, seq, tp->rcv_nxt, skb->len);
+			return atcp_send_bit(tp, TCP_FLAG_ACK);
+		}
+
+		if (th->rst) {
+			ulog("R broken rst: rwin: %u, seq: %u, rcv_nxt: %u, size: %u.\n", 
+					rwin, seq, tp->rcv_nxt, skb->len);
+			atcp_set_state(tp, TCP_CLOSE);
+			err = 0;
+			goto out;
+		}
+
+		if (th->syn) {
+			ulog("R broken syn: rwin: %u, seq: %u, rcv_nxt: %u, size: %u.\n", 
+					rwin, seq, tp->rcv_nxt, skb->len);
+			goto out;
+		}
+
+		if (!th->ack)
+			goto out;
+
+		err = atcp_state_machine[tp->state].run(tp, skb);
+
+		if (between(ack, tp->snd_una, tp->snd_nxt)) {
+			tp->snd_una = ack;
+			atcp_check_retransmit_queue(tp, ack);
+		}
+
+		if (th->fin && seq == tp->rcv_nxt) {
+			if (tp->state == TCP_LISTEN || tp->state == TCP_CLOSE)
+				return 0;
+			tp->rcv_nxt++;
+			atcp_send_bit(tp, TCP_FLAG_ACK);
+		}
+	}
+
+out:
+#if 0
+	ulog("E %u.%u.%u.%u:%u <-> %u.%u.%u.%u:%u : seq: %u, ack: %u, state: %u, err: %d.\n",
+		NIPQUAD(tp->nc->unc.laddr), ntohs(tp->nc->unc.lport),
+		NIPQUAD(tp->nc->unc.faddr), ntohs(tp->nc->unc.fport),
+		ntohl(th->seq), ntohl(th->ack_seq), tp->state, err);
+#endif
+	if (err < 0) {
+		__u32 flags = TCP_FLAG_RST;
+		if (th->ack) {
+			tp->snd_nxt = ntohl(th->ack_seq);
+		} else {
+			flags |= TCP_FLAG_ACK;
+			tp->snd_nxt = 0;
+			tp->rcv_nxt = ntohl(th->seq) + skb->len;
+		}
+		atcp_set_state(tp, TCP_CLOSE);
+		atcp_send_bit(tp, flags);
+		atcp_cleanup_queue(&tp->retransmit_queue, &tp->qlen);
+	}
+
+	if (atcp_retransmit_time(tp))
+		atcp_retransmit(tp);
+
+	return err;
+}
+
+static int atcp_read_data(struct atcp_protocol *tp, __u8 *buf, unsigned int size)
+{
+	struct sk_buff *skb = skb_peek(&tp->ofo_queue);
+	int read = 0;
+
+	if (!skb)
+		return -EAGAIN;
+
+	ulog("%s: size: %u, seq_read: %u.\n", __func__, size, tp->seq_read);
+
+	while (size && (skb != (struct sk_buff *)&tp->ofo_queue)) {
+		__u32 seq = TCP_SKB_CB(skb)->seq;
+		__u32 end_seq = TCP_SKB_CB(skb)->end_seq;
+		unsigned int sz, data_size, off, len;
+		struct sk_buff *next = skb->next;
+
+		if (after(tp->seq_read, end_seq)) {
+			ulog("Impossible: skb: seq: %u, end_seq: %u, seq_read: %u.\n",
+					seq, end_seq, tp->seq_read);
+
+			__skb_unlink(skb, &tp->ofo_queue);
+			kfree_skb(skb);
+
+			skb = next;
+			continue;
+		}
+
+		if (before(tp->seq_read, seq))
+			break;
+
+		off = tp->seq_read - seq;
+		data_size = skb->len - off;
+		sz = min_t(unsigned int, size, data_size);
+
+		ulog("Copy: seq_read: %u, seq: %u, end_seq: %u, size: %u, off: %u, data_size: %u, sz: %u, read: %d.\n",
+				tp->seq_read, seq, end_seq, size, off, data_size, sz, read);
+
+		len = sz;
+		while (len) {
+			unsigned int copied = sz - len;
+			
+			len = copy_to_user(&buf[copied], skb->data + off + copied, len);
+		}
+
+		buf += sz;
+		read += sz;
+
+		tp->seq_read += sz;
+
+		if (aftereq(tp->seq_read, end_seq)) {
+			ulog("Unlinking: skb: seq: %u, end_seq: %u, seq_read: %u.\n",
+					seq, end_seq, tp->seq_read);
+
+			__skb_unlink(skb, &tp->ofo_queue);
+			kfree_skb(skb);
+		}
+
+		skb = next;
+	}
+
+	return read;
+}
+
+static int atcp_process_in(struct netchannel *nc, void *buf, unsigned int size)
+{
+	struct atcp_protocol *tp = atcp_convert(nc->proto);
+	struct tcphdr *th;
+	struct iphdr *iph;
+	struct sk_buff *skb;
+	int err = 0;
+	unsigned int read = 0, timeout = HZ;
+
+	while (size) {
+		unsigned int tm = timeout, len;
+#if 0
+		if (skb_queue_empty(&nc->recv_queue) && read)
+			break;
+#endif
+		skb = netchannel_get_skb(nc, &tm, &err);
+		if (!skb) 
+			break;
+
+		iph = skb->nh.iph;
+		th = skb->h.th;
+
+		skb_pull(skb, (th->doff<<2) + (iph->ihl<<2));
+		len = skb->len;
+
+		ulog("\n%s: skb: %p, data_size: %u.\n", __func__, skb, skb->len);
+
+		TCP_SKB_CB(skb)->seq = ntohl(th->seq);
+		TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(skb)->seq + skb->len;
+		TCP_SKB_CB(skb)->ack_seq = ntohl(th->ack_seq);
+
+		err = atcp_state_machine_run(tp, skb);
+		if (err <= 0) {
+			kfree_skb(skb);
+			break;
+		}
+
+		if (len) {
+			err = atcp_read_data(tp, buf, size);
+
+			if (err > 0) {
+				size -= err;
+				buf += err;
+				read += err;
+			}
+		}
+
+		kfree_skb(skb);
+	}
+
+	if (atcp_retransmit_time(tp))
+		atcp_retransmit(tp);
+
+	return read;
+}
+
+static int atcp_can_send(struct atcp_protocol *tp)
+{
+	__u32 can_send = tp->snd_cwnd > tp->in_flight;
+
+	ulog("%s: swin: %u, rwin: %u, cwnd: %u, in_flight: %u [%u], ssthresh: %u, qlen: %u, ss: %d.\n", 
+			__func__, tp_swin(tp), tp_rwin(tp), tp->snd_cwnd, tp->in_flight, tp->in_flight_bytes, 
+			tp->snd_ssthresh, tp->qlen, atcp_in_slow_start(tp));
+
+	if (can_send) {
+		can_send = tp->in_flight_bytes < tp_rwin(tp);
+	}
+	return can_send;
+}
+
+static int atcp_transmit_combined(struct netchannel *nc, void *buf, unsigned int data_size)
+{
+	struct atcp_protocol *tp = atcp_convert(nc->proto);
+	struct sk_buff *skb;
+	int err = 0;
+	unsigned int copy, total = 0;
+	
+	while (data_size) {
+		skb = skb_peek_tail(&tp->retransmit_queue);
+		if (!skb || !skb_tailroom(skb)) {
+			skb = alloc_skb(tp->mss, GFP_KERNEL);
+			if (!skb) {
+				err = -ENOMEM;
+				goto out;
+			}
+
+			skb->dst = netchannel_route_get(nc);
+			if (!skb->dst) {
+				err = -ENODEV;
+				kfree_skb(skb);
+				goto out;
+			}
+			skb_reserve(skb, MAX_TCP_HEADER);
+
+			__skb_queue_tail(&tp->retransmit_queue, skb);
+
+			tp->qlen += skb_tailroom(skb);
+			ulog("%s: queued skb: %p, size: %u, tail_len: %u.\n", 
+					__func__, skb, skb->len, skb_tailroom(skb));
+		}
+
+		copy = min_t(unsigned int, skb_tailroom(skb), data_size);
+		memcpy(skb_put(skb, copy), buf, copy);
+		buf += copy;
+		data_size -= copy;
+		total += copy;
+		
+		ulog("%s: skb: %p, copy: %u, total: %u, data_size: %u, skb_size: %u, tail_len: %u.\n", 
+				__func__, skb, copy, total, data_size, skb->len, skb_tailroom(skb));
+
+		if (!skb_tailroom(skb)) {
+			struct sk_buff *nskb;
+
+			err = atcp_build_header(tp, skb, TCP_FLAG_PSH|TCP_FLAG_ACK, 0);
+			if (err) {
+				kfree_skb(skb);
+				goto out;
+			}
+
+			nskb = skb_clone(skb, GFP_KERNEL);
+			if (nskb) {
+				err = transmit_data(nskb, tp);
+				if (err)
+					goto out;
+			}
+		}
+	}
+	err = total;
+
+out:
+	return err;
+}
+
+static int atcp_transmit_data(struct netchannel *nc, void *buf, unsigned int data_size)
+{
+	struct atcp_protocol *tp = atcp_convert(nc->proto);
+	struct sk_buff *skb, *nskb;
+	unsigned int size;
+	int err, sent = 0;
+
+	while (data_size) {
+		size = min_t(unsigned int, tp->mss, data_size + MAX_TCP_HEADER);
+
+		skb = alloc_skb(size, GFP_KERNEL);
+		if (!skb) {
+			sent = -ENOMEM;
+			break;
+		}
+
+		skb->dst = netchannel_route_get(nc);
+		if (!skb->dst) {
+			kfree_skb(skb);
+			sent = -ENODEV;
+			break;
+		}
+		skb_reserve(skb, MAX_TCP_HEADER);
+		size -= MAX_TCP_HEADER;
+
+		copy_from_user(skb_put(skb, size), buf, size);
+		
+		err = atcp_build_header(tp, skb, TCP_FLAG_PSH|TCP_FLAG_ACK, 0);
+		if (err) {
+			kfree_skb(skb);
+			sent = err;
+			break;
+		}
+
+		__skb_queue_tail(&tp->retransmit_queue, skb);
+		tp->qlen += skb->len;
+		ulog("%s: queued: skb: %p, size: %u, qlen: %u, data_size: %u, send_size: %u.\n", 
+				__func__, skb, skb->len, tp->qlen, data_size, size);
+
+		nskb = skb_clone(skb, GFP_KERNEL);
+		if (!nskb) {
+			sent = -ENOMEM;
+			break;
+		}
+
+		err = transmit_data(nskb, tp);
+		if (err) {
+			sent = err;
+			break;
+		}
+
+		buf += size;
+		data_size -= size;
+		sent += size;
+	}
+
+	return sent;
+}
+
+static int atcp_process_out(struct netchannel *nc, void *buf, unsigned int data_size)
+{
+	struct atcp_protocol *tp = atcp_convert(nc->proto);
+	int ret = 0;
+
+	if (tp->state == TCP_ESTABLISHED) {
+#if 0
+		if (tp->qlen + data_size > atcp_max_qlen)
+			return -ENOMEM;
+#endif
+		if (atcp_can_send(tp)) {
+			if (atcp_in_slow_start(tp) || data_size + MAX_TCP_HEADER > tp->mss)
+				ret = atcp_transmit_data(nc, buf, data_size);
+			else
+				ret = atcp_transmit_combined(nc, buf, data_size);
+		}
+	}
+
+	if (++tp->sent_without_reading >= 1) {
+		struct sk_buff *skb;
+		unsigned int tm = HZ;
+		int err = 0;
+
+		do {
+			if ((tp->state == TCP_ESTABLISHED) && atcp_can_send(tp))
+				tm = 0;
+			skb = netchannel_get_skb(nc, &tm, &err);
+			if (skb) {
+				struct tcphdr *th;
+				struct iphdr *iph;
+				
+				iph = skb->nh.iph;
+				th = skb->h.th;
+
+				skb_pull(skb, (th->doff<<2) + (iph->ihl<<2));
+
+				ulog("\n%s: skb: %p, data_size: %u.\n", __func__, skb, skb->len);
+
+				TCP_SKB_CB(skb)->seq = ntohl(th->seq);
+				TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(skb)->seq + skb->len;
+				TCP_SKB_CB(skb)->ack_seq = ntohl(th->ack_seq);
+
+				atcp_state_machine_run(tp, skb);
+				kfree_skb(skb);
+				tp->sent_without_reading--;
+			} else
+				break;
+		} while (tp->sent_without_reading);
+
+		tp->sent_without_reading = 0;
+	}
+	
+	return ret;
+}
+
+static int atcp_destroy(struct netchannel *nc)
+{
+	struct atcp_protocol *tp = atcp_convert(nc->proto);
+
+	if (tp->state == TCP_SYN_RECV ||
+			tp->state == TCP_ESTABLISHED || 
+			tp->state == TCP_FIN_WAIT1 ||
+			tp->state == TCP_FIN_WAIT2 ||
+			tp->state == TCP_CLOSE_WAIT)
+		atcp_send_bit(tp, TCP_FLAG_RST);
+
+	atcp_set_state(tp, TCP_CLOSE);
+	atcp_cleanup_queue(&tp->retransmit_queue, &tp->qlen);
+	atcp_cleanup_queue(&tp->ofo_queue, NULL);
+	return 0;
+}
+
+struct common_protocol atcp_common_protocol = {
+	.size		= sizeof(struct atcp_protocol),
+	.connect	= &atcp_connect,
+	.process_in	= &atcp_process_in,
+	.process_out	= &atcp_process_out,
+	.destroy	= &atcp_destroy,
+};

-- 
	Evgeniy Polyakov
