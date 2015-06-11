From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next v2 06/19] bna: remove unused cbfn parameter
Date: Thu, 11 Jun 2015 15:52:18 +0200
Message-ID: <1434030751-28835-7-git-send-email-ivecera@redhat.com>
References: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50000 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754629AbbFKNwN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 09:52:13 -0400
In-Reply-To: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

removed:
bna_rx_ucast_add
bna_rx_ucast_del

simplified:
bna_enet_pause_config
bna_rx_mcast_delall
bna_rx_mcast_listset
bna_rx_mode_set
bna_rx_ucast_listset
bna_rx_ucast_set

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bna.h          | 24 +++++------------
 drivers/net/ethernet/brocade/bna/bna_enet.c     |  5 +---
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c    | 35 +++++++------------------
 drivers/net/ethernet/brocade/bna/bnad.c         | 18 ++++++-------
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c |  2 +-
 5 files changed, 25 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna.h b/drivers/net/ethernet/brocade/bna/bna.h
index 130010d..0962e54 100644
--- a/drivers/net/ethernet/brocade/bna/bna.h
+++ b/drivers/net/ethernet/brocade/bna/bna.h
@@ -386,30 +386,19 @@ void bna_rx_coalescing_timeo_set(struct bna_rx *rx, int coalescing_timeo);
 void bna_rx_dim_reconfig(struct bna *bna, const u32 vector[][BNA_BIAS_T_MAX]);
 void bna_rx_dim_update(struct bna_ccb *ccb);
 enum bna_cb_status
-bna_rx_ucast_set(struct bna_rx *rx, u8 *ucmac,
-		 void (*cbfn)(struct bnad *, struct bna_rx *));
-enum bna_cb_status
-bna_rx_ucast_add(struct bna_rx *rx, u8* ucmac,
-		 void (*cbfn)(struct bnad *, struct bna_rx *));
-enum bna_cb_status
-bna_rx_ucast_del(struct bna_rx *rx, u8 *ucmac,
-		 void (*cbfn)(struct bnad *, struct bna_rx *));
+bna_rx_ucast_set(struct bna_rx *rx, u8 *ucmac);
 enum bna_cb_status
-bna_rx_ucast_listset(struct bna_rx *rx, int count, u8 *uclist,
-		     void (*cbfn)(struct bnad *, struct bna_rx *));
+bna_rx_ucast_listset(struct bna_rx *rx, int count, u8 *uclist);
 enum bna_cb_status
 bna_rx_mcast_add(struct bna_rx *rx, u8 *mcmac,
 		 void (*cbfn)(struct bnad *, struct bna_rx *));
 enum bna_cb_status
-bna_rx_mcast_listset(struct bna_rx *rx, int count, u8 *mcmac,
-		     void (*cbfn)(struct bnad *, struct bna_rx *));
+bna_rx_mcast_listset(struct bna_rx *rx, int count, u8 *mcmac);
 void
-bna_rx_mcast_delall(struct bna_rx *rx,
-		    void (*cbfn)(struct bnad *, struct bna_rx *));
+bna_rx_mcast_delall(struct bna_rx *rx);
 enum bna_cb_status
 bna_rx_mode_set(struct bna_rx *rx, enum bna_rxmode rxmode,
-		enum bna_rxmode bitmask,
-		void (*cbfn)(struct bnad *, struct bna_rx *));
+		enum bna_rxmode bitmask);
 void bna_rx_vlan_add(struct bna_rx *rx, int vlan_id);
 void bna_rx_vlan_del(struct bna_rx *rx, int vlan_id);
 void bna_rx_vlanfilter_enable(struct bna_rx *rx);
@@ -429,8 +418,7 @@ void bna_enet_enable(struct bna_enet *enet);
 void bna_enet_disable(struct bna_enet *enet, enum bna_cleanup_type type,
 		      void (*cbfn)(void *));
 void bna_enet_pause_config(struct bna_enet *enet,
-			   struct bna_pause_config *pause_config,
-			   void (*cbfn)(struct bnad *));
+			   struct bna_pause_config *pause_config);
 void bna_enet_mtu_set(struct bna_enet *enet, int mtu,
 		      void (*cbfn)(struct bnad *));
 void bna_enet_perm_mac_get(struct bna_enet *enet, u8 *mac);
diff --git a/drivers/net/ethernet/brocade/bna/bna_enet.c b/drivers/net/ethernet/brocade/bna/bna_enet.c
index 54902ce..b8de17b 100644
--- a/drivers/net/ethernet/brocade/bna/bna_enet.c
+++ b/drivers/net/ethernet/brocade/bna/bna_enet.c
@@ -1308,13 +1308,10 @@ bna_enet_disable(struct bna_enet *enet, enum bna_cleanup_type type,
 
 void
 bna_enet_pause_config(struct bna_enet *enet,
-		      struct bna_pause_config *pause_config,
-		      void (*cbfn)(struct bnad *))
+		      struct bna_pause_config *pause_config)
 {
 	enet->pause_config = *pause_config;
 
-	enet->pause_cbfn = cbfn;
-
 	bfa_fsm_send_event(enet, ENET_E_PAUSE_CFG);
 }
 
diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 2c85f72..16d36df 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -863,8 +863,7 @@ bna_rxf_fail(struct bna_rxf *rxf)
 }
 
 enum bna_cb_status
-bna_rx_ucast_set(struct bna_rx *rx, u8 *ucmac,
-		 void (*cbfn)(struct bnad *, struct bna_rx *))
+bna_rx_ucast_set(struct bna_rx *rx, u8 *ucmac)
 {
 	struct bna_rxf *rxf = &rx->rxf;
 
@@ -878,7 +877,7 @@ bna_rx_ucast_set(struct bna_rx *rx, u8 *ucmac,
 
 	ether_addr_copy(rxf->ucast_pending_mac->addr, ucmac);
 	rxf->ucast_pending_set = 1;
-	rxf->cam_fltr_cbfn = cbfn;
+	rxf->cam_fltr_cbfn = NULL;
 	rxf->cam_fltr_cbarg = rx->bna->bnad;
 
 	bfa_fsm_send_event(rxf, RXF_E_CONFIG);
@@ -917,8 +916,7 @@ bna_rx_mcast_add(struct bna_rx *rx, u8 *addr,
 }
 
 enum bna_cb_status
-bna_rx_ucast_listset(struct bna_rx *rx, int count, u8 *uclist,
-		     void (*cbfn)(struct bnad *, struct bna_rx *))
+bna_rx_ucast_listset(struct bna_rx *rx, int count, u8 *uclist)
 {
 	struct bna_ucam_mod *ucam_mod = &rx->bna->ucam_mod;
 	struct bna_rxf *rxf = &rx->rxf;
@@ -968,8 +966,6 @@ bna_rx_ucast_listset(struct bna_rx *rx, int count, u8 *uclist,
 		list_add_tail(&mac->qe, &rxf->ucast_pending_add_q);
 	}
 
-	rxf->cam_fltr_cbfn = cbfn;
-	rxf->cam_fltr_cbarg = rx->bna->bnad;
 	bfa_fsm_send_event(rxf, RXF_E_CONFIG);
 
 	return BNA_CB_SUCCESS;
@@ -986,8 +982,7 @@ err_return:
 }
 
 enum bna_cb_status
-bna_rx_mcast_listset(struct bna_rx *rx, int count, u8 *mclist,
-		     void (*cbfn)(struct bnad *, struct bna_rx *))
+bna_rx_mcast_listset(struct bna_rx *rx, int count, u8 *mclist)
 {
 	struct bna_mcam_mod *mcam_mod = &rx->bna->mcam_mod;
 	struct bna_rxf *rxf = &rx->rxf;
@@ -1040,8 +1035,6 @@ bna_rx_mcast_listset(struct bna_rx *rx, int count, u8 *mclist,
 		list_add_tail(&mac->qe, &rxf->mcast_pending_add_q);
 	}
 
-	rxf->cam_fltr_cbfn = cbfn;
-	rxf->cam_fltr_cbarg = rx->bna->bnad;
 	bfa_fsm_send_event(rxf, RXF_E_CONFIG);
 
 	return BNA_CB_SUCCESS;
@@ -1058,8 +1051,7 @@ err_return:
 }
 
 void
-bna_rx_mcast_delall(struct bna_rx *rx,
-		    void (*cbfn)(struct bnad *, struct bna_rx *))
+bna_rx_mcast_delall(struct bna_rx *rx)
 {
 	struct bna_rxf *rxf = &rx->rxf;
 	struct list_head *qe;
@@ -1089,15 +1081,8 @@ bna_rx_mcast_delall(struct bna_rx *rx,
 		need_hw_config = 1;
 	}
 
-	if (need_hw_config) {
-		rxf->cam_fltr_cbfn = cbfn;
-		rxf->cam_fltr_cbarg = rx->bna->bnad;
+	if (need_hw_config)
 		bfa_fsm_send_event(rxf, RXF_E_CONFIG);
-		return;
-	}
-
-	if (cbfn)
-		(*cbfn)(rx->bna->bnad, rx);
 }
 
 void
@@ -2843,8 +2828,7 @@ bna_rx_vlan_strip_disable(struct bna_rx *rx)
 
 enum bna_cb_status
 bna_rx_mode_set(struct bna_rx *rx, enum bna_rxmode new_mode,
-		enum bna_rxmode bitmask,
-		void (*cbfn)(struct bnad *, struct bna_rx *))
+		enum bna_rxmode bitmask)
 {
 	struct bna_rxf *rxf = &rx->rxf;
 	int need_hw_config = 0;
@@ -2899,11 +2883,10 @@ bna_rx_mode_set(struct bna_rx *rx, enum bna_rxmode new_mode,
 	/* Trigger h/w if needed */
 
 	if (need_hw_config) {
-		rxf->cam_fltr_cbfn = cbfn;
+		rxf->cam_fltr_cbfn = NULL;
 		rxf->cam_fltr_cbarg = rx->bna->bnad;
 		bfa_fsm_send_event(rxf, RXF_E_CONFIG);
-	} else if (cbfn)
-		(*cbfn)(rx->bna->bnad, rx);
+	}
 
 	return BNA_CB_SUCCESS;
 
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 6e871a7..0f833e4 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -2349,7 +2349,7 @@ bnad_mac_addr_set_locked(struct bnad *bnad, u8 *mac_addr)
 	if (!bnad->rx_info[0].rx)
 		return 0;
 
-	ret = bna_rx_ucast_set(bnad->rx_info[0].rx, mac_addr, NULL);
+	ret = bna_rx_ucast_set(bnad->rx_info[0].rx, mac_addr);
 	if (ret != BNA_CB_SUCCESS)
 		return -EADDRNOTAVAIL;
 
@@ -2754,7 +2754,7 @@ bnad_open(struct net_device *netdev)
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_enet_mtu_set(&bnad->bna.enet,
 			 BNAD_FRAME_SIZE(bnad->netdev->mtu), NULL);
-	bna_enet_pause_config(&bnad->bna.enet, &pause_config, NULL);
+	bna_enet_pause_config(&bnad->bna.enet, &pause_config);
 	bna_enet_enable(&bnad->bna.enet);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
@@ -3128,7 +3128,7 @@ bnad_set_rx_ucast_fltr(struct bnad *bnad)
 	int entry;
 
 	if (netdev_uc_empty(bnad->netdev)) {
-		bna_rx_ucast_listset(bnad->rx_info[0].rx, 0, NULL, NULL);
+		bna_rx_ucast_listset(bnad->rx_info[0].rx, 0, NULL);
 		return;
 	}
 
@@ -3145,8 +3145,7 @@ bnad_set_rx_ucast_fltr(struct bnad *bnad)
 		entry++;
 	}
 
-	ret = bna_rx_ucast_listset(bnad->rx_info[0].rx, entry,
-			mac_list, NULL);
+	ret = bna_rx_ucast_listset(bnad->rx_info[0].rx, entry, mac_list);
 	kfree(mac_list);
 
 	if (ret != BNA_CB_SUCCESS)
@@ -3157,7 +3156,7 @@ bnad_set_rx_ucast_fltr(struct bnad *bnad)
 	/* ucast packets not in UCAM are routed to default function */
 mode_default:
 	bnad->cfg_flags |= BNAD_CF_DEFAULT;
-	bna_rx_ucast_listset(bnad->rx_info[0].rx, 0, NULL, NULL);
+	bna_rx_ucast_listset(bnad->rx_info[0].rx, 0, NULL);
 }
 
 static void
