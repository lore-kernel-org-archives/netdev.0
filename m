From: Duan Jiong <djduanjiong@gmail.com>
Subject: Re: [PATCH 1/6] ipv6: del the statements for updating route in, (dccp|tcp|sctp)_v6_err
Date: Mon, 16 Sep 2013 20:31:28 +0800
Message-ID: <5236FA20.2000705@gmail.com>
References: <5236EFEB.60106@cn.fujitsu.com> <5236F03F.5020407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:54901 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222Ab3IPMbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 08:31:35 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so4040538pdj.4
        for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 05:31:34 -0700 (PDT)
In-Reply-To: <5236F03F.5020407@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, i forgot to add "v3" in title.

Thanks,
Duan
=D3=DA 2013/9/16 19:49, Duan Jiong =D0=B4=B5=C0:
> Because we will do route updating for redirect in nidsc layer. And
> when dealing with redirect message, the dccp and sctp should like
> tcp return directly.
>
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
>  net/dccp/ipv6.c     | 10 +++-------
>  net/ipv6/tcp_ipv6.c | 12 ++++--------
>  net/sctp/input.c    | 12 ------------
>  net/sctp/ipv6.c     |  6 +++---
>  4 files changed, 10 insertions(+), 30 deletions(-)
>
> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> index 9c61f9c..300840c 100644
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -98,6 +98,9 @@ static void dccp_v6_err(struct sk_buff *skb, struct=
 inet6_skb_parm *opt,
>  		return;
>  	}
> =20
> +	if (type =3D=3D NDISC_REDIRECT)
> +		return;
> +
>  	sk =3D inet6_lookup(net, &dccp_hashinfo,
>  			&hdr->daddr, dh->dccph_dport,
>  			&hdr->saddr, dh->dccph_sport, inet6_iif(skb));
> @@ -130,13 +133,6 @@ static void dccp_v6_err(struct sk_buff *skb, str=
uct inet6_skb_parm *opt,
> =20
>  	np =3D inet6_sk(sk);
> =20
> -	if (type =3D=3D NDISC_REDIRECT) {
> -		struct dst_entry *dst =3D __sk_dst_check(sk, np->dst_cookie);
> -
> -		if (dst)
> -			dst->ops->redirect(dst, sk, skb);
> -	}
> -
>  	if (type =3D=3D ICMPV6_PKT_TOOBIG) {
>  		struct dst_entry *dst =3D NULL;
> =20
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 5c71501..d3ca8a4 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -346,6 +346,10 @@ static void tcp_v6_err(struct sk_buff *skb, stru=
ct inet6_skb_parm *opt,
>  	__u32 seq;
>  	struct net *net =3D dev_net(skb->dev);
> =20
> +
> +	if (type =3D=3D NDISC_REDIRECT)
> +		return;
> +
>  	sk =3D inet6_lookup(net, &tcp_hashinfo, &hdr->daddr,
>  			th->dest, &hdr->saddr, th->source, skb->dev->ifindex);
> =20
> @@ -382,14 +386,6 @@ static void tcp_v6_err(struct sk_buff *skb, stru=
ct inet6_skb_parm *opt,
> =20
>  	np =3D inet6_sk(sk);
> =20
> -	if (type =3D=3D NDISC_REDIRECT) {
> -		struct dst_entry *dst =3D __sk_dst_check(sk, np->dst_cookie);
> -
> -		if (dst)
> -			dst->ops->redirect(dst, sk, skb);
> -		goto out;
> -	}
> -
>  	if (type =3D=3D ICMPV6_PKT_TOOBIG) {
>  		/* We are not interested in TCP_LISTEN and open_requests
>  		 * (SYN-ACKs send out by Linux are always <576bytes so
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index 5f20686..0d2d4b7 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -413,18 +413,6 @@ void sctp_icmp_frag_needed(struct sock *sk, stru=
ct sctp_association *asoc,
>  	sctp_retransmit(&asoc->outqueue, t, SCTP_RTXR_PMTUD);
>  }
> =20
> -void sctp_icmp_redirect(struct sock *sk, struct sctp_transport *t,
> -			struct sk_buff *skb)
> -{
> -	struct dst_entry *dst;
> -
> -	if (!t)
> -		return;
> -	dst =3D sctp_transport_dst_check(t);
> -	if (dst)
> -		dst->ops->redirect(dst, sk, skb);
> -}
> -
>  /*
>   * SCTP Implementer's Guide, 2.37 ICMP handling procedures
>   *
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index da613ce..ee12d87 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -151,6 +151,9 @@ static void sctp_v6_err(struct sk_buff *skb, stru=
ct inet6_skb_parm *opt,
>  	int err;
>  	struct net *net =3D dev_net(skb->dev);
> =20
> +	if (type =3D=3D NDISC_REDIRECT)
> +		return;
> +
>  	idev =3D in6_dev_get(skb->dev);
> =20
>  	/* Fix up skb to look at the embedded net header. */
> @@ -181,9 +184,6 @@ static void sctp_v6_err(struct sk_buff *skb, stru=
ct inet6_skb_parm *opt,
>  			goto out_unlock;
>  		}
>  		break;
> -	case NDISC_REDIRECT:
> -		sctp_icmp_redirect(sk, transport, skb);
> -		break;
>  	default:
>  		break;
>  	}
