From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] l2tp: add support for IPv4-mapped IPv6 addresses
Date: Mon, 30 Sep 2013 21:57:32 -0700 (PDT)
Message-ID: <20130930.215732.511217838898717901.davem@davemloft.net>
References: <5245694D.3070105@init-sys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jchapman@katalix.com, netdev@vger.kernel.org
To: f.cachereul@init-sys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966Ab3JAEu0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 00:50:26 -0400
In-Reply-To: <5245694D.3070105@init-sys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fran=E7ois Cachereul <f.cachereul@init-sys.com>
Date: Fri, 27 Sep 2013 13:17:33 +0200

> @@ -1620,6 +1621,10 @@ int l2tp_tunnel_create(struct net *net, int fd=
, int version, u32 tunnel_id, u32
>  	int err;
>  	struct socket *sock =3D NULL;
>  	struct sock *sk =3D NULL;
> +#if IS_ENABLED(CONFIG_IPV6)
> +	struct inet_sock *inet =3D NULL;
> +	struct ipv6_pinfo *np =3D NULL;
> +#endif
 ...
> +#if IS_ENABLED(CONFIG_IPV6)
> +	np =3D inet6_sk(sk);
> +	if (sk->sk_family =3D=3D PF_INET6 &&
> +	    ipv6_addr_v4mapped(&np->saddr) &&
> +	    ipv6_addr_v4mapped(&np->daddr)) {
> +		tunnel->v4mapped =3D true;
> +		inet =3D inet_sk(sk);
> +		inet->inet_saddr =3D np->saddr.s6_addr32[3];
> +		inet->inet_rcv_saddr =3D np->rcv_saddr.s6_addr32[3];
> +		inet->inet_daddr =3D np->daddr.s6_addr32[3];
> +	} else {
> +		tunnel->v4mapped =3D false;
> +	}
> +#endif

You only need one ifdef here, get rid of the top level variable
declarations and then just go:

#if IS_ENABLED(CONFIG_IPV6)
	if (sk->sk_family =3D=3D PF_INET6) {
		struct ipv6_pinfo *np =3D inet6_sk(sk);

		if (ipv6_addr_v4mapped(&np->saddr) &&
		    ipv6_addr_v4mapped(&np->daddr)) {
			struct inet_sock *inet =3D inet_sk(sk);

			tunnel->v4mapped =3D true;
			inet->inet_saddr =3D np->saddr.s6_addr32[3];
			inet->inet_rcv_saddr =3D np->rcv_saddr.s6_addr32[3];
			inet->inet_daddr =3D np->daddr.s6_addr32[3];
		} else {
			tunnel->v4mapped =3D false;
		}
	}
#endif
