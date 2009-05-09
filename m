From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: reduce number of reference taken on sk_refcnt
Date: Sat, 09 May 2009 14:13:59 +0200
Message-ID: <4A057387.4080308@cosmosbay.com>
References: <m31vqzwzae.fsf@intrepid.localdomain>	<4A044BE7.3070308@cosmosbay.com> <20090508.144859.152310605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42955 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752815AbZEIMOL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 08:14:11 -0400
In-Reply-To: <20090508.144859.152310605.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 08 May 2009 17:12:39 +0200
>=20
>> For example, we can avoid the dst_release() cache miss if this
>> is done in start_xmit(), and not later in TX completion while freein=
g skb.
>> I tried various patches in the past but unfortunatly it seems
>> only safe way to do this is in the driver xmit itself, not in core
>> network stack. This would need many patches, one for each driver.
>=20
> There might be a way around having to hit every driver.
>=20
> The case we can't muck with is when the route will be used.
> Devices which create this kind of situation can be marked with
> a flag bit in struct netdevice.  If that flag bit isn't set,
> you can drop the DST in dev_hard_start_xmit().

Yes, this is a possibility, I'll think about it, thank you.
I'll have to recall which devices would need this flag (loopback for su=
re)..


>=20
>> [PATCH] net: reduce number of reference taken on sk_refcnt
>>
>> Current sk_wmem_alloc schema uses a sk_refcnt taken for each packet
>> in flight. This hurts some workloads at TX completion time, because
>> sock_wfree() has three cache lines to touch at least.
>> (one for sk_wmem_alloc, one for testing sk_flags, one
>>  to decrement sk_refcnt)
>>
>> We could use only one reference count, taken only when sk_wmem_alloc
>> is changed from or to ZERO value (ie one reference count for any num=
ber
>> of in-flight packets)
>>
>> Not all atomic_add() must be changed to atomic_add_return(), if we
>> know current sk_wmem_alloc is already not null.
>>
>> This patch reduces by one number of cache lines dirtied in sock_wfre=
e()
>> and number of atomic operation in some workloads.=20
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> I like this idea.  Let me know when you have some at least
> basic performance numbers and wish to submit this formally.

Sure, but I am focusing right now on the opposite situation
(many tcp flows but with small in/out trafic, where this patch
has no impact, since I have only (0 <--> !0) transitions.)

BTW, oprofile for this kind of workload gives a surprising result.
(timer stuff being *very* expensive)
CPU doing the NAPI stuff has this profile :

88688    88688          9.7805   9.7805    lock_timer_base
72692    161380         8.0165  17.7970    bnx2_poll_work
66958    228338         7.3842  25.1812    mod_timer
47980    276318         5.2913  30.4724    __wake_up
43312    319630         4.7765  35.2489    task_rq_lock
43193    362823         4.7633  40.0122    __slab_alloc
36388    399211         4.0129  44.0251    __alloc_skb
30285    429496         3.3398  47.3650    skb_release_data
29236    458732         3.2242  50.5891    ip_rcv
29219    487951         3.2223  53.8114    resched_task
29094    517045         3.2085  57.0199    __inet_lookup_established
28695    545740         3.1645  60.1844    tcp_v4_rcv
27479    573219         3.0304  63.2148    sock_wfree
26722    599941         2.9469  66.1617    ip_route_input
21401    621342         2.3601  68.5218    select_task_rq_fair
19390    640732         2.1383  70.6601    __kfree_skb
17763    658495         1.9589  72.6190    sched_clock_cpu
17565    676060         1.9371  74.5561    try_to_wake_up
17366    693426         1.9151  76.4712    __enqueue_entity
16174    709600         1.7837  78.2549    update_curr
14323    723923         1.5795  79.8345    __kmalloc_track_caller
14003    737926         1.5443  81.3787    enqueue_task_fair
12456    750382         1.3737  82.7524    __tcp_prequeue
12212    762594         1.3467  84.0991    __wake_up_common
11437    774031         1.2613  85.3604    kmem_cache_alloc
10927    784958         1.2050  86.5654    place_entity
10535    795493         1.1618  87.7272    netif_receive_skb
9971     805464         1.0996  88.8268    ipt_do_table
8551     814015         0.9430  89.7698    internal_add_timer