@@ -3186,8 +3185,7 @@ bnad_set_rx_mcast_fltr(struct bnad *bnad)
 
 	/* copy rest of the MCAST addresses */
 	bnad_netdev_mc_list_get(netdev, mac_list);
-	ret = bna_rx_mcast_listset(bnad->rx_info[0].rx, mc_count + 1,
-			mac_list, NULL);
+	ret = bna_rx_mcast_listset(bnad->rx_info[0].rx, mc_count + 1, mac_list);
 	kfree(mac_list);
 
 	if (ret != BNA_CB_SUCCESS)
@@ -3197,7 +3195,7 @@ bnad_set_rx_mcast_fltr(struct bnad *bnad)
 
 mode_allmulti:
 	bnad->cfg_flags |= BNAD_CF_ALLMULTI;
-	bna_rx_mcast_delall(bnad->rx_info[0].rx, NULL);
+	bna_rx_mcast_delall(bnad->rx_info[0].rx);
 }
 
 void
@@ -3236,7 +3234,7 @@ bnad_set_rx_mode(struct net_device *netdev)
 
 	mode_mask = BNA_RXMODE_PROMISC | BNA_RXMODE_DEFAULT |
 			BNA_RXMODE_ALLMULTI;
-	bna_rx_mode_set(bnad->rx_info[0].rx, new_mode, mode_mask, NULL);
+	bna_rx_mode_set(bnad->rx_info[0].rx, new_mode, mode_mask);
 
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 }
diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index ade251b..088062a 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -533,7 +533,7 @@ bnad_set_pauseparam(struct net_device *netdev,
 		pause_config.rx_pause = pauseparam->rx_pause;
 		pause_config.tx_pause = pauseparam->tx_pause;
 		spin_lock_irqsave(&bnad->bna_lock, flags);
-		bna_enet_pause_config(&bnad->bna.enet, &pause_config, NULL);
+		bna_enet_pause_config(&bnad->bna.enet, &pause_config);
 		spin_unlock_irqrestore(&bnad->bna_lock, flags);
 	}
 	mutex_unlock(&bnad->conf_mutex);
-- 
2.3.6
