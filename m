From: Li Yu <raise.sail@gmail.com>
Subject: [RFC][PATCH 4/4] skbtrace: four TCP/IP tracepoints tcp/icsk_connection,tcp_sendlim,tcp_congestion
Date: Wed, 11 Jul 2012 10:18:04 +0800
Message-ID: <4FFCE25C.5080309@gmail.com>
References: <4FFBC6B6.2000600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:35258 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754682Ab2GKCSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 22:18:10 -0400
Received: by yenl2 with SMTP id l2so745376yen.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 19:18:10 -0700 (PDT)
In-Reply-To: <4FFBC6B6.2000600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yu <bingtian.ly@taobao.com>

This implements four skbtrace traces for TCP.

(1) tcp/icsk_connection is for trace basic state
    migration of TCP protocol, e.g. SYN_RECV ->
    ESTABLISHED.
(2) tcp_sendlim is for trace TCP sending limitation.
    e.g. congestion window is limited to send segments.

(3) tcp_congestion is for trace TCP congestion events,
    e.g. Loss, FRTO and etc.

Thanks.

Sign-off-by: Li Yu <bingtian.ly@taobao.com>
---
 include/linux/skbtrace.h             |    3
 include/linux/skbtrace_api.h         |    1
 include/net/skbtrace_api_ipv4.h      |  124 ++++++++++++
 include/trace/events/skbtrace.h      |    1
 include/trace/events/skbtrace_ipv4.h |   49 ++++
 net/core/net-traces.c                |    4
 net/ipv4/Kconfig                     |    8
 net/ipv4/Makefile                    |    1
 net/ipv4/inet_connection_sock.c      |    2
 net/ipv4/inet_timewait_sock.c        |    3
 net/ipv4/skbtrace-ipv4.c             |  345
+++++++++++++++++++++++++++++++++++
 net/ipv4/tcp.c                       |    5
 net/ipv4/tcp_input.c                 |   12 +
 net/ipv4/tcp_ipv4.c                  |    4
 net/ipv4/tcp_minisocks.c             |    4
 net/ipv4/tcp_output.c                |   61 ++++--
 16 files changed, 610 insertions(+), 17 deletions(-)

diff --git a/include/linux/skbtrace.h b/include/linux/skbtrace.h
index 34b9144..b35d7b3 100644
--- a/include/linux/skbtrace.h
+++ b/include/linux/skbtrace.h
@@ -67,6 +67,9 @@ extern atomic64_t skbtrace_event_seq;
 struct skbtrace_context {
 	union {
 		struct skbtrace_block blk;
+		struct skbtrace_tcp_cong_blk tcp_cong;
+		struct skbtrace_tcp_conn_blk tcp_conn;
+		struct skbtrace_tcp_sendlim_blk tcp_sendlim;
 	};
 };

diff --git a/include/linux/skbtrace_api.h b/include/linux/skbtrace_api.h
index 7489856..281a868 100644
--- a/include/linux/skbtrace_api.h
+++ b/include/linux/skbtrace_api.h
@@ -68,5 +68,6 @@ struct skbtrace_block {
 } __packed;

 #include <net/skbtrace_api_common.h>
+#include <net/skbtrace_api_ipv4.h>

 #endif
