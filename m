From: Li Yu <raise.sail@gmail.com>
Subject: [PATCH 2/3] skbtrace v2: TCP/IPv4 family support
Date: Fri, 19 Oct 2012 14:16:26 +0800
Message-ID: <5080F03A.3020005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:52087 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752180Ab2JSGQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 02:16:31 -0400
Received: by mail-da0-f46.google.com with SMTP id n41so79678dak.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 23:16:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yu <bingtian.ly@taobao.com>

This patch contains:

1. Modifications for TCP/IP protocol family.
2. The connection based trace points for TCP:

	tcp_congestion - trace for TCP congestion events
	tcp_connection - trace for basic TCP connection state migration
	icsk_connection - trace for TCP LISTEN state
	tcp_sendlimit - trace for TCP send limit reasons
	tcp_active_conn - trace for active TCP connections
	tcp_rttm  - trace for TCP RTT measurement
	tcp_ca_state - trace for TCP congestion avoid state machine
	sk_timer - trace for all TCP timers

Thanks.

Sign-off-by: Li Yu <bingtian.ly@taobao.com>
---
 include/net/inet_common.h            |    2
 include/net/inet_timewait_sock.h     |   12
 include/net/skbtrace_api_ipv4.h      |  181 +++++++
 include/net/tcp.h                    |    2
 include/trace/events/skbtrace_ipv4.h |   59 ++
 net/ipv4/Kconfig                     |    7
 net/ipv4/Makefile                    |    1
 net/ipv4/af_inet.c                   |   36 +
 net/ipv4/inet_connection_sock.c      |   11
 net/ipv4/inet_timewait_sock.c        |    8
 net/ipv4/skbtrace-ipv4.c             |  797
+++++++++++++++++++++++++++++++++++
 net/ipv4/tcp.c                       |    5
 net/ipv4/tcp_input.c                 |   12
 net/ipv4/tcp_ipv4.c                  |   32 +
 net/ipv4/tcp_minisocks.c             |   35 +
 net/ipv4/tcp_output.c                |   63 ++
 16 files changed, 1234 insertions(+), 29 deletions(-)

diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index 2340087..cb2e357 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -31,6 +31,8 @@ extern int inet_shutdown(struct socket *sock, int how);
 extern int inet_listen(struct socket *sock, int backlog);
 extern void inet_sock_destruct(struct sock *sk);
 extern int inet_bind(struct socket *sock, struct sockaddr *uaddr, int
addr_len);
+extern int inet_sock_getname(struct sock *sk, struct sockaddr *uaddr,
+			int *uaddr_len, int peer);
 extern int inet_getname(struct socket *sock, struct sockaddr *uaddr,
 			int *uaddr_len, int peer);
 extern int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned
long arg);
diff --git a/include/net/inet_timewait_sock.h
b/include/net/inet_timewait_sock.h
index ba52c83..d75747d 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -89,6 +89,8 @@ extern void inet_twdr_twcal_tick(unsigned long data);

 struct inet_bind_bucket;

+struct skbtrace_context;
+
 /*
  * This is a TIME_WAIT sock. It works around the memory consumption
  * problems of sockets in such a state on heavily loaded servers, but
@@ -125,10 +127,18 @@ struct inet_timewait_sock {
 	/* And these are ours. */
 	unsigned int		tw_ipv6only     : 1,
 				tw_transparent  : 1,
-				tw_pad		: 6,	/* 6 bits hole */
+#if defined(CONFIG_SKBTRACE) || defined(CONFIG_SKBTRACE_MODULE)
+				tw_skbtrace_filtered : 1,
+				tw_hit_skbtrace : 1,
+#endif
+				tw_pad		: 4,	/* 4 bits hole */
 				tw_tos		: 8,
 				tw_ipv6_offset  : 16;
 	kmemcheck_bitfield_end(flags);
+#if defined(CONFIG_SKBTRACE) || defined(CONFIG_SKBTRACE_MODULE)
+	unsigned int tw_skbtrace_fid;
+	struct skbtrace_context *tw_skbtrace;
+#endif
 	unsigned long		tw_ttd;
 	struct inet_bind_bucket	*tw_tb;
 	struct hlist_node	tw_death_node;
