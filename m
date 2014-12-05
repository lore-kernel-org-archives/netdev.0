From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] ixgbevf: add support for X550 VFs
Date: Fri,  5 Dec 2014 09:52:52 -0800
Message-ID: <1417801973-28793-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1417801973-28793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:7195 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751911AbaLERyB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2014 12:54:01 -0500
In-Reply-To: <1417801973-28793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch adds initial support for VFs on a new mac - X550.

The patch adds the basic structures and device IDs for the X550 VFs
that would allow the driver to load and pass traffic.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/defines.h      |  2 ++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  4 ++++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 25 ++++++++++++++++++-----
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 10 +++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.h           |  2 ++
 5 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/defines.h b/drivers/net/ethernet/intel/ixgbevf/defines.h
index 05e4f32..7412d37 100644
--- a/drivers/net/ethernet/intel/ixgbevf/defines.h
+++ b/drivers/net/ethernet/intel/ixgbevf/defines.h
@@ -31,6 +31,8 @@
 /* Device IDs */
 #define IXGBE_DEV_ID_82599_VF           0x10ED
 #define IXGBE_DEV_ID_X540_VF            0x1515
+#define IXGBE_DEV_ID_X550_VF		0x1565
+#define IXGBE_DEV_ID_X550EM_X_VF	0x15A8
 
 #define IXGBE_VF_IRQ_CLEAR_MASK         7
 #define IXGBE_VF_MAX_TX_QUEUES          8
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index bb6726c..8c44ab2 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -432,10 +432,14 @@ enum ixbgevf_state_t {
 enum ixgbevf_boards {
 	board_82599_vf,
 	board_X540_vf,
+	board_X550_vf,
+	board_X550EM_x_vf,
 };
 
 extern const struct ixgbevf_info ixgbevf_82599_vf_info;
 extern const struct ixgbevf_info ixgbevf_X540_vf_info;
+extern const struct ixgbevf_info ixgbevf_X550_vf_info;
+extern const struct ixgbevf_info ixgbevf_X550EM_x_vf_info;
 extern const struct ixgbe_mbx_operations ixgbevf_mbx_ops;
 
 /* needed by ethtool.c */
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 755f71f..54f7f9cd 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -66,6 +66,8 @@ static char ixgbevf_copyright[] =
 static const struct ixgbevf_info *ixgbevf_info_tbl[] = {
 	[board_82599_vf] = &ixgbevf_82599_vf_info,
 	[board_X540_vf]  = &ixgbevf_X540_vf_info,
+	[board_X550_vf]  = &ixgbevf_X550_vf_info,
+	[board_X550EM_x_vf] = &ixgbevf_X550EM_x_vf_info,
 };
 
 /* ixgbevf_pci_tbl - PCI Device ID Table
@@ -79,6 +81,8 @@ static const struct ixgbevf_info *ixgbevf_info_tbl[] = {
 static const struct pci_device_id ixgbevf_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_VF), board_82599_vf },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540_VF), board_X540_vf },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550_VF), board_X550_vf },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_VF), board_X550EM_x_vf },
 	/* required last entry */
 	{0, }
 };
@@ -3529,7 +3533,7 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
 		max_possible_frame = IXGBE_MAX_JUMBO_FRAME_SIZE;
 		break;
 	default:
-		if (adapter->hw.mac.type == ixgbe_mac_X540_vf)
+		if (adapter->hw.mac.type != ixgbe_mac_82599_vf)
 			max_possible_frame = IXGBE_MAX_JUMBO_FRAME_SIZE;
 		break;
 	}
@@ -3860,12 +3864,23 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	ixgbevf_init_last_counter_stats(adapter);
 
-	/* print the MAC address */
-	hw_dbg(hw, "%pM\n", netdev->dev_addr);
+	/* print the VF info */
+	dev_info(&pdev->dev, "%pM\n", netdev->dev_addr);
+	dev_info(&pdev->dev, "MAC: %d\n", hw->mac.type);
 
-	hw_dbg(hw, "MAC: %d\n", hw->mac.type);
+	switch (hw->mac.type) {
+	case ixgbe_mac_X550_vf:
+		dev_info(&pdev->dev, "Intel(R) X550 Virtual Function\n");
+		break;
+	case ixgbe_mac_X540_vf:
+		dev_info(&pdev->dev, "Intel(R) X540 Virtual Function\n");
+		break;
+	case ixgbe_mac_82599_vf:
+	default:
+		dev_info(&pdev->dev, "Intel(R) 82599 Virtual Function\n");
+		break;
+	}
 
-	hw_dbg(hw, "Intel(R) 82599 Virtual Function\n");
 	return 0;
 
 err_register:
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 9cddd56..cdb53be 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -617,3 +617,13 @@ const struct ixgbevf_info ixgbevf_X540_vf_info = {
 	.mac = ixgbe_mac_X540_vf,
 	.mac_ops = &ixgbevf_mac_ops,
 };
+
+const struct ixgbevf_info ixgbevf_X550_vf_info = {
+	.mac = ixgbe_mac_X550_vf,
+	.mac_ops = &ixgbevf_mac_ops,
+};
+
+const struct ixgbevf_info ixgbevf_X550EM_x_vf_info = {
+	.mac = ixgbe_mac_X550EM_x_vf,
+	.mac_ops = &ixgbevf_mac_ops,
+};
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index aa8cc8d..5b17242 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -74,6 +74,8 @@ enum ixgbe_mac_type {
 	ixgbe_mac_unknown = 0,
 	ixgbe_mac_82599_vf,
 	ixgbe_mac_X540_vf,
+	ixgbe_mac_X550_vf,
+	ixgbe_mac_X550EM_x_vf,
 	ixgbe_num_macs
 };
 
-- 
1.9.3
