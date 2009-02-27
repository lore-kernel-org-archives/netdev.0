From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Fri, 27 Feb 2009 21:12:06 +0100
Message-ID: <49A84916.9090106@cosmosbay.com>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <alpine.DEB.1.10.0902271340320.9381@qirst.com> <49A8375A.6000006@cosmosbay.com> <alpine.DEB.1.10.0902271441220.9381@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kenny Chang <kchang@athenacr.com>, netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58756 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753963AbZB0UMr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 15:12:47 -0500
In-Reply-To: <alpine.DEB.1.10.0902271441220.9381@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Fri, 27 Feb 2009, Eric Dumazet wrote:
>=20
>> Christoph Lameter a ?crit :
>>> On Fri, 30 Jan 2009, Eric Dumazet wrote:
>>>> 2.6.29-rc contains UDP receive improvements (lockless)
>>>> Problem is multicast handling was not yet updated, but could be :)
>>> When will that happen?
>> When proven necessary :)
>>
>> Kenny problem is about scheduling storm. The extra spin_lock() in UD=
P
>> multicast receive is not a problem.
>=20
> My tests here show that 2.6.29-rc5 still looses ~5usec vs. 2.6.22 via
> UDP. This would fix a regression.....
>=20

Could you elaborate ?

I just retried Kenny test here. As one cpu is looping in ksoftirqd, onl=
y this cpu
touches the spin_lock, so spin_lock()/spin_unlock() is free.

oprofile shows that udp stack is lightweight in this case. Problem is a=
bout wakeing up
so many threads...

CPU: Core 2, speed 3000.16 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a u=
nit mask of 0x00 (Unhalted core cycles) count 100000
samples  cum. samples  %        cum. %     symbol name
356857   356857        15.1789  15.1789    schedule
274028   630885        11.6557  26.8346    mwait_idle
189218   820103         8.0484  34.8829    __skb_recv_datagram
116903   937006         4.9725  39.8554    skb_release_data
103152   1040158        4.3876  44.2430    lock_sock_nested
89600    1129758        3.8111  48.0541    udp_recvmsg
74171    1203929        3.1549  51.2089    copy_to_user
72299    1276228        3.0752  54.2842    set_next_entity
60392    1336620        2.5688  56.8529    sched_clock_cpu
54026    1390646        2.2980  59.1509    __slab_free
50212    1440858        2.1358  61.2867    prepare_to_wait_exclusive
38689    1479547        1.6456  62.9323    cpu_idle
38142    1517689        1.6224  64.5547    __switch_to
36701    1554390        1.5611  66.1157    hrtick_start_fair
36673    1591063        1.5599  67.6756    dst_release
36268    1627331        1.5427  69.2183    sys_recvfrom
35052    1662383        1.4909  70.7092    kmem_cache_free
32680    1695063        1.3900  72.0992    pick_next_task_fair
31209    1726272        1.3275  73.4267    try_to_wake_up
30382    1756654        1.2923  74.7190    dequeue_task_fair
29048    1785702        1.2356  75.9545    __copy_skb_header
28801    1814503        1.2250  77.1796    sock_def_readable
28655    1843158        1.2188  78.3984    enqueue_task_fair
27232    1870390        1.1583  79.5567    update_curr
21688    1892078        0.9225  80.4792    copy_from_user
18832    1910910        0.8010  81.2802    sysenter_past_esp
17732    1928642        0.7542  82.0345    finish_task_switch
17583    1946225        0.7479  82.7824    resched_task
17367    1963592        0.7387  83.5211    native_sched_clock
15691    1979283        0.6674  84.1885    task_rq_lock
15352    1994635        0.6530  84.8415    sock_queue_rcv_skb
15022    2009657        0.6390  85.4804    udp_queue_rcv_skb
13999    2023656        0.5954  86.0759    __update_sched_clock
12284    2035940        0.5225  86.5984    skb_copy_datagram_iovec
11869    2047809        0.5048  87.1032    release_sock
10986    2058795        0.4673  87.5705    __wake_up_sync
10488    2069283        0.4461  88.0166    sock_recvmsg
9686     2078969        0.4120  88.4286    skb_queue_tail
9425     2088394        0.4009  88.8295    sys_socketcall


