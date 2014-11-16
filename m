From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: /proc/net/sockstat invalid memory accounting or memory leak in
 latest =?UTF-8?Q?kernels=3F=20=28trying=20to=20debug=29?=
Date: Sun, 16 Nov 2014 10:54:11 +0200
Message-ID: <64ef227cf22945d373cb06271fe6e051@visp.net.lb>
References: <40bc2b5fcda47d790f1fd247bc409041@visp.net.lb>
 <1405597918.10255.76.camel@edumazet-glaptop2.roam.corp.google.com>
 <37e25a5815a18a2da507a5b20b58427d@visp.net.lb>
 <1405604568.10255.80.camel@edumazet-glaptop2.roam.corp.google.com>
 <a927787503c2f0d71c330b879303b14f@visp.net.lb>
 <1405672897.10255.95.camel@edumazet-glaptop2.roam.corp.google.com>
 <1405676214.10255.96.camel@edumazet-glaptop2.roam.corp.google.com>
 <0b0b74ab8d2222fa85b23e06c6e992ec@visp.net.lb>
 <1405849675.10255.100.camel@edumazet-glaptop2.roam.corp.google.com>
 <6fc086a122bc3ac728a7aec9e812310f@visp.net.lb>
 <1406016045.10255.122.camel@edumazet-glaptop2.roam.corp.google.com>
 <3f463c3912608f7959481edaa6d7668d@visp.net.lb>
 <1406194817.3363.70.camel@edumazet-glaptop2.roam.corp.google.com>
 <8f138d88e3b850130eb9bb15e3e27069@visp.net.lb>
 <2adbf5346b4dd2bebe1915096c1c567c@visp.net.lb>
 <1415813254.17262.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:48929 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754482AbaKPIyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 03:54:17 -0500
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 6F6A64801A8
	for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 10:54:13 +0200 (EET)
In-Reply-To: <1415813254.17262.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As latest findings, when servers are going crazy because of tcp memory 
invalid accounting.
First of all i upgraded kernel to latest version 3.17.3 and added also 
patch from upcoming kernel,
"12) Don't call sock_kfree_s() with NULL pointers, this function also 
has the side effect of adjusting
the socket memory usage.  From Cong Wang.", but it didnt helped.

I added printk_ratelimited to places where suspicious values might 
appear, and got some more information.
First, is not very suspicious, no idea if it is a problem:
[ 1413.031622] sk ffff8817184d8680 sk_mem_charge negative -10752 by 4352
[ 1413.032027] sk ffff8817184d8680 sk_mem_charge negative -15104 by 4352
[ 1415.768465] sk ffff881666842d80 sk_mem_charge negative -9984 by 4352
[ 1415.768868] sk ffff881666842d80 sk_mem_charge negative -14336 by 4352
[ 1415.769268] sk ffff881666842d80 sk_mem_charge negative -18688 by 4352
[ 1415.769681] sk ffff881666842d80 sk_mem_charge negative -9088 by 4352
[ 1418.933799] sk ffff8816dd640000 sk_mem_charge negative -9984 by 4352
[ 1418.934205] sk ffff8816dd640000 sk_mem_charge negative -14336 by 4352
[ 1418.934604] sk ffff8816dd640000 sk_mem_charge negative -18688 by 4352
[ 1427.131310] sk ffff881731801a00 sk_mem_charge negative -11776 by 4352
[ 1428.564640] sk ffff881731801a00 sk_mem_charge negative -11008 by 4352
[ 1429.134279] sk ffff881731801a00 sk_mem_charge negative -11776 by 4352
[ 1429.134691] sk ffff881731801a00 sk_mem_charge negative -16128 by 4352
[ 1430.666541] sk ffff881731801a00 sk_mem_charge negative -10496 by 4352
[ 1431.395099] sk ffff881731801a00 sk_mem_charge negative -12032 by 4352
[ 1431.395506] sk ffff881731801a00 sk_mem_charge negative -16384 by 4352
[ 1431.877862] sk ffff881731801a00 sk_mem_charge negative -11648 by 4352
Second is always linked with crashes, it is sk_mem_uncharge and 
sk_forward_alloc goes negative. Patch to show message
for sk_mem_uncharge in sock.h is very simple:

  static inline void sk_mem_uncharge(struct sock *sk, int size)
