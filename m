From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 01/19] bna: use ether_addr_copy instead of memcpy
Date: Wed, 10 Jun 2015 18:43:07 +0200
Message-ID: <1433954605-22813-2-git-send-email-ivecera@redhat.com>
References: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40298 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754471AbbFJQm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 12:42:59 -0400
In-Reply-To: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c | 12 ++++++------
 drivers/net/ethernet/brocade/bna/bnad.c      | 14 ++++++--------
 2 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 8ab3a5f..30d5e7f 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -876,7 +876,7 @@ bna_rx_ucast_set(struct bna_rx *rx, u8 *ucmac,
 		bfa_q_qe_init(&rxf->ucast_pending_mac->qe);
 	}
 
-	memcpy(rxf->ucast_pending_mac->addr, ucmac, ETH_ALEN);
+	ether_addr_copy(rxf->ucast_pending_mac->addr, ucmac);
 	rxf->ucast_pending_set = 1;
 	rxf->cam_fltr_cbfn = cbfn;
 	rxf->cam_fltr_cbarg = rx->bna->bnad;
@@ -905,7 +905,7 @@ bna_rx_mcast_add(struct bna_rx *rx, u8 *addr,
 	if (mac == NULL)
 		return BNA_CB_MCAST_LIST_FULL;
 	bfa_q_qe_init(&mac->qe);
-	memcpy(mac->addr, addr, ETH_ALEN);
+	ether_addr_copy(mac->addr, addr);
 	list_add_tail(&mac->qe, &rxf->mcast_pending_add_q);
 
 	rxf->cam_fltr_cbfn = cbfn;
@@ -955,7 +955,7 @@ bna_rx_ucast_listset(struct bna_rx *rx, int count, u8 *uclist,
 		if (mac == NULL)
 			goto err_return;
 		bfa_q_qe_init(&mac->qe);
-		memcpy(mac->addr, mcaddr, ETH_ALEN);
+		ether_addr_copy(mac->addr, mcaddr);
 		list_add_tail(&mac->qe, &list_head);
 		mcaddr += ETH_ALEN;
 	}
@@ -1026,7 +1026,7 @@ bna_rx_mcast_listset(struct bna_rx *rx, int count, u8 *mclist,
 		if (mac == NULL)
 			goto err_return;
 		bfa_q_qe_init(&mac->qe);
-		memcpy(mac->addr, mcaddr, ETH_ALEN);
+		ether_addr_copy(mac->addr, mcaddr);
 		list_add_tail(&mac->qe, &list_head);
 
 		mcaddr += ETH_ALEN;
@@ -1149,8 +1149,8 @@ bna_rxf_ucast_cfg_apply(struct bna_rxf *rxf)
 	/* Set default unicast MAC */
 	if (rxf->ucast_pending_set) {
 		rxf->ucast_pending_set = 0;
-		memcpy(rxf->ucast_active_mac.addr,
-			rxf->ucast_pending_mac->addr, ETH_ALEN);
+		ether_addr_copy(rxf->ucast_active_mac.addr,
+				rxf->ucast_pending_mac->addr);
 		rxf->ucast_active_set = 1;
 		bna_bfi_ucast_req(rxf, &rxf->ucast_active_mac,
 			BFI_ENET_H2I_MAC_UCAST_SET_REQ);
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index caae6cb..bb87c11 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -875,9 +875,9 @@ bnad_set_netdev_perm_addr(struct bnad *bnad)
 {
 	struct net_device *netdev = bnad->netdev;
 
-	memcpy(netdev->perm_addr, &bnad->perm_addr, netdev->addr_len);
+	ether_addr_copy(netdev->perm_addr, bnad->perm_addr.mac);
 	if (is_zero_ether_addr(netdev->dev_addr))
-		memcpy(netdev->dev_addr, &bnad->perm_addr, netdev->addr_len);
+		ether_addr_copy(netdev->dev_addr, bnad->perm_addr.mac);
 }
 
 /* Control Path Handlers */
@@ -1862,8 +1862,7 @@ bnad_netdev_mc_list_get(struct net_device *netdev, u8 *mc_list)
 	struct netdev_hw_addr *mc_addr;
 
 	netdev_for_each_mc_addr(mc_addr, netdev) {
-		memcpy(&mc_list[i * ETH_ALEN], &mc_addr->addr[0],
-							ETH_ALEN);
+		ether_addr_copy(&mc_list[i * ETH_ALEN], &mc_addr->addr[0]);
 		i++;
 	}
 }
@@ -3141,8 +3140,7 @@ bnad_set_rx_ucast_fltr(struct bnad *bnad)
 
 	entry = 0;
 	netdev_for_each_uc_addr(ha, netdev) {
-		memcpy(&mac_list[entry * ETH_ALEN],
-		       &ha->addr[0], ETH_ALEN);
+		ether_addr_copy(&mac_list[entry * ETH_ALEN], &ha->addr[0]);
 		entry++;
 	}
 
@@ -3183,7 +3181,7 @@ bnad_set_rx_mcast_fltr(struct bnad *bnad)
 	if (mac_list == NULL)
 		goto mode_allmulti;
 
-	memcpy(&mac_list[0], &bnad_bcast_addr[0], ETH_ALEN);
+	ether_addr_copy(&mac_list[0], &bnad_bcast_addr[0]);
 
 	/* copy rest of the MCAST addresses */
 	bnad_netdev_mc_list_get(netdev, mac_list);
@@ -3260,7 +3258,7 @@ bnad_set_mac_address(struct net_device *netdev, void *mac_addr)
 	err = bnad_mac_addr_set_locked(bnad, sa->sa_data);
 
 	if (!err)
-		memcpy(netdev->dev_addr, sa->sa_data, netdev->addr_len);
+		ether_addr_copy(netdev->dev_addr, sa->sa_data);
 
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
-- 
2.3.6
