From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/12] e1000e: Add code to check return values on NVM accesses
Date: Fri, 25 Jul 2014 21:45:19 -0700
Message-ID: <1406349922-9883-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <david.m.ertman@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:13529 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751066AbaGZEpc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jul 2014 00:45:32 -0400
In-Reply-To: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <david.m.ertman@intel.com>

Adding code to check and respond to previously ignored return values
from NVM access functions.

Issue discovered through static analysis.

Signed-off-by: Dave Ertman <david.m.ertman@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/manage.c |  5 ++++-
 drivers/net/ethernet/intel/e1000e/netdev.c | 22 ++++++++++++++++------
 drivers/net/ethernet/intel/e1000e/nvm.c    |  4 +++-
 3 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/manage.c b/drivers/net/ethernet/intel/e1000e/manage.c
index cb37ff1..5885603 100644
--- a/drivers/net/ethernet/intel/e1000e/manage.c
+++ b/drivers/net/ethernet/intel/e1000e/manage.c
@@ -327,9 +327,12 @@ bool e1000e_enable_mng_pass_thru(struct e1000_hw *hw)
 	} else if ((hw->mac.type == e1000_82574) ||
 		   (hw->mac.type == e1000_82583)) {
 		u16 data;
+		s32 ret_val;
 
 		factps = er32(FACTPS);
-		e1000_read_nvm(hw, NVM_INIT_CONTROL2_REG, 1, &data);
+		ret_val = e1000_read_nvm(hw, NVM_INIT_CONTROL2_REG, 1, &data);
+		if (ret_val)
+			return false;
 
 		if (!(factps & E1000_FACTPS_MNGCG) &&
 		    ((data & E1000_NVM_INIT_CTRL2_MNGM) ==
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 201cc93..fe3e42a 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6708,6 +6708,7 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	int bars, i, err, pci_using_dac;
 	u16 eeprom_data = 0;
 	u16 eeprom_apme_mask = E1000_EEPROM_APME;
+	s32 rval = 0;
 
 	if (ei->flags2 & FLAG2_DISABLE_ASPM_L0S)
 		aspm_disable_flag = PCIE_LINK_STATE_L0S;
@@ -6940,15 +6941,19 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	} else if (adapter->flags & FLAG_APME_IN_CTRL3) {
 		if (adapter->flags & FLAG_APME_CHECK_PORT_B &&
 		    (adapter->hw.bus.func == 1))
-			e1000_read_nvm(&adapter->hw, NVM_INIT_CONTROL3_PORT_B,
-				       1, &eeprom_data);
+			rval = e1000_read_nvm(&adapter->hw,
+					      NVM_INIT_CONTROL3_PORT_B,
+					      1, &eeprom_data);
 		else
-			e1000_read_nvm(&adapter->hw, NVM_INIT_CONTROL3_PORT_A,
-				       1, &eeprom_data);
+			rval = e1000_read_nvm(&adapter->hw,
+					      NVM_INIT_CONTROL3_PORT_A,
+					      1, &eeprom_data);
 	}
 
 	/* fetch WoL from EEPROM */
-	if (eeprom_data & eeprom_apme_mask)
+	if (rval)
+		e_dbg("NVM read error getting WoL initial values: %d\n", rval);
+	else if (eeprom_data & eeprom_apme_mask)
 		adapter->eeprom_wol |= E1000_WUFC_MAG;
 
 	/* now that we have the eeprom settings, apply the special cases
@@ -6967,7 +6972,12 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		device_wakeup_enable(&pdev->dev);
 
 	/* save off EEPROM version number */
-	e1000_read_nvm(&adapter->hw, 5, 1, &adapter->eeprom_vers);
+	rval = e1000_read_nvm(&adapter->hw, 5, 1, &adapter->eeprom_vers);
+
+	if (rval) {
+		e_dbg("NVM read error getting EEPROM version: %d\n", rval);
+		adapter->eeprom_vers = 0;
+	}
 
 	/* reset the hardware with the new settings */
 	e1000e_reset(adapter);
diff --git a/drivers/net/ethernet/intel/e1000e/nvm.c b/drivers/net/ethernet/intel/e1000e/nvm.c
index b1f212b..fa6b103 100644
--- a/drivers/net/ethernet/intel/e1000e/nvm.c
+++ b/drivers/net/ethernet/intel/e1000e/nvm.c
@@ -327,8 +327,10 @@ s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 
 		ew32(EERD, eerd);
 		ret_val = e1000e_poll_eerd_eewr_done(hw, E1000_NVM_POLL_READ);
-		if (ret_val)
+		if (ret_val) {
+			e_dbg("NVM read error: %d\n", ret_val);
 			break;
+		}
 
 		data[i] = (er32(EERD) >> E1000_NVM_RW_REG_DATA);
 	}
-- 
1.9.3
