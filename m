From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH] cxgb4: remove workqueue when driver registration fails
Date: Fri,  6 Sep 2013 09:32:25 +0800
Message-ID: <1378431145-7203-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: davem@davemloft.net, Wei Yang <weiyang@linux.vnet.ibm.com>
To: dm@chelsio.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp05.au.ibm.com ([202.81.31.147]:49988 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753029Ab3IFBce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 21:32:34 -0400
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Fri, 6 Sep 2013 11:25:05 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 31DAA2BB0057
	for <netdev@vger.kernel.org>; Fri,  6 Sep 2013 11:32:28 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r861WHuq9437638
	for <netdev@vger.kernel.org>; Fri, 6 Sep 2013 11:32:17 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r861WR21003261
	for <netdev@vger.kernel.org>; Fri, 6 Sep 2013 11:32:27 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When driver registration fails, we need to clean up the resources allocated
before. cxgb4 missed to destroy the workqueue allocated at the very beginning.

This patch destroies the workqueue when registration fails.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 5a3256b..1dde5a3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5868,8 +5868,11 @@ static int __init cxgb4_init_module(void)
 		pr_warn("could not create debugfs entry, continuing\n");
 
 	ret = pci_register_driver(&cxgb4_driver);
-	if (ret < 0)
+	if (ret < 0) {
 		debugfs_remove(cxgb4_debugfs_root);
+		destroy_workqueue(workq);
+	}
 	return ret;
 }
 
-- 
1.7.1
