From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] ixgbe: check for Tx timestamp timeouts during watchdog
Date: Tue, 13 Jun 2017 17:38:05 -0700
Message-ID: <20170614003810.33189-5-jeffrey.t.kirsher@intel.com>
References: <20170614003810.33189-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:22692 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753863AbdFNAiW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 20:38:22 -0400
In-Reply-To: <20170614003810.33189-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The ixgbe driver has logic to handle only one Tx timestamp at a time,
using a state bit lock to avoid multiple requests at once.

It may be possible, if incredibly unlikely, that a Tx timestamp event is
requested but never completes. Since we use an interrupt scheme to
determine when the Tx timestamp occurred we would never clear the state
bit in this case.

Add an ixgbe_ptp_tx_hang() function similar to the already existing
ixgbe_ptp_rx_hang() function. This function runs in the watchdog routine
and makes sure we eventually recover from this case instead of
permanently disabling Tx timestamps.

Note: there is no currently known way to cause this without hacking the
driver code to force it.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c  | 27 +++++++++++++++++++++++++++
 3 files changed, 29 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index eb36106218ad..dd5578756ae0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -961,6 +961,7 @@ void ixgbe_ptp_suspend(struct ixgbe_adapter *adapter);
 void ixgbe_ptp_stop(struct ixgbe_adapter *adapter);
 void ixgbe_ptp_overflow_check(struct ixgbe_adapter *adapter);
 void ixgbe_ptp_rx_hang(struct ixgbe_adapter *adapter);
+void ixgbe_ptp_tx_hang(struct ixgbe_adapter *adapter);
 void ixgbe_ptp_rx_pktstamp(struct ixgbe_q_vector *, struct sk_buff *);
 void ixgbe_ptp_rx_rgtstamp(struct ixgbe_q_vector *, struct sk_buff *skb);
 static inline void ixgbe_ptp_rx_hwtstamp(struct ixgbe_ring *rx_ring,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4ea1137ea23f..3ed212f5a43e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7635,6 +7635,7 @@ static void ixgbe_service_task(struct work_struct *work)
 	if (test_bit(__IXGBE_PTP_RUNNING, &adapter->state)) {
 		ixgbe_ptp_overflow_check(adapter);
 		ixgbe_ptp_rx_hang(adapter);
+		ixgbe_ptp_tx_hang(adapter);
 	}
 
 	ixgbe_service_event_complete(adapter);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 4a2000bfd4ae..86d6924a2b71 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -663,6 +663,33 @@ static void ixgbe_ptp_clear_tx_timestamp(struct ixgbe_adapter *adapter)
 }
 
 /**
+ * ixgbe_ptp_tx_hang - detect error case where Tx timestamp never finishes
+ * @adapter: private network adapter structure
+ */
+void ixgbe_ptp_tx_hang(struct ixgbe_adapter *adapter)
+{
+	bool timeout = time_is_before_jiffies(adapter->ptp_tx_start +
+					      IXGBE_PTP_TX_TIMEOUT);
+
+	if (!adapter->ptp_tx_skb)
+		return;
+
+	if (!test_bit(__IXGBE_PTP_TX_IN_PROGRESS, &adapter->state))
+		return;
+
+	/* If we haven't received a timestamp within the timeout, it is
+	 * reasonable to assume that it will never occur, so we can unlock the
+	 * timestamp bit when this occurs.
+	 */
+	if (timeout) {
+		cancel_work_sync(&adapter->ptp_tx_work);
+		ixgbe_ptp_clear_tx_timestamp(adapter);
+		adapter->tx_hwtstamp_timeouts++;
+		e_warn(drv, "clearing Tx timestamp hang\n");
+	}
+}
+
+/**
  * ixgbe_ptp_tx_hwtstamp - utility function which checks for TX time stamp
  * @adapter: the private adapter struct
  *
-- 
2.12.2
