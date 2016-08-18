From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: [RFC PATCH] net/irda: release sock when waiting in accept()
Date: Thu, 18 Aug 2016 17:30:29 +0200
Message-ID: <1471534229-6771-1-git-send-email-vegard.nossum@oracle.com>
Cc: irda-users@lists.sourceforge.net, netdev@vger.kernel.org,
        Vegard Nossum <vegard.nossum@oracle.com>
To: Samuel Ortiz <samuel@sortiz.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:26029 "EHLO
        aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754065AbcHSBGC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:06:02 -0400
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
        by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u7IFVDNQ014041
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 15:31:14 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been seeing these recently:

    INFO: task trinity-c3:14933 blocked for more than 120 seconds.
	  Not tainted 4.8.0-rc1+ #135
    "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
    trinity-c3      D ffff88010c16fc88     0 14933      1 0x00080004
     ffff88010c16fc88 000000003b9aca00 0000000000000000 0000000000000296
     00000000776cdf88 ffff88011a520ae0 ffff88011a520b08 ffff88011a520198
     ffffffff867d7f00 ffff88011942c080 ffff880116841580 ffff88010c168000
    Call Trace:
     [<ffffffff845e9d37>] schedule+0x77/0x230
     [<ffffffff833cb8b9>] __lock_sock+0x129/0x250
     [<ffffffff833cb790>] ? __sk_destruct+0x450/0x450
     [<ffffffff81408ac0>] ? wake_bit_function+0x2e0/0x2e0
     [<ffffffff833d832b>] lock_sock_nested+0xeb/0x120
     [<ffffffff83bad815>] irda_setsockopt+0x65/0xb40
     [<ffffffff833c6c09>] SyS_setsockopt+0x139/0x230
     [<ffffffff833c6ad0>] ? SyS_recv+0x20/0x20
     [<ffffffff81004660>] ? trace_event_raw_event_sys_enter+0xb90/0xb90
     [<ffffffff823c7023>] ? __this_cpu_preempt_check+0x13/0x20
     [<ffffffff8162ee60>] ? __context_tracking_exit.part.3+0x30/0x1b0
     [<ffffffff833c6ad0>] ? SyS_recv+0x20/0x20
     [<ffffffff81007bd3>] do_syscall_64+0x1b3/0x4b0
     [<ffffffff845f84aa>] entry_SYSCALL64_slow_path+0x25/0x25

    Showing all locks held in the system:
    2 locks held by khungtaskd/563:
     #0:  (rcu_read_lock){......}, at: [<ffffffff81534ce6>] watchdog+0x106/0x910
     #1:  (tasklist_lock){......}, at: [<ffffffff8141b3c4>] debug_show_all_locks+0x74/0x360
    1 lock held by trinity-c0/19280:
     #0:  (sk_lock-AF_IRDA){......}, at: [<ffffffff83bab7c6>] irda_accept+0x176/0x10f0
    1 lock held by trinity-c0/12865:
     #0:  (sk_lock-AF_IRDA){......}, at: [<ffffffff83bab7c6>] irda_accept+0x176/0x10f0

The problem seems to be that irda_accept() goes to sleep after locking
the socket, which means that others trying to get the lock will be
"blocked for more than 120 seconds" like above.

There are unfortunately other places in the irda code that seem to be
doing the same thing: irda_connect(), irda_sendmsg(), and
irda_getsockopt() as far as I can tell at a glance. I'll start with
this patch to see if we're going in the right direction -- it does fix
the trinity problem for me, although I haven't tested any real IrDA
workloads.

Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
---
 net/irda/af_irda.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 8d2f7c9..334836a 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -871,6 +871,8 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 	 * Jean II
 	 */
 	while (1) {
+		DEFINE_WAIT(wait);
+
 		skb = skb_dequeue(&sk->sk_receive_queue);
 		if (skb)
 			break;
@@ -880,10 +882,17 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 		if (flags & O_NONBLOCK)
 			goto out;
 
-		err = wait_event_interruptible(*(sk_sleep(sk)),
-					skb_peek(&sk->sk_receive_queue));
-		if (err)
+		if (signal_pending(current)) {
+			err = -EINTR;
 			goto out;
+		}
+
+		prepare_to_wait_exclusive(sk_sleep(sk), &wait,
+			TASK_INTERRUPTIBLE);
+		release_sock(sk);
+		schedule();
+		lock_sock(sk);
+		finish_wait(sk_sleep(sk), &wait);
 	}
 
 	newsk = newsock->sk;
-- 
1.9.1
