From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 02/11] vxge: Wait for Rx to become idle before reseting or closing
Date: Thu, 28 Oct 2010 21:19:37 -0500
Message-ID: <1288318786-12319-2-git-send-email-jon.mason@exar.com>
References: <1288318786-12319-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:37304 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759518Ab0J2CTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 22:19:55 -0400
Received: by mail-gy0-f174.google.com with SMTP id 4so1700548gyg.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 19:19:54 -0700 (PDT)
In-Reply-To: <1288318786-12319-1-git-send-email-jon.mason@exar.com>
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
 drivers/net/vxge/vxge-main.c   |   16 ++++++--
 drivers/net/vxge/vxge-reg.h    |    1 +
 4 files changed, 103 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index 25f0938..dfc4d37 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -20,6 +20,88 @@
 #include "vxge-traffic.h"
 #include "vxge-config.h"
 
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
@@ -217,7 +299,7 @@ __vxge_hw_device_register_poll(void __iomem *reg, u64 mask, u32 max_millis)
 	return ret;
 }
 
- /* __vxge_hw_device_vpath_reset_in_prog_check - Check if vpath reset
+/* __vxge_hw_device_vpath_reset_in_prog_check - Check if vpath reset
  * in progress
  * This routine checks the vpath reset in progress register is turned zero
  */
@@ -1006,7 +1088,6 @@ exit:
  * It can be used to set or reset Pause frame generation or reception
  * support of the NIC.
  */
-
 enum vxge_hw_status vxge_hw_device_setpause_data(struct __vxge_hw_device *hldev,
 						 u32 port, u32 tx, u32 rx)
 {
@@ -1250,7 +1331,6 @@ exit:
 /*
  * __vxge_hw_ring_create - Create a Ring
  * This function creates Ring and initializes it.
- *
  */
 enum vxge_hw_status
 __vxge_hw_ring_create(struct __vxge_hw_vpath_handle *vp,
diff --git a/drivers/net/vxge/vxge-config.h b/drivers/net/vxge/vxge-config.h
index 66c6773..eaa38e6 100644
--- a/drivers/net/vxge/vxge-config.h
+++ b/drivers/net/vxge/vxge-config.h
@@ -2276,4 +2276,11 @@ enum vxge_hw_status vxge_hw_vpath_rts_rth_set(
 
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
index 8a59fe9..d977a63 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -1289,8 +1289,13 @@ void vxge_vpath_intr_enable(struct vxgedev *vdev, int vp_id)
 void vxge_vpath_intr_disable(struct vxgedev *vdev, int vp_id)
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
@@ -1420,6 +1425,7 @@ static int do_vxge_reset(struct vxgedev *vdev, int event)
 	}
 
 	if (event == VXGE_LL_FULL_RESET) {
+		vxge_hw_device_wait_receive_idle(vdev->devh);
 		vxge_hw_device_intr_disable(vdev->devh);
 
 		switch (vdev->cric_err_event) {
@@ -2068,7 +2074,7 @@ static irqreturn_t vxge_isr_napi(int irq, void *dev_id)
 		return IRQ_NONE;
 
 	if (unlikely(!is_vxge_card_up(vdev)))
-		return IRQ_NONE;
+		return IRQ_HANDLED;
 
 	status = vxge_hw_device_begin_irq(hldev, vdev->exec_mode,
 			&reason);
@@ -2775,7 +2781,6 @@ int do_vxge_close(struct net_device *dev, int do_io)
 	while (test_and_set_bit(__VXGE_STATE_RESET_CARD, &vdev->state))
 		msleep(50);
 
-	clear_bit(__VXGE_STATE_CARD_UP, &vdev->state);
 	if (do_io) {
 		/* Put the vpath back in normal mode */
 		vpath_vector = vxge_mBIT(vdev->vpaths[0].device_id);
@@ -2819,6 +2824,11 @@ int do_vxge_close(struct net_device *dev, int do_io)
 
 	del_timer_sync(&vdev->vp_reset_timer);
 
+	if (do_io)
+		vxge_hw_device_wait_receive_idle(hldev);
+
+	clear_bit(__VXGE_STATE_CARD_UP, &vdev->state);
+
 	/* Disable napi */
 	if (vdev->config.intr_type != MSI_X)
 		napi_disable(&vdev->napi);
@@ -2835,8 +2845,6 @@ int do_vxge_close(struct net_device *dev, int do_io)
 	if (do_io)
 		vxge_hw_device_intr_disable(vdev->devh);
 
-	mdelay(1000);
-
 	vxge_rem_isr(vdev);
 
 	vxge_napi_del_all(vdev);
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

