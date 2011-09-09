From: Kumar S <ps2kumar@yahoo.com>
Subject: Re: Memory leak in ip_dst_cache
Date: Fri, 9 Sep 2011 13:48:03 -0700 (PDT)
Message-ID: <1315601283.91185.YahooMailNeo@web113908.mail.gq1.yahoo.com>
References: <1315544674.20226.YahooMailNeo@web113902.mail.gq1.yahoo.com>  <1315546223.5410.23.camel@edumazet-laptop>  <1315593553.98279.YahooMailNeo@web113904.mail.gq1.yahoo.com> <1315596786.2606.3.camel@edumazet-laptop>
Reply-To: Kumar S <ps2kumar@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm15-vm0.bullet.mail.sp2.yahoo.com ([98.139.91.208]:39209 "HELO
	nm15-vm0.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933420Ab1IIUyw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Sep 2011 16:54:52 -0400
In-Reply-To: <1315596786.2606.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,
I did not=A0flush those routes explicitly. They are flushed out automat=
ically by calling=A0"rt_run_flush". It inturn calls rt_free(), but __ca=
che_free() never gets called after that. Basically, I have 512 MBytes o=
f memory on board. I want to restrict the cache to around 64k, with max=
_size. But if I do that due to this leak, TCP/IP communication stops wo=
rking when it reaches 64k.
=A0
Thanks
psk


----- Original Message -----
=46rom: Eric Dumazet <eric.dumazet@gmail.com>
To: Kumar S <ps2kumar@yahoo.com>
Cc:=20
Sent: Friday, September 9, 2011 12:33 PM
Subject: Re: Memory leak in ip_dst_cache

Le vendredi 09 septembre 2011 =E0 11:39 -0700, Kumar S a =E9crit :
> Hi Eric,
> Thanks for the response. Here is the output of the commands you menti=
oned.
>=20

Hmm, you should have included netdev in this message.

> After injecting around11k routes:
> -sh-2.05b#
> -sh-2.05b# ip route ls cache | wc
>=A0  23256=A0 162772 1166903
> -sh-2.05b#
>=20
> After route flush out:
>=20
> -sh-2.05b#
> -sh-2.05b# ip route ls cache | wc
>=A0 =A0 =A0 14=A0 =A0 =A0 88=A0 =A0  710
> -sh-2.05b#
> -sh-2.05b#
> -sh-2.05b#
> -sh-2.05b# cat /proc/slabinfo | grep ip_dst
> ip_dst_cache=A0 =A0 =A0  11673=A0 11685=A0 =A0 256=A0  15=A0 =A0 1 : =
tunables=A0 120=A0  60=A0 =A0 0 : slabdata=A0 =A0 779=A0 =A0 779=A0 =A0=
 =A0 0

Thats OK : Each tcp session has a pointer to a dst.

When you "ip route flush cache", busy dst are all invalidated.
"ip route ls cache" doesnt output invalidated dsts.

As soon as tcp session will try to send a packet, it will notice the ds=
t
is obsolete and 'free' it.


> -sh-2.05b#
> -sh-2.05b# grep . /proc/sys/net/ipv4/route/*
> /proc/sys/net/ipv4/route/error_burst:1250
> /proc/sys/net/ipv4/route/error_cost:250
> grep: /proc/sys/net/ipv4/route/flush: Permission denied
> /proc/sys/net/ipv4/route/gc_elasticity:8
> /proc/sys/net/ipv4/route/gc_interval:60
> /proc/sys/net/ipv4/route/gc_min_interval:0
> /proc/sys/net/ipv4/route/gc_min_interval_ms:500
> /proc/sys/net/ipv4/route/gc_thresh:16384
> /proc/sys/net/ipv4/route/gc_timeout:300
> /proc/sys/net/ipv4/route/max_delay:10
> /proc/sys/net/ipv4/route/max_size:2097152
> /proc/sys/net/ipv4/route/min_adv_mss:256
> /proc/sys/net/ipv4/route/min_delay:2
> /proc/sys/net/ipv4/route/min_pmtu:552
> /proc/sys/net/ipv4/route/mtu_expires:600
> /proc/sys/net/ipv4/route/redirect_load:5
> /proc/sys/net/ipv4/route/redirect_number:9
> /proc/sys/net/ipv4/route/redirect_silence:5120
> /proc/sys/net/ipv4/route/secret_interval:600
> -sh-2.05b# rtstat -c10 -i1
> rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cac=
he|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_ca=
che|rt_cache|
>=A0 entries|=A0 in_hit|in_slow_|in_slow_|in_no_ro|=A0 in_brd|in_marti|=
in_marti| out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o=
|in_hlist|out_hlis|
>=A0 =A0 =A0 =A0  |=A0 =A0 =A0 =A0 |=A0 =A0  tot|=A0 =A0 =A0 mc|=A0 =A0=
  ute|=A0 =A0 =A0 =A0 |=A0 an_dst|=A0 an_src|=A0 =A0 =A0 =A0 |=A0 =A0 _=
tot|=A0 =A0  _mc|=A0 =A0 =A0 =A0 |=A0 =A0 =A0 ed|=A0 =A0 miss| verflow|=
 _search|t_search|
>=A0 =A0 11675|=A0  27700|=A0 101014|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =
=A0  130|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0  36284|=A0  23436|=A0 =A0 =A0=
  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0=
 9658|=A0  23140|
>=A0 =A0 11675|=A0 =A0 =A0  6|=A0 =A0 =A0 18|=A0 =A0 =A0  0|=A0 =A0 =A0=
  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  2|=A0 =A0=
 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0=
 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|
>=A0 =A0 11675|=A0 =A0 =A0  2|=A0 =A0 =A0 10|=A0 =A0 =A0  0|=A0 =A0 =A0=
  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  2|=A0 =A0=
 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0=
 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|
>=A0 =A0 11675|=A0 =A0 =A0  8|=A0 =A0 =A0 18|=A0 =A0 =A0  0|=A0 =A0 =A0=
  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  2|=A0 =A0=
 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0=
 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|
>=A0 =A0 11675|=A0 =A0 =A0  6|=A0 =A0 =A0 18|=A0 =A0 =A0  0|=A0 =A0 =A0=
  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  2|=A0 =A0=
 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0=
 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|
>=A0 =A0 11675|=A0 =A0 =A0  4|=A0 =A0 =A0 16|=A0 =A0 =A0  0|=A0 =A0 =A0=
  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  4|=A0 =A0=
 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0=
 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|
>=A0 =A0 11675|=A0 =A0 =A0  8|=A0 =A0 =A0 12|=A0 =A0 =A0  0|=A0 =A0 =A0=
  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  2|=A0 =A0=
 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0=
 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|
>=A0 =A0 11675|=A0 =A0 =A0  6|=A0 =A0 =A0 10|=A0 =A0 =A0  0|=A0 =A0 =A0=
  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  2|=A0 =A0=
 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0=
 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|
>=A0 =A0 11675|=A0 =A0 =A0  2|=A0 =A0 =A0 14|=A0 =A0 =A0  0|=A0 =A0 =A0=
  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  2|=A0 =A0=
 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0=
 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|
>=A0 =A0 11675|=A0 =A0 =A0  8|=A0 =A0 =A0 12|=A0 =A0 =A0  0|=A0 =A0 =A0=
  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  2|=A0 =A0=
 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|=A0=
 =A0 =A0  0|=A0 =A0 =A0  0|=A0 =A0 =A0  0|
> -sh-2.05b#
>=20
>=20

Thats pretty low ip route usage, you dont need to tweak your tunables.

Thanks