@@ -1480,6 +1485,8 @@
         if (!sk_has_account(sk))
                 return;
         sk->sk_forward_alloc += size;
+       if (sk->sk_forward_alloc < -8192)
+           printk_ratelimited(KERN_WARNING"sk %p sk_mem_uncharge 
negative %d by %d\n", sk, sk->sk_forward_alloc, size);
  }


This is what i am usually setting before box are rebooted:
Nov 15 13:20:53 g1 user.warn kernel: [ 2002.363437] sk ffff88155e904100 
sk_mem_uncharge negative -2147482496 by 2304
Nov 15 13:20:53 g1 user.warn kernel: [ 2002.363837] sk ffff88155e904100 
sk_mem_uncharge negative -2147480192 by 2304
Nov 15 13:20:53 g1 user.warn kernel: [ 2002.364232] sk ffff88155e904100 
sk_mem_uncharge negative -2147477888 by 2304
Nov 15 13:20:53 g1 user.warn kernel: [ 2002.364627] sk ffff88155e904100 
sk_mem_uncharge negative -2147475584 by 2304
Nov 15 13:20:53 g1 user.warn kernel: [ 2002.365022] sk ffff88155e904100 
sk_mem_uncharge negative -2147473280 by 2304
Nov 15 13:20:53 g1 user.warn kernel: [ 2002.365416] sk ffff88155e904100 
sk_mem_uncharge negative -2147470976 by 2304
Nov 15 13:20:53 g1 user.warn kernel: [ 2002.365811] sk ffff88155e904100 
sk_mem_uncharge negative -2147468672 by 2304
Nov 15 13:20:53 g1 user.warn kernel: [ 2002.366214] sk ffff88155e904100 
sk_mem_uncharge negative -2147466368 by 2304
Nov 15 13:20:53 g1 user.warn kernel: [ 2002.366611] sk ffff88155e904100 
sk_mem_uncharge negative -2147464064 by 2304
Nov 15 13:20:53 g1 user.warn kernel: [ 2002.367004] sk ffff88155e904100 
sk_mem_uncharge negative -2147461760 by 2304
Nov 15 13:20:58 g1 user.warn kernel: [ 2007.363601] sk_mem_uncharge: 
576170 callbacks suppressed
Nov 15 13:20:58 g1 user.warn kernel: [ 2007.364001] sk ffff88155e904100 
sk_mem_uncharge negative -1517794432 by 2304
.....
until
...
Nov 15 13:31:58 g1 user.warn kernel: [ 2666.393667] sk ffff88170141ad80 
sk_mem_uncharge negative -169088 by 2944
Nov 15 13:31:58 g1 user.warn kernel: [ 2666.394064] sk ffff88170141ad80 
sk_mem_uncharge negative -166144 by 2944
Nov 15 13:31:58 g1 user.warn kernel: [ 2666.394472] sk ffff88170141ad80 
sk_mem_uncharge negative -163200 by 2944
Nov 15 13:31:58 g1 user.warn kernel: [ 2666.394871] sk ffff88170141ad80 
sk_mem_uncharge negative -158208 by 4992
<reboot>

