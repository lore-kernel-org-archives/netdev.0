From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next v2 12/19] bna: remove TX_E_PRIO_CHANGE event and BNA_TX_F_PRIO_CHANGED flag
Date: Thu, 11 Jun 2015 15:52:24 +0200
Message-ID: <1434030751-28835-13-git-send-email-ivecera@redhat.com>
References: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58164 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754670AbbFKNwV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 09:52:21 -0400
In-Reply-To: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TX_E_PRIO_CHANGE event is never sent for bna_tx so it doesn't need to be
handled. After this change bna_tx->flags cannot contain
BNA_TX_F_PRIO_CHANGED flag and it can be also eliminated.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c | 22 ++++------------------
 drivers/net/ethernet/brocade/bna/bna_types.h |  1 -
 2 files changed, 4 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 896aa82..54ad169 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -2901,7 +2901,6 @@ enum bna_tx_event {
 	TX_E_FAIL			= 3,
 	TX_E_STARTED			= 4,
 	TX_E_STOPPED			= 5,
-	TX_E_PRIO_CHANGE		= 6,
 	TX_E_CLEANUP_DONE		= 7,
 	TX_E_BW_UPDATE			= 8,
 };
@@ -2942,9 +2941,6 @@ bna_tx_sm_stopped(struct bna_tx *tx, enum bna_tx_event event)
 		/* No-op */
 		break;
 
-	case TX_E_PRIO_CHANGE:
-		break;
-
 	case TX_E_BW_UPDATE:
 		/* No-op */
 		break;
@@ -2965,28 +2961,23 @@ bna_tx_sm_start_wait(struct bna_tx *tx, enum bna_tx_event event)
 {
 	switch (event) {
 	case TX_E_STOP:
-		tx->flags &= ~(BNA_TX_F_PRIO_CHANGED | BNA_TX_F_BW_UPDATED);
+		tx->flags &= ~BNA_TX_F_BW_UPDATED;
 		bfa_fsm_set_state(tx, bna_tx_sm_stop_wait);
 		break;
 
 	case TX_E_FAIL:
-		tx->flags &= ~(BNA_TX_F_PRIO_CHANGED | BNA_TX_F_BW_UPDATED);
+		tx->flags &= ~BNA_TX_F_BW_UPDATED;
 		bfa_fsm_set_state(tx, bna_tx_sm_stopped);
 		break;
 
 	case TX_E_STARTED:
-		if (tx->flags & (BNA_TX_F_PRIO_CHANGED | BNA_TX_F_BW_UPDATED)) {
-			tx->flags &= ~(BNA_TX_F_PRIO_CHANGED |
-				BNA_TX_F_BW_UPDATED);
+		if (tx->flags & BNA_TX_F_BW_UPDATED) {
+			tx->flags &= ~BNA_TX_F_BW_UPDATED;
 			bfa_fsm_set_state(tx, bna_tx_sm_prio_stop_wait);
 		} else
 			bfa_fsm_set_state(tx, bna_tx_sm_started);
 		break;
 
-	case TX_E_PRIO_CHANGE:
-		tx->flags |=  BNA_TX_F_PRIO_CHANGED;
-		break;
-
 	case TX_E_BW_UPDATE:
 		tx->flags |= BNA_TX_F_BW_UPDATED;
 		break;
@@ -3028,7 +3019,6 @@ bna_tx_sm_started(struct bna_tx *tx, enum bna_tx_event event)
 		tx->tx_cleanup_cbfn(tx->bna->bnad, tx);
 		break;
 
-	case TX_E_PRIO_CHANGE:
 	case TX_E_BW_UPDATE:
 		bfa_fsm_set_state(tx, bna_tx_sm_prio_stop_wait);
 		break;
@@ -3061,7 +3051,6 @@ bna_tx_sm_stop_wait(struct bna_tx *tx, enum bna_tx_event event)
 		bna_tx_enet_stop(tx);
 		break;
 
-	case TX_E_PRIO_CHANGE:
 	case TX_E_BW_UPDATE:
 		/* No-op */
 		break;
@@ -3081,7 +3070,6 @@ bna_tx_sm_cleanup_wait(struct bna_tx *tx, enum bna_tx_event event)
 {
 	switch (event) {
 	case TX_E_FAIL:
-	case TX_E_PRIO_CHANGE:
 	case TX_E_BW_UPDATE:
 		/* No-op */
 		break;
@@ -3119,7 +3107,6 @@ bna_tx_sm_prio_stop_wait(struct bna_tx *tx, enum bna_tx_event event)
 		bfa_fsm_set_state(tx, bna_tx_sm_prio_cleanup_wait);
 		break;
 
-	case TX_E_PRIO_CHANGE:
 	case TX_E_BW_UPDATE:
 		/* No-op */
 		break;
@@ -3147,7 +3134,6 @@ bna_tx_sm_prio_cleanup_wait(struct bna_tx *tx, enum bna_tx_event event)
 		bfa_fsm_set_state(tx, bna_tx_sm_failed);
 		break;
 
-	case TX_E_PRIO_CHANGE:
 	case TX_E_BW_UPDATE:
 		/* No-op */
 		break;
diff --git a/drivers/net/ethernet/brocade/bna/bna_types.h b/drivers/net/ethernet/brocade/bna/bna_types.h
index 134abf7..e0e797f 100644
--- a/drivers/net/ethernet/brocade/bna/bna_types.h
+++ b/drivers/net/ethernet/brocade/bna/bna_types.h
@@ -135,7 +135,6 @@ enum bna_tx_type {
 enum bna_tx_flags {
 	BNA_TX_F_ENET_STARTED	= 1,
 	BNA_TX_F_ENABLED	= 2,
-	BNA_TX_F_PRIO_CHANGED	= 4,
 	BNA_TX_F_BW_UPDATED	= 8,
 };
 
-- 
2.3.6
