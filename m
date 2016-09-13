From: Varun Prakash <varun@chelsio.com>
Subject: [net-next PATCH 11/11] libcxgb,iw_cxgb4,cxgbit: add cxgb_mk_rx_data_ack()
Date: Tue, 13 Sep 2016 21:24:06 +0530
Message-ID: <08bb164578c75ba72c2f32c57e381c818e016eb8.1473781521.git.varun@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        target-devel@vger.kernel.org, nab@linux-iscsi.org,
        dledford@redhat.com, swise@opengridcomputing.com,
        gerlitz.or@gmail.com, indranil@chelsio.com, varun@chelsio.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:13557 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1759526AbcIMP5V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 11:57:21 -0400
In-Reply-To: <cover.1473781521.git.varun@chelsio.com>
In-Reply-To: <cover.1473781521.git.varun@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add cxgb_mk_rx_data_ack() to remove duplicate
code to form CPL_RX_DATA_ACK hardware command.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cm.c                  | 19 ++++++++-----------
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h | 15 +++++++++++++++
 drivers/target/iscsi/cxgbit/cxgbit_cm.c           | 16 ++++++----------
 3 files changed, 29 insertions(+), 21 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index a6d5fcb..3cbbfbe 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1354,9 +1354,9 @@ static void established_upcall(struct c4iw_ep *ep)
 
 static int update_rx_credits(struct c4iw_ep *ep, u32 credits)
 {
-	struct cpl_rx_data_ack *req;
 	struct sk_buff *skb;
-	int wrlen = roundup(sizeof *req, 16);
+	u32 wrlen = roundup(sizeof(struct cpl_rx_data_ack), 16);
+	u32 credit_dack;
 
 	PDBG("%s ep %p tid %u credits %u\n", __func__, ep, ep->hwtid, credits);
 	skb = get_skb(NULL, wrlen, GFP_KERNEL);
@@ -1373,15 +1373,12 @@ static int update_rx_credits(struct c4iw_ep *ep, u32 credits)
 	if (ep->rcv_win > RCV_BUFSIZ_M * 1024)
 		credits += ep->rcv_win - RCV_BUFSIZ_M * 1024;
 
-	req = (struct cpl_rx_data_ack *) skb_put(skb, wrlen);
-	memset(req, 0, wrlen);
-	INIT_TP_WR(req, ep->hwtid);
-	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_RX_DATA_ACK,
-						    ep->hwtid));
-	req->credit_dack = cpu_to_be32(credits | RX_FORCE_ACK_F |
-				       RX_DACK_CHANGE_F |
-				       RX_DACK_MODE_V(dack_mode));
-	set_wr_txq(skb, CPL_PRIORITY_ACK, ep->ctrlq_idx);
+	credit_dack = credits | RX_FORCE_ACK_F | RX_DACK_CHANGE_F |
+		      RX_DACK_MODE_V(dack_mode);
+
+	cxgb_mk_rx_data_ack(skb, wrlen, ep->hwtid, ep->ctrlq_idx,
+			    credit_dack);
+
 	c4iw_ofld_send(&ep->com.dev->rdev, skb);
 	return credits;
 }
diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
index 70999e8..515b94f 100644
--- a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
@@ -142,4 +142,19 @@ cxgb_mk_abort_rpl(struct sk_buff *skb, u32 len, u32 tid, u16 chan)
 	rpl->cmd = CPL_ABORT_NO_RST;
 	set_wr_txq(skb, CPL_PRIORITY_DATA, chan);
 }
+
+static inline void
+cxgb_mk_rx_data_ack(struct sk_buff *skb, u32 len, u32 tid, u16 chan,
+		    u32 credit_dack)
+{
+	struct cpl_rx_data_ack *req;
+
+	req = (struct cpl_rx_data_ack *)__skb_put(skb, len);
+	memset(req, 0, len);
+
+	INIT_TP_WR(req, tid);
+	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_RX_DATA_ACK, tid));
+	req->credit_dack = cpu_to_be32(credit_dack);
+	set_wr_txq(skb, CPL_PRIORITY_ACK, chan);
+}
 #endif
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_cm.c b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
index 9bdbe3b..2fb1bf1 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_cm.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
@@ -994,22 +994,18 @@ static void cxgbit_send_rx_credits(struct cxgbit_sock *csk, struct sk_buff *skb)
 int cxgbit_rx_data_ack(struct cxgbit_sock *csk)
 {
 	struct sk_buff *skb;
-	struct cpl_rx_data_ack *req;
-	unsigned int len = roundup(sizeof(*req), 16);
+	u32 len = roundup(sizeof(struct cpl_rx_data_ack), 16);
+	u32 credit_dack;
 
 	skb = alloc_skb(len, GFP_KERNEL);
 	if (!skb)
 		return -1;
 
-	req = (struct cpl_rx_data_ack *)__skb_put(skb, len);
-	memset(req, 0, len);
+	credit_dack = RX_DACK_CHANGE_F | RX_DACK_MODE_V(1) |
+		      RX_CREDITS_V(csk->rx_credits);
 
-	set_wr_txq(skb, CPL_PRIORITY_ACK, csk->ctrlq_idx);
-	INIT_TP_WR(req, csk->tid);
-	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_RX_DATA_ACK,
-						    csk->tid));
-	req->credit_dack = cpu_to_be32(RX_DACK_CHANGE_F | RX_DACK_MODE_V(1) |
-				       RX_CREDITS_V(csk->rx_credits));
+	cxgb_mk_rx_data_ack(skb, len, csk->tid, csk->ctrlq_idx,
+			    credit_dack);
 
 	csk->rx_credits = 0;
 
-- 
2.0.2
