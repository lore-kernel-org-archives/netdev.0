From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: User per-cpu 64-bit statistics
Date: Mon, 21 Aug 2017 16:23:48 -0700
Message-ID: <bd260f17-3996-adb5-5c69-353f2a483f84@gmail.com>
References: <20170804043328.4730-1-f.fainelli@gmail.com>
 <1501824968.25002.35.camel@edumazet-glaptop3.roam.corp.google.com>
 <455c39d3-302e-68ab-3812-112c48ed48c2@gmail.com>
 <1501866711.25002.46.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemlot.net,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        open list <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501866711.25002.46.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/04/2017 10:11 AM, Eric Dumazet wrote:
> On Fri, 2017-08-04 at 08:51 -0700, Florian Fainelli wrote:
>> On 08/03/2017 10:36 PM, Eric Dumazet wrote:
>>> On Thu, 2017-08-03 at 21:33 -0700, Florian Fainelli wrote:
>>>> During testing with a background iperf pushing 1Gbit/sec worth of
>>>> traffic and having both ifconfig and ethtool collect statistics, we
>>>> could see quite frequent deadlocks. Convert the often accessed DSA slave
>>>> network devices statistics to per-cpu 64-bit statistics to remove these
>>>> deadlocks and provide fast efficient statistics updates.
>>>>
>>>
>>> This seems to be a bug fix, it would be nice to get a proper tag like :
>>>
>>> Fixes: f613ed665bb3 ("net: dsa: Add support for 64-bit statistics")
>>
>> Right, should have been added, thanks!
>>
>>>
>>> Problem here is that if multiple cpus can call dsa_switch_rcv() at the
>>> same time, then u64_stats_update_begin() contract is not respected.
>>
>> This is really where I struggled understanding what is wrong in the
>> non-per CPU version, my understanding is that we have:
>>
>> - writers for xmit executes in process context
>> - writers for receive executes from NAPI (from the DSA's master network
>> device through it's own NAPI doing netif_receive_skb -> netdev_uses_dsa
>> -> netif_receive_skb)
>>
>> readers should all execute in process context. The test scenario that
>> led to a deadlock involved running iperf in the background, having a
>> while loop with both ifconfig and ethtool reading stats, and somehow
>> when iperf exited, either reader would just be locked. So I guess this
>> leaves us with the two writers not being mutually excluded then, right?
> 
> You could add a debug version of u64_stats_update_begin()
> 
> doing 
> 
> int ret = atomic_inc((atomic_t *)syncp);
> 
> BUG_ON(ret & 1);>
> 
> And u64_stats_update_end()
> 
> int ret = atomic_inc((atomic_t *)syncp);

so with your revised suggested patch:

static inline void u64_stats_update_begin(struct u64_stats_sync *syncp)
{
#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
        int ret = atomic_inc_return((atomic_t *)syncp);
        BUG_ON(ret & 1);
#endif
#if 0
#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
        write_seqcount_begin(&syncp->seq);
#endif
#endif
}

static inline void u64_stats_update_end(struct u64_stats_sync *syncp)
{
#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
        int ret = atomic_inc_return((atomic_t *)syncp);
        BUG_ON(!(ret & 1));
#endif
#if 0
#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
        write_seqcount_end(&syncp->seq);
#endif
#endif
}

and this makes us choke pretty early in IRQ accounting, did I get your
suggestion right?

