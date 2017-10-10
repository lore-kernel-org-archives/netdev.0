From: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH net 1/2] net/smc: replace function pointer get_netdev()
Date: Tue, 10 Oct 2017 16:13:50 +0200
Message-ID: <20171010141351.87700-2-ubraun@linux.vnet.ibm.com>
References: <20171010141351.87700-1-ubraun@linux.vnet.ibm.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jwi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
        schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
        raspl-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
        parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171010141351.87700-1-ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

SMC should not open code the function pointer get_netdev of the
IB device. Replacing ib_query_gid(..., NULL) with
ib_query_gid(..., gid_attr) allows access to the netdev.

Signed-off-by: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Suggested-by: Parav Pandit <parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 net/smc/smc_ib.c | 26 +++++++++-----------------
 1 file changed, 9 insertions(+), 17 deletions(-)

diff --git a/net/smc/smc_ib.c b/net/smc/smc_ib.c
index 0b5852299158..b428c0f6c782 100644
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
+	/* the SMC protocol requires specification of the roce MAC address */
 	rc = smc_ib_fill_gid_and_mac(smcibdev, ibport);
 	if (rc)
 		goto out;
-- 
2.13.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
