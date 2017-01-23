From: Tom Herbert <tom@herbertland.com>
Subject: [RFC PATCH] mlx5: Fix page rfcnt issue
Date: Mon, 23 Jan 2017 15:56:58 -0800
Message-ID: <20170123235658.3872770-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <netdev@vger.kernel.org>, <tariqt@mellanox.com>,
        <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:39736 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750715AbdAWX5Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 18:57:25 -0500
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0NNsNcX001804
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 15:57:09 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 285qs08wrh-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 15:57:09 -0800
Received: from facebook.com (2401:db00:11:d008:face:0:1d:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 a623d2eae1c711e6ac150002c991e86a-a62c1a50 for <netdev@vger.kernel.org>;        Mon,
 23 Jan 2017 15:57:08 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is an FYI about possible issuses in mlx5.

There are two issues we discovered in the mlx5 backport from 4.9 to
4.6...

The bad behaviours we were seeing was a refcnts going to less than zero
and eventually killing hosts. We've only seen this running a real
application work load and it does take a while to trigger. The root
cause is unclear, however this patch seems to circumvent the issue. I
have not been able to reproduce this issue upstream because I haven't
been able to get the app running cleanly. At this point I cannot verify
if it is an upstream issue or not.

Specific issues that I have identified are:

1) In mlx5e_free_rx_mpwqe we are seeing cases where wi->skbs_frags[i] >
   pg_strides so that a negative refcnt is being subtracted. The warning
   at en_rx.c:409 of this patch does trigger.
2) Checksum faults are occurring. I have previously described this
   problem.

As for the checksum faults that seems to be an unrelated issue and I do
believe that was an upstream issue in 4.9, but may have been fixed in
4.10. This is easier to reproduce than the page refcnt issue-- just a
few concurrent netperf TCP_STREAMs was able to trigger the faults.

One other potential problem in the driver is the use of put_page in
release pages.  Comparing how the allocation is done in other drivers
(for instance comparing to ixgbe) some seem to use __free_pages instead.
I don't know which is correct to use, but somehow it doesn't seem like
they can both be right.

This patch:
1) We no longer do the page_ref_sub page_ref_add, instead we take the
   more traditional approach of just doing get_page when giving the
   page to an skb.
2) Add warnings to catch cases where operations on page refcnts are
   nonsensical
3) Comment out checksum-complete processing in order to squelch the
   checksum faults.

---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 20f116f..b24c2b8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -209,6 +209,7 @@ static inline bool mlx5e_rx_cache_get(struct mlx5e_rq *rq,
 	}
 
 	if (page_ref_count(cache->page_cache[cache->head].page) != 1) {
+		WARN_ON(page_ref_count(cache->page_cache[cache->head].page) <= 0);
 		rq->stats.cache_busy++;
 		return false;
 	}
@@ -292,6 +293,13 @@ static inline void mlx5e_add_skb_frag_mpwqe(struct mlx5e_rq *rq,
 				wi->umr.dma_info[page_idx].addr + frag_offset,
 				len, DMA_FROM_DEVICE);
 	wi->skbs_frags[page_idx]++;
+	WARN_ON(wi->skbs_frags[page_idx] > mlx5e_mpwqe_strides_per_page(rq));
+
+	/* Take a page reference every time we give page to skb (alternative
+	 * to original mlx code).
+	 */
+	get_page(wi->umr.dma_info[page_idx].page);
+
 	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
 			wi->umr.dma_info[page_idx].page, frag_offset,
 			len, truesize);
@@ -372,7 +380,6 @@ static int mlx5e_alloc_rx_umr_mpwqe(struct mlx5e_rq *rq,
 		if (unlikely(err))
 			goto err_unmap;
 		wi->umr.mtt[i] = cpu_to_be64(dma_info->addr | MLX5_EN_WR);
-		page_ref_add(dma_info->page, pg_strides);
 		wi->skbs_frags[i] = 0;
 	}
 
@@ -385,7 +392,6 @@ static int mlx5e_alloc_rx_umr_mpwqe(struct mlx5e_rq *rq,
 	while (--i >= 0) {
 		struct mlx5e_dma_info *dma_info = &wi->umr.dma_info[i];
 
-		page_ref_sub(dma_info->page, pg_strides);
 		mlx5e_page_release(rq, dma_info, true);
 	}
 
@@ -400,7 +406,7 @@ void mlx5e_free_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_mpw_info *wi)
 	for (i = 0; i < MLX5_MPWRQ_PAGES_PER_WQE; i++) {
 		struct mlx5e_dma_info *dma_info = &wi->umr.dma_info[i];
 
-		page_ref_sub(dma_info->page, pg_strides - wi->skbs_frags[i]);
+		WARN_ON(pg_strides - wi->skbs_frags[i] < 0);
 		mlx5e_page_release(rq, dma_info, true);
 	}
 }
@@ -565,12 +571,17 @@ static inline void mlx5e_handle_csum(struct net_device *netdev,
 		return;
 	}
 
+#if 0
+	/* Disabled since we are seeing checksum faults occurring. This should
+	 * not have any noticeable impact (in the short term).
+	 */
 	if (is_first_ethertype_ip(skb)) {
 		skb->ip_summed = CHECKSUM_COMPLETE;
 		skb->csum = csum_unfold((__force __sum16)cqe->check_sum);
 		rq->stats.csum_complete++;
 		return;
 	}
+#endif
 
 	if (likely((cqe->hds_ip_ext & CQE_L3_OK) &&
 		   (cqe->hds_ip_ext & CQE_L4_OK))) {
@@ -929,6 +940,7 @@ void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 	if (likely(wi->consumed_strides < rq->mpwqe_num_strides))
 		return;
 
+	WARN_ON(wi->consumed_strides > rq->mpwqe_num_strides);
 	mlx5e_free_rx_mpwqe(rq, wi);
 	mlx5_wq_ll_pop(&rq->wq, cqe->wqe_id, &wqe->next.next_wqe_index);
 }
-- 
2.9.3
