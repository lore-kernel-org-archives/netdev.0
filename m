From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/18] fm10k: update fm10k_slot_warn to use pcie_get_minimum link
Date: Tue, 15 Sep 2015 17:36:31 -0700
Message-ID: <1442363803-47237-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:25583 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753284AbbIPAgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 20:36:49 -0400
In-Reply-To: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This is useful in cases where we connect to a slot at Gen3, but the slot
is behind a bus which only connected at Gen2. This generally only
happens when a PCIe switch is in the sequence of devices, and can be
very confusing when you see slow performance with no obvious cause.

I am aware this patch has a few lines that break 80 characters, but
there does not seem to be a readable way to format them to less than 80
characters. Suggestions welcome.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 105 +++++++++++++++++++--------
 1 file changed, 76 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 8413ab5..2d87c32 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1705,22 +1705,86 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 
 static void fm10k_slot_warn(struct fm10k_intfc *interface)
 {
-	struct device *dev = &interface->pdev->dev;
+	enum pcie_link_width width = PCIE_LNK_WIDTH_UNKNOWN;
+	enum pci_bus_speed speed = PCI_SPEED_UNKNOWN;
 	struct fm10k_hw *hw = &interface->hw;
+	int max_gts = 0, expected_gts = 0;
 
-	if (hw->mac.ops.is_slot_appropriate(hw))
+	if (pcie_get_minimum_link(interface->pdev, &speed, &width) ||
+	    speed == PCI_SPEED_UNKNOWN || width == PCIE_LNK_WIDTH_UNKNOWN) {
+		dev_warn(&interface->pdev->dev,
+			 "Unable to determine PCI Express bandwidth.\n");
 		return;
+	}
+
+	switch (speed) {
+	case PCIE_SPEED_2_5GT:
+		/* 8b/10b encoding reduces max throughput by 20% */
+		max_gts = 2 * width;
+		break;
+	case PCIE_SPEED_5_0GT:
+		/* 8b/10b encoding reduces max throughput by 20% */
+		max_gts = 4 * width;
+		break;
+	case PCIE_SPEED_8_0GT:
+		/* 128b/130b encoding has less than 2% impact on throughput */
+		max_gts = 8 * width;
+		break;
+	default:
+		dev_warn(&interface->pdev->dev,
+			 "Unable to determine PCI Express bandwidth.\n");
+		return;
+	}
+
+	dev_info(&interface->pdev->dev,
+		 "PCI Express bandwidth of %dGT/s available\n",
+		 max_gts);
+	dev_info(&interface->pdev->dev,
+		 "(Speed:%s, Width: x%d, Encoding Loss:%s, Payload:%s)\n",
+		 (speed == PCIE_SPEED_8_0GT ? "8.0GT/s" :
+		  speed == PCIE_SPEED_5_0GT ? "5.0GT/s" :
+		  speed == PCIE_SPEED_2_5GT ? "2.5GT/s" :
+		  "Unknown"),
+		 hw->bus.width,
+		 (speed == PCIE_SPEED_2_5GT ? "20%" :
+		  speed == PCIE_SPEED_5_0GT ? "20%" :
+		  speed == PCIE_SPEED_8_0GT ? "<2%" :
+		  "Unknown"),
+		 (hw->bus.payload == fm10k_bus_payload_128 ? "128B" :
+		  hw->bus.payload == fm10k_bus_payload_256 ? "256B" :
+		  hw->bus.payload == fm10k_bus_payload_512 ? "512B" :
+		  "Unknown"));
 
-	dev_warn(dev,
-		 "For optimal performance, a %s %s slot is recommended.\n",
-		 (hw->bus_caps.width == fm10k_bus_width_pcie_x1 ? "x1" :
-		  hw->bus_caps.width == fm10k_bus_width_pcie_x4 ? "x4" :
-		  "x8"),
-		 (hw->bus_caps.speed == fm10k_bus_speed_2500 ? "2.5GT/s" :
-		  hw->bus_caps.speed == fm10k_bus_speed_5000 ? "5.0GT/s" :
-		  "8.0GT/s"));
-	dev_warn(dev,
-		 "A slot with more lanes and/or higher speed is suggested.\n");
+	switch (hw->bus_caps.speed) {
+	case fm10k_bus_speed_2500:
+		/* 8b/10b encoding reduces max throughput by 20% */
+		expected_gts = 2 * hw->bus_caps.width;
+		break;
+	case fm10k_bus_speed_5000:
+		/* 8b/10b encoding reduces max throughput by 20% */
+		expected_gts = 4 * hw->bus_caps.width;
+		break;
+	case fm10k_bus_speed_8000:
+		/* 128b/130b encoding has less than 2% impact on throughput */
+		expected_gts = 8 * hw->bus_caps.width;
+		break;
+	default:
+		dev_warn(&interface->pdev->dev,
+			 "Unable to determine expected PCI Express bandwidth.\n");
+		return;
+	}
+
+	if (max_gts < expected_gts) {
+		dev_warn(&interface->pdev->dev,
+			 "This device requires %dGT/s of bandwidth for optimal performance.\n",
+			 expected_gts);
+		dev_warn(&interface->pdev->dev,
+			 "A %sslot with x%d lanes is suggested.\n",
+			 (hw->bus_caps.speed == fm10k_bus_speed_2500 ? "2.5GT/s " :
+			  hw->bus_caps.speed == fm10k_bus_speed_5000 ? "5.0GT/s " :
+			  hw->bus_caps.speed == fm10k_bus_speed_8000 ? "8.0GT/s " : ""),
+			 hw->bus_caps.width);
+	}
 }
 
 /**
@@ -1739,7 +1803,6 @@ static int fm10k_probe(struct pci_dev *pdev,
 {
 	struct net_device *netdev;
 	struct fm10k_intfc *interface;
-	struct fm10k_hw *hw;
 	int err;
 
 	err = pci_enable_device_mem(pdev);
@@ -1783,7 +1846,6 @@ static int fm10k_probe(struct pci_dev *pdev,
 
 	interface->netdev = netdev;
 	interface->pdev = pdev;
-	hw = &interface->hw;
 
 	interface->uc_addr = ioremap(pci_resource_start(pdev, 0),
 				     FM10K_UC_ADDR_SIZE);
@@ -1825,21 +1887,6 @@ static int fm10k_probe(struct pci_dev *pdev,
 	/* Register PTP interface */
 	fm10k_ptp_register(interface);
 
-	/* print bus type/speed/width info */
-	dev_info(&pdev->dev, "(PCI Express:%s Width: %s Payload: %s)\n",
-		 (hw->bus.speed == fm10k_bus_speed_8000 ? "8.0GT/s" :
-		  hw->bus.speed == fm10k_bus_speed_5000 ? "5.0GT/s" :
-		  hw->bus.speed == fm10k_bus_speed_2500 ? "2.5GT/s" :
-		  "Unknown"),
-		 (hw->bus.width == fm10k_bus_width_pcie_x8 ? "x8" :
-		  hw->bus.width == fm10k_bus_width_pcie_x4 ? "x4" :
-		  hw->bus.width == fm10k_bus_width_pcie_x1 ? "x1" :
-		  "Unknown"),
-		 (hw->bus.payload == fm10k_bus_payload_128 ? "128B" :
-		  hw->bus.payload == fm10k_bus_payload_256 ? "256B" :
-		  hw->bus.payload == fm10k_bus_payload_512 ? "512B" :
-		  "Unknown"));
-
 	/* print warning for non-optimal configurations */
 	fm10k_slot_warn(interface);
 
-- 
2.4.3
