From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 3/4] net: ethernet: cpsw: split out IRQ handler
Date: Fri, 2 Jan 2015 13:03:50 -0600
Message-ID: <20150102190350.GC4920@saruman>
References: <1420222228-31949-1-git-send-email-balbi@ti.com>
 <1420222228-31949-4-git-send-email-balbi@ti.com>
 <CAA93jw7qyZjdHGKXjiBhiYp4BWBFrUFM6FF-Lzc0i7eOnM6cNg@mail.gmail.com>
 <20150102185535.GB4920@saruman>
 <CAA93jw7=aFM3yQLO+vtN4uHW2gMnfNaY=BdbA+b0WYq-0+gSYQ@mail.gmail.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="iFRdW5/EC4oqxDHL"
Cc: Felipe Balbi <balbi@ti.com>, <netdev@vger.kernel.org>,
	Linux OMAP Mailing List <linux-omap@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:41544 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779AbbABTEU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jan 2015 14:04:20 -0500
Content-Disposition: inline
In-Reply-To: <CAA93jw7=aFM3yQLO+vtN4uHW2gMnfNaY=BdbA+b0WYq-0+gSYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--iFRdW5/EC4oqxDHL
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

(please use reply-all to keep mailing lists in Cc, also avoid
top-posting)

On Fri, Jan 02, 2015 at 10:58:29AM -0800, Dave Taht wrote:
> The beaglebone only has a 100mbit phy, so you aren't going to get more
> than that.

very true :-) Still, with AM437x SK which is definitely GigE, I'm
getting 201Mbits/sec.

> (so do a lot of IoT devices).
>=20
> So you have the two patches that went by on BQL and on NAPI for the beagl=
e?

no, got any pointers ?

