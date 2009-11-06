From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] [PATCH] udp: optimize lookup of UDP sockets to by including
 destination address in the hash key
Date: Fri, 06 Nov 2009 19:34:00 +0100
Message-ID: <4AF46C18.5030104@gmail.com>
References: <4AF1EC18.9090106@ixiacom.com> <200911050104.09538.opurdila@ixiacom.com> <4AF20F02.7000601@gmail.com> <200911051825.45749.opurdila@ixiacom.com> <4AF2FF22.2000805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54820 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755528AbZKFSd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 13:33:58 -0500
In-Reply-To: <4AF2FF22.2000805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Octavian Purdila a =E9crit :
>=20
>> IIRC, we first saw this issue in VoIP tests with up to 16000 sockets=
 bound on a=20
>> certain port and IP addresses (each IP address is assigned to a part=
icular=20
>> interface). We need this setup in order to emulate lots of VoIP user=
s each=20
>> with a different IP address and possible a different L2 encapsulatio=
n.
>=20
> Interesting case indeed, is it SIP 5060 port or RTP ports ?
> (I want to know how many messages per second you want to receive)
>=20
> An rbtree with 16000 elements has 15 levels, its a lot, but OK
> for small trafic.
>=20
>> Now, as a general note I should say that our usecases can seem absur=
d if you=20
>> take them out of the network testing field :) but my _personal_ opin=
ion is that=20
>> a better integration between our code base and upstream code may ben=
efit both=20
>> upstream and us:
>>
>> - for us it gives the ability to stay close to upstream and get all =
of the new=20
>> shiny features without painful upgrades
>>
>> - for upstream, even if most systems don't run into these scalabilit=
y issues=20
>> now, I see that some people are moving in that direction (see the re=
cent PPP=20
>> problems); also, stressing Linux in that regard can only make the co=
de better=20
>> - as long as the approach taken is clean and sound
>>
>> - we (or our customers) use a plethora of networking devices for tes=
ting so=20
>> exposing Linux early to those devices can only help catching issues =
earlier
>>
>> In short: expect more absurd patches from us :)=20
>=20
> I might cook something too :)
>=20

I tried the rbtree thing and suddenly realized it was not possible at a=
ll.

This is not possible because of all wildcards we have in UDP.

1) You can for example bind a socket s1 on address X, port p, dev eth0
2) You can bind socket s2 on adress X, port p  (same values as previous=
 socket), and dev eth1

As bindtodevice can be called after bind() itself, we can get several s=
ockets with same
rbtree key  (port, address), but rbtree doesnt allow duplicates.

I'll try hash based extent.
(Ie allocate an hash extent for given primary hash slot in case number =
of sockets
in this hash chain exceeds 10 or some threshold)

key hash would be function_of(port, address), duplicates allowed.

allocating 4096 bytes secondary hashes would divide per 1024 or 512 tim=
e of lookups, but keeping
rcu lookup might be difficult.

