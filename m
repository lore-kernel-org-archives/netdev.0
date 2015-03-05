From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] i40e: Ioremap changes
Date: Thu,  5 Mar 2015 08:46:29 -0800
Message-ID: <1425573992-30955-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai <anjali.singhai@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:47536 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945965AbbCEQqk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 11:46:40 -0500
In-Reply-To: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai <anjali.singhai@intel.com>

For future device support we do not want to map the whole CSR space since some
of it is mapped by other drivers with different mapping methods.

Note: As a side effect, the flash region (if exposed through the memory map)
gets unmapped too since it follows the future use region.

Change-ID: Ic729a2eacd692984220b1a415ff4fa0f98ea419a
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 ++++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index c513731..ce3fbb8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -72,6 +72,7 @@
 
 #define I40E_MAX_NUM_DESCRIPTORS      4096
 #define I40E_MAX_REGISTER     0x800000
+#define I40E_MAX_CSR_SPACE (4 * 1024 * 1024 - 64 * 1024)
 #define I40E_DEFAULT_NUM_DESCRIPTORS  512
 #define I40E_REQ_DESCRIPTOR_MULTIPLE  32
 #define I40E_MIN_NUM_DESCRIPTORS      64
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 02b57c3..f769005 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9459,6 +9459,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct i40e_pf *pf;
 	struct i40e_hw *hw;
 	static u16 pfs_found;
+	u32 ioremap_len;
 	u16 link_status;
 	int err = 0;
 	u32 len;
@@ -9507,8 +9508,11 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	hw = &pf->hw;
 	hw->back = pf;
-	hw->hw_addr = ioremap(pci_resource_start(pdev, 0),
-			      pci_resource_len(pdev, 0));
+
+	ioremap_len = min_t(int, pci_resource_len(pdev, 0),
+			    I40E_MAX_CSR_SPACE);
+
+	hw->hw_addr = ioremap(pci_resource_start(pdev, 0), ioremap_len);
 	if (!hw->hw_addr) {
 		err = -EIO;
 		dev_info(&pdev->dev, "ioremap(0x%04x, 0x%04x) failed: 0x%x\n",
-- 
1.9.3
