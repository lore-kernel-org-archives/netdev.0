From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v2 2/2] net: ethernet: stmmac: remove private tx queue
 lock
Date: Thu, 15 Dec 2016 10:45:17 +0100
Message-ID: <20161215094517.GA406@amd>
References: <1481241343-18062-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481241343-18062-3-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="opJtzjQTFsWo+cga"
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        romieu@fr.zoreil.com, davem@davemloft.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1481241343-18062-3-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> The driver uses a private lock for synchronization of the xmit function a=
nd
> the xmit completion handler, but since the NETIF_F_LLTX flag is not set,
> the xmit function is also called with the xmit_lock held.
>=20
> On the other hand the completion handler uses the reverse locking order by
> first taking the private lock and (in case that the tx queue had been
> stopped) then the xmit_lock.
>=20
> Improve the locking by removing the private lock and using only the
> xmit_lock for synchronization instead.

Do you have stmmac hardware to test on?

I believe something is very wrong with the locking there. In
particular... scheduling the stmmac_tx_timer() function to run often
should not do anything bad if locking is correct... but it breaks the
driver rather quickly. [Example patch below, needs applying to two
places in net-next.]

(Other possibility is that hardware races with the driver.)

Giuseppe, is there documentation available for the chip? Driver says

  Documentation available at:
          http://www.stlinux.com

but that page does not work for me...

404 Not Found

Code: NoSuchBucket
Message: The specified bucket does not exist
BucketName: www.stlinux.com
RequestId: 1C8A20CB99AE7F75
HostId:
ljPnqbEpyD8exct5MUgcDXSW8n+I67Yw0aejNhLuBQ0pqN0UCfiRBa3ztlOMngiXoSN+COX+VSw=
=3D

Best regards,
									Pavel

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/ne=
t/ethernet/stmicro/stmmac/stmmac_main.c
index ffbcd03..8040370 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1973,8 +1973,9 @@ static void stmmac_xmit_common(struct sk_buff *skb, s=
truct net_device *dev, int
 	 */
 	priv->tx_count_frames +=3D nfrags + 1;
 	if (likely(priv->tx_coal_frames > priv->tx_count_frames)) {
-		mod_timer(&priv->txtimer,
-			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
+		if (priv->tx_count_frames =3D=3D nfrags + 1)
+			mod_timer(&priv->txtimer,
+				  STMMAC_COAL_TIMER(priv->tx_coal_timer));
 	} else {
 		priv->tx_count_frames =3D 0;
 		priv->hw->desc->set_tx_ic(desc);


--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--opJtzjQTFsWo+cga
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhSZi0ACgkQMOfwapXb+vLwFgCcCxNT0xBRdIEgrlrKLoWCt68q
3z4An0I5HFQfvnx85/wPyQ83YFIOI+SA
=WOGL
-----END PGP SIGNATURE-----

--opJtzjQTFsWo+cga--
