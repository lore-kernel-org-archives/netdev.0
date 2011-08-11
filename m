From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Intel 82599 ixgbe driver performance
Date: Thu, 11 Aug 2011 11:43:55 -0700
Message-ID: <4E4422EB.7060508@hp.com>
References: <4E4222F6.7050304@gmail.com> <4E42F112.4020300@hp.com> <4E433706.2020302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "J.Hwan Kim" <frog1120@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:29153 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133Ab1HKSn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 14:43:57 -0400
In-Reply-To: <4E433706.2020302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/10/2011 06:57 PM, J.Hwan Kim wrote:
> On 2011=EB=85=84 08=EC=9B=94 11=EC=9D=BC 05:58, Rick Jones wrote:
>> On 08/09/2011 11:19 PM, J.Hwan Kim wrote:
>>> Hi, everyone
>>>
>>> I'm testing our network card which includes intel 82599 based on
>>> ixgbe driver. I wonder what is the Rx performance of i82599 without
>>> network stack only with 64Byte frames. Our driver reads the packet
>>> directly from DMA packet buffer and push to the application without
>>> passing through linux kernel stack. It seems that the intel 82599
>>> cannot push 64B frames to DMA area in 10G. Is it right?
>>
>> Does your driver perform a copy of that 64B frame to user space?
> Our driver and user application shares the packet memory
>
>> Is this a single-threaded test running?
> Now, 4 core is running and 4 RX queue is used, of which intrerrupt
> affinity is set, but the result is worse than 1 single queue.
>> What does an lat_mem_rd -t (-t for random stride) test from lmbench
>> give for your system's memory latency? (Perhaps using numactl to
>> ensure local, or remote memory access, as you desire)
> ./lat_mem_rd -t 128
> "stride=3D64
>
> 0.00049 1.003
> 0.00098 1.003
> 0.00195 1.003
> 0.00293 1.003
> 0.00391 1.003
> 0.00586 1.003
> 0.00781 1.003
> 0.01172 1.003
> 0.01562 1.003
> 0.02344 1.003
> 0.03125 1.003
> 0.04688 5.293
> 0.06250 5.307
> 0.09375 5.571
> 0.12500 5.683
> 0.18750 5.683
> 0.25000 5.683
> 0.37500 16.394
> 0.50000 42.394

Unless the chip you are using has a rather tiny (by today's standards)=20
data cache, you need to go much father there - I suspect that at 0.5 MB=
=20
you have not yet gotten beyond the size of the last level of data cache=
=20
on the chip.

I would suggest:

(from a system that is not otherwise idle...)

=2E/lat_mem_rd -t 512 256"stride=3D256
0.00049 1.237
0.00098 1.239
0.00195 1.228
0.00293 1.238
0.00391 1.243
0.00586 1.238
0.00781 1.250
0.01172 1.249
0.01562 1.251
0.02344 1.247
0.03125 1.247
0.04688 3.125
0.06250 3.153
0.09375 3.158
0.12500 3.177
0.18750 6.636
0.25000 8.729
0.37500 16.167
0.50000 16.901
0.75000 16.953
1.00000 17.362
1.50000 18.781
2.00000 20.243
3.00000 23.434
4.00000 24.965
6.00000 35.951
8.00000 56.026
12.00000 76.169
16.00000 80.741
24.00000 83.237
32.00000 84.043
48.00000 84.132
64.00000 83.775
96.00000 83.298
128.00000 83.039
192.00000 82.659
256.00000 82.464
384.00000 82.280
512.00000 82.092

You can see the large jump starting at 8MB  - that is where the last=20
level cache runs-out on the chip I'm using - an Intel W3550.

Now, as run, that will include TLB miss overhead once the area of memor=
y=20
being accessed is larger than can be mapped by the chip's TLB at the=20
page size being used.  You can use libhugetlbfs to mitigate that throug=
h=20
the use of hugepages.

rick jones
