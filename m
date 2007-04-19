From: John Heffner <jheffner@psc.edu>
Subject: [PATCH] [NET] Add IP(V6)_PMTUDISC_RPOBE
Date: Wed, 18 Apr 2007 21:07:44 -0400
Message-ID: <11769448651329-git-send-email-jheffner@psc.edu>
References: <11746948063923-git-send-email-jheffner@psc.edu> <11769448643248-git-send-email-jheffner@psc.edu> <11769448642649-git-send-email-jheffner@psc.edu> <11769448654084-git-send-email-jheffner@psc.edu>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	John Heffner <jheffner@psc.edu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:51443 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030988AbXDSBHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2007 21:07:49 -0400
In-Reply-To: <11769448654084-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add IP(V6)_PMTUDISC_PROBE value for IP(V6)_MTU_DISCOVER.  This option forces
us not to fragment, but does not make use of the kernel path MTU discovery.
That is, it allows for user-mode MTU probing (or, packetization-layer path
MTU discovery).  This is particularly useful for diagnostic utilities, like
traceroute/tracepath.

Signed-off-by: John Heffner <jheffner@psc.edu>
---
 include/linux/in.h       |    1 +
 include/linux/in6.h      |    1 +
 net/ipv4/ip_output.c     |   20 +++++++++++++++-----
 net/ipv4/ip_sockglue.c   |    2 +-
 net/ipv6/ip6_output.c    |   15 ++++++++++++---
 net/ipv6/ipv6_sockglue.c |    2 +-
 6 files changed, 31 insertions(+), 10 deletions(-)

diff --git a/include/linux/in.h b/include/linux/in.h
index 1912e7c..3975cbf 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -83,6 +83,7 @@ struct in_addr {
 #define IP_PMTUDISC_DONT		0	/* Never send DF frames */
 #define IP_PMTUDISC_WANT		1	/* Use per route hints	*/
 #define IP_PMTUDISC_DO			2	/* Always DF		*/
+#define IP_PMTUDISC_PROBE		3       /* Ignore dst pmtu      */
 
 #define IP_MULTICAST_IF			32
 #define IP_MULTICAST_TTL 		33
diff --git a/include/linux/in6.h b/include/linux/in6.h
index 4e8350a..d559fac 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -179,6 +179,7 @@ struct in6_flowlabel_req
 #define IPV6_PMTUDISC_DONT		0
 #define IPV6_PMTUDISC_WANT		1
 #define IPV6_PMTUDISC_DO		2
+#define IPV6_PMTUDISC_PROBE		3
 
 /* Flowlabel */
 #define IPV6_FLOWLABEL_MGR	32
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 34606ef..66e2c3a 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -189,6 +189,14 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	return -EINVAL;
 }
 
+static inline int ip_skb_dst_mtu(struct sk_buff *skb)
+{
+	struct inet_sock *inet = skb->sk ? inet_sk(skb->sk) : NULL;
+
+	return (inet && inet->pmtudisc == IP_PMTUDISC_PROBE) ?
+	       skb->dst->dev->mtu : dst_mtu(skb->dst);
+}
+
 static inline int ip_finish_output(struct sk_buff *skb)
 {
 #if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
@@ -198,7 +206,7 @@ static inline int ip_finish_output(struct sk_buff *skb)
 		return dst_output(skb);
 	}
 #endif
-	if (skb->len > dst_mtu(skb->dst) && !skb_is_gso(skb))
+	if (skb->len > ip_skb_dst_mtu(skb) && !skb_is_gso(skb))
 		return ip_fragment(skb, ip_finish_output2);
 	else
 		return ip_finish_output2(skb);
@@ -422,7 +430,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
 	if (unlikely((iph->frag_off & htons(IP_DF)) && !skb->local_df)) {
 		IP_INC_STATS(IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
-			  htonl(dst_mtu(&rt->u.dst)));
+			  htonl(ip_skb_dst_mtu(skb)));
 		kfree_skb(skb);
 		return -EMSGSIZE;
 	}
