From: Karen Xie <kxie@chelsio.com>
Subject: [PATCH net v5 2/7] cxgb4i: fix credit check for tx_data_wr
Date: Tue, 09 Dec 2014 17:43:28 -0800
Message-ID: <201412100143.sBA1hSF4024918@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kxie@chelsio.com, hariprasad@chelsio.com, anish@chelsio.com,
	hch@infradead.org, James.Bottomley@HansenPartnership.com,
	michaelc@cs.wisc.edu, davem@davemloft.net
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:16305 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753877AbaLJBo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 20:44:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net v5 2/7] cxgb4i: fix credit check for tx_data_wr

From: Karen Xie <kxie@chelsio.com>

make sure any tx credit related checking is done before adding the wr header.
        
Signed-off-by: Karen Xie <kxie@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index f119a67..56dbd25 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -547,15 +547,16 @@ static inline void make_tx_data_wr(struct cxgbi_sock *csk, struct sk_buff *skb,
 	struct fw_ofld_tx_data_wr *req;
 	unsigned int submode = cxgbi_skcb_ulp_mode(skb) & 3;
 	unsigned int wr_ulp_mode = 0;
+	bool imm = is_ofld_imm(skb);
 
 	req = (struct fw_ofld_tx_data_wr *)__skb_push(skb, sizeof(*req));
 
-	if (is_ofld_imm(skb)) {
+	if (imm) {
 		req->op_to_immdlen = htonl(FW_WR_OP(FW_OFLD_TX_DATA_WR) |
-					FW_WR_COMPL(1) |
-					FW_WR_IMMDLEN(dlen));
+					   FW_WR_COMPL(1) |
+					   FW_WR_IMMDLEN(dlen));
 		req->flowid_len16 = htonl(FW_WR_FLOWID(csk->tid) |
-						FW_WR_LEN16(credits));
+					  FW_WR_LEN16(credits));
 	} else {
 		req->op_to_immdlen =
 			cpu_to_be32(FW_WR_OP(FW_OFLD_TX_DATA_WR) |
