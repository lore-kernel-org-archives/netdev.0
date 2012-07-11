From: Li Yu <raise.sail@gmail.com>
Subject: [RFC][PATCH 2/4] skbtrace: common code for skbtrace traces and skb_rps_info
 tracepoint
Date: Wed, 11 Jul 2012 10:17:47 +0800
Message-ID: <4FFCE24B.8050001@gmail.com>
References: <4FFBC6B6.2000600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:40614 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754383Ab2GKCRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 22:17:53 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so1204818pbb.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 19:17:53 -0700 (PDT)
In-Reply-To: <4FFBC6B6.2000600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yu <bingtian.ly@taobao.com>
Sign-off-by: Li Yu <bingtian.ly@taobao.com>

---
 include/linux/net.h                    |    5 +++
 include/linux/skbtrace_api.h           |    2 +
 include/linux/skbuff.h                 |    7 +++-
 include/net/skbtrace_api_common.h      |   70
++++++++++++++++++++++++++++++++
 include/net/sock.h                     |    5 +++
 include/trace/events/skbtrace.h        |    2 +
 include/trace/events/skbtrace_common.h |   36 ++++++++++++++++
 kernel/trace/Kconfig                   |    8 ++++
 net/core/Makefile                      |    2 +
 net/core/dev.c                         |    3 ++
 net/core/net-traces.c                  |   12 ++++++
 net/core/skbtrace-events-common.c      |   65 +++++++++++++++++++++++++++++
 net/core/skbuff.c                      |    5 +++
 net/core/sock.c                        |    6 +++
 14 files changed, 227 insertions(+), 1 deletion(-)
 create mode 100644 include/net/skbtrace_api_common.h
 create mode 100644 include/trace/events/skbtrace_common.h
 create mode 100644 net/core/skbtrace-events-common.c

diff --git a/include/linux/net.h b/include/linux/net.h
index e9ac2df..49945ad 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -172,6 +172,11 @@ struct proto_ops {
 				      struct socket *sock2);
 	int		(*accept)    (struct socket *sock,
 				      struct socket *newsock, int flags);
+#if defined(CONFIG_SKBTRACE) || defined(CONFIG_SKBTRACE_MODULE)
+	int		(*skbtrace_getname)   (struct socket *sock,
+				      struct sockaddr *addr,
+				      int *sockaddr_len, int peer);
+#endif
 	int		(*getname)   (struct socket *sock,
 				      struct sockaddr *addr,
 				      int *sockaddr_len, int peer);
diff --git a/include/linux/skbtrace_api.h b/include/linux/skbtrace_api.h
index 58db922..7489856 100644
--- a/include/linux/skbtrace_api.h
+++ b/include/linux/skbtrace_api.h
@@ -67,4 +67,6 @@ struct skbtrace_block {
 	void *ptr;
 } __packed;

+#include <net/skbtrace_api_common.h>
+
 #endif
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 642cb73..e505fcd 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -351,6 +351,8 @@ typedef unsigned char *sk_buff_data_t;
  *	@peeked: this packet has been seen already, so stats have been
  *		done for it, don't do them again
  *	@nf_trace: netfilter packet trace flag
+ *	@hit_skbtrace: is this should be skipped by skbtrace filter?
+ *	@skbtrace_filtered: is this already processed by skbtrace filter?
  *	@protocol: Packet protocol from driver
  *	@destructor: Destruct function
  *	@nfct: Associated connection, if any
