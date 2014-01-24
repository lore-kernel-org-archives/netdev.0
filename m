From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH] net/cxgb4: Fix referencing freed adapter
Date: Fri, 24 Jan 2014 17:12:03 +0800
Message-ID: <1390554723-15285-1-git-send-email-shangw@linux.vnet.ibm.com>
Cc: davem@davemloft.net, Gavin Shan <shangw@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:41533 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750753AbaAXJM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jan 2014 04:12:28 -0500
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <shangw@linux.vnet.ibm.com>;
	Fri, 24 Jan 2014 04:12:27 -0500
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 8759038C8027
	for <netdev@vger.kernel.org>; Fri, 24 Jan 2014 04:12:24 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22035.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0O9COn21507772
	for <netdev@vger.kernel.org>; Fri, 24 Jan 2014 09:12:24 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0O9CNZP023757
	for <netdev@vger.kernel.org>; Fri, 24 Jan 2014 04:12:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The adapter is freed before we check its flags. It was caused
by commit 144be3d ("net/cxgb4: Avoid disabling PCI device for
towice"). The problem was reported by Intel's "0-day" tool.

The patch fixes it to avoid reverting commit 144be3d.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 139a704..43ab35f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -6163,13 +6163,13 @@ static void remove_one(struct pci_dev *pdev)
 		iounmap(adapter->regs);
 		if (!is_t4(adapter->params.chip))
 			iounmap(adapter->bar2);
-		kfree(adapter);
 		pci_disable_pcie_error_reporting(pdev);
 		if ((adapter->flags & DEV_ENABLED)) {
 			pci_disable_device(pdev);
 			adapter->flags &= ~DEV_ENABLED;
 		}
 		pci_release_regions(pdev);
+		kfree(adapter);
 	} else
 		pci_release_regions(pdev);
 }
-- 
1.7.10.4
