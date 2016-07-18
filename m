From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 1/6] bnxt_en: Add basic support for Nitro in North Star 2.
Date: Mon, 18 Jul 2016 07:15:20 -0400
Message-ID: <1468840525-340-2-git-send-email-michael.chan@broadcom.com>
References: <1468840525-340-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:35813 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747AbcGRLPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 07:15:36 -0400
Received: by mail-oi0-f52.google.com with SMTP id l72so101066985oig.2
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 04:15:36 -0700 (PDT)
In-Reply-To: <1468840525-340-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prashant Sreedharan <prashant.sreedharan@broadcom.com>

Nitro is the embedded version of the ethernet controller in the North
Star 2 SoC.  Add basic code to recognize the chip ID and disable
the features (ntuple, TPA, ring and port statistics) not supported on
Nitro A0.

Signed-off-by: Prashant Sreedharan <prashant.sreedharan@broadcom.com>
Signed-off-by: Vasundhara Volam <vasundhara-v.volam@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 38 ++++++++++++++++++++-----------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  3 +++
 2 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 659faa6..4970e72 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2661,7 +2661,7 @@ static int bnxt_alloc_stats(struct bnxt *bp)
 		cpr->hw_stats_ctx_id = INVALID_STATS_CTX_ID;
 	}
 
-	if (BNXT_PF(bp)) {
+	if (BNXT_PF(bp) && bp->chip_num != CHIP_NUM_58700) {
 		bp->hw_port_stats_size = sizeof(struct rx_port_stats) +
 					 sizeof(struct tx_port_stats) + 1024;
 
@@ -3922,6 +3922,9 @@ static int bnxt_hwrm_stat_ctx_free(struct bnxt *bp)
 	if (!bp->bnapi)
 		return 0;
 
+	if (BNXT_CHIP_TYPE_NITRO_A0(bp))
+		return 0;
+
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_STAT_CTX_FREE, -1, -1);
 
 	mutex_lock(&bp->hwrm_cmd_lock);
@@ -3950,6 +3953,9 @@ static int bnxt_hwrm_stat_ctx_alloc(struct bnxt *bp)
 	struct hwrm_stat_ctx_alloc_input req = {0};
 	struct hwrm_stat_ctx_alloc_output *resp = bp->hwrm_cmd_resp_addr;
 
+	if (BNXT_CHIP_TYPE_NITRO_A0(bp))
+		return 0;
+
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_STAT_CTX_ALLOC, -1, -1);
 
 	req.update_period_ms = cpu_to_le32(bp->stats_coal_ticks / 1000);
@@ -4163,6 +4169,9 @@ static int bnxt_hwrm_ver_get(struct bnxt *bp)
 		bp->hwrm_max_req_len = le16_to_cpu(resp->max_req_win_len);
 
 	bp->chip_num = le16_to_cpu(resp->chip_num);
+	if (bp->chip_num == CHIP_NUM_58700 && !resp->chip_rev &&
+	    !resp->chip_metal)
+		bp->flags |= BNXT_FLAG_CHIP_NITRO_A0;
 
 hwrm_ver_get_exit:
 	mutex_unlock(&bp->hwrm_cmd_lock);
@@ -5681,7 +5690,7 @@ static int bnxt_set_features(struct net_device *dev, netdev_features_t features)
 	bool update_tpa = false;
 
 	flags &= ~BNXT_FLAG_ALL_CONFIG_FEATS;
-	if ((features & NETIF_F_GRO) && (bp->pdev->revision > 0))
+	if ((features & NETIF_F_GRO) && !BNXT_CHIP_TYPE_NITRO_A0(bp))
 		flags |= BNXT_FLAG_GRO;
 	if (features & NETIF_F_LRO)
 		flags |= BNXT_FLAG_LRO;
@@ -6576,13 +6585,25 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, dev);
 
+	rc = bnxt_alloc_hwrm_resources(bp);
+	if (rc)
+		goto init_err;
+
+	mutex_init(&bp->hwrm_cmd_lock);
+	rc = bnxt_hwrm_ver_get(bp);
+	if (rc)
+		goto init_err;
+
 	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
 			   NETIF_F_TSO | NETIF_F_TSO6 |
 			   NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_GRE |
 			   NETIF_F_GSO_IPXIP4 |
 			   NETIF_F_GSO_UDP_TUNNEL_CSUM | NETIF_F_GSO_GRE_CSUM |
 			   NETIF_F_GSO_PARTIAL | NETIF_F_RXHASH |
-			   NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_GRO;
+			   NETIF_F_RXCSUM | NETIF_F_GRO;
+
+	if (!BNXT_CHIP_TYPE_NITRO_A0(bp))
+		dev->hw_features |= NETIF_F_LRO;
 
 	dev->hw_enc_features =
 			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
@@ -6601,15 +6622,6 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 #ifdef CONFIG_BNXT_SRIOV
 	init_waitqueue_head(&bp->sriov_cfg_wait);
 #endif
-	rc = bnxt_alloc_hwrm_resources(bp);
-	if (rc)
-		goto init_err;
-
-	mutex_init(&bp->hwrm_cmd_lock);
-	rc = bnxt_hwrm_ver_get(bp);
-	if (rc)
-		goto init_err;
-
 	bp->gro_func = bnxt_gro_func_5730x;
 	if (BNXT_CHIP_NUM_57X1X(bp->chip_num))
 		bp->gro_func = bnxt_gro_func_5731x;
@@ -6647,7 +6659,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 #endif
 	bnxt_set_dflt_rings(bp);
 
-	if (BNXT_PF(bp)) {
+	if (BNXT_PF(bp) && !BNXT_CHIP_TYPE_NITRO_A0(bp)) {
 		dev->hw_features |= NETIF_F_NTUPLE;
 		if (bnxt_rfs_capable(bp)) {
 			bp->flags |= BNXT_FLAG_RFS;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 2313e37..e667150 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -893,6 +893,7 @@ struct bnxt {
 #define CHIP_NUM_57301		0x16c8
 #define CHIP_NUM_57302		0x16c9
 #define CHIP_NUM_57304		0x16ca
+#define CHIP_NUM_58700		0x16cd
 #define CHIP_NUM_57402		0x16d0
 #define CHIP_NUM_57404		0x16d1
 #define CHIP_NUM_57406		0x16d2
@@ -954,6 +955,7 @@ struct bnxt {
 	#define BNXT_FLAG_SHARED_RINGS	0x200
 	#define BNXT_FLAG_PORT_STATS	0x400
 	#define BNXT_FLAG_EEE_CAP	0x1000
+	#define BNXT_FLAG_CHIP_NITRO_A0	0x1000000
 
 	#define BNXT_FLAG_ALL_CONFIG_FEATS (BNXT_FLAG_TPA |		\
 					    BNXT_FLAG_RFS |		\
@@ -963,6 +965,7 @@ struct bnxt {
 #define BNXT_VF(bp)		((bp)->flags & BNXT_FLAG_VF)
 #define BNXT_NPAR(bp)		((bp)->port_partition_type)
 #define BNXT_SINGLE_PF(bp)	(BNXT_PF(bp) && !BNXT_NPAR(bp))
+#define BNXT_CHIP_TYPE_NITRO_A0(bp) ((bp)->flags & BNXT_FLAG_CHIP_NITRO_A0)
 
 	struct bnxt_napi	**bnapi;
 
-- 
1.8.3.1
