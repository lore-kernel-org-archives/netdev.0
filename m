From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Loopback performance from kernel 2.6.12 to 2.6.37
Date: Thu, 18 Nov 2010 18:41:53 +0100
Message-ID: <1290102113.2781.237.camel@edumazet-laptop>
References: <1288954189.28003.178.camel@firesoul.comx.local>
	 <1288988955.2665.297.camel@edumazet-laptop>
	 <1289213926.15004.19.camel@firesoul.comx.local>
	 <1289214289.2820.188.camel@edumazet-laptop>
	 <1289228785.2820.203.camel@edumazet-laptop>
	 <1289311159.17448.9.camel@traveldev.cxnet.dk>
	 <1289312178.17448.20.camel@traveldev.cxnet.dk>
	 <1289312742.18992.21.camel@edumazet-laptop>
	 <1290088353.2781.137.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Jesper Dangaard Brouer <jdb@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40788 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759991Ab0KRRmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 12:42:01 -0500
Received: by wwa36 with SMTP id 36so3596665wwa.1
        for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 09:42:00 -0800 (PST)
In-Reply-To: <1290088353.2781.137.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 18 novembre 2010 =C3=A0 14:52 +0100, Eric Dumazet a =C3=A9crit=
 :
> Le mardi 09 novembre 2010 =C3=A0 15:25 +0100, Eric Dumazet a =C3=A9cr=
it :
>=20
> > So far, so good. These are the expected numbers. Now we have to
> > understand why corei7 gets 38 seconds instead of 8 :)
> >=20
> >=20
>=20
> My tests show a problem with backlog processing, and too big TCP
> windows. (at least on loopback and wild senders)
>=20
> Basically, with huge tcp windows we have now (default 4 Mbytes),
> the reader process can have to process up to 4Mbytes of backlogged da=
ta
> in __release_sock() before returning from its 'small' read(fd, buffer=
,
> 1024) done by netcat.
>=20
> While it processes this backlog, it sends tcp ACKS, allowing sender t=
o
> send new frames that might be dropped because of sk_rcvqueues_full(),=
 or
> continue to fill receive queue up to the receiver window, feeding the
> task in __release_sock() [loop]
>=20
>=20
> This blows cpu caches completely [data is queued, and the dequeue is
> done long after], and latency of a single read() can be very high. Th=
is
> blocks the pipeline of user processing eventually.
>=20
>=20
> <disgress>
> I also understand why UDP latencies are so impacted. If we receive a
> burst of frames on same socket, the user process reading first frame
> might be forced to process the backlog before returning to userland.
>=20
> Really we must zap lock_sock() from UDP input path.
>=20
> commit 95766fff6b9a78d1 ([UDP]: Add memory accounting) was a big erro=
r.
> </disgress>
>=20
>=20
>=20
> On my server machine with 6Mbytes of L2 cache, you dont see the probl=
em,
> while on my laptop with 3Mbytes of L2 cache, you can see the problem.
>=20
> I caught this because of new SNMP counter added in 2.6.34
> (TCPBacklogDrop), that could easily take 1000 increments during the
> test.
>=20
>=20
> I built a test program, maybe easier to use than various netcat flavo=
rs
> It also use two tasks only, thats better if you have a core 2 Duo lik=
e
> me on my laptop ;)
>=20
> To reproduce the problem, run it with option -l 4M
>=20
> $ netstat -s|grep TCPBacklogDrop
>     TCPBacklogDrop: 788
> $ time ./loopback_transfert -l 1k;netstat -s|grep TCPBacklogDrop
>=20
> real	0m14.013s
> user	0m0.630s
> sys	0m13.250s
>     TCPBacklogDrop: 788
> $ time ./loopback_transfert -l 128k;netstat -s|grep TCPBacklogDrop
>=20
> real	0m7.447s
> user	0m0.030s
> sys	0m5.490s
>     TCPBacklogDrop: 789
> $ time ./loopback_transfert -l 1M;netstat -s|grep TCPBacklogDrop
>=20
> real	0m11.206s
> user	0m0.020s
> sys	0m7.150s
>     TCPBacklogDrop: 793
> $ time ./loopback_transfert -l 4M;netstat -s|grep TCPBacklogDrop
>=20
> real	0m10.347s
> user	0m0.000s
> sys	0m6.120s
>     TCPBacklogDrop: 1510
> $ time ./loopback_transfert -l 16k;netstat -s|grep TCPBacklogDrop
>=20
> real	0m6.810s
> user	0m0.040s
> sys	0m6.670s
>     TCPBacklogDrop: 1511
>=20

