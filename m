From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/3] libcxgbi: add pdu parsing of LRO'ed skbs
Date: Wed,  6 Jan 2016 17:59:35 +0530
Message-ID: <1452083376-7180-3-git-send-email-hariprasad@chelsio.com>
References: <1452083376-7180-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, JBottomley@odin.com,
	martin.petersen@oracle.com, leedom@chelsio.com, kxie@chelsio.com,
	manojmalviya@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:19494 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751992AbcAFM2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 07:28:07 -0500
In-Reply-To: <1452083376-7180-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skbs could contain both paritial pdus and multiple completed pdus.

Signed-off-by: Karen Xie <kxie@chelsio.com>
Signed-off-by: Manoj Malviya <manojmalviya@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/scsi/cxgbi/libcxgbi.c | 415 +++++++++++++++++++++++++++++++++---------
 drivers/scsi/cxgbi/libcxgbi.h |   4 +
 2 files changed, 330 insertions(+), 89 deletions(-)

diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index f3bb7af..dc9b470 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -35,6 +35,7 @@
 static unsigned int dbg_level;
 
 #include "libcxgbi.h"
+#include "cxgbi_lro.h"
 
 #define DRV_MODULE_NAME		"libcxgbi"
 #define DRV_MODULE_DESC		"Chelsio iSCSI driver library"
@@ -533,6 +534,7 @@ static void sock_put_port(struct cxgbi_sock *csk)
 /*
  * iscsi tcp connection
  */
+static void skb_lro_hold_done(struct cxgbi_sock *csk);
 void cxgbi_sock_free_cpl_skbs(struct cxgbi_sock *csk)
 {
 	if (csk->cpl_close) {
@@ -547,6 +549,11 @@ void cxgbi_sock_free_cpl_skbs(struct cxgbi_sock *csk)
 		kfree_skb(csk->cpl_abort_rpl);
 		csk->cpl_abort_rpl = NULL;
 	}
+	if (csk->skb_lro_hold) {
+		skb_lro_hold_done(csk);
+		kfree_skb(csk->skb_lro_hold);
+		csk->skb_lro_hold = NULL;
+	}
 }
 EXPORT_SYMBOL_GPL(cxgbi_sock_free_cpl_skbs);
 
@@ -1145,15 +1152,15 @@ static int cxgbi_sock_send_pdus(struct cxgbi_sock *csk, struct sk_buff *skb)
 
 		if (unlikely(skb_headroom(skb) < cdev->skb_tx_rsvd)) {
 			pr_err("csk 0x%p, skb head %u < %u.\n",
-				csk, skb_headroom(skb), cdev->skb_tx_rsvd);
+			       csk, skb_headroom(skb), cdev->skb_tx_rsvd);
 			err = -EINVAL;
 			goto out_err;
 		}
 
 		if (frags >= SKB_WR_LIST_SIZE) {
 			pr_err("csk 0x%p, frags %d, %u,%u >%u.\n",
-				csk, skb_shinfo(skb)->nr_frags, skb->len,
-				skb->data_len, (uint)(SKB_WR_LIST_SIZE));
+			       csk, skb_shinfo(skb)->nr_frags, skb->len,
+			       skb->data_len, (uint)(SKB_WR_LIST_SIZE));
 			err = -EINVAL;
 			goto out_err;
 		}
@@ -1776,10 +1783,8 @@ EXPORT_SYMBOL_GPL(cxgbi_conn_tx_open);
 /*
  * pdu receive, interact with libiscsi_tcp
  */
-static inline int read_pdu_skb(struct iscsi_conn *conn,
-			       struct sk_buff *skb,
-			       unsigned int offset,
-			       int offloaded)
+static inline int read_pdu_skb(struct iscsi_conn *conn, struct sk_buff *skb,
+			       unsigned int offset, int offloaded)
 {
 	int status = 0;
 	int bytes_read;
@@ -1817,7 +1822,8 @@ static inline int read_pdu_skb(struct iscsi_conn *conn,
 	}
 }
 
-static int skb_read_pdu_bhs(struct iscsi_conn *conn, struct sk_buff *skb)
+static int skb_read_pdu_bhs(struct iscsi_conn *conn, struct sk_buff *skb,
+			    unsigned int offset, unsigned long *flag)
 {
 	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
 
@@ -1831,18 +1837,18 @@ static int skb_read_pdu_bhs(struct iscsi_conn *conn, struct sk_buff *skb)
 		return -EIO;
 	}
 
