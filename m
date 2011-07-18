From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 43/45] bna: Dropped BUG_ONs and Rx id init fix
Date: Mon, 18 Jul 2011 01:23:03 -0700
Message-ID: <1310977385-5268-33-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37856 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755110Ab1GRIZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:25:26 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Removed some BUG_ONs and comments addition/cleanup
 - Initializing rx_id to 0 for bnad_cleanup_rx
 - Releasing all the locks while doing free_netdev
 - Counting the Rx buffer allocation failures in bnad_alloc_n_post_rxbufs()

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bna_hw.h |    1 +
 drivers/net/bna/bnad.c   |   32 ++++++++++++++++++++------------
 drivers/net/bna/bnad.h   |   15 ++++++++-------
 3 files changed, 29 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bna/bna_hw.h b/drivers/net/bna/bna_hw.h
index 80b21ee..552e8b1 100644
--- a/drivers/net/bna/bna_hw.h
+++ b/drivers/net/bna/bna_hw.h
@@ -99,6 +99,7 @@
 	(_bna)->bits.error_status_bits = (__HFN_INT_ERR_MASK);		\
 	(_bna)->bits.error_mask_bits = (__HFN_INT_ERR_MASK);		\
 	(_bna)->bits.halt_status_bits = __HFN_INT_LL_HALT;		\
+	(_bna)->bits.halt_mask_bits = __HFN_INT_LL_HALT;		\
 }
 
 #define ct2_reg_addr_init(_bna, _pcidev)				\
diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 6128045..68cd328 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -408,6 +408,7 @@ bnad_alloc_n_post_rxbufs(struct bnad *bnad, struct bna_rcb *rcb)
 						rcb->rxq->buffer_size);
 		if (unlikely(!skb)) {
 			BNAD_UPDATE_CTR(bnad, rxbuf_alloc_failed);
+			rcb->rxq->rxbuf_alloc_failed++;
 			goto finishing;
 		}
 		unmap_array[unmap_prod].skb = skb;
@@ -1913,6 +1914,7 @@ bnad_cleanup_rx(struct bnad *bnad, u32 rx_id)
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	rx_info->rx = NULL;
+	rx_info->rx_id = 0;
 
 	bnad_rx_res_free(bnad, res_info);
 }
@@ -1968,8 +1970,10 @@ bnad_setup_rx(struct bnad *bnad, u32 rx_id)
 	rx = bna_rx_create(&bnad->bna, bnad, rx_config, &rx_cbfn, res_info,
 			rx_info);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
