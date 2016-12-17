From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Sat, 17 Dec 2016 18:31:50 +0100
Message-ID: <20161217173150.GA20231@amd>
References: <20161207231534.GB5889@electric-eye.fr.zoreil.com>
 <051e3043-8b58-0591-36e3-99e2267f67f4@gmx.de>
 <20161208231943.GA13102@electric-eye.fr.zoreil.com>
 <20161209112142.GA22710@amd>
 <c76124b9-6376-42b9-2821-b5a8185f5034@gmx.de>
 <20161211201104.GB20574@amd>
 <cfad6b84-de23-2e03-6d34-2b3451975179@gmx.de>
 <20161215210324.GA13878@amd>
 <f3fc8035-fb6e-fb06-d9b8-bfc96dc4e1d2@gmx.de>
 <6f43eac8-754b-cfa2-371d-050701deb4cd@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="EVF5PPMfhYS0aIcm"
Cc: Francois Romieu <romieu@fr.zoreil.com>, bh74.an@samsung.com,
        ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:34571 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752296AbcLQRby (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 12:31:54 -0500
Content-Disposition: inline
In-Reply-To: <6f43eac8-754b-cfa2-371d-050701deb4cd@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu 2016-12-15 23:33:22, Lino Sanfilippo wrote:
> On 15.12.2016 22:32, Lino Sanfilippo wrote:
>=20
> > Ah ok. Then maybe priv->hw->dma->stop_tx() does not do the job correctl=
y (stop the
> > tx path properly) and the HW is still active on the tx path while the t=
x buffers are
> > freed. OTOH stmmac_release() also stops the phy before the tx (and rx) =
paths are stopped.
> > Did you try to stop the phy fist in stmmac_tx_err_work(), too?
> >=20
> > Regards,
> > Lino
> >=20
>=20
> And this is the "sledgehammer" approach: Do a complete shutdown and resta=
rt
> of the hardware in case of tx error (against net-next and only
>compile tested).

Wow, thanks a lot. I'll try to get the driver back to the non-working
state, and try it.

I believe I have some idea what is wrong there. (Missing memory barriers).

> +static void stmmac_tx_err_work(struct work_struct *work)
> +{
> +	struct stmmac_priv *priv =3D container_of(work, struct stmmac_priv,
> +						tx_err_work);
> +	/* restart netdev */
> +	rtnl_lock();
> +	stmmac_release(priv->dev);
> +	stmmac_open(priv->dev);
> +	rtnl_unlock();
> +}

Won't this up/down the interface, in a way userspace can observe?

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--EVF5PPMfhYS0aIcm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhVdoYACgkQMOfwapXb+vK/xACfRZURmOL0ow/Iz/nEgoJWa2NQ
93wAn3UD83fOR+QaKyH2sG4SoDXQUd4B
=v79f
-----END PGP SIGNATURE-----

--EVF5PPMfhYS0aIcm--
