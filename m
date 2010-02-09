From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH 5/7] be2net: fix to limit max vlans supported in certain
 skews
Date: Tue, 9 Feb 2010 17:04:57 +0530
Message-ID: <20100209113447.GA10511@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f182.google.com ([209.85.223.182]:43051 "EHLO
	mail-iw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871Ab0BILfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 06:35:03 -0500
Received: by iwn12 with SMTP id 12so8477548iwn.26
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2010 03:35:02 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In certain skews the ASIC can support only 16 vlans per interface.
Once the limit is crossed, the ASIC is programmed in vlan promiscuous mode.
Switch off the vlan promiscuous mode once the number of vlans
falls back to the max vlans supported.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h      |    3 ++-
 drivers/net/benet/be_main.c |   30 +++++++++++++++++-------------
 2 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 2420131..476a5c4 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -250,7 +250,8 @@ struct be_adapter {
 	bool rx_post_starved;	/* Zero rx frags have been posted to BE */
 
 	struct vlan_group *vlan_grp;
-	u16 num_vlans;
+	u16 vlans_added;
+	u16 max_vlans;	/* Number of vlans supported */
 	u8 vlan_tag[VLAN_GROUP_ARRAY_LEN];
 	struct be_dma_mem mc_cmd_mem;
 
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 107de6d..c4af647 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -488,17 +488,16 @@ static int be_change_mtu(struct net_device *netdev, int new_mtu)
 }
 
 /*
- * if there are BE_NUM_VLANS_SUPPORTED or lesser number of VLANS configured,
- * program them in BE.  If more than BE_NUM_VLANS_SUPPORTED are configured,
- * set the BE in promiscuous VLAN mode.
+ * A max of 64 (BE_NUM_VLANS_SUPPORTED) vlans can be configured in BE.
+ * If the user configures more, place BE in vlan promiscuous mode.
  */
 static int be_vid_config(struct be_adapter *adapter)
 {
 	u16 vtag[BE_NUM_VLANS_SUPPORTED];
 	u16 ntags = 0, i;
-	int status;
+	int status = 0;
 
-	if (adapter->num_vlans <= BE_NUM_VLANS_SUPPORTED)  {
+	if (adapter->vlans_added <= adapter->max_vlans)  {
 		/* Construct VLAN Table to give to HW */
 		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
 			if (adapter->vlan_tag[i]) {
@@ -532,21 +531,21 @@ static void be_vlan_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
-	adapter->num_vlans++;
 	adapter->vlan_tag[vid] = 1;
-
-	be_vid_config(adapter);
+	adapter->vlans_added++;
+	if (adapter->vlans_added <= (adapter->max_vlans + 1))
+		be_vid_config(adapter);
 }
 
 static void be_vlan_rem_vid(struct net_device *netdev, u16 vid)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
-	adapter->num_vlans--;
 	adapter->vlan_tag[vid] = 0;
-
 	vlan_group_set_device(adapter->vlan_grp, vid, NULL);
-	be_vid_config(adapter);
+	adapter->vlans_added--;
+	if (adapter->vlans_added <= adapter->max_vlans)
+		be_vid_config(adapter);
 }
 
 static void be_set_multicast_list(struct net_device *netdev)
@@ -785,7 +784,7 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 	skb->dev = adapter->netdev;
 
 	if (vlanf) {
-		if (!adapter->vlan_grp || adapter->num_vlans == 0) {
+		if (!adapter->vlan_grp || adapter->vlans_added == 0) {
 			kfree_skb(skb);
 			return;
 		}
@@ -865,7 +864,7 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 		vid = AMAP_GET_BITS(struct amap_eth_rx_compl, vlan_tag, rxcp);
 		vid = be16_to_cpu(vid);
 
-		if (!adapter->vlan_grp || adapter->num_vlans == 0)
+		if (!adapter->vlan_grp || adapter->vlans_added == 0)
 			return;
 
 		vlan_gro_frags(&eq_obj->napi, adapter->vlan_grp, vid);
@@ -2240,6 +2239,11 @@ static int be_get_config(struct be_adapter *adapter)
 	memcpy(adapter->netdev->dev_addr, mac, ETH_ALEN);
 	memcpy(adapter->netdev->perm_addr, mac, ETH_ALEN);
 
+	if (adapter->cap & 0x400)
+		adapter->max_vlans = BE_NUM_VLANS_SUPPORTED/4;
+	else
+		adapter->max_vlans = BE_NUM_VLANS_SUPPORTED;
+
 	return 0;
 }
 
-- 
1.6.3.3