diff --git a/include/net/skbtrace_api_ipv4.h
b/include/net/skbtrace_api_ipv4.h
new file mode 100644
index 0000000..ab60df1
--- /dev/null
+++ b/include/net/skbtrace_api_ipv4.h
@@ -0,0 +1,181 @@
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
+	skbtrace_action_tcp_active_conn	= 104,
+	skbtrace_action_tcp_rttm	= 105,
+	skbtrace_action_tcp_ca_state	= 106,
+	skbtrace_action_tcp_max		= 199,
+};
+
+/* TCP congestion event (101) */
+
+/* flags */
+enum {
+	skbtrace_tcp_cong_cwr		= 0,
+	skbtrace_tcp_cong_loss		= 1,
+	skbtrace_tcp_cong_fastrtx	= 2,
+	skbtrace_tcp_cong_frto		= 3,
+	skbtrace_tcp_cong_frto_loss	= 4,
+	skbtrace_tcp_cong_leave		= 5,
+};
+
+struct skbtrace_tcp_cong_blk {
+	struct skbtrace_block blk;
+	__u32	rto;
+	__u32	cwnd;
+	__u32	sndnxt;
+	__u32	snduna;
+} __packed;
+
+/* TCP basic connection events */
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
+/* TCP send limit event */
+enum {
+	skbtrace_tcp_sndlim_cwnd	= 0,
+	skbtrace_tcp_sndlim_swnd	= 1,
+	skbtrace_tcp_sndlim_nagle	= 2,
+	skbtrace_tcp_sndlim_tso		= 3,
+	skbtrace_tcp_sndlim_frag	= 4,	/* most likely ENOMEM errors */
+	skbtrace_tcp_sndlim_pushone	= 5,
+	skbtrace_tcp_sndlim_other	= 6,
+	skbtrace_tcp_sndlim_ok		= 7,
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
+/* TCP active connections */
+/* Use skbtrace_tcp_conn_blk */
+
+/* TCP RTTM */
+struct skbtrace_tcp_rttm_blk {
+	struct skbtrace_block blk;
+	__u32 pad;
+	__u32 snd_una;
+	__u32 rtt_seq;
+	__u32 rtt;
+	__u32 rttvar;
+	__u32 srtt;
+	__u32 mdev;
+	__u32 mdev_max;
+} __packed;
+
+/* TCP CA state */
+struct skbtrace_tcp_ca_state_blk {
+	struct skbtrace_block blk;
+
+        __u32	cwnd;
+        __u32	rto;
+        __u32	snduna;
+        __u32	sndnxt;
+
+        __u32	snd_ssthresh;
+        __u32	snd_wnd;
+        __u32	rcv_wnd;
+        __u32	high_seq;
+
+        __u32	packets_out;
+        __u32	lost_out;
+        __u32	retrans_out;
+        __u32	sacked_out;
+
+        __u32	fackets_out;
+        __u32	prior_ssthresh;
+        __u32	undo_marker;
+        __u32	undo_retrans;
+
+        __u32	total_retrans;
+        __u32	reordering;
+        __u32	prior_cwnd;
+        __u32	mss_cache;
+
+} __packed;
+
+/* TCP timer flags */
+enum {
+	skbtrace_tcp_timer_rexmit = skbtrace_sk_timer_last + 1,
+	skbtrace_tcp_timer_probe,
+	skbtrace_tcp_timer_keepalive,
+	skbtrace_tcp_timer_delack,
+};
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
+/* Use skbtrace_tcp_active_conn */
+
+#endif
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1f000ff..cb4d896 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -46,6 +46,7 @@

 #include <linux/seq_file.h>
 #include <linux/memcontrol.h>
+#include <trace/events/skbtrace_ipv4.h>

 extern struct inet_hashinfo tcp_hashinfo;

@@ -805,6 +806,7 @@ static inline void tcp_set_ca_state(struct sock *sk,
const u8 ca_state)
 	if (icsk->icsk_ca_ops->set_state)
 		icsk->icsk_ca_ops->set_state(sk, ca_state);
 	icsk->icsk_ca_state = ca_state;
+	trace_tcp_ca_state(sk, ca_state);
 }

 static inline void tcp_ca_event(struct sock *sk, const enum
tcp_ca_event event)
diff --git a/include/trace/events/skbtrace_ipv4.h
b/include/trace/events/skbtrace_ipv4.h
new file mode 100644
index 0000000..b82b81f
--- /dev/null
+++ b/include/trace/events/skbtrace_ipv4.h
@@ -0,0 +1,59 @@
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
+DECLARE_TRACE(icsk_connection,
+	TP_PROTO(void *sk, __u32 state),
+	TP_ARGS(sk, state));
+
+DECLARE_TRACE(tcp_congestion,
+	TP_PROTO(void *sk, int reason),
+	TP_ARGS(sk, reason));
+
+DECLARE_TRACE(tcp_connection,
+	TP_PROTO(void *sk, __u32 state),
+	TP_ARGS(sk, state));
+
+DECLARE_TRACE(tcp_sendlimit,
+	TP_PROTO(void *sk, int reason, int val),
+	TP_ARGS(sk, reason, val));
+
+DECLARE_TRACE(tcp_active_conn,
+	TP_PROTO(void *sk),
+	TP_ARGS(sk));
+
+DECLARE_TRACE(tcp_rttm,
+	TP_PROTO(void *sk, __u32 seq_rtt),
+	TP_ARGS(sk, seq_rtt));
+
+DECLARE_TRACE(tcp_ca_state,
+	TP_PROTO(void *sk, __u8 state),
+	TP_ARGS(sk, state));
+
+#endif
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 5a19aeb..24dba85 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -426,6 +426,13 @@ config INET_UDP_DIAG
 	  Support for UDP socket monitoring interface used by the ss tool.
 	  If unsure, say Y.

+config SKBTRACE_IPV4
+	tristate "IPv4 protocol suite support for skbtrace"
+	depends on SKBTRACE
+	default m
+	---help---
+	  Support for IPv4 part of skbtrace.
+
 menuconfig TCP_CONG_ADVANCED
 	bool "TCP: advanced congestion control"
 	---help---
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 15ca63e..0c7b5c3 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -51,6 +51,7 @@ obj-$(CONFIG_TCP_CONG_YEAH) += tcp_yeah.o
 obj-$(CONFIG_TCP_CONG_ILLINOIS) += tcp_illinois.o
 obj-$(CONFIG_MEMCG_KMEM) += tcp_memcontrol.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
+obj-${CONFIG_SKBTRACE_IPV4} += skbtrace-ipv4.o

 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index fe4582c..6781a12 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -119,6 +119,7 @@
 #include <linux/mroute.h>
 #endif

