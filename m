From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/7] s390/qeth: pass full data length to l2_fill_header()
Date: Fri, 18 Aug 2017 10:19:05 +0200
Message-ID: <20170818081910.48869-3-jwi@linux.vnet.ibm.com>
References: <20170818081910.48869-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:47784 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750847AbdHRITY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 04:19:24 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7I8J94J135907
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 04:19:24 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2cduku2v4e-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 04:19:24 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Fri, 18 Aug 2017 09:19:22 +0100
In-Reply-To: <20170818081910.48869-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For IQD we already need to fix up the qeth_hdr's length field, and
future changes will require more flexibility for OSA as well. The
device-specific path knows best what header length it requires, so just
pass it from there.
While at it, remove the unused qeth_card parameter.

No functional change.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 310bfa225e20..3f5b852408d3 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -259,13 +259,14 @@ static void qeth_l2_hdr_csum(struct qeth_card *card, struct qeth_hdr *hdr,
 		card->perf_stats.tx_csum++;
 }
 
-static void qeth_l2_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
-			struct sk_buff *skb, int cast_type)
+static void qeth_l2_fill_header(struct qeth_hdr *hdr, struct sk_buff *skb,
+				int cast_type, unsigned int data_len)
 {
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)skb_mac_header(skb);
 
 	memset(hdr, 0, sizeof(struct qeth_hdr));
 	hdr->hdr.l2.id = QETH_HEADER_TYPE_LAYER2;
+	hdr->hdr.l2.pkt_length = data_len;
 
 	/* set byte byte 3 to casting flags */
 	if (cast_type == RTN_MULTICAST)
@@ -275,7 +276,6 @@ static void qeth_l2_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 	else
 		hdr->hdr.l2.flags[2] |= QETH_LAYER2_FLAG_UNICAST;
 
-	hdr->hdr.l2.pkt_length = skb->len - sizeof(struct qeth_hdr);
 	/* VSWITCH relies on the VLAN
 	 * information to be present in
 	 * the QDIO header */
@@ -686,8 +686,7 @@ static int qeth_l2_xmit_iqd(struct qeth_card *card, struct sk_buff *skb,
 	hdr = kmem_cache_alloc(qeth_core_header_cache, GFP_ATOMIC);
 	if (!hdr)
 		return -ENOMEM;
-	qeth_l2_fill_header(card, hdr, skb, cast_type);
-	hdr->hdr.l2.pkt_length = skb->len;
+	qeth_l2_fill_header(hdr, skb, cast_type, skb->len);
 	skb_copy_from_linear_data(skb, ((char *)hdr) + sizeof(*hdr),
 				  data_offset);
 
@@ -733,7 +732,8 @@ static int qeth_l2_xmit_osa(struct qeth_card *card, struct sk_buff *skb,
 	if (!skb_copy)
 		return -ENOMEM;
 	hdr = skb_push(skb_copy, sizeof(struct qeth_hdr));
-	qeth_l2_fill_header(card, hdr, skb_copy, cast_type);
+	qeth_l2_fill_header(hdr, skb_copy, cast_type,
+			    skb_copy->len - sizeof(*hdr));
 	if (skb_copy->ip_summed == CHECKSUM_PARTIAL)
 		qeth_l2_hdr_csum(card, hdr, skb_copy);
 
-- 
2.11.2
