From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Network channels.
Date: Sun, 7 Sep 2008 20:45:45 +0400
Message-ID: <20080907164544.GA22577@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:53299 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752110AbYIGQqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Sep 2008 12:46:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

I'm pleased to announce new netchannels release.

Netchannel is a peer-to-peer abstraction, which pushes whole protocol
processing to the end hosts without involving kernel to perform protocol
checks and maintain appropriate states. Because of its archtecture it
allows to be completely protocol-agnostic and maintain single netchannel
storage for effectively any protocol.

Protocol processing was moved to the small and fast userspace network stack [1]

Netchannels feature include:
 * Very high bulk performance with small packets (check userspace network
	stack [1] for more details).
 * Completely lockless netchannel processing (packet queueing and
	netchannel lookup in the global storage are protected by RCU).
 * Unified storage for all kinds of protocols: TCP/UDP, IP/IPv6,
	whatever you decide to implement on top of hardware layer you use.
 * No protocol processing. This is pushed to the peer itself. For
	example to the userspace network stack.
 * Ability to inject packet into the network without root priveledges.

Original idea belongs to Van Jacobson.

This version has a major interface rewrite, unified storage changes and
data queueing redesign. Patch is against Sep 6 vanilla git tree.

TODO list includes:
 * Ability to improve receiving latencies (queue packets from hardware
	interupt handler and not software interrupt).
 * Automatically scale netchannel hash table on demand.

Links.
1. Userspace network stack.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=unetstack

2. Netchannels.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=netchannel

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

dceeb70a6a4f5cd90dbabde78bc543f85ef05860
diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index ffc1bb4..f77e4d6 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -832,4 +832,5 @@ ia32_sys_call_table:
 	.quad sys_dup3			/* 330 */
 	.quad sys_pipe2
 	.quad sys_inotify_init1
+ 	.quad sys_netchannel_create
 ia32_syscall_end:
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index d44395f..3f97ba0 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -332,3 +332,4 @@ ENTRY(sys_call_table)
 	.long sys_dup3			/* 330 */
 	.long sys_pipe2
 	.long sys_inotify_init1
+ 	.long sys_netchannel_create
diff --git a/include/asm-x86/unistd_32.h b/include/asm-x86/unistd_32.h
index d739467..4895385 100644
--- a/include/asm-x86/unistd_32.h
+++ b/include/asm-x86/unistd_32.h
@@ -338,6 +338,7 @@
 #define __NR_dup3		330
 #define __NR_pipe2		331
 #define __NR_inotify_init1	332
+#define __NR_netchannel_create	333
 
 #ifdef __KERNEL__
 
diff --git a/include/asm-x86/unistd_64.h b/include/asm-x86/unistd_64.h
index 3a341d7..fbf5c2f 100644
--- a/include/asm-x86/unistd_64.h
+++ b/include/asm-x86/unistd_64.h
@@ -653,6 +653,8 @@ __SYSCALL(__NR_dup3, sys_dup3)
 __SYSCALL(__NR_pipe2, sys_pipe2)
 #define __NR_inotify_init1			294
 __SYSCALL(__NR_inotify_init1, sys_inotify_init1)
+#define __NR_netchannel_create			295
+__SYSCALL(__NR_netchannel_create, sys_netchannel_create)
 
 
 #ifndef __NO_STUBS