@@ -468,7 +470,10 @@ struct sk_buff {
 	__u8			wifi_acked:1;
 	__u8			no_fcs:1;
 	__u8			head_frag:1;
-	/* 8/10 bit hole (depending on ndisc_nodetype presence) */
+#if defined(CONFIG_SKBTRACE) || defined(CONFIG_SKBTRACE_MODULE)
+	__u8			hit_skbtrace:1;
+	__u8			skbtrace_filtered:1;
+#endif
 	kmemcheck_bitfield_end(flags2);

 #ifdef CONFIG_NET_DMA
diff --git a/include/net/skbtrace_api_common.h
b/include/net/skbtrace_api_common.h
new file mode 100644
index 0000000..7195902
--- /dev/null
+++ b/include/net/skbtrace_api_common.h
@@ -0,0 +1,70 @@
+/*
+ *  skbtrace - sk_buff trace utilty
+ *
+ *	User/Kernel Interface
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
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
02111-1307, USA.
+ *
+ * 2012 Li Yu <bingtian.ly@taobao.com>
+ *
+ */
+#ifndef _NET_SKBTRACE_API_COMMON_H
+#define _NET_SKBTRACE_API_COMMON_H
+
+#include <linux/types.h>
+
+/********************* Common section *********************/
+
+/* skbtrace_block->action */
+enum {
+	skbtrace_action_invalid		= 0,
+	skbtrace_action_common_min	= 1,
+	skbtrace_action_skb_rps_info	= 1,
+	skbtrace_action_common_max	= 99,
+};
+
+/* common skbtrace_block->flags */
+enum {
+	skbtrace_flags_reserved_min = 0,
+	skbtrace_flags_reserved_0 = 0,
+	skbtrace_flags_reserved_1 = 1,
+	skbtrace_flags_reserved_2 = 2,
+	skbtrace_flags_reserved_3 = 3,
+	skbtrace_flags_reserved_max = 3,
+};
+
+/* it is copied from <net/flow_keys.h>, except pad fields and packed */
+struct skbtrace_flow_keys {
+	__u32 src;
+	__u32 dst;
+	union {
+		__u32 ports;
+		__u16 port16[2];
+	};
+	__u8 ip_proto;
+	__u8 pad[3];
+} __packed;
+
+struct skbtrace_skb_rps_info_blk {
+	struct skbtrace_block blk;
+	__u16 rx_queue;
+	__u16 pad;
+	__u32 rx_hash;
+	__u32 cpu;
+	__u32 ifindex;
+	struct skbtrace_flow_keys keys;
+} __packed;
+
+#endif
diff --git a/include/net/sock.h b/include/net/sock.h
index dcb54a0..4af6620 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -190,6 +190,8 @@ struct sock_common {
 };

 struct cg_proto;
+struct skbtrace_context;
+
 /**
   *	struct sock - network layer representation of sockets
   *	@__sk_common: shared layout with inet_timewait_sock
@@ -371,6 +373,9 @@ struct sock {
 	__u32			sk_mark;
 	u32			sk_classid;
 	struct cg_proto		*sk_cgrp;
+#if defined(CONFIG_SKBTRACE) || defined(CONFIG_SKBTRACE_MODULE)
+	struct skbtrace_context *sk_skbtrace;
+#endif
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk, int bytes);
 	void			(*sk_write_space)(struct sock *sk);
diff --git a/include/trace/events/skbtrace.h
b/include/trace/events/skbtrace.h
index b580814..bf8c2cb 100644
--- a/include/trace/events/skbtrace.h
+++ b/include/trace/events/skbtrace.h
@@ -26,4 +26,6 @@

 #include <linux/tracepoint.h>

+#include <trace/events/skbtrace_common.h>
+
 #endif
diff --git a/include/trace/events/skbtrace_common.h
b/include/trace/events/skbtrace_common.h
new file mode 100644
index 0000000..d9199cf
--- /dev/null
+++ b/include/trace/events/skbtrace_common.h
@@ -0,0 +1,36 @@
+/*
+ *  skbtrace - sk_buff trace utilty
+ *
+ *	Comon events
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
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
02111-1307, USA.
+ *
+ * 2012 Li Yu <bingtian.ly@taobao.com>
+ *
+ */
+
+#if !defined(_TRACE_EVENTS_SKBTRACE_COMMON_H)
+#define _TRACE_EVENTS_SKBTRACE_COMMON_H
+
+#include <linux/tracepoint.h>
+
+struct sk_buff;
+struct net_device;
+
+DECLARE_TRACE(skb_rps_info,
+	TP_PROTO(struct sk_buff *skb, struct net_device *dev, int cpu),
+	TP_ARGS(skb, dev, cpu));
+
+#endif
diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
index 8c4c070..cc49b26 100644
--- a/kernel/trace/Kconfig
+++ b/kernel/trace/Kconfig
@@ -367,6 +367,14 @@ config BLK_DEV_IO_TRACE

 	  If unsure, say N.

+config SKBTRACE
+	tristate "skbtrace : flexible networking tracing"
+	help
+	  A blktrace like utility for networking subsystem, you can enable
this feature
+	  as a kernel module.
+
+	  If unsure, say N.
+
 config KPROBE_EVENT
 	depends on KPROBES
 	depends on HAVE_REGS_AND_STACK_ACCESS_API
diff --git a/net/core/Makefile b/net/core/Makefile
index 674641b..6a80a85 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -18,6 +18,8 @@ obj-$(CONFIG_NETPOLL) += netpoll.o
 obj-$(CONFIG_NET_DMA) += user_dma.o
 obj-$(CONFIG_FIB_RULES) += fib_rules.o
 obj-$(CONFIG_TRACEPOINTS) += net-traces.o
+obj-${CONFIG_SKBTRACE} += skbtrace.o
+skbtrace-objs := skbtrace-core.o skbtrace-events-common.o
 obj-$(CONFIG_NET_DROP_MONITOR) += drop_monitor.o
 obj-$(CONFIG_NETWORK_PHY_TIMESTAMPING) += timestamping.o
 obj-$(CONFIG_NETPRIO_CGROUP) += netprio_cgroup.o
diff --git a/net/core/dev.c b/net/core/dev.c
index 69f7a1a..cefd991 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -129,6 +129,8 @@
 #include <trace/events/napi.h>
 #include <trace/events/net.h>
 #include <trace/events/skb.h>
+#include <trace/events/skbtrace_common.h>
+#include <linux/skbtrace.h>
 #include <linux/pci.h>
 #include <linux/inetdevice.h>
 #include <linux/cpu_rmap.h>
@@ -2784,6 +2786,7 @@ static int get_rps_cpu(struct net_device *dev,
struct sk_buff *skb,
 	}

 done:
+	trace_skb_rps_info(skb, dev, cpu);
 	return cpu;
 }