[    0.015149] ------------[ cut here ]------------
[    0.020051] kernel BUG at ./include/linux/u64_stats_sync.h:82!
[    0.026221] Internal error: Oops - BUG: 0 [#1] SMP ARM
[    0.031661] Modules linked in:
[    0.034970] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
4.13.0-rc5-01297-g7d3f0cd43fee-dirty #33
[    0.043990] Hardware name: Broadcom STB (Flattened Device Tree)
[    0.050237] task: c180a500 task.stack: c1800000
[    0.055065] PC is at irqtime_account_delta+0xa4/0xa8
[    0.060322] LR is at 0x1
[    0.063057] pc : [<c0250504>]    lr : [<00000001>]    psr: 000001d3
[    0.069652] sp : c1801eec  ip : ee78b458  fp : c0e5ea48
[    0.075212] r10: c18b4b40  r9 : f0803000  r8 : ee00a800
[    0.080781] r7 : 00000001  r6 : c180a500  r5 : c1800000  r4 : 00000000
[    0.087680] r3 : 00000000  r2 : 0000ec8c  r1 : ee78b3c0  r0 : ee78b440
[    0.094546] Flags: nzcv  IRQs off  FIQs off  Mode SVC_32  ISA ARM
Segment user
[    0.102314] Control: 30c5387d  Table: 00003000  DAC: fffffffd
[    0.108414] Process swapper/0 (pid: 0, stack limit = 0xc1800210)
[    0.114791] Stack: (0xc1801eec to 0xc1802000)
[    0.119431] 1ee0:                            ee78b440 c1800000
c180a500 00000001 c02505c8
[    0.128079] 1f00: 00000004 ee00a800 ffffe000 00000000 00000000
c0227890 c17e6f20 c0278910
[    0.136665] 1f20: c185724c c18079a0 f080200c c1801f58 f0802000
c0201494 c0e00c18 20000053
[    0.145303] 1f40: ffffffff c1801f8c ffffffff c1800000 c18b4b40
c020d238 00000000 0000001f
[    0.153915] 1f60: 00040d00 00000000 efffc940 00000000 c18b4b40
c1807440 ffffffff 00000000
[    0.162571] 1f80: c18b4b40 c0e5ea48 00000004 c1801fa8 c0322fb0
c0e00c18 20000053 ffffffff
[    0.171226] 1fa0: c18b4b40 00000000 ffffffff ffffffff 00000000
c0e006c0 ffffffff 00000000
[    0.179890] 1fc0: 00000000 c1807448 c0e5ea48 00000000 00000000
c18b4dd4 c180745c c0e5ea44
[    0.188546] 1fe0: c180c0d0 00007000 420f00f3 00000000 00000000
00008090 00000000 00000000
[    0.197165] [<c0250504>] (irqtime_account_delta) from [<c02505c8>]
(irqtime_account_irq+0xc0/0xc4)
[    0.206664] [<c02505c8>] (irqtime_account_irq) from [<c0227890>]
(irq_exit+0x28/0x154)
[    0.215012] [<c0227890>] (irq_exit) from [<c0278910>]
(__handle_domain_irq+0x60/0xb4)
[    0.223245] [<c0278910>] (__handle_domain_irq) from [<c0201494>]
(gic_handle_irq+0x48/0x8c)
[    0.232035] [<c0201494>] (gic_handle_irq) from [<c020d238>]
(__irq_svc+0x58/0x74)
[    0.239941] Exception stack(0xc1801f58 to 0xc1801fa0)
[    0.245327] 1f40:
  00000000 0000001f
[    0.253948] 1f60: 00040d00 00000000 efffc940 00000000 c18b4b40
c1807440 ffffffff 00000000
[    0.262534] 1f80: c18b4b40 c0e5ea48 00000004 c1801fa8 c0322fb0
c0e00c18 20000053 ffffffff
[    0.271144] [<c020d238>] (__irq_svc) from [<c0e00c18>]
(start_kernel+0x300/0x410)
[    0.279028] [<c0e00c18>] (start_kernel) from [<00008090>] (0x8090)
[    0.285547] Code: f57ff05b e3130001 18bd80f0 e7f001f2 (e7f001f2)
[    0.291978] ---[ end trace f68728a0d3053b52 ]---
[    0.296871] Kernel panic - not syncing: Fatal exception in interrupt
[    0.303622] ---[ end Kernel panic - not syncing: Fatal exception in
interrupt
-- 
Florian
