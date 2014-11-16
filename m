From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: /proc/net/sockstat invalid memory accounting or memory leak in
 latest =?UTF-8?Q?kernels=3F=20=28trying=20to=20debug=29?=
Date: Sun, 16 Nov 2014 21:05:45 +0200
Message-ID: <8d9b6a2c313db242c1afb3bcd6a12c51@visp.net.lb>
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
 <64ef227cf22945d373cb06271fe6e051@visp.net.lb>
 <1416161495.17262.90.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:54438 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbaKPTFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 14:05:49 -0500
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id D3BF74801FE
	for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 21:05:46 +0200 (EET)
In-Reply-To: <1416161495.17262.90.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-11-16 20:11, Eric Dumazet wrote:
> On Sun, 2014-11-16 at 10:54 +0200, Denys Fedoryshchenko wrote:
>> As latest findings, when servers are going crazy because of tcp memory
>> invalid accounting.
>> First of all i upgraded kernel to latest version 3.17.3 and added also
>> patch from upcoming kernel,
>> "12) Don't call sock_kfree_s() with NULL pointers, this function also
>> has the side effect of adjusting
>> the socket memory usage.  From Cong Wang.", but it didnt helped.
>> 
>> I added printk_ratelimited to places where suspicious values might
>> appear, and got some more information.
>> First, is not very suspicious, no idea if it is a problem:
>> [ 1413.031622] sk ffff8817184d8680 sk_mem_charge negative -10752 by 
>> 4352
>> [ 1413.032027] sk ffff8817184d8680 sk_mem_charge negative -15104 by 
>> 4352
>> [ 1415.768465] sk ffff881666842d80 sk_mem_charge negative -9984 by 
>> 4352
>> [ 1415.768868] sk ffff881666842d80 sk_mem_charge negative -14336 by 
>> 4352
>> [ 1415.769268] sk ffff881666842d80 sk_mem_charge negative -18688 by 
>> 4352
>> [ 1415.769681] sk ffff881666842d80 sk_mem_charge negative -9088 by 
>> 4352
>> [ 1418.933799] sk ffff8816dd640000 sk_mem_charge negative -9984 by 
>> 4352
>> [ 1418.934205] sk ffff8816dd640000 sk_mem_charge negative -14336 by 
>> 4352
>> [ 1418.934604] sk ffff8816dd640000 sk_mem_charge negative -18688 by 
>> 4352
>> [ 1427.131310] sk ffff881731801a00 sk_mem_charge negative -11776 by 
>> 4352
>> [ 1428.564640] sk ffff881731801a00 sk_mem_charge negative -11008 by 
>> 4352
>> [ 1429.134279] sk ffff881731801a00 sk_mem_charge negative -11776 by 
>> 4352
>> [ 1429.134691] sk ffff881731801a00 sk_mem_charge negative -16128 by 
>> 4352
>> [ 1430.666541] sk ffff881731801a00 sk_mem_charge negative -10496 by 
>> 4352
>> [ 1431.395099] sk ffff881731801a00 sk_mem_charge negative -12032 by 
>> 4352
>> [ 1431.395506] sk ffff881731801a00 sk_mem_charge negative -16384 by 
>> 4352
>> [ 1431.877862] sk ffff881731801a00 sk_mem_charge negative -11648 by 
>> 4352
>> Second is always linked with crashes, it is sk_mem_uncharge and
>> sk_forward_alloc goes negative. Patch to show message
>> for sk_mem_uncharge in sock.h is very simple:
>> 
>>   static inline void sk_mem_uncharge(struct sock *sk, int size)
>> @@ -1480,6 +1485,8 @@
>>          if (!sk_has_account(sk))
>>                  return;
>>          sk->sk_forward_alloc += size;
>> +       if (sk->sk_forward_alloc < -8192)
>> +           printk_ratelimited(KERN_WARNING"sk %p sk_mem_uncharge
>> negative %d by %d\n", sk, sk->sk_forward_alloc, size);
>>   }
>> 
> 
> 
> Could you describe your hardware setup and networking setup ?
This problem are happening on multiple different units that i am using 
as https balancers, and all of them very different (except it is all 
Intel CPU's, but even in that - different generations and models). Such 
problem seems happens on all of them, and seems doesn't depend on 
hardware (networking - igb, e1000e, broadcom stuff - all affected). But 
if it is important:
S2600GZ motherboard, one E5-2620 Xeon
networking - onboard igb, 2 ports used
100GB RAM
This particular one has bonding (but it seems crashes with or without 
it).

System are custom, running on USB flash, busybox+glibc based setup, 
similar OS working for other purposes for NAT, PPPoE termination without 
any issues.

What is common between failing units:

I am using haproxy-based HTTPS balancer(Also as i remember haproxy doing 
a lot of setsockopt stuff), that is handling right now:
     454444 connections established
Bandwidth passing thru is around 1Gbps.

I'm disabling tso/gso/gro on all interfaces.

The way i am forwarding transparent traffic to haproxy:
iptables -t mangle -A PREROUTING -p tcp --sport 443 -j MARK --set-mark 
0x1
iptables -t mangle -A PREROUTING -p tcp --dport 443 -j MARK --set-mark 
0x1
ip rule add fwmark 0x1 lookup 100
ip route add local 0.0.0.0/0 dev lo table 100

"Typical" setup is

backend ssl_passthru
         mode tcp
         option transparent
         source 0.0.0.0 usesrc clientip

frontend ssl-in
         mode tcp
         bind    :443 transparent
         default_backend ssl_passthru
         option tcp-smart-accept

I hope i didnt missed something important. I can provide remote ssh 
access to it.
I will keep sending info, just with hope that some of info maybe will 
give idea, what i should patch or test.

P.S. Just got an idea now, that -2147483648 hinting that somewhere is 
happening integer overflow from very large positive value, to negative. 
I will try to set triggers also to that now.

If required i can provide image with such system. I am not sure you are 
interested in this problem and if it can be reproduced on synthetic 
setup, but as i remember this memory leak happened with me once also on 
normal server with torrents (i left some image unattended for 2 weeks, 
with a lot of requests, and it crashed at the end), so it might affect 
also other use cases.
I am trying to limit now socket buffers, to see if it will decrease 
frequency of crashes.
Also i tried to put "canary" values inside structure, near 
sk_forward_alloc , to see if there is any sort of memory corruption 
occuring on sk_forward_alloc, but seems there is no corruption.
I will try also going back to stable kernels 3.2.64, to see if it will 
fix this problem, but testing takes sometimes almost 1 day, depends on 
luck.
