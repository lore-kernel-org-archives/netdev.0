From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 10/16] net: Use passed in table for nexthop lookups
Date: Mon, 27 Jul 2015 12:31:03 -0600
Message-ID: <1438021869-49186-11-git-send-email-dsa@cumulusnetworks.com>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	mingo@kernel.org, luto@amacapital.net,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:32850 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbbG0SdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 14:33:08 -0400
Received: by igbpg9 with SMTP id pg9so104326090igb.0
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 11:33:07 -0700 (PDT)
In-Reply-To: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
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
index 37e1dee7692a..7d79dfbfa5d2 100644
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
