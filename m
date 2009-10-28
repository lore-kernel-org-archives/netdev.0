From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Fwd: Re: [PATCH] Multicast packet reassembly can fail]
Date: Wed, 28 Oct 2009 18:26:37 +0100
Message-ID: <4AE87ECD.7080408@gmail.com>
References: <1256740748.3153.418.camel@linux-1lbu>	 <4AE86420.3040607@gmail.com> <1256749559.3153.447.camel@linux-1lbu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Steve Chen <schen@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37230 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753287AbZJ1Rco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 13:32:44 -0400
In-Reply-To: <1256749559.3153.447.camel@linux-1lbu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Chen a =C3=A9crit :
> On Wed, 2009-10-28 at 16:32 +0100, Eric Dumazet wrote:
>> If each fragment is received twice on host, once by eth0, once by et=
h1,
>> should we deliver datagram once or twice ?
>=20
> The application received it once.  IIRC the duplicate packet is drop =
in
> the routing code.
>=20
>> Once should be enough, even if in the non fragmented case, it will
>> be delivered twice (kernel cannot detect duplicates, user app might =
do itself)
>=20
> Routing code drops the duplicate packet for none-fragmented case as
> well.

Really ? How so ? Receiving two copies of the same packet is legal.

>=20
>>
>>> For this specific case, src/dst address, protocol, IP ID and fragme=
nt
>>> offset are all identical.  The only difference is the ingress inter=
face.
>>> A good follow up question would be why would anyone in their right =
mind
>>> multicast to the same destination?  well, I don't know.  I can not =
get
>>> the people who reported the problem to tell me either.   Since some=
one
>>> found the need to do this,  perhaps others may find it useful too.
>>>
>> Then, if a 2000 bytes message is fragmented in two packets, one comi=
ng
>> from eth0, one coming from eth1, I suspect your patch drops the mess=
age,
>> unless eth0/eth1 are part of a bonding device...
>=20
> Actually, the patch tries to prevent packet drop for this exact
> scenario.  Please consider the following scenarios
> 1.  Packet comes in the fragment reassemble code in the following ord=
er
> (eth0 frag1), (eth0 frag2), (eth1 frag1), (eth1 frag2)
> Packet from both interfaces get reassembled and gets further processe=
d.

Yes your patch does this, so each multicast application receives two co=
pies of the
same datagram.

>=20
> 2. Packet can some times arrive in (perhaps other orders as well)
> (eth0 frag1), (eth1 frag1), (eth0 frag2), (eth1 frag2)
> Without this patch, eth0 frag 1/2 are overwritten by eth1 frag1/2, an=
d
> packet from eth1 is dropped in the routing code.

Really ? how so ? I dont see how it can happen, unless you use RPF ?

current situation should be :

(eth0 frag1) : We create a context, store frag1 in it
(eth1 frag1) : We find this context, and drop frag1 since we already ha=
ve the data
                  (maybe the bug is here, if we cannot cope with a dupl=
icate ?)
(eth0 frag2) : We find this context, store frag2 -> complete datagram a=
nd deliver it
(eth1 frag2) : We find context, drop frag2 since datagram was completed=
=2E

               (or maybe we create a new context that will timeout late=
r, maybe this is your problem ?)

Net effect : We deliver the datagram correctly.


>=20
>> That would break common routing setups, using two links to aggregate=
 bandwidth ?
>=20
> I don't believe it would.  The aggregate bandwidth will work the same=
 as
> before.  The attributes (src/dst addr, protocol, interface, etc.) sho=
uld
> generate a unique hash key.  If hash collision should happen with the
> addition of iif << 5, the code still compare the original src addr al=
ong
> with interface number, so there should be no issues.

What about the obvious :

(eth0 frag1),  (eth1 frag2)

Your patch creates two contexts since hashes are different,
that will timeout and no packet delivered at all

