From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v3] ipv6: check for ip6_null_entry in __ip6_del_rt_siblings()
Date: Mon, 27 Feb 2017 16:07:43 -0800
Message-ID: <1488240463-12000-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34137 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751030AbdB1AIb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 19:08:31 -0500
Received: by mail-pf0-f196.google.com with SMTP id o64so5219505pfb.1
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 16:07:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrey reported a NULL pointer deref bug in ipv6_route_ioctl()
-> ip6_route_del() -> __ip6_del_rt_siblings() code path. This is
because ip6_null_entry is returned in this path since ip6_null_entry
is kinda default for a ipv6 route table root node. Quote from
David Ahern:

 ip6_null_entry is the root of all ipv6 fib tables making it integrated
 into the table ...

We should ignore any attempt of trying to delete it, like we do in
__ip6_del_rt() path and several others.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Fixes: 0ae8133586ad ("net: ipv6: Allow shorthand delete of all nexthops in multipath route")
Cc: David Ahern <dsa@cumulusnetworks.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/route.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f54f426..77c7ce7 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2169,10 +2169,13 @@ int ip6_del_rt(struct rt6_info *rt)
 static int __ip6_del_rt_siblings(struct rt6_info *rt, struct fib6_config *cfg)
 {
 	struct nl_info *info = &cfg->fc_nlinfo;
+	struct net *net = info->nl_net;
 	struct sk_buff *skb = NULL;
 	struct fib6_table *table;
-	int err;
+	int err = -ENOENT;
 
+	if (rt == net->ipv6.ip6_null_entry)
+		goto out_put;
 	table = rt->rt6i_table;
 	write_lock_bh(&table->tb6_lock);
 
@@ -2184,7 +2187,7 @@ static int __ip6_del_rt_siblings(struct rt6_info *rt, struct fib6_config *cfg)
 		if (skb) {
 			u32 seq = info->nlh ? info->nlh->nlmsg_seq : 0;
 
-			if (rt6_fill_node(info->nl_net, skb, rt,
+			if (rt6_fill_node(net, skb, rt,
 					  NULL, NULL, 0, RTM_DELROUTE,
 					  info->portid, seq, 0) < 0) {
 				kfree_skb(skb);
@@ -2198,17 +2201,18 @@ static int __ip6_del_rt_siblings(struct rt6_info *rt, struct fib6_config *cfg)
 					 rt6i_siblings) {
 			err = fib6_del(sibling, info);
 			if (err)
-				goto out;
+				goto out_unlock;
 		}
 	}
 
 	err = fib6_del(rt, info);
-out:
+out_unlock:
 	write_unlock_bh(&table->tb6_lock);
+out_put:
 	ip6_rt_put(rt);
 
 	if (skb) {
-		rtnl_notify(skb, info->nl_net, info->portid, RTNLGRP_IPV6_ROUTE,
+		rtnl_notify(skb, net, info->portid, RTNLGRP_IPV6_ROUTE,
 			    info->nlh, gfp_any());
 	}
 	return err;
-- 
2.5.5
