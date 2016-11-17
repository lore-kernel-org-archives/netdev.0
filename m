From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 1/5] sfc: Update MCDI protocol definitions
Date: Thu, 17 Nov 2016 10:51:30 +0000
Message-ID: <bebbc1a0-c29b-74f0-f4ab-703ea28f0d96@solarflare.com>
References: <ae6b02ca-9a0b-7072-6914-294fc9adb684@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <bkenward@solarflare.com>, <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:62659 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S2993610AbcKQKvj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 05:51:39 -0500
In-Reply-To: <ae6b02ca-9a0b-7072-6914-294fc9adb684@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_pcol.h | 483 +++++++++++++++++++++++++++++++++--
 1 file changed, 462 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index ccceafc..35cc3d4 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -276,6 +276,9 @@
 /* The clock whose frequency you've attempted to set set
  * doesn't exist on this NIC */
 #define MC_CMD_ERR_NO_CLOCK 0x1015
+/* Returned by MC_CMD_TESTASSERT if the action that should
+ * have caused an assertion failed to do so.  */
+#define MC_CMD_ERR_UNREACHABLE 0x1016
 
 #define MC_CMD_ERR_CODE_OFST 0
 
@@ -933,6 +936,8 @@
 #define        MC_CMD_COPYCODE_IN_BOOT_MAGIC_SKIP_BOOT_ICORE_SYNC_WIDTH 1
 #define        MC_CMD_COPYCODE_IN_BOOT_MAGIC_FORCE_STANDALONE_LBN 5
 #define        MC_CMD_COPYCODE_IN_BOOT_MAGIC_FORCE_STANDALONE_WIDTH 1
+#define        MC_CMD_COPYCODE_IN_BOOT_MAGIC_DISABLE_XIP_LBN 6
+#define        MC_CMD_COPYCODE_IN_BOOT_MAGIC_DISABLE_XIP_WIDTH 1
 /* Destination address */
 #define       MC_CMD_COPYCODE_IN_DEST_ADDR_OFST 4
 #define       MC_CMD_COPYCODE_IN_NUMWORDS_OFST 8
@@ -1659,6 +1664,8 @@
 #define       MC_CMD_PTP_OUT_GET_ATTRIBUTES_CAPABILITIES_OFST 8
 #define        MC_CMD_PTP_OUT_GET_ATTRIBUTES_REPORT_SYNC_STATUS_LBN 0
 #define        MC_CMD_PTP_OUT_GET_ATTRIBUTES_REPORT_SYNC_STATUS_WIDTH 1
+#define        MC_CMD_PTP_OUT_GET_ATTRIBUTES_RX_TSTAMP_OOB_LBN 1
+#define        MC_CMD_PTP_OUT_GET_ATTRIBUTES_RX_TSTAMP_OOB_WIDTH 1
 #define       MC_CMD_PTP_OUT_GET_ATTRIBUTES_RESERVED0_OFST 12
 #define       MC_CMD_PTP_OUT_GET_ATTRIBUTES_RESERVED1_OFST 16
 #define       MC_CMD_PTP_OUT_GET_ATTRIBUTES_RESERVED2_OFST 20
@@ -2211,6 +2218,10 @@
 #define          MC_CMD_FW_HIGH_TX_RATE 0x3
 /* enum: Reserved value */
 #define          MC_CMD_FW_PACKED_STREAM_HASH_MODE_1 0x4
+/* enum: Prefer to use firmware with additional "rules engine" filtering
+ * support
+ */
+#define          MC_CMD_FW_RULES_ENGINE 0x5
 /* enum: Only this option is allowed for non-admin functions */
 #define          MC_CMD_FW_DONT_CARE  0xffffffff
 
@@ -3654,12 +3665,27 @@
 
 #define MC_CMD_0x38_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
-/* MC_CMD_NVRAM_UPDATE_START_IN msgrequest */
+/* MC_CMD_NVRAM_UPDATE_START_IN msgrequest: Legacy NVRAM_UPDATE_START request.
+ * Use NVRAM_UPDATE_START_V2_IN in new code
+ */
 #define    MC_CMD_NVRAM_UPDATE_START_IN_LEN 4
 #define       MC_CMD_NVRAM_UPDATE_START_IN_TYPE_OFST 0
 /*            Enum values, see field(s): */
 /*               MC_CMD_NVRAM_TYPES/MC_CMD_NVRAM_TYPES_OUT/TYPES */
 
+/* MC_CMD_NVRAM_UPDATE_START_V2_IN msgrequest: Extended NVRAM_UPDATE_START
+ * request with additional flags indicating version of command in use. See
+ * MC_CMD_NVRAM_UPDATE_FINISH_V2_OUT for details of extended functionality. Use
+ * paired up with NVRAM_UPDATE_FINISH_V2_IN.
+ */
+#define    MC_CMD_NVRAM_UPDATE_START_V2_IN_LEN 8
+#define       MC_CMD_NVRAM_UPDATE_START_V2_IN_TYPE_OFST 0
+/*            Enum values, see field(s): */
+/*               MC_CMD_NVRAM_TYPES/MC_CMD_NVRAM_TYPES_OUT/TYPES */
+#define       MC_CMD_NVRAM_UPDATE_START_V2_IN_FLAGS_OFST 4
+#define        MC_CMD_NVRAM_UPDATE_START_V2_IN_FLAG_REPORT_VERIFY_RESULT_LBN 0
+#define        MC_CMD_NVRAM_UPDATE_START_V2_IN_FLAG_REPORT_VERIFY_RESULT_WIDTH 1
+
 /* MC_CMD_NVRAM_UPDATE_START_OUT msgresponse */
 #define    MC_CMD_NVRAM_UPDATE_START_OUT_LEN 0
 
