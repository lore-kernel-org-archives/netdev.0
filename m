From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 07/11] bnxt_en: Reduce default rings on multi-port cards.
Date: Mon, 28 Aug 2017 13:40:31 -0400
Message-ID: <1503942035-24924-8-git-send-email-michael.chan@broadcom.com>
References: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:36285 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751478AbdH1Rk6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 13:40:58 -0400
Received: by mail-qt0-f181.google.com with SMTP id v29so5266207qtv.3
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 10:40:57 -0700 (PDT)
In-Reply-To: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce default rings from 8 to 4 on multi-port cards to reduce memory
usage.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 13 +++++++++----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  1 +
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index a34fcdd..4406f91 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5795,6 +5795,8 @@ static int bnxt_hwrm_phy_qcaps(struct bnxt *bp)
 		link_info->support_auto_speeds =
 			le16_to_cpu(resp->supported_speeds_auto_mode);
 
+	bp->port_count = resp->port_cnt;
+
 hwrm_phy_qcaps_exit:
 	mutex_unlock(&bp->hwrm_cmd_lock);
 	return rc;
@@ -7877,6 +7879,9 @@ static int bnxt_set_dflt_rings(struct bnxt *bp, bool sh)
 	if (sh)
 		bp->flags |= BNXT_FLAG_SHARED_RINGS;
 	dflt_rings = netif_get_num_default_rss_queues();
+	/* Reduce default rings to reduce memory usage on multi-port cards */
+	if (bp->port_count > 1)
+		dflt_rings = min_t(int, dflt_rings, 4);
 	rc = bnxt_get_dflt_rings(bp, &max_rx_rings, &max_tx_rings, sh);
 	if (rc)
 		return rc;
@@ -8049,6 +8054,10 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	bnxt_ethtool_init(bp);
 	bnxt_dcb_init(bp);
 
+	rc = bnxt_probe_phy(bp);
+	if (rc)
+		goto init_err_pci_clean;
+
 	bnxt_set_rx_skb_mode(bp, false);
 	bnxt_set_tpa_flags(bp);
 	bnxt_set_ring_params(bp);
@@ -8083,10 +8092,6 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (dev->hw_features & NETIF_F_HW_VLAN_CTAG_RX)
 		bp->flags |= BNXT_FLAG_STRIP_VLAN;
 
-	rc = bnxt_probe_phy(bp);
-	if (rc)
-		goto init_err_pci_clean;
-
 	rc = bnxt_init_int_mode(bp);
 	if (rc)
 		goto init_err_pci_clean;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 3521e46..86af8ea 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1207,6 +1207,7 @@ struct bnxt {
 	u8			nge_port_cnt;
 	__le16			nge_fw_dst_port_id;
 	u8			port_partition_type;
+	u8			port_count;
 	u16			br_mode;
 
 	u16			rx_coal_ticks;
-- 
1.8.3.1
