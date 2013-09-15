From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH] cxgb4: remove workqueue when driver registration fails
Date: Sun, 15 Sep 2013 21:53:00 +0800
Message-ID: <1379253180-10292-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: davem@davemloft.net, weiyang@linux.vnet.ibm.com
To: dm@chelsio.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp03.au.ibm.com ([202.81.31.145]:53239 "EHLO
	e23smtp03.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932204Ab3IONxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Sep 2013 09:53:09 -0400
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Sun, 15 Sep 2013 23:41:23 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id C80DB3578050
	for <netdev@vger.kernel.org>; Sun, 15 Sep 2013 23:53:04 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8FDaRc310092894
	for <netdev@vger.kernel.org>; Sun, 15 Sep 2013 23:36:27 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8FDr3kk004311
	for <netdev@vger.kernel.org>; Sun, 15 Sep 2013 23:53:04 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When driver registration fails, we need to clean up the resources allocated
before. cxgb4 missed to destroy the workqueue allocated at the very beginning.

This patch destroies the workqueue when registration fails.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 0d0665c..c73cabd 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -6149,8 +6149,10 @@ static int __init cxgb4_init_module(void)
 		pr_warn("could not create debugfs entry, continuing\n");
 
 	ret = pci_register_driver(&cxgb4_driver);
-	if (ret < 0)
+	if (ret < 0) {
 		debugfs_remove(cxgb4_debugfs_root);
+		destroy_workqueue(workq);
+	}
 
 	register_inet6addr_notifier(&cxgb4_inet6addr_notifier);
 
-- 
1.7.1
