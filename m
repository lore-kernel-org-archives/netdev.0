From: John Heffner <jheffner@psc.edu>
Subject: [PATCH 3/3] [NET] Add IP(V6)_PMTUDISC_RPOBE
Date: Fri, 23 Mar 2007 20:06:46 -0400
Message-ID: <11746948063971-git-send-email-jheffner@psc.edu>
References: <11746948063923-git-send-email-jheffner@psc.edu> <11746948061847-git-send-email-jheffner@psc.edu>
Cc: netdev@vger.kernel.org, John Heffner <jheffner@psc.edu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:59453 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752366AbXCXAp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 20:45:27 -0400
In-Reply-To: <11746948061847-git-send-email-jheffner@psc.edu>
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
 include/linux/skbuff.h   |    3 ++-
 include/net/ip.h         |    2 +-
 net/core/skbuff.c        |    2 ++
 net/ipv4/ip_output.c     |   14 ++++++++++----
 net/ipv4/ip_sockglue.c   |    2 +-
 net/ipv4/raw.c           |    3 +++
 net/ipv6/ip6_output.c    |   12 ++++++++----
 net/ipv6/ipv6_sockglue.c |    2 +-
 net/ipv6/raw.c           |    3 +++
 11 files changed, 33 insertions(+), 12 deletions(-)

