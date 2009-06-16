From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH net-next-2.6] vxge: Enable SRIOV support in the driver.
Date: Tue, 16 Jun 2009 05:26:09 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10906160521210.13320-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com, sivakumar.subramani@neterion.com,
	santosh.rastapur@neterion.com, ram.vepa@neterion.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:51862 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638AbZFPJoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 05:44:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Enabled SRIOV support in the driver.
- Call __vxge_hw_verify_pci_e_info() for the PF only. This function
verifies the negotiated link width and current link speed in the
Link Status Register (offset 12h) which are reserved fields for VFs
as per the SRIOV specification, section 3.5.8.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Rastapur Santosh <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN org/drivers/net/vxge/vxge-config.c mod/drivers/net/vxge/vxge-config.c
--- org/drivers/net/vxge/vxge-config.c	2009-06-15 22:51:49.000000000 -0700
+++ mod/drivers/net/vxge/vxge-config.c	2009-06-15 22:55:59.000000000 -0700
@@ -454,7 +454,7 @@ __vxge_hw_verify_pci_e_info(struct __vxg
 	return VXGE_HW_OK;
 }
 
-static enum vxge_hw_status
+enum vxge_hw_status
 __vxge_hw_device_is_privilaged(struct __vxge_hw_device *hldev)
 {
 	if ((hldev->host_type == VXGE_HW_NO_MR_NO_SR_NORMAL_FUNCTION ||
@@ -676,10 +676,12 @@ enum vxge_hw_status __vxge_hw_device_ini
 {
 	enum vxge_hw_status status = VXGE_HW_OK;
 
-	/* Validate the pci-e link width and speed */
-	status = __vxge_hw_verify_pci_e_info(hldev);
-	if (status != VXGE_HW_OK)
-		goto exit;
+	if (VXGE_HW_OK == __vxge_hw_device_is_privilaged(hldev)) {
+		/* Validate the pci-e link width and speed */
+		status = __vxge_hw_verify_pci_e_info(hldev);
+		if (status != VXGE_HW_OK)
+			goto exit;
+	}
 
 	vxge_hw_wrr_rebalance(hldev);
 exit:
diff -urpN org/drivers/net/vxge/vxge-main.c mod/drivers/net/vxge/vxge-main.c
--- org/drivers/net/vxge/vxge-main.c	2009-06-15 22:51:43.000000000 -0700
+++ mod/drivers/net/vxge/vxge-main.c	2009-06-15 23:03:04.000000000 -0700
@@ -4203,6 +4203,17 @@ vxge_probe(struct pci_dev *pdev, const s
 		max_vpath_supported++;
 	}
 
+#ifdef CONFIG_PCI_IOV
+	/* Enable SRIOV mode, if firmware has SRIOV support and if it is a PF */
+	if ((VXGE_HW_FUNCTION_MODE_SRIOV ==
+		ll_config.device_hw_info.function_mode) &&
+		(max_config_dev > 1) && (pdev->is_physfn)) {
+			ret = pci_enable_sriov(pdev, max_config_dev - 1);
+			if (ret)
+				vxge_debug_ll_config(VXGE_ERR,
+					"Failed to enable SRIOV: %d \n", ret);
+	}
+#endif
 	/*
 	 * Configure vpaths and get driver configured number of vpaths
 	 * which is less than or equal to the maximum vpaths per function.
@@ -4366,6 +4377,9 @@ _exit6:
 
 	vxge_device_unregister(hldev);
 _exit5:
+#ifdef CONFIG_PCI_IOV
+	pci_disable_sriov(pdev);
+#endif
 	vxge_hw_device_terminate(hldev);
 _exit4:
 	iounmap(attr.bar1);
@@ -4428,6 +4442,9 @@ vxge_remove(struct pci_dev *pdev)
 
 	iounmap(vdev->bar0);
 	iounmap(vdev->bar1);
+#ifdef CONFIG_PCI_IOV
+	pci_disable_sriov(pdev);
+#endif
 
 	/* we are safe to free it now */
 	free_netdev(dev);
diff -urpN org/drivers/net/vxge/vxge-version.h mod/drivers/net/vxge/vxge-version.h
--- org/drivers/net/vxge/vxge-version.h	2009-06-15 22:51:54.000000000 -0700
+++ mod/drivers/net/vxge/vxge-version.h	2009-06-15 23:04:18.000000000 -0700
@@ -17,7 +17,7 @@
 
 #define VXGE_VERSION_MAJOR	"2"
 #define VXGE_VERSION_MINOR	"0"
-#define VXGE_VERSION_FIX	"1"
-#define VXGE_VERSION_BUILD	"17129"
+#define VXGE_VERSION_FIX	"4"
+#define VXGE_VERSION_BUILD	"17784"
 #define VXGE_VERSION_FOR	"k"
 #endif

