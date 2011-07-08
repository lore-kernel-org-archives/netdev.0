From: Ben Greear <greearb@candelatech.com>
Subject: network related lockdep splat in 3.0-rc6+
Date: Fri, 08 Jul 2011 15:38:17 -0700
Message-ID: <4E1786D9.3020209@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34001 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872Ab1GHWiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 18:38:18 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p68McH9f013262
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 8 Jul 2011 15:38:17 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This has some additional NFS patches as well, but is otherwise un-tainted.



=======================================================
[ INFO: possible circular locking dependency detected ]
3.0.0-rc6+ #13
-------------------------------------------------------
gnuserver/2266 is trying to acquire lock:
  (rcu_node_level_0){..-...}, at: [<ffffffff810a7439>] rcu_report_unblock_qs_rnp+0x52/0x72

but task is already holding lock:
  (&rq->lock){-.-.-.}, at: [<ffffffff81045da5>] sched_ttwu_pending+0x34/0x58

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #3 (&rq->lock){-.-.-.}:
        [<ffffffff8107b4d5>] lock_acquire+0xf4/0x14b
        [<ffffffff8147e451>] _raw_spin_lock+0x36/0x45
        [<ffffffff8103da13>] __task_rq_lock+0x5b/0x89
        [<ffffffff81046ab6>] wake_up_new_task+0x41/0x116
        [<ffffffff810496d5>] do_fork+0x207/0x2f1
        [<ffffffff81010d25>] kernel_thread+0x70/0x72
        [<ffffffff8146598d>] rest_init+0x21/0xd7
        [<ffffffff81aa9c76>] start_kernel+0x3bd/0x3c8
        [<ffffffff81aa92cd>] x86_64_start_reservations+0xb8/0xbc
        [<ffffffff81aa93d2>] x86_64_start_kernel+0x101/0x110

-> #2 (&p->pi_lock){-.-.-.}:
        [<ffffffff8107b4d5>] lock_acquire+0xf4/0x14b
        [<ffffffff8147e565>] _raw_spin_lock_irqsave+0x4e/0x60
        [<ffffffff810468d0>] try_to_wake_up+0x29/0x1a0
        [<ffffffff81046a54>] default_wake_function+0xd/0xf
        [<ffffffff8106751a>] autoremove_wake_function+0x13/0x38
        [<ffffffff810395d0>] __wake_up_common+0x49/0x7f
        [<ffffffff8103c79a>] __wake_up+0x34/0x48
        [<ffffffff810a74a9>] rcu_report_exp_rnp+0x50/0x89
        [<ffffffff810a8032>] __rcu_read_unlock+0x1e9/0x24e
        [<ffffffff8111a41e>] rcu_read_unlock+0x21/0x23
        [<ffffffff8111a556>] fget_light+0xa2/0xac
        [<ffffffff81128bc1>] do_sys_poll+0x1ff/0x3e5
        [<ffffffff81128f3b>] sys_poll+0x50/0xba
        [<ffffffff81484d52>] system_call_fastpath+0x16/0x1b

-> #1 (sync_rcu_preempt_exp_wq.lock){......}:
        [<ffffffff8107b4d5>] lock_acquire+0xf4/0x14b
        [<ffffffff8147e565>] _raw_spin_lock_irqsave+0x4e/0x60
        [<ffffffff8103c783>] __wake_up+0x1d/0x48
        [<ffffffff810a74a9>] rcu_report_exp_rnp+0x50/0x89
        [<ffffffff810a8c2c>] sync_rcu_preempt_exp_init.clone.0+0x3e/0x53
        [<ffffffff810a8d1c>] synchronize_rcu_expedited+0xdb/0x1c3
        [<ffffffff813c0db3>] synchronize_net+0x25/0x2e
        [<ffffffff813c3382>] rollback_registered_many+0xee/0x1e1
        [<ffffffff813c3489>] unregister_netdevice_many+0x14/0x55
        [<ffffffff813c361b>] default_device_exit_batch+0x98/0xb4
        [<ffffffff813bd95e>] ops_exit_list+0x46/0x4e
        [<ffffffff813bde8c>] cleanup_net+0xeb/0x17d
        [<ffffffff81061343>] process_one_work+0x230/0x41d
        [<ffffffff8106379f>] worker_thread+0x133/0x217
        [<ffffffff81066f9c>] kthread+0x7d/0x85
        [<ffffffff81485ee4>] kernel_thread_helper+0x4/0x10

