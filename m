From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 6/7] decnet: Do not use RTA_PUT() macros
Date: Wed, 27 Jun 2012 11:36:15 +0200
Message-ID: <62bd5127c3f69dd969135ad6764fa53bc2c0fba7.1340788373.git.tgraf@suug.ch>
References: <cover.1340788373.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44585 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756708Ab2F0Jg1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 05:36:27 -0400
In-Reply-To: <cover.1340788373.git.tgraf@suug.ch>
In-Reply-To: <cover.1340788373.git.tgraf@suug.ch>
References: <cover.1340788373.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also, no need to trim on nlmsg_put() failure, nothing has been added
yet.  We also want to use nlmsg_end(), nlmsg_new() and nlmsg_free().

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/decnet/dn_route.c |   61 +++++++++++++++++++++++++++----------------
 net/decnet/dn_table.c |   69 +++++++++++++++++++++++++++++--------------------
 2 files changed, 79 insertions(+), 51 deletions(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index cd584f7..2493ed5 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1515,56 +1515,68 @@ static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 	struct dn_route *rt = (struct dn_route *)skb_dst(skb);
 	struct rtmsg *r;
 	struct nlmsghdr *nlh;
-	unsigned char *b = skb_tail_pointer(skb);
 	long expires;
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*r), flags);
 	if (!nlh)
-		goto out_nlmsg_trim;
+		return -EMSGSIZE;
+
 	r = nlmsg_data(nlh);
 	r->rtm_family = AF_DECnet;
 	r->rtm_dst_len = 16;
 	r->rtm_src_len = 0;
 	r->rtm_tos = 0;
 	r->rtm_table = RT_TABLE_MAIN;
-	RTA_PUT_U32(skb, RTA_TABLE, RT_TABLE_MAIN);
 	r->rtm_type = rt->rt_type;
 	r->rtm_flags = (rt->rt_flags & ~0xFFFF) | RTM_F_CLONED;
 	r->rtm_scope = RT_SCOPE_UNIVERSE;
 	r->rtm_protocol = RTPROT_UNSPEC;
+
 	if (rt->rt_flags & RTCF_NOTIFY)
 		r->rtm_flags |= RTM_F_NOTIFY;
-	RTA_PUT(skb, RTA_DST, 2, &rt->rt_daddr);
+
+	if (nla_put_u32(skb, RTA_TABLE, RT_TABLE_MAIN) < 0 ||
+	    nla_put_le16(skb, RTA_DST, rt->rt_daddr) < 0)
+		goto errout;
+
 	if (rt->fld.saddr) {
 		r->rtm_src_len = 16;
-		RTA_PUT(skb, RTA_SRC, 2, &rt->fld.saddr);
+		if (nla_put_le16(skb, RTA_SRC, rt->fld.saddr) < 0)
+			goto errout;
 	}
-	if (rt->dst.dev)
-		RTA_PUT(skb, RTA_OIF, sizeof(int), &rt->dst.dev->ifindex);
+	if (rt->dst.dev &&
+	    nla_put_u32(skb, RTA_OIF, rt->dst.dev->ifindex) < 0)
+		goto errout;
+
 	/*
 	 * Note to self - change this if input routes reverse direction when
 	 * they deal only with inputs and not with replies like they do
 	 * currently.
 	 */
-	RTA_PUT(skb, RTA_PREFSRC, 2, &rt->rt_local_src);
-	if (rt->rt_daddr != rt->rt_gateway)
-		RTA_PUT(skb, RTA_GATEWAY, 2, &rt->rt_gateway);
+	if (nla_put_le16(skb, RTA_PREFSRC, rt->rt_local_src) < 0)
+		goto errout;
+
+	if (rt->rt_daddr != rt->rt_gateway &&
+	    nla_put_le16(skb, RTA_GATEWAY, rt->rt_gateway) < 0)
+		goto errout;
+
 	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
-		goto rtattr_failure;
+		goto errout;
+
 	expires = rt->dst.expires ? rt->dst.expires - jiffies : 0;
 	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, 0, 0, expires,
 			       rt->dst.error) < 0)
-		goto rtattr_failure;
-	if (dn_is_input_route(rt))
-		RTA_PUT(skb, RTA_IIF, sizeof(int), &rt->fld.flowidn_iif);
+		goto errout;
 
-	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
-	return skb->len;
+	if (dn_is_input_route(rt) &&
+	    nla_put_u32(skb, RTA_IIF, rt->fld.flowidn_iif) < 0)
+		goto errout;
 
