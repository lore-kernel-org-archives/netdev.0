From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next v2 08/19] bna: remove oper_state_cbfn from struct bna_rxf
Date: Thu, 11 Jun 2015 15:52:20 +0200
Message-ID: <1434030751-28835-9-git-send-email-ivecera@redhat.com>
References: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58127 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754662AbbFKNwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 09:52:15 -0400
In-Reply-To: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bna.h       | 15 ---------------
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c |  6 ------
 drivers/net/ethernet/brocade/bna/bna_types.h |  4 ----
 3 files changed, 25 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna.h b/drivers/net/ethernet/brocade/bna/bna.h
index 0962e54..4f16ee2 100644
--- a/drivers/net/ethernet/brocade/bna/bna.h
+++ b/drivers/net/ethernet/brocade/bna/bna.h
@@ -119,21 +119,6 @@ do {									\
 	}								\
 } while (0)
 
-#define	call_rxf_pause_cbfn(rxf)					\
-do {									\
-	if ((rxf)->oper_state_cbfn) {					\
-		void (*cbfn)(struct bnad *, struct bna_rx *);	\
-		struct bnad *cbarg;					\
-		cbfn = (rxf)->oper_state_cbfn;				\
-		cbarg = (rxf)->oper_state_cbarg;			\
-		(rxf)->oper_state_cbfn = NULL;				\
-		(rxf)->oper_state_cbarg = NULL;				\
-		cbfn(cbarg, rxf->rx);					\
-	}								\
-} while (0)
-
-#define	call_rxf_resume_cbfn(rxf) call_rxf_pause_cbfn(rxf)
-
 #define is_xxx_enable(mode, bitmask, xxx) ((bitmask & xxx) && (mode & xxx))
 
 #define is_xxx_disable(mode, bitmask, xxx) ((bitmask & xxx) && !(mode & xxx))
diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 16d36df..27f75d7 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -103,12 +103,10 @@ bna_rxf_sm_stopped(struct bna_rxf *rxf, enum bna_rxf_event event)
 
 	case RXF_E_PAUSE:
 		rxf->flags |= BNA_RXF_F_PAUSED;
-		call_rxf_pause_cbfn(rxf);
 		break;
 
 	case RXF_E_RESUME:
 		rxf->flags &= ~BNA_RXF_F_PAUSED;
-		call_rxf_resume_cbfn(rxf);
 		break;
 
 	default:
@@ -119,7 +117,6 @@ bna_rxf_sm_stopped(struct bna_rxf *rxf, enum bna_rxf_event event)
 static void
 bna_rxf_sm_paused_entry(struct bna_rxf *rxf)
 {
-	call_rxf_pause_cbfn(rxf);
 }
 
 static void
@@ -166,7 +163,6 @@ bna_rxf_sm_cfg_wait(struct bna_rxf *rxf, enum bna_rxf_event event)
 		bna_rxf_cfg_reset(rxf);
 		call_rxf_start_cbfn(rxf);
 		call_rxf_cam_fltr_cbfn(rxf);
-		call_rxf_resume_cbfn(rxf);
 		bfa_fsm_set_state(rxf, bna_rxf_sm_stopped);
 		break;
 
@@ -197,7 +193,6 @@ bna_rxf_sm_started_entry(struct bna_rxf *rxf)
 {
 	call_rxf_start_cbfn(rxf);
 	call_rxf_cam_fltr_cbfn(rxf);
-	call_rxf_resume_cbfn(rxf);
 }
 
 static void
@@ -238,7 +233,6 @@ bna_rxf_sm_fltr_clr_wait(struct bna_rxf *rxf, enum bna_rxf_event event)
 	switch (event) {
 	case RXF_E_FAIL:
 		bna_rxf_cfg_reset(rxf);
-		call_rxf_pause_cbfn(rxf);
 		bfa_fsm_set_state(rxf, bna_rxf_sm_stopped);
 		break;
 
diff --git a/drivers/net/ethernet/brocade/bna/bna_types.h b/drivers/net/ethernet/brocade/bna/bna_types.h
index a50ee99..96a02f2 100644
--- a/drivers/net/ethernet/brocade/bna/bna_types.h
+++ b/drivers/net/ethernet/brocade/bna/bna_types.h
@@ -739,10 +739,6 @@ struct bna_rxf {
 	void (*stop_cbfn) (struct bna_rx *rx);
 	struct bna_rx *stop_cbarg;
 
-	/* callback for bna_rx_receive_pause() / bna_rx_receive_resume() */
-	void (*oper_state_cbfn) (struct bnad *bnad, struct bna_rx *rx);
-	struct bnad *oper_state_cbarg;
-
 	/**
 	 * callback for:
 	 *	bna_rxf_ucast_set()
-- 
2.3.6
