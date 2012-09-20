From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] ipv6: release referenct of ip6_null_entry's dst entry in __ip6_del_rt
Date: Thu, 20 Sep 2012 13:25:34 +0800
Message-ID: <1348118734-2967-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:40575 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751236Ab2ITFZd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2012 01:25:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

as we hold dst_entry before we call __ip6_del_rt,
so we should alse call dst_release not only return
-ENOENT when the rt6_info is ip6_null_entry.

and we already hold the dst entry, so I think it's
safe to call dst_release out of the write-read lock.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv6/route.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 854e401..46eff42 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1589,17 +1589,18 @@ static int __ip6_del_rt(struct rt6_info *rt, struct nl_info *info)
 	struct fib6_table *table;
 	struct net *net = dev_net(rt->dst.dev);
 
-	if (rt == net->ipv6.ip6_null_entry)
-		return -ENOENT;
+	if (rt == net->ipv6.ip6_null_entry) {
+		err = -ENOENT;
+		goto out;
+	}
 
 	table = rt->rt6i_table;
 	write_lock_bh(&table->tb6_lock);
-
 	err = fib6_del(rt, info);
-	dst_release(&rt->dst);
-
 	write_unlock_bh(&table->tb6_lock);
 
+out:
+	dst_release(&rt->dst);
 	return err;
 }
 
-- 
1.7.7.6
