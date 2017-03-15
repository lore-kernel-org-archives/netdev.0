From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 01/12] i40e: Acquire NVM lock before reads on all devices
Date: Wed, 15 Mar 2017 02:25:34 -0700
Message-ID: <20170315092545.63654-2-jeffrey.t.kirsher@intel.com>
References: <20170315092545.63654-1-jeffrey.t.kirsher@intel.com>
Cc: Aaron Salter <aaron.k.salter@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52220 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751935AbdCOJZz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 05:25:55 -0400
In-Reply-To: <20170315092545.63654-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Salter <aaron.k.salter@intel.com>

Acquire NVM lock before reads on all devices.  Previously, locks were
only used for X722 and later.  Fixes an issue where simultaneous X710
NVM accesses were interfering with each other.

Change-ID: If570bb7acf958cef58725ec2a2011cead6f80638
Signed-off-by: Aaron Salter <aaron.k.salter@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 38ee18f11124..800bd55d0159 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -292,14 +292,14 @@ i40e_status i40e_read_nvm_word(struct i40e_hw *hw, u16 offset,
 {
 	enum i40e_status_code ret_code = 0;
 
-	if (hw->flags & I40E_HW_FLAG_AQ_SRCTL_ACCESS_ENABLE) {
-		ret_code = i40e_acquire_nvm(hw, I40E_RESOURCE_READ);
-		if (!ret_code) {
+	ret_code = i40e_acquire_nvm(hw, I40E_RESOURCE_READ);
+	if (!ret_code) {
+		if (hw->flags & I40E_HW_FLAG_AQ_SRCTL_ACCESS_ENABLE) {
 			ret_code = i40e_read_nvm_word_aq(hw, offset, data);
-			i40e_release_nvm(hw);
+		} else {
+			ret_code = i40e_read_nvm_word_srctl(hw, offset, data);
 		}
-	} else {
-		ret_code = i40e_read_nvm_word_srctl(hw, offset, data);
+		i40e_release_nvm(hw);
 	}
 	return ret_code;
 }
-- 
2.12.0
