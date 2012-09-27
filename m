From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 3/5] be2net: cleanup code related to be_link_status_query()
Date: Thu, 27 Sep 2012 12:02:46 +0530
Message-ID: <2dd9f958-4bbb-4964-b8e9-18b653167662@CMEXHTCAS2.ad.emulex.com>
References: <1348727568-2011-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:17101 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755242Ab2I0G43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 02:56:29 -0400
In-Reply-To: <1348727568-2011-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) link_status_query() is always called to query the link-speed (speed
after applying qos). When there is no qos setting, link-speed is derived from
port-speed. Do all this inside this routine and hide this from the callers.

2) adpater->phy.forced_port_speed is not being set anywhere after being
initialized. Get rid of this variable.

3) Ignore async link_speed notifications till the initial value has been
fetched from FW.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |    1 -
 drivers/net/ethernet/emulex/benet/be_cmds.c    |   46 ++++++++++++++-----
 drivers/net/ethernet/emulex/benet/be_cmds.h    |    4 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   57 +++++-------------------
 drivers/net/ethernet/emulex/benet/be_main.c    |    4 +-
 5 files changed, 48 insertions(+), 64 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 5b622993..cf4c05b 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -337,7 +337,6 @@ struct phy_info {
 	u16 auto_speeds_supported;
 	u16 fixed_speeds_supported;
 	int link_speed;
-	int forced_port_speed;
 	u32 dac_cable_len;
 	u32 advertising;
 	u32 supported;
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 6fbfb20..46a19af 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -165,14 +165,13 @@ static void be_async_grp5_cos_priority_process(struct be_adapter *adapter,
 	}
 }
 
-/* Grp5 QOS Speed evt */
+/* Grp5 QOS Speed evt: qos_link_speed is in units of 10 Mbps */
 static void be_async_grp5_qos_speed_process(struct be_adapter *adapter,
 		struct be_async_event_grp5_qos_link_speed *evt)
 {
-	if (evt->physical_port == adapter->port_num) {
-		/* qos_link_speed is in units of 10 Mbps */
-		adapter->phy.link_speed = evt->qos_link_speed * 10;
-	}
+	if (adapter->phy.link_speed >= 0 &&
+	    evt->physical_port == adapter->port_num)
+		adapter->phy.link_speed = le16_to_cpu(evt->qos_link_speed) * 10;
 }
 
 /*Grp5 PVID evt*/
@@ -1326,9 +1325,28 @@ err:
 	return status;
 }
 
-/* Uses synchronous mcc */
-int be_cmd_link_status_query(struct be_adapter *adapter, u8 *mac_speed,
-			     u16 *link_speed, u8 *link_status, u32 dom)
+static int be_mac_to_link_speed(int mac_speed)
+{
+	switch (mac_speed) {
+	case PHY_LINK_SPEED_ZERO:
+		return 0;
+	case PHY_LINK_SPEED_10MBPS:
+		return 10;
+	case PHY_LINK_SPEED_100MBPS:
+		return 100;
+	case PHY_LINK_SPEED_1GBPS:
+		return 1000;
+	case PHY_LINK_SPEED_10GBPS:
+		return 10000;
+	}
+	return 0;
+}
+
+/* Uses synchronous mcc
+ * Returns link_speed in Mbps
+ */
+int be_cmd_link_status_query(struct be_adapter *adapter, u16 *link_speed,
+			     u8 *link_status, u32 dom)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_link_status *req;
@@ -1357,11 +1375,13 @@ int be_cmd_link_status_query(struct be_adapter *adapter, u8 *mac_speed,
 	status = be_mcc_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_link_status *resp = embedded_payload(wrb);
-		if (resp->mac_speed != PHY_LINK_SPEED_ZERO) {
-			if (link_speed)
-				*link_speed = le16_to_cpu(resp->link_speed);
-			if (mac_speed)
-				*mac_speed = resp->mac_speed;
+		if (link_speed) {
+			*link_speed = resp->link_speed ?
+				      le16_to_cpu(resp->link_speed) * 10 :
+				      be_mac_to_link_speed(resp->mac_speed);
+
+			if (!resp->logical_link_status)
+				*link_speed = 0;
 		}
 		if (link_status)
 			*link_status = resp->logical_link_status;
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 1f5b839..0936e21 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1714,8 +1714,8 @@ extern int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 			int type);
 extern int be_cmd_rxq_destroy(struct be_adapter *adapter,
 			struct be_queue_info *q);
-extern int be_cmd_link_status_query(struct be_adapter *adapter, u8 *mac_speed,
-				    u16 *link_speed, u8 *link_status, u32 dom);
+extern int be_cmd_link_status_query(struct be_adapter *adapter, u16 *link_speed,
+				    u8 *link_status, u32 dom);
 extern int be_cmd_reset(struct be_adapter *adapter);
 extern int be_cmd_get_stats(struct be_adapter *adapter,
 			struct be_dma_mem *nonemb_cmd);
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index c0e7006..8e6fb0b 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -512,28 +512,6 @@ static u32 convert_to_et_setting(u32 if_type, u32 if_speeds)
 	return val;
 }
 
