From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [net-next PATCH 1/4] be2net: clear vlan-promisc setting before programming the vlan list
Date: Fri, 22 Jul 2016 06:55:43 -0400
Message-ID: <1469184946-26309-2-git-send-email-sathya.perla@broadcom.com>
References: <1469184946-26309-1-git-send-email-sathya.perla@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:20969 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753807AbcGVK4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 06:56:05 -0400
In-Reply-To: <1469184946-26309-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>

The Lancer FW has a bug due to which in some cases vlan-promisc setting
is cleared eventhough the vlan-list programming did not succeed (via
VLAN_CONFIG) cmd. The driver has no way of knowing if the vlan-promisc
mode was cleared or not when this cmd fails. To work around this issue,
this patch first explicitly clears the vlan-promisc mode via RX_FILTER
cmd and then tries to program the vlan list.
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 1f16e73..2782299 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1427,6 +1427,11 @@ static int be_vid_config(struct be_adapter *adapter)
 	if (adapter->vlans_added > be_max_vlans(adapter))
 		return be_set_vlan_promisc(adapter);
 
+	if (adapter->if_flags & BE_IF_FLAGS_VLAN_PROMISCUOUS) {
+		status = be_clear_vlan_promisc(adapter);
+		if (status)
+			return status;
+	}
 	/* Construct VLAN Table to give to HW */
 	for_each_set_bit(i, adapter->vids, VLAN_N_VID)
 		vids[num++] = cpu_to_le16(i);
@@ -1439,8 +1444,6 @@ static int be_vid_config(struct be_adapter *adapter)
 		    addl_status(status) ==
 				MCC_ADDL_STATUS_INSUFFICIENT_RESOURCES)
 			return be_set_vlan_promisc(adapter);
-	} else if (adapter->if_flags & BE_IF_FLAGS_VLAN_PROMISCUOUS) {
-		status = be_clear_vlan_promisc(adapter);
 	}
 	return status;
 }
-- 
2.4.1
