From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: fix possible socket refcount problem
Date: Mon, 20 Aug 2012 12:22:46 +0200
Message-ID: <1345458166.5158.316.camel@edumazet-glaptop>
References: <20120818021918.GA6499@localhost>
	 <1345380682.5158.201.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	networking <netdev@vger.kernel.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:32820 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532Ab2HTKWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 06:22:52 -0400
Received: by bkwj10 with SMTP id j10so1802240bkw.19
        for <netdev@vger.kernel.org>; Mon, 20 Aug 2012 03:22:50 -0700 (PDT)
In-Reply-To: <1345380682.5158.201.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit 6f458dfb40 (tcp: improve latencies of timer triggered events)
added bug leading to following trace :

[ 2866.131281] IPv4: Attempt to release TCP socket in state 1 ffff880019ec0000
[ 2866.131726] 
[ 2866.132188] =========================
[ 2866.132281] [ BUG: held lock freed! ]
[ 2866.132281] 3.6.0-rc1+ #622 Not tainted
[ 2866.132281] -------------------------
[ 2866.132281] kworker/0:1/652 is freeing memory ffff880019ec0000-ffff880019ec0a1f, with a lock still held there!
[ 2866.132281]  (sk_lock-AF_INET-RPC){+.+...}, at: [<ffffffff81903619>] tcp_sendmsg+0x29/0xcc6
[ 2866.132281] 4 locks held by kworker/0:1/652:
[ 2866.132281]  #0:  (rpciod){.+.+.+}, at: [<ffffffff81083567>] process_one_work+0x1de/0x47f
[ 2866.132281]  #1:  ((&task->u.tk_work)){+.+.+.}, at: [<ffffffff81083567>] process_one_work+0x1de/0x47f
[ 2866.132281]  #2:  (sk_lock-AF_INET-RPC){+.+...}, at: [<ffffffff81903619>] tcp_sendmsg+0x29/0xcc6
[ 2866.132281]  #3:  (&icsk->icsk_retransmit_timer){+.-...}, at: [<ffffffff81078017>] run_timer_softirq+0x1ad/0x35f
[ 2866.132281] 
[ 2866.132281] stack backtrace:
[ 2866.132281] Pid: 652, comm: kworker/0:1 Not tainted 3.6.0-rc1+ #622
[ 2866.132281] Call Trace:
[ 2866.132281]  <IRQ>  [<ffffffff810bc527>] debug_check_no_locks_freed+0x112/0x159
[ 2866.132281]  [<ffffffff818a0839>] ? __sk_free+0xfd/0x114
[ 2866.132281]  [<ffffffff811549fa>] kmem_cache_free+0x6b/0x13a
[ 2866.132281]  [<ffffffff818a0839>] __sk_free+0xfd/0x114
[ 2866.132281]  [<ffffffff818a08c0>] sk_free+0x1c/0x1e
[ 2866.132281]  [<ffffffff81911e1c>] tcp_write_timer+0x51/0x56
[ 2866.132281]  [<ffffffff81078082>] run_timer_softirq+0x218/0x35f
[ 2866.132281]  [<ffffffff81078017>] ? run_timer_softirq+0x1ad/0x35f
[ 2866.132281]  [<ffffffff810f5831>] ? rb_commit+0x58/0x85
[ 2866.132281]  [<ffffffff81911dcb>] ? tcp_write_timer_handler+0x148/0x148
[ 2866.132281]  [<ffffffff81070bd6>] __do_softirq+0xcb/0x1f9
[ 2866.132281]  [<ffffffff81a0a00c>] ? _raw_spin_unlock+0x29/0x2e
[ 2866.132281]  [<ffffffff81a1227c>] call_softirq+0x1c/0x30
[ 2866.132281]  [<ffffffff81039f38>] do_softirq+0x4a/0xa6
[ 2866.132281]  [<ffffffff81070f2b>] irq_exit+0x51/0xad
[ 2866.132281]  [<ffffffff81a129cd>] do_IRQ+0x9d/0xb4
[ 2866.132281]  [<ffffffff81a0a3ef>] common_interrupt+0x6f/0x6f
[ 2866.132281]  <EOI>  [<ffffffff8109d006>] ? sched_clock_cpu+0x58/0xd1
[ 2866.132281]  [<ffffffff81a0a172>] ? _raw_spin_unlock_irqrestore+0x4c/0x56
[ 2866.132281]  [<ffffffff81078692>] mod_timer+0x178/0x1a9
[ 2866.132281]  [<ffffffff818a00aa>] sk_reset_timer+0x19/0x26
[ 2866.132281]  [<ffffffff8190b2cc>] tcp_rearm_rto+0x99/0xa4
[ 2866.132281]  [<ffffffff8190dfba>] tcp_event_new_data_sent+0x6e/0x70
[ 2866.132281]  [<ffffffff8190f7ea>] tcp_write_xmit+0x7de/0x8e4
[ 2866.132281]  [<ffffffff818a565d>] ? __alloc_skb+0xa0/0x1a1
[ 2866.132281]  [<ffffffff8190f952>] __tcp_push_pending_frames+0x2e/0x8a
[ 2866.132281]  [<ffffffff81904122>] tcp_sendmsg+0xb32/0xcc6
[ 2866.132281]  [<ffffffff819229c2>] inet_sendmsg+0xaa/0xd5
[ 2866.132281]  [<ffffffff81922918>] ? inet_autobind+0x5f/0x5f
[ 2866.132281]  [<ffffffff810ee7f1>] ? trace_clock_local+0x9/0xb
[ 2866.132281]  [<ffffffff8189adab>] sock_sendmsg+0xa3/0xc4
[ 2866.132281]  [<ffffffff810f5de6>] ? rb_reserve_next_event+0x26f/0x2d5
[ 2866.132281]  [<ffffffff8103e6a9>] ? native_sched_clock+0x29/0x6f
[ 2866.132281]  [<ffffffff8103e6f8>] ? sched_clock+0x9/0xd
[ 2866.132281]  [<ffffffff810ee7f1>] ? trace_clock_local+0x9/0xb
[ 2866.132281]  [<ffffffff8189ae03>] kernel_sendmsg+0x37/0x43
[ 2866.132281]  [<ffffffff8199ce49>] xs_send_kvec+0x77/0x80
[ 2866.132281]  [<ffffffff8199cec1>] xs_sendpages+0x6f/0x1a0
[ 2866.132281]  [<ffffffff8107826d>] ? try_to_del_timer_sync+0x55/0x61
[ 2866.132281]  [<ffffffff8199d0d2>] xs_tcp_send_request+0x55/0xf1
[ 2866.132281]  [<ffffffff8199bb90>] xprt_transmit+0x89/0x1db
[ 2866.132281]  [<ffffffff81999bcd>] ? call_connect+0x3c/0x3c
[ 2866.132281]  [<ffffffff81999d92>] call_transmit+0x1c5/0x20e
[ 2866.132281]  [<ffffffff819a0d55>] __rpc_execute+0x6f/0x225
[ 2866.132281]  [<ffffffff81999bcd>] ? call_connect+0x3c/0x3c
[ 2866.132281]  [<ffffffff819a0f33>] rpc_async_schedule+0x28/0x34
[ 2866.132281]  [<ffffffff810835d6>] process_one_work+0x24d/0x47f
[ 2866.132281]  [<ffffffff81083567>] ? process_one_work+0x1de/0x47f
[ 2866.132281]  [<ffffffff819a0f0b>] ? __rpc_execute+0x225/0x225
[ 2866.132281]  [<ffffffff81083a6d>] worker_thread+0x236/0x317
[ 2866.132281]  [<ffffffff81083837>] ? process_scheduled_works+0x2f/0x2f
[ 2866.132281]  [<ffffffff8108b7b8>] kthread+0x9a/0xa2
[ 2866.132281]  [<ffffffff81a12184>] kernel_thread_helper+0x4/0x10
[ 2866.132281]  [<ffffffff81a0a4b0>] ? retint_restore_args+0x13/0x13
[ 2866.132281]  [<ffffffff8108b71e>] ? __init_kthread_worker+0x5a/0x5a
[ 2866.132281]  [<ffffffff81a12180>] ? gs_change+0x13/0x13
[ 2866.308506] IPv4: Attempt to release TCP socket in state 1 ffff880019ec0000
[ 2866.309689] =============================================================================
[ 2866.310254] BUG TCP (Not tainted): Object already free
[ 2866.310254] -----------------------------------------------------------------------------
[ 2866.310254] 

