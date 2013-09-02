From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v2 5/5] tunnels: harmonize cleanup done
	on skb on rx path
Date: Mon,  2 Sep 2013 15:34:58 +0200
Message-ID: <1378128898-15136-6-git-send-email-nicolas.dichtel@6wind.com>
References: <CALnjE+pKi=p0y2ot2qWG1w=pxEUcPUKY+_UUi0RXbnGqVk9poA@mail.gmail.com>
	<1378128898-15136-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1378128898-15136-1-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
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

The goal of this patch is to harmonize cleanup done on a skbuff on rx path.
Before this patch, behaviors were different depending of the tunnel type.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
---
 include/net/dst.h     | 12 +++++++-----
 net/ipv4/ip_tunnel.c  |  3 +--
 net/ipv4/ipmr.c       |  3 +--
 net/ipv6/ip6_gre.c    |  5 +----
 net/ipv6/ip6_tunnel.c |  7 +------
 net/ipv6/ip6mr.c      |  3 +--
 net/ipv6/sit.c        |  6 +-----
 7 files changed, 13 insertions(+), 26 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 1f8fd109e225..3bc4865f8267 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -311,11 +311,13 @@ static inline void skb_dst_force(struct sk_buff *skb)
  *	__skb_tunnel_rx - prepare skb for rx reinsert
  *	@skb: buffer
  *	@dev: tunnel device
+ *	@net: netns for packet i/o
  *
  *	After decapsulation, packet is going to re-enter (netif_rx()) our stack,
  *	so make some cleanups. (no accounting done)
  */
-static inline void __skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev)
+static inline void __skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev,
+				   struct net *net)
 {
 	skb->dev = dev;
 
@@ -327,8 +329,7 @@ static inline void __skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev)
 	if (!skb->l4_rxhash)
 		skb->rxhash = 0;
 	skb_set_queue_mapping(skb, 0);
-	skb_dst_drop(skb);
-	nf_reset(skb);
+	skb_scrub_packet(skb, !net_eq(net, dev_net(dev)));
 }
 
 /**
@@ -340,12 +341,13 @@ static inline void __skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev)
  *	so make some cleanups, and perform accounting.
  *	Note: this accounting is not SMP safe.
  */
-static inline void skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev)
+static inline void skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev,
+				 struct net *net)
 {
 	/* TODO : stats should be SMP safe */
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += skb->len;
-	__skb_tunnel_rx(skb, dev);
+	__skb_tunnel_rx(skb, dev, net);
 }
 
 /* Children define the path of the packet through the
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 88d7d7d1eccb..ac9fabe0300f 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -461,8 +461,7 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 		skb->dev = tunnel->dev;
 	}
 
-	if (!net_eq(tunnel->net, dev_net(tunnel->dev)))
-		skb_scrub_packet(skb, true);
+	skb_scrub_packet(skb, !net_eq(tunnel->net, dev_net(tunnel->dev)));
 
 	gro_cells_receive(&tunnel->gro_cells, skb);
 	return 0;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index bacc0bcf48ce..9ae54b09254f 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2067,9 +2067,8 @@ static int __pim_rcv(struct mr_table *mrt, struct sk_buff *skb,
 	skb_reset_network_header(skb);
 	skb->protocol = htons(ETH_P_IP);
 	skb->ip_summed = CHECKSUM_NONE;
-	skb->pkt_type = PACKET_HOST;
 
-	skb_tunnel_rx(skb, reg_dev);
+	skb_tunnel_rx(skb, reg_dev, dev_net(reg_dev));
 
 	netif_rx(skb);
 
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index f179ff1f56ec..db992a373011 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -509,8 +509,6 @@ static int ip6gre_rcv(struct sk_buff *skb)
 			goto drop;
 		}
 
-		secpath_reset(skb);
-
 		skb->protocol = gre_proto;
 		/* WCCP version 1 and 2 protocol decoding.
 		 * - Change protocol to IP
@@ -525,7 +523,6 @@ static int ip6gre_rcv(struct sk_buff *skb)
 		skb->mac_header = skb->network_header;
 		__pskb_pull(skb, offset);
 		skb_postpull_rcsum(skb, skb_transport_header(skb), offset);
-		skb->pkt_type = PACKET_HOST;
 
 		if (((flags&GRE_CSUM) && csum) ||
 		    (!(flags&GRE_CSUM) && tunnel->parms.i_flags&GRE_CSUM)) {
@@ -557,7 +554,7 @@ static int ip6gre_rcv(struct sk_buff *skb)
 			skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 		}
 
-		__skb_tunnel_rx(skb, tunnel->dev);
+		__skb_tunnel_rx(skb, tunnel->dev, tunnel->net);
 
 		skb_reset_network_header(skb);
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index ecbcdbd4bc4f..55999d923f26 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -802,14 +802,12 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 			rcu_read_unlock();
 			goto discard;
 		}
-		secpath_reset(skb);
 		skb->mac_header = skb->network_header;
 		skb_reset_network_header(skb);
 		skb->protocol = htons(protocol);
-		skb->pkt_type = PACKET_HOST;
 		memset(skb->cb, 0, sizeof(struct inet6_skb_parm));
 
-		__skb_tunnel_rx(skb, t->dev);
+		__skb_tunnel_rx(skb, t->dev, t->net);
 
 		err = dscp_ecn_decapsulate(t, ipv6h, skb);
 		if (unlikely(err)) {
@@ -829,9 +827,6 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
 
-		if (!net_eq(t->net, dev_net(t->dev)))
-			skb_scrub_packet(skb, true);
-
 		netif_rx(skb);
 
 		rcu_read_unlock();
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index a60a84ef04f7..f365310bfcca 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -672,9 +672,8 @@ static int pim6_rcv(struct sk_buff *skb)
 	skb_reset_network_header(skb);
 	skb->protocol = htons(ETH_P_IPV6);
 	skb->ip_summed = CHECKSUM_NONE;
-	skb->pkt_type = PACKET_HOST;
 
-	skb_tunnel_rx(skb, reg_dev);
+	skb_tunnel_rx(skb, reg_dev, dev_net(reg_dev));
 
 	netif_rx(skb);
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 82b425b9b7d2..19abcc9d6a1a 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -581,12 +581,10 @@ static int ipip6_rcv(struct sk_buff *skb)
 		    tunnel->parms.iph.protocol != 0)
 			goto out;
 
-		secpath_reset(skb);
 		skb->mac_header = skb->network_header;
 		skb_reset_network_header(skb);
 		IPCB(skb)->flags = 0;
 		skb->protocol = htons(ETH_P_IPV6);
-		skb->pkt_type = PACKET_HOST;
 
 		if (tunnel->dev->priv_flags & IFF_ISATAP) {
 			if (!isatap_chksrc(skb, iph, tunnel)) {
@@ -603,7 +601,7 @@ static int ipip6_rcv(struct sk_buff *skb)
 			}
 		}
 
-		__skb_tunnel_rx(skb, tunnel->dev);
+		__skb_tunnel_rx(skb, tunnel->dev, tunnel->net);
 
 		err = IP_ECN_decapsulate(iph, skb);
 		if (unlikely(err)) {
@@ -621,8 +619,6 @@ static int ipip6_rcv(struct sk_buff *skb)
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
 
-		if (!net_eq(tunnel->net, dev_net(tunnel->dev)))
-			skb_scrub_packet(skb, true);
 		netif_rx(skb);
 
 		return 0;
-- 
1.8.2.1
