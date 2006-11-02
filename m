From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] networking structure holes
Date: Thu, 02 Nov 2006 07:55:59 +0100
Message-ID: <4549967F.7050505@cosmosbay.com>
References: <20061031203430.GF5319@mandriva.com>
 <4547BA54.5090709@cosmosbay.com>
 <39e6f6c70611011831m3521599boa5a6a77957d143a8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604002mt.neufgp.fr ([84.96.92.61]:37280 "EHLO sMtp.neuf.fr")
	by vger.kernel.org with ESMTP id S1750698AbWKBG4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 01:56:00 -0500
Received: from [192.168.30.203] ([84.7.143.198]) by sp604002mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J8300GE9CLB0HH1@sp604002mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Thu, 02 Nov 2006 07:55:59 +0100 (CET)
In-reply-to: <39e6f6c70611011831m3521599boa5a6a77957d143a8@mail.gmail.com>
To: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo a =E9crit :
> On 10/31/06, Eric Dumazet <dada1@cosmosbay.com> wrote:
>> Arnaldo Carvalho de Melo a =E9crit :
>> > Hi,
>> >
>> >       I've been working on some DWARF2 utilities and one of them,
>> > pahole (Poke-a-Hole) can be used to find holes due to alignment ru=
les
>> > in structs, the full output of:
>> >
>> > [acme@newtoy net-2.6]$ pahole net/ipv4/tcp.o
>> >
>> >       is available at:
>> >
>> > http://oops.merseine.nu:81/acme/net.ipv4.tcp.o.pahole
>> >
>> >       Just to show what we can find with this tool here is the lay=
out
>> > of struct net_device, that barring any cacheline locality optimiza=
tion
>> > has 4 bytes to harvest, David, do you think reordering those field=
s to
>> > get 4 byts back is ok?
>>
>> I just want to bring your attention this net_device structure was=20
>> re-ordered
>> (by me :)) so that separate cache lines are used on SMP machines.
>>
>> If you select CONFIG_SMP , you'll probably notice far more holes. Bu=
t=20
>> it was a
>> feature, not lazyness.
>=20
> Thanks for commenting on this case!
>=20
>> We can probably move some fields, but very carefully :)
>=20
> Of course, in time I probably will try to combine valgrind's
> cachegrind or some new tool using the same principles I used in OSTRA
> to find out working sets of struct members to do automatic
> "suggestions" on how to reorder structs to avoid holes while keeping
> the relevant struct members close together as to exploit cacheline
> locality effects, like you do so well manually :-)
>=20
> - Arnaldo
>=20
> PS.: While we don't have tools to check out that the holes are not a
> problem because we want to exploit cacheline locality effects... what
> about some comments on the structs to explain that such holes are not
> a problem? :-)

I am all for automatic tools, if they can convince human beings :)

=46or example, I am using an optimization that is quite simple but whic=
h was not=20
accepted by netdev community :

- Moving the struct flowi directly into "struct dst_entry", right after=
 the=20
'struct dst_entry *next;' pointer.


AFAIK all objects that include a 'struct dst_entry' also include a 'str=
uct=20
flowi', so this is just a small violation of layering.

This really helps because lookups now touch only one cache line per cha=
ined=20
item instead of two/three. On loaded routers with 8 items per chain, th=
ats 8=20
or 16 cache lines CPU dont have to bring in its cache per IP packet.

Eric
