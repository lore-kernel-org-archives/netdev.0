From: Michal Ostrowski <mostrows@watson.ibm.com>
Subject: Re: Deadlock in sungem/ip_auto_config/linkwatch
Date: Mon, 05 Jan 2004 11:19:25 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1073319565.2043.98923.camel@brick.watson.ibm.com>
References: <1073307882.2041.98320.camel@brick.watson.ibm.com>
	 <200401051550.51063.srompf@isg.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-T7Vi+m2S37xHNyQWLC01"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <200401051550.51063.srompf@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-T7Vi+m2S37xHNyQWLC01
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

This can get pretty hairy.

Suppose the linkwatch code backs-off in the case that rtnl_sem is held
legitimately by thread A.  Meanwhile, thread B is doing a
flush_scheduled_work in order to wait for pending linkwatch events to
complete. =20

In the proposed solution this will result in incorrect behaviour
(flush_scheduled_work returns with the linkwatch work not really done).=20
(Admittedly I'm not sure if such a scenario really is feasible.)

My initial though was to use a seperate work-queue, un-entangled with
the global queue used for flush_scheduled_work.  This would allow
linkwatch events to be synchronized against explicitly.  For this
solution though I think it would be nice to not have to have a thread
per cpu for the linkwatch work queue.

On the other hand, ic_open_devs appears to be the only place where
rtnl_sem is held while going into a driver's open() function, and so
maybe the right rule is that rtnl_sem is not held when calling
dev->open().


--=20
Michal Ostrowski <mostrows@watson.ibm.com>


On Mon, 2004-01-05 at 09:50, Stefan Rompf wrote:
> Am Montag, 05. Januar 2004 14:07 schrieb Michal Ostrowski:
>=20
> > ic_open_devs grabs rtnl_sem with an rtnl_shlock() call.
> >
> > The sungem driver at some point calls gem_init_one, which calls
> > netif_carrier_*, which in turn calls schedule_work (linkwatch_event).
> >
> > linkwatch_event in turn needs rtnl_sem.
>=20
> Good catch! The sungem driver shows clearly that we need some way to remo=
ve=20
> queued work without scheduling and waiting for other events.
>=20
> I will change the linkwatch code to use rtnl_shlock_nowait() and backoff =
and=20
> retry in case of failure this week. Call it a workaround, but it increase=
s=20
> overall system stability.
>=20
> Btw, what is the planned difference between rtnl_shlock() and rtnl_exlock=
()?=20
> Even though the later is a null operation right now, I don't want to hold=
=20
> more locks than needed in the linkwatch code.
>=20
> Stefan

>=20

--=-T7Vi+m2S37xHNyQWLC01
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQA/+Y6MDMDCqU5zPMARAhzgAKCYfZQv5KwkiFbAsdhEoMaLk4ZgkwCdEclN
kHFuP/wl7cmOAbijpPORTco=
=+eos
-----END PGP SIGNATURE-----

--=-T7Vi+m2S37xHNyQWLC01--
