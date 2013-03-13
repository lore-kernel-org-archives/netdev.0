From: Tom Parkin <tparkin@katalix.com>
Subject: Re: [RFC PATCH] udp: don't rereference dst_entry dev pointer on rcv
Date: Wed, 13 Mar 2013 23:27:43 +0000
Message-ID: <20130313232743.GA3686@raven>
References: <1362695800-8633-1-git-send-email-tparkin@katalix.com>
 <1362695800-8633-2-git-send-email-tparkin@katalix.com>
 <1362696444.15793.220.camel@edumazet-glaptop>
 <20130307.181527.390191009324148471.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FL5UXtIhxfXey3p5"
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:35920 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755615Ab3CMX1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Mar 2013 19:27:47 -0400
Content-Disposition: inline
In-Reply-To: <20130307.181527.390191009324148471.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--FL5UXtIhxfXey3p5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 07, 2013 at 06:15:27PM -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 07 Mar 2013 14:47:24 -0800
>=20
> > On Thu, 2013-03-07 at 22:36 +0000, Tom Parkin wrote:
> >> When a fragmented IP packet is queued during device teardown, it is po=
ssible
> >> for the reassembled packet to hit the UDP rcv path with a NULL dst_ent=
ry dev
> >> pointer.  Drop such packets to prevent an oops.
> >> ---
> >>  net/ipv4/udp.c |    3 +++
> >>  1 file changed, 3 insertions(+)
> >>=20
> >> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> >> index 0a073a2..c38a4b1 100644
> >> --- a/net/ipv4/udp.c
> >> +++ b/net/ipv4/udp.c
> >> @@ -1700,6 +1700,9 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct u=
dp_table *udptable,
> >>  		return __udp4_lib_mcast_deliver(net, skb, uh,
> >>  				saddr, daddr, udptable);
> >> =20
> >> +	if (skb_dst(skb)->dev =3D=3D NULL)
> >> +		goto drop;
> >> +
> >>  	sk =3D __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
> >> =20
> >>  	if (sk !=3D NULL) {
> >=20
> >=20
> > Hmm... couldnt it be tested in reassembly layer instead ?
> >=20
> > Why is it specific to UDP ?
>=20
> Furthermore, when devices are unregistered we set the route's device
> pointer to point to the loopback device, not NULL, exactly to avoid
> this kind of problem.
>=20
> I don't see anything in our generic DST handler nor the ipv4 specific
> route handling, that would set dst->dev to NULL.
>=20
> You really have to show us how this can actually happen.

I've been working to this end, and while I don't have a root cause as
yet, I do have some more information.

I think what's happening is that the dst_entry refcounting is getting
screwed up either by the ip defrag code, or by something before that
in the rcv path.  What I see from ftrace debugging is that an skb
fragment ends up queued on the reassembly queue while pointing to a
dst_entry with a refcount of 0.  If the dst_entry should be deleted before
the final fragment in the frame arrives, then we end up accessing
free'd memory.

So far as I can make out, the l2tp code isn't doing anything untoward
which is causing this bug.  My stress test simply makes it easier to
reproduce because I'm setting up and tearing down routes and devices
a lot while passing data.  I'm lucky in that my dev branch seems to
reproduce this more easily than net-next master does, although the
same oops occurs on master if you're prepared to wait around for long
enough.

This ftrace debug log snippet shows the sort of behaviour I'm seeing.
The numbers in brackets after some dst pointer values represent the
refcount for that dst:

# The dst_entry is created with a refcount of 1
  <idle>-0     [000] ..s2   112.770192: dst_alloc: dst ffff880012bbb0c0, re=
fcnt 1
# First fragment is queued
  <idle>-0     [000] ..s2   112.770193: ip_local_deliver: skb ffff880012864=
600, dst ffff880012bbb0c0(1) : is fragment
  <idle>-0     [000] ..s2   112.770206: ip_local_deliver: skb ffff880012864=
600, dst ffff880012bbb0c0 : fragment queued
# Second and final fragment arrives, reassemble
      ip-10970 [000] ..s1   112.770678: ip_local_deliver: skb ffff880010937=
e00, dst ffff880012bbb0c0(1) : is fragment
# skb_morph bumps refcount to 2, skb_consume drops it back down to 1
      ip-10970 [000] ..s2   112.770682: ip_defrag: >>> clone skb ffff880010=
937e00 with dst ffff880012bbb0c0
      ip-10970 [000] ..s2   112.770691: __copy_skb_header: don't dst_clone =
ffff880012bbb0c0
      ip-10970 [000] ..s2   112.770691: ip_defrag: >>> morph skb ffff880010=
937e00 from ffff880012864600
      ip-10970 [000] ..s2   112.770692: skb_release_head_state: drop skb ff=
ff880010937e00 dst ref
      ip-10970 [000] ..s2   112.770692: __copy_skb_header: cloning dst ffff=
880012bbb0c0 (skb ffff880012864600 -> skb ffff880010937e00)
      ip-10970 [000] ..s2   112.770692: ip_defrag: >>> consume skb ffff8800=
12864600
      ip-10970 [000] ..s2   112.770693: skb_release_head_state: drop skb ff=
ff880012864600 dst ref
      ip-10970 [000] ..s2   112.770693: dst_release: dst ffff880012bbb0c0 n=
ewrefcnt 1
      ip-10970 [000] ..s2   112.770698: ip_defrag: >>> coalesce loop
      ip-10970 [000] ..s2   112.770698: ip_defrag: kfree_skb_partial(ffff88=
0010937500, false)
      ip-10970 [000] ..s2   112.770699: skb_release_head_state: drop skb ff=
ff880010937500 dst ref
# skb is reassembled and delivered, dst has refcount of 1 now
      ip-10970 [000] ..s1   112.770705: ip_local_deliver: skb ffff880010937=
e00, dst ffff880012bbb0c0(1) : queue defragmented
# l2tp_eth uses dev_forward_skb, which calls skb_dst_drop
      ip-10970 [000] ..s1   112.770707: skb_release_head_state: drop skb ff=
ff880010937e00 dst ref
      ip-10970 [000] ..s1   112.770708: dst_release: dst ffff880012bbb0c0 n=
ewrefcnt 0
# Another skb arrives; dst refcount remains at 0
  <idle>-0     [000] ..s2   112.771481: ip_local_deliver: skb ffff880012864=
500, dst ffff880012bbb0c0(0) : is fragment
  <idle>-0     [000] ..s2   112.771494: ip_local_deliver: skb ffff880012864=
500, dst ffff880012bbb0c0 : fragment queued

The strange thing is that once the dst refcount reaches zero, another
skb hitting ip_input doesn't bump the refcount back up.  This is
partially why I'm not sure whether the error is caused by the defrag
code, or by something prior to that in the rcv path.
--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--FL5UXtIhxfXey3p5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJRQQtvAAoJEJSMBmUKuovQHEIIAMNT1wxLJXpModrk9PLHLHb0
yoyWYae1o+2hm7e6EwmRiDIt9vRvotl0x00V9CzzMXdAg6j1DZmFR0YUIwhEFfmX
QU3kLMZPY5ah01W7QxluHHpWulyilyZKSnFtk1IQY5QfcDfrXIMk2i1SEH3m0bN2
eIBV5CxVS7YD6+yYf+5guNAYowGUfBGaOFTIakEA7ZRku+PcKSwxYyHAK6A//w94
hvAFwqkti+AJkDSChhqEPTzQif0yyFEB9Q/Iu/Z6wL2721eqcCg8cCD5o3Ovr7Nr
KlI4NekhN1lZ31mfSG+98DFtJ6N0uResZ9+l/8uysSoI5Xuwd31T+sTnE1XtdiE=
=pSok
-----END PGP SIGNATURE-----

--FL5UXtIhxfXey3p5--
