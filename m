From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net 2/2] ipv6: allow IPV6_PMTUDISC_INTERFACE generate fragments if packet size is larger than interface mtu
Date: Tue, 25 Feb 2014 01:58:15 +0100
Message-ID: <20140225005815.GA12227@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: fweimer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50468 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376AbaBYA6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 19:58:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following the changes of the IPv4 IP_PMTUDISC_INTERFACE logic, this
patch relax this option to allow generation of fragments if the packet
size exceeds only the interface mtu.

Fixes: 93b36cf3425b9b ("ipv6: support IPV6_PMTU_INTERFACE on sockets")
Cc: Florian Weimer <fweimer@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip6_route.h | 8 ++++++++
 net/ipv6/ip6_output.c   | 9 +++++----
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 017badb..f0dc32f 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -174,6 +174,14 @@ static inline bool ip6_sk_accept_pmtu(const struct sock *sk)
 	return inet6_sk(sk)->pmtudisc != IPV6_PMTUDISC_INTERFACE;
 }
 
+static inline bool ip6_sk_allow_local_frag(const struct sock *sk)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+
+	return np->pmtudisc != IPV6_PMTUDISC_DO &&
+	       np->pmtudisc != IPV6_PMTUDISC_PROBE;
+}
+
 static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt)
 {
 	return &rt->rt6i_gateway;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 16f91a2..227b7b7 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1231,8 +1231,10 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 			      sizeof(struct frag_hdr) : 0) +
 			     rt->rt6i_nfheader_len;
 
-		maxnonfragsize = (np->pmtudisc >= IPV6_PMTUDISC_DO) ?
-				 mtu : sizeof(struct ipv6hdr) + IPV6_MAXPLEN;
+		if (ip6_sk_allow_local_frag(sk))
+			maxnonfragsize = sizeof(struct ipv6hdr) + IPV6_MAXPLEN;
+		else
+			maxnonfragsize = mtu;
 
 		/* dontfrag active */
 		if ((cork->length + length > mtu - headersize) && dontfrag &&
@@ -1540,8 +1542,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	}
 
 	/* Allow local fragmentation. */
-	if (np->pmtudisc < IPV6_PMTUDISC_DO)
-		skb->local_df = 1;
+	skb->local_df = ip6_sk_allow_local_frag(sk);
 
 	*final_dst = fl6->daddr;
 	__skb_pull(skb, skb_network_header_len(skb));
-- 
1.8.5.3
