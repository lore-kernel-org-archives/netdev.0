From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Synopsys Ethernet QoS
Date: Sat, 17 Dec 2016 18:38:24 +0100
Message-ID: <20161217173824.GB20231@amd>
References: <CAHp75VcKURaTQX9=SY8+46GGATuwO1oXAi8eMS+uwk58sjKx5Q@mail.gmail.com>
 <3aee5a67-5e19-34e6-1719-ff13c7b914ea@gmail.com>
 <CAHp75VfT9B3O5jU0eHoKtgYc48K2ZjCQ-g9ZQ9nX1Hew6tz-zw@mail.gmail.com>
 <556353b7-c847-7549-626d-3c324063647e@gmail.com>
 <f5357ea2-a295-ab08-046e-f8b8f6ca4344@synopsys.com>
 <1d445ec1-deb8-6e36-39c4-6813c446095f@axis.com>
 <73bf8cb4-5685-2db6-529c-1de99b1fd358@st.com>
 <99424968-ad8f-fec6-ebcf-ab7b19ee5486@axis.com>
 <20161214125735.GA19542@amd>
 <79642215-95ce-7f04-3db7-121c585e2f2a@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="61jdw2sOBCFtR2d/"
Cc: Niklas Cassel <niklas.cassel@axis.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andy Shevchenko <andy.shevchenko@gmail.com>,
        David Miller <davem@davemloft.net>, larper@axis.com,
        rabinv@axis.com, netdev <netdev@vger.kernel.org>,
        CARLOS.PALMINHA@synopsys.com, Jie.Deng1@synopsys.com,
        Stephen Warren <swarren@nvidia.com>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:34729 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751932AbcLQRi0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 12:38:26 -0500
Content-Disposition: inline
In-Reply-To: <79642215-95ce-7f04-3db7-121c585e2f2a@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--61jdw2sOBCFtR2d/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> >> So if there is a long time before handling interrupts,
> >> I guess that it makes sense that one stream could
> >> get an advantage in the net scheduler.
> >>
> >> If I find the time, and if no one beats me to it, I will try to replace
> >> the normal timers with HR timers + a smaller default timeout.
> >>
> >=20
> > Can you try something like this? Highres timers will be needed, too,
> > but this fixes the logic problem.
> >=20
> > You'll need to apply it twice as code is copy&pasted.
> >=20
> > Best regards,
> > 									Pavel
> >=20
> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >=20
> >  	 */
> >  	priv->tx_count_frames +=3D nfrags + 1;
> >  	if (likely(priv->tx_coal_frames > priv->tx_count_frames)) {
> > -		mod_timer(&priv->txtimer,
> > -			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
> > +		if (priv->tx_count_frames =3D=3D nfrags + 1)
> > +			mod_timer(&priv->txtimer,
> > +				  STMMAC_COAL_TIMER(priv->tx_coal_timer));
> >  	} else {
> >  		priv->tx_count_frames =3D 0;
> >  		priv->hw->desc->set_tx_ic(desc);
> >=20
> >=20
>=20
> I know that this is completely of topic, but I am facing a dificulty with
> stmmac. I have interrupts, mac well configured rx packets being received
> successfully, but TX is not working, resulting in Tx errors =3D Total TX =
packets.
> I have made a lot of debug and my conclusions is that by some reason when=
 using
> stmmac after starting tx dma, the hw state machine enters a deadend state
> resulting in those errors. Anyone faced this trouble?

SMP or UP system? AFAICT the driver gets the memory barriers wrong. It
does not fail completely for me, but still fails rather quickly.

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/ne=
t/ethernet/stmicro/stmmac/stmmac_main.c
index 3e40578..641b03d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2121,11 +2205,11 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *=
skb, struct net_device *dev)
 	if (mss_desc)
 		priv->hw->desc->set_tx_owner(mss_desc);
=20
-	/* The own bit must be the latest setting done when prepare the
+	/* The own bit must be the latest setting done when preparing the
 	 * descriptor and then barrier is needed to make sure that
 	 * all is coherent before granting the DMA engine.
 	 */
-	smp_wmb();
+	wmb();
=20
 	if (netif_msg_pktdata(priv)) {
 		pr_info("%s: curr=3D%d dirty=3D%d f=3D%d, e=3D%d, f_p=3D%p, nfrags %d\n",
@@ -2336,9 +2401,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, s=
truct net_device *dev)
=20
 		/* The own bit must be the latest setting done when prepare the
 		 * descriptor and then barrier is needed to make sure that
-		 * all is coherent before granting the DMA engine.
+		 * all is coherent before granting access to the DMA engine.
 		 */
-		smp_wmb();
+		wmb();
 	}
=20
 	netdev_sent_queue(dev, skb->len);

Plus I'd suggest... at least (hand-edited). Driver should really be
modified to use readl() when accessing memory that changes.

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/ne=
t/ethernet/stmicro/stmmac/stmmac_main.c
index 3e40578..641b03d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1309,6 +1323,8 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 		status =3D priv->hw->desc->tx_status(&priv->dev->stats,
 						      &priv->xstats, p,
 						      priv->ioaddr);
+		rmb();
+	=09
 		/* Check if the descriptor is owned by the DMA */
 		if (unlikely(status & tx_dma_own))
 			break;

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--61jdw2sOBCFtR2d/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhVeBAACgkQMOfwapXb+vKoIwCgvo5TWkRyoYrrW24Yh9Um8WdL
IzIAn1D5xmtM2MX3R0Q4/dkEbxnppl12
=LcQa
-----END PGP SIGNATURE-----

--61jdw2sOBCFtR2d/--
