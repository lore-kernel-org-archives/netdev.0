From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 6/9] s390/qeth: consolidate pack buffer flushing
Date: Tue,  6 Jun 2017 14:33:47 +0200
Message-ID: <20170606123350.13781-7-jwi@linux.vnet.ibm.com>
References: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:54670 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751479AbdFFMeI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 08:34:08 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v56CXjN4020942
        for <netdev@vger.kernel.org>; Tue, 6 Jun 2017 08:34:08 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2awvdprdk2-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 08:34:08 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 6 Jun 2017 13:34:06 +0100
In-Reply-To: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

qeth_switch_to_nonpacking_if_needed() contains an open-coded version
of qeth_flush_buffers_on_no_pci(). Extract a single helper instead.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Acked-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 65 +++++++++++++++------------------------
 1 file changed, 25 insertions(+), 40 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index dba7d00715e3..a159eb900d03 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3347,6 +3347,28 @@ static void qeth_handle_send_error(struct qeth_card *card,
 		       (u16)qdio_err, (u8)sbalf15);
 }
 
+/**
+ * qeth_prep_flush_pack_buffer - Prepares flushing of a packing buffer.
+ * @queue: queue to check for packing buffer
+ *
+ * Returns number of buffers that were prepared for flush.
+ */
+static int qeth_prep_flush_pack_buffer(struct qeth_qdio_out_q *queue)
+{
+	struct qeth_qdio_out_buffer *buffer;
+
+	buffer = queue->bufs[queue->next_buf_to_fill];
+	if ((atomic_read(&buffer->state) == QETH_QDIO_BUF_EMPTY) &&
+	    (buffer->next_element_to_fill > 0)) {
+		/* it's a packing buffer */
+		atomic_set(&buffer->state, QETH_QDIO_BUF_PRIMED);
+		queue->next_buf_to_fill =
+			(queue->next_buf_to_fill + 1) % QDIO_MAX_BUFFERS_PER_Q;
+		return 1;
+	}
+	return 0;
+}
+
 /*
  * Switched to packing state if the number of used buffers on a queue
  * reaches a certain limit.
@@ -3373,9 +3395,6 @@ static void qeth_switch_to_packing_if_needed(struct qeth_qdio_out_q *queue)
  */
 static int qeth_switch_to_nonpacking_if_needed(struct qeth_qdio_out_q *queue)
 {
-	struct qeth_qdio_out_buffer *buffer;
-	int flush_count = 0;
-
 	if (queue->do_pack) {
 		if (atomic_read(&queue->used_buffers)
 		    <= QETH_LOW_WATERMARK_PACK) {
@@ -3384,42 +3403,9 @@ static int qeth_switch_to_nonpacking_if_needed(struct qeth_qdio_out_q *queue)
 			if (queue->card->options.performance_stats)
 				queue->card->perf_stats.sc_p_dp++;
 			queue->do_pack = 0;
-			/* flush packing buffers */
-			buffer = queue->bufs[queue->next_buf_to_fill];
-			if ((atomic_read(&buffer->state) ==
-						QETH_QDIO_BUF_EMPTY) &&
-			    (buffer->next_element_to_fill > 0)) {
-				atomic_set(&buffer->state,
-					   QETH_QDIO_BUF_PRIMED);
-				flush_count++;
-				queue->next_buf_to_fill =
-					(queue->next_buf_to_fill + 1) %
-					QDIO_MAX_BUFFERS_PER_Q;
-			}
+			return qeth_prep_flush_pack_buffer(queue);
 		}
 	}
-	return flush_count;
-}
-
-
-/*
- * Called to flush a packing buffer if no more pci flags are on the queue.
- * Checks if there is a packing buffer and prepares it to be flushed.
- * In that case returns 1, otherwise zero.
- */
-static int qeth_flush_buffers_on_no_pci(struct qeth_qdio_out_q *queue)
-{
-	struct qeth_qdio_out_buffer *buffer;
-
-	buffer = queue->bufs[queue->next_buf_to_fill];
-	if ((atomic_read(&buffer->state) == QETH_QDIO_BUF_EMPTY) &&
-	   (buffer->next_element_to_fill > 0)) {
-		/* it's a packing buffer */
-		atomic_set(&buffer->state, QETH_QDIO_BUF_PRIMED);
-		queue->next_buf_to_fill =
-			(queue->next_buf_to_fill + 1) % QDIO_MAX_BUFFERS_PER_Q;
-		return 1;
-	}
 	return 0;
 }
 
@@ -3532,8 +3518,7 @@ static void qeth_check_outbound_queue(struct qeth_qdio_out_q *queue)
 			flush_cnt += qeth_switch_to_nonpacking_if_needed(queue);
 			if (!flush_cnt &&
 			    !atomic_read(&queue->set_pci_flags_count))
-				flush_cnt +=
-					qeth_flush_buffers_on_no_pci(queue);
+				flush_cnt += qeth_prep_flush_pack_buffer(queue);
 			if (queue->card->options.performance_stats &&
 			    q_was_packing)
 				queue->card->perf_stats.bufs_sent_pack +=
@@ -4127,7 +4112,7 @@ int qeth_do_send_packet(struct qeth_card *card, struct qeth_qdio_out_q *queue,
 		 * flag out on the queue
 		 */
 		if (!flush_count && !atomic_read(&queue->set_pci_flags_count))
-			flush_count += qeth_flush_buffers_on_no_pci(queue);
+			flush_count += qeth_prep_flush_pack_buffer(queue);
 		if (flush_count)
 			qeth_flush_buffers(queue, start_index, flush_count);
 	}
-- 
2.11.2
