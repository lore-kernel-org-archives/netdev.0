From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/17] i40e: update fw version text string per previous product formats
Date: Mon, 12 Oct 2015 22:53:10 -0700
Message-ID: <1444715598-20970-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65148 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752044AbbJMFx0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 01:53:26 -0400
In-Reply-To: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch moves the internal fw version and fw api version info to be
output in probe.  The nvm version, etrack and oem version info are now
configured for output via ethtool -i.

Change-ID: I05d490093a7137dbefcdef263d014d1e5c9e83d0
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 10 ++++++----
 drivers/net/ethernet/intel/i40e/i40e_main.c |  7 +++++++
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index f26dcb2..cfe8f83 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -107,6 +107,8 @@
 #define I40E_NVM_VERSION_LO_MASK   (0xff << I40E_NVM_VERSION_LO_SHIFT)
 #define I40E_NVM_VERSION_HI_SHIFT  12
 #define I40E_NVM_VERSION_HI_MASK   (0xf << I40E_NVM_VERSION_HI_SHIFT)
+#define I40E_OEM_VER_BUILD_MASK    0xff00
+#define I40E_OEM_VER_PATCH_MASK    0xff
 
 /* The values in here are decimal coded as hex as is the case in the NVM map*/
 #define I40E_CURRENT_NVM_VERSION_HI 0x2
@@ -587,14 +589,14 @@ static inline char *i40e_fw_version_str(struct i40e_hw *hw)
 	static char buf[32];
 
 	snprintf(buf, sizeof(buf),
-		 "f%d.%d.%05d a%d.%d n%x.%02x e%x",
-		 hw->aq.fw_maj_ver, hw->aq.fw_min_ver, hw->aq.fw_build,
-		 hw->aq.api_maj_ver, hw->aq.api_min_ver,
+		 "%x.%02x 0x%x %d.%d.%d",
 		 (hw->nvm.version & I40E_NVM_VERSION_HI_MASK) >>
 			I40E_NVM_VERSION_HI_SHIFT,
 		 (hw->nvm.version & I40E_NVM_VERSION_LO_MASK) >>
 			I40E_NVM_VERSION_LO_SHIFT,
-		 (hw->nvm.eetrack & 0xffffff));
+		 hw->nvm.eetrack, (hw->nvm.oem_ver >> 24),
+		 (hw->nvm.oem_ver & I40E_OEM_VER_BUILD_MASK) >> 8,
+		 hw->nvm.oem_ver & I40E_OEM_VER_PATCH_MASK);
 
 	return buf;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d5d8b66..45b3292 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10064,6 +10064,13 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	err = i40e_init_adminq(hw);
 	dev_info(&pdev->dev, "%s\n", i40e_fw_version_str(hw));
+
+	/* provide additional fw info, like api and ver */
+	dev_info(&pdev->dev, "fw_version:%d.%d.%05d\n",
+		 hw->aq.fw_maj_ver, hw->aq.fw_min_ver, hw->aq.fw_build);
+	dev_info(&pdev->dev, "fw api version:%d.%d\n",
+		 hw->aq.api_maj_ver, hw->aq.api_min_ver);
+
 	if (err) {
 		dev_info(&pdev->dev,
 			 "The driver for the device stopped because the NVM image is newer than expected. You must install the most recent version of the network driver.\n");
-- 
2.4.3
