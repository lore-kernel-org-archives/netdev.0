From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH V2 net 1/1] smc: switch to usage of IB_PD_UNSAFE_GLOBAL_RKEY
Date: Fri, 12 May 2017 19:09:52 +0200
Message-ID: <20170512170952.39863-2-ubraun@linux.vnet.ibm.com>
References: <20170512170952.39863-1-ubraun@linux.vnet.ibm.com>
Cc: hch@lst.de, netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:39990 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1757717AbdELRKE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 13:10:04 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4CH9fxT086392
        for <netdev@vger.kernel.org>; Fri, 12 May 2017 13:10:03 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2adg802a76-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 12 May 2017 13:10:03 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Fri, 12 May 2017 18:10:00 +0100
In-Reply-To: <20170512170952.39863-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes users aware of the current security implications
when using smc.

The final fix to resolve the reported security issue is worked on;
respective patches will follow as soon as possible.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/smc_clc.c  |  4 ++--
 net/smc/smc_core.c | 16 +++-------------
 net/smc/smc_core.h |  2 +-
 net/smc/smc_ib.c   | 21 ++-------------------
 net/smc/smc_ib.h   |  2 --
 5 files changed, 8 insertions(+), 37 deletions(-)

diff --git a/net/smc/smc_clc.c b/net/smc/smc_clc.c
index e41f594..03ec058 100644
--- a/net/smc/smc_clc.c
+++ b/net/smc/smc_clc.c
@@ -204,7 +204,7 @@ int smc_clc_send_confirm(struct smc_sock *smc)
 	memcpy(&cclc.lcl.mac, &link->smcibdev->mac[link->ibport - 1], ETH_ALEN);
 	hton24(cclc.qpn, link->roce_qp->qp_num);
 	cclc.rmb_rkey =
-		htonl(conn->rmb_desc->mr_rx[SMC_SINGLE_LINK]->rkey);
+		htonl(conn->rmb_desc->rkey[SMC_SINGLE_LINK]);
 	cclc.conn_idx = 1; /* for now: 1 RMB = 1 RMBE */
 	cclc.rmbe_alert_token = htonl(conn->alert_token_local);
 	cclc.qp_mtu = min(link->path_mtu, link->peer_mtu);
@@ -256,7 +256,7 @@ int smc_clc_send_accept(struct smc_sock *new_smc, int srv_first_contact)
 	memcpy(&aclc.lcl.mac, link->smcibdev->mac[link->ibport - 1], ETH_ALEN);
 	hton24(aclc.qpn, link->roce_qp->qp_num);
 	aclc.rmb_rkey =
-		htonl(conn->rmb_desc->mr_rx[SMC_SINGLE_LINK]->rkey);
+		htonl(conn->rmb_desc->rkey[SMC_SINGLE_LINK]);
 	aclc.conn_idx = 1;			/* as long as 1 RMB = 1 RMBE */
 	aclc.rmbe_alert_token = htonl(conn->alert_token_local);
 	aclc.qp_mtu = link->path_mtu;
diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
index 65020e9..3ac09a6 100644
--- a/net/smc/smc_core.c
+++ b/net/smc/smc_core.c
@@ -613,19 +613,8 @@ int smc_rmb_create(struct smc_sock *smc)
 			rmb_desc = NULL;
 			continue; /* if mapping failed, try smaller one */
 		}
