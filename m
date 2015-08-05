From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] e1000e: Fix EEE in Sx implementation
Date: Wed,  5 Aug 2015 16:52:11 -0700
Message-ID: <1438818735-38115-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Raanan Avargil <raanan.avargil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:11984 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753690AbbHEXwU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2015 19:52:20 -0400
In-Reply-To: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raanan Avargil <raanan.avargil@intel.com>

This patch implements the EEE in Sx code so that it only applies to parts
that support EEE in Sx (as opposed to all parts that support EEE).
It also uses the existing eee_advert and eee_lp_abiliity to set just the
bits (100/1000) that should be set.

Signed-off-by: Raanan Avargil <raanan.avargil@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index fea1601..b32bc48 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6317,6 +6317,33 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool runtime)
 			return retval;
 	}
 
+	/* Ensure that the appropriate bits are set in LPI_CTRL
+	 * for EEE in Sx
+	 */
+	if ((hw->phy.type >= e1000_phy_i217) &&
+	    adapter->eee_advert && hw->dev_spec.ich8lan.eee_lp_ability) {
+		u16 lpi_ctrl = 0;
+
+		retval = hw->phy.ops.acquire(hw);
+		if (!retval) {
+			retval = e1e_rphy_locked(hw, I82579_LPI_CTRL,
+						 &lpi_ctrl);
+			if (!retval) {
+				if (adapter->eee_advert &
+				    hw->dev_spec.ich8lan.eee_lp_ability &
+				    I82579_EEE_100_SUPPORTED)
+					lpi_ctrl |= I82579_LPI_CTRL_100_ENABLE;
+				if (adapter->eee_advert &
+				    hw->dev_spec.ich8lan.eee_lp_ability &
+				    I82579_EEE_1000_SUPPORTED)
+					lpi_ctrl |= I82579_LPI_CTRL_1000_ENABLE;
+
+				retval = e1e_wphy_locked(hw, I82579_LPI_CTRL,
+							 lpi_ctrl);
+			}
+		}
+		hw->phy.ops.release(hw);
+	}
 
 	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
 	 * would have already happened in close and is redundant.
-- 
2.4.3
