From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH 1/2] net: ipv4: Simplify rt_fill_info
Date: Thu,  5 Jan 2017 19:32:46 -0800
Message-ID: <1483673566-14311-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33867 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937594AbdAFDcx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 22:32:53 -0500
Received: by mail-pf0-f177.google.com with SMTP id 127so11099810pfg.1
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 19:32:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rt_fill_info has only 1 caller and both of the last 2 args -- nowait
and flags -- are hardcoded to 0. Given that remove them as input arguments
and simplify rt_fill_info accordingly.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 0fcac8e7a2b2..7b52ac20145b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2454,7 +2454,7 @@ EXPORT_SYMBOL_GPL(ip_route_output_flow);
 
 static int rt_fill_info(struct net *net,  __be32 dst, __be32 src, u32 table_id,
 			struct flowi4 *fl4, struct sk_buff *skb, u32 portid,
-			u32 seq, int event, int nowait, unsigned int flags)
+			u32 seq, int event)
 {
 	struct rtable *rt = skb_rtable(skb);
 	struct rtmsg *r;
@@ -2463,7 +2463,7 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src, u32 table_id,
 	u32 error;
 	u32 metrics[RTAX_MAX];
 
-	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*r), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*r), 0);
 	if (!nlh)
 		return -EMSGSIZE;
 
@@ -2541,18 +2541,12 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src, u32 table_id,
 		    IPV4_DEVCONF_ALL(net, MC_FORWARDING)) {
 			int err = ipmr_get_route(net, skb,
 						 fl4->saddr, fl4->daddr,
-						 r, nowait, portid);
+						 r, 0, portid);
 
 			if (err <= 0) {
-				if (!nowait) {
-					if (err == 0)
-						return 0;
-					goto nla_put_failure;
-				} else {
-					if (err == -EMSGSIZE)
-						goto nla_put_failure;
-					error = err;
-				}
+				if (err == 0)
+					return 0;
+				goto nla_put_failure;
 			}
 		} else
 #endif
@@ -2665,7 +2659,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 
 	err = rt_fill_info(net, dst, src, table_id, &fl4, skb,
 			   NETLINK_CB(in_skb).portid, nlh->nlmsg_seq,
-			   RTM_NEWROUTE, 0, 0);
+			   RTM_NEWROUTE);
 	if (err < 0)
 		goto errout_free;
 
-- 
2.1.4
