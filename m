From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] rionet: fix page allocation order of rionet_active
Date: Fri, 30 Mar 2012 20:01:46 +0900
Message-ID: <1333105306-2601-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Matt Porter <mporter@kernel.crashing.org>,
	Alexandre Bounine <alexandre.bounine@idt.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:37561 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759426Ab2C3LBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 07:01:09 -0400
Received: by pbcun15 with SMTP id un15so1603185pbc.19
        for <netdev@vger.kernel.org>; Fri, 30 Mar 2012 04:01:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rionet_active is allocated from the page allocator and the allocation
order is calculated on the assumption that the page size is 4KB, so it
wastes memory on more than 4K page systems.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Matt Porter <mporter@kernel.crashing.org>
Cc: Alexandre Bounine <alexandre.bounine@idt.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/rionet.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index a57f057..91d2588 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -375,8 +375,8 @@ static void rionet_remove(struct rio_dev *rdev)
 	struct net_device *ndev = rio_get_drvdata(rdev);
 	struct rionet_peer *peer, *tmp;
 
-	free_pages((unsigned long)rionet_active, rdev->net->hport->sys_size ?
-					__fls(sizeof(void *)) + 4 : 0);
+	free_pages((unsigned long)rionet_active, get_order(sizeof(void *) *
+			RIO_MAX_ROUTE_ENTRIES(rdev->net->hport->sys_size)));
 	unregister_netdev(ndev);
 	free_netdev(ndev);
 
@@ -432,15 +432,16 @@ static int rionet_setup_netdev(struct rio_mport *mport, struct net_device *ndev)
 	int rc = 0;
 	struct rionet_private *rnet;
 	u16 device_id;
+	const size_t rionet_active_bytes = sizeof(void *) *
+				RIO_MAX_ROUTE_ENTRIES(mport->sys_size);
 
 	rionet_active = (struct rio_dev **)__get_free_pages(GFP_KERNEL,
-			mport->sys_size ? __fls(sizeof(void *)) + 4 : 0);
+			get_order(rionet_active_bytes));
 	if (!rionet_active) {
 		rc = -ENOMEM;
 		goto out;
 	}
-	memset((void *)rionet_active, 0, sizeof(void *) *
-				RIO_MAX_ROUTE_ENTRIES(mport->sys_size));
+	memset((void *)rionet_active, 0, rionet_active_bytes);
 
 	/* Set up private area */
 	rnet = netdev_priv(ndev);
-- 
1.7.4.4
