From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 1/8] SCTP: protocol definitions for SCTP-AUTH implementation
Date: Fri, 14 Sep 2007 14:44:52 -0400
Message-ID: <11897954991955-git-send-email-vladislav.yasevich@hp.com>
References: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vladislav.yasevich@hp.com>
To: lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:55129 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754321AbXINSpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 14:45:11 -0400
In-Reply-To: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/linux/sctp.h |  100 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 99 insertions(+), 1 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index f4d717b..5eb38cc 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -102,6 +102,9 @@ typedef enum {
         SCTP_CID_ECN_CWR		= 13,
         SCTP_CID_SHUTDOWN_COMPLETE	= 14,
 
+	/* AUTH Extension Section 4.1 */
+	SCTP_CID_AUTH			= 0x0F,
+
 	/* PR-SCTP Sec 3.2 */
 	SCTP_CID_FWD_TSN		= 0xC0,
 
@@ -180,6 +183,11 @@ typedef enum {
 	SCTP_PARAM_SUPPORTED_ADDRESS_TYPES	= __constant_htons(12),
 	SCTP_PARAM_ECN_CAPABLE			= __constant_htons(0x8000),
 
+	/* AUTH Extension Section 3 */
+	SCTP_PARAM_RANDOM			= __constant_htons(0x8002),
+	SCTP_PARAM_CHUNKS			= __constant_htons(0x8003),
+	SCTP_PARAM_HMAC_ALGO			= __constant_htons(0x8004),
+
 	/* Add-IP: Supported Extensions, Section 4.2 */
 	SCTP_PARAM_SUPPORTED_EXT	= __constant_htons(0x8008),
 
@@ -305,6 +313,24 @@ typedef struct sctp_supported_ext_param {
 	__u8 chunks[0];
 } __attribute__((packed)) sctp_supported_ext_param_t;
 
+/* AUTH Section 3.1 Random */
+typedef struct sctp_random_param {
+	sctp_paramhdr_t param_hdr;
+	__u8 random_val[0];
+} __attribute__((packed)) sctp_random_param_t;
+
+/* AUTH Section 3.2 Chunk List */
+typedef struct sctp_chunks_param {
+	sctp_paramhdr_t param_hdr;
+	__u8 chunks[0];
+} __attribute__((packed)) sctp_chunks_param_t;
+
+/* AUTH Section 3.3 HMAC Algorithm */
+typedef struct sctp_hmac_algo_param {
+	sctp_paramhdr_t param_hdr;
+	__be16 hmac_ids[0];
+} __attribute__((packed)) sctp_hmac_algo_param_t;
+
 /* RFC 2960.  Section 3.3.3 Initiation Acknowledgement (INIT ACK) (2):
  *   The INIT ACK chunk is used to acknowledge the initiation of an SCTP
  *   association.
@@ -471,7 +497,19 @@ typedef enum {
 	SCTP_ERROR_RSRC_LOW	= __constant_htons(0x0101),
 	SCTP_ERROR_DEL_SRC_IP	= __constant_htons(0x0102),
 	SCTP_ERROR_ASCONF_ACK   = __constant_htons(0x0103),
-	SCTP_ERROR_REQ_REFUSED	= __constant_htons(0x0104)
+	SCTP_ERROR_REQ_REFUSED	= __constant_htons(0x0104),
+
+	/* AUTH Section 4.  New Error Cause
+	 *
+	 * This section defines a new error cause that will be sent if an AUTH
+	 * chunk is received with an unsupported HMAC identifier.
+	 * illustrates the new error cause.
+	 *
+	 * Cause Code      Error Cause Name
+	 * --------------------------------------------------------------
+	 * 0x0105          Unsupported HMAC Identifier
+	 */
+	 SCTP_ERROR_UNSUP_HMAC	= __constant_htons(0x0105)
 } sctp_error_t;
 
 
@@ -609,4 +647,64 @@ typedef struct sctp_addip_chunk {
 	sctp_addiphdr_t addip_hdr;
 } __attribute__((packed)) sctp_addip_chunk_t;
 
+/* AUTH
+ * Section 4.1  Authentication Chunk (AUTH)
+ *
+ *   This chunk is used to hold the result of the HMAC calculation.
+ *
+ *    0                   1                   2                   3
+ *    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ *   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *   | Type = 0x0F   |   Flags=0     |             Length            |
+ *   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *   |     Shared Key Identifier     |   HMAC Identifier             |
+ *   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *   |                                                               |
+ *   \                             HMAC                              /
+ *   /                                                               \
+ *   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ *   Type: 1 byte (unsigned integer)
+ *   	This value MUST be set to 0x0F for  all AUTH-chunks.
+ *
+ *   Flags: 1 byte (unsigned integer)
+ *	Set to zero on transmit and ignored on receipt.
+ *
+ *   Length: 2 bytes (unsigned integer)
+ *   	This value holds the length of the HMAC in bytes plus 8.
+ *
+ *  Shared Key Identifier: 2 bytes (unsigned integer)
+ *	This value describes which endpoint pair shared key is used.
+ *
+ *   HMAC Identifier: 2 bytes (unsigned integer)
+ *   	This value describes which message digest is being used.  Table 2
+ *	shows the currently defined values.
+ *
+ *    The following Table 2 shows the currently defined values for HMAC
+ *       identifiers.
+ *
+ *	 +-----------------+--------------------------+
+ *	 | HMAC Identifier | Message Digest Algorithm |
+ *	 +-----------------+--------------------------+
+ *	 | 0               | Reserved                 |
+ *	 | 1               | SHA-1 defined in [8]     |
+ *	 | 2               | Reserved                 |
+ *	 | 3               | SHA-256 defined in [8]   |
+ *	 +-----------------+--------------------------+
+ *
+ *
+ *   HMAC: n bytes (unsigned integer) This hold the result of the HMAC
+ *      calculation.
+ */
+typedef struct sctp_authhdr {
+	__be16 shkey_id;
+	__be16 hmac_id;
+	__u8   hmac[0];
+} __attribute__((packed)) sctp_authhdr_t;
+
+typedef struct sctp_auth_chunk {
+	sctp_chunkhdr_t chunk_hdr;
+	sctp_authhdr_t auth_hdr;
+} __attribute__((packed)) sctp_auth_chunk_t;
+
 #endif /* __LINUX_SCTP_H__ */
-- 
1.5.2.4

