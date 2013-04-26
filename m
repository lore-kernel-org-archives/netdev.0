From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/8] ixgbe: fix register access during ethtool loopback test
Date: Thu, 25 Apr 2013 21:57:08 -0700
Message-ID: <1366952231-16727-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366952231-16727-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45056 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751374Ab3DZE5S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Apr 2013 00:57:18 -0400
In-Reply-To: <1366952231-16727-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch cleans up the logic in ixgbe_setup_loopback_test() to only access
registers applicable to the MAC type. AUTOC is only valid on MACs older than
X540. MACC is used for X540.

In addition it removes a read of AUTOC and uses the stored value to force the
link up.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 26 +++++++++++++-----------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index bbe00bc..509d3ae 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1609,16 +1609,9 @@ static int ixgbe_setup_loopback_test(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 reg_data;
 
-	/* X540 needs to set the MACC.FLU bit to force link up */
-	if (adapter->hw.mac.type == ixgbe_mac_X540) {
-		reg_data = IXGBE_READ_REG(hw, IXGBE_MACC);
-		reg_data |= IXGBE_MACC_FLU;
-		IXGBE_WRITE_REG(hw, IXGBE_MACC, reg_data);
-	}
 
-	/* right now we only support MAC loopback in the driver */
-	reg_data = IXGBE_READ_REG(hw, IXGBE_HLREG0);
 	/* Setup MAC loopback */
+	reg_data = IXGBE_READ_REG(hw, IXGBE_HLREG0);
 	reg_data |= IXGBE_HLREG0_LPBK;
 	IXGBE_WRITE_REG(hw, IXGBE_HLREG0, reg_data);
 
@@ -1626,10 +1619,19 @@ static int ixgbe_setup_loopback_test(struct ixgbe_adapter *adapter)
 	reg_data |= IXGBE_FCTRL_BAM | IXGBE_FCTRL_SBP | IXGBE_FCTRL_MPE;
 	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, reg_data);
 
-	reg_data = IXGBE_READ_REG(hw, IXGBE_AUTOC);
-	reg_data &= ~IXGBE_AUTOC_LMS_MASK;
-	reg_data |= IXGBE_AUTOC_LMS_10G_LINK_NO_AN | IXGBE_AUTOC_FLU;
-	IXGBE_WRITE_REG(hw, IXGBE_AUTOC, reg_data);
+	/* X540 needs to set the MACC.FLU bit to force link up */
+	if (adapter->hw.mac.type == ixgbe_mac_X540) {
+		reg_data = IXGBE_READ_REG(hw, IXGBE_MACC);
+		reg_data |= IXGBE_MACC_FLU;
+		IXGBE_WRITE_REG(hw, IXGBE_MACC, reg_data);
+	} else {
+		if (hw->mac.orig_autoc) {
+			reg_data = hw->mac.orig_autoc | IXGBE_AUTOC_FLU;
+			IXGBE_WRITE_REG(hw, IXGBE_AUTOC, reg_data);
+		} else {
+			return 10;
+		}
+	}
 	IXGBE_WRITE_FLUSH(hw);
 	usleep_range(10000, 20000);
 
-- 
1.7.11.7
