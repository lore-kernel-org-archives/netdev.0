From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v7 net-next] net: systemport: Support 64bit statistics
Date: Fri, 18 Aug 2017 16:27:15 -0700
Message-ID: <be67badf-6332-ef1e-99f0-f57c7fe71304@gmail.com>
References: <1501801665-6686-1-git-send-email-jqiaoulk@gmail.com>
 <20170806.212129.568625131913902231.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, jqiaoulk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:38106 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751566AbdHRX1U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 19:27:20 -0400
Received: by mail-wm0-f67.google.com with SMTP id y206so5652313wmd.5
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 16:27:20 -0700 (PDT)
In-Reply-To: <20170806.212129.568625131913902231.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2017 09:21 PM, David Miller wrote:
> From: "Jianming.qiao" <jqiaoulk@gmail.com>
> Date: Fri,  4 Aug 2017 00:07:45 +0100
> 
>> When using Broadcom Systemport device in 32bit Platform, ifconfig can
>> only report up to 4G tx,rx status, which will be wrapped to 0 when the
>> number of incoming or outgoing packets exceeds 4G, only taking
>> around 2 hours in busy network environment (such as streaming).
>> Therefore, it makes hard for network diagnostic tool to get reliable
>> statistical result, so the patch is used to add 64bit support for
>> Broadcom Systemport device in 32bit Platform.
>>
>> This patch provides 64bit statistics capability on both ethtool and ifconfig.
>>
>> Signed-off-by: Jianming.qiao <kiki-good@hotmail.com>
> 
> Applied, thanks.
> 

Kiki, I don't know how you tested that, but I keep hitting deadlocks
with that patch, I don't have time to debug this at the moment and I
still need to add the debugging that Eric suggested in another, but it
does not take long to reproduce:

# ethtool -K eth0 rx on
Cannot get device udp-fragmentation-offload settings: Operation not
supported


^C

