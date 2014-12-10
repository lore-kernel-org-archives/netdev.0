From: Karen Xie <kxie@chelsio.com>
Subject: [PATCH net v8 6/7] cxgb4i: use set_wr_txq() to set tx queues
Date: Wed, 10 Dec 2014 13:11:21 -0800
Message-ID: <201412102111.sBALBL5m011686@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kxie@chelsio.com, hariprasad@chelsio.com, anish@chelsio.com,
	hch@infradead.org, James.Bottomley@HansenPartnership.com,
	michaelc@cs.wisc.edu, davem@davemloft.net
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25012 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933199AbaLJVME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 16:12:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karen Xie <kxie@chelsio.com>

use cxgb4's set_wr_txq() for setting of the tx queue for a outgoing packet. Remove the similar function in cxgb4i.

Signed-off-by: Karen Xie <kxie@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |   16 +++++-----------
 1 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index dff7345..6aa50fc 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -157,12 +157,6 @@ static struct scsi_transport_template *cxgb4i_stt;
 #define RCV_BUFSIZ_MASK		0x3FFU
 #define MAX_IMM_TX_PKT_LEN	128
 
-static inline void set_queue(struct sk_buff *skb, unsigned int queue,
-				const struct cxgbi_sock *csk)
-{
-	skb->queue_mapping = queue;
-}
-
 static int push_tx_frames(struct cxgbi_sock *, int);
 
 /*
@@ -404,7 +398,7 @@ static void send_abort_req(struct cxgbi_sock *csk)
 
 	csk->cpl_abort_req = NULL;
 	req = (struct cpl_abort_req *)skb->head;
-	set_queue(skb, CPL_PRIORITY_DATA, csk);
+	set_wr_txq(skb, CPL_PRIORITY_DATA, csk->port_id);
 	req->cmd = CPL_ABORT_SEND_RST;
 	t4_set_arp_err_handler(skb, csk, abort_arp_failure);
 	INIT_TP_WR(req, csk->tid);
@@ -430,7 +424,7 @@ static void send_abort_rpl(struct cxgbi_sock *csk, int rst_status)
 		csk, csk->state, csk->flags, csk->tid, rst_status);
 
 	csk->cpl_abort_rpl = NULL;
-	set_queue(skb, CPL_PRIORITY_DATA, csk);
+	set_wr_txq(skb, CPL_PRIORITY_DATA, csk->port_id);
 	INIT_TP_WR(rpl, csk->tid);
 	OPCODE_TID(rpl) = cpu_to_be32(MK_OPCODE_TID(CPL_ABORT_RPL, csk->tid));
 	rpl->cmd = rst_status;
@@ -555,7 +549,7 @@ static inline int send_tx_flowc_wr(struct cxgbi_sock *csk)
 	flowc->mnemval[8].mnemonic = FW_FLOWC_MNEM_TXDATAPLEN_MAX;
 	flowc->mnemval[8].val = 16384;
 
-	set_queue(skb, CPL_PRIORITY_DATA, csk);
+	set_wr_txq(skb, CPL_PRIORITY_DATA, csk->port_id);
 
 	log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_SOCK,
 		"csk 0x%p, tid 0x%x, %u,%u,%u,%u,%u,%u,%u.\n",
@@ -660,7 +654,7 @@ static int push_tx_frames(struct cxgbi_sock *csk, int req_completion)
 			break;
 		}
 		__skb_unlink(skb, &csk->write_queue);
-		set_queue(skb, CPL_PRIORITY_DATA, csk);
+		set_wr_txq(skb, CPL_PRIORITY_DATA, csk->port_id);
 		skb->csum = credits_needed + flowclen16;
 		csk->wr_cred -= credits_needed;
 		csk->wr_una_cred += credits_needed;
@@ -1552,7 +1546,7 @@ static int ddp_ppod_write_idata(struct cxgbi_device *cdev, unsigned int port_id,
 		return -ENOMEM;
 	}
 	req = (struct ulp_mem_io *)skb->head;
-	set_queue(skb, CPL_PRIORITY_CONTROL, NULL);
+	set_wr_txq(skb, CPL_PRIORITY_CONTROL, 0);
 
 	ulp_mem_io_set_hdr(lldi, req, wr_len, dlen, pm_addr);
 	idata = (struct ulptx_idata *)(req + 1);
