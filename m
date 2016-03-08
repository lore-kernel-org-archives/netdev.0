From: Joe Perches <joe@perches.com>
Subject: [PATCH] cisco: enic: Update logging macros and uses
Date: Tue,  8 Mar 2016 13:54:56 -0800
Message-ID: <fd7e962bc72778fc1f2a9b21742eff2eb19d9bd8.1457474066.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christian Benvenuti <benve@cisco.com>,
	Sujith Sankar <ssujith@cisco.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Neel Patel <neepatel@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0146.hostedemail.com ([216.40.44.146]:34162 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750765AbcCHVzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 16:55:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't hide varibles used by the logging macros.

Miscellanea:

o Use the more common ##__VA_ARGS__ extension
o Add missing newlines to formats
o Realign arguments

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      | 22 ++++++++------
 drivers/net/ethernet/cisco/enic/vnic_cq.c   |  2 +-
 drivers/net/ethernet/cisco/enic/vnic_dev.c  | 45 +++++++++++++++--------------
 drivers/net/ethernet/cisco/enic/vnic_intr.c |  3 +-
 drivers/net/ethernet/cisco/enic/vnic_rq.c   |  4 +--
 drivers/net/ethernet/cisco/enic/vnic_wq.c   |  4 +--
 6 files changed, 43 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 7ba6d53..130f910 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -201,16 +201,20 @@ static inline struct net_device *vnic_get_netdev(struct vnic_dev *vdev)
 }
 
 /* wrappers function for kernel log
- * Make sure variable vdev of struct vnic_dev is available in the block where
- * these macros are used
  */
