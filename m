From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] bna: make function tables cont
Date: Fri, 16 Sep 2011 14:09:51 -0700
Message-ID: <20110916140951.6318785d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rasesh Mody <rmody@brocade.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42660 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932215Ab1IPVJv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 17:09:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To prevent malicious usage, all tables of pointers must be const.

Compile tested only.
Gleaned for PAX.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/ethernet/brocade/bna/bfa_ioc.h    |    2 -
 drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c |   36 ++++++++++----------------
 drivers/net/ethernet/brocade/bna/bna.h        |    4 +-
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c  |    4 +-
 drivers/net/ethernet/brocade/bna/bnad.c       |   33 +++++++++++------------
 5 files changed, 36 insertions(+), 43 deletions(-)

--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.h	2011-09-16 13:35:52.245432520 -0700
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.h	2011-09-16 13:35:54.593432627 -0700
@@ -199,7 +199,7 @@ struct bfa_ioc {
 	struct bfi_ioc_attr	*attr;
 	struct bfa_ioc_cbfn	*cbfn;
 	struct bfa_ioc_mbox_mod	mbox_mod;
-	struct bfa_ioc_hwif	*ioc_hwif;
+	const struct bfa_ioc_hwif *ioc_hwif;
 	struct bfa_iocpf	iocpf;
 	enum bfi_asic_gen	asic_gen;
 	enum bfi_asic_mode	asic_mode;
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c	2011-09-16 13:35:52.273432521 -0700
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c	2011-09-16 13:40:28.501445140 -0700
@@ -49,21 +49,21 @@ static bool bfa_ioc_ct_sync_complete(str
 static enum bfa_status bfa_ioc_ct_pll_init(void __iomem *rb,
 				enum bfi_asic_mode asic_mode);
 
-static struct bfa_ioc_hwif nw_hwif_ct;
-
-static void
-bfa_ioc_set_ctx_hwif(struct bfa_ioc *ioc, struct bfa_ioc_hwif *hwif)
-{
-	hwif->ioc_firmware_lock = bfa_ioc_ct_firmware_lock;
-	hwif->ioc_firmware_unlock = bfa_ioc_ct_firmware_unlock;
-	hwif->ioc_notify_fail = bfa_ioc_ct_notify_fail;
-	hwif->ioc_ownership_reset = bfa_ioc_ct_ownership_reset;
-	hwif->ioc_sync_start = bfa_ioc_ct_sync_start;
-	hwif->ioc_sync_join = bfa_ioc_ct_sync_join;
-	hwif->ioc_sync_leave = bfa_ioc_ct_sync_leave;
-	hwif->ioc_sync_ack = bfa_ioc_ct_sync_ack;
-	hwif->ioc_sync_complete = bfa_ioc_ct_sync_complete;
-}
+static const struct bfa_ioc_hwif nw_hwif_ct = {
+	.ioc_pll_init	     = bfa_ioc_ct_pll_init,
+	.ioc_firmware_lock   = bfa_ioc_ct_firmware_lock,
+	.ioc_firmware_unlock = bfa_ioc_ct_firmware_unlock,
+	.ioc_reg_init	     = bfa_ioc_ct_reg_init,
+	.ioc_map_port	     = bfa_ioc_ct_map_port,
+	.ioc_isr_mode_set    = bfa_ioc_ct_isr_mode_set,
+	.ioc_notify_fail     = bfa_ioc_ct_notify_fail,
+	.ioc_ownership_reset = bfa_ioc_ct_ownership_reset,
+	.ioc_sync_start      = bfa_ioc_ct_sync_start,
+	.ioc_sync_join       = bfa_ioc_ct_sync_join,
+	.ioc_sync_leave	     = bfa_ioc_ct_sync_leave,
+	.ioc_sync_ack	     = bfa_ioc_ct_sync_ack,
+	.ioc_sync_complete   = bfa_ioc_ct_sync_complete,
+};
 
 /**
  * Called from bfa_ioc_attach() to map asic specific calls.
@@ -71,12 +71,6 @@ bfa_ioc_set_ctx_hwif(struct bfa_ioc *ioc
 void
 bfa_nw_ioc_set_ct_hwif(struct bfa_ioc *ioc)
 {
-	bfa_ioc_set_ctx_hwif(ioc, &nw_hwif_ct);
-
-	nw_hwif_ct.ioc_pll_init = bfa_ioc_ct_pll_init;
-	nw_hwif_ct.ioc_reg_init = bfa_ioc_ct_reg_init;
-	nw_hwif_ct.ioc_map_port = bfa_ioc_ct_map_port;
-	nw_hwif_ct.ioc_isr_mode_set = bfa_ioc_ct_isr_mode_set;
 	ioc->ioc_hwif = &nw_hwif_ct;
 }
 
--- a/drivers/net/ethernet/brocade/bna/bna.h	2011-09-16 13:35:52.257432521 -0700
+++ b/drivers/net/ethernet/brocade/bna/bna.h	2011-09-16 13:35:54.593432627 -0700
@@ -453,7 +453,7 @@ void bna_tx_res_req(int num_txq, int txq
 		    struct bna_res_info *res_info);
 struct bna_tx *bna_tx_create(struct bna *bna, struct bnad *bnad,
 			       struct bna_tx_config *tx_cfg,
-			       struct bna_tx_event_cbfn *tx_cbfn,
+			       const struct bna_tx_event_cbfn *tx_cbfn,
 			       struct bna_res_info *res_info, void *priv);
 void bna_tx_destroy(struct bna_tx *tx);
 void bna_tx_enable(struct bna_tx *tx);
@@ -490,7 +490,7 @@ void bna_rx_res_req(struct bna_rx_config
 		    struct bna_res_info *res_info);
 struct bna_rx *bna_rx_create(struct bna *bna, struct bnad *bnad,
 			       struct bna_rx_config *rx_cfg,
-			       struct bna_rx_event_cbfn *rx_cbfn,
+			       const struct bna_rx_event_cbfn *rx_cbfn,
 			       struct bna_res_info *res_info, void *priv);
 void bna_rx_destroy(struct bna_rx *rx);
 void bna_rx_enable(struct bna_rx *rx);
--- a/drivers/net/ethernet/brocade/bna/bnad.c	2011-09-16 13:35:52.237432520 -0700
+++ b/drivers/net/ethernet/brocade/bna/bnad.c	2011-09-16 13:35:54.597432628 -0700
@@ -1730,7 +1730,14 @@ bnad_setup_tx(struct bnad *bnad, u32 tx_
 	struct bna_intr_info *intr_info =
 			&res_info[BNA_TX_RES_INTR_T_TXCMPL].res_u.intr_info;
 	struct bna_tx_config *tx_config = &bnad->tx_config[tx_id];
-	struct bna_tx_event_cbfn tx_cbfn;
+	static const struct bna_tx_event_cbfn tx_cbfn = {
+		.tcb_setup_cbfn = bnad_cb_tcb_setup,
+		.tcb_destroy_cbfn = bnad_cb_tcb_destroy,
+		.tx_stall_cbfn = bnad_cb_tx_stall,
+		.tx_resume_cbfn = bnad_cb_tx_resume,
+		.tx_cleanup_cbfn = bnad_cb_tx_cleanup,
+	};
+
 	struct bna_tx *tx;
 	unsigned long flags;
 
@@ -1742,13 +1749,6 @@ bnad_setup_tx(struct bnad *bnad, u32 tx_
 	tx_config->tx_type = BNA_TX_T_REGULAR;
 	tx_config->coalescing_timeo = bnad->tx_coalescing_timeo;
 
-	/* Initialize the tx event handlers */
-	tx_cbfn.tcb_setup_cbfn = bnad_cb_tcb_setup;
-	tx_cbfn.tcb_destroy_cbfn = bnad_cb_tcb_destroy;
-	tx_cbfn.tx_stall_cbfn = bnad_cb_tx_stall;
-	tx_cbfn.tx_resume_cbfn = bnad_cb_tx_resume;
-	tx_cbfn.tx_cleanup_cbfn = bnad_cb_tx_cleanup;
-
 	/* Get BNA's resource requirement for one tx object */
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_tx_res_req(bnad->num_txq_per_tx,
@@ -1893,7 +1893,14 @@ bnad_setup_rx(struct bnad *bnad, u32 rx_
 	struct bna_intr_info *intr_info =
 			&res_info[BNA_RX_RES_T_INTR].res_u.intr_info;
 	struct bna_rx_config *rx_config = &bnad->rx_config[rx_id];
-	struct bna_rx_event_cbfn rx_cbfn;
+	static const struct bna_rx_event_cbfn rx_cbfn = {
+		.rcb_setup_cbfn = bnad_cb_rcb_setup,
+		.rcb_destroy_cbfn = bnad_cb_rcb_destroy,
+		.ccb_setup_cbfn = bnad_cb_ccb_setup,
+		.ccb_destroy_cbfn = bnad_cb_ccb_destroy,
+		.rx_cleanup_cbfn = bnad_cb_rx_cleanup,
+		.rx_post_cbfn = bnad_cb_rx_post,
+	};
 	struct bna_rx *rx;
 	unsigned long flags;
 
@@ -1902,14 +1909,6 @@ bnad_setup_rx(struct bnad *bnad, u32 rx_
 	/* Initialize the Rx object configuration */
 	bnad_init_rx_config(bnad, rx_config);
 
-	/* Initialize the Rx event handlers */
-	rx_cbfn.rcb_setup_cbfn = bnad_cb_rcb_setup;
-	rx_cbfn.rcb_destroy_cbfn = bnad_cb_rcb_destroy;
-	rx_cbfn.ccb_setup_cbfn = bnad_cb_ccb_setup;
-	rx_cbfn.ccb_destroy_cbfn = bnad_cb_ccb_destroy;
-	rx_cbfn.rx_cleanup_cbfn = bnad_cb_rx_cleanup;
-	rx_cbfn.rx_post_cbfn = bnad_cb_rx_post;
-
 	/* Get BNA's resource requirement for one Rx object */
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_rx_res_req(rx_config, res_info);
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c	2011-09-16 13:36:57.733435512 -0700
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c	2011-09-16 13:37:07.885435977 -0700
@@ -2305,7 +2305,7 @@ bna_rx_res_req(struct bna_rx_config *q_c
 struct bna_rx *
 bna_rx_create(struct bna *bna, struct bnad *bnad,
 		struct bna_rx_config *rx_cfg,
-		struct bna_rx_event_cbfn *rx_cbfn,
+		const struct bna_rx_event_cbfn *rx_cbfn,
 		struct bna_res_info *res_info,
 		void *priv)
 {
@@ -3444,7 +3444,7 @@ bna_tx_res_req(int num_txq, int txq_dept
 struct bna_tx *
 bna_tx_create(struct bna *bna, struct bnad *bnad,
 		struct bna_tx_config *tx_cfg,
-		struct bna_tx_event_cbfn *tx_cbfn,
+		const struct bna_tx_event_cbfn *tx_cbfn,
 		struct bna_res_info *res_info, void *priv)
 {
 	struct bna_intr_info *intr_info;
