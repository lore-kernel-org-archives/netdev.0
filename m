From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next] vxlan: Bypass encapsulation if the destination is
 local
Date: Tue, 02 Apr 2013 11:10:42 -0700
Message-ID: <1364926242.29336.32.camel@oc1677441337.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com, davem@davemloft.net, dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:38496 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759718Ab3DBSLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 14:11:00 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Tue, 2 Apr 2013 12:11:00 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 3B81819D8065
	for <netdev@vger.kernel.org>; Tue,  2 Apr 2013 12:10:51 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r32IAiKO056244
	for <netdev@vger.kernel.org>; Tue, 2 Apr 2013 12:10:47 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r32IAiC2029248
	for <netdev@vger.kernel.org>; Tue, 2 Apr 2013 12:10:44 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch bypasses vxlan encapsulation if the destination vxlan
endpoint is a local device.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
---

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 62a4438..2ad2311 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -912,6 +912,36 @@ static int handle_offloads(struct sk_buff *skb)
 	return 0;
 }
 
+/* Bypass encapsulation if the destination is local */
+static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
+			       struct vxlan_dev *dst_vxlan)
+{
+	struct pcpu_tstats *tx_stats = this_cpu_ptr(src_vxlan->dev->tstats);
+	struct pcpu_tstats *rx_stats = this_cpu_ptr(dst_vxlan->dev->tstats);
+
+	skb->pkt_type = PACKET_HOST;
+	skb->encapsulation = 0;
+	skb->dev = dst_vxlan->dev;
+	__skb_pull(skb, skb_network_offset(skb));
+
+	if (dst_vxlan->flags & VXLAN_F_LEARN)
+		vxlan_snoop(skb->dev, INADDR_LOOPBACK, eth_hdr(skb)->h_source);
+
+	u64_stats_update_begin(&tx_stats->syncp);
+	tx_stats->tx_packets++;
+	tx_stats->tx_bytes += skb->len;
+	u64_stats_update_end(&tx_stats->syncp);
+
+	if (netif_rx(skb) == NET_RX_SUCCESS) {
+		u64_stats_update_begin(&rx_stats->syncp);
+		rx_stats->rx_packets++;
+		rx_stats->rx_bytes += skb->len;
+		u64_stats_update_end(&rx_stats->syncp);
+	} else {
+		skb->dev->stats.rx_dropped++;
+	}
+}
+
 static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 				  struct vxlan_rdst *rdst, bool did_rsc)
 {
@@ -922,7 +952,6 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct vxlanhdr *vxh;
 	struct udphdr *uh;
 	struct flowi4 fl4;
-	unsigned int pkt_len = skb->len;
 	__be32 dst;
 	__u16 src_port, dst_port;
         u32 vni;
@@ -935,22 +964,8 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 	if (!dst) {
 		if (did_rsc) {
-			__skb_pull(skb, skb_network_offset(skb));
-			skb->ip_summed = CHECKSUM_NONE;
-			skb->pkt_type = PACKET_HOST;
-
 			/* short-circuited back to local bridge */
-			if (netif_rx(skb) == NET_RX_SUCCESS) {
-				struct pcpu_tstats *stats = this_cpu_ptr(dev->tstats);
-
-				u64_stats_update_begin(&stats->syncp);
-				stats->tx_packets++;
-				stats->tx_bytes += pkt_len;
-				u64_stats_update_end(&stats->syncp);
-			} else {
-				dev->stats.tx_errors++;
-				dev->stats.tx_aborted_errors++;
-			}
+			vxlan_encap_bypass(skb, vxlan, vxlan);
 			return NETDEV_TX_OK;
 		}
 		goto drop;
@@ -997,6 +1012,16 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		goto tx_error;
 	}
 
+	/* Bypass encapsulation if the destination is local */
+	if (rt->rt_flags & RTCF_LOCAL) {
+		struct vxlan_dev *dst_vxlan;
+
+		dst_vxlan = vxlan_find_vni(dev_net(dev), vni);
+		vxlan_encap_bypass(skb, vxlan, dst_vxlan);
+		ip_rt_put(rt);
+		return NETDEV_TX_OK;
+	}
+
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
 			      IPSKB_REROUTED);
