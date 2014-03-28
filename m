From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 11/14] e1000e: add timeout for TX HW time stamping work
Date: Fri, 28 Mar 2014 07:08:12 -0700
Message-ID: <1396015695-25283-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1396015695-25283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17012 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752412AbaC1OJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2014 10:09:12 -0400
In-Reply-To: <1396015695-25283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <kubakici@wp.pl>

Hardware may fail to report time stamp e.g.:
 - when hardware time stamping is not enabled
 - when time stamp is requested shortly after ifup

Timeout time stamp reading work to prevent it from
scheduling itself indefinitely. Report timeout events
via system log and device stats.

Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h   | 2 ++
 drivers/net/ethernet/intel/e1000e/ethtool.c | 1 +
 drivers/net/ethernet/intel/e1000e/netdev.c  | 7 +++++++
 3 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 5325e3e..1471c54 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -262,6 +262,7 @@ struct e1000_adapter {
 	u32 tx_head_addr;
 	u32 tx_fifo_size;
 	u32 tx_dma_failed;
+	u32 tx_hwtstamp_timeouts;
 
 	/* Rx */
 	bool (*clean_rx) (struct e1000_ring *ring, int *work_done,
@@ -334,6 +335,7 @@ struct e1000_adapter {
 	struct hwtstamp_config hwtstamp_config;
 	struct delayed_work systim_overflow_work;
 	struct sk_buff *tx_hwtstamp_skb;
+	unsigned long tx_hwtstamp_start;
 	struct work_struct tx_hwtstamp_work;
 	spinlock_t systim_lock;	/* protects SYSTIML/H regsters */
 	struct cyclecounter cc;
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 3c2898d..cad250b 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -104,6 +104,7 @@ static const struct e1000_stats e1000_gstrings_stats[] = {
 	E1000_STAT("rx_hwtstamp_cleared", rx_hwtstamp_cleared),
 	E1000_STAT("uncorr_ecc_errors", uncorr_errors),
 	E1000_STAT("corr_ecc_errors", corr_errors),
+	E1000_STAT("tx_hwtstamp_timeouts", tx_hwtstamp_timeouts),
 };
 
 #define E1000_GLOBAL_STATS_LEN	ARRAY_SIZE(e1000_gstrings_stats)
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 6bd1832..b8d252f 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1163,6 +1163,12 @@ static void e1000e_tx_hwtstamp_work(struct work_struct *work)
 		skb_tstamp_tx(adapter->tx_hwtstamp_skb, &shhwtstamps);
 		dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
 		adapter->tx_hwtstamp_skb = NULL;
+	} else if (time_after(jiffies, adapter->tx_hwtstamp_start
+			      + adapter->tx_timeout_factor * HZ)) {
+		dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
+		adapter->tx_hwtstamp_skb = NULL;
+		adapter->tx_hwtstamp_timeouts++;
+		e_warn("clearing Tx timestamp hang");
 	} else {
 		/* reschedule to check later */
 		schedule_work(&adapter->tx_hwtstamp_work);
@@ -5567,6 +5573,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 			tx_flags |= E1000_TX_FLAGS_HWTSTAMP;
 			adapter->tx_hwtstamp_skb = skb_get(skb);
+			adapter->tx_hwtstamp_start = jiffies;
 			schedule_work(&adapter->tx_hwtstamp_work);
 		} else {
 			skb_tx_timestamp(skb);
-- 
1.9.0
