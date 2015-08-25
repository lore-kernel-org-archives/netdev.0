From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next] enic: reduce ioread in devcmd2
Date: Tue, 25 Aug 2015 13:49:55 +0530
Message-ID: <1440490795-6888-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:57396 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752371AbbHYIUa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 04:20:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

posted_index is RO in firmware. We need not do ioread everytime to get
posted index. Store posted index locally.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/vnic_dev.c | 8 +++++---
 drivers/net/ethernet/cisco/enic/vnic_wq.h  | 1 +
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index 19a49a6..a5fc073 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -301,12 +301,12 @@ static int _vnic_dev_cmd2(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	struct devcmd2_result *result = dc2c->result + dc2c->next_result;
 	unsigned int i;
 	int delay, err;
-	u32 fetch_index, posted, new_posted;
+	u32 fetch_index, new_posted;
+	u32 posted = dc2c->posted;
 
-	posted = ioread32(&dc2c->wq_ctrl->posted_index);
 	fetch_index = ioread32(&dc2c->wq_ctrl->fetch_index);
 
-	if (posted == 0xFFFFFFFF || fetch_index == 0xFFFFFFFF)
+	if (fetch_index == 0xFFFFFFFF)
 		return -ENODEV;
 
 	new_posted = (posted + 1) % DEVCMD2_RING_SIZE;
@@ -331,6 +331,7 @@ static int _vnic_dev_cmd2(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	 */
 	wmb();
 	iowrite32(new_posted, &dc2c->wq_ctrl->posted_index);
+	dc2c->posted = new_posted;
 
 	if (dc2c->cmd_ring[posted].flags & DEVCMD2_FNORESULT)
 		return 0;
@@ -402,6 +403,7 @@ static int vnic_dev_init_devcmd2(struct vnic_dev *vdev)
 
 	enic_wq_init_start(&vdev->devcmd2->wq, 0, fetch_index, fetch_index, 0,
 			   0);
+	dc2c->posted = fetch_index;
 	vnic_wq_enable(&vdev->devcmd2->wq);
 
 	err = vnic_dev_alloc_desc_ring(vdev, &vdev->devcmd2->results_ring,
diff --git a/drivers/net/ethernet/cisco/enic/vnic_wq.h b/drivers/net/ethernet/cisco/enic/vnic_wq.h
index 8944af9..0120961 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_wq.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_wq.h
@@ -97,6 +97,7 @@ struct devcmd2_controller {
 	int color;
 	struct vnic_dev_ring results_ring;
 	struct vnic_wq wq;
+	u32 posted;
 };
 
 static inline unsigned int vnic_wq_desc_avail(struct vnic_wq *wq)
-- 
2.5.0
