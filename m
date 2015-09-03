From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2] net: Fix behaviour of unreachable, blackhole and
 prohibit routes
Date: Thu, 3 Sep 2015 11:13:59 +0200
Message-ID: <20150903091359.GB6328@breakpoint.cc>
References: <1441271331.3360.36.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nikola =?iso-8859-15?Q?Forr=F3?= <nforro@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41005 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752128AbbICJOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 05:14:02 -0400
Content-Disposition: inline
In-Reply-To: <1441271331.3360.36.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikola Forr=C3=B3 <nforro@redhat.com> wrote:
> Man page of ip-route(8) says following about route types:
>=20
>   unreachable - these destinations are unreachable.  Packets are dis=E2=
=80=90
>   carded and the ICMP message host unreachable is generated.  The loc=
al
>   senders get an EHOSTUNREACH error.
>=20
>   blackhole - these destinations are unreachable.  Packets are dis=E2=
=80=90
>   carded silently.  The local senders get an EINVAL error.
>=20
>   prohibit - these destinations are unreachable.  Packets are discard=
ed
>   and the ICMP message communication administratively prohibited is
>   generated.  The local senders get an EACCES error.
>=20
> In the inet6 address family, this was correct, except the local sende=
rs
> got ENETUNREACH error instead of EHOSTUNREACH in case of unreachable =
route.
> In the inet address family, all three route types generated ICMP mess=
age
> net unreachable, and the local senders got ENETUNREACH error.
>=20
> In both address families all three route types now behave consistentl=
y
> with documentation.
>=20
> Signed-off-by: Nikola Forr=C3=B3 <nforro@redhat.com>
> ---
>  include/net/ip_fib.h | 21 ++++++++++++++++-----
>  net/ipv4/route.c     |  6 ++++--
>  net/ipv6/route.c     |  4 +++-
>  3 files changed, 23 insertions(+), 8 deletions(-)
>=20
> diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> index 5fa643b..cf025107 100644
> --- a/include/net/ip_fib.h
> +++ b/include/net/ip_fib.h
> @@ -233,8 +233,10 @@ static inline int fib_lookup(struct net *net, co=
nst struct flowi4 *flp,
>  	rcu_read_lock();
> =20
>  	tb =3D fib_get_table(net, RT_TABLE_MAIN);
> -	if (tb && !fib_table_lookup(tb, flp, res, flags | FIB_LOOKUP_NOREF)=
)
> -		err =3D 0;
> +	if (tb)
> +		err =3D fib_table_lookup(tb, flp, res, flags | FIB_LOOKUP_NOREF);
> +		if (err =3D=3D -EAGAIN)
> +			err =3D -ENETUNREACH;

Missing { } ?
