From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net v2 3/9] bnx2x: Unlock VF-PF channel on MAC/VLAN
 config error
Date: Sun, 20 Oct 2013 16:51:28 +0200
Message-ID: <1382280694-8428-4-git-send-email-yuvalmin@broadcom.com>
References: <1382280694-8428-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2637 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751103Ab3JTOvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 10:51:54 -0400
In-Reply-To: <1382280694-8428-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

Current code returns upon failure, leaving the VF-PF in an unusable state;
This patch adds the missing release so further commands could pass between
PF and VF.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 9ad012b..997c661 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -3390,14 +3390,16 @@ int bnx2x_set_vf_mac(struct net_device *dev, int vfidx, u8 *mac)
 		rc = bnx2x_del_all_macs(bp, mac_obj, BNX2X_ETH_MAC, true);
 		if (rc) {
 			BNX2X_ERR("failed to delete eth macs\n");
-			return -EINVAL;
+			rc = -EINVAL;
+			goto out;
 		}
 
 		/* remove existing uc list macs */
 		rc = bnx2x_del_all_macs(bp, mac_obj, BNX2X_UC_LIST_MAC, true);
 		if (rc) {
 			BNX2X_ERR("failed to delete uc_list macs\n");
-			return -EINVAL;
+			rc = -EINVAL;
+			goto out;
 		}
 
 		/* configure the new mac to device */
@@ -3405,6 +3407,7 @@ int bnx2x_set_vf_mac(struct net_device *dev, int vfidx, u8 *mac)
 		bnx2x_set_mac_one(bp, (u8 *)&bulletin->mac, mac_obj, true,
 				  BNX2X_ETH_MAC, &ramrod_flags);
 
+out:
 		bnx2x_unlock_vf_pf_channel(bp, vf, CHANNEL_TLV_PF_SET_MAC);
 	}
 
@@ -3467,7 +3470,8 @@ int bnx2x_set_vf_vlan(struct net_device *dev, int vfidx, u16 vlan, u8 qos)
 					  &ramrod_flags);
 		if (rc) {
 			BNX2X_ERR("failed to delete vlans\n");
-			return -EINVAL;
+			rc = -EINVAL;
+			goto out;
 		}
 
 		/* send queue update ramrod to configure default vlan and silent
@@ -3501,7 +3505,8 @@ int bnx2x_set_vf_vlan(struct net_device *dev, int vfidx, u16 vlan, u8 qos)
 			rc = bnx2x_config_vlan_mac(bp, &ramrod_param);
 			if (rc) {
 				BNX2X_ERR("failed to configure vlan\n");
-				return -EINVAL;
+				rc =  -EINVAL;
+				goto out;
 			}
 
 			/* configure default vlan to vf queue and set silent
@@ -3519,18 +3524,18 @@ int bnx2x_set_vf_vlan(struct net_device *dev, int vfidx, u16 vlan, u8 qos)
 		rc = bnx2x_queue_state_change(bp, &q_params);
 		if (rc) {
 			BNX2X_ERR("Failed to configure default VLAN\n");
-			return rc;
+			goto out;
 		}
 
 		/* clear the flag indicating that this VF needs its vlan
-		 * (will only be set if the HV configured th Vlan before vf was
-		 * and we were called because the VF came up later
+		 * (will only be set if the HV configured the Vlan before vf was
+		 * up and we were called because the VF came up later
 		 */
+out:
 		vf->cfg_flags &= ~VF_CFG_VLAN;
-
 		bnx2x_unlock_vf_pf_channel(bp, vf, CHANNEL_TLV_PF_SET_VLAN);
 	}
-	return 0;
+	return rc;
 }
 
 /* crc is the first field in the bulletin board. Compute the crc over the
-- 
1.8.1.227.g44fe835
