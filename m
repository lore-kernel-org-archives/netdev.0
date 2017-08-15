From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 06/12] s390/qeth: clean up fill_buffer() offset logic
Date: Tue, 15 Aug 2017 17:02:44 +0200
Message-ID: <20170815150250.67158-7-jwi@linux.vnet.ibm.com>
References: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:60247 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752563AbdHOPDM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:03:12 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7FF34C7057541
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:12 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2cbvj333v2-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:12 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 15 Aug 2017 16:03:09 +0100
In-Reply-To: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For some xmit paths we pass down a data offset to qeth_fill_buffer(),
to indicate that the first k bytes of the skb should be skipped when
mapping it into buffer elements.
Commit acd9776b5c45 ("s390/qeth: no ETH header for outbound AF_IUCV")
recently switched the offset for the IUCV-over-HiperSockets path
from 0 to ETH_HLEN, and now we have

	device	offset
	OSA	= 0
	IQD	> 0

for all xmit paths.

OSA would previously pass down -1 from do_send_packet(), to distinguish
between 1) OSA and 2) IQD with offset 0. That's no longer needed now,
so have it pass 0, make the offset unsigned and clean up how we apply
the offset in __qeth_fill_buffer().

No change of behaviour for any of our current xmit paths.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Acked-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  6 ++++--
 drivers/s390/net/qeth_core_main.c | 31 ++++++++++++++-----------------
 2 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 7a0ffc71b25d..95266449a50a 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -951,8 +951,10 @@ int qeth_get_priority_queue(struct qeth_card *, struct sk_buff *, int, int);
 int qeth_get_elements_no(struct qeth_card *card, struct sk_buff *skb,
 			 int extra_elems, int data_offset);
 int qeth_get_elements_for_frags(struct sk_buff *);
-int qeth_do_send_packet_fast(struct qeth_card *, struct qeth_qdio_out_q *,
-			struct sk_buff *, struct qeth_hdr *, int, int);
+int qeth_do_send_packet_fast(struct qeth_card *card,
+			     struct qeth_qdio_out_q *queue, struct sk_buff *skb,
+			     struct qeth_hdr *hdr, unsigned int offset,
+			     int hd_len);
 int qeth_do_send_packet(struct qeth_card *, struct qeth_qdio_out_q *,
 		    struct sk_buff *, struct qeth_hdr *, int);
 int qeth_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 9796388780f9..394bee93b891 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3890,22 +3890,16 @@ EXPORT_SYMBOL_GPL(qeth_hdr_chk_and_bounce);
 
 static inline void __qeth_fill_buffer(struct sk_buff *skb,
 				      struct qeth_qdio_out_buffer *buf,
-				      bool is_first_elem, int offset)
+				      bool is_first_elem, unsigned int offset)
 {
 	struct qdio_buffer *buffer = buf->buffer;
 	int element = buf->next_element_to_fill;
-	int length = skb_headlen(skb);
+	int length = skb_headlen(skb) - offset;
+	char *data = skb->data + offset;
 	int length_here, cnt;
-	char *data;
 	struct skb_frag_struct *frag;
 
-	data = skb->data;
-
-	if (offset >= 0) {
-		data = skb->data + offset;
-		length -= offset;
-	}
-
+	/* map linear part into buffer element(s) */
 	while (length > 0) {
 		/* length_here is the remaining amount of data in this page */
 		length_here = PAGE_SIZE - ((unsigned long) data % PAGE_SIZE);
@@ -3931,6 +3925,7 @@ static inline void __qeth_fill_buffer(struct sk_buff *skb,
 		element++;
 	}
 
+	/* map page frags into buffer element(s) */
 	for (cnt = 0; cnt < skb_shinfo(skb)->nr_frags; cnt++) {
 		frag = &skb_shinfo(skb)->frags[cnt];
 		data = (char *)page_to_phys(skb_frag_page(frag)) +
@@ -3958,8 +3953,9 @@ static inline void __qeth_fill_buffer(struct sk_buff *skb,
 }
 
 static inline int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
-		struct qeth_qdio_out_buffer *buf, struct sk_buff *skb,
-		struct qeth_hdr *hdr, int offset, int hd_len)
+				   struct qeth_qdio_out_buffer *buf,
+				   struct sk_buff *skb, struct qeth_hdr *hdr,
+				   unsigned int offset, int hd_len)
 {
 	struct qdio_buffer *buffer;
 	int flush_cnt = 0, hdr_len;
@@ -3969,7 +3965,6 @@ static inline int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
 	refcount_inc(&skb->users);
 	skb_queue_tail(&buf->skb_list, skb);
 
-	/*check first on TSO ....*/
 	if (hdr->hdr.l3.id == QETH_HEADER_TYPE_TSO) {
 		int element = buf->next_element_to_fill;
 		is_first_elem = false;
@@ -3985,7 +3980,8 @@ static inline int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
 		skb->len  -= hdr_len;
 	}
 
-	if (offset >= 0) {
+	/* IQD */
+	if (offset > 0) {
 		int element = buf->next_element_to_fill;
 		is_first_elem = false;
 
@@ -4022,8 +4018,9 @@ static inline int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
 }
 
 int qeth_do_send_packet_fast(struct qeth_card *card,
-		struct qeth_qdio_out_q *queue, struct sk_buff *skb,
-		struct qeth_hdr *hdr, int offset, int hd_len)
+			     struct qeth_qdio_out_q *queue, struct sk_buff *skb,
+			     struct qeth_hdr *hdr, unsigned int offset,
+			     int hd_len)
 {
 	struct qeth_qdio_out_buffer *buffer;
 	int index;
@@ -4103,7 +4100,7 @@ int qeth_do_send_packet(struct qeth_card *card, struct qeth_qdio_out_q *queue,
 			}
 		}
 	}
-	tmp = qeth_fill_buffer(queue, buffer, skb, hdr, -1, 0);
+	tmp = qeth_fill_buffer(queue, buffer, skb, hdr, 0, 0);
 	queue->next_buf_to_fill = (queue->next_buf_to_fill + tmp) %
 				  QDIO_MAX_BUFFERS_PER_Q;
 	flush_count += tmp;
-- 
2.11.2
