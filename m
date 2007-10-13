From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [PATCH 06/14] Port redirection support for TCP
Date: Sat, 13 Oct 2007 19:32:04 +0200
Message-ID: <20071013173204.22517.35523.stgit@nessa.odu>
References: <20071013172857.22517.84760.stgit@nessa.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:45511 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761344AbXJMSjs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2007 14:39:48 -0400
Received: from nessa.odu ([152.66.208.5])
 by balu.sch.bme.hu (Sun Java System Messaging Server 6.2-7.05 (built Sep  5
 2006)) with ESMTP id <0JPV009GJ1YHZ930@balu.sch.bme.hu> for
 netdev@vger.kernel.org; Sat, 13 Oct 2007 19:30:18 +0200 (CEST)
In-reply-to: <20071013172857.22517.84760.stgit@nessa.odu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Current TCP code relies on the local port of the listening socket
being the same as the destination address of the incoming
connection. Port redirection used by many transparent proxying
techniques obviously breaks this, so we have to store the original
destination port address.

This patch extends struct inet_request_sock and stores the incoming
destination port value there. It also modifies the handshake code to
use that value as the source port when sending reply packets.

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 include/net/inet_sock.h         |    2 +-
 include/net/tcp.h               |    1 +
 net/ipv4/inet_connection_sock.c |    2 ++
 net/ipv4/syncookies.c           |    1 +
 net/ipv4/tcp_output.c           |    2 +-
 5 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 517efe7..d7e2a52 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -61,8 +61,8 @@ struct inet_request_sock {
 	struct request_sock	req;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	u16			inet6_rsk_offset;
-	/* 2 bytes hole, try to pack */
 #endif
+	__be16			loc_port;
 	__be32			loc_addr;
 	__be32			rmt_addr;
 	__be16			rmt_port;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 92049e6..13bd06f 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1006,6 +1006,7 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	ireq->acked = 0;
 	ireq->ecn_ok = 0;
 	ireq->rmt_port = tcp_hdr(skb)->source;
+	ireq->loc_port = tcp_hdr(skb)->dest;
 }
 
 extern void tcp_enter_memory_pressure(void);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 1667cd8..eda765f 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -515,6 +515,8 @@ struct sock *inet_csk_clone(struct sock *sk, const struct request_sock *req,
 		newicsk->icsk_bind_hash = NULL;
 
 		inet_sk(newsk)->dport = inet_rsk(req)->rmt_port;
+		inet_sk(newsk)->num = ntohs(inet_rsk(req)->loc_port);
+		inet_sk(newsk)->sport = inet_rsk(req)->loc_port;
 		newsk->sk_write_space = sk_stream_write_space;
 
 		newicsk->icsk_retransmits = 0;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index a0f6fdb..6e84243 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -223,6 +223,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	treq->rcv_isn		= ntohl(th->seq) - 1;
 	treq->snt_isn		= cookie;
 	req->mss		= mss;
+	ireq->loc_port		= th->dest;
 	ireq->rmt_port		= th->source;
 	ireq->loc_addr		= ip_hdr(skb)->daddr;
 	ireq->rmt_addr		= ip_hdr(skb)->saddr;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 324b420..b27535f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2218,7 +2218,7 @@ struct sk_buff * tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	th->syn = 1;
 	th->ack = 1;
 	TCP_ECN_make_synack(req, th);
-	th->source = inet_sk(sk)->sport;
+	th->source = ireq->loc_port;
 	th->dest = ireq->rmt_port;
 	TCP_SKB_CB(skb)->seq = tcp_rsk(req)->snt_isn;
 	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(skb)->seq + 1;