diff --git a/include/linux/netchannel.h b/include/linux/netchannel.h
new file mode 100644
index 0000000..7440c94
--- /dev/null
+++ b/include/linux/netchannel.h
@@ -0,0 +1,94 @@
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
+#define NETCHANNEL_ADDR_SIZE		16
+
+struct netchannel_addr
+{
+	unsigned char			proto;
+	unsigned char			size;
+	unsigned short			port;
+	unsigned char			addr[NETCHANNEL_ADDR_SIZE];
+};
+
+/*
+ * Destination and source addresses/ports are from receiving point ov view, 
+ * i.e. when packet is being received, destination is local address.
+ */
+
+struct netchannel_control
+{
+	struct netchannel_addr		saddr, daddr;
+	__u32				packet_limit;
+};
+
+#ifdef __KERNEL__
+
+#include <linux/rcupdate.h>
+#include <linux/skbuff.h>
+
+#define NETCHANNEL_NUM_PER_PAGE		(PAGE_SIZE / sizeof(void *))
+
+struct netchannel_page
+{
+	void 		*page[NETCHANNEL_NUM_PER_PAGE];
+};
+
+struct netchannel
+{
+	struct rcu_head			rcu_head;
+	struct list_head		entry;
+
+	struct netchannel_control	ctl;
+
+	struct dst_entry 		*dst;
+
+	struct file			*file;
+
+	wait_queue_head_t		wait;
+
+	unsigned int			packet_mask;
+	atomic_t			pos, last_read;
+
+	struct netchannel_page		*l1;
+};
+
+int netchannel_bind_fd(struct netchannel *nc);
+
+void netchannel_free(struct netchannel *nc);
+int netchannel_storage_init(unsigned int num, gfp_t mask);
+void netchannel_storage_exit(void);
+
+struct netchannel *netchannel_search(struct netchannel_addr *a1, struct netchannel_addr *a2);
+int netchannel_add(struct netchannel *nc);
+void netchannel_remove(struct netchannel *nc);
+
+struct dst_entry *netchannel_get_dst_v4(struct netchannel *nc);
+
+int netchannel_user_init(void);
+
+#endif /* __KERNEL__ */
+#endif /* __NETCHANNEL_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 488c56e..2d02e98 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1233,6 +1233,15 @@ extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev,
 					    struct netdev_queue *txq);
 
+#ifdef CONFIG_NETCHANNEL
+extern int netchannel_recv(struct sk_buff *skb);
+#else
+static inline int netchannel_recv(struct sk_buff *skb) 
+{
+	return -1;
+}
+#endif
+
 extern int		netdev_budget;
 
 /* Called by rtnetlink.c:rtnl_unlock() */
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index d6ff145..aceb5a9 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -625,4 +625,6 @@ asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len);
 
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
 
+asmlinkage long sys_netchannel_create(void __user *arg, unsigned int flags);
+
 #endif
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 08d6e1b..835dc5b 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -168,3 +168,5 @@ cond_syscall(compat_sys_timerfd_settime);
 cond_syscall(compat_sys_timerfd_gettime);
 cond_syscall(sys_eventfd);
 cond_syscall(sys_eventfd2);
+
+cond_syscall(sys_netchannel_create);
diff --git a/net/Kconfig b/net/Kconfig
index 7612cc8..b3d6ba9 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -66,6 +66,8 @@ source "net/netlabel/Kconfig"
 
 endif # if INET
 
+source "net/core/netchannel/Kconfig"
+
 config NETWORK_SECMARK
 	bool "Security Marking"
 	help
diff --git a/net/core/Makefile b/net/core/Makefile
index b1332f6..cc0e6a9 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -14,5 +14,6 @@ obj-$(CONFIG_XFRM) += flow.o
 obj-y += net-sysfs.o
 obj-$(CONFIG_NET_PKTGEN) += pktgen.o
 obj-$(CONFIG_NETPOLL) += netpoll.o
+obj-$(CONFIG_NETCHANNEL) += netchannel/
 obj-$(CONFIG_NET_DMA) += user_dma.o
 obj-$(CONFIG_FIB_RULES) += fib_rules.o
diff --git a/net/core/dev.c b/net/core/dev.c
index 60c51f7..f561f33 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2229,6 +2229,10 @@ int netif_receive_skb(struct sk_buff *skb)
 		}
 	}
 
+	ret = netchannel_recv(skb);
+	if (!ret)
+		goto out;
+
 #ifdef CONFIG_NET_CLS_ACT
 	skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
 	if (!skb)
