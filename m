From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 6/9] be2net: remove duplicate code in be_cmd_rx_filter()
Date: Fri, 6 Feb 2015 08:18:40 -0500
Message-ID: <1423228723-10919-7-git-send-email-sathya.perla@emulex.com>
References: <1423228723-10919-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:55307 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755082AbbBFNPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 08:15:43 -0500
In-Reply-To: <1423228723-10919-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch passes BE_IF_FLAGS_XXX flags to be_cmd_rx_filter() routine
instead of the IFF_XXX flags. Doing this gets rid of the code to convert
the IFF_XXX flags to the BE_IF_FLAGS_XXX used by the FW cmd. The patch
also removes code for setting if_flags_mask that was duplicated for each
filter mode.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 54 ++++++++++-------------------
 drivers/net/ethernet/emulex/benet/be_cmds.h |  4 +++
 drivers/net/ethernet/emulex/benet/be_main.c | 29 +++++++---------
 3 files changed, 36 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 2f59553..1c85bbf 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1886,7 +1886,7 @@ err:
 	return status;
 }
 
-int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
+static int __be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_dma_mem *mem = &adapter->rx_filter;
@@ -1906,31 +1906,13 @@ int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 			       wrb, mem);
 
 	req->if_id = cpu_to_le32(adapter->if_handle);
