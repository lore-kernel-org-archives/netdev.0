From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 1/3] be2net: fix be_vlan_add/rem_vid
Date: Fri, 30 Dec 2011 16:15:12 -0600
Message-ID: <20111230221512.GA6825@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:55982 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752037Ab1L3WPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 17:15:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) fix be_vlan_add/rem_vid to return proper status
2) perform appropriate housekeeping if firmware command succeeds.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   35 ++++++++++++++++++--------
 1 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 76f3a98..10f2313 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -817,32 +817,45 @@ static int be_vid_config(struct be_adapter *adapter, bool vf, u32 vf_num)
 static int be_vlan_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
+	int status = 0;
 
-	adapter->vlans_added++;
-	if (!be_physfn(adapter))
-		return 0;
+	if (!be_physfn(adapter)) {
+		status = -EINVAL;
+		goto ret;
+	}
 
 	adapter->vlan_tag[vid] = 1;
 	if (adapter->vlans_added <= (adapter->max_vlans + 1))
-		be_vid_config(adapter, false, 0);
+		status = be_vid_config(adapter, false, 0);
 
-	return 0;
+	if (!status)
+		adapter->vlans_added++;
+	else
+		adapter->vlan_tag[vid] = 0;
+ret:
+	return status;
 }
 
 static int be_vlan_rem_vid(struct net_device *netdev, u16 vid)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
+	int status = 0;
 
-	adapter->vlans_added--;
-
-	if (!be_physfn(adapter))
-		return 0;
+	if (!be_physfn(adapter)) {
+		status = -EINVAL;
+		goto ret;
+	}
 
 	adapter->vlan_tag[vid] = 0;
 	if (adapter->vlans_added <= adapter->max_vlans)
-		be_vid_config(adapter, false, 0);
+		status = be_vid_config(adapter, false, 0);
 
-	return 0;
+	if (!status)
+		adapter->vlans_added--;
+	else
+		adapter->vlan_tag[vid] = 1;
+ret:
+	return status;
 }
 
 static void be_set_rx_mode(struct net_device *netdev)
-- 
1.7.5.4
