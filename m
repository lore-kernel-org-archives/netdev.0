From: Rick Jones <rick.jones2@hp.com>
Subject: Re: rps testing questions
Date: Tue, 18 Jan 2011 10:23:44 -0800
Message-ID: <4D35DAB0.9030201@hp.com>
References: <AANLkTin1pC=auiFBt83YomdhVgUO8uSdvq=tPaDu0=3U@mail.gmail.com> <1295269713.3700.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mi wake <wakemi.wake@gmail.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:23519 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122Ab1ARScz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 13:32:55 -0500
In-Reply-To: <1295269713.3700.5.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Mon, 2011-01-17 at 17:43 +0800, mi wake wrote:
>=20
>>I do a rps(Receive Packet Steering) testing on centos 5.5 with  kerne=
l 2.6.37.
>>cpu: 8 core Intel.
>>ethernet adapter: bnx2x
>>
>>Problem statement:
>>enable rps with:
>>echo "ff" > /sys/class/net/eth2/queues/rx-0/rps_cpus.
>>
>>running 1 instances of netperf TCP_RR: netperf  -t TCP_RR -H 192.168.=
0.1 -c -C
>>without rps: 9963.48(Trans Rate per sec)
>>with rps:  9387.59(Trans Rate per sec)

Presumably there was an increase in service demand corresponding with t=
he drop=20
in transactions per second.

Also, an unsolicited benchmarking style tip or two.  I find it helpful =
to either=20
do several discrete runs, or use the confidence intervals (global -i an=
d -I=20
options) with the TCP_RR tests when I am looking to compare two setting=
s.  I=20
find a bit more "variability" in the _RR tests than the _STREAM tests.

http://www.netperf.org/svn/netperf2/trunk/doc/netperf.html#index-g_t_00=
2dI_002c-Global-26

Pinning netperf/netserver is also something I tend to do, but combining=
 that=20
with  confidence intervals, RPS is kind of difficult - the successive d=
ata=20
connections made while running the iterations of the confidence interva=
ls will=20
have different port numbers and so different hashing.  That would cause=
 RPS to=20
put the connections on different cores in turn, which would, in conjunc=
tion with=20
netperf/netserver being pinned to a core cause the relationship between=
 where=20
netperf runs and where netserver runs to change.  That will likely resu=
lt in=20
cache to cache (processor cache) transfers which will definitely up the=
 service=20
demand and drop the single-stream transactions per second.

In theory :) with RFS that should not be an issue since where netperf/n=
etserver=20
are pinned controls where the inbound processing takes place.

We are in a maze of twisty heuristics... :)

>>I do ab and tbench testing also find there is less tps with enable
>>rps.but,there is more cpu using when with enable rps.when with enable
>>rps =EF=BC=8Csoftirqs is blanced  on cpus.
>>
>>is there something wrong with my test=EF=BC=9F
>=20
>=20
> In addition to what Eric said, check the interrupt moderation setting=
s
> (ethtool -c/-C options).  One-way latency for a single request/respon=
se
> test will be at least the interrupt moderation value.
>=20
> I haven't tested RPS by itself (Solarflare NICs have plenty of hardwa=
re
> queues) so I don't know whether it can improve latency.  However, RFS
> certainly does when there are many flows.

Is there actually an expectation that either RPS or RFS would improve *=
latency*?=20
  Multiple-stream throughput certainly, but with the additional work do=
ne to=20
spread things around, I wouldn't expect either to improve latency.

happy benchmarking,

rick jones
