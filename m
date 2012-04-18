From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: fix rt6_update_expires
Date: Wed, 18 Apr 2012 10:24:48 +0800
Message-ID: <4F8E25F0.3040703@cn.fujitsu.com>
References: <1330064404-24763-1-git-send-email-gaofeng@cn.fujitsu.com> <1333707190-14075-1-git-send-email-gaofeng@cn.fujitsu.com> <20120413.125851.894792528374368454.davem@davemloft.net> <20120416133439.GB18159@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:33449 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752922Ab2DRCYS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 22:24:18 -0400
In-Reply-To: <20120416133439.GB18159@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B404=E6=9C=8816=E6=97=A5 21:34, Jiri Bohac =E5=86=99=
=E9=81=93:
>=20
> Commit 1716a961 (ipv6: fix problem with expired dst cache) broke PMTU
> discovery. rt6_update_expires() calls dst_set_expires(), which only u=
pdates
> dst->expires if it has not been set previously (expires =3D=3D 0) or =
if the new
> expires is earlier than the current dst->expires.
>=20
> rt6_update_expires() needs to zero rt->dst.expires, otherwise it will=
 contain
> ivalid data left over from rt->dst.from and will confuse dst_set_expi=
res().
>=20
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
>=20
> diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
> index ad4126f..68c1f94 100644
> --- a/include/net/ip6_fib.h
> +++ b/include/net/ip6_fib.h
> @@ -143,8 +143,13 @@ static inline void rt6_set_expires(struct rt6_in=
fo *rt, unsigned long expires)
> =20
>  static inline void rt6_update_expires(struct rt6_info *rt, int timeo=
ut)
>  {
> -	if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.from)
> -		dst_release(rt->dst.from);
> +	if (!(rt->rt6i_flags & RTF_EXPIRES)) {
> +		if (rt->dst.from)
> +			dst_release(rt->dst.from);
> +		/* dst_set_expires relies on expires =3D=3D 0=20
> +                  if it has not been set previously */
> +		rt->dst.expires =3D 0;
> +	}
> =20
>  	dst_set_expires(&rt->dst, timeout);
>  	rt->rt6i_flags |=3D RTF_EXPIRES;
>=20

looks good to me, thanks.
