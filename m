From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/3] [IPv4]: Convert FIB dumping to use new netlink api
Date: Tue, 15 Aug 2006 00:00:02 +0200
Message-ID: <20060815145945.857738447@postel.suug.ch>
References: <20060815145723.147333034@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:12517 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1030329AbWHOPAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 11:00:37 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ipv4_fib_dump
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/ipv4/fib_semantics.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/fib_semantics.c
+++ net-2.6.19.git/net/ipv4/fib_semantics.c
@@ -286,7 +286,7 @@ void rtmsg_fib(int event, u32 key, struc
 		goto errout;
 
 	err = fib_dump_info(skb, info->pid, seq, event, tb_id,
-			    fa->fa_type, fa->fa_scope, &key, dst_len,
+			    fa->fa_type, fa->fa_scope, key, dst_len,
 			    fa->fa_tos, fa->fa_info, 0);
 	if (err < 0) {
 		kfree_skb(skb);
@@ -928,79 +928,87 @@ u32 __fib_res_prefsrc(struct fib_result 
 	return inet_select_addr(FIB_RES_DEV(*res), FIB_RES_GW(*res), res->scope);
 }
 
-int
-fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
-	      u32 tb_id, u8 type, u8 scope, void *dst, int dst_len, u8 tos,
-	      struct fib_info *fi, unsigned int flags)
+int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
+		  u32 tb_id, u8 type, u8 scope, u32 dst, int dst_len, u8 tos,
+		  struct fib_info *fi, unsigned int flags)
 {
+	struct nlmsghdr *nlh;
 	struct rtmsg *rtm;
-	struct nlmsghdr  *nlh;
-	unsigned char	 *b = skb->tail;
 
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*rtm), flags);
-	rtm = NLMSG_DATA(nlh);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*rtm), flags);
+	if (nlh == NULL)
+		return -ENOBUFS;
+
+	rtm = nlmsg_data(nlh);
 	rtm->rtm_family = AF_INET;
 	rtm->rtm_dst_len = dst_len;
 	rtm->rtm_src_len = 0;
 	rtm->rtm_tos = tos;
 	rtm->rtm_table = tb_id;
-	RTA_PUT_U32(skb, RTA_TABLE, tb_id);
+	NLA_PUT_U32(skb, RTA_TABLE, tb_id);
 	rtm->rtm_type = type;
 	rtm->rtm_flags = fi->fib_flags;
 	rtm->rtm_scope = scope;
-	if (rtm->rtm_dst_len)
-		RTA_PUT(skb, RTA_DST, 4, dst);
 	rtm->rtm_protocol = fi->fib_protocol;
+
+	if (rtm->rtm_dst_len)
+		NLA_PUT_U32(skb, RTA_DST, dst);
+
 	if (fi->fib_priority)
