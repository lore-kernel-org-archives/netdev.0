From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Bug, kernel panic, NULL dereference , =?UTF-8?Q?cleanup=5Fonc?=  =?UTF-8?Q?e=20/=20icmp=5Froute=5Flookup=2Eclone=2E=31=39=2Eclone=20/=20na?=  =?UTF-8?Q?t=20=2C=20=32=2E=36=2E=33=39-rc=37-git=31=31?=
Date: Thu, 19 May 2011 09:39:00 +0300
Message-ID: <d63fd484351a3538453f230bfa5c9dd9@visp.net.lb>
References: <54ec5cd14e5e5c76aa06c2e6899299ce@visp.net.lb>
 <41a1892fed59b411bb08d3ecb0d8cda5@visp.net.lb>
 <1305711471.2983.27.camel@edumazet-laptop>
 <0a630bbf006d1210220a6ba4d55c5804@visp.net.lb>
 <1305713111.2991.1.camel@edumazet-laptop>
 <1305719047.2991.4.camel@edumazet-laptop>
 <4ae96506c000a4b3c8f78ccef836deaf@visp.net.lb>
 <1305733944.2991.45.camel@edumazet-laptop>
 <1305746989.3019.0.camel@edumazet-laptop>
 <1305782397.3019.5.camel@edumazet-laptop>
 <626ba8ae63cfc8fdb68c7f281463dc27@visp.net.lb>
 <1305786623.3019.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rev-153-13.globalproof.net ([194.146.153.13]:57598 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755454Ab1ESGjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 02:39:04 -0400
In-Reply-To: <1305786623.3019.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Thu, 19 May 2011 08:30:23 +0200, Eric Dumazet wrote:
> Le jeudi 19 mai 2011 =C3=A0 09:11 +0300, Denys Fedoryshchenko a =C3=A9=
crit :
>> On Thu, 19 May 2011 07:19:57 +0200, Eric Dumazet wrote:
>> > Le mercredi 18 mai 2011 =C3=A0 21:29 +0200, Eric Dumazet a =C3=A9c=
rit :
>> >> Le mercredi 18 mai 2011 =C3=A0 17:52 +0200, Eric Dumazet a =C3=A9=
crit :
>> >>
>> >> > Hmm, it seems we have some inetpeer refcount leak somewhere.
>> >> >
>> >> > Maybe one (struct rtable)->peer is not released on dst/rtable
>> >> removal,
>> >> > or we also leak dst/rtable (and their ->peer inetpeer)
>> >> >
>> >> > Watch :
>> >> >
>> >> > grep peer /proc/slabinfo
>> >> > grep dst /proc/slabinfo
>> >> >
>> >>
>> >> FYI, I started a bisection to find the faulty commit.
>> >>
>> >
>> > Oh well, of course this came to 2c8cec5c10bced240
>> > (ipv4: Cache learned PMTU information in inetpeer.)
>> >
>> > So my method to check if we have a leak might be wrong, since the
>> > above
>> > commit let cache full of garbage, and hope that following lookups
>> > will
>> > find and evict obsolete dst.
>> >
>> > Thats getting difficult :(
>> >
>> > Could you please send us
>> >
>> > grep . /proc/sys/net/ipv4/route/*
>> >
>> > Thanks !
>>  NewNet-PPPoE ~ # grep . /proc/sys/net/ipv4/route/*
>>  /proc/sys/net/ipv4/route/error_burst:5000
>>  /proc/sys/net/ipv4/route/error_cost:1000
>>  grep: /proc/sys/net/ipv4/route/flush: Permission denied
>>  /proc/sys/net/ipv4/route/gc_elasticity:8
>>  /proc/sys/net/ipv4/route/gc_interval:60
>>  /proc/sys/net/ipv4/route/gc_min_interval:0
>>  /proc/sys/net/ipv4/route/gc_min_interval_ms:500
>>  /proc/sys/net/ipv4/route/gc_thresh:32768
>>  /proc/sys/net/ipv4/route/gc_timeout:300
>>  /proc/sys/net/ipv4/route/max_size:524288
>>  /proc/sys/net/ipv4/route/min_adv_mss:256
>>  /proc/sys/net/ipv4/route/min_pmtu:552
>>  /proc/sys/net/ipv4/route/mtu_expires:600
>>  /proc/sys/net/ipv4/route/redirect_load:20
>>  /proc/sys/net/ipv4/route/redirect_number:9
>>  /proc/sys/net/ipv4/route/redirect_silence:20480
>>
>>  I think it is default one.
>>
>>  PMTU is very actual for that, as it is pppoe, and up to 2k=20
>> interfaces
>>  terminated there.
>>
>
> Yes, and every time an interface is added -> new route added, route
> cache is invalidated (we change rt_genid)
 If it matters, there is ifb with shaper on it (for shaping from ppp to=
=20
 world).

>
>>  I don't know, if it matters, but
>>  iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS
>>  --clamp-mss-to-pmtu
>>  also there.
>>
>>  I can generate and put "ip route ls cache" and any other info.
>>
>
> Hmm would you please send :
>
> rtstat -c10 -i1
 Note, it is offpeak time now, just 1447 interfaces, peak is after 12=20
 hours

 NewNet-PPPoE ~ # ./rtstat -c10 -i1
 rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cach=
e|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cac=
he|rt_cache|
  entries|  in_hit|in_slow_|in_slow_|in_no_ro| =20
 in_brd|in_marti|in_marti|=20
 out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist=
|out_hlis|
         |        |     tot|      mc|     ute|        |  an_dst| =20
 an_src|        |    _tot|     _mc|        |      ed|    miss| verflow|=
=20
 _search|t_search|
     2256|355568844|85929285|    1649|       9|   59954|     293|   =20
 1460|14423031| 6865540|       0|       0|       0|       0|      =20
 0|22719682| 1262044|
     3408|   14887|    2117|       0|       0|       1|       1|      =20
 0|     761|     159|       0|       0|       0|       0|       0|   =20
 1209|      46|
     3189|   17185|    5613|       0|       0|       1|       0|      =20
 0|     987|     334|       0|       0|       0|       0|       0|    =20
 684|      22|
     2698|   18312|    3417|       0|       0|       5|       0|      =20
 0|     923|     242|       0|       0|       0|       0|       0|    =20
 498|      10|
     4996|   17268|    3604|       0|       0|       1|       0|      =20
 0|     847|     240|       0|       0|       0|       0|       0|    =20
 830|      23|
     2457|   16439|    4227|       0|       0|       4|       0|      =20
 0|     663|     268|       0|       0|       0|       0|       0|    =20
 655|      22|
     4763|   16895|    3634|       0|       0|       1|       0|      =20
 0|     880|     266|       0|       0|       0|       0|       0|    =20
 896|      32|
     6299|   19169|    2220|       0|       0|       2|       0|      =20
 0|     898|     206|       0|       0|       0|       0|       0|   =20
 1213|      60|
     7511|   20059|    1597|       0|       0|       2|       1|      =20
 0|     855|     197|       0|       0|       0|       0|       0|   =20
 1917|      54|
     9271|   17731|    2919|       0|       0|       0|       0|      =20
 0|     855|     223|       0|       0|       0|       0|       0|   =20
 1664|     101|

