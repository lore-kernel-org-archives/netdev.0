From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: Re: Inconsistend lock state in inet_frag_find
Date: Fri, 30 May 2008 15:18:45 +0200
Message-ID: <20080530131845.GA5167@alice>
References: <20080529120248.GA9702@alice> <20080530105334.GA7378@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:34723 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751558AbYE3NSy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 09:18:54 -0400
Content-Disposition: inline
In-Reply-To: <20080530105334.GA7378@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Jarek Poplawski (jarkao2@gmail.com) wrote:
> On 29-05-2008 14:02, Eric Sesterhenn wrote:
> > hi,
> > 
> > the following just popped up on my test box with
> > tcpsic6  -s ::1 -d ::1 -p 100000 -r 4995
> > 
> > [   63.616218] =================================
> > [   63.616456] [ INFO: inconsistent lock state ]
> > [   63.616456] 2.6.26-rc4 #5
> > [   63.616456] ---------------------------------
> > [   63.616456] inconsistent {softirq-on-W} -> {in-softirq-R} usage.
> > [   63.616456] tcpsic6/3869 [HC0[0]:SC1[1]:HE1:SE0] takes:
> > [   63.616456]  (&f->lock){---?}, at: [<c06be62e>]
> > inet_frag_find+0x1e/0x140
> ...
> 
> Hi,
> 
> Could you try this patch?

with the patch applied i get the following lockdep warning:

