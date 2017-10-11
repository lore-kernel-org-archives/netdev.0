From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH v2 net 1/2] net/smc: replace function pointer get_netdev()
Date: Wed, 11 Oct 2017 13:47:22 +0200
Message-ID: <20171011114723.30733-2-ubraun@linux.vnet.ibm.com>
References: <20171011114723.30733-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com,
        parav@mellanox.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:60354 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751992AbdJKLre (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 07:47:34 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9BBk9Um128942
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 07:47:33 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dhfn8auhw-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 07:47:33 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 11 Oct 2017 12:47:31 +0100
In-Reply-To: <20171011114723.30733-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SMC should not open code the function pointer get_netdev of the
IB device. Replacing ib_query_gid(..., NULL) with
ib_query_gid(..., gid_attr) allows access to the netdev.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Suggested-by: Parav Pandit <parav@mellanox.com>
Reviewed-by: Parav Pandit <parav@mellanox.com>
---
 net/smc/smc_ib.c | 26 +++++++++-----------------
 1 file changed, 9 insertions(+), 17 deletions(-)

diff --git a/net/smc/smc_ib.c b/net/smc/smc_ib.c
index 0b5852299158..468e1d725d97 100644
--- a/net/smc/smc_ib.c
+++ b/net/smc/smc_ib.c
@@ -369,26 +369,17 @@ void smc_ib_buf_unmap_sg(struct smc_ib_device *smcibdev,
 
 static int smc_ib_fill_gid_and_mac(struct smc_ib_device *smcibdev, u8 ibport)
 {
-	struct net_device *ndev;
+	struct ib_gid_attr gattr;
 	int rc;
 
 	rc = ib_query_gid(smcibdev->ibdev, ibport, 0,
-			  &smcibdev->gid[ibport - 1], NULL);
-	/* the SMC protocol requires specification of the roce MAC address;
-	 * if net_device cannot be determined, it can be derived from gid 0
-	 */
-	ndev = smcibdev->ibdev->get_netdev(smcibdev->ibdev, ibport);
-	if (ndev) {
-		memcpy(&smcibdev->mac, ndev->dev_addr, ETH_ALEN);
-		dev_put(ndev);
-	} else if (!rc) {
-		memcpy(&smcibdev->mac[ibport - 1][0],
-		       &smcibdev->gid[ibport - 1].raw[8], 3);
-		memcpy(&smcibdev->mac[ibport - 1][3],
-		       &smcibdev->gid[ibport - 1].raw[13], 3);
-		smcibdev->mac[ibport - 1][0] &= ~0x02;
-	}
-	return rc;
+			  &smcibdev->gid[ibport - 1], &gattr);
+	if (rc || !gattr.ndev)
+		return -ENODEV;
+
+	memcpy(smcibdev->mac[ibport - 1], gattr.ndev->dev_addr, ETH_ALEN);
+	dev_put(gattr.ndev);
+	return 0;
 }
 
 /* Create an identifier unique for this instance of SMC-R.
@@ -419,6 +410,7 @@ int smc_ib_remember_port_attr(struct smc_ib_device *smcibdev, u8 ibport)
 			   &smcibdev->pattr[ibport - 1]);
 	if (rc)
 		goto out;
+	/* the SMC protocol requires specification of the RoCE MAC address */
 	rc = smc_ib_fill_gid_and_mac(smcibdev, ibport);
 	if (rc)
 		goto out;
-- 
2.13.5
