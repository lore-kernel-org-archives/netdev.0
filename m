From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 4/7] s390/qeth: pass TSO data offset to fill_buffer()
Date: Fri, 18 Aug 2017 10:19:07 +0200
Message-ID: <20170818081910.48869-5-jwi@linux.vnet.ibm.com>
References: <20170818081910.48869-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:40143 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750954AbdHRIT1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 04:19:27 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7I8JA0f139298
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 04:19:26 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2cdmacsdf3-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 04:19:26 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Fri, 18 Aug 2017 09:19:24 +0100
In-Reply-To: <20170818081910.48869-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For TSO we need to skip the skb's qeth/IP/TCP headers when mapping
it into buffer elements. Instead of (mis)using skb_pull(), pass a
corresponding offset to fill_buffer() like we already do for IQDs.

No actual change in the resulting TSO buffers.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  2 +-
 drivers/s390/net/qeth_core_main.c | 10 ++++------
 drivers/s390/net/qeth_l2_main.c   |  4 ++--
 drivers/s390/net/qeth_l3_main.c   |  2 +-
 4 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 2f5673812810..5753fbc485d5 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -952,7 +952,7 @@ int qeth_do_send_packet_fast(struct qeth_card *card,
 			     unsigned int hd_len);
 int qeth_do_send_packet(struct qeth_card *card, struct qeth_qdio_out_q *queue,
 			struct sk_buff *skb, struct qeth_hdr *hdr,
-			unsigned int hd_len, int elements);
+			unsigned int hd_len, unsigned int offset, int elements);
 int qeth_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 int qeth_core_get_sset_count(struct net_device *, int);
 void qeth_core_get_ethtool_stats(struct net_device *,
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 6cafeceea3ce..4a5c3028dfb6 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3975,11 +3975,8 @@ static int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
 		buffer->element[element].length = hd_len;
 		buffer->element[element].eflags = SBAL_EFLAGS_FIRST_FRAG;
 		buf->next_element_to_fill++;
-		skb_pull(skb, hd_len);
-	}
-
 	/* IQD */
-	if (offset > 0) {
+	} else if (offset) {
 		int element = buf->next_element_to_fill;
 		is_first_elem = false;
 
@@ -4049,7 +4046,8 @@ EXPORT_SYMBOL_GPL(qeth_do_send_packet_fast);
 
 int qeth_do_send_packet(struct qeth_card *card, struct qeth_qdio_out_q *queue,
 			struct sk_buff *skb, struct qeth_hdr *hdr,
-			unsigned int hd_len, int elements_needed)
+			unsigned int offset, unsigned int hd_len,
+			int elements_needed)
 {
 	struct qeth_qdio_out_buffer *buffer;
 	int start_index;
@@ -4098,7 +4096,7 @@ int qeth_do_send_packet(struct qeth_card *card, struct qeth_qdio_out_q *queue,
 			}
 		}
 	}
-	tmp = qeth_fill_buffer(queue, buffer, skb, hdr, 0, hd_len);
+	tmp = qeth_fill_buffer(queue, buffer, skb, hdr, offset, hd_len);
 	queue->next_buf_to_fill = (queue->next_buf_to_fill + tmp) %
 				  QDIO_MAX_BUFFERS_PER_Q;
 	flush_count += tmp;
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index c78d9fadb9c8..a6233ab562f0 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -746,7 +746,7 @@ static int qeth_l2_xmit_osa(struct qeth_card *card, struct sk_buff *skb,
 		rc = -EINVAL;
 		goto out;
 	}
-	rc = qeth_do_send_packet(card, queue, skb_copy, hdr, 0, elements);
+	rc = qeth_do_send_packet(card, queue, skb_copy, hdr, 0, 0, elements);
 out:
 	if (!rc) {
 		/* tx success, free dangling original */
@@ -778,7 +778,7 @@ static int qeth_l2_xmit_osn(struct qeth_card *card, struct sk_buff *skb,
 		return -E2BIG;
 	if (qeth_hdr_chk_and_bounce(skb, &hdr, sizeof(*hdr)))
 		return -EINVAL;
-	return qeth_do_send_packet(card, queue, skb, hdr, 0, elements);
+	return qeth_do_send_packet(card, queue, skb, hdr, 0, 0, elements);
 }
 
 static netdev_tx_t qeth_l2_hard_start_xmit(struct sk_buff *skb,
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index fa8b638e3842..02400bbcb610 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2768,7 +2768,7 @@ static netdev_tx_t qeth_l3_hard_start_xmit(struct sk_buff *skb,
 		if (qeth_hdr_chk_and_bounce(new_skb, &hdr, len))
 			goto tx_drop;
 		rc = qeth_do_send_packet(card, queue, new_skb, hdr, hd_len,
-					 elements);
+					 hd_len, elements);
 	} else
 		rc = qeth_do_send_packet_fast(card, queue, new_skb, hdr,
 					      data_offset, 0);
-- 
2.11.2
