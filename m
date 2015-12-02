From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH v2 net 2/3] bnxt_en: enforce proper storing of MAC address
Date: Wed, 2 Dec 2015 01:54:07 -0500
Message-ID: <1449039248-8745-3-git-send-email-mchan@broadcom.com>
References: <1449039248-8745-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jeffrey Huang <huangjw@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:33994 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756075AbbLBGyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 01:54:10 -0500
In-Reply-To: <1449039248-8745-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeffrey Huang <huangjw@broadcom.com>

For PF, the bp->pf.mac_addr always holds the permanent MAC
addr assigned by the HW.  For VF, the bp->vf.mac_addr always
holds the administrator assigned VF MAC addr. The random
generated VF MAC addr should never get stored to bp->vf.mac_addr.
This way, when the VF wants to change the MAC address, we can tell
if the adminstrator has already set it and disallow the VF from
changing it.

v2: Fix compile error if CONFIG_BNXT_SRIOV is not set.

Signed-off-by: Jeffrey Huang <huangjw@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c       | 20 +++++++++++++-------
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c |  7 +++----
 2 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 651b587..f0481dc 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3625,6 +3625,7 @@ static int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 		pf->fw_fid = le16_to_cpu(resp->fid);
 		pf->port_id = le16_to_cpu(resp->port_id);
 		memcpy(pf->mac_addr, resp->perm_mac_address, ETH_ALEN);
+		memcpy(bp->dev->dev_addr, pf->mac_addr, ETH_ALEN);
 		pf->max_rsscos_ctxs = le16_to_cpu(resp->max_rsscos_ctx);
 		pf->max_cp_rings = le16_to_cpu(resp->max_cmpl_rings);
 		pf->max_tx_rings = le16_to_cpu(resp->max_tx_rings);
@@ -3648,8 +3649,11 @@ static int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 
 		vf->fw_fid = le16_to_cpu(resp->fid);
 		memcpy(vf->mac_addr, resp->perm_mac_address, ETH_ALEN);
-		if (!is_valid_ether_addr(vf->mac_addr))
-			random_ether_addr(vf->mac_addr);
+		if (is_valid_ether_addr(vf->mac_addr))
+			/* overwrite netdev dev_adr with admin VF MAC */
+			memcpy(bp->dev->dev_addr, vf->mac_addr, ETH_ALEN);
+		else
+			random_ether_addr(bp->dev->dev_addr);
 
 		vf->max_rsscos_ctxs = le16_to_cpu(resp->max_rsscos_ctx);
 		vf->max_cp_rings = le16_to_cpu(resp->max_cmpl_rings);
@@ -5218,6 +5222,11 @@ static int bnxt_change_mac_addr(struct net_device *dev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
+#ifdef CONFIG_BNXT_SRIOV
+	if (BNXT_VF(bp) && is_valid_ether_addr(bp->vf.mac_addr))
+		return -EADDRNOTAVAIL;
+#endif
+
 	if (ether_addr_equal(addr->sa_data, dev->dev_addr))
 		return 0;
 
@@ -5695,15 +5704,12 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	bnxt_set_tpa_flags(bp);
 	bnxt_set_ring_params(bp);
 	dflt_rings = netif_get_num_default_rss_queues();
-	if (BNXT_PF(bp)) {
-		memcpy(dev->dev_addr, bp->pf.mac_addr, ETH_ALEN);
+	if (BNXT_PF(bp))
 		bp->pf.max_irqs = max_irqs;
-	} else {
 #if defined(CONFIG_BNXT_SRIOV)
-		memcpy(dev->dev_addr, bp->vf.mac_addr, ETH_ALEN);
+	else
 		bp->vf.max_irqs = max_irqs;
 #endif
-	}
 	bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings);
 	bp->rx_nr_rings = min_t(int, dflt_rings, max_rx_rings);
 	bp->tx_nr_rings_per_tc = min_t(int, dflt_rings, max_tx_rings);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index f4cf688..7a9af28 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -804,10 +804,9 @@ void bnxt_update_vf_mac(struct bnxt *bp)
 	if (!is_valid_ether_addr(resp->perm_mac_address))
 		goto update_vf_mac_exit;
 
-	if (ether_addr_equal(resp->perm_mac_address, bp->vf.mac_addr))
-		goto update_vf_mac_exit;
-
-	memcpy(bp->vf.mac_addr, resp->perm_mac_address, ETH_ALEN);
+	if (!ether_addr_equal(resp->perm_mac_address, bp->vf.mac_addr))
+		memcpy(bp->vf.mac_addr, resp->perm_mac_address, ETH_ALEN);
+	/* overwrite netdev dev_adr with admin VF MAC */
 	memcpy(bp->dev->dev_addr, bp->vf.mac_addr, ETH_ALEN);
 update_vf_mac_exit:
 	mutex_unlock(&bp->hwrm_cmd_lock);
-- 
1.8.3.1
