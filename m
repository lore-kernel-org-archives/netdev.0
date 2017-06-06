From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/9] s390/qeth: remove skb_is_nonlinear() check on IQD
Date: Tue,  6 Jun 2017 14:33:43 +0200
Message-ID: <20170606123350.13781-3-jwi@linux.vnet.ibm.com>
References: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:56560 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751485AbdFFMeJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 08:34:09 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v56CXfTo089132
        for <netdev@vger.kernel.org>; Tue, 6 Jun 2017 08:34:03 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2awv2rhufv-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 08:34:03 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 6 Jun 2017 13:34:01 +0100
In-Reply-To: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

qeth doesn't advertise NETIF_F_SG for L3 IQDs. So trust the stack to
not hand us any nonlinear skbs, and remove an always-true condition.

With the fact that data_offset < 0 is no longer possible on IQDs,
apply a small cleanup to subsequent code.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Acked-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index ac8310fe2fb0..56e813972d77 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2676,8 +2676,7 @@ static netdev_tx_t qeth_l3_hard_start_xmit(struct sk_buff *skb,
 	use_tso = skb_is_gso(skb) &&
 		  (qeth_get_ip_protocol(skb) == IPPROTO_TCP) && (ipv == 4);
 
-	if ((card->info.type == QETH_CARD_TYPE_IQD) &&
-	    !skb_is_nonlinear(skb)) {
+	if (card->info.type == QETH_CARD_TYPE_IQD) {
 		new_skb = skb;
 		data_offset = ETH_HLEN;
 		hdr = kmem_cache_alloc(qeth_core_header_cache, GFP_ATOMIC);
@@ -2690,12 +2689,7 @@ static netdev_tx_t qeth_l3_hard_start_xmit(struct sk_buff *skb,
 					+ VLAN_HLEN);
 		if (!new_skb)
 			goto tx_drop;
-	}
 
-	if (card->info.type == QETH_CARD_TYPE_IQD) {
-		if (data_offset < 0)
-			skb_pull(new_skb, ETH_HLEN);
-	} else {
 		if (ipv == 4) {
 			skb_pull(new_skb, ETH_HLEN);
 		}
-- 
2.11.2
