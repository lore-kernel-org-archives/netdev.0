From: Ivan Vecera <cera@cera.cz>
Subject: [PATCH net] be2net: fix accesses to unicast list
Date: Fri,  6 Jan 2017 20:30:02 +0100
Message-ID: <20170106193002.32727-1-cera@cera.cz>
Cc: Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47838 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1033286AbdAFTaM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 14:30:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 988d44b "be2net: Avoid redundant addition of mac address in HW"
introduced be_dev_mac_add & be_uc_mac_add helpers that incorrectly
access adapter->uc_list as an array of bytes instead of an array of
be_eth_addr. Consequently NIC is not filled with valid data so unicast
filtering is broken.

Cc: Sathya Perla <sathya.perla@broadcom.com>
Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Cc: Somnath Kotur <somnath.kotur@broadcom.com>
Fixes: 988d44b be2net: Avoid redundant addition of mac address in HW
Signed-off-by: Ivan Vecera <cera@cera.cz>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 225e9a4..3510352 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -275,8 +275,7 @@ static int be_dev_mac_add(struct be_adapter *adapter, u8 *mac)
 
 	/* Check if mac has already been added as part of uc-list */
 	for (i = 0; i < adapter->uc_macs; i++) {
-		if (ether_addr_equal((u8 *)&adapter->uc_list[i * ETH_ALEN],
-				     mac)) {
+		if (ether_addr_equal(adapter->uc_list[i].mac, mac)) {
 			/* mac already added, skip addition */
 			adapter->pmac_id[0] = adapter->pmac_id[i + 1];
 			return 0;
@@ -1655,14 +1654,12 @@ static void be_clear_mc_list(struct be_adapter *adapter)
 
 static int be_uc_mac_add(struct be_adapter *adapter, int uc_idx)
 {
-	if (ether_addr_equal((u8 *)&adapter->uc_list[uc_idx * ETH_ALEN],
-			     adapter->dev_mac)) {
+	if (ether_addr_equal(adapter->uc_list[uc_idx].mac, adapter->dev_mac)) {
 		adapter->pmac_id[uc_idx + 1] = adapter->pmac_id[0];
 		return 0;
 	}
 
-	return be_cmd_pmac_add(adapter,
-			       (u8 *)&adapter->uc_list[uc_idx * ETH_ALEN],
+	return be_cmd_pmac_add(adapter, adapter->uc_list[uc_idx].mac,
 			       adapter->if_handle,
 			       &adapter->pmac_id[uc_idx + 1], 0);
 }
-- 
2.10.2
