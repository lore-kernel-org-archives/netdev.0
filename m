From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] i40e: fix race condition with PTP_TX_IN_PROGRESS bits
Date: Wed, 31 May 2017 03:48:51 -0700
Message-ID: <20170531104856.47929-5-jeffrey.t.kirsher@intel.com>
References: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:24804 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751120AbdEaKtC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 06:49:02 -0400
In-Reply-To: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Hardware related to the i40e driver has a limitation on Tx PTP packets.
This requires us to limit the driver to timestamping a single packet at
once. This is done using a state bitlock which enforces that only one
timestamp request is honored at a time.

Unfortunately this suffers from a race condition. The bit lock is not
cleared until after skb_tstamp_tx() is called notifying applications of
a new Tx timestamp. Even a well behaved application sending only one
packet at a time and waiting for a response can wake up and send a new
timestamped packet request before the bit lock is cleared. This results
in needlessly dropping some Tx timestamp requests.

We can fix this by unlocking the state bit as soon as we read the
Timestamp register, as this is the first point at which it is safe to
timestamp another packet.

To avoid issues with the skb pointer, we'll use a copy of the pointer
and set the global variable in the driver structure to NULL first. This
ensures that the next timestamp request does not modify our local copy
of the skb pointer.

Now, a well behaved application which has at most one outstanding
timestamp request will not accidentally race with the driver unlock bit.
Obviously an application attempting to timestamp faster than one request
at a time will have some timestamp requests skipped. Unfortunately there
is nothing we can do about that.

Reported-by: David Mirabito <davidm@metamako.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ptp.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index 0efff18ee336..aead71a92a60 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -338,6 +338,7 @@ void i40e_ptp_rx_hang(struct i40e_vsi *vsi)
 void i40e_ptp_tx_hwtstamp(struct i40e_pf *pf)
 {
 	struct skb_shared_hwtstamps shhwtstamps;
+	struct sk_buff *skb = pf->ptp_tx_skb;
 	struct i40e_hw *hw = &pf->hw;
 	u32 hi, lo;
 	u64 ns;
@@ -353,12 +354,19 @@ void i40e_ptp_tx_hwtstamp(struct i40e_pf *pf)
 	hi = rd32(hw, I40E_PRTTSYN_TXTIME_H);
 
 	ns = (((u64)hi) << 32) | lo;
-
 	i40e_ptp_convert_to_hwtstamp(&shhwtstamps, ns);
-	skb_tstamp_tx(pf->ptp_tx_skb, &shhwtstamps);
-	dev_kfree_skb_any(pf->ptp_tx_skb);
+
+	/* Clear the bit lock as soon as possible after reading the register,
+	 * and prior to notifying the stack via skb_tstamp_tx(). Otherwise
+	 * applications might wake up and attempt to request another transmit
+	 * timestamp prior to the bit lock being cleared.
+	 */
 	pf->ptp_tx_skb = NULL;
 	clear_bit_unlock(__I40E_PTP_TX_IN_PROGRESS, pf->state);
+
+	/* Notify the stack and free the skb after we've unlocked */
+	skb_tstamp_tx(skb, &shhwtstamps);
+	dev_kfree_skb_any(skb);
 }
 
 /**
-- 
2.12.2
