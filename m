From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 5/8] vxge: Fixed MSIX interrupt configuration.
Date: Mon, 29 Mar 2010 04:11:41 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.11003290410360.4435-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:48124 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737Ab0C2IXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 04:23:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Fixed MSIX interrupt configuration to support non contiguous vpaths in
  functions. Four msi-x vectors are reserved per vpath internal to the chip.
  In all, there are 68 msi-x vectors for the 17 vpaths in the chip. In the 
  multi function configurations, non-contiguous vpaths are configured to
  represent a function. For instance vpaths 0 and 8 can be configured to
  represent function zero.

- If pci_enable_msix fails for the requested vectors, try with a lesser number
  vectors by reducing the vpath count.
 
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch4/drivers/net/vxge/vxge-main.c patch5/drivers/net/vxge/vxge-main.c
--- patch4/drivers/net/vxge/vxge-main.c	2010-03-19 16:21:17.000000000 +0530
+++ patch5/drivers/net/vxge/vxge-main.c	2010-03-19 18:00:19.000000000 +0530
@@ -1363,28 +1363,26 @@ static int vxge_set_mac_addr(struct net_
 void vxge_vpath_intr_enable(struct vxgedev *vdev, int vp_id)
 {
 	struct vxge_vpath *vpath = &vdev->vpaths[vp_id];
-	int msix_id, alarm_msix_id;
-	int tim_msix_id[4] = {[0 ...3] = 0};
+	int msix_id = 0;
+	int tim_msix_id[4] = {0, 1, 0, 0};
+	int alarm_msix_id = VXGE_ALARM_MSIX_ID;
 
 	vxge_hw_vpath_intr_enable(vpath->handle);
 
 	if (vdev->config.intr_type == INTA)
 		vxge_hw_vpath_inta_unmask_tx_rx(vpath->handle);
 	else {
-		msix_id = vp_id * VXGE_HW_VPATH_MSIX_ACTIVE;
-		alarm_msix_id =
-			VXGE_HW_VPATH_MSIX_ACTIVE * vdev->no_of_vpath - 2;
-
-		tim_msix_id[0] = msix_id;
-		tim_msix_id[1] = msix_id + 1;
 		vxge_hw_vpath_msix_set(vpath->handle, tim_msix_id,
 			alarm_msix_id);
 
+		msix_id = vpath->device_id * VXGE_HW_VPATH_MSIX_ACTIVE;
 		vxge_hw_vpath_msix_unmask(vpath->handle, msix_id);
 		vxge_hw_vpath_msix_unmask(vpath->handle, msix_id + 1);
 
 		/* enable the alarm vector */
-		vxge_hw_vpath_msix_unmask(vpath->handle, alarm_msix_id);
+		msix_id = (vpath->handle->vpath->hldev->first_vp_id *
+			VXGE_HW_VPATH_MSIX_ACTIVE) + alarm_msix_id;
+		vxge_hw_vpath_msix_unmask(vpath->handle, msix_id);
 	}
 }
 
@@ -1405,12 +1403,13 @@ void vxge_vpath_intr_disable(struct vxge
 	if (vdev->config.intr_type == INTA)
 		vxge_hw_vpath_inta_mask_tx_rx(vpath->handle);
 	else {
-		msix_id = vp_id * VXGE_HW_VPATH_MSIX_ACTIVE;
+		msix_id = vpath->device_id * VXGE_HW_VPATH_MSIX_ACTIVE;
 		vxge_hw_vpath_msix_mask(vpath->handle, msix_id);
 		vxge_hw_vpath_msix_mask(vpath->handle, msix_id + 1);
 
 		/* disable the alarm vector */
-		msix_id = VXGE_HW_VPATH_MSIX_ACTIVE * vdev->no_of_vpath - 2;
+		msix_id = (vpath->handle->vpath->hldev->first_vp_id *
+			VXGE_HW_VPATH_MSIX_ACTIVE) + VXGE_ALARM_MSIX_ID;
 		vxge_hw_vpath_msix_mask(vpath->handle, msix_id);
 	}
 }
@@ -2223,19 +2222,18 @@ vxge_alarm_msix_handle(int irq, void *de
 	enum vxge_hw_status status;
 	struct vxge_vpath *vpath = (struct vxge_vpath *)dev_id;
 	struct vxgedev *vdev = vpath->vdev;
-	int alarm_msix_id =
-		VXGE_HW_VPATH_MSIX_ACTIVE * vdev->no_of_vpath - 2;
+	int msix_id = (vpath->handle->vpath->vp_id *
+		VXGE_HW_VPATH_MSIX_ACTIVE) + VXGE_ALARM_MSIX_ID;
 
 	for (i = 0; i < vdev->no_of_vpath; i++) {
-		vxge_hw_vpath_msix_mask(vdev->vpaths[i].handle,
-			alarm_msix_id);
+		vxge_hw_vpath_msix_mask(vdev->vpaths[i].handle, msix_id);
 
 		status = vxge_hw_vpath_alarm_process(vdev->vpaths[i].handle,
 			vdev->exec_mode);
 		if (status == VXGE_HW_OK) {
 
 			vxge_hw_vpath_msix_unmask(vdev->vpaths[i].handle,
-				alarm_msix_id);
+					msix_id);
 			continue;
 		}
 		vxge_debug_intr(VXGE_ERR,
@@ -2248,18 +2246,17 @@ vxge_alarm_msix_handle(int irq, void *de
 static int vxge_alloc_msix(struct vxgedev *vdev)
 {
 	int j, i, ret = 0;
-	int intr_cnt = 0;
-	int alarm_msix_id = 0, msix_intr_vect = 0;
+	int msix_intr_vect = 0, temp;
 	vdev->intr_cnt = 0;
 
+start:
 	/* Tx/Rx MSIX Vectors count */
 	vdev->intr_cnt = vdev->no_of_vpath * 2;
 
 	/* Alarm MSIX Vectors count */
 	vdev->intr_cnt++;
 
-	intr_cnt = (vdev->max_vpath_supported * 2) + 1;
-	vdev->entries = kzalloc(intr_cnt * sizeof(struct msix_entry),
+	vdev->entries = kzalloc(vdev->intr_cnt * sizeof(struct msix_entry),
 						GFP_KERNEL);
 	if (!vdev->entries) {
 		vxge_debug_init(VXGE_ERR,
@@ -2268,8 +2265,9 @@ static int vxge_alloc_msix(struct vxgede
 		return  -ENOMEM;
 	}
 
-	vdev->vxge_entries = kzalloc(intr_cnt * sizeof(struct vxge_msix_entry),
-							GFP_KERNEL);
+	vdev->vxge_entries =
+		kzalloc(vdev->intr_cnt * sizeof(struct vxge_msix_entry),
+				GFP_KERNEL);
 	if (!vdev->vxge_entries) {
 		vxge_debug_init(VXGE_ERR, "%s: memory allocation failed",
 			VXGE_DRIVER_NAME);
@@ -2277,9 +2275,7 @@ static int vxge_alloc_msix(struct vxgede
 		return -ENOMEM;
 	}
 
-	/* Last vector in the list is used for alarm */
-	alarm_msix_id = VXGE_HW_VPATH_MSIX_ACTIVE * vdev->no_of_vpath - 2;
-	for (i = 0, j = 0; i < vdev->max_vpath_supported; i++) {
+	for (i = 0, j = 0; i < vdev->no_of_vpath; i++) {
 
 		msix_intr_vect = i * VXGE_HW_VPATH_MSIX_ACTIVE;
 
@@ -2297,47 +2293,31 @@ static int vxge_alloc_msix(struct vxgede
 	}
 
 	/* Initialize the alarm vector */
-	vdev->entries[j].entry = alarm_msix_id;
-	vdev->vxge_entries[j].entry = alarm_msix_id;
+	vdev->entries[j].entry = VXGE_ALARM_MSIX_ID;
+	vdev->vxge_entries[j].entry = VXGE_ALARM_MSIX_ID;
 	vdev->vxge_entries[j].in_use = 0;
 
-	ret = pci_enable_msix(vdev->pdev, vdev->entries, intr_cnt);
-	/* if driver request exceeeds available irq's, request with a small
-	 * number.
-	*/
-	if (ret > 0) {
-		vxge_debug_init(VXGE_ERR,
-			"%s: MSI-X enable failed for %d vectors, available: %d",
-			VXGE_DRIVER_NAME, intr_cnt, ret);
-		vdev->max_vpath_supported = vdev->no_of_vpath;
-		intr_cnt = (vdev->max_vpath_supported * 2) + 1;
-
-		/* Reset the alarm vector setting */
-		vdev->entries[j].entry = 0;
-		vdev->vxge_entries[j].entry = 0;
-
-		/* Initialize the alarm vector with new setting */
-		vdev->entries[intr_cnt - 1].entry = alarm_msix_id;
-		vdev->vxge_entries[intr_cnt - 1].entry = alarm_msix_id;
-		vdev->vxge_entries[intr_cnt - 1].in_use = 0;
+	ret = pci_enable_msix(vdev->pdev, vdev->entries, vdev->intr_cnt);
 
-		ret = pci_enable_msix(vdev->pdev, vdev->entries, intr_cnt);
-		if (!ret)
-			vxge_debug_init(VXGE_ERR,
-				"%s: MSI-X enabled for %d vectors",
-				VXGE_DRIVER_NAME, intr_cnt);
-	}
-
-	if (ret) {
+	if (ret > 0) {
 		vxge_debug_init(VXGE_ERR,
 			"%s: MSI-X enable failed for %d vectors, ret: %d",
-			VXGE_DRIVER_NAME, intr_cnt, ret);
+			VXGE_DRIVER_NAME, vdev->intr_cnt, ret);
 		kfree(vdev->entries);
 		kfree(vdev->vxge_entries);
 		vdev->entries = NULL;
 		vdev->vxge_entries = NULL;
+
+		if ((max_config_vpath != VXGE_USE_DEFAULT) || (ret < 3))
+			return -ENODEV;
+		/* Try with less no of vector by reducing no of vpaths count */
+		temp = (ret - 1)/2;
+		vxge_close_vpaths(vdev, temp);
+		vdev->no_of_vpath = temp;
+		goto start;
+	} else if (ret < 0)
 		return -ENODEV;
-	}
+
 	return 0;
 }
 
@@ -2345,43 +2325,26 @@ static int vxge_enable_msix(struct vxged
 {
 
 	int i, ret = 0;
-	enum vxge_hw_status status;
 	/* 0 - Tx, 1 - Rx  */
-	int tim_msix_id[4];
-	int alarm_msix_id = 0, msix_intr_vect = 0;
+	int tim_msix_id[4] = {0, 1, 0, 0};
+
 	vdev->intr_cnt = 0;
 
 	/* allocate msix vectors */
 	ret = vxge_alloc_msix(vdev);
 	if (!ret) {
-		/* Last vector in the list is used for alarm */
-		alarm_msix_id =
-			VXGE_HW_VPATH_MSIX_ACTIVE * vdev->no_of_vpath - 2;
 		for (i = 0; i < vdev->no_of_vpath; i++) {
 
 			/* If fifo or ring are not enabled
 			   the MSIX vector for that should be set to 0
 			   Hence initializeing this array to all 0s.
 			*/
-			memset(tim_msix_id, 0, sizeof(tim_msix_id));
-			msix_intr_vect = i * VXGE_HW_VPATH_MSIX_ACTIVE;
-			tim_msix_id[0] = msix_intr_vect;
-
-			tim_msix_id[1] = msix_intr_vect + 1;
-			vdev->vpaths[i].ring.rx_vector_no = tim_msix_id[1];
-
-			status = vxge_hw_vpath_msix_set(
-						vdev->vpaths[i].handle,
-						tim_msix_id, alarm_msix_id);
-			if (status != VXGE_HW_OK) {
-				vxge_debug_init(VXGE_ERR,
-					"vxge_hw_vpath_msix_set "
-					"failed with status : %x", status);
-				kfree(vdev->entries);
-				kfree(vdev->vxge_entries);
-				pci_disable_msix(vdev->pdev);
-				return -ENODEV;
-			}
+			vdev->vpaths[i].ring.rx_vector_no =
+				(vdev->vpaths[i].device_id *
+					VXGE_HW_VPATH_MSIX_ACTIVE) + 1;
+
+			vxge_hw_vpath_msix_set(vdev->vpaths[i].handle,
+					tim_msix_id, VXGE_ALARM_MSIX_ID);
 		}
 	}
 
@@ -2392,7 +2355,7 @@ static void vxge_rem_msix_isr(struct vxg
 {
 	int intr_cnt;
 
-	for (intr_cnt = 0; intr_cnt < (vdev->max_vpath_supported * 2 + 1);
+	for (intr_cnt = 0; intr_cnt < (vdev->no_of_vpath * 2 + 1);
 		intr_cnt++) {
 		if (vdev->vxge_entries[intr_cnt].in_use) {
 			synchronize_irq(vdev->entries[intr_cnt].vector);
@@ -2457,9 +2420,10 @@ static int vxge_add_isr(struct vxgedev *
 			switch (msix_idx) {
 			case 0:
 				snprintf(vdev->desc[intr_cnt], VXGE_INTR_STRLEN,
-					"%s:vxge fn: %d vpath: %d Tx MSI-X: %d",
-					vdev->ndev->name, pci_fun, vp_idx,
-					vdev->entries[intr_cnt].entry);
+				"%s:vxge:MSI-X %d - Tx - fn:%d vpath:%d",
+					vdev->ndev->name,
+					vdev->entries[intr_cnt].entry,
+					pci_fun, vp_idx);
 				ret = request_irq(
 				    vdev->entries[intr_cnt].vector,
 					vxge_tx_msix_handle, 0,
@@ -2471,9 +2435,10 @@ static int vxge_add_isr(struct vxgedev *
 				break;
 			case 1:
 				snprintf(vdev->desc[intr_cnt], VXGE_INTR_STRLEN,
-					"%s:vxge fn: %d vpath: %d Rx MSI-X: %d",
-					vdev->ndev->name, pci_fun, vp_idx,
-					vdev->entries[intr_cnt].entry);
+				"%s:vxge:MSI-X %d - Rx - fn:%d vpath:%d",
+					vdev->ndev->name,
+					vdev->entries[intr_cnt].entry,
+					pci_fun, vp_idx);
 				ret = request_irq(
 				    vdev->entries[intr_cnt].vector,
 					vxge_rx_msix_napi_handle,
@@ -2501,9 +2466,11 @@ static int vxge_add_isr(struct vxgedev *
 			if (irq_req) {
 				/* We requested for this msix interrupt */
 				vdev->vxge_entries[intr_cnt].in_use = 1;
+				msix_idx +=  vdev->vpaths[vp_idx].device_id *
+					VXGE_HW_VPATH_MSIX_ACTIVE;
 				vxge_hw_vpath_msix_unmask(
 					vdev->vpaths[vp_idx].handle,
-					intr_idx);
+					msix_idx);
 				intr_cnt++;
 			}
 
@@ -2513,16 +2480,17 @@ static int vxge_add_isr(struct vxgedev *
 				vp_idx++;
 		}
 
-		intr_cnt = vdev->max_vpath_supported * 2;
+		intr_cnt = vdev->no_of_vpath * 2;
 		snprintf(vdev->desc[intr_cnt], VXGE_INTR_STRLEN,
-			"%s:vxge Alarm fn: %d MSI-X: %d",
-			vdev->ndev->name, pci_fun,
-			vdev->entries[intr_cnt].entry);
+			"%s:vxge:MSI-X %d - Alarm - fn:%d",
+			vdev->ndev->name,
+			vdev->entries[intr_cnt].entry,
+			pci_fun);
 		/* For Alarm interrupts */
 		ret = request_irq(vdev->entries[intr_cnt].vector,
 					vxge_alarm_msix_handle, 0,
 					vdev->desc[intr_cnt],
-					&vdev->vpaths[vp_idx]);
+					&vdev->vpaths[0]);
 		if (ret) {
 			vxge_debug_init(VXGE_ERR,
 				"%s: MSIX - %d Registration failed",
@@ -2535,16 +2503,19 @@ static int vxge_add_isr(struct vxgedev *
 				goto INTA_MODE;
 		}
 
+		msix_idx = (vdev->vpaths[0].handle->vpath->vp_id *
+			VXGE_HW_VPATH_MSIX_ACTIVE) + VXGE_ALARM_MSIX_ID;
 		vxge_hw_vpath_msix_unmask(vdev->vpaths[vp_idx].handle,
-					intr_idx - 2);
+					msix_idx);
 		vdev->vxge_entries[intr_cnt].in_use = 1;
-		vdev->vxge_entries[intr_cnt].arg = &vdev->vpaths[vp_idx];
+		vdev->vxge_entries[intr_cnt].arg = &vdev->vpaths[0];
 	}
 INTA_MODE:
 #endif
-	snprintf(vdev->desc[0], VXGE_INTR_STRLEN, "%s:vxge", vdev->ndev->name);
 
 	if (vdev->config.intr_type == INTA) {
+		snprintf(vdev->desc[0], VXGE_INTR_STRLEN,
+			"%s:vxge:INTA", vdev->ndev->name);
 		vxge_hw_device_set_intr_type(vdev->devh,
 			VXGE_HW_INTR_MODE_IRQLINE);
 		vxge_hw_vpath_tti_ci_set(vdev->devh,
diff -urpN patch4/drivers/net/vxge/vxge-main.h patch5/drivers/net/vxge/vxge-main.h
--- patch4/drivers/net/vxge/vxge-main.h	2010-03-19 16:21:17.000000000 +0530
+++ patch5/drivers/net/vxge/vxge-main.h	2010-03-19 16:27:57.000000000 +0530
@@ -31,6 +31,7 @@
 #define PCI_DEVICE_ID_TITAN_UNI		0x5833
 #define	VXGE_USE_DEFAULT		0xffffffff
 #define VXGE_HW_VPATH_MSIX_ACTIVE	4
+#define VXGE_ALARM_MSIX_ID		2
 #define VXGE_HW_RXSYNC_FREQ_CNT		4
 #define VXGE_LL_WATCH_DOG_TIMEOUT	(15 * HZ)
 #define VXGE_LL_RX_COPY_THRESHOLD	256
diff -urpN patch4/drivers/net/vxge/vxge-traffic.c patch5/drivers/net/vxge/vxge-traffic.c
--- patch4/drivers/net/vxge/vxge-traffic.c	2010-03-19 16:21:17.000000000 +0530
+++ patch5/drivers/net/vxge/vxge-traffic.c	2010-03-26 15:46:14.000000000 +0530
@@ -231,8 +231,7 @@ void vxge_hw_channel_msix_mask(struct __
 {
 
 	__vxge_hw_pio_mem_write32_upper(
-		(u32)vxge_bVALn(vxge_mBIT(channel->first_vp_id+(msix_id/4)),
-			0, 32),
+		(u32)vxge_bVALn(vxge_mBIT(msix_id >> 2), 0, 32),
 		&channel->common_reg->set_msix_mask_vect[msix_id%4]);
 
 	return;
@@ -252,8 +251,7 @@ vxge_hw_channel_msix_unmask(struct __vxg
 {
 
 	__vxge_hw_pio_mem_write32_upper(
-		(u32)vxge_bVALn(vxge_mBIT(channel->first_vp_id+(msix_id/4)),
-			0, 32),
+		(u32)vxge_bVALn(vxge_mBIT(msix_id >> 2), 0, 32),
 		&channel->common_reg->clear_msix_mask_vect[msix_id%4]);
 
 	return;
@@ -2220,29 +2218,24 @@ exit:
  * This API will associate a given MSIX vector numbers with the four TIM
  * interrupts and alarm interrupt.
  */
-enum vxge_hw_status
+void
 vxge_hw_vpath_msix_set(struct __vxge_hw_vpath_handle *vp, int *tim_msix_id,
 		       int alarm_msix_id)
 {
 	u64 val64;
 	struct __vxge_hw_virtualpath *vpath = vp->vpath;
 	struct vxge_hw_vpath_reg __iomem *vp_reg = vpath->vp_reg;
-	u32 first_vp_id = vpath->hldev->first_vp_id;
+	u32 vp_id = vp->vpath->vp_id;
 
 	val64 =  VXGE_HW_INTERRUPT_CFG0_GROUP0_MSIX_FOR_TXTI(
-		  (first_vp_id * 4) + tim_msix_id[0]) |
+		  (vp_id * 4) + tim_msix_id[0]) |
 		 VXGE_HW_INTERRUPT_CFG0_GROUP1_MSIX_FOR_TXTI(
-		  (first_vp_id * 4) + tim_msix_id[1]) |
-		 VXGE_HW_INTERRUPT_CFG0_GROUP2_MSIX_FOR_TXTI(
-			(first_vp_id * 4) + tim_msix_id[2]);
-
-		val64 |= VXGE_HW_INTERRUPT_CFG0_GROUP3_MSIX_FOR_TXTI(
-			(first_vp_id * 4) + tim_msix_id[3]);
+		  (vp_id * 4) + tim_msix_id[1]);
 
 	writeq(val64, &vp_reg->interrupt_cfg0);
 
 	writeq(VXGE_HW_INTERRUPT_CFG2_ALARM_MAP_TO_MSG(
-			(first_vp_id * 4) + alarm_msix_id),
+			(vpath->hldev->first_vp_id * 4) + alarm_msix_id),
 			&vp_reg->interrupt_cfg2);
 
 	if (vpath->hldev->config.intr_mode ==
@@ -2263,7 +2256,7 @@ vxge_hw_vpath_msix_set(struct __vxge_hw_
 				0, 32), &vp_reg->one_shot_vect3_en);
 	}
 
-	return VXGE_HW_OK;
+	return;
 }
 
 /**
@@ -2283,8 +2276,7 @@ vxge_hw_vpath_msix_mask(struct __vxge_hw
 {
 	struct __vxge_hw_device *hldev = vp->vpath->hldev;
 	__vxge_hw_pio_mem_write32_upper(
-		(u32) vxge_bVALn(vxge_mBIT(hldev->first_vp_id +
-			(msix_id  / 4)), 0, 32),
+		(u32) vxge_bVALn(vxge_mBIT(msix_id  >> 2), 0, 32),
 		&hldev->common_reg->set_msix_mask_vect[msix_id % 4]);
 
 	return;
@@ -2309,14 +2301,12 @@ vxge_hw_vpath_msix_clear(struct __vxge_h
 	if (hldev->config.intr_mode ==
 			VXGE_HW_INTR_MODE_MSIX_ONE_SHOT) {
 		__vxge_hw_pio_mem_write32_upper(
-			(u32)vxge_bVALn(vxge_mBIT(hldev->first_vp_id +
-				(msix_id/4)), 0, 32),
+			(u32)vxge_bVALn(vxge_mBIT(msix_id >> 2), 0, 32),
 				&hldev->common_reg->
 					clr_msix_one_shot_vec[msix_id%4]);
 	} else {
 		__vxge_hw_pio_mem_write32_upper(
-			(u32)vxge_bVALn(vxge_mBIT(hldev->first_vp_id +
-				(msix_id/4)), 0, 32),
+			(u32)vxge_bVALn(vxge_mBIT(msix_id >> 2), 0, 32),
 				&hldev->common_reg->
 					clear_msix_mask_vect[msix_id%4]);
 	}
@@ -2341,8 +2331,7 @@ vxge_hw_vpath_msix_unmask(struct __vxge_
 {
 	struct __vxge_hw_device *hldev = vp->vpath->hldev;
 	__vxge_hw_pio_mem_write32_upper(
-			(u32)vxge_bVALn(vxge_mBIT(hldev->first_vp_id +
-			(msix_id/4)), 0, 32),
+			(u32)vxge_bVALn(vxge_mBIT(msix_id >> 2), 0, 32),
 			&hldev->common_reg->clear_msix_mask_vect[msix_id%4]);
 
 	return;
diff -urpN patch4/drivers/net/vxge/vxge-traffic.h patch5/drivers/net/vxge/vxge-traffic.h
--- patch4/drivers/net/vxge/vxge-traffic.h	2010-03-19 16:21:17.000000000 +0530
+++ patch5/drivers/net/vxge/vxge-traffic.h	2010-03-19 16:24:45.000000000 +0530
@@ -2376,7 +2376,7 @@ enum vxge_hw_status vxge_hw_vpath_alarm_
 	struct __vxge_hw_vpath_handle *vpath_handle,
 	u32 skip_alarms);
 
-enum vxge_hw_status
+void
 vxge_hw_vpath_msix_set(struct __vxge_hw_vpath_handle *vpath_handle,
 		       int *tim_msix_id, int alarm_msix_id);
 

