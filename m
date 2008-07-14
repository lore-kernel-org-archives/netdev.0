From: frank.blaschka@de.ibm.com
Subject: [patch 1/1] qeth: preallocated qeth header for hiper socket
Date: Mon, 14 Jul 2008 10:16:01 +0200
Message-ID: <20080714081641.883516000@de.ibm.com>
References: <20080714081600.800572000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:37128 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756038AbYGNIRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 04:17:32 -0400
Content-Disposition: inline; filename=600-qeth-prealloc.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

For hiper socket devices this patch will economize the reallocation
of the tx skb data segment by allocating separate memory for the qdio
transport information (qeth header).

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |    5 +--
 drivers/s390/net/qeth_core_main.c |   59 +++++++++++++++++++++++++++++---------
 drivers/s390/net/qeth_l2_main.c   |   50 +++++++++++++++++++++++++-------
 drivers/s390/net/qeth_l3_main.c   |   51 ++++++++++++++++++++++++--------
 4 files changed, 126 insertions(+), 39 deletions(-)

Index: git_linus/drivers/s390/net/qeth_core.h
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_core.h	2008-07-14 09:33:15.000000000 +0200
+++ git_linus/drivers/s390/net/qeth_core.h	2008-07-14 09:51:18.000000000 +0200
@@ -424,6 +424,7 @@
 	int next_element_to_fill;
 	struct sk_buff_head skb_list;
 	struct list_head ctx_list;
+	int is_header[16];
 };
 
 struct qeth_card;
@@ -790,7 +791,7 @@
 
 /* exports for qeth discipline device drivers */
 extern struct qeth_card_list_struct qeth_core_card_list;
-
+extern struct kmem_cache *qeth_core_header_cache;
 extern struct qeth_dbf_info qeth_dbf[QETH_DBF_INFOS];
 
 void qeth_set_allowed_threads(struct qeth_card *, unsigned long , int);
@@ -851,7 +852,7 @@
 int qeth_get_elements_no(struct qeth_card *, void *, struct sk_buff *, int);
 int qeth_do_send_packet_fast(struct qeth_card *, struct qeth_qdio_out_q *,
 			struct sk_buff *, struct qeth_hdr *, int,
-			struct qeth_eddp_context *);
+			struct qeth_eddp_context *, int, int);
 int qeth_do_send_packet(struct qeth_card *, struct qeth_qdio_out_q *,
 		    struct sk_buff *, struct qeth_hdr *,
 		    int, struct qeth_eddp_context *);
Index: git_linus/drivers/s390/net/qeth_core_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_core_main.c	2008-07-14 09:33:15.000000000 +0200
+++ git_linus/drivers/s390/net/qeth_core_main.c	2008-07-14 09:51:18.000000000 +0200
@@ -48,6 +48,8 @@
 
 struct qeth_card_list_struct qeth_core_card_list;
 EXPORT_SYMBOL_GPL(qeth_core_card_list);
+struct kmem_cache *qeth_core_header_cache;
+EXPORT_SYMBOL_GPL(qeth_core_header_cache);
 
 static struct device *qeth_core_root_dev;
 static unsigned int known_devices[][10] = QETH_MODELLIST_ARRAY;
