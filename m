From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net-next 3/5] tcp: Add a few more tracepoints for tcp tracer
Date: Sun, 14 Dec 2014 17:56:44 -0800
Message-ID: <1418608606-1569264-4-git-send-email-kafai@fb.com>
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
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:43756 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751102AbaLOB6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2014 20:58:18 -0500
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id sBF1wGnp023901
	for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 17:58:17 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1r9hebrtmp-6
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 17:58:17 -0800
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 acc01cfa83fd11e4a22e24be0593f280-ec7fa390 for <netdev@vger.kernel.org>;	Sun,
 14 Dec 2014 17:57:07 -0800
In-Reply-To: <1418608606-1569264-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tcp tracer, which will be added in the later patch, depends
on them to collect statistics.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 include/trace/events/tcp.h | 15 +++++++++++++++
 net/ipv4/tcp_input.c       |  6 ++++++
 2 files changed, 21 insertions(+)

diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
index 81b40ef..440a26b 100644
--- a/include/trace/events/tcp.h
+++ b/include/trace/events/tcp.h
@@ -167,6 +167,21 @@ TRACE_EVENT(tcp_rcv_established,
 		  __entry->rcv_nxt, __entry->rcv_wnd)
 );
 
+DECLARE_TRACE(tcp_ooo_rcv,
+	      TP_PROTO(struct sock *sk),
+	      TP_ARGS(sk)
+);
+
+DECLARE_TRACE(tcp_sacks_rcv,
+	     TP_PROTO(struct sock *sk, int num_sacks),
+	     TP_ARGS(sk, num_sacks)
+);
+
+DECLARE_TRACE(tcp_rtt_sample,
+	      TP_PROTO(struct sock *sk, long rtt_sample_us),
+	      TP_ARGS(sk, rtt_sample_us)
+);
+
 #undef TCP_TRACE_ASSIGN_SA
 
 #endif /* _TRACE_TCP_H */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 808fad7..1f82987 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1650,6 +1650,8 @@ tcp_sacktag_write_queue(struct sock *sk, const struct sk_buff *ack_skb,
 	int i, j;
 	int first_sack_index;
 
+	trace_tcp_sacks_rcv(sk, num_sacks);
+
 	state.flag = 0;
 	state.reord = tp->packets_out;
 	state.rtt_us = -1L;
@@ -2932,6 +2934,9 @@ static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
 
 	/* RFC6298: only reset backoff on valid RTT measurement. */
 	inet_csk(sk)->icsk_backoff = 0;
+
+	trace_tcp_rtt_sample(sk, seq_rtt_us);
+
 	return true;
 }
 
@@ -4232,6 +4237,7 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPOFOQUEUE);
 	SOCK_DEBUG(sk, "out of order segment: rcv_next %X seq %X - %X\n",
 		   tp->rcv_nxt, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq);
+	trace_tcp_ooo_rcv(sk);
 
 	skb1 = skb_peek_tail(&tp->out_of_order_queue);
 	if (!skb1) {
-- 
1.8.1
