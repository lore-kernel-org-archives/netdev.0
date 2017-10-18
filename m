From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 11/13] s390/qeth: try harder to get packets from RX buffer
Date: Wed, 18 Oct 2017 17:40:23 +0200
Message-ID: <20171018154025.73630-12-jwi@linux.vnet.ibm.com>
References: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:38658 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751919AbdJRPkz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:40:55 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9IFduRK017362
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:55 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2dp69v5fpg-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:55 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Wed, 18 Oct 2017 16:40:52 +0100
In-Reply-To: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current code bails out when two subsequent buffer elements hold
insufficient data to contain a qeth_hdr packet descriptor.
This seems reasonable, but it would be legal for quirky hardware to
leave a few elements empty and then present packets in a subsequent
element. These packets would currently be dropped.

So make sure to check all buffer elements, until we hit the LAST_ENTRY
indication.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 23b439fb5f2c..8855bc8534d2 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -5214,13 +5214,11 @@ struct sk_buff *qeth_core_get_next_skb(struct qeth_card *card,
 	int use_rx_sg = 0;
 
 	/* qeth_hdr must not cross element boundaries */
-	if (element->length < offset + sizeof(struct qeth_hdr)) {
+	while (element->length < offset + sizeof(struct qeth_hdr)) {
 		if (qeth_is_last_sbale(element))
 			return NULL;
 		element++;
 		offset = 0;
-		if (element->length < sizeof(struct qeth_hdr))
-			return NULL;
 	}
 	*hdr = element->addr + offset;
 
-- 
2.13.5
