From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] ixgbe: ptp code cleanup
Date: Sat,  9 Jun 2012 01:21:01 -0700
Message-ID: <1339230063-12545-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1339230063-12545-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40735 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752833Ab2FIIVP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2012 04:21:15 -0400
In-Reply-To: <1339230063-12545-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch fixes two minor nits from Richard Cochran. The first is a case of
ambitious line wrapping that wasn't necessary. The second is to re-order the
flag checks for PPS support. Previously, the hardware test was done first, and
the interrupt flag test was done second. Now, test the interrupt flag and use
the unlikely macro.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    8 +++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c  |   13 +++++++------
 2 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 17ad6a3..1675b66 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -790,12 +790,10 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		total_packets += tx_buffer->gso_segs;
 
 #ifdef CONFIG_IXGBE_PTP
-		if (unlikely(tx_buffer->tx_flags &
-			     IXGBE_TX_FLAGS_TSTAMP))
-			ixgbe_ptp_tx_hwtstamp(q_vector,
-					      tx_buffer->skb);
-
+		if (unlikely(tx_buffer->tx_flags & IXGBE_TX_FLAGS_TSTAMP))
+			ixgbe_ptp_tx_hwtstamp(q_vector, tx_buffer->skb);
 #endif
+
 		/* free the skb */
 		dev_kfree_skb_any(tx_buffer->skb);
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index ddc6a4d..174f41f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -307,13 +307,14 @@ void ixgbe_ptp_check_pps_event(struct ixgbe_adapter *adapter, u32 eicr)
 	    !(adapter->flags2 & IXGBE_FLAG2_PTP_PPS_ENABLED))
 		return;
 
-	switch (hw->mac.type) {
-	case ixgbe_mac_X540:
-		if (eicr & IXGBE_EICR_TIMESYNC)
+	if (unlikely(eicr & IXGBE_EICR_TIMESYNC)) {
+		switch (hw->mac.type) {
+		case ixgbe_mac_X540:
 			ptp_clock_event(adapter->ptp_clock, &event);
-		break;
-	default:
-		break;
+			break;
+		default:
+			break;
+		}
 	}
 }
 
-- 
1.7.10.2