-> #0 (rcu_node_level_0){..-...}:
        [<ffffffff8107ace2>] __lock_acquire+0xae6/0xdd5
        [<ffffffff8107b4d5>] lock_acquire+0xf4/0x14b
        [<ffffffff8147e451>] _raw_spin_lock+0x36/0x45
        [<ffffffff810a7439>] rcu_report_unblock_qs_rnp+0x52/0x72
        [<ffffffff810a7ff0>] __rcu_read_unlock+0x1a7/0x24e
        [<ffffffff8103d34d>] rcu_read_unlock+0x21/0x23
        [<ffffffff8103d3a2>] cpuacct_charge+0x53/0x5b
        [<ffffffff81044d04>] update_curr+0x11f/0x15a
        [<ffffffff81045a37>] enqueue_task_fair+0x46/0x22a
        [<ffffffff8103d2c0>] enqueue_task+0x61/0x68
        [<ffffffff8103d2ef>] activate_task+0x28/0x30
        [<ffffffff81040b3b>] ttwu_activate+0x12/0x34
        [<ffffffff81045d5f>] ttwu_do_activate.clone.4+0x2d/0x3f
        [<ffffffff81045db4>] sched_ttwu_pending+0x43/0x58
        [<ffffffff81045dd2>] scheduler_ipi+0x9/0xb
        [<ffffffff81021e10>] smp_reschedule_interrupt+0x25/0x27
        [<ffffffff81485c73>] reschedule_interrupt+0x13/0x20
        [<ffffffff813fce40>] rcu_read_unlock+0x21/0x23
        [<ffffffff813fd52d>] ip_queue_xmit+0x35e/0x3b1
        [<ffffffff8140f5f3>] tcp_transmit_skb+0x785/0x7c3
        [<ffffffff81411e23>] tcp_write_xmit+0x806/0x8f5
        [<ffffffff81411f63>] __tcp_push_pending_frames+0x20/0x4d
        [<ffffffff8140411f>] tcp_push+0x84/0x86
        [<ffffffff81406577>] tcp_sendmsg+0x674/0x775
        [<ffffffff81423d68>] inet_sendmsg+0x61/0x6a
        [<ffffffff813af67a>] __sock_sendmsg_nosec+0x58/0x61
        [<ffffffff813b0db5>] __sock_sendmsg+0x3d/0x48
        [<ffffffff813b1631>] sock_sendmsg+0xa3/0xbc
        [<ffffffff813b1bf5>] sys_sendto+0xfa/0x11f
        [<ffffffff81484d52>] system_call_fastpath+0x16/0x1b

other info that might help us debug this:

Chain exists of:
   rcu_node_level_0 --> &p->pi_lock --> &rq->lock

  Possible unsafe locking scenario:

        CPU0                    CPU1
        ----                    ----
   lock(&rq->lock);
                                lock(&p->pi_lock);
                                lock(&rq->lock);
   lock(rcu_node_level_0);

  *** DEADLOCK ***

2 locks held by gnuserver/2266:
  #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff81405f24>] tcp_sendmsg+0x21/0x775
  #1:  (&rq->lock){-.-.-.}, at: [<ffffffff81045da5>] sched_ttwu_pending+0x34/0x58

