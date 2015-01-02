From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 3/4] net: ethernet: cpsw: split out IRQ handler
Date: Fri, 2 Jan 2015 12:55:35 -0600
Message-ID: <20150102185535.GB4920@saruman>
References: <1420222228-31949-1-git-send-email-balbi@ti.com>
 <1420222228-31949-4-git-send-email-balbi@ti.com>
 <CAA93jw7qyZjdHGKXjiBhiYp4BWBFrUFM6FF-Lzc0i7eOnM6cNg@mail.gmail.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KFztAG8eRSV9hGtP"
Cc: Felipe Balbi <balbi@ti.com>,
	Linux OMAP Mailing List <linux-omap@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAA93jw7qyZjdHGKXjiBhiYp4BWBFrUFM6FF-Lzc0i7eOnM6cNg@mail.gmail.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--KFztAG8eRSV9hGtP
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Fri, Jan 02, 2015 at 10:49:49AM -0800, Dave Taht wrote:
> +1.
>=20
> We'd had a thread on netdev (can't find it now) where we discussed
> adding BQL support and also something saner for the NAPI handling to
> this driver.

yeah, currently is completely borked. I'm on a gigabit network and I'm
getting 94Mbits/sec, total crap.

> Initial results for the beaglebone black were pretty spectacular, and
> it does look like this is way cleaner infrastructure underneat th deal
> with. Are you testing

cool, if I new more about networking I'd certainly help, but I can help
testing for sure, just keep me in Cc ;-)

> on the beaglebone black.? do you remember that convo?

yeah, testing on beagleboneblack and AM437x SK.

cheers

