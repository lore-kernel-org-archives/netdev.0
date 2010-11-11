From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 02/12] vxge: Wait for Rx to become idle before reseting or closing
Date: Thu, 11 Nov 2010 08:25:54 -0600
Message-ID: <1289485564-8822-3-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:59414 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756568Ab0KKO0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 09:26:38 -0500
Received: by gxk23 with SMTP id 23so1162393gxk.19
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 06:26:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wait for the receive traffic to become idle before attempting to close
or reset the adapter.  To enable the processing of packets while Receive
Idle, move the clearing of __VXGE_STATE_CARD_UP bit in vxge_close to
after it.  Also, modify the return value of the ISR when the adapter is
down to IRQ_HANDLED.  Otherwise there are unhandled interrupts for the
device.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-config.c |   86 ++++++++++++++++++++++++++++++++++++++-
 drivers/net/vxge/vxge-config.h |    7 +++
 drivers/net/vxge/vxge-main.c   |   19 ++++++---
 drivers/net/vxge/vxge-main.h   |    2 +
 drivers/net/vxge/vxge-reg.h    |    1 +
 5 files changed, 106 insertions(+), 9 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index 0a35ab1..212e301 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -193,6 +193,88 @@ static enum vxge_hw_status
 __vxge_hw_vpath_xmac_rx_stats_get(struct __vxge_hw_virtualpath	*vpath,
 				  struct vxge_hw_xmac_vpath_rx_stats *vpath_rx_stats);
 
+static void
+vxge_hw_vpath_set_zero_rx_frm_len(struct vxge_hw_vpath_reg __iomem *vp_reg)
+{
+	u64 val64;
+
+	val64 = readq(&vp_reg->rxmac_vcfg0);
+	val64 &= ~VXGE_HW_RXMAC_VCFG0_RTS_MAX_FRM_LEN(0x3fff);
+	writeq(val64, &vp_reg->rxmac_vcfg0);
+	val64 = readq(&vp_reg->rxmac_vcfg0);
+
+	return;
+}
+
+/*
+ * vxge_hw_vpath_wait_receive_idle - Wait for Rx to become idle
+ */
+int vxge_hw_vpath_wait_receive_idle(struct __vxge_hw_device *hldev, u32 vp_id)
+{
+	struct vxge_hw_vpath_reg __iomem *vp_reg;
+	struct __vxge_hw_virtualpath *vpath;
+	u64 val64, rxd_count, rxd_spat;
+	int count = 0, total_count = 0;
+
+	vpath = &hldev->virtual_paths[vp_id];
+	vp_reg = vpath->vp_reg;
+
+	vxge_hw_vpath_set_zero_rx_frm_len(vp_reg);
+
+	/* Check that the ring controller for this vpath has enough free RxDs
+	 * to send frames to the host.  This is done by reading the
+	 * PRC_RXD_DOORBELL_VPn register and comparing the read value to the
+	 * RXD_SPAT value for the vpath.
+	 */
+	val64 = readq(&vp_reg->prc_cfg6);
+	rxd_spat = VXGE_HW_PRC_CFG6_GET_RXD_SPAT(val64) + 1;
+	/* Use a factor of 2 when comparing rxd_count against rxd_spat for some
+	 * leg room.
+	 */
+	rxd_spat *= 2;
+
+	do {
+		mdelay(1);
+
+		rxd_count = readq(&vp_reg->prc_rxd_doorbell);
+
+		/* Check that the ring controller for this vpath does
+		 * not have any frame in its pipeline.
+		 */
+		val64 = readq(&vp_reg->frm_in_progress_cnt);
+		if ((rxd_count <= rxd_spat) || (val64 > 0))
+			count = 0;
+		else
+			count++;
+		total_count++;
+	} while ((count < VXGE_HW_MIN_SUCCESSIVE_IDLE_COUNT) &&
+			(total_count < VXGE_HW_MAX_POLLING_COUNT));
+
+	if (total_count >= VXGE_HW_MAX_POLLING_COUNT)
+		printk(KERN_ALERT "%s: Still Receiving traffic. Abort wait\n",
+			__func__);
+
+	return total_count;
+}
+
+/* vxge_hw_device_wait_receive_idle - This function waits until all frames
+ * stored in the frame buffer for each vpath assigned to the given
+ * function (hldev) have been sent to the host.
+ */
+void vxge_hw_device_wait_receive_idle(struct __vxge_hw_device *hldev)
+{
+	int i, total_count = 0;
+
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+		if (!(hldev->vpaths_deployed & vxge_mBIT(i)))
+			continue;
+
+		total_count += vxge_hw_vpath_wait_receive_idle(hldev, i);
+		if (total_count >= VXGE_HW_MAX_POLLING_COUNT)
+			break;
+	}
+}
+
 /*
  * __vxge_hw_channel_allocate - Allocate memory for channel
  * This function allocates required memory for the channel and various arrays
@@ -390,7 +472,7 @@ __vxge_hw_device_register_poll(void __iomem *reg, u64 mask, u32 max_millis)
 	return ret;
 }
 
- /* __vxge_hw_device_vpath_reset_in_prog_check - Check if vpath reset
+/* __vxge_hw_device_vpath_reset_in_prog_check - Check if vpath reset
  * in progress
  * This routine checks the vpath reset in progress register is turned zero
  */
