From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 5/7] s390/qeth: pass full IQD header length to fill_buffer()
Date: Fri, 18 Aug 2017 10:19:08 +0200
Message-ID: <20170818081910.48869-6-jwi@linux.vnet.ibm.com>
References: <20170818081910.48869-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:59347 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750960AbdHRIT2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 04:19:28 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7I8JAks039983
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 04:19:27 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2cdqt1f4up-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 04:19:27 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Fri, 18 Aug 2017 09:19:25 +0100
In-Reply-To: <20170818081910.48869-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a prerequisite for unifying the code to build header elements.
The TSO header has a different size, so we can no longer rely on implicitly
adding the size of a normal qeth_hdr.

No functional change.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 3 +--
 drivers/s390/net/qeth_l2_main.c   | 2 +-
 drivers/s390/net/qeth_l3_main.c   | 3 ++-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 4a5c3028dfb6..cef9f54d0eb9 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3981,8 +3981,7 @@ static int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
 		is_first_elem = false;
 
 		buffer->element[element].addr = hdr;
-		buffer->element[element].length = sizeof(struct qeth_hdr) +
-							hd_len;
+		buffer->element[element].length = hd_len;
 		buffer->element[element].eflags = SBAL_EFLAGS_FIRST_FRAG;
 		buf->is_header[element] = 1;
 		buf->next_element_to_fill++;
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index a6233ab562f0..c85fadf21b38 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -695,7 +695,7 @@ static int qeth_l2_xmit_iqd(struct qeth_card *card, struct sk_buff *skb,
 		goto out;
 	}
 	rc = qeth_do_send_packet_fast(card, queue, skb, hdr, data_offset,
-				      data_offset);
+				      sizeof(*hdr) + data_offset);
 out:
 	if (rc)
 		kmem_cache_free(qeth_core_header_cache, hdr);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 02400bbcb610..ab661a431f7c 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2670,6 +2670,7 @@ static netdev_tx_t qeth_l3_hard_start_xmit(struct sk_buff *skb,
 	if (card->info.type == QETH_CARD_TYPE_IQD) {
 		new_skb = skb;
 		data_offset = ETH_HLEN;
+		hd_len = sizeof(*hdr);
 		hdr = kmem_cache_alloc(qeth_core_header_cache, GFP_ATOMIC);
 		if (!hdr)
 			goto tx_drop;
@@ -2771,7 +2772,7 @@ static netdev_tx_t qeth_l3_hard_start_xmit(struct sk_buff *skb,
 					 hd_len, elements);
 	} else
 		rc = qeth_do_send_packet_fast(card, queue, new_skb, hdr,
-					      data_offset, 0);
+					      data_offset, hd_len);
 
 	if (!rc) {
 		card->stats.tx_packets++;
-- 
2.11.2
