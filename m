From: Jon Mason <jdmason@kudzu.us>
Subject: [net-next PATCH 2/3] vxge: spin-lock issue
Date: Fri,  8 Apr 2011 16:11:22 -0500
Message-ID: <1302297083-22665-2-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:61650 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757969Ab1DHVLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 17:11:30 -0400
Received: by ywj3 with SMTP id 3so1588416ywj.19
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2011 14:11:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In vxge_hw_vpath_close, __vxge_hw_vp_terminate memsets the vpath which
clobbers the spin lock state, then the driver attempts to acquire the
spin lock.  Resolve this by not zeroing the lock part of vpath struct,
clean-up vpath locking in init, close, and fix locking hole in fw_api
call.

Issue found by Bob Picco <bpicco@redhat.com>

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/vxge/vxge-config.c |   48 ++++++++++++++++++++++++++-------------
 1 files changed, 32 insertions(+), 16 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index e74e4b4..77d0e81 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -159,16 +159,15 @@ vxge_hw_vpath_fw_api(struct __vxge_hw_virtualpath *vpath, u32 action,
 		     u32 fw_memo, u32 offset, u64 *data0, u64 *data1,
 		     u64 *steer_ctrl)
 {
-	struct vxge_hw_vpath_reg __iomem *vp_reg;
+	struct vxge_hw_vpath_reg __iomem *vp_reg = vpath->vp_reg;
 	enum vxge_hw_status status;
 	u64 val64;
-	u32 retry = 0, max_retry = 100;
-
-	vp_reg = vpath->vp_reg;
+	u32 retry = 0, max_retry = 3;
 
-	if (vpath->vp_open) {
-		max_retry = 3;
-		spin_lock(&vpath->lock);
+	spin_lock(&vpath->lock);
+	if (!vpath->vp_open) {
+		spin_unlock(&vpath->lock);
+		max_retry = 100;
 	}
 
 	writeq(*data0, &vp_reg->rts_access_steer_data0);
@@ -1000,7 +999,7 @@ exit:
 /**
  * vxge_hw_device_hw_info_get - Get the hw information
  * Returns the vpath mask that has the bits set for each vpath allocated
- * for the driver, FW version information and the first mac addresse for
+ * for the driver, FW version information, and the first mac address for
  * each vpath
  */
 enum vxge_hw_status __devinit
@@ -1064,9 +1063,10 @@ vxge_hw_device_hw_info_get(void __iomem *bar0,
 
 		val64 = readq(&toc->toc_vpath_pointer[i]);
 
+		spin_lock_init(&vpath.lock);
 		vpath.vp_reg = (struct vxge_hw_vpath_reg __iomem *)
 			       (bar0 + val64);
-		vpath.vp_open = 0;
+		vpath.vp_open = VXGE_HW_VP_NOT_OPEN;
 
 		status = __vxge_hw_vpath_pci_func_mode_get(&vpath, hw_info);
 		if (status != VXGE_HW_OK)
@@ -1090,7 +1090,7 @@ vxge_hw_device_hw_info_get(void __iomem *bar0,
 		val64 = readq(&toc->toc_vpath_pointer[i]);
 		vpath.vp_reg = (struct vxge_hw_vpath_reg __iomem *)
 			       (bar0 + val64);
-		vpath.vp_open = 0;
+		vpath.vp_open = VXGE_HW_VP_NOT_OPEN;
 
 		status =  __vxge_hw_vpath_addr_get(&vpath,
 				hw_info->mac_addrs[i],
@@ -4646,7 +4646,27 @@ static void __vxge_hw_vp_terminate(struct __vxge_hw_device *hldev, u32 vp_id)
 		vpath->hldev->tim_int_mask1, vpath->vp_id);
 	hldev->stats.hw_dev_info_stats.vpath_info[vpath->vp_id] = NULL;
 
-	memset(vpath, 0, sizeof(struct __vxge_hw_virtualpath));
+	/* If the whole struct __vxge_hw_virtualpath is zeroed, nothing will
+	 * work after the interface is brought down.
+	 */
+	spin_lock(&vpath->lock);
+	vpath->vp_open = VXGE_HW_VP_NOT_OPEN;
+	spin_unlock(&vpath->lock);
+
+	vpath->vpmgmt_reg = NULL;
+	vpath->nofl_db = NULL;
+	vpath->max_mtu = 0;
+	vpath->vsport_number = 0;
+	vpath->max_kdfc_db = 0;
+	vpath->max_nofl_db = 0;
+	vpath->ringh = NULL;
+	vpath->fifoh = NULL;
+	memset(&vpath->vpath_handles, 0, sizeof(struct list_head));
+	vpath->stats_block = 0;
+	vpath->hw_stats = NULL;
+	vpath->hw_stats_sav = NULL;
+	vpath->sw_stats = NULL;
+
 exit:
 	return;
 }
@@ -4670,7 +4690,7 @@ __vxge_hw_vp_initialize(struct __vxge_hw_device *hldev, u32 vp_id,
 
 	vpath = &hldev->virtual_paths[vp_id];
 
-	spin_lock_init(&hldev->virtual_paths[vp_id].lock);
+	spin_lock_init(&vpath->lock);
 	vpath->vp_id = vp_id;
 	vpath->vp_open = VXGE_HW_VP_OPEN;
 	vpath->hldev = hldev;
@@ -5019,10 +5039,6 @@ enum vxge_hw_status vxge_hw_vpath_close(struct __vxge_hw_vpath_handle *vp)
 
 	__vxge_hw_vp_terminate(devh, vp_id);
 
-	spin_lock(&vpath->lock);
-	vpath->vp_open = VXGE_HW_VP_NOT_OPEN;
-	spin_unlock(&vpath->lock);
-
 vpath_close_exit:
 	return status;
 }
-- 
1.7.0.4

