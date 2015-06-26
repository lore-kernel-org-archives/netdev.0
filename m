From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] bnx2x: fix lockdep splat
Date: Fri, 26 Jun 2015 07:32:29 +0200
Message-ID: <1435296749.4110.56.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Michal Kalderon <Michal.Kalderon@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	David Decotigny <decot@googlers.com>,
	Michel Lespinasse <walken@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38585 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbbFZFce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 01:32:34 -0400
Received: by wibdq8 with SMTP id dq8so7458814wib.1
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 22:32:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Michel reported following lockdep splat

[   44.718117] INFO: trying to register non-static key.
[   44.723081] the code is fine but needs lockdep annotation.
[   44.728559] turning off the locking correctness validator.
[   44.734036] CPU: 8 PID: 5483 Comm: ethtool Not tainted 4.1.0
[   44.770289] Call Trace:
[   44.772741]  [<ffffffff816eb1cd>] dump_stack+0x4c/0x65
[   44.777879]  [<ffffffff8111d921>] ? console_unlock+0x1f1/0x510
[   44.783708]  [<ffffffff811121f5>] __lock_acquire+0x1d05/0x1f10
[   44.789538]  [<ffffffff8111370a>] ? mark_held_locks+0x6a/0x90
[   44.795276]  [<ffffffff81113835>] ? trace_hardirqs_on_caller+0x105/0x1d0
[   44.801967]  [<ffffffff8111390d>] ? trace_hardirqs_on+0xd/0x10
[   44.807793]  [<ffffffff811330fa>] ? hrtimer_try_to_cancel+0x4a/0x250
[   44.814142]  [<ffffffff81112ba6>] lock_acquire+0xb6/0x290
[   44.819537]  [<ffffffff810d6675>] ? flush_work+0x5/0x280
[   44.824844]  [<ffffffff810d66ad>] flush_work+0x3d/0x280
[   44.830061]  [<ffffffff810d6675>] ? flush_work+0x5/0x280
[   44.835366]  [<ffffffff816f3c43>] ? schedule_hrtimeout_range+0x13/0x20
[   44.841889]  [<ffffffff8112ec9b>] ? usleep_range+0x4b/0x50
[   44.847365]  [<ffffffff8111370a>] ? mark_held_locks+0x6a/0x90
[   44.853102]  [<ffffffff810d8585>] ? __cancel_work_timer+0x105/0x1c0
[   44.859359]  [<ffffffff81113835>] ? trace_hardirqs_on_caller+0x105/0x1d0
[   44.866045]  [<ffffffff810d851f>] __cancel_work_timer+0x9f/0x1c0
[   44.872048]  [<ffffffffa0010982>] ? bnx2x_func_stop+0x42/0x90 [bnx2x]
[   44.878481]  [<ffffffff810d8670>] cancel_work_sync+0x10/0x20
[   44.884134]  [<ffffffffa00259e5>] bnx2x_chip_cleanup+0x245/0x730 [bnx2x]
[   44.890829]  [<ffffffff8110ce02>] ? up+0x32/0x50
[   44.895439]  [<ffffffff811306b5>] ? del_timer_sync+0x5/0xd0
[   44.901005]  [<ffffffffa005596d>] bnx2x_nic_unload+0x20d/0x8e0 [bnx2x]
[   44.907527]  [<ffffffff811f1aef>] ? might_fault+0x5f/0xb0
[   44.912921]  [<ffffffffa005851c>] bnx2x_reload_if_running+0x2c/0x50 [bnx2x]
[   44.919879]  [<ffffffffa005a3c5>] bnx2x_set_ringparam+0x2b5/0x460 [bnx2x]
[   44.926664]  [<ffffffff815d498b>] dev_ethtool+0x55b/0x1c40
[   44.932148]  [<ffffffff815dfdc7>] ? rtnl_lock+0x17/0x20
[   44.937364]  [<ffffffff815e7f8b>] dev_ioctl+0x17b/0x630
[   44.942582]  [<ffffffff815abf8d>] sock_do_ioctl+0x5d/0x70
[   44.947972]  [<ffffffff815ac013>] sock_ioctl+0x73/0x280
[   44.953192]  [<ffffffff8124c1c8>] do_vfs_ioctl+0x88/0x5b0
[   44.958587]  [<ffffffff8110d0b3>] ? up_read+0x23/0x40
[   44.963631]  [<ffffffff812584cc>] ? __fget_light+0x6c/0xa0
[   44.969105]  [<ffffffff8124c781>] SyS_ioctl+0x91/0xb0
[   44.974149]  [<ffffffff816f4dd7>] system_call_fastpath+0x12/0x6f

As bnx2x_init_ptp() is only called if bp->flags contains PTP_SUPPORTED,
we also need to guard bnx2x_stop_ptp() with same condition, otherwise
ptp_task workqueue is not initialized and kernel barfs on
cancel_work_sync()

Fixes: eeed018cbfa30 ("bnx2x: Add timestamping and PTP hardware clock support")
Reported-by: Michel Lespinasse <walken@google.com> 
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Michal Kalderon <Michal.Kalderon@qlogic.com>
Cc: Ariel Elior <Ariel.Elior@qlogic.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
Cc: David Decotigny <decot@google.com>
---
This is a stable candidate, bug was added in linux-3.18

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 3df03bba477b..c27af12314ed 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9331,7 +9331,8 @@ unload_error:
 	 * function stop ramrod is sent, since as part of this ramrod FW access
 	 * PTP registers.
 	 */
-	bnx2x_stop_ptp(bp);
+	if (bp->flags & PTP_SUPPORTED)
+		bnx2x_stop_ptp(bp);
 
 	/* Disable HW interrupts, NAPI */
 	bnx2x_netif_stop(bp, 1);
