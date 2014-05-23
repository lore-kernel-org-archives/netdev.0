From: nisse@southpole.se (Niels =?utf-8?Q?M=C3=B6ller?=)
Subject: What's the right way to use a *large* number of source addresses?
Date: Fri, 23 May 2014 11:38:22 +0200
Message-ID: <6zlhtsvnqp.fsf@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([37.247.8.11]:47313 "EHLO mail.southpole.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751017AbaEWJ6N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 05:58:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a client doing traffic generation for load testing. When they
experienced performance problems with assigning a large number (say,
100000) ip addresses to an interface, they wrote a custom and
proprietary source NAT kernel module which let's you set any desired
source address on a socket, and then sets up SNAT to that address. This
was a couple of years ago, and it appears to have worked fine.

However, the code is a bit complex, and duplicates functionality in the
iptables SNAT target and the connection tracking machinery in the
current kernel. If I could relicense the module under a free license, I
suspect it would be shot down for technical reasons.

So now I'm trying to figure out what's the Right Way to enable traffic
generations with a large number of source addresses, to possibly retire
the proprietary kernel module. I see a couple of different approaches:

1. Simply assign all addresses to be used to the interface, fixing any
   remaining performance problems.

   I've done a simple benchmark with a script assigning n addresses
   using "ip address add", and this seems to have O(n^2) complexity.
   E.g, assigning n=3D25500 addresses took 26 s, and doubling n, assign=
ing
   51000 addresses, took 122 s, 4.6 times longer. Which isn't
   necessarily a problems once all the addresses are assigned, but it
   sounds a bit like there's a linear datastructure in there, not
   intended for a large number of addresses.

   A way to add an address range (or a prefix), using a *single* entry
   of whatever datastructures are used, would help.

2. Do source NAT. I think the current SNAT target does almost everythin=
g
   needed. It could be extended with some setsockopt to set the desired
   address on a per socket basis. Not sure where to store that info;
   either associate the desired address with the socket, and have the
   SNAT module look for that. Or maybe one could have setsockopt create
   a conntrack entry in advance, prior to connect.

   Main drawback of using NAT is the overhead for connection tracking;
   it would be preferable if the only per-connection state needed is th=
e
   socket itself.

3. Just set the desired local address with the bind call. Currently,
   this gives an EADDRNOTAVAIL error, so the first step would be some
   option to allow arbitrary source addresses.

   For an arbitrary source address, the network stack can't guess the
   intended interface. So one would also need to support something like
   SO_BINDTODEVICE to tell it explicitly.

   And for replies to be passed up to the transport layer, one must set
   up some processing of incoming packets to deliver them to the local
   machine. It's very unclear to me if there's any good way to do that,
   maybe one needs a conntrack entry for each connection just like with
   SNAT. Even with conntrack I think this approach is a bit cleaner tha=
n
   SNAT, in that the transport-layer 5-tuple would be based on the
   address that really is used on the wire.

What do you think? From a user perspective, I think I'd prefer either
(1), or (3) with a single setsockopt call which means "I'm going to use
an arbitrary source address. Transmit my packets over interface X, and
arrange the processing of incoming packets so that replies arrive to
this socket.", and then specify the desired source address with bind()
as usual.

Best regards,
/Niels M=C3=B6ller
