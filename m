From: Sebastien Decugis <sdecugis@hongo.wide.ad.jp>
Subject: Re: [RFC PATCH] [XFRM]: Fix ordering issue in xfrm_dst_hash_transfer().
Date: Fri, 15 Feb 2008 14:45:04 +0900
Message-ID: <47B526E0.3040807@hongo.wide.ad.jp>
References: <20080215.132424.85799616.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	kazunori@miyazawa.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-1637.dedibox.fr ([88.191.18.91]:33629 "EHLO
	sd-1637.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761679AbYBOGTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 01:19:43 -0500
In-Reply-To: <20080215.132424.85799616.yoshfuji@wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It works, thank you!

Acked-by: Sebastien Decugis <sdecugis@hongo.wide.ad.jp>


YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E a =C3=A9crit :
> Keep ordering of policy entries with same selector in xfrm_dst_hash_t=
ransfer().
>=20
> Issue should not appear in usual cases because multiple policy entrie=
s with
> same selector are basically not allowed so far.
> Bug was pointed out by Sebastien Decugis <sdecugis@hongo.wide.ad.jp>.
>=20
> We could convert bydst from hlist to list and use list_add_tail() ins=
tead.
>=20
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>=20
> ----
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index 47219f9..9fc4c31 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -331,15 +331,31 @@ static void xfrm_dst_hash_transfer(struct hlist=
_head *list,
>  				   struct hlist_head *ndsttable,
>  				   unsigned int nhashmask)
>  {
> -	struct hlist_node *entry, *tmp;
> +	struct hlist_node *entry, *tmp, *entry0 =3D NULL;
>  	struct xfrm_policy *pol;
> +	unsigned int h0 =3D 0;
> =20
> +redo:
>  	hlist_for_each_entry_safe(pol, entry, tmp, list, bydst) {
>  		unsigned int h;
> =20
>  		h =3D __addr_hash(&pol->selector.daddr, &pol->selector.saddr,
>  				pol->family, nhashmask);
> -		hlist_add_head(&pol->bydst, ndsttable+h);
> +		if (!entry0) {
> +			hlist_del(entry);
> +			hlist_add_head(&pol->bydst, ndsttable+h);
> +			h0 =3D h;
> +		} else {
> +			if (h !=3D h0)
> +				continue;
> +			hlist_del(entry);
> +			hlist_add_after(entry0, &pol->bydst);
> +		}
> +		entry0 =3D entry;
> +	}
> +	if (!hlist_empty(list)) {
> +		entry0 =3D NULL;
> +		goto redo;
>  	}
>  }
> =20
>=20

--=20
Sebastien Decugis
http://www.nautilus6.org
