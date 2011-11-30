From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next] Include selection of congestion control
 algorithm in that which is inherited across an accept() call
Date: Wed, 30 Nov 2011 06:21:01 +0100
Message-ID: <1322630461.2596.61.camel@edumazet-laptop>
References: <20111130003112.C04FE29005FE@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rick Jones <raj@tardy.cup.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:35399 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017Ab1K3FVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 00:21:07 -0500
Received: by eaak14 with SMTP id k14so156250eaa.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 21:21:05 -0800 (PST)
In-Reply-To: <20111130003112.C04FE29005FE@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 29 novembre 2011 =C3=A0 16:31 -0800, Rick Jones a =C3=A9crit :
> From: Rick Jones <rick.jones2@hp.com>
>=20
> Include congestion control algorithm in what is inherited across an
> accept() call.
>=20
> Signed-off-by: Rick Jones <rick.jones2@hp.com>
>=20

Hi Rick, thanks for working on this !

I am still not sure why adding new fields is needed, please see my
comment :

> ---
>=20
=2E..
>  include/linux/ipv6.h     |    3 +++
>  include/net/inet_sock.h  |    3 +++
>  net/ipv4/tcp_ipv4.c      |    3 +++
>  net/ipv4/tcp_minisocks.c |    2 +-
>  net/ipv6/tcp_ipv6.c      |    3 +++
>  5 files changed, 13 insertions(+), 1 deletions(-)
>=20
> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> index 0c99776..1d0dde3 100644
> --- a/include/linux/ipv6.h
> +++ b/include/linux/ipv6.h
> @@ -265,11 +265,14 @@ static inline int inet6_iif(const struct sk_buf=
f *skb)
>  	return IP6CB(skb)->iif;
>  }
> =20
> +struct tcp_congestion_ops;
> +
>  struct inet6_request_sock {
>  	struct in6_addr		loc_addr;
>  	struct in6_addr		rmt_addr;
>  	struct sk_buff		*pktopts;
>  	int			iif;
> +	const struct tcp_congestion_ops *cong_ops;
>  };
> =20
>  struct tcp6_request_sock {
> diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
> index f941964..9ec68a3 100644
> --- a/include/net/inet_sock.h
> +++ b/include/net/inet_sock.h
> @@ -69,6 +69,8 @@ struct ip_options_data {
>  	char			data[40];
>  };
> =20
> +struct tcp_congestion_ops;
> +
>  struct inet_request_sock {
>  	struct request_sock	req;
>  #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> @@ -89,6 +91,7 @@ struct inet_request_sock {
>  				no_srccheck: 1;
>  	kmemcheck_bitfield_end(flags);
>  	struct ip_options_rcu	*opt;
> +	const struct tcp_congestion_ops *cong_ops;
>  };
> =20
>  static inline struct inet_request_sock *inet_rsk(const struct reques=
t_sock *sk)
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index a9db4b1..79c02e2 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1254,6 +1254,7 @@ int tcp_v4_conn_request(struct sock *sk, struct=
 sk_buff *skb)
>  	const u8 *hash_location;
>  	struct request_sock *req;
>  	struct inet_request_sock *ireq;
> +	struct inet_connection_sock *icsk =3D inet_csk(sk);
>  	struct tcp_sock *tp =3D tcp_sk(sk);
>  	struct dst_entry *dst =3D NULL;
>  	__be32 saddr =3D ip_hdr(skb)->saddr;
> @@ -1341,6 +1342,8 @@ int tcp_v4_conn_request(struct sock *sk, struct=
 sk_buff *skb)
>  	ireq->rmt_addr =3D saddr;
>  	ireq->no_srccheck =3D inet_sk(sk)->transparent;
>  	ireq->opt =3D tcp_v4_save_options(sk, skb);
> +	ireq->cong_ops =3D (icsk->icsk_ca_ops) ? icsk->icsk_ca_ops :
> +					&tcp_init_congestion_ops;
> =20
>  	if (security_inet_conn_request(sk, skb, req))
>  		goto drop_and_free;
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index 945efff..be338d7 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -495,7 +495,7 @@ struct sock *tcp_create_openreq_child(struct sock=
 *sk, struct request_sock *req,
>  		newtp->frto_counter =3D 0;
>  		newtp->frto_highmark =3D 0;
> =20
> -		newicsk->icsk_ca_ops =3D &tcp_init_congestion_ops;
> +		newicsk->icsk_ca_ops =3D ireq->cong_ops;


At this point, sk points to listener socket and is locked, why not
simply copy inet_csk(sk)->icsk_ca_ops to newicsk->icsk_ca_ops ?

As a matter of fact, it was already copied at newsk creation (clone of
sk)

> =20
>  		tcp_set_ca_state(newsk, TCP_CA_Open);
>  		tcp_init_xmit_timers(newsk);
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 9d74eee..c689779 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1164,6 +1164,7 @@ static int tcp_v6_conn_request(struct sock *sk,=
 struct sk_buff *skb)
>  	const u8 *hash_location;
>  	struct request_sock *req;
>  	struct inet6_request_sock *treq;
> +	struct inet_connection_sock *icsk =3D inet_csk(sk);
>  	struct ipv6_pinfo *np =3D inet6_sk(sk);
>  	struct tcp_sock *tp =3D tcp_sk(sk);
>  	__u32 isn =3D TCP_SKB_CB(skb)->when;
> @@ -1254,6 +1255,8 @@ static int tcp_v6_conn_request(struct sock *sk,=
 struct sk_buff *skb)
>  		TCP_ECN_create_request(req, tcp_hdr(skb));
> =20
>  	treq->iif =3D sk->sk_bound_dev_if;
> +	treq->cong_ops =3D (icsk->icsk_ca_ops) ? icsk->icsk_ca_ops :
> +					&tcp_init_congestion_ops;
> =20
>  	/* So that link locals have meaning */
>  	if (!sk->sk_bound_dev_if &&


So my suggestion would be to use this two lines patch instead :

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 945efff..6b066e2 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -495,8 +495,6 @@ struct sock *tcp_create_openreq_child(struct sock *=
sk, struct request_sock *req,
 		newtp->frto_counter =3D 0;
 		newtp->frto_highmark =3D 0;
=20
-		newicsk->icsk_ca_ops =3D &tcp_init_congestion_ops;
-
 		tcp_set_ca_state(newsk, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
 		skb_queue_head_init(&newtp->out_of_order_queue);
