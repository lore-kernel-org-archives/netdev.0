From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 2/7] be2net: cleanup be_vid_config()
Date: Wed, 6 Jun 2012 11:07:18 +0530
Message-ID: <a55cbff2-6c19-4823-b287-4ccdc81a99f8@exht1.ad.emulex.com>
References: <1338961043-26820-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:2015 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753236Ab2FFFwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 01:52:30 -0400
In-Reply-To: <1338961043-26820-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- get rid of 2 unused arguments to the routine and some unused code
- don't use the term "vlan_tag" in place of "vid" as they are different

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   25 +++++++++----------------
 1 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f1b0926..cfbec8b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -785,19 +785,12 @@ static int be_change_mtu(struct net_device *netdev, int new_mtu)
  * A max of 64 (BE_NUM_VLANS_SUPPORTED) vlans can be configured in BE.
  * If the user configures more, place BE in vlan promiscuous mode.
  */
-static int be_vid_config(struct be_adapter *adapter, bool vf, u32 vf_num)
+static int be_vid_config(struct be_adapter *adapter)
 {
-	struct be_vf_cfg *vf_cfg = &adapter->vf_cfg[vf_num];
-	u16 vtag[BE_NUM_VLANS_SUPPORTED];
-	u16 ntags = 0, i;
+	u16 vids[BE_NUM_VLANS_SUPPORTED];
+	u16 num = 0, i;
 	int status = 0;
 
-	if (vf) {
-		vtag[0] = cpu_to_le16(vf_cfg->vlan_tag);
-		status = be_cmd_vlan_config(adapter, vf_cfg->if_handle, vtag,
-					    1, 1, 0);
-	}
-
 	/* No need to further configure vids if in promiscuous mode */
 	if (adapter->promiscuous)
 		return 0;
@@ -808,10 +801,10 @@ static int be_vid_config(struct be_adapter *adapter, bool vf, u32 vf_num)
 	/* Construct VLAN Table to give to HW */
 	for (i = 0; i < VLAN_N_VID; i++)
 		if (adapter->vlan_tag[i])
-			vtag[ntags++] = cpu_to_le16(i);
+			vids[num++] = cpu_to_le16(i);
 
 	status = be_cmd_vlan_config(adapter, adapter->if_handle,
-				    vtag, ntags, 1, 0);
+				    vids, num, 1, 0);
 
 	/* Set to VLAN promisc mode as setting VLAN filter failed */
 	if (status) {
@@ -840,7 +833,7 @@ static int be_vlan_add_vid(struct net_device *netdev, u16 vid)
 
 	adapter->vlan_tag[vid] = 1;
 	if (adapter->vlans_added <= (adapter->max_vlans + 1))
-		status = be_vid_config(adapter, false, 0);
+		status = be_vid_config(adapter);
 
 	if (!status)
 		adapter->vlans_added++;
@@ -862,7 +855,7 @@ static int be_vlan_rem_vid(struct net_device *netdev, u16 vid)
 
 	adapter->vlan_tag[vid] = 0;
 	if (adapter->vlans_added <= adapter->max_vlans)
-		status = be_vid_config(adapter, false, 0);
+		status = be_vid_config(adapter);
 
 	if (!status)
 		adapter->vlans_added--;
@@ -889,7 +882,7 @@ static void be_set_rx_mode(struct net_device *netdev)
 		be_cmd_rx_filter(adapter, IFF_PROMISC, OFF);
 
 		if (adapter->vlans_added)
-			be_vid_config(adapter, false, 0);
+			be_vid_config(adapter);
 	}
 
 	/* Enable multicast promisc if num configured exceeds what we support */
@@ -2763,7 +2756,7 @@ static int be_setup(struct be_adapter *adapter)
 	be_cmd_get_fw_ver(adapter, adapter->fw_ver, NULL);
 
 	if (adapter->vlans_added)
-		be_vid_config(adapter, false, 0);
+		be_vid_config(adapter);
 
 	be_set_rx_mode(adapter->netdev);
 
-- 
1.7.4
