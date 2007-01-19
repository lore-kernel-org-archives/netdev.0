From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/12] L2 network namespace (v3)
Date: Fri, 19 Jan 2007 00:27:30 -0700
Message-ID: <m1ps9b5vdp.fsf@ebiederm.dsl.xmission.com>
References: <200701171851.14734.dim@openvz.org>
	<20070119.090745.39279848.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=euc-jp
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dim@openvz.org, netdev@vger.kernel.org, containers@lists.osdl.org,
	alexey@sw.ru, saw@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:50539 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964881AbXASH2r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jan 2007 02:28:47 -0500
To: YOSHIFUJI Hideaki / =?euc-jp?B?tcjGo7HRzMA=?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20070119.090745.39279848.yoshfuji@linux-ipv6.org> (YOSHIFUJI
	Hideaki's message of "Fri, 19 Jan 2007 09:07:45 +0900 (JST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =B5=C8=C6=A3=B1=D1=CC=C0 <yoshfuji@linux-ipv6.org> =
writes:

> In article <200701171851.14734.dim@openvz.org> (at Wed, 17 Jan 2007 1=
8:51:14
> +0300), Dmitry Mishin <dim@openvz.org> says:
>
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> L2 network namespaces
>>=20
>> The most straightforward concept of network virtualization is comple=
te
>> separation of namespaces, covering device list, routing tables, netf=
ilter
>> tables, socket hashes, and everything else.
>>=20
>> On input path, each packet is tagged with namespace right from the
>> place where it appears from a device, and is processed by each layer
>> in the context of this namespace.
>> Non-root namespaces communicate with the outside world in two ways: =
by
>> owning hardware devices, or receiving packets forwarded them by thei=
r parent
>> namespace via pass-through device.
>
> Can you handle multicast / broadcast and IPv6, which are very importa=
nt?

The basic idea here is very simple.

Each network namespace appears to user space as a separate network stac=
k,
with it's own set of routing tables etc.

All sockets and all network devices (the sources of packets) belong
to exactly one network namespace. =20

=46rom the socket or the network device a packet enters the network sta=
ck
you can infer the network namespace that it will be processed in.
Each network namespace should get it own complement of the data structu=
res
necessary to process packets, and everything should work.

Talking between namespaces is accomplished either through an external n=
etwork,
or through a special pseudo network device.  The simplest to implement
is two network devices where all packets transmitted on one are receive=
d
on the other.  Then by placing one network device in one namespace and
the other in another interface it looks like two machines connected by
a cross over cable.

Once you have that in a one namespace you can connect other namespaces
with the existing ethernet bridging or by configuring one of the
namespaces as a router and routing traffic between them.


Supporting IPv6 is roughly as difficult as supporting IPv4. =20

What needs to happen to convert code is all variables either need
a per network namespace instance or the data structures needs to be
modified to have a network namespace tag.  For hash tables which
are hard to allocate dynamically tagging is the preferred conversion
method, for anything that is small enough duplication is preferred
as it allows the existing logic to be kept.

In the fast path the impact of all of the conversions should be very li=
ght,
to non-existent.  In network stack initialization and cleanup there
is work todo because you are initializing and cleanup variables more of=
ten
then at module insertion and removal.

So my expectation is that once we get a framework established and merge=
d
to allow network namespaces eventually the entire network stack will be
converted.  Not just ipv4 and ipv6 but decnet, ipx, iptables, fair sche=
duling,
ethernet bridging and all of the other weird and twisty bits of the
linux network stack.

The primary practical hurdle is there is a lot of networking code in
the kernel.

I think I know a path by which we can incrementally merge support for
network namespaces without breaking anything.  More to come on this
when I finish up my demonstration patchset in a week or so that
is complete enough to show what I am talking about.

I hope this helps but the concept into perspective.

As for Dmitry's patchset in particular it currently does not support
IPv6 and I don't know where it is with respect to the broadcast and
multicast but I don't see any immediate problems that would preclude
those from working.  But any incompleteness is exactly that
incompleteness and an implementation problem not a fundamental design
issue.

Eric
