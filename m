From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 3/4] bnxt_en: Call firmware to approve VF MAC address change.
Date: Mon, 11 Apr 2016 04:11:13 -0400
Message-ID: <1460362274-21771-4-git-send-email-michael.chan@broadcom.com>
References: <1460362274-21771-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:12225 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbcDKILS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 04:11:18 -0400
In-Reply-To: <1460362274-21771-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some hypervisors (e.g. ESX) require the VF MAC address to be forwarded to
the PF for approval.  In Linux PF, the call is not forwarded and the
firmware will simply check and approve the MAC address if the PF has not
previously administered a valid MAC address for this VF.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c       |  7 +++---
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c | 30 +++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h |  1 +
 3 files changed, 34 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index e874a56..c83a5a1 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5696,10 +5696,9 @@ static int bnxt_change_mac_addr(struct net_device *dev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-#ifdef CONFIG_BNXT_SRIOV
-	if (BNXT_VF(bp) && is_valid_ether_addr(bp->vf.mac_addr))
-		return -EADDRNOTAVAIL;
-#endif
+	rc = bnxt_approve_mac(bp, addr->sa_data);
+	if (rc)
+		return rc;
 
 	if (ether_addr_equal(addr->sa_data, dev->dev_addr))
 		return 0;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index 8457850..363884d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -865,6 +865,31 @@ update_vf_mac_exit:
 	mutex_unlock(&bp->hwrm_cmd_lock);
 }
 
+int bnxt_approve_mac(struct bnxt *bp, u8 *mac)
+{
+	struct hwrm_func_vf_cfg_input req = {0};
+	int rc = 0;
+
+	if (!BNXT_VF(bp))
+		return 0;
+
+	if (bp->hwrm_spec_code < 0x10202) {
+		if (is_valid_ether_addr(bp->vf.mac_addr))
+			rc = -EADDRNOTAVAIL;
+		goto mac_done;
+	}
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_VF_CFG, -1, -1);
+	req.enables = cpu_to_le32(FUNC_VF_CFG_REQ_ENABLES_DFLT_MAC_ADDR);
+	memcpy(req.dflt_mac_addr, mac, ETH_ALEN);
+	rc = hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+mac_done:
+	if (rc) {
+		rc = -EADDRNOTAVAIL;
+		netdev_warn(bp->dev, "VF MAC address %pM not approved by the PF\n",
+			    mac);
+	}
+	return rc;
+}
 #else
 
 void bnxt_sriov_disable(struct bnxt *bp)
@@ -879,4 +904,9 @@ void bnxt_hwrm_exec_fwd_req(struct bnxt *bp)
 void bnxt_update_vf_mac(struct bnxt *bp)
 {
 }
+
+int bnxt_approve_mac(struct bnxt *bp, u8 *mac)
+{
+	return 0;
+}
 #endif
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h
index 3f08354..0392670 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h
@@ -20,4 +20,5 @@ int bnxt_sriov_configure(struct pci_dev *pdev, int num_vfs);
 void bnxt_sriov_disable(struct bnxt *);
 void bnxt_hwrm_exec_fwd_req(struct bnxt *);
 void bnxt_update_vf_mac(struct bnxt *);
+int bnxt_approve_mac(struct bnxt *, u8 *);
 #endif
-- 
1.8.3.1
