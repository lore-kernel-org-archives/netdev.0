From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: Inconsistend lock state in inet_frag_find
Date: Thu, 29 May 2008 14:02:48 +0200
Message-ID: <20080529120248.GA9702@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:37485 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750780AbYE2MDJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 08:03:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

the following just popped up on my test box with
tcpsic6  -s ::1 -d ::1 -p 100000 -r 4995

[   63.616218] =================================
[   63.616456] [ INFO: inconsistent lock state ]
[   63.616456] 2.6.26-rc4 #5
[   63.616456] ---------------------------------
[   63.616456] inconsistent {softirq-on-W} -> {in-softirq-R} usage.
[   63.616456] tcpsic6/3869 [HC0[0]:SC1[1]:HE1:SE0] takes:
[   63.616456]  (&f->lock){---?}, at: [<c06be62e>]
inet_frag_find+0x1e/0x140
[   63.616456] {softirq-on-W} state was registered at:
[   63.616456]   [<c0143b7a>] __lock_acquire+0x3aa/0x1080
[   63.616456]   [<c01448c6>] lock_acquire+0x76/0xa0
[   63.616456]   [<c07a8d7b>] _write_lock+0x2b/0x40
[   63.616456]   [<c06be6df>] inet_frag_find+0xcf/0x140
[   63.616456]   [<c072740c>] nf_ct_frag6_gather+0x3cc/0x900
[   63.616456]   [<c0726653>] ipv6_defrag+0x23/0x70
[   63.616456]   [<c0673563>] nf_iterate+0x53/0x80
[   63.616456]   [<c0673717>] nf_hook_slow+0xb7/0x100
[   63.616456]   [<c07102e9>] rawv6_sendmsg+0x719/0xc10
[   63.616456]   [<c06b6864>] inet_sendmsg+0x34/0x60
[   63.616456]   [<c06472df>] sock_sendmsg+0xff/0x120
[   63.616456]   [<c0647d95>] sys_sendto+0xa5/0xd0
[   63.616456]   [<c06486cb>] sys_socketcall+0x16b/0x290
[   63.616456]   [<c0103005>] sysenter_past_esp+0x6a/0xb1
[   63.616456]   [<ffffffff>] 0xffffffff
[   63.616456] irq event stamp: 3590
[   63.616456] hardirqs last  enabled at (3590): [<c0127a7d>]
local_bh_enable+0x7d/0xf0
[   63.616456] hardirqs last disabled at (3589): [<c0127a27>]
local_bh_enable+0x27/0xf0
[   63.616456] softirqs last  enabled at (3572): [<c0655674>]
dev_queue_xmit+0xd4/0x370
[   63.616456] softirqs last disabled at (3573): [<c0105814>]
do_softirq+0x84/0xc0
[   63.616456] 
[   63.616456] other info that might help us debug this:
[   63.616456] 3 locks held by tcpsic6/3869:
[   63.616456]  #0:  (rcu_read_lock){..--}, at: [<c0654b30>]
net_rx_action+0x60/0x1c0
[   63.616456]  #1:  (rcu_read_lock){..--}, at: [<c0652540>]
netif_receive_skb+0x100/0x320
[   63.616456]  #2:  (rcu_read_lock){..--}, at: [<c06fcb40>]
ip6_input_finish+0x0/0x330
[   63.616456] 
[   63.616456] stack backtrace:
[   63.616456] Pid: 3869, comm: tcpsic6 Not tainted 2.6.26-rc4 #5
[   63.616456]  [<c0142313>] print_usage_bug+0x153/0x160
[   63.616456]  [<c0142ff9>] mark_lock+0x469/0x590
[   63.616456]  [<c0143c90>] __lock_acquire+0x4c0/0x1080
[   63.616456]  [<c0143a3d>] ? __lock_acquire+0x26d/0x1080
[   63.616456]  [<c0143a3d>] ? __lock_acquire+0x26d/0x1080
[   63.616456]  [<c01432b8>] ? trace_hardirqs_on+0x78/0x150
[   63.616456]  [<c07257d8>] ? ip6t_do_table+0x258/0x360
[   63.616456]  [<c01448c6>] lock_acquire+0x76/0xa0
[   63.616456]  [<c06be62e>] ? inet_frag_find+0x1e/0x140
[   63.616456]  [<c07a8e7b>] _read_lock+0x2b/0x40
[   63.616456]  [<c06be62e>] ? inet_frag_find+0x1e/0x140
[   63.616456]  [<c06be62e>] inet_frag_find+0x1e/0x140
[   63.616456]  [<c071739a>] ipv6_frag_rcv+0xba/0xbd0
[   63.616456]  [<c067bf1a>] ? nf_ct_deliver_cached_events+0x1a/0x80
[   63.616456]  [<c0726964>] ? ipv6_confirm+0xb4/0xe0
[   63.616456]  [<c06fcc5d>] ip6_input_finish+0x11d/0x330
[   63.616456]  [<c06fcb40>] ? ip6_input_finish+0x0/0x330
[   63.616456]  [<c06fcec7>] ip6_input+0x57/0x60
[   63.616456]  [<c06fcb40>] ? ip6_input_finish+0x0/0x330
[   63.616456]  [<c06fd154>] ipv6_rcv+0x1e4/0x340
[   63.616456]  [<c06fcf30>] ? ip6_rcv_finish+0x0/0x40
[   63.616456]  [<c06fcf70>] ? ipv6_rcv+0x0/0x340
[   63.616456]  [<c06526c0>] netif_receive_skb+0x280/0x320
[   63.616456]  [<c0652540>] ? netif_receive_skb+0x100/0x320
[   63.616456]  [<c06552ca>] process_backlog+0x6a/0xc0
[   63.616456]  [<c0654c09>] net_rx_action+0x139/0x1c0
[   63.616456]  [<c0654b30>] ? net_rx_action+0x60/0x1c0
[   63.616456]  [<c0127c72>] __do_softirq+0x52/0xb0
[   63.616456]  [<c0105814>] do_softirq+0x84/0xc0
[   63.616456]  [<c0127a95>] local_bh_enable+0x95/0xf0
[   63.616456]  [<c0655674>] dev_queue_xmit+0xd4/0x370
[   63.616456]  [<c06555d4>] ? dev_queue_xmit+0x34/0x370
[   63.616456]  [<c06fa1b0>] ip6_output_finish+0x70/0xc0
[   63.616456]  [<c06fa5cb>] ip6_output2+0xbb/0x1d0
[   63.616456]  [<c06fa140>] ? ip6_output_finish+0x0/0xc0
[   63.616456]  [<c06fac9e>] ip6_output+0x4fe/0xa40
[   63.616456]  [<c0725902>] ? ip6t_local_out_hook+0x22/0x30
[   63.616456]  [<c0673723>] ? nf_hook_slow+0xc3/0x100
[   63.616456]  [<c0673739>] ? nf_hook_slow+0xd9/0x100
[   63.616456]  [<c070eef0>] ? dst_output+0x0/0x10
[   63.616456]  [<c071065d>] rawv6_sendmsg+0xa8d/0xc10
[   63.616456]  [<c070eef0>] ? dst_output+0x0/0x10
[   63.616456]  [<c0143a3d>] ? __lock_acquire+0x26d/0x1080
[   63.616456]  [<c0143160>] ? mark_held_locks+0x40/0x80
[   63.616456]  [<c07a91a7>] ? _spin_unlock_irqrestore+0x47/0x60
[   63.616456]  [<c06b6864>] inet_sendmsg+0x34/0x60
[   63.616456]  [<c06472df>] sock_sendmsg+0xff/0x120
[   63.616456]  [<c0135970>] ? autoremove_wake_function+0x0/0x40
[   63.616456]  [<c01432f9>] ? trace_hardirqs_on+0xb9/0x150
[   63.616456]  [<c07a9062>] ? _read_unlock_irq+0x22/0x30
[   63.616456]  [<c0647d95>] sys_sendto+0xa5/0xd0
[   63.616456]  [<c016f311>] ? __do_fault+0x191/0x3a0
[   63.616456]  [<c06486cb>] sys_socketcall+0x16b/0x290
[   63.616456]  [<c0103005>] sysenter_past_esp+0x6a/0xb1
[   63.616456]  =======================

Greetings, Eric
