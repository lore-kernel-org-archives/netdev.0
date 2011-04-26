From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/3] net: Byte queue limit patch series
Date: Tue, 26 Apr 2011 08:14:12 +0200
Message-ID: <1303798452.2747.206.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1104252128001.5889@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58208 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756088Ab1DZGOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 02:14:19 -0400
Received: by wya21 with SMTP id 21so186713wya.19
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 23:14:18 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1104252128001.5889@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 25 avril 2011 =C3=A0 21:38 -0700, Tom Herbert a =C3=A9crit :
> This patch series implements byte queue limits (bql) for NIC TX queue=
s.
>=20
> Byte queue limits are a mechanism to limit the size of the transmit
> hardware queue on a NIC by number of bytes. The goal of these byte
> limits is too reduce latency caused by excessive queuing in hardware
> without sacrificing throughput.
>=20
> Hardware queuing limits are typically specified in terms of a number
> hardware descriptors, each of which has a variable size. The variabil=
ity
> of the size of individual queued items can have a very wide range. Fo=
r
> instance with the e1000 NIC the size could range from 64 bytes to 4K
> (with TSO enabled). This variability makes it next to impossible to
> choose a single queue limit that prevents starvation and provides low=
est
> possible latency.
>=20
> The objective of byte queue limits is to set the limit to be the
> minimum needed to prevent starvation between successive transmissions=
 to
> the hardware. The latency between two transmissions can be variable i=
n a
> system. It is dependent on interrupt frequency, NAPI polling latencie=
s,
> scheduling of the queuing discipline, lock contention, etc. Therefore=
 we
> propose that byte queue limits should be dynamic and change in
> iaccordance with networking stack latencies a system encounters.
>=20
> Patches to implement this:
> Patch 1: Dynamic queue limits (dql) library.  This provides the gener=
al
> queuing algorithm.
> Patch 2: netdev changes that use dlq to support byte queue limits.
> Patch 3: Support in forcedeth drvier for byte queue limits.
>=20
> The effects of BQL are demonstrated in the benchmark results below.
> These were made running 200 stream of netperf RR tests:
>=20
> 140000 rr size
> BQL: 80-215K bytes in queue, 856 tps, 3.26%
> No BQL: 2700-2930K bytes in queue, 854 tps, 3.71% cpu
>=20
> 14000 rr size
> BQ: 25-55K bytes in queue, 8500 tps
> No BQL: 1500-1622K bytes in queue,  8523 tps, 4.53% cpu
>=20
> 1400 rr size
> BQL: 20-38K in queue bytes in queue, 86582 tps,  7.38% cpu
> No BQL: 29-117K 85738 tps, 7.67% cpu
>=20
> 140 rr size
> BQL: 1-10K bytes in queue, 320540 tps, 34.6% cpu
> No BQL: 1-13K bytes in queue, 323158, 37.16% cpu
>=20
> 1 rr size
> BQL: 0-3K in queue, 338811 tps, 41.41% cpu
> No BQL: 0-3K in queue, 339947 42.36% cpu
>=20
> The amount of queuing in the NIC is reduced up to 90%, and I haven't
> yet seen a consistent negative impact in terms of throughout or
> CPU utilization.

Hi Tom

Thats a focus on thoughput, adding some extra latency (because of new
fields to access/dirty in tx path and tx completion path), especially o=
n
setups where many cpus are sending data on one device. I suspect this i=
s
the price to pay to fight bufferbloat.

We can try to make this non so expensive.

Maybe try to separate the DQL structure into two parts, one use on TX
path (inside the already dirtied cache line in netdev_queue structure
(_xmit_lock, xmit_lock_owner, trans_start)), and the other one in TX
completion path ?


This new limit schem also favors streams using super packets. Your
workload use 200 identical clients, it would be nice to mix DNS trafic
(small UDP frames) in them, and check how they behave when queue is
full, while it was almost never full before...



