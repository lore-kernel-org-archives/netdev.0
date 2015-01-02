From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next 0/3] swdev: add IPv4 routing offload
Date: Thu, 1 Jan 2015 21:11:15 -0800
Message-ID: <CAA93jw780LZe1e+zfkXq6S1WROYePYyvvN4mTtbuU-4R4AexzA@mail.gmail.com>
References: <1420169361-31767-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jiri@resnulli.us, john fastabend <john.fastabend@gmail.com>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>, andy@greyhouse.net,
	roopa@cumulusnetworks.com, David Lamparter <equinox@diac24.net>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:55269 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbbABFLQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 00:11:16 -0500
Received: by mail-oi0-f44.google.com with SMTP id a141so5914227oig.3
        for <netdev@vger.kernel.org>; Thu, 01 Jan 2015 21:11:15 -0800 (PST)
In-Reply-To: <1420169361-31767-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 1, 2015 at 7:29 PM,  <sfeldma@gmail.com> wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> This patch set adds L3 routing offload support for IPv4 routes.  The =
idea is to
> mirror routes installed in the kernel's FIB down to a hardware switch=
 device to
> offload the data forwarding path for L3.  Only the data forwarding pa=
th is
> intercepted.  Control and management of the kernel's FIB remains with=
 the
> kernel.
>
> A couple of new ndo ops (ndo_switch_fib_ipv4_add/del) are added to th=
e swdev
> model to add/remove FIB entries to/from the offload device.  The ops =
are called
> from the core IPv4 FIB code directly.  Just before the FIB entry is i=
nstalled
> in the kernel's FIB, the swdev device driver gets a chance at the FIB=
 entry
> (assuming the swdev driver implements the new ndo ops).  This is a sy=
nchronous
> call in the RTM_NEWROUTE path, and the swdev has the option to fail t=
he
> install, which means the FIB entry is not installed in swdev or the k=
ernel, and
> the user is notified of the failure.  The swdev driver also has the o=
ption to
> return -EOPNOTSUPP to pass on the FIB entry, so it'll only be install=
ed in the
> kernel FIB.

A couple notes:

1) As currently implemented in quagga, (to my knowledge), an actual
route change is actually a route delete/route add rather than an
atomic route modify or route add/route delete. While it would be nice
to fix quagga to do it atomically (and for all I know some fork does
it right?), I am curious as to the extent of serialization during the
process like this in the virtual switch. (and it does not appear you
have tested the ip route change commands above, or beat up quagga's
routing decisions)

2) It is generally helpful to be concurrently running the max traffic
you can sustain through the switch, while doing fib changes... and
observing what happens to that traffic.

3) As you attempt ipv6, life gets more complex. (you need to switch to
a later routing protocol in particular...)

4) There's a new idea on the block: Source specific routing (sometimes
called SADR) is mandated by the ietf homenet working group, in
particular, which relies on IPV6_subtrees, and link local ipv6
multicast. the code furthest enough along is babels
(http://www.pps.univ-paris-diderot.fr/~jch/software/babel/
https://github.com/boutier/babeld also with patches for quagga) which,
being easy to setup, might be a good exercise of both link local
multicast and of ipv6 in the virtual switch itself, as well as
exercising the fib. (ospfv3 and ISIS also have support for source
specific routing in various branches.)

>
> The FIB flush path is modified also to call into the swdev driver to =
flush the
> FIB entries from hardware.
>
> The rocker swdev driver is updated to support these new ndo ops.  Rig=
ht now
> rocker only supports IPv4 singlepath routes, but follow-on patches wi=
ll add
> IPv6 and ECMP support.  Also, only unicast IPv4 routes are supported,=
 but
> follow-on patches will add multicast route support.
>
> Testing was done in my simulated network envionment using VMs and the=
 rocker
> device.  I'm using Quagga OSPFv2 for the routing protocol for automat=
ic control
> plane processing.  No modifications to Quagga or netlink/iproute2 is =
required;
> it just works.
>
> One important metric is the time spent installing/removing FIB entrie=
s from the
> kernel and the device.  With these patches applied, I measured the wa=
ll time
> required to install and remove 10K IPv4 routes.  I used ip route add =
cmd in
> batch mode to install static routes.  I used the ip route flush cmd t=
o delete
> the routes.  This is 10000 routes installed to the kernel's FIB and t=
o the
> swdev device's L3 tables.  And then removed from each.  The performan=
ce is less
> than a second for each operation.  This is on my simulated rocker dev=
ice running
> on a VM, so a real embedded CPU would probably do much better.
>
> My batch has 10K lines of:
>
> simp@simp:~$ head east
> route add 16.0.0.0/32 nexthop via 11.0.0.2 dev swp1
> route add 16.0.0.1/32 nexthop via 11.0.0.2 dev swp1
> route add 16.0.0.2/32 nexthop via 11.0.0.2 dev swp1
> route add 16.0.0.3/32 nexthop via 11.0.0.2 dev swp1
> route add 16.0.0.4/32 nexthop via 11.0.0.2 dev swp1
> route add 16.0.0.5/32 nexthop via 11.0.0.2 dev swp1
> route add 16.0.0.6/32 nexthop via 11.0.0.2 dev swp1
> route add 16.0.0.7/32 nexthop via 11.0.0.2 dev swp1
> route add 16.0.0.8/32 nexthop via 11.0.0.2 dev swp1
> route add 16.0.0.9/32 nexthop via 11.0.0.2 dev swp1
> [...]
>
> Install/removing routes:
>
> simp@simp:~$ wc -l east
> 10000 east
> simp@simp:~$ ip route show root 16/8 | wc -l
> 0
> simp@simp:~$ time sudo ip --batch east
>
> real    0m0.715s
> user    0m0.092s
> sys     0m0.388s
> simp@simp:~$ ip route show root 16/8 | wc -l
> 10000
>
> [At this point, 10K routes are installed in kernel and the device]
>
> simp@simp:~$ time sudo ip route flush root 16/8
>
> real    0m0.458s
> user    0m0.000s
> sys     0m0.284s
> simp@simp:~$ ip route show root 16/8 | wc -l
> 0
>
> [All gone]
>
> Scott Feldman (3):
>   net: add IPv4 routing FIB support for swdev
>   net: call swdev fib del for flushed routes
>   rocker: implement IPv4 fib offloading
>
>  drivers/net/ethernet/rocker/rocker.c |  441 ++++++++++++++++++++++++=
+++++++++-
>  include/linux/netdevice.h            |   22 ++
>  include/net/switchdev.h              |   18 ++
>  net/ipv4/fib_trie.c                  |   31 ++-
>  net/switchdev/switchdev.c            |   89 +++++++
>  5 files changed, 592 insertions(+), 9 deletions(-)
>
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Dave T=C3=A4ht

thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
