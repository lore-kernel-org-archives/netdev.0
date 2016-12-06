From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 7/7] bnxt_en: Add interface to support RDMA driver.
Date: Tue,  6 Dec 2016 12:09:38 -0500
Message-ID: <1481044178-25193-8-git-send-email-michael.chan@broadcom.com>
References: <1481044178-25193-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, selvin.xavier@broadcom.com,
        somnath.kotur@broadcom.com, dledford@redhat.com,
        linux-rdma@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33917 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753728AbcLFRKM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 12:10:12 -0500
Received: by mail-pg0-f46.google.com with SMTP id x23so151275979pgx.1
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 09:10:11 -0800 (PST)
In-Reply-To: <1481044178-25193-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the network driver and RDMA driver operate on the same PCI function,
we need to create an interface to allow the RDMA driver to share resources
with the network driver.

1. Create a new bnxt_en_dev struct which will be returned by
bnxt_ulp_probe() upon success.  After that, all calls from the RDMA driver
to bnxt_en will pass a pointer to this struct.

2. This struct contains additional function pointers to register, request
msix, send fw messages, register for async events.

3. If the RDMA driver wants to enable RDMA on the function, it needs to
call the function pointer bnxt_register_device().  A ulp_ops structure
is passed for RCU protected upcalls from bnxt_en to the RDMA driver.

4. The RDMA driver can call firmware APIs using the bnxt_send_fw_msg()
function pointer.

5. 1 stats context is reserved when the RDMA driver registers.  MSIX
and completion rings are reserved when the RDMA driver calls
bnxt_request_msix() function pointer.

6. When the RDMA driver calls bnxt_unregister_device(), all RDMA resources
will be cleaned up.

Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/Makefile   |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c     |  41 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h     |   6 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c | 346 ++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.h |  93 +++++++
 5 files changed, 483 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.h

diff --git a/drivers/net/ethernet/broadcom/bnxt/Makefile b/drivers/net/ethernet/broadcom/bnxt/Makefile
index b233a86..6082ed1 100644
--- a/drivers/net/ethernet/broadcom/bnxt/Makefile
+++ b/drivers/net/ethernet/broadcom/bnxt/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_BNXT) += bnxt_en.o
 
-bnxt_en-y := bnxt.o bnxt_sriov.o bnxt_ethtool.o bnxt_dcb.o
+bnxt_en-y := bnxt.o bnxt_sriov.o bnxt_ethtool.o bnxt_dcb.o bnxt_ulp.o
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c26735ea..d334da3 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -52,6 +52,7 @@
 
 #include "bnxt_hsi.h"
 #include "bnxt.h"
+#include "bnxt_ulp.h"
 #include "bnxt_sriov.h"
 #include "bnxt_ethtool.h"
 #include "bnxt_dcb.h"
@@ -1528,12 +1529,11 @@ static int bnxt_async_event_process(struct bnxt *bp,
 		set_bit(BNXT_RESET_TASK_SILENT_SP_EVENT, &bp->sp_event);
 		break;
 	default:
-		netdev_err(bp->dev, "unhandled ASYNC event (id 0x%x)\n",
-			   event_id);
 		goto async_event_process_exit;
 	}
 	schedule_work(&bp->sp_task);
 async_event_process_exit:
+	bnxt_ulp_async_events(bp, cmpl);
 	return 0;
 }
 
@@ -3547,7 +3547,7 @@ static int bnxt_hwrm_vnic_ctx_alloc(struct bnxt *bp, u16 vnic_id, u16 ctx_idx)
 	return rc;
 }
 
-static int bnxt_hwrm_vnic_cfg(struct bnxt *bp, u16 vnic_id)
+int bnxt_hwrm_vnic_cfg(struct bnxt *bp, u16 vnic_id)
 {
 	unsigned int ring = 0, grp_idx;
 	struct bnxt_vnic_info *vnic = &bp->vnic_info[vnic_id];
@@ -3595,6 +3595,9 @@ static int bnxt_hwrm_vnic_cfg(struct bnxt *bp, u16 vnic_id)
 #endif
 	if ((bp->flags & BNXT_FLAG_STRIP_VLAN) || def_vlan)
 		req.flags |= cpu_to_le32(VNIC_CFG_REQ_FLAGS_VLAN_STRIP_MODE);
+	if (!vnic_id && bnxt_ulp_registered(bp->edev, BNXT_ROCE_ULP))
+		req.flags |=
+			cpu_to_le32(VNIC_CFG_REQ_FLAGS_ROCE_DUAL_VNIC_MODE);
 
 	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
 }
