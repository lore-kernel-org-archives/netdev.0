From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 2/3] be2net: Log a kernel message when the user tries to configure more Multicast addresses than supported
Date: Thu, 5 Dec 2013 10:34:43 +0530
Message-ID: <83f2f47f-d142-4a9f-9e27-58ea531329e3@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>,
	Kalesh AP <kalesh.purayil@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:37358 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723Ab3LEFGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 00:06:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the user tries to configure more Multicast addresses than supported,
we put interface into Multicast promiscuous mode. Added a log to notify the user
about the same.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_main.c |   31 ++++++++++++++++++++-------
 2 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 5878df6..9baf274 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -367,6 +367,7 @@ enum vf_state {
 #define BE_FLAGS_LINK_STATUS_INIT		1
 #define BE_FLAGS_WORKER_SCHEDULED		(1 << 3)
 #define BE_FLAGS_VLAN_PROMISC			(1 << 4)
+#define BE_FLAGS_MCAST_PROMISC			(1 << 6)
 #define BE_FLAGS_NAPI_ENABLED			(1 << 9)
 #define BE_UC_PMAC_COUNT		30
 #define BE_VF_UC_PMAC_COUNT		2
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index a2302dc..e24294e 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1164,6 +1164,7 @@ ret:
 static void be_set_rx_mode(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
+	struct device *dev = &adapter->pdev->dev;
 	int status;
 
 	if (netdev->flags & IFF_PROMISC) {
@@ -1175,6 +1176,8 @@ static void be_set_rx_mode(struct net_device *netdev)
 	/* BE was previously in promiscuous mode; disable it */
 	if (adapter->promiscuous) {
 		adapter->promiscuous = false;
+		if (adapter->flags & BE_FLAGS_MCAST_PROMISC)
+			adapter->flags &= ~BE_FLAGS_MCAST_PROMISC;
 		be_cmd_rx_filter(adapter, IFF_PROMISC, OFF);
 
 		if (adapter->vlans_added)
@@ -1184,8 +1187,10 @@ static void be_set_rx_mode(struct net_device *netdev)
 	/* Enable multicast promisc if num configured exceeds what we support */
 	if (netdev->flags & IFF_ALLMULTI ||
 	    netdev_mc_count(netdev) > be_max_mc(adapter)) {
-		be_cmd_rx_filter(adapter, IFF_ALLMULTI, ON);
-		goto done;
+		if (adapter->flags & BE_FLAGS_MCAST_PROMISC)
+			goto done;
+		else
+			goto set_mcast_promisc;
 	}
 
 	if (netdev_uc_count(netdev) != adapter->uc_macs) {
@@ -1211,13 +1216,23 @@ static void be_set_rx_mode(struct net_device *netdev)
 		}
 	}
 
-	status = be_cmd_rx_filter(adapter, IFF_MULTICAST, ON);
+	if (adapter->flags & BE_FLAGS_MCAST_PROMISC)
+		dev_info(dev, "Re-Enabling HW multicast filtering\n");
 
-	/* Set to MCAST promisc mode if setting MULTICAST address fails */
-	if (status) {
-		dev_info(&adapter->pdev->dev, "Exhausted multicast HW filters.\n");
-		dev_info(&adapter->pdev->dev, "Disabling HW multicast filtering.\n");
-		be_cmd_rx_filter(adapter, IFF_ALLMULTI, ON);
+	status = be_cmd_rx_filter(adapter, IFF_MULTICAST, ON);
+	if (!status) {
+		adapter->flags &= ~BE_FLAGS_MCAST_PROMISC;
+		goto done;
+	}
+set_mcast_promisc:
+	/* Set to MCAST promisc mode if setting MULTICAST address fails
+	 * or if num configured exceeds what we support
+	 */
+	dev_info(dev, "Exhausted multicast HW filters\n");
+	status = be_cmd_rx_filter(adapter, IFF_ALLMULTI, ON);
+	if (!status) {
+		dev_info(dev, "Disabling HW multicast filtering.\n");
+		adapter->flags |= BE_FLAGS_MCAST_PROMISC;
 	}
 done:
 	return;
-- 
1.6.0.2
