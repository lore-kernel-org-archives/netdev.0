From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: add 64bit support to ifstat
Date: Mon, 23 Aug 2010 10:33:33 -0700
Message-ID: <20100823103333.67c5f795@nehalam>
References: <20100823083258.0777e83d@nehalam>
	<1282578203.2267.27.camel@achroite.uk.solarflarecom.com>
	<20100823091750.2bf87605@nehalam>
	<1282582464.2486.479.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42760 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751318Ab0HWRdf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 13:33:35 -0400
In-Reply-To: <1282582464.2486.479.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Aug 2010 18:54:24 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 23 ao=FBt 2010 =E0 09:17 -0700, Stephen Hemminger a =E9crit =
:
> > On Mon, 23 Aug 2010 16:43:23 +0100
> > Ben Hutchings <bhutchings@solarflare.com> wrote:
> >=20
> > > On Mon, 2010-08-23 at 08:32 -0700, Stephen Hemminger wrote:
> > > > This commit broke iproute2 build:
> > > >=20
> > > > commit be1f3c2c027cc5ad735df6a45a542ed1db7ec48b
> > > > Author: Ben Hutchings <bhutchings@solarflare.com>
> > > > Date:   Tue Jun 8 07:19:54 2010 +0000
> > > >=20
> > > >     net: Enable 64-bit net device statistics on 32-bit architec=
tures
> > > >    =20
> > > >     Use struct rtnl_link_stats64 as the statistics structure.
> > > >=20
> > > > Iproute2 uses a the kernel exported headers, and the structure
> > > > net_device_stats which is part of the netlink IFLA_STATS messag=
e
> > > > was no longer exposed.
> > > [...]
> > >=20
> > > This is not true; the kernel uses struct rtnl_link_stats for IFLA=
_STATS.
> > > AFAICS the only reference to struct net_device_stats in iproute2 =
is:
> > >=20
> > > misc/ifstat.c:51:#define MAXS (sizeof(struct net_device_stats)/si=
zeof(unsigned long))
> > >=20
> > > This should be changed to refer to the structure that is actually=
 used.
> >=20
> > Ok.
>=20
> Stephen,
>=20
> Here is a patch to ifstat on top of your last one.
>=20
> I guess nobody tried it on a 64bit platform...
>=20
> Thanks
>=20
> iproute2: add 64bit support to ifstat
>=20
> ifstat assumes IFLA_STATS fields are "unsigned long"
>=20
> ifstat can use 64bit stats if available (IFLA_STATS64)
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>=20
> diff --git a/misc/ifstat.c b/misc/ifstat.c
> index 5cf2e01..c649ee2 100644
> --- a/misc/ifstat.c
> +++ b/misc/ifstat.c
> @@ -49,7 +49,7 @@ int npatterns;
>  char info_source[128];
>  int source_mismatch;
> =20
> -#define MAXS (sizeof(struct rtnl_link_stats)/sizeof(unsigned long))
> +#define MAXS (sizeof(struct rtnl_link_stats)/sizeof(__u32))
> =20
>  struct ifstat_ent
>  {
> @@ -58,7 +58,7 @@ struct ifstat_ent
>  	int			ifindex;
>  	unsigned long long	val[MAXS];
>  	double			rate[MAXS];
> -	unsigned long		ival[MAXS];
> +	__u32			ival[MAXS];
>  };
> =20
>  struct ifstat_ent *kern_db;
> @@ -108,8 +108,12 @@ static int get_nlmsg(const struct sockaddr_nl *w=
ho,
>  	n->name =3D strdup(RTA_DATA(tb[IFLA_IFNAME]));
>  	memcpy(&n->ival, RTA_DATA(tb[IFLA_STATS]), sizeof(n->ival));
>  	memset(&n->rate, 0, sizeof(n->rate));
> -	for (i=3D0; i<MAXS; i++)
> -		n->val[i] =3D n->ival[i];
> +	if (tb[IFLA_STATS64])
> +		memcpy(&n->val, RTA_DATA(tb[IFLA_STATS64]), sizeof(n->val));
> +	else
> +		for (i =3D 0; i < MAXS; i++)
> +			n->val[i] =3D n->ival[i];
> +
>  	n->next =3D kern_db;
>  	kern_db =3D n;
>  	return 0;
>=20
>=20

I think this breaks the wraparound detection code in this command.


--=20
