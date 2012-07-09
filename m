From: Li Yu <raise.sail@gmail.com>
Subject: Re: [RFC] Introduce to batch variants of accept() and epoll_ctl()
 syscall
Date: Mon, 09 Jul 2012 11:36:38 +0800
Message-ID: <4FFA51C6.3070306@gmail.com>
References: <4FDAB652.6070201@gmail.com>  <CABa6K_H3NrvvZ3Bh7JqsR6h33BSqYPBenUDG5Yt1U=2VvP700g@mail.gmail.com>  <4FDACA26.70004@gmail.com> <1339750318.7491.70.camel@edumazet-glaptop> <4FF6B20E.7000402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	davidel@xmailserver.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FF6B20E.7000402@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B407=E6=9C=8806=E6=97=A5 17:38, Li Yu =E5=86=99=E9=
=81=93:
> =E4=BA=8E 2012=E5=B9=B406=E6=9C=8815=E6=97=A5 16:51, Eric Dumazet =E5=
=86=99=E9=81=93:
>> On Fri, 2012-06-15 at 13:37 +0800, Li Yu wrote:
>>
>>> Of course, I think that implementing them should not be a hard work=
 :)
>>>
>>> Em. I really do not know whether it is necessary to introduce to a =
new
>>> syscall here. An alternative solution to add new socket option to h=
andle
>>> such batch requirement, so applications also can detect if kernel h=
as
>>> this extended ability with a easy getsockopt() call.
>>>
>>> Any way, I am going to try to write a prototype first.
>>
>> Before that, could you post the result of "perf top", or "perf
>> record ...;perf report"
>>
>
> Sorry for I just have time to write a benchmark to reproduce this
> problem on my test bed, below are results of "perf record -g -C 0".
> kernel is 3.4.0:
>
> Events: 7K cycles
> +  54.87%  swapper  [kernel.kallsyms]  [k] poll_idle
> -   3.10%   :22984  [kernel.kallsyms]  [k] _raw_spin_lock
>     - _raw_spin_lock
>        - 64.62% sch_direct_xmit
>             dev_queue_xmit
>             ip_finish_output
>             ip_output
>           - ip_local_out
>              + 49.48% ip_queue_xmit
>              + 37.48% ip_build_and_send_pkt
>              + 13.04% ip_send_skb
>
> I can not reproduce complete same high CPU usage on my testing
> environment, but top show that it has similar ratio of sys% and
> si% on one CPU:
>
> Tasks: 125 total,   2 running, 123 sleeping,   0 stopped,   0 zombie
> Cpu0  :  1.0%us, 30.7%sy,  0.0%ni, 18.8%id,  0.0%wa,  0.0%hi, 49.5%si=
,
> 0.0%st
>
> Well, it seem that I must acknowledge I was wrong here. however,
> I recall that I indeed ever encountered this in another benchmarking =
a
> small packets performance.
>
> I guess, this is since TX softirq and syscall context contend same lo=
ck
> in sch_direct_xmit(), is this right?
>

Em, do we have some means to decrease the lock contention here?

> thanks
>
> Yu
>
>>>   The top shows the kernel is most cpu hog, the testing is simple,
>>> just a accept() -> epoll_ctl(ADD) loop, the ratio of cpu util sys% =
to
>>> si% is about 2:5.
>>
>> This ratio is not meaningful, if we dont know where time is spent.
>>
>>
>> I doubt epoll_ctl(ADD) is a problem here...
>>
>> If it is, batching the fds wont speed the thing anyway...
>>
>> I believe accept() is the problem here, because it contends with the
>> softirq processing the tcp session handshake.
>>
>>
>>
>>
>
>
