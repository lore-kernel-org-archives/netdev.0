From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/17] i40e: X722 is on the IOSF bus and does not report the PCI bus info
Date: Thu, 15 Oct 2015 02:40:00 -0700
Message-ID: <1444902004-14433-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12861 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752426AbbJOJmd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 05:42:33 -0400
In-Reply-To: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

X722 will report Gen 1x1 in the PCI config space as it is on
IOSF bus, so skip the PCI bus link/speed check.

Change-ID: Icd5f5751dc7fb00dccf0d5dc5a0a644948e7062e
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 69 ++++++++++++++++++++---------
 2 files changed, 50 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index c8591b9..d587a05 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -333,6 +333,7 @@ struct i40e_pf {
 #define I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE	BIT_ULL(38)
 #define I40E_FLAG_LINK_POLLING_ENABLED		BIT_ULL(39)
 #define I40E_FLAG_VEB_MODE_ENABLED		BIT_ULL(40)
+#define I40E_FLAG_NO_PCI_LINK_CHECK		BIT_ULL(42)
 
 	/* tracks features that get auto disabled by errors */
 	u64 auto_disable_flags;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 0f8ab65..2217078 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10308,26 +10308,55 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	i40e_fcoe_vsi_setup(pf);
 
 #endif
-	/* Get the negotiated link width and speed from PCI config space */
-	pcie_capability_read_word(pf->pdev, PCI_EXP_LNKSTA, &link_status);
-
-	i40e_set_pci_config_data(hw, link_status);
-
-	dev_info(&pdev->dev, "PCI-Express: %s %s\n",
-		(hw->bus.speed == i40e_bus_speed_8000 ? "Speed 8.0GT/s" :
-		 hw->bus.speed == i40e_bus_speed_5000 ? "Speed 5.0GT/s" :
-		 hw->bus.speed == i40e_bus_speed_2500 ? "Speed 2.5GT/s" :
-		 "Unknown"),
-		(hw->bus.width == i40e_bus_width_pcie_x8 ? "Width x8" :
-		 hw->bus.width == i40e_bus_width_pcie_x4 ? "Width x4" :
-		 hw->bus.width == i40e_bus_width_pcie_x2 ? "Width x2" :
-		 hw->bus.width == i40e_bus_width_pcie_x1 ? "Width x1" :
-		 "Unknown"));
-
-	if (hw->bus.width < i40e_bus_width_pcie_x8 ||
-	    hw->bus.speed < i40e_bus_speed_8000) {
-		dev_warn(&pdev->dev, "PCI-Express bandwidth available for this device may be insufficient for optimal performance.\n");
-		dev_warn(&pdev->dev, "Please move the device to a different PCI-e link with more lanes and/or higher transfer rate.\n");
+#define PCI_SPEED_SIZE 8
+#define PCI_WIDTH_SIZE 8
+	/* Devices on the IOSF bus do not have this information
+	 * and will report PCI Gen 1 x 1 by default so don't bother
+	 * checking them.
+	 */
+	if (!(pf->flags & I40E_FLAG_NO_PCI_LINK_CHECK)) {
+		char speed[PCI_SPEED_SIZE] = "Unknown";
+		char width[PCI_WIDTH_SIZE] = "Unknown";
+
+		/* Get the negotiated link width and speed from PCI config
+		 * space
+		 */
+		pcie_capability_read_word(pf->pdev, PCI_EXP_LNKSTA,
+					  &link_status);
+
+		i40e_set_pci_config_data(hw, link_status);
+
+		switch (hw->bus.speed) {
+		case i40e_bus_speed_8000:
+			strncpy(speed, "8.0", PCI_SPEED_SIZE); break;
+		case i40e_bus_speed_5000:
+			strncpy(speed, "5.0", PCI_SPEED_SIZE); break;
+		case i40e_bus_speed_2500:
+			strncpy(speed, "2.5", PCI_SPEED_SIZE); break;
+		default:
+			break;
+		}
+		switch (hw->bus.width) {
+		case i40e_bus_width_pcie_x8:
+			strncpy(width, "8", PCI_WIDTH_SIZE); break;
+		case i40e_bus_width_pcie_x4:
+			strncpy(width, "4", PCI_WIDTH_SIZE); break;
+		case i40e_bus_width_pcie_x2:
+			strncpy(width, "2", PCI_WIDTH_SIZE); break;
+		case i40e_bus_width_pcie_x1:
+			strncpy(width, "1", PCI_WIDTH_SIZE); break;
+		default:
+			break;
+		}
+
+		dev_info(&pdev->dev, "PCI-Express: Speed %sGT/s Width x%s\n",
+			 speed, width);
+
+		if (hw->bus.width < i40e_bus_width_pcie_x8 ||
+		    hw->bus.speed < i40e_bus_speed_8000) {
+			dev_warn(&pdev->dev, "PCI-Express bandwidth available for this device may be insufficient for optimal performance.\n");
+			dev_warn(&pdev->dev, "Please move the device to a different PCI-e link with more lanes and/or higher transfer rate.\n");
+		}
 	}
 
 	/* get the requested speeds from the fw */
-- 
2.4.3
