From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH 2/4 net-next] enic: use netdev_<foo> or dev_<foo> instead of pr_<foo>
Date: Sun, 16 Aug 2015 01:44:52 +0530
Message-ID: <1439669694-21744-3-git-send-email-_govind@gmx.com>
References: <1439669694-21744-1-git-send-email-_govind@gmx.com>
Cc: nalreddy@cisco.com, ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:59354 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753332AbbHOUPo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Aug 2015 16:15:44 -0400
In-Reply-To: <1439669694-21744-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pr_info does not give any details about the interface involved. This patch
uses netdev_info for printing the message. Use dev_info where netdev is not
ready.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      | 19 ++++++++++++
 drivers/net/ethernet/cisco/enic/vnic_cq.c   |  3 +-
 drivers/net/ethernet/cisco/enic/vnic_dev.c  | 48 ++++++++++++++---------------
 drivers/net/ethernet/cisco/enic/vnic_intr.c |  3 +-
 drivers/net/ethernet/cisco/enic/vnic_rq.c   |  6 ++--
 drivers/net/ethernet/cisco/enic/vnic_wq.c   |  6 ++--
 6 files changed, 54 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 84b6a2b..ce3deb9 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -191,6 +191,25 @@ struct enic {
 	struct vnic_gen_stats gen_stats;
 };
 