diff --git a/include/net/skbtrace_api_ipv4.h
b/include/net/skbtrace_api_ipv4.h
new file mode 100644
index 0000000..a3e6462
--- /dev/null
+++ b/include/net/skbtrace_api_ipv4.h
@@ -0,0 +1,124 @@
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
+#ifndef _NET_SKBTRACE_API_IPV4_H
+#define _NET_SKBTRACE_API_IPV4_H
+
+#include <linux/types.h>
+
+#ifdef __KERNEL__
+#include <linux/in.h>
+#include <linux/in6.h>
+#endif
+
+/********************* TCP section *********************/
+
+/* skbtrace_block->action */
+enum {
+	skbtrace_action_tcp_min		= 101,
+	skbtrace_action_tcp_congestion	= 101,
+	skbtrace_action_tcp_connection	= 102,
+	skbtrace_action_tcp_sendlimit	= 103,
+	skbtrace_action_tcp_max		= 199,
+};
+
+/* TCP congestion event (101) */
+
+/* flags */
+enum {
+	skbtrace_tcp_cong_cwr		= 4,
+	skbtrace_tcp_cong_loss		= 5,
+	skbtrace_tcp_cong_fastrtx	= 6,
+	skbtrace_tcp_cong_frto		= 7,
+	skbtrace_tcp_cong_frto_loss	= 8,
+	skbtrace_tcp_cong_leave		= 9,
+};
+
+struct skbtrace_tcp_cong_blk {
+	struct skbtrace_block blk;
+	__u32	rcv_rtt;
+	__u32	rto;
+	__u32	cwnd;
+	__u32	sndnxt;
+	__u32	snduna;
+} __packed;
+
+/* TCP basic connection events (101) */
+struct skbtrace_tcp_conn_blk {
+	struct skbtrace_block blk;
+	union {
+		struct {
+			struct sockaddr local;
+			struct sockaddr peer;
+		};
+		struct {
+			struct sockaddr_in local;
+			struct sockaddr_in peer;
+		} inet;
+		struct {
+			struct sockaddr_in6 local;
+			struct sockaddr_in6 peer;
+		} inet6;
+	} addr;
+} __packed;
+
+/* TCP send limit event (102) */
+enum {
+	skbtrace_tcp_sndlim_cwnd	= 4,
+	skbtrace_tcp_sndlim_swnd	= 5,
+	skbtrace_tcp_sndlim_nagle	= 6,
+	skbtrace_tcp_sndlim_tso		= 7,
+	skbtrace_tcp_sndlim_frag	= 8,	/* most likely ENOMEM errors */
+	skbtrace_tcp_sndlim_pushone	= 9,
+	skbtrace_tcp_sndlim_other	= 10,
+	skbtrace_tcp_sndlim_ok		= 11,
+};
+
+
+/* val member:
+ *    skbtrace_tcp_sndlim_other: the return value of tcp_transmit_skb()
+ *    skbtrace_tcp_sndlim_ok: total sent pkts
+ *    other cases: send limit occurs under MTU probe if 1, otherwise,
it is 0
+ */
+struct skbtrace_tcp_sendlim_blk {
+	struct skbtrace_block blk;
+	__u32 val;
+	__u32 count;
+	struct timespec begin;
+	__u32	snd_ssthresh;
+	__u32	snd_cwnd;
+	__u32	snd_cwnd_cnt;
+	__u32	snd_wnd;
+} __packed;
+
+/********************* icsk section *********************/
+
+/* skbtrace_block->action */
+enum {
+	skbtrace_action_icsk_min	= 201,
+	skbtrace_action_icsk_connection	= 201,
+	skbtrace_action_icsk_max	= 299,
+};
+
+/* Use skbtrace_tcp_conn_blk */
+
+#endif
diff --git a/include/trace/events/skbtrace.h
b/include/trace/events/skbtrace.h
index bf8c2cb..91567bf 100644
--- a/include/trace/events/skbtrace.h
+++ b/include/trace/events/skbtrace.h
@@ -27,5 +27,6 @@
 #include <linux/tracepoint.h>

 #include <trace/events/skbtrace_common.h>
+#include <trace/events/skbtrace_ipv4.h>

 #endif
diff --git a/include/trace/events/skbtrace_ipv4.h
b/include/trace/events/skbtrace_ipv4.h
new file mode 100644
index 0000000..73a9fb0
--- /dev/null
+++ b/include/trace/events/skbtrace_ipv4.h
@@ -0,0 +1,49 @@
+ /*
+ *  skbtrace - sk_buff trace utilty
+ *
+ *	The IPv4 related skbtrace events
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
+ * Thanks for Web10G project here, some sources reference to it.
+ *
+ * 2012 Li Yu <bingtian.ly@taobao.com>
+ *
+ */
+
+#if !defined(_TRACE_EVENTS_SKBTRACE_IPV4_H)
+#define _TRACE_EVENTS_SKBTRACE_IPV4_H
+
+#include <linux/tracepoint.h>
+
+struct sock;
+
+DECLARE_TRACE(icsk_connection,
+	TP_PROTO(struct sock *sk, __u32 state),
+	TP_ARGS(sk, state));
+
+DECLARE_TRACE(tcp_congestion,
+	TP_PROTO(struct sock *sk, int reason, int prior_state),
+	TP_ARGS(sk, reason, prior_state));
+
+DECLARE_TRACE(tcp_connection,
+	TP_PROTO(void *sk, __u32 state),
+	TP_ARGS(sk, state));
+
+DECLARE_TRACE(tcp_sendlimit,
+	TP_PROTO(struct sock *sk, int reason, int val),
+	TP_ARGS(sk, reason, val));
+
+#endif
diff --git a/net/core/net-traces.c b/net/core/net-traces.c
index d86a58b..95ad083 100644
--- a/net/core/net-traces.c
+++ b/net/core/net-traces.c
@@ -45,5 +45,9 @@ EXPORT_TRACEPOINT_SYMBOL_GPL(napi_poll);
 	EXPORT_TRACEPOINT_SYMBOL_GPL(name);

 NEW_SKBTRACE_TP(skb_rps_info);
