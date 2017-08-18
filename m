From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 3/7] s390/qeth: pass TSO header length to fill_buffer()
Date: Fri, 18 Aug 2017 10:19:06 +0200
Message-ID: <20170818081910.48869-4-jwi@linux.vnet.ibm.com>
References: <20170818081910.48869-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:51755 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750877AbdHRITY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 04:19:24 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7I8JBDr064293
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 04:19:24 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2cdqg07txh-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 04:19:24 -0400
Received: from localhost
        by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Fri, 18 Aug 2017 09:19:22 +0100
In-Reply-To: <20170818081910.48869-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TSO code already calculates the length of its header element,
no need to duplicate this in the low-level code again.

Use this opportunity to make hd_len unsigned, and for TSO match
its calculation to what tso_fill_header() does.

No functional change.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  7 ++++---
 drivers/s390/net/qeth_core_main.c | 18 ++++++++----------
 drivers/s390/net/qeth_l2_main.c   |  4 ++--
 drivers/s390/net/qeth_l3_main.c   | 15 +++++++++------
 4 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 4a4ca5cb37a0..2f5673812810 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -949,9 +949,10 @@ int qeth_get_elements_for_frags(struct sk_buff *);
 int qeth_do_send_packet_fast(struct qeth_card *card,
 			     struct qeth_qdio_out_q *queue, struct sk_buff *skb,
 			     struct qeth_hdr *hdr, unsigned int offset,
-			     int hd_len);
-int qeth_do_send_packet(struct qeth_card *, struct qeth_qdio_out_q *,
-		    struct sk_buff *, struct qeth_hdr *, int);
+			     unsigned int hd_len);
+int qeth_do_send_packet(struct qeth_card *card, struct qeth_qdio_out_q *queue,
+			struct sk_buff *skb, struct qeth_hdr *hdr,
+			unsigned int hd_len, int elements);
 int qeth_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 int qeth_core_get_sset_count(struct net_device *, int);
 void qeth_core_get_ethtool_stats(struct net_device *,
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 415424e618ad..6cafeceea3ce 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3956,11 +3956,11 @@ static void __qeth_fill_buffer(struct sk_buff *skb,
 static int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
 			    struct qeth_qdio_out_buffer *buf,
 			    struct sk_buff *skb, struct qeth_hdr *hdr,
-			    unsigned int offset, int hd_len)
+			    unsigned int offset, unsigned int hd_len)
 {
 	struct qdio_buffer *buffer;
-	int flush_cnt = 0, hdr_len;
 	bool is_first_elem = true;
+	int flush_cnt = 0;
 
 	buffer = buf->buffer;
 	refcount_inc(&skb->users);
@@ -3970,14 +3970,12 @@ static int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
 		int element = buf->next_element_to_fill;
 		is_first_elem = false;
 
-		hdr_len = sizeof(struct qeth_hdr_tso) +
-			((struct qeth_hdr_tso *)hdr)->ext.dg_hdr_len;
 		/*fill first buffer entry only with header information */
 		buffer->element[element].addr = skb->data;
-		buffer->element[element].length = hdr_len;
+		buffer->element[element].length = hd_len;
 		buffer->element[element].eflags = SBAL_EFLAGS_FIRST_FRAG;
 		buf->next_element_to_fill++;
-		skb_pull(skb, hdr_len);
+		skb_pull(skb, hd_len);
 	}
 
 	/* IQD */
@@ -4020,7 +4018,7 @@ static int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
 int qeth_do_send_packet_fast(struct qeth_card *card,
 			     struct qeth_qdio_out_q *queue, struct sk_buff *skb,
 			     struct qeth_hdr *hdr, unsigned int offset,
-			     int hd_len)
+			     unsigned int hd_len)
 {
 	struct qeth_qdio_out_buffer *buffer;
 	int index;
@@ -4050,8 +4048,8 @@ int qeth_do_send_packet_fast(struct qeth_card *card,
 EXPORT_SYMBOL_GPL(qeth_do_send_packet_fast);
 
 int qeth_do_send_packet(struct qeth_card *card, struct qeth_qdio_out_q *queue,
-		struct sk_buff *skb, struct qeth_hdr *hdr,
-		int elements_needed)
+			struct sk_buff *skb, struct qeth_hdr *hdr,
+			unsigned int hd_len, int elements_needed)
 {
 	struct qeth_qdio_out_buffer *buffer;
 	int start_index;
@@ -4100,7 +4098,7 @@ int qeth_do_send_packet(struct qeth_card *card, struct qeth_qdio_out_q *queue,
 			}
 		}
 	}
-	tmp = qeth_fill_buffer(queue, buffer, skb, hdr, 0, 0);
+	tmp = qeth_fill_buffer(queue, buffer, skb, hdr, 0, hd_len);
 	queue->next_buf_to_fill = (queue->next_buf_to_fill + tmp) %
 				  QDIO_MAX_BUFFERS_PER_Q;
 	flush_count += tmp;
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 3f5b852408d3..c78d9fadb9c8 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -746,7 +746,7 @@ static int qeth_l2_xmit_osa(struct qeth_card *card, struct sk_buff *skb,
 		rc = -EINVAL;
 		goto out;
 	}
-	rc = qeth_do_send_packet(card, queue, skb_copy, hdr, elements);
+	rc = qeth_do_send_packet(card, queue, skb_copy, hdr, 0, elements);
 out:
 	if (!rc) {
 		/* tx success, free dangling original */
@@ -778,7 +778,7 @@ static int qeth_l2_xmit_osn(struct qeth_card *card, struct sk_buff *skb,
 		return -E2BIG;
 	if (qeth_hdr_chk_and_bounce(skb, &hdr, sizeof(*hdr)))
 		return -EINVAL;
-	return qeth_do_send_packet(card, queue, skb, hdr, elements);
+	return qeth_do_send_packet(card, queue, skb, hdr, 0, elements);
 }
 
 static netdev_tx_t qeth_l2_hard_start_xmit(struct sk_buff *skb,
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 0a3dc14a1381..fa8b638e3842 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2637,6 +2637,7 @@ static netdev_tx_t qeth_l3_hard_start_xmit(struct sk_buff *skb,
 			qeth_get_priority_queue(card, skb, ipv, cast_type) :
 			card->qdio.default_out_queue];
 	int tx_bytes = skb->len;
+	unsigned int hd_len = 0;
 	bool use_tso;
 	int data_offset = -1;
 	unsigned int nr_frags;
@@ -2756,16 +2757,18 @@ static netdev_tx_t qeth_l3_hard_start_xmit(struct sk_buff *skb,
 
 	if (card->info.type != QETH_CARD_TYPE_IQD) {
 		int len;
-		if (use_tso)
-			len = ((unsigned long)tcp_hdr(new_skb) +
-				tcp_hdrlen(new_skb)) -
-				(unsigned long)new_skb->data;
-		else
+		if (use_tso) {
+			hd_len = sizeof(struct qeth_hdr_tso) +
+				 ip_hdrlen(new_skb) + tcp_hdrlen(new_skb);
+			len = hd_len;
+		} else {
 			len = sizeof(struct qeth_hdr_layer3);
+		}
 
 		if (qeth_hdr_chk_and_bounce(new_skb, &hdr, len))
 			goto tx_drop;
-		rc = qeth_do_send_packet(card, queue, new_skb, hdr, elements);
+		rc = qeth_do_send_packet(card, queue, new_skb, hdr, hd_len,
+					 elements);
 	} else
 		rc = qeth_do_send_packet_fast(card, queue, new_skb, hdr,
 					      data_offset, 0);
-- 
2.11.2
