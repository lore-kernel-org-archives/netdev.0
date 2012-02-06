From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2x: Fix mem leak in bnx2x_tpa_stop() if build_skb()
 fails.
Date: Mon, 06 Feb 2012 23:53:53 +0100
Message-ID: <1328568833.2476.1.camel@edumazet-laptop>
References: <alpine.LNX.2.00.1202062224210.20532@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eilon Greenstein <eilong@broadcom.com>,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eliezer Tamir <eliezert@broadcom.com>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1202062224210.20532@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 06 f=C3=A9vrier 2012 =C3=A0 22:28 +0100, Jesper Juhl a =C3=A9c=
rit :
> We allocate memory for 'new_data' with kmalloc(). If we get the memor=
y
> we then try to build_skb() and if that should fail (which it can) we
> do not enter 'if (likely(skb)) {' and actually use 'new_data' but
> instead fall through to the 'drop:' label and end up returning from
> the function without ever assigning 'new'data' to anything or freeing
> it. That leaks the memory allocated to 'new_data'.
>=20
> This patch fixes the memory leak by doing a kfree(new_data) in the
> case where build_skb() fails (or where allocation of 'new_data' itsel=
f
> fails, but in taht case it's just a harmless kfree(NULL)).
>=20
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
>=20
>  No hardware to test, so compile tested only.
>=20
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/driver=
s/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> index 03f3935..7aee469 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -523,7 +523,6 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, stru=
ct bnx2x_fastpath *fp,
>  		skb =3D build_skb(data);
> =20
>  	if (likely(skb)) {
> -
>  #ifdef BNX2X_STOP_ON_ERROR
>  		if (pad + len > fp->rx_buf_size) {
>  			BNX2X_ERR("skb_put is about to fail...  "
> @@ -557,7 +556,7 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, stru=
ct bnx2x_fastpath *fp,
> =20
>  		return;
>  	}
> -
> +	kfree(new_data);
>  drop:
>  	/* drop the packet and keep the buffer in the bin */
>  	DP(NETIF_MSG_RX_STATUS,
> --=20
> 1.7.9
>=20
>=20

Good catch, my bad.

Thanks

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
