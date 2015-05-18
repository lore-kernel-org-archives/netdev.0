From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/21] netfilter: ipset: make ip_set_get_ip*_port to use skb_network_offset
Date: Mon, 18 May 2015 18:25:06 +0200
Message-ID: <1431966324-4494-4-git-send-email-pablo@netfilter.org>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43992 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932364AbbERQUn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 12:20:43 -0400
In-Reply-To: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Drozdov <al.drozdov@gmail.com>

All the ipset functions respect skb->network_header value,
except for ip_set_get_ip4_port() & ip_set_get_ip6_port(). The
functions should use skb_network_offset() to get the transport
header offset.

Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_getport.c |    6 ++++--
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
1.7.10.4
