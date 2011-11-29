From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Tue, 29 Nov 2011 17:46:24 +0100
Message-ID: <1322585184.2465.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60509 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754671Ab1K2Qqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 11:46:31 -0500
Received: by bkas6 with SMTP id s6so742421bka.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 08:46:29 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 novembre 2011 =C3=A0 18:32 -0800, Tom Herbert a =C3=A9crit =
:
> Changes from last version:
>   - Fixed obj leak in netdev_queue_add_kobject (suggested by shemming=
er)
>   - Change dql to use unsigned int (32 bit) values (suggested by eric=
)
>   - Added adj_limit field to dql structure.  This computed as
>     limit + num_completed.  In dql_avail this is used to determine
>     availability with one less arithmetic op.=20
>   - Use UINT_MAX for limit constants.
>   - Change netdev_sent_queue to not have a number of packets argument=
,
>     one packet is assumed.  (suggested by shemminger)
>   - Added more detail about locking requirements for dql
>   - Moves netdev->state field to written fields part of netdev struct=
ure
>   - Fixed function prototypes in dql.h.
>=20
> ----
>=20
> This patch series implements byte queue limits (bql) for NIC TX queue=
s.
>=20
> Byte queue limits are a mechanism to limit the size of the transmit
> hardware queue on a NIC by number of bytes. The goal of these byte
> limits is too reduce latency (HOL blocking) caused by excessive queui=
ng
> in hardware (aka buffer bloat) without sacrificing throughput.
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
> accordance with networking stack latencies a system encounters.  BQL
> should not need to take the underlying link speed as input, it should
> automatically adjust to whatever the speed is (even if that in itself=
 is
> dynamic).
>=20
> Patches to implement this:
> - Dynamic queue limits (dql) library.  This provides the general
> queuing algorithm.
> - netdev changes that use dlq to support byte queue limits.
> - Support in drivers for byte queue limits.
>=20
> The effects of BQL are demonstrated in the benchmark results below.
>=20
> --- High priority versus low priority traffic:
>=20
> In this test 100 netperf TCP_STREAMs were started to saturate the lin=
k.
> A single instance of a netperf TCP_RR was run with high priority set.
> Queuing discipline in pfifo_fast, NIC is e1000 with TX ring size set =
to
> 1024.  tps for the high priority RR is listed.
>=20
> No BQL, tso on: 3000-3200K bytes in queue: 36 tps
> BQL, tso on: 156-194K bytes in queue, 535 tps
> No BQL, tso off: 453-454K bytes int queue, 234 tps
> BQL, tso off: 66K bytes in queue, 914 tps
>=20
> ---  Various RR sizes
>=20
> These tests were done running 200 stream of netperf RR tests.  The
> results demonstrate the reduction in queuing and also illustrates=20
> the overhead due to BQL (in small RR sizes).
>=20
> 140000 rr size
> BQL: 80-215K bytes in queue, 856 tps, 3.26%
> No BQL: 2700-2930K bytes in queue, 854 tps, 3.71% cpu
>=20
> 14000 rr size
> BQL: 25-55K bytes in queue, 8500 tps
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
> So the amount of queuing in the NIC can be reduced up to 90% or more.
> Accordingly, the latency for high priority packets in the prescence
> of low priority bulk throughput traffic can be reduced by 90% or more=
=2E
>=20
> Since BQL accounting is in the transmit path for every packet, and th=
e
> function to recompute the byte limit is run once per transmit
> completion-- there will be some overhead in using BQL.  So far, Ive s=
ee
> the overhead to be in the range of 1-3% for CPU utilization and maxim=
um
> pps.


I did sucessful tests with tg3 (I'll provide the patch for bnx2 shortly=
)

Some details probably can be polished, but I believe your v4 is ready
for inclusion.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !
