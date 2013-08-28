From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: [RFC PATCH net-next 2/4] skb: allow skb_scrub_packet() to
	be used by tunnels
Date: Wed, 28 Aug 2013 17:20:08 +0200
Message-ID: <1377703210-7021-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1377703210-7021-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1377703210-7021-1-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

This function was only used when a packet was sent to another netns. Now, it can
also be used after tunnel encapsulation or decapsulation.

Only skb_orphan() should not be done when a packet is not crossing netns.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
---
 include/linux/skbuff.h |  2 +-
 net/core/dev.c         |  2 +-
 net/core/skbuff.c      | 19 ++++++++++++-------
 net/ipv4/ip_tunnel.c   |  4 ++--
 net/ipv6/ip6_tunnel.c  |  4 ++--
 net/ipv6/sit.c         |  4 ++--
 6 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5ac96f31d546..a3eeabe7c04b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2392,7 +2392,7 @@ extern void	       skb_split(struct sk_buff *skb,
 				 struct sk_buff *skb1, const u32 len);
 extern int	       skb_shift(struct sk_buff *tgt, struct sk_buff *skb,
 				 int shiftlen);
-extern void	       skb_scrub_packet(struct sk_buff *skb);
+extern void	       skb_scrub_packet(struct sk_buff *skb, bool xnet);
 
 extern struct sk_buff *skb_segment(struct sk_buff *skb,
 				   netdev_features_t features);
diff --git a/net/core/dev.c b/net/core/dev.c
index 1ed2b66a10a6..d55493e72af6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1697,7 +1697,7 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 	 * call skb_scrub_packet() after it to clear pkt_type _after_ calling
 	 * eth_type_trans().
 	 */
-	skb_scrub_packet(skb);
+	skb_scrub_packet(skb, true);
 
 	return netif_rx(skb);
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2c3d0f53d198..d81cff119f73 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3500,17 +3500,22 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 EXPORT_SYMBOL(skb_try_coalesce);
 
 /**
- * skb_scrub_packet - scrub an skb before sending it to another netns
+ * skb_scrub_packet - scrub an skb
  *
  * @skb: buffer to clean
- *
- * skb_scrub_packet can be used to clean an skb before injecting it in
- * another namespace. We have to clear all information in the skb that
- * could impact namespace isolation.
+ * @xnet: packet is crossing netns
+ *
+ * skb_scrub_packet can be used after encapsulating or decapsulting a packet
+ * into/from a tunnel. Some information have to be cleared during these
+ * operations.
+ * skb_scrub_packet can also be used to clean a skb before injecting it in
+ * another namespace (@xnet == true). We have to clear all information in the
+ * skb that could impact namespace isolation.
  */
-void skb_scrub_packet(struct sk_buff *skb)
+void skb_scrub_packet(struct sk_buff *skb, bool xnet)
 {
-	skb_orphan(skb);
+	if (xnet)
+		skb_orphan(skb);
 	skb->tstamp.tv64 = 0;
 	skb->pkt_type = PACKET_HOST;
 	skb->skb_iif = 0;
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 0a6cf0e69478..b0e74e17088f 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -462,7 +462,7 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 	}
 
 	if (!net_eq(tunnel->net, dev_net(tunnel->dev)))
-		skb_scrub_packet(skb);
+		skb_scrub_packet(skb, true);
 
 	gro_cells_receive(&tunnel->gro_cells, skb);
 	return 0;
@@ -615,7 +615,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	if (!net_eq(tunnel->net, dev_net(dev)))
-		skb_scrub_packet(skb);
+		skb_scrub_packet(skb, true);
 
 	if (tunnel->err_count > 0) {
 		if (time_before(jiffies,
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index d6e00a39274c..72372ac90159 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -830,7 +830,7 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 		tstats->rx_bytes += skb->len;
 
 		if (!net_eq(t->net, dev_net(t->dev)))
-			skb_scrub_packet(skb);
+			skb_scrub_packet(skb, true);
 
 		netif_rx(skb);
 
@@ -1002,7 +1002,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	}
 
 	if (!net_eq(t->net, dev_net(dev)))
-		skb_scrub_packet(skb);
+		skb_scrub_packet(skb, true);
 
 	/*
 	 * Okay, now see if we can stuff it in the buffer as-is.
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 1d1458a3b7c4..b2e44f478e14 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -622,7 +622,7 @@ static int ipip6_rcv(struct sk_buff *skb)
 		tstats->rx_bytes += skb->len;
 
 		if (!net_eq(tunnel->net, dev_net(tunnel->dev)))
-			skb_scrub_packet(skb);
+			skb_scrub_packet(skb, true);
 		netif_rx(skb);
 
 		return 0;
@@ -861,7 +861,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	}
 
 	if (!net_eq(tunnel->net, dev_net(dev)))
-		skb_scrub_packet(skb);
+		skb_scrub_packet(skb, true);
 
 	/*
 	 * Okay, now see if we can stuff it in the buffer as-is.
-- 
1.8.2.1
