From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: Re: [PATCH 4 of 5] IPv6: fix lifetime calculation on temporary
	address creation
Date: Wed, 2 Apr 2008 02:17:06 +0200
Message-ID: <20080402001706.GD32592@pirzuine>
References: <ec551b4a5bb25cda00ff.1206305172@pirzuine> <20080328.120401.89511262.yoshfuji@linux-ipv6.org> <20080401215657.GP475@pirzuine> <20080402.084114.60517414.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, pekkas@netcore.fi
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pilet.ens-lyon.fr ([140.77.167.16]:52673 "EHLO
	pilet.ens-lyon.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869AbYDBARK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 20:17:10 -0400
Content-Disposition: inline
In-Reply-To: <20080402.084114.60517414.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 02, 2008 at 08:41:14AM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20080401215657.GP475@pirzuine> (at Tue, 1 Apr 2008 23:56:=
57 +0200), Benoit Boissinot <benoit.boissinot@ens-lyon.org> says:
>=20
> > On Fri, Mar 28, 2008 at 12:04:01PM +0900, YOSHIFUJI Hideaki / =E5=90=
=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> > > In article <ec551b4a5bb25cda00ff.1206305172@pirzuine> (at Sun, 23=
 Mar 2008 21:46:12 +0100), Benoit Boissinot <benoit.boissinot@ens-lyon.=
org> says:
> > >=20
> > > > IPv6: fix lifetime calculation on temporary address creation
> > [snip]
> > > > +	now =3D jiffies;
> > > > +	elapsed =3D (now - ifp->tstamp) / HZ;
> > > > +	if (elapsed >=3D ifp->valid_lft)
> > > > +		tmp_valid_lft =3D 0;
> > > > +	else
> > > > +		tmp_valid_lft =3D min_t(__u32,
> > > > +				      ifp->valid_lft - elapsed,
> > > > +				      idev->cnf.temp_valid_lft);
> > > > +	if (elapsed >=3D ifp->prefered_lft)
> > > > +		tmp_prefered_lft =3D 0;
> > > > +	else
> > > > +		tmp_prefered_lft =3D min_t(__u32,
> > > > +					 ifp->prefered_lft - elapsed,
> > > > +					 idev->cnf.temp_prefered_lft - desync_factor / HZ);
> > >=20
> > > Basically I agree, but it is possible to expire the temporary
> > > address AFTER public address, which is not good.  Please fix this=
=2E
> >=20
> > do you mean because of the rounding of 'elapsed' ? otherwise I don'=
t see
> > what the problem is, sorry.
>=20
> Right.  Maybe we could substruct "now" by adj =3D (now - ifp->tstamp)=
 % HZ;
>    now =3D jiffies
>    elapsed =3D (now - ifp->tstamp) / HZ;
>    now -=3D (now - ifp->tstamp) % HZ;

Why not just simply round it above:
elapsed =3D (now - ifp->tstamp + HZ - 1) / HZ; /* round it up */
and the rest stays the same.

Or do we care about having a lifetime a little bit (<1s) shorter ?

updated patch below:

IPv6: fix lifetime calculation on temporary address creation

The lifetime calculation was buggy since it copied the tstamp
from the associated public address.
If (now - ifp->prefered_lft)/HZ (ie the elapsed time since the
timestamp was set in the public address) was greater than
temp_prefered_lft, you would always get deprecated addresses.

This patch corrects the lifetime calculation by setting the tstamp
to "now" and calculating the remaining time from the public address.

Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>

diff -r 00affc24c178 net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	Sat Mar 22 00:39:16 2008 +0100
+++ b/net/ipv6/addrconf.c	Wed Apr 02 02:14:13 2008 +0200
@@ -775,8 +775,7 @@
 {
 	struct inet6_dev *idev =3D ifp->idev;
 	struct in6_addr addr, *tmpaddr;
-	unsigned long tmp_prefered_lft, tmp_valid_lft, tmp_cstamp, tmp_tstamp=
;
-	unsigned long regen_advance;
+	unsigned long tmp_prefered_lft, tmp_valid_lft, elapsed, regen_advance=
;
 	int tmp_plen;
 	int ret =3D 0;
 	int max_addresses;
@@ -825,16 +824,21 @@
 		goto out;
 	}
 	memcpy(&addr.s6_addr[8], idev->rndid, 8);
-	tmp_valid_lft =3D min_t(__u32,
-			      ifp->valid_lft,
-			      idev->cnf.temp_valid_lft);
-	tmp_prefered_lft =3D min_t(__u32,
-				 ifp->prefered_lft,
-				 idev->cnf.temp_prefered_lft - desync_factor / HZ);
+	elapsed =3D (jiffies - ifp->tstamp + HZ - 1) / HZ; /* round above */
+	if (elapsed >=3D ifp->valid_lft)
+		tmp_valid_lft =3D 0;
+	else
+		tmp_valid_lft =3D min_t(__u32,
+				      ifp->valid_lft - elapsed,
+				      idev->cnf.temp_valid_lft);
+	if (elapsed >=3D ifp->prefered_lft)
+		tmp_prefered_lft =3D 0;
+	else
+		tmp_prefered_lft =3D min_t(__u32,
+					 ifp->prefered_lft - elapsed,
+					 idev->cnf.temp_prefered_lft - desync_factor / HZ);
 	tmp_plen =3D ifp->prefix_len;
 	max_addresses =3D idev->cnf.max_addresses;
-	tmp_cstamp =3D ifp->cstamp;
-	tmp_tstamp =3D ifp->tstamp;
 	spin_unlock_bh(&ifp->lock);
=20
 	regen_advance =3D idev->cnf.regen_max_retry *
@@ -878,8 +882,6 @@
 	ift->ifpub =3D ifp;
 	ift->valid_lft =3D tmp_valid_lft;
 	ift->prefered_lft =3D tmp_prefered_lft;
-	ift->cstamp =3D tmp_cstamp;
-	ift->tstamp =3D tmp_tstamp;
 	spin_unlock_bh(&ift->lock);
=20
 	addrconf_dad_start(ift, 0);

--=20
:wq
