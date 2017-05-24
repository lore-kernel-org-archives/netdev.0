From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 8/8] net: ipv6: RTM_GETROUTE: return matched fib result when requested
Date: Wed, 24 May 2017 11:19:11 -0700
Message-ID: <1495649951-30417-9-git-send-email-roopa@cumulusnetworks.com>
References: <1495649951-30417-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, dsahern@gmail.com,
        nikolay@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36215 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933834AbdEXSTX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 14:19:23 -0400
Received: by mail-pf0-f179.google.com with SMTP id m17so143163444pfg.3
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 11:19:23 -0700 (PDT)
In-Reply-To: <1495649951-30417-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds support to return matched fib result when RTM_F_FIB_MATCH
flag is specified in RTM_GETROUTE request. This is useful for user-space
applications/controllers wanting to query a matching route.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/ipv6/route.c | 36 +++++++++++++++++++++++++++++-------
 1 file changed, 29 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 80bda31..c4d6da9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3612,6 +3612,7 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 	struct rtmsg *rtm;
 	struct flowi6 fl6;
 	int err, iif = 0, oif = 0;
+	bool fibmatch;
 
 	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv6_policy,
 			  extack);
@@ -3622,6 +3623,7 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 	memset(&fl6, 0, sizeof(fl6));
 	rtm = nlmsg_data(nlh);
 	fl6.flowlabel = ip6_make_flowinfo(rtm->rtm_tos, 0);
+	fibmatch = (rtm->rtm_flags & RTM_F_FIB_MATCH) ? true : false;
 
 	if (tb[RTA_SRC]) {
 		if (nla_len(tb[RTA_SRC]) < sizeof(struct in6_addr))
@@ -3667,12 +3669,27 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 		if (!ipv6_addr_any(&fl6.saddr))
 			flags |= RT6_LOOKUP_F_HAS_SADDR;
 
-		rt = (struct rt6_info *)ip6_route_input_lookup(net, dev, &fl6,
-							       flags);
+		if (!fibmatch)
+			rt = (struct rt6_info *)ip6_route_input_lookup(net, dev,
+								       &fl6,
+								       flags);
 	} else {
 		fl6.flowi6_oif = oif;
 
-		rt = (struct rt6_info *)ip6_route_output(net, NULL, &fl6);
+		if (!fibmatch)
+			rt = (struct rt6_info *)ip6_route_output_flags(net,
+								       NULL,
+								       &fl6, 0);
+	}
+
+	if (fibmatch) {
+		rt = (struct rt6_info *)ip6_route_lookup(net, &fl6, 0);
+		if (rt->dst.error) {
+			err = rt->dst.error;
+			ip6_rt_put(rt);
+			goto errout;
+		}
+
 	}
 
 	if (rt == net->ipv6.ip6_null_entry) {
@@ -3689,10 +3706,15 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 	}
 
 	skb_dst_set(skb, &rt->dst);
-
-	err = rt6_fill_node(net, skb, rt, &fl6.daddr, &fl6.saddr, iif,
-			    RTM_NEWROUTE, NETLINK_CB(in_skb).portid,
-			    nlh->nlmsg_seq, 0);
+	if (fibmatch) {
+		err = rt6_fill_node(net, skb, rt, NULL, NULL, iif,
+				    RTM_NEWROUTE, NETLINK_CB(in_skb).portid,
+				    nlh->nlmsg_seq, 0);
+	} else {
+		err = rt6_fill_node(net, skb, rt, &fl6.daddr, &fl6.saddr, iif,
+				    RTM_NEWROUTE, NETLINK_CB(in_skb).portid,
+				    nlh->nlmsg_seq, 0);
+	}
 	if (err < 0) {
 		kfree_skb(skb);
 		goto errout;
-- 
1.9.1
