From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 11/11] enic: organize device initialization/deinit
	into separate functions
Date: Thu, 03 Sep 2009 20:02:45 -0700
Message-ID: <20090904030245.5047.80150.stgit@palito_client100.nuovasystems.com>
References: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:59828 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932802AbZIDDCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:02:42 -0400
In-Reply-To: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: organize device initialization/deinit into separate functions

To unclutter probe() a little bit, put all device initialization code
in one spot and device deinit code in another spot.  Also remove unused
rq->buf_index variable/func.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic_main.c |  145 ++++++++++++++++++++++++++----------------
 drivers/net/enic/vnic_rq.c   |   27 +++++---
 drivers/net/enic/vnic_rq.h   |   12 +--
 drivers/net/enic/vnic_wq.c   |   20 +++++-
 drivers/net/enic/vnic_wq.h   |    4 +
 5 files changed, 133 insertions(+), 75 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 9368dae..2737c0d 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1740,6 +1740,88 @@ static const struct net_device_ops enic_netdev_ops = {
 #endif
 };
 
+void enic_dev_deinit(struct enic *enic)
+{
+	netif_napi_del(&enic->napi);
+	enic_free_vnic_resources(enic);
+	enic_clear_intr_mode(enic);
+}
+
+int enic_dev_init(struct enic *enic)
+{
+	struct net_device *netdev = enic->netdev;
+	int err;
+
+	/* Get vNIC configuration
+	 */
+
+	err = enic_get_vnic_config(enic);
+	if (err) {
+		printk(KERN_ERR PFX
+			"Get vNIC configuration failed, aborting.\n");
+		return err;
+	}
+
+	/* Get available resource counts
+	 */
+
+	enic_get_res_counts(enic);
+
+	/* Set interrupt mode based on resource counts and system
+	 * capabilities
+	 */
+
+	err = enic_set_intr_mode(enic);
+	if (err) {
+		printk(KERN_ERR PFX
+			"Failed to set intr mode, aborting.\n");
+		return err;
+	}
+
+	/* Allocate and configure vNIC resources
+	 */
+
+	err = enic_alloc_vnic_resources(enic);
+	if (err) {
+		printk(KERN_ERR PFX
+			"Failed to alloc vNIC resources, aborting.\n");
+		goto err_out_free_vnic_resources;
+	}
+
+	enic_init_vnic_resources(enic);
+
+	err = enic_set_rq_alloc_buf(enic);
+	if (err) {
+		printk(KERN_ERR PFX
+			"Failed to set RQ buffer allocator, aborting.\n");
+		goto err_out_free_vnic_resources;
+	}
+
+	err = enic_set_niccfg(enic);
+	if (err) {
+		printk(KERN_ERR PFX
+			"Failed to config nic, aborting.\n");
+		goto err_out_free_vnic_resources;
+	}
+
+	switch (vnic_dev_get_intr_mode(enic->vdev)) {
+	default:
+		netif_napi_add(netdev, &enic->napi, enic_poll, 64);
+		break;
+	case VNIC_DEV_INTR_MODE_MSIX:
+		netif_napi_add(netdev, &enic->napi, enic_poll_msix, 64);
+		break;
+	}
+
+	return 0;
+
+err_out_free_vnic_resources:
+	enic_clear_intr_mode(enic);
+	enic_free_vnic_resources(enic);
+
+	return err;
+}
+
 static void enic_iounmap(struct enic *enic)
 {
 	unsigned int i;
@@ -1882,51 +1964,13 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 		goto err_out_dev_close;
 	}
 
-	/* Get vNIC configuration
-	 */
-
-	err = enic_get_vnic_config(enic);
+	err = enic_dev_init(enic);
 	if (err) {
 		printk(KERN_ERR PFX
-			"Get vNIC configuration failed, aborting.\n");
+			"Device initialization failed, aborting.\n");
 		goto err_out_dev_close;
 	}
 
