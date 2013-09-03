From: Stephen Warren <swarren@wwwdotorg.org>
Subject: Re: [PATCH v2] ipv6: Don't depend on per socket memory for neighbour
 discovery messages
Date: Tue, 03 Sep 2013 12:03:14 -0600
Message-ID: <52262462.80308@wwwdotorg.org>
References: <e4600dac657e1160da7a5e7758dcb973b616a10e.1378207925.git.tgraf@suug.ch>  <52261A12.3060203@wwwdotorg.org>  <20130903172736.GB21729@order.stressinduktion.org>  <52261F68.70907@wwwdotorg.org> <1378230697.7360.38.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org, Fabio Estevam <festevam@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avon.wwwdotorg.org ([70.85.31.133]:54045 "EHLO
	avon.wwwdotorg.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754571Ab3ICSDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 14:03:18 -0400
In-Reply-To: <1378230697.7360.38.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2013 11:51 AM, Eric Dumazet wrote:
> On Tue, 2013-09-03 at 11:42 -0600, Stephen Warren wrote:
> 
>> I don't see any extra messages from PROVE_LOCKING related to networking.
>> There is a single extra message from inside the audio driver, but that's
>> not networking-related at all.
> 
> LOCKDEP is automatically disabled at first splat.
> 
> Please try a kernel without audio driver ;)

Ah, OK. Now I do see something from ipv6:

> [   25.327622] 
> [   25.329142] =============================================
> [   25.334533] [ INFO: possible recursive locking detected ]
> [   25.339927] 3.11.0-rc7-next-20130830-00024-g209b4d8-dirty #17 Not tainted
> [   25.346705] ---------------------------------------------
> [   25.352095] login/704 is trying to acquire lock:
> [   25.356705]  (&ndev->lock){++--..}, at: [<c049be24>] ipv6_chk_mcast_addr+0x5c/0x200
> [   25.364405] 
> [   25.364405] but task is already holding lock:
> [   25.370230]  (&ndev->lock){++--..}, at: [<c0480eb4>] addrconf_rs_timer+0x18/0x134
> [   25.377741] 
> [   25.377741] other info that might help us debug this:
> [   25.384261]  Possible unsafe locking scenario:
> [   25.384261] 
> [   25.390174]        CPU0
> [   25.392614]        ----
> [   25.395053]   lock(&ndev->lock);
> [   25.398286]   lock(&ndev->lock);
> [   25.401518] 
> [   25.401518]  *** DEADLOCK ***
> [   25.401518] 
> [   25.407433]  May be due to missing lock nesting notation
> [   25.407433] 
> [   25.414214] 4 locks held by login/704:
> [   25.417955]  #0:  (((&ndev->rs_timer))){+.-...}, at: [<c002f8a8>] call_timer_fn+0x0/0xe4
> [   25.426076]  #1:  (&ndev->lock){++--..}, at: [<c0480eb4>] addrconf_rs_timer+0x18/0x134
> [   25.434018]  #2:  (rcu_read_lock){.+.+..}, at: [<c048e104>] ndisc_send_skb+0x58/0x3dc
> [   25.441876]  #3:  (rcu_read_lock){.+.+..}, at: [<c049bdc8>] ipv6_chk_mcast_addr+0x0/0x200
> [   25.450079] 
> [   25.450079] stack backtrace:
> [   25.454436] CPU: 0 PID: 704 Comm: login Not tainted 3.11.0-rc7-next-20130830-00024-g209b4d8-dirty #17
> [   25.463674] [<c0016958>] (unwind_backtrace+0x0/0x138) from [<c00125fc>] (show_stack+0x10/0x14)
> [   25.472297] [<c00125fc>] (show_stack+0x10/0x14) from [<c0567808>] (dump_stack+0x80/0xc4)
> [   25.480394] [<c0567808>] (dump_stack+0x80/0xc4) from [<c0074af8>] (validate_chain.isra.24+0x74c/0x8c8)
> [   25.489696] [<c0074af8>] (validate_chain.isra.24+0x74c/0x8c8) from [<c00757b0>] (__lock_acquire+0x3bc/0xa80)
> [   25.499518] [<c00757b0>] (__lock_acquire+0x3bc/0xa80) from [<c007632c>] (lock_acquire+0x60/0x74)
> [   25.508305] [<c007632c>] (lock_acquire+0x60/0x74) from [<c056e998>] (_raw_read_lock_bh+0x4c/0x5c)
> [   25.517175] [<c056e998>] (_raw_read_lock_bh+0x4c/0x5c) from [<c049be24>] (ipv6_chk_mcast_addr+0x5c/0x200)
> [   25.526740] [<c049be24>] (ipv6_chk_mcast_addr+0x5c/0x200) from [<c04799ac>] (ip6_finish_output2+0x298/0x62c)
> [   25.536563] [<c04799ac>] (ip6_finish_output2+0x298/0x62c) from [<c048e2b0>] (ndisc_send_skb+0x204/0x3dc)
> [   25.546037] [<c048e2b0>] (ndisc_send_skb+0x204/0x3dc) from [<c0480fa4>] (addrconf_rs_timer+0x108/0x134)
> [   25.555425] [<c0480fa4>] (addrconf_rs_timer+0x108/0x134) from [<c002f914>] (call_timer_fn+0x6c/0xe4)
> [   25.564553] [<c002f914>] (call_timer_fn+0x6c/0xe4) from [<c0030220>] (run_timer_softirq+0x180/0x22c)
> [   25.573691] [<c0030220>] (run_timer_softirq+0x180/0x22c) from [<c002a210>] (__do_softirq+0x100/0x1fc)
> [   25.582905] [<c002a210>] (__do_softirq+0x100/0x1fc) from [<c002a6d8>] (irq_exit+0xa8/0xf4)
> [   25.591166] [<c002a6d8>] (irq_exit+0xa8/0xf4) from [<c000f9b8>] (handle_IRQ+0x3c/0x94)
> [   25.599078] [<c000f9b8>] (handle_IRQ+0x3c/0x94) from [<c0008700>] (gic_handle_irq+0x28/0x5c)
> [   25.607511] [<c0008700>] (gic_handle_irq+0x28/0x5c) from [<c00132fc>] (__irq_usr+0x3c/0x60)
> [   25.615855] Exception stack(0xee0d9fb0 to 0xee0d9ff8)
> [   25.620901] 9fa0:                                     5c026e4c c9ce71d5 538e8b11 f2a43512
> [   25.629072] 9fc0: 49f97e42 7a179ff1 9c755700 9b933273 8b7a2401 6d6222ee 7b8908fd 1df2f704
> [   25.637243] 9fe0: 2664e738 bec3ef10 b6d440e9 b6d43d58 900f0030 ffffffff
