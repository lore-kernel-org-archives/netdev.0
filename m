From: Karen Xie <kxie@chelsio.com>
Subject: [PATCH net v9 1/7] cxgb4i: fix tx immediate data credit check
Date: Thu, 11 Dec 2014 07:25:40 -0800
Message-ID: <201412111525.sBBFPeZt012927@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kxie@chelsio.com, hariprasad@chelsio.com, anish@chelsio.com,
	hch@infradead.org, James.Bottomley@HansenPartnership.com,
	michaelc@cs.wisc.edu, davem@davemloft.net
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4724 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754846AbaLKP0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 10:26:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karen Xie <kxie@chelsio.com>

Only data skbs need the wr header added while control skbs do not. Make sure
they are treated differently.

Signed-off-by: Karen Xie <kxie@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |   22 +++++++++++++++-------
 drivers/scsi/cxgbi/libcxgbi.h      |    4 ++--
 2 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 1508125..f119a67 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -171,10 +171,14 @@ static int push_tx_frames(struct cxgbi_sock *, int);
  * Returns true if a packet can be sent as an offload WR with immediate
  * data.  We currently use the same limit as for Ethernet packets.
  */
-static inline int is_ofld_imm(const struct sk_buff *skb)
+static inline bool is_ofld_imm(const struct sk_buff *skb)
 {
-	return skb->len <= (MAX_IMM_TX_PKT_LEN -
-			sizeof(struct fw_ofld_tx_data_wr));
+	int len = skb->len;
+
+	if (likely(cxgbi_skcb_test_flag(skb, SKCBF_TX_NEED_HDR)))
+		len += sizeof(struct fw_ofld_tx_data_wr);
+
+	return len <= MAX_IMM_TX_PKT_LEN;
 }
 
 static void send_act_open_req(struct cxgbi_sock *csk, struct sk_buff *skb,
@@ -597,11 +601,15 @@ static int push_tx_frames(struct cxgbi_sock *csk, int req_completion)
 
 		skb_reset_transport_header(skb);
 		if (is_ofld_imm(skb))
-			credits_needed = DIV_ROUND_UP(dlen +
-					sizeof(struct fw_ofld_tx_data_wr), 16);
+			credits_needed = DIV_ROUND_UP(dlen, 16);
 		else
-			credits_needed = DIV_ROUND_UP(8*calc_tx_flits_ofld(skb)
-					+ sizeof(struct fw_ofld_tx_data_wr),
+			credits_needed = DIV_ROUND_UP(
+						8 * calc_tx_flits_ofld(skb),
+						16);
+
+		if (likely(cxgbi_skcb_test_flag(skb, SKCBF_TX_NEED_HDR)))
+			credits_needed += DIV_ROUND_UP(
+					sizeof(struct fw_ofld_tx_data_wr),
 					16);
 
 		if (csk->wr_cred < credits_needed) {
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
