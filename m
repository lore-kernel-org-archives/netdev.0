From: frank.blaschka@de.ibm.com
Subject: [patch 6/6] [PATCH] qeth: Remove BUG_ONs
Date: Mon, 19 Nov 2012 13:46:50 +0100
Message-ID: <20121119124659.930385554@de.ibm.com>
References: <20121119124644.679089322@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:42093 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859Ab2KSMrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 07:47:05 -0500
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 19 Nov 2012 12:47:03 -0000
Content-Disposition: inline; filename=607-qeth-bug-on.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

Remove BUG_ONs or convert to WARN_ON_ONCE/WARN_ONs since a failure within a
networking device driver is no reason to shut down the entire machine.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_core_main.c |   14 ++++++--------
 drivers/s390/net/qeth_l2_main.c   |    3 +--
 drivers/s390/net/qeth_l3_main.c   |    7 +++----
 3 files changed, 10 insertions(+), 14 deletions(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -383,7 +383,7 @@ static inline void qeth_cleanup_handled_
 				qeth_release_skbs(c);
 
 				c = f->next_pending;
-				BUG_ON(head->next_pending != f);
+				WARN_ON_ONCE(head->next_pending != f);
 				head->next_pending = c;
 				kmem_cache_free(qeth_qdio_outbuf_cache, f);
 			} else {
@@ -415,13 +415,12 @@ static inline void qeth_qdio_handle_aob(
 	buffer = (struct qeth_qdio_out_buffer *) aob->user1;
 	QETH_CARD_TEXT_(card, 5, "%lx", aob->user1);
 
-	BUG_ON(buffer == NULL);
-
 	if (atomic_cmpxchg(&buffer->state, QETH_QDIO_BUF_PRIMED,
 			   QETH_QDIO_BUF_IN_CQ) == QETH_QDIO_BUF_PRIMED) {
 		notification = TX_NOTIFY_OK;
 	} else {
-		BUG_ON(atomic_read(&buffer->state) != QETH_QDIO_BUF_PENDING);
+		WARN_ON_ONCE(atomic_read(&buffer->state) !=
+							QETH_QDIO_BUF_PENDING);
 		atomic_set(&buffer->state, QETH_QDIO_BUF_IN_CQ);
 		notification = TX_NOTIFY_DELAYED_OK;
 	}
@@ -1131,7 +1130,7 @@ static void qeth_release_skbs(struct qet
 		notify_general_error = 1;
 
 	/* release may never happen from within CQ tasklet scope */
-	BUG_ON(atomic_read(&buf->state) == QETH_QDIO_BUF_IN_CQ);
+	WARN_ON_ONCE(atomic_read(&buf->state) == QETH_QDIO_BUF_IN_CQ);
 
 	skb = skb_dequeue(&buf->skb_list);
 	while (skb) {
@@ -2400,7 +2399,7 @@ static int qeth_alloc_qdio_buffers(struc
 		card->qdio.out_qs[i]->queue_no = i;
 		/* give outbound qeth_qdio_buffers their qdio_buffers */
 		for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j) {
-			BUG_ON(card->qdio.out_qs[i]->bufs[j] != NULL);
+			WARN_ON(card->qdio.out_qs[i]->bufs[j] != NULL);
 			if (qeth_init_qdio_out_buf(card->qdio.out_qs[i], j))
 				goto out_freeoutqbufs;
 		}
@@ -3565,7 +3564,7 @@ void qeth_qdio_output_handler(struct ccw
 		if (queue->bufstates &&
 		    (queue->bufstates[bidx].flags &
 		     QDIO_OUTBUF_STATE_FLAG_PENDING) != 0) {
-			BUG_ON(card->options.cq != QETH_CQ_ENABLED);
+			WARN_ON_ONCE(card->options.cq != QETH_CQ_ENABLED);
 
 			if (atomic_cmpxchg(&buffer->state,
 					   QETH_QDIO_BUF_PRIMED,
@@ -3579,7 +3578,6 @@ void qeth_qdio_output_handler(struct ccw
 			QETH_CARD_TEXT(queue->card, 5, "aob");
 			QETH_CARD_TEXT_(queue->card, 5, "%lx",
 					virt_to_phys(buffer->aob));
-			BUG_ON(bidx < 0 || bidx >= QDIO_MAX_BUFFERS_PER_Q);
 			if (qeth_init_qdio_out_buf(queue, bidx)) {
 				QETH_CARD_TEXT(card, 2, "outofbuf");
 				qeth_schedule_recovery(card);
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -411,7 +411,7 @@ static int qeth_l2_process_inbound_buffe
 	unsigned int len;
 
 	*done = 0;
-	BUG_ON(!budget);
+	WARN_ON_ONCE(!budget);
 	while (budget) {
 		skb = qeth_core_get_next_skb(card,
 			&card->qdio.in_q->bufs[card->rx.b_index],
@@ -973,7 +973,6 @@ static int __qeth_l2_set_online(struct c
 	int rc = 0;
 	enum qeth_card_states recover_flag;
 
-	BUG_ON(!card);
 	mutex_lock(&card->discipline_mutex);
 	mutex_lock(&card->conf_mutex);
 	QETH_DBF_TEXT(SETUP, 2, "setonlin");
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1939,7 +1939,7 @@ static int qeth_l3_process_inbound_buffe
 	__u16 magic;
 
 	*done = 0;
-	BUG_ON(!budget);
+	WARN_ON_ONCE(!budget);
 	while (budget) {
 		skb = qeth_core_get_next_skb(card,
 			&card->qdio.in_q->bufs[card->rx.b_index],
@@ -3334,7 +3334,6 @@ static int __qeth_l3_set_online(struct c
 	int rc = 0;
 	enum qeth_card_states recover_flag;
 
-	BUG_ON(!card);
 	mutex_lock(&card->discipline_mutex);
 	mutex_lock(&card->conf_mutex);
 	QETH_DBF_TEXT(SETUP, 2, "setonlin");
@@ -3715,9 +3714,9 @@ static void qeth_l3_unregister_notifiers
 {
 
 	QETH_DBF_TEXT(SETUP, 5, "unregnot");
-	BUG_ON(unregister_inetaddr_notifier(&qeth_l3_ip_notifier));
+	WARN_ON(unregister_inetaddr_notifier(&qeth_l3_ip_notifier));
 #ifdef CONFIG_QETH_IPV6
-	BUG_ON(unregister_inet6addr_notifier(&qeth_l3_ip6_notifier));
+	WARN_ON(unregister_inet6addr_notifier(&qeth_l3_ip6_notifier));
 #endif /* QETH_IPV6 */
 }
 
