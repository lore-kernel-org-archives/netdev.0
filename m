From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] Re: [PATCH 2.6] e100: use NAPI mode all the time
Date: Sun, 06 Jun 2004 23:39:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406070639.i576drvF026556@death.nxdomain.ibm.com>
References: <jgarzik@pobox.com>
Cc: Tim Mattox <tmattox@engr.uky.edu>, sfeldma@pobox.com, netdev@oss.sgi.com,
        bonding-devel@lists.sourceforge.net,
        Scott Feldman <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: Message from Jeff Garzik <jgarzik@pobox.com>
   of "Sun, 06 Jun 2004 22:33:26 EDT." <40C3D3F6.6010103@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:

>Tim Mattox wrote:
>> The problem is caused by the order packets are delivered to the TCP
>> stack on the receiving machine.  In normal round-robin bonding mode,
>> the packets are sent out one per NIC in the bond.  For simplicity
>> sake, lets say we have two NICs in a bond, eth0 and eth1.  When
>> sending packets, eth0 will handle all the even packets, and eth1 all
>> the odd packets.  Similarly when receiving, eth0 would get all
>> the even packets, and eth1 all the odd packets from a particular
>> TCP stream.

>Ethernet drivers have _always_ processed multiple packets per
>interrupt, since before the days of NAPI, and before the days of
>hardware mitigation.

	There was a discussion about this behavior (round-robin mode out
of order delivery) on bonding-devel in February 2003.  The archives can
be found here:

http://sourceforge.net/mailarchive/forum.php?forum_id=2094&max_rows=25&style=ultimate&viewmonth=200302

	The messages on Feb 19 relate to the effects of packet
coalescing, and Feb 17 to general out of order delivery problems.
Somewhere in there are the results of some testing I did, and analysis
of how tcp_ordering effects things.  As I recall, I even used e100s for
my testing, so it may be a fair apples to apples comparsion.

	When I tested this (on 4 100Mbps ethernets), even after
adjusting tcp_reordering I could only get TCP single stream throughput
of about 235 Mb/sec out of a theoretical 375 or so (400 minus about 6%
for headers and whatnot).  UDP would run in the mid to upper 300's,
depending upon datagram size.  The tests did not examine UDP delivery
order.

	The round-robin mode will, for all practical purposes, always
deliver some large percentage of packets out of order.  You can fiddle
with the tcp_reordering parameter to mitigate the effects to some
degree, but there's no way it's going away entirely.

	I'm curious as to what types of systems the beowulf / HPC people
(mentioned by Tim in an earlier message) are using that they don't see
out of order problems with round robin, even without NAPI.

>Therefore, this is mainly an argument against using overly simplistic
>load balancing schemes that _create_ this problem :)  It's much
>smarter to load balance based on flows, for example.  I think the ALB
>mode does this?

	The round robin mode is unique in that it is the only mode that
will attempt (however stupidly) to stripe single connections (flows)
across multiple interfaces.  The other (smarter) modes, 802.3ad, alb,
and tlb, will try to keep particular connections generally on a
particular interface (for 802.3ad, it's required by the standard to
behave that way).  This means that a given single TCP/IP connection
won't get more than one interface worth of throughput.  With
round-robin, you can get more than one interface worth, but not very
efficiently.

>> I have NO problems with NAPI itself, I think it's a wonderful development.
>> I would even advocate for making NAPI the default across the board.
>> But for bonding, until I see otherwise, I want to be able to not use NAPI.
>> As I indicated, I will have a new cluster that I can directly test this
>> NAPI vs Bonding issue very soon.

	After taking into account the effects of delivering multiple
packets per interrupt and the scheduling order of network device
interrupts (potentially on different CPUs), I'm not really sure there's
much room for NAPI to make round-robin any worse than it already is.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
