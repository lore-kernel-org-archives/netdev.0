From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/12] e1000e: Add support for EEE in Sx states
Date: Fri, 25 Jul 2014 21:45:20 -0700
Message-ID: <1406349922-9883-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <david.m.ertman@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28061 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751073AbaGZEpc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jul 2014 00:45:32 -0400
In-Reply-To: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <david.m.ertman@intel.com>

On I217 and newer hardware, EEE is enabled in the PHY by the software
when link is up and disabled by the hardware when link is lost.

To enable EEE in Sx (When both ends of the link support, and are enabled
for, EEE and 100Mbps), we need to disable LPLU and configure the PHY to
automatically enable EEE when link is up, since there will be no software
to complete the task.

To configure this in the PHY, the Auto Enable LPI bit in the Low Power
Idle GPIO Control register must be set.  For normal operation in S0, this
bit must be cleared.

Signed-off-by: Dave Ertman <david.m.ertman@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 18 ++++++++++++++++--
 drivers/net/ethernet/intel/e1000e/ich8lan.h |  4 ++++
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 8dbcdc8..48b74a5 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -4605,14 +4605,23 @@ void e1000_suspend_workarounds_ich8lan(struct e1000_hw *hw)
 
 			/* Disable LPLU if both link partners support 100BaseT
 			 * EEE and 100Full is advertised on both ends of the
-			 * link.
+			 * link, and enable Auto Enable LPI since there will
+			 * be no driver to enable LPI while in Sx.
 			 */
 			if ((eee_advert & I82579_EEE_100_SUPPORTED) &&
 			    (dev_spec->eee_lp_ability &
 			     I82579_EEE_100_SUPPORTED) &&
-			    (hw->phy.autoneg_advertised & ADVERTISE_100_FULL))
+			    (hw->phy.autoneg_advertised & ADVERTISE_100_FULL)) {
 				phy_ctrl &= ~(E1000_PHY_CTRL_D0A_LPLU |
 					      E1000_PHY_CTRL_NOND0A_LPLU);
+
+				/* Set Auto Enable LPI after link up */
+				e1e_rphy_locked(hw,
+						I217_LPI_GPIO_CTRL, &phy_reg);
+				phy_reg |= I217_LPI_GPIO_CTRL_AUTO_EN_LPI;
+				e1e_wphy_locked(hw,
+						I217_LPI_GPIO_CTRL, phy_reg);
+			}
 		}
 
 		/* For i217 Intel Rapid Start Technology support,
@@ -4709,6 +4718,11 @@ void e1000_resume_workarounds_pchlan(struct e1000_hw *hw)
 			return;
 		}
 
+		/* Clear Auto Enable LPI after link up */
+		e1e_rphy_locked(hw, I217_LPI_GPIO_CTRL, &phy_reg);
+		phy_reg &= ~I217_LPI_GPIO_CTRL_AUTO_EN_LPI;
+		e1e_wphy_locked(hw, I217_LPI_GPIO_CTRL, phy_reg);
+
 		if (!(er32(FWSM) & E1000_ICH_FWSM_FW_VALID)) {
 			/* Restore clear on SMB if no manageability engine
 			 * is present
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.h b/drivers/net/ethernet/intel/e1000e/ich8lan.h
index 5515126..8066a49 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.h
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.h
@@ -217,6 +217,10 @@
 #define I217_INBAND_CTRL_LINK_STAT_TX_TIMEOUT_MASK	0x3F00
 #define I217_INBAND_CTRL_LINK_STAT_TX_TIMEOUT_SHIFT	8
 
+/* Low Power Idle GPIO Control */
+#define I217_LPI_GPIO_CTRL			PHY_REG(772, 18)
+#define I217_LPI_GPIO_CTRL_AUTO_EN_LPI		0x0800
+
 /* PHY Low Power Idle Control */
 #define I82579_LPI_CTRL				PHY_REG(772, 20)
 #define I82579_LPI_CTRL_100_ENABLE		0x2000
-- 
1.9.3
