From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 02/10] s390/qeth: move NAPI poll routine to core
Date: Tue, 11 Apr 2017 16:11:11 +0200
Message-ID: <20170411141119.82526-3-jwi@linux.vnet.ibm.com>
References: <20170411141119.82526-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:53397 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753233AbdDKOLj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:11:39 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3BE8vVq146954
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 10:11:38 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29rf064mhn-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 10:11:38 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 11 Apr 2017 15:11:35 +0100
In-Reply-To: <20170411141119.82526-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Identical code, we just need to call a layer-specific hook
to process any received buffer.

qeth_buffer_reclaim_work() is shuffled around to avoid a
forward declaration for qeth_queue_input_buffer().

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Acked-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |   5 +-
 drivers/s390/net/qeth_core_main.c | 105 +++++++++++++++++++++++++++++++++-----
 drivers/s390/net/qeth_l2_main.c   |  78 +---------------------------
 drivers/s390/net/qeth_l3_main.c   |  78 +---------------------------
 4 files changed, 97 insertions(+), 169 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index ee4d43f0c149..196356e11077 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -705,6 +705,7 @@ struct qeth_discipline {
 	void (*start_poll)(struct ccw_device *, int, unsigned long);
 	qdio_handler_t *input_handler;
 	qdio_handler_t *output_handler;
+	int (*process_rx_buffer)(struct qeth_card *card, int budget, int *done);
 	int (*recover)(void *ptr);
 	int (*setup) (struct ccwgroup_device *);
 	void (*remove) (struct ccwgroup_device *);
@@ -909,14 +910,12 @@ int qeth_send_ipa_cmd(struct qeth_card *, struct qeth_cmd_buffer *,
 struct qeth_cmd_buffer *qeth_get_ipacmd_buffer(struct qeth_card *,
 			enum qeth_ipa_cmds, enum qeth_prot_versions);
 int qeth_query_setadapterparms(struct qeth_card *);
-int qeth_check_qdio_errors(struct qeth_card *, struct qdio_buffer *,
-		unsigned int, const char *);
-void qeth_queue_input_buffer(struct qeth_card *, int);
 struct sk_buff *qeth_core_get_next_skb(struct qeth_card *,
 		struct qeth_qdio_buffer *, struct qdio_buffer_element **, int *,
 		struct qeth_hdr **);
 void qeth_schedule_recovery(struct qeth_card *);
 void qeth_qdio_start_poll(struct ccw_device *, int, unsigned long);
+int qeth_poll(struct napi_struct *napi, int budget);
 void qeth_qdio_input_handler(struct ccw_device *,
 		unsigned int, unsigned int, int,
 		int, unsigned long);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index c9fdf98e5e15..b9063eb17436 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3216,8 +3216,10 @@ int qeth_hw_trap(struct qeth_card *card, enum qeth_diags_trap_action action)
 }
 EXPORT_SYMBOL_GPL(qeth_hw_trap);
 
-int qeth_check_qdio_errors(struct qeth_card *card, struct qdio_buffer *buf,
-		unsigned int qdio_error, const char *dbftext)
+static int qeth_check_qdio_errors(struct qeth_card *card,
+				  struct qdio_buffer *buf,
+				  unsigned int qdio_error,
+				  const char *dbftext)
 {
 	if (qdio_error) {
 		QETH_CARD_TEXT(card, 2, dbftext);
@@ -3234,18 +3236,8 @@ int qeth_check_qdio_errors(struct qeth_card *card, struct qdio_buffer *buf,
 	}
 	return 0;
 }
-EXPORT_SYMBOL_GPL(qeth_check_qdio_errors);
 
-static void qeth_buffer_reclaim_work(struct work_struct *work)
-{
-	struct qeth_card *card = container_of(work, struct qeth_card,
-		buffer_reclaim_work.work);
-
-	QETH_CARD_TEXT_(card, 2, "brw:%x", card->reclaim_index);
-	qeth_queue_input_buffer(card, card->reclaim_index);
-}
-
-void qeth_queue_input_buffer(struct qeth_card *card, int index)
+static void qeth_queue_input_buffer(struct qeth_card *card, int index)
 {
 	struct qeth_qdio_q *queue = card->qdio.in_q;
 	struct list_head *lh;
@@ -3319,7 +3311,15 @@ void qeth_queue_input_buffer(struct qeth_card *card, int index)
 					  QDIO_MAX_BUFFERS_PER_Q;
 	}
 }
-EXPORT_SYMBOL_GPL(qeth_queue_input_buffer);
+
+static void qeth_buffer_reclaim_work(struct work_struct *work)
+{
+	struct qeth_card *card = container_of(work, struct qeth_card,
+		buffer_reclaim_work.work);
+
+	QETH_CARD_TEXT_(card, 2, "brw:%x", card->reclaim_index);
+	qeth_queue_input_buffer(card, card->reclaim_index);
+}
 
 static void qeth_handle_send_error(struct qeth_card *card,
 		struct qeth_qdio_out_buffer *buffer, unsigned int qdio_err)
@@ -5282,6 +5282,83 @@ struct sk_buff *qeth_core_get_next_skb(struct qeth_card *card,
 }
 EXPORT_SYMBOL_GPL(qeth_core_get_next_skb);
 
+int qeth_poll(struct napi_struct *napi, int budget)
+{
+	struct qeth_card *card = container_of(napi, struct qeth_card, napi);
+	int work_done = 0;
+	struct qeth_qdio_buffer *buffer;
+	int done;
+	int new_budget = budget;
+
+	if (card->options.performance_stats) {
+		card->perf_stats.inbound_cnt++;
+		card->perf_stats.inbound_start_time = qeth_get_micros();
+	}
+
+	while (1) {
+		if (!card->rx.b_count) {
+			card->rx.qdio_err = 0;
+			card->rx.b_count = qdio_get_next_buffers(
+				card->data.ccwdev, 0, &card->rx.b_index,
+				&card->rx.qdio_err);
+			if (card->rx.b_count <= 0) {
+				card->rx.b_count = 0;
+				break;
+			}
+			card->rx.b_element =
+				&card->qdio.in_q->bufs[card->rx.b_index]
+				.buffer->element[0];
+			card->rx.e_offset = 0;
+		}
+
+		while (card->rx.b_count) {
+			buffer = &card->qdio.in_q->bufs[card->rx.b_index];
+			if (!(card->rx.qdio_err &&
+			    qeth_check_qdio_errors(card, buffer->buffer,
+			    card->rx.qdio_err, "qinerr")))
+				work_done +=
+					card->discipline->process_rx_buffer(
+						card, new_budget, &done);
+			else
+				done = 1;
+
+			if (done) {
+				if (card->options.performance_stats)
+					card->perf_stats.bufs_rec++;
+				qeth_put_buffer_pool_entry(card,
+					buffer->pool_entry);
+				qeth_queue_input_buffer(card, card->rx.b_index);
+				card->rx.b_count--;
+				if (card->rx.b_count) {
+					card->rx.b_index =
+						(card->rx.b_index + 1) %
+						QDIO_MAX_BUFFERS_PER_Q;
+					card->rx.b_element =
+						&card->qdio.in_q
+						->bufs[card->rx.b_index]
+						.buffer->element[0];
+					card->rx.e_offset = 0;
+				}
+			}
+
+			if (work_done >= budget)
+				goto out;
+			else
+				new_budget = budget - work_done;
+		}
+	}
+
+	napi_complete(napi);
+	if (qdio_start_irq(card->data.ccwdev, 0))
+		napi_schedule(&card->napi);
+out:
+	if (card->options.performance_stats)
+		card->perf_stats.inbound_time += qeth_get_micros() -
+			card->perf_stats.inbound_start_time;
+	return work_done;
+}
+EXPORT_SYMBOL_GPL(qeth_poll);
+
 int qeth_setassparms_cb(struct qeth_card *card,
 			struct qeth_reply *reply, unsigned long data)
 {
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 30232076d867..572347d65c1d 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -500,81 +500,6 @@ static int qeth_l2_process_inbound_buffer(struct qeth_card *card,
 	return work_done;
 }
 
-static int qeth_l2_poll(struct napi_struct *napi, int budget)
-{
-	struct qeth_card *card = container_of(napi, struct qeth_card, napi);
-	int work_done = 0;
-	struct qeth_qdio_buffer *buffer;
-	int done;
-	int new_budget = budget;
-
-	if (card->options.performance_stats) {
-		card->perf_stats.inbound_cnt++;
-		card->perf_stats.inbound_start_time = qeth_get_micros();
-	}
-
-	while (1) {
-		if (!card->rx.b_count) {
-			card->rx.qdio_err = 0;
-			card->rx.b_count = qdio_get_next_buffers(
-				card->data.ccwdev, 0, &card->rx.b_index,
-				&card->rx.qdio_err);
-			if (card->rx.b_count <= 0) {
-				card->rx.b_count = 0;
-				break;
-			}
-			card->rx.b_element =
-				&card->qdio.in_q->bufs[card->rx.b_index]
-				.buffer->element[0];
-			card->rx.e_offset = 0;
-		}
-
-		while (card->rx.b_count) {
-			buffer = &card->qdio.in_q->bufs[card->rx.b_index];
-			if (!(card->rx.qdio_err &&
-			    qeth_check_qdio_errors(card, buffer->buffer,
-			    card->rx.qdio_err, "qinerr")))
-				work_done += qeth_l2_process_inbound_buffer(
-					card, new_budget, &done);
-			else
-				done = 1;
-
-			if (done) {
-				if (card->options.performance_stats)
-					card->perf_stats.bufs_rec++;
-				qeth_put_buffer_pool_entry(card,
-					buffer->pool_entry);
-				qeth_queue_input_buffer(card, card->rx.b_index);
-				card->rx.b_count--;
-				if (card->rx.b_count) {
-					card->rx.b_index =
-						(card->rx.b_index + 1) %
-						QDIO_MAX_BUFFERS_PER_Q;
-					card->rx.b_element =
-						&card->qdio.in_q
-						->bufs[card->rx.b_index]
-						.buffer->element[0];
-					card->rx.e_offset = 0;
-				}
-			}
-
-			if (work_done >= budget)
-				goto out;
-			else
-				new_budget = budget - work_done;
-		}
-	}
-
-	napi_complete(napi);
-	if (qdio_start_irq(card->data.ccwdev, 0))
-		napi_schedule(&card->napi);
-out:
-	if (card->options.performance_stats)
-		card->perf_stats.inbound_time += qeth_get_micros() -
-			card->perf_stats.inbound_start_time;
-	return work_done;
-}
-
 static int qeth_l2_request_initial_mac(struct qeth_card *card)
 {
 	int rc = 0;
@@ -1065,7 +990,7 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 	card->dev->gso_max_size = (QETH_MAX_BUFFER_ELEMENTS(card) - 1) *
 				  PAGE_SIZE;
 	SET_NETDEV_DEV(card->dev, &card->gdev->dev);
-	netif_napi_add(card->dev, &card->napi, qeth_l2_poll, QETH_NAPI_WEIGHT);
+	netif_napi_add(card->dev, &card->napi, qeth_poll, QETH_NAPI_WEIGHT);
 	netif_carrier_off(card->dev);
 	return register_netdev(card->dev);
 }
@@ -1357,6 +1282,7 @@ struct qeth_discipline qeth_l2_discipline = {
 	.start_poll = qeth_qdio_start_poll,
 	.input_handler = (qdio_handler_t *) qeth_qdio_input_handler,
 	.output_handler = (qdio_handler_t *) qeth_qdio_output_handler,
+	.process_rx_buffer = qeth_l2_process_inbound_buffer,
 	.recover = qeth_l2_recover,
 	.setup = qeth_l2_probe_device,
 	.remove = qeth_l2_remove_device,
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 25b6823af1b2..bd6ad9be9245 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1829,81 +1829,6 @@ static int qeth_l3_process_inbound_buffer(struct qeth_card *card,
 	return work_done;
 }
 
-static int qeth_l3_poll(struct napi_struct *napi, int budget)
-{
-	struct qeth_card *card = container_of(napi, struct qeth_card, napi);
-	int work_done = 0;
-	struct qeth_qdio_buffer *buffer;
-	int done;
-	int new_budget = budget;
-
-	if (card->options.performance_stats) {
-		card->perf_stats.inbound_cnt++;
-		card->perf_stats.inbound_start_time = qeth_get_micros();
-	}
-
-	while (1) {
-		if (!card->rx.b_count) {
-			card->rx.qdio_err = 0;
-			card->rx.b_count = qdio_get_next_buffers(
-				card->data.ccwdev, 0, &card->rx.b_index,
-				&card->rx.qdio_err);
-			if (card->rx.b_count <= 0) {
-				card->rx.b_count = 0;
-				break;
-			}
-			card->rx.b_element =
-				&card->qdio.in_q->bufs[card->rx.b_index]
-				.buffer->element[0];
-			card->rx.e_offset = 0;
-		}
-
-		while (card->rx.b_count) {
-			buffer = &card->qdio.in_q->bufs[card->rx.b_index];
-			if (!(card->rx.qdio_err &&
-			    qeth_check_qdio_errors(card, buffer->buffer,
-			    card->rx.qdio_err, "qinerr")))
-				work_done += qeth_l3_process_inbound_buffer(
-					card, new_budget, &done);
-			else
-				done = 1;
-
-			if (done) {
-				if (card->options.performance_stats)
-					card->perf_stats.bufs_rec++;
-				qeth_put_buffer_pool_entry(card,
-					buffer->pool_entry);
-				qeth_queue_input_buffer(card, card->rx.b_index);
-				card->rx.b_count--;
-				if (card->rx.b_count) {
-					card->rx.b_index =
-						(card->rx.b_index + 1) %
-						QDIO_MAX_BUFFERS_PER_Q;
-					card->rx.b_element =
-						&card->qdio.in_q
-						->bufs[card->rx.b_index]
-						.buffer->element[0];
-					card->rx.e_offset = 0;
-				}
-			}
-
-			if (work_done >= budget)
-				goto out;
-			else
-				new_budget = budget - work_done;
-		}
-	}
-
-	napi_complete(napi);
-	if (qdio_start_irq(card->data.ccwdev, 0))
-		napi_schedule(&card->napi);
-out:
-	if (card->options.performance_stats)
-		card->perf_stats.inbound_time += qeth_get_micros() -
-			card->perf_stats.inbound_start_time;
-	return work_done;
-}
-
 static int qeth_l3_verify_vlan_dev(struct net_device *dev,
 			struct qeth_card *card)
 {
@@ -3105,7 +3030,7 @@ static int qeth_l3_setup_netdev(struct qeth_card *card)
 				  PAGE_SIZE;
 
 	SET_NETDEV_DEV(card->dev, &card->gdev->dev);
-	netif_napi_add(card->dev, &card->napi, qeth_l3_poll, QETH_NAPI_WEIGHT);
+	netif_napi_add(card->dev, &card->napi, qeth_poll, QETH_NAPI_WEIGHT);
 	netif_carrier_off(card->dev);
 	return register_netdev(card->dev);
 }
@@ -3394,6 +3319,7 @@ struct qeth_discipline qeth_l3_discipline = {
 	.start_poll = qeth_qdio_start_poll,
 	.input_handler = (qdio_handler_t *) qeth_qdio_input_handler,
 	.output_handler = (qdio_handler_t *) qeth_qdio_output_handler,
+	.process_rx_buffer = qeth_l3_process_inbound_buffer,
 	.recover = qeth_l3_recover,
 	.setup = qeth_l3_probe_device,
 	.remove = qeth_l3_remove_device,
-- 
2.10.2
