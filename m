From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive for
 TCP
Date: Mon, 23 Apr 2012 10:14:37 -0700
Message-ID: <4F958DFD.7010207@hp.com>
References: <1335173934.3293.84.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	=?UTF-8?B?TWFjaWVqIMW7ZW5jenlrb3dz?= =?UTF-8?B?a2k=?=
	<maze@google.com>, Yuchung Cheng <ycheng@google.com>,
	=?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:30024 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753392Ab2DWROj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:14:39 -0400
In-Reply-To: <1335173934.3293.84.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2012 02:38 AM, Eric Dumazet wrote:
> From: Eric Dumazet<edumazet@google.com>
>
> While investigating TCP performance problems on 10Gb+ links, we found=
 a
> tcp sender was dropping lot of incoming ACKS because of sk_rcvbuf lim=
it
> in sk_add_backlog(), especially if receiver doesnt use GRO/LRO and se=
nds
> one ACK every two MSS segments.
>
> A sender usually tweaks sk_sndbuf, but sk_rcvbuf stays at its default
> value (87380), allowing a too small backlog.
>
> A TCP ACK, even being small, can consume nearly same truesize space t=
han
> outgoing packets. Using sk_rcvbuf + sk_sndbuf as a limit makes sense =
and
> is fast to compute.
>
> Performance results on netperf, single flow, receiver with disabled
> GRO/LRO : 7500 Mbits instead of 6050 Mbits, no more TCPBacklogDrop
> increments at sender.
>
> Signed-off-by: Eric Dumazet<edumazet@google.com>
> Cc: Neal Cardwell<ncardwell@google.com>
> Cc: Tom Herbert<therbert@google.com>
> Cc: Maciej =C5=BBenczykowski<maze@google.com>
> Cc: Yuchung Cheng<ycheng@google.com>
> Cc: Ilpo J=C3=A4rvinen<ilpo.jarvinen@helsinki.fi>
> Cc: Rick Jones<rick.jones2@hp.com>
> ---
>   net/ipv4/tcp_ipv4.c |    3 ++-
>   net/ipv6/tcp_ipv6.c |    3 ++-
>   2 files changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 917607e..cf97e98 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1752,7 +1752,8 @@ process:
>   			if (!tcp_prequeue(sk, skb))
>   				ret =3D tcp_v4_do_rcv(sk, skb);
>   		}
> -	} else if (unlikely(sk_add_backlog(sk, skb, sk->sk_rcvbuf))) {
> +	} else if (unlikely(sk_add_backlog(sk, skb,
> +					   sk->sk_rcvbuf + sk->sk_sndbuf))) {
>   		bh_unlock_sock(sk);
>   		NET_INC_STATS_BH(net, LINUX_MIB_TCPBACKLOGDROP);
>   		goto discard_and_relse;

This will increase what can be queued for arriving segments in general=20
and not for ACKs specifically yes?  (A possible issue that would have=20
come-up with my previous wondering about just increasing SO_RCVBUF as=20
SO_SNDBUF was increasing).  Perhaps only add sk->sk_sndbuf to the limit=
=20
if the arriving segment contains no data?

rick


> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index b04e6d8..5fb19d3 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1654,7 +1654,8 @@ process:
>   			if (!tcp_prequeue(sk, skb))
>   				ret =3D tcp_v6_do_rcv(sk, skb);
>   		}
> -	} else if (unlikely(sk_add_backlog(sk, skb, sk->sk_rcvbuf))) {
> +	} else if (unlikely(sk_add_backlog(sk, skb,
> +					   sk->sk_rcvbuf + sk->sk_sndbuf))) {
>   		bh_unlock_sock(sk);
>   		NET_INC_STATS_BH(net, LINUX_MIB_TCPBACKLOGDROP);
>   		goto discard_and_relse;
>
