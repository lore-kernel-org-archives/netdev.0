From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bnx2x: remove some bloat
Date: Sat, 28 Apr 2012 09:39:21 +0200
Message-ID: <1335598761.2900.49.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43882 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762Ab2D1Hj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 03:39:27 -0400
Received: by wejx9 with SMTP id x9so864137wej.19
        for <netdev@vger.kernel.org>; Sat, 28 Apr 2012 00:39:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

Before doing skb->head_frag work on bnx2x driver, I found too much stuf=
f
was inlined in bnx2x/bnx2x_cmn.h for no good reason and made my work no=
t
very easy.

Move some big functions out of this include file to the respective .c
file.

A lot of inline keywords are not needed at all in this huge driver.

   text	   data	    bss	    dec	    hex	filename
 490083	   1270	     56	 491409	  77f91	bnx2x/bnx2x.ko.before
 484206	   1270	     56	 485532	  7689c	bnx2x/bnx2x.ko

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Matt Carlson <mcarlson@broadcom.com>
Cc: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c     |  285 +++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h     |  362 ----------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c |   24=20
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c    |  325 ++++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c   |    2=20
 5 files changed, 499 insertions(+), 499 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/=
net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 9c5bc5d..276bc1c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -358,8 +358,8 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *=
fp, u16 queue,
  * Approximate value of the MSS for this aggregation calculated using
  * the first packet of it.
  */
-static inline u16 bnx2x_set_lro_mss(struct bnx2x *bp, u16 parsing_flag=
s,
-				    u16 len_on_bd)
+static u16 bnx2x_set_lro_mss(struct bnx2x *bp, u16 parsing_flags,
+			     u16 len_on_bd)
 {
 	/*
 	 * TPA arrgregation won't have either IP options or TCP options
@@ -385,6 +385,36 @@ static inline u16 bnx2x_set_lro_mss(struct bnx2x *=
bp, u16 parsing_flags,
 	return len_on_bd - hdrs_len;
 }
=20
+static int bnx2x_alloc_rx_sge(struct bnx2x *bp,
+			      struct bnx2x_fastpath *fp, u16 index)
+{
+	struct page *page =3D alloc_pages(GFP_ATOMIC, PAGES_PER_SGE_SHIFT);
+	struct sw_rx_page *sw_buf =3D &fp->rx_page_ring[index];
+	struct eth_rx_sge *sge =3D &fp->rx_sge_ring[index];
+	dma_addr_t mapping;
+
+	if (unlikely(page =3D=3D NULL)) {
+		BNX2X_ERR("Can't alloc sge\n");
+		return -ENOMEM;
+	}
+
+	mapping =3D dma_map_page(&bp->pdev->dev, page, 0,
+			       SGE_PAGE_SIZE*PAGES_PER_SGE, DMA_FROM_DEVICE);
+	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
+		__free_pages(page, PAGES_PER_SGE_SHIFT);
+		BNX2X_ERR("Can't map sge\n");
+		return -ENOMEM;
+	}
+
+	sw_buf->page =3D page;
+	dma_unmap_addr_set(sw_buf, mapping, mapping);
+
+	sge->addr_hi =3D cpu_to_le32(U64_HI(mapping));
+	sge->addr_lo =3D cpu_to_le32(U64_LO(mapping));
+
+	return 0;
+}
+
 static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath=
 *fp,
 			       struct bnx2x_agg_info *tpa_info,
 			       u16 pages,
@@ -483,11 +513,11 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, =
struct bnx2x_fastpath *fp,
 	return 0;
 }
=20
-static inline void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastp=
ath *fp,
-				  struct bnx2x_agg_info *tpa_info,
-				  u16 pages,
-				  struct eth_end_agg_rx_cqe *cqe,
-				  u16 cqe_idx)
+static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp=
,
+			   struct bnx2x_agg_info *tpa_info,
+			   u16 pages,
+			   struct eth_end_agg_rx_cqe *cqe,
+			   u16 cqe_idx)
 {
 	struct sw_rx_bd *rx_buf =3D &tpa_info->first_buf;
 	u8 pad =3D tpa_info->placement_offset;
@@ -557,6 +587,36 @@ drop:
 	fp->eth_q_stats.rx_skb_alloc_failed++;
 }
=20
+static int bnx2x_alloc_rx_data(struct bnx2x *bp,
+			       struct bnx2x_fastpath *fp, u16 index)
+{
+	u8 *data;
+	struct sw_rx_bd *rx_buf =3D &fp->rx_buf_ring[index];
+	struct eth_rx_bd *rx_bd =3D &fp->rx_desc_ring[index];
+	dma_addr_t mapping;
+
+	data =3D kmalloc(fp->rx_buf_size + NET_SKB_PAD, GFP_ATOMIC);
+	if (unlikely(data =3D=3D NULL))
+		return -ENOMEM;
+
+	mapping =3D dma_map_single(&bp->pdev->dev, data + NET_SKB_PAD,
+				 fp->rx_buf_size,
+				 DMA_FROM_DEVICE);
+	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
+		kfree(data);
+		BNX2X_ERR("Can't map rx data\n");
+		return -ENOMEM;
+	}
+
+	rx_buf->data =3D data;
+	dma_unmap_addr_set(rx_buf, mapping, mapping);
+
+	rx_bd->addr_hi =3D cpu_to_le32(U64_HI(mapping));
+	rx_bd->addr_lo =3D cpu_to_le32(U64_LO(mapping));
+
+	return 0;
+}
+
=20
 int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 {
@@ -870,8 +930,8 @@ u16 bnx2x_get_mf_speed(struct bnx2x *bp)
  *
  * It uses a none-atomic bit operations because is called under the mu=
tex.
  */
-static inline void bnx2x_fill_report_data(struct bnx2x *bp,
-					  struct bnx2x_link_report_data *data)
+static void bnx2x_fill_report_data(struct bnx2x *bp,
+				   struct bnx2x_link_report_data *data)
 {
 	u16 line_speed =3D bnx2x_get_mf_speed(bp);
=20
@@ -989,6 +1049,47 @@ void __bnx2x_link_report(struct bnx2x *bp)
 	}
 }
=20
+static void bnx2x_set_next_page_sgl(struct bnx2x_fastpath *fp)
+{
+	int i;
+
+	for (i =3D 1; i <=3D NUM_RX_SGE_PAGES; i++) {
+		struct eth_rx_sge *sge;
+
+		sge =3D &fp->rx_sge_ring[RX_SGE_CNT * i - 2];
+		sge->addr_hi =3D
+			cpu_to_le32(U64_HI(fp->rx_sge_mapping +
+			BCM_PAGE_SIZE*(i % NUM_RX_SGE_PAGES)));
+
+		sge->addr_lo =3D
+			cpu_to_le32(U64_LO(fp->rx_sge_mapping +
+			BCM_PAGE_SIZE*(i % NUM_RX_SGE_PAGES)));
+	}
+}
+
+static void bnx2x_free_tpa_pool(struct bnx2x *bp,
+				struct bnx2x_fastpath *fp, int last)
+{
+	int i;
+
+	for (i =3D 0; i < last; i++) {
+		struct bnx2x_agg_info *tpa_info =3D &fp->tpa_info[i];
+		struct sw_rx_bd *first_buf =3D &tpa_info->first_buf;
+		u8 *data =3D first_buf->data;
+
+		if (data =3D=3D NULL) {
+			DP(NETIF_MSG_IFDOWN, "tpa bin %d empty on free\n", i);
+			continue;
+		}
+		if (tpa_info->tpa_state =3D=3D BNX2X_TPA_START)
+			dma_unmap_single(&bp->pdev->dev,
+					 dma_unmap_addr(first_buf, mapping),
+					 fp->rx_buf_size, DMA_FROM_DEVICE);
+		kfree(data);
+		first_buf->data =3D NULL;
+	}
+}
+
 void bnx2x_init_rx_rings(struct bnx2x *bp)
 {
 	int func =3D BP_FUNC(bp);
@@ -1362,7 +1463,7 @@ static int bnx2x_req_irq(struct bnx2x *bp)
 	return request_irq(irq, bnx2x_interrupt, flags, bp->dev->name, bp->de=
v);
 }
