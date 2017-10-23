From: Song Liu <songliubraving@fb.com>
Subject: [PATCH v2 net-next 6/6] tcp: add tracepoint trace_tcp_set_state()
Date: Mon, 23 Oct 2017 09:20:27 -0700
Message-ID: <20171023162027.2880430-7-songliubraving@fb.com>
References: <20171023162027.2880430-1-songliubraving@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexei.starovoitov@gmail.com>, <liu.song.a23@gmail.com>,
        Song Liu <songliubraving@fb.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:38636 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751336AbdJWQU5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 12:20:57 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9NGJrVG001389
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 09:20:56 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dsj8mrdp2-5
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 09:20:56 -0700
In-Reply-To: <20171023162027.2880430-1-songliubraving@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds tracepoint trace_tcp_set_state. Besides usual fields
(s/d ports, IP addresses), old and new state of the socket is also
printed with TP_printk, with __print_symbolic().

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/trace/events/tcp.h | 76 ++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp.c             |  4 +++
 2 files changed, 80 insertions(+)

diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
index 1724c12..03699ba 100644
--- a/include/trace/events/tcp.h
+++ b/include/trace/events/tcp.h
@@ -9,6 +9,22 @@
 #include <linux/tracepoint.h>
 #include <net/ipv6.h>
 
+#define tcp_state_name(state)	{ state, #state }
+#define show_tcp_state_name(val)			\
+	__print_symbolic(val,				\
+		tcp_state_name(TCP_ESTABLISHED),	\
+		tcp_state_name(TCP_SYN_SENT),		\
+		tcp_state_name(TCP_SYN_RECV),		\
+		tcp_state_name(TCP_FIN_WAIT1),		\
+		tcp_state_name(TCP_FIN_WAIT2),		\
+		tcp_state_name(TCP_TIME_WAIT),		\
+		tcp_state_name(TCP_CLOSE),		\
+		tcp_state_name(TCP_CLOSE_WAIT),		\
+		tcp_state_name(TCP_LAST_ACK),		\
+		tcp_state_name(TCP_LISTEN),		\
+		tcp_state_name(TCP_CLOSING),		\
+		tcp_state_name(TCP_NEW_SYN_RECV))
+
 /*
  * tcp event with arguments sk and skb
  *
@@ -161,6 +177,66 @@ DEFINE_EVENT(tcp_event_sk, tcp_destroy_sock,
 	TP_ARGS(sk)
 );
 
+TRACE_EVENT(tcp_set_state,
+
+	TP_PROTO(const struct sock *sk, const int oldstate, const int newstate),
+
+	TP_ARGS(sk, oldstate, newstate),
+
+	TP_STRUCT__entry(
+		__field(const void *, skaddr)
+		__field(int, oldstate)
+		__field(int, newstate)
+		__field(__u16, sport)
+		__field(__u16, dport)
+		__array(__u8, saddr, 4)
+		__array(__u8, daddr, 4)
+		__array(__u8, saddr_v6, 16)
+		__array(__u8, daddr_v6, 16)
+	),
+
+	TP_fast_assign(
+		struct inet_sock *inet = inet_sk(sk);
+		struct in6_addr *pin6;
+		__be32 *p32;
+
+		__entry->skaddr = sk;
+		__entry->oldstate = oldstate;
+		__entry->newstate = newstate;
+
+		__entry->sport = ntohs(inet->inet_sport);
+		__entry->dport = ntohs(inet->inet_dport);
+
+		p32 = (__be32 *) __entry->saddr;
+		*p32 = inet->inet_saddr;
+
+		p32 = (__be32 *) __entry->daddr;
+		*p32 =  inet->inet_daddr;
+
+#if IS_ENABLED(CONFIG_IPV6)
+		if (sk->sk_family == AF_INET6) {
+			pin6 = (struct in6_addr *)__entry->saddr_v6;
+			*pin6 = sk->sk_v6_rcv_saddr;
+			pin6 = (struct in6_addr *)__entry->daddr_v6;
+			*pin6 = sk->sk_v6_daddr;
+		} else
+#endif
+		{
+			pin6 = (struct in6_addr *)__entry->saddr_v6;
+			ipv6_addr_set_v4mapped(inet->inet_saddr, pin6);
+			pin6 = (struct in6_addr *)__entry->daddr_v6;
+			ipv6_addr_set_v4mapped(inet->inet_daddr, pin6);
+		}
+	),
+
+	TP_printk("sport=%hu dport=%hu saddr=%pI4 daddr=%pI4 saddrv6=%pI6c daddrv6=%pI6c oldstate=%s newstate=%s",
+		  __entry->sport, __entry->dport,
+		  __entry->saddr, __entry->daddr,
+		  __entry->saddr_v6, __entry->daddr_v6,
+		  show_tcp_state_name(__entry->oldstate),
+		  show_tcp_state_name(__entry->newstate))
+);
+
 #endif /* _TRACE_TCP_H */
 
 /* This part must be outside protection */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 8b1fa4d..be07e9b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -282,6 +282,8 @@
 #include <asm/ioctls.h>
 #include <net/busy_poll.h>
 
+#include <trace/events/tcp.h>
+
 int sysctl_tcp_min_tso_segs __read_mostly = 2;
 
 int sysctl_tcp_autocorking __read_mostly = 1;
@@ -2040,6 +2042,8 @@ void tcp_set_state(struct sock *sk, int state)
 {
 	int oldstate = sk->sk_state;
 
+	trace_tcp_set_state(sk, oldstate, state);
+
 	switch (state) {
 	case TCP_ESTABLISHED:
 		if (oldstate != TCP_ESTABLISHED)
-- 
2.9.5
