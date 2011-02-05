From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 4/5] enic: Clean up: Remove support for an older
	version of hardware
Date: Fri, 04 Feb 2011 18:17:21 -0800
Message-ID: <20110205021721.8510.62795.stgit@savbu-pc100.cisco.com>
References: <20110205021618.8510.34816.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:25782 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752832Ab1BECRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Feb 2011 21:17:21 -0500
In-Reply-To: <20110205021618.8510.34816.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Remove support for an older version (A1) of hardware

Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic.h      |    3 +-
 drivers/net/enic/enic_dev.c  |   11 --------
 drivers/net/enic/enic_dev.h  |    1 -
 drivers/net/enic/enic_main.c |   56 ++----------------------------------------
 drivers/net/enic/vnic_dev.c  |   19 --------------
 drivers/net/enic/vnic_dev.h  |    8 ------
 drivers/net/enic/vnic_rq.h   |    5 ----
 7 files changed, 4 insertions(+), 99 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 7316267..57fcaee 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.5"
+#define DRV_VERSION		"2.1.1.6"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
@@ -101,7 +101,6 @@ struct enic {
 	/* receive queue cache line section */
 	____cacheline_aligned struct vnic_rq rq[ENIC_RQ_MAX];
 	unsigned int rq_count;
-	int (*rq_alloc_buf)(struct vnic_rq *rq);
 	u64 rq_truncated_pkts;
 	u64 rq_bad_fcs;
 	struct napi_struct napi[ENIC_RQ_MAX];
diff --git a/drivers/net/enic/enic_dev.c b/drivers/net/enic/enic_dev.c
index 3826266..37ad3a1 100644
--- a/drivers/net/enic/enic_dev.c
+++ b/drivers/net/enic/enic_dev.c
@@ -110,17 +110,6 @@ int enic_dev_del_addr(struct enic *enic, u8 *addr)
 	return err;
 }
 
-int enic_dev_hw_version(struct enic *enic, enum vnic_dev_hw_version *hw_ver)
-{
-	int err;
-
-	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_hw_version(enic->vdev, hw_ver);
-	spin_unlock(&enic->devcmd_lock);
-
-	return err;
-}
-
 int enic_dev_notify_unset(struct enic *enic)
 {
 	int err;
diff --git a/drivers/net/enic/enic_dev.h b/drivers/net/enic/enic_dev.h
index 3ac6ba1..495f57f 100644
--- a/drivers/net/enic/enic_dev.h
+++ b/drivers/net/enic/enic_dev.h
@@ -29,7 +29,6 @@ int enic_dev_add_addr(struct enic *enic, u8 *addr);
 int enic_dev_del_addr(struct enic *enic, u8 *addr);
 void enic_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
 void enic_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
-int enic_dev_hw_version(struct enic *enic, enum vnic_dev_hw_version *hw_ver);
 int enic_dev_notify_unset(struct enic *enic);
 int enic_dev_hang_notify(struct enic *enic);
 int enic_dev_set_ig_vlan_rewrite_mode(struct enic *enic);
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index d6cdecc..0c24370 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1348,50 +1348,6 @@ static int enic_rq_alloc_buf(struct vnic_rq *rq)
 	return 0;
 }
 
-static int enic_rq_alloc_buf_a1(struct vnic_rq *rq)
-{
-	struct rq_enet_desc *desc = vnic_rq_next_desc(rq);
-
-	if (vnic_rq_posting_soon(rq)) {
-
-		/* SW workaround for A0 HW erratum: if we're just about
-		 * to write posted_index, insert a dummy desc
-		 * of type resvd
-		 */
-
-		rq_enet_desc_enc(desc, 0, RQ_ENET_TYPE_RESV2, 0);
-		vnic_rq_post(rq, 0, 0, 0, 0);
-	} else {
-		return enic_rq_alloc_buf(rq);
-	}
-
-	return 0;
-}
-
-static int enic_set_rq_alloc_buf(struct enic *enic)
-{
-	enum vnic_dev_hw_version hw_ver;
-	int err;
-
-	err = enic_dev_hw_version(enic, &hw_ver);
-	if (err)
-		return err;
-
-	switch (hw_ver) {
-	case VNIC_DEV_HW_VER_A1:
-		enic->rq_alloc_buf = enic_rq_alloc_buf_a1;
-		break;
-	case VNIC_DEV_HW_VER_A2:
-	case VNIC_DEV_HW_VER_UNKNOWN:
-		enic->rq_alloc_buf = enic_rq_alloc_buf;
-		break;
-	default:
-		return -ENODEV;
-	}
-
-	return 0;
-}
-
 static void enic_rq_indicate_buf(struct vnic_rq *rq,
 	struct cq_desc *cq_desc, struct vnic_rq_buf *buf,
 	int skipped, void *opaque)
