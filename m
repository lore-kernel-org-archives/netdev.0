From: Richard Cochran <rcochran@linutronix.de>
Subject: [PATCH RFC V1 net-next 6/6] net: igb: Implement time based transmission.
Date: Mon, 18 Sep 2017 09:41:21 +0200
Message-ID: <9ecfd21da8e8ad93a5f757b009cf123b6929255f.1505719061.git.rcochran@linutronix.de>
References: <cover.1505719061.git.rcochran@linutronix.de>
Cc: <linux-kernel@vger.kernel.org>, intel-wired-lan@lists.osuosl.org,
        Andre Guedes <andre.guedes@intel.com>,
        Anna-Maria Gleixner <anna-maria@linutronix.de>,
        David Miller <davem@davemloft.net>,
        Henrik Austad <henrik@austad.us>,
        Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Vinicius Costa Gomes <vinicius.gomes@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1505719061.git.rcochran@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch configures the i210 transmit queues to reserve the first queue
for time based transmit arbitration, placing all other traffic into the
second queue.  This configuration is hard coded and does not make use of
the two spare queues.

Signed-off-by: Richard Cochran <rcochran@linutronix.de>
---
 drivers/net/ethernet/intel/igb/e1000_82575.h   |  1 +
 drivers/net/ethernet/intel/igb/e1000_defines.h | 68 +++++++++++++++++++++++++-
 drivers/net/ethernet/intel/igb/e1000_regs.h    |  5 ++
 drivers/net/ethernet/intel/igb/igb.h           |  3 +-
 drivers/net/ethernet/intel/igb/igb_main.c      | 68 +++++++++++++++++++++++---
 5 files changed, 136 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.h b/drivers/net/ethernet/intel/igb/e1000_82575.h
index acf06051e111..4c107377540d 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.h
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.h
@@ -159,6 +159,7 @@ struct e1000_adv_tx_context_desc {
 /* Additional Transmit Descriptor Control definitions */
 #define E1000_TXDCTL_QUEUE_ENABLE  0x02000000 /* Enable specific Tx Queue */
 /* Tx Queue Arbitration Priority 0=low, 1=high */
+#define E1000_TXDCTL_HIGH_PRIORITY 0x08000000
 
 /* Additional Receive Descriptor Control definitions */
 #define E1000_RXDCTL_QUEUE_ENABLE  0x02000000 /* Enable specific Rx Queue */
diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index 1de82f247312..51ab8d0b3dd6 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -352,8 +352,35 @@
 /* Timestamp in Rx buffer */
 #define E1000_RXPBS_CFG_TS_EN           0x80000000
 
-#define I210_RXPBSIZE_DEFAULT		0x000000A2 /* RXPBSIZE default */
-#define I210_TXPBSIZE_DEFAULT		0x04000014 /* TXPBSIZE default */
+/*
+ * Internal Packet Buffer Size Registers
+ * For transmit, Section 7.2.7.7 on page 312 recommends 8, 8, 4, and 4 KB.
+ * TXPB[0-3]SIZE are in KB for TxQ[0-3].
+ */
+#define RXPBSIZE	0x22
+#define BMC2OSPBSIZE	0x02
+#define TXPB0SIZE	8
+#define TXPB1SIZE	12
+#define TXPB2SIZE	0
+#define TXPB3SIZE	0
+#define OS2BMCPBSIZE	4
+
+#define TOTAL_RXTX_PBSIZE \
+	(RXPBSIZE + BMC2OSPBSIZE + \
+	 TXPB0SIZE + TXPB1SIZE + TXPB2SIZE + TXPB3SIZE + OS2BMCPBSIZE)
+
+#if TOTAL_RXTX_PBSIZE > 60
+#error RX TX PBSIZE exceeds 60 KB.
+#elif TOTAL_RXTX_PBSIZE < 60
+#error RX TX PBSIZE too small.
+#endif
+
+#define I210_TXPBSIZE_DEFAULT \
+	(TXPB0SIZE | (TXPB1SIZE << 6) | (TXPB2SIZE << 12) | \
+	 (TXPB3SIZE << 18) | (OS2BMCPBSIZE << 24))
+
+#define I210_RXPBSIZE_DEFAULT \
+	(RXPBSIZE | (BMC2OSPBSIZE << 6))
 
 /* SerDes Control */
 #define E1000_SCTL_DISABLE_SERDES_LOOPBACK 0x0400
@@ -1051,4 +1078,41 @@
 #define E1000_VLAPQF_P_VALID(_n)	(0x1 << (3 + (_n) * 4))
 #define E1000_VLAPQF_QUEUE_MASK	0x03
 
+/* DMA TX Maximum Packet Size */
+#define E1000_DMA_TX_MAXIMUM_PACKET_SIZE (1536 >> 6) /* Units of 64 bytes. */
+
+/* TX Qav Credit Control fields */
+#define E1000_TQAVCC_QUEUEMODE_STREAM_RESERVATION BIT(31)
+
+/* Tx Qav Control */
+#define E1000_TQAVCTRL_TRANSMITMODE_QAV			BIT(0)
+#define E1000_TQAVCTRL_1588_STAT_EN			BIT(2)
+#define E1000_TQAVCTRL_DATA_FETCH_ARB_MOSTEMPTY		BIT(4)
+#define E1000_TQAVCTRL_DATA_TRAN_ARB_CREDITSHAPER	BIT(8)
+#define E1000_TQAVCTRL_DATA_TRAN_TIM			BIT(9)
+#define E1000_TQAVCTRL_SP_WAIT_SR			BIT(10)
+#define E1000_TQAVCTRL_FETCH_TIM_DELTA_SHIFT		16
+/*
+ * Fetch Time Delta - bits 31:16
+ *
+ * This field holds the value to be reduced from the launch time for
+ * fetch time decision. The FetchTimeDelta value is defined in 32 ns
+ * granularity.
+ *
+ * This field is 16 bits wide, and so the maximum value is:
+ *
+ * 65535 * 32 = 2097120 ~= 2 msec
+ *
+ * Is there any reason not to dial max here?
+ */
+#define E1000_FETCH_TIME_DELTA 0xffff
+
+#define	E1000_DEFAULT_TQAVCTRL (			\
+	E1000_TQAVCTRL_TRANSMITMODE_QAV |		\
+	E1000_TQAVCTRL_DATA_FETCH_ARB_MOSTEMPTY |	\
+	E1000_TQAVCTRL_DATA_TRAN_TIM |			\
+	E1000_TQAVCTRL_SP_WAIT_SR |			\
+	(E1000_FETCH_TIME_DELTA << E1000_TQAVCTRL_FETCH_TIM_DELTA_SHIFT) \
+)
+
 #endif
diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index 58adbf234e07..a2ac3331877c 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -421,6 +421,11 @@ do { \
 
 #define E1000_I210_FLA		0x1201C
 
+#define E1000_I210_TQAVCC0	0x3004
+#define E1000_I210_TQAVCC1	0x3044
+#define E1000_I210_DTXMXPKTSZ	0x355C /* DMA TX Maximum Packet Size */
+#define E1000_I210_TQAVCTRL	0x3570 /* Tx Qav Control */
+
 #define E1000_INVM_DATA_REG(_n)	(0x12120 + 4*(_n))
 #define E1000_INVM_SIZE		64 /* Number of INVM Data Registers */
 
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 06ffb2bc713e..95f20eee8194 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -328,7 +328,8 @@ enum e1000_ring_flags_t {
 	IGB_RING_FLAG_RX_SCTP_CSUM,
 	IGB_RING_FLAG_RX_LB_VLAN_BSWAP,
 	IGB_RING_FLAG_TX_CTX_IDX,
-	IGB_RING_FLAG_TX_DETECT_HANG
+	IGB_RING_FLAG_TX_DETECT_HANG,
+	IGB_RING_FLAG_HIGH_PRIORITY
 };
 
 #define ring_uses_large_buffer(ring) \
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index fd4a46b03cc8..69c877290d52 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1598,6 +1598,40 @@ static void igb_get_hw_control(struct igb_adapter *adapter)
 			ctrl_ext | E1000_CTRL_EXT_DRV_LOAD);
 }
 
+static void igb_qav_config(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+
+	/*
+	 * Global Qav configuration  (see 7.2.7.7 on page 312)
+	 */
+	wr32(E1000_I210_DTXMXPKTSZ, 1536 >> 6);
+	wr32(E1000_I210_TQAVCTRL, (u32) E1000_DEFAULT_TQAVCTRL);
+
+	/*
+	 * Per Queue (0/1) Qav configuration
+	 *
+	 * Note: Queue0 QueueMode must be set to 1
+	 *       when TransmitMode is set to Qav.
+	 */
+	wr32(E1000_I210_TQAVCC0, E1000_TQAVCC_QUEUEMODE_STREAM_RESERVATION);
+}
+
+static u16 igb_select_queue(struct net_device *netdev, struct sk_buff *skb,
+				 void *accel, select_queue_fallback_t fallback)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+
+	if (hw->mac.type != e1000_i210)
+		return fallback(netdev, skb);
+
+	if (skb->transmit_time)
+		return 0;
+	else
+		return 1;
+}
+
 /**
  *  igb_configure - configure the hardware for RX and TX
  *  @adapter: private board structure
@@ -1616,6 +1650,8 @@ static void igb_configure(struct igb_adapter *adapter)
 	igb_setup_mrqc(adapter);
 	igb_setup_rctl(adapter);
 
+	igb_qav_config(adapter);
+
 	igb_nfc_filter_restore(adapter);
 	igb_configure_tx(adapter);
 	igb_configure_rx(adapter);
@@ -2175,6 +2211,7 @@ static const struct net_device_ops igb_netdev_ops = {
 	.ndo_set_features	= igb_set_features,
 	.ndo_fdb_add		= igb_ndo_fdb_add,
 	.ndo_features_check	= igb_features_check,
+	.ndo_select_queue	= igb_select_queue,
 };
 
 /**
@@ -3062,7 +3099,11 @@ static void igb_init_queue_configuration(struct igb_adapter *adapter)
 		break;
 	}
 
-	adapter->rss_queues = min_t(u32, max_rss_queues, num_online_cpus());
+	/*
+	 * For time based Tx, we must configure four Tx queues.
+	 */
+	adapter->rss_queues = hw->mac.type == e1000_i210 ?
+		max_rss_queues : min_t(u32, max_rss_queues, num_online_cpus());
 
 	igb_set_flag_queue_pairs(adapter, max_rss_queues);
 }
