From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next 1/6] sfc: update MCDI protocol headers
Date: Thu, 11 Aug 2016 13:01:01 +0100
Message-ID: <5be065ac-736f-64d7-6408-283da5337fd4@solarflare.com>
References: <78a8505b-8c63-b879-2cd2-d78d9890aa6c@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:26478 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750828AbcHKMRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 08:17:44 -0400
In-Reply-To: <78a8505b-8c63-b879-2cd2-d78d9890aa6c@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_pcol.h | 530 ++++++++++++++++++++++++++++++++++-
 1 file changed, 515 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index c9a5b00..ccceafc 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -2645,16 +2645,20 @@
 #define          MC_CMD_POLL_BIST_MEM_BUS_MC 0x0
 /* enum: CSR IREG bus. */
 #define          MC_CMD_POLL_BIST_MEM_BUS_CSR 0x1
-/* enum: RX DPCPU bus. */
+/* enum: RX0 DPCPU bus. */
 #define          MC_CMD_POLL_BIST_MEM_BUS_DPCPU_RX 0x2
 /* enum: TX0 DPCPU bus. */
 #define          MC_CMD_POLL_BIST_MEM_BUS_DPCPU_TX0 0x3
 /* enum: TX1 DPCPU bus. */
 #define          MC_CMD_POLL_BIST_MEM_BUS_DPCPU_TX1 0x4
-/* enum: RX DICPU bus. */
+/* enum: RX0 DICPU bus. */
 #define          MC_CMD_POLL_BIST_MEM_BUS_DICPU_RX 0x5
 /* enum: TX DICPU bus. */
 #define          MC_CMD_POLL_BIST_MEM_BUS_DICPU_TX 0x6
+/* enum: RX1 DPCPU bus. */
+#define          MC_CMD_POLL_BIST_MEM_BUS_DPCPU_RX1 0x7
+/* enum: RX1 DICPU bus. */
+#define          MC_CMD_POLL_BIST_MEM_BUS_DICPU_RX1 0x8
 /* Pattern written to RAM / register */
 #define       MC_CMD_POLL_BIST_OUT_MEM_EXPECT_OFST 16
 /* Actual value read from RAM / register */
@@ -3612,6 +3616,8 @@
 #define        MC_CMD_NVRAM_INFO_OUT_PROTECTED_WIDTH 1
 #define        MC_CMD_NVRAM_INFO_OUT_TLV_LBN 1
 #define        MC_CMD_NVRAM_INFO_OUT_TLV_WIDTH 1
+#define        MC_CMD_NVRAM_INFO_OUT_CMAC_LBN 6
+#define        MC_CMD_NVRAM_INFO_OUT_CMAC_WIDTH 1
 #define        MC_CMD_NVRAM_INFO_OUT_A_B_LBN 7
 #define        MC_CMD_NVRAM_INFO_OUT_A_B_WIDTH 1
 #define       MC_CMD_NVRAM_INFO_OUT_PHYSDEV_OFST 16
@@ -4389,6 +4395,8 @@
  * the command will fail with MC_CMD_ERR_FILTERS_PRESENT.
  */
 #define          MC_CMD_WORKAROUND_BUG26807 0x6
+/* enum: Bug 61265 work around (broken EVQ TMR writes). */
+#define          MC_CMD_WORKAROUND_BUG61265 0x7
 /* 0 = disable the workaround indicated by TYPE; any non-zero value = enable
  * the workaround
  */
@@ -4413,7 +4421,6 @@
  * (GET_PHY_CFG_OUT_MEDIA_TYPE); the valid 'page number' input values, and the
  * output data, are interpreted on a per-type basis. For SFP+: PAGE=0 or 1
  * returns a 128-byte block read from module I2C address 0xA0 offset 0 or 0x80.
- * Anything else: currently undefined. Locks required: None. Return code: 0.
  */
 #define MC_CMD_GET_PHY_MEDIA_INFO 0x4b
 
@@ -5479,6 +5486,8 @@
 #define        LICENSED_V3_FEATURES_TX_SNIFF_WIDTH 1
 #define        LICENSED_V3_FEATURES_PROXY_FILTER_OPS_LBN 8
 #define        LICENSED_V3_FEATURES_PROXY_FILTER_OPS_WIDTH 1
+#define        LICENSED_V3_FEATURES_EVENT_CUT_THROUGH_LBN 9
+#define        LICENSED_V3_FEATURES_EVENT_CUT_THROUGH_WIDTH 1
 #define       LICENSED_V3_FEATURES_MASK_LBN 0
 #define       LICENSED_V3_FEATURES_MASK_WIDTH 64
 
@@ -5634,6 +5643,109 @@
 /* Only valid if INTRFLAG was true */
 #define       MC_CMD_INIT_EVQ_OUT_IRQ_OFST 0
 
