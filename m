From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Thu, 8 Dec 2016 23:18:30 +0100
Message-ID: <20161208221830.GD12472@amd>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481141138-19466-2-git-send-email-LinoSanfilippo@gmx.de>
 <20161207231534.GB5889@electric-eye.fr.zoreil.com>
 <051e3043-8b58-0591-36e3-99e2267f67f4@gmx.de>
 <20161208215409.GA12472@amd>
 <9b55b51c-bbbf-7f80-fb67-9df88a288708@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="rqzD5py0kzyFAOWN"
Cc: Francois Romieu <romieu@fr.zoreil.com>, bh74.an@samsung.com,
        ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9b55b51c-bbbf-7f80-fb67-9df88a288708@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--rqzD5py0kzyFAOWN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu 2016-12-08 23:12:10, Lino Sanfilippo wrote:
> Hi,
>=20
> On 08.12.2016 22:54, Pavel Machek wrote:
> > On Thu 2016-12-08 21:32:12, Lino Sanfilippo wrote:
> >> Hi,
> >>=20
> >> On 08.12.2016 00:15, Francois Romieu wrote:
> >> > Lino Sanfilippo <LinoSanfilippo@gmx.de> :
> >> >> The driver uses a private lock for synchronization between the xmit
> >> >> function and the xmit completion handler, but since the NETIF_F_LLT=
X flag
> >> >> is not set, the xmit function is also called with the xmit_lock hel=
d.
> >> >>=20
> >> >> On the other hand the xmit completion handler first takes the priva=
te lock
> >> >> and (in case that the tx queue has been stopped) the xmit_lock, lea=
ding
> >> >> to a reverse locking order and the potential danger of a deadlock.
> >> >=20
> >> > netif_tx_stop_queue is used by:
> >> > 1. xmit function before releasing lock and returning.
> >> > 2. sxgbe_restart_tx_queue()
> >> >    <- sxgbe_tx_interrupt
> >> >    <- sxgbe_reset_all_tx_queues()
> >> >       <- sxgbe_tx_timeout()
> >> >=20
> >> > Given xmit won't be called again until tx queue is enabled, it's not=
 clear
> >> > how a deadlock could happen due to #1.
> >> >=20
> >>=20
> >>=20
> >> After spending more thoughts on this I tend to agree with you. Yes, we=
 have the
> >> different locking order for the xmit_lock and the private lock in two =
concurrent
> >> threads. And one of the first things one learns about locking is that =
this is a
> >> good way to create a deadlock sooner or later. But in our case the dea=
dlock=20
> >> can only occur if the xmit function and the tx completion handler perc=
eive different
> >>  states for the tx queue, or to be more specific:=20
> >> the completion handler sees the tx queue in state "stopped" while the =
xmit handler=20
> >> sees it in state "running" at the same time. Only then both functions =
would try to
> >> take both locks, which could lead to a deadlock.
> >>=20
> >> OTOH Pavel said that he actually could produce a deadlock. Now I wonde=
r if this is caused
> >> by that locking scheme (in a way I have not figured out yet) or if it =
is a different issue.
> >=20
> > Pavel has some problems, but that's on different hardware.. and it is
> > possible that it is deadlock (or something else) somewhere else.
> >=20
>=20
> Right, it is different hardware. But the locking situation in xmit functi=
on and tx completion handler
> is very similar in both drivers. So if a deadlock is not possible in sxgb=
e it should=20
> also not be possible in stmmac (at least not due to the different locking=
 order).=20
> So maybe there is no real issue that we could fix with removing the priva=
te lock and we should
> keep it as it is.

Well.. the locking is pretty confused there. Having private lock that
mirrors lock from network layer is confusing and ugly... that should
be reason to fix it.
									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--rqzD5py0kzyFAOWN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEUEARECAAYFAlhJ3DYACgkQMOfwapXb+vKBGQCXVNVCF8YgP3LMLbEInjFsqG9H
dgCdHkso8X1TuebUvfZ/NumA6oPcMt0=
=tIcN
-----END PGP SIGNATURE-----

--rqzD5py0kzyFAOWN--