-	if (flags & IFF_PROMISC) {
-		req->if_flags_mask = cpu_to_le32(BE_IF_FLAGS_PROMISCUOUS |
-						 BE_IF_FLAGS_VLAN_PROMISCUOUS |
-						 BE_IF_FLAGS_MCAST_PROMISCUOUS);
-		if (value == ON)
-			req->if_flags =
-				cpu_to_le32(BE_IF_FLAGS_PROMISCUOUS |
-					    BE_IF_FLAGS_VLAN_PROMISCUOUS |
-					    BE_IF_FLAGS_MCAST_PROMISCUOUS);
-	} else if (flags & IFF_ALLMULTI) {
-		req->if_flags_mask = cpu_to_le32(BE_IF_FLAGS_MCAST_PROMISCUOUS);
-		req->if_flags =	cpu_to_le32(BE_IF_FLAGS_MCAST_PROMISCUOUS);
-	} else if (flags & BE_FLAGS_VLAN_PROMISC) {
-		req->if_flags_mask = cpu_to_le32(BE_IF_FLAGS_VLAN_PROMISCUOUS);
-
-		if (value == ON)
-			req->if_flags =
-				cpu_to_le32(BE_IF_FLAGS_VLAN_PROMISCUOUS);
-	} else {
+	req->if_flags_mask = cpu_to_le32(flags);
+	req->if_flags = (value == ON) ? req->if_flags_mask : 0;
+
+	if (flags & BE_IF_FLAGS_MULTICAST) {
 		struct netdev_hw_addr *ha;
 		int i = 0;
 
-		req->if_flags_mask = cpu_to_le32(BE_IF_FLAGS_MULTICAST);
-		req->if_flags =	cpu_to_le32(BE_IF_FLAGS_MULTICAST);
-
 		/* Reset mcast promisc mode if already set by setting mask
 		 * and not setting flags field
 		 */
@@ -1942,24 +1924,26 @@ int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 			memcpy(req->mcast_mac[i++].byte, ha->addr, ETH_ALEN);
 	}
 
-	if ((req->if_flags_mask & cpu_to_le32(be_if_cap_flags(adapter))) !=
-	    req->if_flags_mask) {
-		dev_warn(&adapter->pdev->dev,
-			 "Cannot set rx filter flags 0x%x\n",
-			 req->if_flags_mask);
-		dev_warn(&adapter->pdev->dev,
-			 "Interface is capable of 0x%x flags only\n",
-			 be_if_cap_flags(adapter));
-	}
-	req->if_flags_mask &= cpu_to_le32(be_if_cap_flags(adapter));
-
 	status = be_mcc_notify_wait(adapter);
-
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
 
+int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
+{
+	struct device *dev = &adapter->pdev->dev;
+
+	if ((flags & be_if_cap_flags(adapter)) != flags) {
+		dev_warn(dev, "Cannot set rx filter flags 0x%x\n", flags);
+		dev_warn(dev, "Interface is capable of 0x%x flags only\n",
+			 be_if_cap_flags(adapter));
+	}
+	flags &= be_if_cap_flags(adapter);
+
+	return __be_cmd_rx_filter(adapter, flags, value);
+}
+
 /* Uses synchrounous mcc */
 int be_cmd_set_flow_control(struct be_adapter *adapter, u32 tx_fc, u32 rx_fc)
 {
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 402d64f..cf9d870 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -586,6 +586,10 @@ enum be_if_flags {
 			 BE_IF_FLAGS_PASS_L3L4_ERRORS | BE_IF_FLAGS_MULTICAST |\
 			 BE_IF_FLAGS_UNTAGGED)
 
+#define BE_IF_FLAGS_ALL_PROMISCUOUS	(BE_IF_FLAGS_PROMISCUOUS | \
+					 BE_IF_FLAGS_VLAN_PROMISCUOUS |\
+					 BE_IF_FLAGS_MCAST_PROMISCUOUS)
+
 /* An RX interface is an object with one or more MAC addresses and
  * filtering capabilities. */
 struct be_cmd_req_if_create {
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2ec1d80..4f7a14b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1133,16 +1133,12 @@ static int be_vid_config(struct be_adapter *adapter)
 				MCC_ADDL_STATUS_INSUFFICIENT_RESOURCES)
 			goto set_vlan_promisc;
 		dev_err(dev, "Setting HW VLAN filtering failed\n");
-	} else {
-		if (adapter->flags & BE_FLAGS_VLAN_PROMISC) {
-			/* hw VLAN filtering re-enabled. */
-			status = be_cmd_rx_filter(adapter,
-						  BE_FLAGS_VLAN_PROMISC, OFF);
-			if (!status) {
-				dev_info(dev,
-					 "Disabling VLAN Promiscuous mode\n");
-				adapter->flags &= ~BE_FLAGS_VLAN_PROMISC;
-			}
+	} else if (adapter->flags & BE_FLAGS_VLAN_PROMISC) {
+		status = be_cmd_rx_filter(adapter, BE_IF_FLAGS_VLAN_PROMISCUOUS,
+					  OFF);
+		if (!status) {
+			dev_info(dev, "Disabling VLAN Promiscuous mode\n");
+			adapter->flags &= ~BE_FLAGS_VLAN_PROMISC;
 		}
 	}
 
@@ -1152,7 +1148,7 @@ set_vlan_promisc:
 	if (adapter->flags & BE_FLAGS_VLAN_PROMISC)
 		return 0;
 
-	status = be_cmd_rx_filter(adapter, BE_FLAGS_VLAN_PROMISC, ON);
+	status = be_cmd_rx_filter(adapter, BE_IF_FLAGS_VLAN_PROMISCUOUS, ON);
 	if (!status) {
 		dev_info(dev, "Enable VLAN Promiscuous mode\n");
 		adapter->flags |= BE_FLAGS_VLAN_PROMISC;
@@ -1204,7 +1200,7 @@ static void be_clear_promisc(struct be_adapter *adapter)
 	adapter->promiscuous = false;
 	adapter->flags &= ~(BE_FLAGS_VLAN_PROMISC | BE_FLAGS_MCAST_PROMISC);
 
-	be_cmd_rx_filter(adapter, IFF_PROMISC, OFF);
+	be_cmd_rx_filter(adapter, BE_IF_FLAGS_ALL_PROMISCUOUS, OFF);
 }
 
 static void be_set_rx_mode(struct net_device *netdev)
@@ -1213,7 +1209,7 @@ static void be_set_rx_mode(struct net_device *netdev)
 	int status;
 
 	if (netdev->flags & IFF_PROMISC) {
-		be_cmd_rx_filter(adapter, IFF_PROMISC, ON);
+		be_cmd_rx_filter(adapter, BE_IF_FLAGS_ALL_PROMISCUOUS, ON);
 		adapter->promiscuous = true;
 		goto done;
 	}
@@ -1240,7 +1236,8 @@ static void be_set_rx_mode(struct net_device *netdev)
 		}
 
 		if (netdev_uc_count(netdev) > be_max_uc(adapter)) {
-			be_cmd_rx_filter(adapter, IFF_PROMISC, ON);
+			be_cmd_rx_filter(adapter, BE_IF_FLAGS_ALL_PROMISCUOUS,
+					 ON);
 			adapter->promiscuous = true;
 			goto done;
 		}
@@ -1253,7 +1250,7 @@ static void be_set_rx_mode(struct net_device *netdev)
 		}
 	}
 
-	status = be_cmd_rx_filter(adapter, IFF_MULTICAST, ON);
+	status = be_cmd_rx_filter(adapter, BE_IF_FLAGS_MULTICAST, ON);
 	if (!status) {
 		if (adapter->flags & BE_FLAGS_MCAST_PROMISC)
 			adapter->flags &= ~BE_FLAGS_MCAST_PROMISC;
@@ -1267,7 +1264,7 @@ set_mcast_promisc:
 	/* Set to MCAST promisc mode if setting MULTICAST address fails
 	 * or if num configured exceeds what we support
 	 */
-	status = be_cmd_rx_filter(adapter, IFF_ALLMULTI, ON);
+	status = be_cmd_rx_filter(adapter, BE_IF_FLAGS_MCAST_PROMISCUOUS, ON);
 	if (!status)
 		adapter->flags |= BE_FLAGS_MCAST_PROMISC;
 done:
-- 
2.2.0
