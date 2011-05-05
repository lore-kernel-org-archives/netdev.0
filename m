From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH] be2net: Fixed bugs related to PVID.
Date: Thu, 5 May 2011 14:10:46 +0530
Message-ID: <fe5f0791-266c-4fd7-9bfb-302b144c8a66@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:46909 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753193Ab1EEIhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 04:37:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed bug to make sure 'pvid' retrieval will work on big endian hosts.
Fixed incorrect comparison between the Rx Completion's 16-bit VLAN TCI
and the PVID. Now comparing only the relevant 12 bits corresponding to
the VID.
Renamed 'vid' field under Rx Completion to 'vlan_tag' to reflect
accurate description.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/benet/be.h      |    2 +-
 drivers/net/benet/be_cmds.c |    2 +-
 drivers/net/benet/be_main.c |   18 ++++++++++++------
 3 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 66823ed..2353eca 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -213,7 +213,7 @@ struct be_rx_stats {
 
 struct be_rx_compl_info {
 	u32 rss_hash;
-	u16 vid;
+	u16 vlan_tag;
 	u16 pkt_size;
 	u16 rxq_idx;
 	u16 mac_id;
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 1e2d825..9dc9394 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -132,7 +132,7 @@ static void be_async_grp5_pvid_state_process(struct be_adapter *adapter,
 		struct be_async_event_grp5_pvid_state *evt)
 {
 	if (evt->enabled)
-		adapter->pvid = evt->tag;
+		adapter->pvid = le16_to_cpu(evt->tag);
 	else
 		adapter->pvid = 0;
 }
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 02a0443..9187fb4 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1018,7 +1018,8 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 			kfree_skb(skb);
 			return;
 		}
-		vlan_hwaccel_receive_skb(skb, adapter->vlan_grp, rxcp->vid);
+		vlan_hwaccel_receive_skb(skb, adapter->vlan_grp,
+					rxcp->vlan_tag);
 	} else {
 		netif_receive_skb(skb);
 	}
@@ -1076,7 +1077,8 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 	if (likely(!rxcp->vlanf))
 		napi_gro_frags(&eq_obj->napi);
 	else
-		vlan_gro_frags(&eq_obj->napi, adapter->vlan_grp, rxcp->vid);
+		vlan_gro_frags(&eq_obj->napi, adapter->vlan_grp,
+				rxcp->vlan_tag);
 }
 
 static void be_parse_rx_compl_v1(struct be_adapter *adapter,
@@ -1102,7 +1104,8 @@ static void be_parse_rx_compl_v1(struct be_adapter *adapter,
 	rxcp->pkt_type =
 		AMAP_GET_BITS(struct amap_eth_rx_compl_v1, cast_enc, compl);
 	rxcp->vtm = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, vtm, compl);
-	rxcp->vid = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, vlan_tag, compl);
+	rxcp->vlan_tag = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, vlan_tag,
+					compl);
 }
 
 static void be_parse_rx_compl_v0(struct be_adapter *adapter,
@@ -1128,7 +1131,8 @@ static void be_parse_rx_compl_v0(struct be_adapter *adapter,
 	rxcp->pkt_type =
 		AMAP_GET_BITS(struct amap_eth_rx_compl_v0, cast_enc, compl);
 	rxcp->vtm = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, vtm, compl);
-	rxcp->vid = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, vlan_tag, compl);
+	rxcp->vlan_tag = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, vlan_tag,
+					compl);
 }
 
 static struct be_rx_compl_info *be_rx_compl_get(struct be_rx_obj *rxo)
@@ -1155,9 +1159,11 @@ static struct be_rx_compl_info *be_rx_compl_get(struct be_rx_obj *rxo)
 		rxcp->vlanf = 0;
 
 	if (!lancer_chip(adapter))
-		rxcp->vid = swab16(rxcp->vid);
+		rxcp->vlan_tag = swab16(rxcp->vlan_tag);
 
-	if ((adapter->pvid == rxcp->vid) && !adapter->vlan_tag[rxcp->vid])
+	if (((adapter->pvid & VLAN_VID_MASK) ==
+		(rxcp->vlan_tag & VLAN_VID_MASK)) &&
+		!adapter->vlan_tag[rxcp->vlan_tag])
 		rxcp->vlanf = 0;
 
 	/* As the compl has been parsed, reset it; we wont touch it again */
-- 
1.5.6.1

