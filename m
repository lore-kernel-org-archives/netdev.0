From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH] enic: Support newer version of firmware devcmd
	CMD_MCPU_FW_INFO
Date: Tue, 08 Mar 2011 17:35:30 -0800
Message-ID: <20110309013530.17378.56666.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:27168 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274Ab1CIBfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 20:35:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

This patch provides support to the newer version of firmware devcmd CMD_MCPU_FW_INFO
that returns additional information (ASIC type and revision) about the underlying hardware.
This knowledge is required by the driver to implement any hardware specific features.

Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic.h        |    2 +-
 drivers/net/enic/vnic_dev.c    |    7 +++++++
 drivers/net/enic/vnic_devcmd.h |   38 ++++++++++++++++++++++++++++++++++++--
 3 files changed, 44 insertions(+), 3 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index e816bbb..3a3c3c8 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.10"
+#define DRV_VERSION		"2.1.1.12"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index c489e72..c089b36 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -408,10 +408,17 @@ int vnic_dev_fw_info(struct vnic_dev *vdev,
 		if (!vdev->fw_info)
 			return -ENOMEM;
 
+		memset(vdev->fw_info, 0, sizeof(struct vnic_devcmd_fw_info));
+
 		a0 = vdev->fw_info_pa;
+		a1 = sizeof(struct vnic_devcmd_fw_info);
 
 		/* only get fw_info once and cache it */
 		err = vnic_dev_cmd(vdev, CMD_MCPU_FW_INFO, &a0, &a1, wait);
+		if (err == ERR_ECMDUNKNOWN) {
+			err = vnic_dev_cmd(vdev, CMD_MCPU_FW_INFO_OLD,
+				&a0, &a1, wait);
+		}
 	}
 
 	*fw_info = vdev->fw_info;
diff --git a/drivers/net/enic/vnic_devcmd.h b/drivers/net/enic/vnic_devcmd.h
index 9abb3d5..d833a07 100644
--- a/drivers/net/enic/vnic_devcmd.h
+++ b/drivers/net/enic/vnic_devcmd.h
@@ -80,8 +80,34 @@
 enum vnic_devcmd_cmd {
 	CMD_NONE                = _CMDC(_CMD_DIR_NONE, _CMD_VTYPE_NONE, 0),
 
-	/* mcpu fw info in mem: (u64)a0=paddr to struct vnic_devcmd_fw_info */
-	CMD_MCPU_FW_INFO        = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 1),
+	/*
+	 * mcpu fw info in mem:
+	 * in:
+	 *   (u64)a0=paddr to struct vnic_devcmd_fw_info
+	 * action:
+	 *   Fills in struct vnic_devcmd_fw_info (128 bytes)
+	 * note:
+	 *   An old definition of CMD_MCPU_FW_INFO
+	 */
+	CMD_MCPU_FW_INFO_OLD    = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 1),
+
+	/*
+	 * mcpu fw info in mem:
+	 * in:
+	 *   (u64)a0=paddr to struct vnic_devcmd_fw_info
+	 *   (u16)a1=size of the structure
+	 * out:
+	 *	 (u16)a1=0                          for in:a1 = 0,
+	 *	         data size actually written for other values.
+	 * action:
+	 *   Fills in first 128 bytes of vnic_devcmd_fw_info for in:a1 = 0,
+	 *            first in:a1 bytes               for 0 < in:a1 <= 132,
+	 *            132 bytes                       for other values of in:a1.
+	 * note:
+	 *   CMD_MCPU_FW_INFO and CMD_MCPU_FW_INFO_OLD have the same enum 1
+	 *   for source compatibility.
+	 */
+	CMD_MCPU_FW_INFO        = _CMDC(_CMD_DIR_RW, _CMD_VTYPE_ALL, 1),
 
 	/* dev-specific block member:
 	 *    in: (u16)a0=offset,(u8)a1=size
@@ -291,11 +317,19 @@ enum vnic_devcmd_error {
 	ERR_EMAXRES = 10,
 };
 
+/*
+ * note: hw_version and asic_rev refer to the same thing,
+ *       but have different formats. hw_version is
+ *       a 32-byte string (e.g. "A2") and asic_rev is
+ *       a 16-bit integer (e.g. 0xA2).
+ */
 struct vnic_devcmd_fw_info {
 	char fw_version[32];
 	char fw_build[32];
 	char hw_version[32];
 	char hw_serial_number[32];
+	u16 asic_type;
+	u16 asic_rev;
 };
 
 struct vnic_devcmd_notify {

