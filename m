From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/33] netfilter: ipset: Support package fragments for IPv4 protos without ports
Date: Fri,  4 Oct 2013 10:32:55 +0200
Message-ID: <1380875598-5250-11-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Anders K. Pedersen" <akp@surftown.com>

Enable ipset port set types to match IPv4 package fragments for
protocols that doesn't have ports (or the port information isn't
supported by ipset).

For example this allows a hash:ip,port ipset containing the entry
192.168.0.1,gre:0 to match all package fragments for PPTP VPN tunnels
to/from the host. Without this patch only the first package fragment
(with fragment offset 0) was matched, while subsequent fragments wasn't.

This is not possible for IPv6, where the protocol is in the fragmented
part of the package unlike IPv4, where the protocol is in the IP header.

IPPROTO_ICMPV6 is deliberately not included, because it isn't relevant
for IPv4.

Signed-off-by: Anders K. Pedersen <akp@surftown.com>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_getport.c |   18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_getport.c b/net/netfilter/ipset/ip_set_getport.c
index dac156f..29fb01d 100644
--- a/net/netfilter/ipset/ip_set_getport.c
+++ b/net/netfilter/ipset/ip_set_getport.c
@@ -102,9 +102,25 @@ ip_set_get_ip4_port(const struct sk_buff *skb, bool src,
 	int protocol = iph->protocol;
 
 	/* See comments at tcp_match in ip_tables.c */
-	if (protocol <= 0 || (ntohs(iph->frag_off) & IP_OFFSET))
+	if (protocol <= 0)
 		return false;
 
+	if (ntohs(iph->frag_off) & IP_OFFSET)
+		switch (protocol) {
+		case IPPROTO_TCP:
+		case IPPROTO_SCTP:
+		case IPPROTO_UDP:
+		case IPPROTO_UDPLITE:
+		case IPPROTO_ICMP:
+			/* Port info not available for fragment offset > 0 */
+			return false;
+		default:
+			/* Other protocols doesn't have ports,
+			   so we can match fragments */
+			*proto = protocol;
+			return true;
+		}
+
 	return get_port(skb, protocol, protooff, src, port, proto);
 }
 EXPORT_SYMBOL_GPL(ip_set_get_ip4_port);
-- 
1.7.10.4

