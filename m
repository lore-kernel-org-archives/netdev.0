From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 1/2] be2net: Fix be_vlan_add/rem_vid() routines
Date: Wed, 8 Jan 2014 14:51:31 +0530
Message-ID: <29a18eef-791d-4f25-afe7-2eb694af383c@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>,
	Kalesh AP <kalesh.purayil@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:40835 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754162AbaAHJXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 04:23:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current logic to put interface into VLAN Promiscous mode is not correct.
We should increment "adapter->vlans_added" before calling be_vid_config().
Also removed some unwanted log messages.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   21 ++++++++-------------
 1 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index bf40fda..2fada24 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1096,8 +1096,6 @@ static int be_vid_config(struct be_adapter *adapter)
 				dev_info(&adapter->pdev->dev,
 					 "Disabling VLAN Promiscuous mode.\n");
 				adapter->flags &= ~BE_FLAGS_VLAN_PROMISC;
-				dev_info(&adapter->pdev->dev,
-					 "Re-Enabling HW VLAN filtering\n");
 			}
 		}
 	}
@@ -1105,12 +1103,12 @@ static int be_vid_config(struct be_adapter *adapter)
 	return status;
 
 set_vlan_promisc:
-	dev_warn(&adapter->pdev->dev, "Exhausted VLAN HW filters.\n");
+	if (adapter->flags & BE_FLAGS_VLAN_PROMISC)
+		return 0;
 
 	status = be_cmd_rx_filter(adapter, BE_FLAGS_VLAN_PROMISC, ON);
 	if (!status) {
 		dev_info(&adapter->pdev->dev, "Enable VLAN Promiscuous mode\n");
-		dev_info(&adapter->pdev->dev, "Disabling HW VLAN filtering\n");
 		adapter->flags |= BE_FLAGS_VLAN_PROMISC;
 	} else
 		dev_err(&adapter->pdev->dev,
@@ -1123,19 +1121,18 @@ static int be_vlan_add_vid(struct net_device *netdev, __be16 proto, u16 vid)
 	struct be_adapter *adapter = netdev_priv(netdev);
 	int status = 0;
 
-
 	/* Packets with VID 0 are always received by Lancer by default */
 	if (lancer_chip(adapter) && vid == 0)
 		goto ret;
 
 	adapter->vlan_tag[vid] = 1;
-	if (adapter->vlans_added <= (be_max_vlans(adapter) + 1))
-		status = be_vid_config(adapter);
+	adapter->vlans_added++;
 
-	if (!status)
-		adapter->vlans_added++;
-	else
+	status = be_vid_config(adapter);
+	if (status) {
+		adapter->vlans_added--;
 		adapter->vlan_tag[vid] = 0;
+	}
 ret:
 	return status;
 }
@@ -1150,9 +1147,7 @@ static int be_vlan_rem_vid(struct net_device *netdev, __be16 proto, u16 vid)
 		goto ret;
 
 	adapter->vlan_tag[vid] = 0;
-	if (adapter->vlans_added <= be_max_vlans(adapter))
-		status = be_vid_config(adapter);
-
+	status = be_vid_config(adapter);
 	if (!status)
 		adapter->vlans_added--;
 	else
-- 
1.6.0.2
