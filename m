From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 02/19] bna: get rid of mac_t
Date: Wed, 10 Jun 2015 18:43:08 +0200
Message-ID: <1433954605-22813-3-git-send-email-ivecera@redhat.com>
References: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57727 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754474AbbFJQnA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 12:43:00 -0400
In-Reply-To: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch converts mac_t type to widely used 'u8 [ETH_ALEN]'.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bfa_defs.h     |  4 ++--
 drivers/net/ethernet/brocade/bna/bfa_defs_cna.h |  2 +-
 drivers/net/ethernet/brocade/bna/bfa_ioc.c      |  8 ++++----
 drivers/net/ethernet/brocade/bna/bfa_ioc.h      |  2 +-
 drivers/net/ethernet/brocade/bna/bfi.h          |  6 +++---
 drivers/net/ethernet/brocade/bna/bfi_enet.h     |  6 +++---
 drivers/net/ethernet/brocade/bna/bna.h          |  4 ++--
 drivers/net/ethernet/brocade/bna/bna_enet.c     |  4 ++--
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c    |  4 ++--
 drivers/net/ethernet/brocade/bna/bnad.c         | 10 +++++-----
 drivers/net/ethernet/brocade/bna/bnad.h         |  2 +-
 drivers/net/ethernet/brocade/bna/cna.h          |  6 ------
 12 files changed, 26 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs.h b/drivers/net/ethernet/brocade/bna/bfa_defs.h
