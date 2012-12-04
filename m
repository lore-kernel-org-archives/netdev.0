From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 5/7] ipmr/ip6mr: allow to get unresolved cache via netlink
Date: Tue,  4 Dec 2012 12:13:39 +0100
Message-ID: <1354619621-16016-6-git-send-email-nicolas.dichtel@6wind.com>
References: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56639 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287Ab2LDLNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 06:13:50 -0500
In-Reply-To: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

/proc/net/ip[6]_mr_cache allows to get all mfc entries, even if they are put in
the unresolved list (mfc[6]_unres_queue). But only the table RT_TABLE_DEFAULT is
displayed.
This patch adds the parsing of the unresolved list when the dump is made via
rtnetlink, hence each table can be checked.

In IPv6, we set rtm_type in ip6mr_fill_mroute(), because in case of unresolved
mfc __ip6mr_fill_mroute() will not set it. In IPv4, it is already done.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ipmr.c  | 21 ++++++++++++++++++++-
 net/ipv6/ip6mr.c | 22 +++++++++++++++++++++-
 2 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 91782a7..084dac3 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2154,6 +2154,7 @@ static int ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 {
 	struct nlmsghdr *nlh;
 	struct rtmsg *rtm;
+	int err;
 
 	nlh = nlmsg_put(skb, portid, seq, RTM_NEWROUTE, sizeof(*rtm), NLM_F_MULTI);
 	if (nlh == NULL)
@@ -2178,7 +2179,9 @@ static int ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 	if (nla_put_be32(skb, RTA_SRC, c->mfc_origin) ||
 	    nla_put_be32(skb, RTA_DST, c->mfc_mcastgrp))
 		goto nla_put_failure;
-	if (__ipmr_fill_mroute(mrt, skb, c, rtm) < 0)
+	err = __ipmr_fill_mroute(mrt, skb, c, rtm);
+	/* do not break the dump if cache is unresolved */
+	if (err < 0 && err != -ENOENT)
 		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
@@ -2221,6 +2224,22 @@ next_entry:
 			}
 			e = s_e = 0;
 		}
+		spin_lock_bh(&mfc_unres_lock);
+		list_for_each_entry(mfc, &mrt->mfc_unres_queue, list) {
+			if (e < s_e)
+				goto next_entry2;
+			if (ipmr_fill_mroute(mrt, skb,
+					     NETLINK_CB(cb->skb).portid,
+					     cb->nlh->nlmsg_seq,
+					     mfc) < 0) {
+				spin_unlock_bh(&mfc_unres_lock);
+				goto done;
+			}
+next_entry2:
+			e++;
+		}
+		spin_unlock_bh(&mfc_unres_lock);
+		e = s_e = 0;
 		s_h = 0;
 next_table:
 		t++;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index e9ef38f..175270f 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2235,6 +2235,7 @@ static int ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 {
 	struct nlmsghdr *nlh;
 	struct rtmsg *rtm;
+	int err;
 
 	nlh = nlmsg_put(skb, portid, seq, RTM_NEWROUTE, sizeof(*rtm), NLM_F_MULTI);
 	if (nlh == NULL)
@@ -2248,6 +2249,7 @@ static int ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 	rtm->rtm_table    = mrt->id;
 	if (nla_put_u32(skb, RTA_TABLE, mrt->id))
 		goto nla_put_failure;
+	rtm->rtm_type = RTN_MULTICAST;
 	rtm->rtm_scope    = RT_SCOPE_UNIVERSE;
 	if (c->mfc_flags & MFC_STATIC)
 		rtm->rtm_protocol = RTPROT_STATIC;
@@ -2258,7 +2260,9 @@ static int ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 	if (nla_put(skb, RTA_SRC, 16, &c->mf6c_origin) ||
 	    nla_put(skb, RTA_DST, 16, &c->mf6c_mcastgrp))
 		goto nla_put_failure;
-	if (__ip6mr_fill_mroute(mrt, skb, c, rtm) < 0)
+	err = __ip6mr_fill_mroute(mrt, skb, c, rtm);
+	/* do not break the dump if cache is unresolved */
+	if (err < 0 && err != -ENOENT)
 		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
@@ -2301,6 +2305,22 @@ next_entry:
 			}
 			e = s_e = 0;
 		}
+		spin_lock_bh(&mfc_unres_lock);
+		list_for_each_entry(mfc, &mrt->mfc6_unres_queue, list) {
+			if (e < s_e)
+				goto next_entry2;
+			if (ip6mr_fill_mroute(mrt, skb,
+					      NETLINK_CB(cb->skb).portid,
+					      cb->nlh->nlmsg_seq,
+					      mfc) < 0) {
+				spin_unlock_bh(&mfc_unres_lock);
+				goto done;
+			}
+next_entry2:
+			e++;
+		}
+		spin_unlock_bh(&mfc_unres_lock);
+		e = s_e = 0;
 		s_h = 0;
 next_table:
 		t++;
-- 
1.8.0.1
