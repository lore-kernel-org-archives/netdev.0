From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH next]infiniband: Kill directly reference of netdev->priv
Date: Mon, 24 Nov 2008 17:31:59 +0800
Message-ID: <492A748F.9040308@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>, rolandd@cisco.com,
	sean.hefty@intel.com, hal.rosenstock@gmail.com,
	general@lists.openfabrics.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59367 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751372AbYKXJcM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2008 04:32:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This use of netdev->priv is wrong.
The right way is:
alloc_netdev() with no memory for private data.
make netdev->ml_priv to point to c2_dev.

I am doing this kind of work for net-next tree.
So I send this patch to Dave, although infiniband's maintainer is
not him.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/infiniband/hw/amso1100/c2_provider.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/amso1100/c2_provider.c b/drivers/infiniband/hw/amso1100/c2_provider.c
index 69580e2..5119d65 100644
--- a/drivers/infiniband/hw/amso1100/c2_provider.c
+++ b/drivers/infiniband/hw/amso1100/c2_provider.c
@@ -653,7 +653,7 @@ static int c2_service_destroy(struct iw_cm_id *cm_id)
 static int c2_pseudo_up(struct net_device *netdev)
 {
 	struct in_device *ind;
-	struct c2_dev *c2dev = netdev->priv;
+	struct c2_dev *c2dev = netdev->ml_priv;
 
 	ind = in_dev_get(netdev);
 	if (!ind)
@@ -678,7 +678,7 @@ static int c2_pseudo_up(struct net_device *netdev)
 static int c2_pseudo_down(struct net_device *netdev)
 {
 	struct in_device *ind;
-	struct c2_dev *c2dev = netdev->priv;
+	struct c2_dev *c2dev = netdev->ml_priv;
 
 	ind = in_dev_get(netdev);
 	if (!ind)
@@ -746,14 +746,14 @@ static struct net_device *c2_pseudo_netdev_init(struct c2_dev *c2dev)
 	/* change ethxxx to iwxxx */
 	strcpy(name, "iw");
 	strcat(name, &c2dev->netdev->name[3]);
-	netdev = alloc_netdev(sizeof(*netdev), name, setup);
+	netdev = alloc_netdev(0, name, setup);
 	if (!netdev) {
 		printk(KERN_ERR PFX "%s -  etherdev alloc failed",
 			__func__);
 		return NULL;
 	}
 
-	netdev->priv = c2dev;
+	netdev->ml_priv = c2dev;
 
 	SET_NETDEV_DEV(netdev, &c2dev->pcidev->dev);
 
-- 
1.5.3.4