+/* MC_CMD_INIT_EVQ_V2_IN msgrequest */
+#define    MC_CMD_INIT_EVQ_V2_IN_LENMIN 44
+#define    MC_CMD_INIT_EVQ_V2_IN_LENMAX 548
+#define    MC_CMD_INIT_EVQ_V2_IN_LEN(num) (36+8*(num))
+/* Size, in entries */
+#define       MC_CMD_INIT_EVQ_V2_IN_SIZE_OFST 0
+/* Desired instance. Must be set to a specific instance, which is a function
+ * local queue index.
+ */
+#define       MC_CMD_INIT_EVQ_V2_IN_INSTANCE_OFST 4
+/* The initial timer value. The load value is ignored if the timer mode is DIS.
+ */
+#define       MC_CMD_INIT_EVQ_V2_IN_TMR_LOAD_OFST 8
+/* The reload value is ignored in one-shot modes */
+#define       MC_CMD_INIT_EVQ_V2_IN_TMR_RELOAD_OFST 12
+/* tbd */
+#define       MC_CMD_INIT_EVQ_V2_IN_FLAGS_OFST 16
+#define        MC_CMD_INIT_EVQ_V2_IN_FLAG_INTERRUPTING_LBN 0
+#define        MC_CMD_INIT_EVQ_V2_IN_FLAG_INTERRUPTING_WIDTH 1
+#define        MC_CMD_INIT_EVQ_V2_IN_FLAG_RPTR_DOS_LBN 1
+#define        MC_CMD_INIT_EVQ_V2_IN_FLAG_RPTR_DOS_WIDTH 1
+#define        MC_CMD_INIT_EVQ_V2_IN_FLAG_INT_ARMD_LBN 2
+#define        MC_CMD_INIT_EVQ_V2_IN_FLAG_INT_ARMD_WIDTH 1
+#define        MC_CMD_INIT_EVQ_V2_IN_FLAG_CUT_THRU_LBN 3
+#define        MC_CMD_INIT_EVQ_V2_IN_FLAG_CUT_THRU_WIDTH 1
+#define        MC_CMD_INIT_EVQ_V2_IN_FLAG_RX_MERGE_LBN 4
+#define        MC_CMD_INIT_EVQ_V2_IN_FLAG_RX_MERGE_WIDTH 1
+#define        MC_CMD_INIT_EVQ_V2_IN_FLAG_TX_MERGE_LBN 5
+#define        MC_CMD_INIT_EVQ_V2_IN_FLAG_TX_MERGE_WIDTH 1
+#define        MC_CMD_INIT_EVQ_V2_IN_FLAG_USE_TIMER_LBN 6
+#define        MC_CMD_INIT_EVQ_V2_IN_FLAG_USE_TIMER_WIDTH 1
+#define        MC_CMD_INIT_EVQ_V2_IN_FLAG_TYPE_LBN 7
+#define        MC_CMD_INIT_EVQ_V2_IN_FLAG_TYPE_WIDTH 4
+/* enum: All initialisation flags specified by host. */
+#define          MC_CMD_INIT_EVQ_V2_IN_FLAG_TYPE_MANUAL 0x0
+/* enum: MEDFORD only. Certain initialisation flags specified by host may be
+ * over-ridden by firmware based on licenses and firmware variant in order to
+ * provide the lowest latency achievable. See
+ * MC_CMD_INIT_EVQ_V2/MC_CMD_INIT_EVQ_V2_OUT/FLAGS for list of affected flags.
+ */
+#define          MC_CMD_INIT_EVQ_V2_IN_FLAG_TYPE_LOW_LATENCY 0x1
+/* enum: MEDFORD only. Certain initialisation flags specified by host may be
+ * over-ridden by firmware based on licenses and firmware variant in order to
+ * provide the best throughput achievable. See
+ * MC_CMD_INIT_EVQ_V2/MC_CMD_INIT_EVQ_V2_OUT/FLAGS for list of affected flags.
+ */
+#define          MC_CMD_INIT_EVQ_V2_IN_FLAG_TYPE_THROUGHPUT 0x2
+/* enum: MEDFORD only. Certain initialisation flags may be over-ridden by
+ * firmware based on licenses and firmware variant. See
+ * MC_CMD_INIT_EVQ_V2/MC_CMD_INIT_EVQ_V2_OUT/FLAGS for list of affected flags.
+ */
+#define          MC_CMD_INIT_EVQ_V2_IN_FLAG_TYPE_AUTO 0x3
+#define       MC_CMD_INIT_EVQ_V2_IN_TMR_MODE_OFST 20
+/* enum: Disabled */
+#define          MC_CMD_INIT_EVQ_V2_IN_TMR_MODE_DIS 0x0
+/* enum: Immediate */
+#define          MC_CMD_INIT_EVQ_V2_IN_TMR_IMMED_START 0x1
+/* enum: Triggered */
+#define          MC_CMD_INIT_EVQ_V2_IN_TMR_TRIG_START 0x2
+/* enum: Hold-off */
+#define          MC_CMD_INIT_EVQ_V2_IN_TMR_INT_HLDOFF 0x3
+/* Target EVQ for wakeups if in wakeup mode. */
+#define       MC_CMD_INIT_EVQ_V2_IN_TARGET_EVQ_OFST 24
+/* Target interrupt if in interrupting mode (note union with target EVQ). Use
+ * MC_CMD_RESOURCE_INSTANCE_ANY unless a specific one required for test
+ * purposes.
+ */
+#define       MC_CMD_INIT_EVQ_V2_IN_IRQ_NUM_OFST 24
+/* Event Counter Mode. */
+#define       MC_CMD_INIT_EVQ_V2_IN_COUNT_MODE_OFST 28
+/* enum: Disabled */
+#define          MC_CMD_INIT_EVQ_V2_IN_COUNT_MODE_DIS 0x0
+/* enum: Disabled */
+#define          MC_CMD_INIT_EVQ_V2_IN_COUNT_MODE_RX 0x1
+/* enum: Disabled */
+#define          MC_CMD_INIT_EVQ_V2_IN_COUNT_MODE_TX 0x2
+/* enum: Disabled */
+#define          MC_CMD_INIT_EVQ_V2_IN_COUNT_MODE_RXTX 0x3
+/* Event queue packet count threshold. */
+#define       MC_CMD_INIT_EVQ_V2_IN_COUNT_THRSHLD_OFST 32
+/* 64-bit address of 4k of 4k-aligned host memory buffer */
+#define       MC_CMD_INIT_EVQ_V2_IN_DMA_ADDR_OFST 36
+#define       MC_CMD_INIT_EVQ_V2_IN_DMA_ADDR_LEN 8
+#define       MC_CMD_INIT_EVQ_V2_IN_DMA_ADDR_LO_OFST 36
+#define       MC_CMD_INIT_EVQ_V2_IN_DMA_ADDR_HI_OFST 40
+#define       MC_CMD_INIT_EVQ_V2_IN_DMA_ADDR_MINNUM 1
+#define       MC_CMD_INIT_EVQ_V2_IN_DMA_ADDR_MAXNUM 64
+
+/* MC_CMD_INIT_EVQ_V2_OUT msgresponse */
+#define    MC_CMD_INIT_EVQ_V2_OUT_LEN 8
+/* Only valid if INTRFLAG was true */
+#define       MC_CMD_INIT_EVQ_V2_OUT_IRQ_OFST 0
+/* Actual configuration applied on the card */
+#define       MC_CMD_INIT_EVQ_V2_OUT_FLAGS_OFST 4
+#define        MC_CMD_INIT_EVQ_V2_OUT_FLAG_CUT_THRU_LBN 0
+#define        MC_CMD_INIT_EVQ_V2_OUT_FLAG_CUT_THRU_WIDTH 1
+#define        MC_CMD_INIT_EVQ_V2_OUT_FLAG_RX_MERGE_LBN 1
+#define        MC_CMD_INIT_EVQ_V2_OUT_FLAG_RX_MERGE_WIDTH 1
+#define        MC_CMD_INIT_EVQ_V2_OUT_FLAG_TX_MERGE_LBN 2
+#define        MC_CMD_INIT_EVQ_V2_OUT_FLAG_TX_MERGE_WIDTH 1
+#define        MC_CMD_INIT_EVQ_V2_OUT_FLAG_RXQ_FORCE_EV_MERGING_LBN 3
+#define        MC_CMD_INIT_EVQ_V2_OUT_FLAG_RXQ_FORCE_EV_MERGING_WIDTH 1
+
 /* QUEUE_CRC_MODE structuredef */
 #define    QUEUE_CRC_MODE_LEN 1
 #define       QUEUE_CRC_MODE_MODE_LBN 0
