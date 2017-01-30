From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/1] smc: some potential use after free bugs
Date: Mon, 30 Jan 2017 10:55:04 +0100
Message-ID: <20170130095504.7940-2-ubraun@linux.vnet.ibm.com>
References: <20170130095504.7940-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com, dan.carpenter@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:32874 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750914AbdA3J4l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 04:56:41 -0500
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U9rbXd138319
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 04:55:14 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0a-001b2d01.pphosted.com with ESMTP id 28a37q04fu-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 04:55:14 -0500
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Mon, 30 Jan 2017 09:55:12 -0000
In-Reply-To: <20170130095504.7940-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>

Say we got really unlucky and these failed on the last iteration, then
it could lead to a use after free bug.

Fixes: cd6851f30386 ("smc: remote memory buffers (RMBs)")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/smc_core.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
index 8b1d343..0eac633 100644
--- a/net/smc/smc_core.c
+++ b/net/smc/smc_core.c
@@ -532,6 +532,7 @@ int smc_sndbuf_create(struct smc_sock *smc)
 						__GFP_NORETRY);
 		if (!sndbuf_desc->cpu_addr) {
 			kfree(sndbuf_desc);
+			sndbuf_desc = NULL;
 			/* if send buffer allocation has failed,
 			 * try a smaller one
 			 */
@@ -543,6 +544,7 @@ int smc_sndbuf_create(struct smc_sock *smc)
 		if (rc) {
 			kfree(sndbuf_desc->cpu_addr);
 			kfree(sndbuf_desc);
+			sndbuf_desc = NULL;
 			continue; /* if mapping failed, try smaller one */
 		}
 		sndbuf_desc->used = 1;
@@ -596,6 +598,7 @@ int smc_rmb_create(struct smc_sock *smc)
 					     __GFP_NORETRY);
 		if (!rmb_desc->cpu_addr) {
 			kfree(rmb_desc);
+			rmb_desc = NULL;
 			/* if RMB allocation has failed,
 			 * try a smaller one
 			 */
@@ -607,6 +610,7 @@ int smc_rmb_create(struct smc_sock *smc)
 		if (rc) {
 			kfree(rmb_desc->cpu_addr);
 			kfree(rmb_desc);
+			rmb_desc = NULL;
 			continue; /* if mapping failed, try smaller one */
 		}
 		rc = smc_ib_get_memory_region(lgr->lnk[SMC_SINGLE_LINK].roce_pd,
@@ -619,6 +623,7 @@ int smc_rmb_create(struct smc_sock *smc)
 					 DMA_FROM_DEVICE);
 			kfree(rmb_desc->cpu_addr);
 			kfree(rmb_desc);
+			rmb_desc = NULL;
 			continue;
 		}
 		rmb_desc->used = 1;
-- 
2.8.4
