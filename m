From: Harald Welte <laforge@netfilter.org>
Subject: [HELP] netfilter Kconfig dependency nightmare
Date: Sat, 17 Sep 2005 10:07:14 +0200
Message-ID: <20050917080714.GV8413@sunbeam.de.gnumonks.org>
References: <20050916021451.3012196c.akpm@osdl.org>
	<20050916191959.GN8413@sunbeam.de.gnumonks.org>
	<39e6f6c705091617514457eded@mail.gmail.com>
	<20050917012315.GA29841@mandriva.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wnJX2LVqXtdJquW1"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Content-Disposition: inline
In-Reply-To: <20050917012315.GA29841@mandriva.com>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--wnJX2LVqXtdJquW1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 16, 2005 at 10:23:15PM -0300, Arnaldo Carvalho de Melo wrote:
> After applying this patch I still get a loop:
>=20
> [acme@toy net-2.6]$ make O=3DOUTPUT/oops/ oldconfig | grep Warning
> Warning! Found recursive dependency: IP_NF_CONNTRACK_NETLINK NETFILTER_NE=
TLINK IP_NF_CONNTRACK_NETLINK
> Warning! Found recursive dependency: NETFILTER_NETLINK IP_NF_CONNTRACK_NE=
TLINK NETFILTER_NETLINK NETFILTER_NETLINK_QUEUE
>=20
> This is using latest Dave tree, the one just before master.kernel.org
> was switched off for moving to Oregon, is there any other patch I should
> apply?

This f!*#$%!#$%ing kconfig dependency is killing me.   We have this
incredible inter-dependency between various options, and with every new
feature it's getting more complex.  The main reason being to avoid some
bits of dead code in case it's not really needed by some other module.

I'm starting to wonder whether it's really worth saving those few bytes
in some configurations at the expense of this complexity.

Maybe some Kconfig freak can help out. This is the intended dependency
rules:

ip_conntrack =3D=3D CONFIG_IP_NF_CONNTRACK
nfnetlink =3D=3D CONFIG_NETFILTER_NETLINK
ip_conntrack_netlink =3D=3D CONFIG_IP_NF_CONNTRACK_NETLINK

If nfnetlink =3D=3D N, ip_conntrack can be N or M or Y
If nfnetlink =3D=3D M, ip_conntrack can be N or M
If nfnetlink =3D=3D Y, ip_conntrack can be Y or M

If ip_conntrack =3D=3D N && nfnetlink =3D=3D N, ip_conntrack_netlink must b=
e N
If ip_conntrack =3D=3D N && nfnetlink =3D=3D M, ip_conntrack_netlink must b=
e N
If ip_conntrack =3D=3D N && nfnetlink =3D=3D Y, ip_conntrack_netlink must b=
e N

If ip_conntrack =3D=3D M && nfnetlink =3D=3D N, ip_conntrack_netlink must b=
e N=20
If ip_conntrack =3D=3D M && nfnetlink =3D=3D M, ip_conntrack_netlink can N =
or M
If ip_conntrack =3D=3D M && nfnetlink =3D=3D Y, ip_conntrack_netlink can N =
or M

if ip_conntrack =3D=3D Y && nfnetlink =3D=3D N, ip_conntrack_netlink must b=
e N
if ip_conntrack =3D=3D Y && nfnetlink =3D=3D M, ip_conntrack_netlink can N =
or M
if ip_conntrack =3D=3D Y && nfnetlink =3D=3D Y, ip_conntrack_netlink can N,=
 M or Y

NETfILTER_NETLINK_QUEUE and NETFILTER_NETLINK_LOG only depend on
NETFILER_NETLINK and nothing else.

Cheers,

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--wnJX2LVqXtdJquW1
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDK86yXaXGVTD0i/8RAsVxAJ4tQPUzHPaqYb96g59ZK7JfRj3cVACfeBMo
GYJthiZqOiuSXbGs2ErQq6U=
=FI3a
-----END PGP SIGNATURE-----

--wnJX2LVqXtdJquW1--
