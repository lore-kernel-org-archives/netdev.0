From: Haavard Skinnemoen <hskinnemoen@atmel.com>
Subject: Re: [PATCH] MACB: clear transmit buffers properly on TX Underrun
Date: Tue, 18 Dec 2007 15:52:32 +0100
Message-ID: <20071218155232.57027995@dhcp-252-066.norway.atmel.com>
References: <4760E49D.5040406@gmail.com>
	<20071213123308.156ab7dd@dhcp-252-066.norway.atmel.com>
	<47650DF5.7030402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: Gregory CLEMENT <gclement00@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-132.atmel.no ([80.232.32.132]:53724 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755272AbXLROxB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2007 09:53:01 -0500
In-Reply-To: <47650DF5.7030402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Dec 2007 12:37:25 +0100
Gregory CLEMENT <gclement00@gmail.com> wrote:

> Haavard Skinnemoen a =C3=A9crit :
> > But the patch is a bit mangled, so I don't think it will apply. Ple=
ase
> > have a look in Documentation/email-clients.txt for information on h=
ow
> > to set up Thunderbird to avoid this.
>=20
> I read it and apply it. Hope it will be OK as I didn't see any proble=
m in m first mail...

Looks good, thanks.

> >=20
> > I also think this should be done as part of the previous loop, befo=
re
> > they are freed. Having free buffers in the ring sounds dangerous, e=
ven
> > if it's only for a short time.
>=20
> OK, I moved this loop before the previous loop, as I wanted to be sur=
e that
> all buffers are marked.
> I did it, but I think we don't really need to do it, as when underrun=
 happen,=20
> controller stop transmitting, so it won't transmit a free buffer.

Yes, you're probably right. But it looks better now, I think.

> >=20
> >> +
> >>          bp->tx_head =3D bp->tx_tail =3D 0;
> >=20
> > Now, I wonder if it would be better to just scan the ring descripto=
rs,
> > find the one that failed and just move the DMA pointer to the next
> > entry. The hardware resets the DMA pointer when an underrun happens=
, so
> > I think your code will work, but we're losing more packets than
> > strictly necessary. In any case, it's better than the existing code=
=2E
>=20
> As hardware reset the DMA pointer, we have to rewrite all the buffer =
descriptor.
>=20
> For example if descriptor n=C2=B078 failed, and there is descriptor 7=
9 and 80 which
> are pending. When underrun happen on 78 the hardware reset DMA pointe=
r which
> will point on descriptor 0. So we have to copy descriptor 79 on 0 and=
 80 on 1.
> The other option is to change Transmit Buffer Queue Pointer Register =
(TBQP), to
> make it point on descriptor 79, but on the next descriptor having wra=
pped bit set,
> the DMA pointer will wrapped on descriptor 79 and not on 0. So I don'=
t think it
> is a good solution.

The second option sounds feasible to me. We know how large the ring is,
so taking care of the wrapping isn't very expensive.

> > Perhaps we need a check in macb_start_xmit() as well to avoid start=
ing
> > a transmission when the ring has just been reset.
> >=20
>=20
> I joined the patch change along your recommendation, if there is no m=
ore error, you
> can maybe submit it for 2.6.24 release, and other improvement can be =
done later.

Ok, if it works for you, I'll send it upstream; your patch certainly
improves things. I think there's still an unresolved race with
macb_start_xmit()...but closing it involves more complex modifications
to the main tx patch, so it's probably safest to leave it for 2.6.25.

> From: Gregory CLEMENT <gclement00@gmail.com>
> Date: Sun, 16 Dec 2007 11:45:03 +0100
> Subject: [PATCH]  MACB: clear transmit buffers properly on transmit u=
nderrun
>=20
> Initially transmit buffer pointers were only reset. But buffer descri=
ptors
> were possibly still set as ready, and buffer in upper layer was not
> freed. This caused driver hang under big load.
> Now reset clean properly the buffer descriptor and freed upper layer.
>=20
> Signed-off-by: Gregory CLEMENT <gclement00@gmail.com>
> ---
>  drivers/net/macb.c |   27 ++++++++++++++++++++++++++-
>  1 files changed, 26 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/macb.c b/drivers/net/macb.c
> index 047ea7b..e898713 100644
> --- a/drivers/net/macb.c
> +++ b/drivers/net/macb.c
> @@ -307,9 +307,34 @@ static void macb_tx(struct macb *bp)
>  		(unsigned long)status);
> =20
>  	if (status & MACB_BIT(UND)) {
> +		int i;
>  		printk(KERN_ERR "%s: TX underrun, resetting buffers\n",
> -		       bp->dev->name);
> +			   bp->dev->name);

I'll just kill these extra spaces...


>  		bp->tx_head =3D bp->tx_tail =3D 0;
> +

=2E..and this extra line.

Haavard
