From: Alexander Drozdov <al.drozdov@gmail.com>
Subject: [PATCH] netfilter: ipset: make ip_set_get_ip*_port to use skb_network_offset
Date: Fri,  6 Mar 2015 13:44:06 +0300
Message-ID: <1425638646-5906-1-git-send-email-al.drozdov@gmail.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Drozdov <al.drozdov@gmail.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All the ipset functions respect skb->network_header value,
except for ip_set_get_ip4_port() & ip_set_get_ip6_port(). The
functions should use skb_network_offset() to get the transport
header offset.

Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>
---
 net/netfilter/ipset/ip_set_getport.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_getport.c b/net/netfilter/ipset/ip_set_getport.c
index 29fb01d..1981f02 100644
--- a/net/netfilter/ipset/ip_set_getport.c
+++ b/net/netfilter/ipset/ip_set_getport.c
@@ -98,7 +98,7 @@ ip_set_get_ip4_port(const struct sk_buff *skb, bool src,
 		    __be16 *port, u8 *proto)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	unsigned int protooff = ip_hdrlen(skb);
+	unsigned int protooff = skb_network_offset(skb) + ip_hdrlen(skb);
 	int protocol = iph->protocol;
 
 	/* See comments at tcp_match in ip_tables.c */
@@ -135,7 +135,9 @@ ip_set_get_ip6_port(const struct sk_buff *skb, bool src,
 	__be16 frag_off = 0;
 
 	nexthdr = ipv6_hdr(skb)->nexthdr;
-	protoff = ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr), &nexthdr,
+	protoff = ipv6_skip_exthdr(skb,
+				   skb_network_offset(skb) +
+					sizeof(struct ipv6hdr), &nexthdr,
 				   &frag_off);
 	if (protoff < 0 || (frag_off & htons(~0x7)) != 0)
 		return false;
-- 
1.9.1
