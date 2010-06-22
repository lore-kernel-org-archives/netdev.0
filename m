From: frank.blaschka@de.ibm.com
Subject: [patch 09/11] [PATCH] qeth: fix page breaks in hw headers
Date: Tue, 22 Jun 2010 10:57:10 +0200
Message-ID: <20100622085808.056074000@de.ibm.com>
References: <20100622085701.772508000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:50269 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758957Ab0FVI6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 04:58:10 -0400
Content-Disposition: inline; filename=609-qeth-page-breaks.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Turning on memory debugging showed there could be page breaks in
hardware headers. OSA does not allow this so we had to add code
to bounce the header in case there is a page break. This patch also
fixes a problem in case the skb->data part of a fragmented skb
spreads multiple pages.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |    1 
 drivers/s390/net/qeth_core_main.c |  104 ++++++++++++++++----------------------
 drivers/s390/net/qeth_l2_main.c   |    7 +-
 drivers/s390/net/qeth_l3_main.c   |   26 ++++-----
 4 files changed, 65 insertions(+), 73 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2010-06-22 08:55:01.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2010-06-22 08:55:01.000000000 +0200
@@ -869,6 +869,7 @@ void qeth_core_get_drvinfo(struct net_de
 void qeth_dbf_longtext(debug_info_t *id, int level, char *text, ...);
 int qeth_core_ethtool_get_settings(struct net_device *, struct ethtool_cmd *);
 int qeth_set_access_ctrl_online(struct qeth_card *card);
+int qeth_hdr_chk_and_bounce(struct sk_buff *, int);
 
 /* exports for OSN */
 int qeth_osn_assist(struct net_device *, void *, int);
diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2010-06-22 08:55:01.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2010-06-22 08:55:01.000000000 +0200
@@ -57,48 +57,6 @@ static void qeth_free_buffer_pool(struct
 static int qeth_qdio_establish(struct qeth_card *);
 
 
-static inline void __qeth_fill_buffer_frag(struct sk_buff *skb,
-		struct qdio_buffer *buffer, int is_tso,
-		int *next_element_to_fill)
-{
-	struct skb_frag_struct *frag;
-	int fragno;
-	unsigned long addr;
-	int element, cnt, dlen;
-
-	fragno = skb_shinfo(skb)->nr_frags;
-	element = *next_element_to_fill;
-	dlen = 0;
-
-	if (is_tso)
-		buffer->element[element].flags =
-			SBAL_FLAGS_MIDDLE_FRAG;
-	else
-		buffer->element[element].flags =
-			SBAL_FLAGS_FIRST_FRAG;
-	dlen = skb->len - skb->data_len;
-	if (dlen) {
-		buffer->element[element].addr = skb->data;
-		buffer->element[element].length = dlen;
-		element++;
-	}
-	for (cnt = 0; cnt < fragno; cnt++) {
-		frag = &skb_shinfo(skb)->frags[cnt];
-		addr = (page_to_pfn(frag->page) << PAGE_SHIFT) +
-			frag->page_offset;
-		buffer->element[element].addr = (char *)addr;
-		buffer->element[element].length = frag->size;
-		if (cnt < (fragno - 1))
-			buffer->element[element].flags =
-				SBAL_FLAGS_MIDDLE_FRAG;
-		else
-			buffer->element[element].flags =
-				SBAL_FLAGS_LAST_FRAG;
-		element++;
-	}
-	*next_element_to_fill = element;
-}
-
 static inline const char *qeth_get_cardname(struct qeth_card *card)
 {
 	if (card->info.guestlan) {
@@ -3020,13 +2978,11 @@ EXPORT_SYMBOL_GPL(qeth_get_priority_queu
 int qeth_get_elements_no(struct qeth_card *card, void *hdr,
 		     struct sk_buff *skb, int elems)
 {
-	int elements_needed = 0;
+	int dlen = skb->len - skb->data_len;
+	int elements_needed = PFN_UP((unsigned long)skb->data + dlen - 1) -
+		PFN_DOWN((unsigned long)skb->data);
 
-	if (skb_shinfo(skb)->nr_frags > 0)
-		elements_needed = (skb_shinfo(skb)->nr_frags + 1);
-	if (elements_needed == 0)
-		elements_needed = 1 + (((((unsigned long) skb->data) %
-				PAGE_SIZE) + skb->len) >> PAGE_SHIFT);
+	elements_needed += skb_shinfo(skb)->nr_frags;
 	if ((elements_needed + elems) > QETH_MAX_BUFFER_ELEMENTS(card)) {
 		QETH_DBF_MESSAGE(2, "Invalid size of IP packet "
 			"(Number=%d / Length=%d). Discarded.\n",
@@ -3037,15 +2993,35 @@ int qeth_get_elements_no(struct qeth_car
 }
 EXPORT_SYMBOL_GPL(qeth_get_elements_no);
 
+int qeth_hdr_chk_and_bounce(struct sk_buff *skb, int len)
+{
+	int hroom, inpage, rest;
+
+	if (((unsigned long)skb->data & PAGE_MASK) !=
+	    (((unsigned long)skb->data + len - 1) & PAGE_MASK)) {
+		hroom = skb_headroom(skb);
+		inpage = PAGE_SIZE - ((unsigned long) skb->data % PAGE_SIZE);
+		rest = len - inpage;
+		if (rest > hroom)
+			return 1;
+		memmove(skb->data - rest, skb->data, skb->len - skb->data_len);
+		skb->data -= rest;
+		QETH_DBF_MESSAGE(2, "skb bounce len: %d rest: %d\n", len, rest);
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(qeth_hdr_chk_and_bounce);
+
 static inline void __qeth_fill_buffer(struct sk_buff *skb,
 	struct qdio_buffer *buffer, int is_tso, int *next_element_to_fill,
 	int offset)
 {
-	int length = skb->len;
+	int length = skb->len - skb->data_len;
 	int length_here;
 	int element;
 	char *data;
-	int first_lap ;
+	int first_lap, cnt;
+	struct skb_frag_struct *frag;
 
 	element = *next_element_to_fill;
 	data = skb->data;
@@ -3068,10 +3044,14 @@ static inline void __qeth_fill_buffer(st
 		length -= length_here;
 		if (!length) {
 			if (first_lap)
-				buffer->element[element].flags = 0;
+				if (skb_shinfo(skb)->nr_frags)
+					buffer->element[element].flags =
+						SBAL_FLAGS_FIRST_FRAG;
+				else
+					buffer->element[element].flags = 0;
 			else
 				buffer->element[element].flags =
-				    SBAL_FLAGS_LAST_FRAG;
+				    SBAL_FLAGS_MIDDLE_FRAG;
 		} else {
 			if (first_lap)
 				buffer->element[element].flags =
@@ -3084,6 +3064,18 @@ static inline void __qeth_fill_buffer(st
 		element++;
 		first_lap = 0;
 	}
+
+	for (cnt = 0; cnt < skb_shinfo(skb)->nr_frags; cnt++) {
+		frag = &skb_shinfo(skb)->frags[cnt];
+		buffer->element[element].addr = (char *)page_to_phys(frag->page)
+			+ frag->page_offset;
+		buffer->element[element].length = frag->size;
+		buffer->element[element].flags = SBAL_FLAGS_MIDDLE_FRAG;
+		element++;
+	}
+
+	if (buffer->element[element - 1].flags)
+		buffer->element[element - 1].flags = SBAL_FLAGS_LAST_FRAG;
 	*next_element_to_fill = element;
 }
 
@@ -3124,12 +3116,8 @@ static inline int qeth_fill_buffer(struc
 		buf->next_element_to_fill++;
 	}
 
-	if (skb_shinfo(skb)->nr_frags == 0)
-		__qeth_fill_buffer(skb, buffer, large_send,
-				(int *)&buf->next_element_to_fill, offset);
-	else
-		__qeth_fill_buffer_frag(skb, buffer, large_send,
-					(int *)&buf->next_element_to_fill);
+	__qeth_fill_buffer(skb, buffer, large_send,
+		(int *)&buf->next_element_to_fill, offset);
 
 	if (!queue->do_pack) {
 		QETH_CARD_TEXT(queue->card, 6, "fillbfnp");
diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2010-06-22 08:54:59.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2010-06-22 08:55:01.000000000 +0200
@@ -712,10 +712,13 @@ static int qeth_l2_hard_start_xmit(struc
 		goto tx_drop;
 	}
 
-	if (card->info.type != QETH_CARD_TYPE_IQD)
+	if (card->info.type != QETH_CARD_TYPE_IQD) {
+		if (qeth_hdr_chk_and_bounce(new_skb,
+		    sizeof(struct qeth_hdr_layer2)))
+			goto tx_drop;
 		rc = qeth_do_send_packet(card, queue, new_skb, hdr,
 					 elements);
-	else
+	} else
 		rc = qeth_do_send_packet_fast(card, queue, new_skb, hdr,
 					elements, data_offset, hd_len);
 	if (!rc) {
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2010-06-22 08:54:59.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2010-06-22 08:55:01.000000000 +0200
@@ -2904,19 +2904,11 @@ static inline int qeth_l3_tso_elements(s
 	unsigned long tcpd = (unsigned long)tcp_hdr(skb) +
 		tcp_hdr(skb)->doff * 4;
 	int tcpd_len = skb->len - (tcpd - (unsigned long)skb->data);
-	int elements = PFN_UP(tcpd + tcpd_len) - PFN_DOWN(tcpd);
+	int elements = PFN_UP(tcpd + tcpd_len - 1) - PFN_DOWN(tcpd);
 	elements += skb_shinfo(skb)->nr_frags;
 	return elements;
 }
 
-static inline int qeth_l3_tso_check(struct sk_buff *skb)
-{
-	int len = ((unsigned long)tcp_hdr(skb) + tcp_hdr(skb)->doff * 4) -
-		(unsigned long)skb->data;
-	return (((unsigned long)skb->data & PAGE_MASK) !=
-		(((unsigned long)skb->data + len) & PAGE_MASK));
-}
-
 static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	int rc;
@@ -3016,8 +3008,6 @@ static int qeth_l3_hard_start_xmit(struc
 	    (cast_type == RTN_UNSPEC)) {
 		hdr = (struct qeth_hdr *)skb_push(new_skb,
 						sizeof(struct qeth_hdr_tso));
-		if (qeth_l3_tso_check(new_skb))
-			QETH_DBF_MESSAGE(2, "tso skb misaligned\n");
 		memset(hdr, 0, sizeof(struct qeth_hdr_tso));
 		qeth_l3_fill_header(card, hdr, new_skb, ipv, cast_type);
 		qeth_tso_fill_header(card, hdr, new_skb);
@@ -3048,10 +3038,20 @@ static int qeth_l3_hard_start_xmit(struc
 	elements_needed += elems;
 	nr_frags = skb_shinfo(new_skb)->nr_frags;
 
-	if (card->info.type != QETH_CARD_TYPE_IQD)
+	if (card->info.type != QETH_CARD_TYPE_IQD) {
+		int len;
+		if (large_send == QETH_LARGE_SEND_TSO)
+			len = ((unsigned long)tcp_hdr(new_skb) +
+				tcp_hdr(new_skb)->doff * 4) -
+				(unsigned long)new_skb->data;
+		else
+			len = sizeof(struct qeth_hdr_layer3);
+
+		if (qeth_hdr_chk_and_bounce(new_skb, len))
+			goto tx_drop;
 		rc = qeth_do_send_packet(card, queue, new_skb, hdr,
 					 elements_needed);
-	else
+	} else
 		rc = qeth_do_send_packet_fast(card, queue, new_skb, hdr,
 					elements_needed, data_offset, 0);
 

