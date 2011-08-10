From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Use of 802.3ad bonding for increasing link throughput
Date: Wed, 10 Aug 2011 10:46:12 -0700
Message-ID: <5344.1312998372@death>
References: <4E427499.8060108@cyconix.com>
Cc: netdev <netdev@vger.kernel.org>
To: Tom Brown <sa212+glibc@cyconix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:34514 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754333Ab1HJRqW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2011 13:46:22 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p7AHX1dB011220
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2011 13:33:01 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7AHkHW9183982
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2011 13:46:17 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7ADk4Lm031156
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2011 10:46:04 -0300
In-reply-to: <4E427499.8060108@cyconix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Brown <sa212+glibc@cyconix.com> wrote:

>[couldn't thread with '802.3ad bonding brain damaged', as I've just signed
>up]
>
>So, under what circumstances would a user actually use 802.3ad mode to
>"increase" link throughput, rather than just for redundancy? Are there any
>circumstances in which a single file, for example, could be transferred at
>multiple-NIC speed? 

	Network load balancing, by and large, increases throughput in
aggregate, not for individual connections.

[...] The 3 hashing options are:
>
>- layer 2: presumably this always puts traffic on the same NIC, even in a
>LAG with multiple NICs? Should layer 2 ever be used?

	Perhaps the network is such that the destinations are not
bonded, and can't handle more than 1 interface's worth of throughput.
Having the "server" end bonded still permits the clients deal with a
single IP address, handle failures of devices on the server, etc.

>- layer2+3: can't be used for a single file, since it still hashes to the
>same NIC, and can't be used for load-balancing, since different IP
>endpoints go unintelligently to different NICs
>
>- layer3+4: seems to have exactly the same issue as layer2+3, as well as
>being non-compliant
>
>I guess my problem is in understanding whether the 802.3/802.1AX spec has
>any use at all beyond redundancy. Given the requirement to maintain frame
>order at the distributor, I can't immediately see how having a bonded
>group of, say, 3 NICs is any better than having 3 separate NICs. Have I
>missed something obvious?

	Others have answered this part already (that it permits larger
aggregate throughput to/from the host, but not single-stream throughput
greater than one interface's worth).  This is by design, to prevent out
of order delivery of packets.

	An aggregate of N devices can be better than 3 individual
devices in that it will gracefully handle failure of one of the devices
in the aggregate, and permits sharing of the bandwidth in aggregate
without the peers having to be hard-coded to specific destinations.

>And, having said that, the redundancy features seem limited. For hot
>standby, when the main link fails, you have to wait for both ends to
>timeout, and re-negotiate via LACP, and hopefully pick up the same
>lower-priority NIC, and then rely on a higher layer to request
>retransmission of the missing frame. Do any of you have any experience of
>using 802.1AX for anything useful and non-trivial?

	In the linux implementation, as soon as the link goes down, that
port is removed from the aggregator and a new aggregator is selected
(which may be the same aggregator, depending on the option and
configuration).  Language in 802.1AX section 5.3.13 permits us to
immediately remove a failed port from an aggregator without waiting for
LACP to time out.

>So, to get multiple-NIC speed, are we stuck with balance-rr? But
>presumably this only works if the other end of the link is also running
>the bonding driver?

	Striping a single connection across multiple network interfaces
is very difficult to do without causing packets to be delivered out of
order.

	Now, that said, if you want to have one TCP connection utilize
more than one interface's worth of throughput, then yes, balance-rr is
the only mode that may do that.  The other end doesn't have to run
bonding, but it must have sufficient aggregate bandwidth to accomodate
the aggregate rate (e.g., N slower devices feeding into one faster
device).

	Running balance-rr itself can be tricky to configure.  An
unmanaged switch may not handle multiple ports with the same MAC address
very well (e.g., sending everything to one port, or sending everything
to all the ports).  A managed switch must have the relevant ports
configured for etherchannel ("static link aggregation" in some
documentation), and the switch may balance the traffic when it leaves
the switch using its transmit algorithm.  I'm not aware of any switches
that have a round-robin balance policy, so the switch may end up hashing
your traffic anyway (which will probably drop some of your packets,
because you're feeding them in faster than the switch can send them out
after they're hashed to one switch port).

	It's possible to play games on managed switches and, e.g., put
each pair of ports (one at each end) into a separate VLAN, but schemes
like that will fail badly if a link goes down somewhere.

	If each member of the bond goes through a different unmanaged
and not interconnected switch, that may avoid those issues (and this was
a common configuration back in the 10 Mb/sec days; it's described in
bonding.txt in more detail).  That configuration still has issues if a
link fails.  Connecting systems directly, back-to-back, should also
avoid those issues.

	Lastly, balance-rr will deliver traffic out of order.  Even the
best case, N slow links feeding one faster link, delivers some small
percentage out of order (in the low single digits).

	On linux, the tcp_reordering sysctl value can be raised to
compensate, but it will still result in increased packet overhead, and
is not likely to be very efficient, and doesn't help with anything
that's not TCP/IP.  I have not tested balance-rr in a few years now, but
my recollection is that, as a best case, throughput of one TCP
connection could reach about 1.5x with 2 slaves, or about 2.5x with 4
slaves (where the multipliers are in units of "bandwidth of one slave").

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
