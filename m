From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net-next 1/5] tcp: Add TCP TRACE_EVENTs
Date: Sun, 14 Dec 2014 17:56:42 -0800
Message-ID: <1418608606-1569264-2-git-send-email-kafai@fb.com>
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
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:49587 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750767AbaLOB5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2014 20:57:21 -0500
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id sBF1r2Vk018276
	for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 17:57:20 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1r9hebrtme-3
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 17:57:20 -0800
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 aca4fa7483fd11e4b40824be0593f280-e87f2390 for <netdev@vger.kernel.org>;	Sun,
 14 Dec 2014 17:57:07 -0800
In-Reply-To: <1418608606-1569264-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add TRACE_EVENT when:
1. connection established
2. segs received
3. segs sending out
4. connection close

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 include/trace/events/tcp.h | 175 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/net-traces.c      |   1 +
 net/ipv4/tcp.c             |   6 +-
 net/ipv4/tcp_input.c       |   3 +
 net/ipv4/tcp_output.c      |   3 +
 5 files changed, 187 insertions(+), 1 deletion(-)
 create mode 100644 include/trace/events/tcp.h

diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
new file mode 100644
index 0000000..81b40ef
--- /dev/null
+++ b/include/trace/events/tcp.h
@@ -0,0 +1,175 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM tcp
+
+#if !defined(_TRACE_TCP_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_TCP_H
+
+#include <net/sock.h>
+#include <net/inet_sock.h>
+#include <net/tcp.h>
+#include <linux/skbuff.h>
+#include <linux/ipv6.h>
+#include <linux/tracepoint.h>
+#include <uapi/linux/in6.h>
+
+#define TCP_TRACE_ASSIGN_SA(e, sk)	do {				\
+	(e)->lport = inet_sk((sk))->inet_sport;				\
+	(e)->rport = inet_sk((sk))->inet_dport;				\
+	if ((sk)->sk_family == AF_INET) {				\
+		(e)->ipv6 = 0;						\
+		memset((e)->laddr, 0, sizeof((e)->laddr));		\
+		memset((e)->raddr, 0, sizeof((e)->raddr));		\
+		memcpy((e)->laddr, &inet_sk((sk))->inet_saddr,		\
+		       sizeof(inet_sk((sk))->inet_saddr));		\
+		memcpy((e)->raddr, &inet_sk((sk))->inet_daddr,		\
+		       sizeof(inet_sk((sk))->inet_daddr));		\
+	} else {							\
+		(e)->ipv6 = 1;						\
+		memcpy((e)->laddr, inet6_sk((sk))->saddr.s6_addr,	\
+		       sizeof((e)->laddr));				\
+		memcpy((e)->raddr, (sk)->sk_v6_daddr.s6_addr,		\
+		       sizeof((e)->raddr));				\
+	}								\
+} while (0)
+
+DECLARE_EVENT_CLASS(tcp,
+	TP_PROTO(struct sock *sk),
+	TP_ARGS(sk),
+	TP_STRUCT__entry(
+		__field(u8, ipv6)
+		__array(u8, laddr, 16)
+		__array(u8, raddr, 16)
+		__field(u16, lport)
+		__field(u16, rport)
+		__field(u32, snd_cwnd)
+		__field(u32, mss_cache)
+		__field(u32, ssthresh)
+		__field(u64, srtt_us)
+		__field(u32, rto_ms)
+	),
+	TP_fast_assign(
+		TCP_TRACE_ASSIGN_SA(__entry, sk);
+		__entry->snd_cwnd = tcp_sk(sk)->snd_cwnd;
+		__entry->mss_cache = tcp_sk(sk)->mss_cache;
+		__entry->ssthresh = tcp_current_ssthresh(sk);
+		__entry->srtt_us = tcp_sk(sk)->srtt_us >> 3;
+		__entry->rto_ms = jiffies_to_msecs(inet_csk(sk)->icsk_rto);
+	),
+	TP_printk("local=%s:%d remote=%s:%d snd_cwnd=%u mss_cache=%u "
+		  "ssthresh=%u srtt_us=%llu rto_ms=%u",
+		  __print_hex(__entry->laddr, 16),
+		  __entry->lport,
+		  __print_hex(__entry->raddr, 16),
+		  __entry->rport,
+		  __entry->snd_cwnd, __entry->mss_cache,
+		  __entry->ssthresh, __entry->srtt_us, __entry->rto_ms)
+);
+
+DEFINE_EVENT(tcp,
+	     tcp_established,
+	     TP_PROTO(struct sock *sk),
+	     TP_ARGS(sk)
+);
+
+DEFINE_EVENT(tcp,
+	     tcp_close,
+	     TP_PROTO(struct sock *sk),
+	     TP_ARGS(sk)
+);
+
+TRACE_EVENT(tcp_transmit_skb,
+	TP_PROTO(struct sock *sk, struct sk_buff *skb),
+	TP_ARGS(sk, skb),
+	TP_STRUCT__entry(
+		__field(u8, ipv6)
+		__array(u8, laddr, 16)
+		__array(u8, raddr, 16)
+		__field(u16, lport)
+		__field(u16, rport)
+		__field(u32, seq)
+		__field(u32, end_seq)
+		__field(u32, pcount)
+		__field(u8, ca_state)
+		__field(u32, snd_nxt)
+		__field(u32, snd_una)
+		__field(u32, snd_wnd)
+		__field(u32, snd_cwnd)
+		__field(u32, mss_cache)
+		__field(u32, ssthresh)
+		__field(u64, srtt_us)
+		__field(u32, rto_ms)
+	),
+	TP_fast_assign(
+		TCP_TRACE_ASSIGN_SA(__entry, sk);
+		__entry->seq = TCP_SKB_CB(skb)->seq;
+		__entry->end_seq = TCP_SKB_CB(skb)->end_seq;
+		__entry->pcount = tcp_skb_pcount(skb);
+		__entry->ca_state = inet_csk(sk)->icsk_ca_state;
+		__entry->snd_nxt = tcp_sk(sk)->snd_nxt;
+		__entry->snd_una = tcp_sk(sk)->snd_una;
+		__entry->snd_wnd = tcp_sk(sk)->snd_wnd;
+		__entry->snd_cwnd = tcp_sk(sk)->snd_cwnd;
+		__entry->mss_cache = tcp_sk(sk)->mss_cache;
+		__entry->ssthresh = tcp_current_ssthresh(sk);
+		__entry->srtt_us = tcp_sk(sk)->srtt_us >> 3;
+		__entry->rto_ms = jiffies_to_msecs(inet_csk(sk)->icsk_rto);
+	),
+	TP_printk("local=%s:%d remote=%s:%d "
+		  "skb_seq=%u skb_end_seq=%u pcount=%u ca_state=%x "
+		  "snd_nxt=%u snd_una=%u snd_wnd=%u snd_cwnd=%u mss_cache=%u "
+		  "ssthresh=%u srtt_us=%llu rto_ms=%u",
+		  __print_hex(__entry->laddr, 16), __entry->lport,
+		  __print_hex(__entry->raddr, 16), __entry->rport,
+
+		  __entry->seq, __entry->end_seq, __entry->pcount,
+		  __entry->ca_state,
+
+		  __entry->snd_nxt, __entry->snd_una, __entry->snd_wnd,
+		  __entry->snd_cwnd, __entry->mss_cache,
+
+		  __entry->ssthresh, __entry->srtt_us, __entry->rto_ms)
+);
+
+TRACE_EVENT(tcp_rcv_established,
+	    TP_PROTO(struct sock *sk, struct sk_buff *skb),
+	    TP_ARGS(sk, skb),
+	TP_STRUCT__entry(
+		__field(u8, ipv6)
+		__array(u8, laddr, 16)
+		__array(u8, raddr, 16)
+		__field(u16, lport)
+		__field(u16, rport)
+		__field(u32, seq)
+		__field(u32, end_seq)
+		__field(u32, ack_seq)
+		__field(u32, snd_una)
+		__field(u32, rcv_nxt)
+		__field(u32, rcv_wnd)
+	),
+	TP_fast_assign(
+		TCP_TRACE_ASSIGN_SA(__entry, sk);
+		__entry->seq = TCP_SKB_CB(skb)->seq;
+		__entry->end_seq = TCP_SKB_CB(skb)->end_seq;
+		__entry->ack_seq = TCP_SKB_CB(skb)->ack_seq;
+		__entry->snd_una = tcp_sk(sk)->snd_una;
+		__entry->rcv_nxt = tcp_sk(sk)->rcv_nxt;
+		__entry->rcv_wnd = tcp_sk(sk)->rcv_wnd;
+	),
+	TP_printk("local=%s:%d remote=%s:%d "
+		  "skb_seq=%u skb_end_seq=%u skb_ack_seq=%u snd_una=%u "
+		  "rcv_nxt=%u, rcv_wnd=%u",
+		  __print_hex(__entry->laddr, 16), __entry->lport,
+		  __print_hex(__entry->raddr, 16), __entry->rport,
+
+		  __entry->seq, __entry->end_seq, __entry->ack_seq,
+		  __entry->snd_una,
+
+		  __entry->rcv_nxt, __entry->rcv_wnd)
+);
+
+#undef TCP_TRACE_ASSIGN_SA
+
+#endif /* _TRACE_TCP_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/net/core/net-traces.c b/net/core/net-traces.c
index ba3c012..63f966b 100644
--- a/net/core/net-traces.c
+++ b/net/core/net-traces.c
@@ -31,6 +31,7 @@
 #include <trace/events/napi.h>
 #include <trace/events/sock.h>
 #include <trace/events/udp.h>
