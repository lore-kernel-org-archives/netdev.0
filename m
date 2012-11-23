From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: BQL support in gianfar causes network hickup
Date: Fri, 23 Nov 2012 11:34:33 -0500
Message-ID: <50AFA599.9040108@windriver.com>
References: <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6E@Exchange1.lawo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "Keitel, Tino (ALC NetworX GmbH)" <Tino.Keitel@alcnetworx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57779 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755762Ab2KWQek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2012 11:34:40 -0500
In-Reply-To: <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6E@Exchange1.lawo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-11-23 10:58 AM, Keitel, Tino (ALC NetworX GmbH) wrote:
> Hi,
> 
> commit d8a0f1b0af67679bba886784de10d8c21acc4e0e causes the following
> trace on a Freescale RDB8313 board:

Thanks for the report.

> 
> NETDEV WATCHDOG: eth1 (fsl-gianfar): transmit queue 0 timed out
> ------------[ cut here ]------------
> WARNING:
> at /home/keitelt1/src/git/linux-stable/net/sched/sch_generic.c:255
> Modules linked in:
> NIP: c02448b0 LR: c02448b0 CTR: c01c19b8
> REGS: c7ffbe40 TRAP: 0700   Not tainted  (3.7.0-rc6-rt18)
                                            ^^^^^^^^^^^^^^^
I almost overlooked the above.  It would have been nice to
see more explicit information on what kernel you are running.
I say that because the above concerns me.  For several reasons.

1) it looks to be not mainline, but preempt_rt
2) There is no RT on 3.7 yet, so I'm assuming this is a custom
   forward port of the 250 odd RT patches.  (The RT is 3.6.7-rt18,
   i.e. based on the 3.6 gregKH stable tree.)

> MSR: 00029032 <EE,ME,IR,DR,RI>  CR: 24002044  XER: 20000000
> TASK = c03dd370[0] 'swapper' THREAD: c03fe000
> GPR00: c02448b0 c7ffbef0 c03dd370 0000003f 00000001 c001aea8 00000000
> 00000001
> GPR08: 00000001 c03e0000 00000000 0000009d 24002084 1008eb5c 07ffb000
> ffffffff
> GPR16: 00000004 c0362c7c c03dfbf8 00200000 c0411ed0 c0411cd0 c0411ad0
> ffffffff
> GPR24: 00000000 c749e1d8 00000004 c783d1b0 c0400000 c03e0000 c749e000
> 00000000
> NIP [c02448b0] dev_watchdog+0x288/0x298
> LR [c02448b0] dev_watchdog+0x288/0x298
> Call Trace:
> [c7ffbef0] [c02448b0] dev_watchdog+0x288/0x298 (unreliable)
> [c7ffbf20] [c00267f8] call_timer_fn+0x6c/0xd8
> [c7ffbf50] [c00269e4] run_timer_softirq+0x180/0x1f8
> [c7ffbfa0] [c0021144] __do_softirq+0xc4/0x160
> [c7ffbff0] [c000d0b8] call_do_softirq+0x14/0x24
> [c03ffe90] [c00058e8] do_softirq+0x8c/0xb8
> [c03ffeb0] [c0021358] irq_exit+0x98/0xb4
> [c03ffec0] [c0009fb0] timer_interrupt+0x158/0x170
> [c03ffee0] [c000f02c] ret_from_except+0x0/0x14
> --- Exception: 901 at cpu_idle+0x94/0x100
>     LR = cpu_idle+0x94/0x100
> [c03fffa0] [c00088ec] cpu_idle+0x5c/0x100 (unreliable)
> [c03fffc0] [c03b37b0] start_kernel+0x2dc/0x2f0
> [c03ffff0] [00003438] 0x3438
> Instruction dump:
> 7d2903a6 4e800421 80fe01fc 4bffff74 7fc3f378 4bfecb7d 7fc4f378 7fe6fb78
> 7c651b78 3c60c038 38637280 48090e69 <0fe00000> 39200001 993cc7c9
> 4bffffb8
> ---[ end trace 32125455035c2f70 ]---
> 
> With this commit reverted, it works fine. v3.3 is ok, v3.4 contains the
> bad commit. The commit doesn't revert in a clean way in 3.7-rc6. I
> attached diff without the tqi changes.

Have you reproduced this on a mainline kernel, i.e. vanilla 3.4
or vanilla 3.7-rc6?  And then done a revert on that baseline?

The patch was relatively straightforward and reviewed by Eric
who knows this stuff inside out; it isn't immediately clear
to me why it would cause problems for you.

Paul.
--

> 
> The above trace happens while a ptp client (for IEEE1588) is running, so
> there is some locally generated network traffic. The client stops to
> work after this, but maybe this is due to bad error handling.
> 
> Regards,
> Tino
> 
