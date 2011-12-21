From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rps: fix insufficient bounds checking in
 store_rps_dev_flow_table_cnt()
Date: Wed, 21 Dec 2011 20:22:24 +0100
Message-ID: <1324495344.2621.5.camel@edumazet-laptop>
References: <1324493459-19764-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Xi Wang <xi.wang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:33170 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343Ab1LUTW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 14:22:28 -0500
Received: by werm1 with SMTP id m1so2884052wer.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 11:22:27 -0800 (PST)
In-Reply-To: <1324493459-19764-1-git-send-email-xi.wang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 13:50 -0500, Xi Wang a =C3=A9c=
rit :
> Setting a large rps_flow_cnt like 1073741824 (1 << 30) on 32-bit
> platform will cause a kernel oops due to insufficient bounds checking=
=2E
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
> 32 bits.  This patch changes the upper bound to (1 << 28).
>=20
> Signed-off-by: Xi Wang <xi.wang@gmail.com>
> ---
>  net/core/net-sysfs.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index c71c434..f53a947 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -665,7 +665,7 @@ static ssize_t store_rps_dev_flow_table_cnt(struc=
t netdev_rx_queue *queue,
>  	if (count) {
>  		int i;
> =20
> -		if (count > 1<<30) {
> +		if (count > 1<<28) {
>  			/* Enforce a limit to prevent overflow */
>  			return -EINVAL;
>  		}


Really, you should remove this magic number and use instead

(INT_MAX - RPS_DEV_FLOW_TABLE_SIZE(0)) / sizeof(struct rps_dev_flow)

Or something like that, because next time we add a field in
rps_dev_flow, test will be obsolete.
