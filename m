From: frank.blaschka@de.ibm.com
Subject: [patch 3/6] [PATCH] qeth: remove EDDP
Date: Wed, 25 Mar 2009 07:57:16 +0100
Message-ID: <20090325065808.959977000@de.ibm.com>
References: <20090325065713.054133000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:35187 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755386AbZCYG6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 02:58:12 -0400
Content-Disposition: inline; filename=607-qeth-rmeddp.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Performance measurements showed EDDP does not lower CPU costs but increase
them. So we dump out EDDP code from qeth driver.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/Makefile         |    2 
 drivers/s390/net/qeth_core.h      |    7 
 drivers/s390/net/qeth_core_main.c |   99 +----
 drivers/s390/net/qeth_core_offl.c |  699 --------------------------------------
 drivers/s390/net/qeth_core_offl.h |   76 ----
 drivers/s390/net/qeth_core_sys.c  |    4 
 drivers/s390/net/qeth_l2_main.c   |   81 ----
 drivers/s390/net/qeth_l3_main.c   |  123 ++++--
 8 files changed, 111 insertions(+), 980 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/Makefile linux-2.6-patched/drivers/s390/net/Makefile
--- linux-2.6/drivers/s390/net/Makefile	2008-12-25 00:26:37.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/Makefile	2009-02-18 12:06:32.000000000 +0100
@@ -8,7 +8,7 @@ obj-$(CONFIG_NETIUCV) += netiucv.o fsm.o
 obj-$(CONFIG_SMSGIUCV) += smsgiucv.o
 obj-$(CONFIG_LCS) += lcs.o cu3088.o
 obj-$(CONFIG_CLAW) += claw.o cu3088.o
-qeth-y += qeth_core_sys.o qeth_core_main.o qeth_core_mpc.o qeth_core_offl.o
+qeth-y += qeth_core_sys.o qeth_core_main.o qeth_core_mpc.o
 obj-$(CONFIG_QETH) += qeth.o
 qeth_l2-y += qeth_l2_main.o
 obj-$(CONFIG_QETH_L2) += qeth_l2.o
diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2009-02-18 12:06:32.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2009-02-18 12:06:32.000000000 +0100
@@ -404,7 +404,6 @@ struct qeth_qdio_q {
 /* possible types of qeth large_send support */
 enum qeth_large_send_types {
 	QETH_LARGE_SEND_NO,
-	QETH_LARGE_SEND_EDDP,
 	QETH_LARGE_SEND_TSO,
 };
 
@@ -839,11 +838,9 @@ int qeth_get_cast_type(struct qeth_card 
 int qeth_get_priority_queue(struct qeth_card *, struct sk_buff *, int, int);
 int qeth_get_elements_no(struct qeth_card *, void *, struct sk_buff *, int);
 int qeth_do_send_packet_fast(struct qeth_card *, struct qeth_qdio_out_q *,
-			struct sk_buff *, struct qeth_hdr *, int,
-			struct qeth_eddp_context *, int, int);
+			struct sk_buff *, struct qeth_hdr *, int, int, int);
 int qeth_do_send_packet(struct qeth_card *, struct qeth_qdio_out_q *,
-		    struct sk_buff *, struct qeth_hdr *,
-		    int, struct qeth_eddp_context *);
+		    struct sk_buff *, struct qeth_hdr *, int);
 int qeth_core_get_stats_count(struct net_device *);
 void qeth_core_get_ethtool_stats(struct net_device *,
 				struct ethtool_stats *, u64 *);
diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2009-02-18 12:06:32.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2009-02-18 12:06:32.000000000 +0100
@@ -17,7 +17,6 @@
 #include <linux/errno.h>
 #include <linux/kernel.h>
 #include <linux/ip.h>
-#include <linux/ipv6.h>
 #include <linux/tcp.h>
 #include <linux/mii.h>
 #include <linux/kthread.h>
@@ -26,7 +25,6 @@
 #include <asm/io.h>
 
 #include "qeth_core.h"
