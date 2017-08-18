From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 7/7] s390/qeth: use skb_cow_head() for L2 OSA xmit
Date: Fri, 18 Aug 2017 10:19:10 +0200
Message-ID: <20170818081910.48869-8-jwi@linux.vnet.ibm.com>
References: <20170818081910.48869-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:50603 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750971AbdHRITb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 04:19:31 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7I8JJ0H143238
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 04:19:31 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2cdqfy8bbp-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 04:19:31 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Fri, 18 Aug 2017 09:19:28 +0100
In-Reply-To: <20170818081910.48869-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Taking a full copy via skb_realloc_headroom() on every xmit is overkill
and wastes CPU time; all we actually need is to push on the qeth_hdr.
So rework the L2 OSA TX path to avoid the copy.
Minor complications arise because struct qeth_hdr must not cross a page
boundary. So add a new helper qeth_push_hdr() that catches this, and
falls back to the hdr cache that we already use for IQDs.

This change uncovered that qeth's TX completion takes rather long.
Now that we no longer free the original skb straight away and thus call
skb->destructor later than before, throughput regresses significantly.
For now, restore old behaviour by adding an explicit skb_orphan(),
and a big TODO to improve the TX completion time.

Tested-by: Nils Hoppmann <niho@de.ibm.com>
Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  1 +
 drivers/s390/net/qeth_core_main.c | 28 +++++++++++++++++++
 drivers/s390/net/qeth_l2_main.c   | 58 ++++++++++++++++++++++++---------------
 3 files changed, 65 insertions(+), 22 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 5753fbc485d5..59e09854c4f7 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -985,6 +985,7 @@ int qeth_set_features(struct net_device *, netdev_features_t);
 int qeth_recover_features(struct net_device *);
 netdev_features_t qeth_fix_features(struct net_device *, netdev_features_t);
 int qeth_vm_request_mac(struct qeth_card *card);
+int qeth_push_hdr(struct sk_buff *skb, struct qeth_hdr **hdr, unsigned int len);
 
 /* exports for OSN */
 int qeth_osn_assist(struct net_device *, void *, int);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index ffefdd97abca..bae7440abc01 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3890,6 +3890,34 @@ int qeth_hdr_chk_and_bounce(struct sk_buff *skb, struct qeth_hdr **hdr, int len)
 }
 EXPORT_SYMBOL_GPL(qeth_hdr_chk_and_bounce);
 
