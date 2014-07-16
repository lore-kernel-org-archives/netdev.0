From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/5] i40e: (ptp) warn when PF_ID does not match in PRTTSYN_CTL0
Date: Wed, 16 Jul 2014 14:35:34 -0700
Message-ID: <1405546534-21025-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1405546534-21025-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28354 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753005AbaGPVgN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2014 17:36:13 -0400
In-Reply-To: <1405546534-21025-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Display a verbose warning message when the incorrect PF attempts to
control timestamping for a port to which it was not assigned. This
shouldn't display except in the case of multiple PFs per port. The
primary intent of this message is to help debugging the reason why the
SIOCSHWTSTAMP ioctl has failed, and to help narrow the cause of the
issue.

Change-ID: Ic98798e0c844d98389d4c20e7160ba256f2bc7e8
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ptp.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index 582704a..bb7fe98b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -447,8 +447,12 @@ static int i40e_ptp_set_timestamp_mode(struct i40e_pf *pf,
 	/* Confirm that 1588 is supported on this PF. */
 	pf_id = (rd32(hw, I40E_PRTTSYN_CTL0) & I40E_PRTTSYN_CTL0_PF_ID_MASK) >>
 		I40E_PRTTSYN_CTL0_PF_ID_SHIFT;
-	if (hw->pf_id != pf_id)
-		return -EINVAL;
+	if (hw->pf_id != pf_id) {
+		dev_err(&pf->pdev->dev,
+			"PF %d attempted to control timestamp mode on port %d, which is owned by PF %d\n",
+			hw->pf_id, hw->port, pf_id);
+		return -EPERM;
+	}
 
 	switch (config->tx_type) {
 	case HWTSTAMP_TX_OFF:
-- 
1.9.3
