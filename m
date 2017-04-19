From: Stefan Agner <stefan@agner.ch>
Subject: Re: FEC on i.MX 7 transmit queue timeout
Date: Tue, 18 Apr 2017 22:01:37 -0700
Message-ID: <e99d7c93b7819507c6448842015bf836@agner.ch>
References: <c6b66956c48f981a952048da6b2ddd54@agner.ch>
 <ed24e51d-499f-597b-0c9f-7f180e257acb@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: fugang.duan@freescale.com, festevam@gmail.com,
        netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Andy Duan <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kmu-office.ch ([178.209.48.109]:43155 "EHLO
        mail.kmu-office.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759376AbdDSFBq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 01:01:46 -0400
In-Reply-To: <ed24e51d-499f-597b-0c9f-7f180e257acb@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy,

On 2017-04-18 19:24, Andy Duan wrote:
> On 2017年04月19日 03:46, Stefan Agner wrote:
>> Hi,
>>
>> I noticed last week on upstream (v4.11-rc6) on a Colibri iMX7 board that
>> after a while (~10 minutes) the detdev wachdog prints a stacktrace and
>> the driver then continuously dumps the TX ring. I then did a quick test
>> with 4.10, and realized it actually suffers the same issue, so it seems
>> not to be a regression. I use a rootfs mounted over NFS...
>>
>> ------------[ cut here ]------------
>> WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:316
>> dev_watchdog+0x240/0x244
>> NETDEV WATCHDOG: eth0 (fec): transmit queue 2 timed out
>> Modules linked in:
>> CPU: 0 PID: 0 Comm: swapper/0 Not tainted
>> 4.11.0-rc7-00030-g2c4e6bd0c4f0-dirty #330
>> Hardware name: Freescale i.MX7 Dual (Device Tree)
>> [<c02293f0>] (unwind_backtrace) from [<c0225820>] (show_stack+0x10/0x14)
>> [<c0225820>] (show_stack) from [<c050db6c>] (dump_stack+0x90/0xa0)
>> [<c050db6c>] (dump_stack) from [<c023ae68>] (__warn+0xac/0x11c)
>> [<c023ae68>] (__warn) from [<c023af10>] (warn_slowpath_fmt+0x38/0x48)
>> [<c023af10>] (warn_slowpath_fmt) from [<c088bb8c>]
>> (dev_watchdog+0x240/0x244)
>> [<c088bb8c>] (dev_watchdog) from [<c0294798>]
>> (run_timer_softirq+0x24c/0x708)
>> [<c0294798>] (run_timer_softirq) from [<c023f584>]
>> (__do_softirq+0x12c/0x2a8)
>> [<c023f584>] (__do_softirq) from [<c023f8c4>] (irq_exit+0xdc/0x13c)
>> [<c023f8c4>] (irq_exit) from [<c02818ac>]
>> (__handle_domain_irq+0xa4/0xf8)
>> [<c02818ac>] (__handle_domain_irq) from [<c0201624>]
>> (gic_handle_irq+0x34/0xa4)
>> [<c0201624>] (gic_handle_irq) from [<c0226338>] (__irq_svc+0x58/0x8c)
>> Exception stack(0xc1201f30 to 0xc1201f78)
>> 1f20:                                     c0233320 00000000 00000000
>> 01400000
>> 1f40: c1203d80 ffffe000 00000000 00000000 c107bf10 c0e055b5 c1203d34
>> 00000001
>> 1f60: c07d2324 c1201f80 c0222ac8 c0222acc 60000013 ffffffff
>> [<c0226338>] (__irq_svc) from [<c0222acc>] (arch_cpu_idle+0x38/0x3c)
>> [<c0222acc>] (arch_cpu_idle) from [<c0275f24>] (do_idle+0xa8/0x250)
>> [<c0275f24>] (do_idle) from [<c02760e4>] (cpu_startup_entry+0x18/0x1c)
>> [<c02760e4>] (cpu_startup_entry) from [<c1000aa0>]
>> (start_kernel+0x3fc/0x45c)
>> ---[ end trace 5b0c6dc3466a7918 ]---
>> fec 30be0000.ethernet eth0: TX ring dump
>> Nr     SC     addr       len  SKB
>>    0    0x1c00 0x00000000  590   (null)
>>    1    0x1c00 0x00000000  590   (null)
>>    2    0x1c00 0x00000000   42   (null)
>>    3  H 0x1c00 0x00000000   42   (null)
>>    4 S  0x0000 0x00000000    0   (null)
>>    5    0x0000 0x00000000    0   (null)
>>    6    0x0000 0x00000000    0   (null)
>>    7    0x0000 0x00000000    0   (null)
>>    8    0x0000 0x00000000    0   (null)
>>    9    0x0000 0x00000000    0   (null)
>>   10    0x0000 0x00000000    0   (null)
>>   11    0x0000 0x00000000    0   (null)
>>   12    0x0000 0x00000000    0   (null)
>>   13    0x0000 0x00000000    0   (null)
>>   14    0x0000 0x00000000    0   (null)
>>   15    0x0000 0x00000000    0   (null)
>>   16    0x0000 0x00000000    0   (null)
>>   17    0x0000 0x00000000    0   (null)
>>   18    0x0000 0x00000000    0   (null)
>> ...
>>
>>
>> A second TX ring dump from 4.10:
>> fec 30be0000.ethernet eth0: TX ring dump
>> Nr     SC     addr       len  SKB
>>    0    0x1c00 0x00000000   42   (null)
>>    1    0x1c00 0x00000000   42   (null)
>>    2    0x1c00 0x00000000   90   (null)
>>    3    0x1c00 0x00000000   90   (null)
>>    4    0x1c00 0x00000000   90   (null)
>>    5    0x1c00 0x00000000  218   (null)
>>    6    0x1c00 0x00000000  218   (null)
>>    7    0x1c00 0x00000000  218   (null)
>>    8    0x1c00 0x00000000   90   (null)
>>    9    0x1c00 0x00000000  206   (null)
>>   10    0x1c00 0x00000000  216   (null)
>>   11    0x1c00 0x00000000  216   (null)
>>   12    0x1c00 0x00000000  216   (null)
>>   13    0x1c00 0x00000000  311   (null)
>>   14    0x1c00 0x00000000  178   (null)
>>   15    0x1c00 0x00000000  311   (null)
>>   16    0x1c00 0x00000000  206   (null)
>>   17  H 0x1c00 0x00000000  311   (null)
>>   18 S  0x0000 0x00000000    0   (null)
>>   19    0x0000 0x00000000    0   (null)
> The dump show tx ring is fine.
> 
>>
>> The ring dump prints continously, but I can access console every now and
>> then. I noticed that the second interrupt seems static (66441, TX
>> interrupt?):
>>   58:         18     GIC-0 150 Level     30be0000.ethernet
>>   59:      66441     GIC-0 151 Level     30be0000.ethernet
>>   60:      70477     GIC-0 152 Level     30be0000.ethernet
> 150 irq number is for tx/rx queue 1 receive/transmit buffer/frame done.
> 151 irq number is for tx/rx queue 2 receive/transmit buffer/frame done.
> 152 irq number is for tx/rx queue 0 receive/transmit buffer/frame done, 
> mii interrupt and others.
> 
> i.MX7D enet has three queues for tx and rx.
> It seems netdev pick tx queue 1 rate is very rare by __netdev_pick_tx().

Oh ok I see, and it seems to choose queue 2 fairly often...

>> Anybody else seen this? Any idea?
>>
>> In 4.10 as well as 4.11-rc6 the interrupt counts were just over 65536...
>> pure chance?
>>
>>
> you can use ethtool to set the irq coalesce like:
> ethtool -c eth0 rx-frames 80
> ethtool -c eth0 rx-usecs 600
> ethtool -c eth0 tx-frames 64
> ethtool -c eth0 tx-usenc 700
> 
> 
> You don't run any test case, just nfs mount rootfs ?
> I will setup one imx7d sdb board to run it.

I noticed it without doing anything, just boot via NFS. There was always
a little bit of activity, at least according to the link (blinks every
~5s).

It seemd that it happened a bit earlier when using iperf to exacerbate
the problem...

I noticed that errata 7885 is not mentioned in the i.MX 7 errata, so I
created a new devtype:

        }, {
                .name = "imx7d-fec",
                .driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
                                FEC_QUIRK_HAS_BUFDESC_EX |
FEC_QUIRK_HAS_CSUM |
                                FEC_QUIRK_HAS_VLAN |
FEC_QUIRK_BUG_CAPTURE |
                                FEC_QUIRK_HAS_RACC |
FEC_QUIRK_HAS_COALESCE,
        }, {

I had that running for about 6h with iperf, it did not seem to happen
despite lots of traffic and interrupts:
 58:   12782877     GIC-0 150 Level     30be0000.ethernet
 59:   14607039     GIC-0 151 Level     30be0000.ethernet
 60:   32356307     GIC-0 152 Level     30be0000.ethernet

But just when I restarted the same stack trace appeared again....
