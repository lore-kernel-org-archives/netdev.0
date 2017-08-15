From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 07/12] s390/qeth: make more use of skb API
Date: Tue, 15 Aug 2017 17:02:45 +0200
Message-ID: <20170815150250.67158-8-jwi@linux.vnet.ibm.com>
References: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:57242 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752607AbdHOPDM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:03:12 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7FExLlj085469
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:11 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2cbsqvtn6e-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:11 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 15 Aug 2017 16:03:09 +0100
In-Reply-To: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace some open-coded parts with their proper API calls.

Also remove two skb_[re]set_mac_header() calls in the L2
xmit paths that are clearly no longer required, since at least
commit 6d1ccff62780 ("net: reset mac header in dev_start_xmit()").

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Acked-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  5 -----
 drivers/s390/net/qeth_core_main.c | 12 +++++-------
 drivers/s390/net/qeth_l2_main.c   |  7 +++----
 drivers/s390/net/qeth_l3_main.c   |  4 ++--
 4 files changed, 10 insertions(+), 18 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 95266449a50a..4a4ca5cb37a0 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -857,11 +857,6 @@ static inline int qeth_get_ip_version(struct sk_buff *skb)
 	}
 }
 
-static inline int qeth_get_ip_protocol(struct sk_buff *skb)
-{
-	return ip_hdr(skb)->protocol;
-}
-
 static inline void qeth_put_buffer_pool_entry(struct qeth_card *card,
 		struct qeth_buffer_pool_entry *entry)
 {
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 394bee93b891..6286a8e35924 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3897,7 +3897,6 @@ static inline void __qeth_fill_buffer(struct sk_buff *skb,
 	int length = skb_headlen(skb) - offset;
 	char *data = skb->data + offset;
 	int length_here, cnt;
-	struct skb_frag_struct *frag;
 
 	/* map linear part into buffer element(s) */
 	while (length > 0) {
@@ -3927,10 +3926,10 @@ static inline void __qeth_fill_buffer(struct sk_buff *skb,
 
 	/* map page frags into buffer element(s) */
 	for (cnt = 0; cnt < skb_shinfo(skb)->nr_frags; cnt++) {
-		frag = &skb_shinfo(skb)->frags[cnt];
-		data = (char *)page_to_phys(skb_frag_page(frag)) +
-			frag->page_offset;
-		length = frag->size;
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[cnt];
+
+		data = skb_frag_address(frag);
+		length = skb_frag_size(frag);
 		while (length > 0) {
 			length_here = PAGE_SIZE -
 				((unsigned long) data % PAGE_SIZE);
@@ -3976,8 +3975,7 @@ static inline int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
 		buffer->element[element].length = hdr_len;
 		buffer->element[element].eflags = SBAL_EFLAGS_FIRST_FRAG;
 		buf->next_element_to_fill++;
-		skb->data += hdr_len;
-		skb->len  -= hdr_len;
+		skb_pull(skb, hdr_len);
 	}
 
 	/* IQD */
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index a6ba897ed707..9c789ad6831a 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -752,11 +752,11 @@ static netdev_tx_t qeth_l2_hard_start_xmit(struct sk_buff *skb,
 			if (!hdr)
 				goto tx_drop;
 			elements_needed++;
-			skb_reset_mac_header(new_skb);
 			qeth_l2_fill_header(card, hdr, new_skb, cast_type);
 			hdr->hdr.l2.pkt_length = new_skb->len;
-			memcpy(((char *)hdr) + sizeof(struct qeth_hdr),
-				skb_mac_header(new_skb), ETH_HLEN);
+			skb_copy_from_linear_data(new_skb,
+						  ((char *)hdr) + sizeof(*hdr),
+						  ETH_HLEN);
 		} else {
 			/* create a clone with writeable headroom */
 			new_skb = skb_realloc_headroom(skb,
@@ -764,7 +764,6 @@ static netdev_tx_t qeth_l2_hard_start_xmit(struct sk_buff *skb,
 			if (!new_skb)
 				goto tx_drop;
 			hdr = skb_push(new_skb, sizeof(struct qeth_hdr));
-			skb_set_mac_header(new_skb, sizeof(struct qeth_hdr));
 			qeth_l2_fill_header(card, hdr, new_skb, cast_type);
 			if (new_skb->ip_summed == CHECKSUM_PARTIAL)
 				qeth_l2_hdr_csum(card, hdr, new_skb);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 13124e6fd9d3..97ca8a6cbb21 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2570,7 +2570,7 @@ static void qeth_tso_fill_header(struct qeth_card *card,
 	hdr->ext.hdr_len     = 28;
 	/*insert non-fix values */
 	hdr->ext.mss = skb_shinfo(skb)->gso_size;
-	hdr->ext.dg_hdr_len = (__u16)(iph->ihl*4 + tcph->doff*4);
+	hdr->ext.dg_hdr_len = (__u16)(ip_hdrlen(skb) + tcp_hdrlen(skb));
 	hdr->ext.payload_len = (__u16)(skb->len - hdr->ext.dg_hdr_len -
 				       sizeof(struct qeth_hdr_tso));
 	tcph->check = 0;
@@ -2663,7 +2663,7 @@ static netdev_tx_t qeth_l3_hard_start_xmit(struct sk_buff *skb,
 
 	/* Ignore segment size from skb_is_gso(), 1 page is always used. */
 	use_tso = skb_is_gso(skb) &&
-		  (qeth_get_ip_protocol(skb) == IPPROTO_TCP) && (ipv == 4);
+		  (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4);
 
 	if (card->info.type == QETH_CARD_TYPE_IQD) {
 		new_skb = skb;
-- 
2.11.2
