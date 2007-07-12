From: Ursula.Braun.braunu@de.ibm.com
Subject: [patch 1/2] s390: scatter-gather for inbound traffic in qeth driver
Date: Thu, 12 Jul 2007 09:51:00 +0200
Message-ID: <20070712075326.591246000@linux.vnet.ibm.com>
References: <20070712075059.579991000@linux.vnet.ibm.com>
Cc: Frank Blaschka <frank.blaschka@de.ibm.com>,
	Frank Pavlic <fpavlic@de.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:17262 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757249AbXGLHx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 03:53:29 -0400
Content-Disposition: inline; filename=701-qeth-scatter-gather.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frank Blaschka <frank.blaschka@de.ibm.com>

For large incoming packets > PAGE_SIZE/2 qeth creates a fragmented skb
by adding pointers to qdio pages to the fragment list of the skb.
This avoids allocating big chunks of consecutive memory. Also copying
data from the qdio buffer to the skb is economized.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 drivers/s390/net/qeth.h      |    9 ++
 drivers/s390/net/qeth_main.c |  182 +++++++++++++++++++++++++++++++++++--------
 drivers/s390/net/qeth_proc.c |    6 +
 3 files changed, 165 insertions(+), 32 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/qeth.h
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/qeth.h
+++ linux-2.6-uschi/drivers/s390/net/qeth.h
@@ -211,6 +211,10 @@ struct qeth_perf_stats {
 	/* initial values when measuring starts */
 	unsigned long initial_rx_packets;
 	unsigned long initial_tx_packets;
+	/* inbound scatter gather data */
+	unsigned int sg_skbs_rx;
+	unsigned int sg_frags_rx;
+	unsigned int sg_alloc_page_rx;
 };
 
 /* Routing stuff */
