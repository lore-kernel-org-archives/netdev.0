From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 7/9] vxge: Allow multiple functions with INTA.
Date: Mon, 5 Oct 2009 07:57:29 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10910050756360.9377-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:42058 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758811AbZJEMAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 08:00:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Allow multiple functions with INTA.
- Removed the condition to allow only one vpath with INTA
- Ensure that the alarm bit in titan_mask_all_int register is cleared when
  driver exits.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
diff -urpN patch6/drivers/net/vxge/vxge-config.c patch7/drivers/net/vxge/vxge-config.cllow multiple functions with INTA.
- Removed the condition to allow only one vpath with INTA
- Ensure that the alarm bit in titan_mask_all_int register is cleared when
  driver exits.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
--- patch6/drivers/net/vxge/vxge-config.c	2009-09-04 01:33:43.000000000 -0700
+++ patch7/drivers/net/vxge/vxge-config.c	2009-09-04 02:11:29.000000000 -0700
@@ -3882,6 +3882,30 @@ __vxge_hw_vpath_tim_configure(struct __v
 	return status;
 }
 
+void
+vxge_hw_vpath_tti_ci_set(struct __vxge_hw_device *hldev, u32 vp_id)
+{
+	struct __vxge_hw_virtualpath *vpath;
+	struct vxge_hw_vpath_reg __iomem *vp_reg;
+	struct vxge_hw_vp_config *config;
+	u64 val64;
+
+	vpath = &hldev->virtual_paths[vp_id];
+	vp_reg = vpath->vp_reg;
+	config = vpath->vp_config;
+
+	if (config->fifo.enable == VXGE_HW_FIFO_ENABLE) {
+		val64 = readq(&vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_TX]);
+
+		if (config->tti.timer_ci_en != VXGE_HW_TIM_TIMER_CI_ENABLE) {
+			config->tti.timer_ci_en = VXGE_HW_TIM_TIMER_CI_ENABLE;
+			val64 |= VXGE_HW_TIM_CFG1_INT_NUM_TIMER_CI;
+			writeq(val64,
+			&vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_TX]);
+		}
+	}
+	return;
+}
 /*
  * __vxge_hw_vpath_initialize
  * This routine is the final phase of init which initializes the
diff -urpN patch6/drivers/net/vxge/vxge-main.c patch7/drivers/net/vxge/vxge-main.c
--- patch6/drivers/net/vxge/vxge-main.c	2009-09-04 01:31:12.000000000 -0700
+++ patch7/drivers/net/vxge/vxge-main.c	2009-09-04 02:13:34.000000000 -0700
@@ -2435,7 +2435,6 @@ static int vxge_add_isr(struct vxgedev *
 	int ret = 0;
 #ifdef CONFIG_PCI_MSI
 	int vp_idx = 0, intr_idx = 0, intr_cnt = 0, msix_idx = 0, irq_req = 0;
-	u64 function_mode = vdev->config.device_hw_info.function_mode;
 	int pci_fun = PCI_FUNC(vdev->pdev->devfn);
 
 	if (vdev->config.intr_type == MSI_X)
@@ -2444,20 +2443,9 @@ static int vxge_add_isr(struct vxgedev *
 	if (ret) {
 		vxge_debug_init(VXGE_ERR,
 			"%s: Enabling MSI-X Failed", VXGE_DRIVER_NAME);
-		if ((function_mode == VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION) &&
-			test_and_set_bit(__VXGE_STATE_CARD_UP,
-				&driver_config->inta_dev_open))
-			return VXGE_HW_FAIL;
-		else {
-			vxge_debug_init(VXGE_ERR,
-				"%s: Defaulting to INTA", VXGE_DRIVER_NAME);
-			vdev->config.intr_type = INTA;
-			vxge_hw_device_set_intr_type(vdev->devh,
-				VXGE_HW_INTR_MODE_IRQLINE);
-			vxge_close_vpaths(vdev, 1);
-			vdev->no_of_vpath = 1;
-			vdev->stats.vpaths_open = 1;
-		}
+		vxge_debug_init(VXGE_ERR,
+			"%s: Defaulting to INTA", VXGE_DRIVER_NAME);
+		vdev->config.intr_type = INTA;
 	}
 
 	if (vdev->config.intr_type == MSI_X) {
@@ -2505,24 +2493,11 @@ static int vxge_add_isr(struct vxgedev *
 					"%s: MSIX - %d  Registration failed",
 					vdev->ndev->name, intr_cnt);
 				vxge_rem_msix_isr(vdev);
-				if ((function_mode ==
-					VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION) &&
-					test_and_set_bit(__VXGE_STATE_CARD_UP,
-						&driver_config->inta_dev_open))
-					return VXGE_HW_FAIL;
-				else {
-					vxge_hw_device_set_intr_type(
-						vdev->devh,
-						VXGE_HW_INTR_MODE_IRQLINE);
-						vdev->config.intr_type = INTA;
-					vxge_debug_init(VXGE_ERR,
-						"%s: Defaulting to INTA"
-						, vdev->ndev->name);
-					vxge_close_vpaths(vdev, 1);
-					vdev->no_of_vpath = 1;
-					vdev->stats.vpaths_open = 1;
+				vdev->config.intr_type = INTA;
+				vxge_debug_init(VXGE_ERR,
+					"%s: Defaulting to INTA"
+					, vdev->ndev->name);
 					goto INTA_MODE;
-				}
 			}
 
 			if (irq_req) {
@@ -2555,23 +2530,11 @@ static int vxge_add_isr(struct vxgedev *
 				"%s: MSIX - %d Registration failed",
 				vdev->ndev->name, intr_cnt);
 			vxge_rem_msix_isr(vdev);
-			if ((function_mode ==
-				VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION) &&
-				test_and_set_bit(__VXGE_STATE_CARD_UP,
-						&driver_config->inta_dev_open))
-				return VXGE_HW_FAIL;
-			else {
-				vxge_hw_device_set_intr_type(vdev->devh,
-						VXGE_HW_INTR_MODE_IRQLINE);
-				vdev->config.intr_type = INTA;
-				vxge_debug_init(VXGE_ERR,
-					"%s: Defaulting to INTA",
-					vdev->ndev->name);
-				vxge_close_vpaths(vdev, 1);
-				vdev->no_of_vpath = 1;
-				vdev->stats.vpaths_open = 1;
+			vdev->config.intr_type = INTA;
+			vxge_debug_init(VXGE_ERR,
+				"%s: Defaulting to INTA",
+				vdev->ndev->name);
 				goto INTA_MODE;
-			}
 		}
 
 		vxge_hw_vpath_msix_unmask(vdev->vpaths[vp_idx].handle,
@@ -2584,6 +2547,10 @@ INTA_MODE:
 	snprintf(vdev->desc[0], VXGE_INTR_STRLEN, "%s:vxge", vdev->ndev->name);
 
 	if (vdev->config.intr_type == INTA) {
+		vxge_hw_device_set_intr_type(vdev->devh,
+			VXGE_HW_INTR_MODE_IRQLINE);
+		vxge_hw_vpath_tti_ci_set(vdev->devh,
+			vdev->vpaths[0].device_id);
 		ret = request_irq((int) vdev->pdev->irq,
 			vxge_isr_napi,
 			IRQF_SHARED, vdev->desc[0], vdev);
@@ -2688,13 +2655,6 @@ vxge_open(struct net_device *dev)
 	 * initialized */
 	netif_carrier_off(dev);
 
