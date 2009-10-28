From: Steve Chen <schen@mvista.com>
Subject: Re: [Fwd: Re: [PATCH] Multicast packet reassembly can fail]
Date: Wed, 28 Oct 2009 12:05:58 -0500
Message-ID: <1256749559.3153.447.camel@linux-1lbu>
References: <1256740748.3153.418.camel@linux-1lbu>
	 <4AE86420.3040607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu47.mvista.com ([206.112.117.47]:49137 "HELO
	gateway-1237.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S1754398AbZJ1RBi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2009 13:01:38 -0400
In-Reply-To: <4AE86420.3040607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-10-28 at 16:32 +0100, Eric Dumazet wrote:
> Steve Chen a =C3=A9crit :
> > Following is the e-mail I replied to Rick Jones in case you haven't=
 got
> > it yet.  I have not posted the test code yet.  The test code is a t=
ar gz
> > file about 11k in size.  Lot of people will get very upset if I sen=
d it
> > to the mailing list.  If you can suggest a place to up load, I'll b=
e
> > happy to do so.
> >=20
> > Regards,
>=20
> > Here is the scenario this patch tries to address
> >=20
> > <src node> ---->  <switch>  ----> <eth0 dest node>
> >                             \--->  <eth1 dest node>
>=20
> If each fragment is received twice on host, once by eth0, once by eth=
1,
> should we deliver datagram once or twice ?

The application received it once.  IIRC the duplicate packet is drop in
the routing code.

>=20
> Once should be enough, even if in the non fragmented case, it will
> be delivered twice (kernel cannot detect duplicates, user app might d=
o itself)

Routing code drops the duplicate packet for none-fragmented case as
well.

>=20
>=20
> >=20
> > For this specific case, src/dst address, protocol, IP ID and fragme=
nt
> > offset are all identical.  The only difference is the ingress inter=
face.
> > A good follow up question would be why would anyone in their right =
mind
> > multicast to the same destination?  well, I don't know.  I can not =
get
> > the people who reported the problem to tell me either.   Since some=
one
> > found the need to do this,  perhaps others may find it useful too.
> >=20
>=20
> Then, if a 2000 bytes message is fragmented in two packets, one comin=
g
> from eth0, one coming from eth1, I suspect your patch drops the messa=
ge,
> unless eth0/eth1 are part of a bonding device...

Actually, the patch tries to prevent packet drop for this exact
scenario.  Please consider the following scenarios
1.  Packet comes in the fragment reassemble code in the following order
(eth0 frag1), (eth0 frag2), (eth1 frag1), (eth1 frag2)
Packet from both interfaces get reassembled and gets further processed.

2. Packet can some times arrive in (perhaps other orders as well)
(eth0 frag1), (eth1 frag1), (eth0 frag2), (eth1 frag2)
Without this patch, eth0 frag 1/2 are overwritten by eth1 frag1/2, and
packet from eth1 is dropped in the routing code.

>=20
> That would break common routing setups, using two links to aggregate =
bandwidth ?

I don't believe it would.  The aggregate bandwidth will work the same a=
s
before.  The attributes (src/dst addr, protocol, interface, etc.) shoul=
d
generate a unique hash key.  If hash collision should happen with the
addition of iif << 5, the code still compare the original src addr alon=
g
with interface number, so there should be no issues.

> Nothing in IP forces all packets of a datagram to follow an unique ro=
ute.
>=20
My understanding as well.

Regards,

Steve

