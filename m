From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 2/7] s390/qeth: use ip_lock for hsuid configuration
Date: Thu, 15 Sep 2016 14:39:22 +0200
Message-ID: <20160915123927.86579-3-ubraun@linux.vnet.ibm.com>
References: <20160915123927.86579-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:33527 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S933829AbcIOMjj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 08:39:39 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8FCXEwh047294
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 08:39:38 -0400
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com [195.75.94.102])
        by mx0b-001b2d01.pphosted.com with ESMTP id 25fp58a4v7-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 08:39:37 -0400
Received: from localhost
        by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 15 Sep 2016 13:39:36 +0100
In-Reply-To: <20160915123927.86579-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

qeth_l3_dev_hsuid_store() changes the ip hash table, which
requires the ip_lock.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_sys.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/s390/net/qeth_l3_sys.c b/drivers/s390/net/qeth_l3_sys.c
index 65645b1..0e00a5c 100644
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -297,7 +297,9 @@ static ssize_t qeth_l3_dev_hsuid_store(struct device *dev,
 		addr->u.a6.pfxlen = 0;
 		addr->type = QETH_IP_TYPE_NORMAL;
 
+		spin_lock_bh(&card->ip_lock);
 		qeth_l3_delete_ip(card, addr);
+		spin_unlock_bh(&card->ip_lock);
 		kfree(addr);
 	}
 
@@ -329,7 +331,10 @@ static ssize_t qeth_l3_dev_hsuid_store(struct device *dev,
 		addr->type = QETH_IP_TYPE_NORMAL;
 	} else
 		return -ENOMEM;
+
+	spin_lock_bh(&card->ip_lock);
 	qeth_l3_add_ip(card, addr);
+	spin_unlock_bh(&card->ip_lock);
 	kfree(addr);
 
 	return count;
-- 
2.8.4
