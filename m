From: Yinglin Luan <synmyth@gmail.com>
Subject: [PATCH]rionet: fix NULL pointer dereference in rionet_remove
Date: Sat, 18 Jun 2011 23:27:15 +0800
Message-ID: <1308410839.9175.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mporter@kernel.crashing.org, jj@chaosbits.net,
	cmdkhh@gmail.com, synmyth@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:44140 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752351Ab1FRP1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2011 11:27:23 -0400
Received: by iwn6 with SMTP id 6so146383iwn.19
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2011 08:27:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function rionet_remove initializes local variable 'ndev' to NULL
and do nothing changes before the call to unregister_netdev(ndev),
this could cause a NULL pointer dereference.

Reported-by: Jesper Juhl <jj@chaosbits.net>
Signed-off-by: Yinglin Luan <synmyth@gmail.com>
---
 drivers/net/rionet.c |   28 +++++++++++++++-------------
 1 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index 77c5092..5d3436d 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -378,7 +378,7 @@ static int rionet_close(struct net_device *ndev)
 
 static void rionet_remove(struct rio_dev *rdev)
 {
-	struct net_device *ndev = NULL;
+	struct net_device *ndev = rio_get_drvdata(rdev);
 	struct rionet_peer *peer, *tmp;
 
 	free_pages((unsigned long)rionet_active, rdev->net->hport->sys_size ?
@@ -433,22 +433,12 @@ static const struct net_device_ops
rionet_netdev_ops = {
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
-static int rionet_setup_netdev(struct rio_mport *mport)
+static int rionet_setup_netdev(struct rio_mport *mport, struct
net_device *ndev)
 {
 	int rc = 0;
-	struct net_device *ndev = NULL;
 	struct rionet_private *rnet;
 	u16 device_id;
 
-	/* Allocate our net_device structure */
-	ndev = alloc_etherdev(sizeof(struct rionet_private));
-	if (ndev == NULL) {
-		printk(KERN_INFO "%s: could not allocate ethernet device.\n",
-		       DRV_NAME);
-		rc = -ENOMEM;
-		goto out;
-	}
-
 	rionet_active = (struct rio_dev **)__get_free_pages(GFP_KERNEL,
 			mport->sys_size ? __fls(sizeof(void *)) + 4 : 0);
 	if (!rionet_active) {
@@ -504,11 +494,21 @@ static int rionet_probe(struct rio_dev *rdev,
const struct rio_device_id *id)
 	int rc = -ENODEV;
 	u32 lpef, lsrc_ops, ldst_ops;
 	struct rionet_peer *peer;
+	struct net_device *ndev = NULL;
 
 	/* If local device is not rionet capable, give up quickly */
 	if (!rionet_capable)
 		goto out;
 
+	/* Allocate our net_device structure */
+	ndev = alloc_etherdev(sizeof(struct rionet_private));
+	if (ndev == NULL) {
+		printk(KERN_INFO "%s: could not allocate ethernet device.\n",
+		       DRV_NAME);
+		rc = -ENOMEM;
+		goto out;
+	}
+
 	/*
 	 * First time through, make sure local device is rionet
 	 * capable, setup netdev,  and set flags so this is skipped
@@ -529,7 +529,7 @@ static int rionet_probe(struct rio_dev *rdev, const
struct rio_device_id *id)
 			goto out;
 		}
 
-		rc = rionet_setup_netdev(rdev->net->hport);
+		rc = rionet_setup_netdev(rdev->net->hport, ndev);
 		rionet_check = 1;
 	}
 
@@ -546,6 +546,8 @@ static int rionet_probe(struct rio_dev *rdev, const
struct rio_device_id *id)
 		list_add_tail(&peer->node, &rionet_peers);
 	}
 
+	rio_set_drvdata(rdev, ndev);
+
       out:
 	return rc;
 }
-- 
1.7.5.4

