From: Song Liu <songliubraving@fb.com>
Subject: [PATCH v2 net-next] tcp: add tracepoint trace_tcp_retransmit_synack()
Date: Mon, 30 Oct 2017 14:41:35 -0700
Message-ID: <20171030214135.2444870-2-songliubraving@fb.com>
References: <20171030214135.2444870-1-songliubraving@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexei.starovoitov@gmail.com>, <liu.song.a23@gmail.com>,
        Song Liu <songliubraving@fb.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37208 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932294AbdJ3Vlo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 17:41:44 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9ULd4tg011556
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 14:41:44 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dx8wj93s2-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 14:41:44 -0700
In-Reply-To: <20171030214135.2444870-1-songliubraving@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This tracepoint can be used to trace synack retransmits. It maintains
pointer to struct request_sock.

We cannot simply reuse trace_tcp_retransmit_skb() here, because the
sk here is the LISTEN socket. The IP addresses and ports should be
extracted from struct request_sock.

Note that, like many other tracepoints, this patch uses IS_ENABLED
in TP_fast_assign macro, which triggers sparse warning like:

./include/trace/events/tcp.h:274:1: error: directive in argument list
./include/trace/events/tcp.h:281:1: error: directive in argument list

However, there is no good solution to avoid these warnings. To the
best of our knowledge, these warnings are harmless.

Signed-off-by: Song Liu <songliubraving@fb.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 include/trace/events/tcp.h | 56 ++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_output.c      |  1 +
 2 files changed, 57 insertions(+)

diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
index 03699ba..07cccca 100644
--- a/include/trace/events/tcp.h
+++ b/include/trace/events/tcp.h
@@ -237,6 +237,62 @@ TRACE_EVENT(tcp_set_state,
 		  show_tcp_state_name(__entry->newstate))
 );
 
+TRACE_EVENT(tcp_retransmit_synack,
+
+	TP_PROTO(const struct sock *sk, const struct request_sock *req),
+
+	TP_ARGS(sk, req),
+
+	TP_STRUCT__entry(
+		__field(const void *, skaddr)
+		__field(const void *, req)
+		__field(__u16, sport)
+		__field(__u16, dport)
+		__array(__u8, saddr, 4)
+		__array(__u8, daddr, 4)
+		__array(__u8, saddr_v6, 16)
+		__array(__u8, daddr_v6, 16)
+	),
+
+	TP_fast_assign(
+		struct inet_request_sock *ireq = inet_rsk(req);
+		struct in6_addr *pin6;
+		__be32 *p32;
+
+		__entry->skaddr = sk;
+		__entry->req = req;
+
+		__entry->sport = ireq->ir_num;
+		__entry->dport = ntohs(ireq->ir_rmt_port);
+
+		p32 = (__be32 *) __entry->saddr;
+		*p32 = ireq->ir_loc_addr;
+
+		p32 = (__be32 *) __entry->daddr;
+		*p32 = ireq->ir_rmt_addr;
+
+#if IS_ENABLED(CONFIG_IPV6)
+		if (sk->sk_family == AF_INET6) {
+			pin6 = (struct in6_addr *)__entry->saddr_v6;
+			*pin6 = ireq->ir_v6_loc_addr;
+			pin6 = (struct in6_addr *)__entry->daddr_v6;
+			*pin6 = ireq->ir_v6_rmt_addr;
+		} else
+#endif
+		{
+			pin6 = (struct in6_addr *)__entry->saddr_v6;
+			ipv6_addr_set_v4mapped(ireq->ir_loc_addr, pin6);
+			pin6 = (struct in6_addr *)__entry->daddr_v6;
+			ipv6_addr_set_v4mapped(ireq->ir_rmt_addr, pin6);
+		}
+	),
+
+	TP_printk("sport=%hu dport=%hu saddr=%pI4 daddr=%pI4 saddrv6=%pI6c daddrv6=%pI6c",
+		  __entry->sport, __entry->dport,
+		  __entry->saddr, __entry->daddr,
+		  __entry->saddr_v6, __entry->daddr_v6)
+);
+
 #endif /* _TRACE_TCP_H */
 
 /* This part must be outside protection */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a69a34f..74d1c4d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3781,6 +3781,7 @@ int tcp_rtx_synack(const struct sock *sk, struct request_sock *req)
 		__NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
 		if (unlikely(tcp_passive_fastopen(sk)))
 			tcp_sk(sk)->total_retrans++;
+		trace_tcp_retransmit_synack(sk, req);
 	}
 	return res;
 }
-- 
2.9.5
