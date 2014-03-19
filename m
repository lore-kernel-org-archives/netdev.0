From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 3/3] ip6mr: fix mfc notification flags
Date: Wed, 19 Mar 2014 17:47:51 +0100
Message-ID: <1395247671-9356-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1395247671-9356-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56156 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965221AbaCSQs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 12:48:57 -0400
In-Reply-To: <1395247671-9356-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 812e44dd1829 ("ip6mr: advertise new mfc entries via rtnl") reuses the
function ip6mr_fill_mroute() to notify mfc events.
But this function was used only for dump and thus was always setting the
flag NLM_F_MULTI, which is wrong in case of a single notification.

Libraries like libnl will wait forever for NLMSG_DONE.

CC: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6mr.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 0eb4038a4d63..8737400af0a0 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2349,13 +2349,14 @@ int ip6mr_get_route(struct net *net,
 }
 
 static int ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
-			     u32 portid, u32 seq, struct mfc6_cache *c, int cmd)
+			     u32 portid, u32 seq, struct mfc6_cache *c, int cmd,
+			     int flags)
 {
 	struct nlmsghdr *nlh;
 	struct rtmsg *rtm;
 	int err;
 
-	nlh = nlmsg_put(skb, portid, seq, cmd, sizeof(*rtm), NLM_F_MULTI);
+	nlh = nlmsg_put(skb, portid, seq, cmd, sizeof(*rtm), flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -2423,7 +2424,7 @@ static void mr6_netlink_event(struct mr6_table *mrt, struct mfc6_cache *mfc,
 	if (skb == NULL)
 		goto errout;
 
-	err = ip6mr_fill_mroute(mrt, skb, 0, 0, mfc, cmd);
+	err = ip6mr_fill_mroute(mrt, skb, 0, 0, mfc, cmd, 0);
 	if (err < 0)
 		goto errout;
 
@@ -2462,7 +2463,8 @@ static int ip6mr_rtm_dumproute(struct sk_buff *skb, struct netlink_callback *cb)
 				if (ip6mr_fill_mroute(mrt, skb,
 						      NETLINK_CB(cb->skb).portid,
 						      cb->nlh->nlmsg_seq,
-						      mfc, RTM_NEWROUTE) < 0)
+						      mfc, RTM_NEWROUTE,
+						      NLM_F_MULTI) < 0)
 					goto done;
 next_entry:
 				e++;
@@ -2476,7 +2478,8 @@ next_entry:
 			if (ip6mr_fill_mroute(mrt, skb,
 					      NETLINK_CB(cb->skb).portid,
 					      cb->nlh->nlmsg_seq,
-					      mfc, RTM_NEWROUTE) < 0) {
+					      mfc, RTM_NEWROUTE,
+					      NLM_F_MULTI) < 0) {
 				spin_unlock_bh(&mfc_unres_lock);
 				goto done;
 			}
-- 
1.8.5.4
