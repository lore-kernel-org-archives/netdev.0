From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: Add support for 64-bit statistics
Date: Thu, 3 Aug 2017 10:30:56 -0700
Message-ID: <e16c44e3-41ee-09cc-a05d-46e22c1404e3@gmail.com>
References: <20170801220036.11355-1-f.fainelli@gmail.com>
 <20170802.164951.1316163070425929253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170802.164951.1316163070425929253.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/02/2017 04:49 PM, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Tue,  1 Aug 2017 15:00:36 -0700
> 
>> DSA slave network devices maintain a pair of bytes and packets counters
>> for each directions, but these are not 64-bit capable. Re-use
>> pcpu_sw_netstats which contains exactly what we need for that purpose
>> and update the code path to report 64-bit capable statistics.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> Applied, thanks.
> 
> I would run ethtool -S and ifconfig under perf to see where it is
> spending so much time.
> 

This appears to be way worse than I thought, will keep digging, but for
now, I may have to send a revert. Andrew, Vivien can you see if you have
the same problems on your boards? Thanks!

# killall iperf
# [ ID] Interval       Transfer     Bandwidth
[  3]  0.0-19.1 sec   500 MBytes   220 Mbits/sec
# while true; do ethtool -S gphy; ifconfig gphy; done
^C^C