diff --git a/net/core/netchannel/Kconfig b/net/core/netchannel/Kconfig
new file mode 100644
index 0000000..d879111
--- /dev/null
+++ b/net/core/netchannel/Kconfig
@@ -0,0 +1,11 @@
+config NETCHANNEL
+	bool "Network channels"
+	---help---
+	  Network channel is a peer-to-peer abstraction, which allows to create
+	  high performance dataflow between two hosts. 
+	  Main advantages are:
+	  	unified address cache (there is no split to IPv6/IPv4)
+		protocol processing moved to userspace
+		dynamic scalable object storage
+		cache friendly packet storage in single netchannel
+			(allows to reduce skb size)
diff --git a/net/core/netchannel/Makefile b/net/core/netchannel/Makefile
new file mode 100644
index 0000000..75a6897
--- /dev/null
+++ b/net/core/netchannel/Makefile
@@ -0,0 +1 @@
+obj-y += netchannel.o storage.o user.o
diff --git a/net/core/netchannel/netchannel.c b/net/core/netchannel/netchannel.c
new file mode 100644
index 0000000..04a1987
--- /dev/null
+++ b/net/core/netchannel/netchannel.c
@@ -0,0 +1,474 @@
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
+#include <linux/init.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/fs.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/skbuff.h>
+#include <linux/highmem.h>
+#include <linux/netchannel.h>
+#include <linux/rcupdate.h>
+
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+
+#include <net/route.h>
+#include <net/ipv6.h>
+#include <net/ip.h>
+
+static int netchannel_started = 0;
+static struct kmem_cache *netchannel_cache __read_mostly;
+
+static unsigned int netchannel_packet_limit = 262144;
+
+static int netchannel_skb_get_ports(struct sk_buff *skb,
+		struct netchannel_addr *src,
+		struct netchannel_addr *dst)
+{
+	u16 *ports = (u16 *)skb_transport_header(skb);
+
+	src->port = ports[0];
+	dst->port = ports[1];
+
+	return 0;
+}
+
+static int netchannel_convert_skb_ipv6(struct sk_buff *skb,
+		struct netchannel_addr *src,
+		struct netchannel_addr *dst)
+{
+	struct ipv6hdr *hdr;
+	u32 pkt_len;
+
+	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr) + 4))
+		goto err_out_exit;
+
+	hdr = ipv6_hdr(skb);
+	skb->transport_header = skb->network_header + sizeof(*hdr);
+	pkt_len = ntohs(hdr->payload_len);
+
+	/* pkt_len may be zero if Jumbo payload option is present */
+	if (pkt_len || hdr->nexthdr != NEXTHDR_HOP) {
+		if (pkt_len + sizeof(struct ipv6hdr) > skb->len)
+			goto err_out_exit;
+		if (pskb_trim_rcsum(skb, pkt_len + sizeof(struct ipv6hdr)))
+			goto err_out_exit;
+		hdr = ipv6_hdr(skb);
+	}
+
+	if (hdr->nexthdr == NEXTHDR_HOP)
+		goto err_out_exit;
+
+	src->size = dst->size = 16;
+	src->proto = dst->proto = hdr->nexthdr;
+
+	memcpy(src->addr, &hdr->saddr, src->size);
+	memcpy(dst->addr, &hdr->daddr, dst->size);
+
+	switch (hdr->nexthdr) {
+		case NEXTHDR_TCP:
+		case NEXTHDR_UDP:
+			if (netchannel_skb_get_ports(skb, src, dst))
+				goto err_out_exit;
+			break;
+		default:
+			goto err_out_exit;
+	}
+
+	return 0;
+
+err_out_exit:
+	return -1;
+}
+
+static int netchannel_convert_skb_ipv4(struct sk_buff *skb,
+		struct netchannel_addr *src,
+		struct netchannel_addr *dst)
+{
+	struct iphdr *iph;
+	u32 len;
+
+	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+		goto inhdr_error;
+
+	iph = ip_hdr(skb);
+
+	if (iph->ihl < 5 || iph->version != 4)
+		goto inhdr_error;
+
+	if (!pskb_may_pull(skb, ip_hdrlen(skb) - sizeof(struct iphdr) + 4))
+		goto inhdr_error;
+
+	iph = ip_hdr(skb);
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
+	skb->transport_header = skb->network_header + ip_hdrlen(skb);
+
+	src->size = dst->size = 4;
+	src->proto = dst->proto = iph->protocol;
+
+	memcpy(src->addr, &iph->saddr, src->size);
+	memcpy(dst->addr, &iph->daddr, dst->size);
+
+	switch (iph->protocol) {
+		case IPPROTO_TCP:
+		case IPPROTO_UDP:
+			if (netchannel_skb_get_ports(skb, src, dst))
+				goto inhdr_error;
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
+static int netchannel_convert_skb(struct sk_buff *skb,
+		struct netchannel_addr *src,
+		struct netchannel_addr *dst)
+{
+	if (skb->pkt_type == PACKET_OTHERHOST)
+		return -1;
+
+	switch (ntohs(skb->protocol)) {
+		case ETH_P_IP:
+			return netchannel_convert_skb_ipv4(skb, src, dst);
+		case ETH_P_IPV6:
+			return netchannel_convert_skb_ipv6(skb, src, dst);
+		default:
+			return -1;
+	}
+}
+
+static int netchannel_queue_packet(struct netchannel *nc, struct sk_buff *skb)
+{
+	int pos, slot, idx, err = -1, max_iter = 10;
+	unsigned long res;
+	struct netchannel_page *l1;
+
+	pos = atomic_read(&nc->pos);
+
+	while (max_iter-- >= 0) {
+		pos &= nc->ctl.packet_limit - 1;
+		slot = pos / NETCHANNEL_NUM_PER_PAGE;
+		idx = pos % NETCHANNEL_NUM_PER_PAGE;
+
+		l1 = nc->l1->page[slot];
+
+		res = (unsigned long)cmpxchg(&l1->page[idx], 0, (unsigned long)skb);
+		if (!res) {
+			atomic_inc(&nc->pos);
+			err = 0;
+			break;
+		}
+
+		pos++;
+	}
+
+	return err;
+}
+
+int netchannel_recv(struct sk_buff *skb)
+{
+	struct netchannel *nc;
+	struct netchannel_addr src, dst;
+	int err;
+
+	if (unlikely(!netchannel_started))
+		return -1;
+
+	err = netchannel_convert_skb(skb, &src, &dst);
+	if (err)
+		goto err_out_exit;
+
+	rcu_read_lock();
+	nc = netchannel_search(&dst, &src);
+	if (!nc) {
+		err = -ENODEV;
+		goto err_out_unlock;
+	}
+
+	err = netchannel_queue_packet(nc, skb);
+	if (err)
+		goto err_out_unlock;
+
+	rcu_read_unlock();
+
+	return 0;
+
+err_out_unlock:
+	rcu_read_unlock();
+err_out_exit:
+	return err;
+}
+
+static int netchannel_ip_route_output_flow(struct rtable **rp, struct flowi *flp, int flags)
+{
+	int err;
+
+	err = __ip_route_output_key(&init_net, rp, flp);
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
+struct dst_entry *route_get_raw(u32 saddr, u32 daddr, u16 sport, u16 dport, u8 proto)
+{
+	struct rtable *rt;
+	struct flowi fl = { .oif = 0,
+			    .nl_u = { .ip4_u =
+				      { .saddr = saddr,
+					.daddr = daddr,
+					.tos = 0 } },
+			    .proto = proto,
+			    .uli_u = { .ports =
+				       { .sport = sport,
+					 .dport = dport } } };
+
+	if (netchannel_ip_route_output_flow(&rt, &fl, 0))
+		goto no_route;
+	return dst_clone(&rt->u.dst);
+
+no_route:
+	return NULL;
+}
+
+struct dst_entry *route_get(struct dst_entry *dst)
+{
+	if (dst && dst->obsolete && dst->ops->check(dst, 0) == NULL) {
+		dst_release(dst);
+		return NULL;
+	}
+	return dst_clone(dst);
+}
+
+struct dst_entry *netchannel_get_dst_v4(struct netchannel *nc)
+{
+	struct dst_entry *dst;
+
+	dst = route_get(nc->dst);
+	if (!dst) {
+		u32 saddr = *(u32 *)nc->ctl.saddr.addr;
+		u32 daddr = *(u32 *)nc->ctl.daddr.addr;
+		u16 sport = nc->ctl.saddr.port;
+		u16 dport = nc->ctl.daddr.port;
+
+		dst = route_get_raw(saddr, daddr, sport, dport, nc->ctl.saddr.proto);
+		if (!dst)
+			return NULL;
+
+		nc->dst = route_get(dst);
+	}
+
+	return dst;
+}
+
+static int netchannel_alloc_pages(struct netchannel_page *l, u32 num, gfp_t mask)
+{
+	unsigned int i;
+	struct netchannel_page *p;
+
+	for (i=0; i<num; ++i) {
+		p = kzalloc(sizeof(struct netchannel_page), mask);
+		if (!p)
+			goto err_out_free;
+
+		l->page[i] = p;
+	}
+
+	return 0;
+
+err_out_free:
+	while (1) {
+		if (i == 0)
+			break;
+
+		i--;
+		kfree(l->page[i]);
+		l->page[i] = NULL;
+	}
+
+	return -ENOMEM;
+}
+
+static int netchannel_create_packet_array(struct netchannel *nc, gfp_t mask)
+{
+	u32 l2_num = nc->ctl.packet_limit / NETCHANNEL_NUM_PER_PAGE;
+	struct netchannel_page *l1;
+	int err = -ENOMEM;
+
+	l1 = kzalloc(sizeof(struct netchannel_page), mask);
+	if (!l1)
+		goto err_out_exit;
+
+	err = netchannel_alloc_pages(l1, l2_num, mask);
+	if (err)
+		goto err_out_free_l1;
+
+	nc->l1 = l1;
+	return 0;
+
+err_out_free_l1:
+	kfree(l1);
+err_out_exit:
+	return err;
+}
+
+static void netchannel_destroy_packet_array(struct netchannel *nc)
+{
+	u32 l2_num = nc->ctl.packet_limit / NETCHANNEL_NUM_PER_PAGE;
+	struct netchannel_page *l1 = nc->l1;
+	unsigned int i;
+
+	for (i=0; i<l2_num; ++i)
+		kfree(l1->page[i]);
+	kfree(l1);
+
+	nc->l1 = NULL;
+}
+
+static void netchannel_free_rcu(struct rcu_head *rcu_head)
+{
+	struct netchannel *nc = container_of(rcu_head, struct netchannel, rcu_head);
+
+	netchannel_destroy_packet_array(nc);
+	kmem_cache_free(netchannel_cache, nc);
+}
+
+void netchannel_free(struct netchannel *nc)
+{
+	call_rcu(&nc->rcu_head, netchannel_free_rcu);
+}
+
+
+/*
+ * Addresses and ports must be in network byte order.
+ */
+static int netchannel_create(struct netchannel_control *ctl)
+{
+	struct netchannel *nc;
+	int err, fd;
+
+	nc = kmem_cache_zalloc(netchannel_cache, GFP_KERNEL);
+	if (!nc) {
+		err = -ENOMEM;
+		goto err_out_exit;
+	}
+
+	memcpy(&nc->ctl, ctl, sizeof(struct netchannel_control));
+
+	init_waitqueue_head(&nc->wait);
+	atomic_set(&nc->last_read, 0);
+	atomic_set(&nc->pos, 0);
+
+	nc->ctl.packet_limit = ALIGN(nc->ctl.packet_limit, NETCHANNEL_NUM_PER_PAGE);
+
+	if (nc->ctl.packet_limit > netchannel_packet_limit)
+		nc->ctl.packet_limit = netchannel_packet_limit;
+
+	err = netchannel_create_packet_array(nc, GFP_KERNEL);
+	if (err)
+		goto err_out_free;
+
+	err = netchannel_add(nc);
+	if (err)
+		goto err_out_free_array;
+
+	fd = netchannel_bind_fd(nc);
+	if (fd < 0) {
+		err = fd;
+		goto err_out_remove;
+	}
+
+	return fd;
+
+err_out_remove:
+	netchannel_remove(nc);
+err_out_free_array:
+	netchannel_destroy_packet_array(nc);
+err_out_free:
+	kmem_cache_free(netchannel_cache, nc);
+err_out_exit:
+	return err;
+}
+
+asmlinkage long sys_netchannel_create(void __user *arg, unsigned int flags)
+{
+	struct netchannel_control ctl;
+
+	if (copy_from_user(&ctl, arg, sizeof(struct netchannel_control)))
+		return -EFAULT;
+
+	return netchannel_create(&ctl);
+}
+
+static int __init netchannel_init(void)
+{
+	int err = -ENOMEM;
+
+	netchannel_cache = kmem_cache_create("netchannel", sizeof(struct netchannel),
+			0, 0, NULL);
+	if (!netchannel_cache)
+		goto err_out_exit;
+
+	err = netchannel_user_init();
+	if (err)
+		goto err_out_destroy;
+	
+	printk(KERN_NOTICE "Netchannel subsystem has been initialized.\n");
+	netchannel_started = 1;
+
+	return 0;
+
+err_out_destroy:
+	kmem_cache_destroy(netchannel_cache);
+err_out_exit:
+	printk(KERN_NOTICE "netchannel: failed to initialize subsystem.\n");
+	return err;
+}
+
+module_init(netchannel_init);
diff --git a/net/core/netchannel/storage.c b/net/core/netchannel/storage.c
new file mode 100644
index 0000000..dc14afe
--- /dev/null
+++ b/net/core/netchannel/storage.c
@@ -0,0 +1,176 @@
+/*
+ * 2008+ Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
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
+#include <linux/init.h>
+#include <linux/list.h>
+#include <linux/rculist.h>
+#include <linux/slab.h>
+#include <linux/jhash.h>
+#include <linux/in.h>
+#include <linux/netchannel.h>
+
+struct netchannel_head
+{
+	struct list_head		head;
+	spinlock_t			lock;
+	int				num;
+};
+
+struct netchannel_hashtable
+{
+	struct netchannel_head		*table;
+	unsigned int			num;
+};
+
+static struct netchannel_hashtable netchannel_table;
+
+#if 0
+static void netchannel_dump_addr(char *str, struct netchannel_addr *a)
+{
+	printk("%s: size: %d, addr: ", str, a->size);
+	if (a->size == 4)
+		printk(NIPQUAD_FMT ":", a->addr[0], a->addr[1], a->addr[2], a->addr[3]);
+	else {
+		int i;
+
+		for (i=0; i<a->size; ++i)
+			printk("%02x:", a->addr[i]);
+	}
+	printk("%d, proto: %d.\n", ntohs(a->port), a->proto);
+}
+#endif
+
+static struct netchannel_head *netchannel_hash(struct netchannel_hashtable *t,
+		struct netchannel_addr *a1, struct netchannel_addr *a2)
+{
+	unsigned int h;
+
+	h = a1->port;
+	h <<= 16;
+	h |= a2->port;
+
+	h = jhash(a1->addr, a1->size, h);
+	h = jhash(a2->addr, a2->size, h);
+	h *= a1->proto;
+
+	return t->table + (h % t->num);
+}
+
+int netchannel_add(struct netchannel *nc)
+{
+	struct netchannel_head *h;
+
+	h = netchannel_hash(&netchannel_table, &nc->ctl.saddr, &nc->ctl.daddr);
+
+	spin_lock_bh(&h->lock);
+	list_add_tail_rcu(&nc->entry, &h->head);
+	spin_unlock_bh(&h->lock);
+#if 0
+	netchannel_dump_addr("src", &nc->ctl.saddr);
+	netchannel_dump_addr("dst", &nc->ctl.daddr);
+#endif
+	return 0;
+}
+
+void netchannel_remove(struct netchannel *nc)
+{
+	struct netchannel_head *h;
+
+	h = netchannel_hash(&netchannel_table, &nc->ctl.saddr, &nc->ctl.daddr);
+
+	spin_lock_bh(&h->lock);
+	list_del_rcu(&nc->entry);
+	spin_unlock_bh(&h->lock);
+}
+
+static inline int netchannel_match(struct netchannel *nc,
+		struct netchannel_addr *src, struct netchannel_addr *dst)
+{
+	struct netchannel_addr *nc_src = &nc->ctl.saddr;
+	struct netchannel_addr *nc_dst = &nc->ctl.daddr;
+
+	if (nc_src->proto != src->proto)
+		return 0;
+	if (nc_dst->proto != dst->proto)
+		return 0;
+	
+	if (nc_src->size != src->size)
+		return 0;
+	if (nc_dst->size != dst->size)
+		return 0;
+	
+	if (memcmp(nc_src->addr, src->addr, src->size))
+		return 0;
+	if (memcmp(nc_dst->addr, dst->addr, dst->size))
+		return 0;
+
+	return 1;
+}
+
+struct netchannel *netchannel_search(struct netchannel_addr *a1, struct netchannel_addr *a2)
+{
+	struct netchannel_head *h;
+	struct netchannel *tmp, *nc = NULL;
+
+	h = netchannel_hash(&netchannel_table, a1, a2);
+
+	list_for_each_entry_rcu(tmp, &h->head, entry) {
+		if (netchannel_match(tmp, a1, a2)) {
+			nc = tmp;
+			break;
+		}
+	}
+
+#if 0
+	if (nc) {
+		netchannel_dump_addr("src", a1);
+		netchannel_dump_addr("dst", a2);
+	}
+#endif
+	return nc;
+}
+
+int netchannel_storage_init(unsigned int num, gfp_t mask)
+{
+	struct netchannel_head *h;
+	unsigned int i;
+
+	h = kmalloc(sizeof(struct netchannel_head) * num, mask);
+	if (!h)
+		return -ENOMEM;
+
+	for (i=0; i<num; ++i) {
+		struct netchannel_head *head = &h[i];
+
+		INIT_LIST_HEAD(&head->head);
+		spin_lock_init(&head->lock);
+		head->num = 0;
+	}
+
+	netchannel_table.table = h;
+	netchannel_table.num = num;
+
+	return 0;
+}
+
+void netchannel_storage_exit(void)
+{
+	kfree(netchannel_table.table);
+}
diff --git a/net/core/netchannel/user.c b/net/core/netchannel/user.c
new file mode 100644
index 0000000..580483e
--- /dev/null
+++ b/net/core/netchannel/user.c
@@ -0,0 +1,246 @@
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <linux/file.h>
+#include <linux/netchannel.h>
+#include <linux/mount.h>
+#include <linux/netfilter.h>
+
+#include <net/ip.h>
+
+static char netchannel_name[] = "netchannel";
+
+static int netchannel_get_sb(struct file_system_type *fs_type, 
+		int flags, const char *dev_name, void *data, struct vfsmount *mnt)
+{
+	/* Very unusual magic number... */
+	return get_sb_pseudo(fs_type, netchannel_name, NULL, 0xabcdef, mnt);
+}
+
+static struct file_system_type netchannel_fs = {
+	.name		= netchannel_name,
+	.get_sb		= netchannel_get_sb,
+	.kill_sb	= kill_anon_super,
+};
+
+static struct vfsmount *netchannel_mnt;
+
+static inline s32 netchannel_has_data(struct netchannel *nc)
+{
+	return (s32)((u32)atomic_read(&nc->pos) - (u32)atomic_read(&nc->last_read)) > 0;
+}
+
+static inline long netchannel_wait_for_packet(struct netchannel *nc, long timeout)
+{
+	if (netchannel_has_data(nc))
+		return 0;
+
+	timeout = wait_event_interruptible_timeout(nc->wait, netchannel_has_data(nc), timeout);
+	if (timeout < 0)
+		return timeout;
+	if (timeout == 0)
+		return -EAGAIN;
+
+	return 0;
+}
+
+static int netchannel_copy_from_user(struct netchannel *nc, void __user *arg, unsigned int size)
+{
+	struct sk_buff *skb;
+	int err = -ENOENT;
+	struct dst_entry *dst;
+	struct net_device *dev;
+
+	dst = netchannel_get_dst_v4(nc);
+	if (!dst)
+		goto err_out_exit;
+
+	dev = dst->dev;
+
+	skb = alloc_skb(size + LL_RESERVED_SPACE(dev), GFP_KERNEL);
+	if (!skb) {
+		err = -ENOMEM;
+		goto err_out_route_put;
+	}
+
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+	skb_reset_network_header(skb);
+
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	err = skb_add_data(skb, arg, size);
+	if (err)
+		goto err_out_free;
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	skb->protocol = htons(ETH_P_IP);
+	skb->dst = dst;
+	skb->dev = dst->dev;
+
+	return NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, skb, NULL, skb->dst->dev, dst_output);
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
+static int netchannel_copy_to_user(struct netchannel *nc, void __user *arg, unsigned int size,
+		unsigned int timeout)
+{
+	unsigned int sz;
+	struct sk_buff *skb;
+	struct iovec to;
+	int err = 0, copied = 0;
+	struct netchannel_page *l1;
+	int pos, slot, idx;
+
+	to.iov_base = arg;
+	to.iov_len = size;
+
+	pos = atomic_read(&nc->last_read) - 1;
+
+	while (size && !err) {
+		pos++;
+
+		err = netchannel_wait_for_packet(nc, timeout);
+		if (err) {
+			if (!copied)
+				copied = err;
+			break;
+		}
+
+		pos &= nc->ctl.packet_limit - 1;
+		slot = pos / NETCHANNEL_NUM_PER_PAGE;
+		idx = pos % NETCHANNEL_NUM_PER_PAGE;
+
+		l1 = nc->l1->page[slot];
+
+		skb = xchg(&l1->page[idx], 0);
+		if (!skb)
+			continue;
+
+		atomic_inc(&nc->last_read);
+
+		sz = min(size, skb->len);
+		err = skb_copy_datagram_iovec(skb, 0, &to, sz);
+		if (!err) {
+			size -= sz;
+			copied += sz;
+		}
+
+		kfree_skb(skb);
+	}
+
+	return copied;
+}
+
+static ssize_t netchannel_read(struct file *file, char __user *buf, size_t size, loff_t *off)
+{
+	struct netchannel *nc = file->private_data;
+	return netchannel_copy_to_user(nc, buf, size, 0);
+}
+
+static ssize_t netchannel_write(struct file *file, const char __user *buf, size_t size, loff_t *off)
+{
+	struct netchannel *nc = file->private_data;
+	return netchannel_copy_from_user(nc, (void __user *)buf, size);
+}
+
+static unsigned int netchannel_poll(struct file *file, struct poll_table_struct *wait)
+{
+	struct netchannel *nc = file->private_data;
+	unsigned int mask = 0;
+
+	poll_wait(file, &nc->wait, wait);
+	if (netchannel_has_data(nc))
+		mask |= POLLIN;
+
+	return mask;
+}
+
+static int netchannel_release(struct inode *inode, struct file *file)
+{
+	struct netchannel *nc = file->private_data;
+
+	netchannel_remove(nc);
+	netchannel_free(nc);
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
+int netchannel_bind_fd(struct netchannel *nc)
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
+	file->f_op = &netchannel_fops;
+	file->f_vfsmnt = mntget(netchannel_mnt);
+	file->f_dentry = dget(netchannel_mnt->mnt_root);
+	file->f_mapping = file->f_dentry->d_inode->i_mapping;
+	file->f_mode = FMODE_READ|FMODE_WRITE;
+	file->f_flags = O_RDWR;
+	file->private_data = nc;
+
+	nc->file = file;
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
+int netchannel_user_init(void)
+{
+	int err;
+
+	err = register_filesystem(&netchannel_fs);
+	if (err) {
+		printk(KERN_ERR "Failed to register netchannel fs, err: %d.\n", err);
+		return err;
+	}
+
+	err = netchannel_storage_init(1024, GFP_KERNEL);
+	if (err)
+		goto err_out_unregister;
+
+	netchannel_mnt = kern_mount(&netchannel_fs);
+	if (IS_ERR(netchannel_mnt)) {
+		printk(KERN_ERR "Failed to mount netchannel fs, err: %ld.\n", PTR_ERR(netchannel_mnt));
+		err = PTR_ERR(netchannel_mnt);
+		goto err_out_storage_exit;
+	}
+
+	return 0;
+
+//err_out_umount:
+	mntput(netchannel_mnt);
+err_out_storage_exit:
+	netchannel_storage_exit();
+err_out_unregister:
+	unregister_filesystem(&netchannel_fs);
+	return err;
+}


-- 
	Evgeniy Polyakov