+NEW_SKBTRACE_TP(tcp_congestion);
+NEW_SKBTRACE_TP(tcp_connection);
+NEW_SKBTRACE_TP(icsk_connection);
+NEW_SKBTRACE_TP(tcp_sendlimit);

 #endif
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 20f1cb5..feb5e28 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -415,6 +415,14 @@ config INET_UDP_DIAG
 	  Support for UDP socket monitoring interface used by the ss tool.
 	  If unsure, say Y.

+config SKBTRACE_IPV4
+	tristate "TCP/IPv4 protocol suite support for skbtrace"
+	depends on SKBTRACE
+	default m
+	---help---
+	  Support for IPv4 part of skbtrace. which only contains TCP/IPv4
+	  specific events.
+
 menuconfig TCP_CONG_ADVANCED
 	bool "TCP: advanced congestion control"
 	---help---
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index ff75d3b..4b03aef 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -50,6 +50,7 @@ obj-$(CONFIG_TCP_CONG_YEAH) += tcp_yeah.o
 obj-$(CONFIG_TCP_CONG_ILLINOIS) += tcp_illinois.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR_KMEM) += tcp_memcontrol.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
+obj-${CONFIG_SKBTRACE_IPV4} += skbtrace-ipv4.o

 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o
diff --git a/net/ipv4/inet_connection_sock.c
b/net/ipv4/inet_connection_sock.c
index 034ddbe..a69becb 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -15,6 +15,7 @@

 #include <linux/module.h>
 #include <linux/jhash.h>
+#include <trace/events/skbtrace_ipv4.h>

 #include <net/inet_connection_sock.h>
 #include <net/inet_hashtables.h>
@@ -702,6 +703,7 @@ int inet_csk_listen_start(struct sock *sk, const int
nr_table_entries)
 		sk_dst_reset(sk);
 		sk->sk_prot->hash(sk);

+		trace_icsk_connection(sk, TCP_LISTEN);
 		return 0;
 	}

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 2784db3..9363a6b 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -12,6 +12,8 @@
 #include <linux/kmemcheck.h>
 #include <linux/slab.h>
 #include <linux/module.h>
+#include <linux/skbtrace.h>
+#include <trace/events/skbtrace_ipv4.h>
 #include <net/inet_hashtables.h>
 #include <net/inet_timewait_sock.h>
 #include <net/ip.h>
@@ -205,6 +207,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const
struct sock *sk, const int stat
 		atomic_set(&tw->tw_refcnt, 0);
 		inet_twsk_dead_node_init(tw);
 		__module_get(tw->tw_prot->owner);
+		trace_tcp_connection(tw, state + TCP_MAX_STATES);
 	}

 	return tw;
