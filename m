From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 2/2] cxgb4: update to utilize the newer VLAN infrastructure
Date: Thu, 21 Oct 2010 14:29:56 -0700
Message-ID: <1287696596-15175-3-git-send-email-dm@chelsio.com>
References: <1287696596-15175-1-git-send-email-dm@chelsio.com>
 <1287696596-15175-2-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27620 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757931Ab0JUV35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 17:29:57 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o9LLTu3P029217
	for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 14:29:57 -0700
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id o9LLTuSb015450
	for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 14:29:56 -0700
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id o9LLTueC015449
	for netdev@vger.kernel.org; Thu, 21 Oct 2010 14:29:56 -0700
In-Reply-To: <1287696596-15175-2-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4.h      |    1 -
 drivers/net/cxgb4/cxgb4_main.c |   31 +++++++++++++++++++------------
 drivers/net/cxgb4/sge.c        |   23 +++++------------------
 3 files changed, 24 insertions(+), 31 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
index eaa49e4..3d4253d 100644
--- a/drivers/net/cxgb4/cxgb4.h
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -281,7 +281,6 @@ struct sge_rspq;
 
 struct port_info {
 	struct adapter *adapter;
-	struct vlan_group *vlan_grp;
 	u16    viid;
 	s16    xact_addr_filt;        /* index of exact MAC address filter */
 	u16    rss_size;              /* size of VI's RSS table slice */
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index bc354ee..26a88a0 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -403,7 +403,7 @@ static int link_start(struct net_device *dev)
 	 * that step explicitly.
 	 */
 	ret = t4_set_rxmode(pi->adapter, mb, pi->viid, dev->mtu, -1, -1, -1,
-			    pi->vlan_grp != NULL, true);
+			    !!(dev->features & NETIF_F_HW_VLAN_RX), true);
 	if (ret == 0) {
 		ret = t4_change_mac(pi->adapter, mb, pi->viid,
 				    pi->xact_addr_filt, dev->dev_addr, true,
@@ -1881,7 +1881,24 @@ static int set_tso(struct net_device *dev, u32 value)
 
 static int set_flags(struct net_device *dev, u32 flags)
 {
-	return ethtool_op_set_flags(dev, flags, ETH_FLAG_RXHASH);
+	int err;
+	unsigned long old_feat = dev->features;
+
+	err = ethtool_op_set_flags(dev, flags, ETH_FLAG_RXHASH |
+				   ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN);
+	if (err)
+		return err;
+
+	if ((old_feat ^ dev->features) & NETIF_F_HW_VLAN_RX) {
+		const struct port_info *pi = netdev_priv(dev);
+
+		err = t4_set_rxmode(pi->adapter, pi->adapter->fn, pi->viid, -1,
+				    -1, -1, -1, !!(flags & ETH_FLAG_RXVLAN),
+				    true);
+		if (err)
+			dev->features = old_feat;
+	}
+	return err;
 }
 
 static int get_rss_table(struct net_device *dev, struct ethtool_rxfh_indir *p)
@@ -2841,15 +2858,6 @@ static int cxgb_set_mac_addr(struct net_device *dev, void *p)
 	return 0;
 }
 
-static void vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
-{
-	struct port_info *pi = netdev_priv(dev);
-
-	pi->vlan_grp = grp;
-	t4_set_rxmode(pi->adapter, pi->adapter->fn, pi->viid, -1, -1, -1, -1,
-		      grp != NULL, true);
-}
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void cxgb_netpoll(struct net_device *dev)
 {
@@ -2877,7 +2885,6 @@ static const struct net_device_ops cxgb4_netdev_ops = {
 	.ndo_validate_addr    = eth_validate_addr,
 	.ndo_do_ioctl         = cxgb_ioctl,
 	.ndo_change_mtu       = cxgb_change_mtu,
-	.ndo_vlan_rx_register = vlan_rx_register,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller  = cxgb_netpoll,
 #endif
diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index 9967f3d..1702225 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -1530,18 +1530,11 @@ static void do_gro(struct sge_eth_rxq *rxq, const struct pkt_gl *gl,
 		skb->rxhash = (__force u32)pkt->rsshdr.hash_val;
 
 	if (unlikely(pkt->vlan_ex)) {
-		struct port_info *pi = netdev_priv(rxq->rspq.netdev);
-		struct vlan_group *grp = pi->vlan_grp;
-
+		__vlan_hwaccel_put_tag(skb, ntohs(pkt->vlan));
 		rxq->stats.vlan_ex++;
-		if (likely(grp)) {
-			ret = vlan_gro_frags(&rxq->rspq.napi, grp,
-					     ntohs(pkt->vlan));
-			goto stats;
-		}
 	}
 	ret = napi_gro_frags(&rxq->rspq.napi);
-stats:	if (ret == GRO_HELD)
+	if (ret == GRO_HELD)
 		rxq->stats.lro_pkts++;
 	else if (ret == GRO_MERGED || ret == GRO_MERGED_FREE)
 		rxq->stats.lro_merged++;
@@ -1608,16 +1601,10 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 		skb_checksum_none_assert(skb);
 
 	if (unlikely(pkt->vlan_ex)) {
-		struct vlan_group *grp = pi->vlan_grp;
-
+		__vlan_hwaccel_put_tag(skb, ntohs(pkt->vlan));
 		rxq->stats.vlan_ex++;
-		if (likely(grp))
-			vlan_hwaccel_receive_skb(skb, grp, ntohs(pkt->vlan));
-		else
-			dev_kfree_skb_any(skb);
-	} else
-		netif_receive_skb(skb);
-
+	}
+	netif_receive_skb(skb);
 	return 0;
 }
 
-- 
1.5.4

