From: zhao ya <marywangran0627@gmail.com>
Subject: Re: [PATCH] IPIP tunnel performance improvement
Date: Sat, 27 Feb 2016 15:06:30 +0800
Message-ID: <56D14AF6.5040300@gmail.com>
References: <56D12752.7080303@gmail.com> <56D128D7.3090009@gmail.com>
 <CAM_iQpVEb=Cshs1ZnJeB0S_SyK559RnZ=GVY4AgcEV4Kmh78XA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVEb=Cshs1ZnJeB0S_SyK559RnZ=GVY4AgcEV4Kmh78XA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Yes, I did, but have no effect.

I want to ask is, why David's patch not used.

Thanks.



Cong Wang said, at 2/27/2016 2:29 PM:
> On Fri, Feb 26, 2016 at 8:40 PM, zhao ya <marywangran0627@gmail.com> wrote:
>> From: Zhao Ya <marywangran0627@gmail.com>
>> Date: Sat, 27 Feb 2016 10:06:44 +0800
>> Subject: [PATCH] IPIP tunnel performance improvement
>>
>> bypass the logic of each packet's own neighbour creation when using
>> pointopint or loopback device.
>>
>> Recently, in our tests, met a performance problem.
>> In a large number of packets with different target IP address through
>> ipip tunnel, PPS will decrease sharply.
>>
>> The output of perf top are as follows, __write_lock_failed is of the first:
>>   - 5.89% [kernel]              [k] __write_lock_failed
>>    -__write_lock_failed                                         a
>>    -_raw_write_lock_bh                                          a
>>    -__neigh_create                                              a
>>    -ip_finish_output                                            a
>>    -ip_output                                                   a
>>    -ip_local_out                                                a
>>
>> The neighbour subsystem will create a neighbour object for each target
>> when using pointopint device. When massive amounts of packets with diff-
>> erent target IP address to be xmit through a pointopint device, these
>> packets will suffer the bottleneck at write_lock_bh(&tbl->lock) after
>> creating the neighbour object and then inserting it into a hash-table
>> at the same time.
>>
>> This patch correct it. Only one or little amounts of neighbour objects
>> will be created when massive amounts of packets with different target IP
>> address through ipip tunnel.
>>
>> As the result, performance will be improved.
> 
> Well, you just basically revert another bug fix:
> 
> commit 0bb4087cbec0ef74fd416789d6aad67957063057
> Author: David S. Miller <davem@davemloft.net>
> Date:   Fri Jul 20 16:00:53 2012 -0700
> 
>     ipv4: Fix neigh lookup keying over loopback/point-to-point devices.
> 
>     We were using a special key "0" for all loopback and point-to-point
>     device neigh lookups under ipv4, but we wouldn't use that special
>     key for the neigh creation.
> 
>     So basically we'd make a new neigh at each and every lookup :-)
> 
>     This special case to use only one neigh for these device types
>     is of dubious value, so just remove it entirely.
> 
>     Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> which would bring the neigh entries counting problem back...
> 
> Did you try to tune the neigh gc parameters for your case?
> 
> Thanks.
> 