@@ -4842,6 +4845,16 @@ unsigned int bnxt_get_max_func_stat_ctxs(struct bnxt *bp)
 #endif
 }
 
+void bnxt_set_max_func_stat_ctxs(struct bnxt *bp, unsigned int max)
+{
+	if (BNXT_PF(bp))
+		bp->pf.max_stat_ctxs = max;
+#if defined(CONFIG_BNXT_SRIOV)
+	else
+		bp->vf.max_stat_ctxs = max;
+#endif
+}
+
 unsigned int bnxt_get_max_func_cp_rings(struct bnxt *bp)
 {
 	if (BNXT_PF(bp))
@@ -4851,6 +4864,16 @@ unsigned int bnxt_get_max_func_cp_rings(struct bnxt *bp)
 #endif
 }
 
+void bnxt_set_max_func_cp_rings(struct bnxt *bp, unsigned int max)
+{
+	if (BNXT_PF(bp))
+		bp->pf.max_cp_rings = max;
+#if defined(CONFIG_BNXT_SRIOV)
+	else
+		bp->vf.max_cp_rings = max;
+#endif
+}
+
 static unsigned int bnxt_get_max_func_irqs(struct bnxt *bp)
 {
 	if (BNXT_PF(bp))
@@ -6767,6 +6790,8 @@ static void bnxt_remove_one(struct pci_dev *pdev)
 	pci_iounmap(pdev, bp->bar2);
 	pci_iounmap(pdev, bp->bar1);
 	pci_iounmap(pdev, bp->bar0);
+	kfree(bp->edev);
+	bp->edev = NULL;
 	free_netdev(dev);
 
 	pci_release_regions(pdev);
@@ -6936,6 +6961,7 @@ void bnxt_restore_pf_fw_resources(struct bnxt *bp)
 {
 	ASSERT_RTNL();
 	bnxt_hwrm_func_qcaps(bp);
+	bnxt_subtract_ulp_resources(bp, BNXT_ROCE_ULP);
 }
 
 static void bnxt_parse_log_pcie_link(struct bnxt *bp)
@@ -7047,6 +7073,8 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (rc)
 		goto init_err;
 
+	bp->ulp_probe = bnxt_ulp_probe;
+
 	/* Get the MAX capabilities for this function */
 	rc = bnxt_hwrm_func_qcaps(bp);
 	if (rc) {
@@ -7144,12 +7172,15 @@ static pci_ers_result_t bnxt_io_error_detected(struct pci_dev *pdev,
 					       pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct bnxt *bp = netdev_priv(netdev);
 
 	netdev_info(netdev, "PCI I/O error detected\n");
 
 	rtnl_lock();
 	netif_device_detach(netdev);
 
+	bnxt_ulp_stop(bp);
+
 	if (state == pci_channel_io_perm_failure) {
 		rtnl_unlock();
 		return PCI_ERS_RESULT_DISCONNECT;
@@ -7195,8 +7226,10 @@ static pci_ers_result_t bnxt_io_slot_reset(struct pci_dev *pdev)
 		if (!err && netif_running(netdev))
 			err = bnxt_open(netdev);
 
-		if (!err)
+		if (!err) {
 			result = PCI_ERS_RESULT_RECOVERED;
+			bnxt_ulp_start(bp);
+		}
 	}
 
 	if (result != PCI_ERS_RESULT_RECOVERED && netif_running(netdev))
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index eec2415..16defe9 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -972,6 +972,9 @@ struct bnxt {
 #define BNXT_SINGLE_PF(bp)	(BNXT_PF(bp) && !BNXT_NPAR(bp))
 #define BNXT_CHIP_TYPE_NITRO_A0(bp) ((bp)->flags & BNXT_FLAG_CHIP_NITRO_A0)
 
+	struct bnxt_en_dev	*edev;
+	struct bnxt_en_dev *	(*ulp_probe)(struct net_device *);
+
 	struct bnxt_napi	**bnapi;
 
 	struct bnxt_rx_ring_info	*rx_ring;
@@ -1242,9 +1245,12 @@ static inline void bnxt_disable_poll(struct bnxt_napi *bnapi)
 int hwrm_send_message_silent(struct bnxt *, void *, u32, int);
 int bnxt_hwrm_func_rgtr_async_events(struct bnxt *bp, unsigned long *bmap,
 				     int bmap_size);
+int bnxt_hwrm_vnic_cfg(struct bnxt *bp, u16 vnic_id);
 int bnxt_hwrm_set_coal(struct bnxt *);
 unsigned int bnxt_get_max_func_stat_ctxs(struct bnxt *bp);
+void bnxt_set_max_func_stat_ctxs(struct bnxt *bp, unsigned int max);
 unsigned int bnxt_get_max_func_cp_rings(struct bnxt *bp);
+void bnxt_set_max_func_cp_rings(struct bnxt *bp, unsigned int max);
 void bnxt_set_max_func_irqs(struct bnxt *bp, unsigned int max);
 void bnxt_tx_disable(struct bnxt *bp);
 void bnxt_tx_enable(struct bnxt *bp);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c
new file mode 100644
index 0000000..781948f
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c
@@ -0,0 +1,346 @@
+/* Broadcom NetXtreme-C/E network driver.
+ *
+ * Copyright (c) 2016 Broadcom Limited
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
+#include <linux/bitops.h>
+#include <linux/irq.h>
+#include <asm/byteorder.h>
+#include <linux/bitmap.h>
+
+#include "bnxt_hsi.h"
+#include "bnxt.h"
+#include "bnxt_ulp.h"
+
+static int bnxt_register_dev(struct bnxt_en_dev *edev, int ulp_id,
+			     struct bnxt_ulp_ops *ulp_ops, void *handle)
+{
+	struct net_device *dev = edev->net;
+	struct bnxt *bp = netdev_priv(dev);
+	struct bnxt_ulp *ulp;
+
+	ASSERT_RTNL();
+	if (ulp_id >= BNXT_MAX_ULP)
+		return -EINVAL;
+
+	ulp = &edev->ulp_tbl[ulp_id];
+	if (rcu_access_pointer(ulp->ulp_ops)) {
+		netdev_err(bp->dev, "ulp id %d already registered\n", ulp_id);
+		return -EBUSY;
+	}
+	if (ulp_id == BNXT_ROCE_ULP) {
+		unsigned int max_stat_ctxs;
+
+		max_stat_ctxs = bnxt_get_max_func_stat_ctxs(bp);
+		if (max_stat_ctxs <= BNXT_MIN_ROCE_STAT_CTXS ||
+		    bp->num_stat_ctxs == max_stat_ctxs)
+			return -ENOMEM;
+		bnxt_set_max_func_stat_ctxs(bp, max_stat_ctxs -
+					    BNXT_MIN_ROCE_STAT_CTXS);
+	}
+
+	atomic_set(&ulp->ref_count, 0);
+	ulp->handle = handle;
+	rcu_assign_pointer(ulp->ulp_ops, ulp_ops);
+
+	if (ulp_id == BNXT_ROCE_ULP) {
+		if (test_bit(BNXT_STATE_OPEN, &bp->state))
+			bnxt_hwrm_vnic_cfg(bp, 0);
+	}
+
+	return 0;
+}
+
+static int bnxt_unregister_dev(struct bnxt_en_dev *edev, int ulp_id)
+{
+	struct net_device *dev = edev->net;
+	struct bnxt *bp = netdev_priv(dev);
+	struct bnxt_ulp *ulp;
+	int i;
+
+	ASSERT_RTNL();
+	if (ulp_id >= BNXT_MAX_ULP)
+		return -EINVAL;
+
+	ulp = &edev->ulp_tbl[ulp_id];
+	if (!rcu_access_pointer(ulp->ulp_ops)) {
+		netdev_err(bp->dev, "ulp id %d not registered\n", ulp_id);
+		return -EINVAL;
+	}
+	if (ulp_id == BNXT_ROCE_ULP) {
+		unsigned int max_stat_ctxs;
+
+		max_stat_ctxs = bnxt_get_max_func_stat_ctxs(bp);
+		bnxt_set_max_func_stat_ctxs(bp, max_stat_ctxs + 1);
+	}
+	if (ulp->max_async_event_id)
+		bnxt_hwrm_func_rgtr_async_events(bp, NULL, 0);
+
+	RCU_INIT_POINTER(ulp->ulp_ops, NULL);
+	synchronize_rcu();
+	ulp->max_async_event_id = 0;
+	ulp->async_events_bmap = NULL;
+	while (atomic_read(&ulp->ref_count) != 0 && i < 10) {
+		msleep(100);
+		i++;
+	}
+	return 0;
+}
+
+static int bnxt_req_msix_vecs(struct bnxt_en_dev *edev, int ulp_id,
+			      struct bnxt_msix_entry *ent, int num_msix)
+{
+	struct net_device *dev = edev->net;
+	struct bnxt *bp = netdev_priv(dev);
+	int max_idx, max_cp_rings;
+	int avail_msix, i, idx;
+
+	ASSERT_RTNL();
+	if (ulp_id != BNXT_ROCE_ULP)
+		return -EINVAL;
+
+	if (!(bp->flags & BNXT_FLAG_USING_MSIX))
+		return -ENODEV;
+
+	max_cp_rings = bnxt_get_max_func_cp_rings(bp);
+	max_idx = min_t(int, bp->total_irqs, max_cp_rings);
+	avail_msix = max_idx - bp->cp_nr_rings;
+	if (!avail_msix)
+		return -ENOMEM;
+	if (avail_msix > num_msix)
+		avail_msix = num_msix;
+
+	idx = max_idx - avail_msix;
+	for (i = 0; i < avail_msix; i++) {
+		ent[i].vector = bp->irq_tbl[idx + i].vector;
+		ent[i].ring_idx = idx + i;
+		ent[i].db_offset = (idx + i) * 0x80;
+	}
+	bnxt_set_max_func_irqs(bp, max_idx - avail_msix);
+	bnxt_set_max_func_cp_rings(bp, max_cp_rings - avail_msix);
+	edev->ulp_tbl[ulp_id].msix_requested = avail_msix;
+	return avail_msix;
+}
+
+static int bnxt_free_msix_vecs(struct bnxt_en_dev *edev, int ulp_id)
+{
+	struct net_device *dev = edev->net;
+	struct bnxt *bp = netdev_priv(dev);
+	int max_cp_rings, msix_requested;
+
+	ASSERT_RTNL();
+	if (ulp_id != BNXT_ROCE_ULP)
+		return -EINVAL;
+
+	max_cp_rings = bnxt_get_max_func_cp_rings(bp);
+	msix_requested = edev->ulp_tbl[ulp_id].msix_requested;
+	bnxt_set_max_func_cp_rings(bp, max_cp_rings + msix_requested);
+	edev->ulp_tbl[ulp_id].msix_requested = 0;
+	bnxt_set_max_func_irqs(bp, bp->total_irqs);
+	return 0;
+}
+
+void bnxt_subtract_ulp_resources(struct bnxt *bp, int ulp_id)
+{
+	ASSERT_RTNL();
+	if (bnxt_ulp_registered(bp->edev, ulp_id)) {
+		struct bnxt_en_dev *edev = bp->edev;
+		unsigned int msix_req, max;
+
+		msix_req = edev->ulp_tbl[ulp_id].msix_requested;
+		max = bnxt_get_max_func_cp_rings(bp);
+		bnxt_set_max_func_cp_rings(bp, max - msix_req);
+		max = bnxt_get_max_func_stat_ctxs(bp);
+		bnxt_set_max_func_stat_ctxs(bp, max - 1);
+	}
+}
+
+static int bnxt_send_msg(struct bnxt_en_dev *edev, int ulp_id,
+			 struct bnxt_fw_msg *fw_msg)
+{
+	struct net_device *dev = edev->net;
+	struct bnxt *bp = netdev_priv(dev);
+	struct input *req;
+	int rc;
+
+	mutex_lock(&bp->hwrm_cmd_lock);
+	req = fw_msg->msg;
+	req->resp_addr = cpu_to_le64(bp->hwrm_cmd_resp_dma_addr);
+	rc = _hwrm_send_message(bp, fw_msg->msg, fw_msg->msg_len,
+				fw_msg->timeout);
+	if (!rc) {
+		struct output *resp = bp->hwrm_cmd_resp_addr;
+		u32 len = le16_to_cpu(resp->resp_len);
+
+		if (fw_msg->resp_max_len < len)
+			len = fw_msg->resp_max_len;
+
+		memcpy(fw_msg->resp, resp, len);
+	}
+	mutex_unlock(&bp->hwrm_cmd_lock);
+	return rc;
+}
+
+static void bnxt_ulp_get(struct bnxt_ulp *ulp)
+{
+	atomic_inc(&ulp->ref_count);
+}
+
+static void bnxt_ulp_put(struct bnxt_ulp *ulp)
+{
+	atomic_dec(&ulp->ref_count);
+}
+
+void bnxt_ulp_stop(struct bnxt *bp)
+{
+	struct bnxt_en_dev *edev = bp->edev;
+	struct bnxt_ulp_ops *ops;
+	int i;
+
+	if (!edev)
+		return;
+
+	for (i = 0; i < BNXT_MAX_ULP; i++) {
+		struct bnxt_ulp *ulp = &edev->ulp_tbl[i];
+
+		rtnl_dereference(ulp->ulp_ops);
+		if (!ops || !ops->ulp_stop)
+			continue;
+		ops->ulp_stop(ulp->handle);
+	}
+}
+
+void bnxt_ulp_start(struct bnxt *bp)
+{
+	struct bnxt_en_dev *edev = bp->edev;
+	struct bnxt_ulp_ops *ops;
+	int i;
+
+	if (!edev)
+		return;
+
+	for (i = 0; i < BNXT_MAX_ULP; i++) {
+		struct bnxt_ulp *ulp = &edev->ulp_tbl[i];
+
+		ops = rtnl_dereference(ulp->ulp_ops);
+		if (!ops || !ops->ulp_start)
+			continue;
+		ops->ulp_start(ulp->handle);
+	}
+}
+
+void bnxt_ulp_sriov_cfg(struct bnxt *bp, int num_vfs)
+{
+	struct bnxt_en_dev *edev = bp->edev;
+	struct bnxt_ulp_ops *ops;
+	int i;
+
+	if (!edev)
+		return;
+
+	for (i = 0; i < BNXT_MAX_ULP; i++) {
+		struct bnxt_ulp *ulp = &edev->ulp_tbl[i];
+
+		rcu_read_lock();
+		ops = rcu_dereference(ulp->ulp_ops);
+		if (!ops || !ops->ulp_sriov_config) {
+			rcu_read_unlock();
+			continue;
+		}
+		bnxt_ulp_get(ulp);
+		rcu_read_unlock();
+		ops->ulp_sriov_config(ulp->handle, num_vfs);
+		bnxt_ulp_put(ulp);
+	}
+}
+
+void bnxt_ulp_async_events(struct bnxt *bp, struct hwrm_async_event_cmpl *cmpl)
+{
+	u16 event_id = le16_to_cpu(cmpl->event_id);
+	struct bnxt_en_dev *edev = bp->edev;
+	struct bnxt_ulp_ops *ops;
+	int i;
+
+	if (!edev)
+		return;
+
+	rcu_read_lock();
+	for (i = 0; i < BNXT_MAX_ULP; i++) {
+		struct bnxt_ulp *ulp = &edev->ulp_tbl[i];
+
+		ops = rcu_dereference(ulp->ulp_ops);
+		if (!ops || !ops->ulp_async_notifier)
+			continue;
+		if (!ulp->async_events_bmap ||
+		    event_id > ulp->max_async_event_id)
+			continue;
+
+		/* Read max_async_event_id first before testing the bitmap. */
+		smp_rmb();
+		if (test_bit(event_id, ulp->async_events_bmap))
+			ops->ulp_async_notifier(ulp->handle, cmpl);
+	}
+	rcu_read_unlock();
+}
+
+static int bnxt_register_async_events(struct bnxt_en_dev *edev, int ulp_id,
+				      unsigned long *events_bmap, u16 max_id)
+{
+	struct net_device *dev = edev->net;
+	struct bnxt *bp = netdev_priv(dev);
+	struct bnxt_ulp *ulp;
+
+	if (ulp_id >= BNXT_MAX_ULP)
+		return -EINVAL;
+
+	ulp = &edev->ulp_tbl[ulp_id];
+	ulp->async_events_bmap = events_bmap;
+	/* Make sure bnxt_ulp_async_events() sees this order */
+	smp_wmb();
+	ulp->max_async_event_id = max_id;
+	bnxt_hwrm_func_rgtr_async_events(bp, events_bmap, max_id + 1);
+	return 0;
+}
+
+static const struct bnxt_en_ops bnxt_en_ops_tbl = {
+	.bnxt_register_device	= bnxt_register_dev,
+	.bnxt_unregister_device	= bnxt_unregister_dev,
+	.bnxt_request_msix	= bnxt_req_msix_vecs,
+	.bnxt_free_msix		= bnxt_free_msix_vecs,
+	.bnxt_send_fw_msg	= bnxt_send_msg,
+	.bnxt_register_fw_async_events	= bnxt_register_async_events,
+};
+
+struct bnxt_en_dev *bnxt_ulp_probe(struct net_device *dev)
+{
+	struct bnxt *bp = netdev_priv(dev);
+	struct bnxt_en_dev *edev;
+
+	edev = bp->edev;
+	if (!edev) {
+		edev = kzalloc(sizeof(*edev), GFP_KERNEL);
+		if (!edev)
+			return ERR_PTR(-ENOMEM);
+		edev->en_ops = &bnxt_en_ops_tbl;
+		if (bp->flags & BNXT_FLAG_ROCEV1_CAP)
+			edev->flags |= BNXT_EN_FLAG_ROCEV1_CAP;
+		if (bp->flags & BNXT_FLAG_ROCEV2_CAP)
+			edev->flags |= BNXT_EN_FLAG_ROCEV2_CAP;
+		edev->net = dev;
+		edev->pdev = bp->pdev;
+		bp->edev = edev;
+	}
+	return bp->edev;
+}
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.h
new file mode 100644
index 0000000..74f816e
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.h
@@ -0,0 +1,93 @@
+/* Broadcom NetXtreme-C/E network driver.
+ *
+ * Copyright (c) 2016 Broadcom Limited
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ */
+
+#ifndef BNXT_ULP_H
+#define BNXT_ULP_H
+
+#define BNXT_ROCE_ULP	0
+#define BNXT_OTHER_ULP	1
+#define BNXT_MAX_ULP	2
+
+#define BNXT_MIN_ROCE_CP_RINGS	2
+#define BNXT_MIN_ROCE_STAT_CTXS	1
+
+struct hwrm_async_event_cmpl;
+struct bnxt;
+
+struct bnxt_ulp_ops {
+	/* async_notifier() cannot sleep (in BH context) */
+	void (*ulp_async_notifier)(void *, struct hwrm_async_event_cmpl *);
+	void (*ulp_stop)(void *);
+	void (*ulp_start)(void *);
+	void (*ulp_sriov_config)(void *, int);
+};
+
+struct bnxt_msix_entry {
+	u32	vector;
+	u32	ring_idx;
+	u32	db_offset;
+};
+
+struct bnxt_fw_msg {
+	void	*msg;
+	int	msg_len;
+	void	*resp;
+	int	resp_max_len;
+	int	timeout;
+};
+
+struct bnxt_ulp {
+	void		*handle;
+	struct bnxt_ulp_ops __rcu *ulp_ops;
+	unsigned long	*async_events_bmap;
+	u16		max_async_event_id;
+	u16		msix_requested;
+	atomic_t	ref_count;
+};
+
+struct bnxt_en_dev {
+	struct net_device *net;
+	struct pci_dev *pdev;
+	u32 flags;
+	#define BNXT_EN_FLAG_ROCEV1_CAP		0x1
+	#define BNXT_EN_FLAG_ROCEV2_CAP		0x2
+	#define BNXT_EN_FLAG_ROCE_CAP		(BNXT_EN_FLAG_ROCEV1_CAP | \
+						 BNXT_EN_FLAG_ROCEV2_CAP)
+	const struct bnxt_en_ops	*en_ops;
+	struct bnxt_ulp			ulp_tbl[BNXT_MAX_ULP];
+};
+
+struct bnxt_en_ops {
+	int (*bnxt_register_device)(struct bnxt_en_dev *, int,
+				    struct bnxt_ulp_ops *, void *);
+	int (*bnxt_unregister_device)(struct bnxt_en_dev *, int);
+	int (*bnxt_request_msix)(struct bnxt_en_dev *, int,
+				 struct bnxt_msix_entry *, int);
+	int (*bnxt_free_msix)(struct bnxt_en_dev *, int);
+	int (*bnxt_send_fw_msg)(struct bnxt_en_dev *, int,
+				struct bnxt_fw_msg *);
+	int (*bnxt_register_fw_async_events)(struct bnxt_en_dev *, int,
+					     unsigned long *, u16);
+};
+
+static inline bool bnxt_ulp_registered(struct bnxt_en_dev *edev, int ulp_id)
+{
+	if (edev && rcu_access_pointer(edev->ulp_tbl[ulp_id].ulp_ops))
+		return true;
+	return false;
+}
+
+void bnxt_subtract_ulp_resources(struct bnxt *bp, int ulp_id);
+void bnxt_ulp_stop(struct bnxt *bp);
+void bnxt_ulp_start(struct bnxt *bp);
+void bnxt_ulp_sriov_cfg(struct bnxt *bp, int num_vfs);
+void bnxt_ulp_async_events(struct bnxt *bp, struct hwrm_async_event_cmpl *cmpl);
+struct bnxt_en_dev *bnxt_ulp_probe(struct net_device *dev);
+
+#endif
-- 
1.8.3.1
