From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/17] i40e: check I40E_FLAG_PTP before handling Tx or Rx timestamps
Date: Thu, 15 Jan 2015 04:19:20 -0800
Message-ID: <1421324368-6860-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:64854 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753710AbbAOMTf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 07:19:35 -0500
In-Reply-To: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

We should not be doing Tx or Rx timestamps if we do not have PTP
enabled. Add checks to ensure that we don't attempt to handle any PTP
related timestamping code if we have not enabled PTP on that PF.

Change-ID: I4335942ae2d5c5f91abfdbeeea02bcace49e7677
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ptp.c  | 9 ++++++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 3 +++
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index 6d1ec92..a152878 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -305,6 +305,13 @@ void i40e_ptp_tx_hwtstamp(struct i40e_pf *pf)
 	u32 hi, lo;
 	u64 ns;
 
+	if (!(pf->flags & I40E_FLAG_PTP) || !pf->ptp_tx)
+		return;
+
+	/* don't attempt to timestamp if we don't have an skb */
+	if (!pf->ptp_tx_skb)
+		return;
+
 	lo = rd32(hw, I40E_PRTTSYN_TXTIME_L);
 	hi = rd32(hw, I40E_PRTTSYN_TXTIME_H);
 
@@ -338,7 +345,7 @@ void i40e_ptp_rx_hwtstamp(struct i40e_pf *pf, struct sk_buff *skb, u8 index)
 	/* Since we cannot turn off the Rx timestamp logic if the device is
 	 * doing Tx timestamping, check if Rx timestamping is configured.
 	 */
-	if (!pf->ptp_rx)
+	if (!(pf->flags & I40E_FLAG_PTP) || !pf->ptp_rx)
 		return;
 
 	hw = &pf->hw;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index bb86390..420d662 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1939,6 +1939,9 @@ static int i40e_tsyn(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	 * we are not already transmitting a packet to be timestamped
 	 */
 	pf = i40e_netdev_to_pf(tx_ring->netdev);
+	if (!(pf->flags & I40E_FLAG_PTP))
+		return 0;
+
 	if (pf->ptp_tx &&
 	    !test_and_set_bit_lock(__I40E_PTP_TX_IN_PROGRESS, &pf->state)) {
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
-- 
1.9.3
