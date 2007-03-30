From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH][IPv6]: Fix incorrect length check in rawv6_sendmsg()
Date: Fri, 30 Mar 2007 10:47:04 -0700
Message-ID: <1175276825.23146.1.camel@w-sridhar2.beaverton.ibm.com>
References: <1175203048.16183.14.camel@w-sridhar2.beaverton.ibm.com>
	 <20070329.142644.70222545.davem@davemloft.net>
	 <20070330.091316.58970851.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:35461 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752205AbXC3RrI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 13:47:08 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2UHl74K011257
	for <netdev@vger.kernel.org>; Fri, 30 Mar 2007 13:47:07 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2UHl6eP292174
	for <netdev@vger.kernel.org>; Fri, 30 Mar 2007 13:47:06 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2UHl6Lf024085
	for <netdev@vger.kernel.org>; Fri, 30 Mar 2007 13:47:06 -0400
In-Reply-To: <20070330.091316.58970851.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-03-30 at 09:13 +0900, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=
=E8=8B=B1=E6=98=8E wrote:
> In article <20070329.142644.70222545.davem@davemloft.net> (at Thu, 29=
 Mar 2007 14:26:44 -0700 (PDT)), David Miller <davem@davemloft.net> say=
s:
>=20
> > From: Sridhar Samudrala <sri@us.ibm.com>
> > Date: Thu, 29 Mar 2007 14:17:28 -0700
> >=20
> > > The check for length in rawv6_sendmsg() is incorrect.
> > > As len is an unsigned int, (len < 0) will never be TRUE.
> > > I think checking for IPV6_MAXPLEN(65535) is better.
> > >=20
> > > Is it possible to send ipv6 jumbo packets using raw
> > > sockets? If so, we can remove this check.
> >=20
> > I don't see why such a limitation against jumbo would exist,
> > does anyone else?
> >=20
> > Thanks for catching this Sridhar.  A good compiler should simply
> > fail to compile "if (x < 0)" when 'x' is an unsigned type, don't
> > you think :-)
>=20
> Dave, we use "int" for returning value,
> so we should fix this anyway, IMHO;
> we should not allow len > INT_MAX.
>=20
> Don't you think so?
>=20
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Acked-by: Sridhar Samudrala <sri@us.ibm.com>

>=20
> diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
> index 306d5d8..203e069 100644
> --- a/net/ipv6/raw.c
> +++ b/net/ipv6/raw.c
> @@ -687,9 +687,9 @@ static int rawv6_sendmsg(struct kiocb *iocb, stru=
ct sock *sk,
>  	int err;
>=20
>  	/* Rough check on arithmetic overflow,
> -	   better check is made in ip6_build_xmit
> +	   better check is made in ip6_append_data().
>  	 */
> -	if (len < 0)
> +	if (len > INT_MAX)
>  		return -EMSGSIZE;
>=20
>  	/* Mirror BSD error message compatibility */
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 0ad4719..f590db5 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -615,7 +615,7 @@ do_udp_sendmsg:
>  		return udp_sendmsg(iocb, sk, msg, len);
>=20
>  	/* Rough check on arithmetic overflow,
> -	   better check is made in ip6_build_xmit
> +	   better check is made in ip6_append_data().
>  	   */
>  	if (len > INT_MAX - sizeof(struct udphdr))
>  		return -EMSGSIZE;
>=20
> --yoshfuji
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

