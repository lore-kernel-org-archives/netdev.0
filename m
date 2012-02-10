From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Bug 42754] New: BUG: sleeping function called from invalid context at mm/memory.c:3924
Date: Fri, 10 Feb 2012 17:30:27 +0100
Message-ID: <20120210163027.GA29329@electric-eye.fr.zoreil.com>
References: <bug-42754-27@https.bugzilla.kernel.org/> <20120209191317.2fbad57b.akpm@linux-foundation.org> <20120210122657.GA9347@smp.if.uj.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Witold Baryluk <baryluk@smp.if.uj.edu.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45251 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758171Ab2BJQmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 11:42:39 -0500
Content-Disposition: inline
In-Reply-To: <20120210122657.GA9347@smp.if.uj.edu.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Witold Baryluk <baryluk@smp.if.uj.edu.pl> :
> On 02-09 19:13, Andrew Morton wrote:
[...]
> https://bugzilla.kernel.org/show_bug.cgi?id=42754

For the sirdev part:

[...]
> [  182.080017] -> #1 (&port_lock_key){..-...}:
> [  182.080017]        [<c10b0f1b>] check_prevs_add+0xcb/0x120
> [  182.080017]        [<c10b14c7>] validate_chain.isra.34+0x557/0x6d0
> [  182.080017]        [<c10b3945>] __lock_acquire+0x355/0x820
> [  182.080017]        [<c10b4467>] lock_acquire+0x87/0x1b0
> [  182.080017]        [<c17c762e>] _raw_spin_lock_irqsave+0x5e/0xa0
> [  182.080017]        [<c13d5f32>] uart_write_room+0x22/0x60
> [  182.080017]        [<c13c1c19>] tty_write_room+0x19/0x20
> [  182.080017]        [<f876b512>] irtty_do_write+0x42/0xa0 [irtty_sir]
> [  182.080017]        [<f869a455>] sirdev_hard_xmit+0xc5/0x280 [sir_dev]

This is dev->drv->do_write in sirdev_hard_xmit.

> [  182.080017]        [<c159586f>] dev_hard_start_xmit+0x22f/0x690
> [  182.080017]        [<c15ba331>] sch_direct_xmit+0xa1/0x220
> [  182.080017]        [<c1595e45>] dev_queue_xmit+0x175/0x770
> [  182.080017]        [<f878e62a>] irlap_queue_xmit+0x9a/0xe0 [irda]
[...]
> [  182.080017]        [<f8787603>] irlmp_discovery_timer_expired+0x23/0x60 [irda]
> [  182.080017]        [<c105abad>] call_timer_fn+0x6d/0x2e0
> [  182.080017]        [<c105af0a>] run_timer_softirq+0xea/0x260
> [  182.080017]        [<c10524cf>] __do_softirq+0x9f/0x360
[...]
> [  182.080017] -> #0 (&(&dev->tx_lock)->rlock){..-...}:
> [  182.080017]        [<c10b0e45>] check_prev_add+0x605/0x610
> [  182.080017]        [<c10b0f1b>] check_prevs_add+0xcb/0x120
> [  182.080017]        [<c10b14c7>] validate_chain.isra.34+0x557/0x6d0
> [  182.080017]        [<c10b3945>] __lock_acquire+0x355/0x820
> [  182.080017]        [<c10b4467>] lock_acquire+0x87/0x1b0
> [  182.080017]        [<c17c762e>] _raw_spin_lock_irqsave+0x5e/0xa0
> [  182.080017]        [<f869a883>] sirdev_write_complete+0x23/0x280 [sir_dev]
> [  182.080017]        [<f876b671>] irtty_write_wakeup+0x31/0x90 [irtty_sir]
> [  182.080017]        [<c13ba332>] tty_wakeup+0x62/0x70
> [  182.080017]        [<c13d7686>] uart_write_wakeup+0x16/0x20
> [  182.080017]        [<c13daffe>] serial8250_tx_chars+0x8e/0x110
> [  182.080017]        [<c13dc157>] serial8250_handle_irq+0x97/0xa0
> [  182.080017]        [<c13dc17c>] serial8250_default_handle_irq+0x1c/0x20
> [  182.080017]        [<c13da1e5>] serial8250_interrupt+0x65/0xd0
> [  182.080017]        [<c10dfa26>] irq_forced_thread_fn+0x26/0x50
> [  182.080017]        [<c10df932>] irq_thread+0x152/0x1e0
> [  182.080017]        [<c10721f2>] kthread+0x72/0x80
> [  182.080017]        [<c17cfafa>] kernel_thread_helper+0x6/0x10
[...]
> [  182.080017]  Possible unsafe locking scenario:
> [  182.080017] 
> [  182.080017]        CPU0                    CPU1
> [  182.080017]        ----                    ----
> [  182.080017]   lock(&port_lock_key);
> [  182.080017]                                lock(&(&dev->tx_lock)->rlock);
> [  182.080017]                                lock(&port_lock_key);
> [  182.080017]   lock(&(&dev->tx_lock)->rlock);
> [  182.080017] 
> [  182.080017]  *** DEADLOCK ***

Once this tx_lock vs port_lock_key deadlock is fixed, there should be
a recursive port_lock_key deadlock through sirdev_write_complete own
dev->drv->do_write.

Paul, Alan, any hindsight about what the sirdev layer should do (or
avoid) regarding the latter ?

-- 
Ueimor
