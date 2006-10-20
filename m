From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Announce] New netchannels implementation. Userspace network stack.
Date: Fri, 20 Oct 2006 16:20:23 +0400
Message-ID: <20061020122023.GA2713@2ka.mipt.ru>
References: <20061020095304.GA22445@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:23005 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S2992608AbWJTMUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 08:20:20 -0400
Received: from 2ka.mipt.ru (localhost [127.0.0.1])
	by 2ka.mipt.ru (8.13.8/8.13.8) with ESMTP id k9KCKO1f003868
	for <netdev@vger.kernel.org>; Fri, 20 Oct 2006 16:20:24 +0400
Received: (from johnpol@localhost)
	by 2ka.mipt.ru (8.13.8/8.12.1/Submit) id k9KCKNwq003794
	for netdev@vger.kernel.org; Fri, 20 Oct 2006 16:20:23 +0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20061020095304.GA22445@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Netchannels implementation.

Patch is against 2.6.17-rc3 tree. If there will be any interest to have
such subsystem in vanila tree I will regenerate patch against
appropriate git tree.

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
index 0000000..23e9f1e
--- /dev/null
+++ b/include/linux/netchannel.h
@@ -0,0 +1,88 @@
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
+	NETCHANNEL_RECV,
+	NETCHANNEL_SEND,
+};
+
+enum netchannel_type {
+	NETCHANNEL_COPY_USER = 0,
+	NETCHANNEL_NTA,
+};
+
+struct unetchannel
+{
+	__u32			faddr, laddr;		/* foreign/local hashes */
+	__u16			fport, lport;		/* foreign/local ports */
+	__u8			proto;			/* IP protocol number */
+	__u8			copy:3,			/* Netchannel type: copy_to_user, mmap or something */
+				state:5;		/* Some initial state */
+	__u8			memory_limit_order;	/* Memor limit order */
+	__u8			init_stat_work;		/* Start statistic dumping */
+};
+
+struct unetchannel_control
+{
+	struct unetchannel	unc;
+	__u32			cmd;
+	__u16			len, header_len;
+	__u32			flags;
+	__u32			timeout;
+	int			fd;
+};
+
+#ifdef __KERNEL__
+
+struct netchannel
+{
+	struct rb_node		netchannel_node;
+	atomic_t		refcnt;
+	struct rcu_head		rcu_head;
+	struct unetchannel	unc;
+	unsigned long		hit;
+
+	struct page *		(*nc_alloc_page)(unsigned int size);
+	void			(*nc_free_page)(struct page *page);
+	int			(*nc_recv_data)(struct netchannel *, unsigned int *timeout, __u16 *len, void __user *arg);
+	int			(*nc_send_data)(struct netchannel *, unsigned int *timeout, __u16 len, __u16 header_len, void __user *arg);
+
+	struct sk_buff_head 	recv_queue;
+	wait_queue_head_t	wait;
+
+	unsigned long		qlen;
+
+	struct work_struct	work;
+
+	struct dst_entry	*dst;
+};
+
+#define NETCHANNEL_MAX_ORDER	31
+#define NETCHANNEL_MIN_ORDER	PAGE_SHIFT
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
index 0000000..d93bfce
--- /dev/null
+++ b/net/core/netchannel.c
@@ -0,0 +1,897 @@
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
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/mount.h>
+#include <linux/skbuff.h>
+#include <linux/highmem.h>
+#include <linux/workqueue.h>
+#include <linux/rbtree.h>
+#include <linux/netfilter.h>
+#include <linux/netchannel.h>
+
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+
+#include <net/route.h>
+#include <net/ip.h>
+
+#include <linux/netdevice.h>
+
+#include <asm/uaccess.h>
+
+static struct rb_root netchannel_root = RB_ROOT;
+static kmem_cache_t *netchannel_cache;
+static DEFINE_MUTEX(netchannel_tree_lock);
+
+static struct super_block *netchannel_get_sb(struct file_system_type *fs_type, 
+		int flags, const char *dev_name, void *data)
+{
+	/* So original magic... */
+	return get_sb_pseudo(fs_type, "netchannel", NULL, 0xabcdef);	
+}
+
+static struct file_system_type netchannel_fs = {
+	.name		= "netchannel",
+	.get_sb		= netchannel_get_sb,
+	.kill_sb	= kill_anon_super,
+};
+
+static struct vfsmount *netchannel_mnt;
+
+static inline int netchannel_compare(struct unetchannel *unc1, struct unetchannel *unc2)
+{
+	u32 ports1, ports2;
+	u64 addrs1, addrs2;
+
+	ports1 = unc1->fport;
+	ports1 = (ports1 << 16) | unc1->lport;
+	ports2 = unc2->fport;
+	ports2 = (ports2 << 16) | unc2->lport;
+
+	addrs1 = unc1->faddr;
+	addrs1 = (addrs1 << 16) | unc1->laddr;
+	addrs2 = unc2->faddr;
+	addrs2 = (addrs2 << 16) | unc2->laddr;
+
+	if (unc1->proto > unc2->proto)
+		return 1;
+	if (unc1->proto < unc2->proto)
+		return -1;
+
+	if (ports1 > ports2)
+		return 1;
+	if (ports1 < ports2)
+		return -1;
+	
+	if (addrs1 > addrs2)
+		return 1;
+	if (addrs1 < addrs2)
+		return -1;
+
+	return 0;
+}
+
+static struct netchannel *netchannel_search(struct unetchannel *unc)
+{
+	struct rb_node *node = netchannel_root.rb_node;
+	struct netchannel *nc, *ret = NULL;
+	int cmp;
+
+	while (node) {
+		nc = rb_entry(node, struct netchannel, netchannel_node);
+		
+		cmp = netchannel_compare(&nc->unc, unc);
+		if (cmp > 0)
+			node = node->rb_right;
+		else if (cmp < 0)
+			node = node->rb_left;
+		else {
+			ret = nc;
+			break;
+		}
+	}
+
+	return ret;
+}
+
+static inline void netchannel_dump_info(struct netchannel *nc, char *prefix, int err)
+{
+	printk(KERN_NOTICE "netchannel: %s %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, "
+			"proto: %u, copy: %u, state: %u, order: %u [%u], hit: %lu, err: %d, qlen: %lu.\n",
+			prefix, NIPQUAD(nc->unc.laddr), ntohs(nc->unc.lport), NIPQUAD(nc->unc.faddr), ntohs(nc->unc.fport), 
+			nc->unc.proto, nc->unc.copy, nc->unc.state, nc->unc.memory_limit_order, 
+			(1<<nc->unc.memory_limit_order), nc->hit, err, nc->qlen);
+}
+
+static void netchannel_free_rcu(struct rcu_head *rcu)
+{
+	struct netchannel *nc = container_of(rcu, struct netchannel, rcu_head);
+
+	skb_queue_purge(&nc->recv_queue);
+	dst_release(nc->dst);
+	
+	netchannel_dump_info(nc, "cleanup", 0);
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
+	if (atomic_dec_and_test(&nc->refcnt)) {
+		netchannel_dump_info(nc, "put", 0);
+		call_rcu(&nc->rcu_head, &netchannel_free_rcu);
+	}
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
+static struct dst_entry *netchannel_route_get_raw(struct netchannel *nc)
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
+static struct dst_entry *netchannel_route_get(struct netchannel *nc)
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
+	int err;
+	struct sk_buff *skb = NULL;
+	unsigned int size, pnum, i;
+
+	skb = alloc_skb(header_size, gfp_mask);
+	if (!skb)
+		return NULL;
+
+	rcu_read_lock();
+	nc = netchannel_search(unc);
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
+	rcu_read_unlock();
+	kfree_skb(skb);
+	return NULL;
+}
+
+int netchannel_recv(struct sk_buff *skb)
+{
+	struct netchannel *nc;
+	struct unetchannel unc;
+	int err;
+
+	rcu_read_lock();
+
+	err = netchannel_convert_skb(skb, &unc);
+	if (err)
+		goto unlock;
+
+	nc = netchannel_search(&unc);
+	if (!nc) {
+		err = -ENODEV;
+		goto unlock;
+	}
+
+	nc->hit++;
+#if 1
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
+struct sk_buff *netchannel_get_skb(struct netchannel *nc, unsigned int *timeout, int *error)
+{
+	struct sk_buff *skb = NULL;
+	long tm = *timeout;
+
+	*error = 0;
+
+	while (1) {
+		skb = skb_dequeue(&nc->recv_queue);
+		if (skb)
+			break;
+
+		if (*timeout) {
+			*error = netchannel_wait_for_packet(nc, &tm);
+			if (*error) {
+				*timeout = tm;
+				break;
+			}
+			tm = *timeout;
+		} else {
+			*error = -EAGAIN;
+			break;
+		}
+	}
+
+	if (!skb)
+		skb = skb_dequeue(&nc->recv_queue);
+
+	if (skb)
+		nc->qlen -= skb->len;
+
+	return skb;
+}
+
+static int netchannel_copy_from_user(struct netchannel *nc, unsigned int *timeout, __u16 len, __u16 header_len, void __user *arg)
+{
+	struct sk_buff *skb;
+	int err = -EINVAL;
+	struct dst_entry *dst;
+	struct net_device *dev;
+
+	if (header_len > len)
+		goto err_out_exit;
+
+	dst = netchannel_route_get(nc);
+	if (!dst) {
+		err = -EHOSTUNREACH;
+		goto err_out_exit;
+	}
+
+	dev = dst->dev;
+
+	skb = alloc_skb(len+LL_RESERVED_SPACE(dev), GFP_KERNEL);
+	if (!skb) {
+		err = -ENOMEM;
+		goto err_out_route_put;
+	}
+
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+
+	skb->ip_summed = CHECKSUM_HW;
+
+	err = skb_add_data(skb, arg, len);
+	if (err)
+		goto err_out_free;
+	
+	skb->ip_summed = CHECKSUM_NONE;
+
+	skb->nh.raw = skb->data;
+	skb->h.raw = skb->data + header_len;
+	skb->protocol = htons(ETH_P_IP);
+	skb->dst = dst;
+	skb->dev = dst->dev;
+
+#if defined(NETCHANNEL_DEBUG)
+	if (nc->unc.proto == IPPROTO_TCP) {
+		struct tcphdr *th = skb->h.th;
+
+		printk("S %u.%u.%u.%u:%u <-> %u.%u.%u.%u:%u : seq: %u, ack: %u, win: %u, doff: %u, "
+			"s: %u, a: %u, p: %u, r: %u, f: %u, len: %u, skb: %p, csum: %04x.\n",
+			NIPQUAD(nc->unc.laddr), ntohs(nc->unc.lport),
+			NIPQUAD(nc->unc.faddr), ntohs(nc->unc.fport),
+			ntohl(th->seq), ntohl(th->ack_seq), ntohs(th->window), th->doff,
+			th->syn, th->ack, th->psh, th->rst, th->fin,
+			skb->len, skb, th->check);
+	}
+#endif
+
+	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, skb->dst->dev, dst_output);
+
+err_out_free:
+	kfree_skb(skb);
+	dst = NULL;
+err_out_route_put:
+	dst_release(dst);
+err_out_exit:
+	return err;
+}
+
+static int netchannel_copy_to_user(struct netchannel *nc, unsigned int *timeout, __u16 *len, void __user *arg)
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
+	err = skb_copy_datagram_iovec(skb, 0, &to, copied);
+
+	*len = (err == 0)?copied:0;
+
+	kfree_skb(skb);
+
+	return err;
+}
+
+static int netchannel_copy_user_setup(struct netchannel *nc)
+{
+	nc->nc_recv_data = &netchannel_copy_to_user;
+	nc->nc_send_data = &netchannel_copy_from_user;
+
+	return 0;
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
+	switch (nc->unc.copy) {
+		case NETCHANNEL_COPY_USER:
+			ret = netchannel_copy_user_setup(nc);
+			break;
+		default:
+			ret = -EINVAL;
+			break;
+	}
+
+	return ret;
+}
+
+static void netchannel_work(void *data)
+{
+	struct netchannel *nc = data;
+	
+	netchannel_dump_info(nc, "work", 0);
+	schedule_delayed_work(&nc->work, msecs_to_jiffies(1000*nc->unc.init_stat_work));
+}
+
+static void netchannel_tree_remove(struct netchannel *nc)
+{
+	rb_erase(&nc->netchannel_node, &netchannel_root);
+}
+
+static int netchannel_tree_add(struct netchannel *new)
+{
+	struct rb_node **p = &netchannel_root.rb_node, *parent = NULL;
+	struct netchannel *nc;
+	int err = 0, cmp = 0;
+
+	while (*p) {
+		parent = *p;
+		nc = rb_entry(parent, struct netchannel, netchannel_node);
+
+		cmp = netchannel_compare(&nc->unc, &new->unc);
+		if (cmp > 0)
+			p = &parent->rb_right;
+		else if (cmp < 0)
+			p = &parent->rb_left;
+		else {
+			err = -EEXIST;
+			break;
+		}
+	}
+	if (likely(!err)) {
+		rb_link_node(&new->netchannel_node, parent, p);
+		rb_insert_color(&new->netchannel_node, &netchannel_root);
+	}
+
+	return err;
+}
+
+ssize_t netchannel_read(struct file *file, char __user *buf, size_t size, loff_t *off)
+{
+	struct netchannel *nc = file->private_data;
+	unsigned int timeout = 0;
+	int ret;
+
+	ret = nc->nc_recv_data(nc, &timeout, (__u16 *)&size, buf);
+	if (ret < 0)
+		return ret;
+	return size;
+}
+
+ssize_t netchannel_write(struct file *file, const char __user *buf, size_t size, loff_t *off)
+{
+	return -ENOTSUPP;
+}
+
+unsigned int netchannel_poll(struct file *file, struct poll_table_struct *wait)
+{
+	struct netchannel *nc = file->private_data;
+	unsigned int mask = 0;
+
+	poll_wait(file, &nc->wait, wait);
+	if (!skb_queue_empty(&nc->recv_queue))
+		mask |= POLLIN;
+
+	return mask;
+}
+
+static int netchannel_release(struct inode *inode, struct file *file)
+{
+	struct netchannel *nc = file->private_data;
+
+	mutex_lock(&netchannel_tree_lock);
+	netchannel_tree_remove(nc);
+	mutex_unlock(&netchannel_tree_lock);
+
+	if (nc->unc.init_stat_work) {
+		cancel_rearming_delayed_work(&nc->work);
+		flush_scheduled_work();
+	}
+
+	netchannel_dump_info(nc, "remove", 0);
+	netchannel_put(nc);
+
+	return 0;
+}
+
+static struct file_operations netchannel_fops = {
+	.release	= netchannel_release,
+	.read		= netchannel_read,
+	.poll		= netchannel_poll,
+	.write		= netchannel_write,
+	.owner		= THIS_MODULE,
+};
+
+static struct netchannel *netchannel_search_control(struct unetchannel_control *ctl)
+{
+	struct netchannel *nc;
+
+	if (ctl->fd) {
+		struct file *file;
+		int fput_needed;
+
+		file = fget_light(ctl->fd, &fput_needed);
+		if (!file)
+			return NULL;
+
+		nc = file->private_data;
+
+		fput_light(file, fput_needed);
+
+		if (!nc)
+			return NULL;
+	} else {
+		mutex_lock(&netchannel_tree_lock);
+		nc = netchannel_search(&ctl->unc);
+		if (!nc)
+			goto err_out_unlock;
+
+		netchannel_get(nc);
+		mutex_unlock(&netchannel_tree_lock);
+	}
+
+	return nc;
+
+err_out_unlock:
+	mutex_unlock(&netchannel_tree_lock);
+	return NULL;
+}
+
+static int netchannel_send_data(struct unetchannel_control *ctl, void __user *data)
+{
+	int ret;
+	struct netchannel *nc;
+
+	nc = netchannel_search_control(ctl);
+	if (!nc)
+		return -ENODEV;
+
+	ret = nc->nc_send_data(nc, &ctl->timeout, ctl->len, ctl->header_len, data);
+	
+	if (!ctl->fd)
+		netchannel_put(nc);
+	return ret;
+}
+
+static int netchannel_recv_data(struct unetchannel_control *ctl, void __user *data)
+{
+	int ret;
+	struct netchannel *nc;
+
+	nc = netchannel_search_control(ctl);
+	if (!nc)
+		return -ENODEV;
+
+	ret = nc->nc_recv_data(nc, &ctl->timeout, &ctl->len, data);
+	
+	if (!ctl->fd)
+		netchannel_put(nc);
+	return ret;
+}
+
+static int netchannel_bind_fd(struct netchannel *nc)
+{
+	struct file *file;
+	int fd, ret;
+
+	fd = get_unused_fd();
+	if (fd < 0)
+		return fd;
+
+	file = get_empty_filp();
+	if (!file) {
+		ret = -ENFILE;
+		goto out_put_fd;
+	}
+	
+	netchannel_get(nc);
+
+	file->f_op = &netchannel_fops;
+	file->f_vfsmnt = mntget(netchannel_mnt);
+	file->f_dentry = dget(netchannel_mnt->mnt_root);
+	file->f_mapping = file->f_dentry->d_inode->i_mapping;
+	file->f_mode = FMODE_READ;
+	file->f_flags = O_RDONLY;
+	file->private_data = nc;
+	
+	fd_install(fd, file);
+
+	return fd;
+
+out_put_fd:
+	put_unused_fd(fd);
+	return ret;
+}
+
+static int netchannel_create(struct unetchannel *unc)
+{
+	struct netchannel *nc;
+	int err = -ENOMEM, fd;
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
+	atomic_set(&nc->refcnt, 0);
+	memcpy(&nc->unc, unc, sizeof(struct unetchannel));
+
+	err = netchannel_setup(nc);
+	if (err)
+		goto err_out_free;
+
+	nc->dst = netchannel_route_get_raw(nc);
+	if (!nc->dst) {
+		err = -ENODEV;
+		goto err_out_free;
+	}
+
+	mutex_lock(&netchannel_tree_lock);
+	err = netchannel_tree_add(nc);
+	if (err)
+		goto err_out_unlock;
+	
+	fd = netchannel_bind_fd(nc);
+	if (fd < 0) {
+		err = fd;
+		goto err_out_unlock;
+	}
+	
+	mutex_unlock(&netchannel_tree_lock);
+
+	netchannel_dump_info(nc, "create", err);
+
+	if (nc->unc.init_stat_work) {
+		INIT_WORK(&nc->work, netchannel_work, nc);
+		schedule_delayed_work(&nc->work, msecs_to_jiffies(1000*nc->unc.init_stat_work));
+	}
+
+	return fd;
+
+err_out_unlock:
+	mutex_unlock(&netchannel_tree_lock);
+	dst_release(nc->dst);
+err_out_free:
+	kmem_cache_free(netchannel_cache, nc);
+
+	return err;
+}
+
+asmlinkage long sys_netchannel_control(void __user *arg)
+{
+	struct unetchannel_control ctl;
+	int ret;
+
+	if (copy_from_user(&ctl, arg, sizeof(struct unetchannel_control)))
+		return -EFAULT;
+
+	switch (ctl.cmd) {
+		case NETCHANNEL_CREATE:
+			ret = netchannel_create(&ctl.unc);
+			break;
+		case NETCHANNEL_RECV:
+			ret = netchannel_recv_data(&ctl, arg + sizeof(struct unetchannel_control));
+			break;
+		case NETCHANNEL_SEND:
+			ret = netchannel_send_data(&ctl, arg + sizeof(struct unetchannel_control));
+			break;
+		default:
+			ret = -EINVAL;
+			break;
+	}
+	if (copy_to_user(arg, &ctl, sizeof(struct unetchannel_control)))
+		return -EFAULT;
+
+	return ret;
+}
+
+
+
+static int __init netchannel_init(void)
+{
+	int err;
+	
+	err = register_filesystem(&netchannel_fs);
+	if (err) {
+		printk(KERN_ERR "Failed to register netchannel fs, err: %d.\n", err);
+		return err;
+	}
+
+	netchannel_mnt = kern_mount(&netchannel_fs);
+	if (IS_ERR(netchannel_mnt)) {
+		printk(KERN_ERR "Failed to mount netchannel fs, err: %ld.\n", PTR_ERR(netchannel_mnt));
+		err = PTR_ERR(netchannel_mnt);
+		goto err_out_unregister;
+	}
+
+	netchannel_cache = kmem_cache_create("netchannel", sizeof(struct netchannel), 0, 0,
+			NULL, NULL);
+	if (!netchannel_cache)
+		goto err_out_umount;
+
+	return 0;
+
+err_out_umount:
+	mntput(netchannel_mnt);
+err_out_unregister:
+	unregister_filesystem(&netchannel_fs);
+	printk(KERN_NOTICE "netchannel: failed to initialize tree.\n");
+	return err;
+}
+
+static void __exit netchannel_exit(void)
+{
+	kmem_cache_destroy(netchannel_cache);
+	mntput(netchannel_mnt);
+	unregister_filesystem(&netchannel_fs);
+}
+
+module_init(netchannel_init);
+module_exit(netchannel_exit);


-- 
	Evgeniy Polyakov