@@ -5697,8 +5809,8 @@
 #define        MC_CMD_INIT_RXQ_IN_FLAG_PREFIX_WIDTH 1
 #define        MC_CMD_INIT_RXQ_IN_FLAG_DISABLE_SCATTER_LBN 9
 #define        MC_CMD_INIT_RXQ_IN_FLAG_DISABLE_SCATTER_WIDTH 1
-#define        MC_CMD_INIT_RXQ_IN_FLAG_FORCE_EV_MERGING_LBN 10
-#define        MC_CMD_INIT_RXQ_IN_FLAG_FORCE_EV_MERGING_WIDTH 1
+#define        MC_CMD_INIT_RXQ_IN_UNUSED_LBN 10
+#define        MC_CMD_INIT_RXQ_IN_UNUSED_WIDTH 1
 /* Owner ID to use if in buffer mode (zero if physical) */
 #define       MC_CMD_INIT_RXQ_IN_OWNER_ID_OFST 20
 /* The port ID associated with the v-adaptor which should contain this DMAQ. */
@@ -7854,6 +7966,20 @@
 #define        MC_CMD_GET_CAPABILITIES_V2_OUT_EVENT_CUT_THROUGH_WIDTH 1
 #define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_CUT_THROUGH_LBN 4
 #define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_CUT_THROUGH_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_VFIFO_ULL_MODE_LBN 5
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_VFIFO_ULL_MODE_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_MAC_STATS_40G_TX_SIZE_BINS_LBN 6
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_MAC_STATS_40G_TX_SIZE_BINS_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_INIT_EVQ_V2_LBN 7
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_INIT_EVQ_V2_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_MAC_TIMESTAMPING_LBN 8
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_MAC_TIMESTAMPING_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_TIMESTAMP_LBN 9
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_TIMESTAMP_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_SNIFF_LBN 10
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_SNIFF_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_SNIFF_LBN 11
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_SNIFF_WIDTH 1
 /* Number of FATSOv2 contexts per datapath supported by this NIC. Not present
  * on older firmware (check the length).
  */
