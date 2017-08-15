From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 12/12] s390/qeth: fix using of ref counter for rxip addresses
Date: Tue, 15 Aug 2017 17:02:50 +0200
Message-ID: <20170815150250.67158-13-jwi@linux.vnet.ibm.com>
References: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:56018 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752694AbdHOPDU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:03:20 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7FF0erB022868
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:19 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2cc0m60063-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:19 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 15 Aug 2017 16:03:16 +0100
In-Reply-To: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kittipon Meesompop <kmeesomp@linux.vnet.ibm.com>

IP-address setting and removal are delayed when the device is not yet in
state SOFTSETUP or UP. ref_counter has been implemented only for
ip-address with type normal. In this patch ref_counter logic is also used
for ip-address with type rxip to allow appropriate handling of multiple
postponed rxip add and del calls.

Signed-off-by: Kittipon Meesompop <kmeesomp@linux.vnet.ibm.com>
Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 41bd00454d0f..0a3dc14a1381 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -247,7 +247,8 @@ int qeth_l3_delete_ip(struct qeth_card *card, struct qeth_ipaddr *tmp_addr)
 		return -ENOENT;
 
 	addr->ref_counter--;
-	if (addr->type == QETH_IP_TYPE_NORMAL && addr->ref_counter > 0)
+	if (addr->ref_counter > 0 && (addr->type == QETH_IP_TYPE_NORMAL ||
+				      addr->type == QETH_IP_TYPE_RXIP))
 		return rc;
 	if (addr->in_progress)
 		return -EINPROGRESS;
@@ -329,8 +330,9 @@ int qeth_l3_add_ip(struct qeth_card *card, struct qeth_ipaddr *tmp_addr)
 			kfree(addr);
 		}
 	} else {
-			if (addr->type == QETH_IP_TYPE_NORMAL)
-				addr->ref_counter++;
+		if (addr->type == QETH_IP_TYPE_NORMAL ||
+		    addr->type == QETH_IP_TYPE_RXIP)
+			addr->ref_counter++;
 	}
 
 	return rc;
-- 
2.11.2
