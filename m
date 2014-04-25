From: Alex Shi <alex.shi@linaro.org>
Subject: deadlock in ipv6?
Date: Fri, 25 Apr 2014 15:05:52 +0800
Message-ID: <535A0950.9090302@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Mark Brown <broonie@linaro.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@kernel.org>
To: John Stultz <john.stultz@linaro.org>,
	"naresh.kamboju@linaro.org Kamboju" <naresh.kamboju@linaro.org>,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I caught a deadlock bug in 3.14 kernel occasionally on my panda board. It looks like a real issue. Any one like take a look on this?


 * Starting configure virtual network devices[74G[ OK ]


 * Stopping configure virtual network devices[74G[ OK ]


 * Stopping OpenSSH server[74G[ OK ]


 * Starting OpenSSH server[74G[ OK ]


[   18.449584] 

[   18.449584] =================================

[   18.455810] [ INFO: inconsistent lock state ]

[   18.459289] 3.14.0 #81 Not tainted

[   18.459289] ---------------------------------

[   18.459289] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.

[   18.469238] kworker/0:1/560 [HC0[0]:SC0[0]:HE1:SE1] takes:

[   18.480834]  (&addrconf_stats->syncp.seq){+.?...}, at: [<c0523fdb>] ipv6_mc_dad_complete+0x23/0x40

[   18.489624] {IN-SOFTIRQ-W} state was registered at:

[   18.495605]   [<c0070091>] __lock_acquire+0x47d/0x17e8

[   18.499938]   [<c0071a6b>] lock_acquire+0x6b/0x164

[   18.503143]   [<c051fd69>] mld_sendpack+0xd1/0x5f4

[   18.509307]   [<c0520827>] mld_ifc_timer_expire+0x16b/0x1fc

[   18.509307]   [<c003d8c5>] call_timer_fn+0x6d/0x244

[   18.522460]   [<c003dff1>] run_timer_softirq+0x12d/0x26c

[   18.522460]   [<c0038003>] __do_softirq+0x11b/0x3b8

[   18.532531]   [<c00384e9>] irq_exit+0x85/0xb8

[   18.533874]   [<c000e045>] handle_IRQ+0x39/0x70

[   18.539306]   [<c0008591>] gic_handle_irq+0x2d/0x54

[   18.539306]   [<c0570dbf>] __irq_svc+0x3f/0x64

[   18.550445]   [<c05726e8>] do_page_fault.part.11+0x104/0x2b4

[   18.558654]   [<c05728f3>] do_page_fault+0x5b/0x60

[   18.559783]   [<c00083c9>] do_DataAbort+0x35/0x78

[   18.568725]   [<c0570f83>] __dabt_usr+0x43/0x60

[   18.573516] irq event stamp: 7141

[   18.577026] hardirqs last  enabled at (7141): [<c00383bf>] __local_bh_enable_ip+0x63/0xa8

[   18.585693] hardirqs last disabled at (7139): [<c0038389>] __local_bh_enable_ip+0x2d/0xa8

[   18.594360] softirqs last  enabled at (7140): [<c0501448>] ip6_finish_output2+0x1e4/0x88c

[   18.603027] softirqs last disabled at (7130): [<c05012a2>] ip6_finish_output2+0x3e/0x88c

[   18.611602] 

[   18.611602] other info that might help us debug this:

[   18.618499]  Possible unsafe locking scenario:

[   18.618499] 

[   18.624755]        CPU0

[   18.627349]        ----

[   18.629943]   lock(&addrconf_stats->syncp.seq);

[   18.634735]   <Interrupt>

[   18.637512]     lock(&addrconf_stats->syncp.seq);

[   18.642486] 

[   18.642486]  *** DEADLOCK ***

[   18.642486] 

[   18.648742] 4 locks held by kworker/0:1/560:

[   18.653259]  #0:  ("%s"("ipv6_addrconf")){.+.+..}, at: [<c0049b32>] process_one_work+0xd2/0x4b4

[   18.662536]  #1:  ((&(&ifa->dad_work)->work)){+.+...}, at: [<c0049b32>] process_one_work+0xd2/0x4b4

[   18.672149]  #2:  (rtnl_mutex){+.+.+.}, at: [<c050bf4d>] addrconf_dad_work+0x1d/0x250

[   18.680450]  #3:  (rcu_read_lock){.+.+..}, at: [<c051fc98>] mld_sendpack+0x0/0x5f4

[   18.688507] 

[   18.688507] stack backtrace:

[   18.693145] CPU: 0 PID: 560 Comm: kworker/0:1 Not tainted 3.14.0 #81

[   18.699859] Workqueue: ipv6_addrconf addrconf_dad_work

[   18.705322] [<c00133ad>] (unwind_backtrace) from [<c0010761>] (show_stack+0x11/0x14)

[   18.713531] [<c0010761>] (show_stack) from [<c056b2e9>] (dump_stack+0x71/0x84)

[   18.721191] [<c056b2e9>] (dump_stack) from [<c0567a29>] (print_usage_bug+0x25d/0x268)

[   18.729492] [<c0567a29>] (print_usage_bug) from [<c006f2f7>] (mark_lock+0x173/0x5dc)

[   18.737670] [<c006f2f7>] (mark_lock) from [<c00700d7>] (__lock_acquire+0x4c3/0x17e8)

[   18.745880] [<c00700d7>] (__lock_acquire) from [<c0071a6b>] (lock_acquire+0x6b/0x164)

[   18.754180] [<c0071a6b>] (lock_acquire) from [<c051ffd7>] (mld_sendpack+0x33f/0x5f4)

[   18.762390] [<c051ffd7>] (mld_sendpack) from [<c0523fdb>] (ipv6_mc_dad_complete+0x23/0x40)

[   18.771118] [<c0523fdb>] (ipv6_mc_dad_complete) from [<c050bea3>] (addrconf_dad_completed+0xb3/0x140)

[   18.780883] [<c050bea3>] (addrconf_dad_completed) from [<c050c0ab>] (addrconf_dad_work+0x17b/0x250)

[   18.790496] [<c050c0ab>] (addrconf_dad_work) from [<c0049b97>] (process_one_work+0x137/0x4b4)

[   18.799499] [<c0049b97>] (process_one_work) from [<c004a793>] (worker_thread+0xef/0x2d8)

[   18.808074] [<c004a793>] (worker_thread) from [<c004f90f>] (kthread+0xa7/0xb8)

[   18.815734] [<c004f90f>] (kthread) from [<c000d809>] (ret_from_fork+0x11/0x1c)

 * Starting NetBIOS n


-- 
Thanks
    Alex
