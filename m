From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] inet: fix races with reqsk timers
Date: Thu, 13 Aug 2015 13:19:33 -0700
Message-ID: <1439497173.7960.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439222953.1084.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150810.211821.2246516216165801977.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34170 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753295AbbHMUTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 16:19:35 -0400
Received: by paccq16 with SMTP id cq16so608521pac.1
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 13:19:35 -0700 (PDT)
In-Reply-To: <20150810.211821.2246516216165801977.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-08-10 at 21:18 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 10 Aug 2015 09:09:13 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > reqsk_queue_destroy() and reqsk_queue_unlink() should use
> > del_timer_sync() instead of del_timer() before calling reqsk_put(),
> > otherwise we could free a req still used by another cpu.
> > 
> > But before doing so, reqsk_queue_destroy() must release syn_wait_lock
> > spinlock or risk a dead lock, as reqsk_timer_handler() might
> > need to take this same spinlock from reqsk_queue_unlink() (called from
> > inet_csk_reqsk_queue_drop())
> > 
> > Fixes: fa76ce7328b2 ("inet: get rid of central tcp/dccp listener timer")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied and queued up for -stable.

It seems I added another bug with this commit.

[18875.001804] BUG: soft lockup - CPU#39 stuck for 11s! [swapper/39:0]
[18875.008068] Modules linked in: udp_diag iptable_filter bonding w1_therm wire i2c_mux_pca954x i2c_mux mlx4_i2c i2c_usb cdc_acm ehci_
pci ehci_hcd i2c_dev i2c_i801 i2c_iimc i2c_core i2c_debug msr cpuid genrtc mlx4_en ib_uverbs mlx4_ib ib_sa ib_mad ib_core nv_p2p_glue 
mlx4_core
[18875.008085] CPU: 39 PID: 0 Comm: swapper/39 Tainted: G        W     3.11.10-smp-DEV #142
[18875.008088] task: ffff88012c694b80 ti: ffff88012c698000 task.ti: ffff88012c698000
[18875.008089] RIP: 0010:[<ffffffffaec039fe>]  [<ffffffffaec039fe>] _raw_spin_unlock_irqrestore+0xe/0x10
[18875.008096] RSP: 0018:ffff88407f3e3d40  EFLAGS: 00000286
[18875.008097] RAX: ffff8820ac938000 RBX: ffff88407f3e3ce0 RCX: 000000000000000a
[18875.008098] RDX: 0000000000000a0a RSI: 0000000000000286 RDI: ffff8820ac938000
[18875.008099] RBP: ffff88407f3e3d40 R08: 000010dca51a47c7 R09: ffff8820ac938000
[18875.008099] R10: 0000000000000005 R11: 0000000000000000 R12: ffff88407f3e3cb8
[18875.008100] R13: ffffffffaf1f7d0a R14: ffff88407f3e3d40 R15: 00000000ffffffff
[18875.008101] FS:  0000000000000000(0000) GS:ffff88407f3e0000(0000) knlGS:0000000000000000
[18875.008102] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[18875.008103] CR2: 0000000000440380 CR3: 000000002f60d000 CR4: 00000000001427e0
[18875.008104] Stack:
[18875.008105]  ffff88407f3e3d70 ffffffffaec75cbf ffffffffffffff10 0000000000000286
[18875.008114]  ffff8820bc0c72a8 ffff88012e336040 ffff88407f3e3d90 ffffffffaec75d3a
[18875.008123]  ffff88407f3e3e10 ffff8820bc0c7200 ffff88407f3e3dc0 ffffffffaf14566c
[18875.008131] Call Trace:
[18875.008132]  <IRQ> 
[18875.008135]  [<ffffffffaec75cbf>] try_to_del_timer_sync+0x4f/0x70
[18875.008145]  [<ffffffffaec75d3a>] del_timer_sync+0x5a/0x70
[18875.008150]  [<ffffffffaf14566c>] inet_csk_reqsk_queue_drop+0x7c/0x200
[18875.008154]  [<ffffffffaf145a68>] reqsk_timer_handler+0x278/0x2e0
[18875.008157]  [<ffffffffaf1457f0>] ? inet_csk_reqsk_queue_drop+0x200/0x200
[18875.008161]  [<ffffffffaec74a9a>] call_timer_fn+0x3a/0x110
[18875.008164]  [<ffffffffaf1457f0>] ? inet_csk_reqsk_queue_drop+0x200/0x200
[18875.008168]  [<ffffffffaec75fb0>] run_timer_softirq+0x1f0/0x2c0
[18875.008171]  [<ffffffffaec6cf40>] __do_softirq+0xe0/0x220
[18875.008176]  [<ffffffffaf1f87dc>] call_softirq+0x1c/0x30
[18875.008181]  [<ffffffffaec14d25>] do_softirq+0x55/0x90
[18875.008184]  [<ffffffffaec6d1f5>] irq_exit+0xa5/0xb0
[18875.008188]  [<ffffffffaec04075>] smp_apic_timer_interrupt+0x75/0x90
[18875.008192]  [<ffffffffaf1f7d0a>] apic_timer_interrupt+0x6a/0x70
[18875.008193]  <EOI> 

A caller handler can not call del_timer_sync()
