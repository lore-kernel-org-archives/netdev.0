From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 7/10] ipvs: Remove all remaining references to
 rt->rt_{src,dst}
Date: Wed, 11 May 2011 01:46:05 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1105110128100.4532@ja.ssi.bg>
References: <20110509.223127.102546540.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:55808 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751041Ab1EJWof (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2011 18:44:35 -0400
In-Reply-To: <20110509.223127.102546540.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Remove all remaining references to rt->rt_{src,dst}
by using dest->dst_saddr to cache saddr (used for TUN mode).
For ICMP in FORWARD hook just restrict the rt_mode for NAT
to disable LOCALNODE. All other modes do not allow
IP_VS_RT_MODE_RDR, so we should be safe with the ICMP
forwarding. Using cp->daddr as replacement for rt_dst
is safe for all modes except BYPASS, even when cp->dest is
NULL because it is cp->daddr that is used to assign cp->dest
for sync-ed connections.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

	I'm proposing this patch as replacement for
original patches 6 and 7, it can be number 7 again.
The idea is to avoid storing flowi in cp.

diff -urp net-next-2.6-7ef73bc/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- net-next-2.6-7ef73bc/linux/include/net/ip_vs.h	2011-05-09 07:24:07.000000000 +0300
+++ linux/include/net/ip_vs.h	2011-05-11 00:46:02.510271856 +0300
@@ -665,9 +665,7 @@ struct ip_vs_dest {
 	struct dst_entry	*dst_cache;	/* destination cache entry */
 	u32			dst_rtos;	/* RT_TOS(tos) for dst */
 	u32			dst_cookie;
-#ifdef CONFIG_IP_VS_IPV6
-	struct in6_addr		dst_saddr;
-#endif
+	union nf_inet_addr	dst_saddr;
 
 	/* for virtual service */
 	struct ip_vs_service	*svc;		/* service it belongs to */
@@ -1236,7 +1234,8 @@ extern int ip_vs_tunnel_xmit
 extern int ip_vs_dr_xmit
 (struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
 extern int ip_vs_icmp_xmit
-(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp, int offset);
+(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp,
+ int offset, unsigned int hooknum);
 extern void ip_vs_dst_reset(struct ip_vs_dest *dest);
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1250,7 +1249,7 @@ extern int ip_vs_dr_xmit_v6
 (struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
 extern int ip_vs_icmp_xmit_v6
 (struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp,
- int offset);
+ int offset, unsigned int hooknum);
 #endif
 
 #ifdef CONFIG_SYSCTL
diff -urp net-next-2.6-7ef73bc/linux/net/netfilter/ipvs/ip_vs_core.c linux/net/netfilter/ipvs/ip_vs_core.c
--- net-next-2.6-7ef73bc/linux/net/netfilter/ipvs/ip_vs_core.c	2011-05-09 07:24:07.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_core.c	2011-05-11 01:07:29.429270382 +0300
@@ -1378,15 +1378,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *
 	ip_vs_in_stats(cp, skb);
 	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol)
 		offset += 2 * sizeof(__u16);
-	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset);
-	/* LOCALNODE from FORWARD hook is not supported */
-	if (verdict == NF_ACCEPT && hooknum == NF_INET_FORWARD &&
-	    skb_rtable(skb)->rt_flags & RTCF_LOCAL) {
-		IP_VS_DBG(1, "%s(): "
-			  "local delivery to %pI4 but in FORWARD\n",
-			  __func__, &skb_rtable(skb)->rt_dst);
-		verdict = NF_DROP;
-	}
+	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum);
 
   out:
 	__ip_vs_conn_put(cp);
@@ -1408,7 +1400,6 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, in
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
 	unsigned int offset, verdict;
-	struct rt6_info *rt;
 
 	*related = 1;
 
@@ -1470,23 +1461,12 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, in
 	if (!cp)
 		return NF_ACCEPT;
 
-	verdict = NF_DROP;
-
 	/* do the statistics and put it back */
 	ip_vs_in_stats(cp, skb);
 	if (IPPROTO_TCP == cih->nexthdr || IPPROTO_UDP == cih->nexthdr ||
 	    IPPROTO_SCTP == cih->nexthdr)
 		offset += 2 * sizeof(__u16);
-	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offset);
-	/* LOCALNODE from FORWARD hook is not supported */
-	if (verdict == NF_ACCEPT && hooknum == NF_INET_FORWARD &&
-	    (rt = (struct rt6_info *) skb_dst(skb)) &&
-	    rt->rt6i_dev && rt->rt6i_dev->flags & IFF_LOOPBACK) {
-		IP_VS_DBG(1, "%s(): "
-			  "local delivery to %pI6 but in FORWARD\n",
-			  __func__, &rt->rt6i_dst);
-		verdict = NF_DROP;
-	}
+	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offset, hooknum);
 
 	__ip_vs_conn_put(cp);
 
