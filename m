From: Tom Herbert <therbert@google.com>
Subject: [PATCH v3 0/10] bql: Byte Queue Limits
Date: Tue, 22 Nov 2011 21:52:12 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1111222134590.9126@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f202.google.com ([209.85.216.202]:56241 "EHLO
	mail-qy0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797Ab1KWF5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 00:57:31 -0500
Received: by qyk10 with SMTP id 10so107548qyk.1
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 21:57:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes from last version:
  - Rebase to 3.2
  - Added CONFIG_BQL and CONFIG_DQL
  - Added some cache alignment in struct dql, to split read only, writeable
    elements, and split those elements written on transmit from those
    written at transmit completion (suggested by Eric).
  - Split out adding xps_queue_release as its own patch.
  - Some minor performance changes, use likely and unlikely for some
    conditionals.
  - Cleaned up some "show" functions for bql (pointed out by Ben).
  - Change netdev_tx_completed_queue to do check xoff, check
    availability, and then check xoff again.  This to prevent potential
    race conditions with netdev_sent_queue (as Ben pointed out).
  - Did some more testing trying to evaluate overhead of BQL in the
    transmit path.  I see about 1-3% degradation in CPU utilization
    and maximum pps when BQL is enabled.  Any ideas to beat this
    down as much as possible would be appreciated!
  - Added high versus low priority traffic test to results below.
  
----

This patch series implements byte queue limits (bql) for NIC TX queues.

Byte queue limits are a mechanism to limit the size of the transmit
hardware queue on a NIC by number of bytes. The goal of these byte
limits is too reduce latency (HOL blocking) caused by excessive queuing
in hardware (aka buffer bloat) without sacrificing throughput.

Hardware queuing limits are typically specified in terms of a number
hardware descriptors, each of which has a variable size. The variability
of the size of individual queued items can have a very wide range. For
instance with the e1000 NIC the size could range from 64 bytes to 4K
(with TSO enabled). This variability makes it next to impossible to
choose a single queue limit that prevents starvation and provides lowest
possible latency.

The objective of byte queue limits is to set the limit to be the
minimum needed to prevent starvation between successive transmissions to
the hardware. The latency between two transmissions can be variable in a
system. It is dependent on interrupt frequency, NAPI polling latencies,
scheduling of the queuing discipline, lock contention, etc. Therefore we
propose that byte queue limits should be dynamic and change in
accordance with networking stack latencies a system encounters.  BQL
should not need to take the underlying link speed as input, it should
automatically adjust to whatever the speed is (even if that in itself is
dynamic).

Patches to implement this:
- Dynamic queue limits (dql) library.  This provides the general
queuing algorithm.
- netdev changes that use dlq to support byte queue limits.
- Support in drivers for byte queue limits.

The effects of BQL are demonstrated in the benchmark results below.

--- High priority versus low priority traffic:

In this test 100 netperf TCP_STREAMs were started to saturate the link.
A single instance of a netperf TCP_RR was run with high priority set.
Queuing discipline in pfifo_fast, NIC is e1000 with TX ring size set to
1024.  tps for the high priority RR is listed.

No BQL, tso on: 3000-3200K bytes in queue: 36 tps
BQL, tso on: 156-194K bytes in queue, 535 tps
No BQL, tso off: 453-454K bytes int queue, 234 tps
BQL, tso off: 66K bytes in queue, 914 tps

---  Various RR sizes

These tests were done running 200 stream of netperf RR tests.  The
results demonstrate the reduction in queuing and also illustrates 
the overhead due to BQL (in small RR sizes).

140000 rr size
BQL: 80-215K bytes in queue, 856 tps, 3.26%
No BQL: 2700-2930K bytes in queue, 854 tps, 3.71% cpu

14000 rr size
BQL: 25-55K bytes in queue, 8500 tps
No BQL: 1500-1622K bytes in queue,  8523 tps, 4.53% cpu

1400 rr size
BQL: 20-38K in queue bytes in queue, 86582 tps,  7.38% cpu
No BQL: 29-117K 85738 tps, 7.67% cpu

140 rr size
BQL: 1-10K bytes in queue, 320540 tps, 34.6% cpu
No BQL: 1-13K bytes in queue, 323158, 37.16% cpu

1 rr size
BQL: 0-3K in queue, 338811 tps, 41.41% cpu
No BQL: 0-3K in queue, 339947 42.36% cpu

So the amount of queuing in the NIC can be reduced up to 90% or more.
Accordingly, the latency for high priority packets in the prescence
of low priority bulk throughput traffic can be reduced by 90% or more.

Since BQL accounting is in the transmit path for every packet, and the
function to recompute the byte limit is run once per transmit
completion-- there will be some overhead in using BQL.  So far, Ive see
the overhead to be in the range of 1-3% for CPU utilization and maximum
pps.
