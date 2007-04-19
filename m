From: John Heffner <jheffner@psc.edu>
Subject: [PATCH] Revert "[NET] Add IP(V6)_PMTUDISC_RPOBE"
Date: Wed, 18 Apr 2007 21:07:41 -0400
Message-ID: <11769448643248-git-send-email-jheffner@psc.edu>
References: <11746948063923-git-send-email-jheffner@psc.edu>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	John Heffner <jheffner@psc.edu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:51444 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030985AbXDSBHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2007 21:07:49 -0400
In-Reply-To: <11746948063923-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit d21d2a90b879c0cf159df5944847e6d9833816eb.

Must be backed out because commit 87e927a0583bd4a8ba9e97cd75b58d8aa1c76e37
does not work.

Signed-off-by: John Heffner <jheffner@psc.edu>
---
 include/linux/in.h       |    1 -
 include/linux/in6.h      |    1 -
 include/linux/skbuff.h   |    3 +--
 include/net/ip.h         |    2 +-
 net/core/skbuff.c        |    2 --
 net/ipv4/ip_output.c     |   14 ++++----------
 net/ipv4/ip_sockglue.c   |    2 +-
 net/ipv4/raw.c           |    3 ---
 net/ipv6/ip6_output.c    |   12 ++++--------
 net/ipv6/ipv6_sockglue.c |    2 +-
 net/ipv6/raw.c           |    3 ---
 11 files changed, 12 insertions(+), 33 deletions(-)

