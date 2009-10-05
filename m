From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 6/9] vxge: Check if FCS stripping is disabled
 by the firmware.
Date: Mon, 5 Oct 2009 05:11:40 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10910050510440.2346-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:39135 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932292AbZJEJMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 05:12:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Added a function to check if FCS stripping is disabled by the firmware, if
  it is not disabled fail driver load.

- By default FCS stripping is disabled by the firmware. With this assumption
  driver decrements the indicated packet length by 4 bytes(FCS length).

- This patch ensures that FCS stripping is disabled during driver load time.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
diff -urpN patch5/drivers/net/vxge/vxge-config.c patch6/drivers/net/vxge/vxge-config.c
--- patch5/drivers/net/vxge/vxge-config.c	2009-09-04 01:24:25.000000000 -0700
+++ patch6/drivers/net/vxge/vxge-config.c	2009-09-04 01:33:43.000000000 -0700
@@ -2157,6 +2157,28 @@ exit:
 }
 
 /*
+ * vxge_hw_vpath_strip_fcs_check - Check for FCS strip.
+ */
+enum vxge_hw_status
+vxge_hw_vpath_strip_fcs_check(struct __vxge_hw_device *hldev, u64 vpath_mask)
+{
+	struct vxge_hw_vpmgmt_reg       __iomem *vpmgmt_reg;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	int i = 0, j = 0;
+
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+		if (!((vpath_mask) & vxge_mBIT(i)))
+			continue;
+		vpmgmt_reg = hldev->vpmgmt_reg[i];
+		for (j = 0; j < VXGE_HW_MAC_MAX_MAC_PORT_ID; j++) {
+			if (readq(&vpmgmt_reg->rxmac_cfg0_port_vpmgmt_clone[j])
+			& VXGE_HW_RXMAC_CFG0_PORT_VPMGMT_CLONE_STRIP_FCS)
+				return VXGE_HW_FAIL;
+		}
+	}
+	return status;
+}
+/*
  * vxge_hw_mgmt_reg_Write - Write Titan register.
  */
 enum vxge_hw_status
diff -urpN patch5/drivers/net/vxge/vxge-config.h patch6/drivers/net/vxge/vxge-config.h
--- patch5/drivers/net/vxge/vxge-config.h	2009-09-04 01:23:26.000000000 -0700
+++ patch6/drivers/net/vxge/vxge-config.h	2009-09-04 01:29:17.000000000 -0700
@@ -2201,6 +2201,8 @@ __vxge_hw_vpath_func_id_get(
 enum vxge_hw_status
 __vxge_hw_vpath_reset_check(struct __vxge_hw_virtualpath *vpath);
 
+enum vxge_hw_status
+vxge_hw_vpath_strip_fcs_check(struct __vxge_hw_device *hldev, u64 vpath_mask);
 /**
  * vxge_debug
  * @level: level of debug verbosity.
diff -urpN patch5/drivers/net/vxge/vxge-main.c patch6/drivers/net/vxge/vxge-main.c
--- patch5/drivers/net/vxge/vxge-main.c	2009-09-04 01:23:26.000000000 -0700
+++ patch6/drivers/net/vxge/vxge-main.c	2009-09-04 01:31:12.000000000 -0700
@@ -4244,6 +4244,15 @@ vxge_probe(struct pci_dev *pdev, const s
 			goto _exit3;
 	}
 
+	/* if FCS stripping is not disabled in MAC fail driver load */
+	if (vxge_hw_vpath_strip_fcs_check(hldev, vpath_mask) != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR,
+			"%s: FCS stripping is not disabled in MAC"
+			" failing driver load", VXGE_DRIVER_NAME);
+		ret = -EINVAL;
+		goto _exit4;
+	}
+
 	vxge_hw_device_debug_set(hldev, VXGE_ERR, VXGE_COMPONENT_LL);
 
 	/* set private device info */

