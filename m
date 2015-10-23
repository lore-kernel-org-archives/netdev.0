From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/17] i40e: Fix an incorrect OEM version string
Date: Fri, 23 Oct 2015 06:17:48 -0700
Message-ID: <1445606279-19345-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13278 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752188AbbJWNST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 09:18:19 -0400
In-Reply-To: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes a problem where the driver output of the OEM
version string varied from the other tools.  The mask value
and the order of operations were incorrect, per the original
change request.  Without this patch, the version string will
appear incorrect from the driver.

Change-ID: Ie1ca6485284b4ce3b57e5a99b18b7641617c7ef7
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 7c2b2e8..4dd3e26 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -109,8 +109,10 @@
 #define I40E_NVM_VERSION_LO_MASK   (0xff << I40E_NVM_VERSION_LO_SHIFT)
 #define I40E_NVM_VERSION_HI_SHIFT  12
 #define I40E_NVM_VERSION_HI_MASK   (0xf << I40E_NVM_VERSION_HI_SHIFT)
-#define I40E_OEM_VER_BUILD_MASK    0xff00
+#define I40E_OEM_VER_BUILD_MASK    0xffff
 #define I40E_OEM_VER_PATCH_MASK    0xff
+#define I40E_OEM_VER_BUILD_SHIFT   8
+#define I40E_OEM_VER_SHIFT         24
 
 /* The values in here are decimal coded as hex as is the case in the NVM map*/
 #define I40E_CURRENT_NVM_VERSION_HI 0x2
@@ -594,6 +596,15 @@ struct i40e_device {
 static inline char *i40e_nvm_version_str(struct i40e_hw *hw)
 {
 	static char buf[32];
+	u32 full_ver;
+	u8 ver, patch;
+	u16 build;
+
+	full_ver = hw->nvm.oem_ver;
+	ver = (u8)(full_ver >> I40E_OEM_VER_SHIFT);
+	build = (u16)((full_ver >> I40E_OEM_VER_BUILD_SHIFT)
+		 & I40E_OEM_VER_BUILD_MASK);
+	patch = (u8)(full_ver & I40E_OEM_VER_PATCH_MASK);
 
 	snprintf(buf, sizeof(buf),
 		 "%x.%02x 0x%x %d.%d.%d",
@@ -601,9 +612,7 @@ static inline char *i40e_nvm_version_str(struct i40e_hw *hw)
 			I40E_NVM_VERSION_HI_SHIFT,
 		 (hw->nvm.version & I40E_NVM_VERSION_LO_MASK) >>
 			I40E_NVM_VERSION_LO_SHIFT,
-		 hw->nvm.eetrack, (hw->nvm.oem_ver >> 24),
-		 (hw->nvm.oem_ver & I40E_OEM_VER_BUILD_MASK) >> 8,
-		 hw->nvm.oem_ver & I40E_OEM_VER_PATCH_MASK);
+		 hw->nvm.eetrack, ver, build, patch);
 
 	return buf;
 }
-- 
2.4.3
