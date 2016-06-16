From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 02/13] qeth: refactor calculation of SBALE count
Date: Thu, 16 Jun 2016 16:18:52 +0200
Message-ID: <1466086743-55484-3-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1466086743-55484-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:37036 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752492AbcFPOT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 10:19:29 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5GEIwWY120520
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:19:28 -0400
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com [195.75.94.112])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23kbtvnbxx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:19:28 -0400
Received: from localhost
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Thu, 16 Jun 2016 15:19:25 +0100
In-Reply-To: <1466086743-55484-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

Rewrite the functions that calculate the required number of buffer
elements needed to represent SKB data, to make them hopefully more
comprehensible. Plus a few cleanups.

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      | 13 +++++++++
 drivers/s390/net/qeth_core_main.c | 55 +++++++++++++++++++++++--------------
 drivers/s390/net/qeth_l3_main.c   | 58 +++++++++++++++++++++++++--------------
 3 files changed, 85 insertions(+), 41 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index ec2e014..eb8f434 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -844,6 +844,19 @@ struct qeth_trap_id {
 /*some helper functions*/
 #define QETH_CARD_IFNAME(card) (((card)->dev)? (card)->dev->name : "")
 
+/**
+ * qeth_get_elements_for_range() -	find number of SBALEs to cover range.
+ * @start:				Start of the address range.
+ * @end:				Address after the end of the range.
+ *
+ * Returns the number of pages, and thus QDIO buffer elements, needed to cover
+ * the specified address range.
+ */
+static inline int qeth_get_elements_for_range(addr_t start, addr_t end)
+{
+	return PFN_UP(end - 1) - PFN_DOWN(start);
+}
+
 static inline int qeth_get_micros(void)
 {
 	return (int) (get_tod_clock() >> 12);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index b7b7477..a91a31d 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3810,41 +3810,54 @@ int qeth_get_priority_queue(struct qeth_card *card, struct sk_buff *skb,
 }
 EXPORT_SYMBOL_GPL(qeth_get_priority_queue);
 
+/**
+ * qeth_get_elements_for_frags() -	find number of SBALEs for skb frags.
+ * @skb:				SKB address
+ *
+ * Returns the number of pages, and thus QDIO buffer elements, needed to cover
+ * fragmented part of the SKB. Returns zero for linear SKB.
+ */
 int qeth_get_elements_for_frags(struct sk_buff *skb)
 {
-	int cnt, length, e, elements = 0;
-	struct skb_frag_struct *frag;
-	char *data;
+	int cnt, elements = 0;
 
 	for (cnt = 0; cnt < skb_shinfo(skb)->nr_frags; cnt++) {
-		frag = &skb_shinfo(skb)->frags[cnt];
-		data = (char *)page_to_phys(skb_frag_page(frag)) +
-			frag->page_offset;
-		length = frag->size;
-		e = PFN_UP((unsigned long)data + length - 1) -
-			PFN_DOWN((unsigned long)data);
-		elements += e;
+		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[cnt];
+
+		elements += qeth_get_elements_for_range(
+			(addr_t)skb_frag_address(frag),
+			(addr_t)skb_frag_address(frag) + skb_frag_size(frag));
 	}
 	return elements;
 }
 EXPORT_SYMBOL_GPL(qeth_get_elements_for_frags);
 
+/**
+ * qeth_get_elements_no() -	find number of SBALEs for skb data, inc. frags.
+ * @card:			qeth card structure, to check max. elems.
+ * @skb:			SKB address
+ * @extra_elems:		extra elems needed, to check against max.
+ *
+ * Returns the number of pages, and thus QDIO buffer elements, needed to cover
+ * skb data, including linear part and fragments. Checks if the result plus
+ * extra_elems fits under the limit for the card. Returns 0 if it does not.
+ * Note: extra_elems is not included in the returned result.
+ */
 int qeth_get_elements_no(struct qeth_card *card,
-		     struct sk_buff *skb, int elems)
+		     struct sk_buff *skb, int extra_elems)
 {
-	int dlen = skb->len - skb->data_len;
-	int elements_needed = PFN_UP((unsigned long)skb->data + dlen - 1) -
-		PFN_DOWN((unsigned long)skb->data);
-
-	elements_needed += qeth_get_elements_for_frags(skb);
+	int elements = qeth_get_elements_for_range(
+				(addr_t)skb->data,
+				(addr_t)skb->data + skb_headlen(skb)) +
+			qeth_get_elements_for_frags(skb);
 
-	if ((elements_needed + elems) > QETH_MAX_BUFFER_ELEMENTS(card)) {
+	if ((elements + extra_elems) > QETH_MAX_BUFFER_ELEMENTS(card)) {
 		QETH_DBF_MESSAGE(2, "Invalid size of IP packet "
 			"(Number=%d / Length=%d). Discarded.\n",
-			(elements_needed+elems), skb->len);
+			elements + extra_elems, skb->len);
 		return 0;
 	}
-	return elements_needed;
+	return elements;
 }
 EXPORT_SYMBOL_GPL(qeth_get_elements_no);
 
@@ -3859,7 +3872,7 @@ int qeth_hdr_chk_and_bounce(struct sk_buff *skb, struct qeth_hdr **hdr, int len)
 		rest = len - inpage;
 		if (rest > hroom)
 			return 1;
-		memmove(skb->data - rest, skb->data, skb->len - skb->data_len);
+		memmove(skb->data - rest, skb->data, skb_headlen(skb));
 		skb->data -= rest;
 		skb->tail -= rest;
 		*hdr = (struct qeth_hdr *)skb->data;
@@ -3873,7 +3886,7 @@ static inline void __qeth_fill_buffer(struct sk_buff *skb,
 	struct qdio_buffer *buffer, int is_tso, int *next_element_to_fill,
 	int offset)
 {
-	int length = skb->len - skb->data_len;
+	int length = skb_headlen(skb);
 	int length_here;
 	int element;
 	char *data;
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index ac54433..7c9968a 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2793,15 +2793,34 @@ static void qeth_tso_fill_header(struct qeth_card *card,
 	}
 }
 
-static inline int qeth_l3_tso_elements(struct sk_buff *skb)
+/**
+ * qeth_get_elements_no_tso() - find number of SBALEs for skb data, inc. frags.
+ * @card:			qeth card structure, to check max. elems.
+ * @skb:			SKB address
+ * @extra_elems:		extra elems needed, to check against max.
+ *
+ * Returns the number of pages, and thus QDIO buffer elements, needed to cover
+ * skb data, including linear part and fragments, but excluding TCP header.
+ * (Exclusion of TCP header distinguishes it from qeth_get_elements_no().)
+ * Checks if the result plus extra_elems fits under the limit for the card.
+ * Returns 0 if it does not.
+ * Note: extra_elems is not included in the returned result.
+ */
+static int qeth_get_elements_no_tso(struct qeth_card *card,
+			struct sk_buff *skb, int extra_elems)
 {
-	unsigned long tcpd = (unsigned long)tcp_hdr(skb) +
-		tcp_hdr(skb)->doff * 4;
-	int tcpd_len = skb_headlen(skb) - (tcpd - (unsigned long)skb->data);
-	int elements = PFN_UP(tcpd + tcpd_len - 1) - PFN_DOWN(tcpd);
-
-	elements += qeth_get_elements_for_frags(skb);
+	addr_t tcpdptr = (addr_t)tcp_hdr(skb) + tcp_hdrlen(skb);
+	int elements = qeth_get_elements_for_range(
+				tcpdptr,
+				(addr_t)skb->data + skb_headlen(skb)) +
+		qeth_get_elements_for_frags(skb);
 
+	if ((elements + extra_elems) > QETH_MAX_BUFFER_ELEMENTS(card)) {
+		QETH_DBF_MESSAGE(2,
+	"Invalid size of TSO IP packet (Number=%d / Length=%d). Discarded.\n",
+				elements + extra_elems, skb->len);
+		return 0;
+	}
 	return elements;
 }
 
@@ -2810,8 +2829,8 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int rc;
 	u16 *tag;
 	struct qeth_hdr *hdr = NULL;
-	int elements_needed = 0;
-	int elems;
+	int hdr_elements = 0;
+	int elements;
 	struct qeth_card *card = dev->ml_priv;
 	struct sk_buff *new_skb = NULL;
 	int ipv = qeth_get_ip_version(skb);
@@ -2859,7 +2878,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		hdr = kmem_cache_alloc(qeth_core_header_cache, GFP_ATOMIC);
 		if (!hdr)
 			goto tx_drop;
-		elements_needed++;
+		hdr_elements++;
 	} else {
 		/* create a clone with writeable headroom */
 		new_skb = skb_realloc_headroom(skb, sizeof(struct qeth_hdr_tso)
@@ -2895,7 +2914,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * chaining we can not send long frag lists
 	 */
 	if (large_send) {
-		if (qeth_l3_tso_elements(new_skb) + 1 > 16) {
+		if (!qeth_get_elements_no_tso(card, new_skb, 1)) {
 			if (skb_linearize(new_skb))
 				goto tx_drop;
 			if (card->options.performance_stats)
@@ -2909,7 +2928,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		memset(hdr, 0, sizeof(struct qeth_hdr_tso));
 		qeth_l3_fill_header(card, hdr, new_skb, ipv, cast_type);
 		qeth_tso_fill_header(card, hdr, new_skb);
-		elements_needed++;
+		hdr_elements++;
 	} else {
 		if (data_offset < 0) {
 			hdr = (struct qeth_hdr *)skb_push(new_skb,
@@ -2930,31 +2949,29 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			qeth_l3_hdr_csum(card, hdr, new_skb);
 	}
 
-	elems = qeth_get_elements_no(card, new_skb, elements_needed);
-	if (!elems) {
+	elements = qeth_get_elements_no(card, new_skb, hdr_elements);
+	if (!elements) {
 		if (data_offset >= 0)
 			kmem_cache_free(qeth_core_header_cache, hdr);
 		goto tx_drop;
 	}
-	elements_needed += elems;
-	nr_frags = skb_shinfo(new_skb)->nr_frags;
+	elements += hdr_elements;
 
 	if (card->info.type != QETH_CARD_TYPE_IQD) {
 		int len;
 		if (large_send)
 			len = ((unsigned long)tcp_hdr(new_skb) +
-				tcp_hdr(new_skb)->doff * 4) -
+				tcp_hdrlen(new_skb)) -
 				(unsigned long)new_skb->data;
 		else
 			len = sizeof(struct qeth_hdr_layer3);
 
 		if (qeth_hdr_chk_and_bounce(new_skb, &hdr, len))
 			goto tx_drop;
-		rc = qeth_do_send_packet(card, queue, new_skb, hdr,
-					 elements_needed);
+		rc = qeth_do_send_packet(card, queue, new_skb, hdr, elements);
 	} else
 		rc = qeth_do_send_packet_fast(card, queue, new_skb, hdr,
-					elements_needed, data_offset, 0);
+					elements, data_offset, 0);
 
 	if (!rc) {
 		card->stats.tx_packets++;
@@ -2962,6 +2979,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (new_skb != skb)
 			dev_kfree_skb_any(skb);
 		if (card->options.performance_stats) {
+			nr_frags = skb_shinfo(new_skb)->nr_frags;
 			if (large_send) {
 				card->perf_stats.large_send_bytes += tx_bytes;
 				card->perf_stats.large_send_cnt++;
-- 
2.6.6
