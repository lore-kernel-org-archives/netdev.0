From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/6] [NET]: Turn nfmark into generic mark
Date: Thu, 09 Nov 2006 12:27:36 +0100
Message-ID: <20061109113245.439512828@lsx.localdomain>
References: <20061109112735.577771022@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:3792 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932814AbWKILdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 06:33:37 -0500
To: davem@davemloft.net
Content-Disposition: inline; filename=rename_nfmark
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nfmark is being used in various subsystems and has become
the defacto mark field for all kinds of packets. Therefore
it makes sense to rename it to `mark' and remove the
dependency on CONFIG_NETFILTER.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/include/linux/skbuff.h
===================================================================
--- net-2.6.20.orig/include/linux/skbuff.h	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/include/linux/skbuff.h	2006-11-08 16:12:30.000000000 +0100
@@ -216,7 +216,7 @@
  *	@tail: Tail pointer
  *	@end: End pointer
  *	@destructor: Destruct function
- *	@nfmark: Can be used for communication between hooks
+ *	@mark: Generic packet mark
  *	@nfct: Associated connection, if any
  *	@ipvs_property: skbuff is owned by ipvs
  *	@nfctinfo: Relationship of this skb to the connection
@@ -295,7 +295,6 @@
 #ifdef CONFIG_BRIDGE_NETFILTER
 	struct nf_bridge_info	*nf_bridge;
 #endif
-	__u32			nfmark;
 #endif /* CONFIG_NETFILTER */
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
@@ -310,6 +309,7 @@
 	__u32			secmark;
 #endif
 
+	__u32			mark;
 
 	/* These elements must be at the end, see alloc_skb() for details.  */
 	unsigned int		truesize;
Index: net-2.6.20/net/core/skbuff.c
===================================================================
--- net-2.6.20.orig/net/core/skbuff.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/core/skbuff.c	2006-11-08 16:12:30.000000000 +0100
@@ -473,8 +473,8 @@
 #endif
 	C(protocol);
 	n->destructor = NULL;
+	C(mark);
 #ifdef CONFIG_NETFILTER
-	C(nfmark);
 	C(nfct);
 	nf_conntrack_get(skb->nfct);
 	C(nfctinfo);
@@ -534,8 +534,8 @@
 	new->pkt_type	= old->pkt_type;
 	new->tstamp	= old->tstamp;
 	new->destructor = NULL;
+	new->mark	= old->mark;
 #ifdef CONFIG_NETFILTER
-	new->nfmark	= old->nfmark;
 	new->nfct	= old->nfct;
 	nf_conntrack_get(old->nfct);
 	new->nfctinfo	= old->nfctinfo;
Index: net-2.6.20/net/ipv4/netfilter/iptable_mangle.c
===================================================================
--- net-2.6.20.orig/net/ipv4/netfilter/iptable_mangle.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/ipv4/netfilter/iptable_mangle.c	2006-11-08 16:12:30.000000000 +0100
@@ -132,7 +132,7 @@
 	unsigned int ret;
 	u_int8_t tos;
 	__be32 saddr, daddr;
-	unsigned long nfmark;
+	u_int32_t mark;
 
 	/* root is playing with raw sockets. */
 	if ((*pskb)->len < sizeof(struct iphdr)
@@ -143,7 +143,7 @@
 	}
 
 	/* Save things which could affect route */
-	nfmark = (*pskb)->nfmark;
+	mark = (*pskb)->mark;
 	saddr = (*pskb)->nh.iph->saddr;
 	daddr = (*pskb)->nh.iph->daddr;
 	tos = (*pskb)->nh.iph->tos;
@@ -154,7 +154,7 @@
 	    && ((*pskb)->nh.iph->saddr != saddr
 		|| (*pskb)->nh.iph->daddr != daddr
 #ifdef CONFIG_IP_ROUTE_FWMARK
-		|| (*pskb)->nfmark != nfmark
+		|| (*pskb)->mark != mark
 #endif
 		|| (*pskb)->nh.iph->tos != tos))
 		if (ip_route_me_harder(pskb, RTN_UNSPEC))
Index: net-2.6.20/net/bridge/netfilter/ebt_mark.c
===================================================================
--- net-2.6.20.orig/net/bridge/netfilter/ebt_mark.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/bridge/netfilter/ebt_mark.c	2006-11-08 16:12:30.000000000 +0100
@@ -25,13 +25,13 @@
 	int action = info->target & -16;
 
 	if (action == MARK_SET_VALUE)
-		(*pskb)->nfmark = info->mark;
+		(*pskb)->mark = info->mark;
 	else if (action == MARK_OR_VALUE)
-		(*pskb)->nfmark |= info->mark;
+		(*pskb)->mark |= info->mark;
 	else if (action == MARK_AND_VALUE)
-		(*pskb)->nfmark &= info->mark;
+		(*pskb)->mark &= info->mark;
 	else
-		(*pskb)->nfmark ^= info->mark;
+		(*pskb)->mark ^= info->mark;
 
 	return info->target | -16;
 }
Index: net-2.6.20/net/bridge/netfilter/ebt_mark_m.c
===================================================================
--- net-2.6.20.orig/net/bridge/netfilter/ebt_mark_m.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/bridge/netfilter/ebt_mark_m.c	2006-11-08 16:12:30.000000000 +0100
@@ -19,8 +19,8 @@
 	struct ebt_mark_m_info *info = (struct ebt_mark_m_info *) data;
 
 	if (info->bitmask & EBT_MARK_OR)
-		return !(!!(skb->nfmark & info->mask) ^ info->invert);
-	return !(((skb->nfmark & info->mask) == info->mark) ^ info->invert);
+		return !(!!(skb->mark & info->mask) ^ info->invert);
+	return !(((skb->mark & info->mask) == info->mark) ^ info->invert);
 }
 
 static int ebt_mark_check(const char *tablename, unsigned int hookmask,
Index: net-2.6.20/net/bridge/netfilter/ebt_ulog.c
===================================================================
--- net-2.6.20.orig/net/bridge/netfilter/ebt_ulog.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/bridge/netfilter/ebt_ulog.c	2006-11-08 16:12:30.000000000 +0100
@@ -168,7 +168,7 @@
 	if (ub->qlen == 1)
 		skb_set_timestamp(ub->skb, &pm->stamp);
 	pm->data_len = copy_len;
-	pm->mark = skb->nfmark;
+	pm->mark = skb->mark;
 	pm->hook = hooknr;
 	if (uloginfo->prefix != NULL)
 		strcpy(pm->prefix, uloginfo->prefix);
Index: net-2.6.20/net/decnet/dn_route.c
===================================================================
--- net-2.6.20.orig/net/decnet/dn_route.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/decnet/dn_route.c	2006-11-08 16:12:30.000000000 +0100
@@ -1236,7 +1236,7 @@
 				       .saddr = cb->src,
 				       .scope = RT_SCOPE_UNIVERSE,
 #ifdef CONFIG_DECNET_ROUTE_FWMARK
-				       .fwmark = skb->nfmark
+				       .fwmark = skb->mark
 #endif
 				    } },
 			    .iif = skb->dev->ifindex };
@@ -1458,7 +1458,7 @@
 	 	    (rt->fl.fld_dst == cb->dst) &&
 		    (rt->fl.oif == 0) &&
 #ifdef CONFIG_DECNET_ROUTE_FWMARK
-		    (rt->fl.fld_fwmark == skb->nfmark) &&
+		    (rt->fl.fld_fwmark == skb->mark) &&
 #endif
 		    (rt->fl.iif == cb->iif)) {
 			rt->u.dst.lastuse = jiffies;
Index: net-2.6.20/net/ipv4/ip_output.c
===================================================================
--- net-2.6.20.orig/net/ipv4/ip_output.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/ipv4/ip_output.c	2006-11-08 16:12:30.000000000 +0100
@@ -386,6 +386,7 @@
 	dst_release(to->dst);
 	to->dst = dst_clone(from->dst);
 	to->dev = from->dev;
+	to->mark = from->mark;
 
 	/* Copy the flags to each fragment. */
 	IPCB(to)->flags = IPCB(from)->flags;
@@ -394,7 +395,6 @@
 	to->tc_index = from->tc_index;
 #endif
 #ifdef CONFIG_NETFILTER
-	to->nfmark = from->nfmark;
 	/* Connection association is same as pre-frag packet */
 	nf_conntrack_put(to->nfct);
 	to->nfct = from->nfct;
Index: net-2.6.20/net/ipv4/ipvs/ip_vs_proto_tcp.c
===================================================================
--- net-2.6.20.orig/net/ipv4/ipvs/ip_vs_proto_tcp.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/ipv4/ipvs/ip_vs_proto_tcp.c	2006-11-08 16:12:30.000000000 +0100
@@ -84,7 +84,7 @@
 	}
 
 	if (th->syn &&
-	    (svc = ip_vs_service_get(skb->nfmark, skb->nh.iph->protocol,
+	    (svc = ip_vs_service_get(skb->mark, skb->nh.iph->protocol,
 				     skb->nh.iph->daddr, th->dest))) {
 		if (ip_vs_todrop()) {
 			/*
Index: net-2.6.20/net/ipv4/ipvs/ip_vs_proto_udp.c
===================================================================
--- net-2.6.20.orig/net/ipv4/ipvs/ip_vs_proto_udp.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/ipv4/ipvs/ip_vs_proto_udp.c	2006-11-08 16:12:30.000000000 +0100
@@ -89,7 +89,7 @@
 		return 0;
 	}
 
-	if ((svc = ip_vs_service_get(skb->nfmark, skb->nh.iph->protocol,
+	if ((svc = ip_vs_service_get(skb->mark, skb->nh.iph->protocol,
 				     skb->nh.iph->daddr, uh->dest))) {
 		if (ip_vs_todrop()) {
 			/*
Index: net-2.6.20/net/ipv4/netfilter.c
===================================================================
--- net-2.6.20.orig/net/ipv4/netfilter.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/ipv4/netfilter.c	2006-11-08 16:12:30.000000000 +0100
@@ -28,7 +28,7 @@
 		fl.nl_u.ip4_u.tos = RT_TOS(iph->tos);
 		fl.oif = (*pskb)->sk ? (*pskb)->sk->sk_bound_dev_if : 0;
 #ifdef CONFIG_IP_ROUTE_FWMARK
-		fl.nl_u.ip4_u.fwmark = (*pskb)->nfmark;
+		fl.nl_u.ip4_u.fwmark = (*pskb)->mark;
 #endif
 		if (ip_route_output_key(&rt, &fl) != 0)
 			return -1;
Index: net-2.6.20/net/ipv4/netfilter/ip_queue.c
===================================================================
--- net-2.6.20.orig/net/ipv4/netfilter/ip_queue.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/ipv4/netfilter/ip_queue.c	2006-11-08 16:12:30.000000000 +0100
@@ -243,7 +243,7 @@
 	pmsg->data_len        = data_len;
 	pmsg->timestamp_sec   = entry->skb->tstamp.off_sec;
 	pmsg->timestamp_usec  = entry->skb->tstamp.off_usec;
-	pmsg->mark            = entry->skb->nfmark;
+	pmsg->mark            = entry->skb->mark;
 	pmsg->hook            = entry->info->hook;
 	pmsg->hw_protocol     = entry->skb->protocol;
 	
Index: net-2.6.20/net/ipv4/netfilter/ipt_REJECT.c
===================================================================
--- net-2.6.20.orig/net/ipv4/netfilter/ipt_REJECT.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/ipv4/netfilter/ipt_REJECT.c	2006-11-08 16:12:30.000000000 +0100
@@ -76,7 +76,7 @@
 
 	/* This packet will not be the same as the other: clear nf fields */
 	nf_reset(nskb);
-	nskb->nfmark = 0;
+	nskb->mark = 0;
 	skb_init_secmark(nskb);
 
 	tcph = (struct tcphdr *)((u_int32_t*)nskb->nh.iph + nskb->nh.iph->ihl);
Index: net-2.6.20/net/ipv4/netfilter/ipt_ULOG.c
===================================================================
--- net-2.6.20.orig/net/ipv4/netfilter/ipt_ULOG.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/ipv4/netfilter/ipt_ULOG.c	2006-11-08 16:12:30.000000000 +0100
@@ -239,7 +239,7 @@
 	pm->data_len = copy_len;
 	pm->timestamp_sec = skb->tstamp.off_sec;
 	pm->timestamp_usec = skb->tstamp.off_usec;
-	pm->mark = skb->nfmark;
+	pm->mark = skb->mark;
 	pm->hook = hooknum;
 	if (prefix != NULL)
 		strncpy(pm->prefix, prefix, sizeof(pm->prefix));
Index: net-2.6.20/net/ipv4/route.c
===================================================================
--- net-2.6.20.orig/net/ipv4/route.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/ipv4/route.c	2006-11-08 16:12:30.000000000 +0100
@@ -1644,7 +1644,7 @@
 	rth->rt_dst	= daddr;
 	rth->fl.fl4_tos	= tos;
 #ifdef CONFIG_IP_ROUTE_FWMARK
-	rth->fl.fl4_fwmark= skb->nfmark;
+	rth->fl.fl4_fwmark= skb->mark;
 #endif
 	rth->fl.fl4_src	= saddr;
 	rth->rt_src	= saddr;
@@ -1790,7 +1790,7 @@
 	rth->rt_dst	= daddr;
 	rth->fl.fl4_tos	= tos;
 #ifdef CONFIG_IP_ROUTE_FWMARK
-	rth->fl.fl4_fwmark= skb->nfmark;
+	rth->fl.fl4_fwmark= skb->mark;
 #endif
 	rth->fl.fl4_src	= saddr;
 	rth->rt_src	= saddr;
@@ -1921,7 +1921,7 @@
 					.tos = tos,
 					.scope = RT_SCOPE_UNIVERSE,
 #ifdef CONFIG_IP_ROUTE_FWMARK
-					.fwmark = skb->nfmark
+					.fwmark = skb->mark
 #endif
 				      } },
 			    .iif = dev->ifindex };
@@ -2035,7 +2035,7 @@
 	rth->rt_dst	= daddr;
 	rth->fl.fl4_tos	= tos;
 #ifdef CONFIG_IP_ROUTE_FWMARK
-	rth->fl.fl4_fwmark= skb->nfmark;
+	rth->fl.fl4_fwmark= skb->mark;
 #endif
 	rth->fl.fl4_src	= saddr;
 	rth->rt_src	= saddr;
@@ -2114,7 +2114,7 @@
 		    rth->fl.iif == iif &&
 		    rth->fl.oif == 0 &&
 #ifdef CONFIG_IP_ROUTE_FWMARK
-		    rth->fl.fl4_fwmark == skb->nfmark &&
+		    rth->fl.fl4_fwmark == skb->mark &&
 #endif
 		    rth->fl.fl4_tos == tos) {
 			rth->u.dst.lastuse = jiffies;
Index: net-2.6.20/net/ipv6/ip6_output.c
===================================================================
--- net-2.6.20.orig/net/ipv6/ip6_output.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/ipv6/ip6_output.c	2006-11-08 16:12:30.000000000 +0100
@@ -499,12 +499,12 @@
 	dst_release(to->dst);
 	to->dst = dst_clone(from->dst);
 	to->dev = from->dev;
+	to->mark = from->mark;
 
 #ifdef CONFIG_NET_SCHED
 	to->tc_index = from->tc_index;
 #endif
 #ifdef CONFIG_NETFILTER
-	to->nfmark = from->nfmark;
 	/* Connection association is same as pre-frag packet */
 	nf_conntrack_put(to->nfct);
 	to->nfct = from->nfct;
Index: net-2.6.20/net/ipv6/netfilter/ip6_queue.c
===================================================================
--- net-2.6.20.orig/net/ipv6/netfilter/ip6_queue.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/ipv6/netfilter/ip6_queue.c	2006-11-08 16:12:30.000000000 +0100
@@ -241,7 +241,7 @@
 	pmsg->data_len        = data_len;
 	pmsg->timestamp_sec   = entry->skb->tstamp.off_sec;
 	pmsg->timestamp_usec  = entry->skb->tstamp.off_usec;
-	pmsg->mark            = entry->skb->nfmark;
+	pmsg->mark            = entry->skb->mark;
 	pmsg->hook            = entry->info->hook;
 	pmsg->hw_protocol     = entry->skb->protocol;
 	
Index: net-2.6.20/net/ipv6/netfilter/ip6table_mangle.c
===================================================================
--- net-2.6.20.orig/net/ipv6/netfilter/ip6table_mangle.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/ipv6/netfilter/ip6table_mangle.c	2006-11-08 16:12:30.000000000 +0100
@@ -149,11 +149,10 @@
 		   int (*okfn)(struct sk_buff *))
 {
 
-	unsigned long nfmark;
 	unsigned int ret;
 	struct in6_addr saddr, daddr;
 	u_int8_t hop_limit;
-	u_int32_t flowlabel;
+	u_int32_t flowlabel, mark;
 
 #if 0
 	/* root is playing with raw sockets. */
@@ -165,10 +164,10 @@
 	}
 #endif
 
-	/* save source/dest address, nfmark, hoplimit, flowlabel, priority,  */
+	/* save source/dest address, mark, hoplimit, flowlabel, priority,  */
 	memcpy(&saddr, &(*pskb)->nh.ipv6h->saddr, sizeof(saddr));
 	memcpy(&daddr, &(*pskb)->nh.ipv6h->daddr, sizeof(daddr));
-	nfmark = (*pskb)->nfmark;
+	mark = (*pskb)->mark;
 	hop_limit = (*pskb)->nh.ipv6h->hop_limit;
 
 	/* flowlabel and prio (includes version, which shouldn't change either */
@@ -179,7 +178,7 @@
 	if (ret != NF_DROP && ret != NF_STOLEN 
 		&& (memcmp(&(*pskb)->nh.ipv6h->saddr, &saddr, sizeof(saddr))
 		    || memcmp(&(*pskb)->nh.ipv6h->daddr, &daddr, sizeof(daddr))
-		    || (*pskb)->nfmark != nfmark
+		    || (*pskb)->mark != mark
 		    || (*pskb)->nh.ipv6h->hop_limit != hop_limit))
 		return ip6_route_me_harder(*pskb) == 0 ? ret : NF_DROP;
 
Index: net-2.6.20/net/ipv6/route.c
===================================================================
--- net-2.6.20.orig/net/ipv6/route.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/ipv6/route.c	2006-11-08 16:12:30.000000000 +0100
@@ -711,7 +711,7 @@
 				.daddr = iph->daddr,
 				.saddr = iph->saddr,
 #ifdef CONFIG_IPV6_ROUTE_FWMARK
-				.fwmark = skb->nfmark,
+				.fwmark = skb->mark,
 #endif
 				.flowlabel = (* (__be32 *) iph)&IPV6_FLOWINFO_MASK,
 			},
Index: net-2.6.20/net/netfilter/nfnetlink_log.c
===================================================================
--- net-2.6.20.orig/net/netfilter/nfnetlink_log.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/netfilter/nfnetlink_log.c	2006-11-08 16:12:30.000000000 +0100
@@ -501,8 +501,8 @@
 #endif
 	}
 
-	if (skb->nfmark) {
-		tmp_uint = htonl(skb->nfmark);
+	if (skb->mark) {
+		tmp_uint = htonl(skb->mark);
 		NFA_PUT(inst->skb, NFULA_MARK, sizeof(tmp_uint), &tmp_uint);
 	}
 
Index: net-2.6.20/net/netfilter/nfnetlink_queue.c
===================================================================
--- net-2.6.20.orig/net/netfilter/nfnetlink_queue.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/netfilter/nfnetlink_queue.c	2006-11-08 16:12:30.000000000 +0100
@@ -480,8 +480,8 @@
 #endif
 	}
 
-	if (entskb->nfmark) {
-		tmp_uint = htonl(entskb->nfmark);
+	if (entskb->mark) {
+		tmp_uint = htonl(entskb->mark);
 		NFA_PUT(skb, NFQA_MARK, sizeof(u_int32_t), &tmp_uint);
 	}
 
@@ -833,8 +833,8 @@
 	}
 
 	if (nfqa[NFQA_MARK-1])
-		entry->skb->nfmark = ntohl(*(__be32 *)
-		                           NFA_DATA(nfqa[NFQA_MARK-1]));
+		entry->skb->mark = ntohl(*(__be32 *)
+		                         NFA_DATA(nfqa[NFQA_MARK-1]));
 		
 	issue_verdict(entry, verdict);
 	instance_put(queue);
Index: net-2.6.20/net/netfilter/xt_CONNMARK.c
===================================================================
--- net-2.6.20.orig/net/netfilter/xt_CONNMARK.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/netfilter/xt_CONNMARK.c	2006-11-08 16:12:30.000000000 +0100
@@ -42,7 +42,7 @@
 {
 	const struct xt_connmark_target_info *markinfo = targinfo;
 	u_int32_t diff;
-	u_int32_t nfmark;
+	u_int32_t mark;
 	u_int32_t newmark;
 	u_int32_t ctinfo;
 	u_int32_t *ctmark = nf_ct_get_mark(*pskb, &ctinfo);
@@ -62,7 +62,7 @@
 			break;
 		case XT_CONNMARK_SAVE:
 			newmark = (*ctmark & ~markinfo->mask) |
-				  ((*pskb)->nfmark & markinfo->mask);
+				  ((*pskb)->mark & markinfo->mask);
 			if (*ctmark != newmark) {
 				*ctmark = newmark;
 #if defined(CONFIG_IP_NF_CONNTRACK) || defined(CONFIG_IP_NF_CONNTRACK_MODULE)
@@ -73,10 +73,10 @@
 			}
 			break;
 		case XT_CONNMARK_RESTORE:
-			nfmark = (*pskb)->nfmark;
-			diff = (*ctmark ^ nfmark) & markinfo->mask;
+			mark = (*pskb)->mark;
+			diff = (*ctmark ^ mark) & markinfo->mask;
 			if (diff != 0)
-				(*pskb)->nfmark = nfmark ^ diff;
+				(*pskb)->mark = mark ^ diff;
 			break;
 		}
 	}
Index: net-2.6.20/net/netfilter/xt_MARK.c
===================================================================
--- net-2.6.20.orig/net/netfilter/xt_MARK.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/netfilter/xt_MARK.c	2006-11-08 16:12:30.000000000 +0100
@@ -31,8 +31,8 @@
 {
 	const struct xt_mark_target_info *markinfo = targinfo;
 
-	if((*pskb)->nfmark != markinfo->mark)
-		(*pskb)->nfmark = markinfo->mark;
+	if((*pskb)->mark != markinfo->mark)
+		(*pskb)->mark = markinfo->mark;
 
 	return XT_CONTINUE;
 }
@@ -54,16 +54,16 @@
 		break;
 		
 	case XT_MARK_AND:
-		mark = (*pskb)->nfmark & markinfo->mark;
+		mark = (*pskb)->mark & markinfo->mark;
 		break;
 		
 	case XT_MARK_OR:
-		mark = (*pskb)->nfmark | markinfo->mark;
+		mark = (*pskb)->mark | markinfo->mark;
 		break;
 	}
 
-	if((*pskb)->nfmark != mark)
-		(*pskb)->nfmark = mark;
+	if((*pskb)->mark != mark)
+		(*pskb)->mark = mark;
 
 	return XT_CONTINUE;
 }
Index: net-2.6.20/net/netfilter/xt_mark.c
===================================================================
--- net-2.6.20.orig/net/netfilter/xt_mark.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/netfilter/xt_mark.c	2006-11-08 16:12:30.000000000 +0100
@@ -31,7 +31,7 @@
 {
 	const struct xt_mark_info *info = matchinfo;
 
-	return ((skb->nfmark & info->mask) == info->mark) ^ info->invert;
+	return ((skb->mark & info->mask) == info->mark) ^ info->invert;
 }
 
 static int
Index: net-2.6.20/net/sched/Kconfig
===================================================================
--- net-2.6.20.orig/net/sched/Kconfig	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/sched/Kconfig	2006-11-08 16:12:30.000000000 +0100
@@ -320,7 +320,7 @@
 
 config CLS_U32_MARK
 	bool "Netfilter marks support"
-	depends on NET_CLS_U32 && NETFILTER
+	depends on NET_CLS_U32
 	---help---
 	  Say Y here to be able to use netfilter marks as u32 key.
 
Index: net-2.6.20/net/sched/cls_fw.c
===================================================================
--- net-2.6.20.orig/net/sched/cls_fw.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/sched/cls_fw.c	2006-11-08 16:12:30.000000000 +0100
@@ -101,11 +101,7 @@
 	struct fw_head *head = (struct fw_head*)tp->root;
 	struct fw_filter *f;
 	int r;
-#ifdef CONFIG_NETFILTER
-	u32 id = skb->nfmark & head->mask;
-#else
-	u32 id = 0;
-#endif
+	u32 id = skb->mark & head->mask;
 
 	if (head != NULL) {
 		for (f=head->ht[fw_hash(id)]; f; f=f->next) {
Index: net-2.6.20/net/sched/cls_u32.c
===================================================================
--- net-2.6.20.orig/net/sched/cls_u32.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/sched/cls_u32.c	2006-11-08 16:12:30.000000000 +0100
@@ -143,7 +143,7 @@
 #endif
 
 #ifdef CONFIG_CLS_U32_MARK
-		if ((skb->nfmark & n->mark.mask) != n->mark.val) {
+		if ((skb->mark & n->mark.mask) != n->mark.val) {
 			n = n->next;
 			goto next_knode;
 		} else {
Index: net-2.6.20/net/sched/em_meta.c
===================================================================
--- net-2.6.20.orig/net/sched/em_meta.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/sched/em_meta.c	2006-11-08 16:12:30.000000000 +0100
@@ -208,13 +208,9 @@
  * Netfilter
  **************************************************************************/
 
-META_COLLECTOR(int_nfmark)
+META_COLLECTOR(int_mark)
 {
-#ifdef CONFIG_NETFILTER
-	dst->value = skb->nfmark;
-#else
-	dst->value = 0;
-#endif
+	dst->value = skb->mark;
 }
 
 /**************************************************************************
@@ -490,7 +486,7 @@
 		[META_ID(PKTLEN)]		= META_FUNC(int_pktlen),
 		[META_ID(DATALEN)]		= META_FUNC(int_datalen),
 		[META_ID(MACLEN)]		= META_FUNC(int_maclen),
-		[META_ID(NFMARK)]		= META_FUNC(int_nfmark),
+		[META_ID(NFMARK)]		= META_FUNC(int_mark),
 		[META_ID(TCINDEX)]		= META_FUNC(int_tcindex),
 		[META_ID(RTCLASSID)]		= META_FUNC(int_rtclassid),
 		[META_ID(RTIIF)]		= META_FUNC(int_rtiif),

--

