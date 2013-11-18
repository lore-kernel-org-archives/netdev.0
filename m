From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH 1/2] be2net: Fix unconditional enabling of Rx interface
 options
Date: Mon, 18 Nov 2013 10:44:24 -0600
Message-ID: <20131118164424.GA3033@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:48456 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab3KRQoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 11:44:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver currently requests the firmware to enable rx_interface options
without considering if the interface was created with that capability.
This could cause commands to firmware to fail.

To avoid this, enable only those options on an interface if the interface
was created with that capability.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 16 ++++++++++++++--
 drivers/net/ethernet/emulex/benet/be_cmds.h |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c |  2 +-
 3 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 7fb0edf..dbcd526 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1758,7 +1758,7 @@ err:
 
 /* Uses sycnhronous mcc */
 int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
-			u32 num, bool untagged, bool promiscuous)
+		       u32 num, bool promiscuous)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_vlan_config *req;
@@ -1778,7 +1778,7 @@ int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
 
 	req->interface_id = if_id;
 	req->promiscuous = promiscuous;
-	req->untagged = untagged;
+	req->untagged = BE_IF_FLAGS_UNTAGGED & be_if_cap_flags(adapter) ? 1 : 0;
 	req->num_vlan = num;
 	if (!promiscuous) {
 		memcpy(req->normal_vlan, vtag_array,
@@ -1847,7 +1847,19 @@ int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 			memcpy(req->mcast_mac[i++].byte, ha->addr, ETH_ALEN);
 	}
 
+	if ((req->if_flags_mask & cpu_to_le32(be_if_cap_flags(adapter))) !=
+	     req->if_flags_mask) {
+		dev_warn(&adapter->pdev->dev,
+			 "Cannot set rx filter flags 0x%x\n",
+			 req->if_flags_mask);
+		dev_warn(&adapter->pdev->dev,
+			 "Interface is capable of 0x%x flags only\n",
+			 be_if_cap_flags(adapter));
+	}
+	req->if_flags_mask &= cpu_to_le32(be_if_cap_flags(adapter));
+
 	status = be_mcc_notify_wait(adapter);
+
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index edf3e8a..0075686 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1984,7 +1984,7 @@ int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver,
 		      char *fw_on_flash);
 int be_cmd_modify_eqd(struct be_adapter *adapter, struct be_set_eqd *, int num);
 int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
-		       u32 num, bool untagged, bool promiscuous);
+		       u32 num, bool promiscuous);
 int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 status);
 int be_cmd_set_flow_control(struct be_adapter *adapter, u32 tx_fc, u32 rx_fc);
 int be_cmd_get_flow_control(struct be_adapter *adapter, u32 *tx_fc, u32 *rx_fc);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 741d3bf..13818d3 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1079,7 +1079,7 @@ static int be_vid_config(struct be_adapter *adapter)
 			vids[num++] = cpu_to_le16(i);
 
 	status = be_cmd_vlan_config(adapter, adapter->if_handle,
-				    vids, num, 1, 0);
+				    vids, num, 0);
 
 	if (status) {
 		/* Set to VLAN promisc mode as setting VLAN filter failed */
-- 
1.8.1.2