@@ -1528,7 +1484,7 @@ static int enic_poll(struct napi_struct *napi, int budget)
 			0 /* don't unmask intr */,
 			0 /* don't reset intr timer */);
 
-	err = vnic_rq_fill(&enic->rq[0], enic->rq_alloc_buf);
+	err = vnic_rq_fill(&enic->rq[0], enic_rq_alloc_buf);
 
 	/* Buffer allocation failed. Stay in polling
 	 * mode so we can try to fill the ring again.
@@ -1578,7 +1534,7 @@ static int enic_poll_msix(struct napi_struct *napi, int budget)
 			0 /* don't unmask intr */,
 			0 /* don't reset intr timer */);
 
-	err = vnic_rq_fill(&enic->rq[rq], enic->rq_alloc_buf);
+	err = vnic_rq_fill(&enic->rq[rq], enic_rq_alloc_buf);
 
 	/* Buffer allocation failed. Stay in polling mode
 	 * so we can try to fill the ring again.
@@ -1781,7 +1737,7 @@ static int enic_open(struct net_device *netdev)
 	}
 
 	for (i = 0; i < enic->rq_count; i++) {
-		vnic_rq_fill(&enic->rq[i], enic->rq_alloc_buf);
+		vnic_rq_fill(&enic->rq[i], enic_rq_alloc_buf);
 		/* Need at least one buffer on ring to get going */
 		if (vnic_rq_desc_used(&enic->rq[i]) == 0) {
 			netdev_err(netdev, "Unable to alloc receive buffers\n");
@@ -2347,12 +2303,6 @@ static int enic_dev_init(struct enic *enic)
 
 	enic_init_vnic_resources(enic);
 
-	err = enic_set_rq_alloc_buf(enic);
-	if (err) {
-		dev_err(dev, "Failed to set RQ buffer allocator, aborting\n");
-		goto err_out_free_vnic_resources;
-	}
-
 	err = enic_set_rss_nic_cfg(enic);
 	if (err) {
 		dev_err(dev, "Failed to config nic, aborting\n");
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index fb35d8b..c489e72 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -419,25 +419,6 @@ int vnic_dev_fw_info(struct vnic_dev *vdev,
 	return err;
 }
 
-int vnic_dev_hw_version(struct vnic_dev *vdev, enum vnic_dev_hw_version *hw_ver)
-{
-	struct vnic_devcmd_fw_info *fw_info;
-	int err;
-
-	err = vnic_dev_fw_info(vdev, &fw_info);
-	if (err)
-		return err;
-
-	if (strncmp(fw_info->hw_version, "A1", sizeof("A1")) == 0)
-		*hw_ver = VNIC_DEV_HW_VER_A1;
-	else if (strncmp(fw_info->hw_version, "A2", sizeof("A2")) == 0)
-		*hw_ver = VNIC_DEV_HW_VER_A2;
-	else
-		*hw_ver = VNIC_DEV_HW_VER_UNKNOWN;
-
-	return 0;
-}
-
 int vnic_dev_spec(struct vnic_dev *vdev, unsigned int offset, unsigned int size,
 	void *value)
 {
diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
index 05f9a24..e837546 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -44,12 +44,6 @@ static inline void writeq(u64 val, void __iomem *reg)
 #undef pr_fmt
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
-enum vnic_dev_hw_version {
-	VNIC_DEV_HW_VER_UNKNOWN,
-	VNIC_DEV_HW_VER_A1,
-	VNIC_DEV_HW_VER_A2,
-};
-
 enum vnic_dev_intr_mode {
 	VNIC_DEV_INTR_MODE_UNKNOWN,
 	VNIC_DEV_INTR_MODE_INTX,
@@ -93,8 +87,6 @@ int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	u64 *a0, u64 *a1, int wait);
 int vnic_dev_fw_info(struct vnic_dev *vdev,
 	struct vnic_devcmd_fw_info **fw_info);
-int vnic_dev_hw_version(struct vnic_dev *vdev,
-	enum vnic_dev_hw_version *hw_ver);
 int vnic_dev_spec(struct vnic_dev *vdev, unsigned int offset, unsigned int size,
 	void *value);
 int vnic_dev_stats_dump(struct vnic_dev *vdev, struct vnic_stats **stats);
diff --git a/drivers/net/enic/vnic_rq.h b/drivers/net/enic/vnic_rq.h
index 37f08de..2056586 100644
--- a/drivers/net/enic/vnic_rq.h
+++ b/drivers/net/enic/vnic_rq.h
@@ -141,11 +141,6 @@ static inline void vnic_rq_post(struct vnic_rq *rq,
 	}
 }
 
-static inline int vnic_rq_posting_soon(struct vnic_rq *rq)
-{
-	return (rq->to_use->index & VNIC_RQ_RETURN_RATE) == 0;
-}
-
 static inline void vnic_rq_return_descs(struct vnic_rq *rq, unsigned int count)
 {
 	rq->ring.desc_avail += count;

