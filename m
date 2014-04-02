From: Jakub Kicinski <kubakici@wp.pl>
Subject: [PATCH net-next 4/4] igb: fix last_rx_timestamp usage
Date: Wed,  2 Apr 2014 02:52:19 +0200
Message-ID: <1396399939-18420-5-git-send-email-kubakici@wp.pl>
References: <1396399939-18420-1-git-send-email-kubakici@wp.pl>
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Matthew Vick <matthew.vick@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:22504 "EHLO mx3.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755050AbaDBAx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 20:53:29 -0400
In-Reply-To: <1396399939-18420-1-git-send-email-kubakici@wp.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

last_rx_timestamp should be updated only when rx time stamp is
read. Also it's only used with NICs that have per-interface time
stamping resources so it can be moved to adapter structure and
set in igb_ptp_rx_rgtstamp().

Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
---
NOTE: Compile tested only!
---
 drivers/net/ethernet/intel/igb/igb.h      | 16 +---------------
 drivers/net/ethernet/intel/igb/igb_main.c |  4 +++-
 drivers/net/ethernet/intel/igb/igb_ptp.c  | 14 +++++++-------
 3 files changed, 11 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 7fbe1e9..2713006 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -241,7 +241,6 @@ struct igb_ring {
 		struct igb_tx_buffer *tx_buffer_info;
 		struct igb_rx_buffer *rx_buffer_info;
 	};
-	unsigned long last_rx_timestamp;
 	void *desc;			/* descriptor ring memory */
 	unsigned long flags;		/* ring specific flags */
 	void __iomem *tail;		/* pointer to ring tail register */
@@ -437,6 +436,7 @@ struct igb_adapter {
 	struct hwtstamp_config tstamp_config;
 	unsigned long ptp_tx_start;
 	unsigned long last_rx_ptp_check;
+	unsigned long last_rx_timestamp;
 	spinlock_t tmreg_lock;
 	struct cyclecounter cc;
 	struct timecounter tc;
@@ -533,20 +533,6 @@ void igb_ptp_rx_hang(struct igb_adapter *adapter);
 void igb_ptp_rx_rgtstamp(struct igb_q_vector *q_vector, struct sk_buff *skb);
 void igb_ptp_rx_pktstamp(struct igb_q_vector *q_vector, unsigned char *va,
 			 struct sk_buff *skb);
-static inline void igb_ptp_rx_hwtstamp(struct igb_ring *rx_ring,
-				       union e1000_adv_rx_desc *rx_desc,
-				       struct sk_buff *skb)
-{
-	if (igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TS) &&
-	    !igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TSIP))
-		igb_ptp_rx_rgtstamp(rx_ring->q_vector, skb);
-
-	/* Update the last_rx_timestamp timer in order to enable watchdog check
-	 * for error case of latched timestamp on a dropped packet.
-	 */
-	rx_ring->last_rx_timestamp = jiffies;
-}
-
 int igb_ptp_set_ts_config(struct net_device *netdev, struct ifreq *ifr);
 int igb_ptp_get_ts_config(struct net_device *netdev, struct ifreq *ifr);
 #ifdef CONFIG_IGB_HWMON
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 3019818..accec51 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6955,7 +6955,9 @@ static void igb_process_skb_fields(struct igb_ring *rx_ring,
 
 	igb_rx_checksum(rx_ring, rx_desc, skb);
 
-	igb_ptp_rx_hwtstamp(rx_ring, rx_desc, skb);
+	if (igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TS) &&
+	    !igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TSIP))
+		igb_ptp_rx_rgtstamp(rx_ring->q_vector, skb);
 
 	if ((dev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
 	    igb_test_staterr(rx_desc, E1000_RXD_STAT_VP)) {
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index bc33c4c..ab25e49 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -427,10 +427,8 @@ static void igb_ptp_overflow_check(struct work_struct *work)
 void igb_ptp_rx_hang(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	struct igb_ring *rx_ring;
 	u32 tsyncrxctl = rd32(E1000_TSYNCRXCTL);
 	unsigned long rx_event;
-	int n;
 
 	if (hw->mac.type != e1000_82576)
 		return;
@@ -445,11 +443,8 @@ void igb_ptp_rx_hang(struct igb_adapter *adapter)
 
 	/* Determine the most recent watchdog or rx_timestamp event */
 	rx_event = adapter->last_rx_ptp_check;
-	for (n = 0; n < adapter->num_rx_queues; n++) {
-		rx_ring = adapter->rx_ring[n];
-		if (time_after(rx_ring->last_rx_timestamp, rx_event))
-			rx_event = rx_ring->last_rx_timestamp;
-	}
+	if (time_after(adapter->last_rx_timestamp, rx_event))
+		rx_event = adapter->last_rx_timestamp;
 
 	/* Only need to read the high RXSTMP register to clear the lock */
 	if (time_is_before_jiffies(rx_event + 5 * HZ)) {
@@ -540,6 +535,11 @@ void igb_ptp_rx_rgtstamp(struct igb_q_vector *q_vector,
 	regval |= (u64)rd32(E1000_RXSTMPH) << 32;
 
 	igb_ptp_systim_to_hwtstamp(adapter, skb_hwtstamps(skb), regval);
+
+	/* Update the last_rx_timestamp timer in order to enable watchdog check
+	 * for error case of latched timestamp on a dropped packet.
+	 */
+	adapter->last_rx_timestamp = jiffies;
 }
 
 /**
-- 
1.9.0