@@ -3784,16 +3810,81 @@
 
 #define MC_CMD_0x3c_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
-/* MC_CMD_NVRAM_UPDATE_FINISH_IN msgrequest */
+/* MC_CMD_NVRAM_UPDATE_FINISH_IN msgrequest: Legacy NVRAM_UPDATE_FINISH
+ * request. Use NVRAM_UPDATE_FINISH_V2_IN in new code
+ */
 #define    MC_CMD_NVRAM_UPDATE_FINISH_IN_LEN 8
 #define       MC_CMD_NVRAM_UPDATE_FINISH_IN_TYPE_OFST 0
 /*            Enum values, see field(s): */
 /*               MC_CMD_NVRAM_TYPES/MC_CMD_NVRAM_TYPES_OUT/TYPES */
 #define       MC_CMD_NVRAM_UPDATE_FINISH_IN_REBOOT_OFST 4
 
-/* MC_CMD_NVRAM_UPDATE_FINISH_OUT msgresponse */
+/* MC_CMD_NVRAM_UPDATE_FINISH_V2_IN msgrequest: Extended NVRAM_UPDATE_FINISH
+ * request with additional flags indicating version of NVRAM_UPDATE commands in
+ * use. See MC_CMD_NVRAM_UPDATE_FINISH_V2_OUT for details of extended
+ * functionality. Use paired up with NVRAM_UPDATE_START_V2_IN.
+ */
+#define    MC_CMD_NVRAM_UPDATE_FINISH_V2_IN_LEN 12
+#define       MC_CMD_NVRAM_UPDATE_FINISH_V2_IN_TYPE_OFST 0
+/*            Enum values, see field(s): */
+/*               MC_CMD_NVRAM_TYPES/MC_CMD_NVRAM_TYPES_OUT/TYPES */
+#define       MC_CMD_NVRAM_UPDATE_FINISH_V2_IN_REBOOT_OFST 4
+#define       MC_CMD_NVRAM_UPDATE_FINISH_V2_IN_FLAGS_OFST 8
+#define        MC_CMD_NVRAM_UPDATE_FINISH_V2_IN_FLAG_REPORT_VERIFY_RESULT_LBN 0
+#define        MC_CMD_NVRAM_UPDATE_FINISH_V2_IN_FLAG_REPORT_VERIFY_RESULT_WIDTH 1
+
+/* MC_CMD_NVRAM_UPDATE_FINISH_OUT msgresponse: Legacy NVRAM_UPDATE_FINISH
+ * response. Use NVRAM_UPDATE_FINISH_V2_OUT in new code
+ */
 #define    MC_CMD_NVRAM_UPDATE_FINISH_OUT_LEN 0
 
+/* MC_CMD_NVRAM_UPDATE_FINISH_V2_OUT msgresponse:
+ *
+ * Extended NVRAM_UPDATE_FINISH response that communicates the result of secure
+ * firmware validation where applicable back to the host.
+ *
+ * Medford only: For signed firmware images, such as those for medford, the MC
+ * firmware verifies the signature before marking the firmware image as valid.
+ * This process takes a few seconds to complete. So is likely to take more than
+ * the MCDI timeout. Hence signature verification is initiated when
+ * MC_CMD_NVRAM_UPDATE_FINISH_V2_IN is received by the firmware, however, the
+ * MCDI command returns immediately with error code EAGAIN. Subsequent
+ * NVRAM_UPDATE_FINISH_V2_IN requests also return EAGAIN if the verification is
+ * in progress. Once the verification has completed, this response payload
+ * includes the results of the signature verification. Note that the nvram lock
+ * in firmware is only released after the verification has completed and the
+ * host has read back the result code from firmware.
+ */
+#define    MC_CMD_NVRAM_UPDATE_FINISH_V2_OUT_LEN 4
+/* Result of nvram update completion processing */
+#define       MC_CMD_NVRAM_UPDATE_FINISH_V2_OUT_RESULT_CODE_OFST 0
+/* enum: Verify succeeded without any errors. */
+#define          MC_CMD_NVRAM_VERIFY_RC_SUCCESS 0x1
+/* enum: CMS format verification failed due to an internal error. */
+#define          MC_CMD_NVRAM_VERIFY_RC_CMS_CHECK_FAILED 0x2
+/* enum: Invalid CMS format in image metadata. */
+#define          MC_CMD_NVRAM_VERIFY_RC_INVALID_CMS_FORMAT 0x3
+/* enum: Message digest verification failed due to an internal error. */
+#define          MC_CMD_NVRAM_VERIFY_RC_MESSAGE_DIGEST_CHECK_FAILED 0x4
+/* enum: Error in message digest calculated over the reflash-header, payload
+ * and reflash-trailer.
+ */
+#define          MC_CMD_NVRAM_VERIFY_RC_BAD_MESSAGE_DIGEST 0x5
+/* enum: Signature verification failed due to an internal error. */
+#define          MC_CMD_NVRAM_VERIFY_RC_SIGNATURE_CHECK_FAILED 0x6
+/* enum: There are no valid signatures in the image. */
+#define          MC_CMD_NVRAM_VERIFY_RC_NO_VALID_SIGNATURES 0x7
+/* enum: Trusted approvers verification failed due to an internal error. */
+#define          MC_CMD_NVRAM_VERIFY_RC_TRUSTED_APPROVERS_CHECK_FAILED 0x8
+/* enum: The Trusted approver's list is empty. */
+#define          MC_CMD_NVRAM_VERIFY_RC_NO_TRUSTED_APPROVERS 0x9
+/* enum: Signature chain verification failed due to an internal error. */
+#define          MC_CMD_NVRAM_VERIFY_RC_SIGNATURE_CHAIN_CHECK_FAILED 0xa
+/* enum: The signers of the signatures in the image are not listed in the
+ * Trusted approver's list.
+ */
+#define          MC_CMD_NVRAM_VERIFY_RC_NO_SIGNATURE_MATCH 0xb
+
 
 /***********************************/
 /* MC_CMD_REBOOT
@@ -4356,6 +4447,28 @@
 /* MC_CMD_TESTASSERT_OUT msgresponse */
 #define    MC_CMD_TESTASSERT_OUT_LEN 0
 
