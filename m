From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next v2 4/4] be2net: re-enable vlan filtering mode asap
Date: Mon, 30 Jun 2014 13:01:33 +0530
Message-ID: <1404113493-14851-5-git-send-email-sathya.perla@emulex.com>
References: <1404113493-14851-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:13555 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754324AbaF3H3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 03:29:08 -0400
In-Reply-To: <1404113493-14851-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

While adding vlans, when the HW limit of vlan filters is reached, the
driver enables vlan promiscuous mode.
Similarily, while removing vlans, the driver must re-enable HW filtering
as soon as the number of vlan filters is within the HW limit.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5ac9d13..64a0b6c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1172,20 +1172,15 @@ static int be_vlan_add_vid(struct net_device *netdev, __be16 proto, u16 vid)
 static int be_vlan_rem_vid(struct net_device *netdev, __be16 proto, u16 vid)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	int status = 0;
 
 	/* Packets with VID 0 are always received by Lancer by default */
 	if (lancer_chip(adapter) && vid == 0)
-		goto ret;
+		return 0;
 
 	clear_bit(vid, adapter->vids);
-	status = be_vid_config(adapter);
-	if (!status)
-		adapter->vlans_added--;
-	else
-		set_bit(vid, adapter->vids);
-ret:
-	return status;
+	adapter->vlans_added--;
+
+	return be_vid_config(adapter);
 }
 
 static void be_clear_promisc(struct be_adapter *adapter)
-- 
1.7.1
