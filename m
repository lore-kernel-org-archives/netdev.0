From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: [PATCH] Re: [2.6.0, pktgen] divide-by-zero
Date: Sun, 18 Jan 2004 16:48:02 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040118154802.GE10397@wohnheim.fh-wedel.de>
References: <20031231111316.GA10218@gnu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@gnu.org>
Content-Disposition: inline
In-Reply-To: <20031231111316.GA10218@gnu.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 31 December 2003 06:13:16 -0500, Lennert Buytenhek wrote:
>=20
> When generating packets with pktgen with count=3D10, I get a divide-by-=
zero
> oops in inject().
>=20
> Line 273 in net/core/pktgen.c seems unsafe:
> 	__u64 pps =3D (__u32)(info->sofar * 1000) / ((__u32)(total) / 1000);
>=20
> What if total < 1000 ?

Since noone else seemed to care, try this patch.  Against -test11,
yeah, I'm lazy again.

J=F6rn

--=20
Time? What's that? Time is only worth what you do with it.
-- Theo de Raadt

--- old/net/core/pktgen.c	2003-11-26 21:44:47.000000000 +0100
+++ new/net/core/pktgen.c	2004-01-18 16:27:10.000000000 +0100
@@ -720,7 +720,9 @@
=20
 	{
 		char *p =3D info->result;
-		__u64 pps =3D (__u32)(info->sofar * 1000) / ((__u32)(total) / 1000);
+		__u32 safe_total =3D (__u32)(total) / 1000;
+		safe_total +=3D 1 - (!!safe_total); /* avoid divide-by-zero */
+		__u64 pps =3D (__u32)(info->sofar * 1000) / safe_total;
 		__u64 bps =3D pps * 8 * (info->pkt_size + 4); /* take 32bit ethernet C=
RC into account */
 		p +=3D sprintf(p, "OK: %llu(c%llu+d%llu) usec, %llu (%dbyte,%dfrags) %=
llupps %lluMb/sec (%llubps)  errors: %llu",
 			     (unsigned long long) total,
