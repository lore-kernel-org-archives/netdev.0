From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 3/4] vxge: Pass correct number of VFs value to
 pci_sriov_enable().
Date: Thu, 8 Apr 2010 04:44:26 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.11004080443390.365-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:38559 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756585Ab0DHIo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 04:44:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-  max_config_dev loadable parameter is set to 0xFF by default. Pass correct
   number of VFs value to pci_sriov_enable() if max_config_dev is set to its 
   default value.
 
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@exar.com>
---
diff -urpN patch2/drivers/net/vxge/vxge-config.h patch3/drivers/net/vxge/vxge-config.h
--- patch2/drivers/net/vxge/vxge-config.h	2010-04-01 12:06:55.000000000 +0530
+++ patch3/drivers/net/vxge/vxge-config.h	2010-04-01 14:20:19.000000000 +0530
@@ -764,10 +764,18 @@ struct vxge_hw_device_hw_info {
 #define VXGE_HW_SR_VH_VIRTUAL_FUNCTION				6
 #define VXGE_HW_VH_NORMAL_FUNCTION				7
 	u64		function_mode;
-#define VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION			0
-#define VXGE_HW_FUNCTION_MODE_SINGLE_FUNCTION			1
+#define VXGE_HW_FUNCTION_MODE_SINGLE_FUNCTION			0
+#define VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION			1
 #define VXGE_HW_FUNCTION_MODE_SRIOV				2
 #define VXGE_HW_FUNCTION_MODE_MRIOV				3
+#define VXGE_HW_FUNCTION_MODE_MRIOV_8				4
+#define VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION_17			5
+#define VXGE_HW_FUNCTION_MODE_SRIOV_8				6
+#define VXGE_HW_FUNCTION_MODE_SRIOV_4				7
+#define VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION_2			8
+#define VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION_4			9
+#define VXGE_HW_FUNCTION_MODE_MRIOV_4				10
+
 	u32		func_id;
 	u64		vpath_mask;
 	struct vxge_hw_device_version fw_version;
@@ -2265,4 +2273,6 @@ enum vxge_hw_status vxge_hw_vpath_rts_rt
 	struct vxge_hw_rth_hash_types *hash_type,
 	u16 bucket_size);
 
+enum vxge_hw_status
+__vxge_hw_device_is_privilaged(u32 host_type, u32 func_id);
 #endif
diff -urpN patch2/drivers/net/vxge/vxge-main.c patch3/drivers/net/vxge/vxge-main.c
--- patch2/drivers/net/vxge/vxge-main.c	2010-04-01 12:12:50.000000000 +0530
+++ patch3/drivers/net/vxge/vxge-main.c	2010-04-01 14:33:30.000000000 +0530
@@ -3965,6 +3965,36 @@ static void vxge_io_resume(struct pci_de
 	netif_device_attach(netdev);
 }
 
+static inline u32 vxge_get_num_vfs(u64 function_mode)
+{
+	u32 num_functions = 0;
+
+	switch (function_mode) {
+	case VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION:
+	case VXGE_HW_FUNCTION_MODE_SRIOV_8:
+		num_functions = 8;
+		break;
+	case VXGE_HW_FUNCTION_MODE_SINGLE_FUNCTION:
+		num_functions = 1;
+		break;
+	case VXGE_HW_FUNCTION_MODE_SRIOV:
+	case VXGE_HW_FUNCTION_MODE_MRIOV:
+	case VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION_17:
+		num_functions = 17;
+		break;
+	case VXGE_HW_FUNCTION_MODE_SRIOV_4:
+		num_functions = 4;
+		break;
+	case VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION_2:
+		num_functions = 2;
+		break;
+	case VXGE_HW_FUNCTION_MODE_MRIOV_8:
+		num_functions = 8; /* TODO */
+		break;
+	}
+	return num_functions;
+}
+
 /**
  * vxge_probe
  * @pdev : structure containing the PCI related information of the device.
@@ -3992,14 +4022,19 @@ vxge_probe(struct pci_dev *pdev, const s
 	u8 *macaddr;
 	struct vxge_mac_addrs *entry;
 	static int bus = -1, device = -1;
+	u32 host_type;
 	u8 new_device = 0;
+	enum vxge_hw_status is_privileged;
+	u32 function_mode;
+	u32 num_vfs = 0;
 
 	vxge_debug_entryexit(VXGE_TRACE, "%s:%d", __func__, __LINE__);
 	attr.pdev = pdev;
 
-	if (bus != pdev->bus->number)
-		new_device = 1;
-	if (device != PCI_SLOT(pdev->devfn))
+	/* In SRIOV-17 mode, functions of the same adapter
+	 * can be deployed on different buses */
+	if ((!pdev->is_virtfn) && ((bus != pdev->bus->number) ||
+		(device != PCI_SLOT(pdev->devfn))))
 		new_device = 1;
 
 	bus = pdev->bus->number;
