From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 2/4] be2net: clear promiscuous bits in adapter->flags while disabling promiscuous mode
Date: Mon, 3 Mar 2014 14:24:43 +0530
Message-ID: <99d02e2d-ce5f-4e04-a15e-6e93c6e6a1ac@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath kotur <somnath.kotur@emulex.com>,
	Kalesh AP <kalesh.purayil@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:39715 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889AbaCCI41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 03:56:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath kotur <somnath.kotur@emulex.com>

We should clear promiscuous bits in adapter->flags while disabling promiscuous
mode. Else we will not put interface back into VLAN promisc mode if the vlans
already added exceeds the maximum limit.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 45662af..9e6d678 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1157,6 +1157,14 @@ ret:
 	return status;
 }
 
+static void be_clear_promisc(struct be_adapter *adapter)
+{
+	adapter->promiscuous = false;
+	adapter->flags &= ~BE_FLAGS_VLAN_PROMISC;
+
+	be_cmd_rx_filter(adapter, IFF_PROMISC, OFF);
+}
+
 static void be_set_rx_mode(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
@@ -1170,9 +1178,7 @@ static void be_set_rx_mode(struct net_device *netdev)
 
 	/* BE was previously in promiscuous mode; disable it */
 	if (adapter->promiscuous) {
-		adapter->promiscuous = false;
-		be_cmd_rx_filter(adapter, IFF_PROMISC, OFF);
-
+		be_clear_promisc(adapter);
 		if (adapter->vlans_added)
 			be_vid_config(adapter);
 	}
-- 
1.5.6.1
