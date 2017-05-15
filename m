From: Stefan Agner <stefan@agner.ch>
Subject: Re: [PATCH] net: fec: select queue depending on VLAN priority
Date: Sun, 14 May 2017 22:39:26 -0700
Message-ID: <2f01cfbfae700463dc09433064006429@agner.ch>
References: <20170509053708.2573-1-stefan@agner.ch>
 <20170509.093913.1803457630634565212.davem@davemloft.net>
 <AM4PR0401MB2260BA1BC2F65B36284CF7D2FFEC0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <ed62e3b2eb91f7ef795279e92e249c51@agner.ch>
 <AM4PR0401MB2260CCF651251378BBE13CB7FFED0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, andrew@lunn.ch,
        festevam@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andy Duan <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kmu-office.ch ([178.209.48.109]:42478 "EHLO
        mail.kmu-office.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756096AbdEOFkG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 01:40:06 -0400
In-Reply-To: <AM4PR0401MB2260CCF651251378BBE13CB7FFED0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-05-10 21:49, Andy Duan wrote:
> From: Stefan Agner <stefan@agner.ch> Sent: Thursday, May 11, 2017 12:08 PM
>>To: Andy Duan <fugang.duan@nxp.com>
>>Cc: David Miller <davem@davemloft.net>; andrew@lunn.ch;
>>festevam@gmail.com; netdev@vger.kernel.org; linux-
>>kernel@vger.kernel.org
>>Subject: Re: [PATCH] net: fec: select queue depending on VLAN priority
>>
>>On 2017-05-09 19:42, Andy Duan wrote:
>>> From: David Miller <davem@davemloft.net> Sent: Tuesday, May 09, 2017
>>> 9:39 PM
>>>>To: stefan@agner.ch
>>>>Cc: Andy Duan <fugang.duan@nxp.com>; andrew@lunn.ch;
>>>>festevam@gmail.com; netdev@vger.kernel.org; linux-
>>>>kernel@vger.kernel.org
>>>>Subject: Re: [PATCH] net: fec: select queue depending on VLAN priority
>>>>
>>>>From: Stefan Agner <stefan@agner.ch>
>>>>Date: Mon,  8 May 2017 22:37:08 -0700
>>>>
>>>>> Since the addition of the multi queue code with commit 59d0f7465644
>>>>> ("net: fec: init multi queue date structure") the queue selection
>>>>> has been handelt by the default transmit queue selection
>>>>> implementation which tries to evenly distribute the traffic across
>>>>> all available queues. This selection presumes that the queues are
>>>>> using an equal priority, however, the queues 1 and 2 are actually of
>>>>> higher priority (the classification of the queues is enabled in
>>fec_enet_enable_ring).
>>>>>
>>>>> This can lead to net scheduler warnings and continuous TX ring dumps
>>>>> when exercising the system with iperf.
>>>>>
>>>>> Use only queue 0 for all common traffic (no VLAN and P802.1p
>>>>> priority
>>>>> 0 and 1) and route level 2-7 through queue 1 and 2.
>>>>>
>>>>> Signed-off-by: Fugang Duan <fugang.duan@nxp.com>
>>>>> Fixes: 59d0f7465644 ("net: fec: init multi queue date structure")
>>>>
>>>>If the queues are used for prioritization, and it does not have
>>>>multiple normal priority level queues, multiqueue is not what the
>>>>driver should have implemented.
>>> Firstly, HW multiple queues support:
>>> 	- Traffic-shaping bandwidth distribution supports credit-based and
>>> round-robin-based policies. Either policy can be combined with
>>> time-based shaping.
>>> 	- AVB (Audio Video Bridging, IEEE 802.1Qav) features:
>>> 		* Credit-based bandwidth distribution policy can be combined
>>with
>>> time-based shaping
>>> 		* AVB endpoint talker and listener support
>>> 		* Support for arbitration between different priority traffic (for
>>> example, AVB class A, AVB class B, and non-AVB) Round-robin-based
>>> policies:
>>> 	It has the same priority for three queues: In the round-robin QoS
>>> scheme, each queue is given an equal opportunity to transmit one
>>> frame. For example, if queue n has a frame to transmit, the queue
>>> transmits its frame. After queue n has transmitted its frame, or if
>>> queue n does not have a frame to transmit, queue n+1 is then allowed
>>> to transmit its frame, and so on.
>>>
>>> Credit-based policies:
>>> 	The AVB credit based shaper acts independently, per class, to control
>>> the bandwidth distribution between normal traffic and time-sensitive
>>> traffic with respect to the total link bandwidth available.
>>> 	Credit based shaper conbined with time-based shaping:
>>> 		- priority: ClassA queue > ClassB queue > best effort
>>> 		- ensure the queue bandwidth as user set based on time-
>>based shaping
>>> algorithms (transmitter transmit frame from three queue in turn based
>>> on time-based shaping algorithms)
>>> 	And in real AVB case,  each streaming can be independent, and are
>>> fixed on related queue. Then driver level should implement
>>> .ndo_select_queue() to put the streaming into related queue. That is
>>> what the patch did.
>>>
>>> The current driver config the three queue to credit-based policies
>>> (AVB), the patch seems no problem for the implementation. Do you have
>>> any suggestion ?
>>>
>>
>>I tried using the round robin mode by adding this:
>>
>>+       /* Set Round-Robin policy */
>>+       writel(1, fep->hwp + FEC_QOS_SCHEME);
>>
>>After a while I got the warning non the less:
>>
>>WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:316
>>dev_watchdog+0x248/0x24c NETDEV WATCHDOG: eth0 (fec): transmit queue
>>2 timed out Modules linked in:
>>CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.11.0-rc1-00058-g56d22eced8bc-
>>dirty #377 Hardware name: Freescale i.MX7 Dual (Device Tree) [<c02266b0>]
>>(unwind_backtrace) from [<c0222d7c>] (show_stack+0x10/0x14) [<c0222d7c>]
>>(show_stack) from [<c04d4098>] (dump_stack+0x78/0x8c) [<c04d4098>]
>>(dump_stack) from [<c0236548>] (__warn+0xe8/0x100) [<c0236548>]
>>(__warn) from [<c0236598>] (warn_slowpath_fmt+0x38/0x48) [<c0236598>]
>>(warn_slowpath_fmt) from [<c0805904>]
>>(dev_watchdog+0x248/0x24c)
>>[<c0805904>] (dev_watchdog) from [<c028a0e8>] (call_timer_fn+0x28/0x98)
>>[<c028a0e8>] (call_timer_fn) from [<c028a1f8>] (expire_timers+0xa0/0xac)
>>[<c028a1f8>] (expire_timers) from [<c028a2a0>]
>>(run_timer_softirq+0x9c/0x194)
>>[<c028a2a0>] (run_timer_softirq) from [<c023aaf8>]
>>(__do_softirq+0x114/0x234)
>>[<c023aaf8>] (__do_softirq) from [<c023aee4>] (irq_exit+0xcc/0x108)
>>[<c023aee4>] (irq_exit) from [<c0279920>]
>>(__handle_domain_irq+0x80/0xec)
>>[<c0279920>] (__handle_domain_irq) from [<c0201544>]
>>(gic_handle_irq+0x48/0x8c)
>>[<c0201544>] (gic_handle_irq) from [<c0223838>] (__irq_svc+0x58/0x8c)
>>Exception stack(0xc1001f28 to 0xc1001f70)
>>1f20:                   00000001 00000000 00000000 c022fdc0 c1000000
>>c1003d80
>>1f40: c1003d34 c0e72ed0 c0bd9b04 c1001f80 00000000 00000000 00000000
>>c1001f78
>>1f60: c022048c c0220490 60000013 ffffffff [<c0223838>] (__irq_svc) from
>>[<c0220490>] (arch_cpu_idle+0x38/0x3c) [<c0220490>] (arch_cpu_idle) from
>>[<c026ec60>] (do_idle+0x170/0x204) [<c026ec60>] (do_idle) from
>>[<c026efac>] (cpu_startup_entry+0x18/0x1c) [<c026efac>]
>>(cpu_startup_entry) from [<c0e00c88>]
>>(start_kernel+0x394/0x3a0)
>>---[ end trace a474f341d40e0705 ]---
>>fec 30be0000.ethernet eth0: TX ring dump
>>
>>I disabled the regular ring dump and only printed one line. It seems to come
>>up every 2 seconds, and checking cat /proc/interrupts showed that queue 2
>>stayed at its last value (3562218):
>>
>> 58:    3091320     GIC-0 150 Level     30be0000.ethernet
>> 59:    3562218     GIC-0 151 Level     30be0000.ethernet
>> 60:   13377922     GIC-0 152 Level     30be0000.ethernet
> 
> Pls check ENETx_DMAnCFG[16] whether is set, and disable time-based
> shaping for round robin.

When I do not set ENETx_DMAnCFG[16] (DMA_CLASS_EN), then networking
stops working (I cannot mount NFS).

Time-based is disabled by default I guess?