diff -urp net-next-2.6-7ef73bc/linux/net/netfilter/ipvs/ip_vs_xmit.c linux/net/netfilter/ipvs/ip_vs_xmit.c
--- net-next-2.6-7ef73bc/linux/net/netfilter/ipvs/ip_vs_xmit.c	2011-05-10 23:52:06.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_xmit.c	2011-05-11 01:08:21.837272458 +0300
@@ -87,7 +87,7 @@ __ip_vs_dst_check(struct ip_vs_dest *des
 /* Get route to destination or remote server */
 static struct rtable *
 __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
-		   __be32 daddr, u32 rtos, int rt_mode)
+		   __be32 daddr, u32 rtos, int rt_mode, __be32 *ret_saddr)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct rtable *rt;			/* Route to the other host */
@@ -98,7 +98,12 @@ __ip_vs_get_out_rt(struct sk_buff *skb, 
 		spin_lock(&dest->dst_lock);
 		if (!(rt = (struct rtable *)
 		      __ip_vs_dst_check(dest, rtos))) {
-			rt = ip_route_output(net, dest->addr.ip, 0, rtos, 0);
+			struct flowi4 fl4;
+
+			memset(&fl4, 0, sizeof(fl4));
+			fl4.daddr = dest->addr.ip;
+			fl4.flowi4_tos = rtos;
+			rt = ip_route_output_key(net, &fl4);
 			if (IS_ERR(rt)) {
 				spin_unlock(&dest->dst_lock);
 				IP_VS_DBG_RL("ip_route_output error, dest: %pI4\n",
@@ -106,19 +111,30 @@ __ip_vs_get_out_rt(struct sk_buff *skb, 
 				return NULL;
 			}
 			__ip_vs_dst_set(dest, rtos, dst_clone(&rt->dst), 0);
-			IP_VS_DBG(10, "new dst %pI4, refcnt=%d, rtos=%X\n",
-				  &dest->addr.ip,
+			dest->dst_saddr.ip = fl4.saddr;
+			IP_VS_DBG(10, "new dst %pI4, src %pI4, refcnt=%d, "
+				  "rtos=%X\n",
+				  &dest->addr.ip, &dest->dst_saddr.ip,
 				  atomic_read(&rt->dst.__refcnt), rtos);
 		}
 		daddr = dest->addr.ip;
+		if (ret_saddr)
+			*ret_saddr = dest->dst_saddr.ip;
 		spin_unlock(&dest->dst_lock);
 	} else {
-		rt = ip_route_output(net, daddr, 0, rtos, 0);
+		struct flowi4 fl4;
+
+		memset(&fl4, 0, sizeof(fl4));
+		fl4.daddr = daddr;
+		fl4.flowi4_tos = rtos;
+		rt = ip_route_output_key(net, &fl4);
 		if (IS_ERR(rt)) {
 			IP_VS_DBG_RL("ip_route_output error, dest: %pI4\n",
 				     &daddr);
 			return NULL;
 		}
+		if (ret_saddr)
+			*ret_saddr = fl4.saddr;
 	}
 
 	local = rt->rt_flags & RTCF_LOCAL;
@@ -249,7 +265,7 @@ __ip_vs_get_out_rt_v6(struct sk_buff *sk
 			u32 cookie;
 
 			dst = __ip_vs_route_output_v6(net, &dest->addr.in6,
-						      &dest->dst_saddr,
+						      &dest->dst_saddr.in6,
 						      do_xfrm);
 			if (!dst) {
 				spin_unlock(&dest->dst_lock);
@@ -259,11 +275,11 @@ __ip_vs_get_out_rt_v6(struct sk_buff *sk
 			cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
 			__ip_vs_dst_set(dest, 0, dst_clone(&rt->dst), cookie);
 			IP_VS_DBG(10, "new dst %pI6, src %pI6, refcnt=%d\n",
-				  &dest->addr.in6, &dest->dst_saddr,
+				  &dest->addr.in6, &dest->dst_saddr.in6,
 				  atomic_read(&rt->dst.__refcnt));
 		}
 		if (ret_saddr)
-			ipv6_addr_copy(ret_saddr, &dest->dst_saddr);
+			ipv6_addr_copy(ret_saddr, &dest->dst_saddr.in6);
 		spin_unlock(&dest->dst_lock);
 	} else {
 		dst = __ip_vs_route_output_v6(net, daddr, ret_saddr, do_xfrm);
@@ -386,7 +402,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, s
 	EnterFunction(10);
 
 	if (!(rt = __ip_vs_get_out_rt(skb, NULL, iph->daddr, RT_TOS(iph->tos),
-				      IP_VS_RT_MODE_NON_LOCAL)))
+				      IP_VS_RT_MODE_NON_LOCAL, NULL)))
 		goto tx_error_icmp;
 
 	/* MTU checking */
@@ -518,7 +534,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
 				      RT_TOS(iph->tos),
 				      IP_VS_RT_MODE_LOCAL |
 					IP_VS_RT_MODE_NON_LOCAL |
-					IP_VS_RT_MODE_RDR)))
+					IP_VS_RT_MODE_RDR, NULL)))
 		goto tx_error_icmp;
 	local = rt->rt_flags & RTCF_LOCAL;
 	/*
@@ -540,7 +556,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
 #endif
 
 	/* From world but DNAT to loopback address? */
