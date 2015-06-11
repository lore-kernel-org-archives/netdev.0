From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next v2 17/19] bna: use list_for_each_entry where appropriate
Date: Thu, 11 Jun 2015 15:52:29 +0200
Message-ID: <1434030751-28835-18-git-send-email-ivecera@redhat.com>
References: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54161 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933580AbbFKNw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 09:52:28 -0400
In-Reply-To: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bfa_ioc.c   |   5 +-
 drivers/net/ethernet/brocade/bna/bna.h       |  41 ++++------
 drivers/net/ethernet/brocade/bna/bna_enet.c  |  23 ------
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c | 117 +++++----------------------
 4 files changed, 37 insertions(+), 149 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index dabbb30..2c74beb 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -1091,12 +1091,9 @@ static void
 bfa_ioc_event_notify(struct bfa_ioc *ioc, enum bfa_ioc_event event)
 {
 	struct bfa_ioc_notify *notify;
-	struct list_head			*qe;
 
-	list_for_each(qe, &ioc->notify_q) {
-		notify = (struct bfa_ioc_notify *)qe;
+	list_for_each_entry(notify, &ioc->notify_q, qe)
 		notify->cbfn(notify->cbarg, event);
-	}
 }
 
 static void
diff --git a/drivers/net/ethernet/brocade/bna/bna.h b/drivers/net/ethernet/brocade/bna/bna.h
index 66e6e09..dc845b2 100644
--- a/drivers/net/ethernet/brocade/bna/bna.h
+++ b/drivers/net/ethernet/brocade/bna/bna.h
@@ -208,28 +208,24 @@ do {									\
 #define bna_rx_rid_mask(_bna) ((_bna)->rx_mod.rid_mask)
 
 #define bna_tx_from_rid(_bna, _rid, _tx)				\
-do {								    \
-	struct bna_tx_mod *__tx_mod = &(_bna)->tx_mod;	  \
-	struct bna_tx *__tx;					    \
-	struct list_head *qe;					   \
-	_tx = NULL;						     \
-	list_for_each(qe, &__tx_mod->tx_active_q) {		     \
-		__tx = (struct bna_tx *)qe;			     \
-		if (__tx->rid == (_rid)) {			      \
-			(_tx) = __tx;				   \
-			break;					  \
-		}						       \
-	}							       \
+do {									\
+	struct bna_tx_mod *__tx_mod = &(_bna)->tx_mod;			\
+	struct bna_tx *__tx;						\
+	_tx = NULL;							\
+	list_for_each_entry(__tx, &__tx_mod->tx_active_q, qe) {		\
+		if (__tx->rid == (_rid)) {				\
+			(_tx) = __tx;					\
+			break;						\
+		}							\
+	}								\
 } while (0)
 
 #define bna_rx_from_rid(_bna, _rid, _rx)				\
 do {									\
 	struct bna_rx_mod *__rx_mod = &(_bna)->rx_mod;			\
 	struct bna_rx *__rx;						\
-	struct list_head *qe;						\
 	_rx = NULL;							\
-	list_for_each(qe, &__rx_mod->rx_active_q) {			\
-		__rx = (struct bna_rx *)qe;				\
+	list_for_each_entry(__rx, &__rx_mod->rx_active_q, qe) {		\
 		if (__rx->rid == (_rid)) {				\
 			(_rx) = __rx;					\
 			break;						\
@@ -249,15 +245,12 @@ do {									\
 
 static inline struct bna_mac *bna_mac_find(struct list_head *q, u8 *addr)
 {
-	struct bna_mac *mac = NULL;
-	struct list_head *qe;
-	list_for_each(qe, q) {
-		if (ether_addr_equal(((struct bna_mac *)qe)->addr, addr)) {
-			mac = (struct bna_mac *)qe;
-			break;
-		}
-	}
-	return mac;
+	struct bna_mac *mac;
+
+	list_for_each_entry(mac, q, qe)
+		if (ether_addr_equal(mac->addr, addr))
+			return mac;
+	return NULL;
 }
 
 #define bna_attr(_bna) (&(_bna)->ioceth.attr)
diff --git a/drivers/net/ethernet/brocade/bna/bna_enet.c b/drivers/net/ethernet/brocade/bna/bna_enet.c
index bd8f2c2..05680e0 100644
--- a/drivers/net/ethernet/brocade/bna/bna_enet.c
+++ b/drivers/net/ethernet/brocade/bna/bna_enet.c
@@ -1806,17 +1806,6 @@ bna_ucam_mod_init(struct bna_ucam_mod *ucam_mod, struct bna *bna,
 static void
 bna_ucam_mod_uninit(struct bna_ucam_mod *ucam_mod)
 {
-	struct list_head *qe;
-	int i;
-
-	i = 0;
-	list_for_each(qe, &ucam_mod->free_q)
-		i++;
-
-	i = 0;
-	list_for_each(qe, &ucam_mod->del_q)
-		i++;
-
 	ucam_mod->bna = NULL;
 }
 
@@ -1852,18 +1841,6 @@ bna_mcam_mod_init(struct bna_mcam_mod *mcam_mod, struct bna *bna,
 static void
 bna_mcam_mod_uninit(struct bna_mcam_mod *mcam_mod)
 {
-	struct list_head *qe;
-	int i;
-
-	i = 0;
-	list_for_each(qe, &mcam_mod->free_q) i++;
-
-	i = 0;
-	list_for_each(qe, &mcam_mod->del_q) i++;
-
-	i = 0;
-	list_for_each(qe, &mcam_mod->free_handle_q) i++;
-
 	mcam_mod->bna = NULL;
 }
 
diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 1245bb1..64eb8c4 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -356,19 +356,14 @@ static struct bna_mac *
 bna_rxf_mcmac_get(struct bna_rxf *rxf, u8 *mac_addr)
 {
 	struct bna_mac *mac;
-	struct list_head *qe;
 
-	list_for_each(qe, &rxf->mcast_active_q) {
-		mac = (struct bna_mac *)qe;
+	list_for_each_entry(mac, &rxf->mcast_active_q, qe)
 		if (ether_addr_equal(mac->addr, mac_addr))
 			return mac;
-	}
 
-	list_for_each(qe, &rxf->mcast_pending_del_q) {
-		mac = (struct bna_mac *)qe;
+	list_for_each_entry(mac, &rxf->mcast_pending_del_q, qe)
 		if (ether_addr_equal(mac->addr, mac_addr))
 			return mac;
-	}
 
 	return NULL;
 }
@@ -377,13 +372,10 @@ static struct bna_mcam_handle *
 bna_rxf_mchandle_get(struct bna_rxf *rxf, int handle)
 {
 	struct bna_mcam_handle *mchandle;
-	struct list_head *qe;
 
-	list_for_each(qe, &rxf->mcast_handle_q) {
-		mchandle = (struct bna_mcam_handle *)qe;
+	list_for_each_entry(mchandle, &rxf->mcast_handle_q, qe)
 		if (mchandle->handle == handle)
 			return mchandle;
-	}
 
 	return NULL;
 }
@@ -576,16 +568,13 @@ bna_rit_init(struct bna_rxf *rxf, int rit_size)
 {
 	struct bna_rx *rx = rxf->rx;
 	struct bna_rxp *rxp;
-	struct list_head *qe;
 	int offset = 0;
 
 	rxf->rit_size = rit_size;
-	list_for_each(qe, &rx->rxp_q) {
-		rxp = (struct bna_rxp *)qe;
+	list_for_each_entry(rxp, &rx->rxp_q, qe) {
 		rxf->rit[offset] = rxp->cq.ccb->id;
 		offset++;
 	}
-
 }
 
 void
@@ -1487,14 +1476,11 @@ static void
 bna_rx_sm_started_entry(struct bna_rx *rx)
 {
 	struct bna_rxp *rxp;
-	struct list_head *qe_rxp;
 	int is_regular = (rx->type == BNA_RX_T_REGULAR);
 
 	/* Start IB */
-	list_for_each(qe_rxp, &rx->rxp_q) {
-		rxp = (struct bna_rxp *)qe_rxp;
+	list_for_each_entry(rxp, &rx->rxp_q, qe)
 		bna_ib_start(rx->bna, &rxp->cq.ib, is_regular);
-	}
 
 	bna_ethport_cb_rx_started(&rx->bna->ethport);
 }
@@ -1751,13 +1737,10 @@ static void
 bna_rx_enet_stop(struct bna_rx *rx)
 {
 	struct bna_rxp *rxp;
-	struct list_head		 *qe_rxp;
 
 	/* Stop IB */
-	list_for_each(qe_rxp, &rx->rxp_q) {
-		rxp = (struct bna_rxp *)qe_rxp;
+	list_for_each_entry(rxp, &rx->rxp_q, qe)
 		bna_ib_stop(rx->bna, &rxp->cq.ib);
-	}
 
 	bna_bfi_rx_enet_stop(rx);
 }
@@ -2002,24 +1985,20 @@ void
 bna_rx_mod_start(struct bna_rx_mod *rx_mod, enum bna_rx_type type)
 {
 	struct bna_rx *rx;
-	struct list_head *qe;
 
 	rx_mod->flags |= BNA_RX_MOD_F_ENET_STARTED;
 	if (type == BNA_RX_T_LOOPBACK)
 		rx_mod->flags |= BNA_RX_MOD_F_ENET_LOOPBACK;
 
-	list_for_each(qe, &rx_mod->rx_active_q) {
-		rx = (struct bna_rx *)qe;
+	list_for_each_entry(rx, &rx_mod->rx_active_q, qe)
 		if (rx->type == type)
 			bna_rx_start(rx);
-	}
 }
 
 void
 bna_rx_mod_stop(struct bna_rx_mod *rx_mod, enum bna_rx_type type)
 {
 	struct bna_rx *rx;
-	struct list_head *qe;
 
 	rx_mod->flags &= ~BNA_RX_MOD_F_ENET_STARTED;
 	rx_mod->flags &= ~BNA_RX_MOD_F_ENET_LOOPBACK;
@@ -2028,13 +2007,11 @@ bna_rx_mod_stop(struct bna_rx_mod *rx_mod, enum bna_rx_type type)
 
 	bfa_wc_init(&rx_mod->rx_stop_wc, bna_rx_mod_cb_rx_stopped_all, rx_mod);
 
-	list_for_each(qe, &rx_mod->rx_active_q) {
-		rx = (struct bna_rx *)qe;
+	list_for_each_entry(rx, &rx_mod->rx_active_q, qe)
 		if (rx->type == type) {
 			bfa_wc_up(&rx_mod->rx_stop_wc);
 			bna_rx_stop(rx);
 		}
-	}
 
 	bfa_wc_wait(&rx_mod->rx_stop_wc);
 }
@@ -2043,15 +2020,12 @@ void
 bna_rx_mod_fail(struct bna_rx_mod *rx_mod)
 {
 	struct bna_rx *rx;
-	struct list_head *qe;
 
 	rx_mod->flags &= ~BNA_RX_MOD_F_ENET_STARTED;
 	rx_mod->flags &= ~BNA_RX_MOD_F_ENET_LOOPBACK;
 
-	list_for_each(qe, &rx_mod->rx_active_q) {
-		rx = (struct bna_rx *)qe;
+	list_for_each_entry(rx, &rx_mod->rx_active_q, qe)
 		bna_rx_fail(rx);
-	}
 }
 
 void bna_rx_mod_init(struct bna_rx_mod *rx_mod, struct bna *bna,
@@ -2113,21 +2087,6 @@ void bna_rx_mod_init(struct bna_rx_mod *rx_mod, struct bna *bna,
 void
 bna_rx_mod_uninit(struct bna_rx_mod *rx_mod)
 {
-	struct list_head		*qe;
-	int i;
-
-	i = 0;
-	list_for_each(qe, &rx_mod->rx_free_q)
-		i++;
-
-	i = 0;
-	list_for_each(qe, &rx_mod->rxp_free_q)
-		i++;
-
-	i = 0;
-	list_for_each(qe, &rx_mod->rxq_free_q)
-		i++;
-
 	rx_mod->bna = NULL;
 }
 
@@ -2721,10 +2680,8 @@ void
 bna_rx_coalescing_timeo_set(struct bna_rx *rx, int coalescing_timeo)
 {
 	struct bna_rxp *rxp;
-	struct list_head *qe;
 
-	list_for_each(qe, &rx->rxp_q) {
-		rxp = (struct bna_rxp *)qe;
+	list_for_each_entry(rxp, &rx->rxp_q, qe) {
 		rxp->cq.ccb->rx_coalescing_timeo = coalescing_timeo;
 		bna_ib_coalescing_timeo_set(&rxp->cq.ib, coalescing_timeo);
 	}
@@ -2917,11 +2874,9 @@ static void
 bna_tx_sm_started_entry(struct bna_tx *tx)
 {
 	struct bna_txq *txq;
-	struct list_head		 *qe;
 	int is_regular = (tx->type == BNA_TX_T_REGULAR);
 
-	list_for_each(qe, &tx->txq_q) {
-		txq = (struct bna_txq *)qe;
+	list_for_each_entry(txq, &tx->txq_q, qe) {
 		txq->tcb->priority = txq->priority;
 		/* Start IB */
 		bna_ib_start(tx->bna, &txq->ib, is_regular);
@@ -3200,13 +3155,10 @@ static void
 bna_tx_enet_stop(struct bna_tx *tx)
 {
 	struct bna_txq *txq;
-	struct list_head		 *qe;
 
 	/* Stop IB */
-	list_for_each(qe, &tx->txq_q) {
-		txq = (struct bna_txq *)qe;
+	list_for_each_entry(txq, &tx->txq_q, qe)
 		bna_ib_stop(tx->bna, &txq->ib);
-	}
 
 	bna_bfi_tx_enet_stop(tx);
 }
@@ -3361,12 +3313,9 @@ void
 bna_bfi_bw_update_aen(struct bna_tx_mod *tx_mod)
 {
 	struct bna_tx *tx;
-	struct list_head		*qe;
 
-	list_for_each(qe, &tx_mod->tx_active_q) {
-		tx = (struct bna_tx *)qe;
+	list_for_each_entry(tx, &tx_mod->tx_active_q, qe)
 		bfa_fsm_send_event(tx, TX_E_BW_UPDATE);
-	}
 }
 
 void
@@ -3426,7 +3375,6 @@ bna_tx_create(struct bna *bna, struct bnad *bnad,
 	struct bna_tx_mod *tx_mod = &bna->tx_mod;
 	struct bna_tx *tx;
 	struct bna_txq *txq;
-	struct list_head *qe;
 	int page_count;
 	int i;
 
@@ -3496,8 +3444,7 @@ bna_tx_create(struct bna *bna, struct bnad *bnad,
 	/* TxQ */
 
 	i = 0;
-	list_for_each(qe, &tx->txq_q) {
-		txq = (struct bna_txq *)qe;
+	list_for_each_entry(txq, &tx->txq_q, qe) {
 		txq->tcb = (struct bna_tcb *)
 		res_info[BNA_TX_RES_MEM_T_TCB].res_u.mem_info.mdl[i].kva;
 		txq->tx_packets = 0;
@@ -3570,13 +3517,10 @@ void
 bna_tx_destroy(struct bna_tx *tx)
 {
 	struct bna_txq *txq;
-	struct list_head *qe;
 
-	list_for_each(qe, &tx->txq_q) {
-		txq = (struct bna_txq *)qe;
+	list_for_each_entry(txq, &tx->txq_q, qe)
 		if (tx->tcb_destroy_cbfn)
 			(tx->tcb_destroy_cbfn)(tx->bna->bnad, txq->tcb);
-	}
 
 	tx->bna->tx_mod.rid_mask &= ~BIT(tx->rid);
 	bna_tx_free(tx);
@@ -3669,17 +3613,6 @@ bna_tx_mod_init(struct bna_tx_mod *tx_mod, struct bna *bna,
 void
 bna_tx_mod_uninit(struct bna_tx_mod *tx_mod)
 {
-	struct list_head		*qe;
-	int i;
-
-	i = 0;
-	list_for_each(qe, &tx_mod->tx_free_q)
-		i++;
-
-	i = 0;
-	list_for_each(qe, &tx_mod->txq_free_q)
-		i++;
-
 	tx_mod->bna = NULL;
 }
 
@@ -3687,24 +3620,20 @@ void
 bna_tx_mod_start(struct bna_tx_mod *tx_mod, enum bna_tx_type type)
 {
 	struct bna_tx *tx;
-	struct list_head		*qe;
 
 	tx_mod->flags |= BNA_TX_MOD_F_ENET_STARTED;
 	if (type == BNA_TX_T_LOOPBACK)
 		tx_mod->flags |= BNA_TX_MOD_F_ENET_LOOPBACK;
 
-	list_for_each(qe, &tx_mod->tx_active_q) {
-		tx = (struct bna_tx *)qe;
+	list_for_each_entry(tx, &tx_mod->tx_active_q, qe)
 		if (tx->type == type)
 			bna_tx_start(tx);
-	}
 }
 
 void
 bna_tx_mod_stop(struct bna_tx_mod *tx_mod, enum bna_tx_type type)
 {
 	struct bna_tx *tx;
-	struct list_head		*qe;
 
 	tx_mod->flags &= ~BNA_TX_MOD_F_ENET_STARTED;
 	tx_mod->flags &= ~BNA_TX_MOD_F_ENET_LOOPBACK;
@@ -3713,13 +3642,11 @@ bna_tx_mod_stop(struct bna_tx_mod *tx_mod, enum bna_tx_type type)
 
 	bfa_wc_init(&tx_mod->tx_stop_wc, bna_tx_mod_cb_tx_stopped_all, tx_mod);
 
-	list_for_each(qe, &tx_mod->tx_active_q) {
-		tx = (struct bna_tx *)qe;
+	list_for_each_entry(tx, &tx_mod->tx_active_q, qe)
 		if (tx->type == type) {
 			bfa_wc_up(&tx_mod->tx_stop_wc);
 			bna_tx_stop(tx);
 		}
-	}
 
 	bfa_wc_wait(&tx_mod->tx_stop_wc);
 }
@@ -3728,25 +3655,19 @@ void
 bna_tx_mod_fail(struct bna_tx_mod *tx_mod)
 {
 	struct bna_tx *tx;
-	struct list_head		*qe;
 
 	tx_mod->flags &= ~BNA_TX_MOD_F_ENET_STARTED;
 	tx_mod->flags &= ~BNA_TX_MOD_F_ENET_LOOPBACK;
 
-	list_for_each(qe, &tx_mod->tx_active_q) {
-		tx = (struct bna_tx *)qe;
+	list_for_each_entry(tx, &tx_mod->tx_active_q, qe)
 		bna_tx_fail(tx);
-	}
 }
 
 void
 bna_tx_coalescing_timeo_set(struct bna_tx *tx, int coalescing_timeo)
 {
 	struct bna_txq *txq;
-	struct list_head *qe;
 
-	list_for_each(qe, &tx->txq_q) {
-		txq = (struct bna_txq *)qe;
+	list_for_each_entry(txq, &tx->txq_q, qe)
 		bna_ib_coalescing_timeo_set(&txq->ib, coalescing_timeo);
-	}
 }
-- 
2.3.6