diff --git a/net/ipv4/skbtrace-ipv4.c b/net/ipv4/skbtrace-ipv4.c
new file mode 100644
index 0000000..ed486be
--- /dev/null
+++ b/net/ipv4/skbtrace-ipv4.c
@@ -0,0 +1,345 @@
+/*
+ *  skbtrace - sk_buff trace for TCP/IPv4 protocol suite support
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
+#include <linux/inet.h>
+
+#include <linux/skbtrace.h>
+#include <linux/tcp.h>
+#include <net/inet_common.h>
+#include <net/inet_connection_sock.h>
+#include <net/tcp.h>
+
+static void skbtrace_tcp_congestion(struct skbtrace_tracepoint *t,
+			struct sock *sk, int reason, int prior_state)
+SKBTRACE_SOCK_EVENT_BEGIN
+	struct skbtrace_context *ctx;
+	struct skbtrace_tcp_cong_blk blk, *b;
+	struct tcp_sock *tp;
+
+	if (skbtrace_tcp_cong_leave == reason &&
+			inet_csk(sk)->icsk_ca_state == TCP_CA_Open)
+		return;
+
+	local_bh_disable();
+	ctx = skbtrace_context_get(sk);
+	if (ctx) {
+		if (skbtrace_action_tcp_congestion != ctx->blk.action)
+			skbtrace_probe(&ctx->blk);
+		b = &ctx->tcp_cong;
+	} else
+		b = &blk;
+
+	tp = tcp_sk(sk);
+	INIT_SKBTRACE_BLOCK(&b->blk, tp,
+			skbtrace_action_tcp_congestion,
+			1 << reason,
+			sizeof(*b));
+	b->cwnd = tp->snd_cwnd * tp->mss_cache;
+	b->rcv_rtt = tp->rcv_rtt_est.rtt;
+	b->rto = inet_csk(sk)->icsk_rto;
+	b->snduna = tp->snd_una;
+	b->sndnxt = tp->snd_nxt;
+	skbtrace_probe(&b->blk);
+	local_bh_enable();
+SKBTRACE_SOCK_EVENT_END
+
+static void skbtrace_tcp_connection(struct skbtrace_tracepoint *t,
+							void *ptr, u32 state)
+{
+	struct sock *sk = ptr;
+	struct inet_timewait_sock *tw = inet_twsk(ptr);
+
+	switch (state) {
+	case TCP_TIME_WAIT + TCP_MAX_STATES:
+	case TCP_FIN_WAIT2 + TCP_MAX_STATES:
+		{
+			struct skbtrace_tcp_conn_blk blk;
+
+			state -= TCP_MAX_STATES;
+			INIT_SKBTRACE_BLOCK(&blk.blk, tw,
+				skbtrace_action_tcp_connection,
+				1 << (state + skbtrace_flags_reserved_max),
+				sizeof(blk));
+			blk.addr.inet.local.sin_family = AF_INET;
+			blk.addr.inet.local.sin_port = tw->tw_sport;
+			blk.addr.inet.local.sin_addr.s_addr = tw->tw_rcv_saddr;
+			blk.addr.inet.peer.sin_family = AF_INET;
+			blk.addr.inet.peer.sin_port = tw->tw_dport;
+			blk.addr.inet.peer.sin_addr.s_addr = tw->tw_daddr;
+			skbtrace_probe(&blk.blk);
+			break;
+		}
+	case TCP_ESTABLISHED:
+	case TCP_FIN_WAIT1:
+	case TCP_CLOSE:
+	case TCP_CLOSE_WAIT:
+	case TCP_LAST_ACK:
+	case TCP_SYN_SENT:
+	case TCP_SYN_RECV:
+	case TCP_CLOSING:
+		{
+			struct skbtrace_context *ctx;
+			struct skbtrace_tcp_conn_blk blk, *b;
+
+			local_bh_disable();
+			b = &blk;
+			ctx = skbtrace_context_get(sk);
+			if (ctx) {
+				if (skbtrace_action_tcp_connection
+							!= ctx->blk.action)
+					skbtrace_probe(&ctx->blk);
+				b = &ctx->tcp_conn;
+			}
+			INIT_SKBTRACE_BLOCK(&b->blk, ptr,
+				skbtrace_action_tcp_connection,
+				1 << (state + skbtrace_flags_reserved_max),
+				sizeof(blk));
+			__inet_sock_getname(sk, &b->addr.local, NULL, 0);
+			if (TCP_LISTEN != state)
+				__inet_sock_getname(sk, &b->addr.peer, NULL, 1);
+			skbtrace_probe(&b->blk);
+			local_bh_enable();
+			break;
+		}
+	}
+}
+
+static void skbtrace_icsk_connection(struct skbtrace_tracepoint *t,
+						struct sock *sk, u32 state)
+SKBTRACE_SOCK_EVENT_BEGIN
+	struct skbtrace_context *ctx;
+	struct skbtrace_tcp_conn_blk blk, *b;
+
+	if (TCP_LISTEN != state)
+		return;
+
+	local_bh_disable();
+	ctx = skbtrace_context_get(sk);
+	if (ctx) {
+		if (skbtrace_action_icsk_connection != ctx->blk.action)
+			skbtrace_probe(&ctx->blk);
+		b = &ctx->tcp_conn;
+	} else
+		b = &blk;
+	INIT_SKBTRACE_BLOCK(&b->blk, sk,
+				skbtrace_action_icsk_connection,
+				1 << (state + skbtrace_flags_reserved_max),
+				sizeof(blk));
+	__inet_sock_getname(sk, &b->addr.local, NULL, 0);
+	skbtrace_probe(&b->blk);
+	local_bh_enable();
+SKBTRACE_SOCK_EVENT_END
+
+static const char * const skbtrace_tcp_sendlimit_options[] = {
+	"cwnd",
+	"swnd",
+	"nagle",
+	"tso",
+	"frag",
+	"pushone",
+	"other",
+	"ok",
+};
+
+static const int skbtrace_tcp_sendlimit_masks[] = {
+	skbtrace_tcp_sndlim_cwnd,
+	skbtrace_tcp_sndlim_swnd,
+	skbtrace_tcp_sndlim_nagle,
+	skbtrace_tcp_sndlim_tso,
+	skbtrace_tcp_sndlim_frag,
+	skbtrace_tcp_sndlim_pushone,
+	skbtrace_tcp_sndlim_other,
+	skbtrace_tcp_sndlim_ok,
+};
+
+static int skbtrace_tcp_sendlimit_setopt(struct skbtrace_tracepoint *t,
+						char *name, char *options)
+{
+	unsigned long mask = 0UL;
+	char *cur;
+	int ret = 0;
+
+	if (options) {
+		if (strncmp(options, "skip=", sizeof("skip=") - 1)) {
+			options = NULL;
+			ret = -EINVAL;
+		} else
+			options += sizeof("skip=") - 1;
+	}
+
+	if (!options || '\x0' == *options)
+		goto quit;
+
+	mask = 0UL;
+	cur = strsep(&options, ":");
+	while (cur) {
+		int i, nr_options;
+
+		nr_options = sizeof(skbtrace_tcp_sendlimit_masks)/sizeof(int);
+		for (i = 0; i < nr_options; i++) {
+			if (!strcmp(cur, skbtrace_tcp_sendlimit_options[i])) {
+				mask |= (1 << skbtrace_tcp_sendlimit_masks[i]);
+				break;
+			}
+		}
+		if (i >= nr_options) {
+			mask = 0UL;
+			ret = -EINVAL;
+		}
+		cur = strsep(&options, ":");
+	}
+
+quit:
+	t->private = (void *)(mask);
+	return ret;
+}
+
+static char *skbtrace_tcp_sendlimit_desc(struct skbtrace_tracepoint *t)
+{
+	char *desc;
+	unsigned long mask = (unsigned long)t->private;
+	int i, nr_options, copied;
+
+	desc = kmalloc(strlen(t->name) + 128, GFP_KERNEL);
+	if (!desc)
+		return NULL;
+
+	copied = sprintf(desc, "%s enabled:%d skip=", t->name, t->enabled);
+	nr_options = sizeof(skbtrace_tcp_sendlimit_masks)/sizeof(int);
+	for (i = 0; i < nr_options; i++) {
+		int this_n;
+		const char *this_p;
+
+		this_n = skbtrace_tcp_sendlimit_masks[i];
+		this_p = skbtrace_tcp_sendlimit_options[i];
+		if (t->enabled && (mask & (1 << this_n)))
+			copied += sprintf(desc + copied, "%s,", this_p);
+		else if (!t->enabled)
+			copied += sprintf(desc + copied, "%s,", this_p);
+	}
+
+	sprintf(desc + copied, "\n");
+	return desc;
+}
+
+static inline void tcp_sendlimit_block_setup(struct
skbtrace_tcp_sendlim_blk *b,
+					struct sock *sk, int reason, int val)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	INIT_SKBTRACE_BLOCK(&b->blk, tp,
+			skbtrace_action_tcp_sendlimit,
+			1 << reason,
+			sizeof(*b));
+
+	b->val = val;
+	b->count = 1;
+	b->begin = current_kernel_time();
+
+	b->snd_ssthresh = tp->snd_ssthresh;
+	b->snd_cwnd = tp->snd_cwnd;
+	b->snd_cwnd_cnt = tp->snd_cwnd_cnt;
+	b->snd_wnd = tp->snd_wnd;
+}
+
+static void skbtrace_tcp_sendlimit(struct skbtrace_tracepoint *t,
+		struct sock *sk, int reason, int val)
+SKBTRACE_SOCK_EVENT_BEGIN
+	struct skbtrace_context *ctx;
+	unsigned long mask = (unsigned long)t->private;
+
+	if (mask & (1<<reason))
+		return;
+
+	if (skbtrace_tcp_sndlim_ok == reason && !val)
+		return;
+
+	local_bh_disable();
+	ctx = skbtrace_context_get(sk);
+	if (unlikely(!ctx)) { /* no saved context, just fire up */
+		struct skbtrace_tcp_sendlim_blk blk;
+
+		tcp_sendlimit_block_setup(&blk, sk, reason, val);
+		skbtrace_probe(&blk.blk);
+		local_bh_enable();
+		return;
+	}
+
+	if (ctx->blk.action == skbtrace_action_tcp_sendlimit &&
+			(ctx->blk.flags & (1 << reason)) &&
+			ctx->tcp_sendlim.val == val &&
+			current_kernel_time().tv_sec == ctx->blk.ts.tv_sec) {
+		/* same event happens continuously */
+		++ctx->tcp_sendlim.count;
+		local_bh_enable();
+		return;
+	}
+
+	/* fire up last event or the same but delayed too much event */
+	skbtrace_probe(&ctx->blk);
+
+	/* initialize new context */
+	tcp_sendlimit_block_setup(&ctx->tcp_sendlim, sk, reason, val);
+	local_bh_enable();
+SKBTRACE_SOCK_EVENT_END
+
+static struct skbtrace_tracepoint af_inet4[] = {
+	{
+		.name = "tcp_congestion",
+		.probe = skbtrace_tcp_congestion,
+	},
+	{
+		.name = "tcp_connection",
+		.probe = skbtrace_tcp_connection,
+	},
+	{
+		.name = "icsk_connection",
+		.probe = skbtrace_icsk_connection,
+	},
+	{
+		.name = "tcp_sendlimit",
+		.probe = skbtrace_tcp_sendlimit,
+		.setup_options = skbtrace_tcp_sendlimit_setopt,
+		.desc = skbtrace_tcp_sendlimit_desc,
+	},
+	EMPTY_SKBTRACE_TP
+};
+
+static int skbtrace_ipv4_init(void)
+{
+	return skbtrace_register_tracepoints(AF_INET, af_inet4);
+}
+
+static void skbtrace_ipv4_cleanup(void)
+{
+	skbtrace_unregister_tracepoints(AF_INET);
+}
+
+module_init(skbtrace_ipv4_init);
+module_exit(skbtrace_ipv4_cleanup);
+MODULE_ALIAS("skbtrace-af-" __stringify(AF_INET));
+MODULE_LICENSE("GPL");
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3ba605f..d85c8d7 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -279,6 +279,9 @@
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>