+/* MC_CMD_TESTASSERT_V2_IN msgrequest */
+#define    MC_CMD_TESTASSERT_V2_IN_LEN 4
+/* How to provoke the assertion */
+#define       MC_CMD_TESTASSERT_V2_IN_TYPE_OFST 0
+/* enum: Assert using the FAIL_ASSERTION_WITH_USEFUL_VALUES macro. Unless
+ * you're testing firmware, this is what you want.
+ */
+#define          MC_CMD_TESTASSERT_V2_IN_FAIL_ASSERTION_WITH_USEFUL_VALUES  0x0
+/* enum: Assert using assert(0); */
+#define          MC_CMD_TESTASSERT_V2_IN_ASSERT_FALSE  0x1
+/* enum: Deliberately trigger a watchdog */
+#define          MC_CMD_TESTASSERT_V2_IN_WATCHDOG  0x2
+/* enum: Deliberately trigger a trap by loading from an invalid address */
+#define          MC_CMD_TESTASSERT_V2_IN_LOAD_TRAP  0x3
+/* enum: Deliberately trigger a trap by storing to an invalid address */
+#define          MC_CMD_TESTASSERT_V2_IN_STORE_TRAP  0x4
+/* enum: Jump to an invalid address */
+#define          MC_CMD_TESTASSERT_V2_IN_JUMP_TRAP  0x5
+
+/* MC_CMD_TESTASSERT_V2_OUT msgresponse */
+#define    MC_CMD_TESTASSERT_V2_OUT_LEN 0
+
 
 /***********************************/
 /* MC_CMD_WORKAROUND
@@ -4421,6 +4534,7 @@
  * (GET_PHY_CFG_OUT_MEDIA_TYPE); the valid 'page number' input values, and the
  * output data, are interpreted on a per-type basis. For SFP+: PAGE=0 or 1
  * returns a 128-byte block read from module I2C address 0xA0 offset 0 or 0x80.
+ * Anything else: currently undefined. Locks required: None. Return code: 0.
  */
 #define MC_CMD_GET_PHY_MEDIA_INFO 0x4b
 
@@ -5362,12 +5476,14 @@
 #define          NVRAM_PARTITION_TYPE_EXPANSION_UEFI       0xd00
 /* enum: Spare partition 0 */
 #define          NVRAM_PARTITION_TYPE_SPARE_0              0x1000
-/* enum: Spare partition 1 */
-#define          NVRAM_PARTITION_TYPE_SPARE_1              0x1100
+/* enum: Used for XIP code of shmbooted images */
+#define          NVRAM_PARTITION_TYPE_XIP_SCRATCH          0x1100
 /* enum: Spare partition 2 */
 #define          NVRAM_PARTITION_TYPE_SPARE_2              0x1200
-/* enum: Spare partition 3 */
-#define          NVRAM_PARTITION_TYPE_SPARE_3              0x1300
+/* enum: Manufacturing partition. Used during manufacture to pass information
+ * between XJTAG and Manftest.
+ */
+#define          NVRAM_PARTITION_TYPE_MANUFACTURING        0x1300
 /* enum: Spare partition 4 */
 #define          NVRAM_PARTITION_TYPE_SPARE_4              0x1400
 /* enum: Spare partition 5 */
@@ -5402,6 +5518,14 @@
 #define          LICENSED_APP_ID_CAPTURE_SOLARSYSTEM     0x40
 /* enum: Network Access Control */
 #define          LICENSED_APP_ID_NETWORK_ACCESS_CONTROL  0x80
+/* enum: TCP Direct */
+#define          LICENSED_APP_ID_TCP_DIRECT              0x100
+/* enum: Low Latency */
+#define          LICENSED_APP_ID_LOW_LATENCY             0x200
+/* enum: SolarCapture Tap */
+#define          LICENSED_APP_ID_SOLARCAPTURE_TAP        0x400
+/* enum: Capture SolarSystem 40G */
+#define          LICENSED_APP_ID_CAPTURE_SOLARSYSTEM_40G 0x800
 #define       LICENSED_APP_ID_ID_LBN 0
 #define       LICENSED_APP_ID_ID_WIDTH 32
 
@@ -5458,6 +5582,14 @@
 #define        LICENSED_V3_APPS_CAPTURE_SOLARSYSTEM_WIDTH 1
 #define        LICENSED_V3_APPS_NETWORK_ACCESS_CONTROL_LBN 7
 #define        LICENSED_V3_APPS_NETWORK_ACCESS_CONTROL_WIDTH 1
