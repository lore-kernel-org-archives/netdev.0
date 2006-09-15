From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 6/9] s390: qeth driver fixes [3/6]
Date: Fri, 15 Sep 2006 16:26:19 +0200
Message-ID: <20060915142619.GF10043@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:45869 "EHLO
	mtagate1.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751554AbWIOOhS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Sep 2006 10:37:18 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id k8FEbHlf160086
	for <netdev@vger.kernel.org>; Fri, 15 Sep 2006 14:37:17 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8FEdSem1020010
	for <netdev@vger.kernel.org>; Fri, 15 Sep 2006 15:39:28 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8FEbGo0022966
	for <netdev@vger.kernel.org>; Fri, 15 Sep 2006 15:37:16 +0100
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 6/9] s390: qeth driver fixes [3/6]

From: Frank Pavlic <fpavlic@de.ibm.com>
       	fixed kernel panic caused by qeth driver:
        Using a bonding device qeth driver will realloc
        headroom for every skb coming from the bond device.
        Once this happens qeth frees the original skb and
        set the skb pointer to the new realloced skb.
        Under heavy transmit workload (e.g.UDP streams) through bond
        network device the qdio output queue might get full.
        In this case we return with EBUSY from qeth_send_packet.
        Returning to qeth_hard_start_xmit routine
        the skb address on the stack still points to the old address,
        which has been freed before.
        Returning from qeth_hard_start_xmit with EBUSY results in
        requeuing the skb. In this case it corrupts the qdisc queue
        and results in kernel panic.

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 drivers/s390/net/qeth.h      |   33 +++----
 drivers/s390/net/qeth_main.c |  193 ++++++++++++++++++++++--------------------
 drivers/s390/net/qeth_tso.h  |    2 
 3 files changed, 113 insertions(+), 115 deletions(-)

80a8bd094c70579c027f15838501759ab8f3331d
diff --git a/drivers/s390/net/qeth.h b/drivers/s390/net/qeth.h
index e8bd8c5..c04ee91 100644
--- a/drivers/s390/net/qeth.h
+++ b/drivers/s390/net/qeth.h
@@ -859,23 +859,18 @@ qeth_get_ipa_adp_type(enum qeth_link_typ
 	}
 }
 
-static inline int
-qeth_realloc_headroom(struct qeth_card *card, struct sk_buff **skb, int size)
+static inline struct sk_buff *
+qeth_realloc_headroom(struct qeth_card *card, struct sk_buff *skb, int size)
 {
-	struct sk_buff *new_skb = NULL;
+	struct sk_buff *new_skb = skb;
 
-	if (skb_headroom(*skb) < size){
-		new_skb = skb_realloc_headroom(*skb, size);
-		if (!new_skb) {
-                        PRINT_ERR("qeth_prepare_skb: could "
-                                  "not realloc headroom for qeth_hdr "
-                                  "on interface %s", QETH_CARD_IFNAME(card));
-                        return -ENOMEM;
-                }
-		kfree_skb(*skb);
-                *skb = new_skb;
-	}
-	return 0;
+	if (skb_headroom(skb) >= size)
+		return skb;
+	new_skb = skb_realloc_headroom(skb, size);
+	if (!new_skb) 
+		PRINT_ERR("Could not realloc headroom for qeth_hdr "
+			  "on interface %s", QETH_CARD_IFNAME(card));
+	return new_skb;
 }
 
 static inline struct sk_buff *
@@ -885,16 +880,15 @@ qeth_pskb_unshare(struct sk_buff *skb, i
         if (!skb_cloned(skb))
                 return skb;
         nskb = skb_copy(skb, pri);
-        kfree_skb(skb); /* free our shared copy */
         return nskb;
 }
 
 static inline void *
