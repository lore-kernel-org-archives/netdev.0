From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [Announce] Netchannels ported to the latest git tree. Gigabit benchmark. Complete rout.
Date: Thu, 26 Oct 2006 14:51:51 +0400
Message-ID: <20061026105151.GA8325@2ka.mipt.ru>
References: <20061020095304.GA22445@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="DocE+STaALJfprDB"
Cc: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:21661 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1423233AbWJZKwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 06:52:24 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20061020095304.GA22445@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--DocE+STaALJfprDB
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline

On Fri, Oct 20, 2006 at 01:53:05PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> Netchannel [1] is pure bridge between low-level hardware and user, without any
> special protocol processing involved between them.
> Users are not limited to userspace only - I will use this netchannel
> infrastructure for fast NAT implementation, which is purely kernelspace user 
> (although it is possible to create NAT in userspace, but price of the 
> kernelspace board crossing is too high, which only needs to change some fields 
> in the header and recalculate checksum).
> Userspace network stack [2] is another user of the new netchannel subsystem.
> 
> Current netchannel version supports data transfer using copy*user().

Performance graph (speed and CPU usage) attached.
Benchmark uses 128 bytes sending/receiving per syscall (no latency
checks, only throughput.

MB and KB mean not 1000, but 1024.

Receiving is about 8 MB/sec faster.
Receiving CPU usage is 3 times less (90% socket code vs. 30%
netchannels+unetstack).

Sending is 10 MB/sec faster.
Sending CPU usage is 5 times less (upto 50% vs. upto 10%).

Number of syscalls is about 10 times less for netchannels.

Hardware.
System 1.
 Netchannel kernel (2.6.19-rc3-git) or 
   vanilla 2.6.19-rc3/2.6.18-1.2200.fc5.
 amd64 athlon 3500+ cpu
 1gb ram
 r8169 nic

System 2.
 2.6.17-2-686 debian etch
 intel core duo 3.40GHz
 2 gb ram
 Marvell Technology Group Ltd. 88E8053 PCI-E Gigabit Ethernet Controller
	 (sky2 driven)

All software used in tests (tcp_client.c/tcp_test.c and userspace
network stack) can be found on project's hompages (userspace network stack
requires increased window scaling factor than default).

Consider for inclusion netchannel subsystem.

1. Netchannels homepage.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=netchannel

2. Userspace network stack homapage.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=unetstack

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/arch/i386/kernel/syscall_table.S b/arch/i386/kernel/syscall_table.S
index 2697e92..3231b22 100644
--- a/arch/i386/kernel/syscall_table.S
+++ b/arch/i386/kernel/syscall_table.S
@@ -319,3 +319,4 @@ ENTRY(sys_call_table)
 	.long sys_move_pages
 	.long sys_getcpu
 	.long sys_epoll_pwait
+	.long sys_netchannel_control
diff --git a/arch/x86_64/ia32/ia32entry.S b/arch/x86_64/ia32/ia32entry.S
index b4aa875..d35d4d8 100644
--- a/arch/x86_64/ia32/ia32entry.S
+++ b/arch/x86_64/ia32/ia32entry.S
@@ -718,4 +718,5 @@ #endif
 	.quad compat_sys_vmsplice
 	.quad compat_sys_move_pages
 	.quad sys_getcpu
+	.quad sys_netchannel_control
 ia32_syscall_end:		
diff --git a/include/asm-i386/unistd.h b/include/asm-i386/unistd.h
index beeeaf6..33242f8 100644
--- a/include/asm-i386/unistd.h
+++ b/include/asm-i386/unistd.h
@@ -325,10 +325,11 @@ #define __NR_vmsplice		316
 #define __NR_move_pages		317
 #define __NR_getcpu		318
 #define __NR_epoll_pwait	319
+#define __NR_netchannel_control	320
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 320
+#define NR_syscalls 321
 #include <linux/err.h>
 
 /*
diff --git a/include/asm-x86_64/unistd.h b/include/asm-x86_64/unistd.h
index 777288e..16f1aac 100644
--- a/include/asm-x86_64/unistd.h
+++ b/include/asm-x86_64/unistd.h
@@ -619,8 +619,10 @@ #define __NR_vmsplice		278
 __SYSCALL(__NR_vmsplice, sys_vmsplice)
 #define __NR_move_pages		279
 __SYSCALL(__NR_move_pages, sys_move_pages)
+#define __NR_netchannel_control	280
+__SYSCALL(__NR_netchannel_control, sys_netchannel_control)
 
-#define __NR_syscall_max __NR_move_pages
+#define __NR_syscall_max __NR_netchannel_control
 
 #ifdef __KERNEL__
 #include <linux/err.h>
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
index 9264139..5b1c042 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -707,6 +707,15 @@ extern int		dev_hard_start_xmit(struct s
 
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
 extern int		netdev_budget;
 
 /* Called by rtnetlink.c:rtnl_unlock() */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 85577a4..ff2bdf9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -338,6 +338,18 @@ static inline struct sk_buff *alloc_skb(
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
index 1912c6c..a42e608 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -605,4 +605,6 @@ asmlinkage long sys_getcpu(unsigned __us
 
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
 
+asmlinkage long sys_netchannel_control(void __user *arg);
+
 #endif
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 0e53314..275e3e8 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -134,9 +134,12 @@ cond_syscall(sys_mincore);
 cond_syscall(sys_madvise);
 cond_syscall(sys_mremap);
 cond_syscall(sys_remap_file_pages);
+
 cond_syscall(compat_sys_move_pages);
 
 /* block-layer dependent */
 cond_syscall(sys_bdflush);
 cond_syscall(sys_ioprio_set);
 cond_syscall(sys_ioprio_get);
+
+cond_syscall(sys_netchannel_control);
diff --git a/net/Kconfig b/net/Kconfig
index a81aca4..db801d1 100644
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
 config NETWORK_SECMARK
 	bool "Security Marking"
 	help
diff --git a/net/core/Makefile b/net/core/Makefile
index 1195680..442b83f 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -16,5 +16,6 @@ obj-$(CONFIG_NET_DIVERT) += dv.o
 obj-$(CONFIG_NET_PKTGEN) += pktgen.o
 obj-$(CONFIG_WIRELESS_EXT) += wireless.o
 obj-$(CONFIG_NETPOLL) += netpoll.o
+obj-$(CONFIG_NETCHANNEL) += netchannel.o
 obj-$(CONFIG_NET_DMA) += user_dma.o
 obj-$(CONFIG_FIB_RULES) += fib_rules.o
diff --git a/net/core/dev.c b/net/core/dev.c
index 81c426a..33ba1ff 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1808,6 +1808,10 @@ #endif
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
index 0000000..2c5fe34
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
+static int netchannel_get_sb(struct file_system_type *fs_type, 
+		int flags, const char *dev_name, void *data, struct vfsmount *mnt)
+{
+	/* So original magic... */
+	return get_sb_pseudo(fs_type, "netchannel", NULL, 0xabcdef, mnt);
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
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
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

--DocE+STaALJfprDB
Content-Type: image/png
Content-Disposition: attachment; filename="atcp_speed.png"
Content-Transfer-Encoding: base64

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
QmCC

--DocE+STaALJfprDB--
