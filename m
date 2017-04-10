From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 03/10] net/smc: return active RoCE port only
Date: Mon, 10 Apr 2017 14:57:58 +0200
Message-ID: <20170410125805.13653-4-ubraun@linux.vnet.ibm.com>
References: <20170410125805.13653-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:46865 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753310AbdDJM6R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 08:58:17 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3ACtC75122035
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:58:17 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29r99tbq30-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:58:17 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Mon, 10 Apr 2017 13:58:15 +0100
In-Reply-To: <20170410125805.13653-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SMC requires an active ib port on the RoCE device.
smc_pnet_find_roce_resource() determines the matching RoCE device port
according to the configured PNET table. Do not return the found
RoCE device port, if it is not flagged active.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 net/smc/smc_pnet.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/smc/smc_pnet.c b/net/smc/smc_pnet.c
index f1cff01..78f7af2 100644
--- a/net/smc/smc_pnet.c
+++ b/net/smc/smc_pnet.c
@@ -523,8 +523,11 @@ void smc_pnet_find_roce_resource(struct sock *sk,
 	read_lock(&smc_pnettable.lock);
 	list_for_each_entry(pnetelem, &smc_pnettable.pnetlist, list) {
 		if (dst->dev == pnetelem->ndev) {
-			*smcibdev = pnetelem->smcibdev;
-			*ibport = pnetelem->ib_port;
+			if (smc_ib_port_active(pnetelem->smcibdev,
+					       pnetelem->ib_port)) {
+				*smcibdev = pnetelem->smcibdev;
+				*ibport = pnetelem->ib_port;
+			}
 			break;
 		}
 	}
-- 
2.10.2