+#include <linux/skbtrace.h>
+#include <trace/events/skbtrace_ipv4.h>
+
 int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;

 struct percpu_counter tcp_orphan_count;
@@ -1925,6 +1928,8 @@ void tcp_set_state(struct sock *sk, int state)
 			TCP_DEC_STATS(sock_net(sk), TCP_MIB_CURRESTAB);
 	}

+	trace_tcp_connection(sk, state);
+
 	/* Change state AFTER socket is unhashed to avoid closed
 	 * socket sitting in hash tables.
 	 */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ca0d0e7..8f8b5f5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -74,6 +74,8 @@
 #include <linux/ipsec.h>
 #include <asm/unaligned.h>
 #include <net/netdma.h>
+#include <linux/skbtrace.h>
+#include <trace/events/skbtrace_ipv4.h>

 int sysctl_tcp_timestamps __read_mostly = 1;
 int sysctl_tcp_window_scaling __read_mostly = 1;
@@ -861,6 +863,7 @@ void tcp_enter_cwr(struct sock *sk, const int
set_ssthresh)

 		tcp_set_ca_state(sk, TCP_CA_CWR);
 	}
+	trace_tcp_congestion(sk, skbtrace_tcp_cong_cwr, 0);
 }

 /*
@@ -2151,6 +2154,8 @@ void tcp_enter_frto(struct sock *sk)
 	tcp_set_ca_state(sk, TCP_CA_Disorder);
 	tp->high_seq = tp->snd_nxt;
 	tp->frto_counter = 1;
+
+	trace_tcp_congestion(sk, skbtrace_tcp_cong_frto, 0);
 }

 /* Enter Loss state after F-RTO was applied. Dupack arrived after RTO,
@@ -2218,6 +2223,8 @@ static void tcp_enter_frto_loss(struct sock *sk,
int allowed_segments, int flag)
 	TCP_ECN_queue_cwr(tp);

 	tcp_clear_all_retrans_hints(tp);
+
+	trace_tcp_congestion(sk, skbtrace_tcp_cong_frto_loss, 0);
 }

 static void tcp_clear_retrans_partial(struct tcp_sock *tp)
@@ -2247,6 +2254,8 @@ void tcp_enter_loss(struct sock *sk, int how)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;

+	trace_tcp_congestion(sk, skbtrace_tcp_cong_loss, 0);
+
 	/* Reduce ssthresh if it has not yet been made inside this window. */
 	if (icsk->icsk_ca_state <= TCP_CA_Disorder || tp->snd_una ==
tp->high_seq ||
 	    (icsk->icsk_ca_state == TCP_CA_Loss && !icsk->icsk_retransmits)) {
@@ -3217,6 +3226,7 @@ static void tcp_fastretrans_alert(struct sock *sk,
int pkts_acked,
 		/* Otherwise enter Recovery state */
 		tcp_enter_recovery(sk, (flag & FLAG_ECE));
 		fast_rexmit = 1;
+		trace_tcp_congestion(sk, skbtrace_tcp_cong_fastrtx, 0);
 	}

 	if (do_lost || (tcp_is_fack(tp) && tcp_head_timedout(sk)))
@@ -3770,6 +3780,7 @@ static int tcp_ack(struct sock *sk, const struct
sk_buff *skb, int flag)
 	u32 prior_fackets;
 	int prior_packets;
 	int prior_sacked = tp->sacked_out;
+	int prior_state = icsk->icsk_ca_state;
 	int pkts_acked = 0;
 	int newly_acked_sacked = 0;
 	bool frto_cwnd = false;
@@ -3864,6 +3875,7 @@ static int tcp_ack(struct sock *sk, const struct
sk_buff *skb, int flag)
 		is_dupack = !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
 		tcp_fastretrans_alert(sk, pkts_acked, newly_acked_sacked,
 				      is_dupack, flag);
+		trace_tcp_congestion(sk, skbtrace_tcp_cong_leave, prior_state);
 	} else {
 		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd)
 			tcp_cong_avoid(sk, ack, prior_in_flight);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 64568fa..505e4fd 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -85,6 +85,9 @@
 #include <linux/crypto.h>
 #include <linux/scatterlist.h>

