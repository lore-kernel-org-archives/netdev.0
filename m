From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 02/13] Port redirection support for TCP
Date: Mon, 05 Mar 2007 16:45:11 +0100
Message-ID: <20070305154511.3471.9670.stgit@nienna.balabit>
References: <20070305154451.3471.18396.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:1434 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933531AbXCEPpN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 10:45:13 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id CAC2F294020
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2007 16:45:11 +0100 (CET)
In-Reply-To: <20070305154451.3471.18396.stgit@nienna.balabit>
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

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 include/net/inet_sock.h         |    1 +
 include/net/tcp.h               |    1 +
 net/ipv4/inet_connection_sock.c |    2 ++
 net/ipv4/syncookies.c           |    1 +
 net/ipv4/tcp_output.c           |    2 +-
 5 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index ce6da97..0bd167b 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -64,6 +64,7 @@ struct inet_request_sock {
 #endif
 	__be32			loc_addr;
 	__be32			rmt_addr;
+	__be16			loc_port;
 	__be16			rmt_port;
 	u16			snd_wscale : 4, 
 				rcv_wscale : 4, 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5c472f2..e1cb3d0 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -982,6 +982,7 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	ireq->acked = 0;
 	ireq->ecn_ok = 0;
 	ireq->rmt_port = skb->h.th->source;
+	ireq->loc_port = skb->h.th->dest;
 }
 
 extern void tcp_enter_memory_pressure(void);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 43fb160..83ad972 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -502,6 +502,8 @@ struct sock *inet_csk_clone(struct sock *sk, const struct request_sock *req,
 		newicsk->icsk_bind_hash = NULL;
 
 		inet_sk(newsk)->dport = inet_rsk(req)->rmt_port;
+		inet_sk(newsk)->num = ntohs(inet_rsk(req)->loc_port);
+		inet_sk(newsk)->sport = inet_rsk(req)->loc_port;
 		newsk->sk_write_space = sk_stream_write_space;
 
 		newicsk->icsk_retransmits = 0;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 33016cc..431c81d 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -223,6 +223,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	treq->rcv_isn		= ntohl(skb->h.th->seq) - 1;
 	treq->snt_isn		= cookie;
 	req->mss		= mss;
+	ireq->loc_port		= skb->h.th->dest;
 	ireq->rmt_port		= skb->h.th->source;
 	ireq->loc_addr		= skb->nh.iph->daddr;
 	ireq->rmt_addr		= skb->nh.iph->saddr;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index dc15113..a3ea7a1 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2135,7 +2135,7 @@ struct sk_buff * tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	th->syn = 1;
 	th->ack = 1;
 	TCP_ECN_make_synack(req, th);
-	th->source = inet_sk(sk)->sport;
+	th->source = ireq->loc_port;
 	th->dest = ireq->rmt_port;
 	TCP_SKB_CB(skb)->seq = tcp_rsk(req)->snt_isn;
 	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(skb)->seq + 1;

