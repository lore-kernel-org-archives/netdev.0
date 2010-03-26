From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Subject: Re: [PATCH] net: ipmr/ip6mr: prevent out-of-bounds vif_table access
Date: Fri, 26 Mar 2010 18:19:34 +0100
Message-ID: <4BACECA6.2050506@dev.6wind.com>
References: <4BAC823F.8050409@dev.6wind.com> <20100326.095137.165317348.davem@davemloft.net>
Reply-To: nicolas.dichtel@dev.6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:57863 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751362Ab0CZRTn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Mar 2010 13:19:43 -0400
In-Reply-To: <20100326.095137.165317348.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

yes, but I think that it is not enough, ip[6]mr_mfc_add() is only calle=
d via=20
setsockopt().

When a multicast packet arrived in ip6_mr_input(), if there is no cache=
=20
ip6mr_cache_unresolved() will be called and this function will add an e=
ntry with=20
parent =3D=3D 65535.

And the second problem is that when a vif is removed, no cleanup is mad=
e in=20
cache entry. Hence, we can have a cache entry which points to an invali=
d vif=20
(dev is set ot NULL).


Regards,
Nicolas

Le 26.03.2010 17:51, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
> Date: Fri, 26 Mar 2010 10:45:35 +0100
>=20
>> please consider the attached patch about IPv4 and IPv6 multicast.
>=20
> Already fixed by Patrick McHardy recently:
>=20
> commit a50436f2cd6e85794f7e1aad795ca8302177b896
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Wed Mar 17 06:04:14 2010 +0000
>=20
>     net: ipmr/ip6mr: fix potential out-of-bounds vif_table access
>    =20
>     mfc_parent of cache entries is used to index into the vif_table a=
nd is
>     initialised from mfcctl->mfcc_parent. This can take values of to =
2^16-1,
>     while the vif_table has only MAXVIFS (32) entries. The same probl=
em
>     affects ip6mr.
>    =20
>     Refuse invalid values to fix a potential out-of-bounds access. Un=
like
>     the other validity checks, this is checked in ipmr_mfc_add() inst=
ead of
>     the setsockopt handler since its unused in the delete path and mi=
ght be
>     uninitialized.
>    =20
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index 8582e12..0b9d03c 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -802,6 +802,9 @@ static int ipmr_mfc_add(struct net *net, struct m=
fcctl *mfc, int mrtsock)
>  	int line;
>  	struct mfc_cache *uc, *c, **cp;
> =20
> +	if (mfc->mfcc_parent >=3D MAXVIFS)
> +		return -ENFILE;
> +
>  	line =3D MFC_HASH(mfc->mfcc_mcastgrp.s_addr, mfc->mfcc_origin.s_add=
r);
> =20
>  	for (cp =3D &net->ipv4.mfc_cache_array[line];
> diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
> index 52e0f74..23e4ac0 100644
> --- a/net/ipv6/ip6mr.c
> +++ b/net/ipv6/ip6mr.c
> @@ -1113,6 +1113,9 @@ static int ip6mr_mfc_add(struct net *net, struc=
t mf6cctl *mfc, int mrtsock)
>  	unsigned char ttls[MAXMIFS];
>  	int i;
> =20
> +	if (mfc->mf6cc_parent >=3D MAXMIFS)
> +		return -ENFILE;
> +
>  	memset(ttls, 255, MAXMIFS);
>  	for (i =3D 0; i < MAXMIFS; i++) {
>  		if (IF_ISSET(i, &mfc->mf6cc_ifset))
