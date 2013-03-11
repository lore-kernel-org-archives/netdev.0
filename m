From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH] netconsole: don't call __netpoll_cleanup() while atomic
Date: Mon, 11 Mar 2013 11:21:48 +0100
Message-ID: <1362997308-5834-1-git-send-email-vfalico@redhat.com>
Cc: amwang@redhat.com, davem@davemloft.net, vfalico@redhat.com,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1775 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751403Ab3CKKVg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Mar 2013 06:21:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__netpoll_cleanup() is called in netconsole_netdev_event() while holding a
spinlock. Release/acquire the spinlock before/after it and restart the
loop. Also, disable the netconsole completely, because we won't have chance
after the restart of the loop, and might end up in a situation where
nt->enabled == 1 and nt->np.dev == NULL.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/netconsole.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 37add21..59ac143 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -666,6 +666,7 @@ static int netconsole_netdev_event(struct notifier_block *this,
 		goto done;
 
 	spin_lock_irqsave(&target_list_lock, flags);
+restart:
 	list_for_each_entry(nt, &target_list, list) {
 		netconsole_target_get(nt);
 		if (nt->np.dev == dev) {
@@ -678,15 +679,17 @@ static int netconsole_netdev_event(struct notifier_block *this,
 			case NETDEV_UNREGISTER:
 				/*
 				 * rtnl_lock already held
+				 * we might sleep in __netpoll_cleanup()
 				 */
-				if (nt->np.dev) {
-					__netpoll_cleanup(&nt->np);
-					dev_put(nt->np.dev);
-					nt->np.dev = NULL;
-				}
+				spin_unlock_irqrestore(&target_list_lock, flags);
+				__netpoll_cleanup(&nt->np);
+				spin_lock_irqsave(&target_list_lock, flags);
+				dev_put(nt->np.dev);
+				nt->np.dev = NULL;
 				nt->enabled = 0;
 				stopped = true;
-				break;
+				netconsole_target_put(nt);
+				goto restart;
 			}
 		}
 		netconsole_target_put(nt);
-- 
1.7.1
