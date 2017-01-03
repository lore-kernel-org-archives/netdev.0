From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next] ipmr, ip6mr: add RTNH_F_UNRESOLVED flag to unresolved cache entries
Date: Tue,  3 Jan 2017 12:13:39 +0100
Message-ID: <1483442019-20917-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f176.google.com ([209.85.210.176]:34160 "EHLO
        mail-wj0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934045AbdACLOG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 06:14:06 -0500
Received: by mail-wj0-f176.google.com with SMTP id sd9so257479834wjb.1
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 03:14:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While working with ipmr, we noticed that it is impossible to determine
if an entry is actually unresolved or its IIF interface has disappeared
(e.g. virtual interface got deleted). These entries look almost
identical to user-space when dumping or receiving notifications. So in
order to recognize them add a new RTNH_F_UNRESOLVED flag which is set when
sending an unresolved cache entry to user-space.

Suggested-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/rtnetlink.h | 1 +
 net/ipv4/ipmr.c                | 4 +++-
 net/ipv6/ip6mr.c               | 4 +++-
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index e14377f2ec27..8c93ad1ef9ab 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -350,6 +350,7 @@ struct rtnexthop {
 #define RTNH_F_ONLINK		4	/* Gateway is forced on link	*/
 #define RTNH_F_OFFLOAD		8	/* offloaded route */
 #define RTNH_F_LINKDOWN		16	/* carrier-down on nexthop */
+#define RTNH_F_UNRESOLVED	32	/* The entry is unresolved (ipmr) */
 
 #define RTNH_COMPARE_MASK	(RTNH_F_DEAD | RTNH_F_LINKDOWN | RTNH_F_OFFLOAD)
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index efc1e76d4977..b35dda57586b 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2091,8 +2091,10 @@ static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 	int ct;
 
 	/* If cache is unresolved, don't try to parse IIF and OIF */
-	if (c->mfc_parent >= MAXVIFS)
+	if (c->mfc_parent >= MAXVIFS) {
+		rtm->rtm_flags |= RTNH_F_UNRESOLVED;
 		return -ENOENT;
+	}
 
 	if (VIF_EXISTS(mrt, c->mfc_parent) &&
 	    nla_put_u32(skb, RTA_IIF, mrt->vif_table[c->mfc_parent].dev->ifindex) < 0)
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 604d8953c775..e275077e8af2 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2243,8 +2243,10 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 	int ct;
 
 	/* If cache is unresolved, don't try to parse IIF and OIF */
-	if (c->mf6c_parent >= MAXMIFS)
+	if (c->mf6c_parent >= MAXMIFS) {
+		rtm->rtm_flags |= RTNH_F_UNRESOLVED;
 		return -ENOENT;
+	}
 
 	if (MIF_EXISTS(mrt, c->mf6c_parent) &&
 	    nla_put_u32(skb, RTA_IIF, mrt->vif6_table[c->mf6c_parent].dev->ifindex) < 0)
-- 
2.1.4
