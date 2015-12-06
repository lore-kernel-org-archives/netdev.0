From: Dave Jones <davej@codemonkey.org.uk>
Subject: suspicious rcu_dereference_check in sctp_v6_get_dst
Date: Sat, 5 Dec 2015 19:25:17 -0500
Message-ID: <20151206002517.GB14181@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:51029 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417AbbLFAZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 19:25:25 -0500
Received: from [209.6.119.210] (helo=wopr.kernelslacker.org)
	by arcturus.aphlor.org with esmtpsa (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.84)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1a5N8m-0002ep-4B
	for netdev@vger.kernel.org; Sun, 06 Dec 2015 00:25:24 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

===============================
[ INFO: suspicious RCU usage. ]
4.4.0-rc3-think+ #8 Tainted: G        W      
-------------------------------
net/sctp/ipv6.c:331 suspicious rcu_dereference_check() usage!

other info that might help us debug this:


rcu_scheduler_active = 1, debug_locks = 0
1 lock held by trinity-c2/15441:
 #0:  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffffc065fc01>] sctp_sendmsg+0x501/0x16a0 [sctp]

stack backtrace:
CPU: 2 PID: 15441 Comm: trinity-c2 Tainted: G        W       4.4.0-rc3-think+ #8
 ffffffffffffff9b ffff880458d677c8 ffffffffab530f11 ffff88045f1db700
 ffff880458d677f8 ffffffffab12d248 ffff880452b13f80 ffff880452b13f60
 0000000000000000 ffff88045ad45280 ffff880458d67970 ffffffffc0673a7c
Call Trace:
 [<ffffffffab530f11>] dump_stack+0x4e/0x7d
 [<ffffffffab12d248>] lockdep_rcu_suspicious+0xf8/0x110
 [<ffffffffc0673a7c>] sctp_v6_get_dst+0xacc/0xb30 [sctp]
 [<ffffffffc0673666>] ? sctp_v6_get_dst+0x6b6/0xb30 [sctp]
 [<ffffffffc0672fb0>] ? sctp_inet6_send_verify+0x180/0x180 [sctp]
 [<ffffffffab6b1c69>] ? get_random_bytes+0x69/0x150
 [<ffffffffab6b0950>] ? extract_buf+0x370/0x370
 [<ffffffffab12afa2>] ? __lock_is_held+0x92/0xd0
 [<ffffffffc0647390>] ? sctp_transport_new+0x2f0/0x320 [sctp]
 [<ffffffffc0647786>] sctp_transport_route+0x66/0x1c0 [sctp]
 [<ffffffffc0644d02>] sctp_assoc_add_peer+0x242/0x680 [sctp]
 [<ffffffffc06603d1>] sctp_sendmsg+0xcd1/0x16a0 [sctp]
 [<ffffffffab12f64f>] ? mark_lock+0x6f/0x8a0
 [<ffffffffc065f700>] ? sctp_id2assoc+0x140/0x140 [sctp]
 [<ffffffffab130620>] ? debug_check_no_locks_freed+0x1b0/0x1b0
 [<ffffffffab12f64f>] ? mark_lock+0x6f/0x8a0
 [<ffffffffab015269>] ? native_sched_clock+0x69/0x160
 [<ffffffffab5606e7>] ? debug_smp_processor_id+0x17/0x20
 [<ffffffffab0eb1e1>] ? preempt_count_sub+0xc1/0x120
 [<ffffffffabbb3d0e>] inet_sendmsg+0x18e/0x270
 [<ffffffffabbb3b85>] ? inet_sendmsg+0x5/0x270
 [<ffffffffabaa4ee8>] SYSC_sendto+0x1d8/0x2c0
 [<ffffffffabaa4d10>] ? sock_create_kern+0x20/0x20
 [<ffffffffab12af35>] ? __lock_is_held+0x25/0xd0
 [<ffffffffab1300c6>] ? trace_hardirqs_on_caller+0x186/0x280
 [<ffffffffab1301cd>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffffab253a5d>] ? context_tracking_exit+0x1d/0x20
 [<ffffffffab002fdf>] ? enter_from_user_mode+0x1f/0x50
 [<ffffffffab0031b2>] ? syscall_trace_enter_phase1+0x1a2/0x240
 [<ffffffffab003010>] ? enter_from_user_mode+0x50/0x50
 [<ffffffffabcb735a>] ? int_ret_from_sys_call+0x52/0x9f
 [<ffffffffab1300c6>] ? trace_hardirqs_on_caller+0x186/0x280
 [<ffffffffab002017>] ? trace_hardirqs_on_thunk+0x17/0x19
 [<ffffffffabaa5aee>] SyS_sendto+0xe/0x10
 [<ffffffffabcb71d7>] entry_SYSCALL_64_fastpath+0x12/0x6b

This maybe ?

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index acb45b8c2a9d..7081183f4d9f 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -328,7 +328,9 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 	if (baddr) {
 		fl6->saddr = baddr->v6.sin6_addr;
 		fl6->fl6_sport = baddr->v6.sin6_port;
+		rcu_read_lock();
 		final_p = fl6_update_dst(fl6, rcu_dereference(np->opt), &final);
+		rcu_read_unlock();
 		dst = ip6_dst_lookup_flow(sk, fl6, final_p);
 	}
 
