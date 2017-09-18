From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 5/9] s390/qeth: don't take queue lock in send_packet_fast()
Date: Mon, 18 Sep 2017 21:18:18 +0200
Message-ID: <20170918191822.65142-6-jwi@linux.vnet.ibm.com>
References: <20170918191822.65142-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:39942 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750790AbdIRTUD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:20:03 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8IJK0Ni091173
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:20:03 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d2ea07b0e-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:20:02 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Mon, 18 Sep 2017 20:19:27 +0100
In-Reply-To: <20170918191822.65142-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Locking the output queue prior to TX is needed on OSA devices,
to synchronize against a packing flush from the TX completion code
(via qeth_check_outbound_queue()).
But send_packet_fast() is only used for IQDs, which don't do packing.
So remove the locking, and apply some easy cleanups.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  3 +--
 drivers/s390/net/qeth_core_main.c | 22 +++++-----------------
 drivers/s390/net/qeth_l2_main.c   |  2 +-
 drivers/s390/net/qeth_l3_main.c   |  4 ++--
 4 files changed, 9 insertions(+), 22 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index e3d3609cd9e7..b7e8531625aa 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -962,8 +962,7 @@ int qeth_get_priority_queue(struct qeth_card *, struct sk_buff *, int, int);
 int qeth_get_elements_no(struct qeth_card *card, struct sk_buff *skb,
 			 int extra_elems, int data_offset);
 int qeth_get_elements_for_frags(struct sk_buff *);
-int qeth_do_send_packet_fast(struct qeth_card *card,
-			     struct qeth_qdio_out_q *queue, struct sk_buff *skb,
+int qeth_do_send_packet_fast(struct qeth_qdio_out_q *queue, struct sk_buff *skb,
 			     struct qeth_hdr *hdr, unsigned int offset,
 			     unsigned int hd_len);
 int qeth_do_send_packet(struct qeth_card *card, struct qeth_qdio_out_q *queue,
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 77032801e30b..68e118f1202e 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4040,35 +4040,23 @@ static int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
 	return flush_cnt;
 }
 
-int qeth_do_send_packet_fast(struct qeth_card *card,
-			     struct qeth_qdio_out_q *queue, struct sk_buff *skb,
+int qeth_do_send_packet_fast(struct qeth_qdio_out_q *queue, struct sk_buff *skb,
 			     struct qeth_hdr *hdr, unsigned int offset,
 			     unsigned int hd_len)
 {
-	struct qeth_qdio_out_buffer *buffer;
-	int index;
+	int index = queue->next_buf_to_fill;
+	struct qeth_qdio_out_buffer *buffer = queue->bufs[index];
 
-	/* spin until we get the queue ... */
-	while (atomic_cmpxchg(&queue->state, QETH_OUT_Q_UNLOCKED,
-			      QETH_OUT_Q_LOCKED) != QETH_OUT_Q_UNLOCKED);
-	/* ... now we've got the queue */
-	index = queue->next_buf_to_fill;
-	buffer = queue->bufs[queue->next_buf_to_fill];
 	/*
 	 * check if buffer is empty to make sure that we do not 'overtake'
 	 * ourselves and try to fill a buffer that is already primed
 	 */
 	if (atomic_read(&buffer->state) != QETH_QDIO_BUF_EMPTY)
-		goto out;
-	queue->next_buf_to_fill = (queue->next_buf_to_fill + 1) %
-					  QDIO_MAX_BUFFERS_PER_Q;
-	atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
+		return -EBUSY;
+	queue->next_buf_to_fill = (index + 1) % QDIO_MAX_BUFFERS_PER_Q;
 	qeth_fill_buffer(queue, buffer, skb, hdr, offset, hd_len);
 	qeth_flush_buffers(queue, index, 1);
 	return 0;
-out:
-	atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
-	return -EBUSY;
 }
 EXPORT_SYMBOL_GPL(qeth_do_send_packet_fast);
 
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 25a0f381bcd5..009de7248cc7 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -698,7 +698,7 @@ static int qeth_l2_xmit_iqd(struct qeth_card *card, struct sk_buff *skb,
 		rc = -E2BIG;
 		goto out;
 	}
-	rc = qeth_do_send_packet_fast(card, queue, skb, hdr, data_offset,
+	rc = qeth_do_send_packet_fast(queue, skb, hdr, data_offset,
 				      sizeof(*hdr) + data_offset);
 out:
 	if (rc)
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index ab661a431f7c..733f94cbd4d4 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2771,8 +2771,8 @@ static netdev_tx_t qeth_l3_hard_start_xmit(struct sk_buff *skb,
 		rc = qeth_do_send_packet(card, queue, new_skb, hdr, hd_len,
 					 hd_len, elements);
 	} else
-		rc = qeth_do_send_packet_fast(card, queue, new_skb, hdr,
-					      data_offset, hd_len);
+		rc = qeth_do_send_packet_fast(queue, new_skb, hdr, data_offset,
+					      hd_len);
 
 	if (!rc) {
 		card->stats.tx_packets++;
-- 
2.13.5