+#define        LICENSED_V3_APPS_TCP_DIRECT_LBN 8
+#define        LICENSED_V3_APPS_TCP_DIRECT_WIDTH 1
+#define        LICENSED_V3_APPS_LOW_LATENCY_LBN 9
+#define        LICENSED_V3_APPS_LOW_LATENCY_WIDTH 1
+#define        LICENSED_V3_APPS_SOLARCAPTURE_TAP_LBN 10
+#define        LICENSED_V3_APPS_SOLARCAPTURE_TAP_WIDTH 1
+#define        LICENSED_V3_APPS_CAPTURE_SOLARSYSTEM_40G_LBN 11
+#define        LICENSED_V3_APPS_CAPTURE_SOLARSYSTEM_40G_WIDTH 1
 #define       LICENSED_V3_APPS_MASK_LBN 0
 #define       LICENSED_V3_APPS_MASK_WIDTH 64
 
@@ -5988,6 +6120,8 @@
 #define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_INNER_TCP_CSUM_EN_WIDTH 1
 #define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_TSOV2_EN_LBN 12
 #define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_TSOV2_EN_WIDTH 1
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_CTPIO_LBN 13
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_CTPIO_WIDTH 1
 /* Owner ID to use if in buffer mode (zero if physical) */
 #define       MC_CMD_INIT_TXQ_EXT_IN_OWNER_ID_OFST 20
 /* The port ID associated with the v-adaptor which should contain this DMAQ. */
@@ -7728,6 +7862,8 @@
  * tests (Medford development only)
  */
 #define          MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_TYPE_LAYER2_PERF  0x7
+/* enum: Rules engine RX PD production firmware */
+#define          MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_TYPE_RULES_ENGINE  0x8
 /* enum: RX PD firmware for GUE parsing prototype (Medford development only) */
 #define          MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_TYPE_TESTFW_GUE_PROTOTYPE  0xe
 /* enum: RX PD firmware parsing but not filtering network overlay tunnel
@@ -7763,6 +7899,8 @@
  * tests (Medford development only)
  */
 #define          MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_TYPE_LAYER2_PERF  0x7
+/* enum: Rules engine TX PD production firmware */
+#define          MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_TYPE_RULES_ENGINE  0x8
 /* enum: RX PD firmware for GUE parsing prototype (Medford development only) */
 #define          MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_TYPE_TESTFW_GUE_PROTOTYPE  0xe
 /* Hardware capabilities of NIC */
@@ -7913,6 +8051,8 @@
  * tests (Medford development only)
  */
 #define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_TYPE_LAYER2_PERF  0x7
+/* enum: Rules engine RX PD production firmware */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_TYPE_RULES_ENGINE  0x8
 /* enum: RX PD firmware for GUE parsing prototype (Medford development only) */
 #define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_TYPE_TESTFW_GUE_PROTOTYPE  0xe
 /* enum: RX PD firmware parsing but not filtering network overlay tunnel
@@ -7948,6 +8088,8 @@
  * tests (Medford development only)
  */
 #define          MC_CMD_GET_CAPABILITIES_V2_OUT_TXPD_FW_TYPE_LAYER2_PERF  0x7
+/* enum: Rules engine TX PD production firmware */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_TXPD_FW_TYPE_RULES_ENGINE  0x8
 /* enum: RX PD firmware for GUE parsing prototype (Medford development only) */
 #define          MC_CMD_GET_CAPABILITIES_V2_OUT_TXPD_FW_TYPE_TESTFW_GUE_PROTOTYPE  0xe
 /* Hardware capabilities of NIC */
@@ -7980,6 +8122,8 @@
 #define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_SNIFF_WIDTH 1
 #define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_SNIFF_LBN 11
 #define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_SNIFF_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_NVRAM_UPDATE_REPORT_VERIFY_RESULT_LBN 12
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_NVRAM_UPDATE_REPORT_VERIFY_RESULT_WIDTH 1
 /* Number of FATSOv2 contexts per datapath supported by this NIC. Not present
  * on older firmware (check the length).
  */
@@ -8247,6 +8391,8 @@
 #define        MC_CMD_GET_CAPABILITIES_V3_OUT_RX_SNIFF_WIDTH 1
 #define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_SNIFF_LBN 11
 #define        MC_CMD_GET_CAPABILITIES_V3_OUT_TX_SNIFF_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_NVRAM_UPDATE_REPORT_VERIFY_RESULT_LBN 12
+#define        MC_CMD_GET_CAPABILITIES_V3_OUT_NVRAM_UPDATE_REPORT_VERIFY_RESULT_WIDTH 1
 /* Number of FATSOv2 contexts per datapath supported by this NIC. Not present
  * on older firmware (check the length).
  */
@@ -8304,7 +8450,7 @@
 #define       MC_CMD_GET_CAPABILITIES_V3_OUT_SIZE_PIO_BUFF_LEN 2
 /* On chips later than Medford the amount of address space assigned to each VI
  * is configurable. This is a global setting that the driver must query to
- * discover the VI to address mapping. Cut-through PIO (CTPIO) in not available
+ * discover the VI to address mapping. Cut-through PIO (CTPIO) is not available
  * with 8k VI windows.
  */
 #define       MC_CMD_GET_CAPABILITIES_V3_OUT_VI_WINDOW_MODE_OFST 72
@@ -10283,6 +10429,8 @@
  * more data is returned.
  */
 #define          MC_CMD_PCIE_TUNE_IN_POLL_EYE_PLOT  0x6
