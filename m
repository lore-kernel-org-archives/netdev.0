From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] net: Move rcu_barrier from rollback_registered_many to netdev_run_todo.
Date: Fri, 14 Oct 2011 01:25:23 -0700
Message-ID: <m1r52g7zf0.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:59381 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646Ab1JNIZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 04:25:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch moves the rcu_barrier from rollback_registered_many
(inside the rtnl_lock) into netdev_run_todo (just outside the rtnl_lock).
This allows us to gain the full benefit of sychronize_net calling
synchronize_rcu_expedited when the rtnl_lock is held.

The rcu_barrier in rollback_registered_many was originally a synchronize_net
but was promoted to be a rcu_barrier() when it was found that people were
unnecessarily hitting the 250ms wait in netdev_wait_allrefs().  Changing
the rcu_barrier back to a synchronize_net is therefore safe.

Since we only care about waiting for the rcu callbacks before we get
to netdev_wait_allrefs() it is also safe to move the wait into
netdev_run_todo.

This was tested by creating and destroying 1000 tap devices and observing
/proc/lock_stat.  /proc/lock_stat reports this change reduces the hold
times of the rtnl_lock by a factor of 10.  There was no observable
difference in the amount of time it takes to destroy a network device.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/dev.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 70ecb86..44dcacf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5235,7 +5235,7 @@ static void rollback_registered_many(struct list_head *head)
 	dev = list_first_entry(head, struct net_device, unreg_list);
 	call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
 
-	rcu_barrier();
+	synchronize_net();
 
 	list_for_each_entry(dev, head, unreg_list)
 		dev_put(dev);
@@ -5748,6 +5748,12 @@ void netdev_run_todo(void)
 
 	__rtnl_unlock();
 
+	/* Wait for rcu callbacks to finish before attempting to drain
+	 * the device list.  This usually avoids a 250ms wait.
+	 */
+	if (!list_empty(&list))
+		rcu_barrier();
+
 	while (!list_empty(&list)) {
 		struct net_device *dev
 			= list_first_entry(&list, struct net_device, todo_list);
-- 
1.7.2.5
