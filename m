From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next v5 02/11] ipv6: Remove external dependency on rt6i_dst and rt6i_src
Date: Fri, 22 May 2015 20:55:57 -0700
Message-ID: <1432353366-2296465-3-git-send-email-kafai@fb.com>
References: <1432353366-2296465-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:38575 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757129AbbEWD4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 23:56:15 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4N3snOa013958
	for <netdev@vger.kernel.org>; Fri, 22 May 2015 20:56:14 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1ujba10j0t-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 22 May 2015 20:56:14 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 a6b71e9c00ff11e58dbc0002c991e86a-726dd3a0 for <netdev@vger.kernel.org>;	Fri,
 22 May 2015 20:56:12 -0700
In-Reply-To: <1432353366-2296465-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the assumptions that the returned rt is always
a RTF_CACHE entry with the rt6i_dst and rt6i_src containing the
destination and source address.  The dst and src can be recovered from
the calling site.

We may consider to rename (rt6i_dst, rt6i_src) to
(rt6i_key_dst, rt6i_key_src) later.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Julian Anastasov <ja@ssi.bg>
---
 drivers/scsi/cxgbi/libcxgbi.c   |  2 +-
 include/net/ipv6.h              |  4 +++-
 net/ipv6/icmp.c                 |  2 +-
 net/ipv6/ip6_output.c           | 13 ++++++++-----
 net/ipv6/ndisc.c                |  2 +-
 net/ipv6/output_core.c          | 10 ++++++----
 net/ipv6/tcp_ipv6.c             |  2 +-
 net/netfilter/ipvs/ip_vs_xmit.c |  4 ++--
 net/sctp/ipv6.c                 |  3 ++-
 9 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index eb58afc..45d3039 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -728,7 +728,7 @@ static struct cxgbi_sock *cxgbi_check_route6(struct sockaddr *dst_addr)
 	}
 	ndev = n->dev;
 
