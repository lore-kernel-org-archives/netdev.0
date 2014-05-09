From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 4/7] be2net: covert vlan array to bit-map
Date: Fri, 9 May 2014 13:29:16 +0530
Message-ID: <1399622359-25926-5-git-send-email-sathya.perla@emulex.com>
References: <1399622359-25926-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:21312 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbaEIH4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 03:56:11 -0400
In-Reply-To: <1399622359-25926-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ravikumar Nelavelli <ravikumar.nelavelli@emulex.com>

This patch converts the vlan u8[] used to track vlan-id
membership to a bit-map as it reduces memory usage.

Signed-off-by: Ravikumar Nelavelli <ravikumar.nelavelli@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c |   19 +++++++++----------
 2 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 2f67c7c..31c3766 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -455,7 +455,7 @@ struct be_adapter {
 	struct be_drv_stats drv_stats;
 	struct be_aic_obj aic_obj[MAX_EVT_QS];
 	u16 vlans_added;
-	u8 vlan_tag[VLAN_N_VID];
+	unsigned long vids[BITS_TO_LONGS(VLAN_N_VID)];
 	u8 vlan_prio_bmap;	/* Available Priority BitMap */
 	u16 recommended_prio;	/* Recommended Priority */
 	struct be_dma_mem rx_filter; /* Cmd DMA mem for rx-filter */
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 8dc1af4..2cd733b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1094,7 +1094,7 @@ static int be_change_mtu(struct net_device *netdev, int new_mtu)
 static int be_vid_config(struct be_adapter *adapter)
 {
 	u16 vids[BE_NUM_VLANS_SUPPORTED];
-	u16 num = 0, i;
+	u16 num = 0, i = 0;
 	int status = 0;
 
 	/* No need to further configure vids if in promiscuous mode */
@@ -1105,9 +1105,8 @@ static int be_vid_config(struct be_adapter *adapter)
 		goto set_vlan_promisc;
 
 	/* Construct VLAN Table to give to HW */
-	for (i = 0; i < VLAN_N_VID; i++)
-		if (adapter->vlan_tag[i])
-			vids[num++] = cpu_to_le16(i);
+	for_each_set_bit(i, adapter->vids, VLAN_N_VID)
+		vids[num++] = cpu_to_le16(i);
 
 	status = be_cmd_vlan_config(adapter, adapter->if_handle, vids, num, 0);
 
@@ -1155,16 +1154,16 @@ static int be_vlan_add_vid(struct net_device *netdev, __be16 proto, u16 vid)
 	if (lancer_chip(adapter) && vid == 0)
 		return status;
 
-	if (adapter->vlan_tag[vid])
+	if (test_bit(vid, adapter->vids))
 		return status;
 
-	adapter->vlan_tag[vid] = 1;
+	set_bit(vid, adapter->vids);
 	adapter->vlans_added++;
 
 	status = be_vid_config(adapter);
 	if (status) {
 		adapter->vlans_added--;
-		adapter->vlan_tag[vid] = 0;
+		clear_bit(vid, adapter->vids);
 	}
 
 	return status;
@@ -1179,12 +1178,12 @@ static int be_vlan_rem_vid(struct net_device *netdev, __be16 proto, u16 vid)
 	if (lancer_chip(adapter) && vid == 0)
 		goto ret;
 
-	adapter->vlan_tag[vid] = 0;
+	clear_bit(vid, adapter->vids);
 	status = be_vid_config(adapter);
 	if (!status)
 		adapter->vlans_added--;
 	else
-		adapter->vlan_tag[vid] = 1;
+		set_bit(vid, adapter->vids);
 ret:
 	return status;
 }
@@ -1795,7 +1794,7 @@ static struct be_rx_compl_info *be_rx_compl_get(struct be_rx_obj *rxo)
 			rxcp->vlan_tag = swab16(rxcp->vlan_tag);
 
 		if (adapter->pvid == (rxcp->vlan_tag & VLAN_VID_MASK) &&
-		    !adapter->vlan_tag[rxcp->vlan_tag])
+		    !test_bit(rxcp->vlan_tag, adapter->vids))
 			rxcp->vlanf = 0;
 	}
 
-- 
1.7.1
