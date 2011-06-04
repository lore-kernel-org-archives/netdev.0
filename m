From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH] enic: Add support for MTU change via port
	profile on a dynamic vnic
Date: Fri, 03 Jun 2011 17:35:17 -0700
Message-ID: <20110604003517.21165.45654.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:7240 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110Ab1FDAfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 20:35:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

enic driver gets MTU change notifications for MTU changes in the
port profile associated to a dynamic vnic. This patch adds support
in enic driver to set new MTU on the dynamic vnic and dynamically
adjust its buffers with new MTU size in response to such notifications.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 drivers/net/enic/enic.h      |    3 +-
 drivers/net/enic/enic_main.c |   71 +++++++++++++++++++++++++++++++++++++++---
 2 files changed, 68 insertions(+), 6 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 38b351c..e0d2ad1 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.13"
+#define DRV_VERSION		"2.1.1.16"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
@@ -74,6 +74,7 @@ struct enic {
 	struct vnic_dev *vdev;
 	struct timer_list notify_timer;
 	struct work_struct reset;
+	struct work_struct change_mtu_work;
 	struct msix_entry msix_entry[ENIC_INTR_MAX];
 	struct enic_msix_entry msix[ENIC_INTR_MAX];
 	u32 msg_enable;
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 2f433fb..449e3fa 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -423,11 +423,18 @@ static void enic_mtu_check(struct enic *enic)
 
 	if (mtu && mtu != enic->port_mtu) {
 		enic->port_mtu = mtu;
-		if (mtu < netdev->mtu)
-			netdev_warn(netdev,
-				"interface MTU (%d) set higher "
-				"than switch port MTU (%d)\n",
-				netdev->mtu, mtu);
+		if (enic_is_dynamic(enic)) {
+			mtu = max_t(int, ENIC_MIN_MTU,
+				min_t(int, ENIC_MAX_MTU, mtu));
+			if (mtu != netdev->mtu)
+				schedule_work(&enic->change_mtu_work);
+		} else {
+			if (mtu < netdev->mtu)
+				netdev_warn(netdev,
+					"interface MTU (%d) set higher "
+					"than switch port MTU (%d)\n",
+					netdev->mtu, mtu);
+		}
 	}
 }
 
@@ -1688,6 +1695,9 @@ static int enic_change_mtu(struct net_device *netdev, int new_mtu)
 	if (new_mtu < ENIC_MIN_MTU || new_mtu > ENIC_MAX_MTU)
 		return -EINVAL;
 
+	if (enic_is_dynamic(enic))
+		return -EOPNOTSUPP;
+
 	if (running)
 		enic_stop(netdev);
 
@@ -1704,6 +1714,55 @@ static int enic_change_mtu(struct net_device *netdev, int new_mtu)
 	return 0;
 }
 
+static void enic_change_mtu_work(struct work_struct *work)
+{
+	struct enic *enic = container_of(work, struct enic, change_mtu_work);
+	struct net_device *netdev = enic->netdev;
+	int new_mtu = vnic_dev_mtu(enic->vdev);
+	int err;
+	unsigned int i;
+
+	new_mtu = max_t(int, ENIC_MIN_MTU, min_t(int, ENIC_MAX_MTU, new_mtu));
+
+	rtnl_lock();
+
+	/* Stop RQ */
+	del_timer_sync(&enic->notify_timer);
+
+	for (i = 0; i < enic->rq_count; i++)
+		napi_disable(&enic->napi[i]);
+
+	vnic_intr_mask(&enic->intr[0]);
+	enic_synchronize_irqs(enic);
+	err = vnic_rq_disable(&enic->rq[0]);
+	if (err) {
+		netdev_err(netdev, "Unable to disable RQ.\n");
+		return;
+	}
+	vnic_rq_clean(&enic->rq[0], enic_free_rq_buf);
+	vnic_cq_clean(&enic->cq[0]);
+	vnic_intr_clean(&enic->intr[0]);
+
+	/* Fill RQ with new_mtu-sized buffers */
+	netdev->mtu = new_mtu;
+	vnic_rq_fill(&enic->rq[0], enic_rq_alloc_buf);
+	/* Need at least one buffer on ring to get going */
+	if (vnic_rq_desc_used(&enic->rq[0]) == 0) {
+		netdev_err(netdev, "Unable to alloc receive buffers.\n");
+		return;
+	}
+
+	/* Start RQ */
+	vnic_rq_enable(&enic->rq[0]);
+	napi_enable(&enic->napi[0]);
+	vnic_intr_unmask(&enic->intr[0]);
+	enic_notify_timer_start(enic);
+
+	rtnl_unlock();
+
+	netdev_info(netdev, "interface MTU set as %d\n", netdev->mtu);
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void enic_poll_controller(struct net_device *netdev)
 {
@@ -2345,6 +2404,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	enic->notify_timer.data = (unsigned long)enic;
 
 	INIT_WORK(&enic->reset, enic_reset);
+	INIT_WORK(&enic->change_mtu_work, enic_change_mtu_work);
 
 	for (i = 0; i < enic->wq_count; i++)
 		spin_lock_init(&enic->wq_lock[i]);
@@ -2427,6 +2487,7 @@ static void __devexit enic_remove(struct pci_dev *pdev)
 		struct enic *enic = netdev_priv(netdev);
 
 		cancel_work_sync(&enic->reset);
+		cancel_work_sync(&enic->change_mtu_work);
 		unregister_netdev(netdev);
 		enic_dev_deinit(enic);
 		vnic_dev_close(enic->vdev);

