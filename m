From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] rps: fix insufficient bounds checking in
 store_rps_dev_flow_table_cnt()
Date: Fri, 23 Dec 2011 05:10:14 +0100
Message-ID: <1324613414.2674.2.camel@edumazet-laptop>
References: <1324493459-19764-1-git-send-email-xi.wang@gmail.com>
	 <4EF3BEBA.4040402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Xi Wang <xi.wang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:34474 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525Ab1LWEKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 23:10:18 -0500
Received: by wibhm6 with SMTP id hm6so2920333wib.19
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 20:10:17 -0800 (PST)
In-Reply-To: <4EF3BEBA.4040402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 d=C3=A9cembre 2011 =C3=A0 18:35 -0500, Xi Wang a =C3=A9crit=
 :
> Setting a large rps_flow_cnt like (1 << 30) on 32-bit platform will
> cause a kernel oops due to insufficient bounds checking.
>=20
> 	if (count > 1<<30) {
> 		/* Enforce a limit to prevent overflow */
> 		return -EINVAL;
> 	}
> 	count =3D roundup_pow_of_two(count);
> 	table =3D vmalloc(RPS_DEV_FLOW_TABLE_SIZE(count));
>=20
> Note that the macro RPS_DEV_FLOW_TABLE_SIZE(count) is defined as:
>=20
> 	... + (count * sizeof(struct rps_dev_flow))
>=20
> where sizeof(struct rps_dev_flow) is 8.  (1 << 30) * 8 will overflow
> 32 bits.
>=20
> This patch replaces the magic number (1 << 30) with a symbolic bound.
>=20
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Xi Wang <xi.wang@gmail.com>
> ---
>  net/core/net-sysfs.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index c71c434..385aefe 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -665,11 +665,14 @@ static ssize_t store_rps_dev_flow_table_cnt(str=
uct netdev_rx_queue *queue,
>  	if (count) {
>  		int i;
> =20
> -		if (count > 1<<30) {
> +		if (count > INT_MAX)
> +			return -EINVAL;
> +		count =3D roundup_pow_of_two(count);
> +		if (count > (ULONG_MAX - sizeof(struct rps_dev_flow_table))

Oh well, you added a bug here, since count is "unsigned int"

Why mixing INT_MAX in the previous test and ULONG_MAX here ?


> +				/ sizeof(struct rps_dev_flow)) {
>  			/* Enforce a limit to prevent overflow */
>  			return -EINVAL;
>  		}
> -		count =3D roundup_pow_of_two(count);
>  		table =3D vmalloc(RPS_DEV_FLOW_TABLE_SIZE(count));
>  		if (!table)
>  			return -ENOMEM;
