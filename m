From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] i40e: check for Tx timestamp timeouts during watchdog
Date: Wed, 31 May 2017 03:48:55 -0700
Message-ID: <20170531104856.47929-9-jeffrey.t.kirsher@intel.com>
References: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:24804 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751145AbdEaKtD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 06:49:03 -0400
In-Reply-To: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The i40e driver has logic to handle only one Tx timestamp at a time,
using a state bit lock to avoid multiple requests at once.

It may be possible, if incredibly unlikely, that a Tx timestamp event is
requested but never completes. Since we use an interrupt scheme to
determine when the Tx timestamp occurred we would never clear the state
bit in this case.

Add an i40e_ptp_tx_hang() function similar to the already existing
i40e_ptp_rx_hang() function. This function runs in the watchdog routine
and makes sure we eventually recover from this case instead of
permanently disabling Tx timestamps.

Note: there is no currently known way to cause this without hacking the
driver code to force it.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_main.c |  1 +
 drivers/net/ethernet/intel/i40e/i40e_ptp.c  | 30 +++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c |  1 +
 4 files changed, 34 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index f4465afe1fe1..25bf336c5f38 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -502,6 +502,7 @@ struct i40e_pf {
 	struct ptp_clock *ptp_clock;
 	struct ptp_clock_info ptp_caps;
 	struct sk_buff *ptp_tx_skb;
+	unsigned long ptp_tx_start;
 	struct hwtstamp_config tstamp_config;
 	struct mutex tmreg_lock; /* Used to protect the SYSTIME registers. */
 	u64 ptp_base_adj;
@@ -957,6 +958,7 @@ bool i40e_dcb_need_reconfig(struct i40e_pf *pf,
 			    struct i40e_dcbx_config *new_cfg);
 #endif /* CONFIG_I40E_DCB */
 void i40e_ptp_rx_hang(struct i40e_pf *pf);
+void i40e_ptp_tx_hang(struct i40e_pf *pf);
 void i40e_ptp_tx_hwtstamp(struct i40e_pf *pf);
 void i40e_ptp_rx_hwtstamp(struct i40e_pf *pf, struct sk_buff *skb, u8 index);
 void i40e_ptp_set_increment(struct i40e_pf *pf);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c019dec988e3..e4eb97832413 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6373,6 +6373,7 @@ static void i40e_watchdog_subtask(struct i40e_pf *pf)
 	}
 
 	i40e_ptp_rx_hang(pf);
+	i40e_ptp_tx_hang(pf);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index cb81e16d0874..1a0be835fa06 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -328,6 +328,36 @@ void i40e_ptp_rx_hang(struct i40e_pf *pf)
 }
 
 /**
+ * i40e_ptp_tx_hang - Detect error case when Tx timestamp register is hung
+ * @pf: The PF private data structure
+ *
+ * This watchdog task is run periodically to make sure that we clear the Tx
+ * timestamp logic if we don't obtain a timestamp in a reasonable amount of
+ * time. It is unexpected in the normal case but if it occurs it results in
+ * permanently prevent timestamps of future packets
+ **/
+void i40e_ptp_tx_hang(struct i40e_pf *pf)
+{
+	if (!(pf->flags & I40E_FLAG_PTP) || !pf->ptp_tx)
+		return;
+
+	/* Nothing to do if we're not already waiting for a timestamp */
+	if (!test_bit(__I40E_PTP_TX_IN_PROGRESS, pf->state))
+		return;
+
+	/* We already have a handler routine which is run when we are notified
+	 * of a Tx timestamp in the hardware. If we don't get an interrupt
+	 * within a second it is reasonable to assume that we never will.
+	 */
+	if (time_is_before_jiffies(pf->ptp_tx_start + HZ)) {
+		dev_kfree_skb_any(pf->ptp_tx_skb);
+		pf->ptp_tx_skb = NULL;
+		clear_bit_unlock(__I40E_PTP_TX_IN_PROGRESS, pf->state);
+		pf->tx_hwtstamp_timeouts++;
+	}
+}
+
+/**
  * i40e_ptp_tx_hwtstamp - Utility function which returns the Tx timestamp
  * @pf: Board private structure
  *
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index c69ee4b0cfe2..c2e9013d05eb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2628,6 +2628,7 @@ static int i40e_tsyn(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	if (pf->ptp_tx &&
 	    !test_and_set_bit_lock(__I40E_PTP_TX_IN_PROGRESS, pf->state)) {
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+		pf->ptp_tx_start = jiffies;
 		pf->ptp_tx_skb = skb_get(skb);
 	} else {
 		pf->tx_hwtstamp_skipped++;
-- 
2.12.2