+#include <trace/events/tcp.h>
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(kfree_skb);
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3075723..3b887fa 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -275,6 +275,7 @@
 #include <net/xfrm.h>
 #include <net/ip.h>
 #include <net/sock.h>
+#include <trace/events/tcp.h>
 
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
@@ -1901,8 +1902,10 @@ void tcp_set_state(struct sock *sk, int state)
 
 	switch (state) {
 	case TCP_ESTABLISHED:
-		if (oldstate != TCP_ESTABLISHED)
+		if (oldstate != TCP_ESTABLISHED) {
 			TCP_INC_STATS(sock_net(sk), TCP_MIB_CURRESTAB);
+			trace_tcp_established(sk);
+		}
 		break;
 
 	case TCP_CLOSE:
@@ -1913,6 +1916,7 @@ void tcp_set_state(struct sock *sk, int state)
 		if (inet_csk(sk)->icsk_bind_hash &&
 		    !(sk->sk_userlocks & SOCK_BINDPORT_LOCK))
 			inet_put_port(sk);
+		trace_tcp_close(sk);
 		/* fall through */
 	default:
 		if (oldstate == TCP_ESTABLISHED)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 075ab4d..808fad7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -75,6 +75,7 @@
 #include <linux/ipsec.h>
 #include <asm/unaligned.h>
 #include <linux/errqueue.h>
+#include <trace/events/tcp.h>
 
 int sysctl_tcp_timestamps __read_mostly = 1;
 int sysctl_tcp_window_scaling __read_mostly = 1;
@@ -5076,6 +5077,8 @@ void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
+	trace_tcp_rcv_established(sk, skb);
+
 	if (unlikely(sk->sk_rx_dst == NULL))
 		inet_csk(sk)->icsk_af_ops->sk_rx_dst_set(sk, skb);
 	/*
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7f18262..9832512 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -41,6 +41,7 @@
 #include <linux/compiler.h>
 #include <linux/gfp.h>
 #include <linux/module.h>
+#include <trace/events/tcp.h>
 
 /* People can turn this off for buggy TCP's found in printers etc. */
 int sysctl_tcp_retrans_collapse __read_mostly = 1;
@@ -1014,6 +1015,8 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	/* Our usage of tstamp should remain private */
 	skb->tstamp.tv64 = 0;
 
+	trace_tcp_transmit_skb(sk, skb);
+
 	/* Cleanup our debris for IP stacks */
 	memset(skb->cb, 0, max(sizeof(struct inet_skb_parm),
 			       sizeof(struct inet6_skb_parm)));
-- 
1.8.1
