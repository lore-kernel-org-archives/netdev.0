From: mroos@linux.ee
Subject: Re: [PATCH v2] rhashtable: fix for resize events during table walk
Date: Wed, 15 Jul 2015 00:35:23 +0300 (EEST)
Message-ID: <alpine.LRH.2.11.1507150031550.15113@math.ut.ee>
References: <1436190680-21887-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Thomas Graf <tgraf@suug.ch>, sparclinux@vger.kernel.org,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.apana.org.au, daniel@iogearbox.net,
	geert@linux-m68k.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1436190680-21887-1-git-send-email-phil@nwl.cc>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> If rhashtable_walk_next detects a resize operation in progress, it jumps
> to the new table and continues walking that one. But it misses to drop
> the reference to it's current item, leading it to continue traversing
> the new table's bucket in which the current item is sorted into, and
> after reaching that bucket's end continues traversing the new table's
> second bucket instead of the first one, thereby potentially missing
> items.
> 
> This fixes the rhashtable runtime test for me. Bug probably introduced
> by Herbert Xu's patch eddee5ba ("rhashtable: Fix walker behaviour during
> rehash") although not explicitly tested.
> 
> Fixes: eddee5ba ("rhashtable: Fix walker behaviour during rehash")
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Yes, this fixes the error, thank you.

The new problem with the test - soft lockup - CPU#0 stuck for 22s! is 
still there on 360 MHz UltraSparc IIi. I understand it is harmless but 
is there some easy way to make the test avoid NMI watchdog?

[   58.374173] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! [swapper:1]
[   58.374293] Modules linked in:
[   58.374387] irq event stamp: 5555144
[   58.374461] hardirqs last  enabled at (5555143): [<0000000000404b1c>] rtrap_xcall+0x18/0x20
[   58.374621] hardirqs last disabled at (5555144): [<0000000000426b28>] sys_call_table+0x5ac/0x744
[   58.374788] softirqs last  enabled at (5555142): [<000000000045f5fc>] __do_softirq+0x4fc/0x680
[   58.374958] softirqs last disabled at (5555135): [<000000000042be28>] do_softirq_own_stack+0x28/0x40
[   58.375148] CPU: 0 PID: 1 Comm: swapper Not tainted 4.2.0-rc2-00077-gf760b87 #20
[   58.375248] task: fffff8001f09ef60 ti: fffff8001f0fc000 task.ti: fffff8001f0fc000
[   58.375348] TSTATE: 0000004480001601 TPC: 000000000049663c TNPC: 0000000000496640 Y: 00000000    Not tainted
[   58.375497] TPC: <lock_is_held+0x3c/0x60>
[   58.375579] g0: 0000000000b1d000 g1: 0000000000000002 g2: 00a8800000000000 g3: 000000000000007f
[   58.375699] g4: fffff8001f09ef60 g5: 0000000000000000 g6: fffff8001f0fc000 g7: 2f23003c7b800000
[   58.375817] o0: 0000000000000000 o1: 0000000000000002 o2: 0000000000000620 o3: fffff8001f09f560
[   58.375937] o4: fffff8001f09ef60 o5: 0000000000000002 sp: fffff8001f0ff041 ret_pc: 000000000049662c
[   58.376069] RPC: <lock_is_held+0x2c/0x60>
[   58.376152] l0: fffff8001f09ef60 l1: 000000000189bc00 l2: 0000000000b1d000 l3: 0000000000000028
[   58.376272] l4: fffff8001f09f538 l5: 0000000000000008 l6: 0000000000000000 l7: 0000000000000014
[   58.376388] i0: 00000000018d1428 i1: 0000000001318d18 i2: 00000000000005f8 i3: 0000000000000000
[   58.376506] i4: 0000000000000000 i5: 0000000000000001 i6: fffff8001f0ff0f1 i7: 00000000007022d8
[   58.376643] I7: <lockdep_rht_mutex_is_held+0x18/0x40>
[   58.376715] Call Trace:
[   58.376798]  [00000000007022d8] lockdep_rht_mutex_is_held+0x18/0x40
[   58.376917]  [0000000000b7a6ac] test_rht_lookup.constprop.10+0x32c/0x4ac
[   58.377029]  [0000000000b7afd0] test_rhashtable.constprop.8+0x7a4/0x1100
[   58.377138]  [0000000000b7ba00] test_rht_init+0xd4/0x148
[   58.377240]  [0000000000426e2c] do_one_initcall+0xec/0x1e0
[   58.377351]  [0000000000b58b60] kernel_init_freeable+0x114/0x1c4
[   58.377469]  [000000000091c1ec] kernel_init+0xc/0x100
[   58.377577]  [0000000000405fe4] ret_from_fork+0x1c/0x2c
[   58.377663]  [0000000000000000]           (null)


-- 
Meelis Roos (mroos@linux.ee)
