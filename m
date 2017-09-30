From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40e: refactor FW version checking
Date: Fri, 29 Sep 2017 17:45:07 -0700
Message-ID: <20170930004507.20072-16-jeffrey.t.kirsher@intel.com>
References: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:23279 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752572AbdI3Apv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 20:45:51 -0400
In-Reply-To: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The i40e driver now supports two different devices with two different
firmware versions. So be smart about how we handle these. Move the FW
version macros to the appropriate header file, and add a convenience
macro that checks the version based on the device. Then use this macro
to check whether or not the driver can use the new link info API.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 10 +++++++++-
 drivers/net/ethernet/intel/i40e/i40e_common.c       |  6 ++++--
 drivers/net/ethernet/intel/i40e/i40e_main.c         |  2 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 10 +++++++++-
 4 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 5d5f422cbae5..e2a9ec80a623 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -34,7 +34,15 @@
  */
 
 #define I40E_FW_API_VERSION_MAJOR	0x0001
-#define I40E_FW_API_VERSION_MINOR	0x0005
+#define I40E_FW_API_VERSION_MINOR_X722	0x0005
+#define I40E_FW_API_VERSION_MINOR_X710	0x0007
+
+#define I40E_FW_MINOR_VERSION(_h) ((_h)->mac.type == I40E_MAC_XL710 ? \
+					I40E_FW_API_VERSION_MINOR_X710 : \
+					I40E_FW_API_VERSION_MINOR_X722)
+
+/* API version 1.7 implements additional link and PHY-specific APIs  */
+#define I40E_MINOR_VER_GET_LINK_INFO_XL710 0x0007
 
 struct i40e_aq_desc {
 	__le16 flags;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 111426ba5fbc..7346d8850c8e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1593,8 +1593,10 @@ i40e_status i40e_aq_get_phy_capabilities(struct i40e_hw *hw,
 		status = I40E_ERR_UNKNOWN_PHY;
 
 	if (report_init) {
-		hw->phy.phy_types = le32_to_cpu(abilities->phy_type);
-		hw->phy.phy_types |= ((u64)abilities->phy_type_ext << 32);
+		if (hw->mac.type ==  I40E_MAC_XL710 &&
+		    hw->aq.api_maj_ver == I40E_FW_API_VERSION_MAJOR &&
+		    hw->aq.api_min_ver >= I40E_MINOR_VER_GET_LINK_INFO_XL710)
+			status = i40e_aq_get_link_info(hw, true, NULL, NULL);
 	}
 
 	return status;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 8a44793d5390..47f71d7c3ae0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11434,7 +11434,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		 i40e_nvm_version_str(hw));
 
 	if (hw->aq.api_maj_ver == I40E_FW_API_VERSION_MAJOR &&
-	    hw->aq.api_min_ver > I40E_FW_API_VERSION_MINOR)
+	    hw->aq.api_min_ver > I40E_FW_MINOR_VERSION(hw))
 		dev_info(&pdev->dev,
 			 "The driver for the device detected a newer version of the NVM image than expected. Please install the most recent version of the network driver.\n");
 	else if (hw->aq.api_maj_ver == 1 && hw->aq.api_min_ver < 4)
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index 83e63e55c4b4..f9f48d1900b0 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -34,7 +34,15 @@
  */
 
 #define I40E_FW_API_VERSION_MAJOR	0x0001
-#define I40E_FW_API_VERSION_MINOR	0x0005
+#define I40E_FW_API_VERSION_MINOR_X722	0x0005
+#define I40E_FW_API_VERSION_MINOR_X710	0x0007
+
+#define I40E_FW_MINOR_VERSION(_h) ((_h)->mac.type == I40E_MAC_XL710 ? \
+					I40E_FW_API_VERSION_MINOR_X710 : \
+					I40E_FW_API_VERSION_MINOR_X722)
+
+/* API version 1.7 implements additional link and PHY-specific APIs  */
+#define I40E_MINOR_VER_GET_LINK_INFO_XL710 0x0007
 
 struct i40e_aq_desc {
 	__le16 flags;
-- 
2.14.1
