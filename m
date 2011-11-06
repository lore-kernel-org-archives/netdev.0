From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: Linux Route Cache performance tests
Date: Sun, 06 Nov 2011 19:28:40 +0100
Message-ID: <4EB6D1D8.8040604@itcare.pl>
References: <4EB6AE62.5050803@itcare.pl> <1320600597.6506.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:44872 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752933Ab1KFS2m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Nov 2011 13:28:42 -0500
In-Reply-To: <1320600597.6506.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2011-11-06 18:29, Eric Dumazet pisze:
> Le dimanche 06 novembre 2011 =C3=A0 16:57 +0100, Pawe=C5=82 Staszewsk=
i a =C3=A9crit :
>> Hello
>>
>>
>>
>> I make some networking performance tests for Linux 3.1
>>
>> Configuration:
>>
>> Linux (pktget) ---->  Linux (router) ---->  Linux (Sink)
>>
>> pktgen config:
>> clone_skb 32
>> pkt_size 64
>> delay 0
>>
>> pgset "flag IPDST_RND"
>> pgset "dst_min 10.0.0.0"
>> pgset "dst_max 10.18.255.255"
>> pgset "config 1"
>> pgset "flows 256"
>> pgset "flowlen 8"
>>
>> TX performance for this host:
>> eth0:            RX: 0.00 P/s      TX: 12346107.73 P/s      TOTAL:
>> 12346107.73 P/s
>>
>> On Linux (router):
>> grep . /proc/sys/net/ipv4/route/*
>> /proc/sys/net/ipv4/route/error_burst:500
>> /proc/sys/net/ipv4/route/error_cost:100
>> grep: /proc/sys/net/ipv4/route/flush: Permission denied
>> /proc/sys/net/ipv4/route/gc_elasticity:4
>> /proc/sys/net/ipv4/route/gc_interval:60
>> /proc/sys/net/ipv4/route/gc_min_interval:0
>> /proc/sys/net/ipv4/route/gc_min_interval_ms:500
>> /proc/sys/net/ipv4/route/gc_thresh:2000000
>> /proc/sys/net/ipv4/route/gc_timeout:60
>> /proc/sys/net/ipv4/route/max_size:8388608
>> /proc/sys/net/ipv4/route/min_adv_mss:256
>> /proc/sys/net/ipv4/route/min_pmtu:552
>> /proc/sys/net/ipv4/route/mtu_expires:600
>> /proc/sys/net/ipv4/route/redirect_load:2
>> /proc/sys/net/ipv4/route/redirect_number:9
>> /proc/sys/net/ipv4/route/redirect_silence:2048
>>
>> For the first 30secs maybee more router is forwarding ~5Mpps to the
>> Linux (Sink)
>> and some stats for this forst 30secs in attached image:
>>
>> http://imageshack.us/photo/my-images/684/test1ih.png/
>>
>> Left up - pktgen linux
>> left down - Linux router (htop)
>> Right up - Linux router (bwm-ng - showing pps)
>> Right down - Linux router (lnstat)
>>
>>
>> And all is good - performance 5Mpps until Linux router will reach ~1=
kk
>> entries
>> What You can see on next attached image:
>>
>> http://imageshack.us/photo/my-images/24/test2id.png/
>>
>> Forwarding performance drops from 5Mpps to 1,8Mpps
>> And after 3 - 4 minutes it will stop on 0,7Mpps
>>
>>
>> After flushing the route cache performance increase from 0.7Mpps to =
6Mpps
>> What You can see on next attached image:
>>
>> http://imageshack.us/photo/my-images/197/test3r.png/
>>
>> Is it possible to turn off route cache ? and see what performance wi=
ll
>> be without caching
>>
> Route cache cannot handle DDOS situation, since it will be filled,
> unless you have a lot of memory.
hmm
but what is DDOS situation for route cache ? new entries per sec ? tota=
l=20
amount of entries 1,2kk in my tests ?
Look sometimes in normal scenario You can hit
1245072 route cache entries
This is normal for BGP configurations.

The performance of route cache is ok to the point where we reach more=20
than 1245072 entries.
Router is starting forwarding packets with 5Mpps and ends at about=20
0.7Mpps when more than 1245072 entries is reached.
=46or my scenario
Random ip generation start at: 10.0.0.0 ends on 10.18.255.255
this is 1170450 random ip's

> I am not sure what you expected here. If caches misses are too freque=
nt,
> a cache is useless, whatever how its done.
Yes i understand this.
> If you disable route cache, you'll get poor performance in normal
> situation (99.9999% of cases, non DDOS), and same performance on DDOS=
,
> in 0.0001% cases
>
> Trick to disable it is to use a big (and negative) rebuild_count
>
> $ echo 3000000000>/proc/sys/net/ipv4/rt_cache_rebuild_count
> $ cat /proc/sys/net/ipv4/rt_cache_rebuild_count
> -1294967296
Ok so disabling route cache

echo 300000000000 > /proc/sys/net/ipv4/rt_cache_rebuild_count
cat /proc/sys/net/ipv4/rt_cache_rebuild_count
-647710720


I can reach 4Mpps forwarding performance without degradation in time.
   /         iface                   Rx                  =20
Tx                Total
  =20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
                lo:            0.00 P/s             0.00 P/s           =
 =20
0.00 P/s
              eth1:            1.00 P/s             1.00 P/s           =
 =20
2.00 P/s
              eth2:            0.00 P/s       3971015.09 P/s      =20
3971015.09 P/s
              eth3:      3970941.17 P/s             0.00 P/s      =20
3970941.17 P/s
  =20
-----------------------------------------------------------------------=
-------
             total:      3970942.17 P/s       3971016.09 P/s      =20
7941958.26 P/s

lnstat -c -1 -i 1 -f rt_cache -k entries
rt_cache|
  entries|
        8|
        6|
        5|
       10|
        5|
        7|
        7|
       11|
        5|
       11|
       11|
        6|
        7|
        6|


So with disabled route cache performance is better for over 1kk route=20
cache entries.
But it is static.
So i have the same performance now for generated 10k,50k,100k,1kk rando=
m=20
ip's

So yes in scenarion when You count that route cache will never reach=20
over 1kk entries performance with route cache enabled is 2x more that=20
with disabled.
But when somehow - You will reach over 1kk entries in route cache -=20
router almost stops forwarding traffic.

Thanks
Pawel

>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