-#define vdev_info(args...)	dev_info(&vdev->pdev->dev, args)
-#define vdev_warn(args...)	dev_warn(&vdev->pdev->dev, args)
-#define vdev_err(args...)	dev_err(&vdev->pdev->dev, args)
-
-#define vdev_netinfo(args...)	netdev_info(vnic_get_netdev(vdev), args)
-#define vdev_netwarn(args...)	netdev_warn(vnic_get_netdev(vdev), args)
-#define vdev_neterr(args...)	netdev_err(vnic_get_netdev(vdev), args)
+#define vdev_err(vdev, fmt, ...)					\
+	dev_err(&(vdev)->pdev->dev, fmt, ##__VA_ARGS__)
+#define vdev_warn(vdev, fmt, ...)					\
+	dev_warn(&(vdev)->pdev->dev, fmt, ##__VA_ARGS__)
+#define vdev_info(vdev, fmt, ...)					\
+	dev_info(&(vdev)->pdev->dev, fmt, ##__VA_ARGS__)
+
+#define vdev_neterr(vdev, fmt, ...)					\
+	netdev_err(vnic_get_netdev(vdev), fmt, ##__VA_ARGS__)
+#define vdev_netwarn(vdev, fmt, ...)					\
+	netdev_warn(vnic_get_netdev(vdev), fmt, ##__VA_ARGS__)
+#define vdev_netinfo(vdev, fmt, ...)					\
+	netdev_info(vnic_get_netdev(vdev), fmt, ##__VA_ARGS__)
 
 static inline struct device *enic_get_dev(struct enic *enic)
 {
diff --git a/drivers/net/ethernet/cisco/enic/vnic_cq.c b/drivers/net/ethernet/cisco/enic/vnic_cq.c
index abeda2a..9c682af 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_cq.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_cq.c
@@ -43,7 +43,7 @@ int vnic_cq_alloc(struct vnic_dev *vdev, struct vnic_cq *cq, unsigned int index,
 
 	cq->ctrl = vnic_dev_get_res(vdev, RES_TYPE_CQ, index);
 	if (!cq->ctrl) {
-		vdev_err("Failed to hook CQ[%d] resource\n", index);
+		vdev_err(vdev, "Failed to hook CQ[%d] resource\n", index);
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index 1fdf5fe..8f27df3 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -53,14 +53,14 @@ static int vnic_dev_discover_res(struct vnic_dev *vdev,
 		return -EINVAL;
 
 	if (bar->len < VNIC_MAX_RES_HDR_SIZE) {
-		vdev_err("vNIC BAR0 res hdr length error\n");
+		vdev_err(vdev, "vNIC BAR0 res hdr length error\n");
 		return -EINVAL;
 	}
 
 	rh  = bar->vaddr;
 	mrh = bar->vaddr;
 	if (!rh) {
-		vdev_err("vNIC BAR0 res hdr not mem-mapped\n");
+		vdev_err(vdev, "vNIC BAR0 res hdr not mem-mapped\n");
 		return -EINVAL;
 	}
 
@@ -69,7 +69,7 @@ static int vnic_dev_discover_res(struct vnic_dev *vdev,
 		(ioread32(&rh->version) != VNIC_RES_VERSION)) {
 		if ((ioread32(&mrh->magic) != MGMTVNIC_MAGIC) ||
 			(ioread32(&mrh->version) != MGMTVNIC_VERSION)) {
-			vdev_err("vNIC BAR0 res magic/version error exp (%lx/%lx) or (%lx/%lx), curr (%x/%x)\n",
+			vdev_err(vdev, "vNIC BAR0 res magic/version error exp (%lx/%lx) or (%lx/%lx), curr (%x/%x)\n",
 				 VNIC_RES_MAGIC, VNIC_RES_VERSION,
 				 MGMTVNIC_MAGIC, MGMTVNIC_VERSION,
 				 ioread32(&rh->magic), ioread32(&rh->version));
@@ -106,7 +106,7 @@ static int vnic_dev_discover_res(struct vnic_dev *vdev,
 			/* each count is stride bytes long */
 			len = count * VNIC_RES_STRIDE;
 			if (len + bar_offset > bar[bar_num].len) {
-				vdev_err("vNIC BAR0 resource %d out-of-bounds, offset 0x%x + size 0x%x > bar len 0x%lx\n",
+				vdev_err(vdev, "vNIC BAR0 resource %d out-of-bounds, offset 0x%x + size 0x%x > bar len 0x%lx\n",
 					 type, bar_offset, len,
 					 bar[bar_num].len);
 				return -EINVAL;
@@ -198,7 +198,7 @@ int vnic_dev_alloc_desc_ring(struct vnic_dev *vdev, struct vnic_dev_ring *ring,
 		&ring->base_addr_unaligned);
 
 	if (!ring->descs_unaligned) {
-		vdev_err("Failed to allocate ring (size=%d), aborting\n",
+		vdev_err(vdev, "Failed to allocate ring (size=%d), aborting\n",
 			 (int)ring->size);
 		return -ENOMEM;
 	}
@@ -241,7 +241,7 @@ static int _vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 		return -ENODEV;
 	}
 	if (status & STAT_BUSY) {
-		vdev_neterr("Busy devcmd %d\n", _CMD_N(cmd));
+		vdev_neterr(vdev, "Busy devcmd %d\n", _CMD_N(cmd));
 		return -EBUSY;
 	}
 
@@ -275,7 +275,7 @@ static int _vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 					return -err;
 				if (err != ERR_ECMDUNKNOWN ||
 				    cmd != CMD_CAPABILITY)
-					vdev_neterr("Error %d devcmd %d\n",
+					vdev_neterr(vdev, "Error %d devcmd %d\n",
 						    err, _CMD_N(cmd));
 				return -err;
 			}
@@ -290,7 +290,7 @@ static int _vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 		}
 	}
 
-	vdev_neterr("Timedout devcmd %d\n", _CMD_N(cmd));
+	vdev_neterr(vdev, "Timedout devcmd %d\n", _CMD_N(cmd));
 	return -ETIMEDOUT;
 }
 
@@ -313,7 +313,7 @@ static int _vnic_dev_cmd2(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	new_posted = (posted + 1) % DEVCMD2_RING_SIZE;
 
 	if (new_posted == fetch_index) {
-		vdev_neterr("devcmd2 %d: wq is full. fetch index: %u, posted index: %u\n",
+		vdev_neterr(vdev, "devcmd2 %d: wq is full. fetch index: %u, posted index: %u\n",
 			    _CMD_N(cmd), fetch_index, posted);
 		return -EBUSY;
 	}
@@ -352,7 +352,7 @@ static int _vnic_dev_cmd2(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 				err = result->error;
 				if (err != ERR_ECMDUNKNOWN ||
 				    cmd != CMD_CAPABILITY)
-					vdev_neterr("Error %d devcmd %d\n",
+					vdev_neterr(vdev, "Error %d devcmd %d\n",
 						    err, _CMD_N(cmd));
 				return -err;
 			}
@@ -365,7 +365,7 @@ static int _vnic_dev_cmd2(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 		udelay(100);
 	}
 
-	vdev_neterr("devcmd %d timed out\n", _CMD_N(cmd));
+	vdev_neterr(vdev, "devcmd %d timed out\n", _CMD_N(cmd));
 
 	return -ETIMEDOUT;
 }
@@ -401,7 +401,7 @@ static int vnic_dev_init_devcmd2(struct vnic_dev *vdev)
 
 	fetch_index = ioread32(&vdev->devcmd2->wq.ctrl->fetch_index);
 	if (fetch_index == 0xFFFFFFFF) { /* check for hardware gone  */
-		vdev_err("Fatal error in devcmd2 init - hardware surprise removal");
+		vdev_err(vdev, "Fatal error in devcmd2 init - hardware surprise removal\n");
 
 		return -ENODEV;
 	}
@@ -474,8 +474,8 @@ static int vnic_dev_cmd_proxy(struct vnic_dev *vdev,
 		err = (int)vdev->args[1];
 		if (err != ERR_ECMDUNKNOWN ||
 		    cmd != CMD_CAPABILITY)
-			vdev_neterr("Error %d proxy devcmd %d\n", err,
-				    _CMD_N(cmd));
+			vdev_neterr(vdev, "Error %d proxy devcmd %d\n",
+				    err, _CMD_N(cmd));
 		return err;
 	}
 
@@ -768,7 +768,7 @@ int vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
 
 	err = vnic_dev_cmd(vdev, CMD_PACKET_FILTER, &a0, &a1, wait);
 	if (err)
-		vdev_neterr("Can't set packet filter\n");
+		vdev_neterr(vdev, "Can't set packet filter\n");
 
 	return err;
 }
@@ -785,7 +785,7 @@ int vnic_dev_add_addr(struct vnic_dev *vdev, const u8 *addr)
 
 	err = vnic_dev_cmd(vdev, CMD_ADDR_ADD, &a0, &a1, wait);
 	if (err)
-		vdev_neterr("Can't add addr [%pM], %d\n", addr, err);
+		vdev_neterr(vdev, "Can't add addr [%pM], %d\n", addr, err);
 
 	return err;
 }
@@ -802,7 +802,7 @@ int vnic_dev_del_addr(struct vnic_dev *vdev, const u8 *addr)
 
 	err = vnic_dev_cmd(vdev, CMD_ADDR_DEL, &a0, &a1, wait);
 	if (err)
-		vdev_neterr("Can't del addr [%pM], %d\n", addr, err);
+		vdev_neterr(vdev, "Can't del addr [%pM], %d\n", addr, err);
 
 	return err;
 }
@@ -846,7 +846,8 @@ int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr)
 	dma_addr_t notify_pa;
 
 	if (vdev->notify || vdev->notify_pa) {
-		vdev_neterr("notify block %p still allocated", vdev->notify);
+		vdev_neterr(vdev, "notify block %p still allocated\n",
+			    vdev->notify);
 		return -EINVAL;
 	}
 
@@ -965,7 +966,7 @@ int vnic_dev_intr_coal_timer_info(struct vnic_dev *vdev)
 	 */
 	if ((err == ERR_ECMDUNKNOWN) ||
 		(!err && !(vdev->args[0] && vdev->args[1] && vdev->args[2]))) {
-		vdev_netwarn("Using default conversion factor for interrupt coalesce timer\n");
+		vdev_netwarn(vdev, "Using default conversion factor for interrupt coalesce timer\n");
 		vnic_dev_intr_coal_timer_info_default(vdev);
 		return 0;
 	}
@@ -1103,16 +1104,16 @@ int vnic_devcmd_init(struct vnic_dev *vdev)
 	if (res) {
 		err = vnic_dev_init_devcmd2(vdev);
 		if (err)
-			vdev_warn("DEVCMD2 init failed: %d, Using DEVCMD1",
+			vdev_warn(vdev, "DEVCMD2 init failed: %d, Using DEVCMD1\n",
 				  err);
 		else
 			return 0;
 	} else {
-		vdev_warn("DEVCMD2 resource not found (old firmware?) Using DEVCMD1\n");
+		vdev_warn(vdev, "DEVCMD2 resource not found (old firmware?) Using DEVCMD1\n");
 	}
 	err = vnic_dev_init_devcmd1(vdev);
 	if (err)
-		vdev_err("DEVCMD1 initialization failed: %d", err);
+		vdev_err(vdev, "DEVCMD1 initialization failed: %d\n", err);
 
 	return err;
 }
diff --git a/drivers/net/ethernet/cisco/enic/vnic_intr.c b/drivers/net/ethernet/cisco/enic/vnic_intr.c
index 942759d..23604e3 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_intr.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_intr.c
@@ -40,7 +40,8 @@ int vnic_intr_alloc(struct vnic_dev *vdev, struct vnic_intr *intr,
 
 	intr->ctrl = vnic_dev_get_res(vdev, RES_TYPE_INTR_CTRL, index);
 	if (!intr->ctrl) {
-		vdev_err("Failed to hook INTR[%d].ctrl resource\n", index);
+		vdev_err(vdev, "Failed to hook INTR[%d].ctrl resource\n",
+			 index);
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/ethernet/cisco/enic/vnic_rq.c b/drivers/net/ethernet/cisco/enic/vnic_rq.c
index cce2777..e572a52 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_rq.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_rq.c
@@ -92,7 +92,7 @@ int vnic_rq_alloc(struct vnic_dev *vdev, struct vnic_rq *rq, unsigned int index,
 
 	rq->ctrl = vnic_dev_get_res(vdev, RES_TYPE_RQ, index);
 	if (!rq->ctrl) {
-		vdev_err("Failed to hook RQ[%d] resource\n", index);
+		vdev_err(vdev, "Failed to hook RQ[%d] resource\n", index);
 		return -EINVAL;
 	}
 
@@ -179,7 +179,7 @@ int vnic_rq_disable(struct vnic_rq *rq)
 		udelay(10);
 	}
 
-	vdev_neterr("Failed to disable RQ[%d]\n", rq->index);
+	vdev_neterr(vdev, "Failed to disable RQ[%d]\n", rq->index);
 
 	return -ETIMEDOUT;
 }
diff --git a/drivers/net/ethernet/cisco/enic/vnic_wq.c b/drivers/net/ethernet/cisco/enic/vnic_wq.c
index 05ad16a..090cc65 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_wq.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_wq.c
@@ -95,7 +95,7 @@ int vnic_wq_alloc(struct vnic_dev *vdev, struct vnic_wq *wq, unsigned int index,
 
 	wq->ctrl = vnic_dev_get_res(vdev, RES_TYPE_WQ, index);
 	if (!wq->ctrl) {
-		vdev_err("Failed to hook WQ[%d] resource\n", index);
+		vdev_err(vdev, "Failed to hook WQ[%d] resource\n", index);
 		return -EINVAL;
 	}
 
@@ -187,7 +187,7 @@ int vnic_wq_disable(struct vnic_wq *wq)
 		udelay(10);
 	}
 
-	vdev_neterr("Failed to disable WQ[%d]\n", wq->index);
+	vdev_neterr(vdev, "Failed to disable WQ[%d]\n", wq->index);
 
 	return -ETIMEDOUT;
 }
-- 
2.6.3.368.gf34be46
