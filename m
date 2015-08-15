From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH 4/4 net-next] enic: add devcmd2
Date: Sun, 16 Aug 2015 01:44:54 +0530
Message-ID: <1439669694-21744-5-git-send-email-_govind@gmx.com>
References: <1439669694-21744-1-git-send-email-_govind@gmx.com>
Cc: nalreddy@cisco.com, ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:64430 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754362AbbHOUQB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Aug 2015 16:16:01 -0400
In-Reply-To: <1439669694-21744-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

devcmd is an interface for driver to communicate with fw/adaptor. It
involves writing data to hardware registers and waiting for the result.
This mechanism does not scale well. The queuing of "no wait" devcmds is
done in firmware memory rather than on the host. Firmware memory is a
rather more scarce and valuable resource than host memory. A devcmd storm
from one vf can disrupt the service on other pf/vf. The lack of flow
control allows for possible denial of server from one VM to another.

Devcmd2 uses work queue to post the devcmds, just like tx work queue. This
allows better flow control.

Initialize devcmd2, if fails we fall back to devcmd1.

Also change the driver version.

Signed-off-by: N V V Satyanarayana Reddy <nalreddy@cisco.com>
Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic.h        |   2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c   |   5 +
 drivers/net/ethernet/cisco/enic/vnic_dev.c    | 188 +++++++++++++++++++++++++-
 drivers/net/ethernet/cisco/enic/vnic_dev.h    |   3 +
 drivers/net/ethernet/cisco/enic/vnic_devcmd.h |   5 +
 drivers/net/ethernet/cisco/enic/vnic_wq.c     |  25 +++-
 drivers/net/ethernet/cisco/enic/vnic_wq.h     |   6 +
 7 files changed, 222 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index ce3deb9..f137cc9 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -33,7 +33,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.83"
+#define DRV_VERSION		"2.3.0.12"
 #define DRV_COPYRIGHT		"Copyright 2008-2013 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 8f646e4..cb1fdc3 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2484,6 +2484,11 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_iounmap;
 	}
 
+	err = vnic_devcmd_init(enic->vdev);
+
+	if (err)
+		goto err_out_vnic_unregister;
+
 #ifdef CONFIG_PCI_IOV
 	/* Get number of subvnics */
 	pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_SRIOV);
diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index 52bfb3a..ff2da7e 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -27,6 +27,7 @@
 #include "vnic_resource.h"
 #include "vnic_devcmd.h"
 #include "vnic_dev.h"
+#include "vnic_wq.h"
 #include "vnic_stats.h"
 #include "enic.h"
 
@@ -113,6 +114,7 @@ static int vnic_dev_discover_res(struct vnic_dev *vdev,
 			break;
 		case RES_TYPE_INTR_PBA_LEGACY:
 		case RES_TYPE_DEVCMD:
+		case RES_TYPE_DEVCMD2:
 			len = count;
 			break;
 		default:
@@ -292,6 +294,156 @@ static int _vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	return -ETIMEDOUT;
 }
 
