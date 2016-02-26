From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 01/10] bnxt_en: Improve bnxt_vf_update_mac().
Date: Fri, 26 Feb 2016 03:59:59 -0500
Message-ID: <1456477208-30692-2-git-send-email-michael.chan@broadcom.com>
References: <1456477208-30692-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:36528
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750754AbcBZJAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 04:00:47 -0500
In-Reply-To: <1456477208-30692-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeffrey Huang <huangjw@broadcom.com>

Allow the VF to setup its own MAC address if the PF has not administratively
set it for the VF.  To do that, we should always store the MAC address
from the firmware.  There are 2 cases:

1. The MAC address is valid.  This MAC address is assigned by the PF and
it needs to override the current VF MAC address.

2. The MAC address is zero.  The VF will use a random MAC address by default.
By storing this 0 MAC address in the VF structure, it will allow the VF
user to change the MAC address later using ndo_set_mac_address() when
it sees that the stored MAC address is 0.

v2: Expanded descriptions and added more comments.

Signed-off-by: Jeffrey Huang <huangjw@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index c1cc83d..0b4ca35 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -809,13 +809,19 @@ void bnxt_update_vf_mac(struct bnxt *bp)
 	if (_hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT))
 		goto update_vf_mac_exit;
 
-	if (!is_valid_ether_addr(resp->perm_mac_address))
-		goto update_vf_mac_exit;
-
+	/* Store MAC address from the firmware.  There are 2 cases:
+	 * 1. MAC address is valid.  It is assigned from the PF and we
+	 *    need to override the current VF MAC address with it.
+	 * 2. MAC address is zero.  The VF will use a random MAC address by
+	 *    default but the stored zero MAC will allow the VF user to change
+	 *    the random MAC address using ndo_set_mac_address() if he wants.
+	 */
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
