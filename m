From: Song Liu <songliubraving@fb.com>
Subject: [PATCH v2 net-next 3/6] tcp: add tracepoint trace_tcp_send_reset
Date: Mon, 23 Oct 2017 09:20:24 -0700
Message-ID: <20171023162027.2880430-4-songliubraving@fb.com>
References: <20171023162027.2880430-1-songliubraving@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexei.starovoitov@gmail.com>, <liu.song.a23@gmail.com>,
        Song Liu <songliubraving@fb.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:55510 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751429AbdJWQU5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 12:20:57 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.21/8.16.0.21) with SMTP id v9NGIqvx017307
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 09:20:56 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 2ds42422jp-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 09:20:56 -0700
In-Reply-To: <20171023162027.2880430-1-songliubraving@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New tracepoint trace_tcp_send_reset is added and called from
tcp_v4_send_reset(), tcp_v6_send_reset() and tcp_send_active_reset().

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/trace/events/tcp.h | 11 +++++++++++
 net/core/net-traces.c      |  2 ++
 net/ipv4/tcp_ipv4.c        |  6 +++++-
 net/ipv4/tcp_output.c      |  5 +++++
 net/ipv6/tcp_ipv6.c        | 10 ++++++++--
 5 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
index 2b6fe72..3e57e1a 100644
--- a/include/trace/events/tcp.h
+++ b/include/trace/events/tcp.h
@@ -77,6 +77,17 @@ DEFINE_EVENT(tcp_event_sk_skb, tcp_retransmit_skb,
 	TP_ARGS(sk, skb)
 );
 
+/*
+ * skb of trace_tcp_send_reset is the skb that caused RST. In case of
+ * active reset, skb should be NULL
+ */
+DEFINE_EVENT(tcp_event_sk_skb, tcp_send_reset,
+
+	TP_PROTO(const struct sock *sk, const struct sk_buff *skb),
+
+	TP_ARGS(sk, skb)
+);
+
 #endif /* _TRACE_TCP_H */
 
 /* This part must be outside protection */
diff --git a/net/core/net-traces.c b/net/core/net-traces.c
index f4e4fa2..8dcd9b0 100644
--- a/net/core/net-traces.c
+++ b/net/core/net-traces.c
@@ -49,3 +49,5 @@ EXPORT_TRACEPOINT_SYMBOL_GPL(br_fdb_update);
 EXPORT_TRACEPOINT_SYMBOL_GPL(kfree_skb);
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(napi_poll);
+
+EXPORT_TRACEPOINT_SYMBOL_GPL(tcp_send_reset);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index e22439f..eb3f3b8 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -85,6 +85,8 @@
 #include <crypto/hash.h>
 #include <linux/scatterlist.h>
 
+#include <trace/events/tcp.h>
+
 #ifdef CONFIG_TCP_MD5SIG
 static int tcp_v4_md5_hash_hdr(char *md5_hash, const struct tcp_md5sig_key *key,
 			       __be32 daddr, __be32 saddr, const struct tcphdr *th);
@@ -701,8 +703,10 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 	 * routing might fail in this case. No choice here, if we choose to force
 	 * input interface, we will misroute in case of asymmetric route.
 	 */
-	if (sk)
+	if (sk) {
 		arg.bound_dev_if = sk->sk_bound_dev_if;
+		trace_tcp_send_reset(sk, skb);
+	}
 
 	BUILD_BUG_ON(offsetof(struct sock, sk_bound_dev_if) !=
 		     offsetof(struct inet_timewait_sock, tw_bound_dev_if));
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 988733f..1f01f4c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3084,6 +3084,11 @@ void tcp_send_active_reset(struct sock *sk, gfp_t priority)
 	/* Send it off. */
 	if (tcp_transmit_skb(sk, skb, 0, priority))
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTFAILED);
+
+	/* skb of trace_tcp_send_reset() keeps the skb that caused RST,
+	 * skb here is different to the troublesome skb, so use NULL
+	 */
+	trace_tcp_send_reset(sk, NULL);
 }
 
 /* Send a crossed SYN-ACK during socket establishment.
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ae83615..0e25299 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -69,6 +69,8 @@
 #include <crypto/hash.h>
 #include <linux/scatterlist.h>
 
+#include <trace/events/tcp.h>
+
 static void	tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb);
 static void	tcp_v6_reqsk_send_ack(const struct sock *sk, struct sk_buff *skb,
 				      struct request_sock *req);
@@ -890,7 +892,7 @@ static void tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb)
 	int genhash;
 	struct sock *sk1 = NULL;
 #endif
-	int oif;
+	int oif = 0;
 
 	if (th->rst)
 		return;
@@ -939,7 +941,11 @@ static void tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb)
 		ack_seq = ntohl(th->seq) + th->syn + th->fin + skb->len -
 			  (th->doff << 2);
 
-	oif = sk ? sk->sk_bound_dev_if : 0;
+	if (sk) {
+		oif = sk->sk_bound_dev_if;
+		trace_tcp_send_reset(sk, skb);
+	}
+
 	tcp_v6_send_response(sk, skb, seq, ack_seq, 0, 0, 0, oif, key, 1, 0, 0);
 
 #ifdef CONFIG_TCP_MD5SIG
-- 
2.9.5