index 3bfd9da..f55887b 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs.h
@@ -55,7 +55,7 @@ struct bfa_adapter_attr {
 	char		optrom_ver[BFA_VERSION_LEN];
 	char		os_type[BFA_ADAPTER_OS_TYPE_LEN];
 	struct bfa_mfg_vpd vpd;
-	struct mac mac;
+	u8		mac[ETH_ALEN];
 
 	u8		nports;
 	u8		max_speed;
@@ -211,7 +211,7 @@ struct bfa_mfg_block {
 	char	supplier_partnum[STRSZ(BFA_MFG_SUPPLIER_PARTNUM_SIZE)];
 	char	supplier_serialnum[STRSZ(BFA_MFG_SUPPLIER_SERIALNUM_SIZE)];
 	char	supplier_revision[STRSZ(BFA_MFG_SUPPLIER_REVISION_SIZE)];
-	mac_t	mfg_mac;	/* base mac address */
+	u8	mfg_mac[ETH_ALEN]; /* base mac address */
 	u8	num_mac;	/* number of mac addresses */
 	u8	rsv2;
 	u32	card_type;	/* card type          */
diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h b/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h
index a37326d..ce0b228 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h
@@ -188,7 +188,7 @@ struct bfa_cee_attr {
 	u8 error_reason;
 	struct bfa_cee_lldp_cfg lldp_remote;
 	struct bfa_cee_dcbx_cfg dcbx_remote;
-	mac_t src_mac;
+	u8 src_mac[ETH_ALEN];
 	u8 link_speed;
 	u8 nw_priority;
 	u8 filler[2];
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index 68f3c13..82c95f8 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -2796,7 +2796,7 @@ bfa_ioc_get_adapter_attr(struct bfa_ioc *ioc,
 		ad_attr->prototype = 0;
 
 	ad_attr->pwwn = bfa_ioc_get_pwwn(ioc);
-	ad_attr->mac  = bfa_nw_ioc_get_mac(ioc);
+	bfa_nw_ioc_get_mac(ioc, ad_attr->mac);
 
 	ad_attr->pcie_gen = ioc_attr->pcie_gen;
 	ad_attr->pcie_lanes = ioc_attr->pcie_lanes;
@@ -2942,10 +2942,10 @@ bfa_ioc_get_pwwn(struct bfa_ioc *ioc)
 	return ioc->attr->pwwn;
 }
 
-mac_t
-bfa_nw_ioc_get_mac(struct bfa_ioc *ioc)
+void
+bfa_nw_ioc_get_mac(struct bfa_ioc *ioc, u8 *mac)
 {
-	return ioc->attr->mac;
+	ether_addr_copy(mac, ioc->attr->mac);
 }
 
 /* Firmware failure detected. Start recovery actions. */
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.h b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
index effb715..b37bc16 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
@@ -309,7 +309,7 @@ void bfa_nw_ioc_fwver_get(struct bfa_ioc *ioc,
 			struct bfi_ioc_image_hdr *fwhdr);
 bool bfa_nw_ioc_fwver_cmp(struct bfa_ioc *ioc,
 			struct bfi_ioc_image_hdr *fwhdr);
-mac_t bfa_nw_ioc_get_mac(struct bfa_ioc *ioc);
+void bfa_nw_ioc_get_mac(struct bfa_ioc *ioc, u8 *mac);
 void bfa_nw_ioc_debug_memclaim(struct bfa_ioc *ioc, void *dbg_fwsave);
 int bfa_nw_ioc_debug_fwtrc(struct bfa_ioc *ioc, void *trcdata, int *trclen);
 int bfa_nw_ioc_debug_fwsave(struct bfa_ioc *ioc, void *trcdata, int *trclen);
diff --git a/drivers/net/ethernet/brocade/bna/bfi.h b/drivers/net/ethernet/brocade/bna/bfi.h
index 2bcde40..63645ac 100644
--- a/drivers/net/ethernet/brocade/bna/bfi.h
+++ b/drivers/net/ethernet/brocade/bna/bfi.h
@@ -189,14 +189,14 @@ struct bfi_ioc_getattr_req {
 struct bfi_ioc_attr {
 	u64		mfg_pwwn;	/*!< Mfg port wwn	   */
 	u64		mfg_nwwn;	/*!< Mfg node wwn	   */
-	mac_t		mfg_mac;	/*!< Mfg mac		   */
+	u8		mfg_mac[ETH_ALEN]; /*!< Mfg mac		   */
 	u8		port_mode;	/* enum bfi_port_mode	   */
 	u8		rsvd_a;
 	u64		pwwn;
 	u64		nwwn;
-	mac_t		mac;		/*!< PBC or Mfg mac	   */
+	u8		mac[ETH_ALEN];	/*!< PBC or Mfg mac	   */
 	u16	rsvd_b;
-	mac_t		fcoe_mac;
+	u8		fcoe_mac[ETH_ALEN];
 	u16	rsvd_c;
 	char		brcd_serialnum[STRSZ(BFA_MFG_SERIALNUM_SIZE)];
 	u8		pcie_gen;
diff --git a/drivers/net/ethernet/brocade/bna/bfi_enet.h b/drivers/net/ethernet/brocade/bna/bfi_enet.h
index bccca3b..5b0c6c8 100644
--- a/drivers/net/ethernet/brocade/bna/bfi_enet.h
+++ b/drivers/net/ethernet/brocade/bna/bfi_enet.h
@@ -573,7 +573,7 @@ struct bfi_enet_rss_cfg_req {
  */
 struct bfi_enet_ucast_req {
 	struct bfi_msgq_mhdr	mh;
-	mac_t			mac_addr;
+	u8			mac_addr[ETH_ALEN];
 	u8			rsvd[2];
 };
 
@@ -581,7 +581,7 @@ struct bfi_enet_ucast_req {
 struct bfi_enet_mac_n_vlan_req {
 	struct bfi_msgq_mhdr	mh;
 	u16			vlan_id;
-	mac_t			mac_addr;
+	u8			mac_addr[ETH_ALEN];
 };
 
 /* MAC Multicast
@@ -591,7 +591,7 @@ struct bfi_enet_mac_n_vlan_req {
  */
 struct bfi_enet_mcast_add_req {
 	struct bfi_msgq_mhdr	mh;
-	mac_t			mac_addr;
+	u8			mac_addr[ETH_ALEN];
 	u8			rsvd[2];
 };
 
diff --git a/drivers/net/ethernet/brocade/bna/bna.h b/drivers/net/ethernet/brocade/bna/bna.h
index 8ba72b1..0cad6bd 100644
--- a/drivers/net/ethernet/brocade/bna/bna.h
+++ b/drivers/net/ethernet/brocade/bna/bna.h
@@ -36,7 +36,7 @@ extern const u32 bna_napi_dim_vector[][BNA_BIAS_T_MAX];
 #define bna_is_small_rxq(_id) ((_id) & 0x1)
 
 #define BNA_MAC_IS_EQUAL(_mac1, _mac2)					\
-	(!memcmp((_mac1), (_mac2), sizeof(mac_t)))
+	(!memcmp((_mac1), (_mac2), ETH_ALEN))
 
 #define BNA_POWER_OF_2(x) (((x) & ((x) - 1)) == 0)
 
@@ -536,7 +536,7 @@ void bna_enet_pause_config(struct bna_enet *enet,
 			   void (*cbfn)(struct bnad *));
 void bna_enet_mtu_set(struct bna_enet *enet, int mtu,
 		      void (*cbfn)(struct bnad *));
-void bna_enet_perm_mac_get(struct bna_enet *enet, mac_t *mac);
+void bna_enet_perm_mac_get(struct bna_enet *enet, u8 *mac);
 
 /* IOCETH */
 
diff --git a/drivers/net/ethernet/brocade/bna/bna_enet.c b/drivers/net/ethernet/brocade/bna/bna_enet.c
index deb8da6..5a1e6b5 100644
--- a/drivers/net/ethernet/brocade/bna/bna_enet.c
+++ b/drivers/net/ethernet/brocade/bna/bna_enet.c
@@ -1330,9 +1330,9 @@ bna_enet_mtu_set(struct bna_enet *enet, int mtu,
 }
 
 void
-bna_enet_perm_mac_get(struct bna_enet *enet, mac_t *mac)
+bna_enet_perm_mac_get(struct bna_enet *enet, u8 *mac)
 {
-	*mac = bfa_nw_ioc_get_mac(&enet->bna->ioceth.ioc);
+	bfa_nw_ioc_get_mac(&enet->bna->ioceth.ioc, mac);
 }
 
 /* IOCETH */
diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 30d5e7f..8943188 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -283,7 +283,7 @@ bna_bfi_ucast_req(struct bna_rxf *rxf, struct bna_mac *mac,
 	bfi_msgq_mhdr_set(req->mh, BFI_MC_ENET, req_type, 0, rxf->rx->rid);
 	req->mh.num_entries = htons(
 	bfi_msgq_num_cmd_entries(sizeof(struct bfi_enet_ucast_req)));
-	memcpy(&req->mac_addr, &mac->addr, sizeof(mac_t));
+	ether_addr_copy(req->mac_addr, mac->addr);
 	bfa_msgq_cmd_set(&rxf->msgq_cmd, NULL, NULL,
 		sizeof(struct bfi_enet_ucast_req), &req->mh);
 	bfa_msgq_cmd_post(&rxf->rx->bna->msgq, &rxf->msgq_cmd);
@@ -299,7 +299,7 @@ bna_bfi_mcast_add_req(struct bna_rxf *rxf, struct bna_mac *mac)
 		0, rxf->rx->rid);
 	req->mh.num_entries = htons(
 	bfi_msgq_num_cmd_entries(sizeof(struct bfi_enet_mcast_add_req)));
-	memcpy(&req->mac_addr, &mac->addr, sizeof(mac_t));
+	ether_addr_copy(req->mac_addr, mac->addr);
 	bfa_msgq_cmd_set(&rxf->msgq_cmd, NULL, NULL,
 		sizeof(struct bfi_enet_mcast_add_req), &req->mh);
 	bfa_msgq_cmd_post(&rxf->rx->bna->msgq, &rxf->msgq_cmd);
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index bb87c11..980e578 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -875,9 +875,9 @@ bnad_set_netdev_perm_addr(struct bnad *bnad)
 {
 	struct net_device *netdev = bnad->netdev;
 
-	ether_addr_copy(netdev->perm_addr, bnad->perm_addr.mac);
+	ether_addr_copy(netdev->perm_addr, bnad->perm_addr);
 	if (is_zero_ether_addr(netdev->dev_addr))
-		ether_addr_copy(netdev->dev_addr, bnad->perm_addr.mac);
+		ether_addr_copy(netdev->dev_addr, bnad->perm_addr);
 }
 
 /* Control Path Handlers */
@@ -1094,8 +1094,8 @@ bnad_cb_tx_resume(struct bnad *bnad, struct bna_tx *tx)
 	 * get a 0 MAC address. We try to get the MAC address
 	 * again here.
 	 */
-	if (is_zero_ether_addr(&bnad->perm_addr.mac[0])) {
-		bna_enet_perm_mac_get(&bnad->bna.enet, &bnad->perm_addr);
+	if (is_zero_ether_addr(bnad->perm_addr)) {
+		bna_enet_perm_mac_get(&bnad->bna.enet, bnad->perm_addr);
 		bnad_set_netdev_perm_addr(bnad);
 	}
 }
@@ -3740,7 +3740,7 @@ bnad_pci_probe(struct pci_dev *pdev,
 
 	/* Get the burnt-in mac */
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bna_enet_perm_mac_get(&bna->enet, &bnad->perm_addr);
+	bna_enet_perm_mac_get(&bna->enet, bnad->perm_addr);
 	bnad_set_netdev_perm_addr(bnad);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index 7ead6c2..91fd82d 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -344,7 +344,7 @@ struct bnad {
 	struct bnad_completion bnad_completions;
 
 	/* Burnt in MAC address */
-	mac_t			perm_addr;
+	u8			perm_addr[ETH_ALEN];
 
 	struct workqueue_struct *work_q;
 
diff --git a/drivers/net/ethernet/brocade/bna/cna.h b/drivers/net/ethernet/brocade/bna/cna.h
index 28e7d0f..b42aafd 100644
--- a/drivers/net/ethernet/brocade/bna/cna.h
+++ b/drivers/net/ethernet/brocade/bna/cna.h
@@ -42,12 +42,6 @@ extern char bfa_version[];
 #define CNA_FW_FILE_CT2	"ct2fw-3.2.5.1.bin"
 #define FC_SYMNAME_MAX	256	/*!< max name server symbolic name size */
 
-#pragma pack(1)
-
-typedef struct mac { u8 mac[ETH_ALEN]; } mac_t;
-
-#pragma pack()
-
 #define bfa_q_first(_q) ((void *)(((struct list_head *) (_q))->next))
 #define bfa_q_next(_qe)	(((struct list_head *) (_qe))->next)
 #define bfa_q_prev(_qe) (((struct list_head *) (_qe))->prev)
-- 
2.3.6
