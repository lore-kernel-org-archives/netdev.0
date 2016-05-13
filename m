From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] igb: adjust PTP timestamps for Tx/Rx latency
Date: Fri, 13 May 2016 16:43:49 -0700
Message-ID: <1463183035-31888-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Nathan Sullivan <nathan.sullivan@ni.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:31691 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932205AbcEMXoB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 19:44:01 -0400
In-Reply-To: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Sullivan <nathan.sullivan@ni.com>

Table 7-62 on page 338 of the i210 datasheet lists TX and RX latencies
for the various speeds the chip supports.  To give better PTP timestamp
accuracy, adjust the timestamps by the amounts Intel gives based on
current link speed.

Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h     |  8 +++++++
 drivers/net/ethernet/intel/igb/igb_ptp.c | 36 ++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 7a7bc31..b9609af 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -91,6 +91,14 @@ struct igb_adapter;
 #define NVM_COMB_VER_OFF	0x0083
 #define NVM_COMB_VER_PTR	0x003d
 
+/* Transmit and receive latency (for PTP timestamps) */
+#define IGB_I210_TX_LATENCY_10		9542
+#define IGB_I210_TX_LATENCY_100		1024
+#define IGB_I210_TX_LATENCY_1000	178
+#define IGB_I210_RX_LATENCY_10		20662
+#define IGB_I210_RX_LATENCY_100		2213
+#define IGB_I210_RX_LATENCY_1000	448
+
 struct vf_data_storage {
 	unsigned char vf_mac_addresses[ETH_ALEN];
 	u16 vf_mc_hashes[IGB_MAX_VF_MC_ENTRIES];
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index fdb6dfd..f097c5a 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -722,11 +722,29 @@ static void igb_ptp_tx_hwtstamp(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	struct skb_shared_hwtstamps shhwtstamps;
 	u64 regval;
+	int adjust = 0;
 
 	regval = rd32(E1000_TXSTMPL);
 	regval |= (u64)rd32(E1000_TXSTMPH) << 32;
 
 	igb_ptp_systim_to_hwtstamp(adapter, &shhwtstamps, regval);
+	/* adjust timestamp for the TX latency based on link speed */
+	if (adapter->hw.mac.type == e1000_i210) {
+		switch (adapter->link_speed) {
+		case SPEED_10:
+			adjust = IGB_I210_TX_LATENCY_10;
+			break;
+		case SPEED_100:
+			adjust = IGB_I210_TX_LATENCY_100;
+			break;
+		case SPEED_1000:
+			adjust = IGB_I210_TX_LATENCY_1000;
+			break;
+		}
+	}
+
+	shhwtstamps.hwtstamp = ktime_sub_ns(shhwtstamps.hwtstamp, adjust);
+
 	skb_tstamp_tx(adapter->ptp_tx_skb, &shhwtstamps);
 	dev_kfree_skb_any(adapter->ptp_tx_skb);
 	adapter->ptp_tx_skb = NULL;
@@ -771,6 +789,7 @@ void igb_ptp_rx_rgtstamp(struct igb_q_vector *q_vector,
 	struct igb_adapter *adapter = q_vector->adapter;
 	struct e1000_hw *hw = &adapter->hw;
 	u64 regval;
+	int adjust = 0;
 
 	/* If this bit is set, then the RX registers contain the time stamp. No
 	 * other packet will be time stamped until we read these registers, so
@@ -790,6 +809,23 @@ void igb_ptp_rx_rgtstamp(struct igb_q_vector *q_vector,
 
 	igb_ptp_systim_to_hwtstamp(adapter, skb_hwtstamps(skb), regval);
 
+	/* adjust timestamp for the RX latency based on link speed */
+	if (adapter->hw.mac.type == e1000_i210) {
+		switch (adapter->link_speed) {
+		case SPEED_10:
+			adjust = IGB_I210_RX_LATENCY_10;
+			break;
+		case SPEED_100:
+			adjust = IGB_I210_RX_LATENCY_100;
+			break;
+		case SPEED_1000:
+			adjust = IGB_I210_RX_LATENCY_1000;
+			break;
+		}
+	}
+	skb_hwtstamps(skb)->hwtstamp =
+		ktime_add_ns(skb_hwtstamps(skb)->hwtstamp, adjust);
+
 	/* Update the last_rx_timestamp timer in order to enable watchdog check
 	 * for error case of latched timestamp on a dropped packet.
 	 */
-- 
2.5.5
