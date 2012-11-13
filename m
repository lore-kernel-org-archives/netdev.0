From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/11] igb: Clear Go Link Disconnect for 82580 and later devices
Date: Tue, 13 Nov 2012 06:03:20 -0800
Message-ID: <1352815405-751-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35423 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754783Ab2KMODb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 09:03:31 -0500
In-Reply-To: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Customers are requesting that the hw prevents PHY from establishing link
until the driver loads.  This patch clears the Go Link Disconnect bit which
provides the requested behavior on parts 82580 and later.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 8 ++++++++
 drivers/net/ethernet/intel/igb/e1000_phy.h   | 1 +
 2 files changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index deb0597..8c12dbd 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -1278,12 +1278,20 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 {
 	u32 ctrl;
 	s32  ret_val;
+	u32 phpm_reg;
 
 	ctrl = rd32(E1000_CTRL);
 	ctrl |= E1000_CTRL_SLU;
 	ctrl &= ~(E1000_CTRL_FRCSPD | E1000_CTRL_FRCDPX);
 	wr32(E1000_CTRL, ctrl);
 
+	/* Clear Go Link Disconnect bit */
+	if (hw->mac.type >= e1000_82580) {
+		phpm_reg = rd32(E1000_82580_PHY_POWER_MGMT);
+		phpm_reg &= ~E1000_82580_PM_GO_LINKD;
+		wr32(E1000_82580_PHY_POWER_MGMT, phpm_reg);
+	}
+
 	ret_val = igb_setup_serdes_link_82575(hw);
 	if (ret_val)
 		goto out;
diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.h b/drivers/net/ethernet/intel/igb/e1000_phy.h
index 6ac3299..ed282f8 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.h
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.h
@@ -124,6 +124,7 @@ s32  igb_check_polarity_m88(struct e1000_hw *hw);
 #define E1000_82580_PM_SPD		0x0001 /* Smart Power Down */
 #define E1000_82580_PM_D0_LPLU		0x0002 /* For D0a states */
 #define E1000_82580_PM_D3_LPLU		0x0004 /* For all other states */
+#define E1000_82580_PM_GO_LINKD		0x0020 /* Go Link Disconnect */
 
 /* Enable flexible speed on link-up */
 #define IGP02E1000_PM_D0_LPLU             0x0002 /* For D0a states */
-- 
1.7.11.7
