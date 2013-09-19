From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH -net v2 2/2] netconsole: fix a deadlock with rtnl and netconsole's mutex
Date: Thu, 19 Sep 2013 15:02:36 +0200
Message-ID: <1379595756-3527-3-git-send-email-nikolay@redhat.com>
References: <1379595756-3527-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6093 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752033Ab3ISNGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Sep 2013 09:06:12 -0400
In-Reply-To: <1379595756-3527-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This bug was introduced by commit
7a163bfb7ce50895bbe67300ea610d31b9c09230 ("netconsole: avoid a crash with
multiple sysfs writers"). In store_enabled() we have the following
sequence: acquire nt->mutex then rtnl, but in the netconsole netdev
notifier we have rtnl then nt->mutex effectively leading to a deadlock.
The NULL pointer dereference that the above commit tries to fix is
actually due to another bug in netpoll_cleanup(). This is fixed by dropping
the mutex from the netdev notifier as it's already protected by rtnl.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v2: new patch dependent on the fix from patch 01

 drivers/net/netconsole.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index dcb2134..adeee61 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -684,15 +684,12 @@ restart:
 			case NETDEV_RELEASE:
 			case NETDEV_JOIN:
 			case NETDEV_UNREGISTER:
-				/*
-				 * rtnl_lock already held
+				/* rtnl_lock already held
 				 * we might sleep in __netpoll_cleanup()
 				 */
 				spin_unlock_irqrestore(&target_list_lock, flags);
 
-				mutex_lock(&nt->mutex);
 				__netpoll_cleanup(&nt->np);
-				mutex_unlock(&nt->mutex);
 
 				spin_lock_irqsave(&target_list_lock, flags);
 				dev_put(nt->np.dev);
-- 
1.8.1.4
