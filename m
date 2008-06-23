From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH/RFC] remove irqs_disabled warning from local_bh_enable
Date: Mon, 23 Jun 2008 11:22:40 +0200
Message-ID: <200806231122.40934.mb@bu3sch.de>
References: <1213739834.3803.137.camel@johannes.berg> <200806201818.34904.mb@bu3sch.de> <20080623084123.GA32688@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	David Ellingsworth <david@identd.dyndns.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:48994 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753310AbYFWJXz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 05:23:55 -0400
In-Reply-To: <20080623084123.GA32688@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 23 June 2008 10:41:23 Ingo Molnar wrote:
> ---------------------->
> commit 24a5454d9f7863b00143760197f0ec29c8234289
> Author: Michael Buesch <mb@bu3sch.de>
> Date:   Fri Jun 20 18:18:34 2008 +0200
> 
>     net, vortex: fix lockup
>     
>     Ingo Molnar reported:
>     
>     -tip testing found that Johannes Berg's "softirq: remove irqs_disabled
>     warning from local_bh_enable" enhancement to lockdep triggers a new
>     warning on an old testbox that uses 3c59x vortex and netlogging:
>     
>     ----->
>     calling  vortex_init+0x0/0xb0
>     PCI: Found IRQ 10 for device 0000:00:0b.0
>     PCI: Sharing IRQ 10 with 0000:00:0a.0
>     PCI: Sharing IRQ 10 with 0000:00:0b.1
>     3c59x: Donald Becker and others.
>     0000:00:0b.0: 3Com PCI 3c556 Laptop Tornado at e0800400.
>     PCI: Enabling bus mastering for device 0000:00:0b.0
>     initcall vortex_init+0x0/0xb0 returned 0 after 47 msecs
>     ...
>     calling  init_netconsole+0x0/0x1b0
>     netconsole: local port 4444
>     netconsole: local IP 10.0.1.9
>     netconsole: interface eth0
>     netconsole: remote port 4444
>     netconsole: remote IP 10.0.1.16
>     netconsole: remote ethernet address 00:19:xx:xx:xx:xx
>     netconsole: device eth0 not up yet, forcing it
>     eth0:  setting half-duplex.
>     eth0:  setting full-duplex.
>     ------------[ cut here ]------------
>     WARNING: at kernel/softirq.c:137 local_bh_enable_ip+0xd1/0xe0()
>     Pid: 1, comm: swapper Not tainted 2.6.26-rc6-tip #2091
>      [<c0125ecf>] warn_on_slowpath+0x4f/0x70
>      [<c0126834>] ? release_console_sem+0x1b4/0x1d0
>      [<c0126d00>] ? vprintk+0x2a0/0x450
>      [<c012fde5>] ? __mod_timer+0xa5/0xc0
>      [<c046f7fd>] ? mdio_sync+0x3d/0x50
>      [<c0160ef6>] ? marker_probe_cb+0x46/0xa0
>      [<c0126ed7>] ? printk+0x27/0x50
>      [<c046f4c3>] ? vortex_set_duplex+0x43/0xc0
>      [<c046f521>] ? vortex_set_duplex+0xa1/0xc0
>      [<c0471b92>] ? vortex_timer+0xe2/0x3e0
>      [<c012b361>] local_bh_enable_ip+0xd1/0xe0
>      [<c08d9f9f>] _spin_unlock_bh+0x2f/0x40
>      [<c0471b92>] vortex_timer+0xe2/0x3e0
>      [<c014743b>] ? trace_hardirqs_on+0xb/0x10
>      [<c0147358>] ? trace_hardirqs_on_caller+0x88/0x160
>      [<c012f8b2>] run_timer_softirq+0x162/0x1c0
>      [<c0471ab0>] ? vortex_timer+0x0/0x3e0
>      [<c012b361>] local_bh_enable_ip+0xd1/0xe0
>      [<c08d9f9f>] _spin_unlock_bh+0x2f/0x40
>      [<c0471b92>] vortex_timer+0xe2/0x3e0
>      [<c014743b>] ? trace_hardirqs_on+0xb/0x10
>      [<c0147358>] ? trace_hardirqs_on_caller+0x88/0x160
>      [<c012f8b2>] run_timer_softirq+0x162/0x1c0
>      [<c0471ab0>] ? vortex_timer+0x0/0x3e0
>      [<c0471ab0>] ? vortex_timer+0x0/0x3e0
>      [<c012b60a>] __do_softirq+0x9a/0x160
>      [<c012b570>] ? __do_softirq+0x0/0x160
>      [<c0106775>] call_on_stack+0x15/0x30
>      [<c012b4f5>] ? irq_exit+0x55/0x60
>      [<c0106e85>] ? do_IRQ+0x85/0xd0
>      [<c0147391>] ? trace_hardirqs_on_caller+0xc1/0x160
>      [<c0104888>] ? common_interrupt+0x28/0x30
>      [<c08d8ac8>] ? mutex_unlock+0x8/0x10
>      [<c08d8180>] ? _cond_resched+0x10/0x30
>      [<c07a3be7>] ? netpoll_setup+0x117/0x390
>      [<c0cbfcfe>] ? init_netconsole+0x14e/0x1b0
>      [<c013d539>] ? ktime_get+0x19/0x40
>      [<c0c9bab2>] ? kernel_init+0x1b2/0x2c0
>      [<c0cbfbb0>] ? init_netconsole+0x0/0x1b0
>      [<c0396aa4>] ? trace_hardirqs_on_thunk+0xc/0x10
>      [<c0103f12>] ? restore_nocheck_notrace+0x0/0xe
>      [<c0c9b900>] ? kernel_init+0x0/0x2c0
>      [<c0c9b900>] ? kernel_init+0x0/0x2c0
>      [<c0104aa7>] ? kernel_thread_helper+0x7/0x10
>      =======================
>     ---[ end trace 37f9c502aff112e0 ]---
>     console [netcon0] enabled
>     netconsole: network logging started
>     initcall init_netconsole+0x0/0x1b0 returned 0 after 2914 msecs
>     
>     looking at the driver I think the bug is real and the fix actually
>     is trivial.
>     
>     vp->lock is also taken in hardware IRQ context, so we _have_ to always
>     use irqsafe locking. As we run in a timer with IRQs disabled,
>     we can simply use spin_lock.
>     
>     Cc: <stable@kernel.org>

Signed-off-by: Michael Buesch <mb@bu3sch.de>

>     Signed-off-by: Ingo Molnar <mingo@elte.hu>
> 
> diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
> index 2edda8c..aabad8c 100644
> --- a/drivers/net/3c59x.c
> +++ b/drivers/net/3c59x.c
> @@ -1768,9 +1768,10 @@ vortex_timer(unsigned long data)
>  	case XCVR_MII: case XCVR_NWAY:
>  		{
>  			ok = 1;
> -			spin_lock_bh(&vp->lock);
> +			/* Interrupts are already disabled */
> +			spin_lock(&vp->lock);
>  			vortex_check_media(dev, 0);
> -			spin_unlock_bh(&vp->lock);
> +			spin_unlock(&vp->lock);
>  		}
>  		break;
>  	  default:					/* Other media types handled by Tx timeouts. */
> 
> 



-- 
Greetings Michael.
