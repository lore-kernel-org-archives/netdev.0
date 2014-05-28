From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 1/6] be2net: skip multicast promiscuos setting in already set
Date: Wed, 28 May 2014 12:01:00 +0530
Message-ID: <1401258665-6238-2-git-send-email-sathya.perla@emulex.com>
References: <1401258665-6238-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:44468 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753927AbaE1G2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 02:28:14 -0400
In-Reply-To: <1401258665-6238-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

Set mc-promisc (multicast promiscuous) mode on an interface, only if it is
*not already* in that mode.

Also removed logs that report interface being set to multicast
promiscous mode. In an earlier comment on the netdev list such log messages
were deemed unnecessary as this behaviour is common across most of the
ethernet drivers.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_main.c |   31 +++++++++++++++-----------
 2 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 31c3766..2e7c555 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -374,6 +374,7 @@ enum vf_state {
 #define BE_FLAGS_LINK_STATUS_INIT		1
 #define BE_FLAGS_WORKER_SCHEDULED		(1 << 3)
 #define BE_FLAGS_VLAN_PROMISC			(1 << 4)
+#define BE_FLAGS_MCAST_PROMISC			(1 << 5)
 #define BE_FLAGS_NAPI_ENABLED			(1 << 9)
 #define BE_FLAGS_QNQ_ASYNC_EVT_RCVD		(1 << 11)
 #define BE_FLAGS_VXLAN_OFFLOADS			(1 << 12)
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index e1d445d..9116d5e 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1190,7 +1190,7 @@ ret:
 static void be_clear_promisc(struct be_adapter *adapter)
 {
 	adapter->promiscuous = false;
-	adapter->flags &= ~BE_FLAGS_VLAN_PROMISC;
+	adapter->flags &= ~(BE_FLAGS_VLAN_PROMISC | BE_FLAGS_MCAST_PROMISC);
 
 	be_cmd_rx_filter(adapter, IFF_PROMISC, OFF);
 }
@@ -1215,10 +1215,8 @@ static void be_set_rx_mode(struct net_device *netdev)
 
 	/* Enable multicast promisc if num configured exceeds what we support */
 	if (netdev->flags & IFF_ALLMULTI ||
-	    netdev_mc_count(netdev) > be_max_mc(adapter)) {
-		be_cmd_rx_filter(adapter, IFF_ALLMULTI, ON);
-		goto done;
-	}
+	    netdev_mc_count(netdev) > be_max_mc(adapter))
+		goto set_mcast_promisc;
 
 	if (netdev_uc_count(netdev) != adapter->uc_macs) {
 		struct netdev_hw_addr *ha;
@@ -1244,15 +1242,22 @@ static void be_set_rx_mode(struct net_device *netdev)
 	}
 
 	status = be_cmd_rx_filter(adapter, IFF_MULTICAST, ON);
-
-	/* Set to MCAST promisc mode if setting MULTICAST address fails */
-	if (status) {
-		dev_info(&adapter->pdev->dev,
-			 "Exhausted multicast HW filters.\n");
-		dev_info(&adapter->pdev->dev,
-			 "Disabling HW multicast filtering.\n");
-		be_cmd_rx_filter(adapter, IFF_ALLMULTI, ON);
+	if (!status) {
+		if (adapter->flags & BE_FLAGS_MCAST_PROMISC)
+			adapter->flags &= ~BE_FLAGS_MCAST_PROMISC;
+		goto done;
 	}
+
+set_mcast_promisc:
+	if (adapter->flags & BE_FLAGS_MCAST_PROMISC)
+		return;
+
+	/* Set to MCAST promisc mode if setting MULTICAST address fails
+	 * or if num configured exceeds what we support
+	 */
+	status = be_cmd_rx_filter(adapter, IFF_ALLMULTI, ON);
+	if (!status)
+		adapter->flags |= BE_FLAGS_MCAST_PROMISC;
 done:
 	return;
 }
-- 
1.7.1
