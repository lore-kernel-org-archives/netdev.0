From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/6] igb: Remove workaround for EEE configuration on i210/I211
Date: Thu,  1 Nov 2012 03:44:24 -0700
Message-ID: <1351766667-28489-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1351766667-28489-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:1625 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757293Ab2KAKoc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 06:44:32 -0400
In-Reply-To: <1351766667-28489-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch removes a workaround that was needed on pre-release hardware.
Released hardware should not have this setting, but any devices that do
will get a warning message instead.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index ca4641e..4313bcc 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -2233,19 +2233,16 @@ s32 igb_set_eee_i350(struct e1000_hw *hw)
 
 	/* enable or disable per user setting */
 	if (!(hw->dev_spec._82575.eee_disable)) {
-		ipcnfg |= (E1000_IPCNFG_EEE_1G_AN |
-			E1000_IPCNFG_EEE_100M_AN);
-		eeer |= (E1000_EEER_TX_LPI_EN |
-			E1000_EEER_RX_LPI_EN |
+		u32 eee_su = rd32(E1000_EEE_SU);
+
+		ipcnfg |= (E1000_IPCNFG_EEE_1G_AN | E1000_IPCNFG_EEE_100M_AN);
+		eeer |= (E1000_EEER_TX_LPI_EN | E1000_EEER_RX_LPI_EN |
 			E1000_EEER_LPI_FC);
 
-		/* keep the LPI clock running before EEE is enabled */
-		if (hw->mac.type == e1000_i210 || hw->mac.type == e1000_i211) {
-			u32 eee_su;
-			eee_su = rd32(E1000_EEE_SU);
-			eee_su &= ~E1000_EEE_SU_LPI_CLK_STP;
-			wr32(E1000_EEE_SU, eee_su);
-		}
+		/* This bit should not be set in normal operation. */
+		if (eee_su & E1000_EEE_SU_LPI_CLK_STP)
+			hw_dbg("LPI Clock Stop Bit should not be set!\n");
+
 
 	} else {
 		ipcnfg &= ~(E1000_IPCNFG_EEE_1G_AN |
-- 
1.7.11.7
