From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: xt_socket: fix transparent match for IPv6
 request sockets
Date: Tue, 20 Sep 2016 08:01:12 -0700
Message-ID: <1474383672.23058.19.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160920132637.221892-1-hidden@balabit.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org,
        Alex Badics <alex.badics@balabit.com>,
        netdev <netdev@vger.kernel.org>
To: KOVACS Krisztian <hidden@balabit.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160920132637.221892-1-hidden@balabit.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-09-20 at 15:26 +0200, KOVACS Krisztian wrote:
> The introduction of TCP_NEW_SYN_RECV state, and the addition of request
> sockets to the ehash table seems to have broken the --transparent option
> of the socket match for IPv6 (around commit a9407000).
> 
> Now that the socket lookup finds the TCP_NEW_SYN_RECV socket instead of the
> listener, the --transparent option tries to match on the no_srccheck flag
> of the request socket.
> 
> Unfortunately, that flag was only set for IPv4 sockets in tcp_v4_init_req()
> by copying the transparent flag of the listener socket. This effectively
> causes '-m socket --transparent' not match on the ACK packet sent by the
> client in a TCP handshake.
> 
> This change adds the same code initializing no_srccheck to
> tcp_v6_init_req(), rendering the above scenario working again.
> 
> Signed-off-by: Alex Badics <alex.badics@balabit.com>
> Signed-off-by: KOVACS Krisztian <hidden@balabit.com>
> ---
>  net/ipv6/tcp_ipv6.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 94f4f89..21f2e5c 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -690,6 +690,7 @@ static void tcp_v6_init_req(struct request_sock *req,
>  
>  	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
>  	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
> +	ireq->no_srccheck = inet_sk(sk_listener)->transparent;
>  
>  	/* So that link locals have meaning */
>  	if (!sk_listener->sk_bound_dev_if &&

Thanks a lot for the bug hunting guys.

Could you add the precise tag to help stable backports ?

Fixes: 12-digit-sha1 ("patch title")

Since it is a netdev patch, I would also copy netdev@ (done here)

Also what about moving this (IPv4/IPv6 common code) before the
af_ops->init_req(req, sk, skb); call, since it is no longer family
specific ?

Something like :

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3ebf45b38bc3..0fccfd6cc258 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6264,6 +6264,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	/* Note: tcp_v6_init_req() might override ir_iif for link locals */
 	inet_rsk(req)->ir_iif = inet_request_bound_dev_if(sk, skb);
 
+	ireq->no_srccheck = inet_sk(sk)->transparent;
 	af_ops->init_req(req, sk, skb);
 
 	if (security_inet_conn_request(sk, skb, req))
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7158d4f8dae4..b448eb9fe1b9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1195,7 +1195,6 @@ static void tcp_v4_init_req(struct request_sock *req,
 
 	sk_rcv_saddr_set(req_to_sk(req), ip_hdr(skb)->daddr);
 	sk_daddr_set(req_to_sk(req), ip_hdr(skb)->saddr);
-	ireq->no_srccheck = inet_sk(sk_listener)->transparent;
 	ireq->opt = tcp_v4_save_options(skb);
 }
 


