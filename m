From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] e1000e: Resolve intermittent negotiation issue on 82574/82583.
Date: Thu,  3 May 2012 02:56:26 -0700
Message-ID: <1336038992-3144-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51334 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754069Ab2ECJ4f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 05:56:35 -0400
In-Reply-To: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

For 82574 and 82583 devices, resolve an intermittent link issue where
the link negotiates to 100Mbps rather than 1Gbps when powering off the
PHY and powering on the PHY after several seconds.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/phy.c |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index bd5ef64..ad22b8c 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -722,8 +722,24 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 		phy_data |= M88E1000_PSCR_POLARITY_REVERSAL;
 
 	/* Enable downshift on BM (disabled by default) */
-	if (phy->type == e1000_phy_bm)
+	if (phy->type == e1000_phy_bm) {
+		/* For 82574/82583, first disable then enable downshift */
+		if (phy->id == BME1000_E_PHY_ID_R2) {
+			phy_data &= ~BME1000_PSCR_ENABLE_DOWNSHIFT;
+			ret_val = e1e_wphy(hw, M88E1000_PHY_SPEC_CTRL,
+					   phy_data);
+			if (ret_val)
+				return ret_val;
+			/* Commit the changes. */
+			ret_val = e1000e_commit_phy(hw);
+			if (ret_val) {
+				e_dbg("Error committing the PHY changes\n");
+				return ret_val;
+			}
+		}
+
 		phy_data |= BME1000_PSCR_ENABLE_DOWNSHIFT;
+	}
 
 	ret_val = e1e_wphy(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
 	if (ret_val)
-- 
1.7.7.6
