From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH net-next 4/6] sunvnet: add checksum offload support
Date: Tue, 02 Dec 2014 15:31:22 -0500
Message-ID: <547E219A.7010706@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31305 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933360AbaLBUb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 15:31:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for sender-side checksum offloading.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |   37 +++++++++++++++++++++++++++++++++--
 1 files changed, 34 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index b6a5336..b172eda 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -375,6 +375,8 @@ static int vnet_rx_one(struct vnet_port *port, struct vio_net_desc *desc)
 		}
 	}
 
+	skb->ip_summed = port->switch_port ? CHECKSUM_NONE : CHECKSUM_PARTIAL;
+
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += len;
 	napi_gro_receive(&port->napi, skb);
@@ -1047,7 +1049,8 @@ static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, int ncookies)
 	if (((unsigned long)skb->data & 7) != VNET_PACKET_SKIP ||
 	    skb_tailroom(skb) < pad ||
 	    skb_headroom(skb) < VNET_PACKET_SKIP || docopy) {
-		int offset;
+		int start = 0, offset;
+		__wsum csum;
 
 		len = skb->len > ETH_ZLEN ? skb->len : ETH_ZLEN;
 		nskb = alloc_and_align_skb(skb->dev, len);
@@ -1065,10 +1068,35 @@ static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, int ncookies)
 		offset = skb_transport_header(skb) - skb->data;
 		skb_set_transport_header(nskb, offset);
 
+		offset = 0;
 		nskb->csum_offset = skb->csum_offset;
 		nskb->ip_summed = skb->ip_summed;
 
-		if (skb_copy_bits(skb, 0, nskb->data, skb->len)) {
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
+			start = skb_checksum_start_offset(skb);
+		if (start) {
+			struct iphdr *iph = ip_hdr(nskb);
+			int offset = start + nskb->csum_offset;
+
+			if (skb_copy_bits(skb, 0, nskb->data, start)) {
+				dev_kfree_skb(nskb);
+				dev_kfree_skb(skb);
+				return NULL;
+			}
+			*(__sum16 *)(skb->data + offset) = 0;
+			csum = skb_copy_and_csum_bits(skb, start,
+						      nskb->data + start,
+						      skb->len - start, 0);
+			if (iph->protocol == IPPROTO_TCP ||
+			    iph->protocol == IPPROTO_UDP) {
+				csum = csum_tcpudp_magic(iph->saddr, iph->daddr,
+							 skb->len - start,
+							 iph->protocol, csum);
+			}
+			*(__sum16 *)(nskb->data + offset) = csum;
+
+			nskb->ip_summed = CHECKSUM_NONE;
+		} else if (skb_copy_bits(skb, 0, nskb->data, skb->len)) {
 			dev_kfree_skb(nskb);
 			dev_kfree_skb(skb);
 			return NULL;
@@ -1150,6 +1178,9 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto out_dropped;
 	}
 
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		vnet_fullcsum(skb);
+
 	dr = &port->vio.drings[VIO_DRIVER_TX_RING];
 	i = skb_get_queue_mapping(skb);
 	txq = netdev_get_tx_queue(dev, i);
@@ -1611,7 +1642,7 @@ static struct vnet *vnet_new(const u64 *local_mac)
 	dev->ethtool_ops = &vnet_ethtool_ops;
 	dev->watchdog_timeo = VNET_TX_TIMEOUT;
 
-	dev->hw_features = NETIF_F_SG;
+	dev->hw_features = NETIF_F_HW_CSUM | NETIF_F_SG;
 	dev->features = dev->hw_features;
 
 	err = register_netdev(dev);
-- 
1.7.1
