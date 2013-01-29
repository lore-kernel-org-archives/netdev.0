From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RESEND] ipv6: add anti-spoofing checks for 6to4 and 6rd
Date: Tue, 29 Jan 2013 05:10:44 +0100
Message-ID: <20130129041043.GA11940@order.stressinduktion.org>
References: <20130123100248.GB7317@order.stressinduktion.org> <5100B1A2.3000908@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57215 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477Ab3A2EKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 23:10:45 -0500
Content-Disposition: inline
In-Reply-To: <5100B1A2.3000908@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 24, 2013 at 12:59:30PM +0900, YOSHIFUJI Hideaki wrote:
> I need to do more research.  I am still not convinced
> to have such destination check here because the standard
> seems silent about it, and we have several basic checks
> in standard input path and tunnel search.
> 
> 
> Anyway, try_6rd() can do check for prefix as well
> but we are doing slightly different thing.
> So I think we can introduce new __check_6rd() to
> return non-6rd/6to4 addresses.
> 
> bool __check_6rd(struct ip_tunnel *tunnel,
> 		 const struct in6_addr *v6dst,
> 		 __be32 *v4dst);
> 
> If prefix matches, fill *v4dst and return true.
> Otherwise, return false.
> 
> __be32 __try_6rd()
> {
> 	__be32 dst = 0;
> 	__check_6rd(tunnel, v6dst, &dst);
> 	return dst;
> }
> 
> --yoshfuji

Yoshfuji, could you have a look at this patch?

[PATCH] ipv6: add anti-spoofing checks for 6to4 and 6rd

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
 net/ipv6/sit.c | 51 ++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 40 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 98fe536..3829d88 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -72,6 +72,8 @@ MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 static int ipip6_tunnel_init(struct net_device *dev);
 static void ipip6_tunnel_setup(struct net_device *dev);
 static void ipip6_dev_free(struct net_device *dev);
+static inline bool __check_6rd(struct ip_tunnel *tunnel,
+			       const struct in6_addr *v6dst, __be32 *v4dst);
 static struct rtnl_link_ops sit_link_ops __read_mostly;
 
 static int sit_net_id __read_mostly;
@@ -590,6 +592,16 @@ out:
 	return err;
 }
 
+static inline bool __is_spoofed_6rd(struct ip_tunnel *tunnel,
+				    const __be32 v4addr,
+				    const struct in6_addr *v6addr)
+{
+	__be32 v4embed = 0;
+	if (__check_6rd(tunnel, v6addr, &v4embed) && v4addr != v4embed)
+		return true;
+	return false;
+}
+
 static int ipip6_rcv(struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
@@ -608,10 +620,19 @@ static int ipip6_rcv(struct sk_buff *skb)
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
+			if (__is_spoofed_6rd(tunnel, iph->saddr,
+					     &ipv6_hdr(skb)->saddr) ||
+			    __is_spoofed_6rd(tunnel, iph->daddr,
+					     &ipv6_hdr(skb)->daddr)) {
+				tunnel->dev->stats.rx_errors++;
+				goto out;
+			}
 		}
 
 		__skb_tunnel_rx(skb, tunnel->dev);
@@ -648,11 +669,9 @@ out:
  * Returns the embedded IPv4 address if the IPv6 address
  * comes from 6rd / 6to4 (RFC 3056) addr space.
  */
-static inline
-__be32 try_6rd(const struct in6_addr *v6dst, struct ip_tunnel *tunnel)
+static inline bool __check_6rd(struct ip_tunnel *tunnel,
+			       const struct in6_addr *v6dst, __be32 *v4dst)
 {
-	__be32 dst = 0;
-
 #ifdef CONFIG_IPV6_SIT_6RD
 	if (ipv6_prefix_equal(v6dst, &tunnel->ip6rd.prefix,
 			      tunnel->ip6rd.prefixlen)) {
@@ -671,14 +690,24 @@ __be32 try_6rd(const struct in6_addr *v6dst, struct ip_tunnel *tunnel)
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
+static inline __be32 __try_6rd(struct ip_tunnel *tunnel,
+			       const struct in6_addr *v6dst)
+{
+	__be32 dst = 0;
+	__check_6rd(tunnel, v6dst, &dst);
 	return dst;
 }
 
@@ -739,7 +768,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	}
 
 	if (!dst)
-		dst = try_6rd(&iph6->daddr, tunnel);
+		dst = __try_6rd(tunnel, &iph6->daddr);
 
 	if (!dst) {
 		struct neighbour *neigh = NULL;
-- 
1.8.1
