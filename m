From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: do DCB state reset in couple of places
Date: Sat, 23 Sep 2017 16:07:28 +0530
Message-ID: <1506163048-17544-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:52281 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750814AbdIWKhj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 06:37:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

reset the driver's DCB state in couple of places
where it was missing.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c  | 15 +++++++++++----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h  |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 10 ++++++++--
 3 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
index 6ee2ed3..4e7f72b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
@@ -40,8 +40,7 @@ static inline bool cxgb4_dcb_state_synced(enum cxgb4_dcb_state state)
 		return false;
 }
 
-/* Initialize a port's Data Center Bridging state.  Typically used after a
- * Link Down event.
+/* Initialize a port's Data Center Bridging state.
  */
 void cxgb4_dcb_state_init(struct net_device *dev)
 {
@@ -106,6 +105,15 @@ static void cxgb4_dcb_cleanup_apps(struct net_device *dev)
 	}
 }
 
+/* Reset a port's Data Center Bridging state.  Typically used after a
+ * Link Down event.
+ */
+void cxgb4_dcb_reset(struct net_device *dev)
+{
+	cxgb4_dcb_cleanup_apps(dev);
+	cxgb4_dcb_state_init(dev);
+}
+
 /* Finite State machine for Data Center Bridging.
  */
 void cxgb4_dcb_state_fsm(struct net_device *dev,
@@ -194,8 +202,7 @@ void cxgb4_dcb_state_fsm(struct net_device *dev,
 			 * state.  We need to reset back to a ground state
 			 * of incomplete.
 			 */
-			cxgb4_dcb_cleanup_apps(dev);
-			cxgb4_dcb_state_init(dev);
+			cxgb4_dcb_reset(dev);
 			dcb->state = CXGB4_DCB_STATE_FW_INCOMPLETE;
 			dcb->supported = CXGB4_DCBX_FW_SUPPORT;
 			linkwatch_fire_event(dev);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h
index ccf24d3..02040b9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h
@@ -131,6 +131,7 @@ struct port_dcb_info {
 
 void cxgb4_dcb_state_init(struct net_device *);
 void cxgb4_dcb_version_init(struct net_device *);
+void cxgb4_dcb_reset(struct net_device *dev);
 void cxgb4_dcb_state_fsm(struct net_device *, enum cxgb4_dcb_state_input);
 void cxgb4_dcb_handle_fw_update(struct adapter *, const struct fw_port_cmd *);
 void cxgb4_dcb_set_caps(struct adapter *, const struct fw_port_cmd *);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index aa93ae9..13b636b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -281,7 +281,7 @@ void t4_os_link_changed(struct adapter *adapter, int port_id, int link_stat)
 		else {
 #ifdef CONFIG_CHELSIO_T4_DCB
 			if (cxgb4_dcb_enabled(dev)) {
-				cxgb4_dcb_state_init(dev);
+				cxgb4_dcb_reset(dev);
 				dcb_tx_queue_prio_enable(dev, false);
 			}
 #endif /* CONFIG_CHELSIO_T4_DCB */
@@ -2304,10 +2304,16 @@ static int cxgb_close(struct net_device *dev)
 {
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adapter = pi->adapter;
+	int ret;
 
 	netif_tx_stop_all_queues(dev);
 	netif_carrier_off(dev);
-	return t4_enable_vi(adapter, adapter->pf, pi->viid, false, false);
+	ret = t4_enable_vi(adapter, adapter->pf, pi->viid, false, false);
+#ifdef CONFIG_CHELSIO_T4_DCB
+	cxgb4_dcb_reset(dev);
+	dcb_tx_queue_prio_enable(dev, false);
+#endif
+	return ret;
 }
 
 int cxgb4_create_server_filter(const struct net_device *dev, unsigned int stid,
-- 
2.1.0
