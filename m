From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2 8/8] net: ipv6: RTM_GETROUTE: return matched fib result when requested
Date: Thu, 25 May 2017 10:42:40 -0700
Message-ID: <1495734160-47659-9-git-send-email-roopa@cumulusnetworks.com>
References: <1495734160-47659-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: davem@davemloft.net, dsahern@gmail.com, rami.rosen@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34916 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969966AbdEYRnK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 13:43:10 -0400
Received: by mail-pf0-f179.google.com with SMTP id n23so173595072pfb.2
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 10:43:10 -0700 (PDT)
In-Reply-To: <1495734160-47659-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds support to return matched fib result when RTM_F_FIB_MATCH
flag is specified in RTM_GETROUTE request. This is useful for user-space
applications/controllers wanting to query a matching route.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/ipv6/route.c | 34 ++++++++++++++++++++++++++--------
 1 file changed, 26 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 80bda31..2fe84bd 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3607,11 +3607,13 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct nlattr *tb[RTA_MAX+1];
+	int err, iif = 0, oif = 0;
+	struct dst_entry *dst;
 	struct rt6_info *rt;
 	struct sk_buff *skb;
 	struct rtmsg *rtm;
 	struct flowi6 fl6;
-	int err, iif = 0, oif = 0;
+	bool fibmatch;
 
 	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv6_policy,
 			  extack);
@@ -3622,6 +3624,7 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 	memset(&fl6, 0, sizeof(fl6));
 	rtm = nlmsg_data(nlh);
 	fl6.flowlabel = ip6_make_flowinfo(rtm->rtm_tos, 0);
+	fibmatch = !!(rtm->rtm_flags & RTM_F_FIB_MATCH);
 
 	if (tb[RTA_SRC]) {
 		if (nla_len(tb[RTA_SRC]) < sizeof(struct in6_addr))
@@ -3667,12 +3670,23 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 		if (!ipv6_addr_any(&fl6.saddr))
 			flags |= RT6_LOOKUP_F_HAS_SADDR;
 
-		rt = (struct rt6_info *)ip6_route_input_lookup(net, dev, &fl6,
-							       flags);
+		if (!fibmatch)
+			dst = ip6_route_input_lookup(net, dev, &fl6, flags);
 	} else {
 		fl6.flowi6_oif = oif;
 
-		rt = (struct rt6_info *)ip6_route_output(net, NULL, &fl6);
+		if (!fibmatch)
+			dst = ip6_route_output(net, NULL, &fl6);
+	}
+
+	if (fibmatch)
+		dst = ip6_route_lookup(net, &fl6, 0);
+
+	rt = container_of(dst, struct rt6_info, dst);
+	if (rt->dst.error) {
+		err = rt->dst.error;
+		ip6_rt_put(rt);
+		goto errout;
 	}
 
 	if (rt == net->ipv6.ip6_null_entry) {
@@ -3689,10 +3703,14 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 	}
 
 	skb_dst_set(skb, &rt->dst);
-
-	err = rt6_fill_node(net, skb, rt, &fl6.daddr, &fl6.saddr, iif,
-			    RTM_NEWROUTE, NETLINK_CB(in_skb).portid,
-			    nlh->nlmsg_seq, 0);
+	if (fibmatch)
+		err = rt6_fill_node(net, skb, rt, NULL, NULL, iif,
+				    RTM_NEWROUTE, NETLINK_CB(in_skb).portid,
+				    nlh->nlmsg_seq, 0);
+	else
+		err = rt6_fill_node(net, skb, rt, &fl6.daddr, &fl6.saddr, iif,
+				    RTM_NEWROUTE, NETLINK_CB(in_skb).portid,
+				    nlh->nlmsg_seq, 0);
 	if (err < 0) {
 		kfree_skb(skb);
 		goto errout;
-- 
1.9.1
