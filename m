From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 2/5] be2net: clear promiscuous bits in adapter->flags while disabling promiscuous mode
Date: Mon, 24 Feb 2014 12:20:27 +0530
Message-ID: <12524c44-4309-43ca-a84c-5accf381f130@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath kotur <somnath.kotur@emulex.com>,
	Kalesh AP <kalesh.purayil@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:57245 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbaBXGw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 01:52:29 -0500
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
