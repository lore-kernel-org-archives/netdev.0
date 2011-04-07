From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 1/5] be2net: add rxhash support
Date: Wed, 6 Apr 2011 23:07:43 -0500
Message-ID: <20110407040743.GA4183@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:55047 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750714Ab1DGEIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 00:08:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add rxhash support,
Based on initial work by Eric Dumazet.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be.h         |    5 +++++
 drivers/net/benet/be_ethtool.c |   13 +++++++++++++
 drivers/net/benet/be_main.c    |   17 ++++++++++++-----
 3 files changed, 30 insertions(+), 5 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 0899d91..8941b98 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -485,6 +485,11 @@ static inline void be_vf_eth_addr_generate(struct be_adapter *adapter, u8 *mac)
 	memcpy(mac, adapter->netdev->dev_addr, 3);
 }
 
+static inline bool be_multi_rxq(struct be_adapter *adapter)
+{
+	return (adapter->num_rx_qs > 1);
+}
+
 extern void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
 		u16 num_popped);
 extern void be_link_status_update(struct be_adapter *adapter, bool link_up);
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index a665697..1565c81 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -735,6 +735,18 @@ be_read_eeprom(struct net_device *netdev, struct ethtool_eeprom *eeprom,
 	return status;
 }
 
+static int be_set_flags(struct net_device *netdev, u32 data)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	int rc = -1;
+
+	if (be_multi_rxq(adapter))
+		rc = ethtool_op_set_flags(netdev, data, ETH_FLAG_RXHASH |
+				ETH_FLAG_TXVLAN | ETH_FLAG_RXVLAN);
+
+	return rc;
+}
+
 const struct ethtool_ops be_ethtool_ops = {
 	.get_settings = be_get_settings,
 	.get_drvinfo = be_get_drvinfo,
@@ -764,4 +776,5 @@ const struct ethtool_ops be_ethtool_ops = {
 	.get_regs = be_get_regs,
 	.flash_device = be_do_flash,
 	.self_test = be_self_test,
+	.set_flags = be_set_flags,
 };
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index a24fb45..4910055 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -116,11 +116,6 @@ static char *ue_status_hi_desc[] = {
 	"Unknown"
 };
 
-static inline bool be_multi_rxq(struct be_adapter *adapter)
-{
-	return (adapter->num_rx_qs > 1);
-}
-
 static void be_queue_free(struct be_adapter *adapter, struct be_queue_info *q)
 {
 	struct be_dma_mem *mem = &q->dma_mem;
@@ -1012,6 +1007,9 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 
 	skb->truesize = skb->len + sizeof(struct sk_buff);
 	skb->protocol = eth_type_trans(skb, adapter->netdev);
+	if (adapter->netdev->features & NETIF_F_RXHASH)
+		skb->rxhash = rxcp->rss_hash;
+
 
 	if (unlikely(rxcp->vlanf)) {
 		if (!adapter->vlan_grp || adapter->vlans_added == 0) {
@@ -1072,6 +1070,8 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 	skb->data_len = rxcp->pkt_size;
 	skb->truesize += rxcp->pkt_size;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
+	if (adapter->netdev->features & NETIF_F_RXHASH)
+		skb->rxhash = rxcp->rss_hash;
 
 	if (likely(!rxcp->vlanf))
 		napi_gro_frags(&eq_obj->napi);
@@ -1101,6 +1101,8 @@ static void be_parse_rx_compl_v1(struct be_adapter *adapter,
 		AMAP_GET_BITS(struct amap_eth_rx_compl_v1, numfrags, compl);
 	rxcp->pkt_type =
 		AMAP_GET_BITS(struct amap_eth_rx_compl_v1, cast_enc, compl);
+	rxcp->rss_hash =
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v1, rsshash, rxcp);
 	if (rxcp->vlanf) {
 		rxcp->vtm = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, vtm,
 				compl);
@@ -1131,6 +1133,8 @@ static void be_parse_rx_compl_v0(struct be_adapter *adapter,
 		AMAP_GET_BITS(struct amap_eth_rx_compl_v0, numfrags, compl);
 	rxcp->pkt_type =
 		AMAP_GET_BITS(struct amap_eth_rx_compl_v0, cast_enc, compl);
+	rxcp->rss_hash =
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v0, rsshash, rxcp);
 	if (rxcp->vlanf) {
 		rxcp->vtm = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, vtm,
 				compl);
@@ -2614,6 +2618,9 @@ static void be_netdev_init(struct net_device *netdev)
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		NETIF_F_GRO | NETIF_F_TSO6;
 
+	if (be_multi_rxq(adapter))
+		netdev->features |= NETIF_F_RXHASH;
+
 	netdev->vlan_features |= NETIF_F_SG | NETIF_F_TSO |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 
-- 
1.7.1

