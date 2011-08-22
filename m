From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/5] be2net: fix erx->rx_drops_no_frags wrap
 around
Date: Mon, 22 Aug 2011 13:43:33 +0200
Message-ID: <1314013414.2307.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1314011613-4519-1-git-send-email-sathya.perla@emulex.com>
	 <1314011613-4519-4-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42377 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649Ab1HVLnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 07:43:32 -0400
Received: by wyg24 with SMTP id 24so3415119wyg.19
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 04:43:31 -0700 (PDT)
In-Reply-To: <1314011613-4519-4-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 22 ao=C3=BBt 2011 =C3=A0 16:43 +0530, Sathya Perla a =C3=A9cri=
t :
> The rx_drops_no_frags HW counter for RSS rings is 16bits in HW and ca=
n
> wraparound often. Maintain a 32-bit accumulator in the driver to prev=
ent
> frequent wraparound.
>=20
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> ---
>  drivers/net/ethernet/emulex/benet/be_main.c |   21 +++++++++++++++++=
+---
>  1 files changed, 18 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/ne=
t/ethernet/emulex/benet/be_main.c
> index 2375c0c..4e588d8 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/f
> @@ -378,6 +378,17 @@ static void populate_lancer_stats(struct be_adap=
ter *adapter)
>  				pport_stats->rx_drops_too_many_frags_lo;
>  }
> =20
> +static void accumulate_16bit_val(u32 *acc, u16 val)
> +{
> +#define lo(x)			(x & 0xFFFF)
> +#define hi(x)			(x & 0xFFFF0000)
> +	bool wrapped =3D val < lo(*acc);
> +
> +	*acc =3D hi(*acc) + val;
> +	if (wrapped)
> +		*acc +=3D 65536;
> +}
> +
> =20

This adds a race for lockless SNMP readers (in be_get_stats64())

They can see the 32bit value going backward.

You have to be very careful to read the *acc once, and write it once.




