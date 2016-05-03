From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: [PATCH] igb: adjust ptp timestamps for tx/rx latency
Date: Tue, 3 May 2016 18:10:56 -0500
Message-ID: <1462317056-28805-1-git-send-email-nathan.sullivan@ni.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Nathan Sullivan <nathan.sullivan@ni.com>
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Table 7-62 on page 338 of the i210 datasheet lists TX and RX latencies
for the various speeds the chip supports.  To give better ptp timestamp
accuracy, adjust the timestamps by the amounts Intel gives based on
current link speed.

Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
---
 drivers/net/ethernet/intel/igb/igb.h     |    8 +++++++
 drivers/net/ethernet/intel/igb/igb_ptp.c |   36 ++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 9413fa6..7cee61f9 100644
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
index 22a8a29..76a896d 100644
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
1.7.10.4