@@ -4133,6 +4168,11 @@ vxge_probe(struct pci_dev *pdev, const s
 		"%s:%d  Vpath mask = %llx", __func__, __LINE__,
 		(unsigned long long)vpath_mask);
 
+	function_mode = ll_config.device_hw_info.function_mode;
+	host_type = ll_config.device_hw_info.host_type;
+	is_privileged = __vxge_hw_device_is_privilaged(host_type,
+		ll_config.device_hw_info.func_id);
+
 	/* Check how many vpaths are available */
 	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
 		if (!((vpath_mask) & vxge_mBIT(i)))
@@ -4140,14 +4180,18 @@ vxge_probe(struct pci_dev *pdev, const s
 		max_vpath_supported++;
 	}
 
+	if (new_device)
+		num_vfs = vxge_get_num_vfs(function_mode) - 1;
+
 	/* Enable SRIOV mode, if firmware has SRIOV support and if it is a PF */
-	if ((VXGE_HW_FUNCTION_MODE_SRIOV ==
-		ll_config.device_hw_info.function_mode) &&
-		(max_config_dev > 1) && (pdev->is_physfn)) {
-			ret = pci_enable_sriov(pdev, max_config_dev - 1);
-			if (ret)
-				vxge_debug_ll_config(VXGE_ERR,
-					"Failed to enable SRIOV: %d\n", ret);
+	if (is_sriov(function_mode) && (max_config_dev > 1) &&
+		(ll_config.intr_type != INTA) &&
+		(is_privileged == VXGE_HW_OK)) {
+		ret = pci_enable_sriov(pdev, ((max_config_dev - 1) < num_vfs)
+			? (max_config_dev - 1) : num_vfs);
+		if (ret)
+			vxge_debug_ll_config(VXGE_ERR,
+				"Failed in enabling SRIOV mode: %d\n", ret);
 	}
 
 	/*
diff -urpN patch2/drivers/net/vxge/vxge-main.h patch3/drivers/net/vxge/vxge-main.h
--- patch2/drivers/net/vxge/vxge-main.h	2010-04-01 12:06:55.000000000 +0530
+++ patch3/drivers/net/vxge/vxge-main.h	2010-04-01 13:52:56.000000000 +0530
@@ -90,6 +90,11 @@
 
 #define VXGE_LL_MAX_FRAME_SIZE(dev) ((dev)->mtu + VXGE_HW_MAC_HEADER_MAX_SIZE)
 
+#define is_sriov(function_mode) \
+	((function_mode == VXGE_HW_FUNCTION_MODE_SRIOV) || \
+	(function_mode == VXGE_HW_FUNCTION_MODE_SRIOV_8) || \
+	(function_mode == VXGE_HW_FUNCTION_MODE_SRIOV_4))
+
 enum vxge_reset_event {
 	/* reset events */
 	VXGE_LL_VPATH_RESET	= 0,