+/* enum: Enable the SERDES BIST and set it to generate a 200MHz square wave */
+#define          MC_CMD_PCIE_TUNE_IN_BIST_SQUARE_WAVE  0x7
 /* Align the arguments to 32 bits */
 #define       MC_CMD_PCIE_TUNE_IN_PCIE_TUNE_RSVD_OFST 1
 #define       MC_CMD_PCIE_TUNE_IN_PCIE_TUNE_RSVD_LEN 3
@@ -10468,6 +10616,12 @@
 #define       MC_CMD_PCIE_TUNE_POLL_EYE_PLOT_OUT_SAMPLES_MINNUM 0
 #define       MC_CMD_PCIE_TUNE_POLL_EYE_PLOT_OUT_SAMPLES_MAXNUM 126
 
+/* MC_CMD_PCIE_TUNE_BIST_SQUARE_WAVE_IN msgrequest */
+#define    MC_CMD_PCIE_TUNE_BIST_SQUARE_WAVE_IN_LEN 0
+
+/* MC_CMD_PCIE_TUNE_BIST_SQUARE_WAVE_OUT msgrequest */
+#define    MC_CMD_PCIE_TUNE_BIST_SQUARE_WAVE_OUT_LEN 0
+
 
 /***********************************/
 /* MC_CMD_LICENSING
@@ -10783,29 +10937,45 @@
 #define MC_CMD_0xd4_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_LICENSED_V3_VALIDATE_APP_IN msgrequest */
-#define    MC_CMD_LICENSED_V3_VALIDATE_APP_IN_LEN 72
+#define    MC_CMD_LICENSED_V3_VALIDATE_APP_IN_LEN 56
+/* challenge for validation (384 bits) */
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_IN_CHALLENGE_OFST 0
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_IN_CHALLENGE_LEN 48
 /* application ID expressed as a single bit mask */
-#define       MC_CMD_LICENSED_V3_VALIDATE_APP_IN_APP_ID_OFST 0
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_IN_APP_ID_OFST 48
 #define       MC_CMD_LICENSED_V3_VALIDATE_APP_IN_APP_ID_LEN 8
-#define       MC_CMD_LICENSED_V3_VALIDATE_APP_IN_APP_ID_LO_OFST 0
-#define       MC_CMD_LICENSED_V3_VALIDATE_APP_IN_APP_ID_HI_OFST 4
-/* challenge for validation */
-#define       MC_CMD_LICENSED_V3_VALIDATE_APP_IN_CHALLENGE_OFST 8
-#define       MC_CMD_LICENSED_V3_VALIDATE_APP_IN_CHALLENGE_LEN 64
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_IN_APP_ID_LO_OFST 48
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_IN_APP_ID_HI_OFST 52
 
 /* MC_CMD_LICENSED_V3_VALIDATE_APP_OUT msgresponse */
-#define    MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_LEN 72
+#define    MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_LEN 116
+/* validation response to challenge in the form of ECDSA signature consisting
+ * of two 384-bit integers, r and s, in big-endian order. The signature signs a
+ * SHA-384 digest of a message constructed from the concatenation of the input
+ * message and the remaining fields of this output message, e.g. challenge[48
+ * bytes] ... expiry_time[4 bytes] ...
+ */
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_RESPONSE_OFST 0
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_RESPONSE_LEN 96
 /* application expiry time */
-#define       MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_EXPIRY_TIME_OFST 0
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_EXPIRY_TIME_OFST 96
 /* application expiry units */
-#define       MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_EXPIRY_UNITS_OFST 4
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_EXPIRY_UNITS_OFST 100
 /* enum: expiry units are accounting units */
 #define          MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_EXPIRY_UNIT_ACC  0x0
 /* enum: expiry units are calendar days */
 #define          MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_EXPIRY_UNIT_DAYS  0x1
-/* validation response to challenge */
-#define       MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_RESPONSE_OFST 8
-#define       MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_RESPONSE_LEN 64
+/* base MAC address of the NIC stored in NVRAM (note that this is a constant
+ * value for a given NIC regardless which function is calling, effectively this
+ * is PF0 base MAC address)
+ */
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_BASE_MACADDR_OFST 104
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_BASE_MACADDR_LEN 6
+/* MAC address of v-adaptor associated with the client. If no such v-adapator
+ * exists, then the field is filled with 0xFF.
+ */
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_VADAPTOR_MACADDR_OFST 110
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_VADAPTOR_MACADDR_LEN 6
 
 
 /***********************************/
@@ -10835,6 +11005,70 @@
 
 
 /***********************************/