The bug comes from the fact that timer set in sk_reset_timer() can run
before we actually do the sock_hold(). socket refcount reaches zero and
we free the socket too soon.

timer handler is not allowed to reduce socket refcnt if socket is owned
by the user, or we need to change sk_reset_timer() implementation.

We should take a reference on the socket in case TCP_DELACK_TIMER_DEFERRED
or TCP_DELACK_TIMER_DEFERRED bit are set in tsq_flags

Also fix a typo in tcp_delack_timer(), where TCP_WRITE_TIMER_DEFERRED
was used instead of TCP_DELACK_TIMER_DEFERRED.

For consistency, use same socket refcount change for TCP_MTU_REDUCED_DEFERRED,
even if not fired from a timer.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Tested-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c   |    8 +++++---
 net/ipv4/tcp_output.c |   14 +++++++++-----
 net/ipv4/tcp_timer.c  |    6 ++++--
 3 files changed, 18 insertions(+), 10 deletions(-)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7678237..6278a11 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -417,10 +417,12 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 
 		if (code == ICMP_FRAG_NEEDED) { /* PMTU discovery (RFC1191) */
 			tp->mtu_info = info;
-			if (!sock_owned_by_user(sk))
+			if (!sock_owned_by_user(sk)) {
 				tcp_v4_mtu_reduced(sk);
-			else
-				set_bit(TCP_MTU_REDUCED_DEFERRED, &tp->tsq_flags);
+			} else {
+				if (!test_and_set_bit(TCP_MTU_REDUCED_DEFERRED, &tp->tsq_flags))
+					sock_hold(sk);
+			}
 			goto out;
 		}
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 20dfd89..d046326 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -910,14 +910,18 @@ void tcp_release_cb(struct sock *sk)
 	if (flags & (1UL << TCP_TSQ_DEFERRED))
 		tcp_tsq_handler(sk);
 
