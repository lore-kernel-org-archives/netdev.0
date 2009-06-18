From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next PATCH 3/4] be2net: cleanup multicast_set cmd to avoid
	mc_list copy
Date: Thu, 18 Jun 2009 15:39:25 +0530
Message-ID: <20090618100925.GA12704@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:14461 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751970AbZFRKJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 06:09:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanup multicast_set method to avoid an extra copy of mc_list
 and unwanted promiscuos sets to BE.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be.h      |    1 +
 drivers/net/benet/be_cmds.c |   19 ++++++++++------
 drivers/net/benet/be_cmds.h |    4 +-
 drivers/net/benet/be_main.c |   49 +++++++++++++++----------------------------
 4 files changed, 32 insertions(+), 41 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index ef5be13..94b75cb 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -274,6 +274,7 @@ struct be_adapter {
 
 	struct be_link_info link;
 	u32 port_num;
+	bool promiscuous;
 };
 
 extern struct ethtool_ops be_ethtool_ops;
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 0b60508..dad2d2b 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -927,8 +927,8 @@ int be_cmd_promiscuous_config(struct be_ctrl_info *ctrl, u8 port_num, bool en)
  * Use MCC for this command as it may be called in BH context
  * (mc == NULL) => multicast promiscous
  */
-int be_cmd_mcast_mac_set(struct be_ctrl_info *ctrl, u32 if_id, u8 *mac_table,
-			u32 num, bool promiscuous)
+int be_cmd_multicast_set(struct be_ctrl_info *ctrl, u32 if_id,
+		struct dev_mc_list *mc_list, u32 mc_count)
 {
 #define BE_MAX_MC		32 /* set mcast promisc if > 32 */
 	struct be_mcc_wrb *wrb;
@@ -947,11 +947,16 @@ int be_cmd_mcast_mac_set(struct be_ctrl_info *ctrl, u32 if_id, u8 *mac_table,
 		OPCODE_COMMON_NTWK_MULTICAST_SET, sizeof(*req));
 
 	req->interface_id = if_id;
-	req->promiscuous = promiscuous;
-	if (!promiscuous) {
-		req->num_mac = cpu_to_le16(num);
-		if (num)
-			memcpy(req->mac, mac_table, ETH_ALEN * num);
+	if (mc_list && mc_count <= BE_MAX_MC) {
+		int i;
+		struct dev_mc_list *mc;
+
+		req->num_mac = cpu_to_le16(mc_count);
+
+		for (mc = mc_list, i = 0; mc; mc = mc->next, i++)
+			memcpy(req->mac[i].byte, mc->dmi_addr, ETH_ALEN);
+	} else {
+		req->promiscuous = 1;
 	}
 
 	be_mcc_notify_wait(ctrl);
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 0a9189d..a567aa4 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -716,8 +716,8 @@ extern int be_cmd_vlan_config(struct be_ctrl_info *ctrl, u32 if_id,
 			bool promiscuous);
 extern int be_cmd_promiscuous_config(struct be_ctrl_info *ctrl,
 			u8 port_num, bool en);
-extern int be_cmd_mcast_mac_set(struct be_ctrl_info *ctrl, u32 if_id,
-			u8 *mac_table, u32 num, bool promiscuous);
+extern int be_cmd_multicast_set(struct be_ctrl_info *ctrl, u32 if_id,
+			struct dev_mc_list *mc_list, u32 mc_count);
 extern int be_cmd_set_flow_control(struct be_ctrl_info *ctrl,
 			u32 tx_fc, u32 rx_fc);
 extern int be_cmd_get_flow_control(struct be_ctrl_info *ctrl,
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index a4ce80e..3dc6803 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -549,47 +549,32 @@ static void be_vlan_rem_vid(struct net_device *netdev, u16 vid)
 	be_vid_config(netdev);
 }
 
-static void be_set_multicast_filter(struct net_device *netdev)
+static void be_set_multicast_list(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	struct dev_mc_list *mc_ptr;
-	u8 mac_addr[32][ETH_ALEN];
-	int i = 0;
+	struct be_ctrl_info *ctrl = &adapter->ctrl;
 
-	if (netdev->flags & IFF_ALLMULTI) {
-		/* set BE in Multicast promiscuous */
-		be_cmd_mcast_mac_set(&adapter->ctrl,
-					adapter->if_handle, NULL, 0, true);
-		return;
+	if (netdev->flags & IFF_PROMISC) {
+		be_cmd_promiscuous_config(ctrl, adapter->port_num, 1);
+		adapter->promiscuous = true;
+		goto done;
 	}
 
-	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
-		memcpy(&mac_addr[i][0], mc_ptr->dmi_addr, ETH_ALEN);
-		if (++i >= 32) {
-			be_cmd_mcast_mac_set(&adapter->ctrl,
-				adapter->if_handle, &mac_addr[0][0], i, false);
-			i = 0;
-		}
-
+	/* BE was previously in promiscous mode; disable it */
+	if (adapter->promiscuous) {
+		adapter->promiscuous = false;
+		be_cmd_promiscuous_config(ctrl, adapter->port_num, 0);
 	}
 
-	if (i) {
-		/* reset the promiscuous mode also. */
-		be_cmd_mcast_mac_set(&adapter->ctrl,
-			adapter->if_handle, &mac_addr[0][0], i, false);
+	if (netdev->flags & IFF_ALLMULTI) {
+		be_cmd_multicast_set(ctrl, adapter->if_handle, NULL, 0);
+		goto done;
 	}
-}
-
-static void be_set_multicast_list(struct net_device *netdev)
-{
-	struct be_adapter *adapter = netdev_priv(netdev);
 
-	if (netdev->flags & IFF_PROMISC) {
-		be_cmd_promiscuous_config(&adapter->ctrl, adapter->port_num, 1);
-	} else {
-		be_cmd_promiscuous_config(&adapter->ctrl, adapter->port_num, 0);
-		be_set_multicast_filter(netdev);
-	}
+	be_cmd_multicast_set(ctrl, adapter->if_handle, netdev->mc_list,
+		netdev->mc_count);
+done:
+	return;
 }
 
 static void be_rx_rate_update(struct be_adapter *adapter)
-- 
1.6.0.4

