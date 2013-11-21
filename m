From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] genetlink: fix genlmsg_multicast() bug
Date: Thu, 21 Nov 2013 18:17:04 +0100
Message-ID: <1385054224-1410-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:50881 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754565Ab3KURRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 12:17:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Unfortunately, I introduced a tremendously stupid bug into
genlmsg_multicast() when doing all those multicast group
changes: it adjusts the group number, but then passes it
to genlmsg_multicast_netns() which does that again.

Somehow, my tests failed to catch this, so add a warning
into genlmsg_multicast_netns() and remove the offending
group ID adjustment.

Also add a warning to the similar code in other functions
so people who misuse them are more loudly warned.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/genetlink.h | 5 +----
 net/netlink/genetlink.c | 4 ++--
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index ace4abf..771af09 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -265,7 +265,7 @@ static inline int genlmsg_multicast_netns(struct genl_family *family,
 					  struct net *net, struct sk_buff *skb,
 					  u32 portid, unsigned int group, gfp_t flags)
 {
-	if (group >= family->n_mcgrps)
+	if (WARN_ON_ONCE(group >= family->n_mcgrps))
 		return -EINVAL;
 	group = family->mcgrp_offset + group;
 	return nlmsg_multicast(net->genl_sock, skb, portid, group, flags);
@@ -283,9 +283,6 @@ static inline int genlmsg_multicast(struct genl_family *family,
 				    struct sk_buff *skb, u32 portid,
 				    unsigned int group, gfp_t flags)
 {
-	if (group >= family->n_mcgrps)
-		return -EINVAL;
-	group = family->mcgrp_offset + group;
 	return genlmsg_multicast_netns(family, &init_net, skb,
 				       portid, group, flags);
 }
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 7dbc4f7..4518a57 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -1045,7 +1045,7 @@ static int genlmsg_mcast(struct sk_buff *skb, u32 portid, unsigned long group,
 int genlmsg_multicast_allns(struct genl_family *family, struct sk_buff *skb,
 			    u32 portid, unsigned int group, gfp_t flags)
 {
-	if (group >= family->n_mcgrps)
+	if (WARN_ON_ONCE(group >= family->n_mcgrps))
 		return -EINVAL;
 	group = family->mcgrp_offset + group;
 	return genlmsg_mcast(skb, portid, group, flags);
@@ -1062,7 +1062,7 @@ void genl_notify(struct genl_family *family,
 	if (nlh)
 		report = nlmsg_report(nlh);
 
-	if (group >= family->n_mcgrps)
+	if (WARN_ON_ONCE(group >= family->n_mcgrps))
 		return;
 	group = family->mcgrp_offset + group;
 	nlmsg_notify(sk, skb, portid, group, report, flags);
-- 
1.8.4.rc3
