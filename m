From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: net-next: lockdep complains re percpu counters
Date: Sun, 30 Nov 2008 16:07:26 +0300
Message-ID: <20081130130726.GA4365@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:62540 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbYK3NDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2008 08:03:22 -0500
Received: by ey-out-2122.google.com with SMTP id 6so867204eyi.37
        for <netdev@vger.kernel.org>; Sun, 30 Nov 2008 05:03:21 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is net-next as of c5419e6f054c877339f754e02c3b1dafd88cd96c
aka "cxgb3: Fix sparse warning and micro-optimize is_pure_response()".

=================================
[ INFO: inconsistent lock state ]
2.6.28-rc6-netns #2
---------------------------------
inconsistent {softirq-on-W} -> {in-softirq-W} usage.
recvfrom01/7632 [HC0[0]:SC1[1]:HE1:SE0] takes:
 (&fbc->lock){-+..}, at: [<ffffffff803292d3>] __percpu_counter_add+0x63/0xc0
{softirq-on-W} state was registered at:
  [<ffffffff80257709>] __lock_acquire+0x4b9/0x9c0
  [<ffffffff802586b6>] lock_acquire+0x56/0x80
  [<ffffffff804eb256>] _spin_lock+0x36/0x50
  [<ffffffff803292d3>] __percpu_counter_add+0x63/0xc0
  [<ffffffff802907b9>] get_empty_filp+0x59/0x110
  [<ffffffff80298fa0>] path_lookup_open+0x30/0xc0
  [<ffffffff80299a5e>] do_filp_open+0xae/0x8a0
  [<ffffffff8028f036>] do_sys_open+0x76/0xd0
  [<ffffffff8028f0ab>] sys_open+0x1b/0x20
  [<ffffffff8020b6db>] system_call_fastpath+0x16/0x1b
  [<ffffffffffffffff>] 0xffffffffffffffff
irq event stamp: 5698
hardirqs last  enabled at (5698): [<ffffffff80258de1>] debug_check_no_locks_freed+0xa1/0x150
hardirqs last disabled at (5697): [<ffffffff80258d80>] debug_check_no_locks_freed+0x40/0x150
softirqs last  enabled at (5656): [<ffffffff803d8031>] release_sock+0xc1/0xf0
softirqs last disabled at (5657): [<ffffffff8020cb8c>] call_softirq+0x1c/0x30

other info that might help us debug this:
2 locks held by recvfrom01/7632:
 #0:  (slock-AF_INET/1){-+..}, at: [<ffffffff8044106b>] tcp_v4_rcv+0x50b/0x840
 #1:  (slock-AF_INET){-+..}, at: [<ffffffff803d75f1>] sk_clone+0xe1/0x340

stack backtrace:
Pid: 7632, comm: recvfrom01 Not tainted 2.6.28-rc6-netns #2
Call Trace:
 <IRQ>  [<ffffffff80255e3d>] print_usage_bug+0x18d/0x1e0
 [<ffffffff80256a67>] mark_lock+0x887/0xb70
 [<ffffffff80257692>] __lock_acquire+0x442/0x9c0
 [<ffffffff802586b6>] lock_acquire+0x56/0x80
 [<ffffffff803292d3>] ? __percpu_counter_add+0x63/0xc0
 [<ffffffff804eb256>] _spin_lock+0x36/0x50
 [<ffffffff803292d3>] ? __percpu_counter_add+0x63/0xc0
 [<ffffffff803292d3>] __percpu_counter_add+0x63/0xc0
 [<ffffffff803d7817>] sk_clone+0x307/0x340
 [<ffffffff8042ddb1>] inet_csk_clone+0x11/0xa0
 [<ffffffff80442c34>] tcp_create_openreq_child+0x24/0x470
 [<ffffffff80440773>] tcp_v4_syn_recv_sock+0x53/0x210
 [<ffffffff804431a5>] tcp_check_req+0x125/0x450
 [<ffffffff802377b4>] ? local_bh_enable+0xa4/0x110
 [<ffffffff80440a6d>] tcp_v4_do_rcv+0x13d/0x230
 [<ffffffff804412a5>] tcp_v4_rcv+0x745/0x840
 [<ffffffff80423304>] ip_local_deliver_finish+0x124/0x2b0
 [<ffffffff80423530>] ip_local_deliver+0xa0/0xb0
 [<ffffffff8042364c>] ip_rcv_finish+0x10c/0x3c0
 [<ffffffff80423ac0>] ip_rcv+0x1c0/0x300
 [<ffffffff803e3f79>] netif_receive_skb+0x379/0x400
 [<ffffffff803e411b>] ? process_backlog+0x8b/0x100
 [<ffffffff803e4127>] process_backlog+0x97/0x100
 [<ffffffff803e42da>] net_rx_action+0x14a/0x210
 [<ffffffff802379b8>] __do_softirq+0x88/0x150
 [<ffffffff803d8031>] ? release_sock+0xc1/0xf0
 [<ffffffff8020cb8c>] call_softirq+0x1c/0x30
 <EOI>  [<ffffffff8020e5b7>] do_softirq+0x77/0xd0
 [<ffffffff803d8031>] ? release_sock+0xc1/0xf0
 [<ffffffff8023790b>] local_bh_enable_ip+0xeb/0x110
 [<ffffffff804eb929>] _spin_unlock_bh+0x39/0x40
 [<ffffffff803d7ffe>] ? release_sock+0x8e/0xf0
 [<ffffffff803d8031>] release_sock+0xc1/0xf0
 [<ffffffff8044f178>] inet_stream_connect+0x198/0x2e0
 [<ffffffff80247e70>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80247e70>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803d557d>] sys_connect+0x7d/0xc0
 [<ffffffff8020b70c>] ? sysret_check+0x27/0x62
 [<ffffffff80256eca>] ? trace_hardirqs_on_caller+0xba/0x130
 [<ffffffff804eaf07>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff8020b6db>] system_call_fastpath+0x16/0x1b
