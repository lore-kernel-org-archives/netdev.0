From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when gc_elasticity
 is exceeded
Date: Tue, 30 Sep 2008 19:16:50 +0200
Message-ID: <48E25F02.8030303@cosmosbay.com>
References: <48E141F3.9000903@cosmosbay.com>	<20080929223801.GA3157@hmsreliant.think-freely.org>	<48E1C104.2080801@cosmosbay.com> <20080930.071023.07946874.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.150]:64574 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750751AbYI3RRJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 13:17:09 -0400
In-Reply-To: <20080930.071023.07946874.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 30 Sep 2008 08:02:44 +0200
>=20
>> When a machine is targeted by a DDOS attack, about all slots of the
>> hash table are fully loaded (ie chain length >=3D elasticity). We do=
nt
>> need to invalidate the cache, but find an equilibrium, with small
>> adjustements.
>=20
> Sure, but it is possible to determine that some hash chains
> are unevenly growing out of control compared to others,
> and that is the algorithm that Neil is trying to discover.
>=20
>=20

No problem, but my suggestion to use a separate threshold than elastici=
ty
was apparently not taken into consideration.

I ran an experiment on a big stable machine with 2^19 rtcache slots,
 scanning all chains and found *many* of them having length > elasticit=
y,
maximum being 13. I am sure its allowed by statistics laws.

(average chain length : 3.55)

In order to avoid unecessary cache invalidation, we need some=20
calculation from a statistics expert.

Given rt_hash_size and elasticity (or rt_max_size), compute the "maximu=
m reasonable"=20
chain length, ie some X number where probability(chain_length < X) > 0.=
9999

(CCed Evgeniy Polyakov :) )



MemTotal:   32963064 kB
8 CPUS
/proc/sys/net/ipv4/route/max_size:8388608 (default at boot time)
/proc/sys/net/ipv4/route/gc_thresh:2000000
/proc/sys/net/ipv4/route/gc_elasticity:4
/proc/sys/net/ipv4/route/gc_interval:1

Linux version 2.6.24.5
cat /proc/net/sockstat
sockets: used 957514
TCP: inuse 963998 orphan 7100 tw 10393 alloc 964646 mem 376389

rtstat -c5 -i5 (minus first sample)
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache=
|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cach=
e|rt_cache|
 entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti=
| out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlis=
t|out_hlis|
        |        |     tot|      mc|     ute|        |  an_dst|  an_src=
|        |    _tot|     _mc|        |      ed|    miss| verflow| _searc=
h|t_search|

 1862477|   23758|    4400|       0|       0|       0|       0|       0=
|    4142|    1134|       0|       0|       0|       0|       0|   4575=
4|   11785|
 1863310|   24794|    4504|       0|       0|       0|       0|       0=
|    4089|    1183|       0|       0|       0|       0|       0|   4755=
8|   11640|
 1863604|   24183|    4383|       0|       0|       0|       0|       0=
|    3910|    1061|       0|       0|       0|       0|       0|   4600=
2|   10819|
 1864473|   23899|    4510|       0|       0|       0|       0|       0=
|    4113|    1193|       0|       0|       0|       0|       0|   4645=
1|   11798|

grep ip_dst_cache /proc/slabinfo
ip_dst_cache      1863543 1868660    384   10    1 : tunables    0    0=
    0 : slabdata 186866 186866      0

On this machine, a single "ip route flush cache" is risky=20
(commit 29e75252da20f3ab9e132c68c9aed156b87beae6 [IPV4] route cache: In=
troduce rt_genid for smooth cache invalidation)
not yet included in kernel)




