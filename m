From: Jens Rosenboom <me@jayr.de>
Subject: Re: PATCH: ipv6: avoid wraparound for expired lifetimes
Date: Thu, 25 Jun 2009 11:06:03 +0200
Message-ID: <20090625090603.GP21357@jayr.de>
References: <20090625073943.GO21357@jayr.de> <Pine.LNX.4.64.0906251135410.917@melkinkari.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jens Rosenboom <me@jayr.de>, Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout0.freenet.de ([195.4.92.90]:34201 "EHLO mout0.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752286AbZFYJGU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2009 05:06:20 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0906251135410.917@melkinkari.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 25, 2009 at 11:40:19AM +0300, Ilpo J=E4rvinen wrote:
> On Thu, 25 Jun 2009, Jens Rosenboom wrote:
>=20
> > If the valid or preferred lifetime for an address expires, the kern=
el
> > shows huge values for these due to a counter wrap,
>=20
> I suspect we have plenty of potentially counter-wrapped printouts all=
=20
> around the kernel. So you're fixing just a tip of the iceberg.

So are you implying that because I don't fix all of them at once, I
shouldn't bother to start at all?

On Thu, 2009-06-25 at 01:42 -0700, David Miller wrote:
=2E..
> Jens, don't even bother posting patches that fail to
> build.

Sorry for that, here is the correct version.

--- linux-2.6.30.orig/net/ipv6/addrconf.c	2009-06-10 05:05:27.000000000=
 +0200
+++ linux-2.6.30/net/ipv6/addrconf.c	2009-06-25 10:52:27.000000000 +020=
0
@@ -3361,9 +3361,18 @@
 		valid =3D ifa->valid_lft;
 		if (preferred !=3D INFINITY_LIFE_TIME) {
 			long tval =3D (jiffies - ifa->tstamp)/HZ;
-			preferred -=3D tval;
-			if (valid !=3D INFINITY_LIFE_TIME)
-				valid -=3D tval;
+			if (preferred > tval) {
+				preferred -=3D tval;
+			} else {
+				preferred =3D 0;
+			}
+			if (valid !=3D INFINITY_LIFE_TIME) {
+				if (valid > tval) {
+					valid -=3D tval;
+				} else {
+					valid =3D 0;
+				}
+			}
 		}
 	} else {
 		preferred =3D INFINITY_LIFE_TIME;

And to show you where this appears:

Output with plain 2.6.30

# ip -6 addr show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2001:db8::202:a5ff:fee8:20be/64 scope global dynamic=20
       valid_lft 870sec preferred_lft 7sec
    inet6 fe80::202:a5ff:fee8:20be/64 scope link=20
       valid_lft forever preferred_lft forever
# sleep 30
# ip -6 addr show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2001:db8::202:a5ff:fee8:20be/64 scope global deprecated dynam=
ic=20
       valid_lft 840sec preferred_lft 4294967266sec
    inet6 fe80::202:a5ff:fee8:20be/64 scope link=20
       valid_lft forever preferred_lft forever

Output with patched 2.6.30

# ip -6 addr show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2001:db8::202:a5ff:fee8:12e1/64 scope global dynamic=20
       valid_lft 897sec preferred_lft 27sec
    inet6 fe80::202:a5ff:fee8:12e1/64 scope link=20
       valid_lft forever preferred_lft forever
# sleep 30
# ip -6 addr show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2001:db8::202:a5ff:fee8:12e1/64 scope global deprecated dynam=
ic=20
       valid_lft 862sec preferred_lft 0sec
    inet6 fe80::202:a5ff:fee8:12e1/64 scope link=20
       valid_lft forever preferred_lft forever