-qeth_push_skb(struct qeth_card *card, struct sk_buff **skb, int size)
+qeth_push_skb(struct qeth_card *card, struct sk_buff *skb, int size)
 {
         void *hdr;
 
-	hdr = (void *) skb_push(*skb, size);
+	hdr = (void *) skb_push(skb, size);
         /*
          * sanity check, the Linux memory allocation scheme should
          * never present us cases like this one (the qdio header size plus
@@ -903,8 +897,7 @@ qeth_push_skb(struct qeth_card *card, st
         if ((((unsigned long) hdr) & (~(PAGE_SIZE - 1))) !=
             (((unsigned long) hdr + size +
               QETH_IP_HEADER_SIZE) & (~(PAGE_SIZE - 1)))) {
-                PRINT_ERR("qeth_prepare_skb: misaligned "
-                          "packet on interface %s. Discarded.",
+                PRINT_ERR("Misaligned packet on interface %s. Discarded.",
                           QETH_CARD_IFNAME(card));
                 return NULL;
         }
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index ffff7a1..522fb9d 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -3919,49 +3919,59 @@ qeth_get_ip_version(struct sk_buff *skb)
 	}
 }
 
-static inline int
-qeth_prepare_skb(struct qeth_card *card, struct sk_buff **skb,
-		 struct qeth_hdr **hdr, int ipv)
+static inline struct qeth_hdr *
+__qeth_prepare_skb(struct qeth_card *card, struct sk_buff *skb, int ipv)
 {
-	int rc = 0;
 #ifdef CONFIG_QETH_VLAN
 	u16 *tag;
-#endif
-
-	QETH_DBF_TEXT(trace, 6, "prepskb");
-	if (card->info.type == QETH_CARD_TYPE_OSN) {
-		*hdr = (struct qeth_hdr *)(*skb)->data;
-		return rc;
-	}
-        rc = qeth_realloc_headroom(card, skb, sizeof(struct qeth_hdr));
-        if (rc)
-                return rc;
-#ifdef CONFIG_QETH_VLAN
-	if (card->vlangrp && vlan_tx_tag_present(*skb) &&
+	if (card->vlangrp && vlan_tx_tag_present(skb) &&
 	    ((ipv == 6) || card->options.layer2) ) {
 		/*
 		 * Move the mac addresses (6 bytes src, 6 bytes dest)
 		 * to the beginning of the new header.  We are using three
 		 * memcpys instead of one memmove to save cycles.
 		 */
-		skb_push(*skb, VLAN_HLEN);
-		memcpy((*skb)->data, (*skb)->data + 4, 4);
-		memcpy((*skb)->data + 4, (*skb)->data + 8, 4);
-		memcpy((*skb)->data + 8, (*skb)->data + 12, 4);
-		tag = (u16 *)((*skb)->data + 12);
+		skb_push(skb, VLAN_HLEN);
+		memcpy(skb->data, skb->data + 4, 4);
+		memcpy(skb->data + 4, skb->data + 8, 4);
+		memcpy(skb->data + 8, skb->data + 12, 4);
+		tag = (u16 *)(skb->data + 12);
 		/*
 		 * first two bytes  = ETH_P_8021Q (0x8100)
 		 * second two bytes = VLANID
 		 */
 		*tag = __constant_htons(ETH_P_8021Q);
-		*(tag + 1) = htons(vlan_tx_tag_get(*skb));
+		*(tag + 1) = htons(vlan_tx_tag_get(skb));
 	}
 #endif
-	*hdr = (struct qeth_hdr *)
-		qeth_push_skb(card, skb, sizeof(struct qeth_hdr));
-	if (*hdr == NULL)
-		return -EINVAL;
-	return 0;
+	return ((struct qeth_hdr *)
+		qeth_push_skb(card, skb, sizeof(struct qeth_hdr)));
+}
+
+static inline void
+__qeth_free_new_skb(struct sk_buff *orig_skb, struct sk_buff *new_skb)
+{
+	if (orig_skb != new_skb)
+		dev_kfree_skb_any(new_skb);
+}
+
+static inline struct sk_buff *
+qeth_prepare_skb(struct qeth_card *card, struct sk_buff *skb,
+		 struct qeth_hdr **hdr, int ipv)
+{
+	struct sk_buff *new_skb;
+	
+	QETH_DBF_TEXT(trace, 6, "prepskb");
+
+        new_skb = qeth_realloc_headroom(card, skb, sizeof(struct qeth_hdr));
+       	if (new_skb == NULL)
+		return NULL;
+	*hdr = __qeth_prepare_skb(card, new_skb, ipv);
+	if (*hdr == NULL) {
+		__qeth_free_new_skb(skb, new_skb);
+		return NULL;
+	}
+	return new_skb;
 }
 
 static inline u8
