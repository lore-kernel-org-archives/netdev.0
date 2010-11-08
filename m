From: frank.blaschka@de.ibm.com
Subject: [patch 1/2] [PATCH] qeth: remove dev_queue_xmit invocation
Date: Mon, 08 Nov 2010 14:03:48 +0100
Message-ID: <20101108130427.369029643@de.ibm.com>
References: <20101108130347.973708765@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:35853 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660Ab0KHNE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 08:04:29 -0500
Content-Disposition: inline; filename=602-qeth-dev-queue-xmit.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

For a certain Hipersockets specific error code in the xmit path, the
qeth driver tries to invoke dev_queue_xmit again.
Commit 79640a4ca6955e3ebdb7038508fa7a0cd7fa5527 introduces a busylock
causing locking problems in case of re-invoked dev_queue_xmit by qeth.
This patch removes the attempts to retry packet sending with
dev_queue_xmit from the qeth driver.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |    9 ------
 drivers/s390/net/qeth_core_main.c |   53 +++++---------------------------------
 2 files changed, 8 insertions(+), 54 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2010-11-08 09:40:59.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2010-11-08 09:41:12.000000000 +0100
@@ -440,7 +440,6 @@ struct qeth_qdio_out_q {
 	 * index of buffer to be filled by driver; state EMPTY or PACKING
 	 */
 	int next_buf_to_fill;
-	int sync_iqdio_error;
 	/*
 	 * number of buffers that are currently filled (PRIMED)
 	 * -> these buffers are hardware-owned
@@ -695,14 +694,6 @@ struct qeth_mc_mac {
 	int is_vmac;
 };
 
-struct qeth_skb_data {
-	__u32 magic;
-	int count;
-};
-
-#define QETH_SKB_MAGIC 0x71657468
-#define QETH_SIGA_CC2_RETRIES 3
-
 struct qeth_rx {
 	int b_count;
 	int b_index;
diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2010-11-08 09:40:59.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2010-11-08 09:41:12.000000000 +0100
@@ -877,8 +877,8 @@ out:
 	return;
 }
 
-static void __qeth_clear_output_buffer(struct qeth_qdio_out_q *queue,
-		 struct qeth_qdio_out_buffer *buf, unsigned int qeth_skip_skb)
+static void qeth_clear_output_buffer(struct qeth_qdio_out_q *queue,
+		struct qeth_qdio_out_buffer *buf)
 {
 	int i;
 	struct sk_buff *skb;
@@ -887,13 +887,11 @@ static void __qeth_clear_output_buffer(s
 	if (buf->buffer->element[0].flags & 0x40)
 		atomic_dec(&queue->set_pci_flags_count);
 
-	if (!qeth_skip_skb) {
+	skb = skb_dequeue(&buf->skb_list);
+	while (skb) {
+		atomic_dec(&skb->users);
+		dev_kfree_skb_any(skb);
 		skb = skb_dequeue(&buf->skb_list);
-		while (skb) {
-			atomic_dec(&skb->users);
-			dev_kfree_skb_any(skb);
-			skb = skb_dequeue(&buf->skb_list);
-		}
 	}
 	for (i = 0; i < QETH_MAX_BUFFER_ELEMENTS(queue->card); ++i) {
 		if (buf->buffer->element[i].addr && buf->is_header[i])
@@ -909,12 +907,6 @@ static void __qeth_clear_output_buffer(s
 	atomic_set(&buf->state, QETH_QDIO_BUF_EMPTY);
 }
 
-static void qeth_clear_output_buffer(struct qeth_qdio_out_q *queue,
-		struct qeth_qdio_out_buffer *buf)
-{
-	__qeth_clear_output_buffer(queue, buf, 0);
-}
-
 void qeth_clear_qdio_buffers(struct qeth_card *card)
 {
 	int i, j;
@@ -2833,7 +2825,6 @@ static void qeth_flush_buffers(struct qe
 		}
 	}
 
-	queue->sync_iqdio_error = 0;
 	queue->card->dev->trans_start = jiffies;
 	if (queue->card->options.performance_stats) {
 		queue->card->perf_stats.outbound_do_qdio_cnt++;
@@ -2849,10 +2840,6 @@ static void qeth_flush_buffers(struct qe
 		queue->card->perf_stats.outbound_do_qdio_time +=
 			qeth_get_micros() -
 			queue->card->perf_stats.outbound_do_qdio_start_time;
-	if (rc > 0) {
-		if (!(rc & QDIO_ERROR_SIGA_BUSY))
-			queue->sync_iqdio_error = rc & 3;
-	}
 	if (rc) {
 		queue->card->stats.tx_errors += count;
 		/* ignore temporary SIGA errors without busy condition */
@@ -2940,7 +2927,6 @@ void qeth_qdio_output_handler(struct ccw
 	struct qeth_qdio_out_q *queue = card->qdio.out_qs[__queue];
 	struct qeth_qdio_out_buffer *buffer;
 	int i;
-	unsigned qeth_send_err;
 
 	QETH_CARD_TEXT(card, 6, "qdouhdl");
 	if (qdio_error & QDIO_ERROR_ACTIVATE_CHECK_CONDITION) {
@@ -2956,9 +2942,8 @@ void qeth_qdio_output_handler(struct ccw
 	}
 	for (i = first_element; i < (first_element + count); ++i) {
 		buffer = &queue->bufs[i % QDIO_MAX_BUFFERS_PER_Q];
-		qeth_send_err = qeth_handle_send_error(card, buffer, qdio_error);
-		__qeth_clear_output_buffer(queue, buffer,
-			(qeth_send_err == QETH_SEND_ERROR_RETRY) ? 1 : 0);
+		qeth_handle_send_error(card, buffer, qdio_error);
+		qeth_clear_output_buffer(queue, buffer);
 	}
 	atomic_sub(count, &queue->used_buffers);
 	/* check if we need to do something on this outbound queue */
@@ -3183,10 +3168,7 @@ int qeth_do_send_packet_fast(struct qeth
 		int offset, int hd_len)
 {
 	struct qeth_qdio_out_buffer *buffer;
-	struct sk_buff *skb1;
-	struct qeth_skb_data *retry_ctrl;
 	int index;
-	int rc;
 
 	/* spin until we get the queue ... */
 	while (atomic_cmpxchg(&queue->state, QETH_OUT_Q_UNLOCKED,
@@ -3205,25 +3187,6 @@ int qeth_do_send_packet_fast(struct qeth
 	atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
 	qeth_fill_buffer(queue, buffer, skb, hdr, offset, hd_len);
 	qeth_flush_buffers(queue, index, 1);
-	if (queue->sync_iqdio_error == 2) {
-		skb1 = skb_dequeue(&buffer->skb_list);
-		while (skb1) {
-			atomic_dec(&skb1->users);
-			skb1 = skb_dequeue(&buffer->skb_list);
-		}
-		retry_ctrl = (struct qeth_skb_data *) &skb->cb[16];
-		if (retry_ctrl->magic != QETH_SKB_MAGIC) {
-			retry_ctrl->magic = QETH_SKB_MAGIC;
-			retry_ctrl->count = 0;
-		}
-		if (retry_ctrl->count < QETH_SIGA_CC2_RETRIES) {
-			retry_ctrl->count++;
-			rc = dev_queue_xmit(skb);
-		} else {
-			dev_kfree_skb_any(skb);
-			QETH_CARD_TEXT(card, 2, "qrdrop");
-		}
-	}
 	return 0;
 out:
 	atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);

