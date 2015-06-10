From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 04/19] bna: get rid of duplicate and unused macros
Date: Wed, 10 Jun 2015 18:43:10 +0200
Message-ID: <1433954605-22813-5-git-send-email-ivecera@redhat.com>
References: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57753 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754475AbbFJQnD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 12:43:03 -0400
In-Reply-To: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replaced macros:
BNA_MAC_IS_EQUAL -> ether_addr_equal
BNA_POWER_OF_2 -> is_power_of_2
BNA_TO_POWER_OF_2_HIGH -> roundup_pow_of_two

removed unused macros:
bfa_fsm_get_state
bfa_ioc_clr_stats
bfa_ioc_fetch_stats
bfa_ioc_get_alt_ioc_fwstate
bfa_ioc_isr_mode_set
bfa_ioc_maxfrsize
bfa_ioc_mbox_cmd_pending
bfa_ioc_ownership_reset
bfa_ioc_rx_bbcredit
bfa_ioc_state_disabled
bfa_sm_cmp_state
bfa_sm_get_state
bfa_sm_send_event
bfa_sm_set_state
bfa_sm_state_decl
BFA_STRING_32
BFI_ADAPTER_IS_{PROTO,TTV,UNSUPP)
BFI_IOC_ENDIAN_SIG
BNA_{C,RX,TX}Q_PAGE_INDEX_MAX
BNA_{C,RX,TX}Q_PAGE_INDEX_MAX_SHIFT
BNA_{C,RX,TX}Q_QPGE_PTR_GET
BNA_IOC_TIMER_FREQ
BNA_MESSAGE_SIZE
BNA_QE_INDX_2_PTR
BNA_QE_INDX_RANGE
BNA_Q_GET_{C,P}I
BNA_Q_{C,P}I_ADD
BNA_Q_FREE_COUNT
BNA_Q_IN_USE_COUNT
BNA_TO_POWER_OF_2
containing_rec

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bfa_cs.h       |  14 ----
 drivers/net/ethernet/brocade/bna/bfa_defs.h     |   1 -
 drivers/net/ethernet/brocade/bna/bfa_ioc.c      |  14 ----
 drivers/net/ethernet/brocade/bna/bfa_ioc.h      |  13 ---
 drivers/net/ethernet/brocade/bna/bfi.h          |   8 --
 drivers/net/ethernet/brocade/bna/bna.h          | 105 +-----------------------
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c    |  13 ++-
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c |   4 +-
 8 files changed, 9 insertions(+), 163 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_cs.h b/drivers/net/ethernet/brocade/bna/bfa_cs.h
index af25d8e..1d11d66 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_cs.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_cs.h
@@ -28,19 +28,6 @@
 
 typedef void (*bfa_sm_t)(void *sm, int event);
 
-/* oc - object class eg. bfa_ioc
- * st - state, eg. reset
- * otype - object type, eg. struct bfa_ioc
- * etype - object type, eg. enum ioc_event
- */
-#define bfa_sm_state_decl(oc, st, otype, etype)			\
-	static void oc ## _sm_ ## st(otype * fsm, etype event)
-
-#define bfa_sm_set_state(_sm, _state)	((_sm)->sm = (bfa_sm_t)(_state))
-#define bfa_sm_send_event(_sm, _event)	((_sm)->sm((_sm), (_event)))
-#define bfa_sm_get_state(_sm)		((_sm)->sm)
-#define bfa_sm_cmp_state(_sm, _state)	((_sm)->sm == (bfa_sm_t)(_state))
-
 /* For converting from state machine function to state encoding. */
 struct bfa_sm_table {
 	bfa_sm_t	sm;	/*!< state machine function	*/
@@ -67,7 +54,6 @@ typedef void (*bfa_fsm_t)(void *fsm, int event);
 } while (0)
 
 #define bfa_fsm_send_event(_fsm, _event)	((_fsm)->fsm((_fsm), (_event)))
-#define bfa_fsm_get_state(_fsm)			((_fsm)->fsm)
 #define bfa_fsm_cmp_state(_fsm, _state)					\
 	((_fsm)->fsm == (bfa_fsm_t)(_state))
 
diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs.h b/drivers/net/ethernet/brocade/bna/bfa_defs.h
index 6827d91..d152b3f 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs.h
@@ -24,7 +24,6 @@
 #include "bfa_defs_status.h"
 #include "bfa_defs_mfg_comm.h"
 