+#include <linux/skbtrace.h>
+#include <trace/events/skbtrace_ipv4.h>
+
 int sysctl_tcp_tw_reuse __read_mostly;
 int sysctl_tcp_low_latency __read_mostly;
 EXPORT_SYMBOL(sysctl_tcp_low_latency);
@@ -1528,6 +1531,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk,
struct sk_buff *skb,
 	if (__inet_inherit_port(sk, newsk) < 0)
 		goto put_and_exit;
 	__inet_hash_nolisten(newsk, NULL);
+	trace_tcp_connection(newsk, TCP_SYN_RECV);

 	return newsk;

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 72b7c63..0a8b4be 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -23,10 +23,13 @@
 #include <linux/slab.h>
 #include <linux/sysctl.h>
 #include <linux/workqueue.h>
+#include <linux/skbtrace.h>
 #include <net/tcp.h>
 #include <net/inet_common.h>
 #include <net/xfrm.h>

+#include <trace/events/skbtrace_ipv4.h>
+
 int sysctl_tcp_syncookies __read_mostly = 1;
 EXPORT_SYMBOL(sysctl_tcp_syncookies);

@@ -189,6 +192,7 @@ kill_with_rst:

 		/* FIN arrived, enter true time-wait state. */
 		tw->tw_substate	  = TCP_TIME_WAIT;
