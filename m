From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 1/2] ipv4: take rtnl_lock and mark mrt table as freed on namespace cleanup
Date: Wed, 25 Mar 2015 12:05:44 -0700
Message-ID: <1427310345-29829-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35456 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbbCYTFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 15:05:55 -0400
Received: by pdbop1 with SMTP id op1so37337623pdb.2
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 12:05:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the IPv4 part for commit 905a6f96a1b1
(ipv6: take rtnl_lock and mark mrt6 table as freed on namespace cleanup).

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/ipmr.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 9d78427..d6fede8 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -278,10 +278,12 @@ static void __net_exit ipmr_rules_exit(struct net *net)
 {
 	struct mr_table *mrt, *next;
 
+	rtnl_lock();
 	list_for_each_entry_safe(mrt, next, &net->ipv4.mr_tables, list) {
 		list_del(&mrt->list);
 		ipmr_free_table(mrt);
 	}
+	rtnl_unlock();
 	fib_rules_unregister(net->ipv4.mr_rules_ops);
 }
 #else
@@ -308,7 +310,10 @@ static int __net_init ipmr_rules_init(struct net *net)
 
 static void __net_exit ipmr_rules_exit(struct net *net)
 {
+	rtnl_lock();
 	ipmr_free_table(net->ipv4.mrt);
+	net->ipv4.mrt = NULL;
+	rtnl_unlock();
 }
 #endif
 
-- 
1.8.3.1