-		rc = smc_ib_get_memory_region(lgr->lnk[SMC_SINGLE_LINK].roce_pd,
-					      IB_ACCESS_REMOTE_WRITE |
-					      IB_ACCESS_LOCAL_WRITE,
-					     &rmb_desc->mr_rx[SMC_SINGLE_LINK]);
-		if (rc) {
-			smc_ib_buf_unmap(lgr->lnk[SMC_SINGLE_LINK].smcibdev,
-					 tmp_bufsize, rmb_desc,
-					 DMA_FROM_DEVICE);
-			kfree(rmb_desc->cpu_addr);
-			kfree(rmb_desc);
-			rmb_desc = NULL;
-			continue;
-		}
+		rmb_desc->rkey[SMC_SINGLE_LINK] =
+			lgr->lnk[SMC_SINGLE_LINK].roce_pd->unsafe_global_rkey;
 		rmb_desc->used = 1;
 		write_lock_bh(&lgr->rmbs_lock);
 		list_add(&rmb_desc->list,
@@ -668,6 +657,7 @@ int smc_rmb_rtoken_handling(struct smc_connection *conn,
 
 	for (i = 0; i < SMC_RMBS_PER_LGR_MAX; i++) {
 		if ((lgr->rtokens[i][SMC_SINGLE_LINK].rkey == rkey) &&
+		    (lgr->rtokens[i][SMC_SINGLE_LINK].dma_addr == dma_addr) &&
 		    test_bit(i, lgr->rtokens_used_mask)) {
 			conn->rtoken_idx = i;
 			return 0;
diff --git a/net/smc/smc_core.h b/net/smc/smc_core.h
index 27eb3805..b013cb4 100644
--- a/net/smc/smc_core.h
+++ b/net/smc/smc_core.h
@@ -93,7 +93,7 @@ struct smc_buf_desc {
 	u64			dma_addr[SMC_LINKS_PER_LGR_MAX];
 						/* mapped address of buffer */
 	void			*cpu_addr;	/* virtual address of buffer */
-	struct ib_mr		*mr_rx[SMC_LINKS_PER_LGR_MAX];
+	u32			rkey[SMC_LINKS_PER_LGR_MAX];
 						/* for rmb only:
 						 * rkey provided to peer
 						 */
diff --git a/net/smc/smc_ib.c b/net/smc/smc_ib.c
index cb69ab9..b317155 100644
--- a/net/smc/smc_ib.c
+++ b/net/smc/smc_ib.c
@@ -37,24 +37,6 @@ u8 local_systemid[SMC_SYSTEMID_LEN] = SMC_LOCAL_SYSTEMID_RESET;	/* unique system
 								 * identifier
 								 */
 
-int smc_ib_get_memory_region(struct ib_pd *pd, int access_flags,
-			     struct ib_mr **mr)
-{
-	int rc;
-
-	if (*mr)
-		return 0; /* already done */
-
-	/* obtain unique key -
-	 * next invocation of get_dma_mr returns a different key!
-	 */
-	*mr = pd->device->get_dma_mr(pd, access_flags);
-	rc = PTR_ERR_OR_ZERO(*mr);
-	if (IS_ERR(*mr))
-		*mr = NULL;
-	return rc;
-}
-
 static int smc_ib_modify_qp_init(struct smc_link *lnk)
 {
 	struct ib_qp_attr qp_attr;
@@ -210,7 +192,8 @@ int smc_ib_create_protection_domain(struct smc_link *lnk)
 {
 	int rc;
 
-	lnk->roce_pd = ib_alloc_pd(lnk->smcibdev->ibdev, 0);
+	lnk->roce_pd = ib_alloc_pd(lnk->smcibdev->ibdev,
+				   IB_PD_UNSAFE_GLOBAL_RKEY);
 	rc = PTR_ERR_OR_ZERO(lnk->roce_pd);
 	if (IS_ERR(lnk->roce_pd))
 		lnk->roce_pd = NULL;
diff --git a/net/smc/smc_ib.h b/net/smc/smc_ib.h
index 7e1f0e2..b567152 100644
--- a/net/smc/smc_ib.h
+++ b/net/smc/smc_ib.h
@@ -61,8 +61,6 @@ void smc_ib_dealloc_protection_domain(struct smc_link *lnk);
 int smc_ib_create_protection_domain(struct smc_link *lnk);
 void smc_ib_destroy_queue_pair(struct smc_link *lnk);
 int smc_ib_create_queue_pair(struct smc_link *lnk);
-int smc_ib_get_memory_region(struct ib_pd *pd, int access_flags,
-			     struct ib_mr **mr);
 int smc_ib_ready_link(struct smc_link *lnk);
 int smc_ib_modify_qp_rts(struct smc_link *lnk);
 int smc_ib_modify_qp_reset(struct smc_link *lnk);
-- 
2.10.2
