From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 4/5] be2net: pass domain id to
 be_cmd_link_status_query
Date: Mon, 18 Apr 2011 17:30:33 -0500
Message-ID: <20110418223033.GA9515@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:45953 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753162Ab1DRWao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 18:30:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be.h         |    1 -
 drivers/net/benet/be_cmds.c    |    4 +++-
 drivers/net/benet/be_cmds.h    |    2 +-
 drivers/net/benet/be_ethtool.c |    4 ++--
 drivers/net/benet/be_main.c    |   34 ++++++++++------------------------
 5 files changed, 16 insertions(+), 29 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index a0b4743..4ba9c68 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -293,7 +293,6 @@ struct be_adapter {
 	u8 eq_next_idx;
 	struct be_drv_stats drv_stats;
 
-	struct vlan_group *vlan_grp;
 	u16 vlans_added;
 	u16 max_vlans;	/* Number of vlans supported */
 	u8 vlan_tag[VLAN_N_VID];
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index a94e980..7a580a9 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1112,7 +1112,7 @@ err:
 
 /* Uses synchronous mcc */
 int be_cmd_link_status_query(struct be_adapter *adapter,
-			bool *link_up, u8 *mac_speed, u16 *link_speed)
+			bool *link_up, u8 *mac_speed, u16 *link_speed, u32 dom)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_link_status *req;
@@ -1135,6 +1135,8 @@ int be_cmd_link_status_query(struct be_adapter *adapter,
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_LINK_STATUS_QUERY, sizeof(*req));
 
+	req->hdr.domain = dom;
+
 	status = be_mcc_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_link_status *resp = embedded_payload(wrb);
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 3fb6e0a..af4bbff 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -1112,7 +1112,7 @@ extern int be_cmd_rxq_create(struct be_adapter *adapter,
 extern int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 			int type);
 extern int be_cmd_link_status_query(struct be_adapter *adapter,
-			bool *link_up, u8 *mac_speed, u16 *link_speed);
+			bool *link_up, u8 *mac_speed, u16 *link_speed, u32 dom);
 extern int be_cmd_reset(struct be_adapter *adapter);
 extern int be_cmd_get_stats(struct be_adapter *adapter,
 			struct be_dma_mem *nonemb_cmd);
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 33c2bec..6565f3e 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -376,7 +376,7 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 
 	if ((adapter->link_speed < 0) || (!(netdev->flags & IFF_UP))) {
 		status = be_cmd_link_status_query(adapter, &link_up,
-						&mac_speed, &link_speed);
+						&mac_speed, &link_speed, 0);
 
 		be_link_status_update(adapter, link_up);
 		/* link_speed is in units of 10 Mbps */
@@ -661,7 +661,7 @@ be_self_test(struct net_device *netdev, struct ethtool_test *test, u64 *data)
 	}
 
 	if (be_cmd_link_status_query(adapter, &link_up, &mac_speed,
-				&qos_link_speed) != 0) {
+				&qos_link_speed, 0) != 0) {
 		test->flags |= ETH_TEST_FL_FAILED;
 		data[4] = -1;
 	} else if (!mac_speed) {
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 1bb763c..94a9c4a 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -464,7 +464,7 @@ static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
 			AMAP_SET_BITS(struct amap_eth_hdr_wrb, udpcs, hdr, 1);
 	}
 
-	if (adapter->vlan_grp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		AMAP_SET_BITS(struct amap_eth_hdr_wrb, vlan, hdr, 1);
 		vlan_tag = vlan_tx_tag_get(skb);
 		vlan_prio = (vlan_tag & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
@@ -658,13 +658,6 @@ static int be_vid_config(struct be_adapter *adapter, bool vf, u32 vf_num)
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
@@ -683,7 +676,6 @@ static void be_vlan_rem_vid(struct net_device *netdev, u16 vid)
 	struct be_adapter *adapter = netdev_priv(netdev);
 
 	adapter->vlans_added--;
-	vlan_group_set_device(adapter->vlan_grp, vid, NULL);
 
 	if (!be_physfn(adapter))
 		return;
@@ -1012,15 +1004,10 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 		skb->rxhash = rxcp->rss_hash;
 
 
-	if (unlikely(rxcp->vlanf)) {
-		if (!adapter->vlan_grp || adapter->vlans_added == 0) {
-			kfree_skb(skb);
-			return;
-		}
-		vlan_hwaccel_receive_skb(skb, adapter->vlan_grp, rxcp->vid);
-	} else {
-		netif_receive_skb(skb);
-	}
+	if (unlikely(rxcp->vlanf))
+		__vlan_hwaccel_put_tag(skb, rxcp->vid);
+
+	netif_receive_skb(skb);
 }
 
 /* Process the RX completion indicated by rxcp when GRO is enabled */
@@ -1074,10 +1061,10 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 	if (adapter->netdev->features & NETIF_F_RXHASH)
 		skb->rxhash = rxcp->rss_hash;
 
-	if (likely(!rxcp->vlanf))
-		napi_gro_frags(&eq_obj->napi);
-	else
-		vlan_gro_frags(&eq_obj->napi, adapter->vlan_grp, rxcp->vid);
+	if (unlikely(rxcp->vlanf))
+		__vlan_hwaccel_put_tag(skb, rxcp->vid);
+
+	napi_gro_frags(&eq_obj->napi);
 }
 
 static void be_parse_rx_compl_v1(struct be_adapter *adapter,
@@ -2171,7 +2158,7 @@ static int be_open(struct net_device *netdev)
 	be_async_mcc_enable(adapter);
 
 	status = be_cmd_link_status_query(adapter, &link_up, &mac_speed,
-			&link_speed);
+			&link_speed, 0);
 	if (status)
 		goto err;
 	be_link_status_update(adapter, link_up);
@@ -2613,7 +2600,6 @@ static struct net_device_ops be_netdev_ops = {
 	.ndo_set_mac_address	= be_mac_addr_set,
 	.ndo_change_mtu		= be_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_vlan_rx_register	= be_vlan_register,
 	.ndo_vlan_rx_add_vid	= be_vlan_add_vid,
 	.ndo_vlan_rx_kill_vid	= be_vlan_rem_vid,
 	.ndo_set_vf_mac		= be_set_vf_mac,
-- 
1.7.1

