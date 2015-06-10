From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 16/19] bna: get rid of private macros for manipulation with lists
Date: Wed, 10 Jun 2015 18:43:22 +0200
Message-ID: <1433954605-22813-17-git-send-email-ivecera@redhat.com>
References: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40387 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966183AbbFJQnQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 12:43:16 -0400
In-Reply-To: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove macros for manipulation with struct list_head and replace them
with standard ones.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bfa_cee.c   |   1 -
 drivers/net/ethernet/brocade/bna/bfa_ioc.c   |  10 +-
 drivers/net/ethernet/brocade/bna/bfa_msgq.c  |  10 +-
 drivers/net/ethernet/brocade/bna/bna.h       |   1 -
 drivers/net/ethernet/brocade/bna/bna_enet.c  |  50 ++---
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c | 310 +++++++++------------------
 drivers/net/ethernet/brocade/bna/cna.h       |  56 -----
 7 files changed, 130 insertions(+), 308 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_cee.c b/drivers/net/ethernet/brocade/bna/bfa_cee.c
index cf9f395..95bc8b6 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_cee.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_cee.c
@@ -282,7 +282,6 @@ bfa_nw_cee_attach(struct bfa_cee *cee, struct bfa_ioc *ioc,
 	cee->ioc = ioc;
 
 	bfa_nw_ioc_mbox_regisr(cee->ioc, BFI_MC_CEE, bfa_cee_isr, cee);
-	bfa_q_qe_init(&cee->ioc_notify);
 	bfa_ioc_notify_init(&cee->ioc_notify, bfa_cee_notify, cee);
 	bfa_nw_ioc_notify_register(cee->ioc, &cee->ioc_notify);
 }
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index 52fc439..dabbb30 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -2163,7 +2163,8 @@ bfa_ioc_mbox_poll(struct bfa_ioc *ioc)
 	/**
 	 * Enqueue command to firmware.
 	 */
-	bfa_q_deq(&mod->cmd_q, &cmd);
+	cmd = list_first_entry(&mod->cmd_q, struct bfa_mbox_cmd, qe);
+	list_del(&cmd->qe);
 	bfa_ioc_mbox_send(ioc, cmd->msg, sizeof(cmd->msg));
 
 	/**
@@ -2184,8 +2185,10 @@ bfa_ioc_mbox_flush(struct bfa_ioc *ioc)
 	struct bfa_ioc_mbox_mod *mod = &ioc->mbox_mod;
 	struct bfa_mbox_cmd *cmd;
 
-	while (!list_empty(&mod->cmd_q))
-		bfa_q_deq(&mod->cmd_q, &cmd);
+	while (!list_empty(&mod->cmd_q)) {
+		cmd = list_first_entry(&mod->cmd_q, struct bfa_mbox_cmd, qe);
+		list_del(&cmd->qe);
+	}
 }
 
 /**
@@ -3231,7 +3234,6 @@ bfa_nw_flash_attach(struct bfa_flash *flash, struct bfa_ioc *ioc, void *dev)
 	flash->op_busy = 0;
 
 	bfa_nw_ioc_mbox_regisr(flash->ioc, BFI_MC_FLASH, bfa_flash_intr, flash);
-	bfa_q_qe_init(&flash->ioc_notify);
 	bfa_ioc_notify_init(&flash->ioc_notify, bfa_flash_notify, flash);
 	list_add_tail(&flash->ioc_notify.qe, &flash->ioc->notify_q);
 }
diff --git a/drivers/net/ethernet/brocade/bna/bfa_msgq.c b/drivers/net/ethernet/brocade/bna/bfa_msgq.c
index c07d5b9..9c5bb24 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_msgq.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_msgq.c
@@ -66,8 +66,9 @@ cmdq_sm_stopped_entry(struct bfa_msgq_cmdq *cmdq)
 	cmdq->offset = 0;
 	cmdq->bytes_to_copy = 0;
 	while (!list_empty(&cmdq->pending_q)) {
-		bfa_q_deq(&cmdq->pending_q, &cmdq_ent);
-		bfa_q_qe_init(&cmdq_ent->qe);
+		cmdq_ent = list_first_entry(&cmdq->pending_q,
+					    struct bfa_msgq_cmd_entry, qe);
+		list_del(&cmdq_ent->qe);
 		call_cmdq_ent_cbfn(cmdq_ent, BFA_STATUS_FAILED);
 	}
 }
@@ -242,8 +243,8 @@ bfa_msgq_cmdq_ci_update(struct bfa_msgq_cmdq *cmdq, struct bfi_mbmsg *mb)
 
 	/* Walk through pending list to see if the command can be posted */
 	while (!list_empty(&cmdq->pending_q)) {
-		cmd =
-		(struct bfa_msgq_cmd_entry *)bfa_q_first(&cmdq->pending_q);
+		cmd = list_first_entry(&cmdq->pending_q,
+				       struct bfa_msgq_cmd_entry, qe);
 		if (ntohs(cmd->msg_hdr->num_entries) <=
 			BFA_MSGQ_FREE_CNT(cmdq)) {
 			list_del(&cmd->qe);
@@ -615,7 +616,6 @@ bfa_msgq_attach(struct bfa_msgq *msgq, struct bfa_ioc *ioc)
 	bfa_msgq_rspq_attach(&msgq->rspq, msgq);
 
 	bfa_nw_ioc_mbox_regisr(msgq->ioc, BFI_MC_MSGQ, bfa_msgq_isr, msgq);
-	bfa_q_qe_init(&msgq->ioc_notify);
 	bfa_ioc_notify_init(&msgq->ioc_notify, bfa_msgq_notify, msgq);
 	bfa_nw_ioc_notify_register(msgq->ioc, &msgq->ioc_notify);
 }
diff --git a/drivers/net/ethernet/brocade/bna/bna.h b/drivers/net/ethernet/brocade/bna/bna.h
index 4f16ee2..66e6e09 100644
--- a/drivers/net/ethernet/brocade/bna/bna.h
+++ b/drivers/net/ethernet/brocade/bna/bna.h
@@ -283,7 +283,6 @@ void bna_hw_stats_get(struct bna *bna);
 
 /* APIs for RxF */
 struct bna_mac *bna_cam_mod_mac_get(struct list_head *head);
-void bna_cam_mod_mac_put(struct list_head *tail, struct bna_mac *mac);
 struct bna_mcam_handle *bna_mcam_mod_handle_get(struct bna_mcam_mod *mod);
 void bna_mcam_mod_handle_put(struct bna_mcam_mod *mcam_mod,
 			  struct bna_mcam_handle *handle);
diff --git a/drivers/net/ethernet/brocade/bna/bna_enet.c b/drivers/net/ethernet/brocade/bna/bna_enet.c
index dc9f73b..bd8f2c2 100644
--- a/drivers/net/ethernet/brocade/bna/bna_enet.c
+++ b/drivers/net/ethernet/brocade/bna/bna_enet.c
@@ -1792,17 +1792,13 @@ bna_ucam_mod_init(struct bna_ucam_mod *ucam_mod, struct bna *bna,
 	res_info[BNA_MOD_RES_MEM_T_UCMAC_ARRAY].res_u.mem_info.mdl[0].kva;
 
 	INIT_LIST_HEAD(&ucam_mod->free_q);
-	for (i = 0; i < bna->ioceth.attr.num_ucmac; i++) {
-		bfa_q_qe_init(&ucam_mod->ucmac[i].qe);
+	for (i = 0; i < bna->ioceth.attr.num_ucmac; i++)
 		list_add_tail(&ucam_mod->ucmac[i].qe, &ucam_mod->free_q);
-	}
 
 	/* A separate queue to allow synchronous setting of a list of MACs */
 	INIT_LIST_HEAD(&ucam_mod->del_q);
-	for (i = i; i < (bna->ioceth.attr.num_ucmac * 2); i++) {
-		bfa_q_qe_init(&ucam_mod->ucmac[i].qe);
+	for (i = i; i < (bna->ioceth.attr.num_ucmac * 2); i++)
 		list_add_tail(&ucam_mod->ucmac[i].qe, &ucam_mod->del_q);
-	}
 
 	ucam_mod->bna = bna;
 }
@@ -1834,27 +1830,21 @@ bna_mcam_mod_init(struct bna_mcam_mod *mcam_mod, struct bna *bna,
 	res_info[BNA_MOD_RES_MEM_T_MCMAC_ARRAY].res_u.mem_info.mdl[0].kva;
 
 	INIT_LIST_HEAD(&mcam_mod->free_q);
-	for (i = 0; i < bna->ioceth.attr.num_mcmac; i++) {
-		bfa_q_qe_init(&mcam_mod->mcmac[i].qe);
+	for (i = 0; i < bna->ioceth.attr.num_mcmac; i++)
 		list_add_tail(&mcam_mod->mcmac[i].qe, &mcam_mod->free_q);
-	}
 
 	mcam_mod->mchandle = (struct bna_mcam_handle *)
 	res_info[BNA_MOD_RES_MEM_T_MCHANDLE_ARRAY].res_u.mem_info.mdl[0].kva;
 
 	INIT_LIST_HEAD(&mcam_mod->free_handle_q);
-	for (i = 0; i < bna->ioceth.attr.num_mcmac; i++) {
-		bfa_q_qe_init(&mcam_mod->mchandle[i].qe);
+	for (i = 0; i < bna->ioceth.attr.num_mcmac; i++)
 		list_add_tail(&mcam_mod->mchandle[i].qe,
-				&mcam_mod->free_handle_q);
-	}
+			      &mcam_mod->free_handle_q);
 
 	/* A separate queue to allow synchronous setting of a list of MACs */
 	INIT_LIST_HEAD(&mcam_mod->del_q);
-	for (i = i; i < (bna->ioceth.attr.num_mcmac * 2); i++) {
-		bfa_q_qe_init(&mcam_mod->mcmac[i].qe);
+	for (i = i; i < (bna->ioceth.attr.num_mcmac * 2); i++)
 		list_add_tail(&mcam_mod->mcmac[i].qe, &mcam_mod->del_q);
-	}
 
 	mcam_mod->bna = bna;
 }
