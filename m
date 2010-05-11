From: kaber@trash.net
Subject: [PATCH 6/6] ipv6: ip6mr: add support for dumping routing tables over netlink
Date: Tue, 11 May 2010 16:02:31 +0200
Message-ID: <1273586551-3521-7-git-send-email-kaber@trash.net>
References: <1273586551-3521-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40385 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758040Ab0EKOCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 10:02:36 -0400
In-Reply-To: <1273586551-3521-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

The ip6mr /proc interface (ip6_mr_cache) can't be extended to dump routes
from any tables but the main table in a backwards compatible fashion since
the output format ends in a variable amount of output interfaces.

Introduce a new netlink interface to dump multicast routes from all tables,
similar to the netlink interface for regular routes.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/ip6mr.c |   96 ++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 89 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index c2920a1..163850e 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -112,8 +112,10 @@ static int ip6_mr_forward(struct net *net, struct mr6_table *mrt,
 			  struct sk_buff *skb, struct mfc6_cache *cache);
 static int ip6mr_cache_report(struct mr6_table *mrt, struct sk_buff *pkt,
 			      mifi_t mifi, int assert);
-static int ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
-			     struct mfc6_cache *c, struct rtmsg *rtm);
+static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
+			       struct mfc6_cache *c, struct rtmsg *rtm);
+static int ip6mr_rtm_dumproute(struct sk_buff *skb,
+			       struct netlink_callback *cb);
 static void mroute_clean_tables(struct mr6_table *mrt);
 static void ipmr_expire_process(unsigned long arg);
 
@@ -1038,7 +1040,7 @@ static void ip6mr_cache_resolve(struct net *net, struct mr6_table *mrt,
 			int err;
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct ipv6hdr));
 
-			if (ip6mr_fill_mroute(mrt, skb, c, NLMSG_DATA(nlh)) > 0) {
+			if (__ip6mr_fill_mroute(mrt, skb, c, NLMSG_DATA(nlh)) > 0) {
 				nlh->nlmsg_len = skb_tail_pointer(skb) - (u8 *)nlh;
 			} else {
 				nlh->nlmsg_type = NLMSG_ERROR;
@@ -1350,6 +1352,7 @@ int __init ip6_mr_init(void)
 		goto add_proto_fail;
 	}
 #endif
+	rtnl_register(RTNL_FAMILY_IP6MR, RTM_GETROUTE, NULL, ip6mr_rtm_dumproute);
 	return 0;
 #ifdef CONFIG_IPV6_PIMSM_V2
 add_proto_fail:
@@ -2007,9 +2010,8 @@ int ip6_mr_input(struct sk_buff *skb)
 }
 
 
-static int
-ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
-		  struct mfc6_cache *c, struct rtmsg *rtm)
+static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
+			       struct mfc6_cache *c, struct rtmsg *rtm)
 {
 	int ct;
 	struct rtnexthop *nhp;
@@ -2111,8 +2113,88 @@ int ip6mr_get_route(struct net *net,
 	if (!nowait && (rtm->rtm_flags&RTM_F_NOTIFY))
 		cache->mfc_flags |= MFC_NOTIFY;
 
-	err = ip6mr_fill_mroute(mrt, skb, cache, rtm);
+	err = __ip6mr_fill_mroute(mrt, skb, cache, rtm);
 	read_unlock(&mrt_lock);
 	return err;
 }
 
+static int ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
+			     u32 pid, u32 seq, struct mfc6_cache *c)
+{
+	struct nlmsghdr *nlh;
+	struct rtmsg *rtm;
+
+	nlh = nlmsg_put(skb, pid, seq, RTM_NEWROUTE, sizeof(*rtm), NLM_F_MULTI);
+	if (nlh == NULL)
+		return -EMSGSIZE;
+
+	rtm = nlmsg_data(nlh);
+	rtm->rtm_family   = RTNL_FAMILY_IPMR;
+	rtm->rtm_dst_len  = 128;
+	rtm->rtm_src_len  = 128;
+	rtm->rtm_tos      = 0;
+	rtm->rtm_table    = mrt->id;
+	NLA_PUT_U32(skb, RTA_TABLE, mrt->id);
+	rtm->rtm_scope    = RT_SCOPE_UNIVERSE;
+	rtm->rtm_protocol = RTPROT_UNSPEC;
+	rtm->rtm_flags    = 0;
+
+	NLA_PUT(skb, RTA_SRC, 16, &c->mf6c_origin);
+	NLA_PUT(skb, RTA_DST, 16, &c->mf6c_mcastgrp);
+
+	if (__ip6mr_fill_mroute(mrt, skb, c, rtm) < 0)
+		goto nla_put_failure;
+
+	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+static int ip6mr_rtm_dumproute(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct mr6_table *mrt;
+	struct mfc6_cache *mfc;
+	unsigned int t = 0, s_t;
+	unsigned int h = 0, s_h;
+	unsigned int e = 0, s_e;
+
+	s_t = cb->args[0];
+	s_h = cb->args[1];
+	s_e = cb->args[2];
+
+	read_lock(&mrt_lock);
+	ip6mr_for_each_table(mrt, net) {
+		if (t < s_t)
+			goto next_table;
+		if (t > s_t)
+			s_h = 0;
+		for (h = s_h; h < MFC6_LINES; h++) {
+			list_for_each_entry(mfc, &mrt->mfc6_cache_array[h], list) {
+				if (e < s_e)
+					goto next_entry;
+				if (ip6mr_fill_mroute(mrt, skb,
+						      NETLINK_CB(cb->skb).pid,
+						      cb->nlh->nlmsg_seq,
+						      mfc) < 0)
+					goto done;
+next_entry:
+				e++;
+			}
+			e = s_e = 0;
+		}
+		s_h = 0;
+next_table:
+		t++;
+	}
+done:
+	read_unlock(&mrt_lock);
+
+	cb->args[2] = e;
+	cb->args[1] = h;
+	cb->args[0] = t;
+
+	return skb->len;
+}
-- 
1.7.0.4