+		trace_tcp_connection(tw, TCP_TIME_WAIT + TCP_MAX_STATES);
 		tcptw->tw_rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 		if (tmp_opt.saw_tstamp) {
 			tcptw->tw_ts_recent_stamp = get_seconds();
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c465d3e..a7c0488 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -42,6 +42,9 @@
 #include <linux/gfp.h>
 #include <linux/module.h>

+#include <linux/skbtrace.h>
+#include <trace/events/skbtrace_ipv4.h>
+
 /* People can turn this off for buggy TCP's found in printers etc. */
 int sysctl_tcp_retrans_collapse __read_mostly = 1;

@@ -1660,15 +1663,18 @@ static int tcp_mtu_probe(struct sock *sk)

 	if (tp->snd_wnd < size_needed)
 		return -1;
-	if (after(tp->snd_nxt + size_needed, tcp_wnd_end(tp)))
+	if (after(tp->snd_nxt + size_needed, tcp_wnd_end(tp))) {
+		trace_tcp_sendlimit(sk, skbtrace_tcp_sndlim_swnd, 1);
 		return 0;
-
+	}
 	/* Do we need to wait to drain cwnd? With none in flight, don't stall */
 	if (tcp_packets_in_flight(tp) + 2 > tp->snd_cwnd) {
 		if (!tcp_packets_in_flight(tp))
 			return -1;
-		else
+		else {
+			trace_tcp_sendlimit(sk, skbtrace_tcp_sndlim_cwnd, 1);
 			return 0;
+		}
 	}

 	/* We're allowed to probe.  Build it now. */
@@ -1763,7 +1769,7 @@ static bool tcp_write_xmit(struct sock *sk,
unsigned int mss_now, int nonagle,
 	struct sk_buff *skb;
 	unsigned int tso_segs, sent_pkts;
 	int cwnd_quota;
-	int result;
+	int retval, result, sndlim;

 	sent_pkts = 0;

@@ -1777,6 +1783,8 @@ static bool tcp_write_xmit(struct sock *sk,
unsigned int mss_now, int nonagle,
 		}
 	}

+	sndlim = skbtrace_tcp_sndlim_ok;
+	result = 0;
 	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;

@@ -1784,20 +1792,27 @@ static bool tcp_write_xmit(struct sock *sk,
unsigned int mss_now, int nonagle,
 		BUG_ON(!tso_segs);

 		cwnd_quota = tcp_cwnd_test(tp, skb);
-		if (!cwnd_quota)
+		if (!cwnd_quota) {
+			sndlim = skbtrace_tcp_sndlim_cwnd;
 			break;
+		}

-		if (unlikely(!tcp_snd_wnd_test(tp, skb, mss_now)))
+		if (unlikely(!tcp_snd_wnd_test(tp, skb, mss_now))) {
+			sndlim = skbtrace_tcp_sndlim_swnd;
 			break;
-
+		}
 		if (tso_segs == 1) {
 			if (unlikely(!tcp_nagle_test(tp, skb, mss_now,
-						     (tcp_skb_is_last(sk, skb) ?
-						      nonagle : TCP_NAGLE_PUSH))))
+					     (tcp_skb_is_last(sk, skb) ?
+					      nonagle : TCP_NAGLE_PUSH)))) {
+				sndlim = skbtrace_tcp_sndlim_nagle;
 				break;
+			}
 		} else {
-			if (!push_one && tcp_tso_should_defer(sk, skb))
+			if (!push_one && tcp_tso_should_defer(sk, skb)) {
+				sndlim = skbtrace_tcp_sndlim_tso;
 				break;
+			}
 		}

 		limit = mss_now;