diff --git a/include/linux/in.h b/include/linux/in.h
index 1912e7c..2dc1f8a 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -83,6 +83,7 @@ struct in_addr {
 #define IP_PMTUDISC_DONT		0	/* Never send DF frames */
 #define IP_PMTUDISC_WANT		1	/* Use per route hints	*/
 #define IP_PMTUDISC_DO			2	/* Always DF		*/
+#define IP_PMTUDISC_PROBE		3	/* Ignore dst pmtu	*/
 
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
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4ff3940..64038b4 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -284,7 +284,8 @@ struct sk_buff {
 				nfctinfo:3;
 	__u8			pkt_type:3,
 				fclone:2,
-				ipvs_property:1;
+				ipvs_property:1,
+				ign_dst_mtu;
 	__be16			protocol;
 
 	void			(*destructor)(struct sk_buff *skb);
diff --git a/include/net/ip.h b/include/net/ip.h
index e79c3e3..f5874a3 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -201,7 +201,7 @@ int ip_decrease_ttl(struct iphdr *iph)
 static inline
 int ip_dont_fragment(struct sock *sk, struct dst_entry *dst)
 {
-	return (inet_sk(sk)->pmtudisc == IP_PMTUDISC_DO ||
+	return (inet_sk(sk)->pmtudisc >= IP_PMTUDISC_DO ||
 		(inet_sk(sk)->pmtudisc == IP_PMTUDISC_WANT &&
 		 !(dst_metric(dst, RTAX_LOCK)&(1<<RTAX_MTU))));
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 702fa8f..5c8515c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -474,6 +474,7 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	C(ipvs_property);
 #endif
+	C(ign_dst_mtu);
 	C(protocol);
 	n->destructor = NULL;
 	C(mark);
@@ -549,6 +550,7 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	new->ipvs_property = old->ipvs_property;
 #endif
+	new->ign_dst_mtu	= old->ign_dst_mtu;
 #ifdef CONFIG_BRIDGE_NETFILTER
 	new->nf_bridge	= old->nf_bridge;
 	nf_bridge_get(old->nf_bridge);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 90bdd53..a7e8944 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -201,7 +201,8 @@ static inline int ip_finish_output(struct sk_buff *skb)
 		return dst_output(skb);
 	}
 #endif
-	if (skb->len > dst_mtu(skb->dst) && !skb_is_gso(skb))
+	if (skb->len > dst_mtu(skb->dst) &&
+	    !skb->ign_dst_mtu && !skb_is_gso(skb))
 		return ip_fragment(skb, ip_finish_output2);
 	else
 		return ip_finish_output2(skb);
@@ -801,7 +802,9 @@ int ip_append_data(struct sock *sk,
 			inet->cork.addr = ipc->addr;
 		}
 		dst_hold(&rt->u.dst);
-		inet->cork.fragsize = mtu = dst_mtu(rt->u.dst.path);
+		inet->cork.fragsize = mtu = inet->pmtudisc == IP_PMTUDISC_PROBE ?
+		                            rt->u.dst.dev->mtu :
+		                            dst_mtu(rt->u.dst.path);
 		inet->cork.rt = rt;
 		inet->cork.length = 0;
 		sk->sk_sndmsg_page = NULL;
@@ -1220,13 +1223,16 @@ int ip_push_pending_frames(struct sock *sk)
 	 * to fragment the frame generated here. No matter, what transforms
 	 * how transforms change size of the packet, it will come out.
 	 */
-	if (inet->pmtudisc != IP_PMTUDISC_DO)
+	if (inet->pmtudisc < IP_PMTUDISC_DO)
 		skb->local_df = 1;
 
+	if (inet->pmtudisc == IP_PMTUDISC_PROBE)
+		skb->ign_dst_mtu = 1;
+
 	/* DF bit is set when we want to see DF on outgoing frames.
 	 * If local_df is set too, we still allow to fragment this frame
 	 * locally. */
-	if (inet->pmtudisc == IP_PMTUDISC_DO ||
+	if (inet->pmtudisc >= IP_PMTUDISC_DO ||
 	    (skb->len <= dst_mtu(&rt->u.dst) &&
 	     ip_dont_fragment(sk, &rt->u.dst)))
 		df = htons(IP_DF);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 23048d9..98fa088 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -536,7 +536,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			inet->hdrincl = val ? 1 : 0;
 			break;
 		case IP_MTU_DISCOVER:
-			if (val<0 || val>2)
+			if (val<0 || val>3)
 				goto e_inval;
 			inet->pmtudisc = val;
 			break;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index f252f4e..f562262 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -302,6 +302,9 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 	if (err)
 		goto error_fault;
 
+	if (inet->pmtudisc == IP_PMTUDISC_PROBE)
+		skb->ign_dst_mtu = 1;
+
 	/* We don't modify invalid header */
 	if (length >= sizeof(*iph) && iph->ihl * 4U <= length) {
 		if (!iph->saddr)
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 711dfc3..8b8c04b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -139,8 +139,8 @@ static int ip6_output2(struct sk_buff *skb)
 
 int ip6_output(struct sk_buff *skb)
 {
-	if ((skb->len > dst_mtu(skb->dst) && !skb_is_gso(skb)) ||
-				dst_allfrag(skb->dst))
+	if ((skb->len > dst_mtu(skb->dst) && !skb->ign_dst_mtu &&
+	     !skb_is_gso(skb)) || dst_allfrag(skb->dst))
 		return ip6_fragment(skb, ip6_output2);
 	else
 		return ip6_output2(skb);
@@ -574,7 +574,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	hlen = ip6_find_1stfragopt(skb, &prevhdr);
 	nexthdr = *prevhdr;
 
-	mtu = dst_mtu(&rt->u.dst);
+	mtu = skb->ign_dst_mtu ? skb->len : dst_mtu(&rt->u.dst);
 	if (np && np->frag_size < mtu) {
 		if (np->frag_size)
 			mtu = np->frag_size;
@@ -1015,7 +1015,8 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		inet->cork.fl = *fl;
 		np->cork.hop_limit = hlimit;
 		np->cork.tclass = tclass;
-		mtu = dst_mtu(rt->u.dst.path);
+		mtu = np->pmtudisc == IPV6_PMTUDISC_PROBE ?
+		      rt->u.dst.dev->mtu : dst_mtu(rt->u.dst.path);
 		if (np->frag_size < mtu) {
 			if (np->frag_size)
 				mtu = np->frag_size;
@@ -1303,6 +1304,9 @@ int ip6_push_pending_frames(struct sock *sk)
 		tmp_skb->sk = NULL;
 	}
 
+	if (np->pmtudisc == IPV6_PMTUDISC_PROBE)
+		skb->ign_dst_mtu = 1;
+
 	ipv6_addr_copy(final_dst, &fl->fl6_dst);
 	__skb_pull(skb, skb->h.raw - skb->nh.raw);
 	if (opt && opt->opt_flen)
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index f5f9582..6e88597 100644
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
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 75db277..9ef0946 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -587,6 +587,9 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 	if (err)
 		goto error_fault;
 
+	if (np->pmtudisc == IPV6_PMTUDISC_PROBE)
+		skb->ign_dst_mtu = 1;
+
 	IP6_INC_STATS(rt->rt6i_idev, IPSTATS_MIB_OUTREQUESTS);
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		      dst_output);
-- 
1.5.0.2.gc260-dirty

