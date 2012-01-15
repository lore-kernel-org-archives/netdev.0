From: Yuehai Xu <yuehaixu@gmail.com>
Subject: Re: Why the number of /proc/interrupts doesn't change when nic is
 under heavy workload?
Date: Sun, 15 Jan 2012 17:45:29 -0500
Message-ID: <CAEc1PS1gpA6p0Nb11bCkmi6q6e-yxN=63R1duPvimOFnjC9kLQ@mail.gmail.com>
References: <CAEc1PS0doeaH59621ia7n2GT=WgRSsCit_EzGrCV93QH95XZqw@mail.gmail.com>
	<1326665367.5287.97.camel@edumazet-laptop>
	<CAEc1PS0QxYfHfLFTiSFdTX27ufuxVfJd6Vg5oyv5aip5r=tD4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yhxu@wayne.edu
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:39263 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752513Ab2AOWpa convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jan 2012 17:45:30 -0500
In-Reply-To: <CAEc1PS0QxYfHfLFTiSFdTX27ufuxVfJd6Vg5oyv5aip5r=tD4A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 15, 2012 at 5:27 PM, Yuehai Xu <yuehaixu@gmail.com> wrote:
> Thanks for replying! Please see below:
>
> On Sun, Jan 15, 2012 at 5:09 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> Le dimanche 15 janvier 2012 =E0 15:53 -0500, Yuehai Xu a =E9crit :
>>> Hi All,
>>>
>>> My nic of server is Intel Corporation 80003ES2LAN Gigabit Ethernet
>>> Controller, the driver is e1000e, and my Linux version is 3.1.4. I
>>> have a Memcached server running on this 8 core box, the weird thing=
 is
>>> that when my server is under heavy workload, the number of
>>> /proc/interrupts doesn't change at all. Below are some details:
>>> =3D=3D=3D=3D=3D=3D=3D
>>> cat /proc/interrupts | grep eth0
>>> 68: =A0 =A0 330887 =A0 =A0 330861 =A0 =A0 331432 =A0 =A0 330544 =A0=
 =A0 330346 =A0 =A0 330227
>>> =A0 =A0330830 =A0 =A0 330575 =A0 PCI-MSI-edge =A0 =A0 =A0eth0
>>> =3D=3D=3D=3D=3D=3D=3D
>>> cat /proc/irq/68/smp_affinity
>>> ff
>>>
>>> I know when network is under heavy load, NAPI will disable nic
>>> interrupt and poll ring buffer in nic. My question is, when is nic
>>> interrupt enabled again? It seems that it will never be enabled if =
the
>>> heavy workload doesn't stop, simply because the number showed by
>>> /proc/interrupts doesn't change at all. In my case, one of core is
>>> saturated by ksoftirqd, because lots of softirqs are pending to tha=
t
>>> core. I just want to distribute these softirqs to other cores. Even
>>> RPS is enabled, that core is still occupied by ksoftirq, nearly 100=
%.
>>>
>>> I dive into the codes and find these statements:
>>> __napi_schedule =3D=3D>
>>> =A0 =A0local_irq_save(flags);
>>> =A0 =A0____napi_schedule(&__get_cpu_var(softnet_data), n);
>>> =A0 =A0local_irq_restore(flags);
>>>
>>> here "local_irq_save" actually invokes "cli" which disable interrup=
t
>>> for the local core, is this the one that used in NAPI to disable ni=
c
>>> interrupt? Personally I don't think it is because it just disables
>>> local cpu.
>>>
>>> I also find "enable_irq/disable_irq/e1000_irq_enable/e1000_irq_disa=
ble"
>>> under drivers/net/e1000e, are these used in NAPI to disable nic
>>> interrupt, but I fail to get any clue that they are used in the cod=
e
>>> path of NAPI?
>>
>> This is done in the device driver itself, not in generic NAPI code.
>>
>> When NAPI poll() get less packets than the budget, it re-enables chi=
p
>> interrupts.
>>
>>
>
> So you mean that if NAPI poll() get more or equal packets than budget=
,
> it will not enable chip interrupts, right? In this case, one core
> still suffers from heavy workloads. Can you please briefly show me
> where is this control statement in kernel source code? I have looked
> for it several days but without luck.
>

I go through the codes again, since NAPI poll() actually invokes
e1000_clean() (my driver is e1000e), and this routine shows:
=2E...
adapter->clean_rx(adapter, &work_done, budget);
=2E...
/* If budget not fully consumed, exit the polling mode */
if(work_done < budget) {
     ....
     e1000_irq_enable(adapter)
     .....
}

I think above should be what you have said. Correct me if I am wrong,
"work_done" the number of packets that NAPI polls, while budget is a
parameter that administrator can set. So, if work_done always larger
or equal than budget, chip interrupt will never be re-enabled. This
sounds make sense. However, this also means there is a certain core
needs to handle all softirqs, simply because my smp_affinity of irq
doesn't work here. Even RPS can alleviate some softirqs to other
cores, it doesn't solve the problem 100%.

>
>>>
>>> My current situation is that, almost 60% of time of other 7 cores a=
re
>>> idle, while only one core which is occupied by ksoftirq is 100% bus=
y.
>>>
>>
>> You could post some info, like "cat /proc/net/softnet_stat"
>>
>> If you use RPS on a very high workload, on a mono queue NIC, best is=
 to
>> stick for example cpu0 for the packet dispatching, and other cpus fo=
r
>> IP/UDP handling.
>>
>> echo 01 >/proc/irq/68/smp_affinity
>> echo fe >/sys/class/net/eth0/queues/rx-0/rps_cpus
>>
>> Please keep in mind that if your memcache uses a single UDP socket, =
you
>> probably hit a lot of contention on the socket spinlock and various
>> counters. So maybe it would be better to _reduce_ number of cpus
>> handling network load to reduce false sharing.
>
> My memcached uses 8 different UDP sockets(8 different UDP ports), so
> there should be no lock contention for a single UDP rx-queue.
>
>>
>> echo 0e >/sys/class/net/eth0/queues/rx-0/rps_cpus
>>
>> Really, if you have a single UDP queue, best would be to not use RPS=
 and
>> only have :
>>
>> echo 01 >/proc/irq/68/smp_affinity
>>
>> Then you could post the result of "perf top -C 0" so that we can spo=
t
>> obvious problems on the hot path for this particular cpu.
>>
>>
>>
>
> Thanks!
> Yuehai
