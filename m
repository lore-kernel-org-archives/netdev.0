From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/1] ip6tnl/sit: drop packet if ECN present with not-ECT
Date: Tue, 27 Nov 2012 14:07:11 +0100
Message-ID: <1354021631-13602-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:49443 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755591Ab2K0Q3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 11:29:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reports the change made by Stephen Hemminger in ipip and gre[6] in
commit eccc1bb8d4b4 (tunnel: drop packet if ECN present with not-ECT).

Goal is to handle RFC6040, Section 4.2:

Default Tunnel Egress Behaviour.
 o If the inner ECN field is Not-ECT, the decapsulator MUST NOT
      propagate any other ECN codepoint onwards.  This is because the
      inner Not-ECT marking is set by transports that rely on dropped
      packets as an indication of congestion and would not understand or
      respond to any other ECN codepoint [RFC4774].  Specifically:

      *  If the inner ECN field is Not-ECT and the outer ECN field is
         CE, the decapsulator MUST drop the packet.

      *  If the inner ECN field is Not-ECT and the outer ECN field is
         Not-ECT, ECT(0), or ECT(1), the decapsulator MUST forward the
         outgoing packet with the ECN field cleared to Not-ECT.

The patch takes benefits from common function added in net/inet_ecn.h.

Like it was done for Xin4 tunnels, it adds logging to allow detecting broken
systems that set ECN bits incorrectly when tunneling (or an intermediate
router might be changing the header). Errors are also tracked via
rx_frame_error.

CC: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_tunnel.c | 49 ++++++++++++++++++++++++++++++++-----------------
 net/ipv6/sit.c        | 33 +++++++++++++++++++++------------
 2 files changed, 53 insertions(+), 29 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index fb828e9..a14f28b 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -74,6 +74,10 @@ MODULE_ALIAS_NETDEV("ip6tnl0");
 #define HASH_SIZE_SHIFT  5
 #define HASH_SIZE (1 << HASH_SIZE_SHIFT)
 
+static bool log_ecn_error = true;
+module_param(log_ecn_error, bool, 0644);
+MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
+
 static u32 HASH(const struct in6_addr *addr1, const struct in6_addr *addr2)
 {
 	u32 hash = ipv6_addr_hash(addr1) ^ ipv6_addr_hash(addr2);
@@ -683,28 +687,26 @@ ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	return 0;
 }
 
-static void ip4ip6_dscp_ecn_decapsulate(const struct ip6_tnl *t,
-					const struct ipv6hdr *ipv6h,
-					struct sk_buff *skb)
+static int ip4ip6_dscp_ecn_decapsulate(const struct ip6_tnl *t,
+				       const struct ipv6hdr *ipv6h,
+				       struct sk_buff *skb)
 {
 	__u8 dsfield = ipv6_get_dsfield(ipv6h) & ~INET_ECN_MASK;
 
 	if (t->parms.flags & IP6_TNL_F_RCV_DSCP_COPY)
 		ipv4_change_dsfield(ip_hdr(skb), INET_ECN_MASK, dsfield);
 
-	if (INET_ECN_is_ce(dsfield))
-		IP_ECN_set_ce(ip_hdr(skb));
+	return IP6_ECN_decapsulate(ipv6h, skb);
 }
 