Or:
Nov 15 14:55:01 g1 user.warn kernel: [ 1965.758129] sk ffff8815f8014e00 
sk_mem_uncharge negative -2147483520 by 2304
Nov 15 14:55:01 g1 user.warn kernel: [ 1965.758536] sk ffff8815f8014e00 
sk_mem_uncharge negative -2147481216 by 2304
Nov 15 14:55:01 g1 user.warn kernel: [ 1965.758935] sk ffff8815f8014e00 
sk_mem_uncharge negative -2147478912 by 2304
Nov 15 14:55:01 g1 user.warn kernel: [ 1965.759332] sk ffff8815f8014e00 
sk_mem_uncharge negative -2147476608 by 2304
Nov 15 14:55:01 g1 user.warn kernel: [ 1965.759728] sk ffff8815f8014e00 
sk_mem_uncharge negative -2147474304 by 2304
Nov 15 14:55:01 g1 user.warn kernel: [ 1965.760124] sk ffff8815f8014e00 
sk_mem_uncharge negative -2147472000 by 2304
Nov 15 14:55:01 g1 user.warn kernel: [ 1965.760518] sk ffff8815f8014e00 
sk_mem_uncharge negative -2147469696 by 2304
...
Nov 15 15:03:27 g1 user.warn kernel: [ 2472.170857] sk ffff88163f429a00 
sk_mem_uncharge negative -277169024 by 896
Nov 15 15:03:30 g1 user.warn kernel: [ 2474.611109] sk ffff88163f429a00 
sk_mem_uncharge negative -277164928 by 896
Nov 15 15:03:30 g1 user.warn kernel: [ 2474.611511] sk ffff88163f429a00 
sk_mem_uncharge negative -277164032 by 896
Nov 15 15:03:30 g1 user.warn kernel: [ 2474.706237] sk ffff88163f429a00 
sk_mem_uncharge negative -277159936 by 2304
Nov 15 15:03:34 g1 user.warn kernel: [ 2478.889110] sk ffff88163f429a00 
sk_mem_uncharge negative -277155840 by 2304
Nov 15 15:03:34 g1 user.warn kernel: [ 2478.911516] sk ffff88163f429a00 
sk_mem_uncharge negative -277147648 by 1536
Nov 15 15:03:35 g1 user.warn kernel: [ 2479.320851] sk ffff88163f429a00 
sk_mem_uncharge negative -277143552 by 2304
Nov 15 15:04:33 g1 user.warn kernel: [ 2537.408184] sk ffff88163f429a00 
sk_mem_uncharge negative -277139456 by 2304
Nov 15 15:04:33 g1 user.warn kernel: [ 2537.409790] sk ffff88163f429a00 
sk_mem_uncharge negative -277135360 by 896
(here i can see two sk at same time are like this)


Or

