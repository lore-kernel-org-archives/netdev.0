From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 1/6] enic: Bug fix: use safe queue shutdown in
	dev->stop
Date: Wed, 23 Dec 2009 15:27:30 -0800
Message-ID: <20091223232730.19428.73353.stgit@savbu-pc100.cisco.com>
References: <20091223232551.19428.18916.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:6154 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756779AbZLWX1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:27:33 -0500
In-Reply-To: <20091223232551.19428.18916.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

Fix dev->stop shutdown bug where driver was stopping xmit queue and then
disabling intrs.  Fix is to disable intrs first and then stop the xmit
queue, otherwise an interrupt could cause the queue to be rewoken.  Also,
no need to explicitly do queue servicing because queues are cleaned and
reset back to initial state at end of dev->stop.  Servicing queues also
had the side-effect of also rewakening the xmit queue, which is not what
we want.

Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic.h      |    2 +
 drivers/net/enic/enic_main.c |   62 +++++++++++++++++-------------------------
 drivers/net/enic/vnic_intr.h |    1 +
 3 files changed, 27 insertions(+), 38 deletions(-)

diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index e1c2076..8dd0105 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -34,7 +34,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco 10G Ethernet Driver"
-#define DRV_VERSION		"1.1.0.100"
+#define DRV_VERSION		"1.1.0.241a"
 #define DRV_COPYRIGHT		"Copyright 2008-2009 Cisco Systems, Inc"
 #define PFX			DRV_NAME ": "
 
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index f875751..b4a11be 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1084,34 +1084,6 @@ static int enic_rq_service(struct vnic_dev *vdev, struct cq_desc *cq_desc,
 	return 0;
 }
 
-static void enic_rq_drop_buf(struct vnic_rq *rq,
-	struct cq_desc *cq_desc, struct vnic_rq_buf *buf,
-	int skipped, void *opaque)
-{
-	struct enic *enic = vnic_dev_priv(rq->vdev);
-	struct sk_buff *skb = buf->os_buf;
-
-	if (skipped)
-		return;
-
-	pci_unmap_single(enic->pdev, buf->dma_addr,
-		buf->len, PCI_DMA_FROMDEVICE);
-
-	dev_kfree_skb_any(skb);
-}
-
-static int enic_rq_service_drop(struct vnic_dev *vdev, struct cq_desc *cq_desc,
-	u8 type, u16 q_number, u16 completed_index, void *opaque)
-{
-	struct enic *enic = vnic_dev_priv(vdev);
-
-	vnic_rq_service(&enic->rq[q_number], cq_desc,
-		completed_index, VNIC_RQ_RETURN_DESC,
-		enic_rq_drop_buf, opaque);
-
-	return 0;
-}
-
 static int enic_poll(struct napi_struct *napi, int budget)
 {
 	struct enic *enic = container_of(napi, struct enic, napi);
@@ -1304,6 +1276,24 @@ static int enic_request_intr(struct enic *enic)
 	return err;
 }
 
+static void enic_synchronize_irqs(struct enic *enic)
+{
+	unsigned int i;
+
+	switch (vnic_dev_get_intr_mode(enic->vdev)) {
+	case VNIC_DEV_INTR_MODE_INTX:
+	case VNIC_DEV_INTR_MODE_MSI:
+		synchronize_irq(enic->pdev->irq);
+		break;
+	case VNIC_DEV_INTR_MODE_MSIX:
+		for (i = 0; i < enic->intr_count; i++)
+			synchronize_irq(enic->msix_entry[i].vector);
+		break;
+	default:
+		break;
+	}
+}
+
 static int enic_notify_set(struct enic *enic)
 {
 	int err;
@@ -1409,16 +1399,19 @@ static int enic_stop(struct net_device *netdev)
 	unsigned int i;
 	int err;
 
+	for (i = 0; i < enic->intr_count; i++)
+		vnic_intr_mask(&enic->intr[i]);
+
+	enic_synchronize_irqs(enic);
+
 	del_timer_sync(&enic->notify_timer);
 
 	spin_lock(&enic->devcmd_lock);
 	vnic_dev_disable(enic->vdev);
 	spin_unlock(&enic->devcmd_lock);
 	napi_disable(&enic->napi);
-	netif_stop_queue(netdev);
-
-	for (i = 0; i < enic->intr_count; i++)
-		vnic_intr_mask(&enic->intr[i]);
+	netif_carrier_off(netdev);
+	netif_tx_disable(netdev);
 
 	for (i = 0; i < enic->wq_count; i++) {
 		err = vnic_wq_disable(&enic->wq[i]);
@@ -1436,11 +1429,6 @@ static int enic_stop(struct net_device *netdev)
 	spin_unlock(&enic->devcmd_lock);
 	enic_free_intr(enic);
 
-	(void)vnic_cq_service(&enic->cq[ENIC_CQ_RQ],
-		-1, enic_rq_service_drop, NULL);
-	(void)vnic_cq_service(&enic->cq[ENIC_CQ_WQ],
-		-1, enic_wq_service, NULL);
-
 	for (i = 0; i < enic->wq_count; i++)
 		vnic_wq_clean(&enic->wq[i], enic_free_wq_buf);
 	for (i = 0; i < enic->rq_count; i++)
diff --git a/drivers/net/enic/vnic_intr.h b/drivers/net/enic/vnic_intr.h
index 9a53604..f79a722 100644
--- a/drivers/net/enic/vnic_intr.h
+++ b/drivers/net/enic/vnic_intr.h
@@ -61,6 +61,7 @@ static inline void vnic_intr_unmask(struct vnic_intr *intr)
 static inline void vnic_intr_mask(struct vnic_intr *intr)
 {
 	iowrite32(1, &intr->ctrl->mask);
+	(void)ioread32(&intr->ctrl->mask);
 }
 
 static inline void vnic_intr_return_credits(struct vnic_intr *intr,

