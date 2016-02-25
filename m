From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 01/10] bnxt_en: Improve bnxt_vf_update_mac().
Date: Thu, 25 Feb 2016 03:19:25 -0500
Message-ID: <1456388374-1440-2-git-send-email-michael.chan@broadcom.com>
References: <1456388374-1440-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:48869
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758782AbcBYITf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 03:19:35 -0500
In-Reply-To: <1456388374-1440-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeffrey Huang <huangjw@broadcom.com>

Allow the VF to setup its own MAC address if the PF has not administratively
set it for the VF.  If the perm_mac_address returned by firmware is all
zeros, that means the PF has not set up the MAC address for the VF and
we should store it.  This will allow the VF to change the MAC address using
ndo_set_mac_address() when it sees that the stored permanent MAC address
is all zeros.

Signed-off-by: Jeffrey Huang <huangjw@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index c1cc83d..bb2b376 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -809,13 +809,12 @@ void bnxt_update_vf_mac(struct bnxt *bp)
 	if (_hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT))
 		goto update_vf_mac_exit;
 
-	if (!is_valid_ether_addr(resp->perm_mac_address))
-		goto update_vf_mac_exit;
-
 	if (!ether_addr_equal(resp->perm_mac_address, bp->vf.mac_addr))
 		memcpy(bp->vf.mac_addr, resp->perm_mac_address, ETH_ALEN);
-	/* overwrite netdev dev_adr with admin VF MAC */
-	memcpy(bp->dev->dev_addr, bp->vf.mac_addr, ETH_ALEN);
+
+	/* overwrite netdev dev_addr with admin VF MAC */
+	if (is_valid_ether_addr(bp->vf.mac_addr))
+		memcpy(bp->dev->dev_addr, bp->vf.mac_addr, ETH_ALEN);
 update_vf_mac_exit:
 	mutex_unlock(&bp->hwrm_cmd_lock);
 }
-- 
1.8.3.1
