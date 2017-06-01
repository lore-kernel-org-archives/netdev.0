From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] ipv4: route: restore skb_dst_set in inet_rtm_getroute
Date: Wed, 31 May 2017 22:53:25 -0700
Message-ID: <1496296405-61386-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com, dsahern@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36056 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750848AbdFAFxa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 01:53:30 -0400
Received: by mail-pf0-f179.google.com with SMTP id m17so27802543pfg.3
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 22:53:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

recent updates to inet_rtm_getroute dropped skb_dst_set in
inet_rtm_getroute. This patch restores it because it is
needed to release the dst correctly.

Fixes: 3765d35ed8b9 ("net: ipv4: Convert inet_rtm_getroute to rcu versions of route lookup")
Reported-by: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/ipv4/route.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f1f2e5a..9b38cf1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2547,8 +2547,9 @@ struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
 /* called with rcu_read_lock held */
 static int rt_fill_info(struct net *net,  __be32 dst, __be32 src, u32 table_id,
 			struct flowi4 *fl4, struct sk_buff *skb, u32 portid,
-			u32 seq, struct rtable *rt)
+			u32 seq)
 {
+	struct rtable *rt = skb_rtable(skb);
 	struct rtmsg *r;
 	struct nlmsghdr *nlh;
 	unsigned long expires = 0;
@@ -2750,6 +2751,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 	if (err)
 		goto errout_free;
 
+	skb_dst_set(skb, &rt->dst);
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
@@ -2763,8 +2765,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 				    fl4.flowi4_tos, res.fi, 0);
 	else
 		err = rt_fill_info(net, dst, src, table_id, &fl4, skb,
-				   NETLINK_CB(in_skb).portid, nlh->nlmsg_seq,
-				   rt);
+				   NETLINK_CB(in_skb).portid, nlh->nlmsg_seq);
 	if (err < 0)
 		goto errout_free;
 
-- 
1.9.1