@@ -933,6 +935,10 @@
 	}
 	qeth_eddp_buf_release_contexts(buf);
 	for (i = 0; i < QETH_MAX_BUFFER_ELEMENTS(queue->card); ++i) {
+		if (buf->buffer->element[i].addr && buf->is_header[i])
+			kmem_cache_free(qeth_core_header_cache,
+				buf->buffer->element[i].addr);
+		buf->is_header[i] = 0;
 		buf->buffer->element[i].length = 0;
 		buf->buffer->element[i].addr = NULL;
 		buf->buffer->element[i].flags = 0;
@@ -3017,8 +3023,8 @@
 	if (skb_shinfo(skb)->nr_frags > 0)
 		elements_needed = (skb_shinfo(skb)->nr_frags + 1);
 	if (elements_needed == 0)
-		elements_needed = 1 + (((((unsigned long) hdr) % PAGE_SIZE)
-			+ skb->len) >> PAGE_SHIFT);
+		elements_needed = 1 + (((((unsigned long) skb->data) %
+				PAGE_SIZE) + skb->len) >> PAGE_SHIFT);
 	if ((elements_needed + elems) > QETH_MAX_BUFFER_ELEMENTS(card)) {
 		QETH_DBF_MESSAGE(2, "Invalid size of IP packet "
 			"(Number=%d / Length=%d). Discarded.\n",
@@ -3030,7 +3036,8 @@
 EXPORT_SYMBOL_GPL(qeth_get_elements_no);
 
 static inline void __qeth_fill_buffer(struct sk_buff *skb,
-	struct qdio_buffer *buffer, int is_tso, int *next_element_to_fill)
+	struct qdio_buffer *buffer, int is_tso, int *next_element_to_fill,
+	int offset)
 {
 	int length = skb->len;
 	int length_here;
@@ -3042,6 +3049,11 @@
 	data = skb->data;
 	first_lap = (is_tso == 0 ? 1 : 0);
 
+	if (offset >= 0) {
+		data = skb->data + offset;
+		first_lap = 0;
+	}
+
 	while (length > 0) {
 		/* length_here is the remaining amount of data in this page */
 		length_here = PAGE_SIZE - ((unsigned long) data % PAGE_SIZE);
@@ -3073,22 +3085,22 @@
 }
 
 static inline int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
-		struct qeth_qdio_out_buffer *buf, struct sk_buff *skb)
+		struct qeth_qdio_out_buffer *buf, struct sk_buff *skb,
+		struct qeth_hdr *hdr, int offset, int hd_len)
 {
 	struct qdio_buffer *buffer;
-	struct qeth_hdr_tso *hdr;
 	int flush_cnt = 0, hdr_len, large_send = 0;
 
 	buffer = buf->buffer;
 	atomic_inc(&skb->users);
 	skb_queue_tail(&buf->skb_list, skb);
 
-	hdr  = (struct qeth_hdr_tso *) skb->data;
 	/*check first on TSO ....*/
-	if (hdr->hdr.hdr.l3.id == QETH_HEADER_TYPE_TSO) {
+	if (hdr->hdr.l3.id == QETH_HEADER_TYPE_TSO) {
 		int element = buf->next_element_to_fill;
 
-		hdr_len = sizeof(struct qeth_hdr_tso) + hdr->ext.dg_hdr_len;
+		hdr_len = sizeof(struct qeth_hdr_tso) +
+			((struct qeth_hdr_tso *)hdr)->ext.dg_hdr_len;
 		/*fill first buffer entry only with header information */
 		buffer->element[element].addr = skb->data;
 		buffer->element[element].length = hdr_len;
@@ -3098,9 +3110,20 @@
 		skb->len  -= hdr_len;
 		large_send = 1;
 	}
+
+	if (offset >= 0) {
+		int element = buf->next_element_to_fill;
+		buffer->element[element].addr = hdr;
+		buffer->element[element].length = sizeof(struct qeth_hdr) +
+							hd_len;
+		buffer->element[element].flags = SBAL_FLAGS_FIRST_FRAG;
+		buf->is_header[element] = 1;
+		buf->next_element_to_fill++;
+	}
+
 	if (skb_shinfo(skb)->nr_frags == 0)
 		__qeth_fill_buffer(skb, buffer, large_send,
-				   (int *)&buf->next_element_to_fill);
+				(int *)&buf->next_element_to_fill, offset);
 	else
 		__qeth_fill_buffer_frag(skb, buffer, large_send,
 					(int *)&buf->next_element_to_fill);
@@ -3130,7 +3153,7 @@
 int qeth_do_send_packet_fast(struct qeth_card *card,
 		struct qeth_qdio_out_q *queue, struct sk_buff *skb,
 		struct qeth_hdr *hdr, int elements_needed,
-		struct qeth_eddp_context *ctx)
+		struct qeth_eddp_context *ctx, int offset, int hd_len)
 {
 	struct qeth_qdio_out_buffer *buffer;
 	int buffers_needed = 0;
@@ -3163,7 +3186,7 @@
 	}
 	atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
 	if (ctx == NULL) {
-		qeth_fill_buffer(queue, buffer, skb);
+		qeth_fill_buffer(queue, buffer, skb, hdr, offset, hd_len);
 		qeth_flush_buffers(queue, 0, index, 1);
 	} else {
 		flush_cnt = qeth_eddp_fill_buffer(queue, ctx, index);
@@ -3239,7 +3262,7 @@
 		}
 	}
 	if (ctx == NULL)
-		tmp = qeth_fill_buffer(queue, buffer, skb);
+		tmp = qeth_fill_buffer(queue, buffer, skb, hdr, -1, 0);
 	else {
 		tmp = qeth_eddp_fill_buffer(queue, ctx,
 						queue->next_buf_to_fill);
@@ -4459,8 +4482,17 @@
 	rc = IS_ERR(qeth_core_root_dev) ? PTR_ERR(qeth_core_root_dev) : 0;
 	if (rc)
 		goto register_err;
-	return 0;
 
+	qeth_core_header_cache = kmem_cache_create("qeth_hdr",
+			sizeof(struct qeth_hdr) + ETH_HLEN, 64, 0, NULL);
+	if (!qeth_core_header_cache) {
+		rc = -ENOMEM;
+		goto slab_err;
+	}
+
+	return 0;
+slab_err:
+	s390_root_dev_unregister(qeth_core_root_dev);
 register_err:
 	driver_remove_file(&qeth_core_ccwgroup_driver.driver,
 			   &driver_attr_group);
@@ -4482,6 +4514,7 @@
 			   &driver_attr_group);
 	ccwgroup_driver_unregister(&qeth_core_ccwgroup_driver);
 	ccw_driver_unregister(&qeth_ccw_driver);
