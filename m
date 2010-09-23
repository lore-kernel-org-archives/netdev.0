From: kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Subject: [PATCH 2/4] libcxgbi: pdu read fixes
Date: Thu, 23 Sep 2010 16:43:23 -0700
Message-ID: <201009232343.o8NNhNhw006463@localhost.localdomain>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
        James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <open-iscsi+bncCNvLk8fsDxCmzO_kBBoEi8W44Q-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post?hl=en_US>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/?hl=en_US>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi?hl=en_US>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
 <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
 <mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

[PATCH 2/4] libcxgbi: pdu read fixes
          
From: Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
          
This patch
- fixed the locking and releasing skb in the case of error in the pdu read path, and
- added define iscsi_task_cxgbi_data to access the private data inside the iscsi_task.

Signed-off-by: Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---

 drivers/scsi/cxgbi/libcxgbi.c |   79 ++++++++++++++++++++++++++---------------
 drivers/scsi/cxgbi/libcxgbi.h |    2 +
 2 files changed, 53 insertions(+), 28 deletions(-)


diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index db9d08a..7136fb2 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -593,11 +593,11 @@ static void cxgbi_inform_iscsi_conn_closing(struct cxgbi_sock *csk)
 		csk, csk->state, csk->flags, csk->user_data);
 
 	if (csk->state != CTP_ESTABLISHED) {
-		read_lock(&csk->callback_lock);
+		read_lock_bh(&csk->callback_lock);
 		if (csk->user_data)
 			iscsi_conn_failure(csk->user_data,
 					ISCSI_ERR_CONN_FAILED);
-		read_unlock(&csk->callback_lock);
+		read_unlock_bh(&csk->callback_lock);
 	}
 }
 
@@ -1712,12 +1712,10 @@ void cxgbi_conn_pdu_ready(struct cxgbi_sock *csk)
 			"csk 0x%p, conn 0x%p, id %d, suspend_rx %lu!\n",
 			csk, conn, conn ? conn->id : 0xFF,
 			conn ? conn->suspend_rx : 0xFF);
-		read_unlock(&csk->callback_lock);
 		return;
 	}
 
 	while (!err) {
-		read_lock(&csk->callback_lock);
 		skb = skb_peek(&csk->receive_queue);
 		if (!skb ||
 		    !(cxgbi_skcb_test_flag(skb, SKCBF_RX_STATUS))) {
@@ -1725,11 +1723,9 @@ void cxgbi_conn_pdu_ready(struct cxgbi_sock *csk)
 				log_debug(1 << CXGBI_DBG_PDU_RX,
 					"skb 0x%p, NOT ready 0x%lx.\n",
 					skb, cxgbi_skcb_flags(skb));
-			read_unlock(&csk->callback_lock);
 			break;
 		}
 		__skb_unlink(skb, &csk->receive_queue);
-		read_unlock(&csk->callback_lock);
 
 		read += cxgbi_skcb_rx_pdulen(skb);
 		log_debug(1 << CXGBI_DBG_PDU_RX,
@@ -1739,37 +1735,66 @@ void cxgbi_conn_pdu_ready(struct cxgbi_sock *csk)
 
 		if (cxgbi_skcb_test_flag(skb, SKCBF_RX_COALESCED)) {
 			err = skb_read_pdu_bhs(conn, skb);
-			if (err < 0)
-				break;
+			if (err < 0) {
+				pr_err("coalesced bhs, csk 0x%p, skb 0x%p,%u, "
+					"f 0x%lx, plen %u.\n",
+					csk, skb, skb->len,
+					cxgbi_skcb_flags(skb),
+					cxgbi_skcb_rx_pdulen(skb));
+				goto skb_done;
+			}
 			err = skb_read_pdu_data(conn, skb, skb,
 						err + cdev->skb_rx_extra);
+			if (err < 0)
+				pr_err("coalesced data, csk 0x%p, skb 0x%p,%u, "
+					"f 0x%lx, plen %u.\n",
+					csk, skb, skb->len,
+					cxgbi_skcb_flags(skb),
+					cxgbi_skcb_rx_pdulen(skb));
 		} else {
 			err = skb_read_pdu_bhs(conn, skb);
-			if (err < 0)
-				break;
+			if (err < 0) {
+				pr_err("bhs, csk 0x%p, skb 0x%p,%u, "
+					"f 0x%lx, plen %u.\n",
+					csk, skb, skb->len,
+					cxgbi_skcb_flags(skb),
+					cxgbi_skcb_rx_pdulen(skb));
+				goto skb_done;
+			}
+
 			if (cxgbi_skcb_test_flag(skb, SKCBF_RX_DATA)) {
 				struct sk_buff *dskb;
 
-				read_lock(&csk->callback_lock);
 				dskb = skb_peek(&csk->receive_queue);
 				if (!dskb) {
-					read_unlock(&csk->callback_lock);
-					pr_err("csk 0x%p, NO data.\n", csk);
-					err = -EAGAIN;
-					break;
+					pr_err("csk 0x%p, skb 0x%p,%u, f 0x%lx,"
+						" plen %u, NO data.\n",
+						csk, skb, skb->len,
+						cxgbi_skcb_flags(skb),
+						cxgbi_skcb_rx_pdulen(skb));
+					err = -EIO;
+					goto skb_done;
 				}
 				__skb_unlink(dskb, &csk->receive_queue);
-				read_unlock(&csk->callback_lock);
 
 				err = skb_read_pdu_data(conn, skb, dskb, 0);
+				if (err < 0)
+					pr_err("data, csk 0x%p, skb 0x%p,%u, "
+						"f 0x%lx, plen %u, dskb 0x%p,"
+						"%u.\n",
+						csk, skb, skb->len,
+						cxgbi_skcb_flags(skb),
+						cxgbi_skcb_rx_pdulen(skb),
+						dskb, dskb->len);
 				__kfree_skb(dskb);
 			} else
 				err = skb_read_pdu_data(conn, skb, skb, 0);
 		}
+skb_done:
+		__kfree_skb(skb);
+
 		if (err < 0)
 			break;
-
-		__kfree_skb(skb);
 	}
 
 	log_debug(1 << CXGBI_DBG_PDU_RX, "csk 0x%p, read %u.\n", csk, read);
@@ -1780,7 +1805,8 @@ void cxgbi_conn_pdu_ready(struct cxgbi_sock *csk)
 	}
 
 	if (err < 0) {
-		pr_info("csk 0x%p, 0x%p, rx failed %d.\n", csk, conn, err);
+		pr_info("csk 0x%p, 0x%p, rx failed %d, read %u.\n",
+			csk, conn, err, read);
 		iscsi_conn_failure(conn, ISCSI_ERR_CONN_FAILED);
 	}
 }
