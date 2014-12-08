From: kxie@chelsio.com
Subject: [PATCH net 1/5] cxgb4i: fix tx credit calculation
Date: Mon, 08 Dec 2014 00:09:08 -0800
Message-ID: <201412080809.sB8898BV029841@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kxie@chelsio.com, hariprasad@chelsio.com, anish@chelsio.com,
	hch@infradead.org, James.Bottomley@HansenPartnership.com,
	michaelc@cs.wisc.edu, davem@davemloft.net
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11718 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751094AbaLHILm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 03:11:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net 1/5] cxgb4i: fix tx credit calculation

From: Karen Xie <kxie@chelsio.com>

- Only data skbs need the wr header added while control skbs do not. Make sure they are treated differently.
- Any credit related checking should be done before adding the wr header.
- Fixed compiler warning resulted from added cxgbi_skb_test_flag() call in is_ofld_imm().

Signed-off-by: Karen Xie <kxie@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |   24 ++++++++++++++++--------
 drivers/scsi/cxgbi/libcxgbi.h      |    2 +-
 2 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 1508125..bc4e376 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -173,8 +173,12 @@ static int push_tx_frames(struct cxgbi_sock *, int);
  */
 static inline int is_ofld_imm(const struct sk_buff *skb)
 {
-	return skb->len <= (MAX_IMM_TX_PKT_LEN -
-			sizeof(struct fw_ofld_tx_data_wr));
+	int length = skb->len;
+
+	if (likely(cxgbi_skcb_test_flag(skb, SKCBF_TX_NEED_HDR)))
+		length += sizeof(struct fw_ofld_tx_data_wr);
+
+	return length <= MAX_IMM_TX_PKT_LEN;
 }
 
 static void send_act_open_req(struct cxgbi_sock *csk, struct sk_buff *skb,
@@ -544,15 +548,17 @@ static inline void make_tx_data_wr(struct cxgbi_sock *csk, struct sk_buff *skb,
 	unsigned int submode = cxgbi_skcb_ulp_mode(skb) & 3;
 	unsigned int wr_ulp_mode = 0;
 
-	req = (struct fw_ofld_tx_data_wr *)__skb_push(skb, sizeof(*req));
-
 	if (is_ofld_imm(skb)) {
+		req = (struct fw_ofld_tx_data_wr *)__skb_push(skb,
+							sizeof(*req));
 		req->op_to_immdlen = htonl(FW_WR_OP(FW_OFLD_TX_DATA_WR) |
 					FW_WR_COMPL(1) |
 					FW_WR_IMMDLEN(dlen));
 		req->flowid_len16 = htonl(FW_WR_FLOWID(csk->tid) |
 						FW_WR_LEN16(credits));
 	} else {
+		req = (struct fw_ofld_tx_data_wr *)__skb_push(skb,
+							sizeof(*req));
 		req->op_to_immdlen =
 			cpu_to_be32(FW_WR_OP(FW_OFLD_TX_DATA_WR) |
 					FW_WR_COMPL(1) |
@@ -597,13 +603,15 @@ static int push_tx_frames(struct cxgbi_sock *csk, int req_completion)
 
 		skb_reset_transport_header(skb);
 		if (is_ofld_imm(skb))
-			credits_needed = DIV_ROUND_UP(dlen +
-					sizeof(struct fw_ofld_tx_data_wr), 16);
+			credits_needed = DIV_ROUND_UP(dlen, 16);
 		else
-			credits_needed = DIV_ROUND_UP(8*calc_tx_flits_ofld(skb)
-					+ sizeof(struct fw_ofld_tx_data_wr),
+			credits_needed = DIV_ROUND_UP(8*calc_tx_flits_ofld(skb),
 					16);
 
+		if (likely(cxgbi_skcb_test_flag(skb, SKCBF_TX_NEED_HDR)))
+			credits_needed += DIV_ROUND_UP(
+				sizeof(struct fw_ofld_tx_data_wr), 16);
+
 		if (csk->wr_cred < credits_needed) {
 			log_debug(1 << CXGBI_DBG_PDU_TX,
 				"csk 0x%p, skb %u/%u, wr %d < %u.\n",
diff --git a/drivers/scsi/cxgbi/libcxgbi.h b/drivers/scsi/cxgbi/libcxgbi.h
index 2c7cb1c..631a9b7 100644
--- a/drivers/scsi/cxgbi/libcxgbi.h
+++ b/drivers/scsi/cxgbi/libcxgbi.h
@@ -317,7 +317,7 @@ static inline void cxgbi_skcb_clear_flag(struct sk_buff *skb,
 	__clear_bit(flag, &(cxgbi_skcb_flags(skb)));
 }
 
-static inline int cxgbi_skcb_test_flag(struct sk_buff *skb,
+static inline int cxgbi_skcb_test_flag(const struct sk_buff *skb,
 					enum cxgbi_skcb_flags flag)
 {
 	return test_bit(flag, &(cxgbi_skcb_flags(skb)));
