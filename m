From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ipv6: check for ip6_null_entry in __ip6_del_rt_siblings()
Date: Mon, 27 Feb 2017 11:07:05 -0800
Message-ID: <1488222425-1256-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:32908 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751634AbdB0TQV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 14:16:21 -0500
Received: by mail-pg0-f65.google.com with SMTP id x17so1915163pgi.0
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 11:15:55 -0800 (PST)
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
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/route.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f54f426..9da77e9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2169,10 +2169,13 @@ int ip6_del_rt(struct rt6_info *rt)
 static int __ip6_del_rt_siblings(struct rt6_info *rt, struct fib6_config *cfg)
 {
 	struct nl_info *info = &cfg->fc_nlinfo;
+	struct net *net = info->nl_net;
 	struct sk_buff *skb = NULL;
 	struct fib6_table *table;
 	int err;
 
+	if (rt == net->ipv6.ip6_null_entry)
+		return -ENOENT;
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
@@ -2208,7 +2211,7 @@ static int __ip6_del_rt_siblings(struct rt6_info *rt, struct fib6_config *cfg)
 	ip6_rt_put(rt);
 
 	if (skb) {
-		rtnl_notify(skb, info->nl_net, info->portid, RTNLGRP_IPV6_ROUTE,
+		rtnl_notify(skb, net, info->portid, RTNLGRP_IPV6_ROUTE,
 			    info->nlh, gfp_any());
 	}
 	return err;
-- 
2.5.5
