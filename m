From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 08/10] tipc: protect tipc_subscrb_get() with subscriber spin lock
Date: Mon, 1 Feb 2016 10:44:41 +0100
Message-ID: <1454319883-16031-9-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1454319883-16031-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
	<maloy@donjonn.com>, <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:43575 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864AbcBAJpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 04:45:21 -0500
In-Reply-To: <1454319883-16031-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Until now, during subscription creation the mod_time() &
tipc_subscrb_get() are called after releasing the subscriber
spin lock.

In a SMP system when performing a subscription creation, if the
subscription timeout occurs simultaneously (the timer is
scheduled to run on another CPU) then the timer thread
might decrement the subscribers refcount before the create
thread increments the refcount.

This can be simulated by creating subscription with timeout=0 and
sometimes the timeout occurs before the create request is complete.
This leads to the following message:
[30.702949] BUG: spinlock bad magic on CPU#1, kworker/u8:3/87
[30.703834] general protection fault: 0000 [#1] SMP
[30.704826] CPU: 1 PID: 87 Comm: kworker/u8:3 Not tainted 4.4.0-rc8+ #18
[30.704826] Workqueue: tipc_rcv tipc_recv_work [tipc]
[30.704826] task: ffff88003f878600 ti: ffff88003fae0000 task.ti: ffff88003fae0000
[30.704826] RIP: 0010:[<ffffffff8109196c>]  [<ffffffff8109196c>] spin_dump+0x5c/0xe0
[...]
[30.704826] Call Trace:
[30.704826]  [<ffffffff81091a16>] spin_bug+0x26/0x30
[30.704826]  [<ffffffff81091b75>] do_raw_spin_lock+0xe5/0x120
[30.704826]  [<ffffffff81684439>] _raw_spin_lock_bh+0x19/0x20
[30.704826]  [<ffffffffa0096f10>] tipc_subscrb_rcv_cb+0x1d0/0x330 [tipc]
[30.704826]  [<ffffffffa00a37b1>] tipc_receive_from_sock+0xc1/0x150 [tipc]
[30.704826]  [<ffffffffa00a31df>] tipc_recv_work+0x3f/0x80 [tipc]
[30.704826]  [<ffffffff8106a739>] process_one_work+0x149/0x3c0
[30.704826]  [<ffffffff8106aa16>] worker_thread+0x66/0x460
[30.704826]  [<ffffffff8106a9b0>] ? process_one_work+0x3c0/0x3c0
[30.704826]  [<ffffffff8106a9b0>] ? process_one_work+0x3c0/0x3c0
[30.704826]  [<ffffffff8107029d>] kthread+0xed/0x110
[30.704826]  [<ffffffff810701b0>] ? kthread_create_on_node+0x190/0x190
[30.704826]  [<ffffffff81684bdf>] ret_from_fork+0x3f/0x70

In this commit,
1. we remove the check for the return code for mod_timer()
2. we protect tipc_subscrb_get() using the subscriber spin lock.
   We increment the subscriber's refcount as soon as we add the
   subscription to subscriber's subscription list.

Acked-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/subscr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index e4ebbc161e42..7d226ecb0490 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -284,13 +284,13 @@ static void tipc_subscrp_subscribe(struct net *net, struct tipc_subscr *s,
 
 	spin_lock_bh(&subscriber->lock);
 	list_add(&sub->subscrp_list, &subscriber->subscrp_list);
+	tipc_subscrb_get(subscriber);
 	sub->subscriber = subscriber;
 	tipc_nametbl_subscribe(sub);
 	spin_unlock_bh(&subscriber->lock);
 
 	timeout = htohl(sub->evt.s.timeout, swap);
-	if (!mod_timer(&sub->timer, jiffies + msecs_to_jiffies(timeout)))
-		tipc_subscrb_get(subscriber);
+	mod_timer(&sub->timer, jiffies + msecs_to_jiffies(timeout));
 }
 
 /* Handle one termination request for the subscriber */
-- 
2.1.4
