From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 15/17] i40e: when Rx timestamps disabled set specific mode
Date: Fri, 16 Jan 2015 05:29:04 -0800
Message-ID: <1421414946-22179-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421414946-22179-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:63724 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755574AbbAPN3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2015 08:29:18 -0500
In-Reply-To: <1421414946-22179-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Instead of leaving the Rx timestamps in the same mode as before if we
disable the Rx logic, we can set it into a mode that has the fewest
possible timestamps generated. To do this, select only V1 mode, but do
not enable UDP packet recognition. This should eliminate all (or at
least almost all) Rx timestamps, since V1 packets are always over UDP.

Change-ID: If847288e0030a716e059c4c33ab114f2cf038f05
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ptp.c | 28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index 9f756b4..fabcfa1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -479,7 +479,12 @@ static int i40e_ptp_set_timestamp_mode(struct i40e_pf *pf,
 	switch (config->rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
 		pf->ptp_rx = false;
-		tsyntype = 0;
+		/* We set the type to V1, but do not enable UDP packet
+		 * recognition. In this way, we should be as close to
+		 * disabling PTP Rx timestamps as possible since V1 packets
+		 * are always UDP, since L2 packets are a V2 feature.
+		 */
+		tsyntype = I40E_PRTTSYN_CTL1_TSYNTYPE_V1;
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
 	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
@@ -533,17 +538,18 @@ static int i40e_ptp_set_timestamp_mode(struct i40e_pf *pf,
 		regval &= ~I40E_PFINT_ICR0_ENA_TIMESYNC_MASK;
 	wr32(hw, I40E_PFINT_ICR0_ENA, regval);
 
-	/* There is no simple on/off switch for Rx. To "disable" Rx support,
-	 * ignore any received timestamps, rather than turn off the clock.
+	/* Although there is no simple on/off switch for Rx, we "disable" Rx
+	 * timestamps by setting to V1 only mode and clear the UDP
+	 * recognition. This ought to disable all PTP Rx timestamps as V1
+	 * packets are always over UDP. Note that software is configured to
+	 * ignore Rx timestamps via the pf->ptp_rx flag.
 	 */
-	if (pf->ptp_rx) {
-		regval = rd32(hw, I40E_PRTTSYN_CTL1);
-		/* clear everything but the enable bit */
-		regval &= I40E_PRTTSYN_CTL1_TSYNENA_MASK;
-		/* now enable bits for desired Rx timestamps */
-		regval |= tsyntype;
-		wr32(hw, I40E_PRTTSYN_CTL1, regval);
-	}
+	regval = rd32(hw, I40E_PRTTSYN_CTL1);
+	/* clear everything but the enable bit */
+	regval &= I40E_PRTTSYN_CTL1_TSYNENA_MASK;
+	/* now enable bits for desired Rx timestamps */
+	regval |= tsyntype;
+	wr32(hw, I40E_PRTTSYN_CTL1, regval);
 
 	return 0;
 }
-- 
1.9.3
