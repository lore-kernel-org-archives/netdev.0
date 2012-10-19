From: Li Yu <raise.sail@gmail.com>
Subject: [PATCH 1/3] skbtrace v2: core feature and common events
Date: Fri, 19 Oct 2012 14:16:17 +0800
Message-ID: <5080F031.5040804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:56761 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752180Ab2JSGQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 02:16:22 -0400
Received: by mail-pa0-f46.google.com with SMTP id hz1so121597pad.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 23:16:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yu <bingtian.ly@taobao.com>

This patch contains:

1. The glue code of tracepoints subsystem and relay file system.
2. API for particular networking trace points.
3. The skb_rps_info trace point.

Thanks

Sign-off-by: Li Yu <bingtian.ly@taobao.com>

 include/linux/skbtrace.h               |  478 ++++++++++++
 include/linux/skbtrace_api.h           |   73 +
 include/linux/skbuff.h                 |    7
 include/net/skbtrace_api_common.h      |   84 ++
 include/net/sock.h                     |   14
 include/trace/events/skbtrace.h        |   32
 include/trace/events/skbtrace_common.h |   41 +
 kernel/trace/Kconfig                   |    8
 net/core/Makefile                      |    2
 net/core/dev.c                         |    3
 net/core/net-traces.c                  |   24
 net/core/skbtrace-core.c               | 1226
+++++++++++++++++++++++++++++++++
 net/core/skbtrace-events-common.c      |   68 +
 net/core/skbuff.c                      |    5
 net/core/sock.c                        |    9
 15 files changed, 2073 insertions(+), 1 deletion(-)

============================

