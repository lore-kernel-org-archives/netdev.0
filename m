From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: [PATCH] net: fix decnet rtnexthop parsing
Date: Tue,  5 Jul 2016 21:12:53 +0200
Message-ID: <1467745973-22340-1-git-send-email-vegard.nossum@oracle.com>
Cc: netdev@vger.kernel.org, Vegard Nossum <vegard.nossum@oracle.com>,
	Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:51574 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbcGETNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 15:13:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dn_fib_count_nhs() could enter an infinite loop if nhp->rtnh_len == 0
(i.e. if userspace passes a malformed netlink message).

Let's use the helpers from net/nexthop.h which take care of all this
stuff. We can do exactly the same as e.g. fib_count_nexthops() and
fib_get_nhs() from net/ipv4/fib_semantics.c.

This fixes the softlockup for me.

Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
---
 net/decnet/dn_fib.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index df48034..a796fc7 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -41,6 +41,7 @@
 #include <net/dn_fib.h>
 #include <net/dn_neigh.h>
 #include <net/dn_dev.h>
+#include <net/nexthop.h>
 
 #define RT_MIN_TABLE 1
 
@@ -150,14 +151,13 @@ static int dn_fib_count_nhs(const struct nlattr *attr)
 	struct rtnexthop *nhp = nla_data(attr);
 	int nhs = 0, nhlen = nla_len(attr);
 
-	while(nhlen >= (int)sizeof(struct rtnexthop)) {
-		if ((nhlen -= nhp->rtnh_len) < 0)
-			return 0;
+	while (rtnh_ok(nhp, nhlen)) {
 		nhs++;
-		nhp = RTNH_NEXT(nhp);
+		nhp = rtnh_next(nhp, &nhlen);
 	}
 
-	return nhs;
+	/* leftover implies invalid nexthop configuration, discard it */
+	return nhlen > 0 ? 0 : nhs;
 }
 
 static int dn_fib_get_nhs(struct dn_fib_info *fi, const struct nlattr *attr,
@@ -167,21 +167,24 @@ static int dn_fib_get_nhs(struct dn_fib_info *fi, const struct nlattr *attr,
 	int nhlen = nla_len(attr);
 
 	change_nexthops(fi) {
-		int attrlen = nhlen - sizeof(struct rtnexthop);
-		if (attrlen < 0 || (nhlen -= nhp->rtnh_len) < 0)
+		int attrlen;
+
+		if (!rtnh_ok(nhp, nhlen))
 			return -EINVAL;
 
 		nh->nh_flags  = (r->rtm_flags&~0xFF) | nhp->rtnh_flags;
 		nh->nh_oif    = nhp->rtnh_ifindex;
 		nh->nh_weight = nhp->rtnh_hops + 1;
 
-		if (attrlen) {
+		attrlen = rtnh_attrlen(nhp);
+		if (attrlen > 0) {
 			struct nlattr *gw_attr;
 
 			gw_attr = nla_find((struct nlattr *) (nhp + 1), attrlen, RTA_GATEWAY);
 			nh->nh_gw = gw_attr ? nla_get_le16(gw_attr) : 0;
 		}
-		nhp = RTNH_NEXT(nhp);
+
+		nhp = rtnh_next(nhp, &nhlen);
 	} endfor_nexthops(fi);
 
 	return 0;
-- 
1.9.1