+	kmem_cache_destroy(qeth_core_header_cache);
 	qeth_unregister_dbf_views();
 	PRINT_INFO("core functions removed\n");
 }
Index: git_linus/drivers/s390/net/qeth_l2_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_l2_main.c	2008-07-14 09:33:15.000000000 +0200
+++ git_linus/drivers/s390/net/qeth_l2_main.c	2008-07-14 09:51:18.000000000 +0200
@@ -243,8 +243,7 @@
 static void qeth_l2_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 			struct sk_buff *skb, int ipv, int cast_type)
 {
-	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)((skb->data) +
-					QETH_HEADER_SIZE);
+	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)skb_mac_header(skb);
 
 	memset(hdr, 0, sizeof(struct qeth_hdr));
 	hdr->hdr.l2.id = QETH_HEADER_TYPE_LAYER2;
@@ -621,6 +620,9 @@
 	int tx_bytes = skb->len;
 	enum qeth_large_send_types large_send = QETH_LARGE_SEND_NO;
 	struct qeth_eddp_context *ctx = NULL;
+	int data_offset = -1;
+	int elements_needed = 0;
+	int hd_len = 0;
 
 	if ((card->state != CARD_STATE_UP) || !card->lan_online) {
 		card->stats.tx_carrier_errors++;
@@ -643,13 +645,32 @@
 	if (card->info.type == QETH_CARD_TYPE_OSN)
 		hdr = (struct qeth_hdr *)skb->data;
 	else {
-		/* create a clone with writeable headroom */
-		new_skb = skb_realloc_headroom(skb, sizeof(struct qeth_hdr));
-		if (!new_skb)
-			goto tx_drop;
-		hdr = (struct qeth_hdr *)skb_push(new_skb,
+		if ((card->info.type == QETH_CARD_TYPE_IQD) && (!large_send) &&
+		    (skb_shinfo(skb)->nr_frags == 0)) {
+			new_skb = skb;
+			data_offset = ETH_HLEN;
+			hd_len = ETH_HLEN;
+			hdr = kmem_cache_alloc(qeth_core_header_cache,
+						GFP_ATOMIC);
+			if (!hdr)
+				goto tx_drop;
+			elements_needed++;
+			skb_reset_mac_header(new_skb);
+			qeth_l2_fill_header(card, hdr, new_skb, ipv, cast_type);
+			hdr->hdr.l2.pkt_length = new_skb->len;
+			memcpy(((char *)hdr) + sizeof(struct qeth_hdr),
+				skb_mac_header(new_skb), ETH_HLEN);
+		} else {
+			/* create a clone with writeable headroom */
+			new_skb = skb_realloc_headroom(skb,
+						sizeof(struct qeth_hdr));
+			if (!new_skb)
+				goto tx_drop;
+			hdr = (struct qeth_hdr *)skb_push(new_skb,
 						sizeof(struct qeth_hdr));
-		qeth_l2_fill_header(card, hdr, new_skb, ipv, cast_type);
+			skb_set_mac_header(new_skb, sizeof(struct qeth_hdr));
+			qeth_l2_fill_header(card, hdr, new_skb, ipv, cast_type);
+		}
 	}
 
 	if (large_send == QETH_LARGE_SEND_EDDP) {
@@ -660,9 +681,13 @@
 			goto tx_drop;
 		}
 	} else {
-		elements = qeth_get_elements_no(card, (void *)hdr, new_skb, 0);
-		if (!elements)
+		elements = qeth_get_elements_no(card, (void *)hdr, new_skb,
+						elements_needed);
+		if (!elements) {
+			if (data_offset >= 0)
+				kmem_cache_free(qeth_core_header_cache, hdr);
 			goto tx_drop;
+		}
 	}
 
 	if ((large_send == QETH_LARGE_SEND_NO) &&
@@ -674,7 +699,7 @@
 					 elements, ctx);
 	else
 		rc = qeth_do_send_packet_fast(card, queue, new_skb, hdr,
-					      elements, ctx);
+					elements, ctx, data_offset, hd_len);
 	if (!rc) {
 		card->stats.tx_packets++;
 		card->stats.tx_bytes += tx_bytes;
@@ -701,6 +726,9 @@
 		if (ctx != NULL)
 			qeth_eddp_put_context(ctx);
 
+		if (data_offset >= 0)
+			kmem_cache_free(qeth_core_header_cache, hdr);
+
 		if (rc == -EBUSY) {
 			if (new_skb != skb)
 				dev_kfree_skb_any(new_skb);
Index: git_linus/drivers/s390/net/qeth_l3_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_l3_main.c	2008-07-14 09:33:15.000000000 +0200
+++ git_linus/drivers/s390/net/qeth_l3_main.c	2008-07-14 09:51:18.000000000 +0200
@@ -2611,6 +2611,7 @@
 	int tx_bytes = skb->len;
 	enum qeth_large_send_types large_send = QETH_LARGE_SEND_NO;
 	struct qeth_eddp_context *ctx = NULL;
+	int data_offset = -1;
 
 	if ((card->info.type == QETH_CARD_TYPE_IQD) &&
 	    (skb->protocol != htons(ETH_P_IPV6)) &&
@@ -2631,14 +2632,28 @@
 		card->perf_stats.outbound_start_time = qeth_get_micros();
 	}
 
-	/* create a clone with writeable headroom */
-	new_skb = skb_realloc_headroom(skb, sizeof(struct qeth_hdr_tso) +
-					VLAN_HLEN);
-	if (!new_skb)
-		goto tx_drop;
+	if (skb_is_gso(skb))
+		large_send = card->options.large_send;
+
+	if ((card->info.type == QETH_CARD_TYPE_IQD) && (!large_send) &&
+	    (skb_shinfo(skb)->nr_frags == 0)) {
+		new_skb = skb;
+		data_offset = ETH_HLEN;
+		hdr = kmem_cache_alloc(qeth_core_header_cache, GFP_ATOMIC);
+		if (!hdr)
+			goto tx_drop;
+		elements_needed++;
+	} else {
+		/* create a clone with writeable headroom */
+		new_skb = skb_realloc_headroom(skb, sizeof(struct qeth_hdr_tso)
+					+ VLAN_HLEN);
+		if (!new_skb)
+			goto tx_drop;
+	}
 
 	if (card->info.type == QETH_CARD_TYPE_IQD) {
-		skb_pull(new_skb, ETH_HLEN);
+		if (data_offset < 0)
+			skb_pull(new_skb, ETH_HLEN);
 	} else {
 		if (new_skb->protocol == htons(ETH_P_IP)) {
 			if (card->dev->type == ARPHRD_IEEE802_TR)
@@ -2664,9 +2679,6 @@
 
 	netif_stop_queue(dev);
 
-	if (skb_is_gso(new_skb))
-		large_send = card->options.large_send;
-
 	/* fix hardware limitation: as long as we do not have sbal
 	 * chaining we can not send long frag lists so we temporary
 	 * switch to EDDP
@@ -2684,9 +2696,16 @@
 		qeth_tso_fill_header(card, hdr, new_skb);
 		elements_needed++;
 	} else {
-		hdr = (struct qeth_hdr *)skb_push(new_skb,
+		if (data_offset < 0) {
+			hdr = (struct qeth_hdr *)skb_push(new_skb,
 						sizeof(struct qeth_hdr));
-		qeth_l3_fill_header(card, hdr, new_skb, ipv, cast_type);
+			qeth_l3_fill_header(card, hdr, new_skb, ipv,
+						cast_type);
+		} else {
+			qeth_l3_fill_header(card, hdr, new_skb, ipv,
+						cast_type);
+			hdr->hdr.l3.length = new_skb->len - data_offset;
+		}
 	}
 
 	if (large_send == QETH_LARGE_SEND_EDDP) {
@@ -2702,8 +2721,11 @@
 	} else {
 		int elems = qeth_get_elements_no(card, (void *)hdr, new_skb,
 						 elements_needed);
-		if (!elems)
+		if (!elems) {
+			if (data_offset >= 0)
+				kmem_cache_free(qeth_core_header_cache, hdr);
 			goto tx_drop;
+		}
 		elements_needed += elems;
 	}
 
@@ -2716,7 +2738,7 @@
 					 elements_needed, ctx);
 	else
 		rc = qeth_do_send_packet_fast(card, queue, new_skb, hdr,
-					      elements_needed, ctx);
+					elements_needed, ctx, data_offset, 0);
 
 	if (!rc) {
 		card->stats.tx_packets++;
@@ -2744,6 +2766,9 @@
 		if (ctx != NULL)
 			qeth_eddp_put_context(ctx);
 
+		if (data_offset >= 0)
+			kmem_cache_free(qeth_core_header_cache, hdr);
+
 		if (rc == -EBUSY) {
 			if (new_skb != skb)
 				dev_kfree_skb_any(new_skb);

-- 
