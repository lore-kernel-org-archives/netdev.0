From: Harald Welte <laforge@gnumonks.org>
Subject: Re: "dst cache overflow"
Date: Tue, 21 Sep 2004 23:55:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921215501.GE3236@sunbeam.de.gnumonks.org>
References: <16719.13095.369830.547715@robur.slu.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="C1iGAkRnbeBonpVg"
Cc: cd@cdaniel.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <200409201907.43317.cd@cdaniel.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--C1iGAkRnbeBonpVg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 20, 2004 at 09:44:39PM +0200, Robert Olsson wrote:
> Hello!
>=20
>  size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot  =
   mc=20
> GC:tot ignore gmiss dstof HLS:in    out
> 10501       593     339     0     0     0     0     0       250      24  =
    0
>    362    360     2     0    229     48
>=20
>=20
> The number of packets that hits the route hash is about the same as the
> number of packets that misses it. (hit/tot)
>=20
> Either your route hash is so small in that case increase rhash_entries.=
=20
> Or you are receiving a DoS attack.

Neither is the case.  I have now logged into that box and did some
further analysis.  There definitely is a dst_entry leak somewhere in
the kernel.  the number of entries in ip_dst_cache slab is constantly
increasing, now just before rebooting the box it had approached about
65k.

At least when you manuall flush the cache, the number of allocated
ip_dst_entries from slab should decrease...

After the reboot (uptime 4 hours at this point):

according to /proc/slabinfo, there's 7530 entries allocated
If you cat /proc/net/rt_cache, you see about 1990 entries. =20
I've added a patch to export the number of dst_entries that are sitting
in the dst_garbage_list, it's 5549.  This value is increasing constantly
over time.  Coincidentially, if we subtract 7530-1990 we get almost
exactly this number.

I bet that something inside the kernel forgets dst_release().. IMQ is
just compiled, not used (so I don't see how it should come from this).

Any comments, suggestions?

If nothing else helps, I will add a seq_file interface to
dst_garbage_list and try to find some similarity betwen the stale
entries in order to get a clue about what's going on.

> 						--ro

btw: The system was runnign 2.4.x until about two weeks ago... with no
dst_cache problems.

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--C1iGAkRnbeBonpVg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBUKM1XaXGVTD0i/8RAl+JAJ9HjSeB1oEetTpk/E8oWeDUPRzt7gCfYPRI
ddwsY5RCQLDjf5pJsgg/gpA=
=FUUp
-----END PGP SIGNATURE-----

--C1iGAkRnbeBonpVg--
