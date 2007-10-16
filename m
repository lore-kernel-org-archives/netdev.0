From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 12/12] [NET]: Add netif_rerx_secpath
Date: Tue, 16 Oct 2007 22:33:20 +0800
Message-ID: <E1IhnU0-0003Ha-00@gondolin.me.apana.org.au>
References: <20071016141843.GA11956@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3001 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932715AbXJPOxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 10:53:47 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1Ihnnj-0001GY-Ju
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 00:53:43 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: Add netif_rerx_secpath

This patch follows on the netif_rerx addition.  A number of tunnels reinject
packets back into the stack in the way of netif_rerx.  They also need to
reset the security path since they're not part of the IPsec stack.

This patch creates the netif_rerx_secpath function which resets the security
path before calling netif_rerx.  It also uses them in the appropriate places.

The only spot of note is ipmr.c where we didn't reset the security path
before.  However, that is clearly oversight since PIM is certainly not
part of the IPsec stack.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/veth.c        |    7 +------
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |    9 +++++++++
 net/ipv4/ip_gre.c         |    9 ++-------
 net/ipv4/ipip.c           |    7 +------
 net/ipv4/ipmr.c           |   10 ++--------
 net/ipv6/ip6_tunnel.c     |    6 +-----
 net/ipv6/sit.c            |    5 +----
 8 files changed, 18 insertions(+), 36 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index fdd1e03..a19bc0c 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -14,7 +14,6 @@
 #include <linux/etherdevice.h>
 
 #include <net/dst.h>
-#include <net/xfrm.h>
 #include <net/veth.h>
 
 #define DRV_NAME	"veth"
@@ -172,11 +171,7 @@ static int veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (dev->features & NETIF_F_NO_CSUM)
 		skb->ip_summed = rcv_priv->ip_summed;
 
-	dst_release(skb->dst);
-	skb->dst = NULL;
 	skb->mark = 0;
-	secpath_reset(skb);
-	nf_reset(skb);
 
 	length = skb->len;
 
@@ -187,7 +182,7 @@ static int veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	stats->rx_bytes += length;
 	stats->rx_packets++;
 
-	netif_rx(skb);
+	netif_rerx_secpath(skb);
 	return 0;
 
 outf:
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 097f911..e19c696 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1040,6 +1040,7 @@ extern void dev_kfree_skb_any(struct sk_buff *skb);
 extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
 extern int		netif_rerx(struct sk_buff *skb);
+extern int		netif_rerx_secpath(struct sk_buff *skb);
 #define HAVE_NETIF_RECEIVE_SKB 1
 extern int		netif_receive_skb(struct sk_buff *skb);
 extern int		dev_valid_name(const char *name);
diff --git a/net/core/dev.c b/net/core/dev.c
index b753ec8..202c69a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -113,6 +113,7 @@
 #include <linux/delay.h>
 #include <net/wext.h>
 #include <net/iw_handler.h>
+#include <net/xfrm.h>
 #include <asm/current.h>
 #include <linux/audit.h>
 #include <linux/dmaengine.h>