+static inline struct net_device *vnic_get_netdev(struct vnic_dev *vdev)
+{
+	struct enic *enic = vdev->priv;
+
+	return enic->netdev;
+}
+
+/* wrappers function for kernel log
+ * Make sure variable vdev of struct vnic_dev is available in the block where
+ * these macros are used
+ */
+#define vdev_info(args...)	dev_info(&vdev->pdev->dev, args)
+#define vdev_warn(args...)	dev_warn(&vdev->pdev->dev, args)
+#define vdev_err(args...)	dev_err(&vdev->pdev->dev, args)
+
+#define vdev_netinfo(args...)	netdev_info(vnic_get_netdev(vdev), args)
+#define vdev_netwarn(args...)	netdev_warn(vnic_get_netdev(vdev), args)
+#define vdev_neterr(args...)	netdev_err(vnic_get_netdev(vdev), args)
+
 static inline struct device *enic_get_dev(struct enic *enic)
 {
 	return &(enic->pdev->dev);
diff --git a/drivers/net/ethernet/cisco/enic/vnic_cq.c b/drivers/net/ethernet/cisco/enic/vnic_cq.c
index 0daa1c7..abeda2a 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_cq.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_cq.c
@@ -24,6 +24,7 @@
 
 #include "vnic_dev.h"
 #include "vnic_cq.h"
+#include "enic.h"
 
 void vnic_cq_free(struct vnic_cq *cq)
 {
@@ -42,7 +43,7 @@ int vnic_cq_alloc(struct vnic_dev *vdev, struct vnic_cq *cq, unsigned int index,
 
 	cq->ctrl = vnic_dev_get_res(vdev, RES_TYPE_CQ, index);
 	if (!cq->ctrl) {
-		pr_err("Failed to hook CQ[%d] resource\n", index);
+		vdev_err("Failed to hook CQ[%d] resource\n", index);
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index b239cfd..52bfb3a 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -28,6 +28,7 @@
 #include "vnic_devcmd.h"
 #include "vnic_dev.h"
 #include "vnic_stats.h"
+#include "enic.h"
 
 #define VNIC_MAX_RES_HDR_SIZE \
 	(sizeof(struct vnic_resource_header) + \
@@ -51,14 +52,14 @@ static int vnic_dev_discover_res(struct vnic_dev *vdev,
 		return -EINVAL;
 
 	if (bar->len < VNIC_MAX_RES_HDR_SIZE) {
-		pr_err("vNIC BAR0 res hdr length error\n");
+		vdev_err("vNIC BAR0 res hdr length error\n");
 		return -EINVAL;
 	}
 
 	rh  = bar->vaddr;
 	mrh = bar->vaddr;
 	if (!rh) {
-		pr_err("vNIC BAR0 res hdr not mem-mapped\n");
+		vdev_err("vNIC BAR0 res hdr not mem-mapped\n");
 		return -EINVAL;
 	}
 
@@ -67,11 +68,10 @@ static int vnic_dev_discover_res(struct vnic_dev *vdev,
 		(ioread32(&rh->version) != VNIC_RES_VERSION)) {
 		if ((ioread32(&mrh->magic) != MGMTVNIC_MAGIC) ||
 			(ioread32(&mrh->version) != MGMTVNIC_VERSION)) {
-			pr_err("vNIC BAR0 res magic/version error "
-			"exp (%lx/%lx) or (%lx/%lx), curr (%x/%x)\n",
-			VNIC_RES_MAGIC, VNIC_RES_VERSION,
-			MGMTVNIC_MAGIC, MGMTVNIC_VERSION,
-			ioread32(&rh->magic), ioread32(&rh->version));
+			vdev_err("vNIC BAR0 res magic/version error exp (%lx/%lx) or (%lx/%lx), curr (%x/%x)\n",
+				 VNIC_RES_MAGIC, VNIC_RES_VERSION,
+				 MGMTVNIC_MAGIC, MGMTVNIC_VERSION,
+				 ioread32(&rh->magic), ioread32(&rh->version));
 			return -EINVAL;
 		}
 	}
@@ -105,12 +105,9 @@ static int vnic_dev_discover_res(struct vnic_dev *vdev,
 			/* each count is stride bytes long */
 			len = count * VNIC_RES_STRIDE;
 			if (len + bar_offset > bar[bar_num].len) {
-				pr_err("vNIC BAR0 resource %d "
-					"out-of-bounds, offset 0x%x + "
-					"size 0x%x > bar len 0x%lx\n",
-					type, bar_offset,
-					len,
-					bar[bar_num].len);
+				vdev_err("vNIC BAR0 resource %d out-of-bounds, offset 0x%x + size 0x%x > bar len 0x%lx\n",
+					 type, bar_offset, len,
+					 bar[bar_num].len);
 				return -EINVAL;
 			}
 			break;
@@ -199,8 +196,8 @@ int vnic_dev_alloc_desc_ring(struct vnic_dev *vdev, struct vnic_dev_ring *ring,
 		&ring->base_addr_unaligned);
 
 	if (!ring->descs_unaligned) {
-		pr_err("Failed to allocate ring (size=%d), aborting\n",
-			(int)ring->size);
+		vdev_err("Failed to allocate ring (size=%d), aborting\n",
+			 (int)ring->size);
 		return -ENOMEM;
 	}
 
@@ -242,7 +239,7 @@ static int _vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 		return -ENODEV;
 	}
 	if (status & STAT_BUSY) {
-		pr_err("Busy devcmd %d\n", _CMD_N(cmd));
+		vdev_neterr("Busy devcmd %d\n", _CMD_N(cmd));
 		return -EBUSY;
 	}
 
@@ -276,8 +273,8 @@ static int _vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 					return -err;
 				if (err != ERR_ECMDUNKNOWN ||
 				    cmd != CMD_CAPABILITY)
-					pr_err("Error %d devcmd %d\n",
-						err, _CMD_N(cmd));
+					vdev_neterr("Error %d devcmd %d\n",
+						    err, _CMD_N(cmd));
 				return -err;
 			}
 
@@ -291,7 +288,7 @@ static int _vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 		}
 	}
 
-	pr_err("Timedout devcmd %d\n", _CMD_N(cmd));
+	vdev_neterr("Timedout devcmd %d\n", _CMD_N(cmd));
 	return -ETIMEDOUT;
 }
 
@@ -318,7 +315,8 @@ static int vnic_dev_cmd_proxy(struct vnic_dev *vdev,
 		err = (int)vdev->args[1];
 		if (err != ERR_ECMDUNKNOWN ||
 		    cmd != CMD_CAPABILITY)
-			pr_err("Error %d proxy devcmd %d\n", err, _CMD_N(cmd));
+			vdev_neterr("Error %d proxy devcmd %d\n", err,
+				    _CMD_N(cmd));
 		return err;
 	}
 
@@ -611,7 +609,7 @@ int vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
 
 	err = vnic_dev_cmd(vdev, CMD_PACKET_FILTER, &a0, &a1, wait);
 	if (err)
-		pr_err("Can't set packet filter\n");
+		vdev_neterr("Can't set packet filter\n");
 
 	return err;
 }
@@ -628,7 +626,7 @@ int vnic_dev_add_addr(struct vnic_dev *vdev, const u8 *addr)
 
 	err = vnic_dev_cmd(vdev, CMD_ADDR_ADD, &a0, &a1, wait);
 	if (err)
-		pr_err("Can't add addr [%pM], %d\n", addr, err);
+		vdev_neterr("Can't add addr [%pM], %d\n", addr, err);
 
 	return err;
 }
@@ -645,7 +643,7 @@ int vnic_dev_del_addr(struct vnic_dev *vdev, const u8 *addr)
 
 	err = vnic_dev_cmd(vdev, CMD_ADDR_DEL, &a0, &a1, wait);
 	if (err)
-		pr_err("Can't del addr [%pM], %d\n", addr, err);
+		vdev_neterr("Can't del addr [%pM], %d\n", addr, err);
 
 	return err;
 }
@@ -689,7 +687,7 @@ int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr)
 	dma_addr_t notify_pa;
 
 	if (vdev->notify || vdev->notify_pa) {
-		pr_err("notify block %p still allocated", vdev->notify);
+		vdev_neterr("notify block %p still allocated", vdev->notify);
 		return -EINVAL;
 	}
 
