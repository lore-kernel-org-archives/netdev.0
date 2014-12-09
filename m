From: Karen Xie <kxie@chelsio.com>
Subject: [PATCH net v3 1/6] cxgb4i: fix tx credit calculation
Date: Tue, 09 Dec 2014 09:32:17 -0800
Message-ID: <201412091732.sB9HWHRm008996@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kxie@chelsio.com, hariprasad@chelsio.com, anish@chelsio.com,
	hch@infradead.org, James.Bottomley@HansenPartnership.com,
	michaelc@cs.wisc.edu, davem@davemloft.net
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25126 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbaLIRdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 12:33:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net v3 1/6] cxgb4i: fix tx credit calculation

From: Karen Xie <kxie@chelsio.com>

- Only data skbs need the wr header added while control skbs do not. Make sure they are treated differently.
- Any credit related checking should be done before adding the wr header.
- Fixed compiler warning resulted from added cxgbi_skb_test_flag() call in is_ofld_imm().

Signed-off-by: Karen Xie <kxie@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |   26 +++++++++++++++++---------
 drivers/scsi/cxgbi/libcxgbi.h      |    4 ++--
 2 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 1508125..5c3f15d 100644
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
@@ -597,12 +603,14 @@ static int push_tx_frames(struct cxgbi_sock *csk, int req_completion)
 
 		skb_reset_transport_header(skb);
 		if (is_ofld_imm(skb))
-			credits_needed = DIV_ROUND_UP(dlen +
-					sizeof(struct fw_ofld_tx_data_wr), 16);
+			credits_needed = DIV_ROUND_UP(dlen, 16);
 		else
-			credits_needed = DIV_ROUND_UP(8*calc_tx_flits_ofld(skb)
-					+ sizeof(struct fw_ofld_tx_data_wr),
-					16);
+			credits_needed = DIV_ROUND_UP(8*calc_tx_flits_ofld(skb),
+						      16);
+
+		if (likely(cxgbi_skcb_test_flag(skb, SKCBF_TX_NEED_HDR)))
+			credits_needed += DIV_ROUND_UP(
+				sizeof(struct fw_ofld_tx_data_wr), 16);
 
 		if (csk->wr_cred < credits_needed) {
 			log_debug(1 << CXGBI_DBG_PDU_TX,
diff --git a/drivers/scsi/cxgbi/libcxgbi.h b/drivers/scsi/cxgbi/libcxgbi.h
index 2c7cb1c..aba1af7 100644
--- a/drivers/scsi/cxgbi/libcxgbi.h
+++ b/drivers/scsi/cxgbi/libcxgbi.h
@@ -317,8 +317,8 @@ static inline void cxgbi_skcb_clear_flag(struct sk_buff *skb,
 	__clear_bit(flag, &(cxgbi_skcb_flags(skb)));
 }
 
-static inline int cxgbi_skcb_test_flag(struct sk_buff *skb,
-					enum cxgbi_skcb_flags flag)
+static inline int cxgbi_skcb_test_flag(const struct sk_buff *skb,
+				       enum cxgbi_skcb_flags flag)
 {
 	return test_bit(flag, &(cxgbi_skcb_flags(skb)));
 }
