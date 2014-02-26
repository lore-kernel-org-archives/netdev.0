From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net 3/3] ipv6: yet another new IPV6_MTU_DISCOVER option IPV6_PMTUDISC_OMIT
Date: Wed, 26 Feb 2014 01:20:43 +0100
Message-ID: <1393374043-796-4-git-send-email-hannes@stressinduktion.org>
References: <1393374043-796-1-git-send-email-hannes@stressinduktion.org>
Cc: Florian Weimer <fweimer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52925 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138AbaBZAUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 19:20:50 -0500
In-Reply-To: <1393374043-796-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This option has the same semantic as IP_PMTUDISC_OMIT for IPv4 which
got recently introduced. It doesn't honor the path mtu discovered by the
host but in contrary to IPV6_PMTUDISC_INTERFACE allows the generation of
fragments if the packet size exceeds the MTU of the outgoing interface
MTU.

Fixes: 93b36cf3425b9b ("ipv6: support IPV6_PMTU_INTERFACE on sockets")
Cc: Florian Weimer <fweimer@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip6_route.h  | 9 ++++++++-
 include/uapi/linux/in6.h | 4 ++++
 net/ipv6/ip6_output.c    | 9 +++++----
 net/ipv6/ipv6_sockglue.c | 2 +-
 4 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 017badb..00e3f12 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -171,7 +171,14 @@ static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
 
 static inline bool ip6_sk_accept_pmtu(const struct sock *sk)
 {
-	return inet6_sk(sk)->pmtudisc != IPV6_PMTUDISC_INTERFACE;
+	return inet6_sk(sk)->pmtudisc != IPV6_PMTUDISC_INTERFACE &&
+	       inet6_sk(sk)->pmtudisc != IPV6_PMTUDISC_OMIT;
+}
+
+static inline bool ip6_sk_local_df(const struct sock *sk)
+{
+	return inet6_sk(sk)->pmtudisc < IPV6_PMTUDISC_DO ||
+	       inet6_sk(sk)->pmtudisc == IPV6_PMTUDISC_OMIT;
 }
 
 static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt)
diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
index e9a1d2d..0d8e0f0 100644
--- a/include/uapi/linux/in6.h
+++ b/include/uapi/linux/in6.h
@@ -185,6 +185,10 @@ struct in6_flowlabel_req {
  * also see comments on IP_PMTUDISC_INTERFACE
  */
 #define IPV6_PMTUDISC_INTERFACE		4
+/* weaker version of IPV6_PMTUDISC_INTERFACE, which allows packets to
+ * get fragmented if they exceed the interface mtu
+ */
+#define IPV6_PMTUDISC_OMIT		5
 
 /* Flowlabel */
 #define IPV6_FLOWLABEL_MGR	32
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 16f91a2..2bc1070 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1231,8 +1231,10 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 			      sizeof(struct frag_hdr) : 0) +
 			     rt->rt6i_nfheader_len;
 
-		maxnonfragsize = (np->pmtudisc >= IPV6_PMTUDISC_DO) ?
-				 mtu : sizeof(struct ipv6hdr) + IPV6_MAXPLEN;
+		if (ip6_sk_local_df(sk))
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
+	skb->local_df = ip6_sk_local_df(sk);
 
 	*final_dst = fl6->daddr;
 	__skb_pull(skb, skb_network_header_len(skb));
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 0a00f44..edb58af 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -722,7 +722,7 @@ done:
 	case IPV6_MTU_DISCOVER:
 		if (optlen < sizeof(int))
 			goto e_inval;
-		if (val < IPV6_PMTUDISC_DONT || val > IPV6_PMTUDISC_INTERFACE)
+		if (val < IPV6_PMTUDISC_DONT || val > IPV6_PMTUDISC_OMIT)
 			goto e_inval;
 		np->pmtudisc = val;
 		retv = 0;
-- 
1.8.5.3