+static int _vnic_dev_cmd2(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
+			  int wait)
+{
+	struct devcmd2_controller *dc2c = vdev->devcmd2;
+	struct devcmd2_result *result = dc2c->result + dc2c->next_result;
+	unsigned int i;
+	int delay, err;
+	u32 fetch_index, posted, new_posted;
+
+	posted = ioread32(&dc2c->wq_ctrl->posted_index);
+	fetch_index = ioread32(&dc2c->wq_ctrl->fetch_index);
+
+	if (posted == 0xFFFFFFFF || fetch_index == 0xFFFFFFFF)
+		return -ENODEV;
+
+	new_posted = (posted + 1) % DEVCMD2_RING_SIZE;
+
+	if (new_posted == fetch_index) {
+		vdev_neterr("devcmd2 %d: wq is full. fetch index: %u, posted index: %u\n",
+			    _CMD_N(cmd), fetch_index, posted);
+		return -EBUSY;
+	}
+	dc2c->cmd_ring[posted].cmd = cmd;
+	dc2c->cmd_ring[posted].flags = 0;
+
+	if ((_CMD_FLAGS(cmd) & _CMD_FLAGS_NOWAIT))
+		dc2c->cmd_ring[posted].flags |= DEVCMD2_FNORESULT;
+	if (_CMD_DIR(cmd) & _CMD_DIR_WRITE)
+		for (i = 0; i < VNIC_DEVCMD_NARGS; i++)
+			dc2c->cmd_ring[posted].args[i] = vdev->args[i];
+
+	/* Adding write memory barrier prevents compiler and/or CPU reordering,
+	 * thus avoiding descriptor posting before descriptor is initialized.
+	 * Otherwise, hardware can read stale descriptor fields.
+	 */
+	wmb();
+	iowrite32(new_posted, &dc2c->wq_ctrl->posted_index);
+
+	if (dc2c->cmd_ring[posted].flags & DEVCMD2_FNORESULT)
+		return 0;
+
+	for (delay = 0; delay < wait; delay++) {
+		if (result->color == dc2c->color) {
+			dc2c->next_result++;
+			if (dc2c->next_result == dc2c->result_size) {
+				dc2c->next_result = 0;
+				dc2c->color = dc2c->color ? 0 : 1;
+			}
+			if (result->error) {
+				err = result->error;
+				if (err != ERR_ECMDUNKNOWN ||
+				    cmd != CMD_CAPABILITY)
+					vdev_neterr("Error %d devcmd %d\n",
+						    err, _CMD_N(cmd));
+				return -err;
+			}
+			if (_CMD_DIR(cmd) & _CMD_DIR_READ)
+				for (i = 0; i < VNIC_DEVCMD2_NARGS; i++)
+					vdev->args[i] = result->results[i];
+
+			return 0;
+		}
+		udelay(100);
+	}
+
+	vdev_neterr("devcmd %d timed out\n", _CMD_N(cmd));
+
+	return -ETIMEDOUT;
+}
+
+static int vnic_dev_init_devcmd1(struct vnic_dev *vdev)
+{
+	vdev->devcmd = vnic_dev_get_res(vdev, RES_TYPE_DEVCMD, 0);
+	if (!vdev->devcmd)
+		return -ENODEV;
+	vdev->devcmd_rtn = _vnic_dev_cmd;
+
+	return 0;
+}
+
+static int vnic_dev_init_devcmd2(struct vnic_dev *vdev)
+{
+	int err;
+	unsigned int fetch_index;
+
+	if (vdev->devcmd2)
+		return 0;
+
+	vdev->devcmd2 = kzalloc(sizeof(*vdev->devcmd2), GFP_KERNEL);
+	if (!vdev->devcmd2)
+		return -ENOMEM;
+
+	vdev->devcmd2->color = 1;
+	vdev->devcmd2->result_size = DEVCMD2_RING_SIZE;
+	err = vnic_wq_devcmd2_alloc(vdev, &vdev->devcmd2->wq, DEVCMD2_RING_SIZE,
+				    DEVCMD2_DESC_SIZE);
+	if (err)
+		goto err_free_devcmd2;
+
+	fetch_index = ioread32(&vdev->devcmd2->wq.ctrl->fetch_index);
+	if (fetch_index == 0xFFFFFFFF) { /* check for hardware gone  */
+		vdev_err("Fatal error in devcmd2 init - hardware surprise removal");
+
+		return -ENODEV;
+	}
+
+	vnic_wq_init_start(&vdev->devcmd2->wq, 0, fetch_index, fetch_index, 0,
+			   0);
+	vnic_wq_enable(&vdev->devcmd2->wq);
+
+	err = vnic_dev_alloc_desc_ring(vdev, &vdev->devcmd2->results_ring,
+				       DEVCMD2_RING_SIZE, DEVCMD2_DESC_SIZE);
+	if (err)
+		goto err_free_wq;
+
+	vdev->devcmd2->result = vdev->devcmd2->results_ring.descs;
+	vdev->devcmd2->cmd_ring = vdev->devcmd2->wq.ring.descs;
+	vdev->devcmd2->wq_ctrl = vdev->devcmd2->wq.ctrl;
+	vdev->args[0] = (u64)vdev->devcmd2->results_ring.base_addr |
+			VNIC_PADDR_TARGET;
+	vdev->args[1] = DEVCMD2_RING_SIZE;
+
+	err = _vnic_dev_cmd2(vdev, CMD_INITIALIZE_DEVCMD2, 1000);
+	if (err)
+		goto err_free_desc_ring;
+
+	vdev->devcmd_rtn = _vnic_dev_cmd2;
+
+	return 0;
+
+err_free_desc_ring:
+	vnic_dev_free_desc_ring(vdev, &vdev->devcmd2->results_ring);
+err_free_wq:
+	vnic_wq_disable(&vdev->devcmd2->wq);
+	vnic_wq_free(&vdev->devcmd2->wq);
+err_free_devcmd2:
+	kfree(vdev->devcmd2);
+	vdev->devcmd2 = NULL;
+
+	return err;
+}
+
+static void vnic_dev_deinit_devcmd2(struct vnic_dev *vdev)
+{
+	vnic_dev_free_desc_ring(vdev, &vdev->devcmd2->results_ring);
+	vnic_wq_disable(&vdev->devcmd2->wq);
+	vnic_wq_free(&vdev->devcmd2->wq);
+	kfree(vdev->devcmd2);
+}
+
 static int vnic_dev_cmd_proxy(struct vnic_dev *vdev,
 	enum vnic_devcmd_cmd proxy_cmd, enum vnic_devcmd_cmd cmd,
 	u64 *a0, u64 *a1, int wait)
