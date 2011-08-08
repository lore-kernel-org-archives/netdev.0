From: frank.blaschka@de.ibm.com
Subject: [patch 13/13] [PATCH] qeth: add support for af_iucv HiperSockets transport
Date: Mon, 08 Aug 2011 13:33:59 +0200
Message-ID: <20110808113516.686136290@de.ibm.com>
References: <20110808113346.516293249@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Einar Lueck <elelueck@de.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([194.196.100.163]:57402 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511Ab1HHLfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 07:35:24 -0400
Content-Disposition: inline; filename=netnext_qeth_iucv.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

This patch extends the HiperSockets device driver to send and receive
af_iucv traffic over HiperSockets transport.
TX: Driver uses new asynchronous delivery of storage blocks to pass
    flow control/congestion information from the HiperSockets microcode
    to the af_iucv socket.
RX: Memory for incoming traffic is preallocated and passed to 
    HiperSockets layer. If receiver is not capable to clean its buffers
    shared with HiperSockets and pass new memory to the HiperSockets
    layer this will cause flow control/congestion events on the
    sender.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Signed-off-by: Einar Lueck <elelueck@de.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_core.h      |   19 ++-
 drivers/s390/net/qeth_core_main.c |  230 +++++++++++++++++++++++++++++++-------
 drivers/s390/net/qeth_l2_main.c   |    2 
 drivers/s390/net/qeth_l3.h        |    4 
 drivers/s390/net/qeth_l3_main.c   |   87 +++++++++++---
 drivers/s390/net/qeth_l3_sys.c    |  110 ++++++++++++++++++
 6 files changed, 391 insertions(+), 61 deletions(-)

--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -217,6 +217,7 @@ static inline int qeth_is_ipa_enabled(st
  */
 #define QETH_TX_TIMEOUT		100 * HZ
 #define QETH_RCD_TIMEOUT	60 * HZ
+#define QETH_RECLAIM_WORK_TIME	HZ
 #define QETH_HEADER_SIZE	32
 #define QETH_MAX_PORTNO		15
 
@@ -265,6 +266,7 @@ static inline int qeth_is_ipa_enabled(st
 
 /* large receive scatter gather copy break */
 #define QETH_RX_SG_CB (PAGE_SIZE >> 1)
+#define QETH_RX_PULL_LEN 256
 
 struct qeth_hdr_layer3 {
 	__u8  id;
@@ -382,6 +384,16 @@ enum qeth_qdio_buffer_states {
 	QETH_QDIO_BUF_PRIMED,
 	/*
 	 * inbound: not applicable
+	 * outbound: identified to be pending in TPQ
+	 */
+	QETH_QDIO_BUF_PENDING,
+	/*
+	 * inbound: not applicable
+	 * outbound: found in completion queue
+	 */
+	QETH_QDIO_BUF_IN_CQ,
+	/*
+	 * inbound: not applicable
 	 * outbound: handled via transfer pending / completion queue
 	 */
 	QETH_QDIO_BUF_HANDLED_DELAYED,
@@ -409,6 +421,7 @@ struct qeth_qdio_buffer {
 	struct qdio_buffer *buffer;
 	/* the buffer pool entry currently associated to this buffer */
 	struct qeth_buffer_pool_entry *pool_entry;
+	struct sk_buff *rx_skb;
 };
 
 struct qeth_qdio_q {
@@ -674,6 +687,7 @@ struct qeth_card_options {
 	enum qeth_ipa_isolation_modes isolation;
 	int sniffer;
 	enum qeth_cq cq;
+	char hsuid[9];
 };
 
 /*
@@ -771,6 +785,8 @@ struct qeth_card {
 	struct mutex discipline_mutex;
 	struct napi_struct napi;
 	struct qeth_rx rx;
+	struct delayed_work buffer_reclaim_work;
+	int reclaim_index;
 };
 
 struct qeth_card_list_struct {
@@ -836,6 +852,7 @@ int qeth_core_create_device_attributes(s
 void qeth_core_remove_device_attributes(struct device *);
 int qeth_core_create_osn_attributes(struct device *);
 void qeth_core_remove_osn_attributes(struct device *);
+void qeth_buffer_reclaim_work(struct work_struct *);
 
 /* exports for qeth discipline device drivers */
 extern struct qeth_card_list_struct qeth_core_card_list;
@@ -864,7 +881,7 @@ int qeth_check_qdio_errors(struct qeth_c
 		unsigned int, const char *);
 void qeth_queue_input_buffer(struct qeth_card *, int);
 struct sk_buff *qeth_core_get_next_skb(struct qeth_card *,
-		struct qdio_buffer *, struct qdio_buffer_element **, int *,
+		struct qeth_qdio_buffer *, struct qdio_buffer_element **, int *,
 		struct qeth_hdr **);
 void qeth_schedule_recovery(struct qeth_card *);
 void qeth_qdio_start_poll(struct ccw_device *, int, unsigned long);
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -21,6 +21,7 @@
 #include <linux/mii.h>
 #include <linux/kthread.h>
 #include <linux/slab.h>
+#include <net/iucv/af_iucv.h>
 
 #include <asm/ebcdic.h>
 #include <asm/io.h>
@@ -58,6 +59,10 @@ static void qeth_setup_ccw(struct qeth_c
 static void qeth_free_buffer_pool(struct qeth_card *);
 static int qeth_qdio_establish(struct qeth_card *);
 static void qeth_free_qdio_buffers(struct qeth_card *);
+static void qeth_notify_skbs(struct qeth_qdio_out_q *queue,
+		struct qeth_qdio_out_buffer *buf,
+		enum iucv_tx_notify notification);
+static void qeth_release_skbs(struct qeth_qdio_out_buffer *buf);
 static void qeth_clear_output_buffer(struct qeth_qdio_out_q *queue,
 		struct qeth_qdio_out_buffer *buf,
 		enum qeth_qdio_buffer_states newbufstate);
@@ -204,7 +209,7 @@ static int qeth_alloc_buffer_pool(struct
 
 	QETH_CARD_TEXT(card, 5, "alocpool");
 	for (i = 0; i < card->qdio.init_pool.buf_count; ++i) {
-		pool_entry = kmalloc(sizeof(*pool_entry), GFP_KERNEL);
+		pool_entry = kzalloc(sizeof(*pool_entry), GFP_KERNEL);
 		if (!pool_entry) {
 			qeth_free_buffer_pool(card);
 			return -ENOMEM;
@@ -331,6 +336,30 @@ static inline void qeth_free_cq(struct q
 	card->qdio.out_bufstates = NULL;
 }
 
+static inline enum iucv_tx_notify qeth_compute_cq_notification(int sbalf15,
+	int delayed) {
+	enum iucv_tx_notify n;
+
+	switch (sbalf15) {
+	case 0:
+		n = delayed ? TX_NOTIFY_DELAYED_OK : TX_NOTIFY_OK;
+		break;
+	case 4:
+	case 16:
+	case 17:
+	case 18:
+		n = delayed ? TX_NOTIFY_DELAYED_UNREACHABLE :
+			TX_NOTIFY_UNREACHABLE;
+		break;
+	default:
+		n = delayed ? TX_NOTIFY_DELAYED_GENERALERROR :
+			TX_NOTIFY_GENERALERROR;
+		break;
+	}
+
+	return n;
+}
+
 static inline void qeth_cleanup_handled_pending(struct qeth_qdio_out_q *q,
 	int bidx, int forced_cleanup)
 {
@@ -345,6 +374,11 @@ static inline void qeth_cleanup_handled_
 				struct qeth_qdio_out_buffer *f = c;
 				QETH_CARD_TEXT(f->q->card, 5, "fp");
 				QETH_CARD_TEXT_(f->q->card, 5, "%lx", (long) f);
+				/* release here to avoid interleaving between
+				   outbound tasklet and inbound tasklet
+				   regarding notifications and lifecycle */
+				qeth_release_skbs(c);
+
 				c = f->next_pending;
 				BUG_ON(head->next_pending != f);
 				head->next_pending = c;
@@ -363,6 +397,7 @@ static inline void qeth_qdio_handle_aob(
 		unsigned long phys_aob_addr) {
 	struct qaob *aob;
 	struct qeth_qdio_out_buffer *buffer;
+	enum iucv_tx_notify notification;
 
 	aob = (struct qaob *) phys_to_virt(phys_aob_addr);
 	QETH_CARD_TEXT(card, 5, "haob");
@@ -372,6 +407,22 @@ static inline void qeth_qdio_handle_aob(
 
 	BUG_ON(buffer == NULL);
 
+	if (atomic_cmpxchg(&buffer->state, QETH_QDIO_BUF_PRIMED,
+			   QETH_QDIO_BUF_IN_CQ) == QETH_QDIO_BUF_PRIMED) {
+		notification = TX_NOTIFY_OK;
+	} else {
+		BUG_ON(atomic_read(&buffer->state) != QETH_QDIO_BUF_PENDING);
+
+		atomic_set(&buffer->state, QETH_QDIO_BUF_IN_CQ);
+		notification = TX_NOTIFY_DELAYED_OK;
+	}
+
+	if (aob->aorc != 0)  {
+		QETH_CARD_TEXT_(card, 2, "aorc%02X", aob->aorc);
+		notification = qeth_compute_cq_notification(aob->aorc, 1);
+	}
+	qeth_notify_skbs(buffer->q, buffer, notification);
+
 	buffer->aob = NULL;
 	qeth_clear_output_buffer(buffer->q, buffer,
 				QETH_QDIO_BUF_HANDLED_DELAYED);
@@ -738,7 +789,7 @@ static int qeth_setup_channel(struct qet
 	QETH_DBF_TEXT(SETUP, 2, "setupch");
 	for (cnt = 0; cnt < QETH_CMD_BUFFER_NO; cnt++) {
 		channel->iob[cnt].data =
-			kmalloc(QETH_BUFSIZE, GFP_DMA|GFP_KERNEL);
+			kzalloc(QETH_BUFSIZE, GFP_DMA|GFP_KERNEL);
 		if (channel->iob[cnt].data == NULL)
 			break;
 		channel->iob[cnt].state = BUF_STATE_FREE;
@@ -1033,23 +1084,60 @@ out:
 	return;
 }
 
-static void qeth_clear_output_buffer(struct qeth_qdio_out_q *queue,
+static void qeth_notify_skbs(struct qeth_qdio_out_q *q,
 		struct qeth_qdio_out_buffer *buf,
-		enum qeth_qdio_buffer_states newbufstate)
+		enum iucv_tx_notify notification)
 {
-	int i;
 	struct sk_buff *skb;
 
-	/* is PCI flag set on buffer? */
-	if (buf->buffer->element[0].sflags & SBAL_SFLAGS0_PCI_REQ)
-		atomic_dec(&queue->set_pci_flags_count);
+	if (skb_queue_empty(&buf->skb_list))
+		goto out;
+	skb = skb_peek(&buf->skb_list);
+	while (skb) {
+		QETH_CARD_TEXT_(q->card, 5, "skbn%d", notification);
+		QETH_CARD_TEXT_(q->card, 5, "%lx", (long) skb);
+		if (skb->protocol == ETH_P_AF_IUCV) {
+			if (skb->sk) {
+				struct iucv_sock *iucv = iucv_sk(skb->sk);
+				iucv->sk_txnotify(skb, notification);
+			}
+		}
+		if (skb_queue_is_last(&buf->skb_list, skb))
+			skb = NULL;
+		else
+			skb = skb_queue_next(&buf->skb_list, skb);
+	}
+out:
+	return;
+}
+
+static void qeth_release_skbs(struct qeth_qdio_out_buffer *buf)
+{
+	struct sk_buff *skb;
 
 	skb = skb_dequeue(&buf->skb_list);
 	while (skb) {
+		QETH_CARD_TEXT(buf->q->card, 5, "skbr");
+		QETH_CARD_TEXT_(buf->q->card, 5, "%lx", (long) skb);
 		atomic_dec(&skb->users);
 		dev_kfree_skb_any(skb);
 		skb = skb_dequeue(&buf->skb_list);
 	}
+}
+
+static void qeth_clear_output_buffer(struct qeth_qdio_out_q *queue,
+		struct qeth_qdio_out_buffer *buf,
+		enum qeth_qdio_buffer_states newbufstate)
+{
+	int i;
+
+	/* is PCI flag set on buffer? */
+	if (buf->buffer->element[0].sflags & SBAL_SFLAGS0_PCI_REQ)
+		atomic_dec(&queue->set_pci_flags_count);
+
+	if (newbufstate == QETH_QDIO_BUF_EMPTY) {
+		qeth_release_skbs(buf);
+	}
 	for (i = 0; i < QETH_MAX_BUFFER_ELEMENTS(queue->card); ++i) {
 		if (buf->buffer->element[i].addr && buf->is_header[i])
 			kmem_cache_free(qeth_core_header_cache,
@@ -1111,14 +1199,16 @@ static void qeth_free_buffer_pool(struct
 
 static void qeth_free_qdio_buffers(struct qeth_card *card)
 {
-	int i;
+	int i, j;
 
 	if (atomic_xchg(&card->qdio.state, QETH_QDIO_UNINITIALIZED) ==
 		QETH_QDIO_UNINITIALIZED)
 		return;
 
 	qeth_free_cq(card);
-
+	cancel_delayed_work_sync(&card->buffer_reclaim_work);
+	for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j)
+		kfree_skb(card->qdio.in_q->bufs[j].rx_skb);
 	kfree(card->qdio.in_q);
 	card->qdio.in_q = NULL;
 	/* inbound buffer pool */
@@ -1289,6 +1379,7 @@ static int qeth_setup_card(struct qeth_c
 	card->ipato.invert6 = 0;
 	/* init QDIO stuff */
 	qeth_init_qdio_info(card);
+	INIT_DELAYED_WORK(&card->buffer_reclaim_work, qeth_buffer_reclaim_work);
 	return 0;
 }
 
@@ -1310,7 +1401,7 @@ static struct qeth_card *qeth_alloc_card
 	if (!card)
 		goto out;
 	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
-	card->ip_tbd_list = kmalloc(sizeof(struct list_head), GFP_KERNEL);
+	card->ip_tbd_list = kzalloc(sizeof(struct list_head), GFP_KERNEL);
 	if (!card->ip_tbd_list) {
 		QETH_DBF_TEXT(SETUP, 0, "iptbdnom");
 		goto out_card;
@@ -2239,7 +2330,7 @@ static int qeth_alloc_qdio_buffers(struc
 		QETH_QDIO_ALLOCATED) != QETH_QDIO_UNINITIALIZED)
 		return 0;
 
-	card->qdio.in_q = kmalloc(sizeof(struct qeth_qdio_q),
+	card->qdio.in_q = kzalloc(sizeof(struct qeth_qdio_q),
 				   GFP_KERNEL);
 	if (!card->qdio.in_q)
 		goto out_nomem;
@@ -2247,27 +2338,28 @@ static int qeth_alloc_qdio_buffers(struc
 	QETH_DBF_HEX(SETUP, 2, &card->qdio.in_q, sizeof(void *));
 	memset(card->qdio.in_q, 0, sizeof(struct qeth_qdio_q));
 	/* give inbound qeth_qdio_buffers their qdio_buffers */
-	for (i = 0; i < QDIO_MAX_BUFFERS_PER_Q; ++i)
+	for (i = 0; i < QDIO_MAX_BUFFERS_PER_Q; ++i) {
 		card->qdio.in_q->bufs[i].buffer =
 			&card->qdio.in_q->qdio_bufs[i];
+		card->qdio.in_q->bufs[i].rx_skb = NULL;
+	}
 	/* inbound buffer pool */
 	if (qeth_alloc_buffer_pool(card))
 		goto out_freeinq;
 
 	/* outbound */
 	card->qdio.out_qs =
-		kmalloc(card->qdio.no_out_queues *
+		kzalloc(card->qdio.no_out_queues *
 			sizeof(struct qeth_qdio_out_q *), GFP_KERNEL);
 	if (!card->qdio.out_qs)
 		goto out_freepool;
 	for (i = 0; i < card->qdio.no_out_queues; ++i) {
-		card->qdio.out_qs[i] = kmalloc(sizeof(struct qeth_qdio_out_q),
+		card->qdio.out_qs[i] = kzalloc(sizeof(struct qeth_qdio_out_q),
 					       GFP_KERNEL);
 		if (!card->qdio.out_qs[i])
 			goto out_freeoutq;
 		QETH_DBF_TEXT_(SETUP, 2, "outq %i", i);
 		QETH_DBF_HEX(SETUP, 2, &card->qdio.out_qs[i], sizeof(void *));
-		memset(card->qdio.out_qs[i], 0, sizeof(struct qeth_qdio_out_q));
 		card->qdio.out_qs[i]->queue_no = i;
 		/* give outbound qeth_qdio_buffers their qdio_buffers */
 		for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j) {
@@ -2565,6 +2657,12 @@ static int qeth_init_input_buffer(struct
 	struct qeth_buffer_pool_entry *pool_entry;
 	int i;
 
+	if ((card->options.cq == QETH_CQ_ENABLED) && (!buf->rx_skb)) {
+		buf->rx_skb = dev_alloc_skb(QETH_RX_PULL_LEN + ETH_HLEN);
+		if (!buf->rx_skb)
+			return 1;
+	}
+
 	pool_entry = qeth_find_free_buffer_pool_entry(card);
 	if (!pool_entry)
 		return 1;
@@ -2954,9 +3052,19 @@ int qeth_check_qdio_errors(struct qeth_c
 }
 EXPORT_SYMBOL_GPL(qeth_check_qdio_errors);
 
+void qeth_buffer_reclaim_work(struct work_struct *work)
+{
+	struct qeth_card *card = container_of(work, struct qeth_card,
+		buffer_reclaim_work.work);
+
+	QETH_CARD_TEXT_(card, 2, "brw:%x", card->reclaim_index);
+	qeth_queue_input_buffer(card, card->reclaim_index);
+}
+
 void qeth_queue_input_buffer(struct qeth_card *card, int index)
 {
 	struct qeth_qdio_q *queue = card->qdio.in_q;
+	struct list_head *lh;
 	int count;
 	int i;
 	int rc;
@@ -2988,6 +3096,20 @@ void qeth_queue_input_buffer(struct qeth
 			atomic_add_unless(&card->force_alloc_skb, -1, 0);
 		}
 
+		if (!count) {
+			i = 0;
+			list_for_each(lh, &card->qdio.in_buf_pool.entry_list)
+				i++;
+			if (i == card->qdio.in_buf_pool.buf_count) {
+				QETH_CARD_TEXT(card, 2, "qsarbw");
+				card->reclaim_index = index;
+				schedule_delayed_work(
+					&card->buffer_reclaim_work,
+					QETH_RECLAIM_WORK_TIME);
+			}
+			return;
+		}
+
 		/*
 		 * according to old code it should be avoided to requeue all
 		 * 128 buffers in order to benefit from PCI avoidance.
@@ -3396,15 +3518,34 @@ void qeth_qdio_output_handler(struct ccw
 		if (queue->bufstates &&
 		    (queue->bufstates[bidx].flags &
 		     QDIO_OUTBUF_STATE_FLAG_PENDING) != 0) {
+			BUG_ON(card->options.cq != QETH_CQ_ENABLED);
+
+			if (atomic_cmpxchg(&buffer->state,
+					   QETH_QDIO_BUF_PRIMED,
+					   QETH_QDIO_BUF_PENDING) ==
+				QETH_QDIO_BUF_PRIMED) {
+				qeth_notify_skbs(queue, buffer,
+						 TX_NOTIFY_PENDING);
+			}
 			buffer->aob = queue->bufstates[bidx].aob;
 			QETH_CARD_TEXT_(queue->card, 5, "pel%d", bidx);
-			QETH_CARD_TEXT_(queue->card, 5, "aob");
+			QETH_CARD_TEXT(queue->card, 5, "aob");
 			QETH_CARD_TEXT_(queue->card, 5, "%lx",
 					virt_to_phys(buffer->aob));
 			BUG_ON(bidx < 0 || bidx >= QDIO_MAX_BUFFERS_PER_Q);
-			if (qeth_init_qdio_out_buf(queue, bidx))
+			if (qeth_init_qdio_out_buf(queue, bidx)) {
+				QETH_CARD_TEXT(card, 2, "outofbuf");
 				qeth_schedule_recovery(card);
+			}
 		} else {
+			if (card->options.cq == QETH_CQ_ENABLED) {
+				enum iucv_tx_notify n;
+
+				n = qeth_compute_cq_notification(
+					buffer->buffer->element[15].sflags, 0);
+				qeth_notify_skbs(queue, buffer, n);
+			}
+
 			qeth_clear_output_buffer(queue, buffer,
 						QETH_QDIO_BUF_EMPTY);
 		}
@@ -4335,7 +4476,7 @@ static int qeth_qdio_establish(struct qe
 	qeth_create_qib_param_field(card, qib_param_field);
 	qeth_create_qib_param_field_blkt(card, qib_param_field);
 
-	in_sbal_ptrs = kmalloc(card->qdio.no_in_queues *
+	in_sbal_ptrs = kzalloc(card->qdio.no_in_queues *
 			       QDIO_MAX_BUFFERS_PER_Q * sizeof(void *),
 			       GFP_KERNEL);
 	if (!in_sbal_ptrs) {
@@ -4359,7 +4500,7 @@ static int qeth_qdio_establish(struct qe
 	qeth_qdio_establish_cq(card, in_sbal_ptrs, queue_start_poll);
 
 	out_sbal_ptrs =
-		kmalloc(card->qdio.no_out_queues * QDIO_MAX_BUFFERS_PER_Q *
+		kzalloc(card->qdio.no_out_queues * QDIO_MAX_BUFFERS_PER_Q *
 			sizeof(void *), GFP_KERNEL);
 	if (!out_sbal_ptrs) {
 		rc = -ENOMEM;
@@ -4557,29 +4698,36 @@ out:
 }
 EXPORT_SYMBOL_GPL(qeth_core_hardsetup_card);
 
-static inline int qeth_create_skb_frag(struct qdio_buffer_element *element,
+static inline int qeth_create_skb_frag(struct qeth_qdio_buffer *qethbuffer,
+		struct qdio_buffer_element *element,
 		struct sk_buff **pskb, int offset, int *pfrag, int data_len)
 {
 	struct page *page = virt_to_page(element->addr);
 	if (*pskb == NULL) {
-		/* the upper protocol layers assume that there is data in the
-		 * skb itself. Copy a small amount (64 bytes) to make them
-		 * happy. */
-		*pskb = dev_alloc_skb(64 + ETH_HLEN);
-		if (!(*pskb))
-			return -ENOMEM;
+		if (qethbuffer->rx_skb) {
+			/* only if qeth_card.options.cq == QETH_CQ_ENABLED */
+			*pskb = qethbuffer->rx_skb;
+			qethbuffer->rx_skb = NULL;
+		} else {
+			*pskb = dev_alloc_skb(QETH_RX_PULL_LEN + ETH_HLEN);
+			if (!(*pskb))
+				return -ENOMEM;
+		}
+
 		skb_reserve(*pskb, ETH_HLEN);
-		if (data_len <= 64) {
+		if (data_len <= QETH_RX_PULL_LEN) {
 			memcpy(skb_put(*pskb, data_len), element->addr + offset,
 				data_len);
 		} else {
 			get_page(page);
-			memcpy(skb_put(*pskb, 64), element->addr + offset, 64);
-			skb_fill_page_desc(*pskb, *pfrag, page, offset + 64,
-				data_len - 64);
-			(*pskb)->data_len += data_len - 64;
-			(*pskb)->len      += data_len - 64;
-			(*pskb)->truesize += data_len - 64;
+			memcpy(skb_put(*pskb, QETH_RX_PULL_LEN),
+			       element->addr + offset, QETH_RX_PULL_LEN);
+			skb_fill_page_desc(*pskb, *pfrag, page,
+				offset + QETH_RX_PULL_LEN,
+				data_len - QETH_RX_PULL_LEN);
+			(*pskb)->data_len += data_len - QETH_RX_PULL_LEN;
+			(*pskb)->len      += data_len - QETH_RX_PULL_LEN;
+			(*pskb)->truesize += data_len - QETH_RX_PULL_LEN;
 			(*pfrag)++;
 		}
 	} else {
@@ -4596,11 +4744,12 @@ static inline int qeth_create_skb_frag(s
 }
 
 struct sk_buff *qeth_core_get_next_skb(struct qeth_card *card,
-		struct qdio_buffer *buffer,
+		struct qeth_qdio_buffer *qethbuffer,
 		struct qdio_buffer_element **__element, int *__offset,
 		struct qeth_hdr **hdr)
 {
 	struct qdio_buffer_element *element = *__element;
+	struct qdio_buffer *buffer = qethbuffer->buffer;
 	int offset = *__offset;
 	struct sk_buff *skb = NULL;
 	int skb_len = 0;
@@ -4645,9 +4794,10 @@ struct sk_buff *qeth_core_get_next_skb(s
 	if (!skb_len)
 		return NULL;
 
-	if ((skb_len >= card->options.rx_sg_cb) &&
-	    (!(card->info.type == QETH_CARD_TYPE_OSN)) &&
-	    (!atomic_read(&card->force_alloc_skb))) {
+	if (((skb_len >= card->options.rx_sg_cb) &&
+	     (!(card->info.type == QETH_CARD_TYPE_OSN)) &&
+	     (!atomic_read(&card->force_alloc_skb))) ||
+	    (card->options.cq == QETH_CQ_ENABLED)) {
 		use_rx_sg = 1;
 	} else {
 		skb = dev_alloc_skb(skb_len + headroom);
@@ -4662,8 +4812,8 @@ struct sk_buff *qeth_core_get_next_skb(s
 		data_len = min(skb_len, (int)(element->length - offset));
 		if (data_len) {
 			if (use_rx_sg) {
-				if (qeth_create_skb_frag(element, &skb, offset,
-				    &frag, data_len))
+				if (qeth_create_skb_frag(qethbuffer, element,
+				    &skb, offset, &frag, data_len))
 					goto no_mem;
 			} else {
 				memcpy(skb_put(skb, data_len), data_ptr,
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -409,7 +409,7 @@ static int qeth_l2_process_inbound_buffe
 	BUG_ON(!budget);
 	while (budget) {
 		skb = qeth_core_get_next_skb(card,
-			card->qdio.in_q->bufs[card->rx.b_index].buffer,
+			&card->qdio.in_q->bufs[card->rx.b_index],
 			&card->rx.b_element, &card->rx.e_offset, &hdr);
 		if (!skb) {
 			*done = 1;
--- a/drivers/s390/net/qeth_l3.h
+++ b/drivers/s390/net/qeth_l3.h
@@ -63,5 +63,9 @@ int qeth_l3_add_rxip(struct qeth_card *,
 void qeth_l3_del_rxip(struct qeth_card *card, enum qeth_prot_versions,
 			const u8 *);
 int qeth_l3_is_addr_covered_by_ipato(struct qeth_card *, struct qeth_ipaddr *);
+struct qeth_ipaddr *qeth_l3_get_addr_buffer(enum qeth_prot_versions);
+int qeth_l3_add_ip(struct qeth_card *, struct qeth_ipaddr *);
+int qeth_l3_delete_ip(struct qeth_card *, struct qeth_ipaddr *);
+void qeth_l3_set_ip_addr_list(struct qeth_card *);
 
 #endif /* __QETH_L3_H__ */
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -29,6 +29,7 @@
 #include <net/ip.h>
 #include <net/arp.h>
 #include <net/ip6_checksum.h>
+#include <net/iucv/af_iucv.h>
 
 #include "qeth_l3.h"
 
@@ -267,7 +268,7 @@ static int __qeth_l3_insert_ip_todo(stru
 	}
 }
 
-static int qeth_l3_delete_ip(struct qeth_card *card, struct qeth_ipaddr *addr)
+int qeth_l3_delete_ip(struct qeth_card *card, struct qeth_ipaddr *addr)
 {
 	unsigned long flags;
 	int rc = 0;
@@ -286,7 +287,7 @@ static int qeth_l3_delete_ip(struct qeth
 	return rc;
 }
 
-static int qeth_l3_add_ip(struct qeth_card *card, struct qeth_ipaddr *addr)
+int qeth_l3_add_ip(struct qeth_card *card, struct qeth_ipaddr *addr)
 {
 	unsigned long flags;
 	int rc = 0;
@@ -305,7 +306,7 @@ static int qeth_l3_add_ip(struct qeth_ca
 }
 
 
-static struct qeth_ipaddr *qeth_l3_get_addr_buffer(
+struct qeth_ipaddr *qeth_l3_get_addr_buffer(
 				enum qeth_prot_versions prot)
 {
 	struct qeth_ipaddr *addr;
@@ -421,7 +422,7 @@ again:
 	list_splice(&fail_list, &card->ip_list);
 }
 
-static void qeth_l3_set_ip_addr_list(struct qeth_card *card)
+void qeth_l3_set_ip_addr_list(struct qeth_card *card)
 {
 	struct list_head *tbd_list;
 	struct qeth_ipaddr *todo, *addr;
@@ -438,7 +439,7 @@ static void qeth_l3_set_ip_addr_list(str
 
 	spin_lock_irqsave(&card->ip_lock, flags);
 	tbd_list = card->ip_tbd_list;
-	card->ip_tbd_list = kmalloc(sizeof(struct list_head), GFP_ATOMIC);
+	card->ip_tbd_list = kzalloc(sizeof(struct list_head), GFP_ATOMIC);
 	if (!card->ip_tbd_list) {
 		QETH_CARD_TEXT(card, 0, "silnomem");
 		card->ip_tbd_list = tbd_list;
@@ -1993,12 +1994,13 @@ static int qeth_l3_process_inbound_buffe
 	__u16 vlan_tag = 0;
 	int is_vlan;
 	unsigned int len;
+	__u16 magic;
 
 	*done = 0;
 	BUG_ON(!budget);
 	while (budget) {
 		skb = qeth_core_get_next_skb(card,
-			card->qdio.in_q->bufs[card->rx.b_index].buffer,
+			&card->qdio.in_q->bufs[card->rx.b_index],
 			&card->rx.b_element, &card->rx.e_offset, &hdr);
 		if (!skb) {
 			*done = 1;
@@ -2007,12 +2009,26 @@ static int qeth_l3_process_inbound_buffe
 		skb->dev = card->dev;
 		switch (hdr->hdr.l3.id) {
 		case QETH_HEADER_TYPE_LAYER3:
-			is_vlan = qeth_l3_rebuild_skb(card, skb, hdr,
+			magic = *(__u16 *)skb->data;
+			if ((card->info.type == QETH_CARD_TYPE_IQD) &&
+			    (magic == ETH_P_AF_IUCV)) {
+				skb->protocol = ETH_P_AF_IUCV;
+				skb->pkt_type = PACKET_HOST;
+				skb->mac_header = NET_SKB_PAD;
+				skb->dev = card->dev;
+				len = skb->len;
+				card->dev->header_ops->create(skb, card->dev, 0,
+					card->dev->dev_addr, "FAKELL",
+					card->dev->addr_len);
+				netif_receive_skb(skb);
+			} else {
+				is_vlan = qeth_l3_rebuild_skb(card, skb, hdr,
 						      &vlan_tag);
-			len = skb->len;
-			if (is_vlan && !card->options.sniffer)
-				__vlan_hwaccel_put_tag(skb, vlan_tag);
-			napi_gro_receive(&card->napi, skb);
+				len = skb->len;
+				if (is_vlan && !card->options.sniffer)
+					__vlan_hwaccel_put_tag(skb, vlan_tag);
+				napi_gro_receive(&card->napi, skb);
+			}
 			break;
 		case QETH_HEADER_TYPE_LAYER2: /* for HiperSockets sniffer */
 			skb->pkt_type = PACKET_HOST;
@@ -2784,6 +2800,30 @@ int inline qeth_l3_get_cast_type(struct
 	return cast_type;
 }
 
+static void qeth_l3_fill_af_iucv_hdr(struct qeth_card *card,
+		struct qeth_hdr *hdr, struct sk_buff *skb)
+{
+	char daddr[16];
+	struct af_iucv_trans_hdr *iucv_hdr;
+
+	skb_pull(skb, 14);
+	card->dev->header_ops->create(skb, card->dev, 0,
+				      card->dev->dev_addr, card->dev->dev_addr,
+				      card->dev->addr_len);
+	skb_pull(skb, 14);
+	iucv_hdr = (struct af_iucv_trans_hdr *)skb->data;
+	memset(hdr, 0, sizeof(struct qeth_hdr));
+	hdr->hdr.l3.id = QETH_HEADER_TYPE_LAYER3;
+	hdr->hdr.l3.ext_flags = 0;
+	hdr->hdr.l3.length = skb->len;
+	hdr->hdr.l3.flags = QETH_HDR_IPV6 | QETH_CAST_UNICAST;
+	memset(daddr, 0, sizeof(daddr));
+	daddr[0] = 0xfe;
+	daddr[1] = 0x80;
+	memcpy(&daddr[8], iucv_hdr->destUserID, 8);
+	memcpy(hdr->hdr.l3.dest_addr, daddr, 16);
+}
+
 static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 		struct sk_buff *skb, int ipv, int cast_type)
 {
@@ -2936,8 +2976,11 @@ static int qeth_l3_hard_start_xmit(struc
 	int data_offset = -1;
 	int nr_frags;
 
-	if (((card->info.type == QETH_CARD_TYPE_IQD) && (!ipv)) ||
-	     card->options.sniffer)
+	if (((card->info.type == QETH_CARD_TYPE_IQD) &&
+	     (((card->options.cq != QETH_CQ_ENABLED) && !ipv) ||
+	      ((card->options.cq == QETH_CQ_ENABLED) &&
+	       (skb->protocol != ETH_P_AF_IUCV)))) ||
+	    card->options.sniffer)
 			goto tx_drop;
 
 	if ((card->state != CARD_STATE_UP) || !card->lan_online) {
@@ -2959,7 +3002,10 @@ static int qeth_l3_hard_start_xmit(struc
 	if ((card->info.type == QETH_CARD_TYPE_IQD) && (!large_send) &&
 	    (skb_shinfo(skb)->nr_frags == 0)) {
 		new_skb = skb;
-		data_offset = ETH_HLEN;
+		if (new_skb->protocol == ETH_P_AF_IUCV)
+			data_offset = 0;
+		else
+			data_offset = ETH_HLEN;
 		hdr = kmem_cache_alloc(qeth_core_header_cache, GFP_ATOMIC);
 		if (!hdr)
 			goto tx_drop;
@@ -3024,9 +3070,13 @@ static int qeth_l3_hard_start_xmit(struc
 			qeth_l3_fill_header(card, hdr, new_skb, ipv,
 						cast_type);
 		} else {
-			qeth_l3_fill_header(card, hdr, new_skb, ipv,
-						cast_type);
-			hdr->hdr.l3.length = new_skb->len - data_offset;
+			if (new_skb->protocol == ETH_P_AF_IUCV)
+				qeth_l3_fill_af_iucv_hdr(card, hdr, new_skb);
+			else {
+				qeth_l3_fill_header(card, hdr, new_skb, ipv,
+							cast_type);
+				hdr->hdr.l3.length = new_skb->len - data_offset;
+			}
 		}
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
@@ -3289,6 +3339,8 @@ static int qeth_l3_setup_netdev(struct q
 		card->dev->flags |= IFF_NOARP;
 		card->dev->netdev_ops = &qeth_l3_netdev_ops;
 		qeth_l3_iqd_read_initial_mac(card);
+		if (card->options.hsuid[0])
+			memcpy(card->dev->perm_addr, card->options.hsuid, 9);
 	} else
 		return -ENODEV;
 
@@ -3659,7 +3711,6 @@ static int qeth_l3_ip6_event(struct noti
 	struct qeth_ipaddr *addr;
 	struct qeth_card *card;
 
-
 	card = qeth_l3_get_card_from_dev(dev);
 	if (!card)
 		return NOTIFY_DONE;
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -9,7 +9,7 @@
  */
 
 #include <linux/slab.h>
-
+#include <asm/ebcdic.h>
 #include "qeth_l3.h"
 
 #define QETH_DEVICE_ATTR(_id, _name, _mode, _show, _store) \
@@ -308,6 +308,8 @@ static ssize_t qeth_l3_dev_sniffer_store
 
 	if (card->info.type != QETH_CARD_TYPE_IQD)
 		return -EPERM;
+	if (card->options.cq == QETH_CQ_ENABLED)
+		return -EPERM;
 
 	mutex_lock(&card->conf_mutex);
 	if ((card->state != CARD_STATE_DOWN) &&
@@ -347,6 +349,111 @@ out:
 static DEVICE_ATTR(sniffer, 0644, qeth_l3_dev_sniffer_show,
 		qeth_l3_dev_sniffer_store);
 
+
+static ssize_t qeth_l3_dev_hsuid_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	char tmp_hsuid[9];
+
+	if (!card)
+		return -EINVAL;
+
+	if (card->info.type != QETH_CARD_TYPE_IQD)
+		return -EPERM;
+
+	if (card->state == CARD_STATE_DOWN)
+		return -EPERM;
+
+	memcpy(tmp_hsuid, card->options.hsuid, sizeof(tmp_hsuid));
+	EBCASC(tmp_hsuid, 8);
+	return sprintf(buf, "%s\n", tmp_hsuid);
+}
+
+static ssize_t qeth_l3_dev_hsuid_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	struct qeth_ipaddr *addr;
+	char *tmp;
+	int i;
+
+	if (!card)
+		return -EINVAL;
+
+	if (card->info.type != QETH_CARD_TYPE_IQD)
+		return -EPERM;
+	if (card->state != CARD_STATE_DOWN &&
+	    card->state != CARD_STATE_RECOVER)
+		return -EPERM;
+	if (card->options.sniffer)
+		return -EPERM;
+	if (card->options.cq == QETH_CQ_NOTAVAILABLE)
+		return -EPERM;
+
+	tmp = strsep((char **)&buf, "\n");
+	if (strlen(tmp) > 8)
+		return -EINVAL;
+
+	if (card->options.hsuid[0]) {
+		/* delete old ip address */
+		addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV6);
+		if (addr != NULL) {
+			addr->u.a6.addr.s6_addr32[0] = 0xfe800000;
+			addr->u.a6.addr.s6_addr32[1] = 0x00000000;
+			for (i = 8; i < 16; i++)
+				addr->u.a6.addr.s6_addr[i] =
+					card->options.hsuid[i - 8];
+			addr->u.a6.pfxlen = 0;
+			addr->type = QETH_IP_TYPE_NORMAL;
+		} else
+			return -ENOMEM;
+		if (!qeth_l3_delete_ip(card, addr))
+			kfree(addr);
+		qeth_l3_set_ip_addr_list(card);
+	}
+
+	if (strlen(tmp) == 0) {
+		/* delete ip address only */
+		card->options.hsuid[0] = '\0';
+		if (card->dev)
+			memcpy(card->dev->perm_addr, card->options.hsuid, 9);
+		qeth_configure_cq(card, QETH_CQ_DISABLED);
+		return count;
+	}
+
+	if (qeth_configure_cq(card, QETH_CQ_ENABLED))
+		return -EPERM;
+
+	for (i = 0; i < 8; i++)
+		card->options.hsuid[i] = ' ';
+	card->options.hsuid[8] = '\0';
+	strncpy(card->options.hsuid, tmp, strlen(tmp));
+	ASCEBC(card->options.hsuid, 8);
+	if (card->dev)
+		memcpy(card->dev->perm_addr, card->options.hsuid, 9);
+
+	addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV6);
+	if (addr != NULL) {
+		addr->u.a6.addr.s6_addr32[0] = 0xfe800000;
+		addr->u.a6.addr.s6_addr32[1] = 0x00000000;
+		for (i = 8; i < 16; i++)
+			addr->u.a6.addr.s6_addr[i] = card->options.hsuid[i - 8];
+		addr->u.a6.pfxlen = 0;
+		addr->type = QETH_IP_TYPE_NORMAL;
+	} else
+		return -ENOMEM;
+	if (!qeth_l3_add_ip(card, addr))
+		kfree(addr);
+	qeth_l3_set_ip_addr_list(card);
+
+	return count;
+}
+
+static DEVICE_ATTR(hsuid, 0644, qeth_l3_dev_hsuid_show,
+		   qeth_l3_dev_hsuid_store);
+
+
 static struct attribute *qeth_l3_device_attrs[] = {
 	&dev_attr_route4.attr,
 	&dev_attr_route6.attr,
@@ -354,6 +461,7 @@ static struct attribute *qeth_l3_device_
 	&dev_attr_broadcast_mode.attr,
 	&dev_attr_canonical_macaddr.attr,
 	&dev_attr_sniffer.attr,
+	&dev_attr_hsuid.attr,
 	NULL,
 };
 

