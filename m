From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH v2 net 2/2] net/smc: dev_put for netdev after usage of ib_query_gid()
Date: Wed, 11 Oct 2017 13:47:23 +0200
Message-ID: <20171011114723.30733-3-ubraun@linux.vnet.ibm.com>
References: <20171011114723.30733-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com,
        parav@mellanox.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:37912 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751983AbdJKLre (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 07:47:34 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9BBhurF106026
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 07:47:33 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dhhqe4evc-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 07:47:33 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 11 Oct 2017 12:47:31 +0100
In-Reply-To: <20171011114723.30733-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For RoCEs ib_query_gid() takes a reference count on the net_device.
This reference count must be decreased by the caller.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reported-by: Parav Pandit <parav@mellanox.com>
Reviewed-by: Parav Pandit <parav@mellanox.com>
Fixes: 0cfdd8f92cac ("smc: connection and link group creation")
---
 net/smc/smc_core.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
index 20b66e79c5d6..5f6a20084157 100644
--- a/net/smc/smc_core.c
+++ b/net/smc/smc_core.c
@@ -380,10 +380,14 @@ static int smc_link_determine_gid(struct smc_link_group *lgr)
 		if (ib_query_gid(lnk->smcibdev->ibdev, lnk->ibport, i, &gid,
 				 &gattr))
 			continue;
-		if (gattr.ndev &&
-		    (vlan_dev_vlan_id(gattr.ndev) == lgr->vlan_id)) {
-			lnk->gid = gid;
-			return 0;
+		if (gattr.ndev) {
+			if (is_vlan_dev(gattr.ndev) &&
+			    vlan_dev_vlan_id(gattr.ndev) == lgr->vlan_id) {
+				lnk->gid = gid;
+				dev_put(gattr.ndev);
+				return 0;
+			}
+			dev_put(gattr.ndev);
 		}
 	}
 	return -ENODEV;
-- 
2.13.5
