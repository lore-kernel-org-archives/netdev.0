From: Christoph Lameter <cl@linux-foundation.org>
Subject: Low latency diagnostic tools
Date: Wed, 5 Aug 2009 17:10:09 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908051706050.30180@gentwo.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:50009 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751866AbZHEVKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 17:10:15 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1929E82CC17
	for <netdev@vger.kernel.org>; Wed,  5 Aug 2009 17:31:32 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id DhWiK8IZUrlw for <netdev@vger.kernel.org>;
	Wed,  5 Aug 2009 17:31:27 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6735782CC14
	for <netdev@vger.kernel.org>; Wed,  5 Aug 2009 17:31:27 -0400 (EDT)
Received: from cl (helo=localhost)
	by gentwo.org with local-esmtp (Exim 4.69)
	(envelope-from <cl@linux-foundation.org>)
	id 1MYnkP-0000x0-8q
	for netdev@vger.kernel.org; Wed, 05 Aug 2009 17:10:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am starting a collection of tools / tips for low latency networking.

lldiag-0.12 is available from
http://www.kernel.org/pub/linux/kernel/people/christoph/lldiag

Corrections and additional tools or references to additional material
welcome.

README:


This tarball contains a series of test programs that have turned out to
be useful for testing latency issues on networks and Linux systems.

Tools can be roughly separated into those dealing with networking,
those used for scheduling and for cpu cache issues.


Scheduling related tools:
-------------------------

latencytest	Basic tool to measure the impact of scheduling activity.
		Continually samples TSC and displays statistics on how OS
		scheduling impacted it.

latencystat	Query the Linux scheduling counters of a running process.
		This allows the observation on how the scheduler treats
		a running process.


Cpu cache related tools
-----------------------

trashcache	Clears all cpu caches. Run this before a test
		to avoid caching effects or to see the worst case
		caching situation for latency critical code.


Network related tools
---------------------

udpping		Measure ping pong times for UDP between two hosts.
		(mostly used for unicast)

mcast		Generate and analyze multicast traffic on a mesh
		of senders and receivers. mcast is designed to create
		multicast loads that allow one to explore the multicast
		limitations of a network infrastructure. It can create
		lots of multicast traffic at high rates.

mcasttest	Simple multicast latency test with a single
		multicast group between two machines.


Libraries:
----------

ll.*		Low latency library. Allows timestamp determination and
		determination of cpu caches for an application.



Linux configuration for large amounts of multicast groups
---------------------------------------------------------

/proc/sys/net/core/optmem_max

		Required for multicast metadata storage
		-ENBUFS will result if this is loo low.

/proc/sys/net/ipv4/igmp_max_memberships

		Limit on the number of MC groups that a single
		socket can join. If more MC groups are joined
		-ENOBUFS will result.

/proc/sys/net/ipv4/neigh/default/gc_thresh*

		These settings are often too low for heavy
		multicast usage. Each MC groups counts as a neighbor.
		Heavy MC use can result in thrashing of the neighbor
		cache. If usage reaches gc_thresh3 then again
		-ENOBUFS will be returned by some system calls.


Reducing network latency
------------------------

Most NICs have receive delays that cause additional latency.
ethtool can be used to switch those off. F.e.

ethtool -C eth0 rx-delay 0
ethtool -C eth0 rx-frames 1

WARNING: This may cause high interrupt and network processing
load. May limit the throughput of the NIC. Higher values reduce
the frequency of NIC interrupts and batch transfers from the NIC.

The default behavior of Linux is to send UDP packets immediately. This
means that each sendto() results in NIC interaction. In order to reduce
send delays multiple sendto()s can be coalesced into a single NIC
interaction. This can be accomplished by setting the MSG_MORE option
if it is know that there will be additional data sent. This creates
larger packets which reduce the load on the network infrastructure.


Configuring receive and send buffer sizes to reduce packet loss
---------------------------------------------------------------

In general large receive buffer sizes are recommended in order to
avoid packet loss when receiving data. The lower the buffer sizes
the lower the time until the application must pickup data from
the network socket to avoid packet loss.

For the send side the requirements are opposite due to the broken
flow control behavior of the Linux network stack (observed at least
in 2.6.22 - 2.6.30). Packets are accounted for by the SO_SNDBUF limit
and sendto() and friends block a process if more than SO_SNDBUF
bytes are queued on the socket. In theory this should result in the
application being blocked so that the NIC can send at full speed.

However this is usually jeopardized by the device drivers. These have
a fixed TX ring size and throw packet away that are pushed to the
driver when the count of packets exceeds TX ring size. A fast
cpu can loose huge amounts of packets by just sending at a rate
that the device does not support.

Outbound blocking only works if the SO_SNDBUF limit is lower than
the TX ring size. If SO_SNDBUF sizes are bigger than the TX ring then
the kernel will forward packets to the network device and it will queue
it until the TX ring is full. The additional packets after that are
tossed by the device driver. It is therefore recommended to configure
the send buffer sizes as small as possible to avoid this problem.

(Some device drivers --including the IPoIB layer-- behave in
a moronic way by queuing a few early packets and then throwing
away the rest until the packets queued first have been send.
This means outdated data will be send on the network. NIC should
toss the oldest packets. Best would be not to drop until the limit
established by the user through SO_SNDBUF is reached)

August 5, 2009
	Christoph Lameter <cl@linux-foundation.org>