diff --git a/net/core/net-traces.c b/net/core/net-traces.c
index ba3c012..d86a58b 100644
--- a/net/core/net-traces.c
+++ b/net/core/net-traces.c
@@ -21,6 +21,7 @@
 #include <linux/netlink.h>
 #include <linux/net_dropmon.h>
 #include <linux/slab.h>
+#include <linux/skbtrace.h>

 #include <asm/unaligned.h>
 #include <asm/bitops.h>
@@ -31,7 +32,18 @@
 #include <trace/events/napi.h>
 #include <trace/events/sock.h>
 #include <trace/events/udp.h>
+#include <trace/events/skbtrace.h>

 EXPORT_TRACEPOINT_SYMBOL_GPL(kfree_skb);

 EXPORT_TRACEPOINT_SYMBOL_GPL(napi_poll);
+
+#if HAVE_SKBTRACE
+
+#define NEW_SKBTRACE_TP(name) \
+	DEFINE_TRACE(name); \
+	EXPORT_TRACEPOINT_SYMBOL_GPL(name);
+
+NEW_SKBTRACE_TP(skb_rps_info);
+
+#endif
diff --git a/net/core/skbtrace-events-common.c
b/net/core/skbtrace-events-common.c
new file mode 100644
index 0000000..69fcff2
--- /dev/null
+++ b/net/core/skbtrace-events-common.c
@@ -0,0 +1,65 @@
+/*
+ *  skbtrace - sk_buff trace utilty
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
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
02111-1307, USA.
+ *
+ * 2012 Li Yu <bingtian.ly@taobao.com>
+ *
+ */
+
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/socket.h>
+#include <linux/skbtrace_api.h>
+#include <linux/skbtrace.h>
+#include <net/flow_keys.h>
+
+static void skbtrace_skb_rps_info(struct skbtrace_tracepoint *t,
+		struct sk_buff *skb, struct net_device *dev, int cpu)
+SKBTRACE_SKB_EVENT_BEGIN
+	struct skbtrace_skb_rps_info_blk blk, *b = &blk;
+	struct flow_keys keys;
+
+	INIT_SKBTRACE_BLOCK(&b->blk, skb,
+			skbtrace_action_skb_rps_info,
+			0,
+			sizeof(blk));
+	b->rx_hash = skb->rxhash;
+	if (skb_rx_queue_recorded(skb))
+		b->rx_queue = skb_get_rx_queue(skb);
+	else
+		b->rx_queue = 0;
+	skb_flow_dissect(skb, &keys);
+	b->keys.src = keys.src;
+	b->keys.dst = keys.dst;
+	b->keys.ports = keys.ports;
+	b->keys.ip_proto = keys.ip_proto;
+	b->cpu = cpu;
+	b->ifindex = dev->ifindex;
+	skbtrace_probe(&b->blk);
+SKBTRACE_SKB_EVENT_END
+
+static struct skbtrace_tracepoint common[] = {
+	{
+		.name = "skb_rps_info",
+		.probe = skbtrace_skb_rps_info,
+	},
+	EMPTY_SKBTRACE_TP
+};
+
+int skbtrace_events_common_init(void)
+{
+	return skbtrace_register_tracepoints(AF_UNSPEC, common);
+}
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5a789a8..d8dd1be 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -70,6 +70,7 @@
 #include <asm/uaccess.h>
 #include <trace/events/skb.h>
 #include <linux/highmem.h>
