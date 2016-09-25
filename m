From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 50/53] netfilter: xt_socket: fix transparent match for IPv6 request sockets
Date: Mon, 26 Sep 2016 01:07:00 +0200
Message-ID: <1474844823-2026-51-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: KOVACS Krisztian <hidden@balabit.com>

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
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/tcp_input.c | 1 +
 net/ipv4/tcp_ipv4.c  | 1 -
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8cd02c0b056c..f3a9f3c2c8d8 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6269,6 +6269,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
 	tcp_openreq_init(req, &tmp_opt, skb, sk);
+	inet_rsk(req)->no_srccheck = inet_sk(sk)->transparent;
 
 	/* Note: tcp_v6_init_req() might override ir_iif for link locals */
 	inet_rsk(req)->ir_iif = inet_request_bound_dev_if(sk, skb);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a75bf48d7950..13b05adf9d3e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1196,7 +1196,6 @@ static void tcp_v4_init_req(struct request_sock *req,
 
 	sk_rcv_saddr_set(req_to_sk(req), ip_hdr(skb)->daddr);
 	sk_daddr_set(req_to_sk(req), ip_hdr(skb)->saddr);
-	ireq->no_srccheck = inet_sk(sk_listener)->transparent;
 	ireq->opt = tcp_v4_save_options(skb);
 }
 
-- 
2.1.4

