From: John Fastabend <john.fastabend@gmail.com>
Subject: [PATCH] net: sched: suspicious RCU usage in qdisc_watchdog
Date: Thu, 02 Oct 2014 22:43:09 -0700
Message-ID: <20141003054306.20821.48420.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:43486 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930AbaJCFn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 01:43:29 -0400
Received: by mail-ob0-f169.google.com with SMTP id m8so348940obr.28
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 22:43:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suspicious RCU usage in qdisc_watchdog call needs to be done inside
rcu_read_lock/rcu_read_unlock. And then Qdisc destroy operations
need to ensure timer is cancelled before removing qdisc structure.

[ 3992.191339] ===============================
[ 3992.191340] [ INFO: suspicious RCU usage. ]
[ 3992.191343] 3.17.0-rc6net-next+ #72 Not tainted
[ 3992.191345] -------------------------------
[ 3992.191347] include/net/sch_generic.h:272 suspicious rcu_dereference_check() usage!
[ 3992.191348]
[ 3992.191348] other info that might help us debug this:
[ 3992.191348]
[ 3992.191351]
[ 3992.191351] rcu_scheduler_active = 1, debug_locks = 1
[ 3992.191353] no locks held by swapper/1/0.
[ 3992.191355]
[ 3992.191355] stack backtrace:
[ 3992.191358] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.17.0-rc6net-next+ #72
[ 3992.191360] Hardware name:                  /DZ77RE-75K, BIOS GAZ7711H.86A.0060.2012.1115.1750 11/15/2012
[ 3992.191362]  0000000000000001 ffff880235803e48 ffffffff8178f92c 0000000000000000
[ 3992.191366]  ffff8802322224a0 ffff880235803e78 ffffffff810c9966 ffff8800a5fe3000
[ 3992.191370]  ffff880235803f30 ffff8802359cd768 ffff8802359cd6e0 ffff880235803e98
[ 3992.191374] Call Trace:
[ 3992.191376]  <IRQ>  [<ffffffff8178f92c>] dump_stack+0x4e/0x68
[ 3992.191387]  [<ffffffff810c9966>] lockdep_rcu_suspicious+0xe6/0x130
[ 3992.191392]  [<ffffffff8167213a>] qdisc_watchdog+0x8a/0xb0
[ 3992.191396]  [<ffffffff810f93f2>] __run_hrtimer+0x72/0x420
[ 3992.191399]  [<ffffffff810f9bcd>] ? hrtimer_interrupt+0x7d/0x240
[ 3992.191403]  [<ffffffff816720b0>] ? tc_classify+0xc0/0xc0
[ 3992.191406]  [<ffffffff810f9c4f>] hrtimer_interrupt+0xff/0x240
[ 3992.191410]  [<ffffffff8109e4a5>] ? __atomic_notifier_call_chain+0x5/0x140
[ 3992.191415]  [<ffffffff8103577b>] local_apic_timer_interrupt+0x3b/0x60
[ 3992.191419]  [<ffffffff8179c2b5>] smp_apic_timer_interrupt+0x45/0x60
[ 3992.191422]  [<ffffffff8179a6bf>] apic_timer_interrupt+0x6f/0x80
[ 3992.191424]  <EOI>  [<ffffffff815ed233>] ? cpuidle_enter_state+0x73/0x2e0
[ 3992.191432]  [<ffffffff815ed22e>] ? cpuidle_enter_state+0x6e/0x2e0
[ 3992.191437]  [<ffffffff815ed567>] cpuidle_enter+0x17/0x20
[ 3992.191441]  [<ffffffff810c0741>] cpu_startup_entry+0x3d1/0x4a0
[ 3992.191445]  [<ffffffff81106fc6>] ? clockevents_config_and_register+0x26/0x30
[ 3992.191448]  [<ffffffff81033c16>] start_secondary+0x1b6/0x260

Fixes: b26b0d1e8b1 ("net: qdisc: use rcu prefix and silence sparse warnings")
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/sch_api.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index aa83295..c79a226 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -578,8 +578,10 @@ static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 	struct qdisc_watchdog *wd = container_of(timer, struct qdisc_watchdog,
 						 timer);
 
+	rcu_read_lock();
 	qdisc_unthrottled(wd->qdisc);
 	__netif_schedule(qdisc_root(wd->qdisc));
+	rcu_read_unlock();
 
 	return HRTIMER_NORESTART;
 }
