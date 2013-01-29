From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next (v3)] ipv6: add anti-spoofing checks for 6to4 and 6rd
Date: Tue, 29 Jan 2013 19:24:25 +0100
Message-ID: <20130129182425.GA30498@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58655 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241Ab3A2SY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 13:24:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds anti-spoofing checks in sit.c as specified in RFC3964
section 5.2 for 6to4 and RFC5969 section 12 for 6rd. I left out the
checks which could easily be implemented with netfilter.

Specifically this patch adds following logic (based loosely on the
pseudocode in RFC3964 section 5.2):

if prefix (inner_src_v6) == rd6_prefix (2002::/16 is the default)
        and outer_src_v4 != embedded_ipv4 (inner_src_v6)
                drop
if prefix (inner_dst_v6) == rd6_prefix (or 2002::/16 is the default)
        and outer_dst_v4 != embedded_ipv4 (inner_dst_v6)
                drop
accept

To accomplish the specified security checks proposed by above RFCs,
it is still necessary to employ uRPF filters with netfilter. These new
checks only kick in if the employed addresses are within the 2002::/16 or
another range specified by the 6rd-prefix (which defaults to 2002::/16).

Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/sit.c | 54 +++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 41 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 98fe536..02f96dc 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -72,6 +72,8 @@ MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 static int ipip6_tunnel_init(struct net_device *dev);
 static void ipip6_tunnel_setup(struct net_device *dev);
 static void ipip6_dev_free(struct net_device *dev);
+static bool check_6rd(struct ip_tunnel *tunnel, const struct in6_addr *v6dst,
+		      __be32 *v4dst);
 static struct rtnl_link_ops sit_link_ops __read_mostly;
 
 static int sit_net_id __read_mostly;
@@ -590,6 +592,15 @@ out:
 	return err;
 }
 
+static inline bool is_spoofed_6rd(struct ip_tunnel *tunnel, const __be32 v4addr,
+				  const struct in6_addr *v6addr)
+{
+	__be32 v4embed = 0;
+	if (check_6rd(tunnel, v6addr, &v4embed) && v4addr != v4embed)
+		return true;
+	return false;
+}
+
 static int ipip6_rcv(struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
@@ -608,10 +619,19 @@ static int ipip6_rcv(struct sk_buff *skb)
 		skb->protocol = htons(ETH_P_IPV6);
 		skb->pkt_type = PACKET_HOST;
 
-		if ((tunnel->dev->priv_flags & IFF_ISATAP) &&
-		    !isatap_chksrc(skb, iph, tunnel)) {
-			tunnel->dev->stats.rx_errors++;
-			goto out;
+		if (tunnel->dev->priv_flags & IFF_ISATAP) {
+			if (!isatap_chksrc(skb, iph, tunnel)) {
+				tunnel->dev->stats.rx_errors++;
+				goto out;
+			}
+		} else {
+			if (is_spoofed_6rd(tunnel, iph->saddr,
+					   &ipv6_hdr(skb)->saddr) ||
+			    is_spoofed_6rd(tunnel, iph->daddr,
+					   &ipv6_hdr(skb)->daddr)) {
+				tunnel->dev->stats.rx_errors++;
+				goto out;
+			}
 		}
 
 		__skb_tunnel_rx(skb, tunnel->dev);
@@ -645,14 +665,12 @@ out:
 }
 
 /*
- * Returns the embedded IPv4 address if the IPv6 address
- * comes from 6rd / 6to4 (RFC 3056) addr space.
+ * If the IPv6 address comes from 6rd / 6to4 (RFC 3056) addr space this function
+ * stores the embedded IPv4 address in v4dst and returns true.
  */
-static inline
-__be32 try_6rd(const struct in6_addr *v6dst, struct ip_tunnel *tunnel)
+static bool check_6rd(struct ip_tunnel *tunnel, const struct in6_addr *v6dst,
+		      __be32 *v4dst)
 {
-	__be32 dst = 0;
-
 #ifdef CONFIG_IPV6_SIT_6RD
 	if (ipv6_prefix_equal(v6dst, &tunnel->ip6rd.prefix,
 			      tunnel->ip6rd.prefixlen)) {
@@ -671,14 +689,24 @@ __be32 try_6rd(const struct in6_addr *v6dst, struct ip_tunnel *tunnel)
 			d |= ntohl(v6dst->s6_addr32[pbw0 + 1]) >>
 			     (32 - pbi1);
 
-		dst = tunnel->ip6rd.relay_prefix | htonl(d);
+		*v4dst = tunnel->ip6rd.relay_prefix | htonl(d);
+		return true;
 	}
 #else
 	if (v6dst->s6_addr16[0] == htons(0x2002)) {
 		/* 6to4 v6 addr has 16 bits prefix, 32 v4addr, 16 SLA, ... */
-		memcpy(&dst, &v6dst->s6_addr16[1], 4);
+		memcpy(v4dst, &v6dst->s6_addr16[1], 4);
+		return true;
 	}
 #endif
+	return false;
+}
+
+static inline __be32 try_6rd(struct ip_tunnel *tunnel,
+			     const struct in6_addr *v6dst)
+{
+	__be32 dst = 0;
+	check_6rd(tunnel, v6dst, &dst);
 	return dst;
 }
 
@@ -739,7 +767,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	}
 
 	if (!dst)
-		dst = try_6rd(&iph6->daddr, tunnel);
+		dst = try_6rd(tunnel, &iph6->daddr);
 
 	if (!dst) {
 		struct neighbour *neigh = NULL;
-- 
1.8.1
