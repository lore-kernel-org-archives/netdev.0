From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [RFC PATCH 4/7] net: ethernet: update drivers to provide timestamping packet info
Date: Wed, 12 Apr 2017 16:17:34 +0200
Message-ID: <20170412141737.5881-5-mlichvar@redhat.com>
References: <20170412141737.5881-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54698 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752676AbdDLORt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 10:17:49 -0400
In-Reply-To: <20170412141737.5881-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update drivers that support hardware timestamping to provide the
interface index and packet length for the SOF_TIMESTAMPING_OPT_PKTINFO
option.

TODO: update other drivers (not just e1000e and igb)

CC: Richard Cochran <richardcochran@gmail.com>
CC: Willem de Bruijn <willemb@google.com>
CC: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 14 +++++-----
 drivers/net/ethernet/intel/igb/igb.h       |  7 ++---
 drivers/net/ethernet/intel/igb/igb_main.c  | 21 ++++++++++++---
 drivers/net/ethernet/intel/igb/igb_ptp.c   | 42 +++++++++++++++---------------
 4 files changed, 49 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 3a77054..097b1ec2 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -508,9 +508,8 @@ static int e1000_desc_unused(struct e1000_ring *ring)
  * value involves reading two 32 bit registers. The first read latches the
  * value.
  **/
-static void e1000e_systim_to_hwtstamp(struct e1000_adapter *adapter,
-				      struct skb_shared_hwtstamps *hwtstamps,
-				      u64 systim)
+static ktime_t e1000e_systim_to_hwtstamp(struct e1000_adapter *adapter,
+					 u64 systim)
 {
 	u64 ns;
 	unsigned long flags;
@@ -519,8 +518,7 @@ static void e1000e_systim_to_hwtstamp(struct e1000_adapter *adapter,
 	ns = timecounter_cyc2time(&adapter->tc, systim);
 	spin_unlock_irqrestore(&adapter->systim_lock, flags);
 
-	memset(hwtstamps, 0, sizeof(*hwtstamps));
-	hwtstamps->hwtstamp = ns_to_ktime(ns);
+	return ns_to_ktime(ns);
 }
 
 /**
@@ -553,7 +551,8 @@ static void e1000e_rx_hwtstamp(struct e1000_adapter *adapter, u32 status,
 	 */
 	rxstmp = (u64)er32(RXSTMPL);
 	rxstmp |= (u64)er32(RXSTMPH) << 32;
-	e1000e_systim_to_hwtstamp(adapter, skb_hwtstamps(skb), rxstmp);
+	skb_hw_timestamp(skb, e1000e_systim_to_hwtstamp(adapter, rxstmp),
+			 adapter->netdev->ifindex, skb->len);
 
 	adapter->flags2 &= ~FLAG2_CHECK_RX_HWTSTAMP;
 }
@@ -1188,7 +1187,8 @@ static void e1000e_tx_hwtstamp_work(struct work_struct *work)
 		txstmp = er32(TXSTMPL);
 		txstmp |= (u64)er32(TXSTMPH) << 32;
 
-		e1000e_systim_to_hwtstamp(adapter, &shhwtstamps, txstmp);
+		shhwtstamps.hwtstamp =
+			e1000e_systim_to_hwtstamp(adapter, txstmp);
 
 		skb_tstamp_tx(adapter->tx_hwtstamp_skb, &shhwtstamps);
 		dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index dc6e298..6ceccba 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -653,9 +653,10 @@ void igb_ptp_stop(struct igb_adapter *adapter);
 void igb_ptp_reset(struct igb_adapter *adapter);
 void igb_ptp_suspend(struct igb_adapter *adapter);
 void igb_ptp_rx_hang(struct igb_adapter *adapter);