-out_nlmsg_trim:
-rtattr_failure:
-	nlmsg_trim(skb, b);
-	return -1;
+	return nlmsg_end(skb, nlh);
+
+errout:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 /*
@@ -1587,7 +1599,7 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 	memset(&fld, 0, sizeof(fld));
 	fld.flowidn_proto = DNPROTO_NSP;
 
-	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (skb == NULL)
 		return -ENOBUFS;
 	skb_reset_mac_header(skb);
@@ -1665,13 +1677,16 @@ int dn_cache_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	struct dn_route *rt;
 	int h, s_h;
 	int idx, s_idx;
+	struct rtmsg *rtm;
 
 	if (!net_eq(net, &init_net))
 		return 0;
 
-	if (NLMSG_PAYLOAD(cb->nlh, 0) < sizeof(struct rtmsg))
+	if (nlmsg_len(cb->nlh) < sizeof(struct rtmsg))
 		return -EINVAL;
-	if (!(((struct rtmsg *)nlmsg_data(cb->nlh))->rtm_flags&RTM_F_CLONED))
+
+	rtm = nlmsg_data(cb->nlh);
+	if (!(rtm->rtm_flags & RTM_F_CLONED))
 		return 0;
 
 	s_h = cb->args[0];
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index 92ec741..16c986a 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -297,62 +297,75 @@ static int dn_fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 {
 	struct rtmsg *rtm;
 	struct nlmsghdr *nlh;
-	unsigned char *b = skb_tail_pointer(skb);
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*rtm), flags);
 	if (!nlh)
-		goto out_nlmsg_trim;
+		return -EMSGSIZE;
+
 	rtm = nlmsg_data(nlh);
 	rtm->rtm_family = AF_DECnet;
 	rtm->rtm_dst_len = dst_len;
 	rtm->rtm_src_len = 0;
 	rtm->rtm_tos = 0;
 	rtm->rtm_table = tb_id;
-	RTA_PUT_U32(skb, RTA_TABLE, tb_id);
 	rtm->rtm_flags = fi->fib_flags;
 	rtm->rtm_scope = scope;
 	rtm->rtm_type  = type;
-	if (rtm->rtm_dst_len)
-		RTA_PUT(skb, RTA_DST, 2, dst);
 	rtm->rtm_protocol = fi->fib_protocol;
-	if (fi->fib_priority)
-		RTA_PUT(skb, RTA_PRIORITY, 4, &fi->fib_priority);
+
+	if (nla_put_u32(skb, RTA_TABLE, tb_id) < 0)
+		goto errout;
+
+	if (rtm->rtm_dst_len &&
+	    nla_put(skb, RTA_DST, 2, dst) < 0)
+		goto errout;
+
+	if (fi->fib_priority &&
+	    nla_put_u32(skb, RTA_PRIORITY, fi->fib_priority) < 0)
+		goto errout;
+
 	if (rtnetlink_put_metrics(skb, fi->fib_metrics) < 0)
-		goto rtattr_failure;
+		goto errout;
+
 	if (fi->fib_nhs == 1) {
-		if (fi->fib_nh->nh_gw)
-			RTA_PUT(skb, RTA_GATEWAY, 2, &fi->fib_nh->nh_gw);
-		if (fi->fib_nh->nh_oif)
-			RTA_PUT(skb, RTA_OIF, sizeof(int), &fi->fib_nh->nh_oif);
+		if (fi->fib_nh->nh_gw &&
+		    nla_put_le16(skb, RTA_GATEWAY, fi->fib_nh->nh_gw) < 0)
+			goto errout;
+
+		if (fi->fib_nh->nh_oif &&
+		    nla_put_u32(skb, RTA_OIF, fi->fib_nh->nh_oif) < 0)
+			goto errout;
 	}
+
 	if (fi->fib_nhs > 1) {
 		struct rtnexthop *nhp;
-		struct rtattr *mp_head;
-		if (skb_tailroom(skb) <= RTA_SPACE(0))
-			goto rtattr_failure;
-		mp_head = (struct rtattr *)skb_put(skb, RTA_SPACE(0));
+		struct nlattr *mp_head;
+
+		if (!(mp_head = nla_nest_start(skb, RTA_MULTIPATH)))
+			goto errout;
 
 		for_nexthops(fi) {
-			if (skb_tailroom(skb) < RTA_ALIGN(RTA_ALIGN(sizeof(*nhp)) + 4))
-				goto rtattr_failure;
-			nhp = (struct rtnexthop *)skb_put(skb, RTA_ALIGN(sizeof(*nhp)));
+			if (!(nhp = nla_reserve_nohdr(skb, sizeof(*nhp))))
+				goto errout;
+
 			nhp->rtnh_flags = nh->nh_flags & 0xFF;
 			nhp->rtnh_hops = nh->nh_weight - 1;
 			nhp->rtnh_ifindex = nh->nh_oif;
-			if (nh->nh_gw)
-				RTA_PUT(skb, RTA_GATEWAY, 2, &nh->nh_gw);
+
+			if (nh->nh_gw &&
+			    nla_put_le16(skb, RTA_GATEWAY, nh->nh_gw) < 0)
+				goto errout;
+
 			nhp->rtnh_len = skb_tail_pointer(skb) - (unsigned char *)nhp;
 		} endfor_nexthops(fi);
-		mp_head->rta_type = RTA_MULTIPATH;
-		mp_head->rta_len = skb_tail_pointer(skb) - (u8 *)mp_head;
+
+		nla_nest_end(skb, mp_head);
 	}
 
-	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
-	return skb->len;
+	return nlmsg_end(skb, nlh);
 
-out_nlmsg_trim:
-rtattr_failure:
-	nlmsg_trim(skb, b);
+errout:
+	nlmsg_cancel(skb, nlh);
 	return -EMSGSIZE;
 }
 
-- 
1.7.7.6
