From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [1/1] Netchannel subsyste.
Date: Tue, 16 May 2006 21:34:18 +0400
Message-ID: <20060516173416.GA22552@2ka.mipt.ru>
References: <200605051248.42662.kelly@au.ibm.com> <200605161102.29472.kelly@au.ibm.com> <20060516061909.GA28670@2ka.mipt.ru> <20060515.235712.26771832.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, kelly@au1.ibm.com, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:61926 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932168AbWEPRem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 May 2006 13:34:42 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060515.235712.26771832.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Receiving support.
As proof-of-concept code I created simple copy_to_user() based getting
data callback. Next step is to implement netchannels data allocation
callbacks to get data from mapped userspace area and make get data
callback be similar to ->recvmsg() so all protocol processing happens in
userspace (TCP should start working, now only UDP case) if there is some
interest in it. Patch attached.
There are brief description of netchannel design and implementation,
patches and userspace utility at project's homepage [1].

Thank you.

1. Netchannel project homepage.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=netchannel

Receiving netchannel implementation.

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
index 0000000..e87a148
--- /dev/null
+++ b/include/linux/netchannel.h
@@ -0,0 +1,75 @@
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
+	int			(*nc_read_data)(struct netchannel *, unsigned int *len, void __user *arg);
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
index 0000000..169a764
--- /dev/null
+++ b/net/core/netchannel.c
@@ -0,0 +1,691 @@
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
+	printk(KERN_INFO "netchannel: %s %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, proto: %u, hit: %lu, err: %d.\n",
+			prefix, NIPQUAD(src), sport, NIPQUAD(dst), dport, unc->proto, hit, err);
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
+	skb->h.raw = skb->nh.iph + iph->ihl*4;
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
+			if (ntohs(uh->len) < sizeof(struct udphdr))
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
+
+	skb_queue_tail(&nc->list, skb);
+
+unlock:
+	rcu_read_unlock();
+	return err;
+}
+
+/*
+ * Actually it should be something like recvmsg().
+ */
+static int netchannel_copy_to_user(struct netchannel *nc, unsigned int *len, void __user *arg)
+{
+	unsigned int copied;
+	struct sk_buff *skb;
+	struct iovec to;
+	int err = -EINVAL;
+	
+	to.iov_base = arg;
+	to.iov_len = *len;
+
+	skb = skb_dequeue(&nc->list);
+	if (!skb)
+		return -EAGAIN;
+
+	copied = skb->len;
+	if (copied > *len)
+		copied = *len;
+	
+	if (skb->ip_summed==CHECKSUM_UNNECESSARY) {
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
+	nc->nc_read_data = &netchannel_copy_to_user;
+
+	hlist_add_head_rcu(&nc->node, &bucket->head);
+	err = 0;
+
+out_unlock:
+	mutex_unlock(&bucket->mutex);
+out_exit:
+	netchannel_dump_info_unc(unc, "create", 0, err);
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
+		goto out_unlock;
+
+	ret = nc->nc_read_data(nc, &ctl->len, data);
+
+out_unlock:
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
+		case NETCHANNEL_BIND:
+			ret = netchannel_create(&ctl.unc);
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


-- 
	Evgeniy Polyakov
