From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.12.2: inconsistent lock state
Date: Thu, 26 Dec 2013 07:12:38 -0800
Message-ID: <1388070758.12212.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52BC1963.3040808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Veaceslav Falico <vfalico@redhat.com>,
	Stancek <jstancek@redhat.com>
To: "Alexander E. Patrakov" <patrakov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:58165 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753244Ab3LZPMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 10:12:41 -0500
Received: by mail-pb0-f50.google.com with SMTP id rr13so8270418pbb.23
        for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 07:12:40 -0800 (PST)
In-Reply-To: <52BC1963.3040808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-26 at 17:56 +0600, Alexander E. Patrakov wrote:
> Hello.
> 
> I found this in my dmesg. Did not try to reproduce, and can't remember 
> for sure what I was doing at that time with tcpdump (quite possibly, 
> tried to capture the failed setup of a PPTP tunnel over wi-fi). The 
> taint is due to the zram module.
> 
> [939980.237255] nouveau  [   PLTCG][0000:01:00.0] LTC0_LTS0: 0x036f0000
> [939980.237271] nouveau  [   PLTCG][0000:01:00.0] LTC0_LTS1: 0x036f0040
> [959004.418950] PPP generic driver version 2.4.2
> 
> [964224.130554] =================================
> [964224.130556] [ INFO: inconsistent lock state ]
> [964224.130559] 3.12.2-gentoo #2 Tainted: G         CI
> [964224.130560] ---------------------------------
> [964224.130562] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
> [964224.130564] tcpdump/32136 [HC0[0]:SC0[0]:HE1:SE1] takes:
> [964224.130567]  (&(&list->lock)->rlock){+.?...}, at: 
> [<ffffffff8163a5d0>] packet_set_ring+0x550/0x6b0
> [964224.130579] {IN-SOFTIRQ-W} state was registered at:
> [964224.130581]   [<ffffffff810ae26c>] __lock_acquire+0x45c/0x1e50
> [964224.130587]   [<ffffffff810b04b1>] lock_acquire+0x91/0x150
> [964224.130590]   [<ffffffff81659211>] _raw_spin_lock_irqsave+0x41/0x60
> [964224.130595]   [<ffffffff8154311b>] skb_queue_tail+0x1b/0x50
> [964224.130600]   [<ffffffffa091e7cc>] tun_net_xmit+0x20c/0x3c0 [tun]
> [964224.130606]   [<ffffffff81554102>] dev_hard_start_xmit+0x322/0x5e0
> [964224.130611]   [<ffffffff8157311e>] sch_direct_xmit+0xee/0x270
> [964224.130616]   [<ffffffff8155461c>] dev_queue_xmit+0x25c/0x680
> [964224.130618]   [<ffffffff8155cc73>] neigh_resolve_output+0x123/0x260
> [964224.130623]   [<ffffffff815f96fc>] ip6_finish_output2+0x1ec/0x5c0
> [964224.130628]   [<ffffffff815fd9c8>] ip6_finish_output+0x98/0x200
> [964224.130631]   [<ffffffff815fdb85>] ip6_output+0x55/0x1b0
> [964224.130634]   [<ffffffff8161dc2f>] mld_sendpack+0x18f/0x340
> [964224.130639]   [<ffffffff8161f264>] mld_ifc_timer_expire+0x194/0x2a0
> [964224.130641]   [<ffffffff81052e75>] call_timer_fn+0x75/0x1e0
> [964224.130646]   [<ffffffff81053714>] run_timer_softirq+0x214/0x2d0
> [964224.130648]   [<ffffffff8104b087>] __do_softirq+0xe7/0x2b0
> [964224.130652]   [<ffffffff8166278c>] call_softirq+0x1c/0x30
> [964224.130656]   [<ffffffff81004a65>] do_softirq+0x65/0xa0
> [964224.130660]   [<ffffffff8104b3ce>] irq_exit+0x8e/0xb0
> [964224.130663]   [<ffffffff8102f66f>] smp_apic_timer_interrupt+0x3f/0x50
> [964224.130668]   [<ffffffff81661b6f>] apic_timer_interrupt+0x6f/0x80
> [964224.130671]   [<ffffffff8150dfa4>] cpuidle_idle_call+0xc4/0x280
> [964224.130675]   [<ffffffff8100bc49>] arch_cpu_idle+0x9/0x30
> [964224.130680]   [<ffffffff81099561>] cpu_startup_entry+0x221/0x290
> [964224.130684]   [<ffffffff8102d9f1>] start_secondary+0x1b1/0x210
> [964224.130688] irq event stamp: 13351
> [964224.130689] hardirqs last  enabled at (13351): [<ffffffff81656415>] 
> __mutex_unlock_slowpath+0xe5/0x190
> [964224.130692] hardirqs last disabled at (13350): [<ffffffff81656368>] 
> __mutex_unlock_slowpath+0x38/0x190
> [964224.130695] softirqs last  enabled at (13346): [<ffffffff8163a375>] 
> packet_set_ring+0x2f5/0x6b0
> [964224.130698] softirqs last disabled at (13344): [<ffffffff816590f1>] 
> _raw_spin_lock_bh+0x11/0x50
> [964224.130701]
> other info that might help us debug this:
> [964224.130703]  Possible unsafe locking scenario:
> 
> [964224.130704]        CPU0
> [964224.130705]        ----
> [964224.130707]   lock(&(&list->lock)->rlock);
> [964224.130709]   <Interrupt>
> [964224.130710]     lock(&(&list->lock)->rlock);
> [964224.130712]
>   *** DEADLOCK ***
> 
> [964224.130715] 1 lock held by tcpdump/32136:
> [964224.130716]  #0:  (sk_lock-AF_PACKET){+.+.+.}, at: 
> [<ffffffff8163a2c7>] packet_set_ring+0x247/0x6b0
> [964224.130722]
> stack backtrace:
> [964224.130725] CPU: 2 PID: 32136 Comm: tcpdump Tainted: G CI  
> 3.12.2-gentoo #2
> [964224.130727] Hardware name: To Be Filled By O.E.M. To Be Filled By 
> O.E.M./HM55-MXM, BIOS P1.20 10/24/2010
> [964224.130729]  ffffffff8221c8e0 ffff8800b7789b80 ffffffff8165210b 
> ffff88019bc0e000
> [964224.130733]  ffff8800b7789bd0 ffffffff8164d904 0000000000000000 
> ffff880100000001
> [964224.130737]  ffff880000000001 0000000000000004 ffff88019bc0e740 
> ffffffff810ac830
> [964224.130741] Call Trace:
> [964224.130744]  [<ffffffff8165210b>] dump_stack+0x4e/0x82
> [964224.130750]  [<ffffffff8164d904>] print_usage_bug.part.36+0x28f/0x29e
> [964224.130754]  [<ffffffff810ac830>] ? check_usage_forwards+0x150/0x150
> [964224.130756]  [<ffffffff810ad3b6>] mark_lock+0x1c6/0x650
> [964224.130759]  [<ffffffff810ae393>] __lock_acquire+0x583/0x1e50
> [964224.130762]  [<ffffffff81659422>] ? _raw_spin_unlock_irq+0x32/0x60
> [964224.130766]  [<ffffffff810b04b1>] lock_acquire+0x91/0x150
> [964224.130769]  [<ffffffff8163a5d0>] ? packet_set_ring+0x550/0x6b0
> [964224.130772]  [<ffffffff816590c6>] _raw_spin_lock+0x36/0x50
> [964224.130774]  [<ffffffff8163a5d0>] ? packet_set_ring+0x550/0x6b0
> [964224.130777]  [<ffffffff8163a5d0>] packet_set_ring+0x550/0x6b0
> [964224.130781]  [<ffffffff8163a8d5>] packet_release+0x1a5/0x310
> [964224.130785]  [<ffffffff815395aa>] sock_release+0x1a/0x80
> [964224.130788]  [<ffffffff8153961d>] sock_close+0xd/0x20
> [964224.130793]  [<ffffffff8117ea62>] __fput+0xb2/0x240
> [964224.130796]  [<ffffffff8117ec29>] ____fput+0x9/0x10
> [964224.130801]  [<ffffffff8106616c>] task_work_run+0x9c/0xd0
> [964224.130807]  [<ffffffff81002d77>] do_notify_resume+0x87/0x90
> [964224.130810]  [<ffffffff816610b2>] int_signal+0x12/0x17
> 

Probably fixed by commit ec6f809ff6f19fafba3212f6aff0dda71dfac8e8
("af_packet: block BH in prb_shutdown_retire_blk_timer()")

Its in v3.12.4 already.

Thanks