-	/* Get available resource counts
-	 */
-
-	enic_get_res_counts(enic);
-
-	/* Set interrupt mode based on resource counts and system
-	 * capabilities
-	 */
-
-	err = enic_set_intr_mode(enic);
-	if (err) {
-		printk(KERN_ERR PFX
-			"Failed to set intr mode, aborting.\n");
-		goto err_out_dev_close;
-	}
-
-	/* Allocate and configure vNIC resources
-	 */
-
-	err = enic_alloc_vnic_resources(enic);
-	if (err) {
-		printk(KERN_ERR PFX
-			"Failed to alloc vNIC resources, aborting.\n");
-		goto err_out_free_vnic_resources;
-	}
-
-	enic_init_vnic_resources(enic);
-
-	err = enic_set_niccfg(enic);
-	if (err) {
-		printk(KERN_ERR PFX
-			"Failed to config nic, aborting.\n");
-		goto err_out_free_vnic_resources;
-	}
-
 	/* Setup notification timer, HW reset task, and locks
 	 */
 
@@ -1951,22 +1995,13 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	if (err) {
 		printk(KERN_ERR PFX
 			"Invalid MAC address, aborting.\n");
-		goto err_out_free_vnic_resources;
+		goto err_out_dev_deinit;
 	}
 
 	netdev->netdev_ops = &enic_netdev_ops;
 	netdev->watchdog_timeo = 2 * HZ;
 	netdev->ethtool_ops = &enic_ethtool_ops;
 
-	switch (vnic_dev_get_intr_mode(enic->vdev)) {
-	default:
-		netif_napi_add(netdev, &enic->napi, enic_poll, 64);
-		break;
-	case VNIC_DEV_INTR_MODE_MSIX:
-		netif_napi_add(netdev, &enic->napi, enic_poll_msix, 64);
-		break;
-	}
-
 	netdev->features |= NETIF_F_HW_VLAN_TX |
 		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
 	if (ENIC_SETTING(enic, TXCSUM))
@@ -1994,17 +2029,16 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	if (err) {
 		printk(KERN_ERR PFX
 			"Cannot register net device, aborting.\n");
-		goto err_out_free_vnic_resources;
+		goto err_out_dev_deinit;
 	}
 
 	return 0;
 
-err_out_free_vnic_resources:
-	enic_free_vnic_resources(enic);
+err_out_dev_deinit:
+	enic_dev_deinit(enic);
 err_out_dev_close:
 	vnic_dev_close(enic->vdev);
 err_out_vnic_unregister:
-	enic_clear_intr_mode(enic);
 	vnic_dev_unregister(enic->vdev);
 err_out_iounmap:
 	enic_iounmap(enic);
@@ -2028,9 +2062,8 @@ static void __devexit enic_remove(struct pci_dev *pdev)
 
 		flush_scheduled_work();
 		unregister_netdev(netdev);
-		enic_free_vnic_resources(enic);
+		enic_dev_deinit(enic);
 		vnic_dev_close(enic->vdev);
-		enic_clear_intr_mode(enic);
 		vnic_dev_unregister(enic->vdev);
 		enic_iounmap(enic);
 		pci_release_regions(pdev);
diff --git a/drivers/net/enic/vnic_rq.c b/drivers/net/enic/vnic_rq.c
index 9365e63..7558397 100644
--- a/drivers/net/enic/vnic_rq.c
+++ b/drivers/net/enic/vnic_rq.c
@@ -62,7 +62,6 @@ static int vnic_rq_alloc_bufs(struct vnic_rq *rq)
 	}
 
 	rq->to_use = rq->to_clean = rq->bufs[0];
-	rq->buf_index = 0;
 
 	return 0;
 }
@@ -113,12 +112,12 @@ int vnic_rq_alloc(struct vnic_dev *vdev, struct vnic_rq *rq, unsigned int index,
 	return 0;
 }
 
