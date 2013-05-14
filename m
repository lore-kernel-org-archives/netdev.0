From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/802/mrp: fix lockdep splat
Date: Tue, 14 May 2013 12:40:01 -0700
Message-ID: <1368560401.4519.25.camel@edumazet-glaptop>
References: <6901a7785249816fe13a98e3c0b35127@visp.net.lb>
	 <1368447851.13473.119.camel@edumazet-glaptop>
	 <16b0a5ee4602cb9005dd67ea7ad0d4e8@visp.net.lb>
	 <20130514.120754.1745967383330029903.davem@davemloft.net>
	 <1368559307.4519.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, amwang@redhat.com, david.ward@ll.mit.edu,
	hayeswang@realtek.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f182.google.com ([209.85.213.182]:62828 "EHLO
	mail-ye0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755376Ab3ENTkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 15:40:04 -0400
Received: by mail-ye0-f182.google.com with SMTP id m15so186348yen.27
        for <netdev@vger.kernel.org>; Tue, 14 May 2013 12:40:03 -0700 (PDT)
In-Reply-To: <1368559307.4519.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-14 at 12:21 -0700, Eric Dumazet wrote:
> On Tue, 2013-05-14 at 12:07 -0700, David Miller wrote:
> 
> > Can you double check that you really had Eric's patch applied?
> > lockdep appears to be complaining about the same thing in your
> > log dump, as if the patch was not really applied.
> > 
> > It's saying that app->lock can be taken from the join timer in
> > softirq, but mrp_uninit_applicant() takes it without disabling
> > softirqs.
> > 
> > Eric's patch explicitly fixes this, by making sure that spin_lock_bh()
> > is used there.
> 
> I am going to test this myself, it seems quite simple.
> I'll add a Tested-by: tag once done.

I definitely could trigger the bug easily without my patch :

[  296.523421] 8021q: 802.1Q VLAN Support v1.8
[  296.523478] 8021q: adding VLAN 0 to HW filter on device eth4
[  322.070382] 
[  322.071882] =================================
[  322.076234] [ INFO: inconsistent lock state ]
[  322.080588] 3.10.0-dbg-DEV #383 Not tainted
[  322.084769] ---------------------------------
[  322.089122] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
[  322.095124] ip/19081 [HC0[0]:SC0[0]:HE1:SE1] takes:
[  322.099995]  (&(&app->lock)->rlock){+.?...}, at: [<ffffffffa0240804>] mrp_uninit_applicant+0x54/0x110 [mrp]
[  322.109805] {IN-SOFTIRQ-W} state was registered at:
[  322.114676]   [<ffffffff810dbcb7>] __lock_acquire+0x747/0x1c50
[  322.120531]   [<ffffffff810dd7c7>] lock_acquire+0x97/0x150
[  322.126028]   [<ffffffff815fc5d1>] _raw_spin_lock+0x41/0x50
[  322.131622]   [<ffffffffa02408de>] mrp_join_timer+0x1e/0x70 [mrp]
[  322.137727]   [<ffffffff81096c3f>] call_timer_fn+0x7f/0x1e0
[  322.143323]   [<ffffffff81097a94>] run_timer_softirq+0x214/0x2d0
[  322.149340]   [<ffffffff8108f6a5>] __do_softirq+0xe5/0x2c0
[  322.154838]   [<ffffffff8108fa1e>] irq_exit+0x9e/0xc0
[  322.159903]   [<ffffffff816073ee>] smp_apic_timer_interrupt+0x6e/0x99
[  322.166353]   [<ffffffff8160652f>] apic_timer_interrupt+0x6f/0x80
[  322.172458]   [<ffffffff81055f2e>] arch_cpu_idle+0x1e/0x30
[  322.177966]   [<ffffffff810cdb3f>] cpu_startup_entry+0x14f/0x290
[  322.183992]   [<ffffffff815e33e6>] rest_init+0xd6/0xe0
[  322.189145]   [<ffffffff81cf6e49>] start_kernel+0x3c0/0x3cd
[  322.194729]   [<ffffffff81cf65a6>] x86_64_start_reservations+0x2a/0x2c
[  322.201267]   [<ffffffff81cf668d>] x86_64_start_kernel+0xe5/0xec
[  322.207287] irq event stamp: 2539
[  322.210598] hardirqs last  enabled at (2539): [<ffffffff815fce1f>] _raw_spin_unlock_irqrestore+0x3f/0x70
[  322.220084] hardirqs last disabled at (2538): [<ffffffff815fc6dc>] _raw_spin_lock_irqsave+0x1c/0x60
[  322.229136] softirqs last  enabled at (2482): [<ffffffffa00082b7>] inet6_fill_ifla6_attrs+0x277/0x2a0 [ipv6]
[  322.238977] softirqs last disabled at (2480): [<ffffffff815fcbc6>] _raw_read_lock_bh+0x16/0x60
[  322.247599] 
[  322.247599] other info that might help us debug this:
[  322.254118]  Possible unsafe locking scenario:
[  322.254118] 
[  322.260033]        CPU0
[  322.262478]        ----
[  322.264924]   lock(&(&app->lock)->rlock);
[  322.268965]   <Interrupt>
[  322.271584]     lock(&(&app->lock)->rlock);
[  322.275799] 
[  322.275799]  *** DEADLOCK ***
[  322.275799] 
[  322.281714] 1 lock held by ip/19081:
[  322.285286]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81540787>] rtnl_lock+0x17/0x20
[  322.293107] 
[  322.293107] stack backtrace:
[  322.297461] CPU: 2 PID: 19081 Comm: ip Not tainted 3.10.0-dbg-DEV #383
[  322.311279]  ffffffff82233cc0 ffff880c126e5628 ffffffff815f618c ffff880c126e5688
[  322.318738]  ffffffff815f3c1a 0000000000000000 ffff880c00000001 ffff880c00000001
[  322.326194]  ffffffff8105a70f ffff880c126e56b8 0000000000000004 ffff880c526bacd8
[  322.333650] Call Trace:
[  322.336098]  [<ffffffff815f618c>] dump_stack+0x19/0x1b
[  322.341234]  [<ffffffff815f3c1a>] print_usage_bug+0x1fc/0x20d
[  322.346981]  [<ffffffff8105a70f>] ? save_stack_trace+0x2f/0x50
[  322.352808]  [<ffffffff810db50c>] mark_lock+0x28c/0x2f0
[  322.358026]  [<ffffffff810daa50>] ? check_usage_forwards+0x150/0x150
[  322.364375]  [<ffffffff810dbd1e>] __lock_acquire+0x7ae/0x1c50
[  322.370115]  [<ffffffff810de024>] ? mark_held_locks+0x74/0x140
[  322.375951]  [<ffffffff81096fa8>] ? lock_timer_base.isra.34+0x38/0x70
[  322.382396]  [<ffffffff810de024>] ? mark_held_locks+0x74/0x140
[  322.388231]  [<ffffffffa0240804>] ? mrp_uninit_applicant+0x54/0x110 [mrp]
[  322.395021]  [<ffffffff810dd7c7>] lock_acquire+0x97/0x150
[  322.400415]  [<ffffffffa0240804>] ? mrp_uninit_applicant+0x54/0x110 [mrp]
[  322.407206]  [<ffffffff810de2cd>] ? trace_hardirqs_on+0xd/0x10
[  322.413041]  [<ffffffff815fc5d1>] _raw_spin_lock+0x41/0x50
[  322.418523]  [<ffffffffa0240804>] ? mrp_uninit_applicant+0x54/0x110 [mrp]
[  322.425304]  [<ffffffffa0240804>] mrp_uninit_applicant+0x54/0x110 [mrp]
[  322.431914]  [<ffffffffa0254775>] vlan_mvrp_uninit_applicant+0x15/0x20 [8021q]
[  322.439134]  [<ffffffffa02521f8>] unregister_vlan_dev+0x128/0x150 [8021q]
[  322.445914]  [<ffffffff815422cc>] rtnl_dellink+0xac/0x110
[  322.451308]  [<ffffffff81543a35>] rtnetlink_rcv_msg+0x165/0x250
[  322.457221]  [<ffffffff815f922c>] ? mutex_lock_nested+0x28c/0x380
[  322.463308]  [<ffffffff81540787>] ? rtnl_lock+0x17/0x20
[  322.468529]  [<ffffffff815438d0>] ? __rtnl_unlock+0x20/0x20
[  322.474106]  [<ffffffff81561f99>] netlink_rcv_skb+0xa9/0xd0
[  322.479672]  [<ffffffff815407b5>] rtnetlink_rcv+0x25/0x40
[  322.485065]  [<ffffffff81561939>] netlink_unicast+0x169/0x1e0
[  322.490805]  [<ffffffff81561c5e>] netlink_sendmsg+0x2ae/0x360
[  322.496545]  [<ffffffff81517382>] sock_sendmsg+0xc2/0xe0
[  322.501854]  [<ffffffff8116ba23>] ? might_fault+0x53/0xb0
[  322.507247]  [<ffffffff8116ba23>] ? might_fault+0x53/0xb0
[  322.512643]  [<ffffffff81517722>] __sys_sendmsg+0x382/0x390
[  322.518210]  [<ffffffff810b36c3>] ? up_read+0x23/0x40
[  322.523256]  [<ffffffff81600e84>] ? __do_page_fault+0x254/0x4d0
[  322.529170]  [<ffffffff81175b9c>] ? do_brk+0x1fc/0x360
[  322.534305]  [<ffffffff8151aa09>] SyS_sendmsg+0x49/0x90
[  322.539535]  [<ffffffff816058c2>] system_call_fastpath+0x16/0x1b

And with the patch, there is no lockdep splat anymore.

Tested-by: Eric Dumazet <edumazet@google.com>
