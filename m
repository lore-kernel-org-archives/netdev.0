From: Steve Chen <schen@mvista.com>
Subject: Re: [Fwd: Re: [PATCH] Multicast packet reassembly can fail]
Date: Wed, 28 Oct 2009 13:25:39 -0500
Message-ID: <1256754339.3153.481.camel@linux-1lbu>
References: <1256740748.3153.418.camel@linux-1lbu>
	 <4AE86420.3040607@gmail.com> <1256749559.3153.447.camel@linux-1lbu>
	 <4AE87ECD.7080408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mhuth@mvista.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu47.mvista.com ([206.112.117.47]:56257 "HELO
	gateway-1237.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S1753221AbZJ1SR4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2009 14:17:56 -0400
In-Reply-To: <4AE87ECD.7080408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-10-28 at 18:26 +0100, Eric Dumazet wrote:
> Steve Chen a =C3=A9crit :
> > On Wed, 2009-10-28 at 16:32 +0100, Eric Dumazet wrote:
> >> If each fragment is received twice on host, once by eth0, once by =
eth1,
> >> should we deliver datagram once or twice ?
> >=20
> > The application received it once.  IIRC the duplicate packet is dro=
p in
> > the routing code.
> >=20
> >> Once should be enough, even if in the non fragmented case, it will
> >> be delivered twice (kernel cannot detect duplicates, user app migh=
t do itself)
> >=20
> > Routing code drops the duplicate packet for none-fragmented case as
> > well.
>=20
> Really ? How so ? Receiving two copies of the same packet is legal.

I will have to double check exactly where the packet drop happens.  I
thought it was somewhere in routing, but it could be in netfilter.

>=20
> >=20
> >>
> >>> For this specific case, src/dst address, protocol, IP ID and frag=
ment
> >>> offset are all identical.  The only difference is the ingress int=
erface.
> >>> A good follow up question would be why would anyone in their righ=
t mind
> >>> multicast to the same destination?  well, I don't know.  I can no=
t get
> >>> the people who reported the problem to tell me either.   Since so=
meone
> >>> found the need to do this,  perhaps others may find it useful too=
=2E
> >>>
> >> Then, if a 2000 bytes message is fragmented in two packets, one co=
ming
> >> from eth0, one coming from eth1, I suspect your patch drops the me=
ssage,
> >> unless eth0/eth1 are part of a bonding device...
> >=20
> > Actually, the patch tries to prevent packet drop for this exact
> > scenario.  Please consider the following scenarios
> > 1.  Packet comes in the fragment reassemble code in the following o=
rder
> > (eth0 frag1), (eth0 frag2), (eth1 frag1), (eth1 frag2)
> > Packet from both interfaces get reassembled and gets further proces=
sed.
>=20
> Yes your patch does this, so each multicast application receives two =
copies of the
> same datagram.
>=20
> >=20
> > 2. Packet can some times arrive in (perhaps other orders as well)
> > (eth0 frag1), (eth1 frag1), (eth0 frag2), (eth1 frag2)
> > Without this patch, eth0 frag 1/2 are overwritten by eth1 frag1/2, =
and
> > packet from eth1 is dropped in the routing code.
>=20
> Really ? how so ? I dont see how it can happen, unless you use RPF ?
>=20
> current situation should be :
>=20
> (eth0 frag1) : We create a context, store frag1 in it
> (eth1 frag1) : We find this context, and drop frag1 since we already =
have the data
>                   (maybe the bug is here, if we cannot cope with a du=
plicate ?)
> (eth0 frag2) : We find this context, store frag2 -> complete datagram=
 and deliver it
> (eth1 frag2) : We find context, drop frag2 since datagram was complet=
ed.

Yes, this is exactly what is happening in the current code.

>=20
>                (or maybe we create a new context that will timeout la=
ter, maybe this is your problem ?)
>=20
> Net effect : We deliver the datagram correctly.
>=20
>=20
> >=20
> >> That would break common routing setups, using two links to aggrega=
te bandwidth ?
> >=20
> > I don't believe it would.  The aggregate bandwidth will work the sa=
me as
> > before.  The attributes (src/dst addr, protocol, interface, etc.) s=
hould
> > generate a unique hash key.  If hash collision should happen with t=
he
> > addition of iif << 5, the code still compare the original src addr =
along
> > with interface number, so there should be no issues.
>=20
> What about the obvious :
>=20
> (eth0 frag1),  (eth1 frag2)
>=20
> Your patch creates two contexts since hashes are different,
> that will timeout and no packet delivered at all
>=20
I see the point you are making.  I assumed, probably incorrectly, that
since eth0 and eth1 have different IP address.  I would get a complete
series of fragments for each interface.  Perhaps, I should really be
looking up the stack to see why packets were dropped.  Please correct m=
e
if I'm mistaken.  The normal behavior is that application should be
receiving either 2 (scenario 1) or 1 (scenario 2) packets.

Regards,

Steve

