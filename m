From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] netfilter: xt_socket: fix a stack corruption bug
Date: Sun, 15 Feb 2015 19:03:45 -0800
Message-ID: <1424055825.4942.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Balazs Scheidler <bazsi@balabit.hu>,
	KOVACS Krisztian <hidden@balabit.hu>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:51333 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532AbbBPDDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 22:03:48 -0500
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
---
 net/netfilter/xt_socket.c |   21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 1ba67931eb1b..13332dbf291d 100644
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
