From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] vxlan: revert "vxlan: Bypass encapsulation if the destination is local"
Date: Tue,  9 Apr 2013 17:57:25 +0800
Message-ID: <1365501445-9712-1-git-send-email-amwang@redhat.com>
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51278 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758442Ab3DIJ5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 05:57:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

This reverts commit 9dcc71e1fdbb7aa10d92a3d35e8a201adc84abd0.
It apparently breaks my vxlan tests between different namespaces.

Cc: Sridhar Samudrala <sri@us.ibm.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/vxlan.c |   59 +++++++++++++-------------------------------------
 1 files changed, 16 insertions(+), 43 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 9a64715..62a4438 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -912,36 +912,6 @@ static int handle_offloads(struct sk_buff *skb)
 	return 0;
 }
 
-/* Bypass encapsulation if the destination is local */
-static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
-			       struct vxlan_dev *dst_vxlan)
-{
-	struct pcpu_tstats *tx_stats = this_cpu_ptr(src_vxlan->dev->tstats);
-	struct pcpu_tstats *rx_stats = this_cpu_ptr(dst_vxlan->dev->tstats);
-
-	skb->pkt_type = PACKET_HOST;
-	skb->encapsulation = 0;
-	skb->dev = dst_vxlan->dev;
-	__skb_pull(skb, skb_network_offset(skb));
-
-	if (dst_vxlan->flags & VXLAN_F_LEARN)
-		vxlan_snoop(skb->dev, INADDR_LOOPBACK, eth_hdr(skb)->h_source);
-
-	u64_stats_update_begin(&tx_stats->syncp);
-	tx_stats->tx_packets++;
-	tx_stats->tx_bytes += skb->len;
-	u64_stats_update_end(&tx_stats->syncp);
-
-	if (netif_rx(skb) == NET_RX_SUCCESS) {
-		u64_stats_update_begin(&rx_stats->syncp);
-		rx_stats->rx_packets++;
-		rx_stats->rx_bytes += skb->len;
-		u64_stats_update_end(&rx_stats->syncp);
-	} else {
-		skb->dev->stats.rx_dropped++;
-	}
-}
-
 static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 				  struct vxlan_rdst *rdst, bool did_rsc)
 {
@@ -952,6 +922,7 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct vxlanhdr *vxh;
 	struct udphdr *uh;
 	struct flowi4 fl4;
+	unsigned int pkt_len = skb->len;
 	__be32 dst;
 	__u16 src_port, dst_port;
         u32 vni;
@@ -964,8 +935,22 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 	if (!dst) {
 		if (did_rsc) {
+			__skb_pull(skb, skb_network_offset(skb));
+			skb->ip_summed = CHECKSUM_NONE;
+			skb->pkt_type = PACKET_HOST;
+
 			/* short-circuited back to local bridge */
-			vxlan_encap_bypass(skb, vxlan, vxlan);
+			if (netif_rx(skb) == NET_RX_SUCCESS) {
+				struct pcpu_tstats *stats = this_cpu_ptr(dev->tstats);
+
+				u64_stats_update_begin(&stats->syncp);
+				stats->tx_packets++;
+				stats->tx_bytes += pkt_len;
+				u64_stats_update_end(&stats->syncp);
+			} else {
+				dev->stats.tx_errors++;
+				dev->stats.tx_aborted_errors++;
+			}
 			return NETDEV_TX_OK;
 		}
 		goto drop;
@@ -1012,18 +997,6 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		goto tx_error;
 	}
 
-	/* Bypass encapsulation if the destination is local */
-	if (rt->rt_flags & RTCF_LOCAL) {
-		struct vxlan_dev *dst_vxlan;
-
-		ip_rt_put(rt);
-		dst_vxlan = vxlan_find_vni(dev_net(dev), vni);
-		if (!dst_vxlan)
-			goto tx_error;
-		vxlan_encap_bypass(skb, vxlan, dst_vxlan);
-		return NETDEV_TX_OK;
-	}
-
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
 			      IPSKB_REROUTED);
-- 
1.7.7.6
