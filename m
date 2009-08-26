From: frank.blaschka@de.ibm.com
Subject: [patch 1/5] [PATCH] qeth: HiperSockets SIGA retry support on CC=2.
Date: Wed, 26 Aug 2009 14:01:06 +0200
Message-ID: <20090826120135.998746000@de.ibm.com>
References: <20090826120105.727838000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Klaus-Dieter Wacker <kdwacker@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:57564 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754576AbZHZMBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 08:01:38 -0400
Content-Disposition: inline; filename=605-hipersockets-SIGA-retry.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Klaus-Dieter Wacker <kdwacker@de.ibm.com>

Qeth HiperSockets support now retries sending of packets when the
IBM System z signals a temporary resource shortage (e.g. target
buffer full). The packet is enqueued into the device queue.
After 3 times of unsuccessful send the packet is dropped.

Signed-off-by: Klaus-Dieter Wacker <kdwacker@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |    9 +++++
 drivers/s390/net/qeth_core_main.c |   60 ++++++++++++++++++++++++++++++++------
 2 files changed, 61 insertions(+), 8 deletions(-)

Index: git_net-next/drivers/s390/net/qeth_core.h
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_core.h
+++ git_net-next/drivers/s390/net/qeth_core.h
@@ -435,6 +435,7 @@ struct qeth_qdio_out_q {
 	 * index of buffer to be filled by driver; state EMPTY or PACKING
 	 */
 	int next_buf_to_fill;
+	int sync_iqdio_error;
 	/*
 	 * number of buffers that are currently filled (PRIMED)
 	 * -> these buffers are hardware-owned
@@ -685,6 +686,14 @@ struct qeth_mc_mac {
 	int is_vmac;
 };
 
+struct qeth_skb_data {
+	__u32 magic;
+	int count;
+};
+
+#define QETH_SKB_MAGIC 0x71657468
+#define QETH_SIGA_CC2_RETRIES 3
+
 struct qeth_card {
 	struct list_head list;
 	enum qeth_card_states state;
Index: git_net-next/drivers/s390/net/qeth_core_main.c
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_core_main.c
+++ git_net-next/drivers/s390/net/qeth_core_main.c
@@ -927,8 +927,8 @@ out:
 	return;
 }
 
-static void qeth_clear_output_buffer(struct qeth_qdio_out_q *queue,
-		 struct qeth_qdio_out_buffer *buf)
+static void __qeth_clear_output_buffer(struct qeth_qdio_out_q *queue,
+		 struct qeth_qdio_out_buffer *buf, unsigned int qeth_skip_skb)
 {
 	int i;
 	struct sk_buff *skb;
@@ -937,11 +937,13 @@ static void qeth_clear_output_buffer(str
 	if (buf->buffer->element[0].flags & 0x40)
 		atomic_dec(&queue->set_pci_flags_count);
 
-	skb = skb_dequeue(&buf->skb_list);
-	while (skb) {
-		atomic_dec(&skb->users);
-		dev_kfree_skb_any(skb);
+	if (!qeth_skip_skb) {
 		skb = skb_dequeue(&buf->skb_list);
+		while (skb) {
+			atomic_dec(&skb->users);
+			dev_kfree_skb_any(skb);
+			skb = skb_dequeue(&buf->skb_list);
+		}
 	}
 	for (i = 0; i < QETH_MAX_BUFFER_ELEMENTS(queue->card); ++i) {
 		if (buf->buffer->element[i].addr && buf->is_header[i])
@@ -957,6 +959,12 @@ static void qeth_clear_output_buffer(str
 	atomic_set(&buf->state, QETH_QDIO_BUF_EMPTY);
 }
 
+static void qeth_clear_output_buffer(struct qeth_qdio_out_q *queue,
+		struct qeth_qdio_out_buffer *buf)
+{
+	__qeth_clear_output_buffer(queue, buf, 0);
+}
+
 void qeth_clear_qdio_buffers(struct qeth_card *card)
 {
 	int i, j;
@@ -2685,6 +2693,13 @@ static int qeth_handle_send_error(struct
 	int sbalf15 = buffer->buffer->element[15].flags & 0xff;
 
 	QETH_DBF_TEXT(TRACE, 6, "hdsnderr");
+	if (card->info.type == QETH_CARD_TYPE_IQD) {
+		if (sbalf15 == 0) {
+			qdio_err = 0;
+		} else {
+			qdio_err = 1;
+		}
+	}
 	qeth_check_qdio_errors(buffer->buffer, qdio_err, "qouterr");
 
 	if (!qdio_err)
@@ -2817,6 +2832,7 @@ static void qeth_flush_buffers(struct qe
 		}
 	}
 
+	queue->sync_iqdio_error = 0;
 	queue->card->dev->trans_start = jiffies;
 	if (queue->card->options.performance_stats) {
 		queue->card->perf_stats.outbound_do_qdio_cnt++;
@@ -2832,6 +2848,10 @@ static void qeth_flush_buffers(struct qe
 		queue->card->perf_stats.outbound_do_qdio_time +=
 			qeth_get_micros() -
 			queue->card->perf_stats.outbound_do_qdio_start_time;
+	if (rc > 0) {
+		if (!(rc & QDIO_ERROR_SIGA_BUSY))
+			queue->sync_iqdio_error = rc & 3;
+	}
 	if (rc) {
 		queue->card->stats.tx_errors += count;
 		/* ignore temporary SIGA errors without busy condition */
@@ -2899,6 +2919,7 @@ void qeth_qdio_output_handler(struct ccw
 	struct qeth_qdio_out_q *queue = card->qdio.out_qs[__queue];
 	struct qeth_qdio_out_buffer *buffer;
 	int i;
+	unsigned qeth_send_err;
 
 	QETH_DBF_TEXT(TRACE, 6, "qdouhdl");
 	if (qdio_error & QDIO_ERROR_ACTIVATE_CHECK_CONDITION) {
@@ -2915,8 +2936,9 @@ void qeth_qdio_output_handler(struct ccw
 	}
 	for (i = first_element; i < (first_element + count); ++i) {
 		buffer = &queue->bufs[i % QDIO_MAX_BUFFERS_PER_Q];
-		qeth_handle_send_error(card, buffer, qdio_error);
-		qeth_clear_output_buffer(queue, buffer);
+		qeth_send_err = qeth_handle_send_error(card, buffer, qdio_error);
+		__qeth_clear_output_buffer(queue, buffer,
+			(qeth_send_err == QETH_SEND_ERROR_RETRY) ? 1 : 0);
 	}
 	atomic_sub(count, &queue->used_buffers);
 	/* check if we need to do something on this outbound queue */
@@ -3159,7 +3181,10 @@ int qeth_do_send_packet_fast(struct qeth
 		int offset, int hd_len)
 {
 	struct qeth_qdio_out_buffer *buffer;
+	struct sk_buff *skb1;
+	struct qeth_skb_data *retry_ctrl;
 	int index;
+	int rc;
 
 	/* spin until we get the queue ... */
 	while (atomic_cmpxchg(&queue->state, QETH_OUT_Q_UNLOCKED,
@@ -3178,6 +3203,25 @@ int qeth_do_send_packet_fast(struct qeth
 	atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
 	qeth_fill_buffer(queue, buffer, skb, hdr, offset, hd_len);
 	qeth_flush_buffers(queue, index, 1);
+	if (queue->sync_iqdio_error == 2) {
+		skb1 = skb_dequeue(&buffer->skb_list);
+		while (skb1) {
+			atomic_dec(&skb1->users);
+			skb1 = skb_dequeue(&buffer->skb_list);
+		}
+		retry_ctrl = (struct qeth_skb_data *) &skb->cb[16];
+		if (retry_ctrl->magic != QETH_SKB_MAGIC) {
+			retry_ctrl->magic = QETH_SKB_MAGIC;
+			retry_ctrl->count = 0;
+		}
+		if (retry_ctrl->count < QETH_SIGA_CC2_RETRIES) {
+			retry_ctrl->count++;
+			rc = dev_queue_xmit(skb);
+		} else {
+			dev_kfree_skb_any(skb);
+			QETH_DBF_TEXT(QERR, 2, "qrdrop");
+		}
+	}
 	return 0;
 out:
 	atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);

