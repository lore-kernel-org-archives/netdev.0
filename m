From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv4 BUG: held lock freed!
Date: Sun, 19 Aug 2012 14:51:22 +0200
Message-ID: <1345380682.5158.201.camel@edumazet-glaptop>
References: <20120818021918.GA6499@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	networking <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120818021918.GA6499@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-08-18 at 10:19 +0800, Fengguang Wu wrote:
> Hi David,
> 
> The bug should be introduced somewhere between 3.5 and 3.6-rc1.
> 
> [ 2866.131281] IPv4: Attempt to release TCP socket in state 1 ffff880019ec0000
> [ 2866.131726] 
> [ 2866.132188] =========================
> [ 2866.132281] [ BUG: held lock freed! ]
> [ 2866.132281] 3.6.0-rc1+ #622 Not tainted
> [ 2866.132281] -------------------------
> [ 2866.132281] kworker/0:1/652 is freeing memory ffff880019ec0000-ffff880019ec0a1f, with a lock still held there!
> [ 2866.132281]  (sk_lock-AF_INET-RPC){+.+...}, at: [<ffffffff81903619>] tcp_sendmsg+0x29/0xcc6
> [ 2866.132281] 4 locks held by kworker/0:1/652:
> [ 2866.132281]  #0:  (rpciod){.+.+.+}, at: [<ffffffff81083567>] process_one_work+0x1de/0x47f
> [ 2866.132281]  #1:  ((&task->u.tk_work)){+.+.+.}, at: [<ffffffff81083567>] process_one_work+0x1de/0x47f
> [ 2866.132281]  #2:  (sk_lock-AF_INET-RPC){+.+...}, at: [<ffffffff81903619>] tcp_sendmsg+0x29/0xcc6
> [ 2866.132281]  #3:  (&icsk->icsk_retransmit_timer){+.-...}, at: [<ffffffff81078017>] run_timer_softirq+0x1ad/0x35f
> [ 2866.132281] 
> [ 2866.132281] stack backtrace:
> [ 2866.132281] Pid: 652, comm: kworker/0:1 Not tainted 3.6.0-rc1+ #622
> [ 2866.132281] Call Trace:
> [ 2866.132281]  <IRQ>  [<ffffffff810bc527>] debug_check_no_locks_freed+0x112/0x159
> [ 2866.132281]  [<ffffffff818a0839>] ? __sk_free+0xfd/0x114
> [ 2866.132281]  [<ffffffff811549fa>] kmem_cache_free+0x6b/0x13a
> [ 2866.132281]  [<ffffffff818a0839>] __sk_free+0xfd/0x114
> [ 2866.132281]  [<ffffffff818a08c0>] sk_free+0x1c/0x1e
> [ 2866.132281]  [<ffffffff81911e1c>] tcp_write_timer+0x51/0x56
> [ 2866.132281]  [<ffffffff81078082>] run_timer_softirq+0x218/0x35f
> [ 2866.132281]  [<ffffffff81078017>] ? run_timer_softirq+0x1ad/0x35f
> [ 2866.132281]  [<ffffffff810f5831>] ? rb_commit+0x58/0x85
> [ 2866.132281]  [<ffffffff81911dcb>] ? tcp_write_timer_handler+0x148/0x148
> [ 2866.132281]  [<ffffffff81070bd6>] __do_softirq+0xcb/0x1f9
> [ 2866.132281]  [<ffffffff81a0a00c>] ? _raw_spin_unlock+0x29/0x2e
> [ 2866.132281]  [<ffffffff81a1227c>] call_softirq+0x1c/0x30
> [ 2866.132281]  [<ffffffff81039f38>] do_softirq+0x4a/0xa6
> [ 2866.132281]  [<ffffffff81070f2b>] irq_exit+0x51/0xad
> [ 2866.132281]  [<ffffffff81a129cd>] do_IRQ+0x9d/0xb4
> [ 2866.132281]  [<ffffffff81a0a3ef>] common_interrupt+0x6f/0x6f
> [ 2866.132281]  <EOI>  [<ffffffff8109d006>] ? sched_clock_cpu+0x58/0xd1
> [ 2866.132281]  [<ffffffff81a0a172>] ? _raw_spin_unlock_irqrestore+0x4c/0x56
> [ 2866.132281]  [<ffffffff81078692>] mod_timer+0x178/0x1a9
> [ 2866.132281]  [<ffffffff818a00aa>] sk_reset_timer+0x19/0x26
> [ 2866.132281]  [<ffffffff8190b2cc>] tcp_rearm_rto+0x99/0xa4
> [ 2866.132281]  [<ffffffff8190dfba>] tcp_event_new_data_sent+0x6e/0x70
> [ 2866.132281]  [<ffffffff8190f7ea>] tcp_write_xmit+0x7de/0x8e4
> [ 2866.132281]  [<ffffffff818a565d>] ? __alloc_skb+0xa0/0x1a1
> [ 2866.132281]  [<ffffffff8190f952>] __tcp_push_pending_frames+0x2e/0x8a
> [ 2866.132281]  [<ffffffff81904122>] tcp_sendmsg+0xb32/0xcc6
> [ 2866.132281]  [<ffffffff819229c2>] inet_sendmsg+0xaa/0xd5
> [ 2866.132281]  [<ffffffff81922918>] ? inet_autobind+0x5f/0x5f
> [ 2866.132281]  [<ffffffff810ee7f1>] ? trace_clock_local+0x9/0xb
> [ 2866.132281]  [<ffffffff8189adab>] sock_sendmsg+0xa3/0xc4
> [ 2866.132281]  [<ffffffff810f5de6>] ? rb_reserve_next_event+0x26f/0x2d5
> [ 2866.132281]  [<ffffffff8103e6a9>] ? native_sched_clock+0x29/0x6f
> [ 2866.132281]  [<ffffffff8103e6f8>] ? sched_clock+0x9/0xd
> [ 2866.132281]  [<ffffffff810ee7f1>] ? trace_clock_local+0x9/0xb
> [ 2866.132281]  [<ffffffff8189ae03>] kernel_sendmsg+0x37/0x43
> [ 2866.132281]  [<ffffffff8199ce49>] xs_send_kvec+0x77/0x80
> [ 2866.132281]  [<ffffffff8199cec1>] xs_sendpages+0x6f/0x1a0
> [ 2866.132281]  [<ffffffff8107826d>] ? try_to_del_timer_sync+0x55/0x61
> [ 2866.132281]  [<ffffffff8199d0d2>] xs_tcp_send_request+0x55/0xf1
> [ 2866.132281]  [<ffffffff8199bb90>] xprt_transmit+0x89/0x1db
> [ 2866.132281]  [<ffffffff81999bcd>] ? call_connect+0x3c/0x3c
> [ 2866.132281]  [<ffffffff81999d92>] call_transmit+0x1c5/0x20e
> [ 2866.132281]  [<ffffffff819a0d55>] __rpc_execute+0x6f/0x225
> [ 2866.132281]  [<ffffffff81999bcd>] ? call_connect+0x3c/0x3c
> [ 2866.132281]  [<ffffffff819a0f33>] rpc_async_schedule+0x28/0x34
> [ 2866.132281]  [<ffffffff810835d6>] process_one_work+0x24d/0x47f
> [ 2866.132281]  [<ffffffff81083567>] ? process_one_work+0x1de/0x47f
> [ 2866.132281]  [<ffffffff819a0f0b>] ? __rpc_execute+0x225/0x225
> [ 2866.132281]  [<ffffffff81083a6d>] worker_thread+0x236/0x317
> [ 2866.132281]  [<ffffffff81083837>] ? process_scheduled_works+0x2f/0x2f
> [ 2866.132281]  [<ffffffff8108b7b8>] kthread+0x9a/0xa2
> [ 2866.132281]  [<ffffffff81a12184>] kernel_thread_helper+0x4/0x10
> [ 2866.132281]  [<ffffffff81a0a4b0>] ? retint_restore_args+0x13/0x13
> [ 2866.132281]  [<ffffffff8108b71e>] ? __init_kthread_worker+0x5a/0x5a
> [ 2866.132281]  [<ffffffff81a12180>] ? gs_change+0x13/0x13
> [ 2866.308506] IPv4: Attempt to release TCP socket in state 1 ffff880019ec0000
> [ 2866.309689] =============================================================================
> [ 2866.310254] BUG TCP (Not tainted): Object already free
> [ 2866.310254] -----------------------------------------------------------------------------
> [ 2866.310254] 
> 
> This happens only in one of my test boxes and is rather hard to
> reproduce. I find that it could only happen once out of 100 boots,
> each boot test takes 1.5 hour. It's basically an NFSROOT system that
> runs a bunch of IO and MM tests.
> 
> I've been running auto+manual bisects for one week and it has failed
> several times.  Here is the log for last try. It reports 0bb4087 as
> the first bad commit, however the bug still shows up when reverting
> 0bb4087 on top of 3.6-rc2. So the 'good' commits in the below log may
> not really be good. The 'bad' commits, however, are bad for sure.
> 
> wfg@bee ~/linux% git bisect log
> # bad: [0d7614f09c1ebdbaa1599a5aba7593f147bf96ee] Linux 3.6-rc1
> # good: [28a33cbc24e4256c143dce96c7d93bf423229f92] Linux 3.5
> git bisect start 'v3.6-rc1' 'v3.5' '--'
> # bad: [614a6d4341b3760ca98a1c2c09141b71db5d1e90] Merge branch 'for-3.6' of git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup
> git bisect bad 614a6d4341b3760ca98a1c2c09141b71db5d1e90
> # bad: [320f5ea0cedc08ef65d67e056bcb9d181386ef2c] genetlink: define lockdep_genl_is_held() when CONFIG_LOCKDEP
> git bisect bad 320f5ea0cedc08ef65d67e056bcb9d181386ef2c
> # skip: [dbfa600148a25903976910863c75dae185f8d187] cxgb3: set maximal number of default RSS queues
> git bisect skip dbfa600148a25903976910863c75dae185f8d187
> # bad: [b6dfd939fdc249fcf8cd7b8006f76239b33eb581] ixgbe: add support for new 82599 device
> git bisect bad b6dfd939fdc249fcf8cd7b8006f76239b33eb581
> # bad: [39cb681b3bb4da17e74d48e553d1bb9a1b759aa5] ixgbe: Fix handling of FDIR_HASH flag
> git bisect bad 39cb681b3bb4da17e74d48e553d1bb9a1b759aa5
> # bad: [9297127b9cdd8d30c829ef5fd28b7cc0323a7bcd] ixgbe: Change how we check for pre-existing and assigned VFs
> git bisect bad 9297127b9cdd8d30c829ef5fd28b7cc0323a7bcd
> # bad: [99d744875d01d57d832b8dbfc36d9a1990d503b8] ixgbe: Drop probe_vf and merge functionality into ixgbe_enable_sriov
> git bisect bad 99d744875d01d57d832b8dbfc36d9a1990d503b8
> # bad: [186e868786f97c8026f0a81400b451ace306b3a4] forcedeth: spin_unlock_irq in interrupt handler fix
> git bisect bad 186e868786f97c8026f0a81400b451ace306b3a4
> # good: [3e4b9459fb0e149c6b74c9e89399a8fc39a92b44] Merge tag 'md-3.5-fixes' of git://neil.brown.name/md
> git bisect good 3e4b9459fb0e149c6b74c9e89399a8fc39a92b44
> # good: [e8c7b335faca2cbce715da3b0e1663d75d422f5b] wlcore: increase command completion timeout
> git bisect good e8c7b335faca2cbce715da3b0e1663d75d422f5b
> # good: [1d248b1cf4e09dbec8cef5f7fbeda5874248bd09] net: Pass neighbours and dest address into NETEVENT_REDIRECT events.
> git bisect good 1d248b1cf4e09dbec8cef5f7fbeda5874248bd09
> # good: [73dea3983a9d2e413e1c065ed4e132a7d4127929] be2net: Add description about various RSS hash types
> git bisect good 73dea3983a9d2e413e1c065ed4e132a7d4127929
> # good: [8b0d2f9ed3d8e92feada7c5d70fa85be46e6f948] net: e100: ucode is optional in some cases
> git bisect good 8b0d2f9ed3d8e92feada7c5d70fa85be46e6f948
> # good: [36eb22e97a2b621fb707eead58ef915ab0f46e9e] libertas: firmware.c: remove duplicated include
> git bisect good 36eb22e97a2b621fb707eead58ef915ab0f46e9e
> # good: [5815d5e7aae3cc9c5e85af83094d4d6498c3f4fc] tcp: use hash_32() in tcp_metrics
> git bisect good 5815d5e7aae3cc9c5e85af83094d4d6498c3f4fc
> # good: [e4bce0f288bafd8505ba5ce9c5284a4478f1b725] Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
> git bisect good e4bce0f288bafd8505ba5ce9c5284a4478f1b725
> # good: [a1b5d0dd28e9cb4fe42ad2df4ebbe5cce96866d7] openvswitch: Check gso_type for correct sk_buff in queue_gso_packets().
> git bisect good a1b5d0dd28e9cb4fe42ad2df4ebbe5cce96866d7
> # bad: [0bb4087] ipv4: Fix neigh lookup keying over loopback/point-to-point devices.
> git bisect bad 0bb4087
> # good: [b09e786bd1dd66418b69348cb110f3a64764626a] tun: fix a crash bug and a memory leak
> git bisect good b09e786bd1dd66418b69348cb110f3a64764626a
> # good: [fa0afcd10951afad2022dda09777d2bf70cdab3d] atl1c: fix issue of io access mode for AR8152 v2.1
> git bisect good fa0afcd10951afad2022dda09777d2bf70cdab3d
> 
> Thanks,
> Fengguang

Hi Fengguang, thanks for this report.

Hmm, this looks like sk_reset_timer() is called on a socket, and timer
triggers _before_ the sock_hold()

So the timer handler decrements sk_refcnt to 0 and calls sk_free()

Its probably a bug introduced (or uncovered) by commit 6f458dfb40 (tcp:
improve latencies of timer triggered events)

I always found sk_reset_timer() a bit racy...

void sk_reset_timer(struct sock *sk, struct timer_list* timer,
                    unsigned long expires)
{
	if (!mod_timer(timer, expires))
		sock_hold(sk); // MIGHT BE TOO LATE
}

Following should be safer...

void sk_reset_timer(struct sock *sk, struct timer_list* timer,
                    unsigned long expires)
{
	sock_hold(sk);
	if (mod_timer(timer, expires))
		sock_put(sk);
}

Could you test following patch ?

By the way, there is a typo in tcp_delack_timer()
(should use TCP_DELACK_TIMER_DEFERRED instead of
TCP_WRITE_TIMER_DEFERRED)


Thanks !

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
