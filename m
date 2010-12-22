From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 07/10] bna: Removed unused code
Date: Tue, 21 Dec 2010 23:23:13 -0800
Message-ID: <1293002596-3239-8-git-send-email-rmody@brocade.com>
References: <1293002596-3239-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rasesh Mody <rmody@brocade.com>, Debashis Dutt <ddutt@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:37281 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752128Ab0LVHtC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 02:49:02 -0500
Received: from pps.filterd (m0000542 [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.14.4/8.14.4) with SMTP id oBM7MV7p004157
	for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 23:23:26 -0800
Received: from hq1-exedge.brocade.com (hq1-exedge.brocade.com [144.49.141.11])
	by mx0a-000f0801.pphosted.com with ESMTP id tb34v085b-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 23:23:25 -0800
In-Reply-To: <1293002596-3239-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
	- Remove unused APIs and code cleanup

Signed-off-by: Debashis Dutt <ddutt@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bna_ctrl.c  |  241 +------------------------------------------
 drivers/net/bna/bna_txrx.c  |   11 +--
 drivers/net/bna/bna_types.h |    4 +-
 3 files changed, 3 insertions(+), 253 deletions(-)

diff --git a/drivers/net/bna/bna_ctrl.c b/drivers/net/bna/bna_ctrl.c
index 68e4c5e..e152747 100644
--- a/drivers/net/bna/bna_ctrl.c
+++ b/drivers/net/bna/bna_ctrl.c
@@ -2132,37 +2132,6 @@ rxf_fltr_mbox_cmd(struct bna_rxf *rxf, u8 cmd, enum bna_status status)
 	bna_mbox_send(rxf->rx->bna, &rxf->mbox_qe);
 }
 
-static void
-__rxf_default_function_config(struct bna_rxf *rxf, enum bna_status status)
-{
-	struct bna_rx_fndb_ram *rx_fndb_ram;
-	u32 ctrl_flags;
-	int i;
-
-	rx_fndb_ram = (struct bna_rx_fndb_ram *)
-			BNA_GET_MEM_BASE_ADDR(rxf->rx->bna->pcidev.pci_bar_kva,
-			RX_FNDB_RAM_BASE_OFFSET);
-
-	for (i = 0; i < BFI_MAX_RXF; i++) {
-		if (status == BNA_STATUS_T_ENABLED) {
-			if (i == rxf->rxf_id)
-				continue;
-
-			ctrl_flags =
-				readl(&rx_fndb_ram[i].control_flags);
-			ctrl_flags |= BNA_RXF_CF_DEFAULT_FUNCTION_ENABLE;
-			writel(ctrl_flags,
-						&rx_fndb_ram[i].control_flags);
-		} else {
-			ctrl_flags =
-				readl(&rx_fndb_ram[i].control_flags);
-			ctrl_flags &= ~BNA_RXF_CF_DEFAULT_FUNCTION_ENABLE;
-			writel(ctrl_flags,
-						&rx_fndb_ram[i].control_flags);
-		}
-	}
-}
-
 int
 rxf_process_packet_filter_ucast(struct bna_rxf *rxf)
 {
@@ -2229,46 +2198,6 @@ rxf_process_packet_filter_promisc(struct bna_rxf *rxf)
 }
 
 int
