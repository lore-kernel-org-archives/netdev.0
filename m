From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 01/12] bna: Naming Change and Minor Macro Fix
Date: Mon, 22 Aug 2011 15:40:58 -0700
Message-ID: <1314052869-7407-2-git-send-email-rmody@brocade.com>
References: <1314052869-7407-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:55621 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753957Ab1HVWlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 18:41:39 -0400
In-Reply-To: <1314052869-7407-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Naming changes: rename devid, BNAD_MAX_TXS, BNAD_MAX_RXS,
BNAD_MAX_RXPS_PER_RX to device, BNAD_MAX_TX, BNAD_MAX_RX,
BNAD_MAX_RXP_PER_RX respectively and change all the references.

Macro Fix: Add ioc_isr_mod_set check to bfa_nw_ioc_mbox_regisr macro

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bfa_defs.h |    8 ++++----
 drivers/net/ethernet/brocade/bna/bfa_ioc.h  |    6 ++++--
 drivers/net/ethernet/brocade/bna/bnad.c     |    6 +++---
 drivers/net/ethernet/brocade/bna/bnad.h     |   20 ++++++++++----------
 4 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs.h b/drivers/net/ethernet/brocade/bna/bfa_defs.h
index 205b92b..a81c0cc 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs.h
@@ -251,10 +251,10 @@ struct bfa_mfg_block {
  * ---------------------- pci definitions ------------
  */
 
-#define bfa_asic_id_ct(devid)			\
-	((devid) == PCI_DEVICE_ID_BROCADE_CT ||	\
-	(devid) == PCI_DEVICE_ID_BROCADE_CT_FC)
-#define bfa_asic_id_ctc(devid) (bfa_asic_id_ct(devid))
+#define bfa_asic_id_ct(device)			\
+	((device) == PCI_DEVICE_ID_BROCADE_CT ||	\
+	 (device) == PCI_DEVICE_ID_BROCADE_CT_FC)
+#define bfa_asic_id_ctc(device) (bfa_asic_id_ct(device))
 
 enum bfa_mode {
 	BFA_MODE_HBA		= 1,
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.h b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
index f5a3d4e..9116324 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
@@ -274,8 +274,10 @@ void bfa_nw_ioc_mbox_regisr(struct bfa_ioc *ioc, enum bfi_mclass mc,
 	((__ioc)->ioc_hwif->ioc_pll_init((__ioc)->pcidev.pci_bar_kva, \
 			   (__ioc)->asic_mode))
 
-#define	bfa_ioc_isr_mode_set(__ioc, __msix)			\
-			((__ioc)->ioc_hwif->ioc_isr_mode_set(__ioc, __msix))
+#define	bfa_ioc_isr_mode_set(__ioc, __msix) do {			\
+	if ((__ioc)->ioc_hwif->ioc_isr_mode_set)			\
+		((__ioc)->ioc_hwif->ioc_isr_mode_set(__ioc, __msix));	\
+} while (0)
 #define	bfa_ioc_ownership_reset(__ioc)				\
 			((__ioc)->ioc_hwif->ioc_ownership_reset(__ioc))
 
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index bdfda07..d18ffb3 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -1001,7 +1001,7 @@ bnad_cb_rx_cleanup(struct bnad *bnad, struct bna_rx *rx)
 
 	mdelay(BNAD_TXRX_SYNC_MDELAY);
 
-	for (i = 0; i < BNAD_MAX_RXPS_PER_RX; i++) {
+	for (i = 0; i < BNAD_MAX_RXP_PER_RX; i++) {
 		rx_ctrl = &rx_info->rx_ctrl[i];
 		ccb = rx_ctrl->ccb;
 		if (!ccb)
@@ -1030,7 +1030,7 @@ bnad_cb_rx_post(struct bnad *bnad, struct bna_rx *rx)
 	int i;
 	int j;
 
-	for (i = 0; i < BNAD_MAX_RXPS_PER_RX; i++) {
+	for (i = 0; i < BNAD_MAX_RXP_PER_RX; i++) {
 		rx_ctrl = &rx_info->rx_ctrl[i];
 		ccb = rx_ctrl->ccb;
 		if (!ccb)
@@ -2227,7 +2227,7 @@ bnad_q_num_init(struct bnad *bnad)
 	int rxps;
 
 	rxps = min((uint)num_online_cpus(),
-			(uint)(BNAD_MAX_RXS * BNAD_MAX_RXPS_PER_RX));
+			(uint)(BNAD_MAX_RX * BNAD_MAX_RXP_PER_RX));
 
 	if (!(bnad->cfg_flags & BNAD_CF_MSIX))
 		rxps = 1;	/* INTx */
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index 5b5451e..3c23139 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -38,12 +38,12 @@
 #define BNAD_TXQ_DEPTH		2048
 #define BNAD_RXQ_DEPTH		2048
 
-#define BNAD_MAX_TXS		1
+#define BNAD_MAX_TX		1
 #define BNAD_MAX_TXQ_PER_TX	8	/* 8 priority queues */
 #define BNAD_TXQ_NUM		1
 
-#define BNAD_MAX_RXS		1
-#define BNAD_MAX_RXPS_PER_RX	16
+#define BNAD_MAX_RX		1
+#define BNAD_MAX_RXP_PER_RX	16
 #define BNAD_MAX_RXQ_PER_RXP	2
 
 /*
@@ -190,7 +190,7 @@ struct bnad_tx_info {
 struct bnad_rx_info {
 	struct bna_rx *rx; /* 1:1 between rx_info & rx */
 
-	struct bnad_rx_ctrl rx_ctrl[BNAD_MAX_RXPS_PER_RX];
+	struct bnad_rx_ctrl rx_ctrl[BNAD_MAX_RXP_PER_RX];
 	u32 rx_id;
 } ____cacheline_aligned;
 
@@ -234,8 +234,8 @@ struct bnad {
 	struct net_device	*netdev;
 
 	/* Data path */
-	struct bnad_tx_info tx_info[BNAD_MAX_TXS];
-	struct bnad_rx_info rx_info[BNAD_MAX_RXS];
+	struct bnad_tx_info tx_info[BNAD_MAX_TX];
+	struct bnad_rx_info rx_info[BNAD_MAX_RX];
 
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	/*
@@ -255,8 +255,8 @@ struct bnad {
 	u8			tx_coalescing_timeo;
 	u8			rx_coalescing_timeo;
 
-	struct bna_rx_config rx_config[BNAD_MAX_RXS];
-	struct bna_tx_config tx_config[BNAD_MAX_TXS];
+	struct bna_rx_config rx_config[BNAD_MAX_RX];
+	struct bna_tx_config tx_config[BNAD_MAX_TX];
 
 	void __iomem		*bar0;	/* BAR0 address */
 
@@ -283,8 +283,8 @@ struct bnad {
 	/* Control path resources, memory & irq */
 	struct bna_res_info res_info[BNA_RES_T_MAX];
 	struct bna_res_info mod_res_info[BNA_MOD_RES_T_MAX];
-	struct bnad_tx_res_info tx_res_info[BNAD_MAX_TXS];
-	struct bnad_rx_res_info rx_res_info[BNAD_MAX_RXS];
+	struct bnad_tx_res_info tx_res_info[BNAD_MAX_TX];
+	struct bnad_rx_res_info rx_res_info[BNAD_MAX_RX];
 
 	struct bnad_completion bnad_completions;
 
-- 
1.7.1

