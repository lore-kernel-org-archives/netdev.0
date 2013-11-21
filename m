From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 03/13] bna: Fix Filter Add Del
Date: Wed, 20 Nov 2013 21:54:07 -0800
Message-ID: <1385013257-32745-4-git-send-email-rmody@brocade.com>
References: <1385013257-32745-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@Brocade.COM>,
	Rasesh Mody <rmody@Brocade.COM>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:30185 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752529Ab3KUGTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 01:19:47 -0500
In-Reply-To: <1385013257-32745-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change Details:
 - bna_rx_mcast_listset() API first looks at free_q only and not at other
   pending Qs rendering it non-deterministic of giving an upper limit.
   Modify bna_rx_mcast_listset() implementation to not use only half of the
   limit.
 - Allocate and initialize queue for deleting
 - Segregate the adding and deleting process by using separate queues.
 - The filter framework in bna does not let adding addresses to its max capacity
   due to asynchronous operations involved.
   Provide a synchronous option to set a given list.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bna.h       | 16 ++++---
 drivers/net/ethernet/brocade/bna/bna_enet.c  | 48 +++++++++-----------
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c | 65 ++++++++++++++++------------
 drivers/net/ethernet/brocade/bna/bna_types.h |  8 ++--
 4 files changed, 73 insertions(+), 64 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna.h b/drivers/net/ethernet/brocade/bna/bna.h
index f1eafc4..b11fa6c 100644
--- a/drivers/net/ethernet/brocade/bna/bna.h
+++ b/drivers/net/ethernet/brocade/bna/bna.h
@@ -354,6 +354,14 @@ do {									\
 	}								\
 } while (0)
 
+#define bna_mcam_mod_free_q(_bna) (&(_bna)->mcam_mod.free_q)
+
+#define bna_mcam_mod_del_q(_bna) (&(_bna)->mcam_mod.del_q)
+
+#define bna_ucam_mod_free_q(_bna) (&(_bna)->ucam_mod.free_q)
+
+#define bna_ucam_mod_del_q(_bna) (&(_bna)->ucam_mod.del_q)
+
 /*  Inline functions  */
 
 static inline struct bna_mac *bna_mac_find(struct list_head *q, u8 *addr)
@@ -391,12 +399,8 @@ int bna_num_rxp_set(struct bna *bna, int num_rxp);
 void bna_hw_stats_get(struct bna *bna);
 
 /* APIs for RxF */
-struct bna_mac *bna_ucam_mod_mac_get(struct bna_ucam_mod *ucam_mod);
-void bna_ucam_mod_mac_put(struct bna_ucam_mod *ucam_mod,
-			  struct bna_mac *mac);
-struct bna_mac *bna_mcam_mod_mac_get(struct bna_mcam_mod *mcam_mod);
-void bna_mcam_mod_mac_put(struct bna_mcam_mod *mcam_mod,
-			  struct bna_mac *mac);
+struct bna_mac *bna_cam_mod_mac_get(struct list_head *head);
+void bna_cam_mod_mac_put(struct list_head *tail, struct bna_mac *mac);
 struct bna_mcam_handle *bna_mcam_mod_handle_get(struct bna_mcam_mod *mod);
 void bna_mcam_mod_handle_put(struct bna_mcam_mod *mcam_mod,
 			  struct bna_mcam_handle *handle);
diff --git a/drivers/net/ethernet/brocade/bna/bna_enet.c b/drivers/net/ethernet/brocade/bna/bna_enet.c
index 3ca77fa..79afa11 100644
--- a/drivers/net/ethernet/brocade/bna/bna_enet.c
+++ b/drivers/net/ethernet/brocade/bna/bna_enet.c
@@ -1811,6 +1811,13 @@ bna_ucam_mod_init(struct bna_ucam_mod *ucam_mod, struct bna *bna,
 		list_add_tail(&ucam_mod->ucmac[i].qe, &ucam_mod->free_q);
 	}
 
+	/* A separate queue to allow synchronous setting of a list of MACs */
+	INIT_LIST_HEAD(&ucam_mod->del_q);
+	for (i = i; i < (bna->ioceth.attr.num_ucmac * 2); i++) {
+		bfa_q_qe_init(&ucam_mod->ucmac[i].qe);
+		list_add_tail(&ucam_mod->ucmac[i].qe, &ucam_mod->del_q);
+	}
+
 	ucam_mod->bna = bna;
 }
 
@@ -1851,6 +1858,13 @@ bna_mcam_mod_init(struct bna_mcam_mod *mcam_mod, struct bna *bna,
 				&mcam_mod->free_handle_q);
 	}
 