@@ -808,7 +806,7 @@ int vnic_dev_intr_coal_timer_info(struct vnic_dev *vdev)
 	 */
 	if ((err == ERR_ECMDUNKNOWN) ||
 		(!err && !(vdev->args[0] && vdev->args[1] && vdev->args[2]))) {
-		pr_warn("Using default conversion factor for interrupt coalesce timer\n");
+		vdev_netwarn("Using default conversion factor for interrupt coalesce timer\n");
 		vnic_dev_intr_coal_timer_info_default(vdev);
 		return 0;
 	}
diff --git a/drivers/net/ethernet/cisco/enic/vnic_intr.c b/drivers/net/ethernet/cisco/enic/vnic_intr.c
index 0ca107f..942759d 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_intr.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_intr.c
@@ -25,6 +25,7 @@
 
 #include "vnic_dev.h"
 #include "vnic_intr.h"
+#include "enic.h"
 
 void vnic_intr_free(struct vnic_intr *intr)
 {
@@ -39,7 +40,7 @@ int vnic_intr_alloc(struct vnic_dev *vdev, struct vnic_intr *intr,
 
 	intr->ctrl = vnic_dev_get_res(vdev, RES_TYPE_INTR_CTRL, index);
 	if (!intr->ctrl) {
-		pr_err("Failed to hook INTR[%d].ctrl resource\n", index);
+		vdev_err("Failed to hook INTR[%d].ctrl resource\n", index);
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/ethernet/cisco/enic/vnic_rq.c b/drivers/net/ethernet/cisco/enic/vnic_rq.c
index c4b2183..cce2777 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_rq.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_rq.c
@@ -26,6 +26,7 @@
 
 #include "vnic_dev.h"
 #include "vnic_rq.h"
+#include "enic.h"
 
 static int vnic_rq_alloc_bufs(struct vnic_rq *rq)
 {
@@ -91,7 +92,7 @@ int vnic_rq_alloc(struct vnic_dev *vdev, struct vnic_rq *rq, unsigned int index,
 
 	rq->ctrl = vnic_dev_get_res(vdev, RES_TYPE_RQ, index);
 	if (!rq->ctrl) {
-		pr_err("Failed to hook RQ[%d] resource\n", index);
+		vdev_err("Failed to hook RQ[%d] resource\n", index);
 		return -EINVAL;
 	}
 
@@ -167,6 +168,7 @@ void vnic_rq_enable(struct vnic_rq *rq)
 int vnic_rq_disable(struct vnic_rq *rq)
 {
 	unsigned int wait;
+	struct vnic_dev *vdev = rq->vdev;
 
 	iowrite32(0, &rq->ctrl->enable);
 
@@ -177,7 +179,7 @@ int vnic_rq_disable(struct vnic_rq *rq)
 		udelay(10);
 	}
 
-	pr_err("Failed to disable RQ[%d]\n", rq->index);
+	vdev_neterr("Failed to disable RQ[%d]\n", rq->index);
 
 	return -ETIMEDOUT;
 }
diff --git a/drivers/net/ethernet/cisco/enic/vnic_wq.c b/drivers/net/ethernet/cisco/enic/vnic_wq.c
index b5a1c93..538302a 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_wq.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_wq.c
@@ -26,6 +26,7 @@
 
 #include "vnic_dev.h"
 #include "vnic_wq.h"
+#include "enic.h"
 
 static int vnic_wq_alloc_bufs(struct vnic_wq *wq)
 {
@@ -94,7 +95,7 @@ int vnic_wq_alloc(struct vnic_dev *vdev, struct vnic_wq *wq, unsigned int index,
 
 	wq->ctrl = vnic_dev_get_res(vdev, RES_TYPE_WQ, index);
 	if (!wq->ctrl) {
-		pr_err("Failed to hook WQ[%d] resource\n", index);
+		vdev_err("Failed to hook WQ[%d] resource\n", index);
 		return -EINVAL;
 	}
 
@@ -158,6 +159,7 @@ void vnic_wq_enable(struct vnic_wq *wq)
 int vnic_wq_disable(struct vnic_wq *wq)
 {
 	unsigned int wait;
+	struct vnic_dev *vdev = wq->vdev;
 
 	iowrite32(0, &wq->ctrl->enable);
 
@@ -168,7 +170,7 @@ int vnic_wq_disable(struct vnic_wq *wq)
 		udelay(10);
 	}
 
-	pr_err("Failed to disable WQ[%d]\n", wq->index);
+	vdev_neterr("Failed to disable WQ[%d]\n", wq->index);
 
 	return -ETIMEDOUT;
 }
-- 
2.5.0
