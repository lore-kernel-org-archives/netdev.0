From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/16] i40e: Workaround fix for mss < 256 issue
Date: Tue, 24 Nov 2015 16:04:37 -0800
Message-ID: <1448409886-90686-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:62192 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754599AbbKYAEw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 19:04:52 -0500
In-Reply-To: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

HW/NVM sets a limit of no less than 256 bytes for MSS. Stack can send as
low as 76 bytes MSS. This patch lowers the HW limit to 64 bytes to avoid
MDDs from firing and causing a reset when the MSS is lower than 256.

Change-ID: I36b500a6bb227d283c3e321a7718e0672b11fab0
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7a4595a..781a6f4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6685,6 +6685,7 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	struct i40e_hw *hw = &pf->hw;
 	u8 set_fc_aq_fail = 0;
 	i40e_status ret;
+	u32 val;
 	u32 v;
 
 	/* Now we wait for GRST to settle out.
@@ -6823,6 +6824,20 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 		}
 	}
 
+	/* Reconfigure hardware for allowing smaller MSS in the case
+	 * of TSO, so that we avoid the MDD being fired and causing
+	 * a reset in the case of small MSS+TSO.
+	 */
+#define I40E_REG_MSS          0x000E64DC
+#define I40E_REG_MSS_MIN_MASK 0x3FF0000
+#define I40E_64BYTE_MSS       0x400000
+	val = rd32(hw, I40E_REG_MSS);
+	if ((val & I40E_REG_MSS_MIN_MASK) > I40E_64BYTE_MSS) {
+		val &= ~I40E_REG_MSS_MIN_MASK;
+		val |= I40E_64BYTE_MSS;
+		wr32(hw, I40E_REG_MSS, val);
+	}
+
 	if (((pf->hw.aq.fw_maj_ver == 4) && (pf->hw.aq.fw_min_ver < 33)) ||
 	    (pf->hw.aq.fw_maj_ver < 4)) {
 		msleep(75);
@@ -10185,6 +10200,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	u16 link_status;
 	int err;
 	u32 len;
+	u32 val;
 	u32 i;
 	u8 set_fc_aq_fail;
 
@@ -10489,6 +10505,17 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			 i40e_stat_str(&pf->hw, err),
 			 i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
 
+	/* Reconfigure hardware for allowing smaller MSS in the case
+	 * of TSO, so that we avoid the MDD being fired and causing
+	 * a reset in the case of small MSS+TSO.
+	 */
+	val = rd32(hw, I40E_REG_MSS);
+	if ((val & I40E_REG_MSS_MIN_MASK) > I40E_64BYTE_MSS) {
+		val &= ~I40E_REG_MSS_MIN_MASK;
+		val |= I40E_64BYTE_MSS;
+		wr32(hw, I40E_REG_MSS, val);
+	}
+
 	if (((pf->hw.aq.fw_maj_ver == 4) && (pf->hw.aq.fw_min_ver < 33)) ||
 	    (pf->hw.aq.fw_maj_ver < 4)) {
 		msleep(75);
-- 
2.5.0