+/* MC_CMD_LICENSING_V3_TEMPORARY
+ * Perform operations to support installation of a single temporary license in
+ * the adapter, in addition to those found in the licensing partition. See
+ * SF-116124-SW for an overview of how this could be used. The license is
+ * stored in MC persistent data and so will survive a MC reboot, but will be
+ * erased when the adapter is power cycled
+ */
+#define MC_CMD_LICENSING_V3_TEMPORARY 0xd6
+
+#define MC_CMD_0xd6_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_LICENSING_V3_TEMPORARY_IN msgrequest */
+#define    MC_CMD_LICENSING_V3_TEMPORARY_IN_LEN 4
+/* operation code */
+#define       MC_CMD_LICENSING_V3_TEMPORARY_IN_OP_OFST 0
+/* enum: install a new license, overwriting any existing temporary license.
+ * This is an asynchronous operation owing to the time taken to validate an
+ * ECDSA license
+ */
+#define          MC_CMD_LICENSING_V3_TEMPORARY_SET  0x0
+/* enum: clear the license immediately rather than waiting for the next power
+ * cycle
+ */
+#define          MC_CMD_LICENSING_V3_TEMPORARY_CLEAR  0x1
+/* enum: get the status of the asynchronous MC_CMD_LICENSING_V3_TEMPORARY_SET
+ * operation
+ */
+#define          MC_CMD_LICENSING_V3_TEMPORARY_STATUS  0x2
+
+/* MC_CMD_LICENSING_V3_TEMPORARY_IN_SET msgrequest */
+#define    MC_CMD_LICENSING_V3_TEMPORARY_IN_SET_LEN 164
+#define       MC_CMD_LICENSING_V3_TEMPORARY_IN_SET_OP_OFST 0
+/* ECDSA license and signature */
+#define       MC_CMD_LICENSING_V3_TEMPORARY_IN_SET_LICENSE_OFST 4
+#define       MC_CMD_LICENSING_V3_TEMPORARY_IN_SET_LICENSE_LEN 160
+
+/* MC_CMD_LICENSING_V3_TEMPORARY_IN_CLEAR msgrequest */
+#define    MC_CMD_LICENSING_V3_TEMPORARY_IN_CLEAR_LEN 4
+#define       MC_CMD_LICENSING_V3_TEMPORARY_IN_CLEAR_OP_OFST 0
+
+/* MC_CMD_LICENSING_V3_TEMPORARY_IN_STATUS msgrequest */
+#define    MC_CMD_LICENSING_V3_TEMPORARY_IN_STATUS_LEN 4
+#define       MC_CMD_LICENSING_V3_TEMPORARY_IN_STATUS_OP_OFST 0
+
+/* MC_CMD_LICENSING_V3_TEMPORARY_OUT_STATUS msgresponse */
+#define    MC_CMD_LICENSING_V3_TEMPORARY_OUT_STATUS_LEN 12
+/* status code */
+#define       MC_CMD_LICENSING_V3_TEMPORARY_OUT_STATUS_STATUS_OFST 0
+/* enum: finished validating and installing license */
+#define          MC_CMD_LICENSING_V3_TEMPORARY_STATUS_OK  0x0
+/* enum: license validation and installation in progress */
+#define          MC_CMD_LICENSING_V3_TEMPORARY_STATUS_IN_PROGRESS  0x1
+/* enum: licensing error. More specific error messages are not provided to
+ * avoid exposing details of the licensing system to the client
+ */
+#define          MC_CMD_LICENSING_V3_TEMPORARY_STATUS_ERROR  0x2
+/* bitmask of licensed features */
+#define       MC_CMD_LICENSING_V3_TEMPORARY_OUT_STATUS_LICENSED_FEATURES_OFST 4
+#define       MC_CMD_LICENSING_V3_TEMPORARY_OUT_STATUS_LICENSED_FEATURES_LEN 8
+#define       MC_CMD_LICENSING_V3_TEMPORARY_OUT_STATUS_LICENSED_FEATURES_LO_OFST 4
+#define       MC_CMD_LICENSING_V3_TEMPORARY_OUT_STATUS_LICENSED_FEATURES_HI_OFST 8
+
+
+/***********************************/
 /* MC_CMD_SET_PORT_SNIFF_CONFIG
  * Configure RX port sniffing for the physical port associated with the calling
  * function. Only a privileged function may change the port sniffing
@@ -11705,6 +11939,66 @@
 /* MC_CMD_RX_BALANCING_OUT msgresponse */
 #define    MC_CMD_RX_BALANCING_OUT_LEN 0
 
