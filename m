From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [net-next PATCH 08/16] Port redirection support for TCP
Date: Wed, 01 Oct 2008 16:24:31 +0200
Message-ID: <20081001142431.4893.4942.stgit@este>
References: <20081001142431.4893.48078.stgit@este>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-reply-to: <20081001142431.4893.48078.stgit@este>
Sender: netfilter-devel-owner@vger.kernel.org
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
index dced3f6..de0ecc7 100644
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
index 12c9b4f..f6cc341 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -976,6 +976,7 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	ireq->acked = 0;
 	ireq->ecn_ok = 0;
 	ireq->rmt_port = tcp_hdr(skb)->source;
+	ireq->loc_port = tcp_hdr(skb)->dest;
 }
 
 extern void tcp_enter_memory_pressure(struct sock *sk);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 432c570..21fcc5a 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -516,6 +516,8 @@ struct sock *inet_csk_clone(struct sock *sk, const struct request_sock *req,
 		newicsk->icsk_bind_hash = NULL;
 
 		inet_sk(newsk)->dport = inet_rsk(req)->rmt_port;
+		inet_sk(newsk)->num = ntohs(inet_rsk(req)->loc_port);
+		inet_sk(newsk)->sport = inet_rsk(req)->loc_port;
 		newsk->sk_write_space = sk_stream_write_space;
 
 		newicsk->icsk_retransmits = 0;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 929302b..d346c22 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -297,6 +297,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	treq->rcv_isn		= ntohl(th->seq) - 1;
 	treq->snt_isn		= cookie;
 	req->mss		= mss;
+	ireq->loc_port		= th->dest;
 	ireq->rmt_port		= th->source;
 	ireq->loc_addr		= ip_hdr(skb)->daddr;
 	ireq->rmt_addr		= ip_hdr(skb)->saddr;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a8499ef..493553c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2275,7 +2275,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	th->syn = 1;
 	th->ack = 1;
 	TCP_ECN_make_synack(req, th);
-	th->source = inet_sk(sk)->sport;
+	th->source = ireq->loc_port;
 	th->dest = ireq->rmt_port;
 	/* Setting of flags are superfluous here for callers (and ECE is
 	 * not even correctly set)


