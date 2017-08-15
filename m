From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 03/12] s390/qeth: remove extra L3 adapterparms query
Date: Tue, 15 Aug 2017 17:02:41 +0200
Message-ID: <20170815150250.67158-4-jwi@linux.vnet.ibm.com>
References: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:45255 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752563AbdHOPDG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:03:06 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7FExMrT042294
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:05 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2cbrdmwmpu-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:04 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 15 Aug 2017 16:03:03 +0100
In-Reply-To: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

qeth_l3_setadapter_parms() queries the device for supported
adapterparms, even though they already have been queried as part of the
device's high-level setup. Remove that extra call.

The only call chain for qeth_l3_setadapter_parms() is
__qeth_l3_set_online()
	qeth_core_hardsetup_card()
		qeth_query_setadapterparms()
	qeth_l3_setadapter_parms()
		qeth_query_setadapterparms()

, and we only reach qeth_l3_setadapter_parms() if the first
adapterparms query succeeds. Hence removing the second query results in
no loss of functionality.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Acked-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 6648f02d61ea..13124e6fd9d3 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -890,22 +890,10 @@ static inline u8 qeth_l3_get_qeth_hdr_flags6(int cast_type)
 
 static int qeth_l3_setadapter_parms(struct qeth_card *card)
 {
-	int rc;
+	int rc = 0;
 
 	QETH_DBF_TEXT(SETUP, 2, "setadprm");
 
-	if (!qeth_is_supported(card, IPA_SETADAPTERPARMS)) {
-		dev_info(&card->gdev->dev,
-			"set adapter parameters not supported.\n");
-		QETH_DBF_TEXT(SETUP, 2, " notsupp");
-		return 0;
-	}
-	rc = qeth_query_setadapterparms(card);
-	if (rc) {
-		QETH_DBF_MESSAGE(2, "%s couldn't set adapter parameters: "
-			"0x%x\n", dev_name(&card->gdev->dev), rc);
-		return rc;
-	}
 	if (qeth_adp_supported(card, IPA_SETADP_ALTER_MAC_ADDRESS)) {
 		rc = qeth_setadpparms_change_macaddr(card);
 		if (rc)
-- 
2.11.2
