From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 8/10][IP6TNL]: Use on-device stats instead of private
 ones.
Date: Tue, 20 May 2008 20:41:07 +0400
Message-ID: <4832FF23.3060704@openvz.org>
References: <4832FBD7.7040209@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:45659 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761692AbYETQnf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 12:43:35 -0400
In-Reply-To: <4832FBD7.7040209@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This tunnel uses its own private structure and requires separate
patch to switch from private stats to on-device ones.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/ip6_tunnel.h |    1 -
 net/ipv6/ip6_tunnel.c    |   26 ++++++--------------------
 2 files changed, 6 insertions(+), 21 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 6512d85..3780592 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -19,7 +19,6 @@
 struct ip6_tnl {
 	struct ip6_tnl *next;	/* next tunnel in list */
 	struct net_device *dev;	/* virtual device associated with tunnel */
-	struct net_device_stats stat;	/* statistics for tunnel device */
 	int recursion;		/* depth of hard_start_xmit recursion */
 	struct ip6_tnl_parm parms;	/* tunnel configuration parameters */
 	struct flowi fl;	/* flowi template for xmit */
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 2bda3ba..3781481 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -711,7 +711,7 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 		}
 
 		if (!ip6_tnl_rcv_ctl(t)) {
-			t->stat.rx_dropped++;
+			t->dev->stats.rx_dropped++;
 			read_unlock(&ip6_tnl_lock);
 			goto discard;
 		}
@@ -728,8 +728,8 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 
 		dscp_ecn_decapsulate(t, ipv6h, skb);
 
-		t->stat.rx_packets++;
-		t->stat.rx_bytes += skb->len;
+		t->dev->stats.rx_packets++;
+		t->dev->stats.rx_bytes += skb->len;
 		netif_rx(skb);
 		read_unlock(&ip6_tnl_lock);
 		return 0;
@@ -849,7 +849,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 			 __u32 *pmtu)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
-	struct net_device_stats *stats = &t->stat;
+	struct net_device_stats *stats = &t->dev->stats;
 	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 	struct ipv6_tel_txoption opt;
 	struct dst_entry *dst;
@@ -1043,11 +1043,11 @@ static int
 ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
-	struct net_device_stats *stats = &t->stat;
+	struct net_device_stats *stats = &t->dev->stats;
 	int ret;
 
 	if (t->recursion++) {
-		t->stat.collisions++;
+		stats->collisions++;
 		goto tx_err;
 	}
 
@@ -1289,19 +1289,6 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 }
 
 /**
- * ip6_tnl_get_stats - return the stats for tunnel device
- *   @dev: virtual device associated with tunnel
- *
- * Return: stats for device
- **/
-
-static struct net_device_stats *
-ip6_tnl_get_stats(struct net_device *dev)
-{
-	return &(((struct ip6_tnl *)netdev_priv(dev))->stat);
-}
-
-/**
  * ip6_tnl_change_mtu - change mtu manually for tunnel device
  *   @dev: virtual device associated with tunnel
  *   @new_mtu: the new mtu
@@ -1334,7 +1321,6 @@ static void ip6_tnl_dev_setup(struct net_device *dev)
 	dev->uninit = ip6_tnl_dev_uninit;
 	dev->destructor = free_netdev;
 	dev->hard_start_xmit = ip6_tnl_xmit;
-	dev->get_stats = ip6_tnl_get_stats;
 	dev->do_ioctl = ip6_tnl_ioctl;
 	dev->change_mtu = ip6_tnl_change_mtu;
 
-- 
1.5.3.4