-	if (flags & (1UL << TCP_WRITE_TIMER_DEFERRED))
+	if (flags & (1UL << TCP_WRITE_TIMER_DEFERRED)) {
 		tcp_write_timer_handler(sk);
-
-	if (flags & (1UL << TCP_DELACK_TIMER_DEFERRED))
+		__sock_put(sk);
+	}
+	if (flags & (1UL << TCP_DELACK_TIMER_DEFERRED)) {
 		tcp_delack_timer_handler(sk);
-
-	if (flags & (1UL << TCP_MTU_REDUCED_DEFERRED))
+		__sock_put(sk);
+	}
+	if (flags & (1UL << TCP_MTU_REDUCED_DEFERRED)) {
 		sk->sk_prot->mtu_reduced(sk);
+		__sock_put(sk);
+	}
 }
 EXPORT_SYMBOL(tcp_release_cb);
 
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 6df36ad..b774a03 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -252,7 +252,8 @@ static void tcp_delack_timer(unsigned long data)
 		inet_csk(sk)->icsk_ack.blocked = 1;
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKLOCKED);
 		/* deleguate our work to tcp_release_cb() */
-		set_bit(TCP_WRITE_TIMER_DEFERRED, &tcp_sk(sk)->tsq_flags);
+		if (!test_and_set_bit(TCP_DELACK_TIMER_DEFERRED, &tcp_sk(sk)->tsq_flags))
+			sock_hold(sk);
 	}
 	bh_unlock_sock(sk);
 	sock_put(sk);
@@ -481,7 +482,8 @@ static void tcp_write_timer(unsigned long data)
 		tcp_write_timer_handler(sk);
 	} else {
 		/* deleguate our work to tcp_release_cb() */
-		set_bit(TCP_WRITE_TIMER_DEFERRED, &tcp_sk(sk)->tsq_flags);
+		if (!test_and_set_bit(TCP_WRITE_TIMER_DEFERRED, &tcp_sk(sk)->tsq_flags))
+			sock_hold(sk);
 	}
 	bh_unlock_sock(sk);
 	sock_put(sk);