+
+/***********************************/
+/* MC_CMD_NVRAM_PRIVATE_APPEND
+ * Append a single TLV to the MC_USAGE_TLV partition. Returns MC_CMD_ERR_EEXIST
+ * if the tag is already present.
+ */
+#define MC_CMD_NVRAM_PRIVATE_APPEND 0x11c
+
+#define MC_CMD_0x11c_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_NVRAM_PRIVATE_APPEND_IN msgrequest */
+#define    MC_CMD_NVRAM_PRIVATE_APPEND_IN_LENMIN 9
+#define    MC_CMD_NVRAM_PRIVATE_APPEND_IN_LENMAX 252
+#define    MC_CMD_NVRAM_PRIVATE_APPEND_IN_LEN(num) (8+1*(num))
+/* The tag to be appended */
+#define       MC_CMD_NVRAM_PRIVATE_APPEND_IN_TAG_OFST 0
+/* The length of the data */
+#define       MC_CMD_NVRAM_PRIVATE_APPEND_IN_LENGTH_OFST 4
+/* The data to be contained in the TLV structure */
+#define       MC_CMD_NVRAM_PRIVATE_APPEND_IN_DATA_BUFFER_OFST 8
+#define       MC_CMD_NVRAM_PRIVATE_APPEND_IN_DATA_BUFFER_LEN 1
+#define       MC_CMD_NVRAM_PRIVATE_APPEND_IN_DATA_BUFFER_MINNUM 1
+#define       MC_CMD_NVRAM_PRIVATE_APPEND_IN_DATA_BUFFER_MAXNUM 244
+
+/* MC_CMD_NVRAM_PRIVATE_APPEND_OUT msgresponse */
+#define    MC_CMD_NVRAM_PRIVATE_APPEND_OUT_LEN 0
+
+
+/***********************************/
+/* MC_CMD_XPM_VERIFY_CONTENTS
+ * Verify that the contents of the XPM memory is correct (Medford only). This
+ * is used during manufacture to check that the XPM memory has been programmed
+ * correctly at ATE.
+ */
+#define MC_CMD_XPM_VERIFY_CONTENTS 0x11b
+
+#define MC_CMD_0x11b_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_XPM_VERIFY_CONTENTS_IN msgrequest */
+#define    MC_CMD_XPM_VERIFY_CONTENTS_IN_LEN 4
+/* Data type to be checked */
+#define       MC_CMD_XPM_VERIFY_CONTENTS_IN_DATA_TYPE_OFST 0
+
+/* MC_CMD_XPM_VERIFY_CONTENTS_OUT msgresponse */
+#define    MC_CMD_XPM_VERIFY_CONTENTS_OUT_LENMIN 12
+#define    MC_CMD_XPM_VERIFY_CONTENTS_OUT_LENMAX 252
+#define    MC_CMD_XPM_VERIFY_CONTENTS_OUT_LEN(num) (12+1*(num))
+/* Number of sectors found (test builds only) */
+#define       MC_CMD_XPM_VERIFY_CONTENTS_OUT_NUM_SECTORS_OFST 0
+/* Number of bytes found (test builds only) */
+#define       MC_CMD_XPM_VERIFY_CONTENTS_OUT_NUM_BYTES_OFST 4
+/* Length of signature */
+#define       MC_CMD_XPM_VERIFY_CONTENTS_OUT_SIG_LENGTH_OFST 8
+/* Signature */
+#define       MC_CMD_XPM_VERIFY_CONTENTS_OUT_SIGNATURE_OFST 12
+#define       MC_CMD_XPM_VERIFY_CONTENTS_OUT_SIGNATURE_LEN 1
+#define       MC_CMD_XPM_VERIFY_CONTENTS_OUT_SIGNATURE_MINNUM 0
+#define       MC_CMD_XPM_VERIFY_CONTENTS_OUT_SIGNATURE_MAXNUM 240
+
+
 /***********************************/
 /* MC_CMD_SET_EVQ_TMR
  * Update the timer load, timer reload and timer mode values for a given EVQ.
@@ -11798,4 +12092,151 @@
  */
 #define       MC_CMD_GET_EVQ_TMR_PROPERTIES_OUT_BUG35388_TMR_STEP_OFST 32
 
