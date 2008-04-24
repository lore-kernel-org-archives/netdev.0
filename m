From: frank.blaschka@de.ibm.com
Subject: [patch 07/11] qeth: rework fast path
Date: Thu, 24 Apr 2008 10:15:24 +0200
Message-ID: <20080424081906.402444000@de.ibm.com>
References: <20080424081517.987104000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:59189 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357AbYDXITJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 04:19:09 -0400
Content-Disposition: inline; filename=706-qeth-fastpath.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Remove unnecessary traces. Remove unnecessary wrappers for skb
functions.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |   31 +++--------------
 drivers/s390/net/qeth_core_main.c |   67 +-------------------------------------
 drivers/s390/net/qeth_l2_main.c   |    8 ++--
 drivers/s390/net/qeth_l3_main.c   |    5 --
 4 files changed, 13 insertions(+), 98 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2008-04-23 17:55:52.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2008-04-23 17:55:52.000000000 +0200
@@ -758,27 +758,6 @@ static inline int qeth_get_micros(void)
 	return (int) (get_clock() >> 12);
 }
 
-static inline void *qeth_push_skb(struct qeth_card *card, struct sk_buff *skb,
-		int size)
-{
-	void *hdr;
-
-	hdr = (void *) skb_push(skb, size);
-	/*
-	 * sanity check, the Linux memory allocation scheme should
-	 * never present us cases like this one (the qdio header size plus
-	 * the first 40 bytes of the paket cross a 4k boundary)
-	 */
-	if ((((unsigned long) hdr) & (~(PAGE_SIZE - 1))) !=
-	    (((unsigned long) hdr + size +
-	    QETH_IP_HEADER_SIZE) & (~(PAGE_SIZE - 1)))) {
-		PRINT_ERR("Misaligned packet on interface %s. Discarded.",
-			QETH_CARD_IFNAME(card));
-		return NULL;
-	}
-	return hdr;
-}
-
 static inline int qeth_get_ip_version(struct sk_buff *skb)
 {
 	switch (skb->protocol) {
@@ -791,6 +770,12 @@ static inline int qeth_get_ip_version(st
 	}
 }
 
+static inline void qeth_put_buffer_pool_entry(struct qeth_card *card,
+		struct qeth_buffer_pool_entry *entry)
+{
+	list_add_tail(&entry->list, &card->qdio.in_buf_pool.entry_list);
+}
+
 struct qeth_eddp_context;
 extern struct ccwgroup_driver qeth_l2_ccwgroup_driver;
 extern struct ccwgroup_driver qeth_l3_ccwgroup_driver;
@@ -828,8 +813,6 @@ struct qeth_cmd_buffer *qeth_get_ipacmd_
 int qeth_query_setadapterparms(struct qeth_card *);
 int qeth_check_qdio_errors(struct qdio_buffer *, unsigned int,
 		       unsigned int, const char *);
-void qeth_put_buffer_pool_entry(struct qeth_card *,
-			   struct qeth_buffer_pool_entry *);
 void qeth_queue_input_buffer(struct qeth_card *, int);
 struct sk_buff *qeth_core_get_next_skb(struct qeth_card *,
 		struct qdio_buffer *, struct qdio_buffer_element **, int *,
@@ -865,8 +848,6 @@ int qeth_send_control_data(struct qeth_c
 	void *reply_param);
 int qeth_get_cast_type(struct qeth_card *, struct sk_buff *);
 int qeth_get_priority_queue(struct qeth_card *, struct sk_buff *, int, int);
-struct sk_buff *qeth_prepare_skb(struct qeth_card *, struct sk_buff *,
-		 struct qeth_hdr **);
 int qeth_get_elements_no(struct qeth_card *, void *, struct sk_buff *, int);
 int qeth_do_send_packet_fast(struct qeth_card *, struct qeth_qdio_out_q *,
 			struct sk_buff *, struct qeth_hdr *, int,
diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2008-04-23 17:55:52.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2008-04-23 17:55:52.000000000 +0200
@@ -2252,14 +2252,6 @@ void qeth_print_status_message(struct qe
 }
 EXPORT_SYMBOL_GPL(qeth_print_status_message);
 
-void qeth_put_buffer_pool_entry(struct qeth_card *card,
-		struct qeth_buffer_pool_entry *entry)
-{
-	QETH_DBF_TEXT(TRACE, 6, "ptbfplen");
-	list_add_tail(&entry->list, &card->qdio.in_buf_pool.entry_list);
-}
-EXPORT_SYMBOL_GPL(qeth_put_buffer_pool_entry);
-
 static void qeth_initialize_working_pool_list(struct qeth_card *card)
 {
 	struct qeth_buffer_pool_entry *entry;
@@ -2600,7 +2592,6 @@ void qeth_queue_input_buffer(struct qeth
 	int rc;
 	int newcount = 0;
 
-	QETH_DBF_TEXT(TRACE, 6, "queinbuf");
 	count = (index < queue->next_buf_to_init)?
 		card->qdio.in_buf_pool.buf_count -
 		(queue->next_buf_to_init - index) :
@@ -2789,8 +2780,6 @@ static void qeth_flush_buffers(struct qe
 	int i;
 	unsigned int qdio_flags;
 
-	QETH_DBF_TEXT(TRACE, 6, "flushbuf");
-
 	for (i = index; i < index + count; ++i) {
 		buf = &queue->bufs[i % QDIO_MAX_BUFFERS_PER_Q];
 		buf->buffer->element[buf->next_element_to_fill - 1].flags |=
@@ -3034,49 +3023,6 @@ int qeth_get_priority_queue(struct qeth_
 }
 EXPORT_SYMBOL_GPL(qeth_get_priority_queue);
 
-static void __qeth_free_new_skb(struct sk_buff *orig_skb,
-		struct sk_buff *new_skb)
-{
-	if (orig_skb != new_skb)
-		dev_kfree_skb_any(new_skb);
-}
-
-static inline struct sk_buff *qeth_realloc_headroom(struct qeth_card *card,
-		struct sk_buff *skb, int size)
-{
-	struct sk_buff *new_skb = skb;
-
-	if (skb_headroom(skb) >= size)
-		return skb;
-	new_skb = skb_realloc_headroom(skb, size);
-	if (!new_skb)
-		PRINT_ERR("Could not realloc headroom for qeth_hdr "
-			  "on interface %s", QETH_CARD_IFNAME(card));
-	return new_skb;
-}
-
-struct sk_buff *qeth_prepare_skb(struct qeth_card *card, struct sk_buff *skb,
-		 struct qeth_hdr **hdr)
-{
-	struct sk_buff *new_skb;
-
-	QETH_DBF_TEXT(TRACE, 6, "prepskb");
-
-	new_skb = qeth_realloc_headroom(card, skb,
-			sizeof(struct qeth_hdr));
-	if (!new_skb)
-		return NULL;
-
-	*hdr = ((struct qeth_hdr *)qeth_push_skb(card, new_skb,
-			sizeof(struct qeth_hdr)));
-	if (*hdr == NULL) {
-		__qeth_free_new_skb(skb, new_skb);
-		return NULL;
-	}
-	return new_skb;
-}
-EXPORT_SYMBOL_GPL(qeth_prepare_skb);
-
 int qeth_get_elements_no(struct qeth_card *card, void *hdr,
 		     struct sk_buff *skb, int elems)
 {
@@ -3097,8 +3043,8 @@ int qeth_get_elements_no(struct qeth_car
 }
 EXPORT_SYMBOL_GPL(qeth_get_elements_no);
 
-static void __qeth_fill_buffer(struct sk_buff *skb, struct qdio_buffer *buffer,
-		int is_tso, int *next_element_to_fill)
+static inline void __qeth_fill_buffer(struct sk_buff *skb,
+	struct qdio_buffer *buffer, int is_tso, int *next_element_to_fill)
 {
 	int length = skb->len;
 	int length_here;
@@ -3140,15 +3086,13 @@ static void __qeth_fill_buffer(struct sk
 	*next_element_to_fill = element;
 }
 
-static int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
+static inline int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
 		struct qeth_qdio_out_buffer *buf, struct sk_buff *skb)
 {
 	struct qdio_buffer *buffer;
 	struct qeth_hdr_tso *hdr;
 	int flush_cnt = 0, hdr_len, large_send = 0;
 
-	QETH_DBF_TEXT(TRACE, 6, "qdfillbf");
-
 	buffer = buf->buffer;
 	atomic_inc(&skb->users);
 	skb_queue_tail(&buf->skb_list, skb);
@@ -3207,8 +3151,6 @@ int qeth_do_send_packet_fast(struct qeth
 	int flush_cnt = 0;
 	int index;
 
-	QETH_DBF_TEXT(TRACE, 6, "dosndpfa");
-
 	/* spin until we get the queue ... */
 	while (atomic_cmpxchg(&queue->state, QETH_OUT_Q_UNLOCKED,
 			      QETH_OUT_Q_LOCKED) != QETH_OUT_Q_UNLOCKED);
@@ -3260,8 +3202,6 @@ int qeth_do_send_packet(struct qeth_card
 	int tmp;
 	int rc = 0;
 
-	QETH_DBF_TEXT(TRACE, 6, "dosndpkt");
-
 	/* spin until we get the queue ... */
 	while (atomic_cmpxchg(&queue->state, QETH_OUT_Q_UNLOCKED,
 			      QETH_OUT_Q_LOCKED) != QETH_OUT_Q_UNLOCKED);
@@ -3958,7 +3898,6 @@ struct sk_buff *qeth_core_get_next_skb(s
 	int use_rx_sg = 0;
 	int frag = 0;
 
-	QETH_DBF_TEXT(TRACE, 6, "nextskb");
 	/* qeth_hdr must not cross element boundaries */
 	if (element->length < offset + sizeof(struct qeth_hdr)) {
 		if (qeth_is_last_sbale(element))
diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2008-04-23 17:55:52.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2008-04-23 17:55:52.000000000 +0200
@@ -632,8 +632,6 @@ static int qeth_l2_hard_start_xmit(struc
 	enum qeth_large_send_types large_send = QETH_LARGE_SEND_NO;
 	struct qeth_eddp_context *ctx = NULL;
 
-	QETH_DBF_TEXT(TRACE, 6, "l2xmit");
-
 	if ((card->state != CARD_STATE_UP) || !card->lan_online) {
 		card->stats.tx_carrier_errors++;
 		goto tx_drop;
@@ -655,9 +653,12 @@ static int qeth_l2_hard_start_xmit(struc
 	if (card->info.type == QETH_CARD_TYPE_OSN)
 		hdr = (struct qeth_hdr *)skb->data;
 	else {
-		new_skb = qeth_prepare_skb(card, skb, &hdr);
+		/* create a clone with writeable headroom */
+		new_skb = skb_realloc_headroom(skb, sizeof(struct qeth_hdr));
 		if (!new_skb)
 			goto tx_drop;
+		hdr = (struct qeth_hdr *)skb_push(new_skb,
+						sizeof(struct qeth_hdr));
 		qeth_l2_fill_header(card, hdr, new_skb, ipv, cast_type);
 	}
 
@@ -744,7 +745,6 @@ static void qeth_l2_qdio_input_handler(s
 	int index;
 	int i;
 
-	QETH_DBF_TEXT(TRACE, 6, "qdinput");
 	card = (struct qeth_card *) card_ptr;
 	net_dev = card->dev;
 	if (card->options.performance_stats) {
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2008-04-23 17:55:52.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2008-04-23 17:55:52.000000000 +0200
@@ -2557,8 +2557,6 @@ static int qeth_l3_do_ioctl(struct net_d
 static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 		struct sk_buff *skb, int ipv, int cast_type)
 {
-	QETH_DBF_TEXT(TRACE, 6, "fillhdr");
-
 	memset(hdr, 0, sizeof(struct qeth_hdr));
 	hdr->hdr.l3.id = QETH_HEADER_TYPE_LAYER3;
 	hdr->hdr.l3.ext_flags = 0;
@@ -2637,8 +2635,6 @@ static int qeth_l3_hard_start_xmit(struc
 	enum qeth_large_send_types large_send = QETH_LARGE_SEND_NO;
 	struct qeth_eddp_context *ctx = NULL;
 
-	QETH_DBF_TEXT(TRACE, 6, "l3xmit");
-
 	if ((card->info.type == QETH_CARD_TYPE_IQD) &&
 	    (skb->protocol != htons(ETH_P_IPV6)) &&
 	    (skb->protocol != htons(ETH_P_IP)))
@@ -2982,7 +2978,6 @@ static void qeth_l3_qdio_input_handler(s
 	int index;
 	int i;
 
-	QETH_DBF_TEXT(TRACE, 6, "qdinput");
 	card = (struct qeth_card *) card_ptr;
 	net_dev = card->dev;
 	if (card->options.performance_stats) {

-- 