@@ -7910,6 +8036,288 @@
 #define       MC_CMD_GET_CAPABILITIES_V2_OUT_SIZE_PIO_BUFF_OFST 70
 #define       MC_CMD_GET_CAPABILITIES_V2_OUT_SIZE_PIO_BUFF_LEN 2
 
+/* MC_CMD_GET_CAPABILITIES_V3_OUT msgresponse */
+#define    MC_CMD_GET_CAPABILITIES_V3_OUT_LEN 73
+/* First word of flags. */
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_FLAGS1_OFST 0
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_VPORT_RECONFIGURE_LBN 3
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_VPORT_RECONFIGURE_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_STRIPING_LBN 4
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_STRIPING_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_VADAPTOR_QUERY_LBN 5
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_VADAPTOR_QUERY_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_EVB_PORT_VLAN_RESTRICT_LBN 6
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_EVB_PORT_VLAN_RESTRICT_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_DRV_ATTACH_PREBOOT_LBN 7
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_DRV_ATTACH_PREBOOT_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_FORCE_EVENT_MERGING_LBN 8
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_FORCE_EVENT_MERGING_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_SET_MAC_ENHANCED_LBN 9
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_SET_MAC_ENHANCED_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_UNKNOWN_UCAST_DST_FILTER_ALWAYS_MULTI_RECIPIENT_LBN 10
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_UNKNOWN_UCAST_DST_FILTER_ALWAYS_MULTI_RECIPIENT_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_VADAPTOR_PERMIT_SET_MAC_WHEN_FILTERS_INSTALLED_LBN 11
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_VADAPTOR_PERMIT_SET_MAC_WHEN_FILTERS_INSTALLED_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_MAC_SECURITY_FILTERING_LBN 12
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_MAC_SECURITY_FILTERING_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_ADDITIONAL_RSS_MODES_LBN 13
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_ADDITIONAL_RSS_MODES_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_QBB_LBN 14
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_QBB_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_PACKED_STREAM_VAR_BUFFERS_LBN 15
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_PACKED_STREAM_VAR_BUFFERS_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_RSS_LIMITED_LBN 16
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_RSS_LIMITED_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_PACKED_STREAM_LBN 17
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_PACKED_STREAM_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_INCLUDE_FCS_LBN 18
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_INCLUDE_FCS_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_VLAN_INSERTION_LBN 19
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_VLAN_INSERTION_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_VLAN_STRIPPING_LBN 20
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_VLAN_STRIPPING_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_TSO_LBN 21
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_TSO_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_PREFIX_LEN_0_LBN 22
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_PREFIX_LEN_0_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_PREFIX_LEN_14_LBN 23
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_PREFIX_LEN_14_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_TIMESTAMP_LBN 24
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_TIMESTAMP_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_BATCHING_LBN 25
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_BATCHING_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_MCAST_FILTER_CHAINING_LBN 26
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_MCAST_FILTER_CHAINING_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_PM_AND_RXDP_COUNTERS_LBN 27
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_PM_AND_RXDP_COUNTERS_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_DISABLE_SCATTER_LBN 28
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_DISABLE_SCATTER_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_MCAST_UDP_LOOPBACK_LBN 29
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_MCAST_UDP_LOOPBACK_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_EVB_LBN 30
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_EVB_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_VXLAN_NVGRE_LBN 31
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_VXLAN_NVGRE_WIDTH 1
+/* RxDPCPU firmware id. */
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_RX_DPCPU_FW_ID_OFST 4
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_RX_DPCPU_FW_ID_LEN 2
+/* enum: Standard RXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXDP  0x0
+/* enum: Low latency RXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXDP_LOW_LATENCY  0x1
+/* enum: Packed stream RXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXDP_PACKED_STREAM  0x2
+/* enum: BIST RXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXDP_BIST  0x10a
+/* enum: RXDP Test firmware image 1 */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXDP_TEST_FW_TO_MC_CUT_THROUGH  0x101
+/* enum: RXDP Test firmware image 2 */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXDP_TEST_FW_TO_MC_STORE_FORWARD  0x102
+/* enum: RXDP Test firmware image 3 */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXDP_TEST_FW_TO_MC_STORE_FORWARD_FIRST  0x103
+/* enum: RXDP Test firmware image 4 */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXDP_TEST_EVERY_EVENT_BATCHABLE  0x104
+/* enum: RXDP Test firmware image 5 */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXDP_TEST_BACKPRESSURE  0x105
+/* enum: RXDP Test firmware image 6 */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXDP_TEST_FW_PACKET_EDITS  0x106
+/* enum: RXDP Test firmware image 7 */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXDP_TEST_FW_RX_HDR_SPLIT  0x107
+/* enum: RXDP Test firmware image 8 */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXDP_TEST_FW_DISABLE_DL  0x108
+/* enum: RXDP Test firmware image 9 */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXDP_TEST_FW_DOORBELL_DELAY  0x10b
+/* TxDPCPU firmware id. */
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_TX_DPCPU_FW_ID_OFST 6
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_TX_DPCPU_FW_ID_LEN 2
+/* enum: Standard TXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_TXDP  0x0
+/* enum: Low latency TXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_TXDP_LOW_LATENCY  0x1
+/* enum: High packet rate TXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_TXDP_HIGH_PACKET_RATE  0x3
+/* enum: BIST TXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_TXDP_BIST  0x12d
+/* enum: TXDP Test firmware image 1 */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_TXDP_TEST_FW_TSO_EDIT  0x101
+/* enum: TXDP Test firmware image 2 */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_TXDP_TEST_FW_PACKET_EDITS  0x102
+/* enum: TXDP CSR bus test firmware */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_TXDP_TEST_FW_CSR  0x103
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_RXPD_FW_VERSION_OFST 8
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_RXPD_FW_VERSION_LEN 2
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RXPD_FW_VERSION_REV_LBN 0
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RXPD_FW_VERSION_REV_WIDTH 12
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RXPD_FW_VERSION_TYPE_LBN 12
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RXPD_FW_VERSION_TYPE_WIDTH 4
+/* enum: reserved value - do not use (may indicate alternative interpretation
+ * of REV field in future)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXPD_FW_TYPE_RESERVED  0x0
+/* enum: Trivial RX PD firmware for early Huntington development (Huntington
+ * development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXPD_FW_TYPE_FIRST_PKT  0x1
+/* enum: RX PD firmware with approximately Siena-compatible behaviour
+ * (Huntington development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXPD_FW_TYPE_SIENA_COMPAT  0x2
+/* enum: Virtual switching (full feature) RX PD production firmware */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXPD_FW_TYPE_VSWITCH  0x3
+/* enum: siena_compat variant RX PD firmware using PM rather than MAC
+ * (Huntington development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXPD_FW_TYPE_SIENA_COMPAT_PM  0x4
+/* enum: Low latency RX PD production firmware */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXPD_FW_TYPE_LOW_LATENCY  0x5
+/* enum: Packed stream RX PD production firmware */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXPD_FW_TYPE_PACKED_STREAM  0x6
+/* enum: RX PD firmware handling layer 2 only for high packet rate performance
+ * tests (Medford development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXPD_FW_TYPE_LAYER2_PERF  0x7
+/* enum: Rules engine RX PD production firmware */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXPD_FW_TYPE_RULES_ENGINE  0x8
+/* enum: RX PD firmware for GUE parsing prototype (Medford development only) */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXPD_FW_TYPE_TESTFW_GUE_PROTOTYPE  0xe
+/* enum: RX PD firmware parsing but not filtering network overlay tunnel
+ * encapsulations (Medford development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_RXPD_FW_TYPE_TESTFW_ENCAP_PARSING_ONLY  0xf
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_TXPD_FW_VERSION_OFST 10
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_TXPD_FW_VERSION_LEN 2
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TXPD_FW_VERSION_REV_LBN 0
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TXPD_FW_VERSION_REV_WIDTH 12
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TXPD_FW_VERSION_TYPE_LBN 12
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TXPD_FW_VERSION_TYPE_WIDTH 4
+/* enum: reserved value - do not use (may indicate alternative interpretation
+ * of REV field in future)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_TXPD_FW_TYPE_RESERVED  0x0
+/* enum: Trivial TX PD firmware for early Huntington development (Huntington
+ * development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_TXPD_FW_TYPE_FIRST_PKT  0x1
+/* enum: TX PD firmware with approximately Siena-compatible behaviour
+ * (Huntington development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_TXPD_FW_TYPE_SIENA_COMPAT  0x2
+/* enum: Virtual switching (full feature) TX PD production firmware */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_TXPD_FW_TYPE_VSWITCH  0x3
+/* enum: siena_compat variant TX PD firmware using PM rather than MAC
+ * (Huntington development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_TXPD_FW_TYPE_SIENA_COMPAT_PM  0x4
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_TXPD_FW_TYPE_LOW_LATENCY  0x5 /* enum */
+/* enum: TX PD firmware handling layer 2 only for high packet rate performance
+ * tests (Medford development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_TXPD_FW_TYPE_LAYER2_PERF  0x7
+/* enum: Rules engine TX PD production firmware */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_TXPD_FW_TYPE_RULES_ENGINE  0x8
+/* enum: RX PD firmware for GUE parsing prototype (Medford development only) */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_TXPD_FW_TYPE_TESTFW_GUE_PROTOTYPE  0xe
+/* Hardware capabilities of NIC */
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_HW_CAPABILITIES_OFST 12
+/* Licensed capabilities */
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_LICENSE_CAPABILITIES_OFST 16
+/* Second word of flags. Not present on older firmware (check the length). */
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_FLAGS2_OFST 20
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_TSO_V2_LBN 0
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_TSO_V2_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_TSO_V2_ENCAP_LBN 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_TSO_V2_ENCAP_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_EVQ_TIMER_CTRL_LBN 2
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_EVQ_TIMER_CTRL_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_EVENT_CUT_THROUGH_LBN 3
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_EVENT_CUT_THROUGH_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_CUT_THROUGH_LBN 4
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_CUT_THROUGH_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_VFIFO_ULL_MODE_LBN 5
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_VFIFO_ULL_MODE_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_MAC_STATS_40G_TX_SIZE_BINS_LBN 6
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_MAC_STATS_40G_TX_SIZE_BINS_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_INIT_EVQ_V2_LBN 7
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_INIT_EVQ_V2_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_MAC_TIMESTAMPING_LBN 8
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_MAC_TIMESTAMPING_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_TIMESTAMP_LBN 9
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_TIMESTAMP_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_SNIFF_LBN 10
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_SNIFF_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_SNIFF_LBN 11
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_SNIFF_WIDTH 1
+/* Number of FATSOv2 contexts per datapath supported by this NIC. Not present
+ * on older firmware (check the length).
+ */
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_TX_TSO_V2_N_CONTEXTS_OFST 24
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_TX_TSO_V2_N_CONTEXTS_LEN 2
+/* One byte per PF containing the number of the external port assigned to this
+ * PF, indexed by PF number. Special values indicate that a PF is either not
+ * present or not assigned.
+ */
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_PFS_TO_PORTS_ASSIGNMENT_OFST 26
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_PFS_TO_PORTS_ASSIGNMENT_LEN 1
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_PFS_TO_PORTS_ASSIGNMENT_NUM 16
+/* enum: The caller is not permitted to access information on this PF. */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_ACCESS_NOT_PERMITTED  0xff
+/* enum: PF does not exist. */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_PF_NOT_PRESENT  0xfe
+/* enum: PF does exist but is not assigned to any external port. */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_PF_NOT_ASSIGNED  0xfd
+/* enum: This value indicates that PF is assigned, but it cannot be expressed
+ * in this field. It is intended for a possible future situation where a more
+ * complex scheme of PFs to ports mapping is being used. The future driver
+ * should look for a new field supporting the new scheme. The current/old
+ * driver should treat this value as PF_NOT_ASSIGNED.
+ */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_INCOMPATIBLE_ASSIGNMENT  0xfc
+/* One byte per PF containing the number of its VFs, indexed by PF number. A
+ * special value indicates that a PF is not present.
+ */
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_NUM_VFS_PER_PF_OFST 42
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_NUM_VFS_PER_PF_LEN 1
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_NUM_VFS_PER_PF_NUM 16
+/* enum: The caller is not permitted to access information on this PF. */
+/*               MC_CMD_GET_CAPABILITIES_V3_OUT_ACCESS_NOT_PERMITTED  0xff */
+/* enum: PF does not exist. */
+/*               MC_CMD_GET_CAPABILITIES_V3_OUT_PF_NOT_PRESENT  0xfe */
+/* Number of VIs available for each external port */
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_NUM_VIS_PER_PORT_OFST 58
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_NUM_VIS_PER_PORT_LEN 2
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_NUM_VIS_PER_PORT_NUM 4
+/* Size of RX descriptor cache expressed as binary logarithm The actual size
+ * equals (2 ^ RX_DESC_CACHE_SIZE)
+ */
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_RX_DESC_CACHE_SIZE_OFST 66
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_RX_DESC_CACHE_SIZE_LEN 1
+/* Size of TX descriptor cache expressed as binary logarithm The actual size
+ * equals (2 ^ TX_DESC_CACHE_SIZE)
+ */
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_TX_DESC_CACHE_SIZE_OFST 67
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_TX_DESC_CACHE_SIZE_LEN 1
+/* Total number of available PIO buffers */
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_NUM_PIO_BUFFS_OFST 68
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_NUM_PIO_BUFFS_LEN 2
+/* Size of a single PIO buffer */
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_SIZE_PIO_BUFF_OFST 70
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_SIZE_PIO_BUFF_LEN 2
+/* On chips later than Medford the amount of address space assigned to each VI
+ * is configurable. This is a global setting that the driver must query to
+ * discover the VI to address mapping. Cut-through PIO (CTPIO) in not available
+ * with 8k VI windows.
+ */
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_VI_WINDOW_MODE_OFST 72
+#define       MC_CMD_GET_CAPABILITIES_V3_OUT_VI_WINDOW_MODE_LEN 1
+/* enum: Each VI occupies 8k as on Huntington and Medford. PIO is at offset 4k.
+ * CTPIO is not mapped.
+ */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_VI_WINDOW_MODE_8K   0x0
+/* enum: Each VI occupies 16k. PIO is at offset 4k. CTPIO is at offset 12k. */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_VI_WINDOW_MODE_16K  0x1
+/* enum: Each VI occupies 64k. PIO is at offset 4k. CTPIO is at offset 12k. */
+#define          MC_CMD_GET_CAPABILITIES_V3_OUT_VI_WINDOW_MODE_64K  0x2
+
 
 /***********************************/
 /* MC_CMD_V2_EXTN
@@ -9026,7 +9434,7 @@
  */
 #define MC_CMD_GET_RXDP_CONFIG 0xc2
 
