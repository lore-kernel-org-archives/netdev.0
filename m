From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 11/19] bna: remove paused from bna_rx_config and flags from bna_rxf
Date: Wed, 10 Jun 2015 18:43:17 +0200
Message-ID: <1433954605-22813-12-git-send-email-ivecera@redhat.com>
References: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50253 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965465AbbFJQnL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 12:43:11 -0400
In-Reply-To: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bna_rx_config struct member paused can be removed as it is never
written and as it cannot have non-zero value the bna_rxf struct member
flags also cannot have BNA_RXF_F_PAUSED value and is always zero.
So the flags member can be removed as well as bna_rxf_flags enum and
the code-paths that needs to have non-zero bna_rxf->flags.
This clean-up makes bna_rxf_sm_paused state unsed and can be also removed.
---
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c | 36 +---------------------------
 drivers/net/ethernet/brocade/bna/bna_types.h |  6 -----
 2 files changed, 1 insertion(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index ccf48a1..896aa82 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -59,8 +59,6 @@ static int bna_rxf_allmulti_cfg_reset(struct bna_rxf *rxf,
 
 bfa_fsm_state_decl(bna_rxf, stopped, struct bna_rxf,
 			enum bna_rxf_event);
-bfa_fsm_state_decl(bna_rxf, paused, struct bna_rxf,
-			enum bna_rxf_event);
 bfa_fsm_state_decl(bna_rxf, cfg_wait, struct bna_rxf,
 			enum bna_rxf_event);
 bfa_fsm_state_decl(bna_rxf, started, struct bna_rxf,
@@ -79,11 +77,7 @@ bna_rxf_sm_stopped(struct bna_rxf *rxf, enum bna_rxf_event event)
 {
 	switch (event) {
 	case RXF_E_START:
-		if (rxf->flags & BNA_RXF_F_PAUSED) {
-			bfa_fsm_set_state(rxf, bna_rxf_sm_paused);
-			call_rxf_start_cbfn(rxf);
-		} else
-			bfa_fsm_set_state(rxf, bna_rxf_sm_cfg_wait);
+		bfa_fsm_set_state(rxf, bna_rxf_sm_cfg_wait);
 		break;
 
 	case RXF_E_STOP:
@@ -104,29 +98,6 @@ bna_rxf_sm_stopped(struct bna_rxf *rxf, enum bna_rxf_event event)
 }
 
 static void
-bna_rxf_sm_paused_entry(struct bna_rxf *rxf)
-{
-}
-
-static void
-bna_rxf_sm_paused(struct bna_rxf *rxf, enum bna_rxf_event event)
-{
-	switch (event) {
-	case RXF_E_STOP:
-	case RXF_E_FAIL:
-		bfa_fsm_set_state(rxf, bna_rxf_sm_stopped);
-		break;
-
-	case RXF_E_CONFIG:
-		call_rxf_cam_fltr_cbfn(rxf);
-		break;
-
-	default:
-		bfa_sm_fault(event);
-	}
-}
-
-static void
 bna_rxf_sm_cfg_wait_entry(struct bna_rxf *rxf)
 {
 	if (!bna_rxf_cfg_apply(rxf)) {
@@ -679,9 +650,6 @@ bna_rxf_init(struct bna_rxf *rxf,
 	INIT_LIST_HEAD(&rxf->mcast_active_q);
 	INIT_LIST_HEAD(&rxf->mcast_handle_q);
 
-	if (q_config->paused)
-		rxf->flags |= BNA_RXF_F_PAUSED;
-
 	rxf->rit = (u8 *)
 		res_info[BNA_RX_RES_MEM_T_RIT].res_u.mem_info.mdl[0].kva;
 	bna_rit_init(rxf, q_config->num_paths);
@@ -742,8 +710,6 @@ bna_rxf_uninit(struct bna_rxf *rxf)
 	rxf->rss_pending = 0;
 	rxf->vlan_strip_pending = false;
 
-	rxf->flags = 0;
-
 	rxf->rx = NULL;
 }
 
diff --git a/drivers/net/ethernet/brocade/bna/bna_types.h b/drivers/net/ethernet/brocade/bna/bna_types.h
index e56f650..134abf7 100644
--- a/drivers/net/ethernet/brocade/bna/bna_types.h
+++ b/drivers/net/ethernet/brocade/bna/bna_types.h
@@ -182,10 +182,6 @@ enum bna_rx_mod_flags {
 	BNA_RX_MOD_F_ENET_LOOPBACK	= 2,
 };
 
-enum bna_rxf_flags {
-	BNA_RXF_F_PAUSED		= 1,
-};
-
 enum bna_rxf_event {
 	RXF_E_START			= 1,
 	RXF_E_STOP			= 2,
@@ -668,7 +664,6 @@ struct bna_rx_config {
 	enum bna_rx_type rx_type;
 	int			num_paths;
 	enum bna_rxp_type rxp_type;
-	int			paused;
 	int			coalescing_timeo;
 	/*
 	 * Small/Large (or Header/Data) buffer size to be configured
@@ -713,7 +708,6 @@ struct bna_rxp {
 /* RxF structure (hardware Rx Function) */
 struct bna_rxf {
 	bfa_fsm_t		fsm;
-	enum bna_rxf_flags flags;
 
 	struct bfa_msgq_cmd_entry msgq_cmd;
 	union {
-- 
2.3.6
