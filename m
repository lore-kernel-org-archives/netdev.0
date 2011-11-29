From: Marc Aurele La France <tsi@ualberta.ca>
Subject: RCU'ed dst_get_neighbour()
Date: Tue, 29 Nov 2011 10:44:36 -0700 (Mountain Standard Time)
Message-ID: <alpine.WNT.2.00.1111291027320.1036@TSI>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.srv.ualberta.ca ([129.128.5.19]:61326 "EHLO
	mail1.srv.ualberta.ca" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755968Ab1K2SFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 13:05:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Commit (1) seems to imply that all dst_get_neighbour() references now need 
to be wrapped with rcu_read_lock()/rcu_read_unlock() sequences.  See (2) 
for one such proposed change.

In the case I have here (ipoib), this commit results in ...

===================================================
[ INFO: suspicious rcu_dereference_check() usage. ]
---------------------------------------------------
include/net/dst.h:91 invoked rcu_dereference_check() without protection!

other info that might help us debug this:


rcu_scheduler_active = 1, debug_locks = 1
4 locks held by kworker/3:1/630:
  #0:  (ib_cm){.+.+.+}, at: [<ffffffff81055735>] 
process_one_work+0x1ab/0x4f9
  #1:  ((&(&work->work)->work)){+.+.+.}, at: [<ffffffff81055735>] 
process_one_work+0x1ab/0x4f9
  #2:  (rcu_read_lock_bh){.+....}, at: [<ffffffff81388216>] 
dev_queue_xmit+0x0/0x5ae
  #3:  (_xmit_INFINIBAND){+.-...}, at: [<ffffffff8139eecc>] 
sch_direct_xmit+0x4d/0x22b

stack backtrace:
Pid: 630, comm: kworker/3:1 Not tainted 3.1.3-smp #1
Call Trace:
  [<ffffffff8106c385>] lockdep_rcu_dereference+0x9b/0xa4
  [<ffffffff81351cda>] ipoib_start_xmit+0xf4/0x36f
  [<ffffffff81384215>] dev_hard_start_xmit+0x2a7/0x54f
  [<ffffffff8139eeef>] sch_direct_xmit+0x70/0x22b
  [<ffffffff8138851f>] dev_queue_xmit+0x309/0x5ae
  [<ffffffff81388216>] ? napi_gro_receive+0xb3/0xb3
  [<ffffffff813582d3>] ipoib_cm_rep_handler+0x208/0x248
  [<ffffffff81433e16>] ? _raw_spin_unlock_irqrestore+0x3d/0x5b
  [<ffffffff8135a912>] ipoib_cm_tx_handler+0x95/0x27f
  [<ffffffff8106d183>] ? __trace_hardirqs_on_caller+0x41/0x65
  [<ffffffff81327b29>] cm_process_work+0x26/0xbc
  [<ffffffff81328d74>] cm_rep_handler+0x274/0x2ae
  [<ffffffff81329582>] cm_work_handler+0x41/0x91
  [<ffffffff8105582c>] process_one_work+0x2a2/0x4f9
  [<ffffffff81055735>] ? process_one_work+0x1ab/0x4f9
  [<ffffffff810580c6>] ? worker_thread+0x4a/0x1ca
  [<ffffffff81329541>] ? cm_req_handler+0x355/0x355
  [<ffffffff81058175>] worker_thread+0xf9/0x1ca
  [<ffffffff8105807c>] ? gcwq_mayday_timeout+0x77/0x77
  [<ffffffff8105bfa3>] kthread+0x86/0x8e
  [<ffffffff81436b34>] kernel_thread_helper+0x4/0x10
  [<ffffffff8143425d>] ? retint_restore_args+0xe/0xe
  [<ffffffff8105bf1d>] ? kthread_stop+0x1cd/0x1cd
  [<ffffffff81436b30>] ? gs_change+0xb/0xb

===================================================
[ INFO: suspicious rcu_dereference_check() usage. ]
---------------------------------------------------
include/net/dst.h:91 invoked rcu_dereference_check() without protection!

other info that might help us debug this:


rcu_scheduler_active = 1, debug_locks = 1
2 locks held by kworker/u:2/748:
  #0:  ((name)){.+.+.+}, at: [<ffffffff81055735>] 
process_one_work+0x1ab/0x4f9
  #1:  ((&port_priv->work)){+.+.+.}, at: [<ffffffff81055735>] 
process_one_work+0x1ab/0x4f9

stack backtrace:
Pid: 748, comm: kworker/u:2 Not tainted 3.1.3-smp #1
Call Trace:
  [<ffffffff8106c385>] lockdep_rcu_dereference+0x9b/0xa4
  [<ffffffff81354e68>] ipoib_mcast_join_finish+0x362/0x48a
  [<ffffffff81355481>] ipoib_mcast_sendonly_join_complete+0x3b/0x174
  [<ffffffff813246b3>] mcast_work_handler+0xba/0x182
  [<ffffffff813248aa>] join_handler+0xe6/0xee
  [<ffffffff81322af1>] ib_sa_mcmember_rec_callback+0x51/0x5c
  [<ffffffff8132289c>] recv_handler+0x44/0x50
  [<ffffffff8131efca>] ib_mad_complete_recv+0xc3/0x125
  [<ffffffff8131debe>] ? find_mad_agent+0x13a/0x149
  [<ffffffff8131f30a>] ib_mad_recv_done_handler+0x2de/0x326
  [<ffffffff8131f3b0>] ib_mad_completion_handler+0x5e/0x91
  [<ffffffff8105582c>] process_one_work+0x2a2/0x4f9
  [<ffffffff81055735>] ? process_one_work+0x1ab/0x4f9
  [<ffffffff810580c6>] ? worker_thread+0x4a/0x1ca
  [<ffffffff8131f352>] ? ib_mad_recv_done_handler+0x326/0x326
  [<ffffffff81058175>] worker_thread+0xf9/0x1ca
  [<ffffffff8105807c>] ? gcwq_mayday_timeout+0x77/0x77
  [<ffffffff8105bfa3>] kthread+0x86/0x8e
  [<ffffffff81436b34>] kernel_thread_helper+0x4/0x10
  [<ffffffff8143425d>] ? retint_restore_args+0xe/0xe
  [<ffffffff8105bf1d>] ? kthread_stop+0x1cd/0x1cd
  [<ffffffff81436b30>] ? gs_change+0xb/0xb

Comments/flames?

Thanks.

Marc.

PS:  Please reply-to-all as I am not subscribed to netdev.

(1) http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=f2c31e32b378a6653f8de606149d963baf11d7d3
(2) http://www.spinics.net/lists/netdev/msg179639.html

+----------------------------------+----------------------------------+
|  Marc Aurele La France           |  work:   1-780-492-9310          |
|  Academic Information and        |  fax:    1-780-492-1729          |
|    Communications Technologies   |  email:  tsi@ualberta.ca         |
|  352 General Services Building   +----------------------------------+
|  University of Alberta           |                                  |
|  Edmonton, Alberta               |    Standard disclaimers apply    |
|  T6G 2H1                         |                                  |
|  CANADA                          |                                  |
+----------------------------------+----------------------------------+