@@ -1861,7 +1887,7 @@ int cxgbi_conn_alloc_pdu(struct iscsi_task *task, u8 opcode)
 	struct cxgbi_device *cdev = cconn->chba->cdev;
 	struct iscsi_conn *conn = task->conn;
 	struct iscsi_tcp_task *tcp_task = task->dd_data;
-	struct cxgbi_task_data *tdata = task->dd_data + sizeof(*tcp_task);
+	struct cxgbi_task_data *tdata = iscsi_task_cxgbi_data(task);
 	struct scsi_cmnd *sc = task->sc;
 	int headroom = SKB_TX_ISCSI_PDU_HEADER_MAX;
 
@@ -1916,8 +1942,7 @@ int cxgbi_conn_init_pdu(struct iscsi_task *task, unsigned int offset,
 			      unsigned int count)
 {
 	struct iscsi_conn *conn = task->conn;
-	struct iscsi_tcp_task *tcp_task = task->dd_data;
-	struct cxgbi_task_data *tdata = tcp_task->dd_data;
+	struct cxgbi_task_data *tdata = iscsi_task_cxgbi_data(task);
 	struct sk_buff *skb = tdata->skb;
 	unsigned int datalen = count;
 	int i, padlen = iscsi_padding(count);
@@ -2019,8 +2044,7 @@ int cxgbi_conn_xmit_pdu(struct iscsi_task *task)
 {
 	struct iscsi_tcp_conn *tcp_conn = task->conn->dd_data;
 	struct cxgbi_conn *cconn = tcp_conn->dd_data;
-	struct iscsi_tcp_task *tcp_task = task->dd_data;
-	struct cxgbi_task_data *tdata = tcp_task->dd_data;
+	struct cxgbi_task_data *tdata = iscsi_task_cxgbi_data(task);
 	struct sk_buff *skb = tdata->skb;
 	unsigned int datalen;
 	int err;
@@ -2072,8 +2096,7 @@ EXPORT_SYMBOL_GPL(cxgbi_conn_xmit_pdu);
 
 void cxgbi_cleanup_task(struct iscsi_task *task)
 {
-	struct cxgbi_task_data *tdata = task->dd_data +
-				sizeof(struct iscsi_tcp_task);
+	struct cxgbi_task_data *tdata = iscsi_task_cxgbi_data(task);
 
 	log_debug(1 << CXGBI_DBG_ISCSI,
 		"task 0x%p, skb 0x%p, itt 0x%x.\n",
@@ -2290,12 +2313,12 @@ int cxgbi_bind_conn(struct iscsi_cls_session *cls_session,
 	/*  calculate the tag idx bits needed for this conn based on cmds_max */
 	cconn->task_idx_bits = (__ilog2_u32(conn->session->cmds_max - 1)) + 1;
 
-	write_lock(&csk->callback_lock);
+	write_lock_bh(&csk->callback_lock);
 	csk->user_data = conn;
 	cconn->chba = cep->chba;
 	cconn->cep = cep;
 	cep->cconn = cconn;
-	write_unlock(&csk->callback_lock);
+	write_unlock_bh(&csk->callback_lock);
 
 	cxgbi_conn_max_xmit_dlength(conn);
 	cxgbi_conn_max_recv_dlength(conn);
diff --git a/drivers/scsi/cxgbi/libcxgbi.h b/drivers/scsi/cxgbi/libcxgbi.h
index 2f2485b..48e6d62 100644
--- a/drivers/scsi/cxgbi/libcxgbi.h
+++ b/drivers/scsi/cxgbi/libcxgbi.h
@@ -592,6 +592,8 @@ struct cxgbi_task_data {
 	unsigned int count;
 	unsigned int sgoffset;
 };
+#define iscsi_task_cxgbi_data(task) \
+	((task)->dd_data + sizeof(struct iscsi_tcp_task))
 
 static inline int cxgbi_is_ddp_tag(struct cxgbi_tag_format *tformat, u32 tag)
 {

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To unsubscribe from this group, send email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi?hl=en.
