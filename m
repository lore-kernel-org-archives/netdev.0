From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 2/7] ip6mr: use nla_nest_* helpers
Date: Tue,  4 Dec 2012 12:13:36 +0100
Message-ID: <1354619621-16016-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56625 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968Ab2LDLNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 06:13:49 -0500
In-Reply-To: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the skb manipulations when nested attributes are added by
using standard helpers.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6mr.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index efc6d91..653df91 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2119,8 +2119,7 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 {
 	int ct;
 	struct rtnexthop *nhp;
-	u8 *b = skb_tail_pointer(skb);
-	struct rtattr *mp_head;
+	struct nlattr *mp_attr;
 
 	/* If cache is unresolved, don't try to parse IIF and OIF */
 	if (c->mf6c_parent >= MAXMIFS)
@@ -2129,28 +2128,29 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 	if (MIF_EXISTS(mrt, c->mf6c_parent) &&
 	    nla_put_u32(skb, RTA_IIF, mrt->vif6_table[c->mf6c_parent].dev->ifindex) < 0)
 		return -EMSGSIZE;
-
-	mp_head = (struct rtattr *)skb_put(skb, RTA_LENGTH(0));
+	mp_attr = nla_nest_start(skb, RTA_MULTIPATH);
+	if (mp_attr == NULL)
+		return -EMSGSIZE;
 
 	for (ct = c->mfc_un.res.minvif; ct < c->mfc_un.res.maxvif; ct++) {
 		if (MIF_EXISTS(mrt, ct) && c->mfc_un.res.ttls[ct] < 255) {
-			if (skb_tailroom(skb) < RTA_ALIGN(RTA_ALIGN(sizeof(*nhp)) + 4))
-				goto rtattr_failure;
-			nhp = (struct rtnexthop *)skb_put(skb, RTA_ALIGN(sizeof(*nhp)));
+			nhp = nla_reserve_nohdr(skb, sizeof(*nhp));
+			if (nhp == NULL) {
+				nla_nest_cancel(skb, mp_attr);
+				return -EMSGSIZE;
+			}
+
 			nhp->rtnh_flags = 0;
 			nhp->rtnh_hops = c->mfc_un.res.ttls[ct];
 			nhp->rtnh_ifindex = mrt->vif6_table[ct].dev->ifindex;
 			nhp->rtnh_len = sizeof(*nhp);
 		}
 	}
-	mp_head->rta_type = RTA_MULTIPATH;
-	mp_head->rta_len = skb_tail_pointer(skb) - (u8 *)mp_head;
+
+	nla_nest_end(skb, mp_attr);
+
 	rtm->rtm_type = RTN_MULTICAST;
 	return 1;
-
-rtattr_failure:
-	nlmsg_trim(skb, b);
-	return -EMSGSIZE;
 }
 
 int ip6mr_get_route(struct net *net,
-- 
1.8.0.1