=20
-static inline int bnx2x_setup_irqs(struct bnx2x *bp)
+static int bnx2x_setup_irqs(struct bnx2x *bp)
 {
 	int rc =3D 0;
 	if (bp->flags & USING_MSIX_FLAG &&
@@ -1392,7 +1493,7 @@ static inline int bnx2x_setup_irqs(struct bnx2x *=
bp)
 	return 0;
 }
=20
-static inline void bnx2x_napi_enable(struct bnx2x *bp)
+static void bnx2x_napi_enable(struct bnx2x *bp)
 {
 	int i;
=20
@@ -1400,7 +1501,7 @@ static inline void bnx2x_napi_enable(struct bnx2x=
 *bp)
 		napi_enable(&bnx2x_fp(bp, i, napi));
 }
=20
-static inline void bnx2x_napi_disable(struct bnx2x *bp)
+static void bnx2x_napi_disable(struct bnx2x *bp)
 {
 	int i;
=20
@@ -1487,7 +1588,7 @@ void bnx2x_set_num_queues(struct bnx2x *bp)
  * bnx2x_setup_tc() takes care of the proper TC mappings so that __skb=
_tx_hash()
  * will return a proper Tx index if TC is enabled (netdev->num_tc > 0)=
=2E
  */
-static inline int bnx2x_set_real_num_queues(struct bnx2x *bp)
+static int bnx2x_set_real_num_queues(struct bnx2x *bp)
 {
 	int rc, tx, rx;
=20
@@ -1519,7 +1620,7 @@ static inline int bnx2x_set_real_num_queues(struc=
t bnx2x *bp)
 	return rc;
 }
=20
-static inline void bnx2x_set_rx_buf_size(struct bnx2x *bp)
+static void bnx2x_set_rx_buf_size(struct bnx2x *bp)
 {
 	int i;
=20
@@ -1547,7 +1648,7 @@ static inline void bnx2x_set_rx_buf_size(struct b=
nx2x *bp)
 	}
 }
=20
-static inline int bnx2x_init_rss_pf(struct bnx2x *bp)
+static int bnx2x_init_rss_pf(struct bnx2x *bp)
 {
 	int i;
 	u8 ind_table[T_ETH_INDIRECTION_TABLE_SIZE] =3D {0};
@@ -1614,7 +1715,7 @@ int bnx2x_config_rss_pf(struct bnx2x *bp, struct =
bnx2x_rss_config_obj *rss_obj,
 	return bnx2x_config_rss(bp, &params);
 }
=20
-static inline int bnx2x_init_hw(struct bnx2x *bp, u32 load_code)
+static int bnx2x_init_hw(struct bnx2x *bp, u32 load_code)
 {
 	struct bnx2x_func_state_params func_params =3D {NULL};
=20
@@ -1723,6 +1824,87 @@ bool bnx2x_test_firmware_version(struct bnx2x *b=
p, bool is_err)
 	return true;
 }
=20
+/**
+ * bnx2x_bz_fp - zero content of the fastpath structure.
+ *
+ * @bp:		driver handle
+ * @index:	fastpath index to be zeroed
+ *
+ * Makes sure the contents of the bp->fp[index].napi is kept
+ * intact.
+ */
+static void bnx2x_bz_fp(struct bnx2x *bp, int index)
+{
+	struct bnx2x_fastpath *fp =3D &bp->fp[index];
+	struct napi_struct orig_napi =3D fp->napi;
+	/* bzero bnx2x_fastpath contents */
+	if (bp->stats_init)
+		memset(fp, 0, sizeof(*fp));
+	else {
+		/* Keep Queue statistics */
+		struct bnx2x_eth_q_stats *tmp_eth_q_stats;
+		struct bnx2x_eth_q_stats_old *tmp_eth_q_stats_old;
+
+		tmp_eth_q_stats =3D kzalloc(sizeof(struct bnx2x_eth_q_stats),
+					  GFP_KERNEL);
+		if (tmp_eth_q_stats)
+			memcpy(tmp_eth_q_stats, &fp->eth_q_stats,
+			       sizeof(struct bnx2x_eth_q_stats));
+
+		tmp_eth_q_stats_old =3D
+			kzalloc(sizeof(struct bnx2x_eth_q_stats_old),
+				GFP_KERNEL);
+		if (tmp_eth_q_stats_old)
+			memcpy(tmp_eth_q_stats_old, &fp->eth_q_stats_old,
+			       sizeof(struct bnx2x_eth_q_stats_old));
+
+		memset(fp, 0, sizeof(*fp));
+
+		if (tmp_eth_q_stats) {
+			memcpy(&fp->eth_q_stats, tmp_eth_q_stats,
+				   sizeof(struct bnx2x_eth_q_stats));
+			kfree(tmp_eth_q_stats);
+		}
+
+		if (tmp_eth_q_stats_old) {
+			memcpy(&fp->eth_q_stats_old, tmp_eth_q_stats_old,
+			       sizeof(struct bnx2x_eth_q_stats_old));
+			kfree(tmp_eth_q_stats_old);
+		}
+
+	}
+
+	/* Restore the NAPI object as it has been already initialized */
+	fp->napi =3D orig_napi;
+
+	fp->bp =3D bp;
+	fp->index =3D index;
+	if (IS_ETH_FP(fp))
+		fp->max_cos =3D bp->max_cos;
+	else
+		/* Special queues support only one CoS */
+		fp->max_cos =3D 1;
+
+	/*
+	 * set the tpa flag for each queue. The tpa flag determines the queue
+	 * minimal size so it must be set prior to queue memory allocation
+	 */
+	fp->disable_tpa =3D !(bp->flags & TPA_ENABLE_FLAG ||
+				  (bp->flags & GRO_ENABLE_FLAG &&
+				   bnx2x_mtu_allows_gro(bp->dev->mtu)));
+	if (bp->flags & TPA_ENABLE_FLAG)
+		fp->mode =3D TPA_MODE_LRO;
+	else if (bp->flags & GRO_ENABLE_FLAG)
+		fp->mode =3D TPA_MODE_GRO;
+
+#ifdef BCM_CNIC
+	/* We don't want TPA on an FCoE L2 ring */
+	if (IS_FCOE_FP(fp))
+		fp->disable_tpa =3D 1;
+#endif
+}
+
+
 /* must be called with rtnl_lock */
 int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 {
@@ -3167,7 +3349,7 @@ void bnx2x_free_fp_mem(struct bnx2x *bp)
 		bnx2x_free_fp_mem_at(bp, i);
 }
=20
-static inline void set_sb_shortcuts(struct bnx2x *bp, int index)
+static void set_sb_shortcuts(struct bnx2x *bp, int index)
 {
 	union host_hc_status_block status_blk =3D bnx2x_fp(bp, index, status_=
blk);
 	if (!CHIP_IS_E1x(bp)) {
@@ -3183,6 +3365,63 @@ static inline void set_sb_shortcuts(struct bnx2x=
 *bp, int index)
 	}
 }
=20
+/* Returns the number of actually allocated BDs */
+static int bnx2x_alloc_rx_bds(struct bnx2x_fastpath *fp,
+			      int rx_ring_size)
+{
+	struct bnx2x *bp =3D fp->bp;
+	u16 ring_prod, cqe_ring_prod;
+	int i, failure_cnt =3D 0;
+
+	fp->rx_comp_cons =3D 0;
+	cqe_ring_prod =3D ring_prod =3D 0;
+
+	/* This routine is called only during fo init so
+	 * fp->eth_q_stats.rx_skb_alloc_failed =3D 0
+	 */
+	for (i =3D 0; i < rx_ring_size; i++) {
+		if (bnx2x_alloc_rx_data(bp, fp, ring_prod) < 0) {
+			failure_cnt++;
+			continue;
+		}
+		ring_prod =3D NEXT_RX_IDX(ring_prod);
+		cqe_ring_prod =3D NEXT_RCQ_IDX(cqe_ring_prod);
+		WARN_ON(ring_prod <=3D (i - failure_cnt));
+	}
+
+	if (failure_cnt)
+		BNX2X_ERR("was only able to allocate %d rx skbs on queue[%d]\n",
+			  i - failure_cnt, fp->index);
+
+	fp->rx_bd_prod =3D ring_prod;
+	/* Limit the CQE producer by the CQE ring size */
+	fp->rx_comp_prod =3D min_t(u16, NUM_RCQ_RINGS*RCQ_DESC_CNT,
+			       cqe_ring_prod);
+	fp->rx_pkt =3D fp->rx_calls =3D 0;
+
+	fp->eth_q_stats.rx_skb_alloc_failed +=3D failure_cnt;
+
+	return i - failure_cnt;
+}
+
+static void bnx2x_set_next_page_rx_cq(struct bnx2x_fastpath *fp)
+{
+	int i;
+
+	for (i =3D 1; i <=3D NUM_RCQ_RINGS; i++) {
+		struct eth_rx_cqe_next_page *nextpg;
+
+		nextpg =3D (struct eth_rx_cqe_next_page *)
+			&fp->rx_comp_ring[RCQ_DESC_CNT * i - 1];
+		nextpg->addr_hi =3D
+			cpu_to_le32(U64_HI(fp->rx_comp_mapping +
+				   BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
+		nextpg->addr_lo =3D
+			cpu_to_le32(U64_LO(fp->rx_comp_mapping +
+				   BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
+	}
+}
+
 static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
 {
 	union host_hc_status_block *sb;
@@ -3672,9 +3911,9 @@ void bnx2x_set_ctx_validation(struct bnx2x *bp, s=
truct eth_context *cxt,
 			CDU_REGION_NUMBER_XCM_AG, ETH_CONNECTION_TYPE);
 }
=20
-static inline void storm_memset_hc_timeout(struct bnx2x *bp, u8 port,
-					     u8 fw_sb_id, u8 sb_index,
-					     u8 ticks)
+static void storm_memset_hc_timeout(struct bnx2x *bp, u8 port,
+				    u8 fw_sb_id, u8 sb_index,
+				    u8 ticks)
 {
=20
 	u32 addr =3D BAR_CSTRORM_INTMEM +
@@ -3685,9 +3924,9 @@ static inline void storm_memset_hc_timeout(struct=
 bnx2x *bp, u8 port,
 	   port, fw_sb_id, sb_index, ticks);
 }
=20
-static inline void storm_memset_hc_disable(struct bnx2x *bp, u8 port,
-					     u16 fw_sb_id, u8 sb_index,
-					     u8 disable)
+static void storm_memset_hc_disable(struct bnx2x *bp, u8 port,
+				    u16 fw_sb_id, u8 sb_index,
+				    u8 disable)
 {
 	u32 enable_flag =3D disable ? 0 : (1 << HC_INDEX_DATA_HC_ENABLED_SHIF=
T);
 	u32 addr =3D BAR_CSTRORM_INTMEM +
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/=
net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index cec993b..7cd99b7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -612,53 +612,6 @@ static inline void bnx2x_igu_ack_sb_gen(struct bnx=
2x *bp, u8 igu_sb_id,
 	barrier();
 }
=20
-static inline void bnx2x_igu_clear_sb_gen(struct bnx2x *bp, u8 func,
-					  u8 idu_sb_id, bool is_Pf)
-{
-	u32 data, ctl, cnt =3D 100;
-	u32 igu_addr_data =3D IGU_REG_COMMAND_REG_32LSB_DATA;
-	u32 igu_addr_ctl =3D IGU_REG_COMMAND_REG_CTRL;
-	u32 igu_addr_ack =3D IGU_REG_CSTORM_TYPE_0_SB_CLEANUP + (idu_sb_id/32=
)*4;
-	u32 sb_bit =3D  1 << (idu_sb_id%32);
-	u32 func_encode =3D func | (is_Pf ? 1 : 0) << IGU_FID_ENCODE_IS_PF_SH=
IFT;
-	u32 addr_encode =3D IGU_CMD_E2_PROD_UPD_BASE + idu_sb_id;
-
-	/* Not supported in BC mode */
-	if (CHIP_INT_MODE_IS_BC(bp))
-		return;
-
-	data =3D (IGU_USE_REGISTER_cstorm_type_0_sb_cleanup
-			<< IGU_REGULAR_CLEANUP_TYPE_SHIFT)	|
-		IGU_REGULAR_CLEANUP_SET				|
-		IGU_REGULAR_BCLEANUP;
-
-	ctl =3D addr_encode << IGU_CTRL_REG_ADDRESS_SHIFT		|
-	      func_encode << IGU_CTRL_REG_FID_SHIFT		|
-	      IGU_CTRL_CMD_TYPE_WR << IGU_CTRL_REG_TYPE_SHIFT;
-
-	DP(NETIF_MSG_HW, "write 0x%08x to IGU(via GRC) addr 0x%x\n",
-			 data, igu_addr_data);
-	REG_WR(bp, igu_addr_data, data);
-	mmiowb();
-	barrier();
-	DP(NETIF_MSG_HW, "write 0x%08x to IGU(via GRC) addr 0x%x\n",
-			  ctl, igu_addr_ctl);
-	REG_WR(bp, igu_addr_ctl, ctl);
-	mmiowb();
-	barrier();
-
-	/* wait for clean up to finish */
-	while (!(REG_RD(bp, igu_addr_ack) & sb_bit) && --cnt)
-		msleep(20);
-
-
-	if (!(REG_RD(bp, igu_addr_ack) & sb_bit)) {
-		DP(NETIF_MSG_HW,
-		   "Unable to finish IGU cleanup: idu_sb_id %d offset %d bit %d (cnt=
 %d)\n",
-			  idu_sb_id, idu_sb_id/32, idu_sb_id%32, cnt);
-	}
-}
-
 static inline void bnx2x_hc_ack_sb(struct bnx2x *bp, u8 sb_id,
 				   u8 storm, u16 index, u8 op, u8 update)
 {
@@ -885,66 +838,6 @@ static inline void bnx2x_init_sge_ring_bit_mask(st=
ruct bnx2x_fastpath *fp)
 	bnx2x_clear_sge_mask_next_elems(fp);
 }
=20
-static inline int bnx2x_alloc_rx_sge(struct bnx2x *bp,
-				     struct bnx2x_fastpath *fp, u16 index)
-{
-	struct page *page =3D alloc_pages(GFP_ATOMIC, PAGES_PER_SGE_SHIFT);
-	struct sw_rx_page *sw_buf =3D &fp->rx_page_ring[index];
-	struct eth_rx_sge *sge =3D &fp->rx_sge_ring[index];
-	dma_addr_t mapping;
-
-	if (unlikely(page =3D=3D NULL)) {
-		BNX2X_ERR("Can't alloc sge\n");
-		return -ENOMEM;
-	}
-
-	mapping =3D dma_map_page(&bp->pdev->dev, page, 0,
-			       SGE_PAGE_SIZE*PAGES_PER_SGE, DMA_FROM_DEVICE);
-	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
-		__free_pages(page, PAGES_PER_SGE_SHIFT);
-		BNX2X_ERR("Can't map sge\n");
-		return -ENOMEM;
-	}
-
-	sw_buf->page =3D page;
-	dma_unmap_addr_set(sw_buf, mapping, mapping);
-
-	sge->addr_hi =3D cpu_to_le32(U64_HI(mapping));
-	sge->addr_lo =3D cpu_to_le32(U64_LO(mapping));
-
-	return 0;
-}
-
-static inline int bnx2x_alloc_rx_data(struct bnx2x *bp,
-				      struct bnx2x_fastpath *fp, u16 index)
-{
-	u8 *data;
-	struct sw_rx_bd *rx_buf =3D &fp->rx_buf_ring[index];
-	struct eth_rx_bd *rx_bd =3D &fp->rx_desc_ring[index];
-	dma_addr_t mapping;
-
-	data =3D kmalloc(fp->rx_buf_size + NET_SKB_PAD, GFP_ATOMIC);
-	if (unlikely(data =3D=3D NULL))
-		return -ENOMEM;
-
-	mapping =3D dma_map_single(&bp->pdev->dev, data + NET_SKB_PAD,
-				 fp->rx_buf_size,
-				 DMA_FROM_DEVICE);
-	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
-		kfree(data);
-		BNX2X_ERR("Can't map rx data\n");
-		return -ENOMEM;
-	}
-
-	rx_buf->data =3D data;
-	dma_unmap_addr_set(rx_buf, mapping, mapping);
-
-	rx_bd->addr_hi =3D cpu_to_le32(U64_HI(mapping));
-	rx_bd->addr_lo =3D cpu_to_le32(U64_LO(mapping));
-
-	return 0;
-}
-
 /* note that we are not allocating a new buffer,
  * we are just moving one from cons to prod
  * we are not creating a new mapping,
@@ -1042,66 +935,6 @@ static inline void bnx2x_free_rx_sge_range(struct=
 bnx2x *bp,
 		bnx2x_free_rx_sge(bp, fp, i);
 }
=20
-static inline void bnx2x_free_tpa_pool(struct bnx2x *bp,
-				       struct bnx2x_fastpath *fp, int last)
-{
-	int i;
-
-	for (i =3D 0; i < last; i++) {
-		struct bnx2x_agg_info *tpa_info =3D &fp->tpa_info[i];
-		struct sw_rx_bd *first_buf =3D &tpa_info->first_buf;
-		u8 *data =3D first_buf->data;
-
-		if (data =3D=3D NULL) {
-			DP(NETIF_MSG_IFDOWN, "tpa bin %d empty on free\n", i);
-			continue;
-		}
-		if (tpa_info->tpa_state =3D=3D BNX2X_TPA_START)
-			dma_unmap_single(&bp->pdev->dev,
-					 dma_unmap_addr(first_buf, mapping),
-					 fp->rx_buf_size, DMA_FROM_DEVICE);
-		kfree(data);
-		first_buf->data =3D NULL;
-	}
-}
-
-static inline void bnx2x_init_tx_ring_one(struct bnx2x_fp_txdata *txda=
ta)
-{
-	int i;
-
-	for (i =3D 1; i <=3D NUM_TX_RINGS; i++) {
-		struct eth_tx_next_bd *tx_next_bd =3D
-			&txdata->tx_desc_ring[TX_DESC_CNT * i - 1].next_bd;
-
-		tx_next_bd->addr_hi =3D
-			cpu_to_le32(U64_HI(txdata->tx_desc_mapping +
-				    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
-		tx_next_bd->addr_lo =3D
-			cpu_to_le32(U64_LO(txdata->tx_desc_mapping +
-				    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
-	}
-
-	SET_FLAG(txdata->tx_db.data.header.header, DOORBELL_HDR_DB_TYPE, 1);
-	txdata->tx_db.data.zero_fill1 =3D 0;
-	txdata->tx_db.data.prod =3D 0;
-
-	txdata->tx_pkt_prod =3D 0;
-	txdata->tx_pkt_cons =3D 0;
-	txdata->tx_bd_prod =3D 0;
-	txdata->tx_bd_cons =3D 0;
-	txdata->tx_pkt =3D 0;
-}
-
-static inline void bnx2x_init_tx_rings(struct bnx2x *bp)
-{
-	int i;
-	u8 cos;
-
-	for_each_tx_queue(bp, i)
-		for_each_cos_in_tx_queue(&bp->fp[i], cos)
-			bnx2x_init_tx_ring_one(&bp->fp[i].txdata[cos]);
-}
-
 static inline void bnx2x_set_next_page_rx_bd(struct bnx2x_fastpath *fp=
)
 {
 	int i;
@@ -1119,80 +952,6 @@ static inline void bnx2x_set_next_page_rx_bd(stru=
ct bnx2x_fastpath *fp)
 	}
 }
=20
-static inline void bnx2x_set_next_page_sgl(struct bnx2x_fastpath *fp)
-{
-	int i;
-
-	for (i =3D 1; i <=3D NUM_RX_SGE_PAGES; i++) {
-		struct eth_rx_sge *sge;
-
-		sge =3D &fp->rx_sge_ring[RX_SGE_CNT * i - 2];
-		sge->addr_hi =3D
-			cpu_to_le32(U64_HI(fp->rx_sge_mapping +
-			BCM_PAGE_SIZE*(i % NUM_RX_SGE_PAGES)));
-
-		sge->addr_lo =3D
-			cpu_to_le32(U64_LO(fp->rx_sge_mapping +
-			BCM_PAGE_SIZE*(i % NUM_RX_SGE_PAGES)));
-	}
-}
-
-static inline void bnx2x_set_next_page_rx_cq(struct bnx2x_fastpath *fp=
)
-{
-	int i;
-	for (i =3D 1; i <=3D NUM_RCQ_RINGS; i++) {
-		struct eth_rx_cqe_next_page *nextpg;
-
-		nextpg =3D (struct eth_rx_cqe_next_page *)
-			&fp->rx_comp_ring[RCQ_DESC_CNT * i - 1];
-		nextpg->addr_hi =3D
-			cpu_to_le32(U64_HI(fp->rx_comp_mapping +
-				   BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
-		nextpg->addr_lo =3D
-			cpu_to_le32(U64_LO(fp->rx_comp_mapping +
-				   BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
-	}
-}
-
-/* Returns the number of actually allocated BDs */
-static inline int bnx2x_alloc_rx_bds(struct bnx2x_fastpath *fp,
-				      int rx_ring_size)
-{
-	struct bnx2x *bp =3D fp->bp;
-	u16 ring_prod, cqe_ring_prod;
-	int i, failure_cnt =3D 0;
-
-	fp->rx_comp_cons =3D 0;
-	cqe_ring_prod =3D ring_prod =3D 0;
-
-	/* This routine is called only during fo init so
-	 * fp->eth_q_stats.rx_skb_alloc_failed =3D 0
-	 */
-	for (i =3D 0; i < rx_ring_size; i++) {
-		if (bnx2x_alloc_rx_data(bp, fp, ring_prod) < 0) {
-			failure_cnt++;
-			continue;
-		}
-		ring_prod =3D NEXT_RX_IDX(ring_prod);
-		cqe_ring_prod =3D NEXT_RCQ_IDX(cqe_ring_prod);
-		WARN_ON(ring_prod <=3D (i - failure_cnt));
-	}
-
-	if (failure_cnt)
-		BNX2X_ERR("was only able to allocate %d rx skbs on queue[%d]\n",
-			  i - failure_cnt, fp->index);
-
-	fp->rx_bd_prod =3D ring_prod;
-	/* Limit the CQE producer by the CQE ring size */
-	fp->rx_comp_prod =3D min_t(u16, NUM_RCQ_RINGS*RCQ_DESC_CNT,
-			       cqe_ring_prod);
-	fp->rx_pkt =3D fp->rx_calls =3D 0;
-
-	fp->eth_q_stats.rx_skb_alloc_failed +=3D failure_cnt;
-
-	return i - failure_cnt;
-}
-
 /* Statistics ID are global per chip/path, while Client IDs for E1x ar=
e per
  * port.
  */
@@ -1421,47 +1180,6 @@ static inline void __storm_memset_struct(struct =
bnx2x *bp,
 		REG_WR(bp, addr + (i * 4), data[i]);
 }
=20
-static inline void storm_memset_func_cfg(struct bnx2x *bp,
-				struct tstorm_eth_function_common_config *tcfg,
-				u16 abs_fid)
-{
-	size_t size =3D sizeof(struct tstorm_eth_function_common_config);
-
-	u32 addr =3D BAR_TSTRORM_INTMEM +
-			TSTORM_FUNCTION_COMMON_CONFIG_OFFSET(abs_fid);
-
-	__storm_memset_struct(bp, addr, size, (u32 *)tcfg);
-}
-
-static inline void storm_memset_cmng(struct bnx2x *bp,
-				struct cmng_init *cmng,
-				u8 port)
-{
-	int vn;
-	size_t size =3D sizeof(struct cmng_struct_per_port);
-
-	u32 addr =3D BAR_XSTRORM_INTMEM +
-			XSTORM_CMNG_PER_PORT_VARS_OFFSET(port);
-
-	__storm_memset_struct(bp, addr, size, (u32 *)&cmng->port);
-
-	for (vn =3D VN_0; vn < BP_MAX_VN_NUM(bp); vn++) {
-		int func =3D func_by_vn(bp, vn);
-
-		addr =3D BAR_XSTRORM_INTMEM +
-		       XSTORM_RATE_SHAPING_PER_VN_VARS_OFFSET(func);
-		size =3D sizeof(struct rate_shaping_vars_per_vn);
-		__storm_memset_struct(bp, addr, size,
-				      (u32 *)&cmng->vnic.vnic_max_rate[vn]);
-
-		addr =3D BAR_XSTRORM_INTMEM +
-		       XSTORM_FAIRNESS_PER_VN_VARS_OFFSET(func);
-		size =3D sizeof(struct fairness_vars_per_vn);
-		__storm_memset_struct(bp, addr, size,
-				      (u32 *)&cmng->vnic.vnic_min_rate[vn]);
-	}
-}
-
 /**
  * bnx2x_wait_sp_comp - wait for the outstanding SP commands.
  *
@@ -1544,86 +1262,6 @@ static inline bool bnx2x_mtu_allows_gro(int mtu)
 	 */
 	return mtu <=3D SGE_PAGE_SIZE && (U_ETH_SGL_SIZE * fpp) <=3D MAX_SKB_=
=46RAGS;
 }
-/**
- * bnx2x_bz_fp - zero content of the fastpath structure.
- *
- * @bp:		driver handle
- * @index:	fastpath index to be zeroed
- *
- * Makes sure the contents of the bp->fp[index].napi is kept
- * intact.
- */
-static inline void bnx2x_bz_fp(struct bnx2x *bp, int index)
-{
-	struct bnx2x_fastpath *fp =3D &bp->fp[index];
-	struct napi_struct orig_napi =3D fp->napi;
-	/* bzero bnx2x_fastpath contents */
-	if (bp->stats_init)
-		memset(fp, 0, sizeof(*fp));
-	else {
-		/* Keep Queue statistics */
-		struct bnx2x_eth_q_stats *tmp_eth_q_stats;
-		struct bnx2x_eth_q_stats_old *tmp_eth_q_stats_old;
-
-		tmp_eth_q_stats =3D kzalloc(sizeof(struct bnx2x_eth_q_stats),
-					  GFP_KERNEL);
-		if (tmp_eth_q_stats)
-			memcpy(tmp_eth_q_stats, &fp->eth_q_stats,
-			       sizeof(struct bnx2x_eth_q_stats));
-
-		tmp_eth_q_stats_old =3D
-			kzalloc(sizeof(struct bnx2x_eth_q_stats_old),
-				GFP_KERNEL);
-		if (tmp_eth_q_stats_old)
-			memcpy(tmp_eth_q_stats_old, &fp->eth_q_stats_old,
-			       sizeof(struct bnx2x_eth_q_stats_old));
-
-		memset(fp, 0, sizeof(*fp));
-
-		if (tmp_eth_q_stats) {
-			memcpy(&fp->eth_q_stats, tmp_eth_q_stats,
-				   sizeof(struct bnx2x_eth_q_stats));
-			kfree(tmp_eth_q_stats);
-		}
-
-		if (tmp_eth_q_stats_old) {
-			memcpy(&fp->eth_q_stats_old, tmp_eth_q_stats_old,
-			       sizeof(struct bnx2x_eth_q_stats_old));
-			kfree(tmp_eth_q_stats_old);
-		}
-
-	}
-
-	/* Restore the NAPI object as it has been already initialized */
-	fp->napi =3D orig_napi;
-
-	fp->bp =3D bp;
-	fp->index =3D index;
-	if (IS_ETH_FP(fp))
-		fp->max_cos =3D bp->max_cos;
-	else
-		/* Special queues support only one CoS */
-		fp->max_cos =3D 1;
-
-	/*
-	 * set the tpa flag for each queue. The tpa flag determines the queue
-	 * minimal size so it must be set prior to queue memory allocation
-	 */
-	fp->disable_tpa =3D !(bp->flags & TPA_ENABLE_FLAG ||
-				  (bp->flags & GRO_ENABLE_FLAG &&
-				   bnx2x_mtu_allows_gro(bp->dev->mtu)));
-	if (bp->flags & TPA_ENABLE_FLAG)
-		fp->mode =3D TPA_MODE_LRO;
-	else if (bp->flags & GRO_ENABLE_FLAG)
-		fp->mode =3D TPA_MODE_GRO;
-
-#ifdef BCM_CNIC
-	/* We don't want TPA on an FCoE L2 ring */
-	if (IS_FCOE_FP(fp))
-		fp->disable_tpa =3D 1;
-#endif
-}
-
 #ifdef BCM_CNIC
 /**
  * bnx2x_get_iscsi_info - update iSCSI params according to licensing i=
nfo.
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/driv=
ers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index faf8abd..ddc18ee 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -592,8 +592,8 @@ static int bnx2x_set_settings(struct net_device *de=
v, struct ethtool_cmd *cmd)
 #define IS_E3_ONLINE(info)	(((info) & RI_E3_ONLINE) =3D=3D RI_E3_ONLIN=
E)
 #define IS_E3B0_ONLINE(info)	(((info) & RI_E3B0_ONLINE) =3D=3D RI_E3B0=
_ONLINE)
=20
-static inline bool bnx2x_is_reg_online(struct bnx2x *bp,
-				       const struct reg_addr *reg_info)
+static bool bnx2x_is_reg_online(struct bnx2x *bp,
+				const struct reg_addr *reg_info)
 {
 	if (CHIP_IS_E1(bp))
 		return IS_E1_ONLINE(reg_info->info);
@@ -610,7 +610,7 @@ static inline bool bnx2x_is_reg_online(struct bnx2x=
 *bp,
 }
=20
 /******* Paged registers info selectors ********/
-static inline const u32 *__bnx2x_get_page_addr_ar(struct bnx2x *bp)
+static const u32 *__bnx2x_get_page_addr_ar(struct bnx2x *bp)
 {
 	if (CHIP_IS_E2(bp))
 		return page_vals_e2;
@@ -620,7 +620,7 @@ static inline const u32 *__bnx2x_get_page_addr_ar(s=
truct bnx2x *bp)
 		return NULL;
 }
=20
-static inline u32 __bnx2x_get_page_reg_num(struct bnx2x *bp)
+static u32 __bnx2x_get_page_reg_num(struct bnx2x *bp)
 {
 	if (CHIP_IS_E2(bp))
 		return PAGE_MODE_VALUES_E2;
@@ -630,7 +630,7 @@ static inline u32 __bnx2x_get_page_reg_num(struct b=
nx2x *bp)
 		return 0;
 }
=20
-static inline const u32 *__bnx2x_get_page_write_ar(struct bnx2x *bp)
+static const u32 *__bnx2x_get_page_write_ar(struct bnx2x *bp)
 {
 	if (CHIP_IS_E2(bp))
 		return page_write_regs_e2;
@@ -640,7 +640,7 @@ static inline const u32 *__bnx2x_get_page_write_ar(=
struct bnx2x *bp)
 		return NULL;
 }
=20
-static inline u32 __bnx2x_get_page_write_num(struct bnx2x *bp)
+static u32 __bnx2x_get_page_write_num(struct bnx2x *bp)
 {
 	if (CHIP_IS_E2(bp))
 		return PAGE_WRITE_REGS_E2;
@@ -650,7 +650,7 @@ static inline u32 __bnx2x_get_page_write_num(struct=
 bnx2x *bp)
 		return 0;
 }
=20
-static inline const struct reg_addr *__bnx2x_get_page_read_ar(struct b=
nx2x *bp)
+static const struct reg_addr *__bnx2x_get_page_read_ar(struct bnx2x *b=
p)
 {
 	if (CHIP_IS_E2(bp))
 		return page_read_regs_e2;
@@ -660,7 +660,7 @@ static inline const struct reg_addr *__bnx2x_get_pa=
ge_read_ar(struct bnx2x *bp)
 		return NULL;
 }
=20
-static inline u32 __bnx2x_get_page_read_num(struct bnx2x *bp)
+static u32 __bnx2x_get_page_read_num(struct bnx2x *bp)
 {
 	if (CHIP_IS_E2(bp))
 		return PAGE_READ_REGS_E2;
@@ -670,7 +670,7 @@ static inline u32 __bnx2x_get_page_read_num(struct =
bnx2x *bp)
 		return 0;
 }
=20
-static inline int __bnx2x_get_regs_len(struct bnx2x *bp)
+static int __bnx2x_get_regs_len(struct bnx2x *bp)
 {
 	int num_pages =3D __bnx2x_get_page_reg_num(bp);
 	int page_write_num =3D __bnx2x_get_page_write_num(bp);
@@ -715,7 +715,7 @@ static int bnx2x_get_regs_len(struct net_device *de=
v)
  * ("read address"). There may be more than one write address per "pag=
e" and
  * more than one read address per write address.
  */
-static inline void bnx2x_read_pages_regs(struct bnx2x *bp, u32 *p)
+static void bnx2x_read_pages_regs(struct bnx2x *bp, u32 *p)
 {
 	u32 i, j, k, n;
 	/* addresses of the paged registers */
@@ -744,7 +744,7 @@ static inline void bnx2x_read_pages_regs(struct bnx=
2x *bp, u32 *p)
 	}
 }
=20
-static inline void __bnx2x_get_regs(struct bnx2x *bp, u32 *p)
+static void __bnx2x_get_regs(struct bnx2x *bp, u32 *p)
 {
 	u32 i, j;
=20
@@ -2209,7 +2209,7 @@ static void bnx2x_self_test(struct net_device *de=
v,
 /* ethtool statistics are displayed for all regular ethernet queues an=
d the
  * fcoe L2 queue if not disabled
  */
-static inline int bnx2x_num_stat_queues(struct bnx2x *bp)
+static int bnx2x_num_stat_queues(struct bnx2x *bp)
 {
 	return BNX2X_NUM_ETH_QUEUES(bp);
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers=
/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 0708cb8..35b82e0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -226,15 +226,15 @@ static LIST_HEAD(bnx2x_prev_list);
 * General service functions
 **********************************************************************=
******/
=20
-static inline void __storm_memset_dma_mapping(struct bnx2x *bp,
+static void __storm_memset_dma_mapping(struct bnx2x *bp,
 				       u32 addr, dma_addr_t mapping)
 {
 	REG_WR(bp,  addr, U64_LO(mapping));
 	REG_WR(bp,  addr + 4, U64_HI(mapping));
 }
=20
-static inline void storm_memset_spq_addr(struct bnx2x *bp,
-					 dma_addr_t mapping, u16 abs_fid)
+static void storm_memset_spq_addr(struct bnx2x *bp,
+				  dma_addr_t mapping, u16 abs_fid)
 {
 	u32 addr =3D XSEM_REG_FAST_MEMORY +
 			XSTORM_SPQ_PAGE_BASE_OFFSET(abs_fid);
@@ -242,8 +242,8 @@ static inline void storm_memset_spq_addr(struct bnx=
2x *bp,
 	__storm_memset_dma_mapping(bp, addr, mapping);
 }
=20
-static inline void storm_memset_vf_to_pf(struct bnx2x *bp, u16 abs_fid=
,
-					 u16 pf_id)
+static void storm_memset_vf_to_pf(struct bnx2x *bp, u16 abs_fid,
+				  u16 pf_id)
 {
 	REG_WR8(bp, BAR_XSTRORM_INTMEM + XSTORM_VF_TO_PF_OFFSET(abs_fid),
 		pf_id);
@@ -255,8 +255,8 @@ static inline void storm_memset_vf_to_pf(struct bnx=
2x *bp, u16 abs_fid,
 		pf_id);
 }
=20
-static inline void storm_memset_func_en(struct bnx2x *bp, u16 abs_fid,
-					u8 enable)
+static void storm_memset_func_en(struct bnx2x *bp, u16 abs_fid,
+				 u8 enable)
 {
 	REG_WR8(bp, BAR_XSTRORM_INTMEM + XSTORM_FUNC_EN_OFFSET(abs_fid),
 		enable);
@@ -268,8 +268,8 @@ static inline void storm_memset_func_en(struct bnx2=
x *bp, u16 abs_fid,
 		enable);
 }
=20
-static inline void storm_memset_eq_data(struct bnx2x *bp,
-				struct event_ring_data *eq_data,
+static void storm_memset_eq_data(struct bnx2x *bp,
+				 struct event_ring_data *eq_data,
 				u16 pfid)
 {
 	size_t size =3D sizeof(struct event_ring_data);
@@ -279,8 +279,8 @@ static inline void storm_memset_eq_data(struct bnx2=
x *bp,
 	__storm_memset_struct(bp, addr, size, (u32 *)eq_data);
 }
=20
-static inline void storm_memset_eq_prod(struct bnx2x *bp, u16 eq_prod,
-					u16 pfid)
+static void storm_memset_eq_prod(struct bnx2x *bp, u16 eq_prod,
+				 u16 pfid)
 {
 	u32 addr =3D BAR_CSTRORM_INTMEM + CSTORM_EVENT_RING_PROD_OFFSET(pfid)=
;
 	REG_WR16(bp, addr, eq_prod);
@@ -676,7 +676,7 @@ void bnx2x_fw_dump_lvl(struct bnx2x *bp, const char=
 *lvl)
 	printk("%s" "end of fw dump\n", lvl);
 }
=20
-static inline void bnx2x_fw_dump(struct bnx2x *bp)
+static void bnx2x_fw_dump(struct bnx2x *bp)
 {
 	bnx2x_fw_dump_lvl(bp, KERN_ERR);
 }
@@ -996,8 +996,8 @@ static void bnx2x_pbf_pN_cmd_flushed(struct bnx2x *=
bp,
 	   poll_count-cur_cnt, FLR_WAIT_INTERVAL, regs->pN);
 }
=20
-static inline u32 bnx2x_flr_clnup_reg_poll(struct bnx2x *bp, u32 reg,
-				     u32 expected, u32 poll_count)
+static u32 bnx2x_flr_clnup_reg_poll(struct bnx2x *bp, u32 reg,
+				    u32 expected, u32 poll_count)
 {
 	u32 cur_cnt =3D poll_count;
 	u32 val;
@@ -1008,8 +1008,8 @@ static inline u32 bnx2x_flr_clnup_reg_poll(struct=
 bnx2x *bp, u32 reg,
 	return val;
 }
=20
-static inline int bnx2x_flr_clnup_poll_hw_counter(struct bnx2x *bp, u3=
2 reg,
-						  char *msg, u32 poll_cnt)
+static int bnx2x_flr_clnup_poll_hw_counter(struct bnx2x *bp, u32 reg,
+					   char *msg, u32 poll_cnt)
 {
 	u32 val =3D bnx2x_flr_clnup_reg_poll(bp, reg, 0, poll_cnt);
 	if (val !=3D 0) {
@@ -1106,7 +1106,7 @@ static void bnx2x_tx_hw_flushed(struct bnx2x *bp,=
 u32 poll_count)
 	(((index) << SDM_OP_GEN_AGG_VECT_IDX_SHIFT) & SDM_OP_GEN_AGG_VECT_IDX=
)
=20
=20
-static inline int bnx2x_send_final_clnup(struct bnx2x *bp, u8 clnup_fu=
nc,
+static int bnx2x_send_final_clnup(struct bnx2x *bp, u8 clnup_func,
 					 u32 poll_cnt)
 {
 	struct sdm_op_gen op_gen =3D {0};
@@ -1140,7 +1140,7 @@ static inline int bnx2x_send_final_clnup(struct b=
nx2x *bp, u8 clnup_func,
 	return ret;
 }
=20
-static inline u8 bnx2x_is_pcie_pending(struct pci_dev *dev)
+static u8 bnx2x_is_pcie_pending(struct pci_dev *dev)
 {
 	int pos;
 	u16 status;
@@ -1550,7 +1550,7 @@ static bool bnx2x_trylock_hw_lock(struct bnx2x *b=
p, u32 resource)
  * Returns the recovery leader resource id according to the engine thi=
s function
  * belongs to. Currently only only 2 engines is supported.
  */
-static inline int bnx2x_get_leader_lock_resource(struct bnx2x *bp)
+static int bnx2x_get_leader_lock_resource(struct bnx2x *bp)
 {
 	if (BP_PATH(bp))
 		return HW_LOCK_RESOURCE_RECOVERY_LEADER_1;
@@ -1563,9 +1563,9 @@ static inline int bnx2x_get_leader_lock_resource(=
struct bnx2x *bp)
  *
  * @bp: driver handle
  *
- * Tries to aquire a leader lock for cuurent engine.
+ * Tries to aquire a leader lock for current engine.
  */
-static inline bool bnx2x_trylock_leader_lock(struct bnx2x *bp)
+static bool bnx2x_trylock_leader_lock(struct bnx2x *bp)
 {
 	return bnx2x_trylock_hw_lock(bp, bnx2x_get_leader_lock_resource(bp));
 }
@@ -2331,6 +2331,35 @@ static void bnx2x_cmng_fns_init(struct bnx2x *bp=
, u8 read_cfg, u8 cmng_type)
 	   "rate shaping and fairness are disabled\n");
 }
=20
+static void storm_memset_cmng(struct bnx2x *bp,
+			      struct cmng_init *cmng,
+			      u8 port)
+{
+	int vn;
+	size_t size =3D sizeof(struct cmng_struct_per_port);
+
+	u32 addr =3D BAR_XSTRORM_INTMEM +
+			XSTORM_CMNG_PER_PORT_VARS_OFFSET(port);
+
+	__storm_memset_struct(bp, addr, size, (u32 *)&cmng->port);
+
+	for (vn =3D VN_0; vn < BP_MAX_VN_NUM(bp); vn++) {
+		int func =3D func_by_vn(bp, vn);
+
+		addr =3D BAR_XSTRORM_INTMEM +
+		       XSTORM_RATE_SHAPING_PER_VN_VARS_OFFSET(func);
+		size =3D sizeof(struct rate_shaping_vars_per_vn);
+		__storm_memset_struct(bp, addr, size,
+				      (u32 *)&cmng->vnic.vnic_max_rate[vn]);
+
+		addr =3D BAR_XSTRORM_INTMEM +
+		       XSTORM_FAIRNESS_PER_VN_VARS_OFFSET(func);
+		size =3D sizeof(struct fairness_vars_per_vn);
+		__storm_memset_struct(bp, addr, size,
+				      (u32 *)&cmng->vnic.vnic_min_rate[vn]);
+	}
+}
+
 /* This function is called upon link interrupt */
 static void bnx2x_link_attn(struct bnx2x *bp)
 {
@@ -2671,6 +2700,18 @@ u32 bnx2x_fw_command(struct bnx2x *bp, u32 comma=
nd, u32 param)
 }
=20
=20
+static void storm_memset_func_cfg(struct bnx2x *bp,
+				 struct tstorm_eth_function_common_config *tcfg,
+				 u16 abs_fid)
+{
+	size_t size =3D sizeof(struct tstorm_eth_function_common_config);
+
+	u32 addr =3D BAR_TSTRORM_INTMEM +
+			TSTORM_FUNCTION_COMMON_CONFIG_OFFSET(abs_fid);
+
+	__storm_memset_struct(bp, addr, size, (u32 *)tcfg);
+}
+
 void bnx2x_func_init(struct bnx2x *bp, struct bnx2x_func_init_params *=
p)
 {
 	if (CHIP_IS_E1x(bp)) {
@@ -2700,9 +2741,9 @@ void bnx2x_func_init(struct bnx2x *bp, struct bnx=
2x_func_init_params *p)
  *
  * Return the flags that are common for the Tx-only and not normal con=
nections.
  */
-static inline unsigned long bnx2x_get_common_flags(struct bnx2x *bp,
-						   struct bnx2x_fastpath *fp,
-						   bool zero_stats)
+static unsigned long bnx2x_get_common_flags(struct bnx2x *bp,
+					    struct bnx2x_fastpath *fp,
+					    bool zero_stats)
 {
 	unsigned long flags =3D 0;
=20
@@ -2722,9 +2763,9 @@ static inline unsigned long bnx2x_get_common_flag=
s(struct bnx2x *bp,
 	return flags;
 }
=20
-static inline unsigned long bnx2x_get_q_flags(struct bnx2x *bp,
-					      struct bnx2x_fastpath *fp,
-					      bool leading)
+static unsigned long bnx2x_get_q_flags(struct bnx2x *bp,
+				       struct bnx2x_fastpath *fp,
+				       bool leading)
 {
 	unsigned long flags =3D 0;
=20
@@ -3117,7 +3158,7 @@ static void bnx2x_drv_info_iscsi_stat(struct bnx2=
x *bp)
  *	configure FW
  *	notify others function about the change
  */
-static inline void bnx2x_config_mf_bw(struct bnx2x *bp)
+static void bnx2x_config_mf_bw(struct bnx2x *bp)
 {
 	if (bp->link_vars.link_up) {
 		bnx2x_cmng_fns_init(bp, true, CMNG_FNS_MINMAX);
@@ -3126,7 +3167,7 @@ static inline void bnx2x_config_mf_bw(struct bnx2=
x *bp)
 	storm_memset_cmng(bp, &bp->cmng, BP_PORT(bp));
 }
=20
-static inline void bnx2x_set_mf_bw(struct bnx2x *bp)
+static void bnx2x_set_mf_bw(struct bnx2x *bp)
 {
 	bnx2x_config_mf_bw(bp);
 	bnx2x_fw_command(bp, DRV_MSG_CODE_SET_MF_BW_ACK, 0);
@@ -3213,7 +3254,7 @@ static void bnx2x_dcc_event(struct bnx2x *bp, u32=
 dcc_event)
 }
=20
 /* must be called under the spq lock */
-static inline struct eth_spe *bnx2x_sp_get_next(struct bnx2x *bp)
+static struct eth_spe *bnx2x_sp_get_next(struct bnx2x *bp)
 {
 	struct eth_spe *next_spe =3D bp->spq_prod_bd;
=20
@@ -3229,7 +3270,7 @@ static inline struct eth_spe *bnx2x_sp_get_next(s=
truct bnx2x *bp)
 }
=20
 /* must be called under the spq lock */
-static inline void bnx2x_sp_prod_update(struct bnx2x *bp)
+static void bnx2x_sp_prod_update(struct bnx2x *bp)
 {
 	int func =3D BP_FUNC(bp);
=20
@@ -3251,7 +3292,7 @@ static inline void bnx2x_sp_prod_update(struct bn=
x2x *bp)
  * @cmd:	command to check
  * @cmd_type:	command type
  */
-static inline bool bnx2x_is_contextless_ramrod(int cmd, int cmd_type)
+static bool bnx2x_is_contextless_ramrod(int cmd, int cmd_type)
 {
 	if ((cmd_type =3D=3D NONE_CONNECTION_TYPE) ||
 	    (cmd =3D=3D RAMROD_CMD_ID_ETH_FORWARD_SETUP) ||
@@ -3385,7 +3426,7 @@ static void bnx2x_release_alr(struct bnx2x *bp)
 #define BNX2X_DEF_SB_ATT_IDX	0x0001
 #define BNX2X_DEF_SB_IDX	0x0002
=20
-static inline u16 bnx2x_update_dsb_idx(struct bnx2x *bp)
+static u16 bnx2x_update_dsb_idx(struct bnx2x *bp)
 {
 	struct host_sp_status_block *def_sb =3D bp->def_status_blk;
 	u16 rc =3D 0;
@@ -3517,7 +3558,7 @@ static void bnx2x_attn_int_asserted(struct bnx2x =
*bp, u32 asserted)
 	}
 }
=20
-static inline void bnx2x_fan_failure(struct bnx2x *bp)
+static void bnx2x_fan_failure(struct bnx2x *bp)
 {
 	int port =3D BP_PORT(bp);
 	u32 ext_phy_config;
@@ -3547,7 +3588,7 @@ static inline void bnx2x_fan_failure(struct bnx2x=
 *bp)
=20
 }
=20
-static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 at=
tn)
+static void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
 {
 	int port =3D BP_PORT(bp);
 	int reg_offset;
@@ -3587,7 +3628,7 @@ static inline void bnx2x_attn_int_deasserted0(str=
uct bnx2x *bp, u32 attn)
 	}
 }
=20
-static inline void bnx2x_attn_int_deasserted1(struct bnx2x *bp, u32 at=
tn)
+static void bnx2x_attn_int_deasserted1(struct bnx2x *bp, u32 attn)
 {
 	u32 val;
=20
@@ -3618,7 +3659,7 @@ static inline void bnx2x_attn_int_deasserted1(str=
uct bnx2x *bp, u32 attn)
 	}
 }
=20
-static inline void bnx2x_attn_int_deasserted2(struct bnx2x *bp, u32 at=
tn)
+static void bnx2x_attn_int_deasserted2(struct bnx2x *bp, u32 attn)
 {
 	u32 val;
=20
@@ -3662,7 +3703,7 @@ static inline void bnx2x_attn_int_deasserted2(str=
uct bnx2x *bp, u32 attn)
 	}
 }
=20
-static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 at=
tn)
+static void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
 {
 	u32 val;
=20
@@ -3792,7 +3833,7 @@ void bnx2x_set_reset_global(struct bnx2x *bp)
  *
  * Should be run under rtnl lock
  */
-static inline void bnx2x_clear_reset_global(struct bnx2x *bp)
+static void bnx2x_clear_reset_global(struct bnx2x *bp)
 {
 	u32 val;
 	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_RECOVERY_REG);
@@ -3806,7 +3847,7 @@ static inline void bnx2x_clear_reset_global(struc=
t bnx2x *bp)
  *
  * should be run under rtnl lock
  */
-static inline bool bnx2x_reset_is_global(struct bnx2x *bp)
+static bool bnx2x_reset_is_global(struct bnx2x *bp)
 {
 	u32 val	=3D REG_RD(bp, BNX2X_RECOVERY_GLOB_REG);
=20
@@ -3819,7 +3860,7 @@ static inline bool bnx2x_reset_is_global(struct b=
nx2x *bp)
  *
  * Should be run under rtnl lock
  */
-static inline void bnx2x_set_reset_done(struct bnx2x *bp)
+static void bnx2x_set_reset_done(struct bnx2x *bp)
 {
 	u32 val;
 	u32 bit =3D BP_PATH(bp) ?
@@ -3944,7 +3985,7 @@ bool bnx2x_clear_pf_load(struct bnx2x *bp)
  *
  * should be run under rtnl lock
  */
-static inline bool bnx2x_get_load_status(struct bnx2x *bp, int engine)
+static bool bnx2x_get_load_status(struct bnx2x *bp, int engine)
 {
 	u32 mask =3D (engine ? BNX2X_PATH1_LOAD_CNT_MASK :
 			     BNX2X_PATH0_LOAD_CNT_MASK);
@@ -3965,7 +4006,7 @@ static inline bool bnx2x_get_load_status(struct b=
nx2x *bp, int engine)
 /*
  * Reset the load status for the current engine.
  */
-static inline void bnx2x_clear_load_status(struct bnx2x *bp)
+static void bnx2x_clear_load_status(struct bnx2x *bp)
 {
 	u32 val;
 	u32 mask =3D (BP_PATH(bp) ? BNX2X_PATH1_LOAD_CNT_MASK :
@@ -3976,13 +4017,13 @@ static inline void bnx2x_clear_load_status(stru=
ct bnx2x *bp)
 	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RECOVERY_REG);
 }
=20
-static inline void _print_next_block(int idx, const char *blk)
+static void _print_next_block(int idx, const char *blk)
 {
 	pr_cont("%s%s", idx ? ", " : "", blk);
 }
=20
-static inline int bnx2x_check_blocks_with_parity0(u32 sig, int par_num=
,
-						  bool print)
+static int bnx2x_check_blocks_with_parity0(u32 sig, int par_num,
+					   bool print)
 {
 	int i =3D 0;
 	u32 cur_bit =3D 0;
@@ -4029,8 +4070,8 @@ static inline int bnx2x_check_blocks_with_parity0=
(u32 sig, int par_num,
 	return par_num;
 }
=20
-static inline int bnx2x_check_blocks_with_parity1(u32 sig, int par_num=
,
-						  bool *global, bool print)
+static int bnx2x_check_blocks_with_parity1(u32 sig, int par_num,
+					   bool *global, bool print)
 {
 	int i =3D 0;
 	u32 cur_bit =3D 0;
@@ -4115,8 +4156,8 @@ static inline int bnx2x_check_blocks_with_parity1=
(u32 sig, int par_num,
 	return par_num;
 }
=20
-static inline int bnx2x_check_blocks_with_parity2(u32 sig, int par_num=
,
-						  bool print)
+static int bnx2x_check_blocks_with_parity2(u32 sig, int par_num,
+					   bool print)
 {
 	int i =3D 0;
 	u32 cur_bit =3D 0;
@@ -4167,8 +4208,8 @@ static inline int bnx2x_check_blocks_with_parity2=
(u32 sig, int par_num,
 	return par_num;
 }
=20
-static inline int bnx2x_check_blocks_with_parity3(u32 sig, int par_num=
,
-						  bool *global, bool print)
+static int bnx2x_check_blocks_with_parity3(u32 sig, int par_num,
+					   bool *global, bool print)
 {
 	int i =3D 0;
 	u32 cur_bit =3D 0;
@@ -4209,8 +4250,8 @@ static inline int bnx2x_check_blocks_with_parity3=
(u32 sig, int par_num,
 	return par_num;
 }
=20
-static inline int bnx2x_check_blocks_with_parity4(u32 sig, int par_num=
,
-						  bool print)
+static int bnx2x_check_blocks_with_parity4(u32 sig, int par_num,
+					   bool print)
 {
 	int i =3D 0;
 	u32 cur_bit =3D 0;
@@ -4236,8 +4277,8 @@ static inline int bnx2x_check_blocks_with_parity4=
(u32 sig, int par_num,
 	return par_num;
 }
=20
-static inline bool bnx2x_parity_attn(struct bnx2x *bp, bool *global, b=
ool print,
-				     u32 *sig)
+static bool bnx2x_parity_attn(struct bnx2x *bp, bool *global, bool pri=
nt,
+			      u32 *sig)
 {
 	if ((sig[0] & HW_PRTY_ASSERT_SET_0) ||
 	    (sig[1] & HW_PRTY_ASSERT_SET_1) ||
@@ -4308,7 +4349,7 @@ bool bnx2x_chk_parity_attn(struct bnx2x *bp, bool=
 *global, bool print)
 }
=20
=20
-static inline void bnx2x_attn_int_deasserted4(struct bnx2x *bp, u32 at=
tn)
+static void bnx2x_attn_int_deasserted4(struct bnx2x *bp, u32 attn)
 {
 	u32 val;
 	if (attn & AEU_INPUTS_ATTN_BITS_PGLUE_HW_INTERRUPT) {
@@ -4500,7 +4541,7 @@ void bnx2x_igu_ack_sb(struct bnx2x *bp, u8 igu_sb=
_id, u8 segment,
 			     igu_addr);
 }
=20
-static inline void bnx2x_update_eq_prod(struct bnx2x *bp, u16 prod)
+static void bnx2x_update_eq_prod(struct bnx2x *bp, u16 prod)
 {
 	/* No memory barriers */
 	storm_memset_eq_prod(bp, prod, BP_FUNC(bp));
@@ -4531,7 +4572,7 @@ static int  bnx2x_cnic_handle_cfc_del(struct bnx2=
x *bp, u32 cid,
 }
 #endif
=20
-static inline void bnx2x_handle_mcast_eqe(struct bnx2x *bp)
+static void bnx2x_handle_mcast_eqe(struct bnx2x *bp)
 {
 	struct bnx2x_mcast_ramrod_params rparam;
 	int rc;
@@ -4556,8 +4597,8 @@ static inline void bnx2x_handle_mcast_eqe(struct =
bnx2x *bp)
 	netif_addr_unlock_bh(bp->dev);
 }
=20
-static inline void bnx2x_handle_classification_eqe(struct bnx2x *bp,
-						   union event_ring_elem *elem)
+static void bnx2x_handle_classification_eqe(struct bnx2x *bp,
+					    union event_ring_elem *elem)
 {
 	unsigned long ramrod_flags =3D 0;
 	int rc =3D 0;
@@ -4604,7 +4645,7 @@ static inline void bnx2x_handle_classification_eq=
e(struct bnx2x *bp,
 static void bnx2x_set_iscsi_eth_rx_mode(struct bnx2x *bp, bool start);
 #endif
=20
-static inline void bnx2x_handle_rx_mode_eqe(struct bnx2x *bp)
+static void bnx2x_handle_rx_mode_eqe(struct bnx2x *bp)
 {
 	netif_addr_lock_bh(bp->dev);
=20
@@ -4625,7 +4666,7 @@ static inline void bnx2x_handle_rx_mode_eqe(struc=
t bnx2x *bp)
 	netif_addr_unlock_bh(bp->dev);
 }
=20
-static inline void bnx2x_after_afex_vif_lists(struct bnx2x *bp,
+static void bnx2x_after_afex_vif_lists(struct bnx2x *bp,
 					      union event_ring_elem *elem)
 {
 	if (elem->message.data.vif_list_event.echo =3D=3D VIF_LIST_RULE_GET) =
{
@@ -4642,7 +4683,7 @@ static inline void bnx2x_after_afex_vif_lists(str=
uct bnx2x *bp,
 }
=20
 /* called with rtnl_lock */
-static inline void bnx2x_after_function_update(struct bnx2x *bp)
+static void bnx2x_after_function_update(struct bnx2x *bp)
 {
 	int q, rc;
 	struct bnx2x_fastpath *fp;
@@ -4712,7 +4753,7 @@ static inline void bnx2x_after_function_update(st=
ruct bnx2x *bp)
 #endif /* BCM_CNIC */
 }
=20
-static inline struct bnx2x_queue_sp_obj *bnx2x_cid_to_q_obj(
+static struct bnx2x_queue_sp_obj *bnx2x_cid_to_q_obj(
 	struct bnx2x *bp, u32 cid)
 {
 	DP(BNX2X_MSG_SP, "retrieving fp from cid %d\n", cid);
@@ -5056,7 +5097,7 @@ static void bnx2x_timer(unsigned long data)
  * nic init service functions
  */
=20
-static inline void bnx2x_fill(struct bnx2x *bp, u32 addr, int fill, u3=
2 len)
+static void bnx2x_fill(struct bnx2x *bp, u32 addr, int fill, u32 len)
 {
 	u32 i;
 	if (!(len%4) && !(addr%4))
@@ -5069,10 +5110,10 @@ static inline void bnx2x_fill(struct bnx2x *bp,=
 u32 addr, int fill, u32 len)
 }
=20
 /* helper: writes FP SP data to FW - data_size in dwords */
-static inline void bnx2x_wr_fp_sb_data(struct bnx2x *bp,
-				       int fw_sb_id,
-				       u32 *sb_data_p,
-				       u32 data_size)
+static void bnx2x_wr_fp_sb_data(struct bnx2x *bp,
+				int fw_sb_id,
+				u32 *sb_data_p,
+				u32 data_size)
 {
 	int index;
 	for (index =3D 0; index < data_size; index++)
@@ -5082,7 +5123,7 @@ static inline void bnx2x_wr_fp_sb_data(struct bnx=
2x *bp,
 			*(sb_data_p + index));
 }
=20
-static inline void bnx2x_zero_fp_sb(struct bnx2x *bp, int fw_sb_id)
+static void bnx2x_zero_fp_sb(struct bnx2x *bp, int fw_sb_id)
 {
 	u32 *sb_data_p;
 	u32 data_size =3D 0;
@@ -5115,7 +5156,7 @@ static inline void bnx2x_zero_fp_sb(struct bnx2x =
*bp, int fw_sb_id)
 }
=20
 /* helper:  writes SP SB data to FW */
-static inline void bnx2x_wr_sp_sb_data(struct bnx2x *bp,
+static void bnx2x_wr_sp_sb_data(struct bnx2x *bp,
 		struct hc_sp_status_block_data *sp_sb_data)
 {
 	int func =3D BP_FUNC(bp);
@@ -5127,7 +5168,7 @@ static inline void bnx2x_wr_sp_sb_data(struct bnx=
2x *bp,
 			*((u32 *)sp_sb_data + i));
 }
=20
-static inline void bnx2x_zero_sp_sb(struct bnx2x *bp)
+static void bnx2x_zero_sp_sb(struct bnx2x *bp)
 {
 	int func =3D BP_FUNC(bp);
 	struct hc_sp_status_block_data sp_sb_data;
@@ -5148,8 +5189,7 @@ static inline void bnx2x_zero_sp_sb(struct bnx2x =
*bp)
 }
=20
=20
-static inline
-void bnx2x_setup_ndsb_state_machine(struct hc_status_block_sm *hc_sm,
+static void bnx2x_setup_ndsb_state_machine(struct hc_status_block_sm *=
hc_sm,
 					   int igu_sb_id, int igu_seg_id)
 {
 	hc_sm->igu_sb_id =3D igu_sb_id;
@@ -5160,8 +5200,7 @@ void bnx2x_setup_ndsb_state_machine(struct hc_sta=
tus_block_sm *hc_sm,
=20
=20
 /* allocates state machine ids. */
-static inline
-void bnx2x_map_sb_state_machines(struct hc_index_data *index_data)
+static void bnx2x_map_sb_state_machines(struct hc_index_data *index_da=
ta)
 {
 	/* zero out state machine indices */
 	/* rx indices */
@@ -5569,7 +5608,7 @@ static inline u8 bnx2x_fp_fw_sb_id(struct bnx2x_f=
astpath *fp)
 	return fp->bp->base_fw_ndsb + fp->index + CNIC_PRESENT;
 }
=20
-static inline u8 bnx2x_fp_cl_id(struct bnx2x_fastpath *fp)
+static u8 bnx2x_fp_cl_id(struct bnx2x_fastpath *fp)
 {
 	if (CHIP_IS_E1x(fp->bp))
 		return BP_L_ID(fp->bp) + fp->index;
@@ -5630,6 +5669,43 @@ static void bnx2x_init_eth_fp(struct bnx2x *bp, =
int fp_idx)
 	bnx2x_update_fpsb_idx(fp);
 }
=20
+static void bnx2x_init_tx_ring_one(struct bnx2x_fp_txdata *txdata)
+{
+	int i;
+
+	for (i =3D 1; i <=3D NUM_TX_RINGS; i++) {
+		struct eth_tx_next_bd *tx_next_bd =3D
+			&txdata->tx_desc_ring[TX_DESC_CNT * i - 1].next_bd;
+
+		tx_next_bd->addr_hi =3D
+			cpu_to_le32(U64_HI(txdata->tx_desc_mapping +
+				    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
+		tx_next_bd->addr_lo =3D
+			cpu_to_le32(U64_LO(txdata->tx_desc_mapping +
+				    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
+	}
+
+	SET_FLAG(txdata->tx_db.data.header.header, DOORBELL_HDR_DB_TYPE, 1);
+	txdata->tx_db.data.zero_fill1 =3D 0;
+	txdata->tx_db.data.prod =3D 0;
+
+	txdata->tx_pkt_prod =3D 0;
+	txdata->tx_pkt_cons =3D 0;
+	txdata->tx_bd_prod =3D 0;
+	txdata->tx_bd_cons =3D 0;
+	txdata->tx_pkt =3D 0;
+}
+
+static void bnx2x_init_tx_rings(struct bnx2x *bp)
+{
+	int i;
+	u8 cos;
+
+	for_each_tx_queue(bp, i)
+		for_each_cos_in_tx_queue(&bp->fp[i], cos)
+			bnx2x_init_tx_ring_one(&bp->fp[i].txdata[cos]);
+}
+
 void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 {
 	int i;
@@ -6154,7 +6230,7 @@ void bnx2x_pf_disable(struct bnx2x *bp)
 	REG_WR(bp, CFC_REG_WEAK_ENABLE_PF, 0);
 }
=20
-static inline void bnx2x__common_init_phy(struct bnx2x *bp)
+static void bnx2x__common_init_phy(struct bnx2x *bp)
 {
 	u32 shmem_base[2], shmem2_base[2];
 	shmem_base[0] =3D  bp->common.shmem_base;
@@ -6882,12 +6958,59 @@ static void bnx2x_ilt_wr(struct bnx2x *bp, u32 =
index, dma_addr_t addr)
 	REG_WR_DMAE(bp, reg, wb_write, 2);
 }
=20
-static inline void bnx2x_igu_clear_sb(struct bnx2x *bp, u8 idu_sb_id)
+static void bnx2x_igu_clear_sb_gen(struct bnx2x *bp, u8 func,
+				   u8 idu_sb_id, bool is_Pf)
+{
+	u32 data, ctl, cnt =3D 100;
+	u32 igu_addr_data =3D IGU_REG_COMMAND_REG_32LSB_DATA;
+	u32 igu_addr_ctl =3D IGU_REG_COMMAND_REG_CTRL;
+	u32 igu_addr_ack =3D IGU_REG_CSTORM_TYPE_0_SB_CLEANUP + (idu_sb_id/32=
)*4;
+	u32 sb_bit =3D  1 << (idu_sb_id%32);
+	u32 func_encode =3D func | (is_Pf ? 1 : 0) << IGU_FID_ENCODE_IS_PF_SH=
IFT;
+	u32 addr_encode =3D IGU_CMD_E2_PROD_UPD_BASE + idu_sb_id;
+
+	/* Not supported in BC mode */
+	if (CHIP_INT_MODE_IS_BC(bp))
+		return;
+
+	data =3D (IGU_USE_REGISTER_cstorm_type_0_sb_cleanup
+			<< IGU_REGULAR_CLEANUP_TYPE_SHIFT)	|
+		IGU_REGULAR_CLEANUP_SET				|
+		IGU_REGULAR_BCLEANUP;
+
+	ctl =3D addr_encode << IGU_CTRL_REG_ADDRESS_SHIFT		|
+	      func_encode << IGU_CTRL_REG_FID_SHIFT		|
+	      IGU_CTRL_CMD_TYPE_WR << IGU_CTRL_REG_TYPE_SHIFT;
+
+	DP(NETIF_MSG_HW, "write 0x%08x to IGU(via GRC) addr 0x%x\n",
+			 data, igu_addr_data);
+	REG_WR(bp, igu_addr_data, data);
+	mmiowb();
+	barrier();
+	DP(NETIF_MSG_HW, "write 0x%08x to IGU(via GRC) addr 0x%x\n",
+			  ctl, igu_addr_ctl);
+	REG_WR(bp, igu_addr_ctl, ctl);
+	mmiowb();
+	barrier();
+
+	/* wait for clean up to finish */
+	while (!(REG_RD(bp, igu_addr_ack) & sb_bit) && --cnt)
+		msleep(20);
+
+
+	if (!(REG_RD(bp, igu_addr_ack) & sb_bit)) {
+		DP(NETIF_MSG_HW,
+		   "Unable to finish IGU cleanup: idu_sb_id %d offset %d bit %d (cnt=
 %d)\n",
+			  idu_sb_id, idu_sb_id/32, idu_sb_id%32, cnt);
+	}
+}
+
+static void bnx2x_igu_clear_sb(struct bnx2x *bp, u8 idu_sb_id)
 {
 	bnx2x_igu_clear_sb_gen(bp, BP_FUNC(bp), idu_sb_id, true /*PF*/);
 }
=20
-static inline void bnx2x_clear_func_ilt(struct bnx2x *bp, u32 func)
+static void bnx2x_clear_func_ilt(struct bnx2x *bp, u32 func)
 {
 	u32 i, base =3D FUNC_ILT_BASE(func);
 	for (i =3D base; i < base + ILT_PER_FUNC; i++)
@@ -7238,7 +7361,7 @@ void bnx2x_free_mem(struct bnx2x *bp)
 		       BCM_PAGE_SIZE * NUM_EQ_PAGES);
 }
=20
-static inline int bnx2x_alloc_fw_stats_mem(struct bnx2x *bp)
+static int bnx2x_alloc_fw_stats_mem(struct bnx2x *bp)
 {
 	int num_groups;
 	int is_fcoe_stats =3D NO_FCOE(bp) ? 0 : 1;
@@ -7604,7 +7727,7 @@ void bnx2x_ilt_set_info(struct bnx2x *bp)
  *      - HC configuration
  *      - Queue's CDU context
  */
-static inline void bnx2x_pf_q_prep_init(struct bnx2x *bp,
+static void bnx2x_pf_q_prep_init(struct bnx2x *bp,
 	struct bnx2x_fastpath *fp, struct bnx2x_queue_init_params *init_param=
s)
 {
=20
@@ -7954,7 +8077,7 @@ static void bnx2x_reset_port(struct bnx2x *bp)
 	/* TODO: Close Doorbell port? */
 }
=20
-static inline int bnx2x_reset_hw(struct bnx2x *bp, u32 load_code)
+static int bnx2x_reset_hw(struct bnx2x *bp, u32 load_code)
 {
 	struct bnx2x_func_state_params func_params =3D {NULL};
=20
@@ -7969,7 +8092,7 @@ static inline int bnx2x_reset_hw(struct bnx2x *bp=
, u32 load_code)
 	return bnx2x_func_state_change(bp, &func_params);
 }
=20
-static inline int bnx2x_func_stop(struct bnx2x *bp)
+static int bnx2x_func_stop(struct bnx2x *bp)
 {
 	struct bnx2x_func_state_params func_params =3D {NULL};
 	int rc;
@@ -8084,7 +8207,7 @@ void bnx2x_send_unload_done(struct bnx2x *bp)
 		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE, 0);
 }
=20
-static inline int bnx2x_func_wait_started(struct bnx2x *bp)
+static int bnx2x_func_wait_started(struct bnx2x *bp)
 {
 	int tout =3D 50;
 	int msix =3D (bp->flags & USING_MSIX_FLAG) ? 1 : 0;
@@ -8394,7 +8517,7 @@ static void bnx2x_reset_mcp_prep(struct bnx2x *bp=
, u32 *magic_val)
  *
  * @bp:	driver handle
  */
-static inline void bnx2x_mcp_wait_one(struct bnx2x *bp)
+static void bnx2x_mcp_wait_one(struct bnx2x *bp)
 {
 	/* special handling for emulation and FPGA,
 	   wait 10 times longer */
@@ -8730,7 +8853,7 @@ exit_leader_reset:
 	return rc;
 }
=20
-static inline void bnx2x_recovery_failed(struct bnx2x *bp)
+static void bnx2x_recovery_failed(struct bnx2x *bp)
 {
 	netdev_err(bp->dev, "Recovery has failed. Power cycle is needed.\n");
=20
@@ -10803,8 +10926,8 @@ static int bnx2x_close(struct net_device *dev)
 	return 0;
 }
=20
-static inline int bnx2x_init_mcast_macs_list(struct bnx2x *bp,
-					 struct bnx2x_mcast_ramrod_params *p)
+static int bnx2x_init_mcast_macs_list(struct bnx2x *bp,
+				      struct bnx2x_mcast_ramrod_params *p)
 {
 	int mc_count =3D netdev_mc_count(bp->dev);
 	struct bnx2x_mcast_list_elem *mc_mac =3D
@@ -10827,7 +10950,7 @@ static inline int bnx2x_init_mcast_macs_list(st=
ruct bnx2x *bp,
 	return 0;
 }
=20
-static inline void bnx2x_free_mcast_macs_list(
+static void bnx2x_free_mcast_macs_list(
 	struct bnx2x_mcast_ramrod_params *p)
 {
 	struct bnx2x_mcast_list_elem *mc_mac =3D
@@ -10845,7 +10968,7 @@ static inline void bnx2x_free_mcast_macs_list(
  *
  * We will use zero (0) as a MAC type for these MACs.
  */
-static inline int bnx2x_set_uc_list(struct bnx2x *bp)
+static int bnx2x_set_uc_list(struct bnx2x *bp)
 {
 	int rc;
 	struct net_device *dev =3D bp->dev;
@@ -10876,7 +10999,7 @@ static inline int bnx2x_set_uc_list(struct bnx2=
x *bp)
 				 BNX2X_UC_LIST_MAC, &ramrod_flags);
 }
=20
-static inline int bnx2x_set_mc_list(struct bnx2x *bp)
+static int bnx2x_set_mc_list(struct bnx2x *bp)
 {
 	struct net_device *dev =3D bp->dev;
 	struct bnx2x_mcast_ramrod_params rparam =3D {NULL};
@@ -11062,7 +11185,7 @@ static const struct net_device_ops bnx2x_netdev=
_ops =3D {
 #endif
 };
=20
-static inline int bnx2x_set_coherency_mask(struct bnx2x *bp)
+static int bnx2x_set_coherency_mask(struct bnx2x *bp)
 {
 	struct device *dev =3D &bp->pdev->dev;
=20
@@ -11328,7 +11451,7 @@ static int bnx2x_check_firmware(struct bnx2x *b=
p)
 	return 0;
 }
=20
-static inline void be32_to_cpu_n(const u8 *_source, u8 *_target, u32 n=
)
+static void be32_to_cpu_n(const u8 *_source, u8 *_target, u32 n)
 {
 	const __be32 *source =3D (const __be32 *)_source;
 	u32 *target =3D (u32 *)_target;
@@ -11342,7 +11465,7 @@ static inline void be32_to_cpu_n(const u8 *_sou=
rce, u8 *_target, u32 n)
    Ops array is stored in the following format:
    {op(8bit), offset(24bit, big endian), data(32bit, big endian)}
  */
-static inline void bnx2x_prep_ops(const u8 *_source, u8 *_target, u32 =
n)
+static void bnx2x_prep_ops(const u8 *_source, u8 *_target, u32 n)
 {
 	const __be32 *source =3D (const __be32 *)_source;
 	struct raw_op *target =3D (struct raw_op *)_target;
@@ -11360,7 +11483,7 @@ static inline void bnx2x_prep_ops(const u8 *_so=
urce, u8 *_target, u32 n)
  * IRO array is stored in the following format:
  * {base(24bit), m1(16bit), m2(16bit), m3(16bit), size(16bit) }
  */
-static inline void bnx2x_prep_iro(const u8 *_source, u8 *_target, u32 =
n)
+static void bnx2x_prep_iro(const u8 *_source, u8 *_target, u32 n)
 {
 	const __be32 *source =3D (const __be32 *)_source;
 	struct iro *target =3D (struct iro *)_target;
@@ -11380,7 +11503,7 @@ static inline void bnx2x_prep_iro(const u8 *_so=
urce, u8 *_target, u32 n)
 	}
 }
=20
-static inline void be16_to_cpu_n(const u8 *_source, u8 *_target, u32 n=
)
+static void be16_to_cpu_n(const u8 *_source, u8 *_target, u32 n)
 {
 	const __be16 *source =3D (const __be16 *)_source;
 	u16 *target =3D (u16 *)_target;
@@ -11523,7 +11646,7 @@ void bnx2x__init_func_obj(struct bnx2x *bp)
 }
=20
 /* must be called after sriov-enable */
-static inline int bnx2x_set_qm_cid_count(struct bnx2x *bp)
+static int bnx2x_set_qm_cid_count(struct bnx2x *bp)
 {
 	int cid_count =3D BNX2X_L2_CID_COUNT(bp);
=20
@@ -11539,7 +11662,7 @@ static inline int bnx2x_set_qm_cid_count(struct=
 bnx2x *bp)
  * @dev:	pci device
  *
  */
-static inline int bnx2x_get_num_non_def_sbs(struct pci_dev *pdev)
+static int bnx2x_get_num_non_def_sbs(struct pci_dev *pdev)
 {
 	int pos;
 	u16 control;
@@ -12015,7 +12138,7 @@ module_exit(bnx2x_cleanup);
  * This function will wait until the ramdord completion returns.
  * Return 0 if success, -ENODEV if ramrod doesn't return.
  */
-static inline int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp)
+static int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp)
 {
 	unsigned long ramrod_flags =3D 0;
=20
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/driver=
s/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 7366e92..1e2785c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1316,7 +1316,7 @@ static void bnx2x_port_stats_base_init(struct bnx=
2x *bp)
  *
  * @param bp
  */
-static inline void bnx2x_prep_fw_stats_req(struct bnx2x *bp)
+static void bnx2x_prep_fw_stats_req(struct bnx2x *bp)
 {
 	int i;
 	int first_queue_query_index;
