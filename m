From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/5] be2net: fix erx->rx_drops_no_frags wrap
 around
Date: Tue, 23 Aug 2011 08:41:17 +0200
Message-ID: <1314081677.4791.28.camel@edumazet-laptop>
References: <1314078115-8121-1-git-send-email-sathya.perla@emulex.com>
	 <1314078115-8121-4-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:33563 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726Ab1HWGlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 02:41:23 -0400
Received: by wwe5 with SMTP id 5so2768505wwe.1
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 23:41:22 -0700 (PDT)
In-Reply-To: <1314078115-8121-4-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 ao=C3=BBt 2011 =C3=A0 11:11 +0530, Sathya Perla a =C3=A9cri=
t :
> The rx_drops_no_frags HW counter for RSS rings is 16bits in HW and ca=
n
> wraparound often. Maintain a 32-bit accumulator in the driver to prev=
ent
> frequent wraparound.
>=20
> Also, incorporated Eric's feedback to use ACCESS_ONCE() for the accum=
ulator
> write.
>=20
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> ---
>  drivers/net/ethernet/emulex/benet/be_main.c |   22 +++++++++++++++++=
++---
>  1 files changed, 19 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/ne=
t/ethernet/emulex/benet/be_main.c
> index 2375c0c..fb2eda0 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -378,6 +378,18 @@ static void populate_lancer_stats(struct be_adap=
ter *adapter)
>  				pport_stats->rx_drops_too_many_frags_lo;
>  }
> =20
> +static void accumulate_16bit_val(u32 *acc, u16 val)
> +{
> +#define lo(x)			(x & 0xFFFF)
> +#define hi(x)			(x & 0xFFFF0000)
> +	bool wrapped =3D val < lo(*acc);
> +	u32 newacc =3D hi(*acc) + val;
> +
> +	if (wrapped)
> +		newacc +=3D 65536;
> +	ACCESS_ONCE(*acc) =3D newacc;
> +}
> +

I still feel something is wrong here :

>  void be_parse_stats(struct be_adapter *adapter)
>  {
>  	struct be_erx_stats_v1 *erx =3D be_erx_stats_from_cmd(adapter);
> @@ -394,9 +406,13 @@ void be_parse_stats(struct be_adapter *adapter)
>  	}
> =20
>  	/* as erx_v1 is longer than v0, ok to use v1 defn for v0 access */
> -	for_all_rx_queues(adapter, rxo, i)
> -		rx_stats(rxo)->rx_drops_no_frags =3D
> -			erx->rx_drops_no_fragments[rxo->q.id];

previous code was not doing a sum_of_all_queues.

It only gave the final erx->rx_drops_no_fragments[rxo->q.id], not takin=
g
into account previous rx_stats(rxo)->rx_drops_no_frags value.

Your changelog is about wrap around, while the bug might have be
different (No real sum)

Now you say : previous value is meaningfull, and we add to it 16bits
values.

> +	for_all_rx_queues(adapter, rxo, i) {
> +		/* below erx HW counter can actually wrap around after
> +		 * 65535. Driver accumulates a 32-bit value
> +		 */
> +		accumulate_16bit_val(&rx_stats(rxo)->rx_drops_no_frags,
> +				(u16)erx->rx_drops_no_fragments[rxo->q.id]);
> +	}
>  }
> =20

Arent multiple calls to be_parse_stats() will have wrong final
rx_drops_no_frags value ?

Or are the rx_drops_no_fragments[rxo->q.id] cleared when read ?

I am afraid that if HW maintains 16bit values, then the only way is to
also have a 16bit accumulator. You cannot detect wraparounds without
also keeping a copy of previous 16bit samples.

u16 accum =3D 0;
or_all_rx_queues(adapter, rxo, i) {
	accum +=3D erx->rx_drops_no_fragments[rxo->q.id];
}
rx_stats(rxo)->rx_drops_no_frags =3D accum;


