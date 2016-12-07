From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 2/2] net: ethernet: stmmac: remove private tx queue lock
Date: Wed, 7 Dec 2016 21:55:42 +0100
Message-ID: <20161207205542.GA2250@amd>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481141138-19466-3-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="45Z9DzgjV8m4Oswq"
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1481141138-19466-3-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> The driver uses a private lock for synchronization between the xmit
> function and the xmit completion handler, but since the NETIF_F_LLTX flag
> is not set, the xmit function is also called with the xmit_lock held.
>=20
> On the other hand the xmit completion handler first takes the private lock
> and (in case that the tx queue has been stopped) the xmit_lock, leading to
> a reverse locking order and the potential danger of a deadlock.
>=20
> Fix this by removing the private lock completely and synchronizing the xm=
it
> function and completion handler solely by means of the xmit_lock. By doing
> this remove also the now unnecessary double check for a stopped tx queue.
>=20
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Does not seem to apply to net-next based on
adc176c5472214971d77c1a61c83db9b01e9cdc7. Aha, that's the printk()
changes, probably would apply to mainline.

> index caf069a..db46ec4 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1307,7 +1307,7 @@ static void stmmac_tx_clean(struct stmmac_priv *pri=
v)
>  	unsigned int bytes_compl =3D 0, pkts_compl =3D 0;
>  	unsigned int entry =3D priv->dirty_tx;
> =20
> -	spin_lock(&priv->tx_lock);
> +	netif_tx_lock(priv->dev);
> =20
>  	priv->xstats.tx_clean++;
>

Should it use "netif_tx_lock_bh"?

I could not reproduce the deadlock without this patch, nor can I
detect anything wrong with this patch, so I guess that is:

Tested-by: Pavel Machek <pavel@denx.de>

Thanks,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--45Z9DzgjV8m4Oswq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhId04ACgkQMOfwapXb+vItjACgj6IbYrvZOGMYRYEdrQS0ypnN
sgMAoMPsAFvrY3g6CIcOOZzXkikVH/Un
=h25n
-----END PGP SIGNATURE-----

--45Z9DzgjV8m4Oswq--