-static void ip6ip6_dscp_ecn_decapsulate(const struct ip6_tnl *t,
-					const struct ipv6hdr *ipv6h,
-					struct sk_buff *skb)
+static int ip6ip6_dscp_ecn_decapsulate(const struct ip6_tnl *t,
+				       const struct ipv6hdr *ipv6h,
+				       struct sk_buff *skb)
 {
 	if (t->parms.flags & IP6_TNL_F_RCV_DSCP_COPY)
 		ipv6_copy_dscp(ipv6_get_dsfield(ipv6h), ipv6_hdr(skb));
 
-	if (INET_ECN_is_ce(ipv6_get_dsfield(ipv6h)))
-		IP6_ECN_set_ce(ipv6_hdr(skb));
+	return IP6_ECN_decapsulate(ipv6h, skb);
 }
 
 __u32 ip6_tnl_get_cap(struct ip6_tnl *t,
@@ -768,12 +770,13 @@ EXPORT_SYMBOL_GPL(ip6_tnl_rcv_ctl);
 
 static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 		       __u8 ipproto,
-		       void (*dscp_ecn_decapsulate)(const struct ip6_tnl *t,
-						    const struct ipv6hdr *ipv6h,
-						    struct sk_buff *skb))
+		       int (*dscp_ecn_decapsulate)(const struct ip6_tnl *t,
+						   const struct ipv6hdr *ipv6h,
+						   struct sk_buff *skb))
 {
 	struct ip6_tnl *t;
 	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+	int err;
 
 	rcu_read_lock();
 
@@ -803,14 +806,26 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 		skb->pkt_type = PACKET_HOST;
 		memset(skb->cb, 0, sizeof(struct inet6_skb_parm));
 
+		__skb_tunnel_rx(skb, t->dev);
+
+		err = dscp_ecn_decapsulate(t, ipv6h, skb);
+		if (unlikely(err)) {
+			if (log_ecn_error)
+				net_info_ratelimited("non-ECT from %pI6 with dsfield=%#x\n",
+						     &ipv6h->saddr,
+						     ipv6_get_dsfield(ipv6h));
+			if (err > 1) {
+				++t->dev->stats.rx_frame_errors;
+				++t->dev->stats.rx_errors;
+				rcu_read_unlock();
+				goto discard;
+			}
+		}
+
 		tstats = this_cpu_ptr(t->dev->tstats);
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
 
-		__skb_tunnel_rx(skb, t->dev);
-
-		dscp_ecn_decapsulate(t, ipv6h, skb);
-
 		netif_rx(skb);
 
 		rcu_read_unlock();
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 80cb382..cfba99b 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -65,6 +65,10 @@
 #define HASH_SIZE  16
 #define HASH(addr) (((__force u32)addr^((__force u32)addr>>4))&0xF)
 
+static bool log_ecn_error = true;
+module_param(log_ecn_error, bool, 0644);
+MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
+
 static int ipip6_tunnel_init(struct net_device *dev);
 static void ipip6_tunnel_setup(struct net_device *dev);
 static void ipip6_dev_free(struct net_device *dev);
@@ -106,6 +110,7 @@ static struct rtnl_link_stats64 *ipip6_get_stats64(struct net_device *dev,
 	}
 
 	tot->rx_errors = dev->stats.rx_errors;
+	tot->rx_frame_errors = dev->stats.rx_frame_errors;
 	tot->tx_fifo_errors = dev->stats.tx_fifo_errors;
 	tot->tx_carrier_errors = dev->stats.tx_carrier_errors;
 	tot->tx_dropped = dev->stats.tx_dropped;
@@ -585,16 +590,11 @@ out:
 	return err;
 }
 
-static inline void ipip6_ecn_decapsulate(const struct iphdr *iph, struct sk_buff *skb)
-{
-	if (INET_ECN_is_ce(iph->tos))
-		IP6_ECN_set_ce(ipv6_hdr(skb));
-}
-
 static int ipip6_rcv(struct sk_buff *skb)
 {
 	const struct iphdr *iph;
 	struct ip_tunnel *tunnel;
+	int err;
 
 	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
 		goto out;
@@ -616,18 +616,27 @@ static int ipip6_rcv(struct sk_buff *skb)
 		if ((tunnel->dev->priv_flags & IFF_ISATAP) &&
 		    !isatap_chksrc(skb, iph, tunnel)) {
 			tunnel->dev->stats.rx_errors++;
-			kfree_skb(skb);
-			return 0;
+			goto out;
+		}
+
+		__skb_tunnel_rx(skb, tunnel->dev);
+
+		err = IP_ECN_decapsulate(iph, skb);
+		if (unlikely(err)) {
+			if (log_ecn_error)
+				net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
+						     &iph->saddr, iph->tos);
+			if (err > 1) {
+				++tunnel->dev->stats.rx_frame_errors;
+				++tunnel->dev->stats.rx_errors;
+				goto out;
+			}
 		}
 
 		tstats = this_cpu_ptr(tunnel->dev->tstats);
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
 
-		__skb_tunnel_rx(skb, tunnel->dev);
-
-		ipip6_ecn_decapsulate(iph, skb);
-
 		netif_rx(skb);
 
 		return 0;
-- 
1.7.12
