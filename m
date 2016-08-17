From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv3 net-next 2/4] cxgb4: Register changes and fw defines for crypto
Date: Wed, 17 Aug 2016 12:33:04 +0530
Message-ID: <1471417386-14026-3-git-send-email-hariprasad@chelsio.com>
References: <1471417386-14026-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	atul.gupta@chelsio.com, yeshaswi@chelsio.com, jlulla@chelsio.com,
	harsh@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:65087 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753767AbcHQHEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 03:04:23 -0400
In-Reply-To: <1471417386-14026-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Atul Gupta <atul.gupta@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h   |  437 +++++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h |  124 +++++++
 2 files changed, 561 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 4705e2d..7a2be51 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -61,6 +61,7 @@ enum {
 	CPL_ABORT_REQ_RSS     = 0x2B,
 	CPL_ABORT_RPL_RSS     = 0x2D,
 
+	CPL_RX_PHYS_ADDR      = 0x30,
 	CPL_CLOSE_CON_RPL     = 0x32,
 	CPL_ISCSI_HDR         = 0x33,
 	CPL_RDMA_CQE          = 0x35,
@@ -83,6 +84,10 @@ enum {
 	CPL_PASS_OPEN_REQ6    = 0x81,
 	CPL_ACT_OPEN_REQ6     = 0x83,
 
+	CPL_TX_TLS_PDU     =    0x88,
+	CPL_TX_SEC_PDU        = 0x8A,
+	CPL_TX_TLS_ACK        = 0x8B,
+
 	CPL_RDMA_TERMINATE    = 0xA2,
 	CPL_RDMA_WRITE        = 0xA4,
 	CPL_SGE_EGR_UPDATE    = 0xA5,
@@ -94,6 +99,8 @@ enum {
 	CPL_FW4_PLD           = 0xC1,
 	CPL_FW4_ACK           = 0xC3,
 
+	CPL_RX_PHYS_DSGL      = 0xD0,
+
 	CPL_FW6_MSG           = 0xE0,
 	CPL_FW6_PLD           = 0xE1,
 	CPL_TX_PKT_LSO        = 0xED,
@@ -1360,6 +1367,15 @@ struct ulptx_idata {
 	__be32 len;
 };
 
+struct ulp_txpkt {
+	__be32 cmd_dest;
+	__be32 len;
+};
+
+#define ULPTX_CMD_S    24
+#define ULPTX_CMD_M    0xFF
+#define ULPTX_CMD_V(x) ((x) << ULPTX_CMD_S)
+
 #define ULPTX_NSGE_S    0
 #define ULPTX_NSGE_V(x) ((x) << ULPTX_NSGE_S)
 
@@ -1367,6 +1383,22 @@ struct ulptx_idata {
 #define ULPTX_MORE_V(x)	((x) << ULPTX_MORE_S)
 #define ULPTX_MORE_F	ULPTX_MORE_V(1U)
 
+#define ULP_TXPKT_DEST_S    16
+#define ULP_TXPKT_DEST_M    0x3
+#define ULP_TXPKT_DEST_V(x) ((x) << ULP_TXPKT_DEST_S)
+
+#define ULP_TXPKT_FID_S     4
+#define ULP_TXPKT_FID_M     0x7ff
+#define ULP_TXPKT_FID_V(x)  ((x) << ULP_TXPKT_FID_S)
+
+#define ULP_TXPKT_RO_S      3
+#define ULP_TXPKT_RO_V(x) ((x) << ULP_TXPKT_RO_S)
+#define ULP_TXPKT_RO_F ULP_TXPKT_RO_V(1U)
+
+#define ULP_TX_SC_MORE_S 23
+#define ULP_TX_SC_MORE_V(x) ((x) << ULP_TX_SC_MORE_S)
+#define ULP_TX_SC_MORE_F  ULP_TX_SC_MORE_V(1U)
+
 struct ulp_mem_io {
 	WR_HDR;
 	__be32 cmd;
@@ -1404,4 +1436,409 @@ struct ulp_mem_io {
 #define ULP_MEMIO_DATA_LEN_S    0
 #define ULP_MEMIO_DATA_LEN_V(x) ((x) << ULP_MEMIO_DATA_LEN_S)
 
+#define ULPTX_NSGE_S    0
+#define ULPTX_NSGE_M    0xFFFF
+#define ULPTX_NSGE_V(x) ((x) << ULPTX_NSGE_S)
+#define ULPTX_NSGE_G(x) (((x) >> ULPTX_NSGE_S) & ULPTX_NSGE_M)
+
+struct ulptx_sc_memrd {
+	__be32 cmd_to_len;
+	__be32 addr;
+};
+
+#define ULP_TXPKT_DATAMODIFY_S       23
+#define ULP_TXPKT_DATAMODIFY_M       0x1
+#define ULP_TXPKT_DATAMODIFY_V(x)    ((x) << ULP_TXPKT_DATAMODIFY_S)
+#define ULP_TXPKT_DATAMODIFY_G(x)    \
+	(((x) >> ULP_TXPKT_DATAMODIFY_S) & ULP_TXPKT_DATAMODIFY__M)
+#define ULP_TXPKT_DATAMODIFY_F       ULP_TXPKT_DATAMODIFY_V(1U)
+
+#define ULP_TXPKT_CHANNELID_S        22
+#define ULP_TXPKT_CHANNELID_M        0x1
+#define ULP_TXPKT_CHANNELID_V(x)     ((x) << ULP_TXPKT_CHANNELID_S)
+#define ULP_TXPKT_CHANNELID_G(x)     \
+	(((x) >> ULP_TXPKT_CHANNELID_S) & ULP_TXPKT_CHANNELID_M)
+#define ULP_TXPKT_CHANNELID_F        ULP_TXPKT_CHANNELID_V(1U)
+
+#define SCMD_SEQ_NO_CTRL_S      29
+#define SCMD_SEQ_NO_CTRL_M      0x3
+#define SCMD_SEQ_NO_CTRL_V(x)   ((x) << SCMD_SEQ_NO_CTRL_S)
+#define SCMD_SEQ_NO_CTRL_G(x)   \
+	(((x) >> SCMD_SEQ_NO_CTRL_S) & SCMD_SEQ_NO_CTRL_M)
+
+/* StsFieldPrsnt- Status field at the end of the TLS PDU */
+#define SCMD_STATUS_PRESENT_S   28
+#define SCMD_STATUS_PRESENT_M   0x1
+#define SCMD_STATUS_PRESENT_V(x)    ((x) << SCMD_STATUS_PRESENT_S)
+#define SCMD_STATUS_PRESENT_G(x)    \
+	(((x) >> SCMD_STATUS_PRESENT_S) & SCMD_STATUS_PRESENT_M)
+#define SCMD_STATUS_PRESENT_F   SCMD_STATUS_PRESENT_V(1U)
+
+/* ProtoVersion - Protocol Version 0: 1.2, 1:1.1, 2:DTLS, 3:Generic,
+ * 3-15: Reserved.
+ */
+#define SCMD_PROTO_VERSION_S    24
+#define SCMD_PROTO_VERSION_M    0xf
+#define SCMD_PROTO_VERSION_V(x) ((x) << SCMD_PROTO_VERSION_S)
+#define SCMD_PROTO_VERSION_G(x) \
+	(((x) >> SCMD_PROTO_VERSION_S) & SCMD_PROTO_VERSION_M)
+
+/* EncDecCtrl - Encryption/Decryption Control. 0: Encrypt, 1: Decrypt */
+#define SCMD_ENC_DEC_CTRL_S     23
+#define SCMD_ENC_DEC_CTRL_M     0x1
+#define SCMD_ENC_DEC_CTRL_V(x)  ((x) << SCMD_ENC_DEC_CTRL_S)
+#define SCMD_ENC_DEC_CTRL_G(x)  \
+	(((x) >> SCMD_ENC_DEC_CTRL_S) & SCMD_ENC_DEC_CTRL_M)
+#define SCMD_ENC_DEC_CTRL_F SCMD_ENC_DEC_CTRL_V(1U)
+
+/* CipherAuthSeqCtrl - Cipher Authentication Sequence Control. */
+#define SCMD_CIPH_AUTH_SEQ_CTRL_S       22
+#define SCMD_CIPH_AUTH_SEQ_CTRL_M       0x1
+#define SCMD_CIPH_AUTH_SEQ_CTRL_V(x)    \
+	((x) << SCMD_CIPH_AUTH_SEQ_CTRL_S)
+#define SCMD_CIPH_AUTH_SEQ_CTRL_G(x)    \
+	(((x) >> SCMD_CIPH_AUTH_SEQ_CTRL_S) & SCMD_CIPH_AUTH_SEQ_CTRL_M)
+#define SCMD_CIPH_AUTH_SEQ_CTRL_F   SCMD_CIPH_AUTH_SEQ_CTRL_V(1U)
+
+/* CiphMode -  Cipher Mode. 0: NOP, 1:AES-CBC, 2:AES-GCM, 3:AES-CTR,
+ * 4:Generic-AES, 5-15: Reserved.
+ */
+#define SCMD_CIPH_MODE_S    18
+#define SCMD_CIPH_MODE_M    0xf
+#define SCMD_CIPH_MODE_V(x) ((x) << SCMD_CIPH_MODE_S)
+#define SCMD_CIPH_MODE_G(x) \
+	(((x) >> SCMD_CIPH_MODE_S) & SCMD_CIPH_MODE_M)
+
+/* AuthMode - Auth Mode. 0: NOP, 1:SHA1, 2:SHA2-224, 3:SHA2-256
+ * 4-15: Reserved
+ */
+#define SCMD_AUTH_MODE_S    14
+#define SCMD_AUTH_MODE_M    0xf
+#define SCMD_AUTH_MODE_V(x) ((x) << SCMD_AUTH_MODE_S)
+#define SCMD_AUTH_MODE_G(x) \
+	(((x) >> SCMD_AUTH_MODE_S) & SCMD_AUTH_MODE_M)
+
+/* HmacCtrl - HMAC Control. 0:NOP, 1:No truncation, 2:Support HMAC Truncation
+ * per RFC 4366, 3:IPSec 96 bits, 4-7:Reserved
+ */
+#define SCMD_HMAC_CTRL_S    11
+#define SCMD_HMAC_CTRL_M    0x7
+#define SCMD_HMAC_CTRL_V(x) ((x) << SCMD_HMAC_CTRL_S)
+#define SCMD_HMAC_CTRL_G(x) \
+	(((x) >> SCMD_HMAC_CTRL_S) & SCMD_HMAC_CTRL_M)
+
+/* IvSize - IV size in units of 2 bytes */
+#define SCMD_IV_SIZE_S  7
+#define SCMD_IV_SIZE_M  0xf
+#define SCMD_IV_SIZE_V(x)   ((x) << SCMD_IV_SIZE_S)
+#define SCMD_IV_SIZE_G(x)   \
+	(((x) >> SCMD_IV_SIZE_S) & SCMD_IV_SIZE_M)
+
+/* NumIVs - Number of IVs */
+#define SCMD_NUM_IVS_S  0
+#define SCMD_NUM_IVS_M  0x7f
+#define SCMD_NUM_IVS_V(x)   ((x) << SCMD_NUM_IVS_S)
+#define SCMD_NUM_IVS_G(x)   \
+	(((x) >> SCMD_NUM_IVS_S) & SCMD_NUM_IVS_M)
+
+/* EnbDbgId - If this is enabled upper 20 (63:44) bits if SeqNumber
+ * (below) are used as Cid (connection id for debug status), these
+ * bits are padded to zero for forming the 64 bit
+ * sequence number for TLS
+ */
+#define SCMD_ENB_DBGID_S  31
+#define SCMD_ENB_DBGID_M  0x1
+#define SCMD_ENB_DBGID_V(x)   ((x) << SCMD_ENB_DBGID_S)
+#define SCMD_ENB_DBGID_G(x)   \
+	(((x) >> SCMD_ENB_DBGID_S) & SCMD_ENB_DBGID_M)
+
+/* IV generation in SW. */
+#define SCMD_IV_GEN_CTRL_S      30
+#define SCMD_IV_GEN_CTRL_M      0x1
+#define SCMD_IV_GEN_CTRL_V(x)   ((x) << SCMD_IV_GEN_CTRL_S)
+#define SCMD_IV_GEN_CTRL_G(x)   \
+	(((x) >> SCMD_IV_GEN_CTRL_S) & SCMD_IV_GEN_CTRL_M)
+#define SCMD_IV_GEN_CTRL_F  SCMD_IV_GEN_CTRL_V(1U)
+
+/* More frags */
+#define SCMD_MORE_FRAGS_S   20
+#define SCMD_MORE_FRAGS_M   0x1
+#define SCMD_MORE_FRAGS_V(x)    ((x) << SCMD_MORE_FRAGS_S)
+#define SCMD_MORE_FRAGS_G(x)    (((x) >> SCMD_MORE_FRAGS_S) & SCMD_MORE_FRAGS_M)
+
+/*last frag */
+#define SCMD_LAST_FRAG_S    19
+#define SCMD_LAST_FRAG_M    0x1
+#define SCMD_LAST_FRAG_V(x) ((x) << SCMD_LAST_FRAG_S)
+#define SCMD_LAST_FRAG_G(x) (((x) >> SCMD_LAST_FRAG_S) & SCMD_LAST_FRAG_M)
+
+/* TlsCompPdu */
+#define SCMD_TLS_COMPPDU_S    18
+#define SCMD_TLS_COMPPDU_M    0x1
+#define SCMD_TLS_COMPPDU_V(x) ((x) << SCMD_TLS_COMPPDU_S)
+#define SCMD_TLS_COMPPDU_G(x) (((x) >> SCMD_TLS_COMPPDU_S) & SCMD_TLS_COMPPDU_M)
+
+/* KeyCntxtInline - Key context inline after the scmd  OR PayloadOnly*/
+#define SCMD_KEY_CTX_INLINE_S   17
+#define SCMD_KEY_CTX_INLINE_M   0x1
+#define SCMD_KEY_CTX_INLINE_V(x)    ((x) << SCMD_KEY_CTX_INLINE_S)
+#define SCMD_KEY_CTX_INLINE_G(x)    \
+	(((x) >> SCMD_KEY_CTX_INLINE_S) & SCMD_KEY_CTX_INLINE_M)
+#define SCMD_KEY_CTX_INLINE_F   SCMD_KEY_CTX_INLINE_V(1U)
+
+/* TLSFragEnable - 0: Host created TLS PDUs, 1: TLS Framgmentation in ASIC */
+#define SCMD_TLS_FRAG_ENABLE_S  16
+#define SCMD_TLS_FRAG_ENABLE_M  0x1
+#define SCMD_TLS_FRAG_ENABLE_V(x)   ((x) << SCMD_TLS_FRAG_ENABLE_S)
+#define SCMD_TLS_FRAG_ENABLE_G(x)   \
+	(((x) >> SCMD_TLS_FRAG_ENABLE_S) & SCMD_TLS_FRAG_ENABLE_M)
+#define SCMD_TLS_FRAG_ENABLE_F  SCMD_TLS_FRAG_ENABLE_V(1U)
+
+/* MacOnly - Only send the MAC and discard PDU. This is valid for hash only
+ * modes, in this case TLS_TX  will drop the PDU and only
+ * send back the MAC bytes.
+ */
+#define SCMD_MAC_ONLY_S 15
+#define SCMD_MAC_ONLY_M 0x1
+#define SCMD_MAC_ONLY_V(x)  ((x) << SCMD_MAC_ONLY_S)
+#define SCMD_MAC_ONLY_G(x)  \
+	(((x) >> SCMD_MAC_ONLY_S) & SCMD_MAC_ONLY_M)
+#define SCMD_MAC_ONLY_F SCMD_MAC_ONLY_V(1U)
+
+/* AadIVDrop - Drop the AAD and IV fields. Useful in protocols
+ * which have complex AAD and IV formations Eg:AES-CCM
+ */
+#define SCMD_AADIVDROP_S 14
+#define SCMD_AADIVDROP_M 0x1
+#define SCMD_AADIVDROP_V(x)  ((x) << SCMD_AADIVDROP_S)
+#define SCMD_AADIVDROP_G(x)  \
+	(((x) >> SCMD_AADIVDROP_S) & SCMD_AADIVDROP_M)
+#define SCMD_AADIVDROP_F SCMD_AADIVDROP_V(1U)
+
+/* HdrLength - Length of all headers excluding TLS header
+ * present before start of crypto PDU/payload.
+ */
+#define SCMD_HDR_LEN_S  0
+#define SCMD_HDR_LEN_M  0x3fff
+#define SCMD_HDR_LEN_V(x)   ((x) << SCMD_HDR_LEN_S)
+#define SCMD_HDR_LEN_G(x)   \
+	(((x) >> SCMD_HDR_LEN_S) & SCMD_HDR_LEN_M)
+
+struct cpl_tx_sec_pdu {
+	__be32 op_ivinsrtofst;
+	__be32 pldlen;
+	__be32 aadstart_cipherstop_hi;
+	__be32 cipherstop_lo_authinsert;
+	__be32 seqno_numivs;
+	__be32 ivgen_hdrlen;
+	__be64 scmd1;
+};
+
+#define CPL_TX_SEC_PDU_OPCODE_S     24
+#define CPL_TX_SEC_PDU_OPCODE_M     0xff
+#define CPL_TX_SEC_PDU_OPCODE_V(x)  ((x) << CPL_TX_SEC_PDU_OPCODE_S)
+#define CPL_TX_SEC_PDU_OPCODE_G(x)  \
+	(((x) >> CPL_TX_SEC_PDU_OPCODE_S) & CPL_TX_SEC_PDU_OPCODE_M)
+
+/* RX Channel Id */
+#define CPL_TX_SEC_PDU_RXCHID_S  22
+#define CPL_TX_SEC_PDU_RXCHID_M  0x1
+#define CPL_TX_SEC_PDU_RXCHID_V(x)   ((x) << CPL_TX_SEC_PDU_RXCHID_S)
+#define CPL_TX_SEC_PDU_RXCHID_G(x)   \
+	(((x) >> CPL_TX_SEC_PDU_RXCHID_S) & CPL_TX_SEC_PDU_RXCHID_M)
+#define CPL_TX_SEC_PDU_RXCHID_F  CPL_TX_SEC_PDU_RXCHID_V(1U)
+
+/* Ack Follows */
+#define CPL_TX_SEC_PDU_ACKFOLLOWS_S  21
+#define CPL_TX_SEC_PDU_ACKFOLLOWS_M  0x1
+#define CPL_TX_SEC_PDU_ACKFOLLOWS_V(x)   ((x) << CPL_TX_SEC_PDU_ACKFOLLOWS_S)
+#define CPL_TX_SEC_PDU_ACKFOLLOWS_G(x)   \
+	(((x) >> CPL_TX_SEC_PDU_ACKFOLLOWS_S) & CPL_TX_SEC_PDU_ACKFOLLOWS_M)
+#define CPL_TX_SEC_PDU_ACKFOLLOWS_F  CPL_TX_SEC_PDU_ACKFOLLOWS_V(1U)
+
+/* Loopback bit in cpl_tx_sec_pdu */
+#define CPL_TX_SEC_PDU_ULPTXLPBK_S  20
+#define CPL_TX_SEC_PDU_ULPTXLPBK_M  0x1
+#define CPL_TX_SEC_PDU_ULPTXLPBK_V(x)   ((x) << CPL_TX_SEC_PDU_ULPTXLPBK_S)
+#define CPL_TX_SEC_PDU_ULPTXLPBK_G(x)   \
+	(((x) >> CPL_TX_SEC_PDU_ULPTXLPBK_S) & CPL_TX_SEC_PDU_ULPTXLPBK_M)
+#define CPL_TX_SEC_PDU_ULPTXLPBK_F  CPL_TX_SEC_PDU_ULPTXLPBK_V(1U)
+
+/* Length of cpl header encapsulated */
+#define CPL_TX_SEC_PDU_CPLLEN_S     16
+#define CPL_TX_SEC_PDU_CPLLEN_M     0xf
+#define CPL_TX_SEC_PDU_CPLLEN_V(x)  ((x) << CPL_TX_SEC_PDU_CPLLEN_S)
+#define CPL_TX_SEC_PDU_CPLLEN_G(x)  \
+	(((x) >> CPL_TX_SEC_PDU_CPLLEN_S) & CPL_TX_SEC_PDU_CPLLEN_M)
+
+/* PlaceHolder */
+#define CPL_TX_SEC_PDU_PLACEHOLDER_S    10
+#define CPL_TX_SEC_PDU_PLACEHOLDER_M    0x1
+#define CPL_TX_SEC_PDU_PLACEHOLDER_V(x) ((x) << CPL_TX_SEC_PDU_PLACEHOLDER_S)
+#define CPL_TX_SEC_PDU_PLACEHOLDER_G(x) \
+	(((x) >> CPL_TX_SEC_PDU_PLACEHOLDER_S) & \
+	 CPL_TX_SEC_PDU_PLACEHOLDER_M)
+
+/* IvInsrtOffset: Insertion location for IV */
+#define CPL_TX_SEC_PDU_IVINSRTOFST_S    0
+#define CPL_TX_SEC_PDU_IVINSRTOFST_M    0x3ff
+#define CPL_TX_SEC_PDU_IVINSRTOFST_V(x) ((x) << CPL_TX_SEC_PDU_IVINSRTOFST_S)
+#define CPL_TX_SEC_PDU_IVINSRTOFST_G(x) \
+	(((x) >> CPL_TX_SEC_PDU_IVINSRTOFST_S) & \
+	 CPL_TX_SEC_PDU_IVINSRTOFST_M)
+
+/* AadStartOffset: Offset in bytes for AAD start from
+ * the first byte following the pkt headers (0-255 bytes)
+ */
+#define CPL_TX_SEC_PDU_AADSTART_S   24
+#define CPL_TX_SEC_PDU_AADSTART_M   0xff
+#define CPL_TX_SEC_PDU_AADSTART_V(x)    ((x) << CPL_TX_SEC_PDU_AADSTART_S)
+#define CPL_TX_SEC_PDU_AADSTART_G(x)    \
+	(((x) >> CPL_TX_SEC_PDU_AADSTART_S) & \
+	 CPL_TX_SEC_PDU_AADSTART_M)
+
+/* AadStopOffset: offset in bytes for AAD stop/end from the first byte following
+ * the pkt headers (0-511 bytes)
+ */
+#define CPL_TX_SEC_PDU_AADSTOP_S    15
+#define CPL_TX_SEC_PDU_AADSTOP_M    0x1ff
+#define CPL_TX_SEC_PDU_AADSTOP_V(x) ((x) << CPL_TX_SEC_PDU_AADSTOP_S)
+#define CPL_TX_SEC_PDU_AADSTOP_G(x) \
+	(((x) >> CPL_TX_SEC_PDU_AADSTOP_S) & CPL_TX_SEC_PDU_AADSTOP_M)
+
+/* CipherStartOffset: offset in bytes for encryption/decryption start from the
+ * first byte following the pkt headers (0-1023 bytes)
+ */
+#define CPL_TX_SEC_PDU_CIPHERSTART_S    5
+#define CPL_TX_SEC_PDU_CIPHERSTART_M    0x3ff
+#define CPL_TX_SEC_PDU_CIPHERSTART_V(x) ((x) << CPL_TX_SEC_PDU_CIPHERSTART_S)
+#define CPL_TX_SEC_PDU_CIPHERSTART_G(x) \
+	(((x) >> CPL_TX_SEC_PDU_CIPHERSTART_S) & \
+	 CPL_TX_SEC_PDU_CIPHERSTART_M)
+
+/* CipherStopOffset: offset in bytes for encryption/decryption end
+ * from end of the payload of this command (0-511 bytes)
+ */
+#define CPL_TX_SEC_PDU_CIPHERSTOP_HI_S      0
+#define CPL_TX_SEC_PDU_CIPHERSTOP_HI_M      0x1f
+#define CPL_TX_SEC_PDU_CIPHERSTOP_HI_V(x)   \
+	((x) << CPL_TX_SEC_PDU_CIPHERSTOP_HI_S)
+#define CPL_TX_SEC_PDU_CIPHERSTOP_HI_G(x)   \
+	(((x) >> CPL_TX_SEC_PDU_CIPHERSTOP_HI_S) & \
+	 CPL_TX_SEC_PDU_CIPHERSTOP_HI_M)
+
+#define CPL_TX_SEC_PDU_CIPHERSTOP_LO_S      28
+#define CPL_TX_SEC_PDU_CIPHERSTOP_LO_M      0xf
+#define CPL_TX_SEC_PDU_CIPHERSTOP_LO_V(x)   \
+	((x) << CPL_TX_SEC_PDU_CIPHERSTOP_LO_S)
+#define CPL_TX_SEC_PDU_CIPHERSTOP_LO_G(x)   \
+	(((x) >> CPL_TX_SEC_PDU_CIPHERSTOP_LO_S) & \
+	 CPL_TX_SEC_PDU_CIPHERSTOP_LO_M)
+
+/* AuthStartOffset: offset in bytes for authentication start from
+ * the first byte following the pkt headers (0-1023)
+ */
+#define CPL_TX_SEC_PDU_AUTHSTART_S  18
+#define CPL_TX_SEC_PDU_AUTHSTART_M  0x3ff
+#define CPL_TX_SEC_PDU_AUTHSTART_V(x)   ((x) << CPL_TX_SEC_PDU_AUTHSTART_S)
+#define CPL_TX_SEC_PDU_AUTHSTART_G(x)   \
+	(((x) >> CPL_TX_SEC_PDU_AUTHSTART_S) & \
+	 CPL_TX_SEC_PDU_AUTHSTART_M)
+
+/* AuthStopOffset: offset in bytes for authentication
+ * end from end of the payload of this command (0-511 Bytes)
+ */
+#define CPL_TX_SEC_PDU_AUTHSTOP_S   9
+#define CPL_TX_SEC_PDU_AUTHSTOP_M   0x1ff
+#define CPL_TX_SEC_PDU_AUTHSTOP_V(x)    ((x) << CPL_TX_SEC_PDU_AUTHSTOP_S)
+#define CPL_TX_SEC_PDU_AUTHSTOP_G(x)    \
+	(((x) >> CPL_TX_SEC_PDU_AUTHSTOP_S) & \
+	 CPL_TX_SEC_PDU_AUTHSTOP_M)
+
+/* AuthInsrtOffset: offset in bytes for authentication insertion
+ * from end of the payload of this command (0-511 bytes)
+ */
+#define CPL_TX_SEC_PDU_AUTHINSERT_S 0
+#define CPL_TX_SEC_PDU_AUTHINSERT_M 0x1ff
+#define CPL_TX_SEC_PDU_AUTHINSERT_V(x)  ((x) << CPL_TX_SEC_PDU_AUTHINSERT_S)
+#define CPL_TX_SEC_PDU_AUTHINSERT_G(x)  \
+	(((x) >> CPL_TX_SEC_PDU_AUTHINSERT_S) & \
+	 CPL_TX_SEC_PDU_AUTHINSERT_M)
+
+struct cpl_rx_phys_dsgl {
+	__be32 op_to_tid;
+	__be32 pcirlxorder_to_noofsgentr;
+	struct rss_header rss_hdr_int;
+};
+
+#define CPL_RX_PHYS_DSGL_OPCODE_S       24
+#define CPL_RX_PHYS_DSGL_OPCODE_M       0xff
+#define CPL_RX_PHYS_DSGL_OPCODE_V(x)    ((x) << CPL_RX_PHYS_DSGL_OPCODE_S)
+#define CPL_RX_PHYS_DSGL_OPCODE_G(x)    \
+	(((x) >> CPL_RX_PHYS_DSGL_OPCODE_S) & CPL_RX_PHYS_DSGL_OPCODE_M)
+
+#define CPL_RX_PHYS_DSGL_ISRDMA_S       23
+#define CPL_RX_PHYS_DSGL_ISRDMA_M       0x1
+#define CPL_RX_PHYS_DSGL_ISRDMA_V(x)    ((x) << CPL_RX_PHYS_DSGL_ISRDMA_S)
+#define CPL_RX_PHYS_DSGL_ISRDMA_G(x)    \
+	(((x) >> CPL_RX_PHYS_DSGL_ISRDMA_S) & CPL_RX_PHYS_DSGL_ISRDMA_M)
+#define CPL_RX_PHYS_DSGL_ISRDMA_F       CPL_RX_PHYS_DSGL_ISRDMA_V(1U)
+
+#define CPL_RX_PHYS_DSGL_RSVD1_S        20
+#define CPL_RX_PHYS_DSGL_RSVD1_M        0x7
+#define CPL_RX_PHYS_DSGL_RSVD1_V(x)     ((x) << CPL_RX_PHYS_DSGL_RSVD1_S)
+#define CPL_RX_PHYS_DSGL_RSVD1_G(x)     \
+	(((x) >> CPL_RX_PHYS_DSGL_RSVD1_S) & \
+	 CPL_RX_PHYS_DSGL_RSVD1_M)
+
+#define CPL_RX_PHYS_DSGL_PCIRLXORDER_S          31
+#define CPL_RX_PHYS_DSGL_PCIRLXORDER_M          0x1
+#define CPL_RX_PHYS_DSGL_PCIRLXORDER_V(x)       \
+	((x) << CPL_RX_PHYS_DSGL_PCIRLXORDER_S)
+#define CPL_RX_PHYS_DSGL_PCIRLXORDER_G(x)       \
+	(((x) >> CPL_RX_PHYS_DSGL_PCIRLXORDER_S) & \
+	 CPL_RX_PHYS_DSGL_PCIRLXORDER_M)
+#define CPL_RX_PHYS_DSGL_PCIRLXORDER_F  CPL_RX_PHYS_DSGL_PCIRLXORDER_V(1U)
+
+#define CPL_RX_PHYS_DSGL_PCINOSNOOP_S           30
+#define CPL_RX_PHYS_DSGL_PCINOSNOOP_M           0x1
+#define CPL_RX_PHYS_DSGL_PCINOSNOOP_V(x)        \
+	((x) << CPL_RX_PHYS_DSGL_PCINOSNOOP_S)
+#define CPL_RX_PHYS_DSGL_PCINOSNOOP_G(x)        \
+	(((x) >> CPL_RX_PHYS_DSGL_PCINOSNOOP_S) & \
+	 CPL_RX_PHYS_DSGL_PCINOSNOOP_M)
+
+#define CPL_RX_PHYS_DSGL_PCINOSNOOP_F   CPL_RX_PHYS_DSGL_PCINOSNOOP_V(1U)
+
+#define CPL_RX_PHYS_DSGL_PCITPHNTENB_S          29
+#define CPL_RX_PHYS_DSGL_PCITPHNTENB_M          0x1
+#define CPL_RX_PHYS_DSGL_PCITPHNTENB_V(x)       \
+	((x) << CPL_RX_PHYS_DSGL_PCITPHNTENB_S)
+#define CPL_RX_PHYS_DSGL_PCITPHNTENB_G(x)       \
+	(((x) >> CPL_RX_PHYS_DSGL_PCITPHNTENB_S) & \
+	 CPL_RX_PHYS_DSGL_PCITPHNTENB_M)
+#define CPL_RX_PHYS_DSGL_PCITPHNTENB_F  CPL_RX_PHYS_DSGL_PCITPHNTENB_V(1U)
+
+#define CPL_RX_PHYS_DSGL_PCITPHNT_S     27
+#define CPL_RX_PHYS_DSGL_PCITPHNT_M     0x3
+#define CPL_RX_PHYS_DSGL_PCITPHNT_V(x)  ((x) << CPL_RX_PHYS_DSGL_PCITPHNT_S)
+#define CPL_RX_PHYS_DSGL_PCITPHNT_G(x)  \
+	(((x) >> CPL_RX_PHYS_DSGL_PCITPHNT_S) & \
+	 CPL_RX_PHYS_DSGL_PCITPHNT_M)
+
+#define CPL_RX_PHYS_DSGL_DCAID_S        16
+#define CPL_RX_PHYS_DSGL_DCAID_M        0x7ff
+#define CPL_RX_PHYS_DSGL_DCAID_V(x)     ((x) << CPL_RX_PHYS_DSGL_DCAID_S)
+#define CPL_RX_PHYS_DSGL_DCAID_G(x)     \
+	(((x) >> CPL_RX_PHYS_DSGL_DCAID_S) & \
+	 CPL_RX_PHYS_DSGL_DCAID_M)
+
+#define CPL_RX_PHYS_DSGL_NOOFSGENTR_S           0
+#define CPL_RX_PHYS_DSGL_NOOFSGENTR_M           0xffff
+#define CPL_RX_PHYS_DSGL_NOOFSGENTR_V(x)        \
+	((x) << CPL_RX_PHYS_DSGL_NOOFSGENTR_S)
+#define CPL_RX_PHYS_DSGL_NOOFSGENTR_G(x)        \
+	(((x) >> CPL_RX_PHYS_DSGL_NOOFSGENTR_S) & \
+	 CPL_RX_PHYS_DSGL_NOOFSGENTR_M)
+
 #endif  /* __T4_MSG_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 02e4d35a..95921b1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -102,6 +102,7 @@ enum fw_wr_opcodes {
 	FW_RI_FR_NSMR_WR               = 0x19,
 	FW_RI_INV_LSTAG_WR             = 0x1a,
 	FW_ISCSI_TX_DATA_WR	       = 0x45,
+	FW_CRYPTO_LOOKASIDE_WR         = 0X6d,
 	FW_LASTC2E_WR                  = 0x70
 };
 
@@ -3243,4 +3244,127 @@ struct fw_devlog_cmd {
 #define PCIE_FW_PF_DEVLOG_MEMTYPE_G(x) \
 	(((x) >> PCIE_FW_PF_DEVLOG_MEMTYPE_S) & PCIE_FW_PF_DEVLOG_MEMTYPE_M)
 
+#define MAX_IMM_OFLD_TX_DATA_WR_LEN (0xff + sizeof(struct fw_ofld_tx_data_wr))
+
+struct fw_crypto_lookaside_wr {
+	__be32 op_to_cctx_size;
+	__be32 len16_pkd;
+	__be32 session_id;
+	__be32 rx_chid_to_rx_q_id;
+	__be32 key_addr;
+	__be32 pld_size_hash_size;
+	__be64 cookie;
+};
+
+#define FW_CRYPTO_LOOKASIDE_WR_OPCODE_S 24
+#define FW_CRYPTO_LOOKASIDE_WR_OPCODE_M 0xff
+#define FW_CRYPTO_LOOKASIDE_WR_OPCODE_V(x) \
+	((x) << FW_CRYPTO_LOOKASIDE_WR_OPCODE_S)
+#define FW_CRYPTO_LOOKASIDE_WR_OPCODE_G(x) \
+	(((x) >> FW_CRYPTO_LOOKASIDE_WR_OPCODE_S) & \
+	 FW_CRYPTO_LOOKASIDE_WR_OPCODE_M)
+
+#define FW_CRYPTO_LOOKASIDE_WR_COMPL_S 23
+#define FW_CRYPTO_LOOKASIDE_WR_COMPL_M 0x1
+#define FW_CRYPTO_LOOKASIDE_WR_COMPL_V(x) \
+	((x) << FW_CRYPTO_LOOKASIDE_WR_COMPL_S)
+#define FW_CRYPTO_LOOKASIDE_WR_COMPL_G(x) \
+	(((x) >> FW_CRYPTO_LOOKASIDE_WR_COMPL_S) & \
+	 FW_CRYPTO_LOOKASIDE_WR_COMPL_M)
+#define FW_CRYPTO_LOOKASIDE_WR_COMPL_F FW_CRYPTO_LOOKASIDE_WR_COMPL_V(1U)
+
+#define FW_CRYPTO_LOOKASIDE_WR_IMM_LEN_S 15
+#define FW_CRYPTO_LOOKASIDE_WR_IMM_LEN_M 0xff
+#define FW_CRYPTO_LOOKASIDE_WR_IMM_LEN_V(x) \
+	((x) << FW_CRYPTO_LOOKASIDE_WR_IMM_LEN_S)
+#define FW_CRYPTO_LOOKASIDE_WR_IMM_LEN_G(x) \
+	(((x) >> FW_CRYPTO_LOOKASIDE_WR_IMM_LEN_S) & \
+	 FW_CRYPTO_LOOKASIDE_WR_IMM_LEN_M)
+
+#define FW_CRYPTO_LOOKASIDE_WR_CCTX_LOC_S 5
+#define FW_CRYPTO_LOOKASIDE_WR_CCTX_LOC_M 0x3
+#define FW_CRYPTO_LOOKASIDE_WR_CCTX_LOC_V(x) \
+	((x) << FW_CRYPTO_LOOKASIDE_WR_CCTX_LOC_S)
+#define FW_CRYPTO_LOOKASIDE_WR_CCTX_LOC_G(x) \
+	(((x) >> FW_CRYPTO_LOOKASIDE_WR_CCTX_LOC_S) & \
+	 FW_CRYPTO_LOOKASIDE_WR_CCTX_LOC_M)
+
+#define FW_CRYPTO_LOOKASIDE_WR_CCTX_SIZE_S 0
+#define FW_CRYPTO_LOOKASIDE_WR_CCTX_SIZE_M 0x1f
+#define FW_CRYPTO_LOOKASIDE_WR_CCTX_SIZE_V(x) \
+	((x) << FW_CRYPTO_LOOKASIDE_WR_CCTX_SIZE_S)
+#define FW_CRYPTO_LOOKASIDE_WR_CCTX_SIZE_G(x) \
+	(((x) >> FW_CRYPTO_LOOKASIDE_WR_CCTX_SIZE_S) & \
+	 FW_CRYPTO_LOOKASIDE_WR_CCTX_SIZE_M)
+
+#define FW_CRYPTO_LOOKASIDE_WR_LEN16_S 0
+#define FW_CRYPTO_LOOKASIDE_WR_LEN16_M 0xff
+#define FW_CRYPTO_LOOKASIDE_WR_LEN16_V(x) \
+	((x) << FW_CRYPTO_LOOKASIDE_WR_LEN16_S)
+#define FW_CRYPTO_LOOKASIDE_WR_LEN16_G(x) \
+	(((x) >> FW_CRYPTO_LOOKASIDE_WR_LEN16_S) & \
+	 FW_CRYPTO_LOOKASIDE_WR_LEN16_M)
+
+#define FW_CRYPTO_LOOKASIDE_WR_RX_CHID_S 29
+#define FW_CRYPTO_LOOKASIDE_WR_RX_CHID_M 0x3
+#define FW_CRYPTO_LOOKASIDE_WR_RX_CHID_V(x) \
+	((x) << FW_CRYPTO_LOOKASIDE_WR_RX_CHID_S)
+#define FW_CRYPTO_LOOKASIDE_WR_RX_CHID_G(x) \
+	(((x) >> FW_CRYPTO_LOOKASIDE_WR_RX_CHID_S) & \
+	 FW_CRYPTO_LOOKASIDE_WR_RX_CHID_M)
+
+#define FW_CRYPTO_LOOKASIDE_WR_LCB_S  27
+#define FW_CRYPTO_LOOKASIDE_WR_LCB_M  0x3
+#define FW_CRYPTO_LOOKASIDE_WR_LCB_V(x) \
+	((x) << FW_CRYPTO_LOOKASIDE_WR_LCB_S)
+#define FW_CRYPTO_LOOKASIDE_WR_LCB_G(x) \
+	(((x) >> FW_CRYPTO_LOOKASIDE_WR_LCB_S) & FW_CRYPTO_LOOKASIDE_WR_LCB_M)
+
+#define FW_CRYPTO_LOOKASIDE_WR_PHASH_S 25
+#define FW_CRYPTO_LOOKASIDE_WR_PHASH_M 0x3
+#define FW_CRYPTO_LOOKASIDE_WR_PHASH_V(x) \
+	((x) << FW_CRYPTO_LOOKASIDE_WR_PHASH_S)
+#define FW_CRYPTO_LOOKASIDE_WR_PHASH_G(x) \
+	(((x) >> FW_CRYPTO_LOOKASIDE_WR_PHASH_S) & \
+	 FW_CRYPTO_LOOKASIDE_WR_PHASH_M)
+
+#define FW_CRYPTO_LOOKASIDE_WR_IV_S   23
+#define FW_CRYPTO_LOOKASIDE_WR_IV_M   0x3
+#define FW_CRYPTO_LOOKASIDE_WR_IV_V(x) \
+	((x) << FW_CRYPTO_LOOKASIDE_WR_IV_S)
+#define FW_CRYPTO_LOOKASIDE_WR_IV_G(x) \
+	(((x) >> FW_CRYPTO_LOOKASIDE_WR_IV_S) & FW_CRYPTO_LOOKASIDE_WR_IV_M)
+
+#define FW_CRYPTO_LOOKASIDE_WR_TX_CH_S 10
+#define FW_CRYPTO_LOOKASIDE_WR_TX_CH_M 0x3
+#define FW_CRYPTO_LOOKASIDE_WR_TX_CH_V(x) \
+	((x) << FW_CRYPTO_LOOKASIDE_WR_TX_CH_S)
+#define FW_CRYPTO_LOOKASIDE_WR_TX_CH_G(x) \
+	(((x) >> FW_CRYPTO_LOOKASIDE_WR_TX_CH_S) & \
+	 FW_CRYPTO_LOOKASIDE_WR_TX_CH_M)
+
+#define FW_CRYPTO_LOOKASIDE_WR_RX_Q_ID_S 0
+#define FW_CRYPTO_LOOKASIDE_WR_RX_Q_ID_M 0x3ff
+#define FW_CRYPTO_LOOKASIDE_WR_RX_Q_ID_V(x) \
+	((x) << FW_CRYPTO_LOOKASIDE_WR_RX_Q_ID_S)
+#define FW_CRYPTO_LOOKASIDE_WR_RX_Q_ID_G(x) \
+	(((x) >> FW_CRYPTO_LOOKASIDE_WR_RX_Q_ID_S) & \
+	 FW_CRYPTO_LOOKASIDE_WR_RX_Q_ID_M)
+
+#define FW_CRYPTO_LOOKASIDE_WR_PLD_SIZE_S 24
+#define FW_CRYPTO_LOOKASIDE_WR_PLD_SIZE_M 0xff
+#define FW_CRYPTO_LOOKASIDE_WR_PLD_SIZE_V(x) \
+	((x) << FW_CRYPTO_LOOKASIDE_WR_PLD_SIZE_S)
+#define FW_CRYPTO_LOOKASIDE_WR_PLD_SIZE_G(x) \
+	(((x) >> FW_CRYPTO_LOOKASIDE_WR_PLD_SIZE_S) & \
+	 FW_CRYPTO_LOOKASIDE_WR_PLD_SIZE_M)
+
+#define FW_CRYPTO_LOOKASIDE_WR_HASH_SIZE_S 17
+#define FW_CRYPTO_LOOKASIDE_WR_HASH_SIZE_M 0x7f
+#define FW_CRYPTO_LOOKASIDE_WR_HASH_SIZE_V(x) \
+	((x) << FW_CRYPTO_LOOKASIDE_WR_HASH_SIZE_S)
+#define FW_CRYPTO_LOOKASIDE_WR_HASH_SIZE_G(x) \
+	(((x) >> FW_CRYPTO_LOOKASIDE_WR_HASH_SIZE_S) & \
+	 FW_CRYPTO_LOOKASIDE_WR_HASH_SIZE_M)
+
 #endif /* _T4FW_INTERFACE_H_ */
-- 
1.7.3
