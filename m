From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 07/14] bnxt_en: Check maximum supported MTU from firmware.
Date: Thu, 26 Oct 2017 11:51:25 -0400
Message-ID: <1509033092-1887-8-git-send-email-michael.chan@broadcom.com>
References: <1509033092-1887-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:49574 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932435AbdJZPvy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:51:54 -0400
Received: by mail-qt0-f193.google.com with SMTP id k31so4869467qta.6
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 08:51:53 -0700 (PDT)
In-Reply-To: <1509033092-1887-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some NICs have a firmware enforced maximum MTU setting by management
firmware.  Set up netdev->max_mtu accordingly.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 17 +++++++++++------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  1 +
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index ef5a5e5..285863b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2835,7 +2835,8 @@ int bnxt_set_rx_skb_mode(struct bnxt *bp, bool page_mode)
 	if (page_mode) {
 		if (bp->dev->mtu > BNXT_MAX_PAGE_MODE_MTU)
 			return -EOPNOTSUPP;
-		bp->dev->max_mtu = BNXT_MAX_PAGE_MODE_MTU;
+		bp->dev->max_mtu =
+			min_t(u16, bp->max_mtu, BNXT_MAX_PAGE_MODE_MTU);
 		bp->flags &= ~BNXT_FLAG_AGG_RINGS;
 		bp->flags |= BNXT_FLAG_NO_AGG_RINGS | BNXT_FLAG_RX_PAGE_MODE;
 		bp->dev->hw_features &= ~NETIF_F_LRO;
@@ -2843,7 +2844,7 @@ int bnxt_set_rx_skb_mode(struct bnxt *bp, bool page_mode)
 		bp->rx_dir = DMA_BIDIRECTIONAL;
 		bp->rx_skb_func = bnxt_rx_page_skb;
 	} else {
-		bp->dev->max_mtu = BNXT_MAX_MTU;
+		bp->dev->max_mtu = bp->max_mtu;
 		bp->flags &= ~BNXT_FLAG_RX_PAGE_MODE;
 		bp->rx_dir = DMA_FROM_DEVICE;
 		bp->rx_skb_func = bnxt_rx_skb;
@@ -4732,6 +4733,10 @@ static int bnxt_hwrm_func_qcfg(struct bnxt *bp)
 	else
 		bp->br_mode = BRIDGE_MODE_UNDEF;
 
+	bp->max_mtu = le16_to_cpu(resp->max_mtu_configured);
+	if (!bp->max_mtu)
+		bp->max_mtu = BNXT_MAX_MTU;
+
 func_qcfg_exit:
 	mutex_unlock(&bp->hwrm_cmd_lock);
 	return rc;
@@ -8095,10 +8100,6 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->features |= dev->hw_features | NETIF_F_HIGHDMA;
 	dev->priv_flags |= IFF_UNICAST_FLT;
 
-	/* MTU range: 60 - 9500 */
-	dev->min_mtu = ETH_ZLEN;
-	dev->max_mtu = BNXT_MAX_MTU;
-
 #ifdef CONFIG_BNXT_SRIOV
 	init_waitqueue_head(&bp->sriov_cfg_wait);
 	mutex_init(&bp->sriov_lock);
@@ -8146,6 +8147,10 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	bnxt_ethtool_init(bp);
 	bnxt_dcb_init(bp);
 
+	/* MTU range: 60 - FW defined max */
+	dev->min_mtu = ETH_ZLEN;
+	dev->max_mtu = bp->max_mtu;
+
 	rc = bnxt_probe_phy(bp);
 	if (rc)
 		goto init_err_pci_clean;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index d193923..5f1fce4 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1172,6 +1172,7 @@ struct bnxt {
 	int			nr_vnics;
 	u32			rss_hash_cfg;
 
+	u16			max_mtu;
 	u8			max_tc;
 	u8			max_lltc;	/* lossless TCs */
 	struct bnxt_queue_info	q_info[BNXT_MAX_QUEUE];
-- 
1.8.3.1
