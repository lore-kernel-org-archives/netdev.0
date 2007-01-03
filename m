From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 02/10] Port redirection support for TCP
Date: Wed, 03 Jan 2007 17:34:57 +0100
Message-ID: <20070103163457.14635.96294.stgit@nienna.balabit>
References: <20070103163357.14635.37754.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
In-Reply-To: <20070103163357.14635.37754.stgit@nienna.balabit>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
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
 net/ipv4/tcp_output.c           |    2 +-
 4 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index ce6da97..0bd167b 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -64,6 +64,7 @@ #if defined(CONFIG_IPV6) || defined(CONF
 #endif
 	__be32			loc_addr;
 	__be32			rmt_addr;
+	__be16			loc_port;
 	__be16			rmt_port;
 	u16			snd_wscale : 4, 
 				rcv_wscale : 4, 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index b7d8317..08ea8f3 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -983,6 +983,7 @@ static inline void tcp_openreq_init(stru
 	ireq->acked = 0;
 	ireq->ecn_ok = 0;
 	ireq->rmt_port = skb->h.th->source;
+	ireq->loc_port = skb->h.th->dest;
 }
 
 extern void tcp_enter_memory_pressure(void);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 9d68837..889a487 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -502,6 +502,8 @@ struct sock *inet_csk_clone(struct sock
 		newicsk->icsk_bind_hash = NULL;
 
 		inet_sk(newsk)->dport = inet_rsk(req)->rmt_port;
+		inet_sk(newsk)->num = ntohs(inet_rsk(req)->loc_port);
+		inet_sk(newsk)->sport = inet_rsk(req)->loc_port;
 		newsk->sk_write_space = sk_stream_write_space;
 
 		newicsk->icsk_retransmits = 0;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 32c1a97..bb37048 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2132,7 +2132,7 @@ #endif
 	th->syn = 1;
 	th->ack = 1;
 	TCP_ECN_make_synack(req, th);
-	th->source = inet_sk(sk)->sport;
+	th->source = ireq->loc_port;
 	th->dest = ireq->rmt_port;
 	TCP_SKB_CB(skb)->seq = tcp_rsk(req)->snt_isn;
 	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(skb)->seq + 1;