@@ -2090,32 +2080,26 @@ bna_num_rxp_set(struct bna *bna, int num_rxp)
 struct bna_mac *
 bna_cam_mod_mac_get(struct list_head *head)
 {
-	struct list_head *qe;
+	struct bna_mac *mac;
 
-	if (list_empty(head))
-		return NULL;
+	mac = list_first_entry_or_null(head, struct bna_mac, qe);
+	if (mac)
+		list_del(&mac->qe);
 
-	bfa_q_deq(head, &qe);
-	return (struct bna_mac *)qe;
-}
-
-void
-bna_cam_mod_mac_put(struct list_head *tail, struct bna_mac *mac)
-{
-	list_add_tail(&mac->qe, tail);
+	return mac;
 }
 
 struct bna_mcam_handle *
 bna_mcam_mod_handle_get(struct bna_mcam_mod *mcam_mod)
 {
-	struct list_head *qe;
-
-	if (list_empty(&mcam_mod->free_handle_q))
-		return NULL;
+	struct bna_mcam_handle *handle;
 
-	bfa_q_deq(&mcam_mod->free_handle_q, &qe);
+	handle = list_first_entry_or_null(&mcam_mod->free_handle_q,
+					  struct bna_mcam_handle, qe);
+	if (handle)
+		list_del(&handle->qe);
 
-	return (struct bna_mcam_handle *)qe;
+	return handle;
 }
 
 void
diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 54ad169..1245bb1 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -424,7 +424,6 @@ bna_rxf_mcast_del(struct bna_rxf *rxf, struct bna_mac *mac,
 			ret = 1;
 		}
 		list_del(&mchandle->qe);
-		bfa_q_qe_init(&mchandle->qe);
 		bna_mcam_mod_handle_put(&rxf->rx->bna->mcam_mod, mchandle);
 	}
 	mac->handle = NULL;
