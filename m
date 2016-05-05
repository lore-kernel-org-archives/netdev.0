From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Reset dcb state machine and tx queue prio only if dcb is enabled
Date: Thu,  5 May 2016 11:05:39 +0530
Message-ID: <1462426539-5729-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:39722 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750980AbcEEFbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 01:31:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When cxgb4 is enabled with CONFIG_CHELSIO_T4_DCB set, VI enable command
gets called with DCB enabled. But when we have a back to back setup with
DCB enabled on one side and non-DCB on the Peer side. Firmware doesn't
send any DCB_L2_CFG, and DCB priority is never set for Tx queue.
But driver resets the queue priority and state machine whenever there
is a link down, this patch fixes it by adding a check to reset only if
cxgb4_dcb_enabled() returns true.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 38 +++++++++++++------------
 1 file changed, 20 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index d7f40436f319..477db477b133 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -304,6 +304,22 @@ static void dcb_tx_queue_prio_enable(struct net_device *dev, int enable)
 }
 #endif /* CONFIG_CHELSIO_T4_DCB */
 
+int cxgb4_dcb_enabled(const struct net_device *dev)
+{
+#ifdef CONFIG_CHELSIO_T4_DCB
+	struct port_info *pi = netdev_priv(dev);
+
+	if (!pi->dcb.enabled)
+		return 0;
+
+	return ((pi->dcb.state == CXGB4_DCB_STATE_FW_ALLSYNCED) ||
+		(pi->dcb.state == CXGB4_DCB_STATE_HOST));
+#else
+	return 0;
+#endif
+}
+EXPORT_SYMBOL(cxgb4_dcb_enabled);
+
 void t4_os_link_changed(struct adapter *adapter, int port_id, int link_stat)
 {
 	struct net_device *dev = adapter->port[port_id];
@@ -314,8 +330,10 @@ void t4_os_link_changed(struct adapter *adapter, int port_id, int link_stat)
 			netif_carrier_on(dev);
 		else {
 #ifdef CONFIG_CHELSIO_T4_DCB
-			cxgb4_dcb_state_init(dev);
-			dcb_tx_queue_prio_enable(dev, false);
+			if (cxgb4_dcb_enabled(dev)) {
+				cxgb4_dcb_state_init(dev);
+				dcb_tx_queue_prio_enable(dev, false);
+			}
 #endif /* CONFIG_CHELSIO_T4_DCB */
 			netif_carrier_off(dev);
 		}
@@ -494,22 +512,6 @@ static int link_start(struct net_device *dev)
 	return ret;
 }
 
-int cxgb4_dcb_enabled(const struct net_device *dev)
-{
-#ifdef CONFIG_CHELSIO_T4_DCB
-	struct port_info *pi = netdev_priv(dev);
-
-	if (!pi->dcb.enabled)
-		return 0;
-
-	return ((pi->dcb.state == CXGB4_DCB_STATE_FW_ALLSYNCED) ||
-		(pi->dcb.state == CXGB4_DCB_STATE_HOST));
-#else
-	return 0;
-#endif
-}
-EXPORT_SYMBOL(cxgb4_dcb_enabled);
-
 #ifdef CONFIG_CHELSIO_T4_DCB
 /* Handle a Data Center Bridging update message from the firmware. */
 static void dcb_rpl(struct adapter *adap, const struct fw_port_cmd *pcmd)
-- 
2.3.4