-static int convert_to_et_speed(u32 be_speed)
-{
-	int et_speed = SPEED_10000;
-
-	switch (be_speed) {
-	case PHY_LINK_SPEED_10MBPS:
-		et_speed = SPEED_10;
-		break;
-	case PHY_LINK_SPEED_100MBPS:
-		et_speed = SPEED_100;
-		break;
-	case PHY_LINK_SPEED_1GBPS:
-		et_speed = SPEED_1000;
-		break;
-	case PHY_LINK_SPEED_10GBPS:
-		et_speed = SPEED_10000;
-		break;
-	}
-
-	return et_speed;
-}
-
 bool be_pause_supported(struct be_adapter *adapter)
 {
 	return (adapter->phy.interface_type == PHY_TYPE_SFP_PLUS_10GB ||
@@ -544,27 +522,16 @@ bool be_pause_supported(struct be_adapter *adapter)
 static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	u8 port_speed = 0;
-	u16 link_speed = 0;
 	u8 link_status;
-	u32 et_speed = 0;
+	u16 link_speed = 0;
 	int status;
 
-	if (adapter->phy.link_speed < 0 || !(netdev->flags & IFF_UP)) {
-		if (adapter->phy.forced_port_speed < 0) {
-			status = be_cmd_link_status_query(adapter, &port_speed,
-						&link_speed, &link_status, 0);
-			if (!status)
-				be_link_status_update(adapter, link_status);
-			if (link_speed)
-				et_speed = link_speed * 10;
-			else if (link_status)
-				et_speed = convert_to_et_speed(port_speed);
-		} else {
-			et_speed = adapter->phy.forced_port_speed;
-		}
-
-		ethtool_cmd_speed_set(ecmd, et_speed);
+	if (adapter->phy.link_speed < 0) {
+		status = be_cmd_link_status_query(adapter, &link_speed,
+						  &link_status, 0);
+		if (!status)
+			be_link_status_update(adapter, link_status);
+		ethtool_cmd_speed_set(ecmd, link_speed);
 
 		status = be_cmd_get_phy_info(adapter);
 		if (status)
@@ -773,8 +740,8 @@ static void
 be_self_test(struct net_device *netdev, struct ethtool_test *test, u64 *data)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	u8 mac_speed = 0;
-	u16 qos_link_speed = 0;
+	int status;
+	u8 link_status = 0;
 
 	memset(data, 0, sizeof(u64) * ETHTOOL_TESTS_NUM);
 
@@ -798,11 +765,11 @@ be_self_test(struct net_device *netdev, struct ethtool_test *test, u64 *data)
 		test->flags |= ETH_TEST_FL_FAILED;
 	}
 
-	if (be_cmd_link_status_query(adapter, &mac_speed,
-				     &qos_link_speed, NULL, 0) != 0) {
+	status = be_cmd_link_status_query(adapter, NULL, &link_status, 0);
+	if (status) {
 		test->flags |= ETH_TEST_FL_FAILED;
 		data[4] = -1;
-	} else if (!mac_speed) {
+	} else if (!link_status) {
 		test->flags |= ETH_TEST_FL_FAILED;
 		data[4] = 1;
 	}
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b712091..4855dd6 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2440,8 +2440,7 @@ static int be_open(struct net_device *netdev)
 		be_eq_notify(adapter, eqo->q.id, true, false, 0);
 	}
 
-	status = be_cmd_link_status_query(adapter, NULL, NULL,
-					  &link_status, 0);
+	status = be_cmd_link_status_query(adapter, NULL, &link_status, 0);
 	if (!status)
 		be_link_status_update(adapter, link_status);
 
@@ -2670,7 +2669,6 @@ static void be_setup_init(struct be_adapter *adapter)
 	adapter->be3_native = false;
 	adapter->promiscuous = false;
 	adapter->eq_next_idx = 0;
-	adapter->phy.forced_port_speed = -1;
 }
 
 static int be_get_mac_addr(struct be_adapter *adapter, u8 *mac, u32 if_handle,
-- 
1.7.4