-#define MC_CMD_0xc2_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+#define MC_CMD_0xc2_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_GET_RXDP_CONFIG_IN msgrequest */
 #define    MC_CMD_GET_RXDP_CONFIG_IN_LEN 0
@@ -10125,7 +10533,9 @@
  * that this operation returns a zero-length response
  */
 #define          MC_CMD_LICENSING_V3_IN_OP_UPDATE_LICENSE  0x0
-/* enum: report counts of installed licenses */
+/* enum: report counts of installed licenses Returns EAGAIN if license
+ * processing (updating) has been started but not yet completed.
+ */
 #define          MC_CMD_LICENSING_V3_IN_OP_REPORT_LICENSE  0x1
 
 /* MC_CMD_LICENSING_V3_OUT msgresponse */
@@ -10763,6 +11173,8 @@
 #define          MC_CMD_GET_WORKAROUNDS_OUT_BUG42008 0x20
 /* enum: Bug 26807 features present in firmware (multicast filter chaining) */
 #define          MC_CMD_GET_WORKAROUNDS_OUT_BUG26807 0x40
+/* enum: Bug 61265 work around (broken EVQ TMR writes). */
+#define          MC_CMD_GET_WORKAROUNDS_OUT_BUG61265 0x80
 
 
 /***********************************/
