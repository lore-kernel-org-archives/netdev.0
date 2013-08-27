From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 3/5] bnx2x: Fix functionality of configuring vlan
 list
Date: Wed, 28 Aug 2013 01:13:02 +0300
Message-ID: <1377641584-2939-4-git-send-email-yuvalmin@broadcom.com>
References: <1377641584-2939-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2543 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753893Ab3H0WNU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 18:13:20 -0400
In-Reply-To: <1377641584-2939-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

The check on return code of bnx2x_vfop_config_vlan0() would lead to error
handling flow as the return value indicating an existing pending ramrod would
be erroneously considered as an error.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 37 ++---------------------
 1 file changed, 2 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index ad83f4b..b7efe27 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -522,23 +522,6 @@ static int bnx2x_vfop_set_user_req(struct bnx2x *bp,
 	return 0;
 }
 
-static int
-bnx2x_vfop_config_vlan0(struct bnx2x *bp,
-			struct bnx2x_vlan_mac_ramrod_params *vlan_mac,
-			bool add)
-{
-	int rc;
-
-	vlan_mac->user_req.cmd = add ? BNX2X_VLAN_MAC_ADD :
-		BNX2X_VLAN_MAC_DEL;
-	vlan_mac->user_req.u.vlan.vlan = 0;
-
-	rc = bnx2x_config_vlan_mac(bp, vlan_mac);
-	if (rc == -EEXIST)
-		rc = 0;
-	return rc;
-}
-
 static int bnx2x_vfop_config_list(struct bnx2x *bp,
 				  struct bnx2x_vfop_filters *filters,
 				  struct bnx2x_vlan_mac_ramrod_params *vlan_mac)
@@ -643,30 +626,14 @@ static void bnx2x_vfop_vlan_mac(struct bnx2x *bp, struct bnx2x_virtf *vf)
 
 	case BNX2X_VFOP_VLAN_CONFIG_LIST:
 		/* next state */
-		vfop->state = BNX2X_VFOP_VLAN_CONFIG_LIST_0;
-
-		/* remove vlan0 - could be no-op */
-		vfop->rc = bnx2x_vfop_config_vlan0(bp, vlan_mac, false);
-		if (vfop->rc)
-			goto op_err;
+		vfop->state = BNX2X_VFOP_VLAN_MAC_CHK_DONE;
 
-		/* Do vlan list config. if this operation fails we try to
-		 * restore vlan0 to keep the queue is working order
-		 */
+		/* do list config */
 		vfop->rc = bnx2x_vfop_config_list(bp, filters, vlan_mac);
 		if (!vfop->rc) {
 			set_bit(RAMROD_CONT, &vlan_mac->ramrod_flags);
 			vfop->rc = bnx2x_config_vlan_mac(bp, vlan_mac);
 		}
-		bnx2x_vfop_finalize(vf, vfop->rc, VFOP_CONT); /* fall-through */
-
-	case BNX2X_VFOP_VLAN_CONFIG_LIST_0:
-		/* next state */
-		vfop->state = BNX2X_VFOP_VLAN_MAC_CHK_DONE;
-
-		if (list_empty(&obj->head))
-			/* add vlan0 */
-			vfop->rc = bnx2x_vfop_config_vlan0(bp, vlan_mac, true);
 		bnx2x_vfop_finalize(vf, vfop->rc, VFOP_DONE);
 
 	default:
-- 
1.8.1.227.g44fe835