@@ -1820,6 +1821,14 @@ int netif_rerx(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(netif_rerx);
 
+/* Reinject a packet without keeping the secpath. */
+int netif_rerx_secpath(struct sk_buff *skb)
+{
+	secpath_reset(skb);
+	return netif_rerx(skb);
+}
+EXPORT_SYMBOL(netif_rerx_secpath);
+
 static inline struct net_device *skb_bond(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index f151900..5882eaf 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -38,7 +38,7 @@
 #include <net/checksum.h>
 #include <net/dsfield.h>
 #include <net/inet_ecn.h>
-#include <net/xfrm.h>
+#include <net/route.h>
 
 #ifdef CONFIG_IPV6
 #include <net/ipv6.h>
@@ -599,8 +599,6 @@ static int ipgre_rcv(struct sk_buff *skb)
 
 	read_lock(&ipgre_lock);
 	if ((tunnel = ipgre_tunnel_lookup(iph->saddr, iph->daddr, key)) != NULL) {
-		secpath_reset(skb);
-
 		skb->protocol = *(__be16*)(h + 2);
 		/* WCCP version 1 and 2 protocol decoding.
 		 * - Change protocol to IP
@@ -646,11 +644,8 @@ static int ipgre_rcv(struct sk_buff *skb)
 		tunnel->stat.rx_packets++;
 		tunnel->stat.rx_bytes += skb->len;
 		skb->dev = tunnel->dev;
-		dst_release(skb->dst);
-		skb->dst = NULL;
-		nf_reset(skb);
 		ipgre_ecn_decapsulate(iph, skb);
-		netif_rx(skb);
+		netif_rerx_secpath(skb);
 		read_unlock(&ipgre_lock);
 		return(0);
 	}
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 5cd5bbe..cc78c8f 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -476,8 +476,6 @@ static int ipip_rcv(struct sk_buff *skb)
 			return 0;
 		}
 
-		secpath_reset(skb);
-
 		skb->mac_header = skb->network_header;
 		skb_reset_network_header(skb);
 		skb->protocol = htons(ETH_P_IP);
@@ -486,11 +484,8 @@ static int ipip_rcv(struct sk_buff *skb)
 		tunnel->stat.rx_packets++;
 		tunnel->stat.rx_bytes += skb->len;
 		skb->dev = tunnel->dev;
-		dst_release(skb->dst);
-		skb->dst = NULL;
-		nf_reset(skb);
 		ipip_ecn_decapsulate(iph, skb);
-		netif_rx(skb);
+		netif_rerx_secpath(skb);
 		read_unlock(&ipip_lock);
 		return 0;
 	}
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 37bb497..f0ad033 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1483,12 +1483,9 @@ int pim_rcv_v1(struct sk_buff * skb)
 	skb->protocol = htons(ETH_P_IP);
 	skb->ip_summed = 0;
 	skb->pkt_type = PACKET_HOST;
-	dst_release(skb->dst);
-	skb->dst = NULL;
 	((struct net_device_stats*)netdev_priv(reg_dev))->rx_bytes += skb->len;
 	((struct net_device_stats*)netdev_priv(reg_dev))->rx_packets++;
-	nf_reset(skb);
-	netif_rx(skb);
+	netif_rerx_secpath(skb);
 	dev_put(reg_dev);
 	return 0;
  drop:
@@ -1539,12 +1536,9 @@ static int pim_rcv(struct sk_buff * skb)
 	skb->protocol = htons(ETH_P_IP);
 	skb->ip_summed = 0;
 	skb->pkt_type = PACKET_HOST;
-	dst_release(skb->dst);
 	((struct net_device_stats*)netdev_priv(reg_dev))->rx_bytes += skb->len;
 	((struct net_device_stats*)netdev_priv(reg_dev))->rx_packets++;
-	skb->dst = NULL;
-	nf_reset(skb);
-	netif_rx(skb);
+	netif_rerx_secpath(skb);
 	dev_put(reg_dev);
 	return 0;
  drop:
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 2320cc2..2746ce0 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -699,22 +699,18 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 			read_unlock(&ip6_tnl_lock);
 			goto discard;
 		}
-		secpath_reset(skb);
 		skb->mac_header = skb->network_header;
 		skb_reset_network_header(skb);
 		skb->protocol = htons(protocol);
 		skb->pkt_type = PACKET_HOST;
 		memset(skb->cb, 0, sizeof(struct inet6_skb_parm));
 		skb->dev = t->dev;
-		dst_release(skb->dst);
-		skb->dst = NULL;
-		nf_reset(skb);
 
 		dscp_ecn_decapsulate(t, ipv6h, skb);
 
 		t->stat.rx_packets++;
 		t->stat.rx_bytes += skb->len;
-		netif_rx(skb);
+		netif_rerx_secpath(skb);
 		read_unlock(&ip6_tnl_lock);
 		return 0;
 	}
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 466657a..08081ef 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -385,11 +385,8 @@ static int ipip6_rcv(struct sk_buff *skb)
 		tunnel->stat.rx_packets++;
 		tunnel->stat.rx_bytes += skb->len;
 		skb->dev = tunnel->dev;
-		dst_release(skb->dst);
-		skb->dst = NULL;
-		nf_reset(skb);
 		ipip6_ecn_decapsulate(iph, skb);
-		netif_rx(skb);
+		netif_rerx_secpath(skb);
 		read_unlock(&ipip6_lock);
 		return 0;
 	}