@@ -341,6 +345,9 @@ qeth_is_ipa_enabled(struct qeth_ipa_info
 
 #define QETH_IP_HEADER_SIZE 40
 
+/* large receive scatter gather copy break */
+#define QETH_RX_SG_CB (PAGE_SIZE >> 1)
+
 struct qeth_hdr_layer3 {
 	__u8  id;
 	__u8  flags;
@@ -771,6 +778,7 @@ struct qeth_card_options {
 	int layer2;
 	enum qeth_large_send_types large_send;
 	int performance_stats;
+	int rx_sg_cb;
 };
 
 /*
@@ -828,6 +836,7 @@ struct qeth_card {
 	int (*orig_hard_header)(struct sk_buff *,struct net_device *,
 				unsigned short,void *,void *,unsigned);
 	struct qeth_osn_info osn_info;
+	atomic_t force_alloc_skb;
 };
 
 struct qeth_card_list_struct {
Index: linux-2.6-uschi/drivers/s390/net/qeth_main.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/qeth_main.c
+++ linux-2.6-uschi/drivers/s390/net/qeth_main.c
@@ -1054,6 +1054,7 @@ qeth_set_intial_options(struct qeth_card
 	else
 		card->options.layer2 = 0;
 	card->options.performance_stats = 0;
+	card->options.rx_sg_cb = QETH_RX_SG_CB;
 }
 
 /**
@@ -2258,6 +2259,89 @@ qeth_get_skb(unsigned int length, struct
 	return skb;
 }
 
+static inline int
+qeth_create_skb_frag(struct qdio_buffer_element *element,
+		     struct sk_buff **pskb,
+		     int offset, int *pfrag, int data_len)
+{
+	struct page *page = virt_to_page(element->addr);
+	if (*pfrag == 0) {
+		/* the upper protocol layers assume that there is data in the
+		 * skb itself. Copy a small amount (64 bytes) to make them
+		 * happy. */
+		*pskb = dev_alloc_skb(64 + QETH_FAKE_LL_LEN_ETH);
+		if (!(*pskb))
+			return -ENOMEM;
+		skb_reserve(*pskb, QETH_FAKE_LL_LEN_ETH);
+		if (data_len <= 64) {
+			memcpy(skb_put(*pskb, data_len), element->addr + offset,
+				data_len);
+		} else {
+			get_page(page);
+			memcpy(skb_put(*pskb, 64), element->addr + offset, 64);
+			skb_fill_page_desc(*pskb, *pfrag, page, offset + 64,
+				data_len - 64);
+			(*pskb)->data_len += data_len - 64;
+			(*pskb)->len	  += data_len - 64;
+			(*pskb)->truesize += data_len - 64;
+		}
+	} else {
+		get_page(page);
+		skb_fill_page_desc(*pskb, *pfrag, page, offset, data_len);
+		(*pskb)->data_len += data_len;
+		(*pskb)->len	  += data_len;
+		(*pskb)->truesize += data_len;
+	}
+	(*pfrag)++;
+	return 0;
+}
+
+static inline struct qeth_buffer_pool_entry *
+qeth_find_free_buffer_pool_entry(struct qeth_card *card)
+{
+	struct list_head *plh;
+	struct qeth_buffer_pool_entry *entry;
+	int i, free;
+	struct page *page;
+
+	if (list_empty(&card->qdio.in_buf_pool.entry_list))
+		return NULL;
+
+	list_for_each(plh, &card->qdio.in_buf_pool.entry_list) {
+		entry = list_entry(plh, struct qeth_buffer_pool_entry, list);
+		free = 1;
+		for (i = 0; i < QETH_MAX_BUFFER_ELEMENTS(card); ++i) {
+			if (page_count(virt_to_page(entry->elements[i])) > 1) {
+				free = 0;
+				break;
+			}
+		}
+		if (free) {
+			list_del_init(&entry->list);
+			return entry;
+		}
+	}
+
+	/* no free buffer in pool so take first one and swap pages */
+	entry = list_entry(card->qdio.in_buf_pool.entry_list.next,
+			struct qeth_buffer_pool_entry, list);
+	for (i = 0; i < QETH_MAX_BUFFER_ELEMENTS(card); ++i) {
+		if (page_count(virt_to_page(entry->elements[i])) > 1) {
+			page = alloc_page(GFP_ATOMIC|GFP_DMA);
+			if (!page) {
+				return NULL;
+			} else {
+				free_page((unsigned long)entry->elements[i]);
+				entry->elements[i] = page_address(page);
+				if (card->options.performance_stats)
+					card->perf_stats.sg_alloc_page_rx++;
+			}
+		}
+	}
+	list_del_init(&entry->list);
+	return entry;
+}
+
 static struct sk_buff *
 qeth_get_next_skb(struct qeth_card *card, struct qdio_buffer *buffer,
 		  struct qdio_buffer_element **__element, int *__offset,
@@ -2269,6 +2353,8 @@ qeth_get_next_skb(struct qeth_card *card
 	int skb_len;
 	void *data_ptr;
 	int data_len;
+	int use_rx_sg = 0;
+	int frag = 0;
 
 	QETH_DBF_TEXT(trace,6,"nextskb");
 	/* qeth_hdr must not cross element boundaries */
@@ -2293,23 +2379,43 @@ qeth_get_next_skb(struct qeth_card *card
 
 	if (!skb_len)
 		return NULL;
-	if (card->options.fake_ll){
-		if(card->dev->type == ARPHRD_IEEE802_TR){
-			if (!(skb = qeth_get_skb(skb_len+QETH_FAKE_LL_LEN_TR, *hdr)))
-				goto no_mem;
-			skb_reserve(skb,QETH_FAKE_LL_LEN_TR);
+	if ((skb_len >= card->options.rx_sg_cb) &&
+	    (!(card->info.type == QETH_CARD_TYPE_OSN)) &&
+	    (!atomic_read(&card->force_alloc_skb))) {
+		use_rx_sg = 1;
+	} else {
+		if (card->options.fake_ll) {
+			if (card->dev->type == ARPHRD_IEEE802_TR) {
+				if (!(skb = qeth_get_skb(skb_len +
+						QETH_FAKE_LL_LEN_TR, *hdr)))
+					goto no_mem;
+				skb_reserve(skb, QETH_FAKE_LL_LEN_TR);
+			} else {
+				if (!(skb = qeth_get_skb(skb_len +
+						QETH_FAKE_LL_LEN_ETH, *hdr)))
+					goto no_mem;
+				skb_reserve(skb, QETH_FAKE_LL_LEN_ETH);
+			}
 		} else {
-			if (!(skb = qeth_get_skb(skb_len+QETH_FAKE_LL_LEN_ETH, *hdr)))
+			skb = qeth_get_skb(skb_len, *hdr);
+			if (!skb)
 				goto no_mem;
-			skb_reserve(skb,QETH_FAKE_LL_LEN_ETH);
 		}
-	} else if (!(skb = qeth_get_skb(skb_len, *hdr)))
-		goto no_mem;
+	}
+
 	data_ptr = element->addr + offset;
 	while (skb_len) {
 		data_len = min(skb_len, (int)(element->length - offset));
-		if (data_len)
-			memcpy(skb_put(skb, data_len), data_ptr, data_len);
+		if (data_len) {
+			if (use_rx_sg) {
+				if (qeth_create_skb_frag(element, &skb, offset,
+				    &frag, data_len))
+					goto no_mem;
+			} else {
+				memcpy(skb_put(skb, data_len), data_ptr,
+					data_len);
+			}
+		}
 		skb_len -= data_len;
 		if (skb_len){
 			if (qeth_is_last_sbale(element)){
@@ -2331,6 +2437,10 @@ qeth_get_next_skb(struct qeth_card *card
 	}
 	*__element = element;
 	*__offset = offset;
+	if (use_rx_sg && card->options.performance_stats) {
+		card->perf_stats.sg_skbs_rx++;
+		card->perf_stats.sg_frags_rx += skb_shinfo(skb)->nr_frags;
+	}
 	return skb;
 no_mem:
 	if (net_ratelimit()){
@@ -2608,28 +2718,15 @@ qeth_process_inbound_buffer(struct qeth_
 	}
 }
 
-static struct qeth_buffer_pool_entry *
-qeth_get_buffer_pool_entry(struct qeth_card *card)
-{
-	struct qeth_buffer_pool_entry *entry;
-
-	QETH_DBF_TEXT(trace, 6, "gtbfplen");
-	if (!list_empty(&card->qdio.in_buf_pool.entry_list)) {
-		entry = list_entry(card->qdio.in_buf_pool.entry_list.next,
-				struct qeth_buffer_pool_entry, list);
-		list_del_init(&entry->list);
-		return entry;
-	}
-	return NULL;
-}
-
-static void
+static int
 qeth_init_input_buffer(struct qeth_card *card, struct qeth_qdio_buffer *buf)
 {
 	struct qeth_buffer_pool_entry *pool_entry;
 	int i;
- 
-	pool_entry = qeth_get_buffer_pool_entry(card);
+
+	pool_entry = qeth_find_free_buffer_pool_entry(card);
+	if (!pool_entry)
+		return 1;
 	/*
 	 * since the buffer is accessed only from the input_tasklet
 	 * there shouldn't be a need to synchronize; also, since we use
@@ -2648,6 +2745,7 @@ qeth_init_input_buffer(struct qeth_card 
 			buf->buffer->element[i].flags = 0;
 	}
 	buf->state = QETH_QDIO_BUF_EMPTY;
+	return 0;
 }
 
 static void
@@ -2682,6 +2780,7 @@ qeth_queue_input_buffer(struct qeth_card
 	int count;
 	int i;
 	int rc;
+	int newcount = 0;
 
 	QETH_DBF_TEXT(trace,6,"queinbuf");
 	count = (index < queue->next_buf_to_init)?
@@ -2692,9 +2791,27 @@ qeth_queue_input_buffer(struct qeth_card
 	/* only requeue at a certain threshold to avoid SIGAs */
 	if (count >= QETH_IN_BUF_REQUEUE_THRESHOLD(card)){
 		for (i = queue->next_buf_to_init;
-		     i < queue->next_buf_to_init + count; ++i)
-			qeth_init_input_buffer(card,
-				&queue->bufs[i % QDIO_MAX_BUFFERS_PER_Q]);
+		     i < queue->next_buf_to_init + count; ++i) {
+			if (qeth_init_input_buffer(card,
+				&queue->bufs[i % QDIO_MAX_BUFFERS_PER_Q])) {
+				break;
+			} else {
+				newcount++;
+			}
+		}
+
+		if (newcount < count) {
+			/* we are in memory shortage so we switch back to
+			   traditional skb allocation and drop packages */
+			if (atomic_cmpxchg(&card->force_alloc_skb, 0, 1))
+				printk(KERN_WARNING
+					"qeth: switch to alloc skb\n");
+			count = newcount;
+		} else {
+			if (atomic_cmpxchg(&card->force_alloc_skb, 1, 0))
+				printk(KERN_WARNING "qeth: switch to sg\n");
+		}
+
 		/*
 		 * according to old code it should be avoided to requeue all
 		 * 128 buffers in order to benefit from PCI avoidance.
@@ -6494,6 +6611,7 @@ qeth_hardsetup_card(struct qeth_card *ca
 
 	QETH_DBF_TEXT(setup, 2, "hrdsetup");
 
+	atomic_set(&card->force_alloc_skb, 0);
 retry:
 	if (retries < 3){
 		PRINT_WARN("Retrying to do IDX activates.\n");
Index: linux-2.6-uschi/drivers/s390/net/qeth_proc.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/qeth_proc.c
+++ linux-2.6-uschi/drivers/s390/net/qeth_proc.c
@@ -212,6 +212,12 @@ qeth_perf_procfile_seq_show(struct seq_f
 		      "  Skb fragments sent in SG mode          : %u\n\n",
 		      card->perf_stats.sg_skbs_sent,
 		      card->perf_stats.sg_frags_sent);
+	seq_printf(s, "  Skbs received in SG mode               : %u\n"
+		      "  Skb fragments received in SG mode      : %u\n"
+		      "  Page allocations for rx SG mode        : %u\n\n",
+		      card->perf_stats.sg_skbs_rx,
+		      card->perf_stats.sg_frags_rx,
+		      card->perf_stats.sg_alloc_page_rx);
 	seq_printf(s, "  large_send tx (in Kbytes)              : %u\n"
 		      "  large_send count                       : %u\n\n",
 		      card->perf_stats.large_send_bytes >> 10,

-- 