-rxf_process_packet_filter_default(struct bna_rxf *rxf)
-{
-	struct bna *bna = rxf->rx->bna;
-
-	/* Enable/disable default mode */
-	if (is_default_enable(rxf->rxmode_pending,
-				rxf->rxmode_pending_bitmask)) {
-		/* move default configuration from pending -> active */
-		default_inactive(rxf->rxmode_pending,
-				rxf->rxmode_pending_bitmask);
-		rxf->rxmode_active |= BNA_RXMODE_DEFAULT;
-
-		/* Disable VLAN filter to allow all VLANs */
-		__rxf_vlan_filter_set(rxf, BNA_STATUS_T_DISABLED);
-		/* Redirect all other RxF vlan filtering to this one */
-		__rxf_default_function_config(rxf, BNA_STATUS_T_ENABLED);
-		rxf_fltr_mbox_cmd(rxf, BFI_LL_H2I_RXF_DEFAULT_SET_REQ,
-				BNA_STATUS_T_ENABLED);
-		return 1;
-	} else if (is_default_disable(rxf->rxmode_pending,
-				rxf->rxmode_pending_bitmask)) {
-		/* move default configuration from pending -> active */
-		default_inactive(rxf->rxmode_pending,
-				rxf->rxmode_pending_bitmask);
-		rxf->rxmode_active &= ~BNA_RXMODE_DEFAULT;
-		bna->rxf_default_id = BFI_MAX_RXF;
-
-		/* Revert VLAN filter */
-		__rxf_vlan_filter_set(rxf, rxf->vlan_filter_status);
-		/* Stop RxF vlan filter table redirection */
-		__rxf_default_function_config(rxf, BNA_STATUS_T_DISABLED);
-		rxf_fltr_mbox_cmd(rxf, BFI_LL_H2I_RXF_DEFAULT_SET_REQ,
-				BNA_STATUS_T_DISABLED);
-		return 1;
-	}
-
-	return 0;
-}
-
-int
 rxf_process_packet_filter_allmulti(struct bna_rxf *rxf)
 {
 	/* Enable/disable allmulti mode */
@@ -2365,48 +2294,6 @@ rxf_clear_packet_filter_promisc(struct bna_rxf *rxf)
 }
 
 int
-rxf_clear_packet_filter_default(struct bna_rxf *rxf)
-{
-	struct bna *bna = rxf->rx->bna;
-
-	/* 8. Execute pending default mode disable command */
-	if (is_default_disable(rxf->rxmode_pending,
-				rxf->rxmode_pending_bitmask)) {
-		/* move default configuration from pending -> active */
-		default_inactive(rxf->rxmode_pending,
-				rxf->rxmode_pending_bitmask);
-		rxf->rxmode_active &= ~BNA_RXMODE_DEFAULT;
-		bna->rxf_default_id = BFI_MAX_RXF;
-
-		/* Revert VLAN filter */
-		__rxf_vlan_filter_set(rxf, rxf->vlan_filter_status);
-		/* Stop RxF vlan filter table redirection */
-		__rxf_default_function_config(rxf, BNA_STATUS_T_DISABLED);
-		rxf_fltr_mbox_cmd(rxf, BFI_LL_H2I_RXF_DEFAULT_SET_REQ,
-				BNA_STATUS_T_DISABLED);
-		return 1;
-	}
-
-	/* 9. Clear active default mode; move it to pending enable */
-	if (rxf->rxmode_active & BNA_RXMODE_DEFAULT) {
-		/* move default configuration from active -> pending */
-		default_enable(rxf->rxmode_pending,
-				rxf->rxmode_pending_bitmask);
-		rxf->rxmode_active &= ~BNA_RXMODE_DEFAULT;
-
-		/* Revert VLAN filter */
-		__rxf_vlan_filter_set(rxf, rxf->vlan_filter_status);
-		/* Stop RxF vlan filter table redirection */
-		__rxf_default_function_config(rxf, BNA_STATUS_T_DISABLED);
-		rxf_fltr_mbox_cmd(rxf, BFI_LL_H2I_RXF_DEFAULT_SET_REQ,
-				BNA_STATUS_T_DISABLED);
-		return 1;
-	}
-
-	return 0;
-}
-
-int
 rxf_clear_packet_filter_allmulti(struct bna_rxf *rxf)
 {
 	/* 10. Execute pending allmulti mode disable command */
@@ -2481,28 +2368,6 @@ rxf_reset_packet_filter_promisc(struct bna_rxf *rxf)
 }
 
 void