-void igb_ptp_rx_rgtstamp(struct igb_q_vector *q_vector, struct sk_buff *skb);
-void igb_ptp_rx_pktstamp(struct igb_q_vector *q_vector, void *va,
-			 struct sk_buff *skb);
+ktime_t igb_ptp_rx_rgtstamp(struct igb_q_vector *q_vector,
+			    struct sk_buff *skb);
+ktime_t igb_ptp_rx_pktstamp(struct igb_q_vector *q_vector, void *va,
+			    struct sk_buff *skb);
 int igb_ptp_set_ts_config(struct net_device *netdev, struct ifreq *ifr);
 int igb_ptp_get_ts_config(struct net_device *netdev, struct ifreq *ifr);
 void igb_set_flag_queue_pairs(struct igb_adapter *, const u32);
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 26a821f..20014d92 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6990,9 +6990,14 @@ static struct sk_buff *igb_construct_skb(struct igb_ring *rx_ring,
 		return NULL;
 
 	if (unlikely(igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TSIP))) {
-		igb_ptp_rx_pktstamp(rx_ring->q_vector, va, skb);
+		ktime_t hwtstamp;
+
+		hwtstamp = igb_ptp_rx_pktstamp(rx_ring->q_vector, va, skb);
 		va += IGB_TS_HDR_LEN;
 		size -= IGB_TS_HDR_LEN;
+		/* FIXME: is size the L2 size of the packet? */
+		skb_hw_timestamp(skb, hwtstamp, rx_ring->netdev->ifindex,
+				 size);
 	}
 
 	/* Determine available headroom for copy */
@@ -7052,8 +7057,12 @@ static struct sk_buff *igb_build_skb(struct igb_ring *rx_ring,
 
 	/* pull timestamp out of packet data */
 	if (igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TSIP)) {
-		igb_ptp_rx_pktstamp(rx_ring->q_vector, skb->data, skb);
+		ktime_t hwtstamp;
+
+		hwtstamp = igb_ptp_rx_pktstamp(rx_ring->q_vector, va, skb);
 		__skb_pull(skb, IGB_TS_HDR_LEN);
+		skb_hw_timestamp(skb, hwtstamp, rx_ring->netdev->ifindex,
+				 skb->len);
 	}
 
 	/* update buffer offset */