@@ -436,26 +435,23 @@ static int
 bna_rxf_mcast_cfg_apply(struct bna_rxf *rxf)
 {
 	struct bna_mac *mac = NULL;
-	struct list_head *qe;
 	int ret;
 
 	/* First delete multicast entries to maintain the count */
 	while (!list_empty(&rxf->mcast_pending_del_q)) {
-		bfa_q_deq(&rxf->mcast_pending_del_q, &qe);
-		bfa_q_qe_init(qe);
-		mac = (struct bna_mac *)qe;
+		mac = list_first_entry(&rxf->mcast_pending_del_q,
+				       struct bna_mac, qe);
 		ret = bna_rxf_mcast_del(rxf, mac, BNA_HARD_CLEANUP);
-		bna_cam_mod_mac_put(bna_mcam_mod_del_q(rxf->rx->bna), mac);
+		list_move_tail(&mac->qe, bna_mcam_mod_del_q(rxf->rx->bna));
 		if (ret)
 			return ret;
 	}
 
 	/* Add multicast entries */
 	if (!list_empty(&rxf->mcast_pending_add_q)) {
-		bfa_q_deq(&rxf->mcast_pending_add_q, &qe);
-		bfa_q_qe_init(qe);
-		mac = (struct bna_mac *)qe;
-		list_add_tail(&mac->qe, &rxf->mcast_active_q);
+		mac = list_first_entry(&rxf->mcast_pending_add_q,
+				       struct bna_mac, qe);
+		list_move_tail(&mac->qe, &rxf->mcast_active_q);
 		bna_bfi_mcast_add_req(rxf, mac);
 		return 1;
 	}
@@ -486,27 +482,24 @@ bna_rxf_vlan_cfg_apply(struct bna_rxf *rxf)
 static int
 bna_rxf_mcast_cfg_reset(struct bna_rxf *rxf, enum bna_cleanup_type cleanup)
 {
-	struct list_head *qe;
 	struct bna_mac *mac;
 	int ret;
 
 	/* Throw away delete pending mcast entries */
 	while (!list_empty(&rxf->mcast_pending_del_q)) {
-		bfa_q_deq(&rxf->mcast_pending_del_q, &qe);
-		bfa_q_qe_init(qe);
-		mac = (struct bna_mac *)qe;
+		mac = list_first_entry(&rxf->mcast_pending_del_q,
+				       struct bna_mac, qe);
 		ret = bna_rxf_mcast_del(rxf, mac, cleanup);
-		bna_cam_mod_mac_put(bna_mcam_mod_del_q(rxf->rx->bna), mac);
+		list_move_tail(&mac->qe, bna_mcam_mod_del_q(rxf->rx->bna));
 		if (ret)
 			return ret;
 	}
 
 	/* Move active mcast entries to pending_add_q */
 	while (!list_empty(&rxf->mcast_active_q)) {
-		bfa_q_deq(&rxf->mcast_active_q, &qe);
-		bfa_q_qe_init(qe);
-		list_add_tail(qe, &rxf->mcast_pending_add_q);
-		mac = (struct bna_mac *)qe;
+		mac = list_first_entry(&rxf->mcast_active_q,
+				       struct bna_mac, qe);
+		list_move_tail(&mac->qe, &rxf->mcast_pending_add_q);
 		if (bna_rxf_mcast_del(rxf, mac, cleanup))
 			return 1;
 	}
@@ -682,22 +675,21 @@ bna_rxf_uninit(struct bna_rxf *rxf)
 	rxf->ucast_active_set = 0;
 
 	while (!list_empty(&rxf->ucast_pending_add_q)) {
-		bfa_q_deq(&rxf->ucast_pending_add_q, &mac);
-		bfa_q_qe_init(&mac->qe);
-		bna_cam_mod_mac_put(bna_ucam_mod_free_q(rxf->rx->bna), mac);
+		mac = list_first_entry(&rxf->ucast_pending_add_q,
+				       struct bna_mac, qe);
+		list_move_tail(&mac->qe, bna_ucam_mod_free_q(rxf->rx->bna));
 	}
 
 	if (rxf->ucast_pending_mac) {
-		bfa_q_qe_init(&rxf->ucast_pending_mac->qe);
-		bna_cam_mod_mac_put(bna_ucam_mod_free_q(rxf->rx->bna),
-				    rxf->ucast_pending_mac);
+		list_add_tail(&rxf->ucast_pending_mac->qe,
+			      bna_ucam_mod_free_q(rxf->rx->bna));
 		rxf->ucast_pending_mac = NULL;
 	}
 
 	while (!list_empty(&rxf->mcast_pending_add_q)) {
-		bfa_q_deq(&rxf->mcast_pending_add_q, &mac);
-		bfa_q_qe_init(&mac->qe);
-		bna_cam_mod_mac_put(bna_mcam_mod_free_q(rxf->rx->bna), mac);
+		mac = list_first_entry(&rxf->mcast_pending_add_q,
+				       struct bna_mac, qe);
+		list_move_tail(&mac->qe, bna_mcam_mod_free_q(rxf->rx->bna));
 	}
 
 	rxf->rxmode_pending = 0;
@@ -757,7 +749,6 @@ bna_rx_ucast_set(struct bna_rx *rx, u8 *ucmac)
 			bna_cam_mod_mac_get(bna_ucam_mod_free_q(rxf->rx->bna));
 		if (rxf->ucast_pending_mac == NULL)
 			return BNA_CB_UCAST_CAM_FULL;
-		bfa_q_qe_init(&rxf->ucast_pending_mac->qe);
 	}
 
 	ether_addr_copy(rxf->ucast_pending_mac->addr, ucmac);
@@ -788,7 +779,6 @@ bna_rx_mcast_add(struct bna_rx *rx, u8 *addr,
 	mac = bna_cam_mod_mac_get(bna_mcam_mod_free_q(rxf->rx->bna));
 	if (mac == NULL)
 		return BNA_CB_MCAST_LIST_FULL;
-	bfa_q_qe_init(&mac->qe);
 	ether_addr_copy(mac->addr, addr);
 	list_add_tail(&mac->qe, &rxf->mcast_pending_add_q);
 
@@ -806,29 +796,26 @@ bna_rx_ucast_listset(struct bna_rx *rx, int count, u8 *uclist)
 	struct bna_ucam_mod *ucam_mod = &rx->bna->ucam_mod;
 	struct bna_rxf *rxf = &rx->rxf;
 	struct list_head list_head;
-	struct list_head *qe;
 	u8 *mcaddr;
 	struct bna_mac *mac, *del_mac;
 	int i;
 
 	/* Purge the pending_add_q */
 	while (!list_empty(&rxf->ucast_pending_add_q)) {
-		bfa_q_deq(&rxf->ucast_pending_add_q, &qe);
-		bfa_q_qe_init(qe);
-		mac = (struct bna_mac *)qe;
-		bna_cam_mod_mac_put(&ucam_mod->free_q, mac);
+		mac = list_first_entry(&rxf->ucast_pending_add_q,
+				       struct bna_mac, qe);
+		list_move_tail(&mac->qe, &ucam_mod->free_q);
 	}
 
 	/* Schedule active_q entries for deletion */
 	while (!list_empty(&rxf->ucast_active_q)) {
-		bfa_q_deq(&rxf->ucast_active_q, &qe);
-		mac = (struct bna_mac *)qe;
-		bfa_q_qe_init(&mac->qe);
-
+		mac = list_first_entry(&rxf->ucast_active_q,
+				       struct bna_mac, qe);
 		del_mac = bna_cam_mod_mac_get(&ucam_mod->del_q);
-		memcpy(del_mac, mac, sizeof(*del_mac));
+		ether_addr_copy(del_mac->addr, mac->addr);
+		del_mac->handle = mac->handle;
 		list_add_tail(&del_mac->qe, &rxf->ucast_pending_del_q);
-		bna_cam_mod_mac_put(&ucam_mod->free_q, mac);
+		list_move_tail(&mac->qe, &ucam_mod->free_q);
 	}
 
 	/* Allocate nodes */
@@ -837,7 +824,6 @@ bna_rx_ucast_listset(struct bna_rx *rx, int count, u8 *uclist)
 		mac = bna_cam_mod_mac_get(&ucam_mod->free_q);
 		if (mac == NULL)
 			goto err_return;
-		bfa_q_qe_init(&mac->qe);
 		ether_addr_copy(mac->addr, mcaddr);
 		list_add_tail(&mac->qe, &list_head);
 		mcaddr += ETH_ALEN;
@@ -845,10 +831,8 @@ bna_rx_ucast_listset(struct bna_rx *rx, int count, u8 *uclist)
 
 	/* Add the new entries */
 	while (!list_empty(&list_head)) {
-		bfa_q_deq(&list_head, &qe);
-		mac = (struct bna_mac *)qe;
-		bfa_q_qe_init(&mac->qe);
-		list_add_tail(&mac->qe, &rxf->ucast_pending_add_q);
+		mac = list_first_entry(&list_head, struct bna_mac, qe);
+		list_move_tail(&mac->qe, &rxf->ucast_pending_add_q);
 	}
 
 	bfa_fsm_send_event(rxf, RXF_E_CONFIG);
@@ -857,10 +841,8 @@ bna_rx_ucast_listset(struct bna_rx *rx, int count, u8 *uclist)
 
 err_return:
 	while (!list_empty(&list_head)) {
-		bfa_q_deq(&list_head, &qe);
-		mac = (struct bna_mac *)qe;
-		bfa_q_qe_init(&mac->qe);
-		bna_cam_mod_mac_put(&ucam_mod->free_q, mac);
+		mac = list_first_entry(&list_head, struct bna_mac, qe);
+		list_move_tail(&mac->qe, &ucam_mod->free_q);
 	}
 
 	return BNA_CB_UCAST_CAM_FULL;
@@ -872,31 +854,27 @@ bna_rx_mcast_listset(struct bna_rx *rx, int count, u8 *mclist)
 	struct bna_mcam_mod *mcam_mod = &rx->bna->mcam_mod;
 	struct bna_rxf *rxf = &rx->rxf;
 	struct list_head list_head;
-	struct list_head *qe;
 	u8 *mcaddr;
 	struct bna_mac *mac, *del_mac;
 	int i;
 
 	/* Purge the pending_add_q */
 	while (!list_empty(&rxf->mcast_pending_add_q)) {
-		bfa_q_deq(&rxf->mcast_pending_add_q, &qe);
-		bfa_q_qe_init(qe);
-		mac = (struct bna_mac *)qe;
-		bna_cam_mod_mac_put(&mcam_mod->free_q, mac);
+		mac = list_first_entry(&rxf->mcast_pending_add_q,
+				       struct bna_mac, qe);
+		list_move_tail(&mac->qe, &mcam_mod->free_q);
 	}
 
 	/* Schedule active_q entries for deletion */
 	while (!list_empty(&rxf->mcast_active_q)) {
-		bfa_q_deq(&rxf->mcast_active_q, &qe);
-		mac = (struct bna_mac *)qe;
-		bfa_q_qe_init(&mac->qe);
-
+		mac = list_first_entry(&rxf->mcast_active_q,
+				       struct bna_mac, qe);
 		del_mac = bna_cam_mod_mac_get(&mcam_mod->del_q);
-
-		memcpy(del_mac, mac, sizeof(*del_mac));
+		ether_addr_copy(del_mac->addr, mac->addr);
+		del_mac->handle = mac->handle;
 		list_add_tail(&del_mac->qe, &rxf->mcast_pending_del_q);
 		mac->handle = NULL;
-		bna_cam_mod_mac_put(&mcam_mod->free_q, mac);
+		list_move_tail(&mac->qe, &mcam_mod->free_q);
 	}
 
 	/* Allocate nodes */
@@ -905,7 +883,6 @@ bna_rx_mcast_listset(struct bna_rx *rx, int count, u8 *mclist)
 		mac = bna_cam_mod_mac_get(&mcam_mod->free_q);
 		if (mac == NULL)
 			goto err_return;
-		bfa_q_qe_init(&mac->qe);
 		ether_addr_copy(mac->addr, mcaddr);
 		list_add_tail(&mac->qe, &list_head);
 
@@ -914,10 +891,8 @@ bna_rx_mcast_listset(struct bna_rx *rx, int count, u8 *mclist)
 
 	/* Add the new entries */
 	while (!list_empty(&list_head)) {
-		bfa_q_deq(&list_head, &qe);
-		mac = (struct bna_mac *)qe;
-		bfa_q_qe_init(&mac->qe);
-		list_add_tail(&mac->qe, &rxf->mcast_pending_add_q);
+		mac = list_first_entry(&list_head, struct bna_mac, qe);
+		list_move_tail(&mac->qe, &rxf->mcast_pending_add_q);
 	}
 
 	bfa_fsm_send_event(rxf, RXF_E_CONFIG);
@@ -926,10 +901,8 @@ bna_rx_mcast_listset(struct bna_rx *rx, int count, u8 *mclist)
 
 err_return:
 	while (!list_empty(&list_head)) {
-		bfa_q_deq(&list_head, &qe);
-		mac = (struct bna_mac *)qe;
-		bfa_q_qe_init(&mac->qe);
-		bna_cam_mod_mac_put(&mcam_mod->free_q, mac);
+		mac = list_first_entry(&list_head, struct bna_mac, qe);
+		list_move_tail(&mac->qe, &mcam_mod->free_q);
 	}
 
 	return BNA_CB_MCAST_LIST_FULL;
@@ -939,30 +912,26 @@ void
 bna_rx_mcast_delall(struct bna_rx *rx)
 {
 	struct bna_rxf *rxf = &rx->rxf;
-	struct list_head *qe;
 	struct bna_mac *mac, *del_mac;
 	int need_hw_config = 0;
 
 	/* Purge all entries from pending_add_q */
 	while (!list_empty(&rxf->mcast_pending_add_q)) {
-		bfa_q_deq(&rxf->mcast_pending_add_q, &qe);
-		mac = (struct bna_mac *)qe;
-		bfa_q_qe_init(&mac->qe);
-		bna_cam_mod_mac_put(bna_mcam_mod_free_q(rxf->rx->bna), mac);
+		mac = list_first_entry(&rxf->mcast_pending_add_q,
+				       struct bna_mac, qe);
+		list_move_tail(&mac->qe, bna_mcam_mod_free_q(rxf->rx->bna));
 	}
 
 	/* Schedule all entries in active_q for deletion */
 	while (!list_empty(&rxf->mcast_active_q)) {
-		bfa_q_deq(&rxf->mcast_active_q, &qe);
-		mac = (struct bna_mac *)qe;
-		bfa_q_qe_init(&mac->qe);
-
+		mac = list_first_entry(&rxf->mcast_active_q,
+				       struct bna_mac, qe);
+		list_del(&mac->qe);
 		del_mac = bna_cam_mod_mac_get(bna_mcam_mod_del_q(rxf->rx->bna));
-
 		memcpy(del_mac, mac, sizeof(*del_mac));
 		list_add_tail(&del_mac->qe, &rxf->mcast_pending_del_q);
 		mac->handle = NULL;
-		bna_cam_mod_mac_put(bna_mcam_mod_free_q(rxf->rx->bna), mac);
+		list_add_tail(&mac->qe, bna_mcam_mod_free_q(rxf->rx->bna));
 		need_hw_config = 1;
 	}
 
@@ -1004,15 +973,13 @@ static int
 bna_rxf_ucast_cfg_apply(struct bna_rxf *rxf)
 {
 	struct bna_mac *mac = NULL;
-	struct list_head *qe;
 
 	/* Delete MAC addresses previousely added */
 	if (!list_empty(&rxf->ucast_pending_del_q)) {
-		bfa_q_deq(&rxf->ucast_pending_del_q, &qe);
-		bfa_q_qe_init(qe);
-		mac = (struct bna_mac *)qe;
+		mac = list_first_entry(&rxf->ucast_pending_del_q,
+				       struct bna_mac, qe);
 		bna_bfi_ucast_req(rxf, mac, BFI_ENET_H2I_MAC_UCAST_DEL_REQ);
-		bna_cam_mod_mac_put(bna_ucam_mod_del_q(rxf->rx->bna), mac);
+		list_move_tail(&mac->qe, bna_ucam_mod_del_q(rxf->rx->bna));
 		return 1;
 	}
 
@@ -1029,9 +996,8 @@ bna_rxf_ucast_cfg_apply(struct bna_rxf *rxf)
 
 	/* Add additional MAC entries */
 	if (!list_empty(&rxf->ucast_pending_add_q)) {
-		bfa_q_deq(&rxf->ucast_pending_add_q, &qe);
-		bfa_q_qe_init(qe);
-		mac = (struct bna_mac *)qe;
+		mac = list_first_entry(&rxf->ucast_pending_add_q,
+				       struct bna_mac, qe);
 		list_add_tail(&mac->qe, &rxf->ucast_active_q);
 		bna_bfi_ucast_req(rxf, mac, BFI_ENET_H2I_MAC_UCAST_ADD_REQ);
 		return 1;
@@ -1043,33 +1009,30 @@ bna_rxf_ucast_cfg_apply(struct bna_rxf *rxf)
 static int
 bna_rxf_ucast_cfg_reset(struct bna_rxf *rxf, enum bna_cleanup_type cleanup)
 {
-	struct list_head *qe;
 	struct bna_mac *mac;
 
 	/* Throw away delete pending ucast entries */
 	while (!list_empty(&rxf->ucast_pending_del_q)) {
-		bfa_q_deq(&rxf->ucast_pending_del_q, &qe);
-		bfa_q_qe_init(qe);
-		mac = (struct bna_mac *)qe;
+		mac = list_first_entry(&rxf->ucast_pending_del_q,
+				       struct bna_mac, qe);
 		if (cleanup == BNA_SOFT_CLEANUP)
-			bna_cam_mod_mac_put(bna_ucam_mod_del_q(rxf->rx->bna),
-					    mac);
+			list_move_tail(&mac->qe,
+				       bna_ucam_mod_del_q(rxf->rx->bna));
 		else {
 			bna_bfi_ucast_req(rxf, mac,
-				BFI_ENET_H2I_MAC_UCAST_DEL_REQ);
-			bna_cam_mod_mac_put(bna_ucam_mod_del_q(rxf->rx->bna),
-					    mac);
+					  BFI_ENET_H2I_MAC_UCAST_DEL_REQ);
+			list_move_tail(&mac->qe,
+				       bna_ucam_mod_del_q(rxf->rx->bna));
 			return 1;
 		}
 	}
 
 	/* Move active ucast entries to pending_add_q */
 	while (!list_empty(&rxf->ucast_active_q)) {
-		bfa_q_deq(&rxf->ucast_active_q, &qe);
-		bfa_q_qe_init(qe);
-		list_add_tail(qe, &rxf->ucast_pending_add_q);
+		mac = list_first_entry(&rxf->ucast_active_q,
+				       struct bna_mac, qe);
+		list_move_tail(&mac->qe, &rxf->ucast_pending_add_q);
 		if (cleanup == BNA_HARD_CLEANUP) {
-			mac = (struct bna_mac *)qe;
 			bna_bfi_ucast_req(rxf, mac,
 				BFI_ENET_H2I_MAC_UCAST_DEL_REQ);
 			return 1;
@@ -1674,7 +1637,6 @@ bna_bfi_rx_enet_start(struct bna_rx *rx)
 	struct bfi_enet_rx_cfg_req *cfg_req = &rx->bfi_enet_cmd.cfg_req;
 	struct bna_rxp *rxp = NULL;
 	struct bna_rxq *q0 = NULL, *q1 = NULL;
-	struct list_head *rxp_qe;
 	int i;
 
 	bfi_msgq_mhdr_set(cfg_req->mh, BFI_MC_ENET,
@@ -1684,11 +1646,9 @@ bna_bfi_rx_enet_start(struct bna_rx *rx)
 
 	cfg_req->rx_cfg.frame_size = bna_enet_mtu_get(&rx->bna->enet);
 	cfg_req->num_queue_sets = rx->num_paths;
-	for (i = 0, rxp_qe = bfa_q_first(&rx->rxp_q);
-		i < rx->num_paths;
-		i++, rxp_qe = bfa_q_next(rxp_qe)) {
-		rxp = (struct bna_rxp *)rxp_qe;
-
+	for (i = 0; i < rx->num_paths; i++) {
+		rxp = rxp ? list_next_entry(rxp, qe)
+			: list_first_entry(&rx->rxp_q, struct bna_rxp, qe);
 		GET_RXQS(rxp, q0, q1);
 		switch (rxp->type) {
 		case BNA_RXP_SLR:
@@ -1827,12 +1787,10 @@ static struct bna_rxq *
 bna_rxq_get(struct bna_rx_mod *rx_mod)
 {
 	struct bna_rxq *rxq = NULL;
-	struct list_head	*qe = NULL;
 
-	bfa_q_deq(&rx_mod->rxq_free_q, &qe);
+	rxq = list_first_entry(&rx_mod->rxq_free_q, struct bna_rxq, qe);
+	list_del(&rxq->qe);
 	rx_mod->rxq_free_count--;
-	rxq = (struct bna_rxq *)qe;
-	bfa_q_qe_init(&rxq->qe);
 
 	return rxq;
 }
@@ -1840,7 +1798,6 @@ bna_rxq_get(struct bna_rx_mod *rx_mod)
 static void
 bna_rxq_put(struct bna_rx_mod *rx_mod, struct bna_rxq *rxq)
 {
-	bfa_q_qe_init(&rxq->qe);
 	list_add_tail(&rxq->qe, &rx_mod->rxq_free_q);
 	rx_mod->rxq_free_count++;
 }
@@ -1848,13 +1805,11 @@ bna_rxq_put(struct bna_rx_mod *rx_mod, struct bna_rxq *rxq)
 static struct bna_rxp *
 bna_rxp_get(struct bna_rx_mod *rx_mod)
 {
-	struct list_head	*qe = NULL;
 	struct bna_rxp *rxp = NULL;
 
-	bfa_q_deq(&rx_mod->rxp_free_q, &qe);
+	rxp = list_first_entry(&rx_mod->rxp_free_q, struct bna_rxp, qe);
+	list_del(&rxp->qe);
 	rx_mod->rxp_free_count--;
-	rxp = (struct bna_rxp *)qe;
-	bfa_q_qe_init(&rxp->qe);
 
 	return rxp;
 }
@@ -1862,7 +1817,6 @@ bna_rxp_get(struct bna_rx_mod *rx_mod)
 static void
 bna_rxp_put(struct bna_rx_mod *rx_mod, struct bna_rxp *rxp)
 {
-	bfa_q_qe_init(&rxp->qe);
 	list_add_tail(&rxp->qe, &rx_mod->rxp_free_q);
 	rx_mod->rxp_free_count++;
 }
@@ -1870,18 +1824,16 @@ bna_rxp_put(struct bna_rx_mod *rx_mod, struct bna_rxp *rxp)
 static struct bna_rx *
 bna_rx_get(struct bna_rx_mod *rx_mod, enum bna_rx_type type)
 {
-	struct list_head	*qe = NULL;
 	struct bna_rx *rx = NULL;
 
-	if (type == BNA_RX_T_REGULAR) {
-		bfa_q_deq(&rx_mod->rx_free_q, &qe);
-	} else
-		bfa_q_deq_tail(&rx_mod->rx_free_q, &qe);
+	BUG_ON(list_empty(&rx_mod->rx_free_q));
+	if (type == BNA_RX_T_REGULAR)
+		rx = list_first_entry(&rx_mod->rx_free_q, struct bna_rx, qe);
+	else
+		rx = list_last_entry(&rx_mod->rx_free_q, struct bna_rx, qe);
 
 	rx_mod->rx_free_count--;
-	rx = (struct bna_rx *)qe;
-	bfa_q_qe_init(&rx->qe);
-	list_add_tail(&rx->qe, &rx_mod->rx_active_q);
+	list_move_tail(&rx->qe, &rx_mod->rx_active_q);
 	rx->type = type;
 
 	return rx;
@@ -1890,32 +1842,13 @@ bna_rx_get(struct bna_rx_mod *rx_mod, enum bna_rx_type type)
 static void
 bna_rx_put(struct bna_rx_mod *rx_mod, struct bna_rx *rx)
 {
-	struct list_head *prev_qe = NULL;
 	struct list_head *qe;
 
-	bfa_q_qe_init(&rx->qe);
-
-	list_for_each(qe, &rx_mod->rx_free_q) {
+	list_for_each_prev(qe, &rx_mod->rx_free_q)
 		if (((struct bna_rx *)qe)->rid < rx->rid)
-			prev_qe = qe;
-		else
 			break;
-	}
-
-	if (prev_qe == NULL) {
-		/* This is the first entry */
-		bfa_q_enq_head(&rx_mod->rx_free_q, &rx->qe);
-	} else if (bfa_q_next(prev_qe) == &rx_mod->rx_free_q) {
-		/* This is the last entry */
-		list_add_tail(&rx->qe, &rx_mod->rx_free_q);
-	} else {
-		/* Somewhere in the middle */
-		bfa_q_next(&rx->qe) = bfa_q_next(prev_qe);
-		bfa_q_prev(&rx->qe) = prev_qe;
-		bfa_q_next(prev_qe) = &rx->qe;
-		bfa_q_prev(bfa_q_next(&rx->qe)) = &rx->qe;
-	}
 
+	list_add(&rx->qe, qe);
 	rx_mod->rx_free_count++;
 }
 
@@ -2152,7 +2085,6 @@ void bna_rx_mod_init(struct bna_rx_mod *rx_mod, struct bna *bna,
 	for (index = 0; index < bna->ioceth.attr.num_rxp; index++) {
 		rx_ptr = &rx_mod->rx[index];
 
-		bfa_q_qe_init(&rx_ptr->qe);
 		INIT_LIST_HEAD(&rx_ptr->rxp_q);
 		rx_ptr->bna = NULL;
 		rx_ptr->rid = index;
@@ -2166,7 +2098,6 @@ void bna_rx_mod_init(struct bna_rx_mod *rx_mod, struct bna *bna,
 	/* build RX-path queue */
 	for (index = 0; index < bna->ioceth.attr.num_rxp; index++) {
 		rxp_ptr = &rx_mod->rxp[index];
-		bfa_q_qe_init(&rxp_ptr->qe);
 		list_add_tail(&rxp_ptr->qe, &rx_mod->rxp_free_q);
 		rx_mod->rxp_free_count++;
 	}
@@ -2174,7 +2105,6 @@ void bna_rx_mod_init(struct bna_rx_mod *rx_mod, struct bna *bna,
 	/* build RXQ queue */
 	for (index = 0; index < (bna->ioceth.attr.num_rxp * 2); index++) {
 		rxq_ptr = &rx_mod->rxq[index];
-		bfa_q_qe_init(&rxq_ptr->qe);
 		list_add_tail(&rxq_ptr->qe, &rx_mod->rxq_free_q);
 		rx_mod->rxq_free_count++;
 	}
@@ -2207,7 +2137,6 @@ bna_bfi_rx_enet_start_rsp(struct bna_rx *rx, struct bfi_msgq_mhdr *msghdr)
 	struct bfi_enet_rx_cfg_rsp *cfg_rsp = &rx->bfi_enet_cmd.cfg_rsp;
 	struct bna_rxp *rxp = NULL;
 	struct bna_rxq *q0 = NULL, *q1 = NULL;
-	struct list_head *rxp_qe;
 	int i;
 
 	bfa_msgq_rsp_copy(&rx->bna->msgq, (u8 *)cfg_rsp,
@@ -2215,10 +2144,8 @@ bna_bfi_rx_enet_start_rsp(struct bna_rx *rx, struct bfi_msgq_mhdr *msghdr)
 
 	rx->hw_id = cfg_rsp->hw_id;
 
-	for (i = 0, rxp_qe = bfa_q_first(&rx->rxp_q);
-		i < rx->num_paths;
-		i++, rxp_qe = bfa_q_next(rxp_qe)) {
-		rxp = (struct bna_rxp *)rxp_qe;
+	for (i = 0, rxp = list_first_entry(&rx->rxp_q, struct bna_rxp, qe);
+	     i < rx->num_paths; i++, rxp = list_next_entry(rxp, qe)) {
 		GET_RXQS(rxp, q0, q1);
 
 		/* Setup doorbells */
@@ -2611,7 +2538,8 @@ bna_rx_destroy(struct bna_rx *rx)
 	bna_rxf_uninit(&rx->rxf);
 
 	while (!list_empty(&rx->rxp_q)) {
-		bfa_q_deq(&rx->rxp_q, &rxp);
+		rxp = list_first_entry(&rx->rxp_q, struct bna_rxp, qe);
+		list_del(&rxp->qe);
 		GET_RXQS(rxp, q0, q1);
 		if (rx->rcb_destroy_cbfn)
 			rx->rcb_destroy_cbfn(rx->bna->bnad, q0->rcb);
@@ -2638,13 +2566,11 @@ bna_rx_destroy(struct bna_rx *rx)
 		bna_rxp_put(rx_mod, rxp);
 	}
 
-	list_for_each(qe, &rx_mod->rx_active_q) {
+	list_for_each(qe, &rx_mod->rx_active_q)
 		if (qe == &rx->qe) {
 			list_del(&rx->qe);
-			bfa_q_qe_init(&rx->qe);
 			break;
 		}
-	}
 
 	rx_mod->rid_mask &= ~BIT(rx->rid);
 
@@ -3212,7 +3138,6 @@ bna_bfi_tx_enet_start(struct bna_tx *tx)
 {
 	struct bfi_enet_tx_cfg_req *cfg_req = &tx->bfi_enet_cmd.cfg_req;
 	struct bna_txq *txq = NULL;
-	struct list_head *qe;
 	int i;
 
 	bfi_msgq_mhdr_set(cfg_req->mh, BFI_MC_ENET,
@@ -3221,11 +3146,9 @@ bna_bfi_tx_enet_start(struct bna_tx *tx)
 		bfi_msgq_num_cmd_entries(sizeof(struct bfi_enet_tx_cfg_req)));
 
 	cfg_req->num_queues = tx->num_txq;
-	for (i = 0, qe = bfa_q_first(&tx->txq_q);
-		i < tx->num_txq;
-		i++, qe = bfa_q_next(qe)) {
-		txq = (struct bna_txq *)qe;
-
+	for (i = 0; i < tx->num_txq; i++) {
+		txq = txq ? list_next_entry(txq, qe)
+			: list_first_entry(&tx->txq_q, struct bna_txq, qe);
 		bfi_enet_datapath_q_init(&cfg_req->q_cfg[i].q.q, &txq->qpt);
 		cfg_req->q_cfg[i].q.priority = txq->priority;
 
@@ -3327,18 +3250,15 @@ bna_txq_qpt_setup(struct bna_txq *txq, int page_count, int page_size,
 static struct bna_tx *
 bna_tx_get(struct bna_tx_mod *tx_mod, enum bna_tx_type type)
 {
-	struct list_head	*qe = NULL;
 	struct bna_tx *tx = NULL;
 
 	if (list_empty(&tx_mod->tx_free_q))
 		return NULL;
-	if (type == BNA_TX_T_REGULAR) {
-		bfa_q_deq(&tx_mod->tx_free_q, &qe);
-	} else {
-		bfa_q_deq_tail(&tx_mod->tx_free_q, &qe);
-	}
-	tx = (struct bna_tx *)qe;
-	bfa_q_qe_init(&tx->qe);
+	if (type == BNA_TX_T_REGULAR)
+		tx = list_first_entry(&tx_mod->tx_free_q, struct bna_tx, qe);
+	else
+		tx = list_last_entry(&tx_mod->tx_free_q, struct bna_tx, qe);
+	list_del(&tx->qe);
 	tx->type = type;
 
 	return tx;
@@ -3349,21 +3269,18 @@ bna_tx_free(struct bna_tx *tx)
 {
 	struct bna_tx_mod *tx_mod = &tx->bna->tx_mod;
 	struct bna_txq *txq;
-	struct list_head *prev_qe;
 	struct list_head *qe;
 
 	while (!list_empty(&tx->txq_q)) {
-		bfa_q_deq(&tx->txq_q, &txq);
-		bfa_q_qe_init(&txq->qe);
+		txq = list_first_entry(&tx->txq_q, struct bna_txq, qe);
 		txq->tcb = NULL;
 		txq->tx = NULL;
-		list_add_tail(&txq->qe, &tx_mod->txq_free_q);
+		list_move_tail(&txq->qe, &tx_mod->txq_free_q);
 	}
 
 	list_for_each(qe, &tx_mod->tx_active_q) {
 		if (qe == &tx->qe) {
 			list_del(&tx->qe);
-			bfa_q_qe_init(&tx->qe);
 			break;
 		}
 	}
@@ -3371,28 +3288,11 @@ bna_tx_free(struct bna_tx *tx)
 	tx->bna = NULL;
 	tx->priv = NULL;
 
-	prev_qe = NULL;
-	list_for_each(qe, &tx_mod->tx_free_q) {
+	list_for_each_prev(qe, &tx_mod->tx_free_q)
 		if (((struct bna_tx *)qe)->rid < tx->rid)
-			prev_qe = qe;
-		else {
 			break;
-		}
-	}
 
-	if (prev_qe == NULL) {
-		/* This is the first entry */
-		bfa_q_enq_head(&tx_mod->tx_free_q, &tx->qe);
-	} else if (bfa_q_next(prev_qe) == &tx_mod->tx_free_q) {
-		/* This is the last entry */
-		list_add_tail(&tx->qe, &tx_mod->tx_free_q);
-	} else {
-		/* Somewhere in the middle */
-		bfa_q_next(&tx->qe) = bfa_q_next(prev_qe);
-		bfa_q_prev(&tx->qe) = prev_qe;
-		bfa_q_next(prev_qe) = &tx->qe;
-		bfa_q_prev(bfa_q_next(&tx->qe)) = &tx->qe;
-	}
+	list_add(&tx->qe, qe);
 }
 
 static void
@@ -3425,7 +3325,6 @@ bna_bfi_tx_enet_start_rsp(struct bna_tx *tx, struct bfi_msgq_mhdr *msghdr)
 {
 	struct bfi_enet_tx_cfg_rsp *cfg_rsp = &tx->bfi_enet_cmd.cfg_rsp;
 	struct bna_txq *txq = NULL;
-	struct list_head *qe;
 	int i;
 
 	bfa_msgq_rsp_copy(&tx->bna->msgq, (u8 *)cfg_rsp,
@@ -3433,10 +3332,8 @@ bna_bfi_tx_enet_start_rsp(struct bna_tx *tx, struct bfi_msgq_mhdr *msghdr)
 
 	tx->hw_id = cfg_rsp->hw_id;
 
-	for (i = 0, qe = bfa_q_first(&tx->txq_q);
-		i < tx->num_txq; i++, qe = bfa_q_next(qe)) {
-		txq = (struct bna_txq *)qe;
-
+	for (i = 0, txq = list_first_entry(&tx->txq_q, struct bna_txq, qe);
+	     i < tx->num_txq; i++, txq = list_next_entry(txq, qe)) {
 		/* Setup doorbells */
 		txq->tcb->i_dbell->doorbell_addr =
 			tx->bna->pcidev.pci_bar_kva
@@ -3559,9 +3456,8 @@ bna_tx_create(struct bna *bna, struct bnad *bnad,
 		if (list_empty(&tx_mod->txq_free_q))
 			goto err_return;
 
-		bfa_q_deq(&tx_mod->txq_free_q, &txq);
-		bfa_q_qe_init(&txq->qe);
-		list_add_tail(&txq->qe, &tx->txq_q);
+		txq = list_first_entry(&tx_mod->txq_free_q, struct bna_txq, qe);
+		list_move_tail(&txq->qe, &tx->txq_q);
 		txq->tx = tx;
 	}
 
@@ -3760,9 +3656,7 @@ bna_tx_mod_init(struct bna_tx_mod *tx_mod, struct bna *bna,
 
 	for (i = 0; i < bna->ioceth.attr.num_txq; i++) {
 		tx_mod->tx[i].rid = i;
-		bfa_q_qe_init(&tx_mod->tx[i].qe);
 		list_add_tail(&tx_mod->tx[i].qe, &tx_mod->tx_free_q);
-		bfa_q_qe_init(&tx_mod->txq[i].qe);
 		list_add_tail(&tx_mod->txq[i].qe, &tx_mod->txq_free_q);
 	}
 
diff --git a/drivers/net/ethernet/brocade/bna/cna.h b/drivers/net/ethernet/brocade/bna/cna.h
index b42aafd..75f8f1a 100644
--- a/drivers/net/ethernet/brocade/bna/cna.h
+++ b/drivers/net/ethernet/brocade/bna/cna.h
@@ -42,60 +42,4 @@ extern char bfa_version[];
 #define CNA_FW_FILE_CT2	"ct2fw-3.2.5.1.bin"
 #define FC_SYMNAME_MAX	256	/*!< max name server symbolic name size */
 
-#define bfa_q_first(_q) ((void *)(((struct list_head *) (_q))->next))
-#define bfa_q_next(_qe)	(((struct list_head *) (_qe))->next)
-#define bfa_q_prev(_qe) (((struct list_head *) (_qe))->prev)
-
-/*
- * bfa_q_qe_init - to initialize a queue element
- */
-#define bfa_q_qe_init(_qe) {						\
-	bfa_q_next(_qe) = (struct list_head *) NULL;			\
-	bfa_q_prev(_qe) = (struct list_head *) NULL;			\
-}
-
-/*
- * bfa_q_deq - dequeue an element from head of the queue
- */
-#define bfa_q_deq(_q, _qe) {						\
-	if (!list_empty(_q)) {						\
-		(*((struct list_head **) (_qe))) = bfa_q_next(_q);	\
-		bfa_q_prev(bfa_q_next(*((struct list_head **) _qe))) =	\
-						(struct list_head *) (_q); \
-		bfa_q_next(_q) = bfa_q_next(*((struct list_head **) _qe)); \
-		bfa_q_qe_init(*((struct list_head **) _qe));		\
-	} else {							\
-		*((struct list_head **)(_qe)) = NULL;			\
-	}								\
-}
-
-/*
- * bfa_q_deq_tail - dequeue an element from tail of the queue
- */
-#define bfa_q_deq_tail(_q, _qe) {					\
-	if (!list_empty(_q)) {						\
-		*((struct list_head **) (_qe)) = bfa_q_prev(_q);	\
-		bfa_q_next(bfa_q_prev(*((struct list_head **) _qe))) =  \
-						(struct list_head *) (_q); \
-		bfa_q_prev(_q) = bfa_q_prev(*(struct list_head **) _qe);\
-		bfa_q_qe_init(*((struct list_head **) _qe));		\
-	} else {							\
-		*((struct list_head **) (_qe)) = (struct list_head *) NULL; \
-	}								\
-}
-
-/*
- * bfa_add_tail_head - enqueue an element at the head of queue
- */
-#define bfa_q_enq_head(_q, _qe) {					\
-	if (!(bfa_q_next(_qe) == NULL) && (bfa_q_prev(_qe) == NULL))	\
-		pr_err("Assertion failure: %s:%d: %d",			\
-			__FILE__, __LINE__,				\
-		(bfa_q_next(_qe) == NULL) && (bfa_q_prev(_qe) == NULL));\
-	bfa_q_next(_qe) = bfa_q_next(_q);				\
-	bfa_q_prev(_qe) = (struct list_head *) (_q);			\
-	bfa_q_prev(bfa_q_next(_q)) = (struct list_head *) (_qe);	\
-	bfa_q_next(_q) = (struct list_head *) (_qe);			\
-}
-
 #endif /* __CNA_H__ */
-- 
2.3.6
