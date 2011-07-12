From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next] be2net: move to new vlan model
Date: Tue, 12 Jul 2011 18:08:56 -0500
Message-ID: <20110712230855.GA13833@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:54794 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754932Ab1GLXJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 19:09:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be.h      |    1 -
 drivers/net/benet/be_main.c |   34 +++++++++-------------------------
 2 files changed, 9 insertions(+), 26 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 9aa1534..4d93ffb 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -332,7 +332,6 @@ struct be_adapter {
 	u8 eq_next_idx;
 	struct be_drv_stats drv_stats;
 
-	struct vlan_group *vlan_grp;
 	u16 vlans_added;
 	u16 max_vlans;	/* Number of vlans supported */
 	u8 vlan_tag[VLAN_N_VID];
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 4ebd700..469de79 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -653,7 +653,7 @@ static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
 			AMAP_SET_BITS(struct amap_eth_hdr_wrb, udpcs, hdr, 1);
 	}
 
-	if (adapter->vlan_grp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		AMAP_SET_BITS(struct amap_eth_hdr_wrb, vlan, hdr, 1);
 		vlan_tag = vlan_tx_tag_get(skb);
 		vlan_prio = (vlan_tag & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
@@ -846,13 +846,6 @@ static int be_vid_config(struct be_adapter *adapter, bool vf, u32 vf_num)
 	return status;
 }
 
-static void be_vlan_register(struct net_device *netdev, struct vlan_group *grp)
-{
-	struct be_adapter *adapter = netdev_priv(netdev);
-
-	adapter->vlan_grp = grp;
-}
-
 static void be_vlan_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
@@ -871,7 +864,6 @@ static void be_vlan_rem_vid(struct net_device *netdev, u16 vid)
 	struct be_adapter *adapter = netdev_priv(netdev);
 
 	adapter->vlans_added--;
-	vlan_group_set_device(adapter->vlan_grp, vid, NULL);
 
 	if (!be_physfn(adapter))
 		return;
@@ -1200,16 +1192,10 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 		skb->rxhash = rxcp->rss_hash;
 
 
-	if (unlikely(rxcp->vlanf)) {
-		if (!adapter->vlan_grp || adapter->vlans_added == 0) {
-			kfree_skb(skb);
-			return;
-		}
-		vlan_hwaccel_receive_skb(skb, adapter->vlan_grp,
-					rxcp->vlan_tag);
-	} else {
-		netif_receive_skb(skb);
-	}
+	if (unlikely(rxcp->vlanf))
+		__vlan_hwaccel_put_tag(skb, rxcp->vlan_tag);
+
+	netif_receive_skb(skb);
 }
 
 /* Process the RX completion indicated by rxcp when GRO is enabled */
@@ -1263,11 +1249,10 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 	if (adapter->netdev->features & NETIF_F_RXHASH)
 		skb->rxhash = rxcp->rss_hash;
 
-	if (likely(!rxcp->vlanf))
-		napi_gro_frags(&eq_obj->napi);
-	else
-		vlan_gro_frags(&eq_obj->napi, adapter->vlan_grp,
-				rxcp->vlan_tag);
+	if (unlikely(rxcp->vlanf))
+		__vlan_hwaccel_put_tag(skb, rxcp->vlan_tag);
+
+	napi_gro_frags(&eq_obj->napi);
 }
 
 static void be_parse_rx_compl_v1(struct be_adapter *adapter,
@@ -2950,7 +2935,6 @@ static struct net_device_ops be_netdev_ops = {
 	.ndo_set_mac_address	= be_mac_addr_set,
 	.ndo_change_mtu		= be_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_vlan_rx_register	= be_vlan_register,
 	.ndo_vlan_rx_add_vid	= be_vlan_add_vid,
 	.ndo_vlan_rx_kill_vid	= be_vlan_rem_vid,
 	.ndo_set_vf_mac		= be_set_vf_mac,
-- 
1.7.4.1

