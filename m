From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH] netconsole: release the spinlock before __netpoll_cleanup()
Date: Wed,  6 Mar 2013 15:46:43 +0100
Message-ID: <1362581203-8994-1-git-send-email-vfalico@redhat.com>
Cc: amwang@redhat.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26387 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757218Ab3CFOqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 09:46:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 3335f0ca130c201f8680e97f63612053fbc16e22 removed spinlock unlocking
before __netpoll_cleanup() in netconsole_netdev_event(), however we still
might sleep in __netpoll_cleanup() - via synchronize_srcu(). Revert it and
add a comment.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/netconsole.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 37add21..dd62b4c 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -680,7 +680,17 @@ static int netconsole_netdev_event(struct notifier_block *this,
 				 * rtnl_lock already held
 				 */
 				if (nt->np.dev) {
+					/*
+					 * we still might sleep in
+					 * __netpoll_cleanup(), so release
+					 * the lock
+					 */
+					spin_unlock_irqrestore(
+							      &target_list_lock,
+							      flags);
 					__netpoll_cleanup(&nt->np);
+					spin_lock_irqsave(&target_list_lock,
+							  flags);
 					dev_put(nt->np.dev);
 					nt->np.dev = NULL;
 				}
-- 
1.7.1
