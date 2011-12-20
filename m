From: frank.blaschka@de.ibm.com
Subject: [patch 10/10] [PATCH] qeth: recovery through asynchronous delivery
Date: Tue, 20 Dec 2011 09:56:36 +0100
Message-ID: <20111220085736.554049167@de.ibm.com>
References: <20111220085626.924756639@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Einar Lueck <elelueck@de.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:38231 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690Ab1LTI6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 03:58:01 -0500
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 20 Dec 2011 08:57:59 -0000
Content-Disposition: inline; filename=611-qeth-async-recovery.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Einar Lueck <elelueck@de.ibm.com>

If recovery is triggered in presence of pending asynchronous
deliveries of storage blocks we do a forced cleanup after
the corresponding tasklets are completely stopped and trigger
appropriate notifications for the correspondingerror state.

Signed-off-by: Einar Lueck <elelueck@de.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |   34 +++++++++++++++++++++++++++++-----
 drivers/s390/net/qeth_l3_main.c   |    5 +++++
 2 files changed, 34 insertions(+), 5 deletions(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -66,7 +66,7 @@ static void qeth_release_skbs(struct qet
 static void qeth_clear_output_buffer(struct qeth_qdio_out_q *queue,
 		struct qeth_qdio_out_buffer *buf,
 		enum qeth_qdio_buffer_states newbufstate);
-
+static int qeth_init_qdio_out_buf(struct qeth_qdio_out_q *, int);
 
 static inline const char *qeth_get_cardname(struct qeth_card *card)
 {
@@ -363,6 +363,9 @@ static inline enum iucv_tx_notify qeth_c
 static inline void qeth_cleanup_handled_pending(struct qeth_qdio_out_q *q,
 	int bidx, int forced_cleanup)
 {
+	if (q->card->options.cq != QETH_CQ_ENABLED)
+		return;
+
 	if (q->bufs[bidx]->next_pending != NULL) {
 		struct qeth_qdio_out_buffer *head = q->bufs[bidx];
 		struct qeth_qdio_out_buffer *c = q->bufs[bidx]->next_pending;
@@ -390,6 +393,13 @@ static inline void qeth_cleanup_handled_
 
 		}
 	}
+	if (forced_cleanup && (atomic_read(&(q->bufs[bidx]->state)) ==
+					QETH_QDIO_BUF_HANDLED_DELAYED)) {
+		/* for recovery situations */
+		q->bufs[bidx]->aob = q->bufstates[bidx].aob;
+		qeth_init_qdio_out_buf(q, bidx);
+		QETH_CARD_TEXT(q->card, 2, "clprecov");
+	}
 }
 
 
@@ -412,7 +422,6 @@ static inline void qeth_qdio_handle_aob(
 		notification = TX_NOTIFY_OK;
 	} else {
 		BUG_ON(atomic_read(&buffer->state) != QETH_QDIO_BUF_PENDING);
-
 		atomic_set(&buffer->state, QETH_QDIO_BUF_IN_CQ);
 		notification = TX_NOTIFY_DELAYED_OK;
 	}
@@ -425,7 +434,8 @@ static inline void qeth_qdio_handle_aob(
 
 	buffer->aob = NULL;
 	qeth_clear_output_buffer(buffer->q, buffer,
-				QETH_QDIO_BUF_HANDLED_DELAYED);
+				 QETH_QDIO_BUF_HANDLED_DELAYED);
+
 	/* from here on: do not touch buffer anymore */
 	qdio_release_aob(aob);
 }
@@ -1113,11 +1123,25 @@ out:
 static void qeth_release_skbs(struct qeth_qdio_out_buffer *buf)
 {
 	struct sk_buff *skb;
+	struct iucv_sock *iucv;
+	int notify_general_error = 0;
+
+	if (atomic_read(&buf->state) == QETH_QDIO_BUF_PENDING)
+		notify_general_error = 1;
+
+	/* release may never happen from within CQ tasklet scope */
+	BUG_ON(atomic_read(&buf->state) == QETH_QDIO_BUF_IN_CQ);
 
 	skb = skb_dequeue(&buf->skb_list);
 	while (skb) {
 		QETH_CARD_TEXT(buf->q->card, 5, "skbr");
 		QETH_CARD_TEXT_(buf->q->card, 5, "%lx", (long) skb);
+		if (notify_general_error && skb->protocol == ETH_P_AF_IUCV) {
+			if (skb->sk) {
+				iucv = iucv_sk(skb->sk);
+				iucv->sk_txnotify(skb, TX_NOTIFY_GENERALERROR);
+			}
+		}
 		atomic_dec(&skb->users);
 		dev_kfree_skb_any(skb);
 		skb = skb_dequeue(&buf->skb_list);
@@ -1160,7 +1184,7 @@ static void qeth_clear_outq_buffers(stru
 	for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j) {
 		if (!q->bufs[j])
 			continue;
-		qeth_cleanup_handled_pending(q, j, free);
+		qeth_cleanup_handled_pending(q, j, 1);
 		qeth_clear_output_buffer(q, q->bufs[j], QETH_QDIO_BUF_EMPTY);
 		if (free) {
 			kmem_cache_free(qeth_qdio_outbuf_cache, q->bufs[j]);
@@ -1207,7 +1231,7 @@ static void qeth_free_qdio_buffers(struc
 	qeth_free_cq(card);
 	cancel_delayed_work_sync(&card->buffer_reclaim_work);
 	for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j)
-		kfree_skb(card->qdio.in_q->bufs[j].rx_skb);
+		dev_kfree_skb_any(card->qdio.in_q->bufs[j].rx_skb);
 	kfree(card->qdio.in_q);
 	card->qdio.in_q = NULL;
 	/* inbound buffer pool */
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3544,6 +3544,11 @@ static int __qeth_l3_set_offline(struct
 		card->info.hwtrap = 1;
 	}
 	qeth_l3_stop_card(card, recovery_mode);
+	if ((card->options.cq == QETH_CQ_ENABLED) && card->dev) {
+		rtnl_lock();
+		call_netdevice_notifiers(NETDEV_REBOOT, card->dev);
+		rtnl_unlock();
+	}
 	rc  = ccw_device_set_offline(CARD_DDEV(card));
 	rc2 = ccw_device_set_offline(CARD_WDEV(card));
 	rc3 = ccw_device_set_offline(CARD_RDEV(card));
