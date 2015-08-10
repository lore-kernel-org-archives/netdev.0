From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 8/9] net: Use passed in table for nexthop lookups
Date: Mon, 10 Aug 2015 11:50:35 -0600
Message-ID: <1439229037-79213-9-git-send-email-dsa@cumulusnetworks.com>
References: <1439229037-79213-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:36723 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932444AbbHJRw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 13:52:58 -0400
Received: by igbij6 with SMTP id ij6so74629733igb.1
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 10:52:57 -0700 (PDT)
In-Reply-To: <1439229037-79213-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a user passes in a table for new routes use that table for nexthop
lookups. Specifically, this solves the case where a connected route does
not exist in the main table, but only another table and then a subsequent
route is added with a next hop using the connected route. ie.,

$ ip route ls
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
169.254.0.0/16 dev eth0  scope link  metric 1003
192.168.56.0/24 dev eth1  proto kernel  scope link  src 192.168.56.51

$ ip route ls table 10
1.1.1.0/24 dev eth2  scope link

Without this patch adding a nexthop route fails:

$ ip route add table 10 2.2.2.0/24 via 1.1.1.10
RTNETLINK answers: Network is unreachable

With this patch the route is added successfully.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/fib_semantics.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 85e9a8abf15c..b7f1d20a9615 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -691,6 +691,7 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 		}
 		rcu_read_lock();
 		{
+			struct fib_table *tbl = NULL;
 			struct flowi4 fl4 = {
 				.daddr = nh->nh_gw,
 				.flowi4_scope = cfg->fc_scope + 1,
@@ -701,8 +702,16 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 			/* It is not necessary, but requires a bit of thinking */
 			if (fl4.flowi4_scope < RT_SCOPE_LINK)
 				fl4.flowi4_scope = RT_SCOPE_LINK;
-			err = fib_lookup(net, &fl4, &res,
-					 FIB_LOOKUP_IGNORE_LINKSTATE);
+
+			if (cfg->fc_table)
+				tbl = fib_get_table(net, cfg->fc_table);
+
+			if (tbl)
+				err = fib_table_lookup(tbl, &fl4, &res,
+						   FIB_LOOKUP_IGNORE_LINKSTATE);
+			else
+				err = fib_lookup(net, &fl4, &res,
+						 FIB_LOOKUP_IGNORE_LINKSTATE);
 			if (err) {
 				rcu_read_unlock();
 				return err;
-- 
2.3.2 (Apple Git-55)
