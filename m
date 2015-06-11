From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next v2 10/19] bna: remove RXF_E_PAUSE and RXF_E_RESUME events
Date: Thu, 11 Jun 2015 15:52:22 +0200
Message-ID: <1434030751-28835-11-git-send-email-ivecera@redhat.com>
References: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58152 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754668AbbFKNwS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 09:52:18 -0400
In-Reply-To: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RXF_E_PAUSE & RXF_E_RESUME events are never sent for bna_rxf object so
they needn't to be handled. The bna_rxf's state bna_rxf_sm_fltr_clr_wait
and function bna_rxf_fltr_clear are unused after this so remove them also.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c | 75 ----------------------------
 drivers/net/ethernet/brocade/bna/bna_types.h |  2 -
 2 files changed, 77 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 471e74d..ccf48a1 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -46,7 +46,6 @@ do {									\
 
 static int bna_rxf_cfg_apply(struct bna_rxf *rxf);
 static void bna_rxf_cfg_reset(struct bna_rxf *rxf);
-static int bna_rxf_fltr_clear(struct bna_rxf *rxf);
 static int bna_rxf_ucast_cfg_apply(struct bna_rxf *rxf);
 static int bna_rxf_promisc_cfg_apply(struct bna_rxf *rxf);
 static int bna_rxf_allmulti_cfg_apply(struct bna_rxf *rxf);
@@ -66,8 +65,6 @@ bfa_fsm_state_decl(bna_rxf, cfg_wait, struct bna_rxf,
 			enum bna_rxf_event);
 bfa_fsm_state_decl(bna_rxf, started, struct bna_rxf,
 			enum bna_rxf_event);
-bfa_fsm_state_decl(bna_rxf, fltr_clr_wait, struct bna_rxf,
-			enum bna_rxf_event);
 bfa_fsm_state_decl(bna_rxf, last_resp_wait, struct bna_rxf,
 			enum bna_rxf_event);
 
@@ -101,14 +98,6 @@ bna_rxf_sm_stopped(struct bna_rxf *rxf, enum bna_rxf_event event)
 		call_rxf_cam_fltr_cbfn(rxf);
 		break;
 
-	case RXF_E_PAUSE:
-		rxf->flags |= BNA_RXF_F_PAUSED;
-		break;
-
-	case RXF_E_RESUME:
-		rxf->flags &= ~BNA_RXF_F_PAUSED;
-		break;
-
 	default:
 		bfa_sm_fault(event);
 	}
@@ -132,11 +121,6 @@ bna_rxf_sm_paused(struct bna_rxf *rxf, enum bna_rxf_event event)
 		call_rxf_cam_fltr_cbfn(rxf);
 		break;
 
-	case RXF_E_RESUME:
-		rxf->flags &= ~BNA_RXF_F_PAUSED;
-		bfa_fsm_set_state(rxf, bna_rxf_sm_cfg_wait);
-		break;
-
 	default:
 		bfa_sm_fault(event);
 	}
@@ -170,12 +154,6 @@ bna_rxf_sm_cfg_wait(struct bna_rxf *rxf, enum bna_rxf_event event)
 		/* No-op */
 		break;
 
-	case RXF_E_PAUSE:
-		rxf->flags |= BNA_RXF_F_PAUSED;
-		call_rxf_start_cbfn(rxf);
-		bfa_fsm_set_state(rxf, bna_rxf_sm_fltr_clr_wait);
-		break;
-
 	case RXF_E_FW_RESP:
 		if (!bna_rxf_cfg_apply(rxf)) {
 			/* No more pending config updates */
@@ -209,40 +187,6 @@ bna_rxf_sm_started(struct bna_rxf *rxf, enum bna_rxf_event event)
 		bfa_fsm_set_state(rxf, bna_rxf_sm_cfg_wait);
 		break;
 
-	case RXF_E_PAUSE:
-		rxf->flags |= BNA_RXF_F_PAUSED;
-		if (!bna_rxf_fltr_clear(rxf))
-			bfa_fsm_set_state(rxf, bna_rxf_sm_paused);
-		else
-			bfa_fsm_set_state(rxf, bna_rxf_sm_fltr_clr_wait);
-		break;
-
-	default:
-		bfa_sm_fault(event);
-	}
-}
-
-static void
-bna_rxf_sm_fltr_clr_wait_entry(struct bna_rxf *rxf)
-{
-}
-
-static void
-bna_rxf_sm_fltr_clr_wait(struct bna_rxf *rxf, enum bna_rxf_event event)
-{
-	switch (event) {
-	case RXF_E_FAIL:
-		bna_rxf_cfg_reset(rxf);
-		bfa_fsm_set_state(rxf, bna_rxf_sm_stopped);
-		break;
-
-	case RXF_E_FW_RESP:
-		if (!bna_rxf_fltr_clear(rxf)) {
-			/* No more pending CAM entries to clear */
-			bfa_fsm_set_state(rxf, bna_rxf_sm_paused);
-		}
-		break;
-
 	default:
 		bfa_sm_fault(event);
 	}
@@ -652,25 +596,6 @@ bna_rxf_cfg_apply(struct bna_rxf *rxf)
 	return 0;
 }
 
-/* Only software reset */
-static int
-bna_rxf_fltr_clear(struct bna_rxf *rxf)
-{
-	if (bna_rxf_ucast_cfg_reset(rxf, BNA_HARD_CLEANUP))
-		return 1;
-
-	if (bna_rxf_mcast_cfg_reset(rxf, BNA_HARD_CLEANUP))
-		return 1;
-
-	if (bna_rxf_promisc_cfg_reset(rxf, BNA_HARD_CLEANUP))
-		return 1;
-
-	if (bna_rxf_allmulti_cfg_reset(rxf, BNA_HARD_CLEANUP))
-		return 1;
-
-	return 0;
-}
-
 static void
 bna_rxf_cfg_reset(struct bna_rxf *rxf)
 {
diff --git a/drivers/net/ethernet/brocade/bna/bna_types.h b/drivers/net/ethernet/brocade/bna/bna_types.h
index 095bd63..e56f650 100644
--- a/drivers/net/ethernet/brocade/bna/bna_types.h
+++ b/drivers/net/ethernet/brocade/bna/bna_types.h
@@ -191,8 +191,6 @@ enum bna_rxf_event {
 	RXF_E_STOP			= 2,
 	RXF_E_FAIL			= 3,
 	RXF_E_CONFIG			= 4,
-	RXF_E_PAUSE			= 5,
-	RXF_E_RESUME			= 6,
 	RXF_E_FW_RESP			= 7,
 };
 
-- 
2.3.6
