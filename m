From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] Add prefetches in net/ipv4/route.c
Date: Fri, 29 Jul 2005 19:57:35 +0200
Message-ID: <42EA6E0F.8060705@cosmosbay.com>
References: <42E8FF24.9070009@cosmosbay.com>	<20050728.123922.126777020.davem@davemloft.net>	<42E94680.8060309@cosmosbay.com>	<20050728.135826.63129319.davem@davemloft.net>	<42E94D11.4090002@cosmosbay.com> <17130.16951.581026.863431@robur.slu.se> <42EA6202.703@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>,
        Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <42EA6202.703@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rick Jones a =E9crit :
> Robert Olsson wrote:
>=20
>> Eric Dumazet writes:
>>
>>  > I have no profiling info for this exact patch, I'm sorry David.
>>  > On a dual opteron machine, this thing from ip_route_input() is very=
=20
>> expensive :
>>  >  >   RT_CACHE_STAT_INC(in_hlist_search);
>>  >  > ip_route_input() use a total of 3.4563 % of one cpu, but this=20
>> 'increment' takes 1.20 % !!!
>>
>>  Very weird if the statscounter taking a third of ip_route_input.
>>
>>  > Sometime I wonder if oprofile can be trusted :(
>>  >  > Maybe we should increment a counter on the stack and do a final
>>  >     if (counter !=3D 0)
>>  >         RT_CACHE_STAT_ADD(in_hlist_search, counter);
>>
>>  My experiences from playing with prefetching eth_type_trans in this=20
>>  case. One must look in the total performance not just were the=20
>>  prefetching is done. In this case I was able to get eth_type_trans
>>  down in the profile list but other functions increased so performance
>>  was the same or lower. This needs to be sorted out...=20
>=20
>=20
> How many of the architectures have PMU's that can give us cache miss=20
> statistics?  Itanium does, and can go so far as to tell us which=20
> addresses and instructions are involved - do the others?
>=20
> That sort of data would seem to be desirable in this sort of situation.
>=20
> rick jones
>=20
>=20

oprofile on AMD64 can gather lots of data, DATA_CACHE_MISSES for example.=
..

But I think I know what happens...

nm -v /usr/src/linux/vmlinux | grep -5 rt_cache_stat

ffffffff804c6a80 b rover.5
ffffffff804c6a88 b last_gc.2
ffffffff804c6a90 b rover.3
ffffffff804c6a94 b equilibrium.4
ffffffff804c6a98 b ip_fallback_id.7
ffffffff804c6aa0 B rt_cache_stat
ffffffff804c6aa8 b ip_rt_max_size
ffffffff804c6aac b ip_rt_debug
ffffffff804c6ab0 b rt_deadline

So rt_cache_stat (which is a read only pointer) is in the middle of a hot=
 cache line (some parts of it are written over and over), that=20
probably ping pong between CPUS.

Time to provide a patch to carefully place all the static data from net/i=
pv4/route.c into 2 parts : mostly readonly, and others... :)

Eric
