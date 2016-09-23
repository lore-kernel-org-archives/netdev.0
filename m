From: KOVACS Krisztian <hidden@balabit.com>
Subject: [PATCH] netfilter: xt_socket: fix transparent match for IPv6 request sockets
Date: Fri, 23 Sep 2016 11:27:42 +0200
Message-ID: <20160923092742.88262-1-hidden@balabit.com>
Cc: Alex Badics <alex.badics@balabit.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        KOVACS Krisztian <hidden@balabit.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The introduction of TCP_NEW_SYN_RECV state, and the addition of request
sockets to the ehash table seems to have broken the --transparent option
of the socket match for IPv6 (around commit a9407000).

Now that the socket lookup finds the TCP_NEW_SYN_RECV socket instead of the
listener, the --transparent option tries to match on the no_srccheck flag
of the request socket.

Unfortunately, that flag was only set for IPv4 sockets in tcp_v4_init_req()
by copying the transparent flag of the listener socket. This effectively
causes '-m socket --transparent' not match on the ACK packet sent by the
client in a TCP handshake.

Based on the suggestion from Eric Dumazet, this change moves the code
initializing no_srccheck to tcp_conn_request(), rendering the above
scenario working again.

Fixes: a940700003 ("netfilter: xt_socket: prepare for TCP_NEW_SYN_RECV support")
Signed-off-by: Alex Badics <alex.badics@balabit.com>
Signed-off-by: KOVACS Krisztian <hidden@balabit.com>
---
 net/ipv4/tcp_input.c | 1 +
 net/ipv4/tcp_ipv4.c  | 1 -
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3ebf45b..1fb2e82 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6260,6 +6260,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
 	tcp_openreq_init(req, &tmp_opt, skb, sk);
+	inet_rsk(req)->no_srccheck = inet_sk(sk)->transparent;
 
 	/* Note: tcp_v6_init_req() might override ir_iif for link locals */
 	inet_rsk(req)->ir_iif = inet_request_bound_dev_if(sk, skb);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7158d4f..b448eb9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1195,7 +1195,6 @@ static void tcp_v4_init_req(struct request_sock *req,
 
 	sk_rcv_saddr_set(req_to_sk(req), ip_hdr(skb)->daddr);
 	sk_daddr_set(req_to_sk(req), ip_hdr(skb)->saddr);
-	ireq->no_srccheck = inet_sk(sk_listener)->transparent;
 	ireq->opt = tcp_v4_save_options(skb);
 }
 
-- 
2.10.0