@@ -4242,21 +4252,15 @@ qeth_do_send_packet_fast(struct qeth_car
 	 * check if buffer is empty to make sure that we do not 'overtake'
 	 * ourselves and try to fill a buffer that is already primed
 	 */
-	if (atomic_read(&buffer->state) != QETH_QDIO_BUF_EMPTY) {
-		card->stats.tx_dropped++;
-		atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
-		return -EBUSY;
-	}
+	if (atomic_read(&buffer->state) != QETH_QDIO_BUF_EMPTY) 
+		goto out;
 	if (ctx == NULL)
 		queue->next_buf_to_fill = (queue->next_buf_to_fill + 1) %
 					  QDIO_MAX_BUFFERS_PER_Q;
 	else {
 		buffers_needed = qeth_eddp_check_buffers_for_context(queue,ctx);
-		if (buffers_needed < 0) {
-			card->stats.tx_dropped++;
-			atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
-			return -EBUSY;
-		}
+		if (buffers_needed < 0) 
+			goto out;
 		queue->next_buf_to_fill =
 			(queue->next_buf_to_fill + buffers_needed) %
 			QDIO_MAX_BUFFERS_PER_Q;
@@ -4271,6 +4275,9 @@ qeth_do_send_packet_fast(struct qeth_car
 		qeth_flush_buffers(queue, 0, index, flush_cnt);
 	}
 	return 0;
+out:
+	atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
+	return -EBUSY;
 }
 
 static inline int
@@ -4296,8 +4303,7 @@ qeth_do_send_packet(struct qeth_card *ca
 	 * check if buffer is empty to make sure that we do not 'overtake'
 	 * ourselves and try to fill a buffer that is already primed
 	 */
-	if (atomic_read(&buffer->state) != QETH_QDIO_BUF_EMPTY){
-		card->stats.tx_dropped++;
+	if (atomic_read(&buffer->state) != QETH_QDIO_BUF_EMPTY) {
 		atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
 		return -EBUSY;
 	}
@@ -4320,7 +4326,6 @@ qeth_do_send_packet(struct qeth_card *ca
 				 * again */
 				if (atomic_read(&buffer->state) !=
 						QETH_QDIO_BUF_EMPTY){
-					card->stats.tx_dropped++;
 					qeth_flush_buffers(queue, 0, start_index, flush_count);
 					atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
 					return -EBUSY;
@@ -4331,7 +4336,6 @@ qeth_do_send_packet(struct qeth_card *ca
 			 * free buffers) to handle eddp context */
 			if (qeth_eddp_check_buffers_for_context(queue,ctx) < 0){
 				printk("eddp tx_dropped 1\n");
-				card->stats.tx_dropped++;
 				rc = -EBUSY;
 				goto out;
 			}
@@ -4343,7 +4347,6 @@ qeth_do_send_packet(struct qeth_card *ca
 		tmp = qeth_eddp_fill_buffer(queue,ctx,queue->next_buf_to_fill);
 		if (tmp < 0) {
 			printk("eddp tx_dropped 2\n");
-			card->stats.tx_dropped++;
 			rc = - EBUSY;
 			goto out;
 		}
@@ -4391,21 +4394,21 @@ qeth_get_elements_no(struct qeth_card *c
 {
 	int elements_needed = 0;
 
-        if (skb_shinfo(skb)->nr_frags > 0) {
+        if (skb_shinfo(skb)->nr_frags > 0) 
                 elements_needed = (skb_shinfo(skb)->nr_frags + 1);
-	}
-        if (elements_needed == 0 )
+        if (elements_needed == 0)
                 elements_needed = 1 + (((((unsigned long) hdr) % PAGE_SIZE)
                                         + skb->len) >> PAGE_SHIFT);
 	if ((elements_needed + elems) > QETH_MAX_BUFFER_ELEMENTS(card)){
-                PRINT_ERR("qeth_do_send_packet: invalid size of "
-                          "IP packet (Number=%d / Length=%d). Discarded.\n",
+                PRINT_ERR("Invalid size of IP packet "
+			  "(Number=%d / Length=%d). Discarded.\n",
                           (elements_needed+elems), skb->len);
                 return 0;
         }
         return elements_needed;
 }
 
+
 static inline int
 qeth_send_packet(struct qeth_card *card, struct sk_buff *skb)
 {
@@ -4421,108 +4424,110 @@ qeth_send_packet(struct qeth_card *card,
 	unsigned short nr_frags = skb_shinfo(skb)->nr_frags;
 	unsigned short tso_size = skb_shinfo(skb)->gso_size;
 #endif
+	struct sk_buff *new_skb, *new_skb2;
 	int rc;
 
 	QETH_DBF_TEXT(trace, 6, "sendpkt");
 
+	new_skb = skb;
+	if ((card->info.type == QETH_CARD_TYPE_OSN) &&
+	    (skb->protocol == htons(ETH_P_IPV6)))
+		return -EPERM;
+	cast_type = qeth_get_cast_type(card, skb);
+	if ((cast_type == RTN_BROADCAST) &&
+	    (card->info.broadcast_capable == 0))
+		return -EPERM;
+	queue = card->qdio.out_qs
+		[qeth_get_priority_queue(card, skb, ipv, cast_type)];
 	if (!card->options.layer2) {
 		ipv = qeth_get_ip_version(skb);
 		if ((card->dev->hard_header == qeth_fake_header) && ipv) {
-               		if ((skb = qeth_pskb_unshare(skb,GFP_ATOMIC)) == NULL) {
-                        	card->stats.tx_dropped++;
-                        	dev_kfree_skb_irq(skb);
-                        	return 0;
-                	}
+			new_skb = qeth_pskb_unshare(skb, GFP_ATOMIC);
+			if (!new_skb)
+				return -ENOMEM;
 			if(card->dev->type == ARPHRD_IEEE802_TR){
-				skb_pull(skb, QETH_FAKE_LL_LEN_TR);
+				skb_pull(new_skb, QETH_FAKE_LL_LEN_TR);
 			} else {
-                		skb_pull(skb, QETH_FAKE_LL_LEN_ETH);
+				skb_pull(new_skb, QETH_FAKE_LL_LEN_ETH);
 			}
 		}
 	}
-	if ((card->info.type == QETH_CARD_TYPE_OSN) &&
-		(skb->protocol == htons(ETH_P_IPV6))) {
-		dev_kfree_skb_any(skb);
-		return 0;
-	}
-	cast_type = qeth_get_cast_type(card, skb);
-	if ((cast_type == RTN_BROADCAST) &&
-	    (card->info.broadcast_capable == 0)){
-		card->stats.tx_dropped++;
-		card->stats.tx_errors++;
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
-	}
-	queue = card->qdio.out_qs
-		[qeth_get_priority_queue(card, skb, ipv, cast_type)];
-
 	if (skb_is_gso(skb))
 		large_send = card->options.large_send;
-
-	/*are we able to do TSO ? If so ,prepare and send it from here */
+	/* check on OSN device*/
+	if (card->info.type == QETH_CARD_TYPE_OSN)
+		hdr = (struct qeth_hdr *)new_skb->data;
+	/*are we able to do TSO ? */
 	if ((large_send == QETH_LARGE_SEND_TSO) &&
 	    (cast_type == RTN_UNSPEC)) {
-		rc = qeth_tso_prepare_packet(card, skb, ipv, cast_type);
+		rc = qeth_tso_prepare_packet(card, new_skb, ipv, cast_type);
 		if (rc) {
-			card->stats.tx_dropped++;
-			card->stats.tx_errors++;
-			dev_kfree_skb_any(skb);
-			return NETDEV_TX_OK;
+			__qeth_free_new_skb(skb, new_skb);
+			return rc;
 		}
 		elements_needed++;
-	} else {
-		if ((rc = qeth_prepare_skb(card, &skb, &hdr, ipv))) {
-			QETH_DBF_TEXT_(trace, 4, "pskbe%d", rc);
-			return rc;
+	} else if (card->info.type != QETH_CARD_TYPE_OSN) {
+		new_skb2 = qeth_prepare_skb(card, new_skb, &hdr, ipv);
+		if (!new_skb2) {
+			__qeth_free_new_skb(skb, new_skb);
+			return -EINVAL;
 		}
-		if (card->info.type != QETH_CARD_TYPE_OSN)
-			qeth_fill_header(card, hdr, skb, ipv, cast_type);
+		if (new_skb != skb)
+			__qeth_free_new_skb(new_skb2, new_skb);
+		new_skb = new_skb2;
+		qeth_fill_header(card, hdr, new_skb, ipv, cast_type);
 	}
-
 	if (large_send == QETH_LARGE_SEND_EDDP) {
-		ctx = qeth_eddp_create_context(card, skb, hdr);
+		ctx = qeth_eddp_create_context(card, new_skb, hdr);
 		if (ctx == NULL) {
+			__qeth_free_new_skb(skb, new_skb);
 			PRINT_WARN("could not create eddp context\n");
 			return -EINVAL;
 		}
 	} else {
-		int elems = qeth_get_elements_no(card,(void*) hdr, skb,
+		int elems = qeth_get_elements_no(card,(void*) hdr, new_skb,
 						 elements_needed);
-		if (!elems)
+		if (!elems) {
+			__qeth_free_new_skb(skb, new_skb);
 			return -EINVAL;
+		}
 		elements_needed += elems;
 	}
 
 	if (card->info.type != QETH_CARD_TYPE_IQD)
-		rc = qeth_do_send_packet(card, queue, skb, hdr,
+		rc = qeth_do_send_packet(card, queue, new_skb, hdr,
 					 elements_needed, ctx);
 	else
-		rc = qeth_do_send_packet_fast(card, queue, skb, hdr,
+		rc = qeth_do_send_packet_fast(card, queue, new_skb, hdr,
 					      elements_needed, ctx);
-	if (!rc){
+	if (!rc) {
 		card->stats.tx_packets++;
 		card->stats.tx_bytes += tx_bytes;
+		if (new_skb != skb)
+			dev_kfree_skb_any(skb);
 #ifdef CONFIG_QETH_PERF_STATS
 		if (tso_size &&
 		   !(large_send == QETH_LARGE_SEND_NO)) {
 			card->perf_stats.large_send_bytes += tx_bytes;
 			card->perf_stats.large_send_cnt++;
 		}
- 		if (nr_frags > 0){
+		if (nr_frags > 0) {
 			card->perf_stats.sg_skbs_sent++;
 			/* nr_frags + skb->data */
 			card->perf_stats.sg_frags_sent +=
 				nr_frags + 1;
 		}
 #endif /* CONFIG_QETH_PERF_STATS */
+	} else {
+		card->stats.tx_dropped++;
+		__qeth_free_new_skb(skb, new_skb);
 	}
 	if (ctx != NULL) {
 		/* drop creator's reference */
 		qeth_eddp_put_context(ctx);
 		/* free skb; it's not referenced by a buffer */
-		if (rc == 0)
-			dev_kfree_skb_any(skb);
-
+		if (!rc)
+		       dev_kfree_skb_any(new_skb);
 	}
 	return rc;
 }
diff --git a/drivers/s390/net/qeth_tso.h b/drivers/s390/net/qeth_tso.h
index 593f298..14504af 100644
--- a/drivers/s390/net/qeth_tso.h
+++ b/drivers/s390/net/qeth_tso.h
@@ -24,7 +24,7 @@ static inline struct qeth_hdr_tso *
 qeth_tso_prepare_skb(struct qeth_card *card, struct sk_buff **skb)
 {
 	QETH_DBF_TEXT(trace, 5, "tsoprsk");
-	return qeth_push_skb(card, skb, sizeof(struct qeth_hdr_tso));
+	return qeth_push_skb(card, *skb, sizeof(struct qeth_hdr_tso));
 }
 
 /**
-- 
1.2.4

