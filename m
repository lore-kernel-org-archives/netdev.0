From: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Subject: Re: [PATCH 1/2] IB/rds: Correct ib_api use with gs_dma_address/sg_dma_len
Date: Tue, 25 Dec 2012 13:10:56 +0100
Message-ID: <50D997D0.2020004@acm.org>
References: <20121221175857.23716.46975.stgit@phlsvslse11.ph.intel.com> <20121221180149.23716.54707.stgit@phlsvslse11.ph.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mike Marciniszyn <mike.marciniszyn-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20121221180149.23716.54707.stgit-K+u1se/DcYrLESAwzcoQNrvm/XP+8Wra@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/21/12 19:01, Mike Marciniszyn wrote:
> 0b088e00 ("RDS: Use page_remainder_alloc() for recv bufs")
> added uses of sg_dma_len() and sg_dma_address(). This makes
> RDS DOA with the qib driver.
> 
> IB ulps should use ib_sg_dma_len() and ib_sg_dma_address
> respectively since some HCAs overload ib_sg_dma* operations.
> 
> Signed-off-by: Mike Marciniszyn <mike.marciniszyn-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
>   net/rds/ib_recv.c |    9 ++++++---
>   1 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
> index 8c5bc85..8eb9501 100644
> --- a/net/rds/ib_recv.c
> +++ b/net/rds/ib_recv.c
> @@ -339,8 +339,8 @@ static int rds_ib_recv_refill_one(struct rds_connection *conn,
>   	sge->length = sizeof(struct rds_header);
>   
>   	sge = &recv->r_sge[1];
> -	sge->addr = sg_dma_address(&recv->r_frag->f_sg);
> -	sge->length = sg_dma_len(&recv->r_frag->f_sg);
> +	sge->addr = ib_sg_dma_address(ic->i_cm_id->device, &recv->r_frag->f_sg);
> +	sge->length = ib_sg_dma_len(ic->i_cm_id->device, &recv->r_frag->f_sg);
>   
>   	ret = 0;
>   out:
> @@ -381,7 +381,10 @@ void rds_ib_recv_refill(struct rds_connection *conn, int prefill)
>   		ret = ib_post_recv(ic->i_cm_id->qp, &recv->r_wr, &failed_wr);
>   		rdsdebug("recv %p ibinc %p page %p addr %lu ret %d\n", recv,
>   			 recv->r_ibinc, sg_page(&recv->r_frag->f_sg),
> -			 (long) sg_dma_address(&recv->r_frag->f_sg), ret);
> +			 (long) ib_sg_dma_address(
> +				ic->i_cm_id->device,
> +				&recv->r_frag->f_sg),
> +			ret);
>   		if (ret) {
>   			rds_ib_conn_error(conn, "recv post on "
>   			       "%pI4 returned %d, disconnecting and "

The above patch will slow down RDS for anyone who is not using QLogic
HCA's, isn' it ? How about replacing the above patch with the
(untested) patch below ?

diff --git a/drivers/infiniband/hw/ehca/ehca_mrmw.c b/drivers/infiniband/hw/ehca/ehca_mrmw.c
index 8784486..ec9adf8 100644
--- a/drivers/infiniband/hw/ehca/ehca_mrmw.c
+++ b/drivers/infiniband/hw/ehca/ehca_mrmw.c
@@ -2588,16 +2588,6 @@ static void ehca_dma_unmap_sg(struct ib_device *dev, struct scatterlist *sg,
 	/* This is only a stub; nothing to be done here */
 }
 
-static u64 ehca_dma_address(struct ib_device *dev, struct scatterlist *sg)
-{
-	return sg->dma_address;
-}
-
-static unsigned int ehca_dma_len(struct ib_device *dev, struct scatterlist *sg)
-{
-	return sg->length;
-}
-
 static void ehca_dma_sync_single_for_cpu(struct ib_device *dev, u64 addr,
 					 size_t size,
 					 enum dma_data_direction dir)
@@ -2650,8 +2640,6 @@ struct ib_dma_mapping_ops ehca_dma_mapping_ops = {
 	.unmap_page             = ehca_dma_unmap_page,
 	.map_sg                 = ehca_dma_map_sg,
 	.unmap_sg               = ehca_dma_unmap_sg,
-	.dma_address            = ehca_dma_address,
-	.dma_len                = ehca_dma_len,
 	.sync_single_for_cpu    = ehca_dma_sync_single_for_cpu,
 	.sync_single_for_device = ehca_dma_sync_single_for_device,
 	.alloc_coherent         = ehca_dma_alloc_coherent,
diff --git a/drivers/infiniband/hw/qib/qib_dma.c b/drivers/infiniband/hw/qib/qib_dma.c
index 2920bb3..3620c6c 100644
--- a/drivers/infiniband/hw/qib/qib_dma.c
+++ b/drivers/infiniband/hw/qib/qib_dma.c
@@ -104,7 +104,12 @@ static int qib_map_sg(struct ib_device *dev, struct scatterlist *sgl,
 	for_each_sg(sgl, sg, nents, i) {
 		addr = (u64) page_address(sg_page(sg));
 		/* TODO: handle highmem pages */
-		if (!addr) {
+		if (addr) {
+			sg->dma_address = addr + sg->offset;
+#ifdef CONFIG_NEED_SG_DMA_LENGTH
+			sg->dma_length = sg->length;
+#endif
+		} else {
 			ret = 0;
 			break;
 		}
@@ -119,21 +124,6 @@ static void qib_unmap_sg(struct ib_device *dev,
 	BUG_ON(!valid_dma_direction(direction));
 }
 
-static u64 qib_sg_dma_address(struct ib_device *dev, struct scatterlist *sg)
-{
-	u64 addr = (u64) page_address(sg_page(sg));
-
-	if (addr)
-		addr += sg->offset;
-	return addr;
-}
-
-static unsigned int qib_sg_dma_len(struct ib_device *dev,
-				   struct scatterlist *sg)
-{
-	return sg->length;
-}
-
 static void qib_sync_single_for_cpu(struct ib_device *dev, u64 addr,
 				    size_t size, enum dma_data_direction dir)
 {
@@ -173,8 +163,6 @@ struct ib_dma_mapping_ops qib_dma_mapping_ops = {
 	.unmap_page = qib_dma_unmap_page,
 	.map_sg = qib_map_sg,
 	.unmap_sg = qib_unmap_sg,
-	.dma_address = qib_sg_dma_address,
-	.dma_len = qib_sg_dma_len,
 	.sync_single_for_cpu = qib_sync_single_for_cpu,
 	.sync_single_for_device = qib_sync_single_for_device,
 	.alloc_coherent = qib_dma_alloc_coherent,
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 46bc045..54a0689 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1049,10 +1049,6 @@ struct ib_dma_mapping_ops {
 	void		(*unmap_sg)(struct ib_device *dev,
 				    struct scatterlist *sg, int nents,
 				    enum dma_data_direction direction);
-	u64		(*dma_address)(struct ib_device *dev,
-				       struct scatterlist *sg);
-	unsigned int	(*dma_len)(struct ib_device *dev,
-				   struct scatterlist *sg);
 	void		(*sync_single_for_cpu)(struct ib_device *dev,
 					       u64 dma_handle,
 					       size_t size,
@@ -1863,12 +1859,13 @@ static inline void ib_dma_unmap_sg_attrs(struct ib_device *dev,
  * ib_sg_dma_address - Return the DMA address from a scatter/gather entry
  * @dev: The device for which the DMA addresses were created
  * @sg: The scatter/gather entry
+ *
+ * Note: this function is obsolete. To do: change all occurrences of
+ * ib_sg_dma_address() into sg_dma_address().
  */
 static inline u64 ib_sg_dma_address(struct ib_device *dev,
 				    struct scatterlist *sg)
 {
-	if (dev->dma_ops)
-		return dev->dma_ops->dma_address(dev, sg);
 	return sg_dma_address(sg);
 }
 
@@ -1876,12 +1873,13 @@ static inline u64 ib_sg_dma_address(struct ib_device *dev,
  * ib_sg_dma_len - Return the DMA length from a scatter/gather entry
  * @dev: The device for which the DMA addresses were created
  * @sg: The scatter/gather entry
+ *
+ * Note: this function is obsolete. To do: change all occurrences of
+ * ib_sg_dma_len() into sg_dma_len().
  */
 static inline unsigned int ib_sg_dma_len(struct ib_device *dev,
 					 struct scatterlist *sg)
 {
-	if (dev->dma_ops)
-		return dev->dma_ops->dma_len(dev, sg);
 	return sg_dma_len(sg);
 }
 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