> On Fri, Jan 2, 2015 at 10:55 AM, Felipe Balbi <balbi@ti.com> wrote:
> > Hi,
> >
> > On Fri, Jan 02, 2015 at 10:49:49AM -0800, Dave Taht wrote:
> >> +1.
> >>
> >> We'd had a thread on netdev (can't find it now) where we discussed
> >> adding BQL support and also something saner for the NAPI handling to
> >> this driver.
> >
> > yeah, currently is completely borked. I'm on a gigabit network and I'm
> > getting 94Mbits/sec, total crap.
> >
> >> Initial results for the beaglebone black were pretty spectacular, and
> >> it does look like this is way cleaner infrastructure underneat th deal
> >> with. Are you testing
> >
> > cool, if I new more about networking I'd certainly help, but I can help
> > testing for sure, just keep me in Cc ;-)
> >
> >> on the beaglebone black.? do you remember that convo?
> >
> > yeah, testing on beagleboneblack and AM437x SK.
> >
> > cheers
> >
> >> On Fri, Jan 2, 2015 at 10:10 AM, Felipe Balbi <balbi@ti.com> wrote:
> >> > Now we can introduce dedicated IRQ handlers
> >> > for each of the IRQ events. This helps with
> >> > cleaning up a little bit of the clutter in
> >> > cpsw_interrupt() while also making sure that
> >> > TX IRQs will try to handle TX buffers while
> >> > RX IRQs will try to handle RX buffers.
> >> >
> >> > Signed-off-by: Felipe Balbi <balbi@ti.com>
> >> > ---
> >> >  drivers/net/ethernet/ti/cpsw.c | 41 ++++++++++++++++++++++++++++++-=
----------
> >> >  1 file changed, 30 insertions(+), 11 deletions(-)
> >> >
> >> > diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/t=
i/cpsw.c
> >> > index 6e04128..c9081bd 100644
> >> > --- a/drivers/net/ethernet/ti/cpsw.c
> >> > +++ b/drivers/net/ethernet/ti/cpsw.c
> >> > @@ -754,18 +754,36 @@ requeue:
> >> >                 dev_kfree_skb_any(new_skb);
> >> >  }
> >> >
> >> > -static irqreturn_t cpsw_interrupt(int irq, void *dev_id)
> >> > +static irqreturn_t cpsw_dummy_interrupt(int irq, void *dev_id)
> >> >  {
> >> >         struct cpsw_priv *priv =3D dev_id;
> >> >         int value =3D irq - priv->irqs_table[0];
> >> >
> >> > -       /* NOTICE: Ending IRQ here. The trick with the 'value' varia=
ble above
> >> > -        * is to make sure we will always write the correct value to=
 the EOI
> >> > -        * register. Namely 0 for RX_THRESH Interrupt, 1 for RX Inte=
rrupt, 2
> >> > -        * for TX Interrupt and 3 for MISC Interrupt.
> >> > -        */
> >> >         cpdma_ctlr_eoi(priv->dma, value);
> >> >
> >> > +       return IRQ_HANDLED;
> >> > +}
> >> > +
> >> > +static irqreturn_t cpsw_tx_interrupt(int irq, void *dev_id)
> >> > +{
> >> > +       struct cpsw_priv *priv =3D dev_id;
> >> > +
> >> > +       cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_TX);
> >> > +       cpdma_chan_process(priv->txch, 128);
> >> > +
> >> > +       priv =3D cpsw_get_slave_priv(priv, 1);
> >> > +       if (priv)
> >> > +               cpdma_chan_process(priv->txch, 128);
> >> > +
> >> > +       return IRQ_HANDLED;
> >> > +}
> >> > +
> >> > +static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
> >> > +{
> >> > +       struct cpsw_priv *priv =3D dev_id;
> >> > +
> >> > +       cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
> >> > +
> >> >         cpsw_intr_disable(priv);
> >> >         if (priv->irq_enabled =3D=3D true) {
> >> >                 cpsw_disable_irq(priv);
> >> > @@ -1617,7 +1635,8 @@ static void cpsw_ndo_poll_controller(struct ne=
t_device *ndev)
> >> >
> >> >         cpsw_intr_disable(priv);
> >> >         cpdma_ctlr_int_ctrl(priv->dma, false);
> >> > -       cpsw_interrupt(ndev->irq, priv);
> >> > +       cpsw_rx_interrupt(priv->irq[1], priv);
> >> > +       cpsw_tx_interrupt(priv->irq[2], priv);
> >> >         cpdma_ctlr_int_ctrl(priv->dma, true);
> >> >         cpsw_intr_enable(priv);
> >> >  }
> >> > @@ -2351,7 +2370,7 @@ static int cpsw_probe(struct platform_device *=
pdev)
> >> >                 goto clean_ale_ret;
> >> >
> >> >         priv->irqs_table[0] =3D irq;
> >> > -       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
> >> > +       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_dummy_interru=
pt,
> >> >                         0, dev_name(&pdev->dev), priv);
> >> >         if (ret < 0) {
> >> >                 dev_err(priv->dev, "error attaching irq (%d)\n", ret=
);
> >> > @@ -2363,7 +2382,7 @@ static int cpsw_probe(struct platform_device *=
pdev)
> >> >                 goto clean_ale_ret;
> >> >
> >> >         priv->irqs_table[1] =3D irq;
> >> > -       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
> >> > +       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_rx_interrupt,
> >> >                         0, dev_name(&pdev->dev), priv);
> >> >         if (ret < 0) {
> >> >                 dev_err(priv->dev, "error attaching irq (%d)\n", ret=
);
> >> > @@ -2375,7 +2394,7 @@ static int cpsw_probe(struct platform_device *=
pdev)
> >> >                 goto clean_ale_ret;
> >> >
> >> >         priv->irqs_table[2] =3D irq;
> >> > -       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
> >> > +       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_tx_interrupt,
> >> >                         0, dev_name(&pdev->dev), priv);
> >> >         if (ret < 0) {
> >> >                 dev_err(priv->dev, "error attaching irq (%d)\n", ret=
);
> >> > @@ -2387,7 +2406,7 @@ static int cpsw_probe(struct platform_device *=
pdev)
> >> >                 goto clean_ale_ret;
> >> >
> >> >         priv->irqs_table[3] =3D irq;
> >> > -       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
> >> > +       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_dummy_interru=
pt,
> >> >                         0, dev_name(&pdev->dev), priv);
> >> >         if (ret < 0) {
> >> >                 dev_err(priv->dev, "error attaching irq (%d)\n", ret=
);
> >> > --
> >> > 2.2.0
> >> >
> >> > --
> >> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> >> > the body of a message to majordomo@vger.kernel.org
> >> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> >>
> >>
> >> --
> >> Dave T=E4ht
> >>
> >> thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
> >
> > --
> > balbi
>=20
>=20
>=20
> --=20
> Dave T=E4ht
>=20
> thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks

--=20
balbi

--iFRdW5/EC4oqxDHL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUpuuVAAoJEIaOsuA1yqREaQ0P/RjL3jyXN0mkiXAtvDr+5YEQ
m/olDwWLlljoyHsFrhZo/RCxznIl1d7fFE91cFF66xDZVaZ8y7EL0jMde46VsUCe
XuYhNt9MDKhovlggzcoR+jeHwo0WbQKTqOk6/1lurq7VH78xI8OX25z7Z9WusA4o
O/0xIpoNQUGU9E48NdAY5tkc/gzlk5/YiH11DLrtyQ6osCOzMuidm3bkgGS4sKAL
nYKMLasxBh5tumZNC4eyVv6cO9ROQFfekNflPYleMZtV3Rfmn6b16IdzOStXH100
pQ2hrCKSWe7peZFJ0UC9cjR8z9KxjOXmDH7QRAHGje3PqrfDDtKQbd21GC9bJCem
FFTciD8BAWz39ZaLD3gihHJqWTKNJJjb/cHNQqypG4NpbgYETgm5WYfRiZjzcIGW
WSOHkm66EyMqLW8lj/PHuN+plFoQ4FJDrDMmx5S7NQKCR/NH47BRI5XLrPLsl6yU
tnk+LhuKST8zhu1vl/CkPxQcrf0fkhaqY+dXpiDzYUVNUyb/Z7TqTo6U4Ws25JPn
Vsj/+NLbH22+suHu0lgwdS53OG/GeCRdtqdKQk97P14Mb9PHslf9kQWCVmo/97ZM
CEtqbgU41bnfTrZKZMI71bslSd44s7hClEnun8G7cQZXNr27ZpEaYP9L+oFToEGX
mJOyLCauOo/HLldsK017
=vB4L
-----END PGP SIGNATURE-----

--iFRdW5/EC4oqxDHL--
