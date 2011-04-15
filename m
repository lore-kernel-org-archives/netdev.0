From: Neil Horman <nhorman@tuxdriver.com>
Subject: net: Automatic IRQ siloing for network devices
Date: Fri, 15 Apr 2011 16:17:54 -0400
Message-ID: <1302898677-3833-1-git-send-email-nhorman@tuxdriver.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43200 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753477Ab1DOUSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 16:18:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Automatic IRQ siloing for network devices

At last years netconf:
http://vger.kernel.org/netconf2010.html

Tom Herbert gave a talk in which he outlined some of the things we can do to
improve scalability and througput in our network stack

One of the big items on the slides was the notion of siloing irqs, which is the
practice of setting irq affinity to a cpu or cpu set that was 'close' to the
process that would be consuming data.  The idea was to ensure that a hard irq
for a nic (and its subsequent softirq) would execute on the same cpu as the
process consuming the data, increasing cache hit rates and speeding up overall
throughput.

I had taken an idea away from that talk, and have finally gotten around to
implementing it.  One of the problems with the above approach is that its all
quite manual.  I.e. to properly enact this siloiong, you have to do a few things
by hand:

1) decide which process is the heaviest user of a given rx queue 
2) restrict the cpus which that task will run on
3) identify the irq which the rx queue in (1) maps to
4) manually set the affinity for the irq in (3) to cpus which match the cpus in
(2)

That configuration of course has to change in response to workload changed (what
if your consumer process gets reworked so that its no longer the largest network
user, etc).  

I thought it would be good if we could automate some amount of this, and I think
I've found a way to do that.  With this patch set I introduce the ability to:

A) Register common affinity monitoring routines against a given irq which can
implement various algorithms to determine a suggested placement of said irq's
affinity

B) Add an algorithm to the network subsystem to track the amount of data that
flows through each entry in a given rx_queues rps_flow_table, and uses that data
to suggest an affinity for the irq associated with that rx queue.

This patchset lets these affinity suggestions get exported via the
/proc/irq/<n>/affinity_hint interface (which is unused in the kernel with the
exception of ixgbe).  It also exports a new proc file affinity_alg which informs
anyone interested in the affinity_hint how the hint is being computed.

Testing:
	I've been running this patchset on my dual core system here with a cxgb4
as my network interface.  I've been running a TCP STREAMS test from netperf in 2
minute increments under various conditions.  I've found experimentally that (as
you might expect) optimal performance is reached when irq affinity is bound to a
core that is not the cpu core identified by the largest RFS flow, but is as
close to it as possible (ideally sharing an L2 cache).  In that way with we
avoid the cpu contention between the softirq and the application, while still
maximizing cache hits.  In congunction with the irqbalance patch I hacked up
here:

http://people.redhat.com/nhorman/irqbalance.patch

To steer irqs that have affinity using the rfs max weight algorithm to cpus that
are as close as possible to the hinted cpu, I'm able to get approximately a 3%
speedup in receive rates over the pessimal case, and about a 1% speedup over the
nominal case (statically setting irq affinity to a single cpu).

Note: Currently this patch set only updates cxgb4 to use the new hinting
mechanism.  If this gets accepted, I have more cards to test with and plan to
update them, but I thought for a first pass it would be better to simply update
what I tested with.

Thoughts/Opinions appreciated

Thanks & Regards
Neil

