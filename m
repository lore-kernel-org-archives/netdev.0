From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 0/3] net: Byte queue limit patch series
Date: Tue, 26 Apr 2011 09:57:04 -0700
Message-ID: <1303837024.9358.545.camel@tardy>
References: <alpine.DEB.2.00.1104252128001.5889@pokey.mtv.corp.google.com>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:1167 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753391Ab1DZQ5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 12:57:06 -0400
In-Reply-To: <alpine.DEB.2.00.1104252128001.5889@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-04-25 at 21:38 -0700, Tom Herbert wrote:
> This patch series implements byte queue limits (bql) for NIC TX queues.
> 
> Byte queue limits are a mechanism to limit the size of the transmit
> hardware queue on a NIC by number of bytes. The goal of these byte
> limits is too reduce latency caused by excessive queuing in hardware
> without sacrificing throughput.
> 
> Hardware queuing limits are typically specified in terms of a number
> hardware descriptors, each of which has a variable size. The variability
> of the size of individual queued items can have a very wide range. For
> instance with the e1000 NIC the size could range from 64 bytes to 4K
> (with TSO enabled). This variability makes it next to impossible to
> choose a single queue limit that prevents starvation and provides lowest
> possible latency.
> 
> The objective of byte queue limits is to set the limit to be the
> minimum needed to prevent starvation between successive transmissions to
> the hardware. The latency between two transmissions can be variable in a
> system. It is dependent on interrupt frequency, NAPI polling latencies,
> scheduling of the queuing discipline, lock contention, etc. Therefore we
> propose that byte queue limits should be dynamic and change in
> iaccordance with networking stack latencies a system encounters.
> 
> Patches to implement this:
> Patch 1: Dynamic queue limits (dql) library.  This provides the general
> queuing algorithm.
> Patch 2: netdev changes that use dlq to support byte queue limits.
> Patch 3: Support in forcedeth drvier for byte queue limits.
> 
> The effects of BQL are demonstrated in the benchmark results below.
> These were made running 200 stream of netperf RR tests:
> 
> 140000 rr size
> BQL: 80-215K bytes in queue, 856 tps, 3.26%
> No BQL: 2700-2930K bytes in queue, 854 tps, 3.71% cpu

That is both the request and the response being set to 140000 yes?

> 14000 rr size
> BQ: 25-55K bytes in queue, 8500 tps
> No BQL: 1500-1622K bytes in queue,  8523 tps, 4.53% cpu
> 
> 1400 rr size
> BQL: 20-38K in queue bytes in queue, 86582 tps,  7.38% cpu
> No BQL: 29-117K 85738 tps, 7.67% cpu
> 
> 140 rr size
> BQL: 1-10K bytes in queue, 320540 tps, 34.6% cpu
> No BQL: 1-13K bytes in queue, 323158, 37.16% cpu

What, no 14?-)

> 1 rr size
> BQL: 0-3K in queue, 338811 tps, 41.41% cpu
> No BQL: 0-3K in queue, 339947 42.36% cpu
> 
> The amount of queuing in the NIC is reduced up to 90%, and I haven't
> yet seen a consistent negative impact in terms of throughout or
> CPU utilization.

Presumably this will also have a positive (imo) effect on the maximum
size to which a bulk transfer's window will grow under auto tuning yes?

How about a "burst mode" TCP_RR test?

happy benchmarking,

rick jones

