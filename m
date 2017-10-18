From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 09/13] s390/qeth: clean up page frag creation
Date: Wed, 18 Oct 2017 17:40:21 +0200
Message-ID: <20171018154025.73630-10-jwi@linux.vnet.ibm.com>
References: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:38022 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751907AbdJRPkw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:40:52 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9IFduwD017363
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:51 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2dp69v5fkq-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:51 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Wed, 18 Oct 2017 16:40:49 +0100
In-Reply-To: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the open-coded skb_add_rx_frag(), and use a fall-through
to remove some duplicated code.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 31 +++++++++++--------------------
 1 file changed, 11 insertions(+), 20 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index acf16fa75c63..1cf4e066955f 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -5172,10 +5172,11 @@ EXPORT_SYMBOL_GPL(qeth_core_hardsetup_card);
 
 static int qeth_create_skb_frag(struct qeth_qdio_buffer *qethbuffer,
 				struct qdio_buffer_element *element,
-				struct sk_buff **pskb, int offset, int *pfrag,
-				int data_len)
+				struct sk_buff **pskb, int offset, int data_len)
 {
 	struct page *page = virt_to_page(element->addr);
+	unsigned int next_frag;
+
 	if (*pskb == NULL) {
 		if (qethbuffer->rx_skb) {
 			/* only if qeth_card.options.cq == QETH_CQ_ENABLED */
@@ -5190,28 +5191,19 @@ static int qeth_create_skb_frag(struct qeth_qdio_buffer *qethbuffer,
 		skb_reserve(*pskb, ETH_HLEN);
 		if (data_len <= QETH_RX_PULL_LEN) {
 			skb_put_data(*pskb, element->addr + offset, data_len);
+			return 0;
 		} else {
-			get_page(page);
 			skb_put_data(*pskb, element->addr + offset,
 				     QETH_RX_PULL_LEN);
-			skb_fill_page_desc(*pskb, *pfrag, page,
-				offset + QETH_RX_PULL_LEN,
-				data_len - QETH_RX_PULL_LEN);
-			(*pskb)->data_len += data_len - QETH_RX_PULL_LEN;
-			(*pskb)->len      += data_len - QETH_RX_PULL_LEN;
-			(*pskb)->truesize += data_len - QETH_RX_PULL_LEN;
-			(*pfrag)++;
+			data_len -= QETH_RX_PULL_LEN;
+			offset += QETH_RX_PULL_LEN;
+			/* fall through to add page frag for remaining data */
 		}
-	} else {
-		get_page(page);
-		skb_fill_page_desc(*pskb, *pfrag, page, offset, data_len);
-		(*pskb)->data_len += data_len;
-		(*pskb)->len      += data_len;
-		(*pskb)->truesize += data_len;
-		(*pfrag)++;
 	}
 
-
+	next_frag = skb_shinfo(*pskb)->nr_frags;
+	get_page(page);
+	skb_add_rx_frag(*pskb, next_frag, page, offset, data_len, data_len);
 	return 0;
 }
 
@@ -5234,7 +5226,6 @@ struct sk_buff *qeth_core_get_next_skb(struct qeth_card *card,
 	int data_len;
 	int headroom = 0;
 	int use_rx_sg = 0;
-	int frag = 0;
 
 	/* qeth_hdr must not cross element boundaries */
 	if (element->length < offset + sizeof(struct qeth_hdr)) {
@@ -5286,7 +5277,7 @@ struct sk_buff *qeth_core_get_next_skb(struct qeth_card *card,
 		if (data_len) {
 			if (use_rx_sg) {
 				if (qeth_create_skb_frag(qethbuffer, element,
-				    &skb, offset, &frag, data_len))
+				    &skb, offset, data_len))
 					goto no_mem;
 			} else {
 				skb_put_data(skb, data_ptr, data_len);
-- 
2.13.5
