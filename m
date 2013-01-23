From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RESEND] ipv6: add anti-spoofing checks for 6to4 and 6rd
Date: Wed, 23 Jan 2013 11:02:48 +0100
Message-ID: <20130123100248.GB7317@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45946 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752439Ab3AWKCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 05:02:49 -0500
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
 net/ipv6/sit.c | 29 +++++++++++++++++++++++++++--
 1 file changed, 27 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index cfba99b..5a09f13 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -73,6 +73,8 @@ static int ipip6_tunnel_init(struct net_device *dev);
 static void ipip6_tunnel_setup(struct net_device *dev);
 static void ipip6_dev_free(struct net_device *dev);
 static struct rtnl_link_ops sit_link_ops __read_mostly;
+static inline __be32 try_6rd(const struct in6_addr *v6dst,
+			     struct ip_tunnel *tunnel);
 
 static int sit_net_id __read_mostly;
 struct sit_net {
@@ -590,6 +592,22 @@ out:
 	return err;
 }
 
+static int sit_chk_encap_addr(struct ip_tunnel *tunnel, const __be32 *addr,
+			      const struct in6_addr *addr6)
+{
+#ifdef CONFIG_IPV6_SIT_6RD
+	if (ipv6_prefix_equal(addr6, &tunnel->ip6rd.prefix,
+			      tunnel->ip6rd.prefixlen) &&
+	    *addr != try_6rd(addr6, tunnel))
+		return 0;
+#else
+	if (addr6->s6_addr16[0] == htons(0x2002) &&
+	    *addr != try_6rd(addr6, tunnel))
+		return 0;
+#endif
+	return 1;
+}
+
 static int ipip6_rcv(struct sk_buff *skb)
 {
 	const struct iphdr *iph;
@@ -613,8 +631,15 @@ static int ipip6_rcv(struct sk_buff *skb)
 		skb->protocol = htons(ETH_P_IPV6);
 		skb->pkt_type = PACKET_HOST;
 
-		if ((tunnel->dev->priv_flags & IFF_ISATAP) &&
-		    !isatap_chksrc(skb, iph, tunnel)) {
+		if (tunnel->dev->priv_flags & IFF_ISATAP) {
+			if (!isatap_chksrc(skb, iph, tunnel)) {
+				tunnel->dev->stats.rx_errors++;
+				goto out;
+			}
+		} else if (!sit_chk_encap_addr(tunnel, &iph->saddr,
+					       &ipv6_hdr(skb)->saddr) ||
+			   !sit_chk_encap_addr(tunnel, &iph->daddr,
+					       &ipv6_hdr(skb)->daddr)) {
 			tunnel->dev->stats.rx_errors++;
 			goto out;
 		}
-- 
1.7.11.7