+	/* A separate queue to allow synchronous setting of a list of MACs */
+	INIT_LIST_HEAD(&mcam_mod->del_q);
+	for (i = i; i < (bna->ioceth.attr.num_mcmac * 2); i++) {
+		bfa_q_qe_init(&mcam_mod->mcmac[i].qe);
+		list_add_tail(&mcam_mod->mcmac[i].qe, &mcam_mod->del_q);
+	}
+
 	mcam_mod->bna = bna;
 }
 
@@ -1976,7 +1990,7 @@ bna_mod_res_req(struct bna *bna, struct bna_res_info *res_info)
 		BNA_MEM_T_KVA;
 	res_info[BNA_MOD_RES_MEM_T_UCMAC_ARRAY].res_u.mem_info.num = 1;
 	res_info[BNA_MOD_RES_MEM_T_UCMAC_ARRAY].res_u.mem_info.len =
-		attr->num_ucmac * sizeof(struct bna_mac);
+		(attr->num_ucmac * 2) * sizeof(struct bna_mac);
 
 	/* Virtual memory for Multicast MAC address - stored by mcam module */
 	res_info[BNA_MOD_RES_MEM_T_MCMAC_ARRAY].res_type = BNA_RES_T_MEM;
@@ -1984,7 +1998,7 @@ bna_mod_res_req(struct bna *bna, struct bna_res_info *res_info)
 		BNA_MEM_T_KVA;
 	res_info[BNA_MOD_RES_MEM_T_MCMAC_ARRAY].res_u.mem_info.num = 1;
 	res_info[BNA_MOD_RES_MEM_T_MCMAC_ARRAY].res_u.mem_info.len =
-		attr->num_mcmac * sizeof(struct bna_mac);
+		(attr->num_mcmac * 2) * sizeof(struct bna_mac);
 
 	/* Virtual memory for Multicast handle - stored by mcam module */
 	res_info[BNA_MOD_RES_MEM_T_MCHANDLE_ARRAY].res_type = BNA_RES_T_MEM;
@@ -2080,41 +2094,21 @@ bna_num_rxp_set(struct bna *bna, int num_rxp)
 }
 
 struct bna_mac *
-bna_ucam_mod_mac_get(struct bna_ucam_mod *ucam_mod)
+bna_cam_mod_mac_get(struct list_head *head)
 {
 	struct list_head *qe;
 
-	if (list_empty(&ucam_mod->free_q))
+	if (list_empty(head))
 		return NULL;
 
-	bfa_q_deq(&ucam_mod->free_q, &qe);
-
-	return (struct bna_mac *)qe;
-}
-
-void
-bna_ucam_mod_mac_put(struct bna_ucam_mod *ucam_mod, struct bna_mac *mac)
-{
-	list_add_tail(&mac->qe, &ucam_mod->free_q);
-}
-
-struct bna_mac *
-bna_mcam_mod_mac_get(struct bna_mcam_mod *mcam_mod)
-{
-	struct list_head *qe;
-
-	if (list_empty(&mcam_mod->free_q))
-		return NULL;
-
-	bfa_q_deq(&mcam_mod->free_q, &qe);
-
+	bfa_q_deq(head, &qe);
 	return (struct bna_mac *)qe;
 }
 
 void
-bna_mcam_mod_mac_put(struct bna_mcam_mod *mcam_mod, struct bna_mac *mac)
+bna_cam_mod_mac_put(struct list_head *tail, struct bna_mac *mac)
 {
-	list_add_tail(&mac->qe, &mcam_mod->free_q);
+	list_add_tail(&mac->qe, tail);
 }
 
 struct bna_mcam_handle *
diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 3c07064..803fdfd 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -529,13 +529,13 @@ bna_rxf_mcast_cfg_apply(struct bna_rxf *rxf)
 	struct list_head *qe;
 	int ret;
 
-	/* Delete multicast entries previousely added */
+	/* First delete multicast entries to maintain the count */
 	while (!list_empty(&rxf->mcast_pending_del_q)) {
 		bfa_q_deq(&rxf->mcast_pending_del_q, &qe);
 		bfa_q_qe_init(qe);
 		mac = (struct bna_mac *)qe;
 		ret = bna_rxf_mcast_del(rxf, mac, BNA_HARD_CLEANUP);
-		bna_mcam_mod_mac_put(&rxf->rx->bna->mcam_mod, mac);
+		bna_cam_mod_mac_put(bna_mcam_mod_del_q(rxf->rx->bna), mac);
 		if (ret)
 			return ret;
 	}
@@ -586,7 +586,7 @@ bna_rxf_mcast_cfg_reset(struct bna_rxf *rxf, enum bna_cleanup_type cleanup)
 		bfa_q_qe_init(qe);
 		mac = (struct bna_mac *)qe;
 		ret = bna_rxf_mcast_del(rxf, mac, cleanup);
