From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.6 NULL kernel dereference in skb_gro_receive()
Date: Tue, 02 Jul 2013 09:38:57 -0700
Message-ID: <1372783137.4979.10.camel@edumazet-glaptop>
References: <1372782217.22688.48.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>,
	"Luis Claudio R. Goncalves" <lgoncalv@redhat.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372782217.22688.48.camel@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-07-02 at 12:23 -0400, Steven Rostedt wrote:
> Hi Eric,
> 
> Our Red Hat MRG (real-time) kernel hit this bug recently (based off of
> 3.6.11.5-rt37):
> 
> [  387.304151] BUG: unable to handle kernel NULL pointer dereference at           (null) 
> [  387.304164] IP: [<ffffffff8149d62e>] skb_gro_receive+0xbe/0x590 
> [  387.304167] PGD 0  
> [  387.304171] Oops: 0002 [#1] PREEMPT SMP  
> [  387.304200] CPU 6  
> [  387.304200] Pid: 2625, comm: irq/31-eth0 Not tainted 3.6.11.5-rt37.48.el6rt.x86_64.debug #1
> [  387.304204] RIP: 0010:[<ffffffff8149d62e>]  [<ffffffff8149d62e>] skb_gro_receive+0xbe/0x590 
> [  387.304206] RSP: 0018:ffff88083794d920  EFLAGS: 00010282 
> [  387.304207] RAX: 0000000000000000 RBX: ffff880c3798b300 RCX: 000000000000824c 
> [  387.304208] RDX: 0000000000000900 RSI: 0000000000000000 RDI: ffff880437937800 
> [  387.304209] RBP: ffff88083794d990 R08: ffff880c3798b328 R09: ffff880437937ec0 
> [  387.304210] R10: 00000000000005dc R11: ffff880c37b9e0c0 R12: ffff880c39ae3b00 
> [  387.304211] R13: 0000000000000034 R14: 00000000000005a8 R15: ffff880833f08db0 
> [  387.304213] FS:  00007f487d24d700(0000) GS:ffff880c6fa00000(0000) knlGS:0000000000000000 
> [  387.304214] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b 
> [  387.304215] CR2: 0000000000000000 CR3: 0000000001a15000 CR4: 00000000000007e0 
> [  387.304217] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000 
> [  387.304218] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400 
> [  387.304220] Process irq/31-eth0 (pid: 2625, threadinfo ffff88083794c000, task ffff880837b24820) 
> [  387.304220] Stack: 
> [  387.304228]  ffff88083794d990 ffffffff810af08c 000000000017c01c ffffffff81a39fa0 
> [  387.304232]  ffff880837b24890 0000000000000002 ffff880837b25080 0000001c810af08c 
> [  387.304236]  ffff88046f002c00 ffff880c39ae3b00 00000000000005a8 ffff880c3798b328 
> [  387.304237] Call Trace: 
> [  387.304247]  [<ffffffff810af08c>] ? __lock_acquire+0x2fc/0x4e0 
> [  387.304251]  [<ffffffff814fce41>] tcp_gro_receive+0x271/0x2d0 
> [  387.304256]  [<ffffffff815101b0>] tcp4_gro_receive+0xb0/0x130 
> [  387.304262]  [<ffffffff81527ce1>] inet_gro_receive+0x1b1/0x250 
> [  387.304265]  [<ffffffff81527b75>] ? inet_gro_receive+0x45/0x250 
> [  387.304269]  [<ffffffff814ad1a1>] dev_gro_receive+0x1b1/0x2c0 
> [  387.304272]  [<ffffffff814ad50b>] napi_gro_receive+0x11b/0x1b0 
> [  387.304280]  [<ffffffffa031a689>] bnx2_rx_int+0x2d9/0x720 [bnx2] 
> [  387.304284]  [<ffffffff8149ba27>] ? __kfree_skb+0x47/0xa0 
> [  387.304289]  [<ffffffffa031ab40>] bnx2_poll_work+0x70/0xa0 [bnx2] 
> [  387.304294]  [<ffffffffa031ac91>] bnx2_poll+0x61/0x210 [bnx2] 
> [  387.304297]  [<ffffffff814ad7d9>] net_rx_action+0x139/0x290 
> [  387.304301]  [<ffffffff810537da>] handle_softirq+0x6a/0x1c0 
> [  387.304304]  [<ffffffff81053b1f>] do_current_softirqs+0x1ef/0x2d0 
> [  387.304306]  [<ffffffff81053f8e>] local_bh_enable+0x6e/0x90 
> [  387.304312]  [<ffffffff810ec9a9>] irq_forced_thread_fn+0x49/0x70 
> [  387.304315]  [<ffffffff810eb024>] irq_thread+0x1c4/0x240 
> [  387.304318]  [<ffffffff810ec960>] ? irq_thread_fn+0x50/0x50 
> [  387.304320]  [<ffffffff810ec820>] ? irq_finalize_oneshot+0xf0/0xf0 
> [  387.304323]  [<ffffffff810eae60>] ? irq_select_affinity_usr+0x80/0x80 
> [  387.304327]  [<ffffffff81073236>] kthread+0xa6/0xb0 
> [  387.304332]  [<ffffffff81596864>] kernel_thread_helper+0x4/0x10 
> [  387.304336]  [<ffffffff81082a7c>] ? finish_task_switch+0x8c/0x110 
> [  387.304339]  [<ffffffff8158dbfb>] ? _raw_spin_unlock_irq+0x3b/0x70 
> [  387.304341]  [<ffffffff8158e01d>] ? retint_restore_args+0xe/0xe 
> [  387.304344]  [<ffffffff81073190>] ? kthreadd+0x1e0/0x1e0 
> [  387.304346]  [<ffffffff81596860>] ? gs_change+0xb/0xb 
> [  387.304379] Code: f0 00 00 00 0f 87 8b 00 00 00 8b 43 68 44 29 e8 3b 43 6c 89 43 68 0f 82 af 04 00 00 45 89 ed 4c 01 ab e8 00 00 00 49 8b 44 24 08 <48> 89 18 49 89 5c 24 08 0f b6 43 7c a8 10 0f 85 90 04 00 00 83  
> [  387.304383] RIP  [<ffffffff8149d62e>] skb_gro_receive+0xbe/0x590 
> [  387.304383]  RSP <ffff88083794d920> 
> [  387.304384] CR2: 0000000000000000 
> [  387.370430] ---[ end trace 0000000000000002 ]--- 
> 
> Doing a search on this I found this:
> 
> https://lkml.org/lkml/2012/11/15/145
> 
> Which looks to be the exact same bug. But as Mel was testing other code,
> it seems to have been dismissed as just a fluke.
> 
> My question, do you know about this bug and have a fix (if so, can you
> tell me what the fix is, so that I can add it to 3.6.11.6), or is this
> just something that still exists and is just very hard to hit.

Could you check if your kernel has commit 2e71a6f8084e ("net: gro:
selective flush of packets"), and the fix contained in commit
c3c7c254b2e8cd99b0adf288c2a1bddacd7ba255
("net: gro: fix possible panic in skb_gro_receive() ")

Normally, first commit was in 3.7-rc1, but maybe it was backported into
you 3.6.11 kernel ?

Do you have a git tree for your kernel ?
