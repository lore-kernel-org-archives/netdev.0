From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next v2] be2net: log link status
Date: Wed, 22 Apr 2015 15:43:30 +0200
Message-ID: <1429710210-7291-1-git-send-email-ivecera@redhat.com>
Cc: Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49283 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757138AbbDVNnd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2015 09:43:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver unlike other drivers does not log link state changes.

v2: added current link speed to log message

Cc: Sathya Perla <sathya.perla@emulex.com>
Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |  3 ++-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |  3 ++-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c    | 20 +++++++++++++++-----
 4 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 1bf1cdc..f5409d9 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -796,7 +796,8 @@ static inline void  be_clear_all_error(struct be_adapter *adapter)
 
 void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
 		  u16 num_popped);
-void be_link_status_update(struct be_adapter *adapter, u8 link_status);
+void be_link_status_update(struct be_adapter *adapter, u8 link_status,
+			   u16 speed);
 void be_parse_stats(struct be_adapter *adapter);
 int be_load_fw(struct be_adapter *adapter, u8 *func);
 bool be_is_wol_supported(struct be_adapter *adapter);
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index fb140fa..60381eb 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -262,7 +262,8 @@ static void be_async_link_state_process(struct be_adapter *adapter,
 	 */
 	if (adapter->flags & BE_FLAGS_LINK_STATUS_INIT)
 		be_link_status_update(adapter,
-				      evt->port_link_status & LINK_STATUS_MASK);
+				      evt->port_link_status & LINK_STATUS_MASK,
+				      0);
 }
 
 static void be_async_port_misconfig_event_process(struct be_adapter *adapter,
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index b765c24..831db95 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -611,7 +611,7 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		status = be_cmd_link_status_query(adapter, &link_speed,
 						  &link_status, 0);
 		if (!status)
-			be_link_status_update(adapter, link_status);
+			be_link_status_update(adapter, link_status, link_speed);
 		ethtool_cmd_speed_set(ecmd, link_speed);
 
 		status = be_cmd_get_phy_info(adapter);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index fb0bc3c..d3bfac9 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -649,7 +649,8 @@ static struct rtnl_link_stats64 *be_get_stats64(struct net_device *netdev,
 	return stats;
 }
 
-void be_link_status_update(struct be_adapter *adapter, u8 link_status)
+void be_link_status_update(struct be_adapter *adapter, u8 link_status,
+			   u16 speed)
 {
 	struct net_device *netdev = adapter->netdev;
 
@@ -658,10 +659,18 @@ void be_link_status_update(struct be_adapter *adapter, u8 link_status)
 		adapter->flags |= BE_FLAGS_LINK_STATUS_INIT;
 	}
 
-	if (link_status)
+	if (link_status) {
+		if (speed)
+			/* Print speed only when it is known */
+			netdev_info(netdev, "Link is Up at %d Mbps\n", speed);
+		else
+			netdev_info(netdev, "Link is Up");
+
 		netif_carrier_on(netdev);
-	else
+	} else {
+		netdev_info(netdev, "Link is Down\n");
 		netif_carrier_off(netdev);
+	}
 }
 
 static void be_tx_stats_update(struct be_tx_obj *txo, struct sk_buff *skb)
@@ -3241,6 +3250,7 @@ static int be_open(struct net_device *netdev)
 	struct be_eq_obj *eqo;
 	struct be_rx_obj *rxo;
 	struct be_tx_obj *txo;
+	u16 speed;
 	u8 link_status;
 	int status, i;
 
@@ -3267,9 +3277,9 @@ static int be_open(struct net_device *netdev)
 	}
 	adapter->flags |= BE_FLAGS_NAPI_ENABLED;
 
-	status = be_cmd_link_status_query(adapter, NULL, &link_status, 0);
+	status = be_cmd_link_status_query(adapter, &speed, &link_status, 0);
 	if (!status)
-		be_link_status_update(adapter, link_status);
+		be_link_status_update(adapter, link_status, speed);
 
 	netif_tx_start_all_queues(netdev);
 	be_roce_dev_open(adapter);
-- 
2.0.5
