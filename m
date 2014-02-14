From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC v4 10/12] vti4: Support inter address family tunneling.
Date: Fri, 14 Feb 2014 09:30:18 +0100
Message-ID: <1392366620-31923-11-git-send-email-steffen.klassert@secunet.com>
References: <1392366620-31923-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Christophe Gouault <christophe.gouault@6wind.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39137 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752112AbaBNIau (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 03:30:50 -0500
In-Reply-To: <1392366620-31923-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch we can tunnel ipv6 traffic via a vti4
interface. A vti4 interface can now have an ipv6 address
and ipv6 traffic can be routed via a vti4 interface.
The resulting traffic is xfrm transformed and tunneled
throuhg ipv4 if matching IPsec policies and states are
present.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_vti.c |   48 ++++++++++++++++++++++++++++++++++--------------
 1 file changed, 34 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 0dc341d..9369b7c 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -34,6 +34,7 @@
 #include <linux/init.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/if_ether.h>
+#include <linux/icmpv6.h>
 
 #include <net/sock.h>
 #include <net/ip.h>
@@ -122,31 +123,21 @@ static int vti_rcv_cb(struct sk_buff *skb, int err)
 	return 0;
 }
 
-/* This function assumes it is being called from dev_queue_xmit()
- * and that skb is filled properly by that function.
- */
-static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t vti_xmit(struct sk_buff *skb, struct net_device *dev,
+			    struct flowi *fl)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct dst_entry *dst = skb_dst(skb);
 	struct net_device *tdev;	/* Device to other host */
-	struct flowi fl;
 	int err;
 
-	if (skb->protocol != htons(ETH_P_IP))
-		goto tx_error;
-
-	memset(&fl, 0, sizeof(fl));
-	skb->mark = be32_to_cpu(tunnel->parms.o_key);
-	xfrm_decode_session(skb, &fl, AF_INET);
-
 	if (!dst) {
 		dev->stats.tx_carrier_errors++;
 		goto tx_error_icmp;
 	}
 
 	dst_hold(dst);
-	dst = xfrm_lookup(tunnel->net, dst, &fl, NULL, 0);
+	dst = xfrm_lookup(tunnel->net, dst, fl, NULL, 0);
 	if (IS_ERR(dst)) {
 		dev->stats.tx_carrier_errors++;
 		goto tx_error_icmp;
@@ -178,7 +169,6 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			tunnel->err_count = 0;
 	}
 
-	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 	skb_scrub_packet(skb, !net_eq(tunnel->net, dev_net(dev)));
 	skb_dst_set(skb, dst);
 	skb->dev = skb_dst(skb)->dev;
@@ -197,6 +187,36 @@ tx_error:
 	return NETDEV_TX_OK;
 }
 
+/* This function assumes it is being called from dev_queue_xmit()
+ * and that skb is filled properly by that function.
+ */
+static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct flowi fl;
+
+	memset(&fl, 0, sizeof(fl));
+
+	skb->mark = be32_to_cpu(tunnel->parms.o_key);
+
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+		xfrm_decode_session(skb, &fl, AF_INET);
+		memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
+		break;
+	case htons(ETH_P_IPV6):
+		xfrm_decode_session(skb, &fl, AF_INET6);
+		memset(IP6CB(skb), 0, sizeof(*IP6CB(skb)));
+		break;
+	default:
+		dev->stats.tx_errors++;
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
+	return vti_xmit(skb, dev, &fl);
+}
+
 static int vti4_err(struct sk_buff *skb, u32 info)
 {
 	__be32 spi;
-- 
1.7.9.5
