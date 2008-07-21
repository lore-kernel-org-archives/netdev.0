From: Ingo Molnar <mingo@elte.hu>
Subject: [crash] BUG: unable to handle kernel NULL pointer dereference at
	0000000000000370
Date: Mon, 21 Jul 2008 15:45:06 +0200
Message-ID: <20080721134506.GA27598@elte.hu>
References: <20080720.104411.81744468.davem@davemloft.net> <20080721133059.GA30637@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:54393 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752218AbYGUNpY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 09:45:24 -0400
Content-Disposition: inline
In-Reply-To: <20080721133059.GA30637@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> David,
> 
> -tip testing on latest -git (v2.6.26-5253-g14b395e) triggered the 
> following boot crash on a Core2Duo 64-bit testsystem:
> 
> ADDRCONF(NETDEV_UP): eth0: link is not ready
> eth0: Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
> ------------[ cut here ]------------
> Kernel BUG at ffffffff8079afb1 [verbose debug info unavailable]
> invalid opcode: 0000 [1] SMP 
> CPU 0 
> Pid: 7, comm: events/0 Not tainted 2.6.26-rc8 #21302
> RIP: 0010:[<ffffffff8079afb1>]  [<ffffffff8079afb1>] __netif_schedule+0xd/0x64

note, my tests have also triggered another boot crash on the same 
system, using the same config:

PM: Removing info for No Bus:phy0
mac80211_hwsim: ieee80211_register_hw failed (-2)
BUG: unable to handle kernel NULL pointer dereference at 0000000000000370
IP: [<ffffffff808da9f1>] rollback_registered+0x2a/0xd6
PGD 0 
Oops: 0000 [1] SMP 
CPU 1 
Pid: 1, comm: swapper Not tainted 2.6.26-tip-00013-g6de15c6-dirty #21290
RIP: 0010:[<ffffffff808da9f1>]  [<ffffffff808da9f1>] rollback_registered+0x2a/0xd6
RSP: 0018:ffff88003f83fe00  EFLAGS: 00010212
RAX: 0000000000000001 RBX: 0000000000000000 RCX: ffff88003d4baed8
RDX: ffffffff80979f1d RSI: 0000000000000046 RDI: 0000000000000000
RBP: 0000000000000000 R08: ffffffff80d6f4a0 R09: ffff880004576800
R10: 0000000000000000 R11: ffffffff80406afe R12: 0000000000000000
R13: ffff88003d4bb9a0 R14: 0000000000000000 R15: 0000000000000008
FS:  0000000000000000(0000) GS:ffff88003f829160(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000000370 CR3: 0000000000201000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 1, threadinfo ffff88003f83e000, task ffff88003f824000)
Stack:  0000000000000000 ffffffff808daacf ffff88003d4ba2c0 ffffffff8097e1da
 ffff88003d4bb9a0 ffffffff8060eb76 00000000fffffffe ffff88003d4ba2c0
 ffff88003d4bb9e0 ffffffff811be87a ffff88003f83fea0 ffffffff8024e672
Call Trace:
 [<ffffffff808daacf>] unregister_netdevice+0x32/0x77
 [<ffffffff8097e1da>] ieee80211_unregister_hw+0x35/0xd4
 [<ffffffff8060eb76>] mac80211_hwsim_free+0x1d/0x6a
 [<ffffffff811be87a>] init_mac80211_hwsim+0x2df/0x2f0
 [<ffffffff8024e672>] getnstimeofday+0x38/0x95
 [<ffffffff8024c76a>] ktime_get_ts+0x21/0x49
 [<ffffffff811be59b>] init_mac80211_hwsim+0x0/0x2f0
 [<ffffffff8020a042>] do_one_initcall+0x42/0x13b
 [<ffffffff80247105>] __queue_work+0x23/0x33
 [<ffffffff811a09e0>] kernel_init+0x203/0x271
 [<ffffffff80234e73>] schedule_tail+0x28/0x60
 [<ffffffff80211079>] child_rip+0xa/0x11
 [<ffffffff811a07dd>] kernel_init+0x0/0x271
 [<ffffffff8021106f>] child_rip+0x0/0x11

Code: c3 53 48 89 fb e8 38 78 00 00 85 c0 75 1d ba ce 0e 00 00 48 c7 c6 b5 e9 d4 80 48 c7 c7 4f 85 ca 80 e8 f3 f1 95 ff e8 aa 7c 93 ff <83> bb 70 03 00 00 00 75 15 48 89 da 48 89 de 48 c7 c7 35 eb d4 
RIP  [<ffffffff808da9f1>] rollback_registered+0x2a/0xd6
 RSP <ffff88003f83fe00>
CR2: 0000000000000370
Kernel panic - not syncing: Fatal exception
Rebooting in 1 seconds..Press any key to enter the menu

this crash led to the bisection result i posted in the previous mail. 
This could be a dual bug and one of the crashes masks the other one.

Maybe the __netif_schedule bug is already fixed and when i tried to 
bisect the rollback_registered crash i ran into it as bisection went 
back into networking history?

Same config as before:

  http://redhat.com/~mingo/misc/config-Mon_Jul_21_13_59_54_CEST_2008.bad

Full crashlog:

  http://redhat.com/~mingo/misc/crash-Mon_Jul_21_13_59_52_CEST_2008.log

If the __netif_schedule() bug is already fixed by a later commit then i 
could attempt to bisect this other crash as well, given an sha1 that i 
could cherry-pick into each bisection point.

Thanks,

	Ingo
