From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Sun, 25 Oct 2009 20:28:25 +0100
Message-ID: <4AE4A6D9.5090307@gmail.com>
References: <20091017221857.GG1925@kvack.org> <200910250249.00382.opurdila@ixiacom.com> <4AE40DBE.8050505@gmail.com> <200910251719.13748.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, Benjamin LaHaise <bcrl@lhnet.ca>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56556 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553AbZJYT2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 15:28:30 -0400
In-Reply-To: <200910251719.13748.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
> On Sunday 25 October 2009 10:35:10 you wrote:
>>> Got some time today and did some experiments myself. The test is de=
leting
>>> 1000 dummy interfaces (interface status down, no IP/IPv6 addresses
>>> assigned) on a UP non-preempt ppc750 @800Mhz system.
>>>
>>> 1. Ben's patch:
>>>
>>> real    0m 3.42s
>>> user    0m 0.00s
>>> sys     0m 0.00s
>>>
>>> 2. Eric's schedule_timeout_uninterruptible(1);
>>>
>>> real    0m 3.00s
>>> user    0m 0.00s
>>> sys     0m 0.00s
>>>
>>> 3. Simple synchronize_rcu_expedited()
>>>
>>> This doesn't seem to work well with the UP non-preempt case since
>>> synchronize_rcu_expedited() is a noop in this case - turning
>>> netdev_wait_allrefs() into a while(1) loop.
>> Thanks for these numbers. I presume HZ value is 1000 on this platfor=
m ?
>>
>=20
> Yes. I've attach the full config to this email as well.
>=20
>> Could you give us your scripts so that we can use same "benchmark" ?
>>
>=20
> Sure, I've attached the hack module code I've used.=20
>=20
> For creating interfaces: echo 1000 > /proc/sys/net/ndst/add
> For deleting interface echo start_ifindex stop_ifindex > /proc/sys/ne=
t/ndst/del
>=20
> Some more information:
>=20
> - on our old and optimized kernel I am getting 0.4s for creating 1280=
00=20
> interfaces and 0.57s for deleting them
>=20
> - the 2.6.31 kernel I got the 3s numbers does have some patches to sp=
eed-up=20
> interface creating and deletion (removal of per device sysctl and dev=
_snmp6=20
> entries)
>=20
> I'll start posting the patches we have as RFC.
>=20

OK thanks, I thought you were using dummy module

$ time insmod drivers/net/dummy.ko numdummies=3D100

real    0m2.493s
user    0m0.001s
sys     0m0.021s

$ time rmmod dummy

real    0m1.610s
user    0m0.000s
sys     0m0.001s

$ time insmod drivers/net/dummy.ko numdummies=3D200

real    0m10.118s
user    0m0.000s
sys     0m0.015s

$ time rmmod dummy

real    0m3.218s
user    0m0.000s
sys     0m0.001s

$ time insmod drivers/net/dummy.ko numdummies=3D300

real    0m22.564s
user    0m0.000s
sys     0m0.034s

$ time rmmod dummy

real    0m4.755s
user    0m0.000s
sys     0m0.006s

$ perf record -f insmod drivers/net/dummy.ko numdummies=3D300
$ perf report
# Samples: 898
#
# Overhead  Command           Shared Object  Symbol
# ........  .......  ......................  ......
#
    41.65%   insmod  [kernel]                [k] __register_sysctl_path=
s
    22.83%   insmod  [kernel]                [k] strcmp
     5.46%   insmod  [kernel]                [k] pcpu_alloc
     2.23%   insmod  [kernel]                [k] sysfs_find_dirent
     1.56%   insmod  [kernel]                [k] __sysfs_add_one
     1.11%   insmod  [kernel]                [k] pcpu_alloc_area
     1.11%   insmod  [kernel]                [k] _spin_lock
     1.00%   insmod  [kernel]                [k] kmemdup
     1.00%   insmod  [kernel]                [k] kmem_cache_alloc
     0.67%   insmod  [kernel]                [k] find_symbol_in_section
     0.67%   insmod  [kernel]                [k] find_next_zero_bit
     0.67%   insmod  [kernel]                [k] idr_get_empty_slot
     0.67%   insmod  [kernel]                [k] mutex_lock
     0.67%   insmod  [kernel]                [k] mutex_unlock
     0.56%   insmod  [kernel]                [k] vunmap_page_range
     0.56%   insmod  [kernel]                [k] __slab_alloc