@@ -1165,7 +1247,6 @@ exit:
  * It can be used to set or reset Pause frame generation or reception
  * support of the NIC.
  */
-
 enum vxge_hw_status vxge_hw_device_setpause_data(struct __vxge_hw_device *hldev,
 						 u32 port, u32 tx, u32 rx)
 {
@@ -1409,7 +1490,6 @@ exit:
 /*
  * __vxge_hw_ring_create - Create a Ring
  * This function creates Ring and initializes it.
- *
  */
 static enum vxge_hw_status
 __vxge_hw_ring_create(struct __vxge_hw_vpath_handle *vp,
diff --git a/drivers/net/vxge/vxge-config.h b/drivers/net/vxge/vxge-config.h
index 5d77905..95e7021 100644
--- a/drivers/net/vxge/vxge-config.h
+++ b/drivers/net/vxge/vxge-config.h
@@ -2051,4 +2051,11 @@ enum vxge_hw_status vxge_hw_vpath_rts_rth_set(
 
 enum vxge_hw_status
 __vxge_hw_device_is_privilaged(u32 host_type, u32 func_id);
+
+#define VXGE_HW_MIN_SUCCESSIVE_IDLE_COUNT 5
+#define VXGE_HW_MAX_POLLING_COUNT 100
+
+int vxge_hw_vpath_wait_receive_idle(struct __vxge_hw_device *hldev, u32 vp_id);
+
+void  vxge_hw_device_wait_receive_idle(struct __vxge_hw_device *hldev);
 #endif
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 2f26c37..53db6a4 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -90,7 +90,6 @@ static int vxge_mac_list_add(struct vxge_vpath *vpath, struct macInfo *mac);
 static int vxge_mac_list_del(struct vxge_vpath *vpath, struct macInfo *mac);
 static enum vxge_hw_status vxge_restore_vpath_vid_table(struct vxge_vpath *vpath);
 static enum vxge_hw_status vxge_restore_vpath_mac_addr(struct vxge_vpath *vpath);
-static enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev);
 
 static inline int is_vxge_card_up(struct vxgedev *vdev)
 {
@@ -1299,8 +1298,13 @@ static void vxge_vpath_intr_enable(struct vxgedev *vdev, int vp_id)
 static void vxge_vpath_intr_disable(struct vxgedev *vdev, int vp_id)
 {
 	struct vxge_vpath *vpath = &vdev->vpaths[vp_id];
+	struct __vxge_hw_device *hldev;
 	int msix_id;
 
+	hldev = (struct __vxge_hw_device *)pci_get_drvdata(vdev->pdev);
+
+	vxge_hw_vpath_wait_receive_idle(hldev, vpath->device_id);
+
 	vxge_hw_vpath_intr_disable(vpath->handle);
 
 	if (vdev->config.intr_type == INTA)
@@ -1430,6 +1434,7 @@ static int do_vxge_reset(struct vxgedev *vdev, int event)
 	}
 
 	if (event == VXGE_LL_FULL_RESET) {
+		vxge_hw_device_wait_receive_idle(vdev->devh);
 		vxge_hw_device_intr_disable(vdev->devh);
 
 		switch (vdev->cric_err_event) {
@@ -1935,7 +1940,7 @@ static enum vxge_hw_status vxge_restore_vpath_mac_addr(struct vxge_vpath *vpath)
 }
 
 /* reset vpaths */
-static enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev)
+enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev)
 {
 	enum vxge_hw_status status = VXGE_HW_OK;
 	struct vxge_vpath *vpath;
@@ -2080,7 +2085,7 @@ static irqreturn_t vxge_isr_napi(int irq, void *dev_id)
 		return IRQ_NONE;
 
 	if (unlikely(!is_vxge_card_up(vdev)))
-		return IRQ_NONE;
+		return IRQ_HANDLED;
 
 	status = vxge_hw_device_begin_irq(hldev, vdev->exec_mode,
 			&reason);
@@ -2787,7 +2792,6 @@ static int do_vxge_close(struct net_device *dev, int do_io)
 	while (test_and_set_bit(__VXGE_STATE_RESET_CARD, &vdev->state))
 		msleep(50);
 
-	clear_bit(__VXGE_STATE_CARD_UP, &vdev->state);
 	if (do_io) {
 		/* Put the vpath back in normal mode */
 		vpath_vector = vxge_mBIT(vdev->vpaths[0].device_id);
@@ -2831,6 +2835,11 @@ static int do_vxge_close(struct net_device *dev, int do_io)
 
 	del_timer_sync(&vdev->vp_reset_timer);
 
+	if (do_io)
+		vxge_hw_device_wait_receive_idle(hldev);
+
+	clear_bit(__VXGE_STATE_CARD_UP, &vdev->state);
+
 	/* Disable napi */
 	if (vdev->config.intr_type != MSI_X)
 		napi_disable(&vdev->napi);
@@ -2847,8 +2856,6 @@ static int do_vxge_close(struct net_device *dev, int do_io)
 	if (do_io)
 		vxge_hw_device_intr_disable(vdev->devh);
 
-	mdelay(1000);
-
 	vxge_rem_isr(vdev);
 
 	vxge_napi_del_all(vdev);
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.h
index a4f6d86..54989d0 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -397,6 +397,8 @@ struct vxge_tx_priv {
 	} while (0);
 
 extern void vxge_initialize_ethtool_ops(struct net_device *ndev);
+enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev);
+
 /**
  * #define VXGE_DEBUG_INIT: debug for initialization functions
  * #define VXGE_DEBUG_TX	 : debug transmit related functions
diff --git a/drivers/net/vxge/vxge-reg.h b/drivers/net/vxge/vxge-reg.h
index 3dd5c96..93fd752 100644
--- a/drivers/net/vxge/vxge-reg.h
+++ b/drivers/net/vxge/vxge-reg.h
@@ -3998,6 +3998,7 @@ struct vxge_hw_vpath_reg {
 #define	VXGE_HW_PRC_CFG6_L4_CPC_TRSFR_CODE_EN	vxge_mBIT(9)
 #define VXGE_HW_PRC_CFG6_RXD_CRXDT(val) vxge_vBIT(val, 23, 9)
 #define VXGE_HW_PRC_CFG6_RXD_SPAT(val) vxge_vBIT(val, 36, 9)
+#define VXGE_HW_PRC_CFG6_GET_RXD_SPAT(val)	vxge_bVALn(val, 36, 9)
 /*0x00a78*/	u64	prc_cfg7;
 #define VXGE_HW_PRC_CFG7_SCATTER_MODE(val) vxge_vBIT(val, 6, 2)
 #define	VXGE_HW_PRC_CFG7_SMART_SCAT_EN	vxge_mBIT(11)
-- 
1.7.0.4