-#include "qeth_core_offl.h"
 
 struct qeth_dbf_info qeth_dbf[QETH_DBF_INFOS] = {
 	/* define dbf - Name, Pages, Areas, Maxlen, Level, View, Handle */
@@ -285,17 +283,6 @@ int qeth_set_large_send(struct qeth_card
 		netif_tx_disable(card->dev);
 	card->options.large_send = type;
 	switch (card->options.large_send) {
-	case QETH_LARGE_SEND_EDDP:
-		if (card->info.type != QETH_CARD_TYPE_IQD) {
-			card->dev->features |= NETIF_F_TSO | NETIF_F_SG |
-					NETIF_F_HW_CSUM;
-		} else {
-			card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG |
-						NETIF_F_HW_CSUM);
-			card->options.large_send = QETH_LARGE_SEND_NO;
-			rc = -EOPNOTSUPP;
-		}
-		break;
 	case QETH_LARGE_SEND_TSO:
 		if (qeth_is_supported(card, IPA_OUTBOUND_TSO)) {
 			card->dev->features |= NETIF_F_TSO | NETIF_F_SG |
@@ -956,7 +943,6 @@ static void qeth_clear_output_buffer(str
 		dev_kfree_skb_any(skb);
 		skb = skb_dequeue(&buf->skb_list);
 	}
-	qeth_eddp_buf_release_contexts(buf);
 	for (i = 0; i < QETH_MAX_BUFFER_ELEMENTS(queue->card); ++i) {
 		if (buf->buffer->element[i].addr && buf->is_header[i])
 			kmem_cache_free(qeth_core_header_cache,
@@ -3187,11 +3173,9 @@ static inline int qeth_fill_buffer(struc
 int qeth_do_send_packet_fast(struct qeth_card *card,
 		struct qeth_qdio_out_q *queue, struct sk_buff *skb,
 		struct qeth_hdr *hdr, int elements_needed,
-		struct qeth_eddp_context *ctx, int offset, int hd_len)
+		int offset, int hd_len)
 {
 	struct qeth_qdio_out_buffer *buffer;
-	int buffers_needed = 0;
-	int flush_cnt = 0;
 	int index;
 
 	/* spin until we get the queue ... */
@@ -3206,27 +3190,11 @@ int qeth_do_send_packet_fast(struct qeth
 	 */
 	if (atomic_read(&buffer->state) != QETH_QDIO_BUF_EMPTY)
 		goto out;
-	if (ctx == NULL)
-		queue->next_buf_to_fill = (queue->next_buf_to_fill + 1) %
+	queue->next_buf_to_fill = (queue->next_buf_to_fill + 1) %
 					  QDIO_MAX_BUFFERS_PER_Q;
-	else {
-		buffers_needed = qeth_eddp_check_buffers_for_context(queue,
-									ctx);
-		if (buffers_needed < 0)
-			goto out;
-		queue->next_buf_to_fill =
-			(queue->next_buf_to_fill + buffers_needed) %
-			QDIO_MAX_BUFFERS_PER_Q;
-	}
 	atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
-	if (ctx == NULL) {
-		qeth_fill_buffer(queue, buffer, skb, hdr, offset, hd_len);
-		qeth_flush_buffers(queue, index, 1);
-	} else {
-		flush_cnt = qeth_eddp_fill_buffer(queue, ctx, index);
-		WARN_ON(buffers_needed != flush_cnt);
-		qeth_flush_buffers(queue, index, flush_cnt);
-	}
+	qeth_fill_buffer(queue, buffer, skb, hdr, offset, hd_len);
+	qeth_flush_buffers(queue, index, 1);
 	return 0;
 out:
 	atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
@@ -3236,7 +3204,7 @@ EXPORT_SYMBOL_GPL(qeth_do_send_packet_fa
 
 int qeth_do_send_packet(struct qeth_card *card, struct qeth_qdio_out_q *queue,
 		struct sk_buff *skb, struct qeth_hdr *hdr,
-		int elements_needed, struct qeth_eddp_context *ctx)
+		int elements_needed)
 {
 	struct qeth_qdio_out_buffer *buffer;
 	int start_index;
@@ -3262,53 +3230,32 @@ int qeth_do_send_packet(struct qeth_card
 	qeth_switch_to_packing_if_needed(queue);
 	if (queue->do_pack) {
 		do_pack = 1;
-		if (ctx == NULL) {
-			/* does packet fit in current buffer? */
-			if ((QETH_MAX_BUFFER_ELEMENTS(card) -
-			    buffer->next_element_to_fill) < elements_needed) {
-				/* ... no -> set state PRIMED */
-				atomic_set(&buffer->state,
-					QETH_QDIO_BUF_PRIMED);
-				flush_count++;
-				queue->next_buf_to_fill =
-					(queue->next_buf_to_fill + 1) %
-					QDIO_MAX_BUFFERS_PER_Q;
-				buffer = &queue->bufs[queue->next_buf_to_fill];
-				/* we did a step forward, so check buffer state
-				 * again */
-				if (atomic_read(&buffer->state) !=
-						QETH_QDIO_BUF_EMPTY){
-					qeth_flush_buffers(queue, start_index,
+		/* does packet fit in current buffer? */
+		if ((QETH_MAX_BUFFER_ELEMENTS(card) -
+		    buffer->next_element_to_fill) < elements_needed) {
+			/* ... no -> set state PRIMED */
+			atomic_set(&buffer->state, QETH_QDIO_BUF_PRIMED);
+			flush_count++;
+			queue->next_buf_to_fill =
+				(queue->next_buf_to_fill + 1) %
+				QDIO_MAX_BUFFERS_PER_Q;
+			buffer = &queue->bufs[queue->next_buf_to_fill];
+			/* we did a step forward, so check buffer state
+			 * again */
+			if (atomic_read(&buffer->state) !=
+			    QETH_QDIO_BUF_EMPTY) {
+				qeth_flush_buffers(queue, start_index,
 							   flush_count);
-					atomic_set(&queue->state,
+				atomic_set(&queue->state,
 						QETH_OUT_Q_UNLOCKED);
-					return -EBUSY;
-				}
-			}
-		} else {
-			/* check if we have enough elements (including following
-			 * free buffers) to handle eddp context */
-			if (qeth_eddp_check_buffers_for_context(queue, ctx)
-				< 0) {
-				rc = -EBUSY;
-				goto out;
+				return -EBUSY;
 			}
 		}
 	}
-	if (ctx == NULL)
-		tmp = qeth_fill_buffer(queue, buffer, skb, hdr, -1, 0);
-	else {
-		tmp = qeth_eddp_fill_buffer(queue, ctx,
-						queue->next_buf_to_fill);
-		if (tmp < 0) {
-			rc = -EBUSY;
-			goto out;
-		}
-	}
+	tmp = qeth_fill_buffer(queue, buffer, skb, hdr, -1, 0);
 	queue->next_buf_to_fill = (queue->next_buf_to_fill + tmp) %
 				  QDIO_MAX_BUFFERS_PER_Q;
 	flush_count += tmp;
-out:
 	if (flush_count)
 		qeth_flush_buffers(queue, start_index, flush_count);
 	else if (!atomic_read(&queue->set_pci_flags_count))
diff -urpN linux-2.6/drivers/s390/net/qeth_core_offl.c linux-2.6-patched/drivers/s390/net/qeth_core_offl.c
--- linux-2.6/drivers/s390/net/qeth_core_offl.c	2009-02-18 12:06:14.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core_offl.c	1970-01-01 01:00:00.000000000 +0100
@@ -1,699 +0,0 @@
-/*
- *  drivers/s390/net/qeth_core_offl.c
- *
- *    Copyright IBM Corp. 2007
- *    Author(s): Thomas Spatzier <tspat@de.ibm.com>,
- *		 Frank Blaschka <frank.blaschka@de.ibm.com>
- */
-
-#include <linux/errno.h>
-#include <linux/ip.h>
-#include <linux/inetdevice.h>
-#include <linux/netdevice.h>
-#include <linux/kernel.h>
-#include <linux/tcp.h>
-#include <net/tcp.h>
-#include <linux/skbuff.h>
-
-#include <net/ip.h>
-#include <net/ip6_checksum.h>
-
-#include "qeth_core.h"
-#include "qeth_core_mpc.h"
-#include "qeth_core_offl.h"
-
-int qeth_eddp_check_buffers_for_context(struct qeth_qdio_out_q *queue,
-		struct qeth_eddp_context *ctx)
-{
-	int index = queue->next_buf_to_fill;
-	int elements_needed = ctx->num_elements;
-	int elements_in_buffer;
-	int skbs_in_buffer;
-	int buffers_needed = 0;
-
-	QETH_DBF_TEXT(TRACE, 5, "eddpcbfc");
-	while (elements_needed > 0) {
-		buffers_needed++;
-		if (atomic_read(&queue->bufs[index].state) !=
-				QETH_QDIO_BUF_EMPTY)
-			return -EBUSY;
-
-		elements_in_buffer = QETH_MAX_BUFFER_ELEMENTS(queue->card) -
-				     queue->bufs[index].next_element_to_fill;
-		skbs_in_buffer = elements_in_buffer / ctx->elements_per_skb;
-		elements_needed -= skbs_in_buffer * ctx->elements_per_skb;
-		index = (index + 1) % QDIO_MAX_BUFFERS_PER_Q;
-	}
-	return buffers_needed;
-}
-
-static void qeth_eddp_free_context(struct qeth_eddp_context *ctx)
-{
-	int i;
-
-	QETH_DBF_TEXT(TRACE, 5, "eddpfctx");
-	for (i = 0; i < ctx->num_pages; ++i)
-		free_page((unsigned long)ctx->pages[i]);
-	kfree(ctx->pages);
-	kfree(ctx->elements);
-	kfree(ctx);
-}
-
-
-static void qeth_eddp_get_context(struct qeth_eddp_context *ctx)
-{
-	atomic_inc(&ctx->refcnt);
-}
-
-void qeth_eddp_put_context(struct qeth_eddp_context *ctx)
-{
-	if (atomic_dec_return(&ctx->refcnt) == 0)
-		qeth_eddp_free_context(ctx);
-}
-EXPORT_SYMBOL_GPL(qeth_eddp_put_context);
-
-void qeth_eddp_buf_release_contexts(struct qeth_qdio_out_buffer *buf)
-{
-	struct qeth_eddp_context_reference *ref;
-
-	QETH_DBF_TEXT(TRACE, 6, "eddprctx");
-	while (!list_empty(&buf->ctx_list)) {
-		ref = list_entry(buf->ctx_list.next,
-				 struct qeth_eddp_context_reference, list);
-		qeth_eddp_put_context(ref->ctx);
-		list_del(&ref->list);
-		kfree(ref);
-	}
-}
-
-static int qeth_eddp_buf_ref_context(struct qeth_qdio_out_buffer *buf,
-		struct qeth_eddp_context *ctx)
-{
-	struct qeth_eddp_context_reference *ref;
-
-	QETH_DBF_TEXT(TRACE, 6, "eddprfcx");
-	ref = kmalloc(sizeof(struct qeth_eddp_context_reference), GFP_ATOMIC);
-	if (ref == NULL)
-		return -ENOMEM;
-	qeth_eddp_get_context(ctx);
-	ref->ctx = ctx;
-	list_add_tail(&ref->list, &buf->ctx_list);
-	return 0;
-}
-
-int qeth_eddp_fill_buffer(struct qeth_qdio_out_q *queue,
-		struct qeth_eddp_context *ctx, int index)
-{
-	struct qeth_qdio_out_buffer *buf = NULL;
-	struct qdio_buffer *buffer;
-	int elements = ctx->num_elements;
-	int element = 0;
-	int flush_cnt = 0;
-	int must_refcnt = 1;
-	int i;
-
-	QETH_DBF_TEXT(TRACE, 5, "eddpfibu");
-	while (elements > 0) {
-		buf = &queue->bufs[index];
-		if (atomic_read(&buf->state) != QETH_QDIO_BUF_EMPTY) {
-			/* normally this should not happen since we checked for
-			 * available elements in qeth_check_elements_for_context
-			 */
-			if (element == 0)
-				return -EBUSY;
-			else {
-				QETH_DBF_MESSAGE(2, "could only partially fill"
-					"eddp buffer!\n");
-				goto out;
-			}
-		}
-		/* check if the whole next skb fits into current buffer */
-		if ((QETH_MAX_BUFFER_ELEMENTS(queue->card) -
-					buf->next_element_to_fill)
-				< ctx->elements_per_skb){
-			/* no -> go to next buffer */
-			atomic_set(&buf->state, QETH_QDIO_BUF_PRIMED);
-			index = (index + 1) % QDIO_MAX_BUFFERS_PER_Q;
-			flush_cnt++;
-			/* new buffer, so we have to add ctx to buffer'ctx_list
-			 * and increment ctx's refcnt */
-			must_refcnt = 1;
-			continue;
-		}
-		if (must_refcnt) {
-			must_refcnt = 0;
-			if (qeth_eddp_buf_ref_context(buf, ctx)) {
-				goto out_check;
-			}
-		}
-		buffer = buf->buffer;
-		/* fill one skb into buffer */
-		for (i = 0; i < ctx->elements_per_skb; ++i) {
-			if (ctx->elements[element].length != 0) {
-				buffer->element[buf->next_element_to_fill].
-				addr = ctx->elements[element].addr;
-				buffer->element[buf->next_element_to_fill].
-				length = ctx->elements[element].length;
-				buffer->element[buf->next_element_to_fill].
-				flags = ctx->elements[element].flags;
-				buf->next_element_to_fill++;
-			}
-			element++;
-			elements--;
-		}
-	}
-out_check:
-	if (!queue->do_pack) {
-		QETH_DBF_TEXT(TRACE, 6, "fillbfnp");
-		/* set state to PRIMED -> will be flushed */
-		if (buf->next_element_to_fill > 0) {
-			atomic_set(&buf->state, QETH_QDIO_BUF_PRIMED);
-			flush_cnt++;
-		}
-	} else {
-		if (queue->card->options.performance_stats)
-			queue->card->perf_stats.skbs_sent_pack++;
-		QETH_DBF_TEXT(TRACE, 6, "fillbfpa");
-		if (buf->next_element_to_fill >=
-				QETH_MAX_BUFFER_ELEMENTS(queue->card)) {
-			/*
-			 * packed buffer if full -> set state PRIMED
-			 * -> will be flushed
-			 */
-			atomic_set(&buf->state, QETH_QDIO_BUF_PRIMED);
-			flush_cnt++;
-		}
-	}
-out:
-	return flush_cnt;
-}
-
-static void qeth_eddp_create_segment_hdrs(struct qeth_eddp_context *ctx,
-		struct qeth_eddp_data *eddp, int data_len)
-{
-	u8 *page;
-	int page_remainder;
-	int page_offset;
-	int pkt_len;
-	struct qeth_eddp_element *element;
-
-	QETH_DBF_TEXT(TRACE, 5, "eddpcrsh");
-	page = ctx->pages[ctx->offset >> PAGE_SHIFT];
-	page_offset = ctx->offset % PAGE_SIZE;
-	element = &ctx->elements[ctx->num_elements];
-	pkt_len = eddp->nhl + eddp->thl + data_len;
-	/* FIXME: layer2 and VLAN !!! */
-	if (eddp->qh.hdr.l2.id == QETH_HEADER_TYPE_LAYER2)
-		pkt_len += ETH_HLEN;
-	if (eddp->mac.h_proto == __constant_htons(ETH_P_8021Q))
-		pkt_len += VLAN_HLEN;
-	/* does complete packet fit in current page ? */
-	page_remainder = PAGE_SIZE - page_offset;
-	if (page_remainder < (sizeof(struct qeth_hdr) + pkt_len)) {
-		/* no -> go to start of next page */
-		ctx->offset += page_remainder;
-		page = ctx->pages[ctx->offset >> PAGE_SHIFT];
-		page_offset = 0;
-	}
-	memcpy(page + page_offset, &eddp->qh, sizeof(struct qeth_hdr));
-	element->addr = page + page_offset;
-	element->length = sizeof(struct qeth_hdr);
-	ctx->offset += sizeof(struct qeth_hdr);
-	page_offset += sizeof(struct qeth_hdr);
-	/* add mac header (?) */
-	if (eddp->qh.hdr.l2.id == QETH_HEADER_TYPE_LAYER2) {
-		memcpy(page + page_offset, &eddp->mac, ETH_HLEN);
-		element->length += ETH_HLEN;
-		ctx->offset += ETH_HLEN;
-		page_offset += ETH_HLEN;
-	}
-	/* add VLAN tag */
-	if (eddp->mac.h_proto == __constant_htons(ETH_P_8021Q)) {
-		memcpy(page + page_offset, &eddp->vlan, VLAN_HLEN);
-		element->length += VLAN_HLEN;
-		ctx->offset += VLAN_HLEN;
-		page_offset += VLAN_HLEN;
-	}
-	/* add network header */
-	memcpy(page + page_offset, (u8 *)&eddp->nh, eddp->nhl);
-	element->length += eddp->nhl;
-	eddp->nh_in_ctx = page + page_offset;
-	ctx->offset += eddp->nhl;
-	page_offset += eddp->nhl;
-	/* add transport header */
-	memcpy(page + page_offset, (u8 *)&eddp->th, eddp->thl);
-	element->length += eddp->thl;
-	eddp->th_in_ctx = page + page_offset;
-	ctx->offset += eddp->thl;
-}
-
-static void qeth_eddp_copy_data_tcp(char *dst, struct qeth_eddp_data *eddp,
-		int len, __wsum *hcsum)
-{
-	struct skb_frag_struct *frag;
-	int left_in_frag;
-	int copy_len;
-	u8 *src;
-
-	QETH_DBF_TEXT(TRACE, 5, "eddpcdtc");
-	if (skb_shinfo(eddp->skb)->nr_frags == 0) {
-		skb_copy_from_linear_data_offset(eddp->skb, eddp->skb_offset,
-						 dst, len);
-		*hcsum = csum_partial(eddp->skb->data + eddp->skb_offset, len,
-				      *hcsum);
-		eddp->skb_offset += len;
-	} else {
-		while (len > 0) {
-			if (eddp->frag < 0) {
-				/* we're in skb->data */
-				left_in_frag = (eddp->skb->len -
-						eddp->skb->data_len)
-						- eddp->skb_offset;
-				src = eddp->skb->data + eddp->skb_offset;
-			} else {
-				frag = &skb_shinfo(eddp->skb)->frags[
-					eddp->frag];
-				left_in_frag = frag->size - eddp->frag_offset;
-				src = (u8 *)((page_to_pfn(frag->page) <<
-					PAGE_SHIFT) + frag->page_offset +
-					eddp->frag_offset);
-			}
-			if (left_in_frag <= 0) {
-				eddp->frag++;
-				eddp->frag_offset = 0;
-				continue;
-			}
-			copy_len = min(left_in_frag, len);
-			memcpy(dst, src, copy_len);
-			*hcsum = csum_partial(src, copy_len, *hcsum);
-			dst += copy_len;
-			eddp->frag_offset += copy_len;
-			eddp->skb_offset += copy_len;
-			len -= copy_len;
-		}
-	}
-}
-
-static void qeth_eddp_create_segment_data_tcp(struct qeth_eddp_context *ctx,
-		struct qeth_eddp_data *eddp, int data_len, __wsum hcsum)
-{
-	u8 *page;
-	int page_remainder;
-	int page_offset;
-	struct qeth_eddp_element *element;
-	int first_lap = 1;
-
-	QETH_DBF_TEXT(TRACE, 5, "eddpcsdt");
-	page = ctx->pages[ctx->offset >> PAGE_SHIFT];
-	page_offset = ctx->offset % PAGE_SIZE;
-	element = &ctx->elements[ctx->num_elements];
-	while (data_len) {
-		page_remainder = PAGE_SIZE - page_offset;
-		if (page_remainder < data_len) {
-			qeth_eddp_copy_data_tcp(page + page_offset, eddp,
-						page_remainder, &hcsum);
-			element->length += page_remainder;
-			if (first_lap)
-				element->flags = SBAL_FLAGS_FIRST_FRAG;
-			else
-				element->flags = SBAL_FLAGS_MIDDLE_FRAG;
-			ctx->num_elements++;
-			element++;
-			data_len -= page_remainder;
-			ctx->offset += page_remainder;
-			page = ctx->pages[ctx->offset >> PAGE_SHIFT];
-			page_offset = 0;
-			element->addr = page + page_offset;
-		} else {
-			qeth_eddp_copy_data_tcp(page + page_offset, eddp,
-						data_len, &hcsum);
-			element->length += data_len;
-			if (!first_lap)
-				element->flags = SBAL_FLAGS_LAST_FRAG;
-			ctx->num_elements++;
-			ctx->offset += data_len;
-			data_len = 0;
-		}
-		first_lap = 0;
-	}
-	((struct tcphdr *)eddp->th_in_ctx)->check = csum_fold(hcsum);
-}
-
-static __wsum qeth_eddp_check_tcp4_hdr(struct qeth_eddp_data *eddp,
-		int data_len)
-{
-	__wsum phcsum; /* pseudo header checksum */
-
-	QETH_DBF_TEXT(TRACE, 5, "eddpckt4");
-	eddp->th.tcp.h.check = 0;
-	/* compute pseudo header checksum */
-	phcsum = csum_tcpudp_nofold(eddp->nh.ip4.h.saddr, eddp->nh.ip4.h.daddr,
-				    eddp->thl + data_len, IPPROTO_TCP, 0);
-	/* compute checksum of tcp header */
-	return csum_partial(&eddp->th, eddp->thl, phcsum);
-}
-
-static __wsum qeth_eddp_check_tcp6_hdr(struct qeth_eddp_data *eddp,
-		int data_len)
-{
-	__be32 proto;
-	__wsum phcsum; /* pseudo header checksum */
-
-	QETH_DBF_TEXT(TRACE, 5, "eddpckt6");
-	eddp->th.tcp.h.check = 0;
-	/* compute pseudo header checksum */
-	phcsum = csum_partial(&eddp->nh.ip6.h.saddr,
-			      sizeof(struct in6_addr), 0);
-	phcsum = csum_partial(&eddp->nh.ip6.h.daddr,
-			      sizeof(struct in6_addr), phcsum);
-	proto = htonl(IPPROTO_TCP);
-	phcsum = csum_partial(&proto, sizeof(u32), phcsum);
-	return phcsum;
-}
-
-static struct qeth_eddp_data *qeth_eddp_create_eddp_data(struct qeth_hdr *qh,
-		u8 *nh, u8 nhl, u8 *th, u8 thl)
-{
-	struct qeth_eddp_data *eddp;
-
-	QETH_DBF_TEXT(TRACE, 5, "eddpcrda");
-	eddp = kzalloc(sizeof(struct qeth_eddp_data), GFP_ATOMIC);
-	if (eddp) {
-		eddp->nhl = nhl;
-		eddp->thl = thl;
-		memcpy(&eddp->qh, qh, sizeof(struct qeth_hdr));
-		memcpy(&eddp->nh, nh, nhl);
-		memcpy(&eddp->th, th, thl);
-		eddp->frag = -1; /* initially we're in skb->data */
-	}
-	return eddp;
-}
-
-static void __qeth_eddp_fill_context_tcp(struct qeth_eddp_context *ctx,
-		struct qeth_eddp_data *eddp)
-{
-	struct tcphdr *tcph;
-	int data_len;
-	__wsum hcsum;
-
-	QETH_DBF_TEXT(TRACE, 5, "eddpftcp");
-	eddp->skb_offset = sizeof(struct qeth_hdr) + eddp->nhl + eddp->thl;
-	if (eddp->qh.hdr.l2.id == QETH_HEADER_TYPE_LAYER2) {
-		eddp->skb_offset += sizeof(struct ethhdr);
-		if (eddp->mac.h_proto == __constant_htons(ETH_P_8021Q))
-			eddp->skb_offset += VLAN_HLEN;
-	}
-	tcph = tcp_hdr(eddp->skb);
-	while (eddp->skb_offset < eddp->skb->len) {
-		data_len = min((int)skb_shinfo(eddp->skb)->gso_size,
-			       (int)(eddp->skb->len - eddp->skb_offset));
-		/* prepare qdio hdr */
-		if (eddp->qh.hdr.l2.id == QETH_HEADER_TYPE_LAYER2) {
-			eddp->qh.hdr.l2.pkt_length = data_len + ETH_HLEN +
-						     eddp->nhl + eddp->thl;
-			if (eddp->mac.h_proto == __constant_htons(ETH_P_8021Q))
-				eddp->qh.hdr.l2.pkt_length += VLAN_HLEN;
-		} else
-			eddp->qh.hdr.l3.length = data_len + eddp->nhl +
-						 eddp->thl;
-		/* prepare ip hdr */
-		if (eddp->skb->protocol == htons(ETH_P_IP)) {
-			eddp->nh.ip4.h.tot_len = htons(data_len + eddp->nhl +
-						 eddp->thl);
-			eddp->nh.ip4.h.check = 0;
-			eddp->nh.ip4.h.check =
-				ip_fast_csum((u8 *)&eddp->nh.ip4.h,
-						eddp->nh.ip4.h.ihl);
-		} else
-			eddp->nh.ip6.h.payload_len = htons(data_len +
-								eddp->thl);
-		/* prepare tcp hdr */
-		if (data_len == (eddp->skb->len - eddp->skb_offset)) {
-			/* last segment -> set FIN and PSH flags */
-			eddp->th.tcp.h.fin = tcph->fin;
-			eddp->th.tcp.h.psh = tcph->psh;
-		}
-		if (eddp->skb->protocol == htons(ETH_P_IP))
-			hcsum = qeth_eddp_check_tcp4_hdr(eddp, data_len);
-		else
-			hcsum = qeth_eddp_check_tcp6_hdr(eddp, data_len);
-		/* fill the next segment into the context */
-		qeth_eddp_create_segment_hdrs(ctx, eddp, data_len);
-		qeth_eddp_create_segment_data_tcp(ctx, eddp, data_len, hcsum);
-		if (eddp->skb_offset >= eddp->skb->len)
-			break;
-		/* prepare headers for next round */
-		if (eddp->skb->protocol == htons(ETH_P_IP))
-			eddp->nh.ip4.h.id = htons(ntohs(eddp->nh.ip4.h.id) + 1);
-		eddp->th.tcp.h.seq = htonl(ntohl(eddp->th.tcp.h.seq) +
-			data_len);
-	}
-}
-
-static int qeth_eddp_fill_context_tcp(struct qeth_eddp_context *ctx,
-		struct sk_buff *skb, struct qeth_hdr *qhdr)
-{
-	struct qeth_eddp_data *eddp = NULL;
-
-	QETH_DBF_TEXT(TRACE, 5, "eddpficx");
-	/* create our segmentation headers and copy original headers */
-	if (skb->protocol == htons(ETH_P_IP))
-		eddp = qeth_eddp_create_eddp_data(qhdr,
-						  skb_network_header(skb),
-						  ip_hdrlen(skb),
-						  skb_transport_header(skb),
-						  tcp_hdrlen(skb));
-	else
-		eddp = qeth_eddp_create_eddp_data(qhdr,
-						  skb_network_header(skb),
-						  sizeof(struct ipv6hdr),
-						  skb_transport_header(skb),
-						  tcp_hdrlen(skb));
-
-	if (eddp == NULL) {
-		QETH_DBF_TEXT(TRACE, 2, "eddpfcnm");
-		return -ENOMEM;
-	}
-	if (qhdr->hdr.l2.id == QETH_HEADER_TYPE_LAYER2) {
-		skb_set_mac_header(skb, sizeof(struct qeth_hdr));
-		memcpy(&eddp->mac, eth_hdr(skb), ETH_HLEN);
-		if (eddp->mac.h_proto == __constant_htons(ETH_P_8021Q)) {
-			eddp->vlan[0] = skb->protocol;
-			eddp->vlan[1] = htons(vlan_tx_tag_get(skb));
-		}
-	}
-	/* the next flags will only be set on the last segment */
-	eddp->th.tcp.h.fin = 0;
-	eddp->th.tcp.h.psh = 0;
-	eddp->skb = skb;
-	/* begin segmentation and fill context */
-	__qeth_eddp_fill_context_tcp(ctx, eddp);
-	kfree(eddp);
-	return 0;
-}
-
-static void qeth_eddp_calc_num_pages(struct qeth_eddp_context *ctx,
-		struct sk_buff *skb, int hdr_len)
-{
-	int skbs_per_page;
-
-	QETH_DBF_TEXT(TRACE, 5, "eddpcanp");
-	/* can we put multiple skbs in one page? */
-	skbs_per_page = PAGE_SIZE / (skb_shinfo(skb)->gso_size + hdr_len);
-	if (skbs_per_page > 1) {
-		ctx->num_pages = (skb_shinfo(skb)->gso_segs + 1) /
-				 skbs_per_page + 1;
-		ctx->elements_per_skb = 1;
-	} else {
-		/* no -> how many elements per skb? */
-		ctx->elements_per_skb = (skb_shinfo(skb)->gso_size + hdr_len +
-				     PAGE_SIZE) >> PAGE_SHIFT;
-		ctx->num_pages = ctx->elements_per_skb *
-				 (skb_shinfo(skb)->gso_segs + 1);
-	}
-	ctx->num_elements = ctx->elements_per_skb *
-			    (skb_shinfo(skb)->gso_segs + 1);
-}
-
-static struct qeth_eddp_context *qeth_eddp_create_context_generic(
-		struct qeth_card *card, struct sk_buff *skb, int hdr_len)
-{
-	struct qeth_eddp_context *ctx = NULL;
-	u8 *addr;
-	int i;
-
-	QETH_DBF_TEXT(TRACE, 5, "creddpcg");
-	/* create the context and allocate pages */
-	ctx = kzalloc(sizeof(struct qeth_eddp_context), GFP_ATOMIC);
-	if (ctx == NULL) {
-		QETH_DBF_TEXT(TRACE, 2, "ceddpcn1");
-		return NULL;
-	}
-	ctx->type = QETH_LARGE_SEND_EDDP;
-	qeth_eddp_calc_num_pages(ctx, skb, hdr_len);
-	if (ctx->elements_per_skb > QETH_MAX_BUFFER_ELEMENTS(card)) {
-		QETH_DBF_TEXT(TRACE, 2, "ceddpcis");
-		kfree(ctx);
-		return NULL;
-	}
-	ctx->pages = kcalloc(ctx->num_pages, sizeof(u8 *), GFP_ATOMIC);
-	if (ctx->pages == NULL) {
-		QETH_DBF_TEXT(TRACE, 2, "ceddpcn2");
-		kfree(ctx);
-		return NULL;
-	}
-	for (i = 0; i < ctx->num_pages; ++i) {
-		addr = (u8 *)get_zeroed_page(GFP_ATOMIC);
-		if (addr == NULL) {
-			QETH_DBF_TEXT(TRACE, 2, "ceddpcn3");
-			ctx->num_pages = i;
-			qeth_eddp_free_context(ctx);
-			return NULL;
-		}
-		ctx->pages[i] = addr;
-	}
-	ctx->elements = kcalloc(ctx->num_elements,
-				sizeof(struct qeth_eddp_element), GFP_ATOMIC);
-	if (ctx->elements == NULL) {
-		QETH_DBF_TEXT(TRACE, 2, "ceddpcn4");
-		qeth_eddp_free_context(ctx);
-		return NULL;
-	}
-	/* reset num_elements; will be incremented again in fill_buffer to
-	 * reflect number of actually used elements */
-	ctx->num_elements = 0;
-	return ctx;
-}
-
-static struct qeth_eddp_context *qeth_eddp_create_context_tcp(
-		struct qeth_card *card, struct sk_buff *skb,
-		struct qeth_hdr *qhdr)
-{
-	struct qeth_eddp_context *ctx = NULL;
-
-	QETH_DBF_TEXT(TRACE, 5, "creddpct");
-	if (skb->protocol == htons(ETH_P_IP))
-		ctx = qeth_eddp_create_context_generic(card, skb,
-						(sizeof(struct qeth_hdr) +
-						ip_hdrlen(skb) +
-						tcp_hdrlen(skb)));
-	else if (skb->protocol == htons(ETH_P_IPV6))
-		ctx = qeth_eddp_create_context_generic(card, skb,
-			sizeof(struct qeth_hdr) + sizeof(struct ipv6hdr) +
-			tcp_hdrlen(skb));
-	else
-		QETH_DBF_TEXT(TRACE, 2, "cetcpinv");
-
-	if (ctx == NULL) {
-		QETH_DBF_TEXT(TRACE, 2, "creddpnl");
-		return NULL;
-	}
-	if (qeth_eddp_fill_context_tcp(ctx, skb, qhdr)) {
-		QETH_DBF_TEXT(TRACE, 2, "ceddptfe");
-		qeth_eddp_free_context(ctx);
-		return NULL;
-	}
-	atomic_set(&ctx->refcnt, 1);
-	return ctx;
-}
-
-struct qeth_eddp_context *qeth_eddp_create_context(struct qeth_card *card,
-		struct sk_buff *skb, struct qeth_hdr *qhdr,
-		unsigned char sk_protocol)
-{
-	QETH_DBF_TEXT(TRACE, 5, "creddpc");
-	switch (sk_protocol) {
-	case IPPROTO_TCP:
-		return qeth_eddp_create_context_tcp(card, skb, qhdr);
-	default:
-		QETH_DBF_TEXT(TRACE, 2, "eddpinvp");
-	}
-	return NULL;
-}
-EXPORT_SYMBOL_GPL(qeth_eddp_create_context);
-
-void qeth_tso_fill_header(struct qeth_card *card, struct qeth_hdr *qhdr,
-		struct sk_buff *skb)
-{
-	struct qeth_hdr_tso *hdr = (struct qeth_hdr_tso *)qhdr;
-	struct tcphdr *tcph = tcp_hdr(skb);
-	struct iphdr *iph = ip_hdr(skb);
-	struct ipv6hdr *ip6h = ipv6_hdr(skb);
-
-	QETH_DBF_TEXT(TRACE, 5, "tsofhdr");
-
-	/*fix header to TSO values ...*/
-	hdr->hdr.hdr.l3.id = QETH_HEADER_TYPE_TSO;
-	/*set values which are fix for the first approach ...*/
-	hdr->ext.hdr_tot_len = (__u16) sizeof(struct qeth_hdr_ext_tso);
-	hdr->ext.imb_hdr_no  = 1;
-	hdr->ext.hdr_type    = 1;
-	hdr->ext.hdr_version = 1;
-	hdr->ext.hdr_len     = 28;
-	/*insert non-fix values */
-	hdr->ext.mss = skb_shinfo(skb)->gso_size;
-	hdr->ext.dg_hdr_len = (__u16)(iph->ihl*4 + tcph->doff*4);
-	hdr->ext.payload_len = (__u16)(skb->len - hdr->ext.dg_hdr_len -
-				       sizeof(struct qeth_hdr_tso));
-	tcph->check = 0;
-	if (skb->protocol == ETH_P_IPV6) {
-		ip6h->payload_len = 0;
-		tcph->check = ~csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
-					       0, IPPROTO_TCP, 0);
-	} else {
-		/*OSA want us to set these values ...*/
-		tcph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
-					 0, IPPROTO_TCP, 0);
-		iph->tot_len = 0;
-		iph->check = 0;
-	}
-}
-EXPORT_SYMBOL_GPL(qeth_tso_fill_header);
-
-void qeth_tx_csum(struct sk_buff *skb)
-{
-	int tlen;
-	if (skb->protocol == htons(ETH_P_IP)) {
-		tlen = ntohs(ip_hdr(skb)->tot_len) - (ip_hdr(skb)->ihl << 2);
-		switch (ip_hdr(skb)->protocol) {
-		case IPPROTO_TCP:
-			tcp_hdr(skb)->check = 0;
-			tcp_hdr(skb)->check = csum_tcpudp_magic(
-				ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
-				tlen, ip_hdr(skb)->protocol,
-				skb_checksum(skb, skb_transport_offset(skb),
-					tlen, 0));
-			break;
-		case IPPROTO_UDP:
-			udp_hdr(skb)->check = 0;
-			udp_hdr(skb)->check = csum_tcpudp_magic(
-				ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
-				tlen, ip_hdr(skb)->protocol,
-				skb_checksum(skb, skb_transport_offset(skb),
-					tlen, 0));
-			break;
-		}
-	} else if (skb->protocol == htons(ETH_P_IPV6)) {
-		switch (ipv6_hdr(skb)->nexthdr) {
-		case IPPROTO_TCP:
-			tcp_hdr(skb)->check = 0;
-			tcp_hdr(skb)->check = csum_ipv6_magic(
-				&ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
-				ipv6_hdr(skb)->payload_len,
-				ipv6_hdr(skb)->nexthdr,
-				skb_checksum(skb, skb_transport_offset(skb),
-					ipv6_hdr(skb)->payload_len, 0));
-			break;
-		case IPPROTO_UDP:
-			udp_hdr(skb)->check = 0;
-			udp_hdr(skb)->check = csum_ipv6_magic(
-				&ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
-				ipv6_hdr(skb)->payload_len,
-				ipv6_hdr(skb)->nexthdr,
-				skb_checksum(skb, skb_transport_offset(skb),
-					ipv6_hdr(skb)->payload_len, 0));
-			break;
-		}
-	}
-}
-EXPORT_SYMBOL_GPL(qeth_tx_csum);
diff -urpN linux-2.6/drivers/s390/net/qeth_core_offl.h linux-2.6-patched/drivers/s390/net/qeth_core_offl.h
--- linux-2.6/drivers/s390/net/qeth_core_offl.h	2008-12-25 00:26:37.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core_offl.h	1970-01-01 01:00:00.000000000 +0100
@@ -1,76 +0,0 @@
-/*
- *  drivers/s390/net/qeth_core_offl.h
- *
- *    Copyright IBM Corp. 2007
- *    Author(s): Thomas Spatzier <tspat@de.ibm.com>,
- *		 Frank Blaschka <frank.blaschka@de.ibm.com>
- */
-
-#ifndef __QETH_CORE_OFFL_H__
-#define __QETH_CORE_OFFL_H__
-
-struct qeth_eddp_element {
-	u32 flags;
-	u32 length;
-	void *addr;
-};
-
-struct qeth_eddp_context {
-	atomic_t refcnt;
-	enum qeth_large_send_types type;
-	int num_pages;			    /* # of allocated pages */
-	u8 **pages;			    /* pointers to pages */
-	int offset;			    /* offset in ctx during creation */
-	int num_elements;		    /* # of required 'SBALEs' */
-	struct qeth_eddp_element *elements; /* array of 'SBALEs' */
-	int elements_per_skb;		    /* # of 'SBALEs' per skb **/
-};
-
-struct qeth_eddp_context_reference {
-	struct list_head list;
-	struct qeth_eddp_context *ctx;
-};
-
-struct qeth_eddp_data {
-	struct qeth_hdr qh;
-	struct ethhdr mac;
-	__be16 vlan[2];
-	union {
-		struct {
-			struct iphdr h;
-			u8 options[40];
-		} ip4;
-		struct {
-			struct ipv6hdr h;
-		} ip6;
-	} nh;
-	u8 nhl;
-	void *nh_in_ctx;	/* address of nh within the ctx */
-	union {
-		struct {
-			struct tcphdr h;
-			u8 options[40];
-		} tcp;
-	} th;
-	u8 thl;
-	void *th_in_ctx;	/* address of th within the ctx */
-	struct sk_buff *skb;
-	int skb_offset;
-	int frag;
-	int frag_offset;
-} __attribute__ ((packed));
-
-extern struct qeth_eddp_context *qeth_eddp_create_context(struct qeth_card *,
-		 struct sk_buff *, struct qeth_hdr *, unsigned char);
-extern void qeth_eddp_put_context(struct qeth_eddp_context *);
-extern int qeth_eddp_fill_buffer(struct qeth_qdio_out_q *,
-		struct qeth_eddp_context *, int);
-extern void qeth_eddp_buf_release_contexts(struct qeth_qdio_out_buffer *);
-extern int qeth_eddp_check_buffers_for_context(struct qeth_qdio_out_q *,
-		struct qeth_eddp_context *);
-
-void qeth_tso_fill_header(struct qeth_card *, struct qeth_hdr *,
-		struct sk_buff *);
-void qeth_tx_csum(struct sk_buff *skb);
-
-#endif /* __QETH_CORE_EDDP_H__ */
diff -urpN linux-2.6/drivers/s390/net/qeth_core_sys.c linux-2.6-patched/drivers/s390/net/qeth_core_sys.c
--- linux-2.6/drivers/s390/net/qeth_core_sys.c	2008-12-25 00:26:37.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core_sys.c	2009-02-18 12:06:32.000000000 +0100
@@ -427,8 +427,6 @@ static ssize_t qeth_dev_large_send_show(
 	switch (card->options.large_send) {
 	case QETH_LARGE_SEND_NO:
 		return sprintf(buf, "%s\n", "no");
-	case QETH_LARGE_SEND_EDDP:
-		return sprintf(buf, "%s\n", "EDDP");
 	case QETH_LARGE_SEND_TSO:
 		return sprintf(buf, "%s\n", "TSO");
 	default:
@@ -449,8 +447,6 @@ static ssize_t qeth_dev_large_send_store
 	tmp = strsep((char **) &buf, "\n");
 	if (!strcmp(tmp, "no")) {
 		type = QETH_LARGE_SEND_NO;
-	} else if (!strcmp(tmp, "EDDP")) {
-		type = QETH_LARGE_SEND_EDDP;
 	} else if (!strcmp(tmp, "TSO")) {
 		type = QETH_LARGE_SEND_TSO;
 	} else {
diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2009-02-18 12:06:32.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2009-02-18 12:06:32.000000000 +0100
@@ -21,7 +21,6 @@
 #include <linux/ip.h>
 
 #include "qeth_core.h"
-#include "qeth_core_offl.h"
 
 static int qeth_l2_set_offline(struct ccwgroup_device *);
 static int qeth_l2_stop(struct net_device *);
@@ -634,8 +633,6 @@ static int qeth_l2_hard_start_xmit(struc
 	struct qeth_qdio_out_q *queue = card->qdio.out_qs
 		[qeth_get_priority_queue(card, skb, ipv, cast_type)];
 	int tx_bytes = skb->len;
-	enum qeth_large_send_types large_send = QETH_LARGE_SEND_NO;
-	struct qeth_eddp_context *ctx = NULL;
 	int data_offset = -1;
 	int elements_needed = 0;
 	int hd_len = 0;
@@ -655,14 +652,10 @@ static int qeth_l2_hard_start_xmit(struc
 	}
 	netif_stop_queue(dev);
 
-	if (skb_is_gso(skb))
-		large_send = QETH_LARGE_SEND_EDDP;
-
 	if (card->info.type == QETH_CARD_TYPE_OSN)
 		hdr = (struct qeth_hdr *)skb->data;
 	else {
-		if ((card->info.type == QETH_CARD_TYPE_IQD) && (!large_send) &&
-		    (skb_shinfo(skb)->nr_frags == 0)) {
+		if (card->info.type == QETH_CARD_TYPE_IQD) {
 			new_skb = skb;
 			data_offset = ETH_HLEN;
 			hd_len = ETH_HLEN;
@@ -689,62 +682,26 @@ static int qeth_l2_hard_start_xmit(struc
 		}
 	}
 
-	if (large_send == QETH_LARGE_SEND_EDDP) {
-		ctx = qeth_eddp_create_context(card, new_skb, hdr,
-						skb->sk->sk_protocol);
-		if (ctx == NULL) {
-			QETH_DBF_MESSAGE(2, "could not create eddp context\n");
-			goto tx_drop;
-		}
-	} else {
-		elements = qeth_get_elements_no(card, (void *)hdr, new_skb,
+	elements = qeth_get_elements_no(card, (void *)hdr, new_skb,
 						elements_needed);
-		if (!elements) {
-			if (data_offset >= 0)
-				kmem_cache_free(qeth_core_header_cache, hdr);
-			goto tx_drop;
-		}
-	}
-
-	if ((large_send == QETH_LARGE_SEND_NO) &&
-	    (skb->ip_summed == CHECKSUM_PARTIAL)) {
-		qeth_tx_csum(new_skb);
-		if (card->options.performance_stats)
-			card->perf_stats.tx_csum++;
+	if (!elements) {
+		if (data_offset >= 0)
+			kmem_cache_free(qeth_core_header_cache, hdr);
+		goto tx_drop;
 	}
 
 	if (card->info.type != QETH_CARD_TYPE_IQD)
 		rc = qeth_do_send_packet(card, queue, new_skb, hdr,
-					 elements, ctx);
+					 elements);
 	else
 		rc = qeth_do_send_packet_fast(card, queue, new_skb, hdr,
-					elements, ctx, data_offset, hd_len);
+					elements, data_offset, hd_len);
 	if (!rc) {
 		card->stats.tx_packets++;
 		card->stats.tx_bytes += tx_bytes;
 		if (new_skb != skb)
 			dev_kfree_skb_any(skb);
-		if (card->options.performance_stats) {
-			if (large_send != QETH_LARGE_SEND_NO) {
-				card->perf_stats.large_send_bytes += tx_bytes;
-				card->perf_stats.large_send_cnt++;
-			}
-			if (skb_shinfo(new_skb)->nr_frags > 0) {
-				card->perf_stats.sg_skbs_sent++;
-				/* nr_frags + skb->data */
-				card->perf_stats.sg_frags_sent +=
-					skb_shinfo(new_skb)->nr_frags + 1;
-			}
-		}
-
-		if (ctx != NULL) {
-			qeth_eddp_put_context(ctx);
-			dev_kfree_skb_any(new_skb);
-		}
 	} else {
-		if (ctx != NULL)
-			qeth_eddp_put_context(ctx);
-
 		if (data_offset >= 0)
 			kmem_cache_free(qeth_core_header_cache, hdr);
 
@@ -881,30 +838,8 @@ static void qeth_l2_remove_device(struct
 	return;
 }
 
-static int qeth_l2_ethtool_set_tso(struct net_device *dev, u32 data)
-{
-	struct qeth_card *card = dev->ml_priv;
-
-	if (data) {
-		if (card->options.large_send == QETH_LARGE_SEND_NO) {
-			card->options.large_send = QETH_LARGE_SEND_EDDP;
-			dev->features |= NETIF_F_TSO;
-		}
-	} else {
-		dev->features &= ~NETIF_F_TSO;
-		card->options.large_send = QETH_LARGE_SEND_NO;
-	}
-	return 0;
-}
-
 static struct ethtool_ops qeth_l2_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
-	.get_tx_csum = ethtool_op_get_tx_csum,
-	.set_tx_csum = ethtool_op_set_tx_hw_csum,
-	.get_sg = ethtool_op_get_sg,
-	.set_sg = ethtool_op_set_sg,
-	.get_tso = ethtool_op_get_tso,
-	.set_tso = qeth_l2_ethtool_set_tso,
 	.get_strings = qeth_core_get_strings,
 	.get_ethtool_stats = qeth_core_get_ethtool_stats,
 	.get_stats_count = qeth_core_get_stats_count,
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2009-02-18 12:06:32.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2009-02-18 12:06:32.000000000 +0100
@@ -19,15 +19,15 @@
 #include <linux/etherdevice.h>
 #include <linux/mii.h>
 #include <linux/ip.h>
-#include <linux/reboot.h>
+#include <linux/ipv6.h>
 #include <linux/inetdevice.h>
 #include <linux/igmp.h>
 
 #include <net/ip.h>
 #include <net/arp.h>
+#include <net/ip6_checksum.h>
 
 #include "qeth_l3.h"
-#include "qeth_core_offl.h"
 
 static int qeth_l3_set_offline(struct ccwgroup_device *);
 static int qeth_l3_recover(void *);
@@ -2577,12 +2577,63 @@ static void qeth_l3_fill_header(struct q
 	}
 }
 
+static void qeth_tso_fill_header(struct qeth_card *card,
+		struct qeth_hdr *qhdr, struct sk_buff *skb)
+{
+	struct qeth_hdr_tso *hdr = (struct qeth_hdr_tso *)qhdr;
+	struct tcphdr *tcph = tcp_hdr(skb);
+	struct iphdr *iph = ip_hdr(skb);
+	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+
+	/*fix header to TSO values ...*/
+	hdr->hdr.hdr.l3.id = QETH_HEADER_TYPE_TSO;
+	/*set values which are fix for the first approach ...*/
+	hdr->ext.hdr_tot_len = (__u16) sizeof(struct qeth_hdr_ext_tso);
+	hdr->ext.imb_hdr_no  = 1;
+	hdr->ext.hdr_type    = 1;
+	hdr->ext.hdr_version = 1;
+	hdr->ext.hdr_len     = 28;
+	/*insert non-fix values */
+	hdr->ext.mss = skb_shinfo(skb)->gso_size;
+	hdr->ext.dg_hdr_len = (__u16)(iph->ihl*4 + tcph->doff*4);
+	hdr->ext.payload_len = (__u16)(skb->len - hdr->ext.dg_hdr_len -
+				       sizeof(struct qeth_hdr_tso));
+	tcph->check = 0;
+	if (skb->protocol == ETH_P_IPV6) {
+		ip6h->payload_len = 0;
+		tcph->check = ~csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
+					       0, IPPROTO_TCP, 0);
+	} else {
+		/*OSA want us to set these values ...*/
+		tcph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
+					 0, IPPROTO_TCP, 0);
+		iph->tot_len = 0;
+		iph->check = 0;
+	}
+}
+
+static void qeth_tx_csum(struct sk_buff *skb)
+{
+	__wsum csum;
+	int offset;
+
+	skb_set_transport_header(skb, skb->csum_start - skb_headroom(skb));
+	offset = skb->csum_start - skb_headroom(skb);
+	BUG_ON(offset >= skb_headlen(skb));
+	csum = skb_checksum(skb, offset, skb->len - offset, 0);
+
+	offset += skb->csum_offset;
+	BUG_ON(offset + sizeof(__sum16) > skb_headlen(skb));
+	*(__sum16 *)(skb->data + offset) = csum_fold(csum);
+}
+
 static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	int rc;
 	u16 *tag;
 	struct qeth_hdr *hdr = NULL;
 	int elements_needed = 0;
+	int elems;
 	struct qeth_card *card = dev->ml_priv;
 	struct sk_buff *new_skb = NULL;
 	int ipv = qeth_get_ip_version(skb);
@@ -2591,8 +2642,8 @@ static int qeth_l3_hard_start_xmit(struc
 		[qeth_get_priority_queue(card, skb, ipv, cast_type)];
 	int tx_bytes = skb->len;
 	enum qeth_large_send_types large_send = QETH_LARGE_SEND_NO;
-	struct qeth_eddp_context *ctx = NULL;
 	int data_offset = -1;
+	int nr_frags;
 
 	if ((card->info.type == QETH_CARD_TYPE_IQD) &&
 	    (skb->protocol != htons(ETH_P_IPV6)) &&
@@ -2615,6 +2666,12 @@ static int qeth_l3_hard_start_xmit(struc
 
 	if (skb_is_gso(skb))
 		large_send = card->options.large_send;
+	else
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			qeth_tx_csum(skb);
+			if (card->options.performance_stats)
+				card->perf_stats.tx_csum++;
+		}
 
 	if ((card->info.type == QETH_CARD_TYPE_IQD) && (!large_send) &&
 	    (skb_shinfo(skb)->nr_frags == 0)) {
@@ -2661,12 +2718,13 @@ static int qeth_l3_hard_start_xmit(struc
 	netif_stop_queue(dev);
 
 	/* fix hardware limitation: as long as we do not have sbal
-	 * chaining we can not send long frag lists so we temporary
-	 * switch to EDDP
+	 * chaining we can not send long frag lists
 	 */
 	if ((large_send == QETH_LARGE_SEND_TSO) &&
-		((skb_shinfo(new_skb)->nr_frags + 2) > 16))
-		large_send = QETH_LARGE_SEND_EDDP;
+	    ((skb_shinfo(new_skb)->nr_frags + 2) > 16)) {
+		if (skb_linearize(new_skb))
+			goto tx_drop;
+	}
 
 	if ((large_send == QETH_LARGE_SEND_TSO) &&
 	    (cast_type == RTN_UNSPEC)) {
@@ -2689,40 +2747,22 @@ static int qeth_l3_hard_start_xmit(struc
 		}
 	}
 
-	if (large_send == QETH_LARGE_SEND_EDDP) {
-		/* new_skb is not owned by a socket so we use skb to get
-		 * the protocol
-		 */
-		ctx = qeth_eddp_create_context(card, new_skb, hdr,
-						skb->sk->sk_protocol);
-		if (ctx == NULL) {
-			QETH_DBF_MESSAGE(2, "could not create eddp context\n");
-			goto tx_drop;
-		}
-	} else {
-		int elems = qeth_get_elements_no(card, (void *)hdr, new_skb,
+	elems = qeth_get_elements_no(card, (void *)hdr, new_skb,
 						 elements_needed);
-		if (!elems) {
-			if (data_offset >= 0)
-				kmem_cache_free(qeth_core_header_cache, hdr);
-			goto tx_drop;
-		}
-		elements_needed += elems;
-	}
-
-	if ((large_send == QETH_LARGE_SEND_NO) &&
-	    (new_skb->ip_summed == CHECKSUM_PARTIAL)) {
-		qeth_tx_csum(new_skb);
-		if (card->options.performance_stats)
-			card->perf_stats.tx_csum++;
+	if (!elems) {
+		if (data_offset >= 0)
+			kmem_cache_free(qeth_core_header_cache, hdr);
+		goto tx_drop;
 	}
+	elements_needed += elems;
+	nr_frags = skb_shinfo(new_skb)->nr_frags;
 
 	if (card->info.type != QETH_CARD_TYPE_IQD)
 		rc = qeth_do_send_packet(card, queue, new_skb, hdr,
-					 elements_needed, ctx);
+					 elements_needed);
 	else
 		rc = qeth_do_send_packet_fast(card, queue, new_skb, hdr,
-					elements_needed, ctx, data_offset, 0);
+					elements_needed, data_offset, 0);
 
 	if (!rc) {
 		card->stats.tx_packets++;
@@ -2734,22 +2774,13 @@ static int qeth_l3_hard_start_xmit(struc
 				card->perf_stats.large_send_bytes += tx_bytes;
 				card->perf_stats.large_send_cnt++;
 			}
-			if (skb_shinfo(new_skb)->nr_frags > 0) {
+			if (nr_frags) {
 				card->perf_stats.sg_skbs_sent++;
 				/* nr_frags + skb->data */
-				card->perf_stats.sg_frags_sent +=
-					skb_shinfo(new_skb)->nr_frags + 1;
+				card->perf_stats.sg_frags_sent += nr_frags + 1;
 			}
 		}
-
-		if (ctx != NULL) {
-			qeth_eddp_put_context(ctx);
-			dev_kfree_skb_any(new_skb);
-		}
 	} else {
-		if (ctx != NULL)
-			qeth_eddp_put_context(ctx);
-
 		if (data_offset >= 0)
 			kmem_cache_free(qeth_core_header_cache, hdr);
 
@@ -2844,7 +2875,7 @@ static int qeth_l3_ethtool_set_tso(struc
 	if (data) {
 		if (card->options.large_send == QETH_LARGE_SEND_NO) {
 			if (card->info.type == QETH_CARD_TYPE_IQD)
-				card->options.large_send = QETH_LARGE_SEND_EDDP;
+				return -EPERM;
 			else
 				card->options.large_send = QETH_LARGE_SEND_TSO;
 			dev->features |= NETIF_F_TSO;

