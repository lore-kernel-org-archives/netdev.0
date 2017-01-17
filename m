From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 1/2] net: ipv6: remove nowait arg to rt6_fill_node
Date: Tue, 17 Jan 2017 15:51:07 -0800
Message-ID: <1484697068-20106-2-git-send-email-dsa@cumulusnetworks.com>
References: <1484697068-20106-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:32858 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751612AbdAQXvO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 18:51:14 -0500
Received: by mail-pf0-f180.google.com with SMTP id y143so65655712pfb.0
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 15:51:14 -0800 (PST)
In-Reply-To: <1484697068-20106-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All callers of rt6_fill_node pass 0 for nowait arg. Remove the arg and
simplify rt6_fill_node accordingly.

rt6_fill_node passes the nowait of 0 to ip6mr_get_route. Remove the
nowait arg from it as well.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/linux/mroute6.h |  2 +-
 net/ipv6/ip6mr.c        |  9 ++-------
 net/ipv6/route.c        | 27 ++++++++++-----------------
 3 files changed, 13 insertions(+), 25 deletions(-)

diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
index 19a1c0c2993b..ce44e3e96d27 100644
--- a/include/linux/mroute6.h
+++ b/include/linux/mroute6.h
@@ -116,7 +116,7 @@ struct mfc6_cache {
 
 struct rtmsg;
 extern int ip6mr_get_route(struct net *net, struct sk_buff *skb,
-			   struct rtmsg *rtm, int nowait, u32 portid);
+			   struct rtmsg *rtm, u32 portid);
 
 #ifdef CONFIG_IPV6_MROUTE
 extern struct sock *mroute6_socket(struct net *net, struct sk_buff *skb);
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index e275077e8af2..babaf3ec2742 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2288,7 +2288,7 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 }
 
 int ip6mr_get_route(struct net *net, struct sk_buff *skb, struct rtmsg *rtm,
-		    int nowait, u32 portid)
+		    u32 portid)
 {
 	int err;
 	struct mr6_table *mrt;
@@ -2315,11 +2315,6 @@ int ip6mr_get_route(struct net *net, struct sk_buff *skb, struct rtmsg *rtm,
 		struct net_device *dev;
 		int vif;
 
-		if (nowait) {
-			read_unlock(&mrt_lock);
-			return -EAGAIN;
-		}
-
 		dev = skb->dev;
 		if (!dev || (vif = ip6mr_find_vif(mrt, dev)) < 0) {
 			read_unlock(&mrt_lock);
@@ -2357,7 +2352,7 @@ int ip6mr_get_route(struct net *net, struct sk_buff *skb, struct rtmsg *rtm,
 		return err;
 	}
 
-	if (!nowait && (rtm->rtm_flags&RTM_F_NOTIFY))
+	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		cache->mfc_flags |= MFC_NOTIFY;
 
 	err = __ip6mr_fill_mroute(mrt, skb, cache, rtm);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4f6b067c8753..b2044dd71724 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3169,7 +3169,7 @@ static int rt6_fill_node(struct net *net,
 			 struct sk_buff *skb, struct rt6_info *rt,
 			 struct in6_addr *dst, struct in6_addr *src,
 			 int iif, int type, u32 portid, u32 seq,
-			 int prefix, int nowait, unsigned int flags)
+			 int prefix, unsigned int flags)
 {
 	u32 metrics[RTAX_MAX];
 	struct rtmsg *rtm;
@@ -3261,19 +3261,12 @@ static int rt6_fill_node(struct net *net,
 	if (iif) {
 #ifdef CONFIG_IPV6_MROUTE
 		if (ipv6_addr_is_multicast(&rt->rt6i_dst.addr)) {
-			int err = ip6mr_get_route(net, skb, rtm, nowait,
-						  portid);
-
-			if (err <= 0) {
-				if (!nowait) {
-					if (err == 0)
-						return 0;
-					goto nla_put_failure;
-				} else {
-					if (err == -EMSGSIZE)
-						goto nla_put_failure;
-				}
-			}
+			int err = ip6mr_get_route(net, skb, rtm, portid);
+
+			if (err == 0)
+				return 0;
+			if (err < 0)
+				goto nla_put_failure;
 		} else
 #endif
 			if (nla_put_u32(skb, RTA_IIF, iif))
@@ -3342,7 +3335,7 @@ int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 	return rt6_fill_node(arg->net,
 		     arg->skb, rt, NULL, NULL, 0, RTM_NEWROUTE,
 		     NETLINK_CB(arg->cb->skb).portid, arg->cb->nlh->nlmsg_seq,
-		     prefix, 0, NLM_F_MULTI);
+		     prefix, NLM_F_MULTI);
 }
 
 static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
@@ -3433,7 +3426,7 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 
 	err = rt6_fill_node(net, skb, rt, &fl6.daddr, &fl6.saddr, iif,
 			    RTM_NEWROUTE, NETLINK_CB(in_skb).portid,
-			    nlh->nlmsg_seq, 0, 0, 0);
+			    nlh->nlmsg_seq, 0, 0);
 	if (err < 0) {
 		kfree_skb(skb);
 		goto errout;
@@ -3460,7 +3453,7 @@ void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info,
 		goto errout;
 
 	err = rt6_fill_node(net, skb, rt, NULL, NULL, 0,
-				event, info->portid, seq, 0, 0, nlm_flags);
+				event, info->portid, seq, 0, nlm_flags);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in rt6_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
-- 
2.1.4