@@ -306,7 +458,7 @@ static int vnic_dev_cmd_proxy(struct vnic_dev *vdev,
 	vdev->args[2] = *a0;
 	vdev->args[3] = *a1;
 
-	err = _vnic_dev_cmd(vdev, proxy_cmd, wait);
+	err = vdev->devcmd_rtn(vdev, proxy_cmd, wait);
 	if (err)
 		return err;
 
@@ -334,7 +486,7 @@ static int vnic_dev_cmd_no_proxy(struct vnic_dev *vdev,
 	vdev->args[0] = *a0;
 	vdev->args[1] = *a1;
 
-	err = _vnic_dev_cmd(vdev, cmd, wait);
+	err = vdev->devcmd_rtn(vdev, cmd, wait);
 
 	*a0 = vdev->args[0];
 	*a1 = vdev->args[1];
@@ -797,7 +949,7 @@ int vnic_dev_intr_coal_timer_info(struct vnic_dev *vdev)
 	memset(vdev->args, 0, sizeof(vdev->args));
 
 	if (vnic_dev_capable(vdev, CMD_INTR_COAL_CONVERT))
-		err = _vnic_dev_cmd(vdev, CMD_INTR_COAL_CONVERT, wait);
+		err = vdev->devcmd_rtn(vdev, CMD_INTR_COAL_CONVERT, wait);
 	else
 		err = ERR_ECMDUNKNOWN;
 
@@ -897,6 +1049,9 @@ void vnic_dev_unregister(struct vnic_dev *vdev)
 			pci_free_consistent(vdev->pdev,
 				sizeof(struct vnic_devcmd_fw_info),
 				vdev->fw_info, vdev->fw_info_pa);
+		if (vdev->devcmd2)
+			vnic_dev_deinit_devcmd2(vdev);
+
 		kfree(vdev);
 	}
 }
@@ -918,10 +1073,6 @@ struct vnic_dev *vnic_dev_register(struct vnic_dev *vdev,
 	if (vnic_dev_discover_res(vdev, bar, num_bars))
 		goto err_out;
 
-	vdev->devcmd = vnic_dev_get_res(vdev, RES_TYPE_DEVCMD, 0);
-	if (!vdev->devcmd)
-		goto err_out;
-
 	return vdev;
 
 err_out:
@@ -936,6 +1087,29 @@ struct pci_dev *vnic_dev_get_pdev(struct vnic_dev *vdev)
 }
 EXPORT_SYMBOL(vnic_dev_get_pdev);
 
