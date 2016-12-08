From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Thu, 8 Dec 2016 22:54:09 +0100
Message-ID: <20161208215409.GA12472@amd>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481141138-19466-2-git-send-email-LinoSanfilippo@gmx.de>
 <20161207231534.GB5889@electric-eye.fr.zoreil.com>
 <051e3043-8b58-0591-36e3-99e2267f67f4@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="envbJBWh7q8WU6mo"
Cc: Francois Romieu <romieu@fr.zoreil.com>, bh74.an@samsung.com,
        ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <051e3043-8b58-0591-36e3-99e2267f67f4@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu 2016-12-08 21:32:12, Lino Sanfilippo wrote:
> Hi,
>=20
> On 08.12.2016 00:15, Francois Romieu wrote:
> > Lino Sanfilippo <LinoSanfilippo@gmx.de> :
> >> The driver uses a private lock for synchronization between the xmit
> >> function and the xmit completion handler, but since the NETIF_F_LLTX f=
lag
> >> is not set, the xmit function is also called with the xmit_lock held.
> >>=20
> >> On the other hand the xmit completion handler first takes the private =
lock
> >> and (in case that the tx queue has been stopped) the xmit_lock, leading
> >> to a reverse locking order and the potential danger of a deadlock.
> >=20
> > netif_tx_stop_queue is used by:
> > 1. xmit function before releasing lock and returning.
> > 2. sxgbe_restart_tx_queue()
> >    <- sxgbe_tx_interrupt
> >    <- sxgbe_reset_all_tx_queues()
> >       <- sxgbe_tx_timeout()
> >=20
> > Given xmit won't be called again until tx queue is enabled, it's not cl=
ear
> > how a deadlock could happen due to #1.
> >=20
>=20
>=20
> After spending more thoughts on this I tend to agree with you. Yes, we ha=
ve the
> different locking order for the xmit_lock and the private lock in two con=
current
> threads. And one of the first things one learns about locking is that thi=
s is a
> good way to create a deadlock sooner or later. But in our case the deadlo=
ck=20
> can only occur if the xmit function and the tx completion handler perceiv=
e different
>  states for the tx queue, or to be more specific:=20
> the completion handler sees the tx queue in state "stopped" while the xmi=
t handler=20
> sees it in state "running" at the same time. Only then both functions wou=
ld try to
> take both locks, which could lead to a deadlock.
>=20
> OTOH Pavel said that he actually could produce a deadlock. Now I wonder i=
f this is caused
> by that locking scheme (in a way I have not figured out yet) or if it is =
a different issue.

Pavel has some problems, but that's on different hardware.. and it is
possible that it is deadlock (or something else) somewhere else.

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--envbJBWh7q8WU6mo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhJ1oEACgkQMOfwapXb+vL3JgCfYQWbKWmosPOwX8Hf3iqnqeA3
vnwAoMF0lsmE26ueDjzaXIa3Prncv8qH
=NzZW
-----END PGP SIGNATURE-----

--envbJBWh7q8WU6mo--