[   64.566226] INFO: rcu_sched self-detected stall on CPU
[   64.571487]  0-...: (25999 ticks this GP) idle=006/140000000000001/0
softirq=965/965 fqs=6495
[   64.580214]   (t=26000 jiffies g=205 c=204 q=51)
[   64.584958] NMI backtrace for cpu 0
[   64.588571] CPU: 0 PID: 1515 Comm: ethtool Not tainted
4.13.0-rc3-00534-g5a4d148f0d78 #328
[   64.596951] Hardware name: Broadcom STB (Flattened Device Tree)
[   64.602973] [<c0211fe4>] (unwind_backtrace) from [<c020cc4c>]
(show_stack+0x10/0x14)
[   64.610836] [<c020cc4c>] (show_stack) from [<c0a42bac>]
(dump_stack+0xb0/0xdc)
[   64.618172] [<c0a42bac>] (dump_stack) from [<c0a48f48>]
(nmi_cpu_backtrace+0x11c/0x120)
[   64.626295] [<c0a48f48>] (nmi_cpu_backtrace) from [<c0a49064>]
(nmi_trigger_cpumask_backtrace+0x118/0x158)
[   64.636087] [<c0a49064>] (nmi_trigger_cpumask_backtrace) from
[<c02a8730>] (rcu_dump_cpu_stacks+0xa0/0xd4)
[   64.645875] [<c02a8730>] (rcu_dump_cpu_stacks) from [<c02a7cdc>]
(rcu_check_callbacks+0xb8c/0xbfc)
[   64.654965] [<c02a7cdc>] (rcu_check_callbacks) from [<c02add00>]
(update_process_times+0x30/0x5c)
[   64.663966] [<c02add00>] (update_process_times) from [<c02c1ce0>]
(tick_sched_timer+0x40/0x90)
[   64.672702] [<c02c1ce0>] (tick_sched_timer) from [<c02aeb58>]
(__hrtimer_run_queues+0x198/0x6f0)
[   64.681615] [<c02aeb58>] (__hrtimer_run_queues) from [<c02afa90>]
(hrtimer_interrupt+0x98/0x1f4)
[   64.690530] [<c02afa90>] (hrtimer_interrupt) from [<c0875760>]
(arch_timer_handler_virt+0x28/0x30)
[   64.699628] [<c0875760>] (arch_timer_handler_virt) from [<c0292328>]
(handle_percpu_devid_irq+0xc8/0x484)
[   64.709329] [<c0292328>] (handle_percpu_devid_irq) from [<c028cebc>]
(generic_handle_irq+0x24/0x34)
[   64.718502] [<c028cebc>] (generic_handle_irq) from [<c028d418>]
(__handle_domain_irq+0x5c/0xb0)
[   64.727325] [<c028d418>] (__handle_domain_irq) from [<c02014e8>]
(gic_handle_irq+0x48/0x8c)
[   64.735794] [<c02014e8>] (gic_handle_irq) from [<c020d97c>]
(__irq_svc+0x5c/0x7c)
[   64.743384] Exception stack(0xc283fd40 to 0xc283fd88)
[   64.748510] fd40: 00000001 0011a9ad 00000000 edf37000 ecddb800
f0d95000 ecddbe6c c08e87f4
[   64.756801] fd60: ed6b8010 00000660 00000658 600f0013 00000001
c283fd90 c027a39c c09a8c24
[   64.765091] fd80: 200f0013 ffffffff
[   64.768647] [<c020d97c>] (__irq_svc) from [<c09a8c24>]
(dsa_slave_get_ethtool_stats+0x100/0x104)
[   64.777562] [<c09a8c24>] (dsa_slave_get_ethtool_stats) from
[<c08e87f4>] (dev_ethtool+0x768/0x2840)
[   64.786742] [<c08e87f4>] (dev_ethtool) from [<c09029ec>]
(dev_ioctl+0x5f8/0xa50)
[   64.794251] [<c09029ec>] (dev_ioctl) from [<c038ffb4>]
(do_vfs_ioctl+0xac/0x8d0)
[   64.801755] [<c038ffb4>] (do_vfs_ioctl) from [<c039080c>]
(SyS_ioctl+0x34/0x5c)
[   64.809175] [<c039080c>] (SyS_ioctl) from [<c02085a0>]
(ret_fast_syscall+0x0/0x1c)
[   64.816901] INFO: rcu_sched detected stalls on CPUs/tasks:
[   64.822480]  0-...: (26006 ticks this GP) idle=006/140000000000000/0
softirq=965/965 fqs=6495
[   64.831206]  (detected by 2, t=26264 jiffies, g=205, c=204, q=51)
[   64.837390] Sending NMI from CPU 2 to CPUs 0:
[   64.841811] NMI backtrace for cpu 0
[   64.841818] CPU: 0 PID: 1515 Comm: ethtool Not tainted
4.13.0-rc3-00534-g5a4d148f0d78 #328
[   64.841821] Hardware name: Broadcom STB (Flattened Device Tree)
[   64.841824] task: edf37000 task.stack: c283e000
[   64.841832] PC is at dsa_slave_get_ethtool_stats+0x100/0x104
[   64.841842] LR is at mark_held_locks+0x68/0x90
[   64.841846] pc : [<c09a8c24>]    lr : [<c027a39c>]    psr: 200f0013
[   64.841850] sp : c283fd90  ip : 00000001  fp : 600f0013
[   64.841853] r10: 00000658  r9 : 00000660  r8 : ed6b8010
[   64.841856] r7 : c08e87f4  r6 : ecddbe6c  r5 : f0d95000  r4 : ecddb800
[   64.841860] r3 : edf37000  r2 : 00000000  r1 : 0011a9ad  r0 : 00000001
[   64.841865] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM
Segment user
[   64.841869] Control: 30c5387d  Table: 2dddf500  DAC: fffffffd
[   64.841874] CPU: 0 PID: 1515 Comm: ethtool Not tainted
4.13.0-rc3-00534-g5a4d148f0d78 #328
[   64.841876] Hardware name: Broadcom STB (Flattened Device Tree)
[   64.841885] [<c0211fe4>] (unwind_backtrace) from [<c020cc4c>]
(show_stack+0x10/0x14)
[   64.841892] [<c020cc4c>] (show_stack) from [<c0a42bac>]
(dump_stack+0xb0/0xdc)
[   64.841900] [<c0a42bac>] (dump_stack) from [<c0a48eec>]
(nmi_cpu_backtrace+0xc0/0x120)
[   64.841907] [<c0a48eec>] (nmi_cpu_backtrace) from [<c0210b74>]
(handle_IPI+0x108/0x424)
[   64.841914] [<c0210b74>] (handle_IPI) from [<c0201528>]
(gic_handle_irq+0x88/0x8c)
[   64.841919] [<c0201528>] (gic_handle_irq) from [<c020d97c>]
(__irq_svc+0x5c/0x7c)
[   64.841922] Exception stack(0xc283fd40 to 0xc283fd88)
[   64.841928] fd40: 00000001 0011a9ad 00000000 edf37000 ecddb800
f0d95000 ecddbe6c c08e87f4
[   64.841932] fd60: ed6b8010 00000660 00000658 600f0013 00000001
c283fd90 c027a39c c09a8c24
[   64.841935] fd80: 200f0013 ffffffff
[   64.841942] [<c020d97c>] (__irq_svc) from [<c09a8c24>]
(dsa_slave_get_ethtool_stats+0x100/0x104)
[   64.841950] [<c09a8c24>] (dsa_slave_get_ethtool_stats) from
[<c08e87f4>] (dev_ethtool+0x768/0x2840)
[   64.841958] [<c08e87f4>] (dev_ethtool) from [<c09029ec>]
(dev_ioctl+0x5f8/0xa50)
[   64.841965] [<c09029ec>] (dev_ioctl) from [<c038ffb4>]
(do_vfs_ioctl+0xac/0x8d0)
[   64.841972] [<c038ffb4>] (do_vfs_ioctl) from [<c039080c>]
(SyS_ioctl+0x34/0x5c)
[   64.841979] [<c039080c>] (SyS_ioctl) from [<c02085a0>]
(ret_fast_syscall+0x0/0x1c)


-- 
Florian
