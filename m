From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/2] net: ipv6: remove prefix arg to rt6_fill_node
Date: Tue, 17 Jan 2017 15:51:08 -0800
Message-ID: <1484697068-20106-3-git-send-email-dsa@cumulusnetworks.com>
References: <1484697068-20106-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36719 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751378AbdAQXvP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 18:51:15 -0500
Received: by mail-pf0-f177.google.com with SMTP id 189so65655111pfu.3
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 15:51:15 -0800 (PST)
In-Reply-To: <1484697068-20106-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The prefix arg to rt6_fill_node is non-0 in only 1 path - rt6_dump_route
where a user is requesting a prefix only dump. Simplify rt6_fill_node
by removing the prefix arg and moving the prefix check to rt6_dump_route.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/route.c | 27 ++++++++++++---------------
 1 file changed, 12 insertions(+), 15 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b2044dd71724..5585c501a540 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3169,7 +3169,7 @@ static int rt6_fill_node(struct net *net,
 			 struct sk_buff *skb, struct rt6_info *rt,
 			 struct in6_addr *dst, struct in6_addr *src,
 			 int iif, int type, u32 portid, u32 seq,
-			 int prefix, unsigned int flags)
+			 unsigned int flags)
 {
 	u32 metrics[RTAX_MAX];
 	struct rtmsg *rtm;
@@ -3177,13 +3177,6 @@ static int rt6_fill_node(struct net *net,
 	long expires;
 	u32 table;
 
-	if (prefix) {	/* user wants prefix routes only */
-		if (!(rt->rt6i_flags & RTF_PREFIX_RT)) {
-			/* success since this is not a prefix route */
-			return 1;
-		}
-	}
-
 	nlh = nlmsg_put(skb, portid, seq, type, sizeof(*rtm), flags);
 	if (!nlh)
 		return -EMSGSIZE;
@@ -3324,18 +3317,22 @@ static int rt6_fill_node(struct net *net,
 int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 {
 	struct rt6_rtnl_dump_arg *arg = (struct rt6_rtnl_dump_arg *) p_arg;
-	int prefix;
 
 	if (nlmsg_len(arg->cb->nlh) >= sizeof(struct rtmsg)) {
 		struct rtmsg *rtm = nlmsg_data(arg->cb->nlh);
-		prefix = (rtm->rtm_flags & RTM_F_PREFIX) != 0;
-	} else
-		prefix = 0;
+
+		/* user wants prefix routes only */
+		if (rtm->rtm_flags & RTM_F_PREFIX &&
+		    !(rt->rt6i_flags & RTF_PREFIX_RT)) {
+			/* success since this is not a prefix route */
+			return 1;
+		}
+	}
 
 	return rt6_fill_node(arg->net,
 		     arg->skb, rt, NULL, NULL, 0, RTM_NEWROUTE,
 		     NETLINK_CB(arg->cb->skb).portid, arg->cb->nlh->nlmsg_seq,
-		     prefix, NLM_F_MULTI);
+		     NLM_F_MULTI);
 }
 
 static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
@@ -3426,7 +3423,7 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 
 	err = rt6_fill_node(net, skb, rt, &fl6.daddr, &fl6.saddr, iif,
 			    RTM_NEWROUTE, NETLINK_CB(in_skb).portid,
-			    nlh->nlmsg_seq, 0, 0);
+			    nlh->nlmsg_seq, 0);
 	if (err < 0) {
 		kfree_skb(skb);
 		goto errout;
@@ -3453,7 +3450,7 @@ void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info,
 		goto errout;
 
 	err = rt6_fill_node(net, skb, rt, NULL, NULL, 0,
-				event, info->portid, seq, 0, nlm_flags);
+				event, info->portid, seq, nlm_flags);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in rt6_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
-- 
2.1.4
