From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/7] ipmr: Do not use RTA_PUT() macros
Date: Wed, 27 Jun 2012 11:36:13 +0200
Message-ID: <1dbce6d3050ac4dec8896ff3e6789839c8ba8ae7.1340788373.git.tgraf@suug.ch>
References: <cover.1340788373.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50743 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756630Ab2F0JgY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 05:36:24 -0400
In-Reply-To: <cover.1340788373.git.tgraf@suug.ch>
In-Reply-To: <cover.1340788373.git.tgraf@suug.ch>
References: <cover.1340788373.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also fix a needless skb tailroom check for a 4 bytes area
after after each rtnexthop block.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv4/ipmr.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index c94bbc6..b4ac39f 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2006,37 +2006,37 @@ static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 {
 	int ct;
 	struct rtnexthop *nhp;
-	u8 *b = skb_tail_pointer(skb);
-	struct rtattr *mp_head;
+	struct nlattr *mp_attr;
 
 	/* If cache is unresolved, don't try to parse IIF and OIF */
 	if (c->mfc_parent >= MAXVIFS)
 		return -ENOENT;
 
-	if (VIF_EXISTS(mrt, c->mfc_parent))
-		RTA_PUT(skb, RTA_IIF, 4, &mrt->vif_table[c->mfc_parent].dev->ifindex);
+	if (VIF_EXISTS(mrt, c->mfc_parent) &&
+	    nla_put_u32(skb, RTA_IIF, mrt->vif_table[c->mfc_parent].dev->ifindex) < 0)
+		return -EMSGSIZE;
 
-	mp_head = (struct rtattr *)skb_put(skb, RTA_LENGTH(0));
+	if (!(mp_attr = nla_nest_start(skb, RTA_MULTIPATH)))
+		return -EMSGSIZE;
 
 	for (ct = c->mfc_un.res.minvif; ct < c->mfc_un.res.maxvif; ct++) {
 		if (VIF_EXISTS(mrt, ct) && c->mfc_un.res.ttls[ct] < 255) {
-			if (skb_tailroom(skb) < RTA_ALIGN(RTA_ALIGN(sizeof(*nhp)) + 4))
-				goto rtattr_failure;
-			nhp = (struct rtnexthop *)skb_put(skb, RTA_ALIGN(sizeof(*nhp)));
+			if (!(nhp = nla_reserve_nohdr(skb, sizeof(*nhp)))) {
+				nla_nest_cancel(skb, mp_attr);
+				return -EMSGSIZE;
+			}
+
 			nhp->rtnh_flags = 0;
 			nhp->rtnh_hops = c->mfc_un.res.ttls[ct];
 			nhp->rtnh_ifindex = mrt->vif_table[ct].dev->ifindex;
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
 
 int ipmr_get_route(struct net *net, struct sk_buff *skb,
-- 
1.7.7.6