-		RTA_PUT(skb, RTA_PRIORITY, 4, &fi->fib_priority);
+		NLA_PUT_U32(skb, RTA_PRIORITY, fi->fib_priority);
+
 	if (rtnetlink_put_metrics(skb, fi->fib_metrics) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
+
 	if (fi->fib_prefsrc)
-		RTA_PUT(skb, RTA_PREFSRC, 4, &fi->fib_prefsrc);
+		NLA_PUT_U32(skb, RTA_PREFSRC, fi->fib_prefsrc);
+
 	if (fi->fib_nhs == 1) {
 		if (fi->fib_nh->nh_gw)
-			RTA_PUT(skb, RTA_GATEWAY, 4, &fi->fib_nh->nh_gw);
+			NLA_PUT_U32(skb, RTA_GATEWAY, fi->fib_nh->nh_gw);
+
 		if (fi->fib_nh->nh_oif)
-			RTA_PUT(skb, RTA_OIF, sizeof(int), &fi->fib_nh->nh_oif);
+			NLA_PUT_U32(skb, RTA_OIF, fi->fib_nh->nh_oif);
 #ifdef CONFIG_NET_CLS_ROUTE
 		if (fi->fib_nh[0].nh_tclassid)
-			RTA_PUT(skb, RTA_FLOW, 4, &fi->fib_nh[0].nh_tclassid);
+			NLA_PUT_U32(skb, RTA_FLOW, fi->fib_nh[0].nh_tclassid);
 #endif
 	}
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (fi->fib_nhs > 1) {
-		struct rtnexthop *nhp;
-		struct rtattr *mp_head;
-		if (skb_tailroom(skb) <= RTA_SPACE(0))
-			goto rtattr_failure;
-		mp_head = (struct rtattr*)skb_put(skb, RTA_SPACE(0));
+		struct rtnexthop *rtnh;
+		struct nlattr *mp;
+
+		mp = nla_nest_start(skb, RTA_MULTIPATH);
+		if (mp == NULL)
+			goto nla_put_failure;
 
 		for_nexthops(fi) {
-			if (skb_tailroom(skb) < RTA_ALIGN(RTA_ALIGN(sizeof(*nhp)) + 4))
-				goto rtattr_failure;
-			nhp = (struct rtnexthop*)skb_put(skb, RTA_ALIGN(sizeof(*nhp)));
-			nhp->rtnh_flags = nh->nh_flags & 0xFF;
-			nhp->rtnh_hops = nh->nh_weight-1;
-			nhp->rtnh_ifindex = nh->nh_oif;
+			rtnh = nla_reserve_nohdr(skb, sizeof(*rtnh));
+			if (rtnh == NULL)
+				goto nla_put_failure;
+
+			rtnh->rtnh_flags = nh->nh_flags & 0xFF;
+			rtnh->rtnh_hops = nh->nh_weight - 1;
+			rtnh->rtnh_ifindex = nh->nh_oif;
+
 			if (nh->nh_gw)
-				RTA_PUT(skb, RTA_GATEWAY, 4, &nh->nh_gw);
+				NLA_PUT_U32(skb, RTA_GATEWAY, nh->nh_gw);
 #ifdef CONFIG_NET_CLS_ROUTE
 			if (nh->nh_tclassid)
-				RTA_PUT(skb, RTA_FLOW, 4, &nh->nh_tclassid);
+				NLA_PUT_U32(skb, RTA_FLOW, nh->nh_tclassid);
 #endif
-			nhp->rtnh_len = skb->tail - (unsigned char*)nhp;
+			/* length of rtnetlink header + attributes */
+			rtnh->rtnh_len = nlmsg_get_pos(skb) - (void *) rtnh;
 		} endfor_nexthops(fi);
-		mp_head->rta_type = RTA_MULTIPATH;
-		mp_head->rta_len = skb->tail - (u8*)mp_head;
+
+		nla_nest_end(skb, mp);
 	}
 #endif
-	nlh->nlmsg_len = skb->tail - b;
-	return skb->len;
+	return nlmsg_end(skb, nlh);
 
-nlmsg_failure:
-rtattr_failure:
-	skb_trim(skb, b - skb->data);
-	return -1;
+nla_put_failure:
+	return nlmsg_cancel(skb, nlh);
 }
 
 /*
Index: net-2.6.19.git/net/ipv4/fib_hash.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/fib_hash.c
+++ net-2.6.19.git/net/ipv4/fib_hash.c
@@ -693,7 +693,7 @@ fn_hash_dump_bucket(struct sk_buff *skb,
 					  tb->tb_id,
 					  fa->fa_type,
 					  fa->fa_scope,
-					  &f->fn_key,
+					  f->fn_key,
 					  fz->fz_order,
 					  fa->fa_tos,
 					  fa->fa_info,
Index: net-2.6.19.git/net/ipv4/fib_trie.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/fib_trie.c
+++ net-2.6.19.git/net/ipv4/fib_trie.c
@@ -1854,7 +1854,7 @@ static int fn_trie_dump_fa(t_key key, in
 				  tb->tb_id,
 				  fa->fa_type,
 				  fa->fa_scope,
-				  &xkey,
+				  xkey,
 				  plen,
 				  fa->fa_tos,
 				  fa->fa_info, 0) < 0) {
Index: net-2.6.19.git/net/ipv4/fib_lookup.h
===================================================================
--- net-2.6.19.git.orig/net/ipv4/fib_lookup.h
+++ net-2.6.19.git/net/ipv4/fib_lookup.h
@@ -26,7 +26,7 @@ extern void fib_release_info(struct fib_
 extern struct fib_info *fib_create_info(struct fib_config *cfg);
 extern int fib_nh_match(struct fib_config *cfg, struct fib_info *fi);
 extern int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
-			 u32 tb_id, u8 type, u8 scope, void *dst,
+			 u32 tb_id, u8 type, u8 scope, u32 dst,
 			 int dst_len, u8 tos, struct fib_info *fi,
 			 unsigned int);
 extern void rtmsg_fib(int event, u32 key, struct fib_alias *fa,
Index: net-2.6.19.git/net/ipv4/route.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/route.c
+++ net-2.6.19.git/net/ipv4/route.c
@@ -2639,52 +2639,54 @@ static int rt_fill_info(struct sk_buff *
 {
 	struct rtable *rt = (struct rtable*)skb->dst;
 	struct rtmsg *r;
-	struct nlmsghdr  *nlh;
-	unsigned char	 *b = skb->tail;
+	struct nlmsghdr *nlh;
 	struct rta_cacheinfo ci;
-#ifdef CONFIG_IP_MROUTE
-	struct rtattr *eptr;
-#endif
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*r), flags);
-	r = NLMSG_DATA(nlh);
+
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*r), flags);
+	if (nlh == NULL)
+		return -ENOBUFS;
+
+	r = nlmsg_data(nlh);
 	r->rtm_family	 = AF_INET;
 	r->rtm_dst_len	= 32;
 	r->rtm_src_len	= 0;
 	r->rtm_tos	= rt->fl.fl4_tos;
 	r->rtm_table	= RT_TABLE_MAIN;
-	RTA_PUT_U32(skb, RTA_TABLE, RT_TABLE_MAIN);
+	NLA_PUT_U32(skb, RTA_TABLE, RT_TABLE_MAIN);
 	r->rtm_type	= rt->rt_type;
 	r->rtm_scope	= RT_SCOPE_UNIVERSE;
 	r->rtm_protocol = RTPROT_UNSPEC;
 	r->rtm_flags	= (rt->rt_flags & ~0xFFFF) | RTM_F_CLONED;
 	if (rt->rt_flags & RTCF_NOTIFY)
 		r->rtm_flags |= RTM_F_NOTIFY;
-	RTA_PUT(skb, RTA_DST, 4, &rt->rt_dst);
+
+	NLA_PUT_U32(skb, RTA_DST, rt->rt_dst);
+
 	if (rt->fl.fl4_src) {
 		r->rtm_src_len = 32;
-		RTA_PUT(skb, RTA_SRC, 4, &rt->fl.fl4_src);
+		NLA_PUT_U32(skb, RTA_SRC, rt->fl.fl4_src);
 	}
 	if (rt->u.dst.dev)
-		RTA_PUT(skb, RTA_OIF, sizeof(int), &rt->u.dst.dev->ifindex);
+		NLA_PUT_U32(skb, RTA_OIF, rt->u.dst.dev->ifindex);
 #ifdef CONFIG_NET_CLS_ROUTE
 	if (rt->u.dst.tclassid)
-		RTA_PUT(skb, RTA_FLOW, 4, &rt->u.dst.tclassid);
+		NLA_PUT_U32(skb, RTA_FLOW, rt->u.dst.tclassid);
 #endif
 #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
-	if (rt->rt_multipath_alg != IP_MP_ALG_NONE) {
-		__u32 alg = rt->rt_multipath_alg;
-
-		RTA_PUT(skb, RTA_MP_ALGO, 4, &alg);
-	}
+	if (rt->rt_multipath_alg != IP_MP_ALG_NONE)
+		NLA_PUT_U32(skb, RTA_MP_ALGO, rt->rt_multipath_alg);
 #endif
 	if (rt->fl.iif)
-		RTA_PUT(skb, RTA_PREFSRC, 4, &rt->rt_spec_dst);
+		NLA_PUT_U32(skb, RTA_PREFSRC, rt->rt_spec_dst);
 	else if (rt->rt_src != rt->fl.fl4_src)
-		RTA_PUT(skb, RTA_PREFSRC, 4, &rt->rt_src);
+		NLA_PUT_U32(skb, RTA_PREFSRC, rt->rt_src);
+
 	if (rt->rt_dst != rt->rt_gateway)
-		RTA_PUT(skb, RTA_GATEWAY, 4, &rt->rt_gateway);
+		NLA_PUT_U32(skb, RTA_GATEWAY, rt->rt_gateway);
+
 	if (rtnetlink_put_metrics(skb, rt->u.dst.metrics) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
+
 	ci.rta_lastuse	= jiffies_to_clock_t(jiffies - rt->u.dst.lastuse);
 	ci.rta_used	= rt->u.dst.__use;
 	ci.rta_clntref	= atomic_read(&rt->u.dst.__refcnt);
@@ -2701,10 +2703,7 @@ static int rt_fill_info(struct sk_buff *
 			ci.rta_tsage = xtime.tv_sec - rt->peer->tcp_ts_stamp;
 		}
 	}
-#ifdef CONFIG_IP_MROUTE
-	eptr = (struct rtattr*)skb->tail;
-#endif
-	RTA_PUT(skb, RTA_CACHEINFO, sizeof(ci), &ci);
+
 	if (rt->fl.iif) {
 #ifdef CONFIG_IP_MROUTE
 		u32 dst = rt->rt_dst;
@@ -2716,25 +2715,24 @@ static int rt_fill_info(struct sk_buff *
 				if (!nowait) {
 					if (err == 0)
 						return 0;
-					goto nlmsg_failure;
+					goto nla_put_failure;
 				} else {
 					if (err == -EMSGSIZE)
-						goto nlmsg_failure;
-					((struct rta_cacheinfo*)RTA_DATA(eptr))->rta_error = err;
+						goto nla_put_failure;
+					ci.rta_error = err;
 				}
 			}
 		} else
 #endif
-			RTA_PUT(skb, RTA_IIF, sizeof(int), &rt->fl.iif);
+			NLA_PUT_U32(skb, RTA_IIF, rt->fl.iif);
 	}
 
-	nlh->nlmsg_len = skb->tail - b;
-	return skb->len;
+	NLA_PUT(skb, RTA_CACHEINFO, sizeof(ci), &ci);
+
+	return nlmsg_end(skb, nlh);
 
-nlmsg_failure:
-rtattr_failure:
-	skb_trim(skb, b - skb->data);
-	return -1;
+nla_put_failure:
+	return nlmsg_cancel(skb, nlh);
 }
 
 int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void *arg)
Index: net-2.6.19.git/net/ipv4/fib_frontend.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/fib_frontend.c
+++ net-2.6.19.git/net/ipv4/fib_frontend.c
@@ -591,8 +591,8 @@ int inet_dump_fib(struct sk_buff *skb, s
 	struct hlist_node *node;
 	int dumped = 0;
 
-	if (NLMSG_PAYLOAD(cb->nlh, 0) >= sizeof(struct rtmsg) &&
-	    ((struct rtmsg*)NLMSG_DATA(cb->nlh))->rtm_flags&RTM_F_CLONED)
+	if (nlmsg_len(cb->nlh) >= sizeof(struct rtmsg) &&
+	    ((struct rtmsg *) nlmsg_data(cb->nlh))->rtm_flags & RTM_F_CLONED)
 		return ip_rt_dump(skb, cb);
 
 	s_h = cb->args[0];

