From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 1/9] vxge: Modify __vxge_hw_device_is_privilaged()
 to not assume function-0 as the privileged function: Resubmit#1
Date: Mon, 5 Oct 2009 07:51:38 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10910050749130.9377-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:42021 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758493AbZJEL7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 07:59:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- vxge driver was assuming function-0 is always the privilaged function. Now that
  restriction has been removed any function can act as a privilaged function.

- This patch modifies the __vxge_hw_device_is_privilaged routine to not assume
  function-0 as the privileged function.

- Recreated the patch by incorporating review comments from Dave Miller to
  remove double slash in path names.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
diff -urpN orig/drivers/net/vxge/vxge-config.c patch1/drivers/net/vxge/vxge-config.c
--- orig/drivers/net/vxge/vxge-config.c	2009-09-03 22:39:48.000000000 -0700
+++ patch1/drivers/net/vxge/vxge-config.c	2009-09-03 23:11:24.000000000 -0700
@@ -356,10 +356,8 @@ __vxge_hw_device_access_rights_get(u32 h
 
 	switch (host_type) {
 	case VXGE_HW_NO_MR_NO_SR_NORMAL_FUNCTION:
-		if (func_id == 0) {
-			access_rights |= VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM |
-					VXGE_HW_DEVICE_ACCESS_RIGHT_SRPCIM;
-		}
+		access_rights |= VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM |
+				VXGE_HW_DEVICE_ACCESS_RIGHT_SRPCIM;
 		break;
 	case VXGE_HW_MR_NO_SR_VH0_BASE_FUNCTION:
 		access_rights |= VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM |
@@ -382,6 +380,22 @@ __vxge_hw_device_access_rights_get(u32 h
 	return access_rights;
 }
 /*
+ * __vxge_hw_device_is_privilaged
+ * This routine checks if the device function is privilaged or not
+ */
+
+enum vxge_hw_status
+__vxge_hw_device_is_privilaged(u32 host_type, u32 func_id)
+{
+	if (__vxge_hw_device_access_rights_get(host_type,
+		func_id) &
+		VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM)
+		return VXGE_HW_OK;
+	else
+		return VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+}
+
+/*
  * __vxge_hw_device_host_info_get
  * This routine returns the host type assignments
  */
@@ -446,18 +460,6 @@ __vxge_hw_verify_pci_e_info(struct __vxg
 	return VXGE_HW_OK;
 }
 
-enum vxge_hw_status
-__vxge_hw_device_is_privilaged(struct __vxge_hw_device *hldev)
-{
-	if ((hldev->host_type == VXGE_HW_NO_MR_NO_SR_NORMAL_FUNCTION ||
-	hldev->host_type == VXGE_HW_MR_NO_SR_VH0_BASE_FUNCTION ||
-	hldev->host_type == VXGE_HW_NO_MR_SR_VH0_FUNCTION0) &&
-	(hldev->func_id == 0))
-		return VXGE_HW_OK;
-	else
-		return VXGE_HW_ERR_PRIVILAGED_OPEARATION;
-}
-
 /*
  * vxge_hw_wrr_rebalance - Rebalance the RX_WRR and KDFC_WRR calandars.
  * Rebalance the RX_WRR and KDFC_WRR calandars.
@@ -470,7 +472,8 @@ vxge_hw_status vxge_hw_wrr_rebalance(str
 	u32 i, j, how_often = 1;
 	enum vxge_hw_status status = VXGE_HW_OK;
 
-	status = __vxge_hw_device_is_privilaged(hldev);
+	status = __vxge_hw_device_is_privilaged(hldev->host_type,
+			hldev->func_id);
 	if (status != VXGE_HW_OK)
 		goto exit;
 
@@ -668,7 +671,8 @@ enum vxge_hw_status __vxge_hw_device_ini
 {
 	enum vxge_hw_status status = VXGE_HW_OK;
 
-	if (VXGE_HW_OK == __vxge_hw_device_is_privilaged(hldev)) {
+	if (VXGE_HW_OK == __vxge_hw_device_is_privilaged(hldev->host_type,
+				hldev->func_id)) {
 		/* Validate the pci-e link width and speed */
 		status = __vxge_hw_verify_pci_e_info(hldev);
 		if (status != VXGE_HW_OK)
@@ -953,7 +957,8 @@ vxge_hw_mrpcim_stats_access(struct __vxg
 	u64 val64;
 	enum vxge_hw_status status = VXGE_HW_OK;
 
-	status = __vxge_hw_device_is_privilaged(hldev);
+	status = __vxge_hw_device_is_privilaged(hldev->host_type,
+			hldev->func_id);
 	if (status != VXGE_HW_OK)
 		goto exit;
 
@@ -990,7 +995,8 @@ vxge_hw_device_xmac_aggr_stats_get(struc
 
 	val64 = (u64 *)aggr_stats;
 
-	status = __vxge_hw_device_is_privilaged(hldev);
+	status = __vxge_hw_device_is_privilaged(hldev->host_type,
+			hldev->func_id);
 	if (status != VXGE_HW_OK)
 		goto exit;
 
@@ -1023,7 +1029,8 @@ vxge_hw_device_xmac_port_stats_get(struc
 	u32 offset = 0x0;
 	val64 = (u64 *) port_stats;
 
-	status = __vxge_hw_device_is_privilaged(hldev);
+	status = __vxge_hw_device_is_privilaged(hldev->host_type,
+			hldev->func_id);
 	if (status != VXGE_HW_OK)
 		goto exit;
 
@@ -1221,7 +1228,8 @@ enum vxge_hw_status vxge_hw_device_setpa
 		goto exit;
 	}
 
-	status = __vxge_hw_device_is_privilaged(hldev);
+	status = __vxge_hw_device_is_privilaged(hldev->host_type,
+			hldev->func_id);
 	if (status != VXGE_HW_OK)
 		goto exit;
 