+int vnic_devcmd_init(struct vnic_dev *vdev)
+{
+	int err;
+	void *res;
+
+	res = vnic_dev_get_res(vdev, RES_TYPE_DEVCMD2, 0);
+	if (res) {
+		err = vnic_dev_init_devcmd2(vdev);
+		if (err)
+			vdev_warn("DEVCMD2 init failed: %d, Using DEVCMD1",
+				  err);
+		else
+			return 0;
+	} else {
+		vdev_warn("DEVCMD2 resource not found (old firmware?) Using DEVCMD1\n");
+	}
+	err = vnic_dev_init_devcmd1(vdev);
+	if (err)
+		vdev_err("DEVCMD1 initialization failed: %d", err);
+
+	return err;
+}
+
 int vnic_dev_init_prov2(struct vnic_dev *vdev, u8 *buf, u32 len)
 {
 	u64 a0, a1 = len;
diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.h b/drivers/net/ethernet/cisco/enic/vnic_dev.h
index 51aae05..b013b6a 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.h
@@ -108,6 +108,8 @@ struct vnic_dev {
 	u64 args[VNIC_DEVCMD_NARGS];
 	struct vnic_intr_coal_timer_info intr_coal_timer_info;
 	struct devcmd2_controller *devcmd2;
+	int (*devcmd_rtn)(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
+			  int wait);
 };
 
 struct vnic_stats;
@@ -174,5 +176,6 @@ int vnic_dev_deinit_done(struct vnic_dev *vdev, int *status);
 int vnic_dev_set_mac_addr(struct vnic_dev *vdev, u8 *mac_addr);
 int vnic_dev_classifier(struct vnic_dev *vdev, u8 cmd, u16 *entry,
 			struct filter *data);
+int vnic_devcmd_init(struct vnic_dev *vdev);
 
 #endif /* _VNIC_DEV_H_ */
diff --git a/drivers/net/ethernet/cisco/enic/vnic_devcmd.h b/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
index 09e8039..2a81288 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
@@ -635,6 +635,8 @@ struct vnic_devcmd {
 	u64 args[VNIC_DEVCMD_NARGS];	/* RW cmd args (little-endian) */
 };
 
+#define DEVCMD2_FNORESULT	0x1	/* Don't copy result to host */
+
 #define VNIC_DEVCMD2_NARGS	VNIC_DEVCMD_NARGS
 struct vnic_devcmd2 {
 	u16 pad;
@@ -652,4 +654,7 @@ struct devcmd2_result {
 	u8  color;
 };
 
+#define DEVCMD2_RING_SIZE	32
+#define DEVCMD2_DESC_SIZE	128
+
 #endif /* _VNIC_DEVCMD_H_ */
diff --git a/drivers/net/ethernet/cisco/enic/vnic_wq.c b/drivers/net/ethernet/cisco/enic/vnic_wq.c
index 538302a..627f3b1 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_wq.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_wq.c
@@ -114,10 +114,27 @@ int vnic_wq_alloc(struct vnic_dev *vdev, struct vnic_wq *wq, unsigned int index,
 	return 0;
 }
 
-static void vnic_wq_init_start(struct vnic_wq *wq, unsigned int cq_index,
-	unsigned int fetch_index, unsigned int posted_index,
-	unsigned int error_interrupt_enable,
-	unsigned int error_interrupt_offset)
+int vnic_wq_devcmd2_alloc(struct vnic_dev *vdev, struct vnic_wq *wq,
+			  unsigned int desc_count, unsigned int desc_size)
+{
+	int err;
+
+	wq->index = 0;
+	wq->vdev = vdev;
+
+	wq->ctrl = vnic_dev_get_res(vdev, RES_TYPE_DEVCMD2, 0);
+	if (!wq->ctrl)
+		return -EINVAL;
+	vnic_wq_disable(wq);
+	err = vnic_dev_alloc_desc_ring(vdev, &wq->ring, desc_count, desc_size);
+
+	return err;
+}
+
+void vnic_wq_init_start(struct vnic_wq *wq, unsigned int cq_index,
+			unsigned int fetch_index, unsigned int posted_index,
+			unsigned int error_interrupt_enable,
+			unsigned int error_interrupt_offset)
 {
 	u64 paddr;
 	unsigned int count = wq->ring.desc_count;
diff --git a/drivers/net/ethernet/cisco/enic/vnic_wq.h b/drivers/net/ethernet/cisco/enic/vnic_wq.h
index d5ea706..c9b25d3 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_wq.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_wq.h
@@ -185,5 +185,11 @@ void vnic_wq_enable(struct vnic_wq *wq);
 int vnic_wq_disable(struct vnic_wq *wq);
 void vnic_wq_clean(struct vnic_wq *wq,
 	void (*buf_clean)(struct vnic_wq *wq, struct vnic_wq_buf *buf));
+int vnic_wq_devcmd2_alloc(struct vnic_dev *vdev, struct vnic_wq *wq,
+			  unsigned int desc_count, unsigned int desc_size);
+void vnic_wq_init_start(struct vnic_wq *wq, unsigned int cq_index,
+			unsigned int fetch_index, unsigned int posted_index,
+			unsigned int error_interrupt_enable,
+			unsigned int error_interrupt_offset);
 
 #endif /* _VNIC_WQ_H_ */
-- 
2.5.0
