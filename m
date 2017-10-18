From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 06/13] s390/qeth: clean up initial MTU determination
Date: Wed, 18 Oct 2017 17:40:18 +0200
Message-ID: <20171018154025.73630-7-jwi@linux.vnet.ibm.com>
References: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:52971 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751855AbdJRPkr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:40:47 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9IFdcKU092669
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:46 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2dp4ukmme6-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:46 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Wed, 18 Oct 2017 16:40:44 +0100
In-Reply-To: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Drop the support for Token Ring,
2. use the ETH_DATA_LEN macro for the default L2 MTU,
3. handle OSM via the default case (as OSM is L2-only), and
4. document why the L3 MTU is reduced.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 735b03cae727..acf16fa75c63 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -2219,18 +2219,12 @@ static int qeth_get_initial_mtu_for_card(struct qeth_card *card)
 	case QETH_CARD_TYPE_IQD:
 		return card->info.max_mtu;
 	case QETH_CARD_TYPE_OSD:
-		switch (card->info.link_type) {
-		case QETH_LINK_TYPE_HSTR:
-		case QETH_LINK_TYPE_LANE_TR:
-			return 2000;
-		default:
-			return card->options.layer2 ? 1500 : 1492;
-		}
-	case QETH_CARD_TYPE_OSM:
 	case QETH_CARD_TYPE_OSX:
-		return card->options.layer2 ? 1500 : 1492;
+		if (!card->options.layer2)
+			return ETH_DATA_LEN - 8; /* L3: allow for LLC + SNAP */
+		/* fall through */
 	default:
-		return 1500;
+		return ETH_DATA_LEN;
 	}
 }
 
-- 
2.13.5
