From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net-next 4/5] tcp: Introduce tcp_sk_trace and related structs.
Date: Sun, 14 Dec 2014 17:56:45 -0800
Message-ID: <1418608606-1569264-5-git-send-email-kafai@fb.com>
References: <1418608606-1569264-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>, Josef Bacik <jbacik@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:24383 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750807AbaLOB5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2014 20:57:18 -0500
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id sBF1tfet008413
	for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 17:57:18 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1r9caw9n5t-4
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 17:57:17 -0800
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 ad1d168a83fd11e4af7d24be05956610-8e7d7390 for <netdev@vger.kernel.org>;	Sun,
 14 Dec 2014 17:57:08 -0800
In-Reply-To: <1418608606-1569264-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tcp_sk_trace and its related structs define what will be
collected and recorded to the tracing's ring_buffer by
the TCP tracer (in the following patch).

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 include/linux/tcp.h            |  4 +++
 include/net/tcp_trace.h        | 18 ++++++++++
 include/uapi/linux/tcp_trace.h | 78 ++++++++++++++++++++++++++++++++++++++++++
 kernel/trace/Kconfig           | 11 ++++++
 kernel/trace/Makefile          |  1 +
 kernel/trace/tcp_trace.c       | 37 ++++++++++++++++++++
 net/ipv4/tcp.c                 |  4 +++
 7 files changed, 153 insertions(+)
 create mode 100644 include/net/tcp_trace.h
 create mode 100644 include/uapi/linux/tcp_trace.h
 create mode 100644 kernel/trace/tcp_trace.c

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 67309ec..8d25cb3 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -315,6 +315,10 @@ struct tcp_sock {
 	 * socket. Used to retransmit SYNACKs etc.
 	 */
 	struct request_sock *fastopen_rsk;
+
+#ifdef CONFIG_TCP_TRACE
+	struct tcp_sk_trace *trace;
+#endif
 };
 
 enum tsq_flags {
diff --git a/include/net/tcp_trace.h b/include/net/tcp_trace.h
new file mode 100644
index 0000000..f800cc7
--- /dev/null
+++ b/include/net/tcp_trace.h
@@ -0,0 +1,18 @@
+#ifndef TCP_TRACE_H
+#define TCP_TRACE_H
+
+struct sock;
+
+#ifdef CONFIG_TCP_TRACE
+
+void tcp_sk_trace_init(struct sock *sk);
+void tcp_sk_trace_destruct(struct sock *sk);
+
+#else /* CONFIG_TCP_TRACE */
+
+static inline void tcp_sk_trace_init(struct sock *sk) {}
+static inline void tcp_sk_trace_destruct(struct sock *sk) {}
+
+#endif
+
+#endif /* TCP_TRACE_H */
diff --git a/include/uapi/linux/tcp_trace.h b/include/uapi/linux/tcp_trace.h
new file mode 100644
index 0000000..4f91056
--- /dev/null
+++ b/include/uapi/linux/tcp_trace.h
@@ -0,0 +1,78 @@
+#ifndef UAPI_TCP_TRACE_H
+#define UAPI_TCP_TRACE_H
+
+#include <linux/kernel.h>
+
+#define TCP_TRACE_MAGIC		0x54435000
+#define TCP_TRACE_VERSION	0x01
+#define TCP_TRACE_MAGIC_VERSION	(TCP_TRACE_MAGIC | TCP_TRACE_VERSION)
+
+enum tcp_trace_events {
+	TCP_TRACE_EVENT_ESTABLISHED,
+	TCP_TRACE_EVENT_PERIODIC,	/* Periodic event every 2s */
+	TCP_TRACE_EVENT_RETRANS,	/* Retrans (not in TCP_CA_Loss) */
+	TCP_TRACE_EVENT_RETRANS_LOSS,	/* Retrans in TCP_CA_Loss */
+	TCP_TRACE_EVENT_CLOSE,	/* Connection close */
+};
+
+struct tcp_stats {
+	/* outing packets */
+	__u32	segs_out;
+	__u32	data_segs_out;
+	__u64	data_octets_out;
+
+	/* retrans */
+	__u32	other_segs_retrans;
+	__u32	other_octets_retrans;
+	__u32	loss_segs_retrans;
+	__u32	loss_octets_retrans;
+
+	/* incoming packets */
+	__u32	segs_in;
+	__u32	data_segs_in;
+	__u64	data_octets_in;
+
+	/* RTT */
+	__u64	rtt_sample_us;
+	__u64	max_rtt_us;
+	__u64	min_rtt_us;
+	__u64	sum_rtt_us;
+	__u32	count_rtt;
+
+	/* RTO */
+	__u32	max_rto_ms;
+	__u32	min_rto_ms;
+
+	/* OOO or Loss */
+	__u32	dup_acks_in;
+	__u32	sacks_in;
+	__u32	sack_blks_in;
+	__u32	ooo_in;
+} __packed;
+
+struct tcp_trace {
+	__u32	magic;
+	__u8	event:7,
+		ipv6:1;
+	__u32	local_addr[4];
+	__u32	remote_addr[4];
+	__u16	local_port;
+	__u16	remote_port;
+} __packed;
+
+struct tcp_trace_basic {
+	struct tcp_trace event;
+	/* current values from tcp_sock */
+	__u32	snd_cwnd;
+	__u32	mss;
+	__u32	ssthresh;
+	__u64	srtt_us;
+	__u32	rto_ms;
+} __packed;
+
+struct tcp_trace_stats {
+	struct tcp_trace_basic basic;
+	struct tcp_stats stats;
+} __packed;
+
+#endif /* UAPI_TCP_TRACE_H */
diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
index a5da09c..f30835c 100644
--- a/kernel/trace/Kconfig
+++ b/kernel/trace/Kconfig
@@ -599,6 +599,17 @@ config RING_BUFFER_STARTUP_TEST
 
 	 If unsure, say N
 
+config TCP_TRACE
+	bool "TCP tracing"
+	depends on NET && INET
+	select DEBUG_FS
+	select TRACEPOINTS
+	select GENERIC_TRACER
+	help
+	  This tracer collects per-flow statistics and events.
+
+	  If unsure, say N.
+
 endif # FTRACE
 
 endif # TRACING_SUPPORT
diff --git a/kernel/trace/Makefile b/kernel/trace/Makefile
index 67d6369..71d008a 100644
--- a/kernel/trace/Makefile
+++ b/kernel/trace/Makefile
@@ -65,5 +65,6 @@ obj-$(CONFIG_PROBE_EVENTS) += trace_probe.o
 obj-$(CONFIG_UPROBE_EVENT) += trace_uprobe.o
 
 obj-$(CONFIG_TRACEPOINT_BENCHMARK) += trace_benchmark.o
+obj-$(CONFIG_TCP_TRACE) += tcp_trace.o
 
 libftrace-y := ftrace.o
diff --git a/kernel/trace/tcp_trace.c b/kernel/trace/tcp_trace.c
new file mode 100644
index 0000000..9d09fd0
--- /dev/null
+++ b/kernel/trace/tcp_trace.c
@@ -0,0 +1,37 @@
+#include <net/tcp_trace.h>
+#include <linux/tcp.h>
+#include <uapi/linux/tcp_trace.h>
+
+static bool tcp_trace_enabled __read_mostly;
+
+struct tcp_sk_trace {
+	struct tcp_stats stats;
+	unsigned long start_ts;
+	unsigned long last_ts;
+};
+
+void tcp_sk_trace_init(struct sock *sk)
+{
+	struct tcp_sk_trace *sktr;
+
+	tcp_sk(sk)->trace = NULL;
+	if (!tcp_trace_enabled)
+		return;
+
+	sktr  = kzalloc(sizeof(*sktr), gfp_any());
+	if (unlikely(!sktr))
+		return;
+
+	tcp_sk(sk)->trace = sktr;
+	sk->sk_destruct = tcp_sock_destruct;
+
+	sktr->stats.min_rtt_us = U64_MAX;
+	sktr->stats.min_rto_ms = U32_MAX;
+
+	sktr->last_ts = sktr->start_ts = jiffies;
+}
+
+void tcp_sk_trace_destruct(struct sock *sk)
+{
+	kfree(tcp_sk(sk)->trace);
+}
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3b887fa..41871c4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -275,6 +275,7 @@
 #include <net/xfrm.h>
 #include <net/ip.h>
 #include <net/sock.h>
+#include <net/tcp_trace.h>
 #include <trace/events/tcp.h>
 
 #include <asm/uaccess.h>
@@ -1904,6 +1905,7 @@ void tcp_set_state(struct sock *sk, int state)
 	case TCP_ESTABLISHED:
 		if (oldstate != TCP_ESTABLISHED) {
 			TCP_INC_STATS(sock_net(sk), TCP_MIB_CURRESTAB);
+			tcp_sk_trace_init(sk);
 			trace_tcp_established(sk);
 		}
 		break;
@@ -2254,6 +2256,8 @@ EXPORT_SYMBOL(tcp_disconnect);
 
 void tcp_sock_destruct(struct sock *sk)
 {
+	tcp_sk_trace_destruct(sk);
+
 	inet_sock_destruct(sk);
 
 	kfree(inet_csk(sk)->icsk_accept_queue.fastopenq);
-- 
1.8.1