-	if (ipv6_addr_is_multicast(&rt->rt6i_dst.addr)) {
+	if (ipv6_addr_is_multicast(&daddr6->sin6_addr)) {
 		pr_info("multi-cast route %pI6 port %u, dev %s.\n",
 			daddr6->sin6_addr.s6_addr,
 			ntohs(daddr6->sin6_port), ndev->name);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 8c4f881..b950a20 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -671,7 +671,9 @@ static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_add
 	return __ipv6_addr_diff(a1, a2, sizeof(struct in6_addr));
 }
 
-u32 ipv6_select_ident(struct net *net, struct rt6_info *rt);
+u32 ipv6_select_ident(struct net *net,
+		      const struct in6_addr *daddr,
+		      const struct in6_addr *saddr);
 void ipv6_proxy_select_ident(struct net *net, struct sk_buff *skb);
 
 int ip6_dst_hoplimit(struct dst_entry *dst);
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 2c2b5d5..24b359d 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -207,7 +207,7 @@ static bool icmpv6_xrlim_allow(struct sock *sk, u8 type,
 			struct inet_peer *peer;
 
 			peer = inet_getpeer_v6(net->ipv6.peers,
-					       &rt->rt6i_dst.addr, 1);
+					       &fl6->daddr, 1);
 			res = inet_peer_xrlim_allow(peer, tmo);
 			if (peer)
 				inet_putpeer(peer);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index e4772ab..1b0e3ad 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -459,7 +459,7 @@ int ip6_forward(struct sk_buff *skb)
 		else
 			target = &hdr->daddr;
 
-		peer = inet_getpeer_v6(net->ipv6.peers, &rt->rt6i_dst.addr, 1);
+		peer = inet_getpeer_v6(net->ipv6.peers, &hdr->daddr, 1);
 
 		/* Limit redirects both by destination (here)
 		   and by source (inside ndisc_send_redirect)
@@ -584,7 +584,8 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
 	}
 	mtu -= hlen + sizeof(struct frag_hdr);
 
-	frag_id = ipv6_select_ident(net, rt);
+	frag_id = ipv6_select_ident(net, &ipv6_hdr(skb)->daddr,
+				    &ipv6_hdr(skb)->saddr);
 
 	if (skb_has_frag_list(skb)) {
 		int first_len = skb_pagelen(skb);
@@ -1057,7 +1058,7 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 			int odd, struct sk_buff *skb),
 			void *from, int length, int hh_len, int fragheaderlen,
 			int transhdrlen, int mtu, unsigned int flags,
-			struct rt6_info *rt)
+			const struct flowi6 *fl6)
 
 {
 	struct sk_buff *skb;
@@ -1102,7 +1103,9 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 	skb_shinfo(skb)->gso_size = (mtu - fragheaderlen -
 				     sizeof(struct frag_hdr)) & ~7;
 	skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
-	skb_shinfo(skb)->ip6_frag_id = ipv6_select_ident(sock_net(sk), rt);
+	skb_shinfo(skb)->ip6_frag_id = ipv6_select_ident(sock_net(sk),
+							 &fl6->daddr,
+							 &fl6->saddr);
 
 append:
 	return skb_append_datato_frags(sk, skb, getfrag, from,
@@ -1325,7 +1328,7 @@ emsgsize:
 	    (sk->sk_type == SOCK_DGRAM)) {
 		err = ip6_ufo_append_data(sk, queue, getfrag, from, length,
 					  hh_len, fragheaderlen,
-					  transhdrlen, mtu, flags, rt);
+					  transhdrlen, mtu, flags, fl6);
 		if (err)
 			goto error;
 		return 0;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 96f153c..0a05b35 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1506,7 +1506,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 			  "Redirect: destination is not a neighbour\n");
 		goto release;
 	}
-	peer = inet_getpeer_v6(net->ipv6.peers, &rt->rt6i_dst.addr, 1);
+	peer = inet_getpeer_v6(net->ipv6.peers, &ipv6_hdr(skb)->saddr, 1);
 	ret = inet_peer_xrlim_allow(peer, 1*HZ);
 	if (peer)
 		inet_putpeer(peer);
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index ef0e232..055e85c 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -10,7 +10,8 @@
 #include <net/secure_seq.h>
 
 static u32 __ipv6_select_ident(struct net *net, u32 hashrnd,
-			       struct in6_addr *dst, struct in6_addr *src)
+			       const struct in6_addr *dst,
+			       const struct in6_addr *src)
 {
 	u32 hash, id;
 
@@ -60,15 +61,16 @@ void ipv6_proxy_select_ident(struct net *net, struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(ipv6_proxy_select_ident);
 
-u32 ipv6_select_ident(struct net *net, struct rt6_info *rt)
+u32 ipv6_select_ident(struct net *net,
+		      const struct in6_addr *daddr,
+		      const struct in6_addr *saddr)
 {
 	static u32 ip6_idents_hashrnd __read_mostly;
 	u32 id;
 
 	net_get_random_once(&ip6_idents_hashrnd, sizeof(ip6_idents_hashrnd));
 
-	id = __ipv6_select_ident(net, ip6_idents_hashrnd, &rt->rt6i_dst.addr,
-				 &rt->rt6i_src.addr);
+	id = __ipv6_select_ident(net, ip6_idents_hashrnd, daddr, saddr);
 	return htonl(id);
 }
 EXPORT_SYMBOL(ipv6_select_ident);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index beac6bf..2275999 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -262,7 +262,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	rt = (struct rt6_info *) dst;
 	if (tcp_death_row.sysctl_tw_recycle &&
 	    !tp->rx_opt.ts_recent_stamp &&
-	    ipv6_addr_equal(&rt->rt6i_dst.addr, &sk->sk_v6_daddr))
+	    ipv6_addr_equal(&fl6.daddr, &sk->sk_v6_daddr))
 		tcp_fetch_timewait_stamp(sk, dst);
 
 	icsk->icsk_ext_hdr_len = 0;
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 19986ec..38f8627 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -781,7 +781,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* From world but DNAT to loopback address? */
 	if (local && skb->dev && !(skb->dev->flags & IFF_LOOPBACK) &&
-	    ipv6_addr_type(&rt->rt6i_dst.addr) & IPV6_ADDR_LOOPBACK) {
+	    ipv6_addr_type(&cp->daddr.in6) & IPV6_ADDR_LOOPBACK) {
 		IP_VS_DBG_RL_PKT(1, AF_INET6, pp, skb, 0,
 				 "ip_vs_nat_xmit_v6(): "
 				 "stopping DNAT to loopback address");
@@ -1346,7 +1346,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* From world but DNAT to loopback address? */
 	if (local && skb->dev && !(skb->dev->flags & IFF_LOOPBACK) &&
-	    ipv6_addr_type(&rt->rt6i_dst.addr) & IPV6_ADDR_LOOPBACK) {
+	    ipv6_addr_type(&cp->daddr.in6) & IPV6_ADDR_LOOPBACK) {
 		IP_VS_DBG(1, "%s(): "
 			  "stopping DNAT to loopback %pI6\n",
 			  __func__, &cp->daddr.in6);
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index e703ff7..17a0120 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -332,7 +332,8 @@ out:
 		rt = (struct rt6_info *)dst;
 		t->dst = dst;
 		t->dst_cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
-		pr_debug("rt6_dst:%pI6 rt6_src:%pI6\n", &rt->rt6i_dst.addr,
+		pr_debug("rt6_dst:%pI6/%d rt6_src:%pI6\n",
+			 &rt->rt6i_dst.addr, rt->rt6i_dst.plen,
 			 &fl6->saddr);
 	} else {
 		t->dst = NULL;
-- 
1.8.1
