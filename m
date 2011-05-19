From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Bug, kernel panic, NULL dereference , =?UTF-8?Q?cleanup=5Fonc?=  =?UTF-8?Q?e=20/=20icmp=5Froute=5Flookup=2Eclone=2E=31=39=2Eclone=20/=20na?=  =?UTF-8?Q?t=20=2C=20=32=2E=36=2E=33=39-rc=37-git=31=31?=
Date: Thu, 19 May 2011 09:11:00 +0300
Message-ID: <626ba8ae63cfc8fdb68c7f281463dc27@visp.net.lb>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rev-153-13.globalproof.net ([194.146.153.13]:45759 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S932267Ab1ESGLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 02:11:03 -0400
In-Reply-To: <1305782397.3019.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Thu, 19 May 2011 07:19:57 +0200, Eric Dumazet wrote:
> Le mercredi 18 mai 2011 =C3=A0 21:29 +0200, Eric Dumazet a =C3=A9crit=
 :
>> Le mercredi 18 mai 2011 =C3=A0 17:52 +0200, Eric Dumazet a =C3=A9cri=
t :
>>
>> > Hmm, it seems we have some inetpeer refcount leak somewhere.
>> >
>> > Maybe one (struct rtable)->peer is not released on dst/rtable=20
>> removal,
>> > or we also leak dst/rtable (and their ->peer inetpeer)
>> >
>> > Watch :
>> >
>> > grep peer /proc/slabinfo
>> > grep dst /proc/slabinfo
>> >
>>
>> FYI, I started a bisection to find the faulty commit.
>>
>
> Oh well, of course this came to 2c8cec5c10bced240
> (ipv4: Cache learned PMTU information in inetpeer.)
>
> So my method to check if we have a leak might be wrong, since the=20
> above
> commit let cache full of garbage, and hope that following lookups=20
> will
> find and evict obsolete dst.
>
> Thats getting difficult :(
>
> Could you please send us
>
> grep . /proc/sys/net/ipv4/route/*
>
> Thanks !
 NewNet-PPPoE ~ # grep . /proc/sys/net/ipv4/route/*
 /proc/sys/net/ipv4/route/error_burst:5000
 /proc/sys/net/ipv4/route/error_cost:1000
 grep: /proc/sys/net/ipv4/route/flush: Permission denied
 /proc/sys/net/ipv4/route/gc_elasticity:8
 /proc/sys/net/ipv4/route/gc_interval:60
 /proc/sys/net/ipv4/route/gc_min_interval:0
 /proc/sys/net/ipv4/route/gc_min_interval_ms:500
 /proc/sys/net/ipv4/route/gc_thresh:32768
 /proc/sys/net/ipv4/route/gc_timeout:300
 /proc/sys/net/ipv4/route/max_size:524288
 /proc/sys/net/ipv4/route/min_adv_mss:256
 /proc/sys/net/ipv4/route/min_pmtu:552
 /proc/sys/net/ipv4/route/mtu_expires:600
 /proc/sys/net/ipv4/route/redirect_load:20
 /proc/sys/net/ipv4/route/redirect_number:9
 /proc/sys/net/ipv4/route/redirect_silence:20480

 I think it is default one.

 PMTU is very actual for that, as it is pppoe, and up to 2k interfaces=20
 terminated there.

 I don't know, if it matters, but
 iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS=20
 --clamp-mss-to-pmtu
 also there.

 I can generate and put "ip route ls cache" and any other info.