-	if (conn->hdrdgst_en &&
-	    cxgbi_skcb_test_flag(skb, SKCBF_RX_HCRC_ERR)) {
+	if (conn->hdrdgst_en && test_bit(SKCBF_RX_HCRC_ERR, flag)) {
 		pr_info("conn 0x%p, skb 0x%p, hcrc.\n", conn, skb);
 		iscsi_conn_failure(conn, ISCSI_ERR_HDR_DGST);
 		return -EIO;
 	}
 
-	return read_pdu_skb(conn, skb, 0, 0);
+	return read_pdu_skb(conn, skb, offset, 0);
 }
 
 static int skb_read_pdu_data(struct iscsi_conn *conn, struct sk_buff *lskb,
-			     struct sk_buff *skb, unsigned int offset)
+			     struct sk_buff *skb, unsigned int offset,
+			     unsigned long *flag)
 {
 	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
 	bool offloaded = 0;
@@ -1850,12 +1856,11 @@ static int skb_read_pdu_data(struct iscsi_conn *conn, struct sk_buff *lskb,
 
 	log_debug(1 << CXGBI_DBG_PDU_RX,
 		"conn 0x%p, skb 0x%p, len %u, flag 0x%lx.\n",
-		conn, skb, skb->len, cxgbi_skcb_flags(skb));
+		conn, skb, skb->len, *flag);
 
-	if (conn->datadgst_en &&
-	    cxgbi_skcb_test_flag(lskb, SKCBF_RX_DCRC_ERR)) {
+	if (conn->datadgst_en && test_bit(SKCBF_RX_DCRC_ERR, flag)) {
 		pr_info("conn 0x%p, skb 0x%p, dcrc 0x%lx.\n",
-			conn, lskb, cxgbi_skcb_flags(lskb));
+			conn, lskb, *flag);
 		iscsi_conn_failure(conn, ISCSI_ERR_DATA_DGST);
 		return -EIO;
 	}
@@ -1867,7 +1872,7 @@ static int skb_read_pdu_data(struct iscsi_conn *conn, struct sk_buff *lskb,
 	if (lskb == skb && conn->hdrdgst_en)
 		offset += ISCSI_DIGEST_SIZE;
 
-	if (cxgbi_skcb_test_flag(lskb, SKCBF_RX_DATA_DDPD))
+	if (test_bit(SKCBF_RX_DATA_DDPD, flag))
 		offloaded = 1;
 
 	if (opcode == ISCSI_OP_SCSI_DATA_IN)
@@ -1905,11 +1910,304 @@ static void csk_return_rx_credits(struct cxgbi_sock *csk, int copied)
 		csk->rcv_wup += cdev->csk_send_rx_credits(csk, credits);
 }
 
+static struct sk_buff *cxgbi_conn_rxq_get_skb(struct cxgbi_sock *csk)
+{
+	struct sk_buff *skb = skb_peek(&csk->receive_queue);
+
+	if (!skb)
+		return NULL;
+	if (!(cxgbi_skcb_test_flag(skb, SKCBF_RX_LRO)) &&
+	    !(cxgbi_skcb_test_flag(skb, SKCBF_RX_STATUS))) {
+		log_debug(1 << CXGBI_DBG_PDU_RX,
+			  "skb 0x%p, NOT ready 0x%lx.\n",
+			  skb, cxgbi_skcb_flags(skb));
+		return NULL;
+	}
+	__skb_unlink(skb, &csk->receive_queue);
+	return skb;
+}
+
+void cxgbi_lro_skb_dump(struct sk_buff *skb)
+{
+	struct skb_shared_info *ssi = skb_shinfo(skb);
+	struct cxgbi_rx_lro_cb *lro_cb = cxgbi_skb_rx_lro_cb(skb);
+	struct cxgbi_rx_pdu_cb *pdu_cb = cxgbi_skb_rx_pdu_cb(skb, 0);
+	int i;
+
+	pr_info("skb 0x%p, head 0x%p, 0x%p, len %u,%u, frags %u.\n",
+		skb, skb->head, skb->data, skb->len, skb->data_len,
+		ssi->nr_frags);
+	pr_info("skb 0x%p, lro_cb, csk 0x%p, pdu %u, %u.\n",
+		skb, lro_cb->csk, lro_cb->pdu_cnt, lro_cb->pdu_totallen);
+
+	for (i = 0; i < lro_cb->pdu_cnt; i++, pdu_cb++)
+		pr_info("0x%p, pdu %d,%u,0x%lx,seq 0x%x,dcrc 0x%x,frags %u.\n",
+			skb, i, pdu_cb->pdulen, pdu_cb->flags, pdu_cb->seq,
+			pdu_cb->ddigest, pdu_cb->frags);
+	for (i = 0; i < ssi->nr_frags; i++)
+		pr_info("skb 0x%p, frag %d, off %u, sz %u.\n",
+			skb, i, ssi->frags[i].page_offset, ssi->frags[i].size);
+}
+EXPORT_SYMBOL_GPL(cxgbi_lro_skb_dump);
+
+static void skb_lro_hold_done(struct cxgbi_sock *csk)
+{
+	struct sk_buff *skb = csk->skb_lro_hold;
+	struct cxgbi_rx_lro_cb *lro_cb = cxgbi_skb_rx_lro_cb(skb);
+
+	if (lro_cb->flags & CXGBI_LRO_CB_USED) {
+		struct skb_shared_info *ssi = skb_shinfo(skb);
+		int i;
+
+		memset(skb->data, 0, LRO_SKB_MIN_HEADROOM);
+		for (i = 0; i < ssi->nr_frags; i++)
+			put_page(skb_frag_page(&ssi->frags[i]));
+		ssi->nr_frags = 0;
+	}
+}
+
+static void skb_lro_hold_merge(struct cxgbi_sock *csk, struct sk_buff *skb,
+			       int pdu_idx)
+{
+	struct sk_buff *hskb = csk->skb_lro_hold;
+	struct skb_shared_info *hssi = skb_shinfo(hskb);
+	struct cxgbi_rx_lro_cb *hlro_cb = cxgbi_skb_rx_lro_cb(hskb);
+	struct cxgbi_rx_pdu_cb *hpdu_cb = cxgbi_skb_rx_pdu_cb(hskb, 0);
+	struct skb_shared_info *ssi = skb_shinfo(skb);
+	struct cxgbi_rx_pdu_cb *pdu_cb = cxgbi_skb_rx_pdu_cb(skb, pdu_idx);
+	int frag_idx = 0;
+	int hfrag_idx = 0;
+
+	/* the partial pdu is either 1st or last */
+	if (pdu_idx)
+		frag_idx = ssi->nr_frags - pdu_cb->frags;
+
+	if (cxgbi_rx_cb_test_flag(pdu_cb, SKCBF_RX_HDR)) {
+		unsigned int len = 0;
+
+		skb_lro_hold_done(csk);
+
+		hlro_cb->csk = csk;
+		hlro_cb->pdu_cnt = 1;
+		hlro_cb->flags = CXGBI_LRO_CB_USED;
+
+		hpdu_cb->flags = pdu_cb->flags;
+		hpdu_cb->seq = pdu_cb->seq;
+
+		memcpy(&hssi->frags[hfrag_idx], &ssi->frags[frag_idx],
+		       sizeof(skb_frag_t));
+		get_page(skb_frag_page(&hssi->frags[hfrag_idx]));
+		frag_idx++;
+		hfrag_idx++;
+		hssi->nr_frags = 1;
+		hpdu_cb->frags = 1;
+
+		len = hssi->frags[0].size;
+		hskb->len = len;
+		hskb->data_len = len;
+		hskb->truesize = len;
+	}
+
+	if (cxgbi_rx_cb_test_flag(pdu_cb, SKCBF_RX_DATA)) {
+		unsigned int len = 0;
+		int i, n;
+
+		hpdu_cb->flags |= pdu_cb->flags;
+
+		for (i = 1, n = hfrag_idx; n < pdu_cb->frags;
+		     i++, frag_idx++, n++) {
+			memcpy(&hssi->frags[i], &ssi->frags[frag_idx],
+			       sizeof(skb_frag_t));
+			get_page(skb_frag_page(&hssi->frags[i]));
+			len += hssi->frags[i].size;
+
+			hssi->nr_frags++;
+			hpdu_cb->frags++;
+		}
+		hskb->len += len;
+		hskb->data_len += len;
+		hskb->truesize += len;
+	}
+
+	if (cxgbi_rx_cb_test_flag(pdu_cb, SKCBF_RX_STATUS)) {
+		hpdu_cb->flags |= pdu_cb->flags;
+		hpdu_cb->ddigest = pdu_cb->ddigest;
+		hpdu_cb->pdulen = pdu_cb->pdulen;
+		hlro_cb->pdu_totallen = pdu_cb->pdulen;
+	}
+}
+
+static int rx_skb_lro_read_pdu(struct sk_buff *skb, struct iscsi_conn *conn,
+			       unsigned int *off_p, int idx)
+{
+	struct cxgbi_rx_pdu_cb *pdu_cb = cxgbi_skb_rx_pdu_cb(skb, idx);
+	unsigned int offset = *off_p;
+	int err = 0;
+
+	err = skb_read_pdu_bhs(conn, skb, offset, &pdu_cb->flags);
+	if (err < 0) {
+		pr_err("conn 0x%p, bhs, skb 0x%p, pdu %d, offset %u.\n",
+		       conn, skb, idx, offset);
+		cxgbi_lro_skb_dump(skb);
+		goto done;
+	}
+	offset += err;
+
+	err = skb_read_pdu_data(conn, skb, skb, offset, &pdu_cb->flags);
+	if (err < 0) {
+		pr_err("%s: conn 0x%p data, skb 0x%p, pdu %d.\n",
+		       __func__, conn, skb, idx);
+		cxgbi_lro_skb_dump(skb);
+		goto done;
+	}
+	offset += err;
+	if (conn->hdrdgst_en)
+		offset += ISCSI_DIGEST_SIZE;
+
+done:
+	*off_p = offset;
+	return err;
+}
+
+static int rx_skb_lro(struct sk_buff *skb, struct cxgbi_device *cdev,
+		      struct cxgbi_sock *csk, struct iscsi_conn *conn,
+		      unsigned int *read)
+{
+	struct sk_buff *hskb = csk->skb_lro_hold;
+	struct cxgbi_rx_lro_cb *lro_cb = cxgbi_skb_rx_lro_cb(skb);
+	struct cxgbi_rx_pdu_cb *pdu_cb = cxgbi_skb_rx_pdu_cb(skb, 0);
+	int last = lro_cb->pdu_cnt - 1;
+	int i = 0;
+	int err = 0;
+	unsigned int offset = 0;
+
+	if (!cxgbi_rx_cb_test_flag(pdu_cb, SKCBF_RX_HDR)) {
+		/* there could be partial pdus spanning 2 lro skbs */
+		skb_lro_hold_merge(csk, skb, 0);
+
+		if (cxgbi_rx_cb_test_flag(pdu_cb, SKCBF_RX_STATUS)) {
+			unsigned int dummy = 0;
+
+			err = rx_skb_lro_read_pdu(hskb, conn, &dummy, 0);
+			if (err < 0)
+				goto done;
+
+			if (pdu_cb->frags) {
+				struct skb_shared_info *ssi = skb_shinfo(skb);
+				int k;
+
+				for (k = 0; k < pdu_cb->frags; k++)
+					offset += ssi->frags[k].size;
+			}
+		}
+		i = 1;
+	}
+
+	for (; i < last; i++, pdu_cb++) {
+		err = rx_skb_lro_read_pdu(skb, conn, &offset, i);
+		if (err < 0)
+			goto done;
+	}
+
+	if (i == last) {
+		pdu_cb = cxgbi_skb_rx_pdu_cb(skb, last);
+		if (!cxgbi_rx_cb_test_flag(pdu_cb, SKCBF_RX_STATUS)) {
+			skb_lro_hold_merge(csk, skb, last);
+		} else {
+			err = rx_skb_lro_read_pdu(skb, conn, &offset, last);
+			if (err < 0)
+				goto done;
+		}
+	}
+
+	*read += lro_cb->pdu_totallen;
+
+done:
+	__kfree_skb(skb);
+	return err;
+}
+
+static int rx_skb_coalesced(struct sk_buff *skb, struct cxgbi_device *cdev,
+			    struct cxgbi_sock *csk, struct iscsi_conn *conn,
+			    unsigned int *read)
+{
+	int err = 0;
+
+	*read += cxgbi_skcb_rx_pdulen(skb);
+
+	err = skb_read_pdu_bhs(conn, skb, 0, &cxgbi_skcb_flags(skb));
+	if (err < 0) {
+		pr_err("bhs, csk 0x%p, skb 0x%p,%u, f 0x%lx, plen %u.\n",
+		       csk, skb, skb->len, cxgbi_skcb_flags(skb),
+		       cxgbi_skcb_rx_pdulen(skb));
+		pr_info("bhs %*ph\n", 48, skb->data);
+		goto done;
+	}
+
+	err = skb_read_pdu_data(conn, skb, skb, err + cdev->skb_rx_extra,
+				&cxgbi_skcb_flags(skb));
+	if (err < 0) {
+		pr_err("data, csk 0x%p, skb 0x%p,%u, f 0x%lx, plen %u.\n",
+		       csk, skb, skb->len, cxgbi_skcb_flags(skb),
+		       cxgbi_skcb_rx_pdulen(skb));
+		pr_info("bhs %*ph\n", 48, skb->data);
+	}
+
+done:
+	__kfree_skb(skb);
+	return err;
+}
+
+static int rx_skb(struct sk_buff *skb, struct cxgbi_device *cdev,
+		  struct cxgbi_sock *csk, struct iscsi_conn *conn,
+		  unsigned int *read)
+{
+	int err = 0;
+
+	*read += cxgbi_skcb_rx_pdulen(skb);
+
+	err = skb_read_pdu_bhs(conn, skb, 0, &cxgbi_skcb_flags(skb));
+	if (err < 0) {
+		pr_err("bhs, csk 0x%p, skb 0x%p,%u, f 0x%lx, plen %u.\n",
+		       csk, skb, skb->len, cxgbi_skcb_flags(skb),
+		       cxgbi_skcb_rx_pdulen(skb));
+		pr_err("bhs %*ph\n", 48, skb->data);
+		goto done;
+	}
+
+	if (cxgbi_skcb_test_flag(skb, SKCBF_RX_DATA)) {
+		struct sk_buff *dskb = skb_peek(&csk->receive_queue);
+
+		if (!dskb) {
+			pr_err("csk 0x%p, NO data.\n", csk);
+			err = -EAGAIN;
+			goto done;
+		}
+		__skb_unlink(dskb, &csk->receive_queue);
+
+		err = skb_read_pdu_data(conn, skb, dskb, 0,
+					&cxgbi_skcb_flags(skb));
+		if (err < 0) {
+			pr_err("data, csk 0x%p, 0x%p,%u, 0x%p,%u,0x%lx,%u.\n",
+			       csk, skb, skb->len, dskb, dskb->len,
+			       cxgbi_skcb_flags(dskb),
+			       cxgbi_skcb_rx_pdulen(dskb));
+			pr_info("bhs %*ph\n", 48, skb->data);
+		}
+		__kfree_skb(dskb);
+	} else
+		err = skb_read_pdu_data(conn, skb, skb, 0,
+					&cxgbi_skcb_flags(skb));
+
+done:
+	__kfree_skb(skb);
+	return err;
+}
+
 void cxgbi_conn_pdu_ready(struct cxgbi_sock *csk)
 {
 	struct cxgbi_device *cdev = csk->cdev;
 	struct iscsi_conn *conn = csk->user_data;
-	struct sk_buff *skb;
 	unsigned int read = 0;
 	int err = 0;
 
@@ -1925,83 +2223,22 @@ void cxgbi_conn_pdu_ready(struct cxgbi_sock *csk)
 	}
 
 	while (!err) {
-		skb = skb_peek(&csk->receive_queue);
-		if (!skb ||
-		    !(cxgbi_skcb_test_flag(skb, SKCBF_RX_STATUS))) {
-			if (skb)
-				log_debug(1 << CXGBI_DBG_PDU_RX,
-					"skb 0x%p, NOT ready 0x%lx.\n",
-					skb, cxgbi_skcb_flags(skb));
+		struct sk_buff *skb = cxgbi_conn_rxq_get_skb(csk);
+
+		if (!skb)
 			break;
-		}
-		__skb_unlink(skb, &csk->receive_queue);
 
-		read += cxgbi_skcb_rx_pdulen(skb);
 		log_debug(1 << CXGBI_DBG_PDU_RX,
 			"csk 0x%p, skb 0x%p,%u,f 0x%lx, pdu len %u.\n",
 			csk, skb, skb->len, cxgbi_skcb_flags(skb),
 			cxgbi_skcb_rx_pdulen(skb));
 
-		if (cxgbi_skcb_test_flag(skb, SKCBF_RX_COALESCED)) {
-			err = skb_read_pdu_bhs(conn, skb);
-			if (err < 0) {
-				pr_err("coalesced bhs, csk 0x%p, skb 0x%p,%u, "
-					"f 0x%lx, plen %u.\n",
-					csk, skb, skb->len,
-					cxgbi_skcb_flags(skb),
-					cxgbi_skcb_rx_pdulen(skb));
-				goto skb_done;
-			}
-			err = skb_read_pdu_data(conn, skb, skb,
-						err + cdev->skb_rx_extra);
-			if (err < 0)
-				pr_err("coalesced data, csk 0x%p, skb 0x%p,%u, "
-					"f 0x%lx, plen %u.\n",
-					csk, skb, skb->len,
-					cxgbi_skcb_flags(skb),
-					cxgbi_skcb_rx_pdulen(skb));
-		} else {
-			err = skb_read_pdu_bhs(conn, skb);
-			if (err < 0) {
-				pr_err("bhs, csk 0x%p, skb 0x%p,%u, "
-					"f 0x%lx, plen %u.\n",
-					csk, skb, skb->len,
-					cxgbi_skcb_flags(skb),
-					cxgbi_skcb_rx_pdulen(skb));
-				goto skb_done;
-			}
-
-			if (cxgbi_skcb_test_flag(skb, SKCBF_RX_DATA)) {
-				struct sk_buff *dskb;
-
-				dskb = skb_peek(&csk->receive_queue);
-				if (!dskb) {
-					pr_err("csk 0x%p, skb 0x%p,%u, f 0x%lx,"
-						" plen %u, NO data.\n",
-						csk, skb, skb->len,
-						cxgbi_skcb_flags(skb),
-						cxgbi_skcb_rx_pdulen(skb));
-					err = -EIO;
-					goto skb_done;
-				}
-				__skb_unlink(dskb, &csk->receive_queue);
-
-				err = skb_read_pdu_data(conn, skb, dskb, 0);
-				if (err < 0)
-					pr_err("data, csk 0x%p, skb 0x%p,%u, "
-						"f 0x%lx, plen %u, dskb 0x%p,"
-						"%u.\n",
-						csk, skb, skb->len,
-						cxgbi_skcb_flags(skb),
-						cxgbi_skcb_rx_pdulen(skb),
-						dskb, dskb->len);
-				__kfree_skb(dskb);
-			} else
-				err = skb_read_pdu_data(conn, skb, skb, 0);
-		}
-skb_done:
-		__kfree_skb(skb);
-
+		if (cxgbi_skcb_test_flag(skb, SKCBF_RX_LRO))
+			err = rx_skb_lro(skb, cdev, csk, conn, &read);
+		else if (cxgbi_skcb_test_flag(skb, SKCBF_RX_COALESCED))
+			err = rx_skb_coalesced(skb, cdev, csk, conn, &read);
+		else
+			err = rx_skb(skb, cdev, csk, conn, &read);
 		if (err < 0)
 			break;
 	}
@@ -2014,7 +2251,7 @@ skb_done:
 	}
 
 	if (err < 0) {
-		pr_info("csk 0x%p, 0x%p, rx failed %d, read %u.\n",
+		pr_info("csk 0x%p,0x%p, rx failed %d, read %u.\n",
 			csk, conn, err, read);
 		iscsi_conn_failure(conn, ISCSI_ERR_CONN_FAILED);
 	}
diff --git a/drivers/scsi/cxgbi/libcxgbi.h b/drivers/scsi/cxgbi/libcxgbi.h
index 9842301..13ec7d7 100644
--- a/drivers/scsi/cxgbi/libcxgbi.h
+++ b/drivers/scsi/cxgbi/libcxgbi.h
@@ -208,6 +208,8 @@ struct cxgbi_sock {
 	struct sk_buff *cpl_abort_req;
 	struct sk_buff *cpl_abort_rpl;
 	struct sk_buff *skb_ulp_lhdr;
+	struct sk_buff *skb_lro;	/* accumulated rx so far */
+	struct sk_buff *skb_lro_hold;	/* holds a partial pdu */
 	spinlock_t lock;
 	struct kref refcnt;
 	unsigned int state;
@@ -279,6 +281,7 @@ struct cxgbi_skb_tx_cb {
 
 enum cxgbi_skcb_flags {
 	SKCBF_TX_NEED_HDR,	/* packet needs a header */
+	SKCBF_RX_LRO,		/* received via lro */
 	SKCBF_RX_COALESCED,	/* received whole pdu */
 	SKCBF_RX_HDR,		/* received pdu header */
 	SKCBF_RX_DATA,		/* received pdu payload */
@@ -752,4 +755,5 @@ void cxgbi_ddp_page_size_factor(int *);
 void cxgbi_ddp_ppod_clear(struct cxgbi_pagepod *);
 void cxgbi_ddp_ppod_set(struct cxgbi_pagepod *, struct cxgbi_pagepod_hdr *,
 			struct cxgbi_gather_list *, unsigned int);
+
 #endif	/*__LIBCXGBI_H__*/
-- 
2.3.4
