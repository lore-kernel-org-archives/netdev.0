From: Tore Anderson <tore@fud.no>
Subject: Re: [PATCH net-next] ipv6: =?UTF-8?Q?RTAX=5FFEATURE=5FALLFRAG=20c?=  =?UTF-8?Q?auses=20inefficient=20TCP=20segment=20sizing?=
Date: Wed, 25 Apr 2012 13:49:19 +0200
Message-ID: <4b7a2708fd4545ac65cfef6561e7f02a@greed.fud.no>
References: <1335289058.5205.165.camel@edumazet-glaptop>
 <CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
 <1335298228.5205.168.camel@edumazet-glaptop>
 <CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
 <1335331960.5205.180.camel@edumazet-glaptop>
 <CANP3RGdhs8s_RytR=f8ismSZdGs91bpVq=ZAjb0EOm-gCsDPAw@mail.gmail.com>
 <f88609a3e80bbe53233e62dec2699a3e@greed.fud.no>
 <CANP3RGcGH6Su8Lvt34eTDF2iv2HSipo2DvybXGQA4pXZj_qb9Q@mail.gmail.com>
 <4c435f101fb7c653fd3b4e81980250e7@greed.fud.no>
 <CANP3RGf5oTd9mQsXqKj3uXgweMwjs9N3VSeXBHjDXQ7vG0NaSg@mail.gmail.com>
 <7333a1d306fa2eca215bc9f55d23d03c@greed.fud.no>
 <CANP3RGeV9Z2z3i4GYyupU2tBVbL-4nX2-h2e8MP=PP4WE2s9qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from greed.fud.no ([87.238.35.20]:56488 "EHLO greed.fud.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758157Ab2DYLtX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 07:49:23 -0400
In-Reply-To: <CANP3RGeV9Z2z3i4GYyupU2tBVbL-4nX2-h2e8MP=PP4WE2s9qw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Maciej =C5=BBenczykowski

>> I think you forgot to include the explanation why. :-)
>
> I did try, I just didn't do a very good job.

Oh, because of IPv6-in-IPv4 tunnel encap overhead, I get it now.

>> I suppose. This would be invisible to IPv6, though - the=20
>> fragmentation and
>> reassembly happens at a lower layer than IPv6. Same as ATM for=20
>> example. Situation is
>> described by RFC 2460:
>
> It would be invisible (*), and you probably wouldn't really need the
> frag header in the ipv6 packet,
> but it would still be desirable to have ipv6 already have packets
> smaller than ipv4
> mtu - 20, rather than have to frag/unfrag at the tunnel endpoint.
> Since it is always more efficient to have fragmented correctly in the
> first place.
>
> (*) Would it be legal for a tunnel endpoint to support ipv6 packets=20
> up
> to 1280 bytes in size
> but still send back a 'packet to big please use 1K mtu' message?

I don't think this is a valid thing to do - either the tunnel server=20
would
forward the packet through the tunnel (fragmenting the underlaying IPv4=
=20
if
necessary), and *not* send back a ICMPv6 PTB error at the same time,=20
OR: it
would need to drop the packet and *do* send back the ICMPv6 PTB. Not=20
both
at the same time.

However, if it is going to drop the large packets and reply with the=20
PTB, it
will cause a blackhole with current Linux, because if it get the PTB=20
with
MTU=3D1000, it will include the frag header, but *not* reduce the actua=
l=20
packet
size. And since this is pure IPv6 routing, the tunnel server will not=20
be able
to fragment the IPv6 packets, since IPv6 routers don't do that (the=20
presense
of the Fragmentation header does not change this fact).

So the tunnel routers pretty much *must* support an IPv6 MTU of 1280,=20
either
by ensuring the outer IPv4 MTU is 1300 or larger, or by performing IPv4
fragmentation and reassembly "under the hood".

I don't think it is worth while (or even appropriate) for the Linux=20
IPv6 stack
to try to optimize for this.

Tore