@@ -11280,22 +11692,110 @@
 #define MC_CMD_0x118_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_RX_BALANCING_IN msgrequest */
-#define    MC_CMD_RX_BALANCING_IN_LEN 4
+#define    MC_CMD_RX_BALANCING_IN_LEN 16
 /* The RX port whose upconverter table will be modified */
 #define       MC_CMD_RX_BALANCING_IN_PORT_OFST 0
-#define       MC_CMD_RX_BALANCING_IN_PORT_LEN 1
 /* The VLAN priority associated to the table index and vFIFO */
-#define       MC_CMD_RX_BALANCING_IN_PRIORITY_OFST 1
-#define       MC_CMD_RX_BALANCING_IN_PRIORITY_LEN 1
+#define       MC_CMD_RX_BALANCING_IN_PRIORITY_OFST 4
 /* The resulting bit of SRC^DST for indexing the table */
-#define       MC_CMD_RX_BALANCING_IN_SRC_DST_OFST 2
-#define       MC_CMD_RX_BALANCING_IN_SRC_DST_LEN 1
+#define       MC_CMD_RX_BALANCING_IN_SRC_DST_OFST 8
 /* The RX engine to which the vFIFO in the table entry will point to */
-#define       MC_CMD_RX_BALANCING_IN_ENG_OFST 3
-#define       MC_CMD_RX_BALANCING_IN_ENG_LEN 1
+#define       MC_CMD_RX_BALANCING_IN_ENG_OFST 12
 
 /* MC_CMD_RX_BALANCING_OUT msgresponse */
 #define    MC_CMD_RX_BALANCING_OUT_LEN 0
 