I forgot to include test results for my dev machine (server class
machine, 8 Mbytes of L2 cache) NUMA=20
2 sockets : Intel(R) Xeon(R) CPU           E5540  @ 2.53GHz

# netstat -s|grep TCPBacklogDrop
    TCPBacklogDrop: 8891
# time ./loopback_transfert -l 16k;netstat -s|grep TCPBacklogDrop

real	0m7.033s
user	0m0.010s
sys	0m4.580s
    TCPBacklogDrop: 9239
# time ./loopback_transfert -l 1M;netstat -s|grep TCPBacklogDrop

real	0m5.408s
user	0m0.000s
sys	0m2.880s
    TCPBacklogDrop: 9243
# time ./loopback_transfert -l 4M;netstat -s|grep TCPBacklogDrop

real	0m2.965s
user	0m0.000s
sys	0m2.070s
    TCPBacklogDrop: 10485
# time ./loopback_transfert -l 6M;netstat -s|grep TCPBacklogDrop

real	0m7.711s
user	0m0.000s
sys	0m3.180s
    TCPBacklogDrop: 13537
# time ./loopback_transfert -l 8M;netstat -s|grep TCPBacklogDrop

real	0m11.497s
user	0m0.020s
sys	0m3.830s
    TCPBacklogDrop: 17108


As soon as our working set is larger than L2 cache, this is very slow.

for the -l 8M bench :

# Events: 7K cycles
#
# Overhead  Command      Shared Object                               Sy=
mbol
# ........  .......  .................  ...............................=
=2E...
#
    40.97%  loopback_transf  [kernel.kallsyms]  [k] copy_user_generic_s=
tring
    18.57%    :8968  [kernel.kallsyms]  [k] copy_user_generic_string
     3.54%    :8968  [kernel.kallsyms]  [k] get_page_from_freelist
     3.36%    :8968  [kernel.kallsyms]  [k] tcp_sendmsg
     1.17%    :8968  [kernel.kallsyms]  [k] put_page
     0.99%    :8968  [kernel.kallsyms]  [k] free_hot_cold_page
     0.99%    :8968  [kernel.kallsyms]  [k] __might_sleep
     0.88%    :8968  [kernel.kallsyms]  [k] __ticket_spin_lock
     0.81%  loopback_transf  [kernel.kallsyms]  [k] free_pcppages_bulk
     0.79%    :8968  [kernel.kallsyms]  [k] __alloc_pages_nodemask
     0.63%  loopback_transf  [kernel.kallsyms]  [k] put_page
     0.63%  loopback_transf  [kernel.kallsyms]  [k] __might_sleep
     0.63%  loopback_transf  [kernel.kallsyms]  [k] tcp_transmit_skb
     0.57%    :8968  [kernel.kallsyms]  [k] skb_release_data
     0.55%  loopback_transf  [kernel.kallsyms]  [k] free_hot_cold_page
     0.53%    :8968  [kernel.kallsyms]  [k] tcp_ack
     0.50%  loopback_transf  [kernel.kallsyms]  [k] __inet_lookup_estab=
lished
     0.49%  loopback_transf  [kernel.kallsyms]  [k] skb_copy_datagram_i=
ovec
     0.47%    :8968  [kernel.kallsyms]  [k] __rmqueue
     0.45%    :8968  [kernel.kallsyms]  [k] get_pageblock_flags_group
     0.41%    :8968  [kernel.kallsyms]  [k] zone_watermark_ok
     0.41%    :8968  [kernel.kallsyms]  [k] __inc_zone_state
     0.40%  loopback_transf  [kernel.kallsyms]  [k] skb_release_data
     0.39%    :8968  [kernel.kallsyms]  [k] tcp_transmit_skb