-#define BFA_STRING_32	32
 #define BFA_VERSION_LEN 64
 
 /* ---------------------- adapter definitions ------------ */
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index 82c95f8..29e0428 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -23,14 +23,6 @@
 
 /* IOC local definitions */
 
-#define bfa_ioc_state_disabled(__sm)			\
-	(((__sm) == BFI_IOC_UNINIT) ||			\
-	 ((__sm) == BFI_IOC_INITING) ||			\
-	 ((__sm) == BFI_IOC_HWINIT) ||			\
-	 ((__sm) == BFI_IOC_DISABLED) ||		\
-	 ((__sm) == BFI_IOC_FAIL) ||			\
-	 ((__sm) == BFI_IOC_CFG_DISABLED))
-
 /* Asic specific macros : see bfa_hw_cb.c and bfa_hw_ct.c for details. */
 
 #define bfa_ioc_firmware_lock(__ioc)			\
@@ -57,12 +49,6 @@
 			((__ioc)->ioc_hwif->ioc_get_fwstate(__ioc))
 #define bfa_ioc_set_alt_ioc_fwstate(__ioc, __fwstate)		\
 		((__ioc)->ioc_hwif->ioc_set_alt_fwstate(__ioc, __fwstate))
-#define bfa_ioc_get_alt_ioc_fwstate(__ioc)		\
-			((__ioc)->ioc_hwif->ioc_get_alt_fwstate(__ioc))
-
-#define bfa_ioc_mbox_cmd_pending(__ioc)		\
-			(!list_empty(&((__ioc)->mbox_mod.cmd_q)) || \
-			readl((__ioc)->ioc_regs.hfn_mbox_cmd))
 
 static bool bfa_nw_auto_recover = true;
 
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.h b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
index b37bc16..b6ad2c5 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
@@ -232,12 +232,6 @@ struct bfa_ioc_hwif {
 #define bfa_ioc_asic_gen(__ioc)		((__ioc)->asic_gen)
 #define bfa_ioc_is_default(__ioc)	\
 	(bfa_ioc_pcifn(__ioc) == bfa_ioc_portid(__ioc))
-#define bfa_ioc_fetch_stats(__ioc, __stats) \
-		(((__stats)->drv_stats) = (__ioc)->stats)
-#define bfa_ioc_clr_stats(__ioc)	\
-		memset(&(__ioc)->stats, 0, sizeof((__ioc)->stats))
-#define bfa_ioc_maxfrsize(__ioc)	((__ioc)->attr->maxfrsize)
-#define bfa_ioc_rx_bbcredit(__ioc)	((__ioc)->attr->rx_bbcredit)
 #define bfa_ioc_speed_sup(__ioc)	\
 	BFI_ADAPTER_GETP(SPEED, (__ioc)->attr->adapter_prop)
 #define bfa_ioc_get_nports(__ioc)	\
@@ -268,13 +262,6 @@ void bfa_nw_ioc_mbox_regisr(struct bfa_ioc *ioc, enum bfi_mclass mc,
 	((__ioc)->ioc_hwif->ioc_pll_init((__ioc)->pcidev.pci_bar_kva, \
 			   (__ioc)->asic_mode))
 
-#define	bfa_ioc_isr_mode_set(__ioc, __msix) do {			\
-	if ((__ioc)->ioc_hwif->ioc_isr_mode_set)			\
-		((__ioc)->ioc_hwif->ioc_isr_mode_set(__ioc, __msix));	\
-} while (0)
-#define	bfa_ioc_ownership_reset(__ioc)				\
-			((__ioc)->ioc_hwif->ioc_ownership_reset(__ioc))
-
 #define bfa_ioc_lpu_read_stat(__ioc) do {				\
 		if ((__ioc)->ioc_hwif->ioc_lpu_read_stat)		\
 			((__ioc)->ioc_hwif->ioc_lpu_read_stat(__ioc));	\
diff --git a/drivers/net/ethernet/brocade/bna/bfi.h b/drivers/net/ethernet/brocade/bna/bfi.h
index 3e97077..81e59ea 100644
--- a/drivers/net/ethernet/brocade/bna/bfi.h
+++ b/drivers/net/ethernet/brocade/bna/bfi.h
@@ -315,8 +315,6 @@ enum bfi_ioc_state {
 	BFI_IOC_MEMTEST		= 9,	/*!< IOC is doing memtest	     */
 };
 
-#define BFI_IOC_ENDIAN_SIG  0x12345678
-
 enum {
 	BFI_ADAPTER_TYPE_FC	= 0x01,		/*!< FC adapters	   */
 	BFI_ADAPTER_TYPE_MK	= 0x0f0000,	/*!< adapter type mask     */
@@ -335,12 +333,6 @@ enum {
 		BFI_ADAPTER_ ## __prop ## _SH)
 #define BFI_ADAPTER_SETP(__prop, __val)				\
 	((__val) << BFI_ADAPTER_ ## __prop ## _SH)
-#define BFI_ADAPTER_IS_PROTO(__adap_type)			\
-	((__adap_type) & BFI_ADAPTER_PROTO)
-#define BFI_ADAPTER_IS_TTV(__adap_type)				\
-	((__adap_type) & BFI_ADAPTER_TTV)
-#define BFI_ADAPTER_IS_UNSUPP(__adap_type)			\
-	((__adap_type) & BFI_ADAPTER_UNSUPP)
 #define BFI_ADAPTER_IS_SPECIAL(__adap_type)			\
 	((__adap_type) & (BFI_ADAPTER_TTV | BFI_ADAPTER_PROTO |	\
 			BFI_ADAPTER_UNSUPP))
diff --git a/drivers/net/ethernet/brocade/bna/bna.h b/drivers/net/ethernet/brocade/bna/bna.h
index 0cad6bd..130010d 100644
--- a/drivers/net/ethernet/brocade/bna/bna.h
+++ b/drivers/net/ethernet/brocade/bna/bna.h
@@ -28,36 +28,8 @@ extern const u32 bna_napi_dim_vector[][BNA_BIAS_T_MAX];
 
 /*  Macros and constants  */
 
-#define BNA_IOC_TIMER_FREQ		200
-
-/* Log string size */
-#define BNA_MESSAGE_SIZE		256
-
 #define bna_is_small_rxq(_id) ((_id) & 0x1)
 
-#define BNA_MAC_IS_EQUAL(_mac1, _mac2)					\
-	(!memcmp((_mac1), (_mac2), ETH_ALEN))
-
-#define BNA_POWER_OF_2(x) (((x) & ((x) - 1)) == 0)
-
-#define BNA_TO_POWER_OF_2(x)						\
-do {									\
-	int _shift = 0;							\
-	while ((x) && (x) != 1) {					\
-		(x) >>= 1;						\
-		_shift++;						\
-	}								\
-	(x) <<= _shift;							\
-} while (0)
-
-#define BNA_TO_POWER_OF_2_HIGH(x)					\
-do {									\
-	int n = 1;							\
-	while (n < (x))							\
-		n <<= 1;						\
-	(x) = n;							\
-} while (0)
-
 /*
  * input : _addr-> os dma addr in host endian format,
  * output : _bna_dma_addr-> pointer to hw dma addr
@@ -80,62 +52,8 @@ do {								\
 	| ((ntohl((_bna_dma_addr)->lsb) & 0xffffffff));	\
 } while (0)
 
-#define	containing_rec(addr, type, field)				\
-	((type *)((unsigned char *)(addr) -				\
-	(unsigned char *)(&((type *)0)->field)))
-
 #define BNA_TXQ_WI_NEEDED(_vectors)	(((_vectors) + 3) >> 2)
 
-/* TxQ element is 64 bytes */
-#define BNA_TXQ_PAGE_INDEX_MAX		(PAGE_SIZE >> 6)
-#define BNA_TXQ_PAGE_INDEX_MAX_SHIFT	(PAGE_SHIFT - 6)
-
-#define BNA_TXQ_QPGE_PTR_GET(_qe_idx, _qpt_ptr, _qe_ptr, _qe_ptr_range) \
-{									\
-	unsigned int page_index;	/* index within a page */	\
-	void *page_addr;						\
-	page_index = (_qe_idx) & (BNA_TXQ_PAGE_INDEX_MAX - 1);		\
-	(_qe_ptr_range) = (BNA_TXQ_PAGE_INDEX_MAX - page_index);	\
-	page_addr = (_qpt_ptr)[((_qe_idx) >>  BNA_TXQ_PAGE_INDEX_MAX_SHIFT)];\
-	(_qe_ptr) = &((struct bna_txq_entry *)(page_addr))[page_index]; \
-}
-
-/* RxQ element is 8 bytes */
-#define BNA_RXQ_PAGE_INDEX_MAX		(PAGE_SIZE >> 3)
-#define BNA_RXQ_PAGE_INDEX_MAX_SHIFT	(PAGE_SHIFT - 3)
-
-#define BNA_RXQ_QPGE_PTR_GET(_qe_idx, _qpt_ptr, _qe_ptr, _qe_ptr_range) \
-{									\
-	unsigned int page_index;	/* index within a page */	\
-	void *page_addr;						\
-	page_index = (_qe_idx) & (BNA_RXQ_PAGE_INDEX_MAX - 1);		\
-	(_qe_ptr_range) = (BNA_RXQ_PAGE_INDEX_MAX - page_index);	\
-	page_addr = (_qpt_ptr)[((_qe_idx) >>				\
-				BNA_RXQ_PAGE_INDEX_MAX_SHIFT)];		\
-	(_qe_ptr) = &((struct bna_rxq_entry *)(page_addr))[page_index]; \
-}
-
-/* CQ element is 16 bytes */
-#define BNA_CQ_PAGE_INDEX_MAX		(PAGE_SIZE >> 4)
-#define BNA_CQ_PAGE_INDEX_MAX_SHIFT	(PAGE_SHIFT - 4)
-
-#define BNA_CQ_QPGE_PTR_GET(_qe_idx, _qpt_ptr, _qe_ptr, _qe_ptr_range)	\
-{									\
-	unsigned int page_index;	  /* index within a page */	\
-	void *page_addr;						\
-									\
-	page_index = (_qe_idx) & (BNA_CQ_PAGE_INDEX_MAX - 1);		\
-	(_qe_ptr_range) = (BNA_CQ_PAGE_INDEX_MAX - page_index);		\
-	page_addr = (_qpt_ptr)[((_qe_idx) >>				\
-				    BNA_CQ_PAGE_INDEX_MAX_SHIFT)];	\
-	(_qe_ptr) = &((struct bna_cq_entry *)(page_addr))[page_index];\
-}
-
-#define BNA_QE_INDX_2_PTR(_cast, _qe_idx, _q_base)			\
-	(&((_cast *)(_q_base))[(_qe_idx)])
-
-#define BNA_QE_INDX_RANGE(_qe_idx, _q_depth) ((_q_depth) - (_qe_idx))
-
 #define BNA_QE_INDX_ADD(_qe_idx, _qe_num, _q_depth)			\
 	((_qe_idx) = ((_qe_idx) + (_qe_num)) & ((_q_depth) - 1))
 
@@ -147,31 +65,10 @@ do {								\
 #define BNA_QE_FREE_CNT(_q_ptr, _q_depth)				\
 	(((_q_ptr)->consumer_index - (_q_ptr)->producer_index - 1) &	\
 	 ((_q_depth) - 1))
-
 #define BNA_QE_IN_USE_CNT(_q_ptr, _q_depth)				\
 	((((_q_ptr)->producer_index - (_q_ptr)->consumer_index)) &	\
 	 (_q_depth - 1))
 
-#define BNA_Q_GET_CI(_q_ptr)		((_q_ptr)->q.consumer_index)
-
-#define BNA_Q_GET_PI(_q_ptr)		((_q_ptr)->q.producer_index)
-
-#define BNA_Q_PI_ADD(_q_ptr, _num)					\
-	(_q_ptr)->q.producer_index =					\
-		(((_q_ptr)->q.producer_index + (_num)) &		\
-		((_q_ptr)->q.q_depth - 1))
-
-#define BNA_Q_CI_ADD(_q_ptr, _num)					\
-	(_q_ptr)->q.consumer_index =					\
-		(((_q_ptr)->q.consumer_index + (_num))			\
-		& ((_q_ptr)->q.q_depth - 1))
-
-#define BNA_Q_FREE_COUNT(_q_ptr)					\
-	(BNA_QE_FREE_CNT(&((_q_ptr)->q), (_q_ptr)->q.q_depth))
-
-#define BNA_Q_IN_USE_COUNT(_q_ptr)					\
-	(BNA_QE_IN_USE_CNT(&(_q_ptr)->q, (_q_ptr)->q.q_depth))
-
 #define BNA_LARGE_PKT_SIZE		1000
 
 #define BNA_UPDATE_PKT_CNT(_pkt, _len)					\
@@ -370,7 +267,7 @@ static inline struct bna_mac *bna_mac_find(struct list_head *q, u8 *addr)
 	struct bna_mac *mac = NULL;
 	struct list_head *qe;
 	list_for_each(qe, q) {
-		if (BNA_MAC_IS_EQUAL(((struct bna_mac *)qe)->addr, addr)) {
+		if (ether_addr_equal(((struct bna_mac *)qe)->addr, addr)) {
 			mac = (struct bna_mac *)qe;
 			break;
 		}
diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 8943188..e13f8c9 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -451,13 +451,13 @@ bna_rxf_mcmac_get(struct bna_rxf *rxf, u8 *mac_addr)
 
 	list_for_each(qe, &rxf->mcast_active_q) {
 		mac = (struct bna_mac *)qe;
-		if (BNA_MAC_IS_EQUAL(&mac->addr, mac_addr))
+		if (ether_addr_equal(mac->addr, mac_addr))
 			return mac;
 	}
 
 	list_for_each(qe, &rxf->mcast_pending_del_q) {
 		mac = (struct bna_mac *)qe;
-		if (BNA_MAC_IS_EQUAL(&mac->addr, mac_addr))
+		if (ether_addr_equal(mac->addr, mac_addr))
 			return mac;
 	}
 
@@ -2396,20 +2396,19 @@ bna_rx_res_req(struct bna_rx_config *q_cfg, struct bna_res_info *res_info)
 
 	dq_depth = q_cfg->q0_depth;
 	hq_depth = ((q_cfg->rxp_type == BNA_RXP_SINGLE) ? 0 : q_cfg->q1_depth);
-	cq_depth = dq_depth + hq_depth;
+	cq_depth = roundup_pow_of_two(dq_depth + hq_depth);
 
-	BNA_TO_POWER_OF_2_HIGH(cq_depth);
 	cq_size = cq_depth * BFI_CQ_WI_SIZE;
 	cq_size = ALIGN(cq_size, PAGE_SIZE);
 	cpage_count = SIZE_TO_PAGES(cq_size);
 
-	BNA_TO_POWER_OF_2_HIGH(dq_depth);
+	dq_depth = roundup_pow_of_two(dq_depth);
 	dq_size = dq_depth * BFI_RXQ_WI_SIZE;
 	dq_size = ALIGN(dq_size, PAGE_SIZE);
 	dpage_count = SIZE_TO_PAGES(dq_size);
 
 	if (BNA_RXP_SINGLE != q_cfg->rxp_type) {
-		BNA_TO_POWER_OF_2_HIGH(hq_depth);
+		hq_depth = roundup_pow_of_two(hq_depth);
 		hq_size = hq_depth * BFI_RXQ_WI_SIZE;
 		hq_size = ALIGN(hq_size, PAGE_SIZE);
 		hpage_count = SIZE_TO_PAGES(hq_size);
@@ -2691,7 +2690,7 @@ bna_rx_create(struct bna *bna, struct bnad *bnad,
 		/* if multi-buffer is enabled sum of q0_depth
 		 * and q1_depth need not be a power of 2
 		 */
-		BNA_TO_POWER_OF_2_HIGH(cq_depth);
+		cq_depth = roundup_pow_of_two(cq_depth);
 		rxp->cq.ccb->q_depth = cq_depth;
 		rxp->cq.ccb->cq = &rxp->cq;
 		rxp->cq.ccb->rcb[0] = q0->rcb;
diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index 12f344d..ade251b 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -445,13 +445,13 @@ bnad_set_ringparam(struct net_device *netdev,
 
 	if (ringparam->rx_pending < BNAD_MIN_Q_DEPTH ||
 	    ringparam->rx_pending > BNAD_MAX_RXQ_DEPTH ||
-	    !BNA_POWER_OF_2(ringparam->rx_pending)) {
+	    !is_power_of_2(ringparam->rx_pending)) {
 		mutex_unlock(&bnad->conf_mutex);
 		return -EINVAL;
 	}
 	if (ringparam->tx_pending < BNAD_MIN_Q_DEPTH ||
 	    ringparam->tx_pending > BNAD_MAX_TXQ_DEPTH ||
-	    !BNA_POWER_OF_2(ringparam->tx_pending)) {
+	    !is_power_of_2(ringparam->tx_pending)) {
 		mutex_unlock(&bnad->conf_mutex);
 		return -EINVAL;
 	}
-- 
2.3.6
