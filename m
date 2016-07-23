From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] ixgbevf: add VF support for new hardware
Date: Fri, 22 Jul 2016 23:49:43 -0700
Message-ID: <1469256591-109822-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469256591-109822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55381 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751082AbcGWGuL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 02:50:11 -0400
In-Reply-To: <1469256591-109822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch add VF support for the new X553 hardware.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/defines.h      | 1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      | 2 ++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 2 ++
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 5 +++++
 drivers/net/ethernet/intel/ixgbevf/vf.h           | 1 +
 5 files changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/defines.h b/drivers/net/ethernet/intel/ixgbevf/defines.h
index ae09d60..8617cae 100644
--- a/drivers/net/ethernet/intel/ixgbevf/defines.h
+++ b/drivers/net/ethernet/intel/ixgbevf/defines.h
@@ -32,6 +32,7 @@
 #define IXGBE_DEV_ID_X540_VF		0x1515
 #define IXGBE_DEV_ID_X550_VF		0x1565
 #define IXGBE_DEV_ID_X550EM_X_VF	0x15A8
+#define IXGBE_DEV_ID_X550EM_A_VF	0x15C5
 
 #define IXGBE_DEV_ID_82599_VF_HV	0x152E
 #define IXGBE_DEV_ID_X540_VF_HV		0x1530
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index d5944c3..be52f59 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -457,6 +457,7 @@ enum ixgbevf_boards {
 	board_X550_vf_hv,
 	board_X550EM_x_vf,
 	board_X550EM_x_vf_hv,
+	board_x550em_a_vf,
 };
 
 enum ixgbevf_xcast_modes {
@@ -470,6 +471,7 @@ extern const struct ixgbevf_info ixgbevf_X540_vf_info;
 extern const struct ixgbevf_info ixgbevf_X550_vf_info;
 extern const struct ixgbevf_info ixgbevf_X550EM_x_vf_info;
 extern const struct ixgbe_mbx_operations ixgbevf_mbx_ops;
+extern const struct ixgbevf_info ixgbevf_x550em_a_vf_info;
 
 extern const struct ixgbevf_info ixgbevf_82599_vf_hv_info;
 extern const struct ixgbevf_info ixgbevf_X540_vf_hv_info;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index a1c83c1..1bffac3 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -70,6 +70,7 @@ static const struct ixgbevf_info *ixgbevf_info_tbl[] = {
 	[board_X550_vf_hv]	= &ixgbevf_X550_vf_hv_info,
 	[board_X550EM_x_vf]	= &ixgbevf_X550EM_x_vf_info,
 	[board_X550EM_x_vf_hv]	= &ixgbevf_X550EM_x_vf_hv_info,
+	[board_x550em_a_vf]	= &ixgbevf_x550em_a_vf_info,
 };
 
 /* ixgbevf_pci_tbl - PCI Device ID Table
@@ -89,6 +90,7 @@ static const struct pci_device_id ixgbevf_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550_VF_HV), board_X550_vf_hv },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_VF), board_X550EM_x_vf },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_VF_HV), board_X550EM_x_vf_hv},
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_A_VF), board_x550em_a_vf },
 	/* required last entry */
 	{0, }
 };
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index aa2b1e8..cb409b3 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -1007,3 +1007,8 @@ const struct ixgbevf_info ixgbevf_X550EM_x_vf_hv_info = {
 	.mac = ixgbe_mac_X550EM_x_vf,
 	.mac_ops = &ixgbevf_hv_mac_ops,
 };
+
+const struct ixgbevf_info ixgbevf_x550em_a_vf_info = {
+	.mac = ixgbe_mac_x550em_a_vf,
+	.mac_ops = &ixgbevf_mac_ops,
+};
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index 2cac610..e3a0dea 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -78,6 +78,7 @@ enum ixgbe_mac_type {
 	ixgbe_mac_X540_vf,
 	ixgbe_mac_X550_vf,
 	ixgbe_mac_X550EM_x_vf,
+	ixgbe_mac_x550em_a_vf,
 	ixgbe_num_macs
 };
 
-- 
2.5.5
