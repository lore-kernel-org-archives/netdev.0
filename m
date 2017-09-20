From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 04/10] net/smc: adjust net_device refcount
Date: Wed, 20 Sep 2017 13:58:07 +0200
Message-ID: <20170920115813.63745-5-ubraun@linux.vnet.ibm.com>
References: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:38061 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751785AbdITL63 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 07:58:29 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8KBsasQ087179
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:58:28 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2d3nqr95ab-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:58:28 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 20 Sep 2017 12:58:27 +0100
In-Reply-To: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
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
