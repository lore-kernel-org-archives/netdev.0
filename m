From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 14/47] cxgb4vf: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:16 +0200
Message-ID: <1311173689-17419-15-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	leedom@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18726 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751752Ab1GTOzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:21 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill pi->vlan_grp and cxgb4vf_vlan_rx_register
- allow to turn on/off rx/tx vlan accel via ethtool (set_features)

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/cxgb4vf/adapter.h      |    1 -
 drivers/net/cxgb4vf/cxgb4vf_main.c |   50 +++++++++++++++++++++++------------
 drivers/net/cxgb4vf/sge.c          |   34 +++++-------------------
 3 files changed, 40 insertions(+), 45 deletions(-)

diff --git a/drivers/net/cxgb4vf/adapter.h b/drivers/net/cxgb4vf/adapter.h
index 6e9a8d9..594334d 100644
--- a/drivers/net/cxgb4vf/adapter.h
+++ b/drivers/net/cxgb4vf/adapter.h
@@ -92,7 +92,6 @@ struct sge_rspq;
  */
 struct port_info {
 	struct adapter *adapter;	/* our adapter */
-	struct vlan_group *vlan_grp;	/* out VLAN group */
 	u16 viid;			/* virtual interface ID */
 	s16 xact_addr_filt;		/* index of our MAC address filter */
 	u16 rss_size;			/* size of VI's RSS table slice */
diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 3942a82..ec79913 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -209,18 +209,8 @@ void t4vf_os_link_changed(struct adapter *adapter, int pidx, int link_ok)
  * ======================
  */
 
-/*
- * Record our new VLAN Group and enable/disable hardware VLAN Tag extraction
- * based on whether the specified VLAN Group pointer is NULL or not.
- */
-static void cxgb4vf_vlan_rx_register(struct net_device *dev,
-				     struct vlan_group *grp)
-{
-	struct port_info *pi = netdev_priv(dev);
 
-	pi->vlan_grp = grp;
-	t4vf_set_rxmode(pi->adapter, pi->viid, -1, -1, -1, -1, grp != NULL, 0);
-}
+
 
 /*
  * Perform the MAC and PHY actions needed to enable a "port" (Virtual
@@ -233,9 +223,9 @@ static int link_start(struct net_device *dev)
 
 	/*
 	 * We do not set address filters and promiscuity here, the stack does
-	 * that step explicitly.
+	 * that step explicitly. Enable vlan accel.
 	 */
-	ret = t4vf_set_rxmode(pi->adapter, pi->viid, dev->mtu, -1, -1, -1, -1,
+	ret = t4vf_set_rxmode(pi->adapter, pi->viid, dev->mtu, -1, -1, -1, 1,
 			      true);
 	if (ret == 0) {
 		ret = t4vf_change_mac(pi->adapter, pi->viid,
@@ -1102,6 +1092,32 @@ static int cxgb4vf_change_mtu(struct net_device *dev, int new_mtu)
 	return ret;
 }
 
+static u32 cxgb4vf_fix_features(struct net_device *dev, u32 features)
+{
+	/*
+	 * Since there is no support for separate rx/tx vlan accel
+	 * enable/disable make sure tx flag is always in same state as rx.
+	 */
+	if (features & NETIF_F_HW_VLAN_RX)
+		features |= NETIF_F_HW_VLAN_TX;
+	else
+		features &= ~NETIF_F_HW_VLAN_TX;
+
+	return features;
+}
+
+static int cxgb4vf_set_features(struct net_device *dev, u32 features)
+{
+	struct port_info *pi = netdev_priv(dev);
+	u32 changed = dev->features ^ features;
+
+	if (changed & NETIF_F_HW_VLAN_RX)
+		t4vf_set_rxmode(pi->adapter, pi->viid, -1, -1, -1, -1,
+				features & NETIF_F_HW_VLAN_TX, 0);
+
+	return 0;
+}
+
 /*
  * Change the devices MAC address.
  */
@@ -2431,7 +2447,8 @@ static const struct net_device_ops cxgb4vf_netdev_ops	= {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= cxgb4vf_do_ioctl,
 	.ndo_change_mtu		= cxgb4vf_change_mtu,
-	.ndo_vlan_rx_register	= cxgb4vf_vlan_rx_register,
+	.ndo_fix_features	= cxgb4vf_fix_features,
+	.ndo_set_features	= cxgb4vf_set_features,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= cxgb4vf_poll_controller,
 #endif
@@ -2600,12 +2617,11 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
 
 		netdev->hw_features = NETIF_F_SG | TSO_FLAGS |
 			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-			NETIF_F_HW_VLAN_TX | NETIF_F_RXCSUM;
+			NETIF_F_HW_VLAN_RX | NETIF_F_RXCSUM;
 		netdev->vlan_features = NETIF_F_SG | TSO_FLAGS |
 			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 			NETIF_F_HIGHDMA;
-		netdev->features = netdev->hw_features |
-			NETIF_F_HW_VLAN_RX;
+		netdev->features = netdev->hw_features | NETIF_F_HW_VLAN_TX;
 		if (pci_using_dac)
 			netdev->features |= NETIF_F_HIGHDMA;
 
diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index 5fd75fd..cffb328 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -1491,20 +1491,10 @@ static void do_gro(struct sge_eth_rxq *rxq, const struct pkt_gl *gl,
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb_record_rx_queue(skb, rxq->rspq.idx);
 
-	if (unlikely(pkt->vlan_ex)) {
-		struct port_info *pi = netdev_priv(rxq->rspq.netdev);
-		struct vlan_group *grp = pi->vlan_grp;
-
-		rxq->stats.vlan_ex++;
-		if (likely(grp)) {
-			ret = vlan_gro_frags(&rxq->rspq.napi, grp,
-					     be16_to_cpu(pkt->vlan));
-			goto stats;
-		}
-	}
+	if (pkt->vlan_ex)
+		__vlan_hwaccel_put_tag(skb, be16_to_cpu(pkt->vlan));
 	ret = napi_gro_frags(&rxq->rspq.napi);
 
-stats:
 	if (ret == GRO_HELD)
 		rxq->stats.lro_pkts++;
 	else if (ret == GRO_MERGED || ret == GRO_MERGED_FREE)
@@ -1525,7 +1515,6 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 		       const struct pkt_gl *gl)
 {
 	struct sk_buff *skb;
-	struct port_info *pi;
 	const struct cpl_rx_pkt *pkt = (void *)&rsp[1];
 	bool csum_ok = pkt->csum_calc && !pkt->err_vec;
 	struct sge_eth_rxq *rxq = container_of(rspq, struct sge_eth_rxq, rspq);
@@ -1553,7 +1542,6 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 	__skb_pull(skb, PKTSHIFT);
 	skb->protocol = eth_type_trans(skb, rspq->netdev);
 	skb_record_rx_queue(skb, rspq->idx);
-	pi = netdev_priv(skb->dev);
 	rxq->stats.pkts++;
 
 	if (csum_ok && (rspq->netdev->features & NETIF_F_RXCSUM) &&
@@ -1569,20 +1557,12 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 	} else
 		skb_checksum_none_assert(skb);
 
-	/*
-	 * Deliver the packet to the stack.
-	 */
-	if (unlikely(pkt->vlan_ex)) {
-		struct vlan_group *grp = pi->vlan_grp;
-
+	if (pkt->vlan_ex) {
 		rxq->stats.vlan_ex++;
-		if (likely(grp))
-			vlan_hwaccel_receive_skb(skb, grp,
-						 be16_to_cpu(pkt->vlan));
-		else
-			dev_kfree_skb_any(skb);
-	} else
-		netif_receive_skb(skb);
+		__vlan_hwaccel_put_tag(skb, be16_to_cpu(pkt->vlan));
+	}
+
+	netif_receive_skb(skb);
 
 	return 0;
 }
-- 
1.7.6