@@ -3462,6 +3503,9 @@ void igb_configure_tx_ring(struct igb_adapter *adapter,
 	memset(ring->tx_buffer_info, 0,
 	       sizeof(struct igb_tx_buffer) * ring->count);
 
+	if (ring->flags & IGB_RING_FLAG_HIGH_PRIORITY)
+		txdctl |= E1000_TXDCTL_HIGH_PRIORITY;
+
 	txdctl |= E1000_TXDCTL_QUEUE_ENABLE;
 	wr32(E1000_TXDCTL(reg_idx), txdctl);
 }
@@ -3476,6 +3520,11 @@ static void igb_configure_tx(struct igb_adapter *adapter)
 {
 	int i;
 
+	/*
+	 * Reserve the first queue for time based Tx.
+	 */
+	adapter->tx_ring[0]->flags |= IGB_RING_FLAG_HIGH_PRIORITY;
+
 	for (i = 0; i < adapter->num_tx_queues; i++)
 		igb_configure_tx_ring(adapter, adapter->tx_ring[i]);
 }
@@ -4948,11 +4997,12 @@ static void igb_set_itr(struct igb_q_vector *q_vector)
 	}
 }
 
-static void igb_tx_ctxtdesc(struct igb_ring *tx_ring, u32 vlan_macip_lens,
-			    u32 type_tucmd, u32 mss_l4len_idx)
+static void igb_tx_ctxtdesc(struct igb_ring *tx_ring, struct igb_tx_buffer *first,
+			    u32 vlan_macip_lens, u32 type_tucmd, u32 mss_l4len_idx)
 {
 	struct e1000_adv_tx_context_desc *context_desc;
 	u16 i = tx_ring->next_to_use;
+	struct timespec64 ts;
 
 	context_desc = IGB_TX_CTXTDESC(tx_ring, i);
 
@@ -4967,9 +5017,15 @@ static void igb_tx_ctxtdesc(struct igb_ring *tx_ring, u32 vlan_macip_lens,
 		mss_l4len_idx |= tx_ring->reg_idx << 4;
 
 	context_desc->vlan_macip_lens	= cpu_to_le32(vlan_macip_lens);
-	context_desc->seqnum_seed	= 0;
 	context_desc->type_tucmd_mlhl	= cpu_to_le32(type_tucmd);
 	context_desc->mss_l4len_idx	= cpu_to_le32(mss_l4len_idx);
+
+	if (tx_ring->flags & IGB_RING_FLAG_HIGH_PRIORITY && tx_ring->reg_idx == 0) {
+		ts = ns_to_timespec64(first->skb->transmit_time);
+		context_desc->seqnum_seed = cpu_to_le32(ts.tv_nsec / 32);
+	} else {
+		context_desc->seqnum_seed = 0;
+	}
 }
 
 static int igb_tso(struct igb_ring *tx_ring,
@@ -5052,7 +5108,7 @@ static int igb_tso(struct igb_ring *tx_ring,
 	vlan_macip_lens |= (ip.hdr - skb->data) << E1000_ADVTXD_MACLEN_SHIFT;
 	vlan_macip_lens |= first->tx_flags & IGB_TX_FLAGS_VLAN_MASK;
 
-	igb_tx_ctxtdesc(tx_ring, vlan_macip_lens, type_tucmd, mss_l4len_idx);
+	igb_tx_ctxtdesc(tx_ring, first, vlan_macip_lens, type_tucmd, mss_l4len_idx);
 
 	return 1;
 }
@@ -5107,7 +5163,7 @@ static void igb_tx_csum(struct igb_ring *tx_ring, struct igb_tx_buffer *first)
 	vlan_macip_lens |= skb_network_offset(skb) << E1000_ADVTXD_MACLEN_SHIFT;
 	vlan_macip_lens |= first->tx_flags & IGB_TX_FLAGS_VLAN_MASK;
 
-	igb_tx_ctxtdesc(tx_ring, vlan_macip_lens, type_tucmd, 0);
+	igb_tx_ctxtdesc(tx_ring, first, vlan_macip_lens, type_tucmd, 0);
 }
 
 #define IGB_SET_FLAG(_input, _flag, _result) \
-- 
2.11.0
