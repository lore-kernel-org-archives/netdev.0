From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: support IPV6_PMTU_INTERFACE on sockets
Date: Sun, 15 Dec 2013 03:41:14 +0100
Message-ID: <20131215024114.GA1442@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56242 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753460Ab3LOClP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 21:41:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPV6_PMTU_INTERFACE is the same as IPV6_PMTU_PROBE for ipv6. Add it
nontheless for symmetry with IPv4 sockets. Also drop incoming MTU
information if this mode is enabled.

The additional bit in ipv6_pinfo just eats in the padding behind the
bitfield. There are no changes to the layout of the struct at all.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/ipv6.h     | 2 +-
 include/net/ip6_route.h  | 7 ++++++-
 include/uapi/linux/in6.h | 4 ++++
 net/dccp/ipv6.c          | 3 +++
 net/ipv6/ip6_output.c    | 6 +++---
 net/ipv6/ipv6_sockglue.c | 2 +-
 net/ipv6/tcp_ipv6.c      | 3 +++
 net/ipv6/udp.c           | 5 ++++-
 net/sctp/input.c         | 3 +++
 9 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 3fde066..7e1ded0 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -191,7 +191,7 @@ struct ipv6_pinfo {
 	/* sockopt flags */
 	__u16			recverr:1,
 	                        sndflow:1,
-				pmtudisc:2,
+				pmtudisc:3,
 				ipv6only:1,
 				srcprefs:3,	/* 001: prefer temporary address
 						 * 010: prefer public address
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 733747c..c2626ce 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -178,10 +178,15 @@ static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np = skb->sk ? inet6_sk(skb->sk) : NULL;
 
-	return (np && np->pmtudisc == IPV6_PMTUDISC_PROBE) ?
+	return (np && np->pmtudisc >= IPV6_PMTUDISC_PROBE) ?
 	       skb_dst(skb)->dev->mtu : dst_mtu(skb_dst(skb));
 }
 
+static inline bool ip6_sk_accept_pmtu(const struct sock *sk)
+{
+	return inet6_sk(sk)->pmtudisc != IPV6_PMTUDISC_INTERFACE;
+}
+
 static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt)
 {
 	return &rt->rt6i_gateway;
diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
index 440d5c4..f94f1d0 100644
--- a/include/uapi/linux/in6.h
+++ b/include/uapi/linux/in6.h
@@ -188,6 +188,10 @@ enum {
 #define IPV6_PMTUDISC_WANT		1
 #define IPV6_PMTUDISC_DO		2
 #define IPV6_PMTUDISC_PROBE		3
+/* same as IPV6_PMTUDISC_PROBE, provided for symetry with IPv4
+ * also see comments on IP_PMTUDISC_INTERFACE
+ */
+#define IPV6_PMTUDISC_INTERFACE		4
 
 /* Flowlabel */
 #define IPV6_FLOWLABEL_MGR	32
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 4ac71ff..b5ad684 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -141,6 +141,9 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (type == ICMPV6_PKT_TOOBIG) {
 		struct dst_entry *dst = NULL;
 
+		if (!ip6_sk_accept_pmtu(sk))
+			goto out;
+
 		if (sock_owned_by_user(sk))
 			goto out;
 		if ((1 << sk->sk_state) & (DCCPF_LISTEN | DCCPF_CLOSED))
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9a311cc..bc4e1bc 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1165,10 +1165,10 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		np->cork.hop_limit = hlimit;
 		np->cork.tclass = tclass;
 		if (rt->dst.flags & DST_XFRM_TUNNEL)
-			mtu = np->pmtudisc == IPV6_PMTUDISC_PROBE ?
+			mtu = np->pmtudisc >= IPV6_PMTUDISC_PROBE ?
 			      rt->dst.dev->mtu : dst_mtu(&rt->dst);
 		else
-			mtu = np->pmtudisc == IPV6_PMTUDISC_PROBE ?
+			mtu = np->pmtudisc >= IPV6_PMTUDISC_PROBE ?
 			      rt->dst.dev->mtu : dst_mtu(rt->dst.path);
 		if (np->frag_size < mtu) {
 			if (np->frag_size)
@@ -1270,7 +1270,7 @@ alloc_new_skb:
 			if (skb == NULL || skb_prev == NULL)
 				ip6_append_data_mtu(&mtu, &maxfraglen,
 						    fragheaderlen, skb, rt,
-						    np->pmtudisc ==
+						    np->pmtudisc >=
 						    IPV6_PMTUDISC_PROBE);
 
 			skb_prev = skb;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 759fbf9..af0ecb9 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -722,7 +722,7 @@ done:
 	case IPV6_MTU_DISCOVER:
 		if (optlen < sizeof(int))
 			goto e_inval;
-		if (val < IP_PMTUDISC_DONT || val > IP_PMTUDISC_PROBE)
+		if (val < IPV6_PMTUDISC_DONT || val > IPV6_PMTUDISC_INTERFACE)
 			goto e_inval;
 		np->pmtudisc = val;
 		retv = 0;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index bd91e7f..f20eab3 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -398,6 +398,9 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		if (sk->sk_state == TCP_LISTEN)
 			goto out;
 
+		if (!ip6_sk_accept_pmtu(sk))
+			goto out;
+
 		tp->mtu_info = ntohl(info);
 		if (!sock_owned_by_user(sk))
 			tcp_v6_mtu_reduced(sk);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index bcd5699..ce3e7bc 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -538,8 +538,11 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (sk == NULL)
 		return;
 
-	if (type == ICMPV6_PKT_TOOBIG)
+	if (type == ICMPV6_PKT_TOOBIG) {
+		if (!ip6_sk_accept_pmtu(sk))
+			goto out;
 		ip6_sk_update_pmtu(skb, sk, info);
+	}
 	if (type == NDISC_REDIRECT) {
 		ip6_sk_redirect(skb, sk);
 		goto out;
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 2a192a7..042ec6c 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -389,6 +389,9 @@ void sctp_icmp_frag_needed(struct sock *sk, struct sctp_association *asoc,
 	if (!t || (t->pathmtu <= pmtu))
 		return;
 
+	if (!ip6_sk_accept_pmtu(sk))
+		return;
+
 	if (sock_owned_by_user(sk)) {
 		asoc->pmtu_pending = 1;
 		t->pmtu_pending = 1;
-- 
1.8.3.1