[  283.457657] INFO: rcu_sched self-detected stall on CPU
[  283.458658] INFO: rcu_sched detected stalls on CPUs/tasks:
[  283.458669]  0-...: (21000 ticks this GP) idle=eba/140000000000001/0
softirq=3159/3159 fqs=5246
[  283.458671]  (detected by 3, t=21002 jiffies, g=736, c=735, q=52)
[  283.458682] Sending NMI from CPU 3 to CPUs 0:
[  283.487596]  0-...: (21000 ticks this GP) idle=eba/140000000000001/0
softirq=3159/3159 fqs=5247
[  283.496399]   (t=21031 jiffies g=736 c=735 q=52)
[  293.459258] rcu_sched kthread starved for 9244 jiffies! g736 c735
f0x0 RCU_GP_DOING_FQS(4) ->state=0x0
[  293.459259] NMI backtrace for cpu 0
[  293.459266] CPU: 0 PID: 1489 Comm: ethtool Not tainted
4.13.0-rc5-01160-g6e42b0004c6c-dirty #13
[  293.459269] Hardware name: Broadcom STB (Flattened Device Tree)
[  293.459301] [<c0211720>] (unwind_backtrace) from [<c020c50c>]
(show_stack+0x10/0x14)
[  293.459313] [<c020c50c>] (show_stack) from [<c0979460>]
(dump_stack+0x84/0x98)
[  293.459327] [<c0979460>] (dump_stack) from [<c097f678>]
(nmi_cpu_backtrace+0x11c/0x120)
[  293.459336] [<c097f678>] (nmi_cpu_backtrace) from [<c097f754>]
(nmi_trigger_cpumask_backtrace+0xd8/0x124)
[  293.459347] [<c097f754>] (nmi_trigger_cpumask_backtrace) from
[<c0283c88>] (rcu_dump_cpu_stacks+0xa0/0xd0)
[  293.459355] [<c0283c88>] (rcu_dump_cpu_stacks) from [<c028337c>]
(rcu_check_callbacks+0x7b4/0x930)
[  293.459364] [<c028337c>] (rcu_check_callbacks) from [<c02888cc>]
(update_process_times+0x34/0x5c)
[  293.459374] [<c02888cc>] (update_process_times) from [<c029a744>]
(tick_sched_timer+0x40/0x9c)
[  293.459383] [<c029a744>] (tick_sched_timer) from [<c02899cc>]
(__hrtimer_run_queues+0x168/0x328)
[  293.459389] [<c02899cc>] (__hrtimer_run_queues) from [<c0289dc4>]
(hrtimer_interrupt+0xa4/0x1f8)
[  293.459400] [<c0289dc4>] (hrtimer_interrupt) from [<c07edcb4>]
(arch_timer_handler_virt+0x28/0x30)
[  293.459409] [<c07edcb4>] (arch_timer_handler_virt) from [<c02728fc>]
(handle_percpu_devid_irq+0x88/0x23c)
[  293.459418] [<c02728fc>] (handle_percpu_devid_irq) from [<c026d64c>]
(generic_handle_irq+0x24/0x34)
[  293.459426] [<c026d64c>] (generic_handle_irq) from [<c026db8c>]
(__handle_domain_irq+0x5c/0xb4)
[  293.459433] [<c026db8c>] (__handle_domain_irq) from [<c020148c>]
(gic_handle_irq+0x48/0x8c)
[  293.459438] [<c020148c>] (gic_handle_irq) from [<c020d1b8>]
(__irq_svc+0x58/0x74)
[  293.459442] Exception stack(0xee3d1be0 to 0xee3d1c28)
[  293.459447] 1be0: edbe11a4 00000008 00681daf edbd6010 ee392800
edbe10e4 edbe10e4 ee392800
[  293.459451] 1c00: 00000000 c1803c48 00000000 00000002 00000000
ee3d1c30 00000000 c06e00a8
[  293.459454] 1c20: 20070013 ffffffff
[  293.459463] [<c020d1b8>] (__irq_svc) from [<c06e00a8>]
(bcm_sysport_get_stats64+0x94/0x104)
[  293.459474] [<c06e00a8>] (bcm_sysport_get_stats64) from [<c084a408>]
(dev_get_stats+0x38/0xac)
[  293.459485] [<c084a408>] (dev_get_stats) from [<c0863fc8>]
(rtnl_fill_stats+0x30/0x118)
[  293.459493] [<c0863fc8>] (rtnl_fill_stats) from [<c08645e8>]
(rtnl_fill_ifinfo+0x538/0xdc8)
[  293.459502] [<c08645e8>] (rtnl_fill_ifinfo) from [<c0868e30>]
(rtmsg_ifinfo_build_skb+0x6c/0xd8)
[  293.459507] [<c0868e30>] (rtmsg_ifinfo_build_skb) from [<c0868eb0>]
(rtmsg_ifinfo_event.part.6+0x14/0x44)
[  293.459512] [<c0868eb0>] (rtmsg_ifinfo_event.part.6) from
[<c0868f78>] (rtnetlink_event+0x70/0x7c)
[  293.459520] [<c0868f78>] (rtnetlink_event) from [<c0241778>]
(notifier_call_chain+0x44/0x84)
[  293.459527] [<c0241778>] (notifier_call_chain) from [<c0241918>]
(raw_notifier_call_chain+0x18/0x20)
[  293.459535] [<c0241918>] (raw_notifier_call_chain) from [<c084aef4>]
(netdev_features_change+0x28/0x44)
[  293.459542] [<c084aef4>] (netdev_features_change) from [<c08593e4>]
(dev_ethtool+0x404/0x28e0)
[  293.459551] [<c08593e4>] (dev_ethtool) from [<c0871910>]
(dev_ioctl+0x5c0/0x8a4)
[  293.459561] [<c0871910>] (dev_ioctl) from [<c0355a5c>]
(do_vfs_ioctl+0xac/0x7e4)
[  293.459569] [<c0355a5c>] (do_vfs_ioctl) from [<c03561c8>]
(SyS_ioctl+0x34/0x5c)
[  293.459576] [<c03561c8>] (SyS_ioctl) from [<c0208540>]
(ret_fast_syscall+0x0/0x34)
[  293.776281] rcu_sched       S    0     8      2 0x00000000
[  293.781794] [<c098eda4>] (__schedule) from [<c098f2f0>]
(schedule+0x44/0x9c)
[  293.788863] [<c098f2f0>] (schedule) from [<c0992984>]
(schedule_timeout+0x1c8/0x36c)
[  293.796627] [<c0992984>] (schedule_timeout) from [<c0281d8c>]
(rcu_gp_kthread+0x6bc/0xf7c)
[  293.804919] [<c0281d8c>] (rcu_gp_kthread) from [<c0240060>]
(kthread+0x128/0x158)
[  293.812423] [<c0240060>] (kthread) from [<c02085e8>]
(ret_from_fork+0x14/0x2c)

[  346.462654] INFO: rcu_sched self-detected stall on CPU
[  346.463655] INFO: rcu_sched detected stalls on CPUs/tasks:
[  346.463664]  0-...: (74005 ticks this GP) idle=eba/140000000000001/0
softirq=3159/3159 fqs=18231
[  346.463666]  (detected by 1, t=84007 jiffies, g=736, c=735, q=64)
[  346.463673] Sending NMI from CPU 1 to CPUs 0:
[  346.492658]  0-...: (74005 ticks this GP) idle=eba/140000000000001/0
softirq=3159/3159 fqs=18231
[  346.501547]   (t=84044 jiffies g=736 c=735 q=64)

-- 
Florian
