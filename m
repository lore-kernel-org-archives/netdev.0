From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 4/5] qed: Introduce DMA_REGPAIR_LE
Date: Sun, 21 Feb 2016 11:40:10 +0200
Message-ID: <1456047611-11222-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456047611-11222-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:35839 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751642AbcBURpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 12:45:55 -0500
In-Reply-To: <1456047611-11222-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FW hsi contains regpairs, mostly for 64-bit address representations.
Since same paradigm is applied each time a regpair is filled, this
introduces a new utility macro for setting such regpairs.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c          |  9 +++------
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c | 12 ++++--------
 drivers/net/ethernet/qlogic/qed/qed_spq.c         |  9 +++------
 include/linux/qed/qed_chain.h                     |  4 ++++
 4 files changed, 14 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index feb83fa..24eb4144 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -557,12 +557,10 @@ qed_sp_eth_rxq_start_ramrod(struct qed_hwfn *p_hwfn,
 	p_ramrod->complete_event_flg	= 1;
 
 	p_ramrod->bd_max_bytes	= cpu_to_le16(bd_max_bytes);
-	p_ramrod->bd_base.hi	= DMA_HI_LE(bd_chain_phys_addr);
-	p_ramrod->bd_base.lo	= DMA_LO_LE(bd_chain_phys_addr);
+	DMA_REGPAIR_LE(p_ramrod->bd_base, bd_chain_phys_addr);
 
 	p_ramrod->num_of_pbl_pages	= cpu_to_le16(cqe_pbl_size);
-	p_ramrod->cqe_pbl_addr.hi	= DMA_HI_LE(cqe_pbl_addr);
-	p_ramrod->cqe_pbl_addr.lo	= DMA_LO_LE(cqe_pbl_addr);
+	DMA_REGPAIR_LE(p_ramrod->cqe_pbl_addr, cqe_pbl_addr);
 
 	rc = qed_spq_post(p_hwfn, p_ent, NULL);
 
@@ -721,8 +719,7 @@ qed_sp_eth_txq_start_ramrod(struct qed_hwfn  *p_hwfn,
 	p_ramrod->stats_counter_id	= stats_id;
 
 	p_ramrod->pbl_size		= cpu_to_le16(pbl_size);
-	p_ramrod->pbl_base_addr.hi	= DMA_HI_LE(pbl_addr);
-	p_ramrod->pbl_base_addr.lo	= DMA_LO_LE(pbl_addr);
+	DMA_REGPAIR_LE(p_ramrod->pbl_base_addr, pbl_addr);
 
 	pq_id			= qed_get_qm_pq(p_hwfn,
 						PROTOCOLID_ETH,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
index f070fb0..d5248fd 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -136,16 +136,12 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 	p_ramrod->outer_tag = p_hwfn->hw_info.ovlan;
 
 	/* Place EQ address in RAMROD */
-	p_ramrod->event_ring_pbl_addr.hi =
-			DMA_HI_LE(p_hwfn->p_eq->chain.pbl.p_phys_table);
-	p_ramrod->event_ring_pbl_addr.lo =
-			DMA_LO_LE(p_hwfn->p_eq->chain.pbl.p_phys_table);
+	DMA_REGPAIR_LE(p_ramrod->event_ring_pbl_addr,
+		       p_hwfn->p_eq->chain.pbl.p_phys_table);
 	p_ramrod->event_ring_num_pages = (u8)p_hwfn->p_eq->chain.page_cnt;
 
-	p_ramrod->consolid_q_pbl_addr.hi =
-			DMA_HI_LE(p_hwfn->p_consq->chain.pbl.p_phys_table);
-	p_ramrod->consolid_q_pbl_addr.lo =
-			DMA_LO_LE(p_hwfn->p_consq->chain.pbl.p_phys_table);
+	DMA_REGPAIR_LE(p_ramrod->consolid_q_pbl_addr,
+		       p_hwfn->p_consq->chain.pbl.p_phys_table);
 
 	p_hwfn->hw_info.personality = PERSONALITY_ETH;
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
index f6c6c21..89469d5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_spq.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
@@ -183,10 +183,8 @@ static void qed_spq_hw_initialize(struct qed_hwfn *p_hwfn,
 	p_cxt->xstorm_st_context.spq_base_hi =
 		DMA_HI_LE(p_spq->chain.p_phys_addr);
 
-	p_cxt->xstorm_st_context.consolid_base_addr.lo =
-		DMA_LO_LE(p_hwfn->p_consq->chain.p_phys_addr);
-	p_cxt->xstorm_st_context.consolid_base_addr.hi =
-		DMA_HI_LE(p_hwfn->p_consq->chain.p_phys_addr);
+	DMA_REGPAIR_LE(p_cxt->xstorm_st_context.consolid_base_addr,
+		       p_hwfn->p_consq->chain.p_phys_addr);
 }
 
 static int qed_spq_hw_post(struct qed_hwfn *p_hwfn,
@@ -423,8 +421,7 @@ void qed_spq_setup(struct qed_hwfn *p_hwfn)
 	p_virt	= p_spq->p_virt;
 
 	for (i = 0; i < p_spq->chain.capacity; i++) {
-		p_virt->elem.data_ptr.hi = DMA_HI_LE(p_phys);
-		p_virt->elem.data_ptr.lo = DMA_LO_LE(p_phys);
+		DMA_REGPAIR_LE(p_virt->elem.data_ptr, p_phys);
 
 		list_add_tail(&p_virt->list, &p_spq->free_pool);
 
diff --git a/include/linux/qed/qed_chain.h b/include/linux/qed/qed_chain.h
index 41b9049..5f8fcaa 100644
--- a/include/linux/qed/qed_chain.h
+++ b/include/linux/qed/qed_chain.h
@@ -19,6 +19,10 @@
 /* dma_addr_t manip */
 #define DMA_LO_LE(x)            cpu_to_le32(lower_32_bits(x))
 #define DMA_HI_LE(x)            cpu_to_le32(upper_32_bits(x))
+#define DMA_REGPAIR_LE(x, val)  do { \
+					(x).hi = DMA_HI_LE((val)); \
+					(x).lo = DMA_LO_LE((val)); \
+				} while (0)
 
 #define HILO_GEN(hi, lo, type)  ((((type)(hi)) << 32) + (lo))
 #define HILO_DMA(hi, lo)        HILO_GEN(hi, lo, dma_addr_t)
-- 
1.9.3