+/***********************************/
+/* MC_CMD_SET_EVQ_TMR
+ * Update the timer load, timer reload and timer mode values for a given EVQ.
+ * The requested timer values (in TMR_LOAD_REQ_NS and TMR_RELOAD_REQ_NS) will
+ * be rounded up to the granularity supported by the hardware, then truncated
+ * to the range supported by the hardware. The resulting value after the
+ * rounding and truncation will be returned to the caller (in TMR_LOAD_ACT_NS
+ * and TMR_RELOAD_ACT_NS).
+ */
+#define MC_CMD_SET_EVQ_TMR 0x120
+
+#define MC_CMD_0x120_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_SET_EVQ_TMR_IN msgrequest */
+#define    MC_CMD_SET_EVQ_TMR_IN_LEN 16
+/* Function-relative queue instance */
+#define       MC_CMD_SET_EVQ_TMR_IN_INSTANCE_OFST 0
+/* Requested value for timer load (in nanoseconds) */
+#define       MC_CMD_SET_EVQ_TMR_IN_TMR_LOAD_REQ_NS_OFST 4
+/* Requested value for timer reload (in nanoseconds) */
+#define       MC_CMD_SET_EVQ_TMR_IN_TMR_RELOAD_REQ_NS_OFST 8
+/* Timer mode. Meanings as per EVQ_TMR_REG.TC_TIMER_VAL */
+#define       MC_CMD_SET_EVQ_TMR_IN_TMR_MODE_OFST 12
+#define          MC_CMD_SET_EVQ_TMR_IN_TIMER_MODE_DIS  0x0 /* enum */
+#define          MC_CMD_SET_EVQ_TMR_IN_TIMER_MODE_IMMED_START  0x1 /* enum */
+#define          MC_CMD_SET_EVQ_TMR_IN_TIMER_MODE_TRIG_START  0x2 /* enum */
+#define          MC_CMD_SET_EVQ_TMR_IN_TIMER_MODE_INT_HLDOFF  0x3 /* enum */
+
+/* MC_CMD_SET_EVQ_TMR_OUT msgresponse */
+#define    MC_CMD_SET_EVQ_TMR_OUT_LEN 8
+/* Actual value for timer load (in nanoseconds) */
+#define       MC_CMD_SET_EVQ_TMR_OUT_TMR_LOAD_ACT_NS_OFST 0
+/* Actual value for timer reload (in nanoseconds) */
+#define       MC_CMD_SET_EVQ_TMR_OUT_TMR_RELOAD_ACT_NS_OFST 4
+
+
+/***********************************/
+/* MC_CMD_GET_EVQ_TMR_PROPERTIES
+ * Query properties about the event queue timers.
+ */
+#define MC_CMD_GET_EVQ_TMR_PROPERTIES 0x122
+
+#define MC_CMD_0x122_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_GET_EVQ_TMR_PROPERTIES_IN msgrequest */
+#define    MC_CMD_GET_EVQ_TMR_PROPERTIES_IN_LEN 0
+
+/* MC_CMD_GET_EVQ_TMR_PROPERTIES_OUT msgresponse */
+#define    MC_CMD_GET_EVQ_TMR_PROPERTIES_OUT_LEN 36
+/* Reserved for future use. */
+#define       MC_CMD_GET_EVQ_TMR_PROPERTIES_OUT_FLAGS_OFST 0
+/* For timers updated via writes to EVQ_TMR_REG, this is the time interval (in
+ * nanoseconds) for each increment of the timer load/reload count. The
+ * requested duration of a timer is this value multiplied by the timer
+ * load/reload count.
+ */
+#define       MC_CMD_GET_EVQ_TMR_PROPERTIES_OUT_TMR_REG_NS_PER_COUNT_OFST 4
+/* For timers updated via writes to EVQ_TMR_REG, this is the maximum value
+ * allowed for timer load/reload counts.
+ */
+#define       MC_CMD_GET_EVQ_TMR_PROPERTIES_OUT_TMR_REG_MAX_COUNT_OFST 8
+/* For timers updated via writes to EVQ_TMR_REG, timer load/reload counts not a
+ * multiple of this step size will be rounded in an implementation defined
+ * manner.
+ */
+#define       MC_CMD_GET_EVQ_TMR_PROPERTIES_OUT_TMR_REG_STEP_OFST 12
+/* Maximum timer duration (in nanoseconds) for timers updated via MCDI. Only
+ * meaningful if MC_CMD_SET_EVQ_TMR is implemented.
+ */
+#define       MC_CMD_GET_EVQ_TMR_PROPERTIES_OUT_MCDI_TMR_MAX_NS_OFST 16
+/* Timer durations requested via MCDI that are not a multiple of this step size
+ * will be rounded up. Only meaningful if MC_CMD_SET_EVQ_TMR is implemented.
+ */
+#define       MC_CMD_GET_EVQ_TMR_PROPERTIES_OUT_MCDI_TMR_STEP_NS_OFST 20
+/* For timers updated using the bug35388 workaround, this is the time interval
+ * (in nanoseconds) for each increment of the timer load/reload count. The
+ * requested duration of a timer is this value multiplied by the timer
+ * load/reload count. This field is only meaningful if the bug35388 workaround
+ * is enabled.
+ */
+#define       MC_CMD_GET_EVQ_TMR_PROPERTIES_OUT_BUG35388_TMR_NS_PER_COUNT_OFST 24
+/* For timers updated using the bug35388 workaround, this is the maximum value
+ * allowed for timer load/reload counts. This field is only meaningful if the
+ * bug35388 workaround is enabled.
+ */
+#define       MC_CMD_GET_EVQ_TMR_PROPERTIES_OUT_BUG35388_TMR_MAX_COUNT_OFST 28
+/* For timers updated using the bug35388 workaround, timer load/reload counts
+ * not a multiple of this step size will be rounded in an implementation
+ * defined manner. This field is only meaningful if the bug35388 workaround is
+ * enabled.
+ */
+#define       MC_CMD_GET_EVQ_TMR_PROPERTIES_OUT_BUG35388_TMR_STEP_OFST 32
 
 #endif /* MCDI_PCOL_H */
-- 
2.7.4