+/**
+ * qeth_push_hdr() - push a qeth_hdr onto an skb.
+ * @skb: skb that the qeth_hdr should be pushed onto.
+ * @hdr: double pointer to a qeth_hdr. When returning with >= 0,
+ *	 it contains a valid pointer to a qeth_hdr.
+ * @len: length of the hdr that needs to be pushed on.
+ *
+ * Returns the pushed length. If the header can't be pushed on
+ * (eg. because it would cross a page boundary), it is allocated from
+ * the cache instead and 0 is returned.
+ * Error to create the hdr is indicated by returning with < 0.
+ */
+int qeth_push_hdr(struct sk_buff *skb, struct qeth_hdr **hdr, unsigned int len)
+{
+	if (skb_headroom(skb) >= len &&
+	    qeth_get_elements_for_range((addr_t)skb->data - len,
+					(addr_t)skb->data) == 1) {
+		*hdr = skb_push(skb, len);
+		return len;
+	}
+	/* fall back */
+	*hdr = kmem_cache_alloc(qeth_core_header_cache, GFP_ATOMIC);
+	if (!*hdr)
+		return -ENOMEM;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(qeth_push_hdr);
+
 static void __qeth_fill_buffer(struct sk_buff *skb,
 			       struct qeth_qdio_out_buffer *buf,
 			       bool is_first_elem, unsigned int offset)
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index c85fadf21b38..760b023eae95 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -705,9 +705,11 @@ static int qeth_l2_xmit_iqd(struct qeth_card *card, struct sk_buff *skb,
 static int qeth_l2_xmit_osa(struct qeth_card *card, struct sk_buff *skb,
 			    struct qeth_qdio_out_q *queue, int cast_type)
 {
+	int push_len = sizeof(struct qeth_hdr);
 	unsigned int elements, nr_frags;
-	struct sk_buff *skb_copy;
-	struct qeth_hdr *hdr;
+	unsigned int hdr_elements = 0;
+	struct qeth_hdr *hdr = NULL;
+	unsigned int hd_len = 0;
 	int rc;
 
 	/* fix hardware limitation: as long as we do not have sbal
@@ -727,38 +729,44 @@ static int qeth_l2_xmit_osa(struct qeth_card *card, struct sk_buff *skb,
 	}
 	nr_frags = skb_shinfo(skb)->nr_frags;
 
-	/* create a copy with writeable headroom */
-	skb_copy = skb_realloc_headroom(skb, sizeof(struct qeth_hdr));
-	if (!skb_copy)
-		return -ENOMEM;
-	hdr = skb_push(skb_copy, sizeof(struct qeth_hdr));
-	qeth_l2_fill_header(hdr, skb_copy, cast_type,
-			    skb_copy->len - sizeof(*hdr));
-	if (skb_copy->ip_summed == CHECKSUM_PARTIAL)
-		qeth_l2_hdr_csum(card, hdr, skb_copy);
-
-	elements = qeth_get_elements_no(card, skb_copy, 0, 0);
+	rc = skb_cow_head(skb, push_len);
+	if (rc)
+		return rc;
+	push_len = qeth_push_hdr(skb, &hdr, push_len);
+	if (push_len < 0)
+		return push_len;
+	if (!push_len) {
+		/* hdr was allocated from cache */
+		hd_len = sizeof(*hdr);
+		hdr_elements = 1;
+	}
+	qeth_l2_fill_header(hdr, skb, cast_type, skb->len - push_len);
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		qeth_l2_hdr_csum(card, hdr, skb);
+
+	elements = qeth_get_elements_no(card, skb, hdr_elements, 0);
 	if (!elements) {
 		rc = -E2BIG;
 		goto out;
 	}
-	if (qeth_hdr_chk_and_bounce(skb_copy, &hdr, sizeof(*hdr))) {
-		rc = -EINVAL;
-		goto out;
-	}
-	rc = qeth_do_send_packet(card, queue, skb_copy, hdr, 0, 0, elements);
+	elements += hdr_elements;
+
+	/* TODO: remove the skb_orphan() once TX completion is fast enough */
+	skb_orphan(skb);
+	rc = qeth_do_send_packet(card, queue, skb, hdr, 0, hd_len, elements);
 out:
 	if (!rc) {
-		/* tx success, free dangling original */
-		dev_kfree_skb_any(skb);
 		if (card->options.performance_stats && nr_frags) {
 			card->perf_stats.sg_skbs_sent++;
 			/* nr_frags + skb->data */
 			card->perf_stats.sg_frags_sent += nr_frags + 1;
 		}
 	} else {
-		/* tx fail, free copy */
-		dev_kfree_skb_any(skb_copy);
+		if (hd_len)
+			kmem_cache_free(qeth_core_header_cache, hdr);
+		if (rc == -EBUSY)
+			/* roll back to ETH header */
+			skb_pull(skb, push_len);
 	}
 	return rc;
 }
@@ -1011,6 +1019,12 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 			card->dev->vlan_features |= NETIF_F_RXCSUM;
 		}
 	}
+	if (card->info.type != QETH_CARD_TYPE_OSN &&
+	    card->info.type != QETH_CARD_TYPE_IQD) {
+		card->dev->priv_flags &= ~IFF_TX_SKB_SHARING;
+		card->dev->needed_headroom = sizeof(struct qeth_hdr);
+	}
+
 	card->info.broadcast_capable = 1;
 	qeth_l2_request_initial_mac(card);
 	card->dev->gso_max_size = (QETH_MAX_BUFFER_ELEMENTS(card) - 1) *
-- 
2.11.2
