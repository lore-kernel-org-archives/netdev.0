From: Michal Ostrowski <mostrows@watson.ibm.com>
Subject: Deadlock in sungem/ip_auto_config/linkwatch
Date: Mon, 05 Jan 2004 08:07:58 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1073307882.2041.98320.camel@brick.watson.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-VstyQxFiTA9BMsLFyv50"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-VstyQxFiTA9BMsLFyv50
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

I believe I've found a potential deadlock condition.

It occurs when we make the following sequence of calls:

ip_auto_config
ic_open_devs
dev_change_flags
dev_open
gem_open
flush_scheduled_work

ic_open_devs grabs rtnl_sem with an rtnl_shlock() call.

The sungem driver at some point calls gem_init_one, which calls
netif_carrier_*, which in turn calls schedule_work (linkwatch_event).

linkwatch_event in turn needs rtnl_sem.

If we enter the call sequence above and linkwatch_event is still
pending, we will deadlock since flush_scheduled_work will wait for
completion of linkwatch_event, which is blocked since it cannot get
rtnl_sem.

In general when can one call flush_scheduled_work?  It seems that one
can't unless you know your callers aren't holding any locks.


--=20
Michal Ostrowski <mostrows@watson.ibm.com>

--=-VstyQxFiTA9BMsLFyv50
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQA/+WDqDMDCqU5zPMARAmTwAJ9ujgnF4BI4AVvkhSQ5YgJXBx+sXACfXT+z
rx8XL7PYFznObN8IXIZqAW8=
=HBFR
-----END PGP SIGNATURE-----

--=-VstyQxFiTA9BMsLFyv50--
