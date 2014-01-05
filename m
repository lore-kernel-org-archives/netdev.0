From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e: Change the ethtool NVM read method to use AQ
Date: Sun,  5 Jan 2014 02:46:55 -0800
Message-ID: <1388918827-13430-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21383 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751126AbaAEKrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 05:47:11 -0500
In-Reply-To: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Earlier we were reading Shadow RAM (copy of the NVM) which can differ
from the actual NVM. Use AQ instead to read the actual NVM.

Change-Id: Ia0f2773b722db77d093f738c068af872be69bbd4
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 68 +++++++++++++++++---------
 1 file changed, 46 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 0359c36..42c36d1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -351,38 +351,56 @@ static int i40e_get_eeprom(struct net_device *netdev,
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_hw *hw = &np->vsi->back->hw;
-	int first_word, last_word;
-	u16 i, eeprom_len;
-	u16 *eeprom_buff;
-	int ret_val = 0;
-
+	struct i40e_pf *pf = np->vsi->back;
+	int ret_val = 0, len;
+	u8 *eeprom_buff;
+	u16 i, sectors;
+	bool last;
+#define I40E_NVM_SECTOR_SIZE  4096
 	if (eeprom->len == 0)
 		return -EINVAL;
 
 	eeprom->magic = hw->vendor_id | (hw->device_id << 16);
 
-	first_word = eeprom->offset >> 1;
-	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
-	eeprom_len = last_word - first_word + 1;
-
-	eeprom_buff = kmalloc(sizeof(u16) * eeprom_len, GFP_KERNEL);
+	eeprom_buff = kzalloc(eeprom->len, GFP_KERNEL);
 	if (!eeprom_buff)
 		return -ENOMEM;
 
-	ret_val = i40e_read_nvm_buffer(hw, first_word, &eeprom_len,
-					   eeprom_buff);
-	if (eeprom_len == 0) {
-		kfree(eeprom_buff);
-		return -EACCES;
+	ret_val = i40e_acquire_nvm(hw, I40E_RESOURCE_READ);
+	if (ret_val) {
+		dev_info(&pf->pdev->dev,
+			 "Failed Acquiring NVM resource for read err=%d status=0x%x\n",
+			 ret_val, hw->aq.asq_last_status);
+		goto free_buff;
 	}
 
-	/* Device's eeprom is always little-endian, word addressable */
-	for (i = 0; i < eeprom_len; i++)
-		le16_to_cpus(&eeprom_buff[i]);
+	sectors = eeprom->len / I40E_NVM_SECTOR_SIZE;
+	sectors += (eeprom->len % I40E_NVM_SECTOR_SIZE) ? 1 : 0;
+	len = I40E_NVM_SECTOR_SIZE;
+	last = false;
+	for (i = 0; i < sectors; i++) {
+		if (i == (sectors - 1)) {
+			len = eeprom->len - (I40E_NVM_SECTOR_SIZE * i);
+			last = true;
+		}
+		ret_val = i40e_aq_read_nvm(hw, 0x0,
+				eeprom->offset + (I40E_NVM_SECTOR_SIZE * i),
+				len,
+				(u8 *)eeprom_buff + (I40E_NVM_SECTOR_SIZE * i),
+				last, NULL);
+		if (ret_val) {
+			dev_info(&pf->pdev->dev,
+				 "read NVM failed err=%d status=0x%x\n",
+				 ret_val, hw->aq.asq_last_status);
+			goto release_nvm;
+		}
+	}
 
-	memcpy(bytes, (u8 *)eeprom_buff + (eeprom->offset & 1), eeprom->len);
+release_nvm:
+	i40e_release_nvm(hw);
+	memcpy(bytes, (u8 *)eeprom_buff, eeprom->len);
+free_buff:
 	kfree(eeprom_buff);
-
 	return ret_val;
 }
 
@@ -390,8 +408,14 @@ static int i40e_get_eeprom_len(struct net_device *netdev)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_hw *hw = &np->vsi->back->hw;
-
-	return hw->nvm.sr_size * 2;
+	u32 val;
+
+	val = (rd32(hw, I40E_GLPCI_LBARCTRL)
+		& I40E_GLPCI_LBARCTRL_FL_SIZE_MASK)
+		>> I40E_GLPCI_LBARCTRL_FL_SIZE_SHIFT;
+	/* register returns value in power of 2, 64Kbyte chunks. */
+	val = (64 * 1024) * (1 << val);
+	return val;
 }
 
 static void i40e_get_drvinfo(struct net_device *netdev,
-- 
1.8.3.1
