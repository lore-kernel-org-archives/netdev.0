From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 2/3] ipmr: fix mfc notification flags
Date: Wed, 19 Mar 2014 17:47:50 +0100
Message-ID: <1395247671-9356-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1395247671-9356-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56155 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965141AbaCSQsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 12:48:47 -0400
In-Reply-To: <1395247671-9356-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 8cd3ac9f9b7b ("ipmr: advertise new mfc entries via rtnl") reuses the
function ipmr_fill_mroute() to notify mfc events.
But this function was used only for dump and thus was always setting the
flag NLM_F_MULTI, which is wrong in case of a single notification.

Libraries like libnl will wait forever for NLMSG_DONE.

CC: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ipmr.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index b9b3472975ba..28863570dd60 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2255,13 +2255,14 @@ int ipmr_get_route(struct net *net, struct sk_buff *skb,
 }
 
 static int ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
-			    u32 portid, u32 seq, struct mfc_cache *c, int cmd)
+			    u32 portid, u32 seq, struct mfc_cache *c, int cmd,
+			    int flags)
 {
 	struct nlmsghdr *nlh;
 	struct rtmsg *rtm;
 	int err;
 
-	nlh = nlmsg_put(skb, portid, seq, cmd, sizeof(*rtm), NLM_F_MULTI);
+	nlh = nlmsg_put(skb, portid, seq, cmd, sizeof(*rtm), flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -2329,7 +2330,7 @@ static void mroute_netlink_event(struct mr_table *mrt, struct mfc_cache *mfc,
 	if (skb == NULL)
 		goto errout;
 
-	err = ipmr_fill_mroute(mrt, skb, 0, 0, mfc, cmd);
+	err = ipmr_fill_mroute(mrt, skb, 0, 0, mfc, cmd, 0);
 	if (err < 0)
 		goto errout;
 
@@ -2368,7 +2369,8 @@ static int ipmr_rtm_dumproute(struct sk_buff *skb, struct netlink_callback *cb)
 				if (ipmr_fill_mroute(mrt, skb,
 						     NETLINK_CB(cb->skb).portid,
 						     cb->nlh->nlmsg_seq,
-						     mfc, RTM_NEWROUTE) < 0)
+						     mfc, RTM_NEWROUTE,
+						     NLM_F_MULTI) < 0)
 					goto done;
 next_entry:
 				e++;
@@ -2382,7 +2384,8 @@ next_entry:
 			if (ipmr_fill_mroute(mrt, skb,
 					     NETLINK_CB(cb->skb).portid,
 					     cb->nlh->nlmsg_seq,
-					     mfc, RTM_NEWROUTE) < 0) {
+					     mfc, RTM_NEWROUTE,
+					     NLM_F_MULTI) < 0) {
 				spin_unlock_bh(&mfc_unres_lock);
 				goto done;
 			}
-- 
1.8.5.4