diff --git a/include/linux/in.h b/include/linux/in.h
index 2dc1f8a..1912e7c 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -83,7 +83,6 @@ struct in_addr {
 #define IP_PMTUDISC_DONT		0	/* Never send DF frames */
 #define IP_PMTUDISC_WANT		1	/* Use per route hints	*/
 #define IP_PMTUDISC_DO			2	/* Always DF		*/
-#define IP_PMTUDISC_PROBE		3	/* Ignore dst pmtu	*/
 
 #define IP_MULTICAST_IF			32
 #define IP_MULTICAST_TTL 		33
diff --git a/include/linux/in6.h b/include/linux/in6.h
index d559fac..4e8350a 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -179,7 +179,6 @@ struct in6_flowlabel_req
 #define IPV6_PMTUDISC_DONT		0
 #define IPV6_PMTUDISC_WANT		1
 #define IPV6_PMTUDISC_DO		2
-#define IPV6_PMTUDISC_PROBE		3
 
 /* Flowlabel */
 #define IPV6_FLOWLABEL_MGR	32
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8bf9b9f..7f17cfc 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -277,8 +277,7 @@ struct sk_buff {
 				nfctinfo:3;
 	__u8			pkt_type:3,
 				fclone:2,
-				ipvs_property:1,
-				ign_dst_mtu:1;
+				ipvs_property:1;
 	__be16			protocol;
 
 	void			(*destructor)(struct sk_buff *skb);
diff --git a/include/net/ip.h b/include/net/ip.h
index 6a08b65..75f226d 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -206,7 +206,7 @@ int ip_decrease_ttl(struct iphdr *iph)
 static inline
 int ip_dont_fragment(struct sock *sk, struct dst_entry *dst)
 {
-	return (inet_sk(sk)->pmtudisc >= IP_PMTUDISC_DO ||
+	return (inet_sk(sk)->pmtudisc == IP_PMTUDISC_DO ||
 		(inet_sk(sk)->pmtudisc == IP_PMTUDISC_WANT &&
 		 !(dst_metric(dst, RTAX_LOCK)&(1<<RTAX_MTU))));
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2391cdf..f0d986a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -479,7 +479,6 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	C(ipvs_property);
 #endif
-	C(ign_dst_mtu);
 	C(protocol);
 	n->destructor = NULL;
 	C(mark);
@@ -543,7 +542,6 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	new->ipvs_property = old->ipvs_property;
 #endif
-	new->ign_dst_mtu	= old->ign_dst_mtu;
 #ifdef CONFIG_NET_SCHED
 #ifdef CONFIG_NET_CLS_ACT
 	new->tc_verd = old->tc_verd;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 704bc44..79e71ee 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -198,8 +198,7 @@ static inline int ip_finish_output(struct sk_buff *skb)
 		return dst_output(skb);
 	}
 #endif
-	if (skb->len > dst_mtu(skb->dst) &&
-	    !skb->ign_dst_mtu && !skb_is_gso(skb))
+	if (skb->len > dst_mtu(skb->dst) && !skb_is_gso(skb))
 		return ip_fragment(skb, ip_finish_output2);
 	else
 		return ip_finish_output2(skb);
@@ -788,9 +787,7 @@ int ip_append_data(struct sock *sk,
 			inet->cork.addr = ipc->addr;
 		}
 		dst_hold(&rt->u.dst);
-		inet->cork.fragsize = mtu = inet->pmtudisc == IP_PMTUDISC_PROBE ?
-		                            rt->u.dst.dev->mtu :
-		                            dst_mtu(rt->u.dst.path);
+		inet->cork.fragsize = mtu = dst_mtu(rt->u.dst.path);
 		inet->cork.rt = rt;
 		inet->cork.length = 0;
 		sk->sk_sndmsg_page = NULL;
@@ -1208,16 +1205,13 @@ int ip_push_pending_frames(struct sock *sk)
 	 * to fragment the frame generated here. No matter, what transforms
 	 * how transforms change size of the packet, it will come out.
 	 */
-	if (inet->pmtudisc < IP_PMTUDISC_DO)
+	if (inet->pmtudisc != IP_PMTUDISC_DO)
 		skb->local_df = 1;
 
-	if (inet->pmtudisc == IP_PMTUDISC_PROBE)
-		skb->ign_dst_mtu = 1;
-
 	/* DF bit is set when we want to see DF on outgoing frames.
 	 * If local_df is set too, we still allow to fragment this frame
 	 * locally. */
-	if (inet->pmtudisc >= IP_PMTUDISC_DO ||
+	if (inet->pmtudisc == IP_PMTUDISC_DO ||
 	    (skb->len <= dst_mtu(&rt->u.dst) &&
 	     ip_dont_fragment(sk, &rt->u.dst)))
 		df = htons(IP_DF);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 4d54457..c199d23 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -542,7 +542,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		inet->hdrincl = val ? 1 : 0;
 		break;
 	case IP_MTU_DISCOVER:
-		if (val<0 || val>3)
+		if (val<0 || val>2)
 			goto e_inval;
 		inet->pmtudisc = val;
 		break;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index addb786..c60aadf 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -304,9 +304,6 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 	if (err)
 		goto error_fault;
 
-	if (inet->pmtudisc == IP_PMTUDISC_PROBE)
-		skb->ign_dst_mtu = 1;
-
 	/* We don't modify invalid header */
 	if (length >= sizeof(*iph) && iph->ihl * 4U <= length) {
 		if (!iph->saddr)
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 78317a4..b8e307a 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -139,8 +139,8 @@ static int ip6_output2(struct sk_buff *skb)
 
 int ip6_output(struct sk_buff *skb)
 {
-	if ((skb->len > dst_mtu(skb->dst) && !skb->ign_dst_mtu &&
-	     !skb_is_gso(skb)) || dst_allfrag(skb->dst))
+	if ((skb->len > dst_mtu(skb->dst) && !skb_is_gso(skb)) ||
+				dst_allfrag(skb->dst))
 		return ip6_fragment(skb, ip6_output2);
 	else
 		return ip6_output2(skb);
@@ -566,7 +566,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	hlen = ip6_find_1stfragopt(skb, &prevhdr);
 	nexthdr = *prevhdr;
 
-	mtu = skb->ign_dst_mtu ? skb->len : dst_mtu(&rt->u.dst);
+	mtu = dst_mtu(&rt->u.dst);
 	if (np && np->frag_size < mtu) {
 		if (np->frag_size)
 			mtu = np->frag_size;
@@ -1050,8 +1050,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		inet->cork.fl = *fl;
 		np->cork.hop_limit = hlimit;
 		np->cork.tclass = tclass;
-		mtu = np->pmtudisc == IPV6_PMTUDISC_PROBE ?
-		      rt->u.dst.dev->mtu : dst_mtu(rt->u.dst.path);
+		mtu = dst_mtu(rt->u.dst.path);
 		if (np->frag_size < mtu) {
 			if (np->frag_size)
 				mtu = np->frag_size;
@@ -1339,9 +1338,6 @@ int ip6_push_pending_frames(struct sock *sk)
 		tmp_skb->sk = NULL;
 	}
 
-	if (np->pmtudisc == IPV6_PMTUDISC_PROBE)
-		skb->ign_dst_mtu = 1;
-
 	ipv6_addr_copy(final_dst, &fl->fl6_dst);
 	__skb_pull(skb, skb_network_header_len(skb));
 	if (opt && opt->opt_flen)
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index aa3d07c..da930fa 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -694,7 +694,7 @@ done:
 		retv = ip6_ra_control(sk, val, NULL);
 		break;
 	case IPV6_MTU_DISCOVER:
-		if (val<0 || val>3)
+		if (val<0 || val>2)
 			goto e_inval;
 		np->pmtudisc = val;
 		retv = 0;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 86c9943..f4cd90b 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -591,9 +591,6 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 	if (err)
 		goto error_fault;
 
-	if (np->pmtudisc == IPV6_PMTUDISC_PROBE)
-		skb->ign_dst_mtu = 1;
-
 	IP6_INC_STATS(rt->rt6i_idev, IPSTATS_MIB_OUTREQUESTS);
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		      dst_output);
-- 
1.5.1.rc3.30.ga8f4-dirty