@@ -787,7 +795,9 @@ int ip_append_data(struct sock *sk,
 			inet->cork.addr = ipc->addr;
 		}
 		dst_hold(&rt->u.dst);
-		inet->cork.fragsize = mtu = dst_mtu(rt->u.dst.path);
+		inet->cork.fragsize = mtu = inet->pmtudisc == IP_PMTUDISC_PROBE ?
+					    rt->u.dst.dev->mtu : 
+					    dst_mtu(rt->u.dst.path);
 		inet->cork.rt = rt;
 		inet->cork.length = 0;
 		sk->sk_sndmsg_page = NULL;
@@ -1203,13 +1213,13 @@ int ip_push_pending_frames(struct sock *sk)
 	 * to fragment the frame generated here. No matter, what transforms
 	 * how transforms change size of the packet, it will come out.
 	 */
-	if (inet->pmtudisc != IP_PMTUDISC_DO)
+	if (inet->pmtudisc < IP_PMTUDISC_DO)
 		skb->local_df = 1;
 
 	/* DF bit is set when we want to see DF on outgoing frames.
 	 * If local_df is set too, we still allow to fragment this frame
 	 * locally. */
-	if (inet->pmtudisc == IP_PMTUDISC_DO ||
+	if (inet->pmtudisc >= IP_PMTUDISC_DO ||
 	    (skb->len <= dst_mtu(&rt->u.dst) &&
 	     ip_dont_fragment(sk, &rt->u.dst)))
 		df = htons(IP_DF);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index c199d23..4d54457 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -542,7 +542,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		inet->hdrincl = val ? 1 : 0;
 		break;
 	case IP_MTU_DISCOVER:
-		if (val<0 || val>2)
+		if (val<0 || val>3)
 			goto e_inval;
 		inet->pmtudisc = val;
 		break;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 5a5b7d4..f508171 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -137,9 +137,17 @@ static int ip6_output2(struct sk_buff *skb)
 	return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb,NULL, skb->dev,ip6_output_finish);
 }
 
+static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
+{
+	struct ipv6_pinfo *np = skb->sk ? inet6_sk(skb->sk) : NULL;
+
+	return (np && np->pmtudisc == IPV6_PMTUDISC_PROBE) ?
+	       skb->dst->dev->mtu : dst_mtu(skb->dst);
+}
+
 int ip6_output(struct sk_buff *skb)
 {
-	if ((skb->len > dst_mtu(skb->dst) && !skb_is_gso(skb)) ||
+	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
 				dst_allfrag(skb->dst))
 		return ip6_fragment(skb, ip6_output2);
 	else
@@ -566,7 +574,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	hlen = ip6_find_1stfragopt(skb, &prevhdr);
 	nexthdr = *prevhdr;
 
-	mtu = dst_mtu(&rt->u.dst);
+	mtu = ip6_skb_dst_mtu(skb);
 
 	/* We must not fragment if the socket is set to force MTU discovery
 	 * or if the skb it not generated by a local socket.  (This last
@@ -1063,7 +1071,8 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		inet->cork.fl = *fl;
 		np->cork.hop_limit = hlimit;
 		np->cork.tclass = tclass;
-		mtu = dst_mtu(rt->u.dst.path);
+		mtu = np->pmtudisc == IPV6_PMTUDISC_PROBE ?
+		      rt->u.dst.dev->mtu : dst_mtu(rt->u.dst.path);
 		if (np->frag_size < mtu) {
 			if (np->frag_size)
 				mtu = np->frag_size;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index da930fa..aa3d07c 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -694,7 +694,7 @@ done:
 		retv = ip6_ra_control(sk, val, NULL);
 		break;
 	case IPV6_MTU_DISCOVER:
-		if (val<0 || val>2)
+		if (val<0 || val>3)
 			goto e_inval;
 		np->pmtudisc = val;
 		retv = 0;
-- 
1.5.1.rc3.30.ga8f4-dirty

