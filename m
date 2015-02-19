From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/4] netfilter: xt_socket: fix a stack corruption bug
Date: Thu, 19 Feb 2015 19:19:20 +0100
Message-ID: <1424369960-10988-5-git-send-email-pablo@netfilter.org>
References: <1424369960-10988-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58621 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753445AbbBSSQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2015 13:16:35 -0500
In-Reply-To: <1424369960-10988-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

As soon as extract_icmp6_fields() returns, its local storage (automatic
variables) is deallocated and can be overwritten.

Lets add an additional parameter to make sure storage is valid long
enough.

While we are at it, adds some const qualifiers.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: b64c9256a9b76 ("tproxy: added IPv6 support to the socket match")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_socket.c |   21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 1ba6793..13332db 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -243,12 +243,13 @@ static int
 extract_icmp6_fields(const struct sk_buff *skb,
 		     unsigned int outside_hdrlen,
 		     int *protocol,
-		     struct in6_addr **raddr,
-		     struct in6_addr **laddr,
+		     const struct in6_addr **raddr,
+		     const struct in6_addr **laddr,
 		     __be16 *rport,
-		     __be16 *lport)
+		     __be16 *lport,
+		     struct ipv6hdr *ipv6_var)
 {
-	struct ipv6hdr *inside_iph, _inside_iph;
+	const struct ipv6hdr *inside_iph;
 	struct icmp6hdr *icmph, _icmph;
 	__be16 *ports, _ports[2];
 	u8 inside_nexthdr;
@@ -263,12 +264,14 @@ extract_icmp6_fields(const struct sk_buff *skb,
 	if (icmph->icmp6_type & ICMPV6_INFOMSG_MASK)
 		return 1;
 
-	inside_iph = skb_header_pointer(skb, outside_hdrlen + sizeof(_icmph), sizeof(_inside_iph), &_inside_iph);
+	inside_iph = skb_header_pointer(skb, outside_hdrlen + sizeof(_icmph),
+					sizeof(*ipv6_var), ipv6_var);
 	if (inside_iph == NULL)
 		return 1;
 	inside_nexthdr = inside_iph->nexthdr;
 
-	inside_hdrlen = ipv6_skip_exthdr(skb, outside_hdrlen + sizeof(_icmph) + sizeof(_inside_iph),
+	inside_hdrlen = ipv6_skip_exthdr(skb, outside_hdrlen + sizeof(_icmph) +
+					      sizeof(*ipv6_var),
 					 &inside_nexthdr, &inside_fragoff);
 	if (inside_hdrlen < 0)
 		return 1; /* hjm: Packet has no/incomplete transport layer headers. */
@@ -315,10 +318,10 @@ xt_socket_get_sock_v6(struct net *net, const u8 protocol,
 static bool
 socket_mt6_v1_v2(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct ipv6hdr ipv6_var, *iph = ipv6_hdr(skb);
 	struct udphdr _hdr, *hp = NULL;
 	struct sock *sk = skb->sk;
-	struct in6_addr *daddr = NULL, *saddr = NULL;
+	const struct in6_addr *daddr = NULL, *saddr = NULL;
 	__be16 uninitialized_var(dport), uninitialized_var(sport);
 	int thoff = 0, uninitialized_var(tproto);
 	const struct xt_socket_mtinfo1 *info = (struct xt_socket_mtinfo1 *) par->matchinfo;
@@ -342,7 +345,7 @@ socket_mt6_v1_v2(const struct sk_buff *skb, struct xt_action_param *par)
 
 	} else if (tproto == IPPROTO_ICMPV6) {
 		if (extract_icmp6_fields(skb, thoff, &tproto, &saddr, &daddr,
-					 &sport, &dport))
+					 &sport, &dport, &ipv6_var))
 			return false;
 	} else {
 		return false;
-- 
1.7.10.4
