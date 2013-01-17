From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: add anti-spoofing checks for 6to4 and 6rd
Date: Thu, 17 Jan 2013 21:07:33 +0100
Message-ID: <20130117200733.GA2055@order.stressinduktion.org>
References: <20130117033258.GA23782@order.stressinduktion.org> <50F81C4B.3050406@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34468 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754663Ab3AQUHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 15:07:35 -0500
Content-Disposition: inline
In-Reply-To: <50F81C4B.3050406@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 18, 2013 at 12:44:11AM +0900, YOSHIFUJI Hideaki wrote:
> It seems wrong.  Check should be done for
> - inner source prefix
> - embedded source with relay_prefix.
> - inner destination prefix.
> 
> Note: embedded destination is not being checked.

I fixed the handling of the embedded IPv4 in case of using 6rd
with prefixlen != 16. I'll investigate on how to easily implement
further address checks without breaking 6in4. I don't know if this is
possible without a further flag on the tunnel interface controlling
source/destination address checking.

[PATCH RFC] ipv6: add anti-spoofing checks for 6to4 and 6rd

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
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/sit.c | 29 +++++++++++++++++++++++++++--
 1 file changed, 27 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index cfba99b..7942e81 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -73,6 +73,8 @@ static int ipip6_tunnel_init(struct net_device *dev);
 static void ipip6_tunnel_setup(struct net_device *dev);
 static void ipip6_dev_free(struct net_device *dev);
 static struct rtnl_link_ops sit_link_ops __read_mostly;
+static inline __be32 try_6rd(const struct in6_addr *v6dst,
+			struct ip_tunnel *tunnel);
 
 static int sit_net_id __read_mostly;
 struct sit_net {
@@ -590,6 +592,22 @@ out:
 	return err;
 }
 
+static int sit_chk_encap_addr(struct ip_tunnel *tunnel, const __be32 *addr,
+		const struct in6_addr *addr6)
+{
+#ifdef CONFIG_IPV6_SIT_6RD
+	if (ipv6_prefix_equal(addr6, &tunnel->ip6rd.prefix,
+				tunnel->ip6rd.prefixlen) &&
+		*addr != try_6rd(addr6, tunnel))
+		return 0;
+#else
+	if (addr6->s6_addr16[0] == htons(0x2002) &&
+		*addr != try_6rd(addr6, tunnel))
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
+					&ipv6_hdr(skb)->saddr) ||
+			!sit_chk_encap_addr(tunnel, &iph->daddr,
+				&ipv6_hdr(skb)->daddr)) {
 			tunnel->dev->stats.rx_errors++;
 			goto out;
 		}
-- 
1.7.11.7