+
+/***********************************/
+/* MC_CMD_ALLOCATE_TX_VFIFO_CP
+ * When we use the TX_vFIFO_ULL mode, we can allocate common pools using the
+ * non used switch buffers.
+ */
+#define MC_CMD_ALLOCATE_TX_VFIFO_CP 0x11d
+
+#define MC_CMD_0x11d_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_ALLOCATE_TX_VFIFO_CP_IN msgrequest */
+#define    MC_CMD_ALLOCATE_TX_VFIFO_CP_IN_LEN 20
+/* Desired instance. Must be set to a specific instance, which is a function
+ * local queue index.
+ */
+#define       MC_CMD_ALLOCATE_TX_VFIFO_CP_IN_INSTANCE_OFST 0
+/* Will the common pool be used as TX_vFIFO_ULL (1) */
+#define       MC_CMD_ALLOCATE_TX_VFIFO_CP_IN_MODE_OFST 4
+#define          MC_CMD_ALLOCATE_TX_VFIFO_CP_IN_ENABLED       0x1 /* enum */
+/* enum: Using this interface without TX_vFIFO_ULL is not supported for now */
+#define          MC_CMD_ALLOCATE_TX_VFIFO_CP_IN_DISABLED      0x0
+/* Number of buffers to reserve for the common pool */
+#define       MC_CMD_ALLOCATE_TX_VFIFO_CP_IN_SIZE_OFST 8
+/* TX datapath to which the Common Pool is connected to. */
+#define       MC_CMD_ALLOCATE_TX_VFIFO_CP_IN_INGRESS_OFST 12
+/* enum: Extracts information from function */
+#define          MC_CMD_ALLOCATE_TX_VFIFO_CP_IN_USE_FUNCTION_VALUE          -0x1
+/* Network port or RX Engine to which the common pool connects. */
+#define       MC_CMD_ALLOCATE_TX_VFIFO_CP_IN_EGRESS_OFST 16
+/* enum: Extracts information from function */
+/*               MC_CMD_ALLOCATE_TX_VFIFO_CP_IN_USE_FUNCTION_VALUE          -0x1 */
+#define          MC_CMD_ALLOCATE_TX_VFIFO_CP_IN_PORT0          0x0 /* enum */
+#define          MC_CMD_ALLOCATE_TX_VFIFO_CP_IN_PORT1          0x1 /* enum */
+#define          MC_CMD_ALLOCATE_TX_VFIFO_CP_IN_PORT2          0x2 /* enum */
+#define          MC_CMD_ALLOCATE_TX_VFIFO_CP_IN_PORT3          0x3 /* enum */
+/* enum: To enable Switch loopback with Rx engine 0 */
+#define          MC_CMD_ALLOCATE_TX_VFIFO_CP_IN_RX_ENGINE0     0x4
+/* enum: To enable Switch loopback with Rx engine 1 */
+#define          MC_CMD_ALLOCATE_TX_VFIFO_CP_IN_RX_ENGINE1     0x5
+
+/* MC_CMD_ALLOCATE_TX_VFIFO_CP_OUT msgresponse */
+#define    MC_CMD_ALLOCATE_TX_VFIFO_CP_OUT_LEN 4
+/* ID of the common pool allocated */
+#define       MC_CMD_ALLOCATE_TX_VFIFO_CP_OUT_CP_ID_OFST 0
+
+
+/***********************************/
+/* MC_CMD_ALLOCATE_TX_VFIFO_VFIFO
+ * When we use the TX_vFIFO_ULL mode, we can allocate vFIFOs using the
+ * previously allocated common pools.
+ */
+#define MC_CMD_ALLOCATE_TX_VFIFO_VFIFO 0x11e
+
+#define MC_CMD_0x11e_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_IN msgrequest */
+#define    MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_IN_LEN 20
+/* Common pool previously allocated to which the new vFIFO will be associated
+ */
+#define       MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_IN_CP_OFST 0
+/* Port or RX engine to associate the vFIFO egress */
+#define       MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_IN_EGRESS_OFST 4
+/* enum: Extracts information from common pool */
+#define          MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_IN_USE_CP_VALUE   -0x1
+#define          MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_IN_PORT0          0x0 /* enum */
+#define          MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_IN_PORT1          0x1 /* enum */
+#define          MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_IN_PORT2          0x2 /* enum */
+#define          MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_IN_PORT3          0x3 /* enum */
+/* enum: To enable Switch loopback with Rx engine 0 */
+#define          MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_IN_RX_ENGINE0     0x4
+/* enum: To enable Switch loopback with Rx engine 1 */
+#define          MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_IN_RX_ENGINE1     0x5
+/* Minimum number of buffers that the pool must have */
+#define       MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_IN_SIZE_OFST 8
+/* enum: Do not check the space available */
+#define          MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_IN_NO_MINIMUM     0x0
+/* Will the vFIFO be used as TX_vFIFO_ULL */
+#define       MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_IN_MODE_OFST 12
+/* Network priority of the vFIFO,if applicable */
+#define       MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_IN_PRIORITY_OFST 16
+/* enum: Search for the lowest unused priority */
+#define          MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_IN_LOWEST_AVAILABLE  -0x1
+
+/* MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_OUT msgresponse */
+#define    MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_OUT_LEN 8
+/* Short vFIFO ID */
+#define       MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_OUT_VID_OFST 0
+/* Network priority of the vFIFO */
+#define       MC_CMD_ALLOCATE_TX_VFIFO_VFIFO_OUT_PRIORITY_OFST 4
+
+
+/***********************************/
+/* MC_CMD_TEARDOWN_TX_VFIFO_VF
+ * This interface clears the configuration of the given vFIFO and leaves it
+ * ready to be re-used.
+ */
+#define MC_CMD_TEARDOWN_TX_VFIFO_VF 0x11f
+
+#define MC_CMD_0x11f_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_TEARDOWN_TX_VFIFO_VF_IN msgrequest */
+#define    MC_CMD_TEARDOWN_TX_VFIFO_VF_IN_LEN 4
+/* Short vFIFO ID */
+#define       MC_CMD_TEARDOWN_TX_VFIFO_VF_IN_VFIFO_OFST 0
+
+/* MC_CMD_TEARDOWN_TX_VFIFO_VF_OUT msgresponse */
+#define    MC_CMD_TEARDOWN_TX_VFIFO_VF_OUT_LEN 0
+
+
+/***********************************/
+/* MC_CMD_DEALLOCATE_TX_VFIFO_CP
+ * This interface clears the configuration of the given common pool and leaves
+ * it ready to be re-used.
+ */
+#define MC_CMD_DEALLOCATE_TX_VFIFO_CP 0x121
+
+#define MC_CMD_0x121_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_DEALLOCATE_TX_VFIFO_CP_IN msgrequest */
+#define    MC_CMD_DEALLOCATE_TX_VFIFO_CP_IN_LEN 4
+/* Common pool ID given when pool allocated */
+#define       MC_CMD_DEALLOCATE_TX_VFIFO_CP_IN_POOL_ID_OFST 0
+
+/* MC_CMD_DEALLOCATE_TX_VFIFO_CP_OUT msgresponse */
+#define    MC_CMD_DEALLOCATE_TX_VFIFO_CP_OUT_LEN 0
+
+
+/***********************************/
+/* MC_CMD_SWITCH_GET_UNASSIGNED_BUFFERS
+ * This interface allows the host to find out how many common pool buffers are
+ * not yet assigned.
+ */
+#define MC_CMD_SWITCH_GET_UNASSIGNED_BUFFERS 0x124
+
+#define MC_CMD_0x124_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_SWITCH_GET_UNASSIGNED_BUFFERS_IN msgrequest */
+#define    MC_CMD_SWITCH_GET_UNASSIGNED_BUFFERS_IN_LEN 0
+
+/* MC_CMD_SWITCH_GET_UNASSIGNED_BUFFERS_OUT msgresponse */
+#define    MC_CMD_SWITCH_GET_UNASSIGNED_BUFFERS_OUT_LEN 8
+/* Available buffers for the ENG to NET vFIFOs. */
+#define       MC_CMD_SWITCH_GET_UNASSIGNED_BUFFERS_OUT_NET_OFST 0
+/* Available buffers for the ENG to ENG and NET to ENG vFIFOs. */
+#define       MC_CMD_SWITCH_GET_UNASSIGNED_BUFFERS_OUT_ENG_OFST 4
+
+
 #endif /* MCDI_PCOL_H */