Nov 15 23:37:19 g1 user.warn kernel: [14137.049570] sk ffff8816b3312700 
sk_mem_uncharge negative -2147481856 by 2304
Nov 15 23:37:19 g1 user.warn kernel: [14137.049973] sk ffff8816b3312700 
sk_mem_uncharge negative -2147479552 by 2304
Nov 15 23:37:19 g1 user.warn kernel: [14137.050372] sk ffff8816b3312700 
sk_mem_uncharge negative -2147477248 by 2304
Nov 15 23:37:19 g1 user.warn kernel: [14137.050770] sk ffff8816b3312700 
sk_mem_uncharge negative -2147474944 by 2304
Nov 15 23:37:19 g1 user.warn kernel: [14137.051170] sk ffff8816b3312700 
sk_mem_uncharge negative -2147472640 by 2304
Nov 15 23:37:19 g1 user.warn kernel: [14137.051572] sk ffff8816b3312700 
sk_mem_uncharge negative -2147470336 by 2304
Nov 15 23:37:19 g1 user.warn kernel: [14137.051971] sk ffff8816b3312700 
sk_mem_uncharge negative -2147468032 by 2304
Nov 15 23:37:19 g1 user.warn kernel: [14137.052371] sk ffff8816b3312700 
sk_mem_uncharge negative -2147465728 by 2304
Nov 15 23:37:19 g1 user.warn kernel: [14137.052771] sk ffff8816b3312700 
sk_mem_uncharge negative -2147463424 by 2304
Nov 15 23:37:19 g1 user.warn kernel: [14137.053169] sk ffff8816b3312700 
sk_mem_uncharge negative -2147461120 by 2304
Nov 15 23:37:32 g1 user.warn kernel: [14150.526984] sk_mem_uncharge: 
1083519 callbacks suppressed
Nov 15 23:37:32 g1 user.warn kernel: [14150.527384] sk ffff8816b3312700 
sk_mem_uncharge negative -2147483392 by 2304
Nov 15 23:37:32 g1 user.warn kernel: [14150.527782] sk ffff8816b3312700 
sk_mem_uncharge negative -2147481088 by 2304
Nov 15 23:37:32 g1 user.warn kernel: [14150.528179] sk ffff8816b3312700 
sk_mem_uncharge negative -2147478784 by 2304
Nov 15 23:37:32 g1 user.warn kernel: [14150.528576] sk ffff8816b3312700 
sk_mem_uncharge negative -2147476480 by 2304
Nov 15 23:37:32 g1 user.warn kernel: [14150.528975] sk ffff8816b3312700 
sk_mem_uncharge negative -2147474176 by 2304
Nov 15 23:37:32 g1 user.warn kernel: [14150.529370] sk ffff8816b3312700 
sk_mem_uncharge negative -2147471872 by 2304
Nov 15 23:37:32 g1 user.warn kernel: [14150.529770] sk ffff8816b3312700 
sk_mem_uncharge negative -2147469568 by 2304
Nov 15 23:37:32 g1 user.warn kernel: [14150.530167] sk ffff8816b3312700 
sk_mem_uncharge negative -2147467264 by 2304
Nov 15 23:37:32 g1 user.warn kernel: [14150.530572] sk ffff8816b3312700 
sk_mem_uncharge negative -2147464960 by 2304
Nov 15 23:37:32 g1 user.warn kernel: [14150.530973] sk ffff8816b3312700 
sk_mem_uncharge negative -2147462656 by 2304
<here it reboots much earlier, at this point>

I will try to get more info, what kind of socket it is.

On 2014-11-12 19:27, Eric Dumazet wrote:
> On Wed, 2014-11-12 at 19:07 +0200, Denys Fedoryshchenko wrote:
>> Hi
>> 
>> 
>> I've been able to trace invalid memory shown for sk_forward_alloc. Not
>> sure if it is related to bug when all tcp stack are wrecked on 
>> highload
>> servers (i had even such crash on server with plain torrents, not that
>> much of them).
>> First they were appearing in ss output as f4294966016, but in tc it
>> shows as unsigned integer, while in kernel it is signed integer. 
>> Should
>> i provide patch for iproute2?
>> After changing value to correct one, here is what is got:
>>           skmem:(r0,rb359040,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb357120,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb357120,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb357120,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb357120,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb357120,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb357120,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb357120,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
>>           skmem:(r0,rb357120,t0,tb46080,f-1280,w1280,o0,bl0)
>> 
>> So as it is signed integer, it is actually appears a lot as -1280 
>> bytes.
>> After placing several WARN_ON_ONCE on fall functions involving
>> sk_forward_alloc, where negative value may
>> appear i traced down at least to tcp_connect_queue_skb().
>> [   13.094561] WARNING: CPU: 4 PID: 2855 at include/net/sock.h:1476
>> tcp_connect_queue_skb+0x9f/0xd0()
>> After adding some debug values, it was confirmed:
>> 
>> 
>> skb_header_release(skb);
>> __tcp_add_write_queue_tail(sk, skb);
>> sk->sk_wmem_queued += skb->truesize;
>> sk_mem_charge(sk, skb->truesize); <<<< sk->sk_forward_alloc often is 
>> 0,
>> and skb->truesize is 1280, so -1280 is result
>> tp->write_seq = tcb->end_seq;
>> tp->packets_out += tcp_skb_pcount(skb);
>> 
>> Maybe it should not be subtracted here? Or maybe logic are inverted 
>> all
>> over the code?
>> Please help :)
>> 
> 
> Thanks a lot for the report, I am CCing other experts ;)
> 
> AFAIK, a negative forward alloc should not be a problem, a long as the
> incursion is bound.
