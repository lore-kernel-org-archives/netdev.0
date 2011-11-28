From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] tcp: tcp_sendmsg() wrong access to
 sk_route_caps
Date: Mon, 28 Nov 2011 02:46:37 -0800
Message-ID: <1322477197.2024.4.camel@Joe-Laptop>
References: <1322476067.2292.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:56601 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751724Ab1K1Kqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 05:46:39 -0500
In-Reply-To: <1322476067.2292.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-28 at 11:27 +0100, Eric Dumazet wrote:
> Now sk_route_caps is u64, its dangerous to use an integer to store
> result of an AND operator. It wont work if NETIF_F_SG is moved on the
> upper part of u64.

trivial comment below.

> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
[]
> @@ -917,9 +917,9 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
>  	struct iovec *iov;
>  	struct tcp_sock *tp = tcp_sk(sk);
>  	struct sk_buff *skb;
> -	int iovlen, flags;
> +	int iovlen, flags, err, copied;
>  	int mss_now, size_goal;
> -	int sg, err, copied;
> +	bool sg;
>  	long timeo;
>  
>  	lock_sock(sk);
> @@ -946,7 +946,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
>  	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
>  		goto out_err;
>  
> -	sg = sk->sk_route_caps & NETIF_F_SG;
> +	sg = !!(sk->sk_route_caps & NETIF_F_SG);

As sg is now bool, using !! is unnecessary.

A commit was done recently to remove one.
3ad9b358e03fd9dbf6705721490c811b666b0fe2