@@ -1806,14 +1821,18 @@ static bool tcp_write_xmit(struct sock *sk,
unsigned int mss_now, int nonagle,
 						    cwnd_quota);

 		if (skb->len > limit &&
-		    unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
+		    unlikely(tso_fragment(sk, skb, limit, mss_now, gfp))) {
+			sndlim = skbtrace_tcp_sndlim_frag;
 			break;
+		}

 		TCP_SKB_CB(skb)->when = tcp_time_stamp;

-		if (unlikely(tcp_transmit_skb(sk, skb, 1, gfp)))
+		result = tcp_transmit_skb(sk, skb, 1, gfp);
+		if (unlikely(result)) {
+			sndlim = skbtrace_tcp_sndlim_other;
 			break;
-
+		}
 		/* Advance the send_head.  This one is sent out.
 		 * This call will increment packets_out.
 		 */
@@ -1822,17 +1841,25 @@ static bool tcp_write_xmit(struct sock *sk,
unsigned int mss_now, int nonagle,
 		tcp_minshall_update(tp, mss_now, skb);
 		sent_pkts += tcp_skb_pcount(skb);

-		if (push_one)
+		if (push_one) {
+			sndlim = skbtrace_tcp_sndlim_pushone;
 			break;
+		}
 	}
 	if (inet_csk(sk)->icsk_ca_state == TCP_CA_Recovery)
 		tp->prr_out += sent_pkts;

 	if (likely(sent_pkts)) {
+		trace_tcp_sendlimit(sk, skbtrace_tcp_sndlim_ok, sent_pkts);
 		tcp_cwnd_validate(sk);
-		return false;
-	}
-	return !tp->packets_out && tcp_send_head(sk);
+		retval = false;
+	} else
+		retval = !tp->packets_out && tcp_send_head(sk);
+
+	if (skbtrace_tcp_sndlim_ok != sndlim)
+		trace_tcp_sendlimit(sk, sndlim, result);
+
+	return retval;
 }

 /* Push out any pending frames which were held back due to
