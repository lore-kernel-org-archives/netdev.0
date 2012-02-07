From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: Fix mem leak in bnx2x_tpa_stop() if
 build_skb() fails.
Date: Tue, 7 Feb 2012 08:55:01 +0200
Message-ID: <1328597701.18349.0.camel@lb-tlvb-eilong.il.broadcom.com>
References: <alpine.LNX.2.00.1202062224210.20532@swampdragon.chaosbits.net>
 <1328568833.2476.1.camel@edumazet-laptop>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David Miller" <davem@davemloft.net>,
	"Eliezer Tamir" <eliezert@broadcom.com>
To: "Jesper Juhl" <jj@chaosbits.net>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328568833.2476.1.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-02-06 at 23:53 +0100, Eric Dumazet wrote:
> Le lundi 06 f=C3=A9vrier 2012 =C3=A0 22:28 +0100, Jesper Juhl a =C3=A9=
crit :
> > We allocate memory for 'new_data' with kmalloc(). If we get the mem=
ory
> > we then try to build_skb() and if that should fail (which it can) w=
e
> > do not enter 'if (likely(skb)) {' and actually use 'new_data' but
> > instead fall through to the 'drop:' label and end up returning from
> > the function without ever assigning 'new'data' to anything or freei=
ng
> > it. That leaks the memory allocated to 'new_data'.
> >=20
> > This patch fixes the memory leak by doing a kfree(new_data) in the
> > case where build_skb() fails (or where allocation of 'new_data' its=
elf
> > fails, but in taht case it's just a harmless kfree(NULL)).
> >=20
> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> > ---
> >  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    3 +--
> >  1 files changed, 1 insertions(+), 2 deletions(-)
> >=20
> >  No hardware to test, so compile tested only.
> >=20
> > diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/driv=
ers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> > index 03f3935..7aee469 100644
> > --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> > +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> > @@ -523,7 +523,6 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, st=
ruct bnx2x_fastpath *fp,
> >  		skb =3D build_skb(data);
> > =20
> >  	if (likely(skb)) {
> > -
> >  #ifdef BNX2X_STOP_ON_ERROR
> >  		if (pad + len > fp->rx_buf_size) {
> >  			BNX2X_ERR("skb_put is about to fail...  "
> > @@ -557,7 +556,7 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, st=
ruct bnx2x_fastpath *fp,
> > =20
> >  		return;
> >  	}
> > -
> > +	kfree(new_data);
> >  drop:
> >  	/* drop the packet and keep the buffer in the bin */
> >  	DP(NETIF_MSG_RX_STATUS,
> > --=20
> > 1.7.9
> >=20
> >=20
>=20
> Good catch, my bad.
>=20
> Thanks
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Indeed - nice catch. Thanks Jesper.

Acked-by: Eilon Greenstein <eilong@broadcom.com>
