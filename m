From: Song Liu <songliubraving@fb.com>
Subject: [PATCH net-next 4/6] tcp: add tracepoint trace_tcp_receive_reset
Date: Fri, 20 Oct 2017 14:20:44 -0700
Message-ID: <20171020212046.577888-5-songliubraving@fb.com>
References: <20171020212046.577888-1-songliubraving@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexei.starovoitov@gmail.com>, <liu.song.a23@gmail.com>,
        Song Liu <songliubraving@fb.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:44066 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752418AbdJTVVA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 17:21:00 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.21/8.16.0.21) with SMTP id v9KLIatq014114
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 14:20:59 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 2dqjgn19d6-11
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 14:20:59 -0700
In-Reply-To: <20171020212046.577888-1-songliubraving@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New tracepoint trace_tcp_receive_reset is added and called from
tcp_reset(). This tracepoint is define with a new class tcp_event_sk.

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/trace/events/tcp.h | 66 ++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_input.c       |  3 +++
 2 files changed, 69 insertions(+)

diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
index 3e57e1a..c83c711 100644
--- a/include/trace/events/tcp.h
+++ b/include/trace/events/tcp.h
@@ -88,6 +88,72 @@ DEFINE_EVENT(tcp_event_sk_skb, tcp_send_reset,
 	TP_ARGS(sk, skb)
 );
 
+/*
+ * tcp event with arguments sk
+ *
+ * Note: this class requires a valid sk pointer.
+ */
+DECLARE_EVENT_CLASS(tcp_event_sk,
+
+	TP_PROTO(const struct sock *sk),
+
+	TP_ARGS(sk),
+
+	TP_STRUCT__entry(
+		__field(const void *, skaddr)
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
+	TP_printk("sport=%hu dport=%hu saddr=%pI4 daddr=%pI4 saddrv6=%pI6c daddrv6=%pI6c",
+		  __entry->sport, __entry->dport,
+		  __entry->saddr, __entry->daddr,
+		  __entry->saddr_v6, __entry->daddr_v6)
+);
+
+DEFINE_EVENT(tcp_event_sk, tcp_receive_reset,
+
+	TP_PROTO(const struct sock *sk),
+
+	TP_ARGS(sk)
+);
+
 #endif /* _TRACE_TCP_H */
 
 /* This part must be outside protection */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b2390bf..f041f38 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -75,6 +75,7 @@
 #include <linux/ipsec.h>
 #include <asm/unaligned.h>
 #include <linux/errqueue.h>
+#include <trace/events/tcp.h>
 
 int sysctl_tcp_fack __read_mostly;
 int sysctl_tcp_max_reordering __read_mostly = 300;
@@ -4010,6 +4011,8 @@ static inline bool tcp_sequence(const struct tcp_sock *tp, u32 seq, u32 end_seq)
 /* When we get a reset we do this. */
 void tcp_reset(struct sock *sk)
 {
+	trace_tcp_receive_reset(sk);
+
 	/* We want the right error as BSD sees it (and indeed as we do). */
 	switch (sk->sk_state) {
 	case TCP_SYN_SENT:
-- 
2.9.5
