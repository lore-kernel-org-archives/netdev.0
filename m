From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/11] e1000e: add statistic indicating number of skipped Tx timestamps
Date: Tue,  6 Jun 2017 01:58:04 -0700
Message-ID: <20170606085809.78571-7-jeffrey.t.kirsher@intel.com>
References: <20170606085809.78571-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:30962 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751424AbdFFI6Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 04:58:16 -0400
In-Reply-To: <20170606085809.78571-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The e1000e driver can only handle one Tx timestamp request at a time.
This means it is possible for an application timestamp request to be
ignored.

There is no easy way for an administrator to determine if this occurred.
Add a new statistic which tracks this, tx_hwtstamp_skipped.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h   |  1 +
 drivers/net/ethernet/intel/e1000e/ethtool.c |  1 +
 drivers/net/ethernet/intel/e1000e/netdev.c  | 17 ++++++++++-------
 3 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index c7c994eb410e..98e68888abb1 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -268,6 +268,7 @@ struct e1000_adapter {
 	u32 tx_fifo_size;
 	u32 tx_dma_failed;
 	u32 tx_hwtstamp_timeouts;
+	u32 tx_hwtstamp_skipped;
 
 	/* Rx */
 	bool (*clean_rx)(struct e1000_ring *ring, int *work_done,
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index e23dbd9190d6..c658f6ebf7cb 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -105,6 +105,7 @@ static const struct e1000_stats e1000_gstrings_stats[] = {
 	E1000_STAT("uncorr_ecc_errors", uncorr_errors),
 	E1000_STAT("corr_ecc_errors", corr_errors),
 	E1000_STAT("tx_hwtstamp_timeouts", tx_hwtstamp_timeouts),
+	E1000_STAT("tx_hwtstamp_skipped", tx_hwtstamp_skipped),
 };
 
 #define E1000_GLOBAL_STATS_LEN	ARRAY_SIZE(e1000_gstrings_stats)
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 96257349a1b8..fc1d92ca3ea2 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5867,13 +5867,16 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 			     nr_frags);
 	if (count) {
 		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
-		    (adapter->flags & FLAG_HAS_HW_TIMESTAMP) &&
-		    !adapter->tx_hwtstamp_skb) {
-			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
-			tx_flags |= E1000_TX_FLAGS_HWTSTAMP;
-			adapter->tx_hwtstamp_skb = skb_get(skb);
-			adapter->tx_hwtstamp_start = jiffies;
-			schedule_work(&adapter->tx_hwtstamp_work);
+		    (adapter->flags & FLAG_HAS_HW_TIMESTAMP)) {
+			if (!adapter->tx_hwtstamp_skb) {
+				skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+				tx_flags |= E1000_TX_FLAGS_HWTSTAMP;
+				adapter->tx_hwtstamp_skb = skb_get(skb);
+				adapter->tx_hwtstamp_start = jiffies;
+				schedule_work(&adapter->tx_hwtstamp_work);
+			} else {
+				adapter->tx_hwtstamp_skipped++;
+			}
 		}
 
 		skb_tx_timestamp(skb);
-- 
2.12.2
