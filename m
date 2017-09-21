From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 4/9] net/smc: adjust net_device refcount
Date: Thu, 21 Sep 2017 09:16:29 +0200
Message-ID: <20170921071634.16883-5-ubraun@linux.vnet.ibm.com>
References: <20170921071634.16883-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:39332 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751840AbdIUHQs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 03:16:48 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8L7EC6P146140
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 03:16:47 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d4624q3xn-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 03:16:47 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 21 Sep 2017 08:16:45 +0100
In-Reply-To: <20170921071634.16883-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

smc_pnet_fill_entry() uses dev_get_by_name() adding a refcount to ndev.
The following smc_pnet_enter() has to reduce the refcount if the entry
to be added exists already in the pnet table.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/smc_pnet.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/smc/smc_pnet.c b/net/smc/smc_pnet.c
index 78f7af28ae4f..31f8453c25c5 100644
--- a/net/smc/smc_pnet.c
+++ b/net/smc/smc_pnet.c
@@ -181,8 +181,10 @@ static int smc_pnet_enter(struct smc_pnetentry *new_pnetelem)
 			     sizeof(new_pnetelem->ndev->name)) ||
 		    smc_pnet_same_ibname(pnetelem,
 					 new_pnetelem->smcibdev->ibdev->name,
-					 new_pnetelem->ib_port))
+					 new_pnetelem->ib_port)) {
+			dev_put(pnetelem->ndev);
 			goto found;
+		}
 	}
 	list_add_tail(&new_pnetelem->list, &smc_pnettable.pnetlist);
 	rc = 0;
-- 
2.13.5