-	/* Check for another device already opn with INTA */
-	if ((function_mode == VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION) &&
-		test_bit(__VXGE_STATE_CARD_UP, &driver_config->inta_dev_open)) {
-		ret = -EPERM;
-		goto out0;
-	}
-
 	/* Open VPATHs */
 	status = vxge_open_vpaths(vdev);
 	if (status != VXGE_HW_OK) {
@@ -2983,7 +2943,6 @@ int do_vxge_close(struct net_device *dev
 	vxge_debug_entryexit(VXGE_TRACE,
 		"%s: %s:%d  Exiting...", dev->name, __func__, __LINE__);
 
-	clear_bit(__VXGE_STATE_CARD_UP, &driver_config->inta_dev_open);
 	clear_bit(__VXGE_STATE_RESET_CARD, &vdev->state);
 
 	return 0;
@@ -4397,6 +4356,27 @@ vxge_probe(struct pci_dev *pdev, const s
 	}
 
 	kfree(device_config);
+
+	/*
+	 * INTA is shared in multi-function mode. This is unlike the INTA
+	 * implementation in MR mode, where each VH has its own INTA message.
+	 * - INTA is masked (disabled) as long as at least one function sets
+	 * its TITAN_MASK_ALL_INT.ALARM bit.
+	 * - INTA is unmasked (enabled) when all enabled functions have cleared
+	 * their own TITAN_MASK_ALL_INT.ALARM bit.
+	 * The TITAN_MASK_ALL_INT ALARM & TRAFFIC bits are cleared on power up.
+	 * Though this driver leaves the top level interrupts unmasked while
+	 * leaving the required module interrupt bits masked on exit, there
+	 * could be a rougue driver around that does not follow this procedure
+	 * resulting in a failure to generate interrupts. The following code is
+	 * present to prevent such a failure.
+	 */
+
+	if (ll_config.device_hw_info.function_mode ==
+		VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION)
+		if (vdev->config.intr_type == INTA)
+			vxge_hw_device_unmask_all(hldev);
+
 	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d  Exiting...",
 		vdev->ndev->name, __func__, __LINE__);
 
diff -urpN patch6/drivers/net/vxge/vxge-main.h patch7/drivers/net/vxge/vxge-main.h
--- patch6/drivers/net/vxge/vxge-main.h	2009-09-04 01:25:50.000000000 -0700
+++ patch7/drivers/net/vxge/vxge-main.h	2009-09-04 02:05:36.000000000 -0700
@@ -112,7 +112,6 @@ enum vxge_mac_addr_state {
 struct vxge_drv_config {
 	int config_dev_cnt;
 	int total_dev_cnt;
-	unsigned long inta_dev_open;
 	int g_no_cpus;
 	unsigned int vpath_per_dev;
 };
diff -urpN patch6/drivers/net/vxge/vxge-traffic.c patch7/drivers/net/vxge/vxge-traffic.c
--- patch6/drivers/net/vxge/vxge-traffic.c	2009-09-04 01:25:50.000000000 -0700
+++ patch7/drivers/net/vxge/vxge-traffic.c	2009-09-04 02:06:25.000000000 -0700
@@ -295,6 +295,8 @@ void vxge_hw_device_intr_enable(struct _
 	u64 val64;
 	u32 val32;
 
+	vxge_hw_device_mask_all(hldev);
+
 	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
 
 		if (!(hldev->vpaths_deployed & vxge_mBIT(i)))
diff -urpN patch6/drivers/net/vxge/vxge-traffic.h patch7/drivers/net/vxge/vxge-traffic.h
--- patch6/drivers/net/vxge/vxge-traffic.h	2009-09-04 01:25:50.000000000 -0700
+++ patch7/drivers/net/vxge/vxge-traffic.h	2009-09-04 02:07:28.000000000 -0700
@@ -2389,6 +2389,8 @@ vxge_hw_channel_dtr_free(struct __vxge_h
 
 int
 vxge_hw_channel_dtr_count(struct __vxge_hw_channel *channel);
+void
+vxge_hw_vpath_tti_ci_set(struct __vxge_hw_device *hldev, u32 vp_id);
 
 /* ========================== PRIVATE API ================================= */
 

