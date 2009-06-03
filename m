From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Wed, 03 Jun 2009 23:02:53 +0200
Message-ID: <4A26E4FD.5010405@gmail.com>
References: <200905292344.56814.rusty@rustcorp.com.au> <4A1FFB04.30305@gmail.com> <200906012157.29465.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Divy Le Ray <divy@chelsio.com>,
	Roland Dreier <rolandd@cisco.com>,
	Pavel Emelianov <xemul@openvz.org>,
	Dan Williams <dcbw@redhat.com>,
	libertas-dev@lists.infradead.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59656 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752712AbZFCVDw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 17:03:52 -0400
In-Reply-To: <200906012157.29465.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell a =E9crit :
> On Sat, 30 May 2009 12:41:00 am Eric Dumazet wrote:
>> Rusty Russell a =E9crit :
>>> DaveM points out that there are advantages to doing it generally (i=
t's
>>> more likely to be on same CPU than after xmit), and I couldn't find
>>> any new starvation issues in simple benchmarking here.
>> If really no starvations are possible at all, I really wonder why so=
me
>> guys added memory accounting to UDP flows. Maybe they dont run "simp=
le
>> benchmarks" but real apps ? :)
>=20
> Well, without any accounting at all you could use quite a lot of memo=
ry as=20
> there are many places packets can be queued.
>=20
>> For TCP, I agree your patch is a huge benefit, since its paced by re=
mote
>> ACKS and window control
>=20
> I doubt that.  There'll be some cache friendliness, but I'm not sure =
it'll be=20
> measurable, let alone "huge".  It's the win to drivers which don't ha=
ve a=20
> timely and batching tx free mechanism which I aim for.

At 250.000 packets/second on a Gigabit link, this is huge, I can tell y=
ou.
(250.000 incoming packets and 250.000 outgoing packets per second, 700 =
Mbit/s)

According to this oprofile on CPU0 (dedicated to softirqs on one bnx2 e=
th adapter)

We can see sock_wfree() being number 2 on the profile, because it touch=
es three cache lines per socket and
transmited packet in TX completion handler.

Also, taking a reference on socket for each xmit packet in flight is ve=
ry expensive, since it slows
down receiver in __udp4_lib_lookup(). Several cpus are fighting for sk-=
>refcnt cache line.


CPU: Core 2, speed 3000.24 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a u=
nit mask of 0x00 (Unhalted core cycles) count 100000
samples  cum. samples  %        cum. %     symbol name
21215    21215         11.8847  11.8847    bnx2_poll_work
17239    38454          9.6573  21.5420    sock_wfree      << effect of=
 udp memory accounting >>
14817    53271          8.3005  29.8425    __slab_free
14635    67906          8.1986  38.0411    __udp4_lib_lookup
11425    79331          6.4003  44.4414    __alloc_skb
9710     89041          5.4396  49.8810    __slab_alloc
8095     97136          4.5348  54.4158    __udp4_lib_rcv
7831     104967         4.3869  58.8027    sock_def_write_space
7586     112553         4.2497  63.0524    ip_rcv
7518     120071         4.2116  67.2640    skb_dma_unmap
6711     126782         3.7595  71.0235    netif_receive_skb
6272     133054         3.5136  74.5371    udp_queue_rcv_skb
5262     138316         2.9478  77.4849    skb_release_data
5023     143339         2.8139  80.2988    __kmalloc_track_caller
4070     147409         2.2800  82.5788    kmem_cache_alloc
3216     150625         1.8016  84.3804    ipt_do_table
2576     153201         1.4431  85.8235    skb_queue_tail



