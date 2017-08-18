From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/7] s390/qeth: split L2 xmit paths
Date: Fri, 18 Aug 2017 10:19:04 +0200
Message-ID: <20170818081910.48869-2-jwi@linux.vnet.ibm.com>
References: <20170818081910.48869-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:51745 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750810AbdHRITY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 04:19:24 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7I8J9mC064170
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 04:19:24 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2cdqg07tx4-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 04:19:23 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Fri, 18 Aug 2017 09:19:22 +0100
In-Reply-To: <20170818081910.48869-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2_hard_start_xmit() actually doesn't contain much shared code,
and having device-specific paths makes isolated changes a lot easier.
So split it into three routines for IQD, OSN and OSD/OSM/OSX.

No functional change.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 225 ++++++++++++++++++++++------------------
 1 file changed, 123 insertions(+), 102 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 438a7f29e99f..310bfa225e20 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -676,143 +676,164 @@ static void qeth_l2_set_rx_mode(struct net_device *dev)
 		qeth_promisc_to_bridge(card);
 }
 
-static netdev_tx_t qeth_l2_hard_start_xmit(struct sk_buff *skb,
-					   struct net_device *dev)
+static int qeth_l2_xmit_iqd(struct qeth_card *card, struct sk_buff *skb,
+			    struct qeth_qdio_out_q *queue, int cast_type)
 {
+	unsigned int data_offset = ETH_HLEN;
+	struct qeth_hdr *hdr;
 	int rc;
-	struct qeth_hdr *hdr = NULL;
-	int elements = 0;
-	struct qeth_card *card = dev->ml_priv;
-	struct sk_buff *new_skb = skb;
-	int cast_type = qeth_l2_get_cast_type(card, skb);
-	struct qeth_qdio_out_q *queue;
-	int tx_bytes = skb->len;
-	int data_offset = -1;
-	int elements_needed = 0;
-	int hd_len = 0;
-	unsigned int nr_frags;
 
-	if (card->qdio.do_prio_queueing || (cast_type &&
-					card->info.is_multicast_different))
-		queue = card->qdio.out_qs[qeth_get_priority_queue(card, skb,
-					qeth_get_ip_version(skb), cast_type)];
-	else
-		queue = card->qdio.out_qs[card->qdio.default_out_queue];
+	hdr = kmem_cache_alloc(qeth_core_header_cache, GFP_ATOMIC);
+	if (!hdr)
+		return -ENOMEM;
+	qeth_l2_fill_header(card, hdr, skb, cast_type);
+	hdr->hdr.l2.pkt_length = skb->len;
+	skb_copy_from_linear_data(skb, ((char *)hdr) + sizeof(*hdr),
+				  data_offset);
 
-	if ((card->state != CARD_STATE_UP) || !card->lan_online) {
-		card->stats.tx_carrier_errors++;
-		goto tx_drop;
+	if (!qeth_get_elements_no(card, skb, 1, data_offset)) {
+		rc = -E2BIG;
+		goto out;
 	}
+	rc = qeth_do_send_packet_fast(card, queue, skb, hdr, data_offset,
+				      data_offset);
+out:
+	if (rc)
+		kmem_cache_free(qeth_core_header_cache, hdr);
+	return rc;
+}
 
-	if ((card->info.type == QETH_CARD_TYPE_OSN) &&
-	    (skb->protocol == htons(ETH_P_IPV6)))
-		goto tx_drop;
-
-	if (card->options.performance_stats) {
-		card->perf_stats.outbound_cnt++;
-		card->perf_stats.outbound_start_time = qeth_get_micros();
-	}
-	netif_stop_queue(dev);
+static int qeth_l2_xmit_osa(struct qeth_card *card, struct sk_buff *skb,
+			    struct qeth_qdio_out_q *queue, int cast_type)
+{
+	unsigned int elements, nr_frags;
+	struct sk_buff *skb_copy;
+	struct qeth_hdr *hdr;
+	int rc;
 
 	/* fix hardware limitation: as long as we do not have sbal
 	 * chaining we can not send long frag lists
 	 */
-	if ((card->info.type != QETH_CARD_TYPE_IQD) &&
-	    !qeth_get_elements_no(card, new_skb, 0, 0)) {
-		int lin_rc = skb_linearize(new_skb);
+	if (!qeth_get_elements_no(card, skb, 0, 0)) {
+		rc = skb_linearize(skb);
 
 		if (card->options.performance_stats) {
-			if (lin_rc)
+			if (rc)
 				card->perf_stats.tx_linfail++;
 			else
 				card->perf_stats.tx_lin++;
 		}
-		if (lin_rc)
-			goto tx_drop;
+		if (rc)
+			return rc;
 	}
-	nr_frags = skb_shinfo(new_skb)->nr_frags;
+	nr_frags = skb_shinfo(skb)->nr_frags;
 
-	if (card->info.type == QETH_CARD_TYPE_OSN)
-		hdr = (struct qeth_hdr *)skb->data;
-	else {
-		if (card->info.type == QETH_CARD_TYPE_IQD) {
-			new_skb = skb;
-			data_offset = ETH_HLEN;
-			hd_len = ETH_HLEN;
-			hdr = kmem_cache_alloc(qeth_core_header_cache,
-						GFP_ATOMIC);
-			if (!hdr)
-				goto tx_drop;
-			elements_needed++;
-			qeth_l2_fill_header(card, hdr, new_skb, cast_type);
-			hdr->hdr.l2.pkt_length = new_skb->len;
-			skb_copy_from_linear_data(new_skb,
-						  ((char *)hdr) + sizeof(*hdr),
-						  ETH_HLEN);
-		} else {
-			/* create a clone with writeable headroom */
-			new_skb = skb_realloc_headroom(skb,
-						sizeof(struct qeth_hdr));
-			if (!new_skb)
-				goto tx_drop;
-			hdr = skb_push(new_skb, sizeof(struct qeth_hdr));
-			qeth_l2_fill_header(card, hdr, new_skb, cast_type);
-			if (new_skb->ip_summed == CHECKSUM_PARTIAL)
-				qeth_l2_hdr_csum(card, hdr, new_skb);
-		}
-	}
+	/* create a copy with writeable headroom */
+	skb_copy = skb_realloc_headroom(skb, sizeof(struct qeth_hdr));
+	if (!skb_copy)
+		return -ENOMEM;
+	hdr = skb_push(skb_copy, sizeof(struct qeth_hdr));
+	qeth_l2_fill_header(card, hdr, skb_copy, cast_type);
+	if (skb_copy->ip_summed == CHECKSUM_PARTIAL)
+		qeth_l2_hdr_csum(card, hdr, skb_copy);
 
-	elements = qeth_get_elements_no(card, new_skb, elements_needed,
-					(data_offset > 0) ? data_offset : 0);
+	elements = qeth_get_elements_no(card, skb_copy, 0, 0);
 	if (!elements) {
-		if (data_offset >= 0)
-			kmem_cache_free(qeth_core_header_cache, hdr);
-		goto tx_drop;
+		rc = -E2BIG;
+		goto out;
 	}
-
-	if (card->info.type != QETH_CARD_TYPE_IQD) {
-		if (qeth_hdr_chk_and_bounce(new_skb, &hdr,
-		    sizeof(struct qeth_hdr_layer2)))
-			goto tx_drop;
-		rc = qeth_do_send_packet(card, queue, new_skb, hdr,
-					 elements);
-	} else
-		rc = qeth_do_send_packet_fast(card, queue, new_skb, hdr,
-					      data_offset, hd_len);
+	if (qeth_hdr_chk_and_bounce(skb_copy, &hdr, sizeof(*hdr))) {
+		rc = -EINVAL;
+		goto out;
+	}
+	rc = qeth_do_send_packet(card, queue, skb_copy, hdr, elements);
+out:
 	if (!rc) {
-		card->stats.tx_packets++;
-		card->stats.tx_bytes += tx_bytes;
+		/* tx success, free dangling original */
+		dev_kfree_skb_any(skb);
 		if (card->options.performance_stats && nr_frags) {
 			card->perf_stats.sg_skbs_sent++;
 			/* nr_frags + skb->data */
 			card->perf_stats.sg_frags_sent += nr_frags + 1;
 		}
-		if (new_skb != skb)
-			dev_kfree_skb_any(skb);
-		rc = NETDEV_TX_OK;
 	} else {
-		if (data_offset >= 0)
-			kmem_cache_free(qeth_core_header_cache, hdr);
+		/* tx fail, free copy */
+		dev_kfree_skb_any(skb_copy);
+	}
+	return rc;
+}
 
-		if (rc == -EBUSY) {
-			if (new_skb != skb)
-				dev_kfree_skb_any(new_skb);
-			return NETDEV_TX_BUSY;
-		} else
-			goto tx_drop;
+static int qeth_l2_xmit_osn(struct qeth_card *card, struct sk_buff *skb,
+			    struct qeth_qdio_out_q *queue)
+{
+	unsigned int elements;
+	struct qeth_hdr *hdr;
+
+	if (skb->protocol == htons(ETH_P_IPV6))
+		return -EPROTONOSUPPORT;
+
+	hdr = (struct qeth_hdr *)skb->data;
+	elements = qeth_get_elements_no(card, skb, 0, 0);
+	if (!elements)
+		return -E2BIG;
+	if (qeth_hdr_chk_and_bounce(skb, &hdr, sizeof(*hdr)))
+		return -EINVAL;
+	return qeth_do_send_packet(card, queue, skb, hdr, elements);
+}
+
+static netdev_tx_t qeth_l2_hard_start_xmit(struct sk_buff *skb,
+					   struct net_device *dev)
+{
+	struct qeth_card *card = dev->ml_priv;
+	int cast_type = qeth_l2_get_cast_type(card, skb);
+	struct qeth_qdio_out_q *queue;
+	int tx_bytes = skb->len;
+	int rc;
+
+	if (card->qdio.do_prio_queueing || (cast_type &&
+					card->info.is_multicast_different))
+		queue = card->qdio.out_qs[qeth_get_priority_queue(card, skb,
+					qeth_get_ip_version(skb), cast_type)];
+	else
+		queue = card->qdio.out_qs[card->qdio.default_out_queue];
+
+	if ((card->state != CARD_STATE_UP) || !card->lan_online) {
+		card->stats.tx_carrier_errors++;
+		goto tx_drop;
 	}
 
-	netif_wake_queue(dev);
-	if (card->options.performance_stats)
-		card->perf_stats.outbound_time += qeth_get_micros() -
-			card->perf_stats.outbound_start_time;
-	return rc;
+	if (card->options.performance_stats) {
+		card->perf_stats.outbound_cnt++;
+		card->perf_stats.outbound_start_time = qeth_get_micros();
+	}
+	netif_stop_queue(dev);
+
+	switch (card->info.type) {
+	case QETH_CARD_TYPE_OSN:
+		rc = qeth_l2_xmit_osn(card, skb, queue);
+		break;
+	case QETH_CARD_TYPE_IQD:
+		rc = qeth_l2_xmit_iqd(card, skb, queue, cast_type);
+		break;
+	default:
+		rc = qeth_l2_xmit_osa(card, skb, queue, cast_type);
+	}
+
+	if (!rc) {
+		card->stats.tx_packets++;
+		card->stats.tx_bytes += tx_bytes;
+		if (card->options.performance_stats)
+			card->perf_stats.outbound_time += qeth_get_micros() -
+				card->perf_stats.outbound_start_time;
+		netif_wake_queue(dev);
+		return NETDEV_TX_OK;
+	} else if (rc == -EBUSY) {
+		return NETDEV_TX_BUSY;
+	} /* else fall through */
 
 tx_drop:
 	card->stats.tx_dropped++;
 	card->stats.tx_errors++;
-	if ((new_skb != skb) && new_skb)
-		dev_kfree_skb_any(new_skb);
 	dev_kfree_skb_any(skb);
 	netif_wake_queue(dev);
 	return NETDEV_TX_OK;
-- 
2.11.2