+#include <linux/skbtrace.h>

 /* The inetsw table contains everything that inet_create needs to
  * build a new socket.
@@ -713,23 +714,14 @@ do_err:
 }
 EXPORT_SYMBOL(inet_accept);

-
-/*
- *	This does both peername and sockname.
- */
-int inet_getname(struct socket *sock, struct sockaddr *uaddr,
+int inet_sock_getname(struct sock *sk, struct sockaddr *uaddr,
 			int *uaddr_len, int peer)
 {
-	struct sock *sk		= sock->sk;
 	struct inet_sock *inet	= inet_sk(sk);
 	DECLARE_SOCKADDR(struct sockaddr_in *, sin, uaddr);

 	sin->sin_family = AF_INET;
 	if (peer) {
-		if (!inet->inet_dport ||
-		    (((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_SYN_SENT)) &&
-		     peer == 1))
-			return -ENOTCONN;
 		sin->sin_port = inet->inet_dport;
 		sin->sin_addr.s_addr = inet->inet_daddr;
 	} else {
@@ -740,9 +732,31 @@ int inet_getname(struct socket *sock, struct
sockaddr *uaddr,
 		sin->sin_addr.s_addr = addr;
 	}
 	memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-	*uaddr_len = sizeof(*sin);
+	if (uaddr_len)
+		*uaddr_len = sizeof(*sin);
 	return 0;
 }
+EXPORT_SYMBOL(inet_sock_getname);
+
+/*
+ *	This does both peername and sockname.
+ */
+int inet_getname(struct socket *sock, struct sockaddr *uaddr,
+			int *uaddr_len, int peer)
+{
+	struct sock *sk		= sock->sk;
+	struct inet_sock *inet	= inet_sk(sk);
+
+	if (peer) {
+		if (!inet->inet_dport)
+			return -ENOTCONN;
+		if (((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_SYN_SENT)) &&
+		     peer == 1)
+			return -ENOTCONN;
+	}
+
+	return inet_sock_getname(sk, uaddr, uaddr_len, peer);
+}
 EXPORT_SYMBOL(inet_getname);

 int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
*msg,
diff --git a/net/ipv4/inet_connection_sock.c
b/net/ipv4/inet_connection_sock.c
index 7f75f21..4e1c45f 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -15,6 +15,9 @@

 #include <linux/module.h>
 #include <linux/jhash.h>
+#include <linux/skbtrace.h>
+#include <trace/events/skbtrace_common.h>
+#include <trace/events/skbtrace_ipv4.h>

 #include <net/inet_connection_sock.h>
 #include <net/inet_hashtables.h>
@@ -335,9 +338,16 @@ void inet_csk_init_xmit_timers(struct sock *sk,

 	setup_timer(&icsk->icsk_retransmit_timer, retransmit_handler,
 			(unsigned long)sk);
+	trace_sk_timer(sk, &icsk->icsk_retransmit_timer,
+						skbtrace_sk_timer_setup);
+
 	setup_timer(&icsk->icsk_delack_timer, delack_handler,
 			(unsigned long)sk);
+	trace_sk_timer(sk, &icsk->icsk_delack_timer, skbtrace_sk_timer_setup);
+
 	setup_timer(&sk->sk_timer, keepalive_handler, (unsigned long)sk);
+	trace_sk_timer(sk, &sk->sk_timer, skbtrace_sk_timer_setup);
+
 	icsk->icsk_pending = icsk->icsk_ack.pending = 0;
 }
 EXPORT_SYMBOL(inet_csk_init_xmit_timers);
@@ -704,6 +714,7 @@ int inet_csk_listen_start(struct sock *sk, const int
nr_table_entries)
 		sk_dst_reset(sk);
 		sk->sk_prot->hash(sk);

+		trace_icsk_connection(sk, TCP_LISTEN);
 		return 0;
 	}

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 2784db3..c34dbbc 100644
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
@@ -106,6 +108,7 @@ static noinline void inet_twsk_free(struct
inet_timewait_sock *tw)
 #ifdef SOCK_REFCNT_DEBUG
 	pr_debug("%s timewait_sock %p released\n", tw->tw_prot->name, tw);
 #endif
+	skbtrace_context_destroy(&tw->tw_skbtrace);
 	release_net(twsk_net(tw));
 	kmem_cache_free(tw->tw_prot->twsk_prot->twsk_slab, tw);
 	module_put(owner);
@@ -196,6 +199,10 @@ struct inet_timewait_sock *inet_twsk_alloc(const
struct sock *sk, const int stat
 		tw->tw_ipv6only	    = 0;
 		tw->tw_transparent  = inet->transparent;
 		tw->tw_prot	    = sk->sk_prot_creator;
+		tw->tw_skbtrace_fid = 0;
+#if HAVE_SKBTRACE
+		tw->tw_skbtrace     = NULL;
+#endif
 		twsk_net_set(tw, hold_net(sock_net(sk)));
 		/*
 		 * Because we use RCU lookups, we should not set tw_refcnt
@@ -205,6 +212,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const
struct sock *sk, const int stat
 		atomic_set(&tw->tw_refcnt, 0);
 		inet_twsk_dead_node_init(tw);
 		__module_get(tw->tw_prot->owner);
+		trace_tcp_connection(tw, state + TCP_MAX_STATES);
 	}

 	return tw;
diff --git a/net/ipv4/skbtrace-ipv4.c b/net/ipv4/skbtrace-ipv4.c
new file mode 100644
index 0000000..28e3532
--- /dev/null
+++ b/net/ipv4/skbtrace-ipv4.c
@@ -0,0 +1,797 @@
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
+static int mask_options_setup(struct skbtrace_tracepoint *t,
+				char *names[], int masks[], int nr_masks,
+						char *option_string);
+static char* mask_options_desc(struct skbtrace_tracepoint *t,
+				char *names[], int masks[], int nr_masks);
+
+static struct skbtrace_context *skbtrace_context_twsk_get(
+				struct inet_timewait_sock *tw)
+{
+	struct skbtrace_ops *ops;
+	struct skbtrace_context *ctx;
+
+	ops = skbtrace_ops_get(tw->tw_family);
+	if (!ops)
+		return NULL;
+	local_bh_disable();
+
+	if (tw->tw_skbtrace &&
+			(skbtrace_session != tw->tw_skbtrace->session)) {
+		skbtrace_context_destroy(&tw->tw_skbtrace);
+	}
+
+	if (!tw->tw_skbtrace) {
+		ctx = kzalloc(sizeof(struct skbtrace_context), GFP_ATOMIC);
+		if (likely(ctx)) {
+			skbtrace_context_setup(ctx, ops);
+			tw->tw_skbtrace = ctx;
+		}
+	}
+	local_bh_enable();
+	return tw->tw_skbtrace;
+}
+EXPORT_SYMBOL(skbtrace_context_twsk_get);
+
+static char* tcp_cong_options[] = {
+	"cwr",
+	"loss",
+	"fastrtx",
+	"frto",
+	"frto-loss",
+	"leave",
+};
+
+static int tcp_cong_masks[] = {
+	skbtrace_tcp_cong_cwr,
+	skbtrace_tcp_cong_loss,
+	skbtrace_tcp_cong_fastrtx,
+	skbtrace_tcp_cong_frto,
+	skbtrace_tcp_cong_frto_loss,
+	skbtrace_tcp_cong_leave,
+};
+
+static int tcp_cong_setup_options(struct skbtrace_tracepoint *t,
+							char *options)
+{
+	return mask_options_setup(t,
+			tcp_cong_options,
+			tcp_cong_masks,
+			sizeof(tcp_cong_masks)/sizeof(int),
+			options);
+}
+
+static char *tcp_cong_desc(struct skbtrace_tracepoint *t)
+{
+	return mask_options_desc(t,
+			tcp_cong_options,
+			tcp_cong_masks,
+			sizeof(tcp_cong_masks)/sizeof(int));
+}
+
+static void skbtrace_tcp_congestion(struct skbtrace_tracepoint *t,
+					struct sock *sk, int reason)
+SKBTRACE_SOCK_EVENT_BEGIN
+	struct skbtrace_tcp_cong_blk blk, *b;
+	struct tcp_sock *tp;
+	struct skbtrace_context *ctx;
+	unsigned long mask = (unsigned long)t->private;
+
+	if (mask & (1<<reason))
+		return;
+
+	tp = tcp_sk(sk);
+	ctx = skbtrace_context_get(sk);
+	b = skbtrace_block_get(t, ctx, &blk);
+	INIT_SKBTRACE_BLOCK(&b->blk, tp,
+			skbtrace_action_tcp_congestion,
+			1 << reason,
+			sizeof(*b));
+	b->cwnd = tp->snd_cwnd * tp->mss_cache;
+	b->rto = inet_csk(sk)->icsk_rto;
+	b->snduna = tp->snd_una;
+	b->sndnxt = tp->snd_nxt;
+	skbtrace_probe(t, ctx, &b->blk);
+SKBTRACE_SOCK_EVENT_END
+
+static void skbtrace_tcp_connection(struct skbtrace_tracepoint *t,
+							void *ptr, u32 state)
+{
+	struct sock *sk = ptr;
+	struct inet_timewait_sock *tw = inet_twsk(ptr);
+	struct skbtrace_context *ctx;
+
+	switch (state) {
+	case TCP_TIME_WAIT + TCP_MAX_STATES:
+	case TCP_FIN_WAIT2 + TCP_MAX_STATES:
+		{
+			struct skbtrace_tcp_conn_blk blk, *b;
+			struct skbtrace_context *ctx;
+
+			if (skbtrace_bypass_twsk(tw))
+				return;
+
+			ctx = skbtrace_context_twsk_get(tw);
+			b = skbtrace_block_get(t, ctx, &blk);
+			state -= TCP_MAX_STATES;
+			INIT_SKBTRACE_BLOCK(&b->blk, tw,
+				skbtrace_action_tcp_connection,
+				1 << state,
+				sizeof(blk));
+			b->addr.inet.local.sin_family = AF_INET;
+			b->addr.inet.local.sin_port = tw->tw_sport;
+			b->addr.inet.local.sin_addr.s_addr = tw->tw_rcv_saddr;
+			b->addr.inet.peer.sin_family = AF_INET;
+			b->addr.inet.peer.sin_port = tw->tw_dport;
+			b->addr.inet.peer.sin_addr.s_addr = tw->tw_daddr;
+			skbtrace_probe(t, ctx, &b->blk);
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
+			struct skbtrace_tcp_conn_blk blk, *b;
+			struct skbtrace_ops *ops;
+
+			if (skbtrace_bypass_sock(sk))
+				return;
+
+			if (TCP_CLOSE == sk->sk_state &&
+				SHUTDOWN_MASK == sk->sk_shutdown)
+				/* for active TCP connections, we will call
+				 * tcp_set_state(sk, TCP_CLOSE) two times,
+				 * this hack help skip second one */
+				return;
+
+			ops = skbtrace_ops_get(sk->sk_family);
+			if (!ops)
+				return;
+
+			ctx = skbtrace_context_get(sk);
+			b = skbtrace_block_get(t, ctx, &blk);
+			INIT_SKBTRACE_BLOCK(&b->blk, ptr,
+				skbtrace_action_tcp_connection,
+				1 << state,
+				sizeof(blk));
+			ops->getname(sk, &b->addr.local, NULL, 0);
+			if (TCP_LISTEN != state)
+				ops->getname(sk, &b->addr.peer, NULL, 1);
+			skbtrace_probe(t, ctx, &b->blk);
+			break;
+		}
+	}
+}
+
+static void skbtrace_icsk_connection(struct skbtrace_tracepoint *t,
+						struct sock *sk, u32 state)
+SKBTRACE_SOCK_EVENT_BEGIN
+	struct skbtrace_tcp_conn_blk blk, *b;
+	struct skbtrace_ops *ops;
+	struct skbtrace_context *ctx;
+
+	if (TCP_LISTEN != state)
+		return;
+	ops = skbtrace_ops_get(sk->sk_family);
+	if (!ops)
+		return;
+
+	ctx = skbtrace_context_get(sk);
+	b = skbtrace_block_get(t, ctx, &blk);
+	INIT_SKBTRACE_BLOCK(&b->blk, sk,
+				skbtrace_action_icsk_connection,
+				1 << state,
+				sizeof(blk));
+	ops->getname(sk, &b->addr.local, NULL, 0);
+	skbtrace_probe(t, ctx, &b->blk);
+SKBTRACE_SOCK_EVENT_END
+
+static char* tcp_sendlimit_options[] = {
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
+static int tcp_sendlimit_masks[] = {
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
+static int tcp_sendlimit_setup_options(struct skbtrace_tracepoint *t,
+							char *options)
+{
+	return mask_options_setup(t,
+			tcp_sendlimit_options,
+			tcp_sendlimit_masks,
+			sizeof(tcp_sendlimit_masks)/sizeof(int),
+			options);
+}
+
+static char *tcp_sendlimit_desc(struct skbtrace_tracepoint *t)
+{
+	return mask_options_desc(t,
+			tcp_sendlimit_options,
+			tcp_sendlimit_masks,
+			sizeof(tcp_sendlimit_masks)/sizeof(int));
+}
+
+static void skbtrace_tcp_sendlimit(struct skbtrace_tracepoint *t,
+		struct sock *sk, int reason, int val)
+SKBTRACE_SOCK_EVENT_BEGIN
+	struct skbtrace_tcp_sendlim_blk blk, *b;
+	unsigned long mask = (unsigned long)t->private;
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct skbtrace_context *ctx;
+
+	if (mask & (1<<reason))
+		return;
+
+	if (skbtrace_tcp_sndlim_ok == reason && !val)
+		return;
+
+	ctx = skbtrace_context_get(sk);
+	b = skbtrace_block_get(t, ctx, &blk);
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
+
+	skbtrace_probe(t, ctx, &b->blk);
+SKBTRACE_SOCK_EVENT_END
+
+static void skbtrace_tcp_active_conn(struct skbtrace_tracepoint *t,
+							struct sock *sk)
+SKBTRACE_SOCK_EVENT_BEGIN
+	struct skbtrace_tcp_conn_blk blk, *b;
+	struct skbtrace_context *ctx;
+
+	ctx = skbtrace_context_get(sk);
+	if (ctx) {
+	       	if (ctx->active_conn_hit)
+			return;
+		ctx->active_conn_hit = 1;
+	}
+
+	b = skbtrace_block_get(t, ctx, &blk);
+	INIT_SKBTRACE_BLOCK(&b->blk, sk,
+			skbtrace_action_tcp_active_conn, 0, sizeof(blk));
+	if (ctx && ctx->ops) {
+		ctx->ops->getname(sk, &b->addr.local, NULL, 0);
+		ctx->ops->getname(sk, &b->addr.peer, NULL, 1);
+	} else
+		memset(&b->addr, 0, sizeof(b->addr));
+	skbtrace_probe(t, ctx, &b->blk);
+SKBTRACE_SOCK_EVENT_END
+
+static void skbtrace_tcp_rttm(struct skbtrace_tracepoint *t,
+					struct sock *sk, u32 seq_rtt)
+SKBTRACE_SOCK_EVENT_BEGIN
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct skbtrace_tcp_rttm_blk blk, *b;
+	struct skbtrace_context *ctx;
+
+	ctx = skbtrace_context_get(sk);
+	b = skbtrace_block_get(t, ctx, &blk);
+	INIT_SKBTRACE_BLOCK(&b->blk, sk,
+			skbtrace_action_tcp_rttm, 0, sizeof(blk));
+	b->rtt_seq = tp->rtt_seq;
+	b->snd_una = tp->snd_una;
+	b->rtt = seq_rtt;
+	b->srtt = tp->srtt;
+	b->rttvar = tp->rttvar;
+	b->mdev = tp->mdev;
+	b->mdev_max = tp->mdev_max;
+	skbtrace_probe(t, ctx, &b->blk);
+SKBTRACE_SOCK_EVENT_END
+
+static char* tcp_ca_state_options[] = {
+	"open",
+	"disorder",
+	"cwr",
+	"recovery",
+	"loss",
+};
+
+static int tcp_ca_state_masks[] = {
+	TCP_CA_Open,
+	TCP_CA_Disorder,
+	TCP_CA_CWR,
+	TCP_CA_Recovery,
+	TCP_CA_Loss,
+};
+
+static int tcp_ca_state_setup_options(struct skbtrace_tracepoint *t,
+							char *options)
+{
+	return mask_options_setup(t,
+			tcp_ca_state_options,
+			tcp_ca_state_masks,
+			sizeof(tcp_ca_state_masks)/sizeof(int),
+			options);
+}
+
+static char *tcp_ca_state_desc(struct skbtrace_tracepoint *t)
+{
+	return mask_options_desc(t,
+			tcp_ca_state_options,
+			tcp_ca_state_masks,
+			sizeof(tcp_ca_state_masks)/sizeof(int));
+}
+
+static void skbtrace_tcp_ca_state(struct skbtrace_tracepoint *t,
+					struct sock *sk, u8 state)
+SKBTRACE_SOCK_EVENT_BEGIN
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct skbtrace_tcp_ca_state_blk blk, *b;
+	struct skbtrace_context *ctx;
+	unsigned long mask = (unsigned long)t->private;
+
+	if (mask & (1<<state))
+		return;
+
+	ctx = skbtrace_context_get(sk);
+	b = skbtrace_block_get(t, ctx, &blk);
+	INIT_SKBTRACE_BLOCK(&b->blk, sk,
+			skbtrace_action_tcp_ca_state, 1<<state, sizeof(blk));
+
+	b->cwnd = tp->snd_cwnd;
+	b->rto = inet_csk(sk)->icsk_rto;
+	b->snduna = tp->snd_una;
+	b->sndnxt = tp->snd_nxt;
+
+	b->snd_ssthresh = tp->snd_ssthresh;
+	b->snd_wnd = tp->snd_wnd;
+	b->rcv_wnd = tp->rcv_wnd;
+	b->high_seq = tp->high_seq;
+
+	b->packets_out = tp->packets_out;
+	b->lost_out = tp->lost_out;
+	b->retrans_out = tp->retrans_out;
+	b->sacked_out = tp->sacked_out;
+
+	b->fackets_out = tp->fackets_out;
+	b->prior_ssthresh = tp->prior_ssthresh;
+	b->undo_marker = tp->undo_marker;
+	b->undo_retrans = tp->undo_retrans;
+
+	b->total_retrans =  tp->total_retrans;
+	b->reordering = tp->reordering;
+	b->prior_cwnd = tp->prior_cwnd;
+	b->mss_cache = tp->mss_cache;
+
+	skbtrace_probe(t, ctx, &b->blk);
+SKBTRACE_SOCK_EVENT_END
+
+static char* tcp_timer_options[] = {
+	"setup",
+	"reset",
+	"stop",
+
+	"rexmit",
+	"probe",
+	"keepalive",
+	"delack",
+};
+
+static int tcp_timer_masks[] = {
+	skbtrace_sk_timer_setup,
+	skbtrace_sk_timer_reset,
+	skbtrace_sk_timer_stop,
+
+	skbtrace_tcp_timer_rexmit,
+	skbtrace_tcp_timer_probe,
+	skbtrace_tcp_timer_keepalive,
+	skbtrace_tcp_timer_delack,
+};
+
+static int tcp_timer_setup_options(struct skbtrace_tracepoint *t,
+							char *options)
+{
+	return mask_options_setup(t,
+			tcp_timer_options,
+			tcp_timer_masks,
+			sizeof(tcp_timer_masks)/sizeof(int),
+			options);
+}
+
+static char *tcp_timer_desc(struct skbtrace_tracepoint *t)
+{
+	return mask_options_desc(t,
+			tcp_timer_options,
+			tcp_timer_masks,
+			sizeof(tcp_timer_masks)/sizeof(int));
+}
+
+#define LONG_SIGN_MASK	(1UL<<(BITS_PER_LONG - 1))
+#define LONG_SIGN(l)	(l & LONG_SIGN_MASK)
+
+static s32 timer_timeout_msecs(struct timer_list *timer, unsigned long now)
+{
+	s32 timeout;
+
+	if (unlikely(LONG_SIGN(timer->expires) != LONG_SIGN(now))) {
+		timeout = (s32)timer->expires;
+		timeout += (s32)(ULONG_MAX - now);
+	} else
+		timeout = timer->expires - now;
+
+	return jiffies_to_msecs(timeout);
+}
+
+static void skbtrace_tcp_timer(struct skbtrace_tracepoint *t,
+			struct sock *sk, struct timer_list *timer, int action)
+SKBTRACE_SOCK_EVENT_BEGIN
+	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct skbtrace_sk_timer_blk blk, *b;
+	s32 f_timer, timeout;
+	u32 timer_bits;
+	struct skbtrace_context *ctx;
+	unsigned long mask = (unsigned long)t->private;
+
+	if (IPPROTO_TCP != sk->sk_protocol)
+		return;
+
+	if (mask & (1<<action))
+		return;
+
+	if (timer == &icsk->icsk_retransmit_timer) {
+		f_timer = (icsk->icsk_pending == ICSK_TIME_PROBE0 ?
+				skbtrace_tcp_timer_probe : skbtrace_tcp_timer_rexmit);
+	} else if (timer == &icsk->icsk_delack_timer)
+		f_timer = skbtrace_tcp_timer_delack;
+	else if (timer == &sk->sk_timer)
+		f_timer = skbtrace_tcp_timer_keepalive;
+	else
+		f_timer = 0;
+	timer_bits = f_timer ? (1<<f_timer) : 0;
+
+	if (mask & timer_bits)
+		return;
+
+	/* TCP rexmit timer and probe0 share same timer_list  */
+	if (f_timer == skbtrace_tcp_timer_rexmit
+			&& action == skbtrace_sk_timer_setup) {
+		if (mask & (1<<skbtrace_tcp_timer_probe))
+			return;
+		timer_bits |= 1<<skbtrace_tcp_timer_probe;
+	}
+
+	ctx = skbtrace_context_get(sk);
+	b = skbtrace_block_get(t, ctx, &blk);
+	INIT_SKBTRACE_BLOCK(&b->blk, sk,
+			skbtrace_action_sk_timer, 1<<action, sizeof(blk));
+	b->proto = IPPROTO_TCP;
+
+	if (skbtrace_sk_timer_reset == action) {
+		timeout = timer_timeout_msecs(timer, jiffies);
+	} else
+		timeout = 0;
+
+	b->blk.flags |= timer_bits;
+	b->timeout = timeout;
+	skbtrace_probe(t, ctx, &b->blk);
+SKBTRACE_SOCK_EVENT_END
+
+static struct skbtrace_tracepoint tp_inet4[] = {
+	{
+		.trace_name = "tcp_congestion",
+		.action = skbtrace_action_tcp_congestion,
+		.block_size = sizeof(struct skbtrace_tcp_cong_blk),
+		.probe = skbtrace_tcp_congestion,
+		.setup_options = tcp_cong_setup_options,
+		.desc = tcp_cong_desc,
+	},
+	{
+		.trace_name = "tcp_connection",
+		.action = skbtrace_action_tcp_connection,
+		.block_size = sizeof(struct skbtrace_tcp_conn_blk),
+		.probe = skbtrace_tcp_connection,
+	},
+	{
+		.trace_name = "icsk_connection",
+		.action = skbtrace_action_icsk_connection,
+		.block_size = sizeof(struct skbtrace_tcp_conn_blk),
+		.probe = skbtrace_icsk_connection,
+	},
+	{
+		.trace_name = "tcp_sendlimit",
+		.action = skbtrace_action_tcp_sendlimit,
+		.block_size = sizeof(struct skbtrace_tcp_sendlim_blk),
+		.probe = skbtrace_tcp_sendlimit,
+		.setup_options = tcp_sendlimit_setup_options,
+		.desc = tcp_sendlimit_desc,
+	},
+	{
+		.trace_name = "tcp_active_conn",
+		.action = skbtrace_action_tcp_active_conn,
+		.block_size = sizeof(struct skbtrace_tcp_conn_blk),
+		.probe = skbtrace_tcp_active_conn,
+	},
+	{
+		.trace_name = "tcp_rttm",
+		.action = skbtrace_action_tcp_rttm,
+		.block_size = sizeof(struct skbtrace_tcp_rttm_blk),
+		.probe = skbtrace_tcp_rttm,
+	},
+	{
+		.trace_name = "tcp_ca_state",
+		.action = skbtrace_action_tcp_ca_state,
+		.block_size = sizeof(struct skbtrace_tcp_ca_state_blk),
+		.probe = skbtrace_tcp_ca_state,
+		.setup_options = tcp_ca_state_setup_options,
+		.desc = tcp_ca_state_desc,
+	},
+	{
+		.trace_name = "sk_timer",
+		.action = skbtrace_action_sk_timer,
+		.block_size = sizeof(struct skbtrace_sk_timer_blk),
+		.probe = skbtrace_tcp_timer,
+		.setup_options = tcp_timer_setup_options,
+		.desc = tcp_timer_desc,
+	},
+	EMPTY_SKBTRACE_TP
+};
+
+static int __inet_filter_skb(struct sock *sk, struct sk_buff *skb)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct iphdr *iph;
+
+	skb_reset_network_header(skb);
+	iph = ip_hdr(skb);
+	*((__be16 *)iph) = htons((4 << 12) | (5 << 8));
+	iph->frag_off = 0;
+	iph->ttl      = 0;
+	iph->protocol = sk->sk_protocol;
+	iph->saddr = inet->inet_saddr;
+	iph->daddr = inet->inet_daddr;
+	iph->id = 0;
+	iph->tot_len = htons(sizeof(struct iphdr) + sizeof(struct tcphdr));
+
+	return sizeof(struct iphdr);
+}
+
+int inet_filter_skb(struct sock *sk, struct sk_buff *skb)
+{
+	int size, prot_size;
+
+	if (!skb || !sk->sk_prot->filter_skb) {
+		return -EINVAL;
+	}
+
+	size = __inet_filter_skb(sk, skb);
+	if (size < 0)
+		return -EINVAL;
+	skb->len += size;
+	skb->tail += size;
+	skb->data += size;
+
+	prot_size = sk->sk_prot->filter_skb(sk, skb);
+	if (prot_size < 0)
+		return -EINVAL;
+	skb->len += prot_size;
+	skb->tail += prot_size;
+
+	skb->data -= size;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(inet_filter_skb);
+
+int inet_tw_getname(struct inet_timewait_sock *tw,
+					struct sockaddr *addr, int peer)
+{
+	struct sockaddr_in *in = (struct sockaddr_in*)addr;
+
+	in->sin_family = AF_INET;
+	if (!peer) {
+		in->sin_port = tw->tw_sport;
+		in->sin_addr.s_addr = tw->tw_rcv_saddr;
+	} else {
+		in->sin_port = tw->tw_dport;
+		in->sin_addr.s_addr = tw->tw_daddr;
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(inet_tw_getname);
+
+static int __inet_tw_filter_skb(struct inet_timewait_sock *tw,
+						struct sk_buff *skb)
+{
+	struct iphdr *iph;
+
+	skb_reset_network_header(skb);
+	iph = ip_hdr(skb);
+	*((__be16 *)iph) = htons((4 << 12) | (5 << 8));
+	iph->frag_off = 0;
+	iph->ttl      = 0;
+	iph->protocol = IPPROTO_TCP;
+	iph->saddr = tw->tw_rcv_saddr;
+	iph->daddr = tw->tw_daddr;
+	iph->id = 0;
+	iph->tot_len = htons(sizeof(struct iphdr) + sizeof(struct tcphdr));
+
+	return sizeof(struct iphdr);
+}
+
+int inet_tw_filter_skb(struct inet_timewait_sock *tw, struct sk_buff *skb)
+{
+	int size, prot_size;
+
+	if (!skb)
+		return -EINVAL;
+
+	size = __inet_tw_filter_skb(tw, skb);
+	if (size < 0)
+		return -EINVAL;
+	skb->len += size;
+	skb->tail += size;
+	skb->data += size;
+
+	prot_size = tcp_tw_filter_skb(tw, skb);
+	if (size < 0)
+		return -EINVAL;
+	skb->len += prot_size;
+	skb->tail += prot_size;
+
+	skb->data -= size;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(inet_tw_filter_skb);
+
+static int mask_options_setup(struct skbtrace_tracepoint *t,
+				char *names[], int *masks, int nr_masks,
+							char *option_string)
+{
+	unsigned long mask = 0UL;
+	char *cur, *tail = NULL;
+	int ret = 0;
+
+	option_string = strstr(option_string, "mask=");
+	if (option_string) {
+		if (strncmp(option_string, "mask=", sizeof("mask=") - 1)) {
+			option_string = NULL;
+			ret = -EINVAL;
+		} else
+			option_string += sizeof("mask=") - 1;
+	}
+
+	if (!option_string || '\x0' == *option_string)
+		goto quit;
+
+	tail = strchr(option_string, ',');
+	if (tail)
+		*tail = '\x0';
+
+	mask = 0UL;
+	cur = strsep(&option_string, ":");
+	while (cur) {
+		int i;
+
+		for (i = 0; i < nr_masks; i++) {
+			if (!strcmp(cur, names[i])) {
+				mask |= 1 << masks[i];
+				break;
+			}
+		}
+		if (i >= nr_masks) {
+			mask = 0UL;
+			ret = -EINVAL;
+		}
+		cur = strsep(&option_string, ":");
+	}
+
+quit:
+	if (tail)
+		*tail = ',';
+	t->private = (void *)(mask);
+	return ret;
+}
+
+static char* mask_options_desc(struct skbtrace_tracepoint *t,
+				char *names[],
+				int *masks, int nr_masks)
+{
+	char *desc;
+	unsigned long mask = (unsigned long)t->private;
+	int i, copied;
+
+	desc = kmalloc(strlen(t->trace_name) + 128, GFP_KERNEL);
+	if (!desc)
+		return NULL;
+
+	copied = sprintf(desc, "%s enabled:%d mask=", t->trace_name, t->enabled);
+	for (i = 0; i < nr_masks; i++) {
+		int this_m;
+		const char *this_n;
+
+		this_m = masks[i];
+		this_n = names[i];
+		if (!t->enabled || (t->enabled && (mask & (1 << this_m))))
+			copied += sprintf(desc + copied, "%s:", this_n);
+	}
+
+	sprintf(desc + copied - 1, "\n");
+	return desc;
+}
+
+
+static struct skbtrace_ops ops_inet4 = {
+	.tw_getname = inet_tw_getname,
+	.tw_filter_skb = inet_tw_filter_skb,
+	.getname = inet_sock_getname,
+	.filter_skb = inet_filter_skb,
+};
+
+static int skbtrace_ipv4_init(void)
+{
+	return skbtrace_register_proto(AF_INET, tp_inet4, &ops_inet4);
+}
+
+static void skbtrace_ipv4_cleanup(void)
+{
+	skbtrace_unregister_proto(AF_INET);
+}
+
+module_init(skbtrace_ipv4_init);
+module_exit(skbtrace_ipv4_cleanup);
+MODULE_ALIAS("skbtrace-af-" __stringify(AF_INET));
+MODULE_LICENSE("GPL");
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5f64193..04c5113 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -280,6 +280,9 @@
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>

+#include <linux/skbtrace.h>
+#include <trace/events/skbtrace_ipv4.h>
+
 int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;

 struct percpu_counter tcp_orphan_count;
@@ -1989,6 +1992,8 @@ void tcp_set_state(struct sock *sk, int state)
 			TCP_DEC_STATS(sock_net(sk), TCP_MIB_CURRESTAB);
 	}

+	trace_tcp_connection(sk, state);
+
 	/* Change state AFTER socket is unhashed to avoid closed
 	 * socket sitting in hash tables.
 	 */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d377f48..483ee29 100644
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
@@ -760,6 +762,7 @@ void tcp_enter_cwr(struct sock *sk, const int
set_ssthresh)

 		tcp_set_ca_state(sk, TCP_CA_CWR);
 	}
+	trace_tcp_congestion(sk, skbtrace_tcp_cong_cwr);
 }

 /*
@@ -1970,6 +1973,8 @@ void tcp_enter_frto(struct sock *sk)
 	tcp_set_ca_state(sk, TCP_CA_Disorder);
 	tp->high_seq = tp->snd_nxt;
 	tp->frto_counter = 1;
+
+	trace_tcp_congestion(sk, skbtrace_tcp_cong_frto);
 }

 /* Enter Loss state after F-RTO was applied. Dupack arrived after RTO,
@@ -2037,6 +2042,8 @@ static void tcp_enter_frto_loss(struct sock *sk,
int allowed_segments, int flag)
 	TCP_ECN_queue_cwr(tp);

 	tcp_clear_all_retrans_hints(tp);
+
+	trace_tcp_congestion(sk, skbtrace_tcp_cong_frto_loss);
 }

 static void tcp_clear_retrans_partial(struct tcp_sock *tp)
@@ -2066,6 +2073,8 @@ void tcp_enter_loss(struct sock *sk, int how)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;

+	trace_tcp_congestion(sk, skbtrace_tcp_cong_loss);
+
 	/* Reduce ssthresh if it has not yet been made inside this window. */
 	if (icsk->icsk_ca_state <= TCP_CA_Disorder || tp->snd_una ==
tp->high_seq ||
 	    (icsk->icsk_ca_state == TCP_CA_Loss && !icsk->icsk_retransmits)) {
@@ -3039,6 +3048,7 @@ static void tcp_fastretrans_alert(struct sock *sk,
int pkts_acked,
 		/* Otherwise enter Recovery state */
 		tcp_enter_recovery(sk, (flag & FLAG_ECE));
 		fast_rexmit = 1;
+		trace_tcp_congestion(sk, skbtrace_tcp_cong_fastrtx);
 	}

 	if (do_lost || (tcp_is_fack(tp) && tcp_head_timedout(sk)))
@@ -3051,6 +3061,7 @@ static void tcp_fastretrans_alert(struct sock *sk,
int pkts_acked,
 void tcp_valid_rtt_meas(struct sock *sk, u32 seq_rtt)
 {
 	tcp_rtt_estimator(sk, seq_rtt);
+	trace_tcp_rttm(sk, seq_rtt);
 	tcp_set_rto(sk);
 	inet_csk(sk)->icsk_backoff = 0;
 }
@@ -5391,6 +5402,7 @@ int tcp_rcv_established(struct sock *sk, struct
sk_buff *skb,
 {
 	struct tcp_sock *tp = tcp_sk(sk);

+	trace_tcp_active_conn(sk);
 	if (unlikely(sk->sk_rx_dst == NULL))
 		inet_csk(sk)->icsk_af_ops->sk_rx_dst_set(sk, skb);
 	/*
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 00a748d..77be917 100644
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
@@ -1525,6 +1528,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk,
struct sk_buff *skb,
 	if (__inet_inherit_port(sk, newsk) < 0)
 		goto put_and_exit;
 	__inet_hash_nolisten(newsk, NULL);
+	trace_tcp_connection(newsk, TCP_SYN_RECV);

 	return newsk;

@@ -2604,9 +2608,37 @@ int tcp4_gro_complete(struct sk_buff *skb)
 	return tcp_gro_complete(skb);
 }

+#if HAVE_SKBTRACE
+int tcp_filter_skb(struct sock *sk, struct sk_buff *skb)
+{
+	struct inet_sock *inet;
+	struct tcphdr *th;
+
+	inet = inet_sk(sk);
+
+	skb_reset_transport_header(skb);
+
+	th = tcp_hdr(skb);
+	th->source              = inet->inet_sport;
+	th->dest                = inet->inet_dport;
+	th->seq                 = 0;
+	th->ack_seq             = 0;
+	th->window              = 0;
+	th->check		= 0;
+	th->urg_ptr		= 0;
+	*(((__be16 *)th) + 6)   = htons((sizeof(struct tcphdr) >> 2) << 12);
+
+	return sizeof(struct tcphdr);
+}
+EXPORT_SYMBOL_GPL(tcp_filter_skb);
+#endif
+
 struct proto tcp_prot = {
 	.name			= "TCP",
 	.owner			= THIS_MODULE,
+#if HAVE_SKBTRACE
+	.filter_skb		= tcp_filter_skb,
+#endif
 	.close			= tcp_close,
 	.connect		= tcp_v4_connect,
 	.disconnect		= tcp_disconnect,
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 6ff7f10..e955132 100644
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

@@ -143,6 +146,7 @@ kill_with_rst:

 		/* FIN arrived, enter true time-wait state. */
 		tw->tw_substate	  = TCP_TIME_WAIT;
+		trace_tcp_connection(tw, TCP_TIME_WAIT + TCP_MAX_STATES);
 		tcptw->tw_rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 		if (tmp_opt.saw_tstamp) {
 			tcptw->tw_ts_recent_stamp = get_seconds();
@@ -258,6 +262,28 @@ kill:
 }
 EXPORT_SYMBOL(tcp_timewait_state_process);

+#if HAVE_SKBTRACE
+int tcp_tw_filter_skb(struct inet_timewait_sock *tw, struct sk_buff *skb)
+{
+	struct tcphdr *th;
+
+	skb_reset_transport_header(skb);
+
+	th = tcp_hdr(skb);
+	th->source              = tw->tw_sport;
+	th->dest                = tw->tw_dport;
+	th->seq                 = 0;
+	th->ack_seq             = 0;
+	th->window              = 0;
+	th->check		= 0;
+	th->urg_ptr		= 0;
+	*(((__be16 *)th) + 6)   = htons((sizeof(struct tcphdr) >> 2) << 12);
+
+	return sizeof(struct tcphdr);
+}
+EXPORT_SYMBOL_GPL(tcp_tw_filter_skb);
+#endif
+
 /*
  * Move a socket to time-wait or dead fin-wait-2 state.
  */
@@ -320,6 +346,15 @@ void tcp_time_wait(struct sock *sk, int state, int
timeo)
 		} while (0);
 #endif

+#if HAVE_SKBTRACE
+{
+		if (!tw->tw_skbtrace) {
+			tw->tw_skbtrace = sk->sk_skbtrace;
+			sock_skbtrace_reset(sk);
+		}
+}
+#endif
+
 		/* Linkage updates. */
 		__inet_twsk_hashdance(tw, sk, &tcp_hashinfo);

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d046326..5a00d89 100644
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

@@ -996,6 +999,8 @@ static int tcp_transmit_skb(struct sock *sk, struct
sk_buff *skb, int clone_it,

 	BUG_ON(!skb || !tcp_skb_pcount(skb));

+	trace_tcp_active_conn(sk);
+
 	/* If congestion control is doing timestamping, we must
 	 * take such a timestamp before we potentially clone/copy.
 	 */
@@ -1853,15 +1858,18 @@ static int tcp_mtu_probe(struct sock *sk)

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
@@ -1956,7 +1964,7 @@ static bool tcp_write_xmit(struct sock *sk,
unsigned int mss_now, int nonagle,
 	struct sk_buff *skb;
 	unsigned int tso_segs, sent_pkts;
 	int cwnd_quota;
-	int result;
+	int retval, result, sndlim;

 	sent_pkts = 0;

@@ -1970,6 +1978,8 @@ static bool tcp_write_xmit(struct sock *sk,
unsigned int mss_now, int nonagle,
 		}
 	}

+	sndlim = skbtrace_tcp_sndlim_ok;
+	result = 0;
 	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;

@@ -1978,20 +1988,27 @@ static bool tcp_write_xmit(struct sock *sk,
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

 		/* TSQ : sk_wmem_alloc accounts skb truesize,
@@ -2009,14 +2026,18 @@ static bool tcp_write_xmit(struct sock *sk,
unsigned int mss_now, int nonagle,
 							  sk->sk_gso_max_segs));

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
@@ -2025,17 +2046,25 @@ static bool tcp_write_xmit(struct sock *sk,
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