[   63.531438] =================================
[   63.531520] [ INFO: inconsistent lock state ]
[   63.531520] 2.6.26-rc4 #7
[   63.531520] ---------------------------------
[   63.531520] inconsistent {softirq-on-W} -> {in-softirq-W} usage.
[   63.531520] tcpsic6/3864 [HC0[0]:SC1[1]:HE1:SE0] takes:
[   63.531520]  (&q->lock#2){-+..}, at: [<c07175b0>]
ipv6_frag_rcv+0xd0/0xbd0
[   63.531520] {softirq-on-W} state was registered at:
[   63.531520]   [<c0143bba>] __lock_acquire+0x3aa/0x1080
[   63.531520]   [<c0144906>] lock_acquire+0x76/0xa0
[   63.531520]   [<c07a8f0b>] _spin_lock+0x2b/0x40
[   63.531520]   [<c0727636>] nf_ct_frag6_gather+0x3f6/0x910
[   63.531520]   [<c0726853>] ipv6_defrag+0x23/0x70
[   63.531520]   [<c0673773>] nf_iterate+0x53/0x80
[   63.531520]   [<c0673927>] nf_hook_slow+0xb7/0x100
[   63.531520]   [<c07104f9>] rawv6_sendmsg+0x719/0xc10
[   63.531520]   [<c06b6a74>] inet_sendmsg+0x34/0x60
[   63.531520]   [<c06474df>] sock_sendmsg+0xff/0x120
[   63.531520]   [<c0647f95>] sys_sendto+0xa5/0xd0
[   63.531520]   [<c06488cb>] sys_socketcall+0x16b/0x290
[   63.531520]   [<c0103005>] sysenter_past_esp+0x6a/0xb1
[   63.531520]   [<ffffffff>] 0xffffffff
[   63.531520] irq event stamp: 3344
[   63.531520] hardirqs last  enabled at (3344): [<c07a93b7>]
_spin_unlock_irqrestore+0x47/0x60
[   63.531520] hardirqs last disabled at (3343): [<c07a9296>]
_spin_lock_irqsave+0x16/0x50
[   63.531520] softirqs last  enabled at (3320): [<c0655884>]
dev_queue_xmit+0xd4/0x370
[   63.531520] softirqs last disabled at (3321): [<c0105814>]
do_softirq+0x84/0xc0
[   63.531520] 
[   63.531520] other info that might help us debug this:
[   63.531520] 3 locks held by tcpsic6/3864:
[   63.531520]  #0:  (rcu_read_lock){..--}, at: [<c0654d40>]
net_rx_action+0x60/0x1c0
[   63.531520]  #1:  (rcu_read_lock){..--}, at: [<c0652750>]
netif_receive_skb+0x100/0x320
[   63.531520]  #2:  (rcu_read_lock){..--}, at: [<c06fcd50>]
ip6_input_finish+0x0/0x330
[   63.531520] 
[   63.531520] stack backtrace:
[   63.531520] Pid: 3864, comm: tcpsic6 Not tainted 2.6.26-rc4 #7
[   63.531520]  [<c0142353>] print_usage_bug+0x153/0x160
[   63.531520]  [<c0143144>] mark_lock+0x574/0x590
[   63.531520]  [<c0143b75>] __lock_acquire+0x365/0x1080
[   63.531520]  [<c07a93b7>] ? _spin_unlock_irqrestore+0x47/0x60
[   63.531520]  [<c0144906>] lock_acquire+0x76/0xa0
[   63.531520]  [<c07175b0>] ? ipv6_frag_rcv+0xd0/0xbd0
[   63.531520]  [<c07a8f0b>] _spin_lock+0x2b/0x40
[   63.531520]  [<c07175b0>] ? ipv6_frag_rcv+0xd0/0xbd0
[   63.531520]  [<c07175b0>] ipv6_frag_rcv+0xd0/0xbd0
[   63.531520]  [<c067c12a>] ? nf_ct_deliver_cached_events+0x1a/0x80
[   63.531520]  [<c0726b64>] ? ipv6_confirm+0xb4/0xe0
[   63.531520]  [<c06fce6d>] ip6_input_finish+0x11d/0x330
[   63.531520]  [<c06fcd50>] ? ip6_input_finish+0x0/0x330
[   63.531520]  [<c06fd0d7>] ip6_input+0x57/0x60
[   63.531520]  [<c06fcd50>] ? ip6_input_finish+0x0/0x330
[   63.531520]  [<c06fd364>] ipv6_rcv+0x1e4/0x340
[   63.531520]  [<c06fd140>] ? ip6_rcv_finish+0x0/0x40
[   63.531520]  [<c06fd180>] ? ipv6_rcv+0x0/0x340
[   63.531520]  [<c06528d0>] netif_receive_skb+0x280/0x320
[   63.531520]  [<c0652750>] ? netif_receive_skb+0x100/0x320
[   63.531520]  [<c06554da>] process_backlog+0x6a/0xc0
[   63.531520]  [<c0654e19>] net_rx_action+0x139/0x1c0
[   63.531520]  [<c0654d40>] ? net_rx_action+0x60/0x1c0
[   63.531520]  [<c0127c92>] __do_softirq+0x52/0xb0
[   63.531520]  [<c0105814>] do_softirq+0x84/0xc0
[   63.531520]  [<c0127ab5>] local_bh_enable+0x95/0xf0
[   63.531520]  [<c0655884>] dev_queue_xmit+0xd4/0x370
[   63.531520]  [<c06557e4>] ? dev_queue_xmit+0x34/0x370
[   63.531520]  [<c06fa3c0>] ip6_output_finish+0x70/0xc0
[   63.531520]  [<c06fa7db>] ip6_output2+0xbb/0x1d0
[   63.531520]  [<c06fa350>] ? ip6_output_finish+0x0/0xc0
[   63.531520]  [<c06faeae>] ip6_output+0x4fe/0xa40
[   63.531520]  [<c0725b02>] ? ip6t_local_out_hook+0x22/0x30
[   63.531520]  [<c0673933>] ? nf_hook_slow+0xc3/0x100
[   63.531520]  [<c0673949>] ? nf_hook_slow+0xd9/0x100
[   63.531520]  [<c070f100>] ? dst_output+0x0/0x10
[   63.531520]  [<c071086d>] rawv6_sendmsg+0xa8d/0xc10
[   63.531520]  [<c070f100>] ? dst_output+0x0/0x10
[   63.531520]  [<c0143a7d>] ? __lock_acquire+0x26d/0x1080
[   63.531520]  [<c01431a0>] ? mark_held_locks+0x40/0x80
[   63.531520]  [<c07a93b7>] ? _spin_unlock_irqrestore+0x47/0x60
[   63.531520]  [<c06b6a74>] inet_sendmsg+0x34/0x60
[   63.531520]  [<c06474df>] sock_sendmsg+0xff/0x120
[   63.531520]  [<c0135990>] ? autoremove_wake_function+0x0/0x40
[   63.531520]  [<c0143339>] ? trace_hardirqs_on+0xb9/0x150
[   63.531520]  [<c07a9272>] ? _read_unlock_irq+0x22/0x30
[   63.531520]  [<c0647f95>] sys_sendto+0xa5/0xd0
[   63.531520]  [<c016f351>] ? __do_fault+0x191/0x3a0
[   63.531520]  [<c06488cb>] sys_socketcall+0x16b/0x290
[   63.531520]  [<c0103005>] sysenter_past_esp+0x6a/0xb1
[   63.531520]  =======================


Greetings, Eric
