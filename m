From: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: net/smc and the RDMA core
Date: Thu, 11 May 2017 18:50:04 +0200
Message-ID: <869d9fb6-0d83-5f57-f8e4-5c1ee7477b94@linux.vnet.ibm.com>
References: <20170501163311.GA22209@lst.de>
 <d9214af6-1c6f-9f95-fc00-3e4a316b4f81@linux.vnet.ibm.com>
 <1493750358.2552.13.camel@sandisk.com>
 <1b79048f-4495-3840-e7a6-d4fa5a8dfb57@grimberg.me>
 <20170504084825.GA5399@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>, Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170504084825.GA5399-jcswGhMUV9g@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 05/04/2017 10:48 AM, hch-jcswGhMUV9g@public.gmane.org wrote:
> On Thu, May 04, 2017 at 11:43:50AM +0300, Sagi Grimberg wrote:
>> I would also suggest that you stop exposing the DMA MR for remote
>> access (at least by default) and use a proper reg_mr operations with a
>> limited lifetime on a properly sized buffer.
> 
> Yes, exposing the default DMA MR is a _major_ security risk.  As soon
> as SMC is enabled this will mean a remote system has full read/write
> access to the local systems memory.
> 
> There іs a reason why I removed the ib_get_dma_mr function and replaced
> it with the IB_PD_UNSAFE_GLOBAL_RKEY key that has _UNSAFE_ in the name
> and a very long comment explaining why, and I'm really disappointed that
> we got a driver merged that instead of asking on the relevant list on
> why a change unexpertong a function it needed happened and instead
> tried the hard way to keep a security vulnerarbility alive.
> 

Please consider the following patch to make users aware of the
security implications through existing mechanisms.

Work on proper usage of reg_mr operations is underway, respective
patches will follow as soon as possible.

---
 net/smc/smc_core.c | 16 +++-------------
 net/smc/smc_ib.c   | 21 ++-------------------
 net/smc/smc_ib.h   |  2 --
 3 files changed, 5 insertions(+), 34 deletions(-)

diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
index d52a2ee..6ec3d9a 100644
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
+		rmb_desc->mr_rx[SMC_SINGLE_LINK] =
+			lgr->lnk[SMC_SINGLE_LINK].roce_pd->__internal_mr;
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
diff --git a/net/smc/smc_ib.c b/net/smc/smc_ib.c
index 3d0d91c..6af9ebf 100644
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
@@ -211,7 +193,8 @@ int smc_ib_create_protection_domain(struct smc_link *lnk)
 {
 	int rc;
 
-	lnk->roce_pd = ib_alloc_pd(lnk->smcibdev->ibdev, 0);
+	lnk->roce_pd = ib_alloc_pd(lnk->smcibdev->ibdev,
+				   IB_PD_UNSAFE_GLOBAL_RKEY);
 	rc = PTR_ERR_OR_ZERO(lnk->roce_pd);
 	if (IS_ERR(lnk->roce_pd))
 		lnk->roce_pd = NULL;
diff --git a/net/smc/smc_ib.h b/net/smc/smc_ib.h
index e5bb3c9..55c529b 100644
--- a/net/smc/smc_ib.h
+++ b/net/smc/smc_ib.h
@@ -60,8 +60,6 @@ void smc_ib_dealloc_protection_domain(struct smc_link *lnk);
 int smc_ib_create_protection_domain(struct smc_link *lnk);
 void smc_ib_destroy_queue_pair(struct smc_link *lnk);
 int smc_ib_create_queue_pair(struct smc_link *lnk);
-int smc_ib_get_memory_region(struct ib_pd *pd, int access_flags,
-			     struct ib_mr **mr);
 int smc_ib_ready_link(struct smc_link *lnk);
 int smc_ib_modify_qp_rts(struct smc_link *lnk);
 int smc_ib_modify_qp_reset(struct smc_link *lnk);
-- 

Do you think it is worth the effort for this intermediate patch?

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