+#include <linux/skbtrace.h>

 struct kmem_cache *skbuff_head_cache __read_mostly;
 static struct kmem_cache *skbuff_fclone_cache __read_mostly;
@@ -631,6 +632,10 @@ static void __copy_skb_header(struct sk_buff *new,
const struct sk_buff *old)
 	new->ooo_okay		= old->ooo_okay;
 	new->l4_rxhash		= old->l4_rxhash;
 	new->no_fcs		= old->no_fcs;
+#if HAVE_SKBTRACE
+	new->hit_skbtrace	= old->hit_skbtrace;
+	new->skbtrace_filtered	= old->skbtrace_filtered;
+#endif
 #ifdef CONFIG_XFRM
 	new->sp			= secpath_get(old->sp);
 #endif
diff --git a/net/core/sock.c b/net/core/sock.c
index 929bdcc..dfd9e72 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -132,6 +132,7 @@
 #include <net/netprio_cgroup.h>

 #include <linux/filter.h>
+#include <linux/skbtrace.h>

 #include <trace/events/sock.h>

@@ -1216,6 +1217,7 @@ struct sock *sk_alloc(struct net *net, int family,
gfp_t priority,

 		sock_update_classid(sk);
 		sock_update_netprioidx(sk);
+		skbtrace_context_reset(sk);
 	}

 	return sk;
@@ -1229,6 +1231,8 @@ static void __sk_free(struct sock *sk)
 	if (sk->sk_destruct)
 		sk->sk_destruct(sk);

+	skbtrace_context_destroy(sk);
+
 	filter = rcu_dereference_check(sk->sk_filter,
 				       atomic_read(&sk->sk_wmem_alloc) == 0);
 	if (filter) {
@@ -1384,6 +1388,8 @@ struct sock *sk_clone_lock(const struct sock *sk,
const gfp_t priority)

 		if (newsk->sk_flags & SK_FLAGS_TIMESTAMP)
 			net_enable_timestamp();
+
+		skbtrace_context_reset(newsk);
 	}
 out:
 	return newsk;
-- 
1.7.9.5
