From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 2/2] net/smc: dev_put for netdev after usage of ib_query_gid()
Date: Tue, 10 Oct 2017 16:13:51 +0200
Message-ID: <20171010141351.87700-3-ubraun@linux.vnet.ibm.com>
References: <20171010141351.87700-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com,
        parav@mellanox.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:50364 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755919AbdJJOOD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 10:14:03 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9AEAklQ073276
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 10:14:02 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dgurrq2yf-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 10:14:02 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Tue, 10 Oct 2017 15:13:59 +0100
In-Reply-To: <20171010141351.87700-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For ROCEs ib_query_gid() takes a reference count on the net_device.
This reference count must be decreased by the caller.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/smc_core.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
index 20b66e79c5d6..e93a31ec3cc2 100644
--- a/net/smc/smc_core.c
+++ b/net/smc/smc_core.c
@@ -380,10 +380,13 @@ static int smc_link_determine_gid(struct smc_link_group *lgr)
 		if (ib_query_gid(lnk->smcibdev->ibdev, lnk->ibport, i, &gid,
 				 &gattr))
 			continue;
-		if (gattr.ndev &&
-		    (vlan_dev_vlan_id(gattr.ndev) == lgr->vlan_id)) {
-			lnk->gid = gid;
-			return 0;
+		if (gattr.ndev) {
+			if (vlan_dev_vlan_id(gattr.ndev) == lgr->vlan_id) {
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
