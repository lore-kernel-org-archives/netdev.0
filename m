From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 02/17] netfilter: nat: remove module reference counting
 from NAT protocols
Date: Mon, 21 Nov 2011 08:36:37 +0100
Message-ID: <1321860997.17419.7.camel@edumazet-laptop>
References: <1321854369-3432-1-git-send-email-kaber@trash.net>
	 <1321854369-3432-3-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ulrich.weber@sophos.com
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1321854369-3432-3-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 21 novembre 2011 =C3=A0 06:45 +0100, kaber@trash.net a =C3=A9c=
rit :
> From: Patrick McHardy <kaber@trash.net>
>=20
> The only remaining user of NAT protocol module reference counting is =
NAT
> ctnetlink support. Since this is a fairly short sequence of code, con=
vert
> over to use RCU and remove module reference counting.
>=20
> Signed-off-by: Patrick McHardy <kaber@trash.net>

> @@ -612,16 +592,18 @@ static int nfnetlink_parse_nat_proto(struct nla=
ttr *attr,
>  	if (err < 0)
>  		return err;
> =20
> -	npt =3D nf_nat_proto_find_get(nf_ct_protonum(ct));
> +	rcu_read_lock();
> +	npt =3D __nf_nat_proto_find(nf_ct_protonum(ct));
>  	if (npt->nlattr_to_range)
>  		err =3D npt->nlattr_to_range(tb, range);
> -	nf_nat_proto_put(npt);
> +	rcu_read_unlock();
>  	return err;
>  }

Seems good, but you should explain in changelog why its safe.

(Using rcu also means special action must be taken in the write side,
here the module removal)

> =20
>  static const struct nla_policy nat_nla_policy[CTA_NAT_MAX+1] =3D {
>  	[CTA_NAT_MINIP]		=3D { .type =3D NLA_U32 },
>  	[CTA_NAT_MAXIP]		=3D { .type =3D NLA_U32 },
> +	[CTA_NAT_PROTO]		=3D { .type =3D NLA_NESTED },
>  };

I just dont understand this part :-(



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