@@ -7199,8 +7208,12 @@ static void igb_process_skb_fields(struct igb_ring *rx_ring,
 	igb_rx_checksum(rx_ring, rx_desc, skb);
 
 	if (igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TS) &&
-	    !igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TSIP))
-		igb_ptp_rx_rgtstamp(rx_ring->q_vector, skb);
+	    !igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TSIP)) {
+		ktime_t hwtstamp;
+
+		hwtstamp = igb_ptp_rx_rgtstamp(rx_ring->q_vector, skb);
+		skb_hw_timestamp(skb, hwtstamp, dev->ifindex, skb->len);
+	}
 
 	if ((dev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
 	    igb_test_staterr(rx_desc, E1000_RXD_STAT_VP)) {
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index d333d6d..e903173 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -163,11 +163,11 @@ static void igb_ptp_write_i210(struct igb_adapter *adapter,
  * In addition, here have extended the system time with an overflow
  * counter in software.
  **/
-static void igb_ptp_systim_to_hwtstamp(struct igb_adapter *adapter,
-				       struct skb_shared_hwtstamps *hwtstamps,
-				       u64 systim)
+static ktime_t igb_ptp_systim_to_hwtstamp(struct igb_adapter *adapter,
+					  u64 systim)
 {
 	unsigned long flags;
+	ktime_t hwtstamp = 0;
 	u64 ns;
 
 	switch (adapter->hw.mac.type) {
@@ -181,19 +181,18 @@ static void igb_ptp_systim_to_hwtstamp(struct igb_adapter *adapter,
 
 		spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
 
-		memset(hwtstamps, 0, sizeof(*hwtstamps));
-		hwtstamps->hwtstamp = ns_to_ktime(ns);
+		hwtstamp = ns_to_ktime(ns);
 		break;
 	case e1000_i210:
 	case e1000_i211:
-		memset(hwtstamps, 0, sizeof(*hwtstamps));
 		/* Upper 32 bits contain s, lower 32 bits contain ns. */
-		hwtstamps->hwtstamp = ktime_set(systim >> 32,
-						systim & 0xFFFFFFFF);
+		hwtstamp = ktime_set(systim >> 32, systim & 0xFFFFFFFF);
 		break;
 	default:
 		break;
 	}
+
+	return hwtstamp;
 }
 
 /* PTP clock operations */
@@ -729,7 +728,7 @@ static void igb_ptp_tx_hwtstamp(struct igb_adapter *adapter)
 	regval = rd32(E1000_TXSTMPL);
 	regval |= (u64)rd32(E1000_TXSTMPH) << 32;
 
-	igb_ptp_systim_to_hwtstamp(adapter, &shhwtstamps, regval);
+	shhwtstamps.hwtstamp = igb_ptp_systim_to_hwtstamp(adapter, regval);
 	/* adjust timestamp for the TX latency based on link speed */
 	if (adapter->hw.mac.type == e1000_i210) {
 		switch (adapter->link_speed) {
@@ -764,19 +763,19 @@ static void igb_ptp_tx_hwtstamp(struct igb_adapter *adapter)
  * incoming frame.  The value is stored in little endian format starting on
  * byte 8.
  **/
-void igb_ptp_rx_pktstamp(struct igb_q_vector *q_vector, void *va,
-			 struct sk_buff *skb)
+ktime_t igb_ptp_rx_pktstamp(struct igb_q_vector *q_vector, void *va,
+			    struct sk_buff *skb)
 {
 	__le64 *regval = (__le64 *)va;
 	struct igb_adapter *adapter = q_vector->adapter;
+	ktime_t hwtstamp;
 	int adjust = 0;
 
 	/* The timestamp is recorded in little endian format.
 	 * DWORD: 0        1        2        3
 	 * Field: Reserved Reserved SYSTIML  SYSTIMH
 	 */
-	igb_ptp_systim_to_hwtstamp(adapter, skb_hwtstamps(skb),
-				   le64_to_cpu(regval[1]));
+	hwtstamp = igb_ptp_systim_to_hwtstamp(adapter, le64_to_cpu(regval[1]));
 
 	/* adjust timestamp for the RX latency based on link speed */
 	if (adapter->hw.mac.type == e1000_i210) {
@@ -792,8 +791,8 @@ void igb_ptp_rx_pktstamp(struct igb_q_vector *q_vector, void *va,
 			break;
 		}
 	}
-	skb_hwtstamps(skb)->hwtstamp =
-		ktime_sub_ns(skb_hwtstamps(skb)->hwtstamp, adjust);
+
+	return ktime_sub_ns(hwtstamp, adjust);
 }
 
 /**
@@ -804,11 +803,12 @@ void igb_ptp_rx_pktstamp(struct igb_q_vector *q_vector, void *va,
  * This function is meant to retrieve a timestamp from the internal registers
  * of the adapter and store it in the skb.
  **/
-void igb_ptp_rx_rgtstamp(struct igb_q_vector *q_vector,
-			 struct sk_buff *skb)
+ktime_t igb_ptp_rx_rgtstamp(struct igb_q_vector *q_vector,
+			    struct sk_buff *skb)
 {
 	struct igb_adapter *adapter = q_vector->adapter;
 	struct e1000_hw *hw = &adapter->hw;
+	ktime_t hwtstamp;
 	u64 regval;
 	int adjust = 0;
 
@@ -823,12 +823,12 @@ void igb_ptp_rx_rgtstamp(struct igb_q_vector *q_vector,
 	 * can turn into a skb_shared_hwtstamps.
 	 */
 	if (!(rd32(E1000_TSYNCRXCTL) & E1000_TSYNCRXCTL_VALID))
-		return;
+		return 0;
 
 	regval = rd32(E1000_RXSTMPL);
 	regval |= (u64)rd32(E1000_RXSTMPH) << 32;
 
-	igb_ptp_systim_to_hwtstamp(adapter, skb_hwtstamps(skb), regval);
+	hwtstamp = igb_ptp_systim_to_hwtstamp(adapter, regval);
 
 	/* adjust timestamp for the RX latency based on link speed */
 	if (adapter->hw.mac.type == e1000_i210) {
@@ -844,13 +844,13 @@ void igb_ptp_rx_rgtstamp(struct igb_q_vector *q_vector,
 			break;
 		}
 	}
-	skb_hwtstamps(skb)->hwtstamp =
-		ktime_sub_ns(skb_hwtstamps(skb)->hwtstamp, adjust);
 
 	/* Update the last_rx_timestamp timer in order to enable watchdog check
 	 * for error case of latched timestamp on a dropped packet.
 	 */
 	adapter->last_rx_timestamp = jiffies;
+
+	return ktime_sub_ns(hwtstamp, adjust);
 }
 
 /**
-- 
2.9.3