diff --git a/include/linux/skbtrace.h b/include/linux/skbtrace.h
new file mode 100644
index 0000000..71fbff0
--- /dev/null
+++ b/include/linux/skbtrace.h
@@ -0,0 +1,478 @@
+/*
+ *  skbtrace - sk_buff trace utilty
+ *
+ *	API for kernel
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
+#ifndef _LINUX_SKBTRACE_H
+#define _LINUX_SKBTRACE_H
+
+#include <linux/jump_label.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/net.h>
+#include <linux/skbtrace_api.h>
+#include <asm/atomic.h>
+
+#include <net/sock.h>
+#include <net/inet_timewait_sock.h>
+
+#if defined(CONFIG_SKBTRACE) || defined(CONFIG_SKBTRACE_MODULE)
+#define HAVE_SKBTRACE 1
+#else
+#define HAVE_SKBTRACE 0
+#endif
+
+#if HAVE_SKBTRACE
+
+/* The size parameters of secondary_buffer->slots */
+#define SECONDARY_BUFFER_ORDER	0
+#define SECONDARY_BUFFER_SIZE	(PAGE_SIZE<<SECONDARY_BUFFER_ORDER)
+#define SECONDARY_BUFFER_UNIT	(128)
+#define SECONDARY_BUFFER_COUNTS
(SECONDARY_BUFFER_SIZE/SECONDARY_BUFFER_UNIT)
+
+struct secondary_buffer {
+	atomic_t refcnt;
+	struct hlist_node node;
+	int action;	/* the action of primary event */
+	spinlock_t lock;
+	unsigned long session;
+	int offset;	/* next writeable slot */
+	int count;	/* count of current cached events in 'slots' */
+	char *slots;	/* the cache of secondary events */
+};
+
+
+#define SECONDARY_TABLE_SHIFT	6
+#define SECONDARY_TABLE_SIZE	(1<<SECONDARY_TABLE_SHIFT)
+#define SECONDARY_TABLE_MASK	(SECONDARY_TABLE_SIZE - 1)
+
+struct secondary_table {
+	spinlock_t lock;
+	struct hlist_head table[SECONDARY_TABLE_SIZE];
+};
+
+struct skbtrace_tracepoint {
+	const char *trace_name;
+	int action;
+	int nr_secondary;
+	size_t block_size;
+	void *probe;
+	int (*setup_options)(struct skbtrace_tracepoint *tp,
+						char *options);
+	void (*enable)(struct skbtrace_tracepoint *tp);
+	void (*disable)(struct skbtrace_tracepoint *tp);
+	char *(*desc)(struct skbtrace_tracepoint *tp);
+	void *private;
+
+	/* Below is for internals, which is not a part of kernel API */
+	unsigned int enabled : 1;
+	struct skbtrace_tracepoint *primary;
+	/* The secondary events of sk_buff based event are */
+	/* cached here. The secondary events of socket based */
+	/* event are cached in hash table skbtrace_context->sec_table */
+	struct secondary_buffer sec_buffer;
+};
+
+extern atomic64_t skbtrace_event_seq;
+extern int sysctl_skbtrace_filter_default;
+
+#define INIT_SKBTRACE_BLOCK(blk, p, act, fl, blk_size) \
+	do {\
+		(blk)->magic = 0xDEADBEEF;\
+		(blk)->len = (blk_size);\
+		(blk)->action = (act);\
+		(blk)->flags = (fl);\
+		(blk)->seq = atomic64_add_return(1, &skbtrace_event_seq);\
+		(blk)->ts = current_kernel_time();\
+		(blk)->ptr = (p);\
+	} while (0)
+
+#define EMPTY_SKBTRACE_TP	{.trace_name = NULL, }
+
+struct inet_timewait_sock;
+struct skbtrace_ops {
+	int (*tw_getname)(struct inet_timewait_sock *tw,
+			struct sockaddr *uaddr, int peer);
+	int (*tw_filter_skb)(struct inet_timewait_sock *tw,
+			struct sk_buff *skb);
+	int (*getname)(struct sock *sk, struct sockaddr *uaddr,
+		 int *uaddr_len, int peer);
+	int (*filter_skb)(struct sock *sk, struct sk_buff *skb);
+};
+
+struct skbtrace_context {
+	unsigned long session;
+	struct skbtrace_ops *ops;
+	unsigned int active_conn_hit : 1;
+	struct secondary_table sec_table;
+};
+
+extern unsigned long skbtrace_session;
+
+extern int skbtrace_register_proto(int af,
+				struct skbtrace_tracepoint *tp_list,
+				struct skbtrace_ops *ops);
+extern void skbtrace_unregister_proto(int af);
+extern struct skbtrace_ops* skbtrace_ops_get(int af);
+
+extern void __skbtrace_probe(struct skbtrace_tracepoint *tp,
+				struct skbtrace_context *ctx,
+				struct skbtrace_block *blk);
+extern int skbtrace_events_common_init(void);
+
+extern struct static_key skbtrace_filters_enabled;
+extern struct sk_filter *skbtrace_skb_filter;
+extern struct sk_filter *skbtrace_sock_filter;
+
+extern struct sk_buff* skbtrace_get_sock_filter_skb(struct sock *sk);
+static inline void skbtrace_put_sock_filter_skb(struct sk_buff *skb)
+{
+	skb->data = skb->head;
+	skb->len = 0;
+	skb_reset_tail_pointer(skb);
+	skb_reset_transport_header(skb);
+	skb_reset_network_header(skb);
+	local_bh_enable();
+}
+extern struct sk_buff* skbtrace_get_twsk_filter_skb(
+					struct inet_timewait_sock *tw);
+#define skbtrace_put_twsk_filter_skb skbtrace_put_sock_filter_skb
+
+static inline void skbtrace_probe(struct skbtrace_tracepoint *t,
+				struct skbtrace_context *ctx,
+				struct skbtrace_block *blk)
+{
+	if (skbtrace_action_invalid == blk->action)
+		return;
+	__skbtrace_probe(t, ctx, blk);
+}
+
+static inline int skbtrace_bypass_skb(struct sk_buff *skb)
+{
+	if (static_key_false(&skbtrace_filters_enabled)) {
+		if (skb->skbtrace_filtered)
+			return skb->hit_skbtrace;
+		else if (skbtrace_skb_filter) {
+			unsigned int pkt_len;
+
+			pkt_len = SK_RUN_FILTER(skbtrace_skb_filter, skb);
+			skb->hit_skbtrace = !pkt_len;
+			skb->skbtrace_filtered = 1;
+			return skb->hit_skbtrace;
+		}
+	}
+	return 0;
+}
+
+static inline void secondary_buffer_get(struct secondary_buffer *buf)
+{
+	atomic_inc(&buf->refcnt);
+}
+
+static inline void secondary_buffer_put(struct secondary_buffer *buf)
+{
+	if (buf && atomic_dec_and_test(&buf->refcnt)) {
+		free_pages((unsigned long)buf->slots, SECONDARY_BUFFER_ORDER);
+		buf->slots = NULL;
+	}
+}
+
+static inline void secondary_buffer_reset(struct secondary_buffer *buf)
+{
+	buf->offset = 0;
+	buf->count = 0;
+}
+
+static inline int secondary_buffer_init(struct secondary_buffer *buf,
+					struct skbtrace_tracepoint *tp)
+{
+	buf->slots = (char *)__get_free_pages(GFP_ATOMIC,
+						SECONDARY_BUFFER_ORDER);
+	if (!buf->slots)
+		return -ENOMEM;
+
+	INIT_HLIST_NODE(&buf->node);
+	spin_lock_init(&buf->lock);
+	buf->action = tp->action;
+	buf->session = skbtrace_session;
+	atomic_set(&buf->refcnt, 0);
+	secondary_buffer_reset(buf);
+	secondary_buffer_get(buf);
+	return 0;
+}
+
+static inline struct secondary_buffer* secondary_buffer_new(
+					struct skbtrace_tracepoint *tp)
+{
+	struct secondary_buffer *buf;
+
+	buf = kmalloc(sizeof(*buf), GFP_ATOMIC);
+	if (buf && secondary_buffer_init(buf, tp)) {
+		kfree(buf);
+		buf = NULL;
+	}
+	return buf;
+}
+
+static inline void secondary_buffer_destroy(struct secondary_buffer *buf)
+{
+	if (buf) {
+		secondary_buffer_put(buf);
+		kfree(buf);
+	}
+}
+
+static inline struct secondary_buffer* secondary_table_lookup(
+				struct secondary_table *table,
+				struct skbtrace_tracepoint *tp)
+{
+	unsigned int key;
+	struct secondary_buffer *buffer;
+	struct hlist_node *pos;
+
+	key = (47 * tp->action) & SECONDARY_TABLE_MASK;
+	spin_lock_bh(&table->lock);
+	hlist_for_each_entry(buffer, pos, &table->table[key], node) {
+		if (buffer->session != skbtrace_session)
+			continue;
+		if (buffer->action == tp->action)
+			goto unlock;
+	}
+	buffer = NULL;
+unlock:
+	spin_unlock_bh(&table->lock);
+
+	return buffer;
+}
+
+static inline struct secondary_buffer* secondary_table_lookup_or_create(
+				struct secondary_table *table,
+				struct skbtrace_tracepoint *tp)
+{
+	unsigned int key;
+	struct secondary_buffer *buffer;
+	struct hlist_node *pos;
+
+	key = (47 * tp->action) & SECONDARY_TABLE_MASK;
+	spin_lock_bh(&table->lock);
+	hlist_for_each_entry(buffer, pos, &table->table[key], node) {
+		if (buffer->session != skbtrace_session)
+			continue;
+		if (buffer->action == tp->action)
+			goto unlock;
+	}
+	buffer = secondary_buffer_new(tp);
+	if (buffer)
+		hlist_add_head(&buffer->node, &table->table[key]);
+unlock:
+	spin_unlock_bh(&table->lock);
+
+	return buffer;
+}
+
+static inline void secondary_table_clean(struct secondary_table *table)
+{
+	unsigned int key;
+
+	spin_lock_bh(&table->lock);
+	for (key = 0; key < SECONDARY_TABLE_SIZE; key++) {
+		while (!hlist_empty(&table->table[key])) {
+			struct secondary_buffer *buffer;
+
+			buffer = container_of(table->table[key].first,
+						struct secondary_buffer, node);
+			hlist_del(table->table[key].first);
+			secondary_buffer_destroy(buffer);
+		}
+	}
+	spin_unlock_bh(&table->lock);
+}
+
+static inline void secondary_table_init(struct secondary_table *table)
+{
+	unsigned int key;
+
+	spin_lock_init(&table->lock);
+	for (key = 0; key < SECONDARY_TABLE_SIZE; key++)
+		INIT_HLIST_HEAD(&table->table[key]);
+}
+
+extern struct skbtrace_context *skbtrace_context_get(struct sock *sk);
+extern void skbtrace_context_setup(struct skbtrace_context *ctx,
+					struct skbtrace_ops *ops);
+
+static inline void skbtrace_context_destroy(struct skbtrace_context **ctx)
+{
+	if (!*ctx)
+		return;
+	secondary_table_clean(&(*ctx)->sec_table);
+	kfree(*ctx);
+	*ctx = NULL;
+}
+
+static inline void sock_skbtrace_reset(struct sock *sk)
+{
+	sk->sk_skbtrace = NULL;
+}
+
+static inline void* secondary_buffer_get_block(struct secondary_buffer
*buf,
+					struct skbtrace_tracepoint *primary)
+{
+	void *ret;
+
+	if (!buf->slots && secondary_buffer_init(buf, primary))
+		return NULL;
+
+	spin_lock_bh(&buf->lock);
+	ret = &buf->slots[buf->offset * SECONDARY_BUFFER_UNIT];
+	if (buf->count < SECONDARY_BUFFER_COUNTS)
+		buf->count++;
+	if (++buf->offset >= SECONDARY_BUFFER_COUNTS)
+		buf->offset = 0;
+	spin_unlock_bh(&buf->lock);
+	return ret;
+}
+
+static inline void* skbtrace_block_get(struct skbtrace_tracepoint *tp,
+					struct skbtrace_context *ctx,
+					void *fast)
+{
+	struct skbtrace_tracepoint *pri;
+
+	if (!tp || !tp->primary)
+		return fast;
+
+	pri = tp->primary;
+	if (ctx) {
+		struct secondary_buffer *buf;
+		struct secondary_table *table;
+
+		table = &ctx->sec_table;
+		buf = secondary_table_lookup_or_create(table, pri);
+		if (!buf)
+			return fast;
+		return secondary_buffer_get_block(buf, pri) ? : fast;
+	}
+	return secondary_buffer_get_block(&pri->sec_buffer, pri) ? : fast;
+}
+
+static inline void* skbtrace_block_sk_get(struct skbtrace_tracepoint *tp,
+					struct sock *sk,
+					void *fast)
+{
+	return skbtrace_block_get(tp, skbtrace_context_get(sk), fast);
+}
+
+#define SKBTRACE_SKB_EVENT_BEGIN \
+{\
+	if (skbtrace_bypass_skb(skb)) {\
+		return;	\
+	} else {
+
+#define SKBTRACE_SKB_EVENT_END \
+	} \
+}
+
+extern u32 skbtrace_sock_filter_id;
+static inline int skbtrace_bypass_sock(struct sock *sk)
+{
+	if (static_key_false(&skbtrace_filters_enabled)) {
+		if (likely(sk->sk_skbtrace_filtered &&
+				(skbtrace_sock_filter_id == sk->sk_skbtrace_fid))) {
+			return sk->sk_hit_skbtrace;
+		}
+		if (skbtrace_sock_filter) {
+			unsigned int pkt_len;
+			struct sk_buff *skb;
+
+			skb = skbtrace_get_sock_filter_skb(sk);
+			if (skb) {
+				pkt_len = SK_RUN_FILTER(skbtrace_sock_filter, skb);
+				sk->sk_hit_skbtrace = !pkt_len;
+				sk->sk_skbtrace_filtered = 1;
+				skbtrace_put_sock_filter_skb(skb);
+				sk->sk_skbtrace_fid = skbtrace_sock_filter_id;
+				return sk->sk_hit_skbtrace;
+			}
+			return sysctl_skbtrace_filter_default;
+		}
+	}
+	return 0;
+}
+
+static inline int skbtrace_bypass_twsk(struct inet_timewait_sock *tw)
+{
+	if (static_key_false(&skbtrace_filters_enabled)) {
+		if (likely(tw->tw_skbtrace_filtered &&
+				(skbtrace_sock_filter_id == tw->tw_skbtrace_fid))) {
+			return tw->tw_hit_skbtrace;
+		}
+		if (skbtrace_sock_filter) {
+			unsigned int pkt_len;
+			struct sk_buff *skb;
+
+			skb = skbtrace_get_twsk_filter_skb(tw);
+			if (skb) {
+				pkt_len = SK_RUN_FILTER(skbtrace_sock_filter, skb);
+				tw->tw_hit_skbtrace = !pkt_len;
+				tw->tw_skbtrace_filtered = 1;
+				skbtrace_put_twsk_filter_skb(skb);
+				tw->tw_skbtrace_fid = skbtrace_sock_filter_id;
+				return tw->tw_hit_skbtrace;
+			}
+			return sysctl_skbtrace_filter_default;
+		}
+	}
+	return 0;
+}
+
+#define SKBTRACE_SOCK_EVENT_BEGIN \
+{\
+	if (skbtrace_bypass_sock(sk)) {\
+		return;	\
+	} else {
+
+#define SKBTRACE_SOCK_EVENT_END \
+	} \
+}
+
+extern int inet_filter_skb(struct sock *sk, struct sk_buff *skb);
+extern int inet_tw_getname(struct inet_timewait_sock *tw,
+				struct sockaddr *uaddr, int peer);
+extern int inet_tw_filter_skb(struct inet_timewait_sock *tw,
+				struct sk_buff *skb);
+extern int tcp_tw_filter_skb(struct inet_timewait_sock *tw,
+				struct sk_buff *skb);
+extern int tcp_filter_skb(struct sock *sk, struct sk_buff *skb);
+
+#else /* HAVE_SKBTRACE */
+
+static inline void sock_skbtrace_reset(struct sock *sk)
+{
+}
+
+static inline void skbtrace_context_destroy(struct skbtrace_context **ctx)
+{
+}
+
+#endif /* HAVE_SKBTRACE */
+
+#endif /* _LINUX_SKBTRACE_H */
diff --git a/include/linux/skbtrace_api.h b/include/linux/skbtrace_api.h
new file mode 100644
index 0000000..2d14ff6
--- /dev/null
+++ b/include/linux/skbtrace_api.h
@@ -0,0 +1,73 @@
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
+#ifndef _LINUX_SKBTRACE_API_H
+#define _LINUX_SKBTRACE_API_H
+
+#include <linux/types.h>
+
+#ifdef __KERNEL__
+#include <linux/time.h>
+#else
+#include <time.h>
+#define __packed	__attribute__ ((__packed__))
+#endif
+
+#define TRACE_SPEC_MAX_LEN	256
+
+#define SKBTRACE_DEF_SUBBUF_SIZE	(1<<12)
+#define SKBTRACE_DEF_SUBBUF_NR		(1<<11)
+
+#define SKBTRACE_MIN_SUBBUF_SIZE	SKBTRACE_DEF_SUBBUF_SIZE
+#define SKBTRACE_MIN_SUBBUF_NR		SKBTRACE_DEF_SUBBUF_NR
+
+#define SKBTRACE_MAX_SUBBUF_SIZE	(1<<16)
+#define SKBTRACE_MAX_SUBBUF_NR		(1<<20)
+
+#define SC	0	/* for tracepoints in process context */
+#define SI	1	/* for tracepoints in softirq context */
+#define HW	2	/* for tracepoints in hardirq context */
+#define NR_CHANNELS	3
+
+/* struct skbtrace_block - be used in kernel/user interaction	*/
+/* @len:	whole data structure size in bytes		*/
+/* @action:	action of this skbtrace_block			*/
+/* @flags:	the flags depend on above action field		*/
+/* @ts:		the timestamp of this event.			*/
+/* @ptr:	the major source kernel data structure		*/
+/*		of this event, for gerneral, a sk_buff or sock	*/
+/* PLEASE:							*/
+/*	Keep 64 bits alignment 					*/
+struct skbtrace_block {
+	__u64 magic;
+	__u16 len;
+	__u16 action;
+	__u32 flags;
+	struct timespec ts;
+	__u64 seq;
+	void *ptr;
+} __packed;
+
+#include <net/skbtrace_api_common.h>
+#include <net/skbtrace_api_ipv4.h>
+
+#endif
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7632c87..27a0fe0 100644
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
@@ -469,7 +471,10 @@ struct sk_buff {
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
index 0000000..87892d6
--- /dev/null
+++ b/include/net/skbtrace_api_common.h
@@ -0,0 +1,84 @@
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
+	skbtrace_action_sk_timer	= 2,
+	skbtrace_action_common_max	= 99,
+};
+
+/* common skbtrace_block->flags */
+/* miss_secondary - none secondary events or no enough memory to cache
them */
+enum {
+	skbtrace_flags_reserved_min = 28,
+	skbtrace_flags_miss_secondary = 28,
+	skbtrace_flags_reserved_max = 31,
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
+	__u32 ip_proto;
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
+
+/* socket timers */
+/* flags */
+enum {
+	skbtrace_sk_timer_setup	= 0,
+	skbtrace_sk_timer_reset	= 1,
+	skbtrace_sk_timer_stop	= 2,
+	skbtrace_sk_timer_last	= 3,
+};
+
+struct skbtrace_sk_timer_blk {
+	struct skbtrace_block blk;
+	__s32	proto;
+	__s32	timeout;
+} __packed;
+
+#endif
diff --git a/include/net/sock.h b/include/net/sock.h
index adb7da2..7a1d861 100644
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
@@ -332,7 +334,12 @@ struct sock {
 				sk_userlocks : 4,
 				sk_protocol  : 8,
 				sk_type      : 16;
+#if defined(CONFIG_SKBTRACE) || defined(CONFIG_SKBTRACE_MODULE)
+	unsigned int		sk_hit_skbtrace : 1,
+				sk_skbtrace_filtered : 1;
+#endif
 	kmemcheck_bitfield_end(flags);
+	unsigned int		sk_skbtrace_fid;
 	int			sk_wmem_queued;
 	gfp_t			sk_allocation;
 	netdev_features_t	sk_route_caps;
@@ -373,6 +380,9 @@ struct sock {
 	__u32			sk_mark;
 	u32			sk_classid;
 	struct cg_proto		*sk_cgrp;
+#if defined(CONFIG_SKBTRACE) || defined(CONFIG_SKBTRACE_MODULE)
+	struct skbtrace_context *sk_skbtrace;
+#endif
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk, int bytes);
 	void			(*sk_write_space)(struct sock *sk);
@@ -842,6 +852,10 @@ struct module;
  * transport -> network interface is defined by struct inet_proto
  */
 struct proto {
+#if defined(CONFIG_SKBTRACE) || defined(CONFIG_SKBTRACE_MODULE)
+	int			(*filter_skb)(struct sock *sk,
+					struct sk_buff *skb);
+#endif
 	void			(*close)(struct sock *sk,
 					long timeout);
 	int			(*connect)(struct sock *sk,
diff --git a/include/trace/events/skbtrace.h
b/include/trace/events/skbtrace.h
new file mode 100644
index 0000000..91567bf
--- /dev/null
+++ b/include/trace/events/skbtrace.h
@@ -0,0 +1,32 @@
+/*
+ *  skbtrace - sk_buff trace utilty
+ *
+ *	Events
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
+#if !defined(_TRACE_EVENTS_SKBTRACE_H)
+#define _TRACE_EVENTS_SKBTRACE_H
+
+#include <linux/tracepoint.h>
+
+#include <trace/events/skbtrace_common.h>
+#include <trace/events/skbtrace_ipv4.h>
+
+#endif
diff --git a/include/trace/events/skbtrace_common.h
b/include/trace/events/skbtrace_common.h
new file mode 100644
index 0000000..4352564
--- /dev/null
+++ b/include/trace/events/skbtrace_common.h
@@ -0,0 +1,41 @@
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
+struct timer_list;
+
+DECLARE_TRACE(skb_rps_info,
+	TP_PROTO(struct sk_buff *skb, struct net_device *dev, int cpu),
+	TP_ARGS(skb, dev, cpu));
+
+DECLARE_TRACE(sk_timer,
+	TP_PROTO(void *sk, struct timer_list *timer, int action),
+	TP_ARGS(sk, timer, action));
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
index 89e33a5..b363716 100644
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
@@ -2813,6 +2815,7 @@ static int get_rps_cpu(struct net_device *dev,
struct sk_buff *skb,
 	}

 done:
+	trace_skb_rps_info(skb, dev, cpu);
 	return cpu;
 }

diff --git a/net/core/net-traces.c b/net/core/net-traces.c
index ba3c012..41e1766 100644
--- a/net/core/net-traces.c
+++ b/net/core/net-traces.c
@@ -21,6 +21,7 @@
 #include <linux/netlink.h>
 #include <linux/net_dropmon.h>
 #include <linux/slab.h>
+#include <linux/skbtrace.h>

 #include <asm/unaligned.h>
 #include <asm/bitops.h>
@@ -31,7 +32,30 @@
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
+NEW_SKBTRACE_TP(sk_timer);
+
+NEW_SKBTRACE_TP(tcp_congestion);
+NEW_SKBTRACE_TP(tcp_connection);
+NEW_SKBTRACE_TP(icsk_connection);
+NEW_SKBTRACE_TP(tcp_sendlimit);
+NEW_SKBTRACE_TP(tcp_active_conn);
+NEW_SKBTRACE_TP(tcp_rttm);
+NEW_SKBTRACE_TP(tcp_ca_state);
+
+unsigned long skbtrace_session;
+EXPORT_SYMBOL(skbtrace_session);
+
+#endif
diff --git a/net/core/skbtrace-core.c b/net/core/skbtrace-core.c
new file mode 100644
index 0000000..2c2ac3e
--- /dev/null
+++ b/net/core/skbtrace-core.c
@@ -0,0 +1,1226 @@
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
+#include <linux/module.h>
+#include <linux/relay.h>
+#include <linux/debugfs.h>
+#include <linux/slab.h>
+#include <linux/ctype.h>
+#include <linux/jhash.h>
+
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/filter.h>
+#include <linux/skbtrace.h>
+#include <net/sock.h>
+
+#define SKBTRACE_VERSION	"1"
+#define SKBTRACE_DIR		"skbtrace"
+
+static unsigned long skbtrace_dropped[NR_CHANNELS][NR_CPUS];
+/* +1 for quick indexing trick in __skbtrace_probe() */
+static struct rchan *skbtrace_channels[NR_CHANNELS + 1];
+
+int sysctl_skbtrace_filter_default = 0;
+EXPORT_SYMBOL_GPL(sysctl_skbtrace_filter_default);
+static struct sk_buff **sock_filter_skb;
+static struct sock_fprog skb_filter_fprog;
+static struct sock_fprog sock_filter_fprog;
+struct sk_filter *skbtrace_skb_filter;
+EXPORT_SYMBOL_GPL(skbtrace_skb_filter);
+
+u32 skbtrace_sock_filter_id;
+EXPORT_SYMBOL_GPL(skbtrace_sock_filter_id);
+struct sk_filter *skbtrace_sock_filter;
+EXPORT_SYMBOL_GPL(skbtrace_sock_filter);
+
+static struct dentry	*skbtrace_dentry;
+static struct dentry	*enabled_control;
+static struct dentry	*dropped_control;
+static struct dentry	*version_control;
+static struct dentry	*subbuf_nr_control;
+static struct dentry	*subbuf_size_control;
+static struct dentry	*filters_control;
+static struct dentry	*sock_filters_control;
+
+static const struct file_operations	enabled_fops;
+static const struct file_operations	dropped_fops;
+static const struct file_operations	version_fops;
+static const struct file_operations	subbuf_nr_fops;
+static const struct file_operations	subbuf_size_fops;
+static const struct file_operations	filters_fops;
+static const struct file_operations	sock_filters_fops;
+
+static int nr_skbtrace_enabled_tp;
+static int subbuf_nr = SKBTRACE_DEF_SUBBUF_NR;
+static int subbuf_size = SKBTRACE_DEF_SUBBUF_SIZE;
+
+static bool should_load_proto;
+
+struct static_key skbtrace_filters_enabled = STATIC_KEY_INIT_FALSE;
+EXPORT_SYMBOL_GPL(skbtrace_filters_enabled);
+
+atomic64_t skbtrace_event_seq = ATOMIC64_INIT(0);
+EXPORT_SYMBOL_GPL(skbtrace_event_seq);
+
+/* protect agaist af_tp_list and skbtrace_channels */
+static struct mutex skbtrace_lock;
+static struct skbtrace_tracepoint *af_tp_list[AF_MAX];
+struct skbtrace_ops* skbtrace_ops[AF_MAX];
+
+static int create_controls(void);
+static void remove_controls(void);
+static int  create_channels(void);
+static void flush_channels(void);
+static void destroy_channels(void);
+static ssize_t sk_filter_read(struct sock_fprog *fprog, char __user
*buffer,
+							    size_t count);
+static ssize_t sk_filter_write(struct sock_fprog *sk_fprog,
+				struct sk_filter **sk_filter,
+				const char __user *buffer, size_t count);
+static void reset_filter(struct sock_fprog *fprog, struct sk_filter
**filter);
+static void skbtrace_filters_clean(void);
+
+struct skbtrace_ops* skbtrace_ops_get(int af)
+{
+	return skbtrace_ops[af];
+}
+EXPORT_SYMBOL_GPL(skbtrace_ops_get);
+
+static void skbtrace_proto_load(void)
+{
+	int af;
+
+	if (!should_load_proto)
+		return;
+
+	should_load_proto = false;
+
+	for (af = AF_UNSPEC; af < AF_MAX; af++) {
+		/* load proto-specific events */
+		if (!af_tp_list[af])
+			request_module("skbtrace-af-%d", af);
+	}
+}
+
+void __skbtrace_block_probe(struct skbtrace_block *blk)
+{
+	unsigned int chan_id;
+	struct rchan *rchan;
+
+	chan_id = (!!in_irq()) << 1;
+	chan_id |= !!in_softirq();	/* make sparse happy */
+	rchan = skbtrace_channels[chan_id];
+
+	if (unlikely(chan_id >= HW))
+		relay_write(rchan, blk, blk->len);
+	else {
+		local_bh_disable();
+		__relay_write(rchan, blk, blk->len);
+		local_bh_enable();
+	}
+	blk->action = skbtrace_action_invalid;
+}
+
+void __skbtrace_do_probe(struct skbtrace_tracepoint *tp,
+				struct skbtrace_context *ctx,
+				struct skbtrace_block *blk)
+{
+	int i;
+	char *sec_blk;
+	struct secondary_buffer *buf;
+
+	if (ctx)
+		buf = secondary_table_lookup(&ctx->sec_table, tp);
+	else
+		buf = &tp->sec_buffer;
+
+	if (!buf) {
+		if (tp->nr_secondary)
+			blk->flags |= 1<<skbtrace_flags_miss_secondary;
+		goto quit;
+	}
+
+	spin_lock_bh(&buf->lock);
+	for (i = 0; i < buf->count; i++) {
+		if (--buf->offset < 0)
+			buf->offset = SECONDARY_BUFFER_COUNTS - 1;
+		sec_blk = &buf->slots[buf->offset * SECONDARY_BUFFER_UNIT];
+		__skbtrace_block_probe((struct skbtrace_block*)sec_blk);
+	}
+	secondary_buffer_reset(buf);
+	spin_unlock_bh(&buf->lock);
+
+quit:
+	__skbtrace_block_probe(blk);
+}
+
+void __skbtrace_probe(struct skbtrace_tracepoint *tp,
+				struct skbtrace_context *ctx,
+				struct skbtrace_block *blk)
+{
+	if (!tp)
+		return;
+	if (!tp->primary)
+		__skbtrace_do_probe(tp, ctx, blk);
+}
+EXPORT_SYMBOL_GPL(__skbtrace_probe);
+
+static void __skbtrace_setup_tracepoints(struct skbtrace_tracepoint
*tp_list)
+{
+	struct skbtrace_tracepoint *tp;
+
+	tp = tp_list;
+	while (tp && tp->trace_name) {
+		secondary_buffer_init(&tp->sec_buffer, tp);
+		tp->primary = NULL;
+		tp->enabled = 0;
+		tp++;
+	}
+}
+
+static int __skbtrace_register_tracepoints(int af,
+                                struct skbtrace_tracepoint *tp_list)
+{
+	int ret = 0;
+
+	if (af_tp_list[af])
+		ret = -EEXIST;
+
+	if (tp_list) {
+		__skbtrace_setup_tracepoints(tp_list);
+		if (tp_list[0].trace_name)
+			af_tp_list[af] = tp_list;
+		else
+			ret = -EINVAL;
+	} else
+		af_tp_list[af] = NULL;
+
+	return ret;
+}
+
+static void __skbtrace_unregister_tracepoints(int af)
+{
+	struct skbtrace_tracepoint *tp;
+
+	tp = af_tp_list[af];
+	while (tp && tp->trace_name) {
+		if (tp->enabled) {
+			tp->enabled = 0;
+			--nr_skbtrace_enabled_tp;
+			tracepoint_probe_unregister(tp->trace_name,
+							tp->probe, tp);
+			secondary_buffer_put(&tp->sec_buffer);
+		}
+		tp++;
+	}
+	af_tp_list[af] = NULL;
+}
+
+static inline int __skbtrace_register_ops(int af, struct skbtrace_ops *ops)
+{
+	if (skbtrace_ops[af])
+		return -EEXIST;
+	skbtrace_ops[af] = ops;
+	return 0;
+}
+
+static inline void __skbtrace_unregister_ops(int af)
+{
+	skbtrace_ops[af] = NULL;
+}
+
+int skbtrace_register_proto(int af,
+			struct skbtrace_tracepoint *tp_list,
+			struct skbtrace_ops *ops)
+{
+	int ret;
+
+	if (af < 0 || af >= AF_MAX)
+		return -EINVAL;
+
+	mutex_lock(&skbtrace_lock);
+	ret = __skbtrace_register_tracepoints(af, tp_list);
+	if (!ret) {
+		ret = __skbtrace_register_ops(af, ops);
+		if (ret)
+			__skbtrace_unregister_tracepoints(af);
+	}
+	mutex_unlock(&skbtrace_lock);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(skbtrace_register_proto);
+
+void skbtrace_unregister_proto(int af)
+{
+	if (af < 0 || af >= AF_MAX)
+		return;
+
+	mutex_lock(&skbtrace_lock);
+	__skbtrace_unregister_tracepoints(af);
+	__skbtrace_unregister_ops(af);
+	mutex_unlock(&skbtrace_lock);
+
+	flush_channels();
+	should_load_proto = true;
+}
+EXPORT_SYMBOL_GPL(skbtrace_unregister_proto);
+
+void skbtrace_context_setup(struct skbtrace_context *ctx,
+				struct skbtrace_ops *ops)
+{
+	ctx->ops = ops;
+	ctx->session = skbtrace_session;
+	secondary_table_init(&ctx->sec_table);
+}
+EXPORT_SYMBOL(skbtrace_context_setup);
+
+struct skbtrace_context *skbtrace_context_get(struct sock *sk)
+{
+	struct skbtrace_ops *ops;
+	struct skbtrace_context *ctx;
+
+	ops = skbtrace_ops_get(sk->sk_family);
+	if (!ops)
+		return NULL;
+	local_bh_disable();
+
+	if (sk->sk_skbtrace &&
+			(skbtrace_session != sk->sk_skbtrace->session))
+		skbtrace_context_destroy(&sk->sk_skbtrace);
+
+	if (!sk->sk_skbtrace) {
+		ctx = kzalloc(sizeof(struct skbtrace_context), GFP_ATOMIC);
+		if (likely(ctx)) {
+			skbtrace_context_setup(ctx, ops);
+			sk->sk_skbtrace = ctx;
+		}
+	}
+
+	local_bh_enable();
+	return sk->sk_skbtrace;
+}
+EXPORT_SYMBOL(skbtrace_context_get);
+
+static int subbuf_start_handler(struct rchan_buf *buf,
+				void *subbuf,
+				void *prev_subbuf,
+				size_t prev_padding)
+{
+	if (relay_buf_full(buf)) {
+		long trace, cpu;
+
+		trace = (long)buf->chan->private_data;
+		cpu = buf->cpu;
+		skbtrace_dropped[trace][cpu]++;
+		return 0;
+	}
+	return 1;
+}
+
+static struct dentry *create_buf_file_handler(const char *filename,
+					      struct dentry *parent,
+					      umode_t mode,
+					      struct rchan_buf *buf,
+					      int *is_global)
+{
+	return debugfs_create_file(filename, mode, parent, buf,
+				       &relay_file_operations);
+}
+
+static int remove_buf_file_handler(struct dentry *dentry)
+{
+	debugfs_remove(dentry);
+	return 0;
+}
+
+static struct rchan_callbacks relayfs_callbacks = {
+	.subbuf_start = subbuf_start_handler,
+	.create_buf_file = create_buf_file_handler,
+	.remove_buf_file = remove_buf_file_handler,
+};
+
+/* caller must hold skbtrace_lock */
+static int create_channels(void)
+{
+	unsigned long i, created;
+	const char *skbtrace_names[NR_CHANNELS] = {    "trace.syscall.cpu",
+							"trace.softirq.cpu",
+							"trace.hardirq.cpu" };
+	created = 0;
+	for (i = 0; i < NR_CHANNELS; i++) {
+		if (skbtrace_channels[i])
+			continue;
+		skbtrace_channels[i] = relay_open(skbtrace_names[i],
+			skbtrace_dentry, subbuf_size, subbuf_nr,
+				&relayfs_callbacks, (void *)i);
+		if (!skbtrace_channels[i]) {
+			destroy_channels();
+			return -ENOMEM;
+		}
+		created = 1;
+	}
+	skbtrace_channels[HW + 1] = skbtrace_channels[HW];
+
+	if (created)
+		__module_get(THIS_MODULE);
+	return 0;
+}
+
+static void flush_channels(void)
+{
+	int i;
+	for (i = 0; i < NR_CHANNELS; i++) {
+		if (skbtrace_channels[i])
+			relay_flush(skbtrace_channels[i]);
+	}
+}
+
+/* caller must hold skbtrace_lock */
+static void destroy_channels(void)
+{
+	int i, removed;
+
+	removed = 0;
+	for (i = 0; i < NR_CHANNELS; i++) {
+		if (skbtrace_channels[i]) {
+			relay_flush(skbtrace_channels[i]);
+			relay_close(skbtrace_channels[i]);
+			skbtrace_channels[i] = NULL;
+			removed = 1;
+		}
+	}
+	skbtrace_channels[HW + 1] = NULL;
+
+	if (removed)
+		module_put(THIS_MODULE);
+}
+
+static void remove_controls(void)
+{
+#define REMOVE_DEBUGFS_FILE(name) \
+	do {\
+		if (name##_control) \
+			debugfs_remove(name##_control); \
+	} while(0);
+
+	REMOVE_DEBUGFS_FILE(enabled)
+	REMOVE_DEBUGFS_FILE(dropped)
+	REMOVE_DEBUGFS_FILE(version)
+	REMOVE_DEBUGFS_FILE(subbuf_nr)
+	REMOVE_DEBUGFS_FILE(subbuf_size)
+	REMOVE_DEBUGFS_FILE(filters)
+	REMOVE_DEBUGFS_FILE(sock_filters)
+}
+
+static int create_controls(void)
+{
+#define CREATE_DEBUGFS_FILE(name)\
+	do {\
+		name##_control = debugfs_create_file(#name, 0,\
+				skbtrace_dentry, NULL, &name##_fops);\
+		if (name##_control)\
+			break;\
+		pr_err("skbtrace: couldn't create relayfs file '" #name "'\n");\
+		goto fail;\
+	} while (0);
+
+	CREATE_DEBUGFS_FILE(enabled)
+	CREATE_DEBUGFS_FILE(dropped)
+	CREATE_DEBUGFS_FILE(version)
+	CREATE_DEBUGFS_FILE(subbuf_nr)
+	CREATE_DEBUGFS_FILE(subbuf_size)
+	CREATE_DEBUGFS_FILE(filters)
+	CREATE_DEBUGFS_FILE(sock_filters)
+
+#undef CREATE_DEBUGFS_FILE
+	return 0;
+fail:
+	remove_controls();
+	return -1;
+}
+
+static char *skbtrace_tracepoint_default_desc(struct
skbtrace_tracepoint *t)
+{
+	char *desc;
+	int n;
+
+	n = strlen(t->trace_name) + 64;
+	desc = kmalloc(n, GFP_KERNEL);
+	if (!desc)
+		return NULL;
+
+	snprintf(desc, n, "%s enabled:%d\n", t->trace_name, !!t->enabled);
+	return desc;
+}
+
+static char *skbtrace_tracepoint_desc(struct skbtrace_tracepoint *tp)
+{
+	if (tp->desc)
+		return tp->desc(tp);
+	return skbtrace_tracepoint_default_desc(tp);
+}
+
+static ssize_t enabled_read(struct file *filp, char __user *buffer,
+			    size_t count, loff_t *ppos)
+{
+	size_t ret, offset, len;
+	struct skbtrace_tracepoint *tp;
+	int af;
+	char *desc = NULL;
+
+	skbtrace_proto_load();
+
+	ret = offset = 0;
+	mutex_lock(&skbtrace_lock);
+	for (af = AF_UNSPEC; af < AF_MAX; af++) {
+		tp = af_tp_list[af];
+		while (tp && tp->trace_name) {
+			kfree(desc);
+			desc = skbtrace_tracepoint_desc(tp);
+			if (!desc)
+				return -ENOMEM;
+			len = strlen(desc);
+			offset += len;
+			if (offset <= *ppos) {
+				++tp;
+				continue;
+			}
+			if (count < len) {
+				ret = -EINVAL;
+				goto unlock;
+			}
+			if (copy_to_user(buffer, desc, len)) {
+				ret = -EFAULT;
+				goto unlock;
+			}
+			*ppos += len;
+			ret = len;
+			goto unlock;
+		}
+	}
+unlock:
+	kfree(desc);
+	mutex_unlock(&skbtrace_lock);
+
+	return ret;
+}
+
+static struct skbtrace_tracepoint *skbtrace_lookup_tp(char *name)
+{
+	int af;
+	struct skbtrace_tracepoint *tp;
+
+	for (af = AF_UNSPEC; af < AF_MAX; af++) {
+		tp = af_tp_list[af];
+		while (tp && tp->trace_name) {
+			if (!strcmp(name, tp->trace_name))
+				return tp;
+			++tp;
+		}
+	}
+
+	return NULL;
+}
+
+struct skbtrace_options_context {
+	char *name;
+	char *options;
+	struct skbtrace_tracepoint *primary;
+};
+
+struct option_handler {
+	char *key;
+	int (*handler)(struct skbtrace_options_context *ctx, char *val);
+};
+
+static int handle_primary_option(struct skbtrace_options_context *ctx,
char *val)
+{
+	ctx->primary = skbtrace_lookup_tp(val);
+	if (!ctx->primary)
+		return -EINVAL;
+	return 0;
+}
+
+static struct option_handler common_handlers[] = {
+	{
+		.key = "primary=",
+		.handler = handle_primary_option,
+	},
+	{
+		.key = NULL,
+	},
+};
+
+static int handle_options(char *event_spec, struct option_handler
*handlers,
+					struct skbtrace_options_context *ctx)
+{
+	char *option;
+
+	memset(ctx, 0, sizeof(*ctx));
+	ctx->options = strchr(event_spec, ',');
+	if (!ctx->options)
+		return 0;
+	*(ctx->options) = '\x0';
+	option = ++(ctx->options);
+
+	while (option && *option) {
+		char *end;
+		struct option_handler *h;
+
+		end = strchr(option, ',');
+		if (end)
+			*end = '\x0';
+		h = &handlers[0];
+		while (h->key) {
+			if (strstr(option, h->key) == option) {
+				int ret;
+				char *val;
+
+				val = option + strlen(h->key);
+				ret = h->handler(ctx, val);
+				if (!ret)
+					break;
+				else
+					return -EINVAL;
+			}
+			h++;
+		}
+		if (!h->key) {
+			if (end) {
+				*end = ',';
+				option = end + 1;
+			} else
+				break;
+		} else {
+			if (end) {
+				memmove(option, end + 1, strlen(end + 1) + 1);
+			} else
+				*option = '\x0';
+		}
+	}
+
+	return 0;
+}
+
+static int __enable_tp(struct skbtrace_tracepoint *tp,
+				struct skbtrace_options_context *ctx)
+{
+	int ret = 0;
+
+	if (tp->enabled)
+		return -EBUSY;
+
+	if (tp->enable)
+		tp->enable(tp);
+	ret = tracepoint_probe_register(tp->trace_name, tp->probe, tp);
+	if (!ret) {
+		tp->primary = ctx->primary;
+		if (tp->primary)
+			tp->primary->nr_secondary++;
+		tp->enabled = 1;
+	} else {
+		if (tp->disable)
+			tp->disable(tp);
+	}
+
+	return ret;
+}
+
+static int __disable_tp(struct skbtrace_tracepoint *tp)
+{
+	int ret;
+
+	if (!tp->enabled)
+		return -EINVAL;
+
+	ret = tracepoint_probe_unregister(tp->trace_name, tp->probe, tp);
+	if (ret)
+		return ret;
+
+	if (tp->disable)
+		tp->disable(tp);
+	if (tp->primary) {
+		secondary_buffer_put(&tp->primary->sec_buffer);
+		tp->primary->nr_secondary--;
+	}
+	tp->enabled = 0;
+	return 0;
+}
+
+static int skbtrace_enable_tp(char *event_spec)
+{
+	struct skbtrace_options_context ctx;
+	int ret;
+	struct skbtrace_tracepoint *tp;
+
+	ret = handle_options(event_spec, common_handlers, &ctx);
+	if (ret)
+		return ret;
+	ctx.name = event_spec;
+
+	mutex_lock(&skbtrace_lock);
+	if (!nr_skbtrace_enabled_tp) {
+		ret = create_channels();
+		if (ret)
+			goto unlock;
+	}
+
+	tp = skbtrace_lookup_tp(ctx.name);
+	if (!tp || tp->enabled) {
+		ret = -EINVAL;
+		goto unlock;
+	}
+
+	if (ctx.options && tp->setup_options) {
+		ret = tp->setup_options(tp, ctx.options);
+		if (ret)
+			goto unlock;
+	}
+
+	ret = __enable_tp(tp, &ctx);
+
+	if (ret && !nr_skbtrace_enabled_tp)
+		destroy_channels();
+	else if (!ret)
+		++nr_skbtrace_enabled_tp;
+
+unlock:
+	mutex_unlock(&skbtrace_lock);
+	return ret;
+}
+
+static int skbtrace_disable_all_tp(void)
+{
+	int ret, af;
+	struct skbtrace_tracepoint *tp;
+
+	/*
+	 * '-*' has two meanings:
+	 *
+	 *   (0) first time, it disables all tracepoints, and flush channels.
+	 *   (1) second time, it removes all channels.
+	 */
+
+	if (!nr_skbtrace_enabled_tp) {
+		skbtrace_filters_clean();
+		++skbtrace_session;
+		destroy_channels();
+		return 0;
+	}
+
+	ret = -EINVAL;
+	mutex_lock(&skbtrace_lock);
+	for (af = AF_UNSPEC; af < AF_MAX; af++) {
+		tp = af_tp_list[af];
+		while (tp && tp->trace_name) {
+			ret = __disable_tp(tp);
+			if (!ret)
+				--nr_skbtrace_enabled_tp;
+			++tp;
+		}
+	}
+	mutex_unlock(&skbtrace_lock);
+	flush_channels();
+
+	return ret;
+}
+
+/* The user given buffer should contains such like string:
+ *	(0) To enable a skbtrace event:	"TRACE_NAME,opt1=val1,opt2=val2,..."
+ *	(1) To disable all skbtrace events:"-*"
+ */
+static ssize_t enabled_write(struct file *filp, const char __user *buffer,
+			     size_t count, loff_t *ppos)
+{
+	char kbuf[TRACE_SPEC_MAX_LEN+1];
+	int ret;
+
+	skbtrace_proto_load();
+
+	if (count >= TRACE_SPEC_MAX_LEN)
+		return -EINVAL;
+	if (copy_from_user(kbuf, buffer, count))
+		return -EFAULT;
+	kbuf[count] = '\x0';
+
+	if (strcmp("-*", kbuf))
+		ret = skbtrace_enable_tp(&kbuf[0]);
+	else
+		ret = skbtrace_disable_all_tp();
+
+	return ret ?: count;
+}
+
+static int kmod_open(struct inode *inodep, struct file *filp)
+{
+	__module_get(THIS_MODULE);
+	return 0;
+}
+
+static int kmod_release(struct inode *inodep, struct file *filp)
+{
+	module_put(THIS_MODULE);
+	return 0;
+}
+
+static const struct file_operations enabled_fops = {
+	.owner =	THIS_MODULE,
+	.open =		kmod_open,
+	.release =	kmod_release,
+	.read =		enabled_read,
+	.write =	enabled_write,
+};
+
+static ssize_t dropped_read(struct file *filp, char __user *buffer,
+			    size_t count, loff_t *ppos)
+{
+
+	char buf[256];
+	unsigned long skbtrace_total_dropped[NR_CHANNELS] = {0, 0, 0};
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		skbtrace_total_dropped[HW] += skbtrace_dropped[HW][cpu];
+		skbtrace_total_dropped[SI] += skbtrace_dropped[SI][cpu];
+		skbtrace_total_dropped[SC] += skbtrace_dropped[SC][cpu];
+	}
+
+	snprintf(buf, sizeof(buf), "%lu %lu %lu\n",
+		skbtrace_total_dropped[HW],
+		skbtrace_total_dropped[SI],
+		skbtrace_total_dropped[SC]
+		);
+
+	return simple_read_from_buffer(buffer, count, ppos,
+				       buf, strlen(buf));
+}
+
+static ssize_t dropped_write(struct file *filp, const char __user *buffer,
+			    size_t count, loff_t *ppos)
+{
+	memset(skbtrace_dropped, 0, sizeof(skbtrace_dropped));
+	return count;
+}
+
+static const struct file_operations dropped_fops = {
+	.owner =	THIS_MODULE,
+	.open =		kmod_open,
+	.release =	kmod_release,
+	.read =		dropped_read,
+	.write =	dropped_write,
+};
+
+static ssize_t version_read(struct file *filp, char __user *buffer,
+			    size_t count, loff_t *ppos)
+{
+	return simple_read_from_buffer(buffer, count, ppos,
+				       SKBTRACE_VERSION "\n",
+					strlen(SKBTRACE_VERSION "\n"));
+}
+
+static const struct file_operations version_fops = {
+	.owner =	THIS_MODULE,
+	.open =		kmod_open,
+	.release =	kmod_release,
+	.read =		version_read,
+};
+
+static ssize_t subbuf_x_read(struct file *filp, char __user *buffer,
+			    size_t count, loff_t *ppos, int which)
+{
+	char buf[24];
+
+	sprintf(buf, "%d\n", which);
+	return simple_read_from_buffer(buffer, count, ppos,
+				       buf, strlen(buf));
+}
+
+static ssize_t subbuf_x_write(struct file *filp, const char __user *buffer,
+			    size_t count, loff_t *ppos,
+			    int *which, int min_val, int max_val)
+{
+	char buf[24];
+	int v;
+
+	if (nr_skbtrace_enabled_tp)
+		return -EBUSY;
+
+	if (!buffer || count > sizeof(buf) - 1)
+		return -EINVAL;
+	memset(buf, 0, sizeof(buf));
+	if (copy_from_user(buf, buffer, count))
+		return -EFAULT;
+	if (sscanf(buf, "%d", &v) != 1)
+		return -EINVAL;
+	if (v < min_val || v > max_val)
+		return -EINVAL;
+
+	*which = v;
+	return count;
+}
+
+static ssize_t subbuf_nr_read(struct file *filp, char __user *buffer,
+			    size_t count, loff_t *ppos)
+{
+	return subbuf_x_read(filp, buffer, count, ppos, subbuf_nr);
+}
+
+static ssize_t subbuf_nr_write(struct file *filp, const char __user
*buffer,
+			    size_t count, loff_t *ppos)
+{
+	return subbuf_x_write(filp, buffer, count, ppos, &subbuf_nr,
+			SKBTRACE_MIN_SUBBUF_NR, SKBTRACE_MAX_SUBBUF_NR);
+}
+
+static const struct file_operations subbuf_nr_fops = {
+	.owner =	THIS_MODULE,
+	.open =		kmod_open,
+	.release =	kmod_release,
+	.read =		subbuf_nr_read,
+	.write =	subbuf_nr_write,
+};
+
+static ssize_t subbuf_size_read(struct file *filp, char __user *buffer,
+			    size_t count, loff_t *ppos)
+{
+	return subbuf_x_read(filp, buffer, count, ppos, subbuf_size);
+}
+
+static ssize_t subbuf_size_write(struct file *filp, const char __user
*buffer,
+			    size_t count, loff_t *ppos)
+{
+	return subbuf_x_write(filp, buffer, count, ppos, &subbuf_size,
+			SKBTRACE_MIN_SUBBUF_SIZE, SKBTRACE_MAX_SUBBUF_SIZE);
+}
+
+static const struct file_operations subbuf_size_fops = {
+	.owner =	THIS_MODULE,
+	.open =		kmod_open,
+	.release =	kmod_release,
+	.read =		subbuf_size_read,
+	.write =	subbuf_size_write,
+};
+
+struct sk_buff* skbtrace_get_twsk_filter_skb(struct inet_timewait_sock *tw)
+{
+	unsigned int cpu;
+	struct sk_buff **p_skb;
+	int ret;
+	struct skbtrace_ops *ops;
+
+	local_bh_disable();
+
+	ops = skbtrace_ops_get(tw->tw_family);
+	if (!ops || !ops->filter_skb) {
+		local_bh_enable();
+		return NULL;
+	}
+
+	cpu = smp_processor_id();
+	p_skb = per_cpu_ptr(sock_filter_skb, cpu);
+	if (unlikely(!*p_skb)) {
+		*p_skb = alloc_skb(1500, GFP_ATOMIC);
+		if (!*p_skb) {
+			local_bh_enable();
+			return NULL;
+		}
+	}
+
+	ret = ops->tw_filter_skb(tw, *p_skb);
+	if (ret < 0) {
+		skbtrace_put_twsk_filter_skb(*p_skb);
+		return NULL;
+	}
+
+	return *p_skb;
+}
+EXPORT_SYMBOL_GPL(skbtrace_get_twsk_filter_skb);
+
+struct sk_buff* skbtrace_get_sock_filter_skb(struct sock *sk)
+{
+	unsigned int cpu;
+	struct sk_buff **p_skb;
+	int ret;
+	struct skbtrace_ops *ops;
+
+	local_bh_disable();
+
+	ops = skbtrace_ops_get(sk->sk_family);
+	if (!ops || !ops->filter_skb) {
+		local_bh_enable();
+		return NULL;
+	}
+
+	cpu = smp_processor_id();
+	p_skb = per_cpu_ptr(sock_filter_skb, cpu);
+	if (unlikely(!*p_skb)) {
+		*p_skb = alloc_skb(1500, GFP_ATOMIC);
+		if (!*p_skb) {
+			local_bh_enable();
+			return NULL;
+		}
+	}
+
+	ret = ops->filter_skb(sk, *p_skb);
+	if (ret < 0) {
+		skbtrace_put_sock_filter_skb(*p_skb);
+		return NULL;
+	}
+
+	return *p_skb;
+}
+EXPORT_SYMBOL_GPL(skbtrace_get_sock_filter_skb);
+
+static ssize_t sk_filter_read(struct sock_fprog *fprog, char __user
*buffer,
+							    size_t count)
+{
+	int sz_filter;
+	struct sock_filter __user *user_filter;
+
+	if (!fprog || !fprog->filter)
+		return -EINVAL;
+	sz_filter = fprog->len * sizeof(struct sock_filter);
+	if (count < sizeof(struct sock_fprog) + sz_filter)
+		return -EINVAL;
+
+	if (copy_to_user(buffer, &fprog->len, sizeof(short)))
+		return -EFAULT;
+
+	if (copy_from_user(&user_filter,
+			buffer + sizeof(short), sizeof(user_filter)))
+		return -EFAULT;
+	if (copy_to_user(user_filter, fprog->filter, sz_filter))
+		return -EFAULT;
+
+	return sizeof(struct sock_fprog) + sz_filter;
+}
+
+static ssize_t sk_filter_write(struct sock_fprog *sk_fprog,
+				struct sk_filter **sk_filter,
+				const char __user *buffer, size_t count)
+{
+	int sz_filter, ret;
+	struct sock_filter __user *user_filter;
+
+	if (count < sizeof(struct sock_fprog) || sk_fprog->filter)
+		return -EINVAL;
+	if (copy_from_user(sk_fprog, buffer, sizeof(struct sock_fprog)))
+		return -EFAULT;
+	sz_filter = sk_fprog->len * sizeof(struct sock_filter);
+	user_filter = sk_fprog->filter;
+
+	sk_fprog->filter = kzalloc(sz_filter, GFP_KERNEL);
+	if (!sk_fprog->filter)
+		ret = -ENOMEM;
+
+	ret = -EFAULT;
+	if (!copy_from_user(sk_fprog->filter, user_filter, sz_filter)) {
+		ret = sk_unattached_filter_create(sk_filter, sk_fprog);
+		if (ret) {
+			reset_filter(sk_fprog, sk_filter);
+			return ret;
+		}
+	}
+	static_key_slow_inc(&skbtrace_filters_enabled);
+	return sizeof(struct sock_fprog) + sz_filter;
+}
+
+static ssize_t filters_read(struct file *filp, char __user *buffer,
+			size_t count, loff_t *ppos, struct sock_fprog *fprog)
+{
+	return sk_filter_read(fprog, buffer, count);
+}
+
+static ssize_t skb_filters_read(struct file *filp, char __user *buffer,
+						size_t count, loff_t *ppos)
+{
+	return filters_read(filp, buffer, count, ppos, &skb_filter_fprog);
+}
+
+static ssize_t sock_filters_read(struct file *filp, char __user *buffer,
+						size_t count, loff_t *ppos)
+{
+	return filters_read(filp, buffer, count, ppos, &sock_filter_fprog);
+}
+
+static ssize_t filters_write(struct file *filp, const char __user *buffer,
+						size_t count, loff_t *ppos,
+			struct sock_fprog *fprog, struct sk_filter **filter)
+
+{
+	skbtrace_proto_load();
+
+	if (nr_skbtrace_enabled_tp)
+		return -EBUSY;
+	reset_filter(fprog, filter);
+	return sk_filter_write(fprog, filter, buffer, count);
+}
+
+static ssize_t skb_filters_write(struct file *filp, const char __user
*buffer,
+						size_t count, loff_t *ppos)
+{
+	return filters_write(filp, buffer, count, ppos,
+			&skb_filter_fprog, &skbtrace_skb_filter);
+}
+
+static ssize_t sock_filters_write(struct file *filp, const char __user
*buffer,
+						size_t count, loff_t *ppos)
+{
+	if (unlikely(!++skbtrace_sock_filter_id))
+		skbtrace_sock_filter_id = 1;
+	return filters_write(filp, buffer, count, ppos,
+				&sock_filter_fprog, &skbtrace_sock_filter);
+}
+
+static const struct file_operations filters_fops = {
+	.owner =	THIS_MODULE,
+	.open =		kmod_open,
+	.release =	kmod_release,
+	.read =		skb_filters_read,
+	.write =	skb_filters_write,
+};
+
+static const struct file_operations sock_filters_fops = {
+	.owner =	THIS_MODULE,
+	.open =		kmod_open,
+	.release =	kmod_release,
+	.read =		sock_filters_read,
+	.write =	sock_filters_write,
+};
+
+static void reset_filter(struct sock_fprog *fprog, struct sk_filter
**filter)
+{
+	if (fprog->filter)
+		kfree(fprog->filter);
+	memset(fprog, 0, sizeof(struct sock_fprog));
+
+	if (*filter) {
+		static_key_slow_dec(&skbtrace_filters_enabled);
+		sk_unattached_filter_destroy(*filter);
+		*filter = NULL;
+	}
+}
+
+static void skbtrace_filters_clean(void)
+{
+	reset_filter(&sock_filter_fprog, &skbtrace_sock_filter);
+	reset_filter(&skb_filter_fprog, &skbtrace_skb_filter);
+}
+
+static void clean_skbtrace_filters(void)
+{
+	unsigned int cpu;
+
+	if (skb_filter_fprog.filter)
+		kfree(skb_filter_fprog.filter);
+	if (skbtrace_skb_filter) {
+		static_key_slow_dec(&skbtrace_filters_enabled);
+		sk_unattached_filter_destroy(skbtrace_skb_filter);
+	}
+
+	if (sock_filter_fprog.filter)
+		kfree(sock_filter_fprog.filter);
+	if (skbtrace_sock_filter) {
+		static_key_slow_dec(&skbtrace_filters_enabled);
+		sk_unattached_filter_destroy(skbtrace_sock_filter);
+	}
+
+	for_each_possible_cpu(cpu) {
+		struct sk_buff **p_skb;
+
+		p_skb = per_cpu_ptr(sock_filter_skb, cpu);
+		if (*p_skb)
+			kfree_skb(*p_skb);
+	}
+	free_percpu(sock_filter_skb);
+}
+
+static int setup_skbtrace_filters(void)
+{
+	unsigned int cpu, err;
+
+	skbtrace_sock_filter_id = random32();
+
+	skbtrace_filters_clean();
+
+	sock_filter_skb = alloc_percpu(struct sk_buff*);
+	err = 0;
+	for_each_possible_cpu(cpu) {
+		struct sk_buff **p_skb;
+
+		p_skb = per_cpu_ptr(sock_filter_skb, cpu);
+		if (cpu_online(cpu)) {
+			*p_skb = alloc_skb(1500, GFP_KERNEL);
+			if (!*p_skb)
+				err = 1;
+		} else
+			*p_skb = NULL;
+	}
+
+	if (err) {
+		clean_skbtrace_filters();
+		return -ENOMEM;
+	}
+	return 0;
+}
+
+static int skbtrace_init(void)
+{
+	mutex_init(&skbtrace_lock);
+	if (!skbtrace_session)
+		skbtrace_session = random32();
+
+	if (setup_skbtrace_filters() < 0)
+		return -ENOMEM;
+
+	if (skbtrace_events_common_init())
+		return -ENODEV;
+
+	skbtrace_dentry = debugfs_create_dir(SKBTRACE_DIR, NULL);
+	if (!skbtrace_dentry)
+		return -ENOMEM;
+
+	if (create_controls()) {
+		debugfs_remove(skbtrace_dentry);
+		return -ENOMEM;
+	}
+
+	should_load_proto = true;
+	return 0;
+}
+
+static void skbtrace_exit(void)
+{
+	skbtrace_disable_all_tp(); /* disable all enabled tracepoints */
+	skbtrace_disable_all_tp(); /* remove channels in debugfs at 2nd time */
+	if (unlikely(nr_skbtrace_enabled_tp))
+		pr_err("skbtrace: failed to clean tracepoints.\n");
+	remove_controls();
+	debugfs_remove(skbtrace_dentry);
+	clean_skbtrace_filters();
+}
+
+module_init(skbtrace_init);
+module_exit(skbtrace_exit);
+MODULE_LICENSE("GPL");
diff --git a/net/core/skbtrace-events-common.c
b/net/core/skbtrace-events-common.c
new file mode 100644
index 0000000..30a3730
--- /dev/null
+++ b/net/core/skbtrace-events-common.c
@@ -0,0 +1,68 @@
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
+	struct skbtrace_skb_rps_info_blk blk, *b;
+	struct flow_keys keys;
+
+	b = skbtrace_block_get(t, NULL, &blk);
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
+	skbtrace_probe(t, NULL, &b->blk);
+SKBTRACE_SKB_EVENT_END
+
+static struct skbtrace_tracepoint common[] = {
+	{
+		.trace_name = "skb_rps_info",
+		.action = skbtrace_action_skb_rps_info,
+		.block_size = sizeof(struct skbtrace_skb_rps_info_blk),
+		.probe = skbtrace_skb_rps_info,
+	},
+	EMPTY_SKBTRACE_TP
+};
+
+int skbtrace_events_common_init(void)
+{
+	return skbtrace_register_proto(AF_UNSPEC, common, NULL);
+}
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e33ebae..15954ae 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -70,6 +70,7 @@
 #include <asm/uaccess.h>
 #include <trace/events/skb.h>
 #include <linux/highmem.h>
+#include <linux/skbtrace.h>

 struct kmem_cache *skbuff_head_cache __read_mostly;
 static struct kmem_cache *skbuff_fclone_cache __read_mostly;
@@ -700,6 +701,10 @@ static void __copy_skb_header(struct sk_buff *new,
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
index a6000fb..b818961 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -132,8 +132,10 @@
 #include <net/netprio_cgroup.h>

 #include <linux/filter.h>
+#include <linux/skbtrace.h>

 #include <trace/events/sock.h>
+#include <trace/events/skbtrace_common.h>

 #ifdef CONFIG_INET
 #include <net/tcp.h>
@@ -1272,6 +1274,7 @@ struct sock *sk_alloc(struct net *net, int family,
gfp_t priority,

 		sock_update_classid(sk);
 		sock_update_netprioidx(sk, current);
+		sock_skbtrace_reset(sk);
 	}

 	return sk;
@@ -1292,6 +1295,8 @@ static void __sk_free(struct sock *sk)
 		RCU_INIT_POINTER(sk->sk_filter, NULL);
 	}

+	skbtrace_context_destroy(&sk->sk_skbtrace);
+
 	sock_disable_timestamp(sk, SK_FLAGS_TIMESTAMP);

 	if (atomic_read(&sk->sk_omem_alloc))
@@ -1440,6 +1445,8 @@ struct sock *sk_clone_lock(const struct sock *sk,
const gfp_t priority)

 		if (newsk->sk_flags & SK_FLAGS_TIMESTAMP)
 			net_enable_timestamp();
+
+		sock_skbtrace_reset(newsk);
 	}
 out:
 	return newsk;
@@ -2124,6 +2131,7 @@ void sk_reset_timer(struct sock *sk, struct
timer_list* timer,
 {
 	if (!mod_timer(timer, expires))
 		sock_hold(sk);
+	trace_sk_timer(sk, timer, skbtrace_sk_timer_reset);
 }
 EXPORT_SYMBOL(sk_reset_timer);

@@ -2131,6 +2139,7 @@ void sk_stop_timer(struct sock *sk, struct
timer_list* timer)
 {
 	if (timer_pending(timer) && del_timer(timer))
 		__sock_put(sk);
+	trace_sk_timer(sk, timer, skbtrace_sk_timer_stop);
 }
 EXPORT_SYMBOL(sk_stop_timer);
