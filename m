From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 02/12] s390/qeth: remove extra L2 adapterparms query
Date: Tue, 15 Aug 2017 17:02:40 +0200
Message-ID: <20170815150250.67158-3-jwi@linux.vnet.ibm.com>
References: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:56239 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752610AbdHOPDG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:03:06 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7FExKDw040383
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:05 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2cbucved0h-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:05 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 15 Aug 2017 16:03:03 +0100
In-Reply-To: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

qeth_l2_request_initial_mac() queries the device for its supported
adapterparms, even though they already have been queried as part of the
device's high-level setup. Remove that extra call.

The only call chain for qeth_l2_request_initial_mac() is
__qeth_l2_set_online()
	qeth_core_hardsetup_card()
		qeth_query_setadapterparms()
	qeth_l2_setup_netdev()
		qeth_l2_request_initial_mac()
			qeth_query_setadapterparms()

, and we only reach qeth_l2_request_initial_mac() if the first
adapterparms query succeeds. Hence removing the second query results in
no loss of functionality.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Acked-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 28c9a7eda507..a6ba897ed707 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -519,15 +519,6 @@ static int qeth_l2_request_initial_mac(struct qeth_card *card)
 		/* fall back to alternative mechanism: */
 	}
 
-	if (qeth_is_supported(card, IPA_SETADAPTERPARMS)) {
-		rc = qeth_query_setadapterparms(card);
-		if (rc) {
-			QETH_DBF_MESSAGE(2, "could not query adapter "
-				"parameters on device %s: x%x\n",
-				CARD_BUS_ID(card), rc);
-		}
-	}
-
 	if (card->info.type == QETH_CARD_TYPE_IQD ||
 	    card->info.type == QETH_CARD_TYPE_OSM ||
 	    card->info.type == QETH_CARD_TYPE_OSX ||
-- 
2.11.2
