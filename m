From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 05/14] be2net: Fix configuring VLAN for VF for Lancer
Date: Sat, 20 Oct 2012 21:32:40 +0530
Message-ID: <f1979547-3295-4b91-82b9-b68bcfc9ba79@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:22347 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164Ab2JTQDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 12:03:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow adding VLANs for Lancer VF.
VLAN ID 0 should not be added to list of VLANs sent to FW.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 7a483fd..fa895bc 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -879,11 +879,15 @@ static int be_vlan_add_vid(struct net_device *netdev, u16 vid)
 	struct be_adapter *adapter = netdev_priv(netdev);
 	int status = 0;
 
-	if (!be_physfn(adapter)) {
+	if (!lancer_chip(adapter) && !be_physfn(adapter)) {
 		status = -EINVAL;
 		goto ret;
 	}
 
+	/* Packets with VID 0 are always received by Lancer by default */
+	if (lancer_chip(adapter) && vid == 0)
+		goto ret;
+
 	adapter->vlan_tag[vid] = 1;
 	if (adapter->vlans_added <= (adapter->max_vlans + 1))
 		status = be_vid_config(adapter);
@@ -901,11 +905,15 @@ static int be_vlan_rem_vid(struct net_device *netdev, u16 vid)
 	struct be_adapter *adapter = netdev_priv(netdev);
 	int status = 0;
 
-	if (!be_physfn(adapter)) {
+	if (!lancer_chip(adapter) && !be_physfn(adapter)) {
 		status = -EINVAL;
 		goto ret;
 	}
 
+	/* Packets with VID 0 are always received by Lancer by default */
+	if (lancer_chip(adapter) && vid == 0)
+		goto ret;
+
 	adapter->vlan_tag[vid] = 0;
 	if (adapter->vlans_added <= adapter->max_vlans)
 		status = be_vid_config(adapter);
-- 
1.6.0.2
