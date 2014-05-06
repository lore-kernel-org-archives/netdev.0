From: Meelis Roos <mroos@linux.ee>
Subject: cassini: possible recursive locking detected
Date: Tue, 6 May 2014 12:39:48 +0300 (EEST)
Message-ID: <alpine.SOC.1.00.1405061232520.3891@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.it.da.ut.ee ([193.40.5.66]:52200 "EHLO smtp1.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934558AbaEFKC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2014 06:02:56 -0400
Received: from math.ut.ee (math.ut.ee [193.40.36.2])
	by smtp1.it.da.ut.ee (Postfix) with ESMTP id 9F36F90121
	for <netdev@vger.kernel.org>; Tue,  6 May 2014 12:39:48 +0300 (EEST)
Received: from localhost (localhost [127.0.0.1])
	by math.ut.ee (Postfix) with ESMTP id 38B3D427977
	for <netdev@vger.kernel.org>; Tue,  6 May 2014 12:39:48 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While installing Linux on Sun Fire V480, any traffic on builtin cassini 
NIC caused a hang. Worked this around by using Broadcom NIC and tried a 
kernel with most debugging options. This resulted in the following 
warning. Maybe this is the deadlonck I was seeing?

[   88.316595] =============================================
[   88.316597] [ INFO: possible recursive locking detected ]
[   88.316603] 3.15.0-rc4-00202-g30321c7-dirty #11 Not tainted
[   88.316605] ---------------------------------------------
[   88.316608] swapper/3/1 is trying to acquire lock:
[   88.316644]  (&(&cp->tx_lock[i])->rlock){..-...}, at: [<0000000000745da0>] cas_link_timer+0xa0/0x460
[   88.316646]
[   88.316646] but task is already holding lock:
[   88.316657]  (&(&cp->tx_lock[i])->rlock){..-...}, at: [<0000000000745da0>] cas_link_timer+0xa0/0x460
[   88.316659]
[   88.316659] other info that might help us debug this:
[   88.316661]  Possible unsafe locking scenario:
[   88.316661]
[   88.316662]        CPU0
[   88.316664]        ----
[   88.316668]   lock(&(&cp->tx_lock[i])->rlock);
[   88.316671]   lock(&(&cp->tx_lock[i])->rlock);
[   88.316672]
[   88.316672]  *** DEADLOCK ***
[   88.316672]
[   88.316674]  May be due to missing lock nesting notation
[   88.316674]
[   88.316677] 3 locks held by swapper/3/1:
[   88.316694]  #0:  ((&cp->link_timer)){+.-...}, at: [<0000000000465f80>] call_timer_fn+0x0/0xe0
[   88.316706]  #1:  (&(&cp->lock)->rlock){..-...}, at: [<0000000000745d80>] cas_link_timer+0x80/0x460
[   88.316716]  #2:  (&(&cp->tx_lock[i])->rlock){..-...}, at: [<0000000000745da0>] cas_link_timer+0xa0/0x460
[   88.316718]
[   88.316718] stack backtrace:
[   88.316724] CPU: 2 PID: 1 Comm: swapper/3 Not tainted 3.15.0-rc4-00202-g30321c7-dirty #11
[   88.316727] Call Trace:
[   88.316743]  [00000000004a2c5c] __lock_acquire+0x10fc/0x1fa0
[   88.316749]  [00000000004a406c] lock_acquire+0x4c/0x80
[   88.316760]  [000000000083e07c] _raw_spin_lock+0x1c/0x40
[   88.316765]  [0000000000745da0] cas_link_timer+0xa0/0x460
[   88.316769]  [0000000000465fc8] call_timer_fn+0x48/0xe0
[   88.316775]  [00000000004665d4] run_timer_softirq+0x214/0x280
[   88.316788]  [000000000045f650] __do_softirq+0xf0/0x240
[   88.316800]  [000000000042bd0c] do_softirq_own_stack+0x2c/0x40
[   88.316804]  [000000000045fb44] irq_exit+0xc4/0xe0
[   88.316814]  [000000000042fcc8] timer_interrupt+0x88/0xc0
[   88.316819]  [0000000000426b84] valid_addr_bitmap_patch+0xbc/0x238
[   88.316826]  [00000000004ab2f8] vprintk_emit+0x1d8/0x540
[   88.316842]  [0000000000835fb8] printk+0x34/0x48
[   88.316847]  [00000000004ac3e0] register_console+0x340/0x3e0
[   88.316862]  [0000000000a74f2c] init_netconsole+0x180/0x20c
[   88.316867]  [0000000000426eb0] do_one_initcall+0x110/0x1a0

-- 
Meelis Roos (mroos@linux.ee)
