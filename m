From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 3/3] bnxt_en: Do not setup MAC address in bnxt_hwrm_func_qcaps().
Date: Wed, 23 Aug 2017 19:34:05 -0400
Message-ID: <1503531245-4046-4-git-send-email-michael.chan@broadcom.com>
References: <1503531245-4046-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:38121 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751146AbdHWXeX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 19:34:23 -0400
Received: by mail-qk0-f176.google.com with SMTP id k126so8603409qkb.5
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 16:34:23 -0700 (PDT)
In-Reply-To: <1503531245-4046-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnxt_hwrm_func_qcaps() is called during probe to get all device
resources and it also sets up the factory MAC address.  The same function
is called when SRIOV is disabled to reclaim all resources.  If
the MAC address has been overridden by a user administered MAC
address, calling this function will overwrite it.

Separate the logic that sets up the default MAC address into a new
function bnxt_init_mac_addr() that is only called during probe time.

Fixes: 4a21b49b34c0 ("bnxt_en: Improve VF resource accounting.")
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 40 +++++++++++++++++++++----------
 1 file changed, 28 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index f2f2bbf..f20b3d2 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4647,7 +4647,6 @@ static int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 		pf->port_id = le16_to_cpu(resp->port_id);
 		bp->dev->dev_port = pf->port_id;
 		memcpy(pf->mac_addr, resp->mac_address, ETH_ALEN);
-		memcpy(bp->dev->dev_addr, pf->mac_addr, ETH_ALEN);
 		pf->max_rsscos_ctxs = le16_to_cpu(resp->max_rsscos_ctx);
 		pf->max_cp_rings = le16_to_cpu(resp->max_cmpl_rings);
 		pf->max_tx_rings = le16_to_cpu(resp->max_tx_rings);
@@ -4687,16 +4686,6 @@ static int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 		vf->max_stat_ctxs = le16_to_cpu(resp->max_stat_ctx);
 
 		memcpy(vf->mac_addr, resp->mac_address, ETH_ALEN);
-		mutex_unlock(&bp->hwrm_cmd_lock);
-
-		if (is_valid_ether_addr(vf->mac_addr)) {
-			/* overwrite netdev dev_adr with admin VF MAC */
-			memcpy(bp->dev->dev_addr, vf->mac_addr, ETH_ALEN);
-		} else {
-			eth_hw_addr_random(bp->dev);
-			rc = bnxt_approve_mac(bp, bp->dev->dev_addr);
-		}
-		return rc;
 #endif
 	}
 
@@ -7662,6 +7651,28 @@ void bnxt_restore_pf_fw_resources(struct bnxt *bp)
 	bnxt_subtract_ulp_resources(bp, BNXT_ROCE_ULP);
 }
 
+static int bnxt_init_mac_addr(struct bnxt *bp)
+{
+	int rc = 0;
+
+	if (BNXT_PF(bp)) {
+		memcpy(bp->dev->dev_addr, bp->pf.mac_addr, ETH_ALEN);
+	} else {
+#ifdef CONFIG_BNXT_SRIOV
+		struct bnxt_vf_info *vf = &bp->vf;
+
+		if (is_valid_ether_addr(vf->mac_addr)) {
+			/* overwrite netdev dev_adr with admin VF MAC */
+			memcpy(bp->dev->dev_addr, vf->mac_addr, ETH_ALEN);
+		} else {
+			eth_hw_addr_random(bp->dev);
+			rc = bnxt_approve_mac(bp, bp->dev->dev_addr);
+		}
+#endif
+	}
+	return rc;
+}
+
 static void bnxt_parse_log_pcie_link(struct bnxt *bp)
 {
 	enum pcie_link_width width = PCIE_LNK_WIDTH_UNKNOWN;
@@ -7790,7 +7801,12 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		rc = -1;
 		goto init_err_pci_clean;
 	}
-
+	rc = bnxt_init_mac_addr(bp);
+	if (rc) {
+		dev_err(&pdev->dev, "Unable to initialize mac address.\n");
+		rc = -EADDRNOTAVAIL;
+		goto init_err_pci_clean;
+	}
 	rc = bnxt_hwrm_queue_qportcfg(bp);
 	if (rc) {
 		netdev_err(bp->dev, "hwrm query qportcfg failure rc: %x\n",
-- 
1.8.3.1
