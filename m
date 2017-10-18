From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 10/13] s390/qeth: consolidate skb allocation
Date: Wed, 18 Oct 2017 17:40:22 +0200
Message-ID: <20171018154025.73630-11-jwi@linux.vnet.ibm.com>
References: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:56636 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751900AbdJRPkv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:40:51 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9IFdYjI085363
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:50 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2dp9p5rdev-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:50 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Wed, 18 Oct 2017 16:40:49 +0100
In-Reply-To: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the allocation of SG skbs into the main path. This allows for
a little code sharing, and handling ENOMEM from within one place.

As side effect, L2 SG skbs now get the proper amount of additional
headroom (read: zero) instead of the hard-coded ETH_HLEN.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 71 +++++++++++++++++----------------------
 1 file changed, 31 insertions(+), 40 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 1cf4e066955f..23b439fb5f2c 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -5170,41 +5170,27 @@ int qeth_core_hardsetup_card(struct qeth_card *card)
 }
 EXPORT_SYMBOL_GPL(qeth_core_hardsetup_card);
 
-static int qeth_create_skb_frag(struct qeth_qdio_buffer *qethbuffer,
-				struct qdio_buffer_element *element,
-				struct sk_buff **pskb, int offset, int data_len)
+static void qeth_create_skb_frag(struct qdio_buffer_element *element,
+				 struct sk_buff *skb, int offset, int data_len)
 {
 	struct page *page = virt_to_page(element->addr);
 	unsigned int next_frag;
 
-	if (*pskb == NULL) {
-		if (qethbuffer->rx_skb) {
-			/* only if qeth_card.options.cq == QETH_CQ_ENABLED */
-			*pskb = qethbuffer->rx_skb;
-			qethbuffer->rx_skb = NULL;
-		} else {
-			*pskb = dev_alloc_skb(QETH_RX_PULL_LEN + ETH_HLEN);
-			if (!(*pskb))
-				return -ENOMEM;
-		}
+	/* first fill the linear space */
+	if (!skb->len) {
+		unsigned int linear = min(data_len, skb_tailroom(skb));
 
-		skb_reserve(*pskb, ETH_HLEN);
-		if (data_len <= QETH_RX_PULL_LEN) {
-			skb_put_data(*pskb, element->addr + offset, data_len);
-			return 0;
-		} else {
-			skb_put_data(*pskb, element->addr + offset,
-				     QETH_RX_PULL_LEN);
-			data_len -= QETH_RX_PULL_LEN;
-			offset += QETH_RX_PULL_LEN;
-			/* fall through to add page frag for remaining data */
-		}
+		skb_put_data(skb, element->addr + offset, linear);
+		data_len -= linear;
+		if (!data_len)
+			return;
+		offset += linear;
+		/* fall through to add page frag for remaining data */
 	}
 
-	next_frag = skb_shinfo(*pskb)->nr_frags;
+	next_frag = skb_shinfo(skb)->nr_frags;
 	get_page(page);
-	skb_add_rx_frag(*pskb, next_frag, page, offset, data_len, data_len);
-	return 0;
+	skb_add_rx_frag(skb, next_frag, page, offset, data_len, data_len);
 }
 
 static inline int qeth_is_last_sbale(struct qdio_buffer_element *sbale)
@@ -5220,7 +5206,7 @@ struct sk_buff *qeth_core_get_next_skb(struct qeth_card *card,
 	struct qdio_buffer_element *element = *__element;
 	struct qdio_buffer *buffer = qethbuffer->buffer;
 	int offset = *__offset;
-	struct sk_buff *skb = NULL;
+	struct sk_buff *skb;
 	int skb_len = 0;
 	void *data_ptr;
 	int data_len;
@@ -5261,27 +5247,32 @@ struct sk_buff *qeth_core_get_next_skb(struct qeth_card *card,
 	if (((skb_len >= card->options.rx_sg_cb) &&
 	     (!(card->info.type == QETH_CARD_TYPE_OSN)) &&
 	     (!atomic_read(&card->force_alloc_skb))) ||
-	    (card->options.cq == QETH_CQ_ENABLED)) {
+	    (card->options.cq == QETH_CQ_ENABLED))
 		use_rx_sg = 1;
+
+	if (use_rx_sg && qethbuffer->rx_skb) {
+		/* QETH_CQ_ENABLED only: */
+		skb = qethbuffer->rx_skb;
+		qethbuffer->rx_skb = NULL;
 	} else {
-		skb = dev_alloc_skb(skb_len + headroom);
-		if (!skb)
-			goto no_mem;
-		if (headroom)
-			skb_reserve(skb, headroom);
+		unsigned int linear = (use_rx_sg) ? QETH_RX_PULL_LEN : skb_len;
+
+		skb = dev_alloc_skb(linear + headroom);
 	}
+	if (!skb)
+		goto no_mem;
+	if (headroom)
+		skb_reserve(skb, headroom);
 
 	data_ptr = element->addr + offset;
 	while (skb_len) {
 		data_len = min(skb_len, (int)(element->length - offset));
 		if (data_len) {
-			if (use_rx_sg) {
-				if (qeth_create_skb_frag(qethbuffer, element,
-				    &skb, offset, data_len))
-					goto no_mem;
-			} else {
+			if (use_rx_sg)
+				qeth_create_skb_frag(element, skb, offset,
+						     data_len);
+			else
 				skb_put_data(skb, data_ptr, data_len);
-			}
 		}
 		skb_len -= data_len;
 		if (skb_len) {
-- 
2.13.5
