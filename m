From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: [PATCH] iproute2: support dotted-quad netmask notation.
Date: Sun, 09 Dec 2007 18:10:22 +0100
Message-ID: <1197220222.4392.9.camel@localhost.localdomain>
References: <20071204135818.GA24419@scream.fatal.se>
	 <20071206115350.18e9204f@freepuppy.rosehill>
	 <1197070894.5385.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:42905 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbXLIRHj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2007 12:07:39 -0500
In-Reply-To: <1197070894.5385.14.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On l=C3=B6r, 2007-12-08 at 00:41 +0100, Andreas Henriksson wrote:
> On tor, 2007-12-06 at 11:53 -0800, Stephen Hemminger wrote:
> > On Tue, 4 Dec 2007 14:58:18 +0100
> > Andreas Henriksson <andreas@fatal.se> wrote:
> >=20
> > > Suggested patch for allowing netmask to be specified in dotted qu=
ad format.
> > > See http://bugs.debian.org/357172
> > >=20
> Updated patch, added your netmask validation code but without the che=
ck
> that made 0.0.0.0 (default) and 255.255.255.255 (one address) invalid
> netmasks as they are permitted in CIDR format.=20

I think both previous patches where broken on big-endian platforms.
Here's an updated patch again. I'm very sorry for the inconvenience!

Signed-off-by: Andreas Henriksson <andreas@fatal.se>


diff --git a/lib/utils.c b/lib/utils.c
index 4c42dfd..bb88cf7 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -47,6 +47,41 @@ int get_integer(int *val, const char *arg, int base)
 	return 0;
 }
=20
+/* a valid netmask must be 2^n - 1 (n =3D 1..31) */
+static int is_valid_netmask(const inet_prefix *addr)
+{
+        uint32_t host;
+
+        if (addr->family !=3D AF_INET)
+                return 0;
+
+        host =3D ~ntohl(addr->data[0]);
+
+        return (host & (host + 1)) =3D=3D 0;
+}
+
+static int get_netmask(unsigned *val, const char *arg, int base)
+{
+	inet_prefix addr;
+
+	if (!get_unsigned(val, arg, base))
+		return 0;
+
+	/* try coverting dotted quad to CIDR */
+	if (!get_addr_1(&addr, arg, AF_INET)) {
+		u_int32_t mask;
+
+		*val=3D0;
+		for (mask =3D ntohl(addr.data[0]); mask; mask <<=3D 1)
+			(*val)++;
+
+		if (is_valid_netmask(&addr))
+			return 0;
+	}
+
+	return -1;
+}
+
 int get_unsigned(unsigned *val, const char *arg, int base)
 {
 	unsigned long res;
@@ -304,7 +339,8 @@ int get_prefix_1(inet_prefix *dst, char *arg, int f=
amily)
 				dst->bitlen =3D 32;
 		}
 		if (slash) {
-			if (get_unsigned(&plen, slash+1, 0) || plen > dst->bitlen) {
+			if (get_netmask(&plen, slash+1, 0)
+					|| plen > dst->bitlen) {
 				err =3D -1;
 				goto done;
 			}




--=20
Regards,
Andreas Henriksson