-	if (local && ipv4_is_loopback(rt->rt_dst) &&
+	if (local && ipv4_is_loopback(cp->daddr.ip) &&
 	    rt_is_input_route(skb_rtable(skb))) {
 		IP_VS_DBG_RL_PKT(1, AF_INET, pp, skb, 0, "ip_vs_nat_xmit(): "
 				 "stopping DNAT to loopback address");
@@ -751,6 +767,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, s
 		  struct ip_vs_protocol *pp)
 {
 	struct rtable *rt;			/* Route to the other host */
+	__be32 saddr;				/* Source for tunnel */
 	struct net_device *tdev;		/* Device to other host */
 	struct iphdr  *old_iph = ip_hdr(skb);
 	u8     tos = old_iph->tos;
@@ -764,7 +781,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, s
 
 	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
 				      RT_TOS(tos), IP_VS_RT_MODE_LOCAL |
-						   IP_VS_RT_MODE_NON_LOCAL)))
+						   IP_VS_RT_MODE_NON_LOCAL,
+						   &saddr)))
 		goto tx_error_icmp;
 	if (rt->rt_flags & RTCF_LOCAL) {
 		ip_rt_put(rt);
@@ -832,8 +850,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, s
 	iph->frag_off		=	df;
 	iph->protocol		=	IPPROTO_IPIP;
 	iph->tos		=	tos;
-	iph->daddr		=	rt->rt_dst;
-	iph->saddr		=	rt->rt_src;
+	iph->daddr		=	cp->daddr.ip;
+	iph->saddr		=	saddr;
 	iph->ttl		=	old_iph->ttl;
 	ip_select_ident(iph, &rt->dst, NULL);
 
@@ -996,7 +1014,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struc
 	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
 				      RT_TOS(iph->tos),
 				      IP_VS_RT_MODE_LOCAL |
-					IP_VS_RT_MODE_NON_LOCAL)))
+					IP_VS_RT_MODE_NON_LOCAL, NULL)))
 		goto tx_error_icmp;
 	if (rt->rt_flags & RTCF_LOCAL) {
 		ip_rt_put(rt);
@@ -1114,12 +1132,13 @@ tx_error:
  */
 int
 ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		struct ip_vs_protocol *pp, int offset)
+		struct ip_vs_protocol *pp, int offset, unsigned int hooknum)
 {
 	struct rtable	*rt;	/* Route to the other host */
 	int mtu;
 	int rc;
 	int local;
+	int rt_mode;
 
 	EnterFunction(10);
 
@@ -1140,11 +1159,13 @@ ip_vs_icmp_xmit(struct sk_buff *skb, str
 	 * mangle and send the packet here (only for VS/NAT)
 	 */
 
+	/* LOCALNODE from FORWARD hook is not supported */
+	rt_mode = (hooknum != NF_INET_FORWARD) ?
+		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
+		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
 	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
 				      RT_TOS(ip_hdr(skb)->tos),
-				      IP_VS_RT_MODE_LOCAL |
-					IP_VS_RT_MODE_NON_LOCAL |
-					IP_VS_RT_MODE_RDR)))
+				      rt_mode, NULL)))
 		goto tx_error_icmp;
 	local = rt->rt_flags & RTCF_LOCAL;
 
@@ -1167,7 +1188,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, str
 #endif
 
 	/* From world but DNAT to loopback address? */
-	if (local && ipv4_is_loopback(rt->rt_dst) &&
+	if (local && ipv4_is_loopback(cp->daddr.ip) &&
 	    rt_is_input_route(skb_rtable(skb))) {
 		IP_VS_DBG(1, "%s(): "
 			  "stopping DNAT to loopback %pI4\n",
@@ -1232,12 +1253,13 @@ ip_vs_icmp_xmit(struct sk_buff *skb, str
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		struct ip_vs_protocol *pp, int offset)
+		struct ip_vs_protocol *pp, int offset, unsigned int hooknum)
 {
 	struct rt6_info	*rt;	/* Route to the other host */
 	int mtu;
 	int rc;
 	int local;
+	int rt_mode;
 
 	EnterFunction(10);
 
@@ -1258,10 +1280,12 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, 
 	 * mangle and send the packet here (only for VS/NAT)
 	 */
 
+	/* LOCALNODE from FORWARD hook is not supported */
+	rt_mode = (hooknum != NF_INET_FORWARD) ?
+		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
+		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
 	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
-					 0, (IP_VS_RT_MODE_LOCAL |
-					     IP_VS_RT_MODE_NON_LOCAL |
-					     IP_VS_RT_MODE_RDR))))
+					 0, rt_mode)))
 		goto tx_error_icmp;
 
 	local = __ip_vs_is_local_route6(rt);
