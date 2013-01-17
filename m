From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] igb: Add timeout for PTP Tx work item
Date: Thu, 17 Jan 2013 03:35:16 -0800
Message-ID: <1358422519-20981-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Richard Cochran <richardcochran@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:48983 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755786Ab3AQLfr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 06:35:47 -0500
In-Reply-To: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

When transmitting a packet that must return a Tx timestamp, a work item
gets scheduled to poll for the Tx timestamp being completed in hardware.
Add a timeout on this work item of 15 seconds from when the driver gets the
skb, after which it will stop polling. Report via stats and system log if
this occurs.

Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Acked-by: Jacob Keller <Jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h         |  2 ++
 drivers/net/ethernet/intel/igb/igb_ethtool.c |  1 +
 drivers/net/ethernet/intel/igb/igb_main.c    |  1 +
 drivers/net/ethernet/intel/igb/igb_ptp.c     | 10 ++++++++++
 4 files changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 8372c00..8c6f59d 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -414,9 +414,11 @@ struct igb_adapter {
 	struct delayed_work ptp_overflow_work;
 	struct work_struct ptp_tx_work;
 	struct sk_buff *ptp_tx_skb;
+	unsigned long ptp_tx_start;
 	spinlock_t tmreg_lock;
 	struct cyclecounter cc;
 	struct timecounter tc;
+	u32 tx_hwtstamp_timeouts;
 
 	char fw_version[32];
 #ifdef CONFIG_IGB_HWMON
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 6180303..6f2579c 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -92,6 +92,7 @@ static const struct igb_stats igb_gstrings_stats[] = {
 	IGB_STAT("os2bmc_tx_by_bmc", stats.b2ospc),
 	IGB_STAT("os2bmc_tx_by_host", stats.o2bspc),
 	IGB_STAT("os2bmc_rx_by_host", stats.b2ogprc),
+	IGB_STAT("tx_hwtstamp_timeouts", tx_hwtstamp_timeouts),
 };
 
 #define IGB_NETDEV_STAT(_net_stat) { \
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 1b5e9a5..360b991 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4618,6 +4618,7 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 		tx_flags |= IGB_TX_FLAGS_TSTAMP;
 
 		adapter->ptp_tx_skb = skb_get(skb);
+		adapter->ptp_tx_start = jiffies;
 		if (adapter->hw.mac.type == e1000_82576)
 			schedule_work(&adapter->ptp_tx_work);
 	}
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index ab34297..086af46 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -70,6 +70,7 @@
  */
 
 #define IGB_SYSTIM_OVERFLOW_PERIOD	(HZ * 60 * 9)
+#define IGB_PTP_TX_TIMEOUT		(HZ * 15)
 #define INCPERIOD_82576			(1 << E1000_TIMINCA_16NS_SHIFT)
 #define INCVALUE_82576_MASK		((1 << E1000_TIMINCA_16NS_SHIFT) - 1)
 #define INCVALUE_82576			(16 << IGB_82576_TSYNC_SHIFT)
@@ -396,6 +397,15 @@ void igb_ptp_tx_work(struct work_struct *work)
 	if (!adapter->ptp_tx_skb)
 		return;
 
+	if (time_is_before_jiffies(adapter->ptp_tx_start +
+				   IGB_PTP_TX_TIMEOUT)) {
+		dev_kfree_skb_any(adapter->ptp_tx_skb);
+		adapter->ptp_tx_skb = NULL;
+		adapter->tx_hwtstamp_timeouts++;
+		dev_warn(&adapter->pdev->dev, "clearing Tx timestamp hang");
+		return;
+	}
+
 	tsynctxctl = rd32(E1000_TSYNCTXCTL);
 	if (tsynctxctl & E1000_TSYNCTXCTL_VALID)
 		igb_ptp_tx_hwtstamp(adapter);
-- 
1.7.11.7