> On Fri, Jan 2, 2015 at 10:10 AM, Felipe Balbi <balbi@ti.com> wrote:
> > Now we can introduce dedicated IRQ handlers
> > for each of the IRQ events. This helps with
> > cleaning up a little bit of the clutter in
> > cpsw_interrupt() while also making sure that
> > TX IRQs will try to handle TX buffers while
> > RX IRQs will try to handle RX buffers.
> >
> > Signed-off-by: Felipe Balbi <balbi@ti.com>
> > ---
> >  drivers/net/ethernet/ti/cpsw.c | 41 ++++++++++++++++++++++++++++++----=
-------
> >  1 file changed, 30 insertions(+), 11 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/c=
psw.c
> > index 6e04128..c9081bd 100644
> > --- a/drivers/net/ethernet/ti/cpsw.c
> > +++ b/drivers/net/ethernet/ti/cpsw.c
> > @@ -754,18 +754,36 @@ requeue:
> >                 dev_kfree_skb_any(new_skb);
> >  }
> >
> > -static irqreturn_t cpsw_interrupt(int irq, void *dev_id)
> > +static irqreturn_t cpsw_dummy_interrupt(int irq, void *dev_id)
> >  {
> >         struct cpsw_priv *priv =3D dev_id;
> >         int value =3D irq - priv->irqs_table[0];
> >
> > -       /* NOTICE: Ending IRQ here. The trick with the 'value' variable=
 above
> > -        * is to make sure we will always write the correct value to th=
e EOI
> > -        * register. Namely 0 for RX_THRESH Interrupt, 1 for RX Interru=
pt, 2
> > -        * for TX Interrupt and 3 for MISC Interrupt.
> > -        */
> >         cpdma_ctlr_eoi(priv->dma, value);
> >
> > +       return IRQ_HANDLED;
> > +}
> > +
> > +static irqreturn_t cpsw_tx_interrupt(int irq, void *dev_id)
> > +{
> > +       struct cpsw_priv *priv =3D dev_id;
> > +
> > +       cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_TX);
> > +       cpdma_chan_process(priv->txch, 128);
> > +
> > +       priv =3D cpsw_get_slave_priv(priv, 1);
> > +       if (priv)
> > +               cpdma_chan_process(priv->txch, 128);
> > +
> > +       return IRQ_HANDLED;
> > +}
> > +
> > +static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
> > +{
> > +       struct cpsw_priv *priv =3D dev_id;
> > +
> > +       cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
> > +
> >         cpsw_intr_disable(priv);
> >         if (priv->irq_enabled =3D=3D true) {
> >                 cpsw_disable_irq(priv);
> > @@ -1617,7 +1635,8 @@ static void cpsw_ndo_poll_controller(struct net_d=
evice *ndev)
> >
> >         cpsw_intr_disable(priv);
> >         cpdma_ctlr_int_ctrl(priv->dma, false);
> > -       cpsw_interrupt(ndev->irq, priv);
> > +       cpsw_rx_interrupt(priv->irq[1], priv);
> > +       cpsw_tx_interrupt(priv->irq[2], priv);
> >         cpdma_ctlr_int_ctrl(priv->dma, true);
> >         cpsw_intr_enable(priv);
> >  }
> > @@ -2351,7 +2370,7 @@ static int cpsw_probe(struct platform_device *pde=
v)
> >                 goto clean_ale_ret;
> >
> >         priv->irqs_table[0] =3D irq;
> > -       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
> > +       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_dummy_interrupt,
> >                         0, dev_name(&pdev->dev), priv);
> >         if (ret < 0) {
> >                 dev_err(priv->dev, "error attaching irq (%d)\n", ret);
> > @@ -2363,7 +2382,7 @@ static int cpsw_probe(struct platform_device *pde=
v)
> >                 goto clean_ale_ret;
> >
> >         priv->irqs_table[1] =3D irq;
> > -       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
> > +       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_rx_interrupt,
> >                         0, dev_name(&pdev->dev), priv);
> >         if (ret < 0) {
> >                 dev_err(priv->dev, "error attaching irq (%d)\n", ret);
> > @@ -2375,7 +2394,7 @@ static int cpsw_probe(struct platform_device *pde=
v)
> >                 goto clean_ale_ret;
> >
> >         priv->irqs_table[2] =3D irq;
> > -       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
> > +       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_tx_interrupt,
> >                         0, dev_name(&pdev->dev), priv);
> >         if (ret < 0) {
> >                 dev_err(priv->dev, "error attaching irq (%d)\n", ret);
> > @@ -2387,7 +2406,7 @@ static int cpsw_probe(struct platform_device *pde=
v)
> >                 goto clean_ale_ret;
> >
> >         priv->irqs_table[3] =3D irq;
> > -       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
> > +       ret =3D devm_request_irq(&pdev->dev, irq, cpsw_dummy_interrupt,
> >                         0, dev_name(&pdev->dev), priv);
> >         if (ret < 0) {
> >                 dev_err(priv->dev, "error attaching irq (%d)\n", ret);
> > --
> > 2.2.0
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20
>=20
> --=20
> Dave T=E4ht
>=20
> thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks

--=20
balbi

--KFztAG8eRSV9hGtP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUpumnAAoJEIaOsuA1yqRENmwQAKFdGHDvZHOXHZgucbiy/Qn1
HW5I7aOStJVENKfrFXim62R9G9tGUCaeA6O4cK1nElZK0tbYjt0pmc9LuwTM22Wq
v/2LCBMeTojyCbQ+elPJFATi2efi+BNg+tS23tSXU7nlr3R/b2pIxyqo1oQ7w5L/
Ft2eEDnV2yD/g3k+vxe8JXUtqesY2vXkL0ZLsgIACmiT9dSSbMKxWwS4xvUHfK3Q
rlMyrwhqSNvgwnSTzqfd+pPazKtK3LlGp+xogTSho/0jDo3zMtFMR9sDOVqZ7QDc
Vp7d2kgRtKWpLmr380Cam2pLvDnOL+Cw0yH3PDSHDHDdOCwbwV5i7PR13rMvMfB4
OFZkqaFozFcebPAE6+v74Eullj03prs0x5KG5984/ioYvkvFxB8EHEHS5hsNY2le
+Fvx+tKA8KKK6f6d5Fkdi3qchZYtnrJDQW7/P8SzKzE20CO/uGjPPq9pooSZgwXt
Wci0wxF2OJk4y5jdLvPkvMWDzWMP0fYtiqtPzj21uS9EWELRI5OB5ERMERJ6O40L
IxIQV8gF1KUto63qkwZRliNI0Gqyb3Q4PiKx1VnRDeENcsa8/m+F6/oMqjb5Kr9j
Sazcim6+8Nb7A4mGrufRcr7iI0iN1DkZcQyDeMsV5cKU46S5mDYh1100gF2+u6gu
roCEwvN1YvOeYh+T8YDu
=kP6G
-----END PGP SIGNATURE-----

--KFztAG8eRSV9hGtP--