-void vnic_rq_init(struct vnic_rq *rq, unsigned int cq_index,
+void vnic_rq_init_start(struct vnic_rq *rq, unsigned int cq_index,
+	unsigned int fetch_index, unsigned int posted_index,
 	unsigned int error_interrupt_enable,
 	unsigned int error_interrupt_offset)
 {
 	u64 paddr;
-	u32 fetch_index;
 
 	paddr = (u64)rq->ring.base_addr | VNIC_PADDR_TARGET;
 	writeq(paddr, &rq->ctrl->ring_base);
@@ -128,15 +127,27 @@ void vnic_rq_init(struct vnic_rq *rq, unsigned int cq_index,
 	iowrite32(error_interrupt_offset, &rq->ctrl->error_interrupt_offset);
 	iowrite32(0, &rq->ctrl->dropped_packet_count);
 	iowrite32(0, &rq->ctrl->error_status);
+	iowrite32(fetch_index, &rq->ctrl->fetch_index);
+	iowrite32(posted_index, &rq->ctrl->posted_index);
 
-	/* Use current fetch_index as the ring starting point */
-	fetch_index = ioread32(&rq->ctrl->fetch_index);
 	rq->to_use = rq->to_clean =
 		&rq->bufs[fetch_index / VNIC_RQ_BUF_BLK_ENTRIES]
 			[fetch_index % VNIC_RQ_BUF_BLK_ENTRIES];
-	iowrite32(fetch_index, &rq->ctrl->posted_index);
+}
+
+void vnic_rq_init(struct vnic_rq *rq, unsigned int cq_index,
+	unsigned int error_interrupt_enable,
+	unsigned int error_interrupt_offset)
+{
+	u32 fetch_index;
 
-	rq->buf_index = 0;
+	/* Use current fetch_index as the ring starting point */
+	fetch_index = ioread32(&rq->ctrl->fetch_index);
+
+	vnic_rq_init_start(rq, cq_index,
+		fetch_index, fetch_index,
+		error_interrupt_enable,
+		error_interrupt_offset);
 }
 
 unsigned int vnic_rq_error_status(struct vnic_rq *rq)
@@ -192,8 +203,6 @@ void vnic_rq_clean(struct vnic_rq *rq,
 			[fetch_index % VNIC_RQ_BUF_BLK_ENTRIES];
 	iowrite32(fetch_index, &rq->ctrl->posted_index);
 
-	rq->buf_index = 0;
-
 	vnic_dev_clear_desc_ring(&rq->ring);
 }
 
diff --git a/drivers/net/enic/vnic_rq.h b/drivers/net/enic/vnic_rq.h
index f7b5730..35e736c 100644
--- a/drivers/net/enic/vnic_rq.h
+++ b/drivers/net/enic/vnic_rq.h
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008, 2009 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
@@ -79,7 +79,6 @@ struct vnic_rq {
 	struct vnic_rq_buf *to_use;
 	struct vnic_rq_buf *to_clean;
 	void *os_buf_head;
-	unsigned int buf_index;
 	unsigned int pkts_outstanding;
 };
 
@@ -105,11 +104,6 @@ static inline unsigned int vnic_rq_next_index(struct vnic_rq *rq)
 	return rq->to_use->index;
 }
 
-static inline unsigned int vnic_rq_next_buf_index(struct vnic_rq *rq)
-{
-	return rq->buf_index++;
-}
-
 static inline void vnic_rq_post(struct vnic_rq *rq,
 	void *os_buf, unsigned int os_buf_index,
 	dma_addr_t dma_addr, unsigned int len)
@@ -204,6 +198,10 @@ static inline int vnic_rq_fill(struct vnic_rq *rq,
 void vnic_rq_free(struct vnic_rq *rq);
 int vnic_rq_alloc(struct vnic_dev *vdev, struct vnic_rq *rq, unsigned int index,
 	unsigned int desc_count, unsigned int desc_size);
+void vnic_rq_init_start(struct vnic_rq *rq, unsigned int cq_index,
+	unsigned int fetch_index, unsigned int posted_index,
+	unsigned int error_interrupt_enable,
+	unsigned int error_interrupt_offset);
 void vnic_rq_init(struct vnic_rq *rq, unsigned int cq_index,
 	unsigned int error_interrupt_enable,
 	unsigned int error_interrupt_offset);
diff --git a/drivers/net/enic/vnic_wq.c b/drivers/net/enic/vnic_wq.c
index a576d04..d2e00e5 100644
--- a/drivers/net/enic/vnic_wq.c
+++ b/drivers/net/enic/vnic_wq.c
@@ -112,7 +112,8 @@ int vnic_wq_alloc(struct vnic_dev *vdev, struct vnic_wq *wq, unsigned int index,
 	return 0;
 }
 
-void vnic_wq_init(struct vnic_wq *wq, unsigned int cq_index,
+void vnic_wq_init_start(struct vnic_wq *wq, unsigned int cq_index,
+	unsigned int fetch_index, unsigned int posted_index,
 	unsigned int error_interrupt_enable,
 	unsigned int error_interrupt_offset)
 {
@@ -121,12 +122,25 @@ void vnic_wq_init(struct vnic_wq *wq, unsigned int cq_index,
 	paddr = (u64)wq->ring.base_addr | VNIC_PADDR_TARGET;
 	writeq(paddr, &wq->ctrl->ring_base);
 	iowrite32(wq->ring.desc_count, &wq->ctrl->ring_size);
-	iowrite32(0, &wq->ctrl->fetch_index);
-	iowrite32(0, &wq->ctrl->posted_index);
+	iowrite32(fetch_index, &wq->ctrl->fetch_index);
+	iowrite32(posted_index, &wq->ctrl->posted_index);
 	iowrite32(cq_index, &wq->ctrl->cq_index);
 	iowrite32(error_interrupt_enable, &wq->ctrl->error_interrupt_enable);
 	iowrite32(error_interrupt_offset, &wq->ctrl->error_interrupt_offset);
 	iowrite32(0, &wq->ctrl->error_status);
+
+	wq->to_use = wq->to_clean =
+		&wq->bufs[fetch_index / VNIC_WQ_BUF_BLK_ENTRIES]
+			[fetch_index % VNIC_WQ_BUF_BLK_ENTRIES];
+}
+
+void vnic_wq_init(struct vnic_wq *wq, unsigned int cq_index,
+	unsigned int error_interrupt_enable,
+	unsigned int error_interrupt_offset)
+{
+	vnic_wq_init_start(wq, cq_index, 0, 0,
+		error_interrupt_enable,
+		error_interrupt_offset);
 }
 
 unsigned int vnic_wq_error_status(struct vnic_wq *wq)
diff --git a/drivers/net/enic/vnic_wq.h b/drivers/net/enic/vnic_wq.h
index c826137..9c34d41 100644
--- a/drivers/net/enic/vnic_wq.h
+++ b/drivers/net/enic/vnic_wq.h
@@ -149,6 +149,10 @@ static inline void vnic_wq_service(struct vnic_wq *wq,
 void vnic_wq_free(struct vnic_wq *wq);
 int vnic_wq_alloc(struct vnic_dev *vdev, struct vnic_wq *wq, unsigned int index,
 	unsigned int desc_count, unsigned int desc_size);
+void vnic_wq_init_start(struct vnic_wq *wq, unsigned int cq_index,
+	unsigned int fetch_index, unsigned int posted_index,
+	unsigned int error_interrupt_enable,
+	unsigned int error_interrupt_offset);
 void vnic_wq_init(struct vnic_wq *wq, unsigned int cq_index,
 	unsigned int error_interrupt_enable,
 	unsigned int error_interrupt_offset);

