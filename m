From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [PATCH 12/13] TProxy: added IPv6 support to the socket match
Date: Mon, 24 Aug 2009 14:52:07 +0200
Message-ID: <1253548005.12519.12.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:58462 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751633AbZIUQZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2009 12:25:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ICMP extraction bits were contributed by Harry Mason.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
---
 net/netfilter/xt_socket.c |  152 +++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 146 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 12a7140..b375532 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -14,6 +14,7 @@
 #include <linux/skbuff.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <net/icmp.h>
@@ -21,6 +22,7 @@
 #include <net/inet_sock.h>
 #include <net/netfilter/nf_tproxy_core.h>
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
+#include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 
 #include <linux/netfilter/xt_socket.h>
 
@@ -30,7 +32,7 @@
 #endif
 
 static int
-extract_icmp_fields(const struct sk_buff *skb,
+extract_icmp4_fields(const struct sk_buff *skb,
 		    u8 *protocol,
 		    __be32 *raddr,
 		    __be32 *laddr,
@@ -115,7 +117,7 @@ socket_match(const struct sk_buff *skb, const struct xt_match_param *par,
 		dport = hp->dest;
 
 	} else if (iph->protocol == IPPROTO_ICMP) {
-		if (extract_icmp_fields(skb, &protocol, &saddr, &daddr,
+		if (extract_icmp4_fields(skb, &protocol, &saddr, &daddr,
 					&sport, &dport))
 			return false;
 	} else {
@@ -175,23 +177,148 @@ socket_match(const struct sk_buff *skb, const struct xt_match_param *par,
 }
 
 static bool
-socket_mt_v0(const struct sk_buff *skb, const struct xt_match_param *par)
+socket_mt4_v0(const struct sk_buff *skb, const struct xt_match_param *par)
 {
 	return socket_match(skb, par, NULL);
 }
 
 static bool
-socket_mt_v1(const struct sk_buff *skb, const struct xt_match_param *par)
+socket_mt4_v1(const struct sk_buff *skb, const struct xt_match_param *par)
 {
 	return socket_match(skb, par, par->matchinfo);
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+
+static int
+extract_icmp6_fields(const struct sk_buff *skb,
+		     unsigned int outside_hdrlen,
+		     u8 *protocol,
+		     struct in6_addr **raddr,
+		     struct in6_addr **laddr,
+		     __be16 *rport,
+		     __be16 *lport)
+{
+	struct ipv6hdr *inside_iph, _inside_iph;
+	struct icmp6hdr *icmph, _icmph;
+	__be16 *ports, _ports[2];
+	u8 inside_nexthdr;
+	int inside_hdrlen;
+
+	icmph = skb_header_pointer(skb, outside_hdrlen,
+				   sizeof(_icmph), &_icmph);
+	if (icmph == NULL)
+		return 1;
+
+	if (icmph->icmp6_type & ICMPV6_INFOMSG_MASK)
+		return 1;
+
+	inside_iph = skb_header_pointer(skb, outside_hdrlen + sizeof(_icmph), sizeof(_inside_iph), &_inside_iph);
+	if (inside_iph == NULL)
+		return 1;
+	inside_nexthdr = inside_iph->nexthdr;
+
+	inside_hdrlen = ipv6_skip_exthdr(skb, outside_hdrlen + sizeof(_icmph) + sizeof(_inside_iph), &inside_nexthdr);
+	if (inside_hdrlen < 0)
+		return 1; /* hjm: Packet has no/incomplete transport layer headers. */
+
+	if (inside_nexthdr != IPPROTO_TCP &&
+	    inside_nexthdr != IPPROTO_UDP)
+		return 1;
+
+	ports = skb_header_pointer(skb, inside_hdrlen,
+				   sizeof(_ports), &_ports);
+	if (ports == NULL)
+		return 1;
+
+	/* the inside IP packet is the one quoted from our side, thus
+	 * its saddr is the local address */
+	*protocol = inside_nexthdr;
+	*laddr = &inside_iph->saddr;
+	*lport = ports[0];
+	*raddr = &inside_iph->daddr;
+	*rport = ports[1];
+
+	return 0;
+}
+
+static bool
+socket_mt6_v1(const struct sk_buff *skb, const struct xt_match_param *par)
+{
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct udphdr _hdr, *hp = NULL;
+	struct sock *sk;
+	struct in6_addr *daddr, *saddr;
+	__be16 dport, sport;
+        int thoff;
+	u8 tproto;
+        const struct xt_socket_mtinfo1 *info = (struct xt_socket_mtinfo1 *) par->matchinfo;
+        
+        tproto = ipv6_find_hdr(skb, &thoff, -1, NULL);
+        if (tproto < 0) {
+		pr_debug("socket match: Unable to find transport header in IPv6 packet, dropping\n");
+		return NF_DROP;
+        }
+
+	if (tproto == IPPROTO_UDP || tproto == IPPROTO_TCP) {
+		hp = skb_header_pointer(skb, thoff,
+					sizeof(_hdr), &_hdr);
+		if (hp == NULL)
+			return false;
+
+		saddr = &iph->saddr;
+		sport = hp->source;
+		daddr = &iph->daddr;
+		dport = hp->dest;
+
+	} else if (tproto == IPPROTO_ICMP) {
+		if (extract_icmp6_fields(skb, thoff, &tproto, &saddr, &daddr,
+					 &sport, &dport))
+			return false;
+	} else {
+		return false;
+	}
+
+	sk = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
+				   saddr, daddr, sport, dport, par->in, NFT_LOOKUP_ANY);
+	if (sk != NULL) {
+		bool wildcard;
+		bool transparent = true;
+
+		/* Ignore sockets listening on INADDR_ANY */
+		wildcard = (sk->sk_state != TCP_TIME_WAIT &&
+			    ipv6_addr_any(&inet6_sk(sk)->rcv_saddr));
+
+		/* Ignore non-transparent sockets,
+		   if XT_SOCKET_TRANSPARENT is used */
+		if (info && info->flags & XT_SOCKET_TRANSPARENT)
+			transparent = ((sk->sk_state != TCP_TIME_WAIT &&
+					inet_sk(sk)->transparent) ||
+				       (sk->sk_state == TCP_TIME_WAIT &&
+					inet_twsk(sk)->tw_transparent));
+
+		nf_tproxy_put_sock(sk);
+
+		if (wildcard || !transparent)
+			sk = NULL;
+	}
+
+	pr_debug("socket match: proto %u %pI6:%u -> %pI6:%u "
+		 "(orig %pI6:%u) sock %p\n",
+		 tproto, saddr, ntohs(sport),
+		 daddr, ntohs(dport),
+		 &iph->daddr, hp ? ntohs(hp->dest) : 0, sk);
+
+	return (sk != NULL);
+}
+#endif
+
 static struct xt_match socket_mt_reg[] __read_mostly = {
 	{
 		.name		= "socket",
 		.revision	= 0,
 		.family		= NFPROTO_IPV4,
-		.match		= socket_mt_v0,
+		.match		= socket_mt4_v0,
 		.hooks		= 1 << NF_INET_PRE_ROUTING,
 		.me		= THIS_MODULE,
 	},
@@ -199,16 +326,28 @@ static struct xt_match socket_mt_reg[] __read_mostly = {
 		.name		= "socket",
 		.revision	= 1,
 		.family		= NFPROTO_IPV4,
-		.match		= socket_mt_v1,
+		.match		= socket_mt4_v1,
+		.matchsize	= sizeof(struct xt_socket_mtinfo1),
+		.hooks		= 1 << NF_INET_PRE_ROUTING,
+		.me		= THIS_MODULE,
+	},
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	{
+		.name		= "socket",
+		.revision	= 1,
+		.family		= NFPROTO_IPV6,
+		.match		= socket_mt6_v1,
 		.matchsize	= sizeof(struct xt_socket_mtinfo1),
 		.hooks		= 1 << NF_INET_PRE_ROUTING,
 		.me		= THIS_MODULE,
 	},
+#endif
 };
 
 static int __init socket_mt_init(void)
 {
 	nf_defrag_ipv4_enable();
+	nf_defrag_ipv6_enable();
 	return xt_register_matches(socket_mt_reg, ARRAY_SIZE(socket_mt_reg));
 }
 
@@ -224,3 +363,4 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Krisztian Kovacs, Balazs Scheidler");
 MODULE_DESCRIPTION("x_tables socket match module");
 MODULE_ALIAS("ipt_socket");
+MODULE_ALIAS("ip6t_socket");
-- 
1.6.0.4

