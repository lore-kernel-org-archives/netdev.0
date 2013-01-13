From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 2/7] ipv6: Introduce ip6_flowinfo() to extract flowinfo
 (tclass + flowlabel).
Date: Mon, 14 Jan 2013 00:01:51 +0900
Message-ID: <50F2CC5F.9050202@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:38230 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755055Ab3AMPBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 10:01:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h  |    5 +++++
 net/ipv6/datagram.c |    9 +++++----
 net/ipv6/route.c    |    6 +++---
 3 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index fcbc646..ed67208 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -555,6 +555,11 @@ static inline void ip6_flow_hdr(struct ipv6hdr *hdr, unsigned int tclass,
 	*(__be32 *)hdr = ntohl(0x60000000 | (tclass << 20)) | flowlabel;
 }
 
+static inline __be32 ip6_flowinfo(const struct ipv6hdr *hdr)
+{
+	return *(__be32 *)hdr & IPV6_FLOWINFO_MASK;
+}
+
 /*
  *	Prototypes exported by ipv6
  */
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 56b692b..7f65df4 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -360,7 +360,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
 								  struct ipv6hdr, daddr);
 			sin->sin6_addr = ip6h->daddr;
 			if (np->sndflow)
-				sin->sin6_flowinfo = *(__be32 *)ip6h & IPV6_FLOWINFO_MASK;
+				sin->sin6_flowinfo = ip6_flowinfo(ip6h);
 			if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
 				sin->sin6_scope_id = IP6CB(skb)->iif;
 		} else {
@@ -491,9 +491,10 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 		put_cmsg(msg, SOL_IPV6, IPV6_TCLASS, sizeof(tclass), &tclass);
 	}
 
-	if (np->rxopt.bits.rxflow && (*(__be32 *)nh & IPV6_FLOWINFO_MASK)) {
-		__be32 flowinfo = *(__be32 *)nh & IPV6_FLOWINFO_MASK;
-		put_cmsg(msg, SOL_IPV6, IPV6_FLOWINFO, sizeof(flowinfo), &flowinfo);
+	if (np->rxopt.bits.rxflow) {
+		__be32 flowinfo = ip6_flowinfo((struct ipv6hdr *)nh);
+		if (flowinfo)
+			put_cmsg(msg, SOL_IPV6, IPV6_FLOWINFO, sizeof(flowinfo), &flowinfo);
 	}
 
 	/* HbH is allowed only once */
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 621b68e..6238eb5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -994,7 +994,7 @@ void ip6_route_input(struct sk_buff *skb)
 		.flowi6_iif = skb->dev->ifindex,
 		.daddr = iph->daddr,
 		.saddr = iph->saddr,
-		.flowlabel = (* (__be32 *) iph) & IPV6_FLOWINFO_MASK,
+		.flowlabel = ip6_flowinfo(iph),
 		.flowi6_mark = skb->mark,
 		.flowi6_proto = iph->nexthdr,
 	};
@@ -1159,7 +1159,7 @@ void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 	fl6.flowi6_flags = 0;
 	fl6.daddr = iph->daddr;
 	fl6.saddr = iph->saddr;
-	fl6.flowlabel = (*(__be32 *) iph) & IPV6_FLOWINFO_MASK;
+	fl6.flowlabel = ip6_flowinfo(iph);
 
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (!dst->error)
@@ -1187,7 +1187,7 @@ void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark)
 	fl6.flowi6_flags = 0;
 	fl6.daddr = iph->daddr;
 	fl6.saddr = iph->saddr;
-	fl6.flowlabel = (*(__be32 *) iph) & IPV6_FLOWINFO_MASK;
+	fl6.flowlabel = ip6_flowinfo(iph);
 
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (!dst->error)
-- 
1.7.9.5
