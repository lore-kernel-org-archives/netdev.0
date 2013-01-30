From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Lockup in barely-patched 3.7.5, maybe wifi/ath9k or i2c related
Date: Tue, 29 Jan 2013 18:18:27 -0800
Message-ID: <510882F3.4080000@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I've been seeing strange lockups since 3.7.4.  Not so easily reproducible
most of the time.  Previous lockups looked to be rcu/rtnl based, but the one
below has a bunch of i2c stuff in it.

Patches applied are a few wifi patches from upstream and one hack to make
ath9k able to over-ride the eeprom regdomain.

I *think* the decodes are proper, I had to switch back to this patch
set and re-compile....

(gdb) l *(dev_queue_xmit+0x20b)
0xc08670ab is in dev_queue_xmit (/home/greearb/git/linux-3.7.dev.y/include/linux/rcupdate.h:798).
793	 *
794	 * See rcu_read_lock_bh() for more information.
795	 */
796	static inline void rcu_read_unlock_bh(void)
797	{
798		rcu_lockdep_assert(!rcu_is_cpu_idle(),
799				   "rcu_read_unlock_bh() used illegally while idle");
800		rcu_lock_release(&rcu_bh_lock_map);
801		__release(RCU_BH);
802		local_bh_enable();



[  150.708220] IPv6: ADDRCONF(NETDEV_CHANGE): sta3: link becomes ready
[  150.720329] sta3: associated
[  160.900539] net_ratelimit: 110 callbacks suppressed
[  196.951026] [sched_delayed] sched: RT throttling activated
[  432.111031] BUG: soft lockup - CPU#1 stuck for 22s! [kworker/1:1:29]
[  432.111031] Modules linked in: iptable_raw xt_CT nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack bridge veth ip_gre gre 8021q garp stp llc]
[  432.111031] irq event stamp: 10069689
[  432.111031] hardirqs last  enabled at (10069688): [<c051f809>] kmem_cache_free+0x69/0x130
[  432.111031] hardirqs last disabled at (10069689): [<c0974ff2>] apic_timer_interrupt+0x32/0x40
[  432.111031] softirqs last  enabled at (5393860): [<c044d4ab>] __do_softirq+0x10b/0x170
[  432.111031] softirqs last disabled at (5393867): [<c040ddad>] do_softirq+0x9d/0xf0
[  432.111031] Pid: 29, comm: kworker/1:1 Tainted: G         C   3.7.5+ #36 To Be Filled By O.E.M. To Be Filled By O.E.M./To be filled by O.E.M.
[  432.111031] EIP: 0060:[<c0462623>] EFLAGS: 00000202 CPU: 1
[  432.111031] EIP is at debug_lockdep_rcu_enabled+0x13/0x40
[  432.111031] EAX: 00000000 EBX: ef5cc480 ECX: 00000001 EDX: 00000001
[  432.111031] ESI: f131a200 EDI: f1377600 EBP: f5cc1ca0 ESP: f5cc1ca0
[  432.111031]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  432.111031] CR0: 8005003b CR2: bf903000 CR3: 30012000 CR4: 000007e0
[  432.111031] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[  432.111031] DR6: ffff0ff0 DR7: 00000400
[  432.111031] Process kworker/1:1 (pid: 29, ti=f5cc0000 task=f5dd8000 task.ti=f5de0000)
[  432.111031] Stack:
[  432.111031]  f5cc1cd4 c0866fcb 00000002 00000001 00000000 c0866dc0 00cc1cd4 f131a25c
[  432.111031]  f1396000 00000001 ef5cc480 ef5cc480 f1396000 f5cc1cf8 f8f0ca21 aaaac480
[  432.111031]  328e0e00 ef5cc498 ef4d6c86 f5cc1e38 00000003 f13965c0 f5cc1da8 f8f0e8b8
[  432.111031] Call Trace:
[  432.111031]  [<c0866fcb>] dev_queue_xmit+0x20b/0x6e0
[  432.111031]  [<c0866dc0>] ? ptype_seq_start+0xa0/0xa0
[  432.111031]  [<f8f0ca21>] ieee80211_deliver_skb+0xb1/0x1a0 [mac80211]
[  432.111031]  [<f8f0e8b8>] ieee80211_rx_handlers+0xd28/0x1940 [mac80211]
[  432.111031]  [<c049d294>] ? mark_held_locks+0x64/0xf0
[  432.111031]  [<c049d561>] ? trace_hardirqs_on_caller+0xa1/0x180
[  432.111031]  [<c049d64b>] ? trace_hardirqs_on+0xb/0x10
[  432.111031]  [<c09746df>] ? _raw_spin_unlock_irqrestore+0x3f/0x80
[  432.111031]  [<f8f0f7ae>] ieee80211_prepare_and_rx_handle+0x2de/0xaf0 [mac80211]
[  432.111031]  [<f8f1031b>] ieee80211_rx+0x35b/0xa80 [mac80211]
[  432.111031]  [<f8f10071>] ? ieee80211_rx+0xb1/0xa80 [mac80211]
[  432.111031]  [<f8ae1818>] ath_rx_tasklet+0xde8/0x1340 [ath9k]
[  432.111031]  [<c049d294>] ? mark_held_locks+0x64/0xf0
[  432.111031]  [<f8ae044f>] ath9k_tasklet+0xdf/0x130 [ath9k]
[  432.111031]  [<c044cf8c>] tasklet_action+0xbc/0xd0
[  432.111031]  [<c044d440>] __do_softirq+0xa0/0x170
[  432.111031]  [<c044d3a0>] ? irq_enter+0x70/0x70
[  432.111031]  [<c044d3a0>] ? irq_enter+0x70/0x70
[  432.111031]  <IRQ>
[  432.111031]  [<c044d2fd>] ? irq_exit+0xbd/0xe0
[  432.111031]  [<c040d426>] ? do_IRQ+0x46/0xb0
[  432.111031]  [<c097a6f8>] ? common_interrupt+0x38/0x40
[  432.111031]  [<c09780ab>] ? add_preempt_count+0x3b/0xb0
[  432.111031]  [<c06563c4>] ? delay_tsc+0x54/0xb0
[  432.111031]  [<c0656471>] ? __udelay+0x21/0x24
[  432.111031]  [<f82315a2>] ? i2c_outb+0x62/0xd0 [i2c_algo_bit]
[  432.111031]  [<f823166a>] ? try_address+0x5a/0x70 [i2c_algo_bit]
[  432.111031]  [<f8231a42>] ? bit_xfer+0x3c2/0x980 [i2c_algo_bit]
[  432.111031]  [<f83bef55>] ? gmbus_xfer+0x475/0x640 [i915]
[  432.111031]  [<c0971a78>] ? mutex_unlock+0x8/0x10
[  432.111031]  [<f83bef5f>] ? gmbus_xfer+0x47f/0x640 [i915]
[  432.111031]  [<c049d5b4>] ? trace_hardirqs_on_caller+0xf4/0x180
[  432.111031]  [<c09746df>] ? _raw_spin_unlock_irqrestore+0x3f/0x80
[  432.111031]  [<f82241dd>] ? __i2c_transfer+0x4d/0x60 [i2c_core]
[  432.111031]  [<f822512b>] ? i2c_transfer+0x4b/0xb0 [i2c_core]
[  432.111031]  [<c049d5b4>] ? trace_hardirqs_on_caller+0xf4/0x180
[  432.111031]  [<f83b32d7>] ? intel_sdvo_read_byte+0x47/0x90 [i915]
[  432.111031]  [<f83b3b11>] ? intel_sdvo_write_cmd+0x311/0x3c0 [i915]
[  432.111031]  [<f83b0001>] ? ironlake_edp_panel_vdd_on+0x11/0x1b0 [i915]
[  432.111031]  [<f83b3380>] ? intel_sdvo_read_response+0x60/0x1e0 [i915]
[  432.111031]  [<f83b65ce>] ? intel_sdvo_detect+0x4e/0x310 [i915]
[  432.111031]  [<c065599a>] ? snprintf+0x1a/0x20
[  432.111031]  [<f8252ab0>] ? drm_get_connector_name+0x40/0x50 [drm]
[  432.111031]  [<f82d6618>] ? output_poll_execute+0x98/0x170 [drm_kms_helper]
[  432.111031]  [<c045de09>] ? process_one_work+0x139/0x3d0
[  432.111031]  [<c045de76>] ? process_one_work+0x1a6/0x3d0
[  432.111031]  [<c045de09>] ? process_one_work+0x139/0x3d0
[  432.111031]  [<c0460e58>] ? worker_thread+0x198/0x380
[  432.111031]  [<f82d6580>] ? drm_kms_helper_poll_init+0xa0/0xa0 [drm_kms_helper]
[  432.111031]  [<c0460dc2>] ? worker_thread+0x102/0x380
[  432.111031]  [<c0973362>] ? preempt_schedule+0x32/0x50
[  432.111031]  [<c046596c>] ? kthread+0xac/0xb0
[  432.111031]  [<c0460cc0>] ? manage_workers+0x2b0/0x2b0
[  432.111031]  [<c0974742>] ? _raw_spin_unlock_irq+0x22/0x50
[  432.111031]  [<c097a0b7>] ? ret_from_kernel_thread+0x1b/0x28
[  432.111031]  [<c04658c0>] ? __init_kthread_worker+0x60/0x60
[  432.111031] Code: 80 98 01 00 00 01 89 e5 5d c3 8d b4 26 00 00 00 00 8d bc 27 00 00 00 00 8b 0d 14 ac be c0 55 89 e5 85 c9 74 23 8b 15 60 5b bb c0 <85> d2 4
[  432.111031] Kernel panic - not syncing: softlockup: hung tasks
[  432.111031] Pid: 29, comm: kworker/1:1 Tainted: G         C   3.7.5+ #36
[  432.111031] Call Trace:
[  432.111031]  [<c097128d>] panic+0x8c/0x1a3
[  432.111031]  [<c04c3ab1>] watchdog_timer_fn+0x181/0x190
[  432.111031]  [<c046996c>] __run_hrtimer+0x4c/0xf0
[  432.111031]  [<c04c3930>] ? watchdog+0x20/0x20
[  432.111031]  [<c0469df5>] hrtimer_interrupt+0xf5/0x2e0
[  432.111031]  [<c042de5e>] smp_apic_timer_interrupt+0x4e/0x90
[  432.111031]  [<c0657614>] ? trace_hardirqs_off_thunk+0xc/0x18
[  432.111031]  [<c0974ff9>] apic_timer_interrupt+0x39/0x40
[  432.111031]  [<c0462623>] ? debug_lockdep_rcu_enabled+0x13/0x40
[  432.111031]  [<c0866fcb>] dev_queue_xmit+0x20b/0x6e0
[  432.111031]  [<c0866dc0>] ? ptype_seq_start+0xa0/0xa0
[  432.111031]  [<f8f0ca21>] ieee80211_deliver_skb+0xb1/0x1a0 [mac80211]
[  432.111031]  [<f8f0e8b8>] ieee80211_rx_handlers+0xd28/0x1940 [mac80211]
[  432.111031]  [<c049d294>] ? mark_held_locks+0x64/0xf0
[  432.111031]  [<c049d561>] ? trace_hardirqs_on_caller+0xa1/0x180
[  432.111031]  [<c049d64b>] ? trace_hardirqs_on+0xb/0x10
[  432.111031]  [<c09746df>] ? _raw_spin_unlock_irqrestore+0x3f/0x80
[  432.111031]  [<f8f0f7ae>] ieee80211_prepare_and_rx_handle+0x2de/0xaf0 [mac80211]
[  432.111031]  [<f8f1031b>] ieee80211_rx+0x35b/0xa80 [mac80211]
[  432.111031]  [<f8f10071>] ? ieee80211_rx+0xb1/0xa80 [mac80211]
[  432.111031]  [<f8ae1818>] ath_rx_tasklet+0xde8/0x1340 [ath9k]
[  432.111031]  [<c049d294>] ? mark_held_locks+0x64/0xf0
[  432.111031]  [<f8ae044f>] ath9k_tasklet+0xdf/0x130 [ath9k]
[  432.111031]  [<c044cf8c>] tasklet_action+0xbc/0xd0
[  432.111031]  [<c044d440>] __do_softirq+0xa0/0x170
[  432.111031]  [<c044d3a0>] ? irq_enter+0x70/0x70
[  432.111031]  [<c044d3a0>] ? irq_enter+0x70/0x70
[  432.111031]  <IRQ>  [<c044d2fd>] ? irq_exit+0xbd/0xe0
[  432.111031]  [<c040d426>] ? do_IRQ+0x46/0xb0
[  432.111031]  [<c097a6f8>] ? common_interrupt+0x38/0x40
[  432.111031]  [<c09780ab>] ? add_preempt_count+0x3b/0xb0
[  432.111031]  [<c06563c4>] ? delay_tsc+0x54/0xb0
[  432.111031]  [<c0656471>] ? __udelay+0x21/0x24
[  432.111031]  [<f82315a2>] ? i2c_outb+0x62/0xd0 [i2c_algo_bit]
[  432.111031]  [<f823166a>] ? try_address+0x5a/0x70 [i2c_algo_bit]
[  432.111031]  [<f8231a42>] ? bit_xfer+0x3c2/0x980 [i2c_algo_bit]
[  432.111031]  [<f83bef55>] ? gmbus_xfer+0x475/0x640 [i915]
[  432.111031]  [<c0971a78>] ? mutex_unlock+0x8/0x10
[  432.111031]  [<f83bef5f>] ? gmbus_xfer+0x47f/0x640 [i915]
[  432.111031]  [<c049d5b4>] ? trace_hardirqs_on_caller+0xf4/0x180
[  432.111031]  [<c09746df>] ? _raw_spin_unlock_irqrestore+0x3f/0x80
[  432.111031]  [<f82241dd>] ? __i2c_transfer+0x4d/0x60 [i2c_core]
[  432.111031]  [<f822512b>] ? i2c_transfer+0x4b/0xb0 [i2c_core]
[  432.111031]  [<c049d5b4>] ? trace_hardirqs_on_caller+0xf4/0x180
[  432.111031]  [<f83b32d7>] ? intel_sdvo_read_byte+0x47/0x90 [i915]
[  432.111031]  [<f83b3b11>] ? intel_sdvo_write_cmd+0x311/0x3c0 [i915]
[  432.111031]  [<f83b0001>] ? ironlake_edp_panel_vdd_on+0x11/0x1b0 [i915]
[  432.111031]  [<f83b3380>] ? intel_sdvo_read_response+0x60/0x1e0 [i915]
[  432.111031]  [<f83b65ce>] ? intel_sdvo_detect+0x4e/0x310 [i915]
[  432.111031]  [<c065599a>] ? snprintf+0x1a/0x20
[  432.111031]  [<f8252ab0>] ? drm_get_connector_name+0x40/0x50 [drm]
[  432.111031]  [<f82d6618>] ? output_poll_execute+0x98/0x170 [drm_kms_helper]
[  432.111031]  [<c045de09>] ? process_one_work+0x139/0x3d0
[  432.111031]  [<c045de76>] ? process_one_work+0x1a6/0x3d0
[  432.111031]  [<c045de09>] ? process_one_work+0x139/0x3d0
[  432.111031]  [<c0460e58>] ? worker_thread+0x198/0x380
[  432.111031]  [<f82d6580>] ? drm_kms_helper_poll_init+0xa0/0xa0 [drm_kms_helper]
[  432.111031]  [<c0460dc2>] ? worker_thread+0x102/0x380
[  432.111031]  [<c0973362>] ? preempt_schedule+0x32/0x50
[  432.111031]  [<c046596c>] ? kthread+0xac/0xb0
[  432.111031]  [<c0460cc0>] ? manage_workers+0x2b0/0x2b0
[  432.111031]  [<c0974742>] ? _raw_spin_unlock_irq+0x22/0x50
[  432.111031]  [<c097a0b7>] ? ret_from_kernel_thread+0x1b/0x28
[  432.111031]  [<c04658c0>] ? __init_kthread_worker+0x60/0x60
[  432.111031] panic occurred, switching back to text console
[  432.111031] Rebooting in 10 seconds..
  CTRL-A Z for help |115200 8N1 | NOR | Minicom 2.5    | VT102 | Online 00:07

-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
