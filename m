From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 7/7] s390/qeth: fix setting VIPA address
Date: Thu, 15 Sep 2016 14:39:27 +0200
Message-ID: <20160915123927.86579-8-ubraun@linux.vnet.ibm.com>
References: <20160915123927.86579-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:39882 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934380AbcIOMjm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 08:39:42 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8FCX89l079436
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 08:39:41 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25fk2wj3m9-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 08:39:41 -0400
Received: from localhost
        by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 15 Sep 2016 13:39:39 +0100
In-Reply-To: <20160915123927.86579-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>

commit 5f78e29ceebf ("qeth: optimize IP handling in rx_mode callback")
restructured the internal address handling.
This work broke setting a virtual IP address.
The command
echo 10.1.1.1 > /sys/bus/ccwgroup/devices/<device>/vipa/add4
fails with file exist error even if the IP address has not
been set before.

It turned out that the search result for the IP address
search is handled incorrectly in the VIPA case.

This patch fixes the setting of an virtual IP address.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index c00f6db..272d9e7 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -701,7 +701,7 @@ int qeth_l3_add_vipa(struct qeth_card *card, enum qeth_prot_versions proto,
 
 	spin_lock_bh(&card->ip_lock);
 
-	if (!qeth_l3_ip_from_hash(card, ipaddr))
+	if (qeth_l3_ip_from_hash(card, ipaddr))
 		rc = -EEXIST;
 	else
 		qeth_l3_add_ip(card, ipaddr);
@@ -769,7 +769,7 @@ int qeth_l3_add_rxip(struct qeth_card *card, enum qeth_prot_versions proto,
 
 	spin_lock_bh(&card->ip_lock);
 
-	if (!qeth_l3_ip_from_hash(card, ipaddr))
+	if (qeth_l3_ip_from_hash(card, ipaddr))
 		rc = -EEXIST;
 	else
 		qeth_l3_add_ip(card, ipaddr);
-- 
2.8.4