-		bna_mcam_mod_mac_put(&rxf->rx->bna->mcam_mod, mac);
+		bna_cam_mod_mac_put(bna_mcam_mod_del_q(rxf->rx->bna), mac);
 		if (ret)
 			return ret;
 	}
@@ -796,12 +796,12 @@ bna_rxf_uninit(struct bna_rxf *rxf)
 	while (!list_empty(&rxf->ucast_pending_add_q)) {
 		bfa_q_deq(&rxf->ucast_pending_add_q, &mac);
 		bfa_q_qe_init(&mac->qe);
-		bna_ucam_mod_mac_put(&rxf->rx->bna->ucam_mod, mac);
+		bna_cam_mod_mac_put(bna_ucam_mod_free_q(rxf->rx->bna), mac);
 	}
 
 	if (rxf->ucast_pending_mac) {
 		bfa_q_qe_init(&rxf->ucast_pending_mac->qe);
-		bna_ucam_mod_mac_put(&rxf->rx->bna->ucam_mod,
+		bna_cam_mod_mac_put(bna_ucam_mod_free_q(rxf->rx->bna),
 			rxf->ucast_pending_mac);
 		rxf->ucast_pending_mac = NULL;
 	}
@@ -809,7 +809,7 @@ bna_rxf_uninit(struct bna_rxf *rxf)
 	while (!list_empty(&rxf->mcast_pending_add_q)) {
 		bfa_q_deq(&rxf->mcast_pending_add_q, &mac);
 		bfa_q_qe_init(&mac->qe);
-		bna_mcam_mod_mac_put(&rxf->rx->bna->mcam_mod, mac);
+		bna_cam_mod_mac_put(bna_mcam_mod_free_q(rxf->rx->bna), mac);
 	}
 
 	rxf->rxmode_pending = 0;
@@ -869,7 +869,7 @@ bna_rx_ucast_set(struct bna_rx *rx, u8 *ucmac,
 
 	if (rxf->ucast_pending_mac == NULL) {
 		rxf->ucast_pending_mac =
-				bna_ucam_mod_mac_get(&rxf->rx->bna->ucam_mod);
+			bna_cam_mod_mac_get(bna_ucam_mod_free_q(rxf->rx->bna));
 		if (rxf->ucast_pending_mac == NULL)
 			return BNA_CB_UCAST_CAM_FULL;
 		bfa_q_qe_init(&rxf->ucast_pending_mac->qe);
@@ -900,7 +900,7 @@ bna_rx_mcast_add(struct bna_rx *rx, u8 *addr,
 		return BNA_CB_SUCCESS;
 	}
 
-	mac = bna_mcam_mod_mac_get(&rxf->rx->bna->mcam_mod);
+	mac = bna_cam_mod_mac_get(bna_mcam_mod_free_q(rxf->rx->bna));
 	if (mac == NULL)
 		return BNA_CB_MCAST_LIST_FULL;
 	bfa_q_qe_init(&mac->qe);
@@ -919,32 +919,20 @@ enum bna_cb_status
 bna_rx_mcast_listset(struct bna_rx *rx, int count, u8 *mclist,
 		     void (*cbfn)(struct bnad *, struct bna_rx *))
 {
+	struct bna_mcam_mod *mcam_mod = &rx->bna->mcam_mod;
 	struct bna_rxf *rxf = &rx->rxf;
 	struct list_head list_head;
 	struct list_head *qe;
 	u8 *mcaddr;
-	struct bna_mac *mac;
+	struct bna_mac *mac, *del_mac;
 	int i;
 
-	/* Allocate nodes */
-	INIT_LIST_HEAD(&list_head);
-	for (i = 0, mcaddr = mclist; i < count; i++) {
-		mac = bna_mcam_mod_mac_get(&rxf->rx->bna->mcam_mod);
-		if (mac == NULL)
-			goto err_return;
-		bfa_q_qe_init(&mac->qe);
-		memcpy(mac->addr, mcaddr, ETH_ALEN);
-		list_add_tail(&mac->qe, &list_head);
-
-		mcaddr += ETH_ALEN;
-	}
-
 	/* Purge the pending_add_q */
 	while (!list_empty(&rxf->mcast_pending_add_q)) {
 		bfa_q_deq(&rxf->mcast_pending_add_q, &qe);
 		bfa_q_qe_init(qe);
 		mac = (struct bna_mac *)qe;
-		bna_mcam_mod_mac_put(&rxf->rx->bna->mcam_mod, mac);
+		bna_cam_mod_mac_put(&mcam_mod->free_q, mac);
 	}
 
 	/* Schedule active_q entries for deletion */
@@ -952,7 +940,26 @@ bna_rx_mcast_listset(struct bna_rx *rx, int count, u8 *mclist,
 		bfa_q_deq(&rxf->mcast_active_q, &qe);
 		mac = (struct bna_mac *)qe;
 		bfa_q_qe_init(&mac->qe);
-		list_add_tail(&mac->qe, &rxf->mcast_pending_del_q);
+
+		del_mac = bna_cam_mod_mac_get(&mcam_mod->del_q);
+
+		memcpy(del_mac, mac, sizeof(*mac));
+		list_add_tail(&del_mac->qe, &rxf->mcast_pending_del_q);
+		mac->handle = NULL;
+		bna_cam_mod_mac_put(&mcam_mod->free_q, mac);
+	}
+
+	/* Allocate nodes */
+	INIT_LIST_HEAD(&list_head);
+	for (i = 0, mcaddr = mclist; i < count; i++) {
+		mac = bna_cam_mod_mac_get(&mcam_mod->free_q);
+		if (mac == NULL)
+			goto err_return;
+		bfa_q_qe_init(&mac->qe);
+		memcpy(mac->addr, mcaddr, ETH_ALEN);
+		list_add_tail(&mac->qe, &list_head);
+
+		mcaddr += ETH_ALEN;
 	}
 
 	/* Add the new entries */
@@ -974,7 +981,7 @@ err_return:
 		bfa_q_deq(&list_head, &qe);
 		mac = (struct bna_mac *)qe;
 		bfa_q_qe_init(&mac->qe);
-		bna_mcam_mod_mac_put(&rxf->rx->bna->mcam_mod, mac);
+		bna_cam_mod_mac_put(&mcam_mod->free_q, mac);
 	}
 
 	return BNA_CB_MCAST_LIST_FULL;
@@ -1022,7 +1029,7 @@ bna_rxf_ucast_cfg_apply(struct bna_rxf *rxf)
 		bfa_q_qe_init(qe);
 		mac = (struct bna_mac *)qe;
 		bna_bfi_ucast_req(rxf, mac, BFI_ENET_H2I_MAC_UCAST_DEL_REQ);
-		bna_ucam_mod_mac_put(&rxf->rx->bna->ucam_mod, mac);
+		bna_cam_mod_mac_put(bna_ucam_mod_del_q(rxf->rx->bna), mac);
 		return 1;
 	}
 
@@ -1062,11 +1069,13 @@ bna_rxf_ucast_cfg_reset(struct bna_rxf *rxf, enum bna_cleanup_type cleanup)
 		bfa_q_qe_init(qe);
 		mac = (struct bna_mac *)qe;
 		if (cleanup == BNA_SOFT_CLEANUP)
-			bna_ucam_mod_mac_put(&rxf->rx->bna->ucam_mod, mac);
+			bna_cam_mod_mac_put(bna_ucam_mod_del_q(rxf->rx->bna),
+				    mac);
 		else {
 			bna_bfi_ucast_req(rxf, mac,
 				BFI_ENET_H2I_MAC_UCAST_DEL_REQ);
-			bna_ucam_mod_mac_put(&rxf->rx->bna->ucam_mod, mac);
+			bna_cam_mod_mac_put(bna_ucam_mod_del_q(rxf->rx->bna),
+				    mac);
 			return 1;
 		}
 	}
diff --git a/drivers/net/ethernet/brocade/bna/bna_types.h b/drivers/net/ethernet/brocade/bna/bna_types.h
index dc50f78..acedac2 100644
--- a/drivers/net/ethernet/brocade/bna/bna_types.h
+++ b/drivers/net/ethernet/brocade/bna/bna_types.h
@@ -866,8 +866,9 @@ struct bna_rx_mod {
 /* CAM */
 
 struct bna_ucam_mod {
-	struct bna_mac *ucmac;		/* BFI_MAX_UCMAC entries */
+	struct bna_mac *ucmac;		/* num_ucmac * 2 entries */
 	struct list_head			free_q;
+	struct list_head			del_q;
 
 	struct bna *bna;
 };
@@ -880,9 +881,10 @@ struct bna_mcam_handle {
 };
 
 struct bna_mcam_mod {
-	struct bna_mac *mcmac;		/* BFI_MAX_MCMAC entries */
-	struct bna_mcam_handle *mchandle;	/* BFI_MAX_MCMAC entries */
+	struct bna_mac *mcmac;		/* num_mcmac * 2 entries */
+	struct bna_mcam_handle *mchandle;	/* num_mcmac entries */
 	struct list_head			free_q;
+	struct list_head			del_q;
 	struct list_head			free_handle_q;
 
 	struct bna *bna;
-- 
1.8.2.3
