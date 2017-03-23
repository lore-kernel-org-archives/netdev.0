From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 2/3] s390/qeth: no ETH header for outbound AF_IUCV
Date: Thu, 23 Mar 2017 14:55:09 +0100
Message-ID: <20170323135510.98972-3-ubraun@linux.vnet.ibm.com>
References: <20170323135510.98972-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:49646 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755860AbdCWNzY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 09:55:24 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2NDrr9H145133
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 09:55:23 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29bxj17rxy-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 09:55:22 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 23 Mar 2017 13:55:20 -0000
In-Reply-To: <20170323135510.98972-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>

With AF_IUCV traffic, the skb passed to hard_start_xmit() has a 14 byte
slot at skb->data, intended for an ETH header. qeth_l3_fill_af_iucv_hdr()
fills this ETH header... and then immediately moves it to the
skb's headroom, where it disappears and is never seen again.

But it's still possible for us to return NETDEV_TX_BUSY after the skb has
been modified. Since we didn't get a private copy of the skb, the next
time the skb is delivered to hard_start_xmit() it no longer has the
expected layout (we moved the ETH header to the headroom, so skb->data
now starts at the IUCV_TRANS header). So when qeth_l3_fill_af_iucv_hdr()
does another round of rebuilding, the resulting qeth header ends up
all wrong. On transmission, the buffer is then rejected by
the HiperSockets device with SBALF15 = x'04'.
When this error is passed back to af_iucv as TX_NOTIFY_UNREACHABLE, it
tears down the offending socket.

As the ETH header for AF_IUCV serves no purpose, just align the code to
what we do for IP traffic on L3 HiperSockets: keep the ETH header at
skb->data, and pass down data_offset = ETH_HLEN to qeth_fill_buffer().
When mapping the payload into the SBAL elements, the ETH header is then
stripped off. This avoids the skb manipulations in
qeth_l3_fill_af_iucv_hdr(), and any buffer re-entering hard_start_xmit()
after NETDEV_TX_BUSY is now processed properly.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c | 15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 72aa953..653f0fb 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2609,17 +2609,13 @@ static void qeth_l3_fill_af_iucv_hdr(struct qeth_card *card,
 	char daddr[16];
 	struct af_iucv_trans_hdr *iucv_hdr;
 
-	skb_pull(skb, 14);
-	card->dev->header_ops->create(skb, card->dev, 0,
-				      card->dev->dev_addr, card->dev->dev_addr,
-				      card->dev->addr_len);
-	skb_pull(skb, 14);
-	iucv_hdr = (struct af_iucv_trans_hdr *)skb->data;
 	memset(hdr, 0, sizeof(struct qeth_hdr));
 	hdr->hdr.l3.id = QETH_HEADER_TYPE_LAYER3;
 	hdr->hdr.l3.ext_flags = 0;
-	hdr->hdr.l3.length = skb->len;
+	hdr->hdr.l3.length = skb->len - ETH_HLEN;
 	hdr->hdr.l3.flags = QETH_HDR_IPV6 | QETH_CAST_UNICAST;
+
+	iucv_hdr = (struct af_iucv_trans_hdr *) (skb->data + ETH_HLEN);
 	memset(daddr, 0, sizeof(daddr));
 	daddr[0] = 0xfe;
 	daddr[1] = 0x80;
@@ -2823,10 +2819,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if ((card->info.type == QETH_CARD_TYPE_IQD) &&
 	    !skb_is_nonlinear(skb)) {
 		new_skb = skb;
-		if (new_skb->protocol == ETH_P_AF_IUCV)
-			data_offset = 0;
-		else
-			data_offset = ETH_HLEN;
+		data_offset = ETH_HLEN;
 		hdr = kmem_cache_alloc(qeth_core_header_cache, GFP_ATOMIC);
 		if (!hdr)
 			goto tx_drop;
-- 
2.8.4
