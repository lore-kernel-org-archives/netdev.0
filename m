From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] codel: reduce default maxpacket and reinitialize upon
 re-entering drop state
Date: Mon, 03 Sep 2012 01:05:11 +0200
Message-ID: <1346627111.2563.51.camel@edumazet-glaptop>
References: <1346525457-31481-1-git-send-email-dave.taht@bufferbloat.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Dave =?ISO-8859-1?Q?T=E4ht?= <dave.taht@bufferbloat.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:50418 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754800Ab2IBXFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2012 19:05:16 -0400
Received: by wicr5 with SMTP id r5so3499938wic.1
        for <netdev@vger.kernel.org>; Sun, 02 Sep 2012 16:05:15 -0700 (PDT)
In-Reply-To: <1346525457-31481-1-git-send-email-dave.taht@bufferbloat.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-09-01 at 11:50 -0700, Dave T=C3=A4ht wrote:
> From: Dave Taht <dave.taht@bufferbloat.net>
>=20
> The minimum size packet in a queue is 64, not 256.
>=20
> Also, as ethtool can be used to remove tso/gso/ufo, the last seen
> maxpacket can vary considerably in size (e.g. 64k). So reset it
> on re-entering the drop scheduler to the most recent packet size,
> and let it grow again naturally.
>=20
> Signed-off-by: Dave Taht <dave.taht@bufferbloat.net>
> ---
>  include/net/codel.h |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/include/net/codel.h b/include/net/codel.h
> index 389cf62..0b0ac5e 100644
> --- a/include/net/codel.h
> +++ b/include/net/codel.h
> @@ -170,7 +170,7 @@ static void codel_vars_init(struct codel_vars *va=
rs)
> =20
>  static void codel_stats_init(struct codel_stats *stats)
>  {
> -	stats->maxpacket =3D 256;
> +	stats->maxpacket =3D 64;
>  }
> =20
>  /*
> @@ -333,6 +333,7 @@ static struct sk_buff *codel_dequeue(struct Qdisc=
 *sch,
>  			 */
>  			codel_Newton_step(vars);
>  		} else {
> +			stats->maxpacket =3D skb ? qdisc_pkt_len(skb) : 64;
>  			vars->count =3D 1;
>  			vars->rec_inv_sqrt =3D ~0U >> REC_INV_SQRT_SHIFT;
>  		}

This has very litle value.

maxpacket is mainly an information given to "tc -s qdisc".

It serves as a debugging stuff, to know the max packet size seen on
codel qdisc.

So you can set it to 0 as far as I am concerned, but not reset it in
codel_enqueue(), as it adds runtime overhead and a branch misprediction=
=2E
