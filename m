From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH] Re: [2.6.0, pktgen] divide-by-zero
Date: Mon, 19 Jan 2004 00:15:41 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <16395.5021.616055.384516@robur.slu.se>
References: <20031231111316.GA10218@gnu.org>
	<20040118154802.GE10397@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lennert Buytenhek <buytenh@gnu.org>, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
In-Reply-To: <20040118154802.GE10397@wohnheim.fh-wedel.de>
List-Id: netdev.vger.kernel.org



Hello!

J=F6rn Engel writes:
 > On Wed, 31 December 2003 06:13:16 -0500, Lennert Buytenhek wrote:
 > >=20
 > > When generating packets with pktgen with count=3D10, I get a divid=
e-by-zero
 > > oops in inject().
 > >=20
 > > Line 273 in net/core/pktgen.c seems unsafe:
 > > 	__u64 pps =3D (__u32)(info->sofar * 1000) / ((__u32)(total) / 100=
0);
 > >=20
 > > What if total < 1000 ?
 >=20
 > Since noone else seemed to care, try this patch.  Against -test11,
 > yeah, I'm lazy again.


 Sorry I missed Lennerts original posting...=20

 I suggest the patch below to get integer precision at very short time=20
 intervals too.


--- linux-2.6.1/net/core/pktgen.c.orig	Sun Jan 18 21:56:56 2004
+++ linux-2.6.1/net/core/pktgen.c	Sun Jan 18 23:15:03 2004
@@ -88,7 +88,7 @@
 #define cycles()	((u32)get_cycles())
=20
=20
-#define VERSION "pktgen version 1.3"
+#define VERSION "pktgen version 1.31"
 static char version[] __initdata =3D=20
   "pktgen.c: v1.3: Packet Generator for packet performance testing.\n"=
;
=20
@@ -720,8 +720,18 @@
=20
 	{
 		char *p =3D info->result;
-		__u64 pps =3D (__u32)(info->sofar * 1000) / ((__u32)(total) / 1000);
-		__u64 bps =3D pps * 8 * (info->pkt_size + 4); /* take 32bit ethernet=
 CRC into account */
+		__u64 bps, pps =3D 0;
+
+		if (total > 1000)
+			pps =3D (__u32)(info->sofar * 1000) / ((__u32)(total) / 1000);
+		else if(total > 100)
+			pps =3D (__u32)(info->sofar * 10000) / ((__u32)(total) / 100);
+		else if(total > 10)
+			pps =3D (__u32)(info->sofar * 100000) / ((__u32)(total) / 10);
+		else if(total > 1)
+			pps =3D (__u32)(info->sofar * 1000000) / (__u32)total;
+
+		bps =3D pps * 8 * (info->pkt_size + 4); /* take 32bit ethernet CRC i=
nto account */
 		p +=3D sprintf(p, "OK: %llu(c%llu+d%llu) usec, %llu (%dbyte,%dfrags)=
 %llupps %lluMb/sec (%llubps)  errors: %llu",
 			     (unsigned long long) total,
 			     (unsigned long long) (total - idle),



Cheers.
						--ro
