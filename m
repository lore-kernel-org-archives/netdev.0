From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Mon, 19 Dec 2016 11:02:15 +0100
Message-ID: <20161219100215.GA6296@amd>
References: <20161208231943.GA13102@electric-eye.fr.zoreil.com>
 <20161209112142.GA22710@amd>
 <c76124b9-6376-42b9-2821-b5a8185f5034@gmx.de>
 <20161211201104.GB20574@amd>
 <cfad6b84-de23-2e03-6d34-2b3451975179@gmx.de>
 <20161215210324.GA13878@amd>
 <f3fc8035-fb6e-fb06-d9b8-bfc96dc4e1d2@gmx.de>
 <6f43eac8-754b-cfa2-371d-050701deb4cd@gmx.de>
 <20161217173150.GA20231@amd>
 <20161218001507.GA5343@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="huq684BweRXVnRxX"
Cc: Lino Sanfilippo <LinoSanfilippo@gmx.de>, bh74.an@samsung.com,
        ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161218001507.GA5343@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> Lino, have you considered via-rhine.c since its "move work from irq to
> workqueue context" changes that started in
> 7ab87ff4c770eed71e3777936299292739fcd0fe [*] ?
>=20
> It's a shameless plug - originated in r8169.c - but it should be rather
> close to what the sxgbe and friends require. Thought / opinion ?
>=20
> [*] Including fixes/changes in:
> - 3a5a883a8a663b930908cae4abe5ec913b9b2fd2
> - e1efa87241272104d6a12c8b9fcdc4f62634d447
> - 810f19bcb862f8889b27e0c9d9eceac9593925dd
> - e45af497950a89459a0c4b13ffd91e1729fffef4
> - a926592f5e4e900f3fa903298c4619a131e60963
> - 559bcac35facfed49ab4f408e162971612dcfdf3

Considering the memory barriers... is something like this neccessary
in the via-rhine?

AFAICT... we need a barrier after making sure that descriptor is no
longer owned by DMA (to make sure we don't get stale data in rest of
descriptor)... and we need a barrier before giving the descriptor to
the dma, to make sure DMA engine sees the complete update....?

Thanks,
								Pavel

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/vi=
a/via-rhine.c
index ba5c542..3806e72 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1952,6 +1952,7 @@ static void rhine_tx(struct net_device *dev)
 			  entry, txstatus);
 		if (txstatus & DescOwn)
 			break;
+		dma_rmb();
 		skb =3D rp->tx_skbuff[entry];
 		if (txstatus & 0x8000) {
 			netif_dbg(rp, tx_done, dev,
@@ -2061,6 +2062,7 @@ static int rhine_rx(struct net_device *dev, int limit)
=20
 		if (desc_status & DescOwn)
 			break;
+		dma_rmb();
=20
 		netif_dbg(rp, rx_status, dev, "%s() status %08x\n", __func__,
 			  desc_status);
@@ -2146,6 +2148,7 @@ static int rhine_rx(struct net_device *dev, int limit)
 			u64_stats_update_end(&rp->rx_stats.syncp);
 		}
 give_descriptor_to_nic:
+		dma_wmb();
 		desc->rx_status =3D cpu_to_le32(DescOwn);
 		entry =3D (++rp->cur_rx) % RX_RING_SIZE;
 	}

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--huq684BweRXVnRxX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhXsCcACgkQMOfwapXb+vIthQCgivZk6CLPh7jVvZEjKcO2CMIO
RUUAn1opD/wRi5ZgtbeAxuzHpxo6gI0F
=uSUT
-----END PGP SIGNATURE-----

--huq684BweRXVnRxX--
