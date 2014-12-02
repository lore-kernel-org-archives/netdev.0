From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH net-next 5/6] sunvnet: add GSO support
Date: Tue, 02 Dec 2014 15:31:30 -0500
Message-ID: <547E21A2.3020605@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31388 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933360AbaLBUbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 15:31:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds GSO support to the sunvnet driver.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |   73 +++++++++++++++++++++++++++++++++++-
 1 files changed, 72 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index b172eda..d19b358 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -1102,6 +1102,10 @@ static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, int ncookies)
 			return NULL;
 		}
 		(void)skb_put(nskb, skb->len);
+		if (skb_is_gso(skb)) {
+			skb_shinfo(nskb)->gso_size = skb_shinfo(skb)->gso_size;
+			skb_shinfo(nskb)->gso_type = skb_shinfo(skb)->gso_type;
+		}
 		dev_kfree_skb(skb);
 		skb = nskb;
 	}
@@ -1120,6 +1124,66 @@ vnet_select_queue(struct net_device *dev, struct sk_buff *skb,
 	return port->q_index;
 }
 
+static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev);
+
+static int vnet_handle_offloads(struct vnet_port *port, struct sk_buff *skb)
+{
+	struct net_device *dev = port->vp->dev;
+	struct vio_dring_state *dr = &port->vio.drings[VIO_DRIVER_TX_RING];
+	struct sk_buff *segs;
+	int maclen;
+	int status;
+
+	if (unlikely(vnet_tx_dring_avail(dr) < skb_shinfo(skb)->gso_segs)) {
+		struct netdev_queue *txq;
+
+		txq  = netdev_get_tx_queue(dev, port->q_index);
+		netif_tx_stop_queue(txq);
+		if (vnet_tx_dring_avail(dr) < skb_shinfo(skb)->gso_segs)
+			return NETDEV_TX_BUSY;
+		netif_tx_wake_queue(txq);
+	}
+
+	maclen = skb_network_header(skb) - skb_mac_header(skb);
+	skb_pull(skb, maclen);
+
+	segs = skb_gso_segment(skb, dev->features & ~NETIF_F_TSO);
+	if (IS_ERR(segs)) {
+		dev->stats.tx_dropped++;
+		return NETDEV_TX_OK;
+	}
+
+	skb_push(skb, maclen);
+	skb_reset_mac_header(skb);
+
+	status = 0;
+	while (segs) {
+		struct sk_buff *curr = segs;
+
+		segs = segs->next;
+		curr->next = NULL;
+
+		skb_push(curr, maclen);
+		skb_reset_mac_header(curr);
+		memcpy(skb_mac_header(curr), skb_mac_header(skb),
+		       maclen);
+		curr->csum_start = skb_transport_header(curr) - curr->head;
+		if (ip_hdr(curr)->protocol == IPPROTO_TCP)
+			curr->csum_offset = offsetof(struct tcphdr, check);
+		else if (ip_hdr(curr)->protocol == IPPROTO_UDP)
+			curr->csum_offset = offsetof(struct udphdr, check);
+
+		if (!(status & NETDEV_TX_MASK))
+			status = vnet_start_xmit(curr, dev);
+		if (status & NETDEV_TX_MASK)
+			dev_kfree_skb_any(curr);
+	}
+
+	if (!(status & NETDEV_TX_MASK))
+		dev_kfree_skb_any(skb);
+	return status;
+}
+
 static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct vnet *vp = netdev_priv(dev);
@@ -1139,6 +1203,12 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto out_dropped;
 	}
 
+	if (skb_is_gso(skb)) {
+		err = vnet_handle_offloads(port, skb);
+		rcu_read_unlock();
+		return err;
+	}
+
 	if (skb->len > port->rmtu) {
 		unsigned long localmtu = port->rmtu - ETH_HLEN;
 
@@ -1642,7 +1712,8 @@ static struct vnet *vnet_new(const u64 *local_mac)
 	dev->ethtool_ops = &vnet_ethtool_ops;
 	dev->watchdog_timeo = VNET_TX_TIMEOUT;
 
-	dev->hw_features = NETIF_F_HW_CSUM | NETIF_F_SG;
+	dev->hw_features = NETIF_F_GSO | NETIF_F_GSO_SOFTWARE |
+			   NETIF_F_HW_CSUM | NETIF_F_SG;
 	dev->features = dev->hw_features;
 
 	err = register_netdev(dev);
-- 
1.7.1
