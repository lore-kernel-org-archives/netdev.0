From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 9/10][IPMR]: Use on-device stats instead of private
 ones.
Date: Tue, 20 May 2008 20:43:36 +0400
Message-ID: <4832FFB8.3090705@openvz.org>
References: <4832FBD7.7040209@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:51433 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757203AbYETQqD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 12:46:03 -0400
In-Reply-To: <4832FBD7.7040209@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These devices use the private area of appropriate size for
statistics. Turning them to use on-device ones make them
"privless" and thus - really small wrt kmalloc cache, they
are allocated from.

Besides, code looks nicer, because of absence of multi-braced
type casts and dereferences.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ipmr.c |   25 +++++++++----------------
 1 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 65f1200..ddb25d9 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -181,26 +181,20 @@ static int reg_vif_num = -1;
 static int reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	read_lock(&mrt_lock);
-	((struct net_device_stats*)netdev_priv(dev))->tx_bytes += skb->len;
-	((struct net_device_stats*)netdev_priv(dev))->tx_packets++;
+	dev->stats->tx_bytes += skb->len;
+	dev->stats->tx_packets++;
 	ipmr_cache_report(skb, reg_vif_num, IGMPMSG_WHOLEPKT);
 	read_unlock(&mrt_lock);
 	kfree_skb(skb);
 	return 0;
 }
 
-static struct net_device_stats *reg_vif_get_stats(struct net_device *dev)
-{
-	return (struct net_device_stats*)netdev_priv(dev);
-}
-
 static void reg_vif_setup(struct net_device *dev)
 {
 	dev->type		= ARPHRD_PIMREG;
 	dev->mtu		= ETH_DATA_LEN - sizeof(struct iphdr) - 8;
 	dev->flags		= IFF_NOARP;
 	dev->hard_start_xmit	= reg_vif_xmit;
-	dev->get_stats		= reg_vif_get_stats;
 	dev->destructor		= free_netdev;
 }
 
@@ -209,8 +203,7 @@ static struct net_device *ipmr_reg_vif(void)
 	struct net_device *dev;
 	struct in_device *in_dev;
 
-	dev = alloc_netdev(sizeof(struct net_device_stats), "pimreg",
-			   reg_vif_setup);
+	dev = alloc_netdev(0, "pimreg", reg_vif_setup);
 
 	if (dev == NULL)
 		return NULL;
@@ -1170,8 +1163,8 @@ static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
 	if (vif->flags & VIFF_REGISTER) {
 		vif->pkt_out++;
 		vif->bytes_out+=skb->len;
-		((struct net_device_stats*)netdev_priv(vif->dev))->tx_bytes += skb->len;
-		((struct net_device_stats*)netdev_priv(vif->dev))->tx_packets++;
+		vif->dev->stats->tx_bytes += skb->len;
+		vif->dev->stats->tx_packets++;
 		ipmr_cache_report(skb, vifi, IGMPMSG_WHOLEPKT);
 		kfree_skb(skb);
 		return;
@@ -1487,8 +1480,8 @@ int pim_rcv_v1(struct sk_buff * skb)
 	skb->pkt_type = PACKET_HOST;
 	dst_release(skb->dst);
 	skb->dst = NULL;
-	((struct net_device_stats*)netdev_priv(reg_dev))->rx_bytes += skb->len;
-	((struct net_device_stats*)netdev_priv(reg_dev))->rx_packets++;
+	reg_dev->stats->rx_bytes += skb->len;
+	reg_dev->stats->rx_packets++;
 	nf_reset(skb);
 	netif_rx(skb);
 	dev_put(reg_dev);
@@ -1542,8 +1535,8 @@ static int pim_rcv(struct sk_buff * skb)
 	skb->ip_summed = 0;
 	skb->pkt_type = PACKET_HOST;
 	dst_release(skb->dst);
-	((struct net_device_stats*)netdev_priv(reg_dev))->rx_bytes += skb->len;
-	((struct net_device_stats*)netdev_priv(reg_dev))->rx_packets++;
+	reg_dev->stats->rx_bytes += skb->len;
+	reg_dev->stats->rx_packets++;
 	skb->dst = NULL;
 	nf_reset(skb);
 	netif_rx(skb);
-- 
1.5.3.4

