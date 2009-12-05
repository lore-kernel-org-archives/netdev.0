From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/3] netxen: protect device reset by rtnl_lock
Date: Sat,  5 Dec 2009 14:23:54 -0800
Message-ID: <1260051836-14425-2-git-send-email-amit.salecha@qlogic.com>
References: <1260051836-14425-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:33746 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755705AbZLEWXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Dec 2009 17:23:51 -0500
In-Reply-To: <1260051836-14425-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o To prevent race conditions with other reset events.
  During suspend/resume and firmware recovery, acquire rtnl_lock,
  while changing interface state.

Acked-by: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_main.c |   43 +++++++++++++++++++++++++++------
 1 files changed, 35 insertions(+), 8 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index e5d187f..8ffb30b 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -946,8 +946,9 @@ netxen_nic_init_coalesce_defaults(struct netxen_adapter *adapter)
 		NETXEN_DEFAULT_INTR_COALESCE_TX_PACKETS;
 }
 
+/* with rtnl_lock */
 static int
-netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
+__netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
 {
 	int err;
 
@@ -988,8 +989,24 @@ netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
 	return 0;
 }
 
+/* Usage: During resume and firmware recovery module.*/
+
+static inline int
+netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
+{
+	int err = 0;
+
+	rtnl_lock();
+	if (netif_running(netdev))
+		err = __netxen_nic_up(adapter, netdev);
+	rtnl_unlock();
+
+	return err;
+}
+
+/* with rtnl_lock */
 static void
-netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
+__netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
 {
 	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
 		return;
@@ -1014,6 +1031,17 @@ netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
 	spin_unlock(&adapter->tx_clean_lock);
 }
 
+/* Usage: During suspend and firmware recovery module */
+
+static inline void
+netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
+{
+	rtnl_lock();
+	if (netif_running(netdev))
+		__netxen_nic_down(adapter, netdev);
+	rtnl_unlock();
+
+}
 
 static int
 netxen_nic_attach(struct netxen_adapter *adapter)
@@ -1122,14 +1150,14 @@ netxen_nic_reset_context(struct netxen_adapter *adapter)
 		netif_device_detach(netdev);
 
 		if (netif_running(netdev))
-			netxen_nic_down(adapter, netdev);
+			__netxen_nic_down(adapter, netdev);
 
 		netxen_nic_detach(adapter);
 
 		if (netif_running(netdev)) {
 			err = netxen_nic_attach(adapter);
 			if (!err)
-				err = netxen_nic_up(adapter, netdev);
+				err = __netxen_nic_up(adapter, netdev);
 
 			if (err)
 				goto done;
@@ -1499,7 +1527,7 @@ static int netxen_nic_open(struct net_device *netdev)
 	if (err)
 		return err;
 
-	err = netxen_nic_up(adapter, netdev);
+	err = __netxen_nic_up(adapter, netdev);
 	if (err)
 		goto err_out;
 
@@ -1519,7 +1547,7 @@ static int netxen_nic_close(struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 
-	netxen_nic_down(adapter, netdev);
+	__netxen_nic_down(adapter, netdev);
 	return 0;
 }
 
@@ -2210,8 +2238,7 @@ netxen_detach_work(struct work_struct *work)
 
 	netif_device_detach(netdev);
 
-	if (netif_running(netdev))
-		netxen_nic_down(adapter, netdev);
+	netxen_nic_down(adapter, netdev);
 
 	netxen_nic_detach(adapter);
 
-- 
1.6.0.2

