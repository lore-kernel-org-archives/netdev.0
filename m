From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] ixgbe: add statistic indicating number of skipped Tx timestamps
Date: Tue, 13 Jun 2017 17:38:04 -0700
Message-ID: <20170614003810.33189-4-jeffrey.t.kirsher@intel.com>
References: <20170614003810.33189-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:19685 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752456AbdFNAiW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 20:38:22 -0400
In-Reply-To: <20170614003810.33189-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The ixgbe driver can only handle one Tx timestamp request at a time.
This means it is possible for an application timestamp request to be
ignored.

There is no easy way for an administrator to determine if this occurred.
Add a new statistic which tracks this, tx_hwtstamp_skipped.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  3 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 23 +++++++++++++----------
 3 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 76263762bea1..eb36106218ad 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -733,6 +733,7 @@ struct ixgbe_adapter {
 	struct timecounter hw_tc;
 	u32 base_incval;
 	u32 tx_hwtstamp_timeouts;
+	u32 tx_hwtstamp_skipped;
 	u32 rx_hwtstamp_cleared;
 	void (*ptp_setup_sdp)(struct ixgbe_adapter *);
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 9113e8099b03..2890e926b498 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -111,6 +111,9 @@ static const struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"os2bmc_tx_by_bmc", IXGBE_STAT(stats.b2ospc)},
 	{"os2bmc_tx_by_host", IXGBE_STAT(stats.o2bspc)},
 	{"os2bmc_rx_by_host", IXGBE_STAT(stats.b2ogprc)},
+	{"tx_hwtstamp_timeouts", IXGBE_STAT(tx_hwtstamp_timeouts)},
+	{"tx_hwtstamp_skipped", IXGBE_STAT(tx_hwtstamp_skipped)},
+	{"rx_hwtstamp_cleared", IXGBE_STAT(rx_hwtstamp_cleared)},
 #ifdef IXGBE_FCOE
 	{"fcoe_bad_fccrc", IXGBE_STAT(stats.fccrc)},
 	{"rx_fcoe_dropped", IXGBE_STAT(stats.fcoerpdc)},
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 5773df248360..4ea1137ea23f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8337,16 +8337,19 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 	protocol = vlan_get_protocol(skb);
 
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
-	    adapter->ptp_clock &&
-	    !test_and_set_bit_lock(__IXGBE_PTP_TX_IN_PROGRESS,
-				   &adapter->state)) {
-		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
-		tx_flags |= IXGBE_TX_FLAGS_TSTAMP;
-
-		/* schedule check for Tx timestamp */
-		adapter->ptp_tx_skb = skb_get(skb);
-		adapter->ptp_tx_start = jiffies;
-		schedule_work(&adapter->ptp_tx_work);
+	    adapter->ptp_clock) {
+		if (!test_and_set_bit_lock(__IXGBE_PTP_TX_IN_PROGRESS,
+					   &adapter->state)) {
+			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+			tx_flags |= IXGBE_TX_FLAGS_TSTAMP;
+
+			/* schedule check for Tx timestamp */
+			adapter->ptp_tx_skb = skb_get(skb);
+			adapter->ptp_tx_start = jiffies;
+			schedule_work(&adapter->ptp_tx_work);
+		} else {
+			adapter->tx_hwtstamp_skipped++;
+		}
 	}
 
 	skb_tx_timestamp(skb);
-- 
2.12.2
