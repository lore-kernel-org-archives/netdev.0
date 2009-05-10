From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: reduce number of reference taken on sk_refcnt
Date: Sun, 10 May 2009 12:45:56 +0200
Message-ID: <4A06B064.9080801@cosmosbay.com>
References: <20090508.144859.152310605.davem@davemloft.net>	<4A057387.4080308@cosmosbay.com>	<20090509.133454.111098477.davem@davemloft.net> <20090509.134002.258408495.davem@davemloft.net> <4A067D9E.7050706@cosmosbay.com> <4A0685A0.8020002@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: khc@pm.waw.pl, netdev@vger.kernel.org, satoru.satoh@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34536 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939AbZEJKqH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2009 06:46:07 -0400
In-Reply-To: <4A0685A0.8020002@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Eric Dumazet a =E9crit :
>> David Miller a =E9crit :
>>> From: David Miller <davem@davemloft.net>
>>> Date: Sat, 09 May 2009 13:34:54 -0700 (PDT)
>>>
>>>> Consider the case where we always send some message on CPU A and
>>>> then process the ACK on CPU B.  We'll always be cancelling the
>>>> timer on a foreign cpu.
>>> I should also mention that TCP has a peculiar optimization of timer=
s
>>> that is likely being thwarted by your workload.  It never deletes
>>> timers under normal operation, it simply lets them still expire
>>> and the handler notices that there is "nothing to do" and returns.
>> Yes, you refer to INET_CSK_CLEAR_TIMERS condition, never set.
>>
>>> But when the connection does shut down, we have to purge all of
>>> these timers.
>>>
>>> That could be another part of why you see timers in your profile.
>>>
>>>
>> Well, in my workload they should never expire, since application exc=
hange
>> enough data on both direction, and they are no losses (Gigabit LAN c=
ontext)
>>
>> On machine acting as a server (the one I am focusing to, of course),
>> each incoming frame :
>>
>> - Contains ACK for the previous sent frame
>> - Contains data provided by the client.
>> - Starts a timer for delayed ACK
>>
>> Then server applications reacts and sends a new payload, and TCP sta=
ck
>> - Sends a frame including ACK for previous received frame
>> - Contains data provided by server application
>> - Starts a timer for retransmiting this frame if no ACK is received =
later.
>>
>> So yes, each incoming and each outgoing frame is going to call mod_t=
imer()
>>
>> Problem is that incoming process is done by CPU 0 (the one that is d=
edicated
>> to NAPI processing because of stress situation, cpu 100% in softirq =
land),
>> and outgoing processing done by other cpus in the machine.
>>
>> offsetof(struct inet_connection_sock, icsk_retransmit_timer)=3D0x208
>> offsetof(struct inet_connection_sock, icsk_delack_timer)=3D0x238
>>
>> So there are cache line ping-pongs, but oprofile seems to point
>> to a spinlock contention in lock_timer_base(), I dont know why...
>> shouldnt (in my workload) delack_timer all belongs to cpu 0, and=20
>> retransmit_timers to other cpus ?=20
>>
>> Or is mod_timer never migrates an already established timer ?
>>
>> That would explain the lock contention on timer_base, we should
>> take care of it if possible.
>>
>=20
> ftrace is my friend :)
>=20
> Problem is the application, when doing it recv() call
> is calling tcp_send_delayed_ack() too.
>=20
> So yes, cpus are fighting on icsk_delack_timer and their
> timer_base pretty hard.
>=20
>=20

Changing tcp_prequeue to use same delack timer than tcp_send_delayed_ac=
k()
helps a lot, but I dont know if its correct or not.

It was already changed recently in commit 0c266898b42fe4e4e2f9edfc9d347=
4c10f93aa6a

Author: Satoru SATOH <satoru.satoh@gmail.com>
Date:   Mon May 4 11:11:01 2009 -0700

    tcp: Fix tcp_prequeue() to get correct rto_min value

    tcp_prequeue() refers to the constant value (TCP_RTO_MIN) regardles=
s of
    the actual value might be tuned. The following patches fix this and=
 make
    tcp_prequeue get the actual value returns from tcp_rto_min().

but as reader will reset timeout to an even smaller value, I wonder if
we should not select this smaller value sooner, to avoid a mod_timer pi=
ng/pong

TCP_RTO_MIN (200 ms) was too big, but (3 * tcp_rto_min(sk)) / 4 might
be too big too...

New profile data of cpu0 (no more timer stuff, and improved bandwidth
by more than 10 %). back to normal device driver load and scheduler (wa=
keups)

104452   104452        13.3363  13.3363    bnx2_poll_work
56103    160555         7.1631  20.4994    __wake_up
38650    199205         4.9348  25.4342    task_rq_lock
37947    237152         4.8450  30.2792    __slab_alloc
37229    274381         4.7533  35.0326    tcp_v4_rcv
34781    309162         4.4408  39.4734    __alloc_skb
27977    337139         3.5721  43.0454    skb_release_data
26516    363655         3.3855  46.4309    ip_rcv
26399    390054         3.3706  49.8015    resched_task
26059    416113         3.3272  53.1287    __inet_lookup_established
25518    441631         3.2581  56.3868    sock_wfree
23515    465146         3.0024  59.3892    ip_route_input
19811    484957         2.5294  61.9186    select_task_rq_fair
16901    501858         2.1579  64.0765    __kfree_skb
16466    518324         2.1024  66.1788    __enqueue_entity
16008    534332         2.0439  68.2227    sched_clock_cpu
15486    549818         1.9772  70.2000    try_to_wake_up
14641    564459         1.8693  72.0693    update_curr
13725    578184         1.7524  73.8217    enqueue_task_fair
13304    591488         1.6986  75.5203    __kmalloc_track_caller
13190    604678         1.6841  77.2044    kmem_cache_alloc
12016    616694         1.5342  78.7386    __tcp_prequeue
10989    627683         1.4031  80.1416    __wake_up_common
10623    638306         1.3563  81.4980    netif_receive_skb
10004    648310         1.2773  82.7753    place_entity


Patch follows for RFC only (not Signed-of...), and based on net-next-2.=
6=20

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 19f4150..906f597 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -922,10 +922,13 @@ static inline int tcp_prequeue(struct sock *sk, s=
truct sk_buff *skb)
 	} else if (skb_queue_len(&tp->ucopy.prequeue) =3D=3D 1) {
 		wake_up_interruptible_poll(sk->sk_sleep,
 					   POLLIN | POLLRDNORM | POLLRDBAND);
-		if (!inet_csk_ack_scheduled(sk))
+		if (!inet_csk_ack_scheduled(sk)) {
+			unsigned int delay =3D (3 * tcp_rto_min(sk)) / 4;
+
+			delay =3D min(inet_csk(sk)->icsk_ack.ato, delay);
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
-						  (3 * tcp_rto_min(sk)) / 4,
-						  TCP_RTO_MAX);
+						  delay, TCP_RTO_MAX);
+		}
 	}
 	return 1;
 }

