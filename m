From: Ben Greear <greearb@candelatech.com>
Subject: wireless-testing (2.6.36-rc6):  inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W}
 usage.
Date: Thu, 30 Sep 2010 13:16:00 -0700
Message-ID: <4CA4F000.2060509@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50464 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932304Ab0I3UQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 16:16:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We saw this on a system that has two ath9k APs, some extra routing tables
and rules to use them, and a user-space 'bridge' that uses packet-sockets.

Aside from a few patches to help virtualize wireless devices (and none directly to ath9k),
this is today's wireless-testing tree.

=================================
[ INFO: inconsistent lock state ]
2.6.36-rc6-wl+ #20
---------------------------------
inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
kworker/u:0/5 [HC0[0]:SC0[0]:HE1:SE1] takes:
  (&(&list->lock)->rlock){+.?...}, at: [<c0741066>] packet_rcv+0x1f3/0x27a
{IN-SOFTIRQ-W} state was registered at:
   [<c0457036>] __lock_acquire+0x27f/0xb8c
   [<c045799d>] lock_acquire+0x5a/0x78
   [<c07638dc>] _raw_spin_lock+0x1b/0x2a
   [<c0741066>] packet_rcv+0x1f3/0x27a
   [<c06d04a6>] __netif_receive_skb+0x340/0x389
   [<c06d058d>] process_backlog+0x9e/0x16e
   [<c06d1104>] net_rx_action+0x99/0x17a
   [<c04393f2>] __do_softirq+0x86/0x111
   [<c04394b3>] do_softirq+0x36/0x5a
   [<c04395ec>] irq_exit+0x35/0x69
   [<c0403fb9>] do_IRQ+0x86/0x9a
   [<c04034ee>] common_interrupt+0x2e/0x40
   [<c06adb37>] cpuidle_idle_call+0x7f/0xb4
   [<c040227f>] cpu_idle+0x4e/0x6b
   [<c074f9c5>] rest_init+0x8d/0x92
   [<c097b8e0>] start_kernel+0x316/0x31b
   [<c097b0d0>] i386_start_kernel+0xd0/0xd7
irq event stamp: 62565
hardirqs last  enabled at (62565): [<c04adf88>] kmem_cache_alloc+0xa0/0xc5
hardirqs last disabled at (62564): [<c04adf3a>] kmem_cache_alloc+0x52/0xc5
softirqs last  enabled at (62562): [<c073ffe3>] run_filter+0x9b/0xa5
softirqs last disabled at (62560): [<c073ff59>] run_filter+0x11/0xa5

other info that might help us debug this:
4 locks held by kworker/u:0/5:
  #0:  ((wiphy_name(local->hw.wiphy))){+.+...}, at: [<c0443d2d>] process_one_work+0x173/0x2c3
  #1:  ((&sc->hw_check_work)){+.+...}, at: [<c0443d2d>] process_one_work+0x173/0x2c3
  #2:  (rcu_read_lock){.+.+..}, at: [<f8ff86f8>] ieee80211_tx_status+0x5c1/0x6b9 [mac80211]
  #3:  (rcu_read_lock){.+.+..}, at: [<c06cedec>] rcu_read_lock+0x0/0x21

stack backtrace:
Pid: 5, comm: kworker/u:0 Not tainted 2.6.36-rc6-wl+ #20
Call Trace:
  [<c0761c6a>] ? printk+0xf/0x15
  [<c0455f15>] valid_state+0x131/0x144
  [<c0456017>] mark_lock+0xef/0x1de
  [<c0456738>] ? check_usage_backwards+0x0/0x68
  [<c04570a4>] __lock_acquire+0x2ed/0xb8c
  [<c0455f03>] ? valid_state+0x11f/0x144
  [<c06dd853>] ? sk_run_filter+0x1d0/0x3c0
  [<c0455f46>] ? mark_lock+0x1e/0x1de
  [<c045799d>] lock_acquire+0x5a/0x78
  [<c0741066>] ? packet_rcv+0x1f3/0x27a
  [<c07638dc>] _raw_spin_lock+0x1b/0x2a
  [<c0741066>] ? packet_rcv+0x1f3/0x27a
  [<c0741066>] packet_rcv+0x1f3/0x27a
  [<c06d04a6>] __netif_receive_skb+0x340/0x389
  [<c06d0f3b>] netif_receive_skb+0x72/0x78
  [<f8ff87a0>] ieee80211_tx_status+0x669/0x6b9 [mac80211]
  [<c0450050>] ? ntp_start_leap_timer+0x4b/0x67
  [<f9091861>] ath_tx_complete_buf+0x1ba/0x219 [ath9k]
  [<c04563a9>] ? trace_hardirqs_on_caller+0x104/0x125
  [<f9092d9d>] ath_draintxq+0x179/0x2c8 [ath9k]
  [<f9094346>] ath_drain_all_txq+0x10f/0x11d [ath9k]
  [<f908e9d1>] ath_reset+0x40/0x15e [ath9k]
  [<f908f31e>] ath_hw_check+0x3c/0x47 [ath9k]
  [<c0443d77>] process_one_work+0x1bd/0x2c3
  [<c0443d2d>] ? process_one_work+0x173/0x2c3
  [<f908f2e2>] ? ath_hw_check+0x0/0x47 [ath9k]
  [<c0445422>] worker_thread+0xf7/0x1f7
  [<c044532b>] ? worker_thread+0x0/0x1f7
  [<c0447dff>] kthread+0x62/0x67
  [<c0447d9d>] ? kthread+0x0/0x67
  [<c0403506>] kernel_thread_helper+0x6/0x1a


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

