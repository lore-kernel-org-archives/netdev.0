From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 05/12] s390/qeth: straighten out fill_buffer() interface
Date: Tue, 15 Aug 2017 17:02:43 +0200
Message-ID: <20170815150250.67158-6-jwi@linux.vnet.ibm.com>
References: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:59435 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752634AbdHOPDJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:03:09 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7FF1YTc042951
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:09 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2cc22skyqv-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:09 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 15 Aug 2017 16:03:06 +0100
In-Reply-To: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. for adjusting the buffer's next_element_to_fill in __fill_buffer(),
   just pass the full qeth_qdio_out_buffer struct
2. when adding a header element, be consistent about passing
   a hint ('is_first_elem') to __fill_buffer()

No functional change.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Acked-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 29 ++++++++++++++---------------
 1 file changed, 14 insertions(+), 15 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 3623ba23ff0b..9796388780f9 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3889,24 +3889,21 @@ int qeth_hdr_chk_and_bounce(struct sk_buff *skb, struct qeth_hdr **hdr, int len)
 EXPORT_SYMBOL_GPL(qeth_hdr_chk_and_bounce);
 
 static inline void __qeth_fill_buffer(struct sk_buff *skb,
-	struct qdio_buffer *buffer, int is_tso, int *next_element_to_fill,
-	int offset)
+				      struct qeth_qdio_out_buffer *buf,
+				      bool is_first_elem, int offset)
 {
+	struct qdio_buffer *buffer = buf->buffer;
+	int element = buf->next_element_to_fill;
 	int length = skb_headlen(skb);
-	int length_here;
-	int element;
+	int length_here, cnt;
 	char *data;
-	int first_lap, cnt;
 	struct skb_frag_struct *frag;
 
-	element = *next_element_to_fill;
 	data = skb->data;
-	first_lap = (is_tso == 0 ? 1 : 0);
 
 	if (offset >= 0) {
 		data = skb->data + offset;
 		length -= offset;
-		first_lap = 0;
 	}
 
 	while (length > 0) {
@@ -3918,7 +3915,8 @@ static inline void __qeth_fill_buffer(struct sk_buff *skb,
 		buffer->element[element].addr = data;
 		buffer->element[element].length = length_here;
 		length -= length_here;
-		if (first_lap) {
+		if (is_first_elem) {
+			is_first_elem = false;
 			if (length || skb_is_nonlinear(skb))
 				/* skb needs additional elements */
 				buffer->element[element].eflags =
@@ -3931,7 +3929,6 @@ static inline void __qeth_fill_buffer(struct sk_buff *skb,
 		}
 		data += length_here;
 		element++;
-		first_lap = 0;
 	}
 
 	for (cnt = 0; cnt < skb_shinfo(skb)->nr_frags; cnt++) {
@@ -3957,7 +3954,7 @@ static inline void __qeth_fill_buffer(struct sk_buff *skb,
 
 	if (buffer->element[element - 1].eflags)
 		buffer->element[element - 1].eflags = SBAL_EFLAGS_LAST_FRAG;
-	*next_element_to_fill = element;
+	buf->next_element_to_fill = element;
 }
 
 static inline int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
@@ -3965,7 +3962,8 @@ static inline int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
 		struct qeth_hdr *hdr, int offset, int hd_len)
 {
 	struct qdio_buffer *buffer;
-	int flush_cnt = 0, hdr_len, large_send = 0;
+	int flush_cnt = 0, hdr_len;
+	bool is_first_elem = true;
 
 	buffer = buf->buffer;
 	refcount_inc(&skb->users);
@@ -3974,6 +3972,7 @@ static inline int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
 	/*check first on TSO ....*/
 	if (hdr->hdr.l3.id == QETH_HEADER_TYPE_TSO) {
 		int element = buf->next_element_to_fill;
+		is_first_elem = false;
 
 		hdr_len = sizeof(struct qeth_hdr_tso) +
 			((struct qeth_hdr_tso *)hdr)->ext.dg_hdr_len;
@@ -3984,11 +3983,12 @@ static inline int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
 		buf->next_element_to_fill++;
 		skb->data += hdr_len;
 		skb->len  -= hdr_len;
-		large_send = 1;
 	}
 
 	if (offset >= 0) {
 		int element = buf->next_element_to_fill;
+		is_first_elem = false;
+
 		buffer->element[element].addr = hdr;
 		buffer->element[element].length = sizeof(struct qeth_hdr) +
 							hd_len;
@@ -3997,8 +3997,7 @@ static inline int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
 		buf->next_element_to_fill++;
 	}
 
-	__qeth_fill_buffer(skb, buffer, large_send,
-		(int *)&buf->next_element_to_fill, offset);
+	__qeth_fill_buffer(skb, buf, is_first_elem, offset);
 
 	if (!queue->do_pack) {
 		QETH_CARD_TEXT(queue->card, 6, "fillbfnp");
-- 
2.11.2