-	if (!rx)
+	if (!rx) {
+		err = -ENOMEM;
 		goto err_return;
+	}
 	rx_info->rx = rx;
 
 	/*
@@ -2102,8 +2106,6 @@ bnad_restore_vlans(struct bnad *bnad, u32 rx_id)
 	if (!bnad->vlan_grp)
 		return;
 
-	BUG_ON(!(VLAN_N_VID == (BFI_ENET_VLAN_ID_MAX + 1)));
-
 	for (vlan_id = 0; vlan_id < VLAN_N_VID; vlan_id++) {
 		if (!vlan_group_get_device(bnad->vlan_grp, vlan_id))
 			continue;
@@ -2214,9 +2216,6 @@ bnad_tso_prepare(struct bnad *bnad, struct sk_buff *skb)
 {
 	int err;
 
-	/* SKB_GSO_TCPV4 and SKB_GSO_TCPV6 is defined since 2.6.18. */
-	BUG_ON(!(skb_shinfo(skb)->gso_type == SKB_GSO_TCPV4 ||
-		   skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6));
 	if (skb_header_cloned(skb)) {
 		err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
 		if (err) {
@@ -2243,7 +2242,6 @@ bnad_tso_prepare(struct bnad *bnad, struct sk_buff *skb)
 	} else {
 		struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 
-		BUG_ON(!(skb->protocol == htons(ETH_P_IPV6)));
 		ipv6h->payload_len = 0;
 		tcp_hdr(skb)->check =
 			~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr, 0,
@@ -2583,7 +2581,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	unmap_q = tcb->unmap_q;
 	/*
 	 * Takes care of the Tx that is scheduled between clearing the flag
-	 * and the netif_stop_all_queue() call.
+	 * and the netif_tx_stop_all_queues() call.
 	 */
 	BNAD_DROP_AND_RETURN_IF(!test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags),
 				tx_skb_stopping);
@@ -2631,7 +2629,6 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	txq_prod = tcb->producer_index;
 	BNA_TXQ_QPGE_PTR_GET(txq_prod, tcb->sw_qpt, txqent, wi_range);
-	BUG_ON(!(wi_range <= tcb->q_depth));
 	txqent->hdr.wi.reserved = 0;
 	txqent->hdr.wi.num_vectors = vectors;
 
@@ -2947,7 +2944,7 @@ unlock:
  * conf_lock cannot be used since this call may be made
  * in a non-blocking context.
  */
-static int
+int
 bnad_set_mac_address(struct net_device *netdev, void *mac_addr)
 {
 	int err;
@@ -3069,6 +3066,12 @@ bnad_netpoll(struct net_device *netdev)
 		bnad_isr(bnad->pcidev->irq, netdev);
 		bna_intx_enable(&bnad->bna, curr_mask);
 	} else {
+		/*
+		 * Tx processing may happen in sending context, so no need
+		 * to explicitly process completions here
+		 */
+
+		/* Rx processing */
 		for (i = 0; i < bnad->num_rx; i++) {
 			rx_info = &bnad->rx_info[i];
 			if (!rx_info->rx)
@@ -3262,7 +3265,7 @@ static int __devinit
 bnad_pci_probe(struct pci_dev *pdev,
 		const struct pci_device_id *pcidev_id)
 {
-	bool	using_dac = false;
+	bool	using_dac;
 	int	err;
 	struct bnad *bnad;
 	struct bna *bna;
@@ -3385,6 +3388,11 @@ bnad_pci_probe(struct pci_dev *pdev,
 			bna_num_rxp_set(bna, BNAD_NUM_RXP + 1))
 			err = -EIO;
 	}
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
+	if (err)
+		goto disable_ioceth;
+
+	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_mod_res_req(&bnad->bna, &bnad->mod_res_info[0]);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
@@ -3436,9 +3444,9 @@ drv_uninit:
 	bnad_uninit(bnad);
 pci_uninit:
 	bnad_pci_uninit(pdev);
+free_netdev:
 	mutex_unlock(&bnad->conf_mutex);
 	bnad_lock_uninit(bnad);
-free_netdev:
 	free_netdev(netdev);
 	return err;
 }
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index 1f9bb56..6e14257 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -153,7 +153,6 @@ struct bnad_drv_stats {
 	u64		tcpcsum_offload;
 	u64		udpcsum_offload;
 	u64		csum_help;
-	u64		csum_help_err;
 	u64		tx_skb_too_short;
 	u64		tx_skb_stopping;
 	u64		tx_skb_max_vectors;
@@ -170,13 +169,10 @@ struct bnad_drv_stats {
 	u64		tx_skb_len_mismatch;
 
 	u64		hw_stats_updates;
-	u64		netif_rx_schedule;
-	u64		netif_rx_complete;
 	u64		netif_rx_dropped;
 
 	u64		link_toggle;
 	u64		cee_toggle;
-	u64		cee_up;
 
 	u64		rxp_info_alloc_failed;
 	u64		mbox_intr_disabled;
@@ -323,6 +319,8 @@ struct bnad {
 
 	struct tasklet_struct	tx_free_tasklet;
 
+	u8			ref_count;
+
 	/* Statistics */
 	struct bnad_stats stats;
 
@@ -388,9 +386,12 @@ extern void bnad_netdev_hwstats_fill(struct bnad *bnad,
 	}							\
 }
 
-#define bnad_dim_timer_running(_bnad)				\
-	(((_bnad)->cfg_flags & BNAD_CF_DIM_ENABLED) &&		\
-	(test_bit(BNAD_RF_DIM_TIMER_RUNNING, &((_bnad)->run_flags))))
+/*
+ * Stops the DIM timer
+ * Called with bnad->bna_lock held
+ * Implemented as macro, since we want to use
+ * the correct flags(on stack) while unlocking.
+ */
 #define bnad_dim_timer_stop(_bnad, _flags)		\
 do {							\
 	int to_del = 0;					\
-- 
1.7.1