-rxf_reset_packet_filter_default(struct bna_rxf *rxf)
-{
-	struct bna *bna = rxf->rx->bna;
-
-	/* 8. Clear pending default mode disable */
-	if (is_default_disable(rxf->rxmode_pending,
-				rxf->rxmode_pending_bitmask)) {
-		default_inactive(rxf->rxmode_pending,
-				rxf->rxmode_pending_bitmask);
-		rxf->rxmode_active &= ~BNA_RXMODE_DEFAULT;
-		bna->rxf_default_id = BFI_MAX_RXF;
-	}
-
-	/* 9. Move default mode config from active -> pending */
-	if (rxf->rxmode_active & BNA_RXMODE_DEFAULT) {
-		default_enable(rxf->rxmode_pending,
-				rxf->rxmode_pending_bitmask);
-		rxf->rxmode_active &= ~BNA_RXMODE_DEFAULT;
-	}
-}
-
-void
 rxf_reset_packet_filter_allmulti(struct bna_rxf *rxf)
 {
 	/* 10. Clear pending allmulti mode disable */
@@ -2599,76 +2464,6 @@ rxf_promisc_disable(struct bna_rxf *rxf)
  *	1 = need h/w change
  */
 static int
-rxf_default_enable(struct bna_rxf *rxf)
-{
-	struct bna *bna = rxf->rx->bna;
-	int ret = 0;
-
-	/* There can not be any pending disable command */
-
-	/* Do nothing if pending enable or already enabled */
-	if (is_default_enable(rxf->rxmode_pending,
-		rxf->rxmode_pending_bitmask) ||
-		(rxf->rxmode_active & BNA_RXMODE_DEFAULT)) {
-		/* Schedule enable */
-	} else {
-		/* Default mode should not be active in the system */
-		default_enable(rxf->rxmode_pending,
-				rxf->rxmode_pending_bitmask);
-		bna->rxf_default_id = rxf->rxf_id;
-		ret = 1;
-	}
-
-	return ret;
-}
-
-/**
- * Should only be called by bna_rxf_mode_set.
- * Helps deciding if h/w configuration is needed or not.
- *  Returns:
- *	0 = no h/w change
- *	1 = need h/w change
- */
-static int
-rxf_default_disable(struct bna_rxf *rxf)
-{
-	struct bna *bna = rxf->rx->bna;
-	int ret = 0;
-
-	/* There can not be any pending disable */
-
-	/* Turn off pending enable command , if any */
-	if (is_default_enable(rxf->rxmode_pending,
-				rxf->rxmode_pending_bitmask)) {
-		/* Promisc mode should not be active */
-		/* system default state should be pending */
-		default_inactive(rxf->rxmode_pending,
-				rxf->rxmode_pending_bitmask);
-		/* Remove the default state from the system */
-		bna->rxf_default_id = BFI_MAX_RXF;
-
-	/* Schedule disable */
-	} else if (rxf->rxmode_active & BNA_RXMODE_DEFAULT) {
-		/* Default mode should be active in the system */
-		default_disable(rxf->rxmode_pending,
-				rxf->rxmode_pending_bitmask);
-		ret = 1;
-
-	/* Do nothing if already disabled */
-	} else {
-	}
-
-	return ret;
-}
-
-/**
- * Should only be called by bna_rxf_mode_set.
- * Helps deciding if h/w configuration is needed or not.
- *  Returns:
- *	0 = no h/w change
- *	1 = need h/w change
- */
-static int
 rxf_allmulti_enable(struct bna_rxf *rxf)
 {
 	int ret = 0;
@@ -2730,38 +2525,13 @@ bna_rx_mode_set(struct bna_rx *rx, enum bna_rxmode new_mode,
 	struct bna_rxf *rxf = &rx->rxf;
 	int need_hw_config = 0;
 
-	/* Error checks */
+	/* Process the commands */
 
 	if (is_promisc_enable(new_mode, bitmask)) {
 		/* If promisc mode is already enabled elsewhere in the system */
 		if ((rx->bna->rxf_promisc_id != BFI_MAX_RXF) &&
 			(rx->bna->rxf_promisc_id != rxf->rxf_id))
 			goto err_return;
-
-		/* If default mode is already enabled in the system */
-		if (rx->bna->rxf_default_id != BFI_MAX_RXF)
-			goto err_return;
-
-		/* Trying to enable promiscuous and default mode together */
-		if (is_default_enable(new_mode, bitmask))
-			goto err_return;
-	}
-
-	if (is_default_enable(new_mode, bitmask)) {
-		/* If default mode is already enabled elsewhere in the system */
-		if ((rx->bna->rxf_default_id != BFI_MAX_RXF) &&
-			(rx->bna->rxf_default_id != rxf->rxf_id)) {
-				goto err_return;
-		}
-
-		/* If promiscuous mode is already enabled in the system */
-		if (rx->bna->rxf_promisc_id != BFI_MAX_RXF)
-			goto err_return;
-	}
-
-	/* Process the commands */
-
-	if (is_promisc_enable(new_mode, bitmask)) {
 		if (rxf_promisc_enable(rxf))
 			need_hw_config = 1;
 	} else if (is_promisc_disable(new_mode, bitmask)) {
@@ -2769,14 +2539,6 @@ bna_rx_mode_set(struct bna_rx *rx, enum bna_rxmode new_mode,
 			need_hw_config = 1;
 	}
 
-	if (is_default_enable(new_mode, bitmask)) {
-		if (rxf_default_enable(rxf))
-			need_hw_config = 1;
-	} else if (is_default_disable(new_mode, bitmask)) {
-		if (rxf_default_disable(rxf))
-			need_hw_config = 1;
-	}
-
 	if (is_allmulti_enable(new_mode, bitmask)) {
 		if (rxf_allmulti_enable(rxf))
 			need_hw_config = 1;
@@ -3202,7 +2964,6 @@ bna_init(struct bna *bna, struct bnad *bnad, struct bfa_pcidev *pcidev,
 
 	bna_mcam_mod_init(&bna->mcam_mod, bna, res_info);
 
-	bna->rxf_default_id = BFI_MAX_RXF;
 	bna->rxf_promisc_id = BFI_MAX_RXF;
 
 	/* Mbox q element for posting stat request to f/w */
diff --git a/drivers/net/bna/bna_txrx.c b/drivers/net/bna/bna_txrx.c
index 5076618..58c7664 100644
--- a/drivers/net/bna/bna_txrx.c
+++ b/drivers/net/bna/bna_txrx.c
@@ -1226,8 +1226,7 @@ rxf_process_packet_filter_vlan(struct bna_rxf *rxf)
 	/* Apply the VLAN filter */
 	if (rxf->rxf_flags & BNA_RXF_FL_VLAN_CONFIG_PENDING) {
 		rxf->rxf_flags &= ~BNA_RXF_FL_VLAN_CONFIG_PENDING;
-		if (!(rxf->rxmode_active & BNA_RXMODE_PROMISC) &&
-			!(rxf->rxmode_active & BNA_RXMODE_DEFAULT))
+		if (!(rxf->rxmode_active & BNA_RXMODE_PROMISC))
 			__rxf_vlan_filter_set(rxf, rxf->vlan_filter_status);
 	}
 
@@ -1276,9 +1275,6 @@ rxf_process_packet_filter(struct bna_rxf *rxf)
 	if (rxf_process_packet_filter_promisc(rxf))
 		return 1;
 
-	if (rxf_process_packet_filter_default(rxf))
-		return 1;
-
 	if (rxf_process_packet_filter_allmulti(rxf))
 		return 1;
 
@@ -1340,9 +1336,6 @@ rxf_clear_packet_filter(struct bna_rxf *rxf)
 	if (rxf_clear_packet_filter_promisc(rxf))
 		return 1;
 
-	if (rxf_clear_packet_filter_default(rxf))
-		return 1;
-
 	if (rxf_clear_packet_filter_allmulti(rxf))
 		return 1;
 
@@ -1389,8 +1382,6 @@ rxf_reset_packet_filter(struct bna_rxf *rxf)
 
 	rxf_reset_packet_filter_promisc(rxf);
 
-	rxf_reset_packet_filter_default(rxf);
-
 	rxf_reset_packet_filter_allmulti(rxf);
 }
 
diff --git a/drivers/net/bna/bna_types.h b/drivers/net/bna/bna_types.h
index d79fd98..b9c134f 100644
--- a/drivers/net/bna/bna_types.h
+++ b/drivers/net/bna/bna_types.h
@@ -165,8 +165,7 @@ enum bna_rxp_type {
 
 enum bna_rxmode {
 	BNA_RXMODE_PROMISC 	= 1,
-	BNA_RXMODE_DEFAULT 	= 2,
-	BNA_RXMODE_ALLMULTI 	= 4
+	BNA_RXMODE_ALLMULTI 	= 2
 };
 
 enum bna_rx_event {
@@ -1118,7 +1117,6 @@ struct bna {
 
 	struct bna_rit_mod rit_mod;
 
-	int			rxf_default_id;
 	int			rxf_promisc_id;
 
 	struct bna_mbox_qe mbox_qe;
-- 
1.7.1