stack backtrace:
Pid: 2266, comm: gnuserver Not tainted 3.0.0-rc6+ #13
Call Trace:
  <IRQ>  [<ffffffff8107a13d>] print_circular_bug+0x1fe/0x20f
  [<ffffffff8107ace2>] __lock_acquire+0xae6/0xdd5
  [<ffffffff810a7439>] ? rcu_report_unblock_qs_rnp+0x52/0x72
  [<ffffffff8107b4d5>] lock_acquire+0xf4/0x14b
  [<ffffffff810a7439>] ? rcu_report_unblock_qs_rnp+0x52/0x72
  [<ffffffff8147e451>] _raw_spin_lock+0x36/0x45
  [<ffffffff810a7439>] ? rcu_report_unblock_qs_rnp+0x52/0x72
  [<ffffffff8147ea3b>] ? _raw_spin_unlock+0x45/0x52
  [<ffffffff810a7439>] rcu_report_unblock_qs_rnp+0x52/0x72
  [<ffffffff810a7f25>] ? __rcu_read_unlock+0xdc/0x24e
  [<ffffffff810a7ff0>] __rcu_read_unlock+0x1a7/0x24e
  [<ffffffff8103d34d>] rcu_read_unlock+0x21/0x23
  [<ffffffff8103d3a2>] cpuacct_charge+0x53/0x5b
  [<ffffffff81044d04>] update_curr+0x11f/0x15a
  [<ffffffff81045a37>] enqueue_task_fair+0x46/0x22a
  [<ffffffff8103d2c0>] enqueue_task+0x61/0x68
  [<ffffffff8103d2ef>] activate_task+0x28/0x30
  [<ffffffff81040b3b>] ttwu_activate+0x12/0x34
  [<ffffffff81045d5f>] ttwu_do_activate.clone.4+0x2d/0x3f
  [<ffffffff81045db4>] sched_ttwu_pending+0x43/0x58
  [<ffffffff81045dd2>] scheduler_ipi+0x9/0xb
  [<ffffffff81021e10>] smp_reschedule_interrupt+0x25/0x27
  [<ffffffff81485c73>] reschedule_interrupt+0x13/0x20
  <EOI>  [<ffffffff810a7e9b>] ? __rcu_read_unlock+0x52/0x24e
  [<ffffffff813fce40>] rcu_read_unlock+0x21/0x23
  [<ffffffff813fd52d>] ip_queue_xmit+0x35e/0x3b1
  [<ffffffff813fd1cf>] ? ip_send_reply+0x247/0x247
  [<ffffffff8140f5f3>] tcp_transmit_skb+0x785/0x7c3
  [<ffffffff81411e23>] tcp_write_xmit+0x806/0x8f5
  [<ffffffff810e646f>] ? might_fault+0x4e/0x9e
  [<ffffffff81403e25>] ? copy_from_user+0x2a/0x2c
  [<ffffffff81411f63>] __tcp_push_pending_frames+0x20/0x4d
  [<ffffffff8140411f>] tcp_push+0x84/0x86
  [<ffffffff81406577>] tcp_sendmsg+0x674/0x775
  [<ffffffff81423d68>] inet_sendmsg+0x61/0x6a
  [<ffffffff813af67a>] __sock_sendmsg_nosec+0x58/0x61
  [<ffffffff813b0db5>] __sock_sendmsg+0x3d/0x48
  [<ffffffff813b1631>] sock_sendmsg+0xa3/0xbc
  [<ffffffff810ea6ae>] ? handle_pte_fault+0x7fc/0x84d
  [<ffffffff8111a4e9>] ? fget_light+0x35/0xac
  [<ffffffff813b16b2>] ? sockfd_lookup_light+0x1b/0x53
  [<ffffffff813b1bf5>] sys_sendto+0xfa/0x11f
  [<ffffffff811326ac>] ? mntput_no_expire+0x52/0x109
  [<ffffffff81132784>] ? mntput+0x21/0x23
  [<ffffffff8111af94>] ? fput+0x1a3/0x1b2
  [<ffffffff8109f0a1>] ? audit_syscall_entry+0x119/0x145
  [<ffffffff81484d52>] system_call_fastpath+0x16/0x1b

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

